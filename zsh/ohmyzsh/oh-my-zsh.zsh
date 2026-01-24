##### oh-my-zsh setup #####
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="kphoen"
source "$ZSH/oh-my-zsh.sh"

##### kube-ps1 Configs #####
# Enable kube-ps1 prompt if kube config exists and set color defaults
KUBE_PS1_SYMBOL_COLOR="${KUBE_PS1_SYMBOL_COLOR-blue}"
KUBE_PS1_CTX_COLOR="${KUBE_PS1_CTX_COLOR-green}"
KUBE_PS1_NS_COLOR="${KUBE_PS1_NS_COLOR-green}"
KUBE_PS1_BG_COLOR="${KUBE_PS1_BG_COLOR}"
KUBE_PS1_PREFIX="["
KUBE_PS1_SUFFIX="]"

if [ -f "$HOME/.kube/config" ] && [ -x "$(command -v brew)" ]; then
  source "$(brew --prefix)/share/kube-ps1.sh" && PROMPT='$(kube_ps1) '$PROMPT || echo "Failed to source kube_ps1 plugin"
fi
