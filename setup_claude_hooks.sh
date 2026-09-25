#!/usr/bin/env bash
# Merge the hooks in claude_hooks.json into Claude Code's user settings (~/.claude/settings.json).
# Safe to re-run: hooks from an earlier run are replaced, everything else in the file is kept.

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
SETTINGS=~/.claude/settings.json

if ! command -v jq > /dev/null; then
    echo "jq not found, skipping Claude Code hooks"
    exit 0
fi

mkdir -p ~/.claude
[ -s "$SETTINGS" ] || echo '{}' > "$SETTINGS"
trap 'rm -f "$SETTINGS.tmp"' EXIT

# Drop every hook entry that runs claude_tmux_state.sh, then add the current set with $DOTFILES_DIR filled in.
# jq writes to a temp file first, so a failed merge never leaves a broken settings.json behind.
jq --arg dir "$DOTFILES_DIR" --slurpfile ours "$DOTFILES_DIR/claude_hooks.json" '
    def is_ours: any(.hooks[]?; (.command // "") | contains("claude_tmux_state.sh"));
    .hooks = ((.hooks // {}) | map_values(map(select(is_ours | not))) | with_entries(select(.value | length > 0)))
    | reduce ($ours[0].hooks | to_entries[]) as $e (.;
        .hooks[$e.key] += ($e.value | map(.hooks |= map(.command |= sub("\\$DOTFILES_DIR"; $dir)))))
' "$SETTINGS" > "$SETTINGS.tmp"
mv "$SETTINGS.tmp" "$SETTINGS"

echo "Merged Claude Code hooks into $SETTINGS"
