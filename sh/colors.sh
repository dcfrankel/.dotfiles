#!/usr/bin/env sh

# Enable colors for BSD ls without needing --color
export CLICOLOR=1
# BSD ls colors: bold blue dirs, bold cyan symlinks, bold green executables
export LSCOLORS="ExGxxxxxCxxxxxxxxxxxxx"
# GNU-style colors (tree, fd, zsh completion): same as above plus red archives
export LS_COLORS="di=1;34:ln=1;36:ex=1;32:*.tar=31:*.gz=31:*.tgz=31:*.zip=31:*.bz2=31:*.xz=31:*.7z=31"
