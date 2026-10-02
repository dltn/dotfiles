#!/usr/bin/env bash
# Merge a tmux session's windows into one window of side-by-side columns, and explode them back out.
# For a wide monitor: each window becomes a full-height column that keeps its own pane layout.
#
# Usage, from the key binding in .tmux.conf:
#   tmux_merge.sh toggle <session-id>    # explode if the session has merged windows, otherwise merge
#   tmux_merge.sh merge <session-id>     # every window except pinned ones (@pinned) -> columns of the first
#   tmux_merge.sh explode <session-id>   # each column -> its own window again, under its old name
#
# merge tags every pane with the window it came from: @merge_group (the window's position), @merge_name,
# @merge_auto (set if tmux was naming the window automatically) and @merge_layout. explode goes by column,
# so panes opened, closed or resized while merged stay with their column. If the columns are gone (say the
# layout was cycled) it regroups the panes by tag instead and puts back each window's saved layout.
#
# The merged window also gets @merge_tab, a format for its tab that .tmux.conf uses in place of the name:
# the windows' names joined by +, each behind a copy of @merge_fg (if set) to colour it by its own panes.

session=$2

# tmux only accepts a layout string that starts with this checksum of the rest
with_csum() {
    local s=$1 csum=0 i c
    for ((i = 0; i < ${#s}; i++)); do
        printf -v c %d "'${s:i:1}"
        csum=$((((csum >> 1) + ((csum & 1) << 15) + c) & 0xffff))
    done
    printf '%04x,%s' "$csum" "$s"
}

# The pane ids in a layout, in order. Only a pane has four numbers in a row: WxH,X,Y,id
pane_ids() { grep -oE '[0-9]+x[0-9]+,[0-9]+,[0-9]+,[0-9]+' <<< "$1" | sed 's/.*,/%/'; }

# The cells inside a split cell, one per line, given what is between its brackets
children() {
    local s=$1 depth=0 start=0 i
    for ((i = 0; i < ${#s}; i++)); do
        case ${s:i:1} in
            '{' | '[') depth=$((depth + 1)) ;;
            '}' | ']') depth=$((depth - 1)) ;;
            ,) # a comma followed by WxH starts the next cell; the others sit inside a cell
                if ((depth == 0)) && [[ ${s:i+1} =~ ^[0-9]+x ]]; then
                    echo "${s:start:i-start}"
                    start=$((i + 1))
                fi
                ;;
        esac
    done
    echo "${s:start}"
}

# Layout cell $1 resized to $2 columns by $3 rows, every split keeping its proportions. tmux's own resizing
# squashes the first pane of a nested split instead. Offsets are left at 0, as tmux works them out itself.
scale() {
    local re='^([0-9]+)x([0-9]+),[0-9]+,[0-9]+(,[0-9]+|[[{](.*)[]}])$'
    [[ $1 =~ $re ]] || return 1
    local width=${BASH_REMATCH[1]} height=${BASH_REMATCH[2]} rest=${BASH_REMATCH[3]} inside=${BASH_REMATCH[4]}
    if [ -z "$inside" ]; then
        echo "$2x$3,0,0$rest" # a pane
        return
    fi

    local open=${rest:0:1} kids gaps old new kid size seen=0 used=0 out=
    kids=$(children "$inside")
    gaps=$(($(grep -c . <<< "$kids") - 1)) # one border between each pair
    if [ "$open" = '{' ]; then
        old=$((width - gaps)) new=$(($2 - gaps))
    else
        old=$((height - gaps)) new=$(($3 - gaps))
    fi
    while read -r kid; do
        size=${kid%%,*}
        if [ "$open" = '{' ]; then size=${size%x*}; else size=${size#*x}; fi
        seen=$((seen + size))
        size=$(((seen * new + old / 2) / old - used)) # rounding the running total keeps the sum exact
        ((size > 0)) || size=1
        used=$((used + size))
        if [ "$open" = '{' ]; then
            out=${out:+$out,}$(scale "$kid" "$size" "$3")
        else
            out=${out:+$out,}$(scale "$kid" "$2" "$size")
        fi
    done <<< "$kids"
    echo "$2x$3,0,0$open$out${rest: -1}"
}

# The first of the given panes that merge tagged
tagged() {
    local pane
    for pane; do
        [ -z "$(tmux display -p -t "$pane" '#{@merge_group}')" ] || { echo "$pane" && return; }
    done
}

# Move pane $1 to sit after pane $2. If $2 has been split too small to split again, even its window out first.
join() {
    tmux join-pane -d -h -s "$1" -t "$2" 2> /dev/null && return
    tmux select-layout -t "$2" tiled
    tmux join-pane -d -h -s "$1" -t "$2"
}

merge() {
    explode # start from plain windows, so merging again picks up windows opened since

    local wins count target active width height free win pane layout name auto names tab fg cells last k=0
    wins=$(tmux list-windows -t "$session" -F '#{?@pinned,,#{window_id}}' | grep .)
    count=$(grep -c . <<< "$wins")
    if ((count < 2)); then
        tmux display "nothing to merge"
        return
    fi
    target=$(head -n 1 <<< "$wins")
    active=$(tmux display -p -t "$session" '#{pane_id}')
    tmux select-window -t "$target"
    read -r width height <<< "$(tmux display -p -t "$target" '#{window_width} #{window_height}')"
    free=$((width - count + 1)) # what is left for panes after the borders between columns
    fg=$(tmux show -gqv @merge_fg)

    for win in $wins; do
        k=$((k + 1))
        layout=$(tmux display -p -t "$win" '#{window_layout}')
        layout=${layout#*,}
        name=$(tmux display -p -t "$win" '#{window_name}')
        auto=$(tmux display -p -t "$win" '#{?automatic-rename,1,}')
        names=${names:+$names+}$name
        tab=${tab:+$tab#[default]+}${fg//GROUP/$k}${name//\#/##}
        cells=${cells:+$cells,}$(scale "$layout" "$((k * free / count - (k - 1) * free / count))" "$height")
        for pane in $(tmux list-panes -t "$win" -F '#{pane_id}'); do
            tmux set -p -t "$pane" @merge_group "$k"
            tmux set -p -t "$pane" @merge_name "$name"
            tmux set -p -t "$pane" @merge_auto "$auto"
            tmux set -p -t "$pane" @merge_layout "$layout"
            [ "$win" = "$target" ] || join "$pane" "$last"
            last=$pane
        done
    done

    tmux select-layout -t "$target" "$(with_csum "${width}x$height,0,0{$cells}")"
    tmux rename-window -t "$target" -- "$names"
    tmux set -w -t "$target" @merge_tab "$tab"
    tmux select-pane -t "$active"
}

# Group the panes of merged window $win by column, filling panes[1..n] and layouts[1..n] with one entry
# per window to bring back. A column is a run of neighbouring top-level cells from the same window; a cell
# of untagged panes (split off while merged) joins the column on its left. Fails if the columns are gone.
by_column() {
    local re='^[0-9]+x([0-9]+),[0-9]+,[0-9]+\{(.*)\}$' cell tag prev seen=" " height i
    [[ $layout =~ $re ]] || return 1 # not split into columns
    height=${BASH_REMATCH[1]}
    n=0
    while read -r cell; do
        tag=$(for pane in $(pane_ids "$cell"); do tmux display -p -t "$pane" '#{@merge_group}'; done | sort -u | grep .)
        [ "$(grep -c . <<< "$tag")" -le 1 ] || return 1 # panes from two windows share a cell
        if ((n == 0)) || { [ -n "$tag" ] && [ -n "$prev" ] && [ "$tag" != "$prev" ]; }; then
            n=$((n + 1))
            panes[n]=
            cells[n]=
            widths[n]=-1
        fi
        if [ -n "$tag" ] && [ "$tag" != "$prev" ]; then
            [[ $seen != *" $tag "* ]] || return 1 # one window's panes are in two places
            seen="$seen$tag "
            prev=$tag
        fi
        panes[n]="${panes[n]} $(pane_ids "$cell" | tr '\n' ' ')"
        cells[n]=${cells[n]:+${cells[n]},}$cell
        widths[n]=$((widths[n] + 1 + ${cell%%x*}))
    done < <(children "${BASH_REMATCH[2]}")

    for ((i = 1; i <= n; i++)); do
        if [ "${cells[i]%%x*}" = "${widths[i]}" ]; then
            layouts[i]=${cells[i]}
        else
            layouts[i]="${widths[i]}x$height,0,0{${cells[i]}}"
        fi
    done
}

# The fallback: group the panes by the window they came from, with its saved layout if that still fits.
# Untagged panes stay with the first window.
by_tag() {
    local all tag saved
    all=$(tmux list-panes -t "$win" -F '#{pane_id} #{@merge_group}')
    n=0
    for tag in $(awk 'NF > 1 { print $2 }' <<< "$all" | sort -nu); do
        n=$((n + 1))
        panes[n]=$(awk -v tag="$tag" -v n="$n" '$2 == tag || (n == 1 && NF == 1) { print $1 }' <<< "$all" | tr '\n' ' ')
        saved=$(tmux display -p -t "$(tagged ${panes[n]})" '#{@merge_layout}')
        if [ "$(pane_ids "$saved" | grep -c .)" -eq "$(wc -w <<< "${panes[n]}")" ]; then
            layouts[n]=$saved
        else
            layouts[n]=tiled
        fi
    done
}

explode_window() {
    local win=$1 layout active current all n i pane tag first prev name auto width height
    local -a panes layouts cells widths
    layout=$(tmux display -p -t "$win" '#{window_layout}')
    layout=${layout#*,}
    active=$(tmux display -p -t "$win" '#{pane_id}')
    current=$(tmux display -p -t "$session" '#{window_id}')
    all=$(tmux list-panes -t "$win" -F '#{pane_id}')
    by_column || by_tag

    # Last column first: each new window lands just after this one, and the first column is left behind
    for ((i = n; i >= 1; i--)); do
        set -- ${panes[i]}
        first=$1
        name=$(tmux display -p -t "$(tagged "$@")" '#{@merge_name}')
        auto=$(tmux display -p -t "$(tagged "$@")" '#{@merge_auto}')
        if ((i > 1)); then
            tmux break-pane -d -a -s "$first" -t "$win"
            shift
            prev=$first
            for pane; do
                join "$pane" "$prev"
                prev=$pane
            done
        fi
        if [ -n "$auto" ]; then
            tmux set -wu -t "$first" automatic-rename
        else
            tmux rename-window -t "$first" -- "$name"
        fi
        if [ "${layouts[i]}" != tiled ]; then
            read -r width height <<< "$(tmux display -p -t "$first" '#{window_width} #{window_height}')"
            layouts[i]=$(with_csum "$(scale "${layouts[i]}" "$width" "$height")")
        fi
        tmux select-layout -t "$first" "${layouts[i]}"
    done

    for pane in $all; do
        for tag in @merge_group @merge_name @merge_auto @merge_layout; do
            tmux set -pu -t "$pane" "$tag"
        done
    done
    tmux set -wu -t "$win" @merge_tab
    tmux select-pane -t "$active"
    [ "$win" != "$current" ] || tmux select-window -t "$active"
}

# The session's windows that hold merged panes
merged() { tmux list-panes -s -t "$session" -F '#{?@merge_group,#{window_id},}' | sort -u | grep .; }

explode() {
    local win
    for win in $(merged); do
        explode_window "$win"
    done
}

case $1 in
    toggle) if merged > /dev/null; then explode; else merge; fi ;;
    merge) merge ;;
    explode) explode ;;
esac
