# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

export PATH=$PATH:~/google-cloud-sdk/bin
export PATH=$PATH:/usr/local/opt/llvm/bin
export PATH=$PATH:~/bin

export GOPATH=$HOME/go
export GOROOT="$(brew --prefix golang)/libexec"
export PATH="$PATH:${GOPATH}/bin:${GOROOT}/bin"

ZSH_THEME="eastwood"
TERM=xterm
if [[ $TERM == xterm  ]]; then TERM=xterm-256color; fi

# ZSH Plugins
plugins=(
    git
)

source $ZSH/oh-my-zsh.sh

### Vim-Like Configs
# activate vim mode
# bindkey -v

# change cursor shape for different vi modes
# function zle-keymap-select {
#   if [[ ${KEYMAP} == vicmd ]] ||
#      [[ $1 = 'block' ]]; then
#     echo -ne '\e[1 q'

#   elif [[ ${KEYMAP} == main ]] ||
#        [[ ${KEYMAP} == viins ]] ||
#        [[ ${KEYMAP} = '' ]] ||
#        [[ $1 = 'beam' ]]; then
#     echo -ne '\e[5 q'
#   fi
# }
# zle -N zle-keymap-select

# beam shape cursor on startup
# echo -ne '\e[5 q'

# beam shape cursor for each new prompt
# _fix_cursor() {
#    echo -ne '\e[5 q'
# }

# precmd_functions+=(_fix_cursor)

# aliases
alias gpurge='git branch --merged | grep -v "\*" | grep -v "master" | xargs -n 1 git branch -d'
alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'"
alias grep='grep  --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}'
alias mysql=/usr/local/mysql/bin/mysql
alias em='emacsclient -c'

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

