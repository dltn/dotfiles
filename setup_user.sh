#!/usr/bin/env bash
# Create user with sudo privileges and generate an SSH key.
# Prints the public key for easy GitHub setup.
# Usage: ./setup_user.sh <username>

set -e

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root." >&2
  exit 1
fi

if [ $# -eq 0 ]; then
  echo "Usage: $0 <username>" >&2
  echo "Example: $0 dalton" >&2
  exit 1
fi

USER_NAME="$1"
SSH_KEY="/home/$USER_NAME/.ssh/id_ed25519"

# Validate username
if [[ ! "$USER_NAME" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
  echo "Error: Invalid username '$USER_NAME'. Use only lowercase letters, numbers, underscores, and hyphens." >&2
  exit 1
fi

if id "$USER_NAME" >/dev/null 2>&1; then
  echo "User $USER_NAME already exists."
else
  adduser --disabled-password --gecos "" "$USER_NAME"
  usermod -aG sudo "$USER_NAME"
fi

# ensure .ssh directory exists with correct permissions
su - "$USER_NAME" -c "mkdir -p ~/.ssh && chmod 700 ~/.ssh"

if [ ! -f "$SSH_KEY" ]; then
  su - "$USER_NAME" -c "ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N '' -C '$USER_NAME@$(hostname)'"
fi

PUB_KEY=$(cat "$SSH_KEY.pub")

cat <<EOM
Public key for user $USER_NAME:
$PUB_KEY

Add this key to your GitHub account: https://github.com/settings/keys
EOM

# clone dotfiles repo
echo "Cloning dotfiles repository..."
su - "$USER_NAME" -c "git clone https://github.com/dltn/dotfiles.git ~/dotfiles"
su - "$USER_NAME" -c "cd ~/dotfiles && git remote set-url origin git@github.com:dltn/dotfiles.git"
echo "Cloned dotfiles into /home/$USER_NAME/dotfiles and set SSH remote."
