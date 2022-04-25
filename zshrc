# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

export PATH="~/bin:$PATH"
export PATH="/usr/local/bin:$PATH"

ZSH_THEME="af-magic"

source $ZSH/oh-my-zsh.sh

# Aliases
# Sane grep defaults
alias g='grep --color=always --exclude-dir={.bzr,CVS,.git,.hg,.svn}'
alias gg='git --no-pager grep --color=always --extended-regex --line-number'
alias mysql=/usr/local/mysql/bin/mysql

# Case insensitive path-completion
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'

# Partial completion suggestions
zstyle ':completion:*' list-suffixes
zstyle ':completion:*' expand prefix suffix
autoload -Uz compinit && compinit

### Functions ###
# Find process at port
listening() {
    if [ $# -eq 0 ]; then
        sudo lsof -iTCP -sTCP:LISTEN -n -P
    elif [ $# -eq 1 ]; then
        sudo lsof -iTCP -sTCP:LISTEN -n -P | grep -i --color $1
    else
        echo "Usage: listening [pattern]"
    fi
}

### Plugins ###
# Enable syntax highlighting in shell
zsh_syntax_loc=~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
if [ -f $zsh_syntax_loc ]; then 
    source $zsh_syntax_loc
else
    source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh || echo "Failed to set up zsh-syntax-highlighting"
fi

# Enable automatic suggestions like fish
zsh_auto_loc=~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
if [ -f $zsh_auto_loc ]; then
    source $zsh_auto_loc
else
    source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh || echo "Failed to set up zsh-autosuggestions"
fi

# Enable fzf integration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# asdf
. /usr/local/opt/asdf/libexec/asdf.sh
