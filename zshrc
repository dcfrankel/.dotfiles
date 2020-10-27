# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

export PATH=/usr/local/opt/python@3.7/bin:$PATH
export PATH=$PATH:~/google-cloud-sdk/bin
export PATH=$PATH:/usr/local/opt/llvm/bin
export PATH=$PATH:~/bin

# Go configs
export GOPATH=$HOME/go
export GOROOT="$(brew --prefix golang)/libexec"
export PATH="$PATH:${GOPATH}/bin:${GOROOT}/bin"

# Homebrew configs
export HOMEBREW_NO_AUTO_UPDATE=1

ZSH_THEME="eastwood"

# ZSH Plugins
plugins=(
    git
)

source $ZSH/oh-my-zsh.sh

# aliases
alias gpurge='git branch --merged | grep -v "\*" | grep -v "master" | xargs -n 1 git branch -d'
alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'"
alias grep='grep  --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}'
alias mysql=/usr/local/mysql/bin/mysql

# case insensitive path-completion
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'

# partial completion suggestions
zstyle ':completion:*' list-suffixes
zstyle ':completion:*' expand prefix suffix
autoload -Uz compinit && compinit

# fzf setup
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Syntax highlighting
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

