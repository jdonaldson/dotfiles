# Dotfiles

Bare git repo dotfiles for macOS/zsh. Fork and customize.

> **Branches**: `main` is a clean template. Personal configs live on named branches (e.g., `jdonaldson`).

## Quick Install

```bash
# Fork this repo first, then:
curl -fsSL https://raw.githubusercontent.com/<YOUR-USERNAME>/dotfiles/main/.bootstrap.sh | bash -s <YOUR-USERNAME>
```

Or clone manually:

```bash
git clone --bare git@github.com:<YOUR-USERNAME>/dotfiles.git ~/.dotfiles
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dotfiles checkout
dotfiles config status.showUntrackedFiles no
```

## What's Included

| File | Purpose |
|------|---------|
| `.zshrc` | Main zsh config |
| `.zshrc.local` | Personal customizations (edit this) |
| `.zshrc_m1` / `.zshrc_intel` | Architecture-specific config |
| `.aliases` | Shell aliases and functions |
| `.gitconfig` | Git config (includes `.gitconfig.local`) |
| `.gitconfig.local` | Personal git identity (not tracked) |
| `.tmux.conf` | Tmux config |
| `.config/kitty/kitty.conf` | Kitty terminal config |
| `.claude/CLAUDE.md` | Claude Code instructions |
| `Brewfile` | Homebrew dependencies |

## Usage

```bash
dotfiles status          # or: dfs
dotfiles add <file>
dotfiles commit -m "msg"
dotfiles push
```

## Customization

- **Personal shell config**: Edit `~/.zshrc.local`
- **Personal git identity**: Edit `~/.gitconfig.local` (created by bootstrap, not tracked)
- **Add new files**: `dotfiles add ~/.some-config && dotfiles commit -m "add some-config"`

## Features

- Bare repo pattern (no symlinks)
- Auto-attach to tmux (disable with `touch ~/.no-tmux`)
- Kitty theme switching: `set-theme` or `set-theme "theme name"`
- Architecture detection (Apple Silicon vs Intel)
- Conda-safe brew wrapper

## Requirements

- macOS
- zsh
- git
- [Homebrew](https://brew.sh) (run `brew bundle install` for dependencies)
