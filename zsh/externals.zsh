#!/usr/bin/env zsh

#### fzf related Configs ####
export FZF_DEFAULT_OPTS='--style full'

# Use fd for completions if it's present on the system
if [[ -x "$(command -v fd)" ]]; then
  export FZF_DEFAULT_COMMAND='fd --type file --hidden --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  # Override default completions for 'cd foo**<tab>'
  _fzf_compgen_dir() {
    fd --type d --hidden --follow --exclude ".git" . "$1"
  }
fi

function fzf_init() {
  [[ -x "$(command -v fzf)" ]] && source <(fzf --zsh)
}

#### Bat Configs ####
[[ -x "$(command -v bat)" ]] && alias cat='bat --paging=never'

#### Zoxide Configs ####
if [[ -x "$(command -v zoxide)" ]]; then
    eval "$(zoxide init zsh)"
    alias cd='z'
    alias cdi='zi'

    # Seed zoxide with every git repo/worktree found under the given paths
    # eg `zoxide_seed ~/work/ghec ~/work/ghes`
    # Low score (-s 1) keeps seeded entries below directories actually visited
    zoxide_seed() {
      if (( $# == 0 )); then
        printf '%s\n' "usage: zoxide_seed <path>..." >&2
        return 1
      fi

      # Match .git files (worktrees) and .git dirs (normal clones), and skip
      # descending into .git/.bare since they never contain checkouts
      local -a git_paths
      git_paths=(${(f)"$(find "$@" -maxdepth 6 \
        \( -name .git -o -name .bare \) -prune -name .git -print 2>/dev/null)"})

      if (( ${#git_paths} == 0 )); then
        printf '%s\n' "zoxide_seed: no git repos found in: $*" >&2
        return 1
      fi

      # :h strips the trailing /.git to get the repo/worktree directory
      zoxide add -s 1 -- "${git_paths[@]:h}"
      printf 'zoxide_seed: added %d directories\n' "${#git_paths}"
    }
fi

#### Neovim Configs ####
[[ -x "$(command -v nvim)" ]] && alias vim='nvim'

#### Claude Configs ####
# Force claude to use bash as the shell
[[ -x "$(command -v claude)" ]] && alias claude="SHELL=/bin/bash claude --permission-mode plan"

#### Lazygit Configs ####
if [[ -x "$(command -v lazygit)" ]]; then
  # Set lazygit config path
  export LG_CONFIG_FILE="$HOME/.dotfiles/lazygit/config.yaml"
  alias lg='lazygit'
fi
