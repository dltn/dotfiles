# [@dltn](https://github.com/dltn)'s dotfiles

[What are dotfiles?](https://dotfiles.github.io)

### Installation

Clone into a standalone directory and pull/push files as needed:

```
git clone git@github.com:dltn/dotfiles.git
```

For automated install of the standard setup, run `install.sh`.

`install.sh` also merges the [Claude Code](https://claude.com/claude-code) hooks in `claude_hooks.json` into
`~/.claude/settings.json` (needs `jq`). They tell tmux what each Claude session is doing, so a window's tab turns
green while Claude is working and orange when it's waiting on you.


### Remote Setup

```
curl -fsSL https://raw.githubusercontent.com/dltn/dotfiles/main/setup_user.sh | sudo bash -s dalton
``` 

