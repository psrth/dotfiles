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
brew bundle --quiet

# create directories
echo "(3) creating directories..."
mkdir -p "$HOME/.config/ghostty" "$HOME/.config/zed" "$HOME/.config/btop" "$HOME/.local/bin"

# symlink configs
echo "(4) symlinking configs..."
rm -rf "$HOME/.zshrc" "$HOME/.gitconfig" "$HOME/.config/starship.toml" "$HOME/.config/ghostty/config"
rm -rf "$HOME/.config/zed/settings.json" "$HOME/.config/btop/btop.conf"

ln -s "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
ln -s "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
ln -s "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"
ln -s "$DOTFILES_DIR/ghostty_config" "$HOME/.config/ghostty/config"
ln -s "$DOTFILES_DIR/zed/settings.json" "$HOME/.config/zed/settings.json"
ln -s "$DOTFILES_DIR/btop/btop.conf" "$HOME/.config/btop/btop.conf"

# restore claude code + codex state from the icloud backup (fresh machines only:
# skipped once ~/.claude has transcripts, so it never overwrites live data)
AGENTS_BACKUP="$HOME/Library/Mobile Documents/com~apple~CloudDocs/agents"
if [ -d "$AGENTS_BACKUP/claude" ] && [ -z "$(ls -A "$HOME/.claude/projects" 2>/dev/null)" ]; then
    echo "restoring claude code from icloud backup (may wait on icloud downloads)..."
    brctl download "$AGENTS_BACKUP" 2>/dev/null || true
    mkdir -p "$HOME/.claude"
    rsync -a "$AGENTS_BACKUP/claude/" "$HOME/.claude/"
    [ -f "$HOME/.claude.json" ] || cp "$AGENTS_BACKUP/claude.json" "$HOME/.claude.json"
fi
if [ -d "$AGENTS_BACKUP/codex" ] && [ -z "$(ls -A "$HOME/.codex/sessions" 2>/dev/null)" ]; then
    echo "restoring codex from icloud backup..."
    mkdir -p "$HOME/.codex"
    rsync -a "$AGENTS_BACKUP/codex/" "$HOME/.codex/"
fi

# cmux agent hooks: claude code's are injected by cmux's wrapper automatically,
# codex's must be installed once the codex cli is on PATH
# (after the restore above, so restored codex config doesn't clobber them)
if command -v cmux &> /dev/null && command -v codex &> /dev/null; then
    cmux hooks setup codex --yes || true
fi

# symlink claude code skills
mkdir -p "$HOME/.claude/skills"
for skill in "$DOTFILES_DIR"/skills/*/; do
    name="$(basename "$skill")"
    rm -rf "$HOME/.claude/skills/$name"
    ln -s "${skill%/}" "$HOME/.claude/skills/$name"
done

# daily claude code + codex backup to icloud drive/agents (see bin/agents-backup)
chmod +x "$DOTFILES_DIR/bin/agents-backup"
PLIST="$HOME/Library/LaunchAgents/com.psrth.agents-backup.plist"
mkdir -p "$HOME/Library/LaunchAgents"
launchctl bootout "gui/$(id -u)" "$PLIST" 2>/dev/null || true
sed "s#__HOME__#$HOME#g" "$DOTFILES_DIR/launchd/com.psrth.agents-backup.plist" > "$PLIST"
launchctl bootstrap "gui/$(id -u)" "$PLIST"

# set default shell
echo "(5) setting default shell..."
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s "$(which zsh)"
fi

echo "all done! ready to start a new zsh session."

