# Claude Code state in tmux

Colours tmux by what each [Claude Code](https://claude.com/claude-code) session is doing: green while Claude is
working, orange when it's waiting on you (finished, or asking for permission or input).

Pane borders are coloured as soon as it's installed. Window tabs and pane titles take a line or two in your own
config. This folder works on its own, without the rest of these dotfiles.

### Setup

Needs `jq`. Tested with tmux 3.4.

1. Copy this folder to wherever it will live, say `~/.config/claude_tmux`.
2. Run `./setup_claude_hooks.sh`. It merges the hooks in `claude_hooks.json` into `~/.claude/settings.json` and
   leaves your other settings and hooks alone. It is safe to re-run; run it again if you move the folder.
3. Add this to your `~/.tmux.conf`, with your path, then reload tmux:

   ```
   source-file ~/.config/claude_tmux/claude.tmux.conf
   ```

### Tabs and pane titles

Your tab and title formats are yours, so the colour is something you add to them. `#{E:@claude_fg}` colours
whatever follows it by the state of the window's Claudes (waiting wins if they differ), and
`#{E:@claude_pane_fg}` does the same for a single pane. Neither changes anything where no Claude is running.

For tabs, with tmux's stock format:

```
set -g window-status-format '#{E:@claude_fg}#I:#W#{?window_flags,#{window_flags}, }'
set -g window-status-current-format '#{E:@claude_fg}#I:#W#{?window_flags,#{window_flags}, }'
```

For pane titles:

```
set -g pane-border-status top
set -g pane-border-format '#{E:@claude_pane_fg} #{pane_title} #[default]'
```

With [merge_tmux](../merge_tmux), which joins a session's windows into one, each name in the merged window's
tab is coloured by its own panes. Its README has the tab format for that.

### Colours

The defaults suit a dark status bar; on tmux's stock green one, pick others. Set any of these after the
`source-file` line:

```
set -g @claude_waiting colour208        # waiting: tabs, titles, the active pane's border
set -g @claude_waiting_dim colour130    # waiting: other panes' borders
set -g @claude_working colour71
set -g @claude_working_dim colour28
set -g @claude_border fg=colour240      # border style of panes with no Claude in them
set -g @claude_active_border fg=colour250
```

### How it works

The hooks run `claude_tmux_state.sh` as a session starts work, stops, or asks for something, and it records
`working` or `waiting` in the tmux pane option `@claude_state`. `claude.tmux.conf` turns that into colours. A
pane that is no longer running Claude is ignored, so a killed session can't leave a stale colour behind.
