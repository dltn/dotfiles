#!/usr/bin/env bash

if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "This script is intended for MacOS. Are you sure this is MacOS?"
  exit 1
fi

# cp -iv to (1) prompt before overwrite and (2) be verbose (https://linux.die.net/man/1/cp)
# mkdir -p for "no error if existing, make parent directories as needed" (https://linux.die.net/man/1/mkdir)

mkdir -p ~/.config/karabiner/
cp -iv karabiner.json ~/.config/karabiner/
