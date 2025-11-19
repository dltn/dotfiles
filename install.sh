#!/usr/bin/env bash
# Sets up dotfiles that should work on any system

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# vim
if ! grep -q "source.*dotfiles/.vimrc" ~/.vimrc 2>/dev/null; then
    echo "source $DOTFILES_DIR/.vimrc" >> ~/.vimrc
    echo "Added source for .vimrc"
fi
mkdir -p ~/.vim/swp

# tmux
if ! grep -q "source.*dotfiles/.tmux.conf" ~/.tmux.conf 2>/dev/null; then
    echo "source-file $DOTFILES_DIR/.tmux.conf" >> ~/.tmux.conf
    echo "Added source for .tmux.conf"
fi

# aliases
if ! grep -q "source.*dotfiles/aliases.sh" ~/.zshrc 2>/dev/null; then
    echo "source $DOTFILES_DIR/aliases.sh" >> ~/.zshrc
    echo "Added source for aliases.sh to ~/.zshrc"
fi

# extras
echo "Install extras? [y/N]"
read answer
if [ "$answer" != "${answer#[Yy]}" ]; then
    sh extras_install.sh
fi

# configure git
sh ./setup_git_config.sh
