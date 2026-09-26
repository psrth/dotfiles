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

# node via nvm (brew installs nvm itself; nvm scripts aren't set -e safe)
mkdir -p "$HOME/.nvm"
( set +e; export NVM_DIR="$HOME/.nvm"; source /opt/homebrew/opt/nvm/nvm.sh
  nvm install 24 >/dev/null && nvm alias default 24 >/dev/null && echo "node $(node -v) installed via nvm" ) || true

# uv shell completions (cached; .zshrc loads ~/.zfunc before compinit)
mkdir -p "$HOME/.zfunc"
uv generate-shell-completion zsh > "$HOME/.zfunc/_uv" 2>/dev/null || true

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

# restore claude code + codex from the icloud backup. runs only on a fresh
# machine (no transcripts yet) or to resume an unfinished restore; a machine
# that already has sessions is never touched.
AGENTS_BACKUP="$HOME/Library/Mobile Documents/com~apple~CloudDocs/agents"
RESTORE_PARTIAL="$HOME/.claude/.agents-restore-partial"
RESTORE_DONE="$HOME/.claude/.agents-restore-complete"
if [ ! -f "$RESTORE_DONE" ] && { [ -z "$(ls -A "$HOME/.claude/projects" 2>/dev/null)" ] || [ -f "$RESTORE_PARTIAL" ]; }; then
    if [ -d "$HOME/Library/Mobile Documents/com~apple~CloudDocs" ]; then
        echo "waiting for icloud to sync the agents backup (up to 10 min)..."
        for _ in $(seq 1 120); do [ -f "$AGENTS_BACKUP/last-backup.txt" ] && break; sleep 5; done
    fi
    if [ -f "$AGENTS_BACKUP/last-backup.txt" ]; then
        echo "restoring claude code + codex from icloud (downloads files as it goes)..."
        mkdir -p "$HOME/.claude" "$HOME/.codex" && touch "$RESTORE_PARTIAL"
        brctl download "$AGENTS_BACKUP" 2>/dev/null || true
        # skip icloud conflict copies ("name 2.ext")
        rsync -a --exclude '* [2-9]' --exclude '* [2-9].*' "$AGENTS_BACKUP/claude/" "$HOME/.claude/"
        [ -d "$AGENTS_BACKUP/codex" ] && rsync -a --exclude '* [2-9]' --exclude '* [2-9].*' "$AGENTS_BACKUP/codex/" "$HOME/.codex/"
        [ -f "$HOME/.claude.json" ] || cp "$AGENTS_BACKUP/claude.json" "$HOME/.claude.json"
        want_claude=$(sed -n 's/^claude_transcripts=//p' "$AGENTS_BACKUP/last-backup.txt")
        want_codex=$(sed -n 's/^codex_sessions=//p' "$AGENTS_BACKUP/last-backup.txt")
        got_claude=$(find "$HOME/.claude/projects" -name '*.jsonl' 2>/dev/null | wc -l | tr -d ' ')
        got_codex=$(find "$HOME/.codex/sessions" -name '*.jsonl' 2>/dev/null | wc -l | tr -d ' ')
        if [ "$got_claude" -ge "${want_claude:-0}" ] && [ "$got_codex" -ge "${want_codex:-0}" ]; then
            rm -f "$RESTORE_PARTIAL" && touch "$RESTORE_DONE"
            echo "✅ restored $got_claude claude transcripts, $got_codex codex sessions"
        else
            echo "⚠️  restore incomplete: claude $got_claude/$want_claude, codex $got_codex/$want_codex — re-run setup.sh once icloud finishes syncing"
        fi
    else
        echo "⚠️  no agents backup found in icloud drive — sign into icloud, let it sync, then re-run setup.sh"
    fi
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

# google drive: start at login (sign-in and mirror folder are manual, see README)
defaults write com.google.drivefs.settings AutoStartOnLogin -bool true

# macos preferences
bash "$DOTFILES_DIR/macos.sh"

# set default shell
echo "(5) setting default shell..."
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s "$(which zsh)"
fi

echo "all done! ready to start a new zsh session."

