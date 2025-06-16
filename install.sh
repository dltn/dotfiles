#!/usr/bin/env bash
# Sets up bash scripts that should work on any system

# bashrc
if ! grep -q ".bashrc.d" ~/.bashrc
then
    echo "Setting up ~/.bashrc.d in ~/.bashrc..."
    cat source_bashrcd.sh >> ~/.bashrc
fi

mkdir -p ~/.bashrc.d/
chmod 0755 ~/.bashrc.d/
cp -iv bashrc_scripts/* ~/.bashrc.d/

# vim
cp -iv .vimrc ~/.vimrc
mkdir -p ~/.vim/swp

# tmux
cp -iv .tmux.conf ~/.tmux.conf

# extras
echo "Install extras? [y/N]"
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
        sh extras_install.sh
fi


# configure git
sh ./setup_git_config.sh
