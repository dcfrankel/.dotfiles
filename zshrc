### oh-my-zsh setup ###
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
source "$ZSH/oh-my-zsh.sh"

### ZSH Configs ###
# Case insensitive path-completion
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'
DISABLE_MAGIC_FUNCTIONS=true

# Partial completion suggestions
zstyle ':completion:*' list-suffixes
zstyle ':completion:*' expand prefix suffix
autoload -Uz compinit && compinit

### ZSH Plugins ###
# Enable syntax highlighting in shell
source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" || echo "Failed to source zsh-syntax-highlighting plugin"

# Enable automatic suggestions like fish
source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" || echo "Failed to source zsh-autosuggestions plugin"

# Enable kube-ps1 prompt
source "$(brew --prefix)/share/kube-ps1.sh" && PROMPT='$(kube_ps1) '$PROMPT || echo "Failed to source kube_ps1 plugin"

### PATH Changes ###
# User binaries
export PATH="$HOME/bin:$PATH"
# System wide binaries
export PATH="/usr/local/bin:$PATH"

### Aliases ###
# Sane grep defaults
alias g='grep --color=always --exclude-dir={.bzr,CVS,.git,.hg,.svn}'
alias gg='git --no-pager grep --color=always --extended-regex --line-number'

### Additional Integrations ###
# Enable fzf
[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"

# Enable asdf
[ -f "/usr/local/opt/asdf/libexec/asdf.sh" ] && . "/usr/local/opt/asdf/libexec/asdf.sh"

# Work Specific Configs
[ -f "$HOME/.work_zshrc.zsh" ] && source "$HOME/.work_zshrc.zsh"
