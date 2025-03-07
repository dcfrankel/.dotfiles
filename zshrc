### oh-my-zsh setup ###
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="eastwood"
source "$ZSH/oh-my-zsh.sh"

### PATH Changes ###
# User binaries
export PATH="$HOME/bin:$PATH"
# System wide binaries
export PATH="/usr/local/bin:$PATH"

### ZSH Configs ###
# Case insensitive path-completion
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'
DISABLE_MAGIC_FUNCTIONS=true

# Partial completion suggestions
zstyle ':completion:*' list-suffixes
zstyle ':completion:*' expand prefix suffix
autoload -Uz compinit && compinit

### ZSH Plugins ###
# Enable automatic suggestions like fish
zsh_autosuggestions_path="$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
[ -f "$zsh_autosuggestions_path" ] && source "$zsh_autosuggestions_path"

# Enable kube-ps1 prompt if kube config exists and set color defaults
KUBE_PS1_SYMBOL_COLOR="${KUBE_PS1_SYMBOL_COLOR-blue}"
KUBE_PS1_CTX_COLOR="${KUBE_PS1_CTX_COLOR-green}"
KUBE_PS1_NS_COLOR="${KUBE_PS1_NS_COLOR-green}"
KUBE_PS1_BG_COLOR="${KUBE_PS1_BG_COLOR}"

if [ -f "$HOME/.kube/config" ]; then
  source "$HOMEBREW_PREFIX/share/kube-ps1.sh" && PROMPT='$(kube_ps1) '$PROMPT || echo "Failed to source kube_ps1 plugin"
fi

# Enable vim stuff
zsh_vi_mode_path="$HOMEBREW_PREFIX/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
ZVM_INIT_MODE=sourcing
[ -f "$zsh_vi_mode_path" ] && source "$zsh_vi_mode_path"
plugins+=(zsh-vi-mode)

### Aliases ###
alias ls='ls -lah'

### Additional Integrations ###
# Enable fzf
fzf_path=$(which fzf)
[ -x "$fzf_path" ] && source <(fzf --zsh)

# Work Specific Configs
[ -f "$HOME/.zshrc_work.zsh" ] && source "$HOME/.zshrc_work.zsh"

# ls configs -- see man ls
export LSCOLORS="exfxxxxxxxxxxxxxxxxxxx"
