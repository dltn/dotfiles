# [@dltn](https://github.com/dltn)'s dotfiles

[What are dotfiles?](https://dotfiles.github.io)

### Installation

Clone into a standalone directory and pull/push files as needed:

```
git clone git@github.com:dltn/dotfiles.git
```

For automated install of the standard setup, run `install.sh`.


### Droplet user setup
Run `curl -fsSL https://raw.githubusercontent.com/dltn/dotfiles/master/setup_dalton_user.sh | sh` as root to create the `dalton` user with sudo privileges, generate an SSH key and print the public key for use at [GitHub](https://github.com/settings/keys). If `/root/dotfiles` exists, the repository will be cloned to `/home/dalton/dotfiles` with the remote set to `git@github.com:dltn/dotfiles.git`.
