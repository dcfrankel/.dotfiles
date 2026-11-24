#!/usr/bin/env zsh

#### ZSH Pugins Configs ####
# Check if brew is installed to manage brew insalled zsh plugins
if [[ -x "$(command -v brew)" ]]; then
  brew_prefix="$(brew --prefix)"

  #### FZF Configs ####
  fzf_init

  ##### ZSH Autosuggestions Configs #####
  zsh_autosuggestions_path="$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  [[ -f "$zsh_autosuggestions_path" ]] && source "$zsh_autosuggestions_path"
fi
