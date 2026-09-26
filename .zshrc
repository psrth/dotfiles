# ~/.zshrc
# Shell configuration file that runs every time you open a new terminal

# -------------------------
# 1. PATH FIXES
# add ~/.local/bin to path before everything else so tools installed here
# are found immediately by later sections. (like uv, bun, etc.)
# -------------------------
# keep PATH free of duplicates (nested shells re-add the same dirs)
typeset -U path PATH

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
# brew-installed completions + cached tool completions (~/.zfunc, e.g. _uv)
# must be in fpath before compinit runs or they won't be registered
fpath=(/opt/homebrew/share/zsh/site-functions $HOME/.zfunc $fpath)

# docker completions directory
[[ -d "$HOME/.docker/completions" ]] && fpath=($HOME/.docker/completions $fpath)

# zsh completion system (rebuilds once per day for perf)
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  # touch: compinit leaves the mtime alone if the dump is unchanged, which
  # would make this branch (full audit, ~100ms) run every shell after 24h
  compinit && touch ~/.zcompdump
else
  compinit -C
fi

# -------------------------
# 4. PACKAGE MANAGERS
# package managers will modify path and set environment variables that other
# tools depend on. initializing them early so subsequent configs work.
# -------------------------
# homebrew for apple silicon — static equivalent of `eval "$(brew shellenv)"`,
# which costs a subprocess per shell (its fpath line lives in section 3 above
# so compinit can see brew-installed completions)
export HOMEBREW_PREFIX="/opt/homebrew"
export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
export HOMEBREW_REPOSITORY="/opt/homebrew"
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"

# bun for javascript runtime         
export BUN_INSTALL="$HOME/.bun"                   
export PATH="$BUN_INSTALL/bin:$PATH"

# uv completions are cached at ~/.zfunc/_uv (regenerating them inline costs
# ~150ms/shell). after upgrading uv, refresh with:
#   uv generate-shell-completion zsh > ~/.zfunc/_uv

# bun completion script
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# -------------------------
# 5. LANGUAGE ENVIRONMENTS
# language-specific paths and version managers.
# -------------------------
# golang
export GOPATH="$HOME/go"                         
export PATH="$PATH:$GOPATH/bin"

# node version manager (lazy — sourcing nvm.sh costs ~1.5s/shell, so the
# newest installed node goes on PATH directly and nvm loads on first use)
export NVM_DIR="$HOME/.nvm"
_nvm_node=($NVM_DIR/versions/node/*(Nn[-1]))
[[ -n $_nvm_node ]] && export PATH="$_nvm_node/bin:$PATH"
unset _nvm_node
nvm() { unfunction nvm; source /opt/homebrew/opt/nvm/nvm.sh; nvm "$@"; }  # brew-installed nvm

# -------------------------
# 6. ALIASES
# shortcuts for common commands.
# -------------------------
# force python to use uv
# alias python="uv run python"
# alias py="uv run python"
# alias pip="uv pip"

# cd utility (disabled: can interfere with automation tools)
# alias cd="z"

# git
alias g="git"

# file system
alias ll="ls -lah"
alias lt="tree -L 2 --dirsfirst"

# config management
alias zconfig="open -e ~/.zshrc"
alias reload="source ~/.zshrc"

# -------------------------
# 7. FUNCTIONS
# custom functions.
# -------------------------
gw() {
  git pull && git worktree add ".worktrees/${1//\//-}" -b "$1" && cd ".worktrees/${1//\//-}" && claude
}

gwd() {
  local branch=$(git branch --show-current)
  local wt=$(git rev-parse --show-toplevel)
  cd "$(git -C "$wt" worktree list --porcelain | grep -B2 "bare" | head -1 | sed 's/worktree //')" 2>/dev/null || cd ..
  git worktree remove "$wt" && git branch -d "$branch"
}

# -------------------------
# 8. PROMPT
# initializing the prompt last so it can detect all tools/languages.
# -------------------------
# zsh plugins (path hardcoded — `$(brew --prefix)` forks a subshell per use)
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# fzf keybindings and completion
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

# starship prompt
eval "$(starship init zsh)"

# blank line between prompts, but not before the first one — starship's
# add_newline prints it on the first prompt too in zsh, so it's off in
# starship.toml and handled here instead
__prompt_newline() {
  if [[ -n $__prompt_drawn ]]; then
    print ''
  else
    __prompt_drawn=1
  fi
}
if [[ -z ${precmd_functions[(r)__prompt_newline]} ]]; then
  precmd_functions+=(__prompt_newline)
fi

# zoxide (better cd)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd zd)"
fi

# syntax highlighting stays last so it wraps the widgets defined above
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# pnpm
export PNPM_HOME="/Users/psrth/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
