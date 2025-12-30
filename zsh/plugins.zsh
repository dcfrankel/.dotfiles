#!/usr/bin/env zsh
##### fzf related Configs #####
export FZF_DEFAULT_OPTS='--style full'
# Use fd if it's present on the system
[ -x "$(command -v fd)" ] && export FZF_DEFAULT_COMMAND='fd --type file --hidden --exclude .git'

function fzf_init() {
  [ -x "$(command -v fzf)" ] && source <(fzf --zsh)
}

##### Vi Mode Configs #####
zsh_vi_mode_path="$(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
if [ -f "$zsh_vi_mode_path" ]; then
  source "$zsh_vi_mode_path"
  # zsh vi mode breaks CTRL+R search with fzf unless added here
  zvm_after_init_commands+=(fzf_init)
else
  fzf_init
fi

##### kube-ps1 Configs #####
# Enable kube-ps1 prompt if kube config exists and set color defaults
KUBE_PS1_SYMBOL_COLOR="${KUBE_PS1_SYMBOL_COLOR-blue}"
KUBE_PS1_CTX_COLOR="${KUBE_PS1_CTX_COLOR-green}"
KUBE_PS1_NS_COLOR="${KUBE_PS1_NS_COLOR-green}"
KUBE_PS1_BG_COLOR="${KUBE_PS1_BG_COLOR}"
KUBE_PS1_PREFIX="["
KUBE_PS1_SUFFIX="]"

if [ -f "$HOME/.kube/config" ]; then
  source "$(brew --prefix)/share/kube-ps1.sh" && PROMPT='$(kube_ps1) '$PROMPT || echo "Failed to source kube_ps1 plugin"
fi

##### ZSH Autosuggestions Configs #####
zsh_autosuggestions_path="$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
[ -f "$zsh_autosuggestions_path" ] && source "$zsh_autosuggestions_path"

#### Jujutsu Configs ####
# Use dynamic completions even though they are unstable
[ -x "$(command -v jj)" ] && source <(COMPLETE=zsh jj)
