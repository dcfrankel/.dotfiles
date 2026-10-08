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

#### Jujutsu Configs ####
# Use dynamic completions even though they are unstable
[[ -x "$(command -v jj)" ]] && source <(COMPLETE=zsh jj)

#### Zoxide Configs ####
if [[ -x "$(command -v zoxide)" ]]; then
    eval "$(zoxide init zsh)"
    alias cd='z'
    alias cdi='zi'
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
