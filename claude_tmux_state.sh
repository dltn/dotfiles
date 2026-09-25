#!/usr/bin/env bash
# Claude Code hook -> tmux. Records whether the Claude in this pane is working or waiting on you in the
# pane option @claude_state; .tmux.conf colours the window tab from it (green = working, orange = waiting).
#
# Usage, from the hooks in claude_hooks.json (setup_claude_hooks.sh merges them into ~/.claude/settings.json):
#   claude_tmux_state.sh working   # UserPromptSubmit, PostToolUse, PostToolUseFailure
#   claude_tmux_state.sh tool      # PreToolUse: working, unless the tool stops to ask you something
#   claude_tmux_state.sh waiting   # Stop, StopFailure, Notification, SessionStart
#   claude_tmux_state.sh clear     # SessionEnd

[ -n "$TMUX_PANE" ] || exit 0 # not inside tmux

state=$1
if [ "$state" = tool ]; then
    # the hook input JSON arrives on stdin
    if grep -Eq '"tool_name" *: *"(AskUserQuestion|ExitPlanMode)"'; then
        state=waiting
    else
        state=working
    fi
fi

case $state in
    working | waiting) tmux set -p -t "$TMUX_PANE" @claude_state "$state" ;;
    clear) tmux set -pu -t "$TMUX_PANE" @claude_state ;;
esac
exit 0
