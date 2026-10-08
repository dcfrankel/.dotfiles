#!/usr/bin/env zsh

#### ZSH Pugins Configs ####
# Check if brew is installed to manage brew insalled zsh plugins
if [[ -x "$(command -v brew)" ]]; then
  brew_prefix="$(brew --prefix)"

  #### Vi Mode Configs ####
  zsh_vi_mode_path="$brew_prefix/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
  if [[ -f "$zsh_vi_mode_path" ]]; then
    source "$zsh_vi_mode_path"
    # zsh vi mode breaks CTRL+R search with fzf unless added here
    zvm_after_init_commands+=(fzf_init)
  else
    fzf_init
  fi

  ##### ZSH Autosuggestions Configs #####
  zsh_autosuggestions_path="$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  [[ -f "$zsh_autosuggestions_path" ]] && source "$zsh_autosuggestions_path"
fi
