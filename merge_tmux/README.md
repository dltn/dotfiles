# Merge tmux windows into columns

For a wide monitor: one key joins every window in a tmux session into a single window, each as a full-height
column that keeps its own pane layout. The same key explodes the columns back into windows, under their old
names and in their old order.

This folder works on its own, without the rest of these dotfiles.

### Setup

Needs bash. Tested with tmux 3.4 on Linux.

1. Copy this folder to wherever it will live, say `~/.config/merge_tmux`.
2. Add this to your `~/.tmux.conf`, with your path, then reload tmux:

   ```
   source-file ~/.config/merge_tmux/merge.tmux.conf
   ```

### Keys

- `<prefix> X` merges, or explodes if the session is already merged.
- `<prefix> P` pins the current window, or unpins it. Merges leave pinned windows alone.

For other keys, rebind after the `source-file` line. The commands are in `merge.tmux.conf`.

### What to expect

- The merged window is named after its windows: `news+longangle+apt`.
- Panes you open, close or resize while merged go back with the column they are in.
- If the columns get scrambled, say by cycling layouts, explode regroups the panes by the window they came
  from and gives each window back the layout it had.
- To pick up a window opened since, explode and merge again.
- Zoom is dropped by a merge, and exploded windows get new window ids.

### Tabs and pane titles

Both are optional, and go in your own formats.

To show a `P` on a pinned window's tab, use `#{E:@merge_flags}` where your tab format has `#{window_flags}`.
With tmux's stock format:

```
set -g window-status-format '#I:#W#{?#{E:@merge_flags},#{E:@merge_flags}, }'
set -g window-status-current-format '#I:#W#{?#{E:@merge_flags},#{E:@merge_flags}, }'
```

To show which window each pane of a merged window came from, use the pane's `@merge_name`:

```
set -g pane-border-status top
set -g pane-border-format '#{?@merge_group, #{@merge_name}:,} #{pane_title} '
```

### With claude_tmux

With [claude_tmux](../claude_tmux) sourced as well, each name in a merged window's tab can be coloured by the
Claude Code sessions in its own panes. Use `#{E:@merge_names}` in place of `#W`:

```
set -g window-status-format '#{E:@claude_fg}#I:#{E:@merge_names}#{?#{E:@merge_flags},#{E:@merge_flags}, }'
set -g window-status-current-format '#{E:@claude_fg}#I:#{E:@merge_names}#{?#{E:@merge_flags},#{E:@merge_flags}, }'
```

### How it works

`merge.sh` tags every pane with the window it came from, in the pane options `@merge_group`, `@merge_name`,
`@merge_auto` and `@merge_layout`, then moves the panes into the first unpinned window and applies one layout
with each window's own layout as a column. It rescales the layouts itself, because tmux's own resizing
squashes the first pane of a nested split. Explode reads the columns back off the screen, falls back to the
tags if the columns are gone, and clears the tags.
