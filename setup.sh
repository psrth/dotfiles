#!/usr/bin/env bash

echo "setting up system from dotfiles:"
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ensure homebrew is in PATH for apple silicon
if [[ $(uname -m) == 'arm64' ]] && [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# install homebrew
if ! command -v brew &> /dev/null; then
    echo "(1) installing homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# install packages
echo "(2) installing packages..."
cd "$DOTFILES_DIR"
brew bundle --no-lock --quiet

# install bun
if ! command -v bun &> /dev/null; then
    echo "(3) installing bun..."
    curl -fsSL https://bun.sh/install | bash
fi

# create directories
echo "(4) creating directories..."
mkdir -p "$HOME/.config/starship" "$HOME/.config/ghostty" "$HOME/.local/bin"
mkdir -p "$HOME/Library/Application Support/Cursor/User"

# symlink configs
echo "(5) symlinking configs..."
rm -rf "$HOME/.zshrc" "$HOME/.gitconfig" "$HOME/.config/starship/starship.toml" "$HOME/.config/ghostty/config"
rm -rf "$HOME/Library/Application Support/Cursor/User/settings.json"
rm -rf "$HOME/Library/Application Support/Cursor/User/keybindings.json"

ln -s "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
ln -s "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
ln -s "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship/starship.toml"
ln -s "$DOTFILES_DIR/ghostty_config" "$HOME/.config/ghostty/config"
ln -s "$DOTFILES_DIR/cursor/settings.json" "$HOME/Library/Application Support/Cursor/User/settings.json"
ln -s "$DOTFILES_DIR/cursor/keybindings.json" "$HOME/Library/Application Support/Cursor/User/keybindings.json"

# set default shell
echo "(6) setting default shell..."
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s "$(which zsh)"
fi

echo "all done! ready to start a new zsh session."

