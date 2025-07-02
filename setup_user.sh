#!/usr/bin/env bash
# Create user with sudo privileges and generate an SSH key.
# Interactive setup script with optional GitHub key import and dotfiles setup.
# Usage: ./script.sh [username] [github_username]

set -e

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root." >&2
  exit 1
fi

# Interactive prompts for username and GitHub username
if [ -z "$1" ]; then
  read -p "Enter username to create: " USER_NAME </dev/tty
else
  USER_NAME="$1"
fi

if [ -z "$2" ]; then
  read -p "Enter GitHub username to fetch SSH keys from (or press Enter to skip): " GITHUB_USER </dev/tty
else
  GITHUB_USER="$2"
fi

SSH_KEY="/home/$USER_NAME/.ssh/id_ed25519"
AUTHORIZED_KEYS="/home/$USER_NAME/.ssh/authorized_keys"

# Validate username
if [[ ! "$USER_NAME" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
  echo "Error: Invalid username '$USER_NAME'. Use only lowercase letters, numbers, underscores, and hyphens." >&2
  exit 1
fi

echo "Creating user '$USER_NAME'..."
if id "$USER_NAME" >/dev/null 2>&1; then
  echo "User $USER_NAME already exists."
else
  adduser --disabled-password --gecos "" "$USER_NAME"
  usermod -aG sudo "$USER_NAME"
  echo "User $USER_NAME created and added to sudo group."
fi

# Ensure .ssh directory exists with correct permissions
echo "Setting up SSH directory..."
su - "$USER_NAME" -c "mkdir -p ~/.ssh && chmod 700 ~/.ssh"

# Generate SSH key if it doesn't exist
if [ ! -f "$SSH_KEY" ]; then
  echo "Generating SSH key..."
  su - "$USER_NAME" -c "ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N '' -C \"$USER_NAME@\$(hostname)\""
  echo "SSH key generated."
else
  echo "SSH key already exists."
fi

PUB_KEY=$(cat "$SSH_KEY.pub")

# Clone dotfiles repo
echo "Setting up dotfiles..."
if su - "$USER_NAME" -c "git clone https://github.com/dltn/dotfiles.git ~/dotfiles"; then
  su - "$USER_NAME" -c "cd ~/dotfiles && git remote set-url origin git@github.com:dltn/dotfiles.git"
  echo "Dotfiles cloned and SSH remote configured."
else
  echo "Warning: Failed to clone dotfiles repository. You may need to set it up manually." >&2
fi

# Fetch GitHub SSH keys if username provided
if [ -n "$GITHUB_USER" ]; then
  echo "Fetching SSH keys from GitHub for user '$GITHUB_USER'..."
  if GITHUB_KEYS=$(curl -fsSL "https://github.com/$GITHUB_USER.keys" 2>/dev/null) && [ -n "$GITHUB_KEYS" ]; then
    # Create authorized_keys file if it doesn't exist
    su - "$USER_NAME" -c "touch ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
    
    # Add GitHub keys to authorized_keys, avoiding duplicates
    echo "$GITHUB_KEYS" | while IFS= read -r key; do
      if [ -n "$key" ] && ! grep -Fxq "$key" "$AUTHORIZED_KEYS"; then
        echo "$key" >> "$AUTHORIZED_KEYS"
      fi
    done
    
    # Fix ownership and permissions
    chown "$USER_NAME:$USER_NAME" "$AUTHORIZED_KEYS"
    chmod 600 "$AUTHORIZED_KEYS"
    
    KEY_COUNT=$(echo "$GITHUB_KEYS" | wc -l)
    echo "Added $KEY_COUNT SSH key(s) from GitHub user '$GITHUB_USER' to authorized_keys."
  else
    echo "Warning: Failed to fetch SSH keys for GitHub user '$GITHUB_USER'. User may not exist or have no public keys." >&2
  fi
fi

# Ask if user wants to run dotfiles setup
if [ -f "/home/$USER_NAME/dotfiles/setup.sh" ]; then
  echo ""
  read -p "Would you like to run the dotfiles setup script now? (y/N): " -n 1 -r </dev/tty
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Running dotfiles setup..."
    su - "$USER_NAME" -c "cd ~/dotfiles && bash setup.sh"
    echo "Dotfiles setup completed."
  else
    echo "Skipping dotfiles setup. You can run it later with: su - $USER_NAME -c 'cd ~/dotfiles && bash setup.sh'"
  fi
else
  echo "Note: dotfiles/setup.sh not found, skipping setup script option."
fi

cat <<EOM

=== Setup Complete ===

User: $USER_NAME
Public SSH Key:
$PUB_KEY

Next steps:
1. Add this key to your GitHub account: https://github.com/settings/keys
2. Test SSH access: ssh $USER_NAME@\$(hostname -I | awk '{print \$1}')
$([ -n "$GITHUB_USER" ] && echo "3. Your GitHub SSH keys have been added for authentication")

EOM

