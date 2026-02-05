#!/bin/bash
set -e

# Dotfiles bootstrap script
# Usage: curl https://raw.githubusercontent.com/<USER>/dotfiles/main/.bootstrap.sh | bash -s <USER>
#    or: ./.bootstrap.sh <github-username>

GITHUB_USER="${1:-}"

if [ -z "$GITHUB_USER" ]; then
  echo -n "GitHub username: "
  read GITHUB_USER
fi

if [ -z "$GITHUB_USER" ]; then
  echo "Error: GitHub username required"
  exit 1
fi

echo "Cloning dotfiles from $GITHUB_USER/dotfiles..."
git clone --bare "git@github.com:$GITHUB_USER/dotfiles.git" "$HOME/.dotfiles"

function dotfiles {
  /usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" "$@"
}

mkdir -p "$HOME/.dotfiles-backup"

if dotfiles checkout 2>/dev/null; then
  echo "Checked out dotfiles."
else
  echo "Backing up pre-existing dotfiles..."
  dotfiles checkout 2>&1 | grep -E "^\s+\." | awk '{print $1}' | while read f; do
    mkdir -p "$HOME/.dotfiles-backup/$(dirname "$f")"
    mv "$HOME/$f" "$HOME/.dotfiles-backup/$f"
  done
  dotfiles checkout
fi

dotfiles config status.showUntrackedFiles no

# Set up personal git config if it doesn't exist
if [ ! -f "$HOME/.gitconfig.local" ]; then
  echo ""
  echo "Setting up personal git config..."
  echo -n "Your name: "
  read GIT_NAME
  echo -n "Your email: "
  read GIT_EMAIL

  cat > "$HOME/.gitconfig.local" << EOF
# Personal git config (not tracked in dotfiles repo)
[user]
	name = $GIT_NAME
	email = $GIT_EMAIL
[github]
	user = $GITHUB_USER
EOF
  echo "Created ~/.gitconfig.local"
fi

echo ""
echo "Done! Restart your shell or run: source ~/.zshrc"
