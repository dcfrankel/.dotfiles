#!/usr/bin/env zsh

#### fzf related Configs ####
export FZF_DEFAULT_OPTS='--style full'

# Use fd for completions if it's present on the system
if [ -x "$(command -v fd)" ]; then
  export FZF_DEFAULT_COMMAND='fd --type file --hidden --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  # Override default completions for 'cd foo**<tab>'
  _fzf_compgen_dir() {
    fd --type d --hidden --follow --exclude ".git" . "$1"
  }
fi

function fzf_init() {
  [ -x "$(command -v fzf)" ] && source <(fzf --zsh)
}

#### Bat Configs ####
[ -x "$(command -v bat)" ] && alias cat='bat --paging=never'

#### Jujutsu Configs ####
# Use dynamic completions even though they are unstable
[ -x "$(command -v jj)" ] && source <(COMPLETE=zsh jj)

#### Zoxide Configs ####
[ -x "$(command -v zoxide)" ] && eval "$(zoxide init zsh)"

#### ZSH Pugins Configs ####
# Check if brew is installed to manage brew insalled zsh plugins
if [ -x "$(command -v brew)" ]; then
  brew_prefix="$(brew --prefix)"

  #### Vi Mode Configs ####
  zsh_vi_mode_path="$brew_prefix/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
  if [ -f "$zsh_vi_mode_path" ]; then
    source "$zsh_vi_mode_path"
    # zsh vi mode breaks CTRL+R search with fzf unless added here
    zvm_after_init_commands+=(fzf_init)
  else
    fzf_init
  fi

  ##### ZSH Autosuggestions Configs #####
  zsh_autosuggestions_path="$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  [ -f "$zsh_autosuggestions_path" ] && source "$zsh_autosuggestions_path"
fi
