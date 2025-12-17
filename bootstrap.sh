#!/usr/bin/env bash
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

if [ ! -d "$DOTFILES" ]; then
  echo "Dotfiles directory not found at $DOTFILES"
  exit 1
fi

links=(
  "$HOME/.zshrc.pre-oh-my-zsh:$DOTFILES/zsh/zshrc"
  "$HOME/.zshrc:$DOTFILES/zsh/zshrc"
  "$HOME/.editorconfig:$DOTFILES/.editorconfig"
  "$HOME/.gitconfig:$DOTFILES/git/gitconfig"
  "$HOME/.config/zed/keymap.json:$DOTFILES/zed/keymap.json"
  "$HOME/.config/zed/settings.json:$DOTFILES/zed/settings.json"
  "$HOME/.config/zed/tasks.json:$DOTFILES/zed/tasks.json"
  "$HOME/.config/nvim:$DOTFILES/nvim"
  "$HOME/.config/lazygit/config.yaml:$DOTFILES/lazygit/config.yaml"
  "$HOME/.config/ghostty/config:$DOTFILES/ghostty/config"
)

for entry in "${links[@]}"; do
  IFS=: read -r dest src <<< "$entry"

  if [ ! -e "$src" ]; then
    echo "Missing source $src; skipping..."
    continue
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    echo "Exists, skipping: $dest..."
    continue
  fi

  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  echo "Linked $dest -> $src"
done
