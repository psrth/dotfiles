# dotfiles

Personal dotfiles and machine setup for macOS.

## Quick Setup (New Machine)

```bash
git clone https://github.com/psrth/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./setup.sh
```

The setup script will:
- Install Homebrew (if needed)
- Install all packages, apps, and Cursor extensions from Brewfile
- Install Bun (JavaScript runtime)
- Create symlinks for all config files
- Backup any existing configs
- Set zsh as your default shell

## Manual Installation

If you prefer to set things up manually:

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install packages
brew bundle

# Install Bun
curl -fsSL https://bun.sh/install | bash

# Create symlinks
ln -s ~/.dotfiles/.zshrc ~/.zshrc
ln -s ~/.dotfiles/.gitconfig ~/.gitconfig
ln -s ~/.dotfiles/starship.toml ~/.config/starship/starship.toml
ln -s ~/.dotfiles/ghostty_config ~/.config/ghostty/config

# Reload shell
source ~/.zshrc
```

## What's Included

- **Shell**: zsh with custom configuration
- **Prompt**: Starship prompt
- **Terminal**: Ghostty
- **Development tools**: Git, Go, Python (uv), Docker, etc.
- **Apps**: Cursor, Brave, Raycast, Obsidian, and more
- **VS Code extensions**: For Cursor IDE
