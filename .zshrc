# ~/.zshrc
# Shell configuration file that runs every time you open a new terminal

# -------------------------
# 1. PATH FIXES
# add ~/.local/bin to path before everything else so tools installed here
# are found immediately by later sections. (like uv, bun, etc.)
# -------------------------
export PATH="$HOME/.local/bin:$PATH"

# -------------------------
# 2. SHELL OPTIONS
# zsh behavior settings.
# -------------------------
setopt AUTO_CD

# -------------------------
# 3. COMPLETIONS INIT
# initialize completion system BEFORE any tools register completions.
# -------------------------
# docker completions directory
[[ -d "$HOME/.docker/completions" ]] && fpath=($HOME/.docker/completions $fpath)

# zsh completion system (rebuilds once per day for perf)
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit        
else
  compinit -C     
fi

# -------------------------
# 4. PACKAGE MANAGERS
# package managers will modify path and set environment variables that other
# tools depend on. initializing them early so subsequent configs work.
# -------------------------
# homebrew for apple silicon
eval "$(/opt/homebrew/bin/brew shellenv)"

# bun for javascript runtime         
export BUN_INSTALL="$HOME/.bun"                   
export PATH="$BUN_INSTALL/bin:$PATH"

# uv for python package and project manager
# (now safe to generate completions since compinit ran above)
if command -v uv >/dev/null 2>&1; then            
  eval "$(uv generate-shell-completion zsh)"
fi

# bun completion script
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# -------------------------
# 5. LANGUAGE ENVIRONMENTS
# language-specific paths and version managers.
# -------------------------
# golang
export GOPATH="$HOME/go"                         
export PATH="$PATH:$GOPATH/bin"

# node version manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# -------------------------
# 6. ALIASES
# shortcuts for common commands.
# -------------------------
# add smart home utils to path
export PATH="$HOME/Development/home:$PATH"

# force python to use uv
alias python="uv run python"
alias py="uv run python"
alias pip="uv pip"  

# cd utility
alias cd="z"

# cursor
alias c="cursor ."

# git
alias g="git"

# file system (using eza instead of ls)
if command -v eza >/dev/null 2>&1; then
  alias ls="eza --group-directories-first"
  alias ll="eza --group-directories-first -lah"
  alias lt="eza --group-directories-first --tree --level=2"
else
  alias ls="ls -lah"
  alias ll="ls -lah"
  alias lt="ls -lah --tree --level=2"
fi

# config management
alias zconfig="open -e ~/.zshrc"
alias reload="source ~/.zshrc"

# -------------------------
# 7. FUNCTIONS
# custom functions.
# -------------------------
# npm guard - recommend bun or pnpm instead
npm() {
  if [[ "$1" == "install" || "$1" == "i" ]] && [[ "$EUID" -ne 0 ]]; then
    echo "⚠️ Are you sure you want to use npm?"
    echo "   This system recommends using bun or pnpm instead."
    echo "   Use 'sudo npm $@' to bypass this warning."
    return 1
  fi
  command npm "$@"
}

# -------------------------
# 8. PROMPT
# initializing the prompt last so it can detect all tools/languages.
# -------------------------
# zsh plugins
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# fzf keybindings and completion
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

# zoxide (better cd)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# starship prompt
eval "$(starship init zsh)"

# bun completions
[ -s "/Users/psrth/.bun/_bun" ] && source "/Users/psrth/.bun/_bun"
