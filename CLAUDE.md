# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a macOS dotfiles repository that uses [GNU Stow](https://www.gnu.org/software/stow/) to symlink configuration files into `$HOME`. It manages zsh configuration (oh-my-zsh), git config, Homebrew packages, and VS Code settings.

## Key Commands

```bash
# Full install (brew + oh-my-zsh + stow all packages)
./install.sh

# Install only specific components
./install.sh brew    # Run brew bundle with Brewfile.min
./install.sh zsh     # Install oh-my-zsh + plugins, stow zsh package
./install.sh git     # Stow git package only

# After changes to zsh files
source ~/.zshrc
```

## Architecture

### Stow-based symlinking

The `dotfiles/` directory contains stow packages. Each subdirectory (e.g., `dotfiles/zsh/`, `dotfiles/git/`) is a stow package whose contents get symlinked to `$HOME` via `stow -t $HOME <package>`. Files inside packages mirror the home directory structure — `dotfiles/zsh/.zshrc` becomes `~/.zshrc`.

### Directory layout

- **`bin/`** — Helper scripts sourced by `install.sh`:
  - `install_dot_files.sh` — `stow_package` and `stow_all` functions
  - `zsh.sh` — oh-my-zsh installation + plugin cloning (`zsh-autosuggestions`, `zsh-better-npm-completion`, `zsh-nvm`)
- **`brew/`** — Homebrew bundle files: `Brewfile` (full) and `Brewfile.min` (minimal, used by default install)
- **`dotfiles/zsh/`** — Zsh config: `.zshrc`, `.aliases`, `.functions`
- **`dotfiles/git/`** — Git config: `.gitconfig`
- **`config/`** — Non-stowed config (VS Code profile)

### Zsh configuration

`.zshrc` sources two additional files via stow symlinks:
- `~/.aliases` — shell aliases
- `~/.functions` — shell functions (git helpers, docker utilities)
- `~/.zsh_project_config` — project-specific config (not in repo, must exist locally)
