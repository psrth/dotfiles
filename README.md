# dotfiles

[@psrth](https://github.com/psrth)'s opinionated dotfiles / machine setup for macOS.

![setup](screenshot.png)

## about

this repository began as more of a personal essay for [vim over emacs](https://en.wikipedia.org/wiki/Editor_war), but over the years has evolved into a single source-of-truth for how i like to manage my macOS machines. includes:

1. **terminal config:** minimal, performant and easy-to-use
2. **brewfile:** installation for apps that i love to use daily
3. **symlinks + syncs:** framework to keep data backed up in the cloud
4. **skills:** tooling for my AI agents
 

## instructions

1. sign into the app store first (for mas apps)
2. then, in the root directory, run:
```bash
git clone https://github.com/psrth/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./setup.sh
```

**the setup script will:**
- install homebrew
- install everything in the `Brewfile` — cli tools, apps (casks), app store apps (`mas`), uv tools, go packages
- create symlinks for all dotfiles and agent skills
- restore the last backup of claude code + codex sessions from icloud (fresh machines only)
- set up cmux hooks for codex, and a daily 6am backup of agent sessions to icloud
- set zsh as the default shell

## features

- **shell**: zsh with custom configuration
- **prompt**: starship
- **terminal**: cmux and ghostty
- **development tools**: git, go, python (uv), node (nvm), bun, docker, etc.
- **ai**: claude code, codex, opencode
- **apps**: zed, brave, raycast, obsidian, figma, etc — all via homebrew
- **skills**: claude code skills in `skills/`, symlinked into `~/.claude/skills`

## manual installs

not available through homebrew or the app store:
- copper (shadcn) — from its website

## cloud sync

1. `dev`: repositories synced to github
2. `icloud/obsidian`: syncs vault from icloud
3. `desktop`: syncs from google drive
4. `media`: photos app synced via icloud
5. `icloud/agents`: claude code + codex sessions, backed up daily (one-way, via `bin/agents-backup`)

## disclaimer

1. this is an extremely opinionated setup designed just for me, and will most likely fight you if you don't follow my workflows.
2. if you only want the terminal setup, you can just copy the `ghostty_config`,`starship.toml`, and snippets from the `.zshrc` file.
3. the setup script is a destructive action meant only for fresh machines — it will overwrite your existing dotfiles. make sure to backup before running the script.
4. that being said — this setup is a breeze, takes 5 mins, will never use more than a couple gigs of storage, and will never slow down your machine. if you're brave enough, go for it.

## cheatsheet

```bash
# navigation
zd <query>          # jump to frecent dir (zoxide)
zdi                 # pick interactively

# files
ll                  # list detailed
lt                  # tree view (2 levels)
bat <file>          # cat with syntax highlighting
trash <file>        # safe delete

# git
g                   # git
gw <branch>         # new worktree in .worktrees/, cd in, start claude
gwd                 # remove current worktree + its branch
fzf                 # fuzzy find (ctrl+r history, ctrl+t files)

# python (all via uv)
uv run python       # run python in the project env
uv pip              # pip, but fast

# config
zconfig             # edit .zshrc
reload              # source .zshrc
```
