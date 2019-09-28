#!/usr/bin/env bash
# Sets up bash scripts that should work on any system

if ! grep -q ".bashrc.d" ~/.bashrc
then
    echo "Setting up ~/.bashrc.d in ~/.bashrc..."
    cat source_bashrcd.sh >> ~/.bashrc
fi

mkdir -p ~/.bashrc.d/
chmod 0755 ~/.bashrc.d/
cp -iv bashrc_scripts/* ~/.bashrc.d/

