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
# 3. PACKAGE MANAGERS
# package managers will modify path and set environment variables that other
# tools depend on. initializing them early so subsequent configs work.
# -------------------------
# homebrew for apple silicon
eval "$(/opt/homebrew/bin/brew shellenv)"

# bun for javascript runtime         
export BUN_INSTALL="$HOME/.bun"                   
export PATH="$BUN_INSTALL/bin:$PATH"

# uv for python package and project manager
if command -v uv >/dev/null 2>&1; then            
  eval "$(uv generate-shell-completion zsh)"
fi

# -------------------------
# 4. LANGUAGE ENVIRONMENTS
# language-specific paths and version managers.
# -------------------------
# golang
export GOPATH="$HOME/go"                         
export PATH="$PATH:$GOPATH/bin"

# -------------------------
# 5. COMPLETIONS
# tab completion setup runs before any completion scripts are sourced.
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

# bun completion script
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# -------------------------
# 6. ALIASES
# shortcuts for common commands.
# -------------------------
# force python to use uv
alias python="uv run python"  
alias py="uv run python"      
alias pip="uv pip"            

# git
alias g="git"

# file system
alias ll="ls -lah"

# config management
alias zconfig="open -e ~/.zshrc"
alias reload="source ~/.zshrc"

# -------------------------
# 7. FUNCTIONS
# custom functions.
# -------------------------


# -------------------------
# 8. PROMPT
# initializing the prompt last so it can detect all tools/languages.
# -------------------------
eval "$(starship init zsh)"
