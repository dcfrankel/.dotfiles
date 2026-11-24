#!/usr/bin/env sh

# Homebrew binaries
[ -d /opt/homebrew/bin ] && export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# User binaries
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# Dotfiles scripts (bin/*), usable from any shell
export PATH="$HOME/.dotfiles/bin:$PATH"

# System wide binaries
export PATH="/usr/local/bin:$PATH"

# Go binaries
export PATH="$PATH:$HOME/go/bin"
