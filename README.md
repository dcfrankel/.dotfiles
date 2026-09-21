# dotfiles
A collection of `.file` "dotfile" configurations for vim, zsh, emacs, etc...

The following documentation assumes that this directory should be located in a users "$HOME" directory.

Symbolic links should be created for the following files and directories:
| Link Target | Source |
| --- | --- |
| `$HOME/.zshrc` | `$HOME/.dotfiles/zsh/zshrc` |
| `$HOME/.editorconfig` | `$HOME/.dotfiles/.editorconfig` |
| `$HOME/.gitconfig` | `$HOME/.dotfiles/git/gitconfig` |
| `$HOME/.config/zed/keymap.json` | `$HOME/.dotfiles/zed/keymap.json` |
| `$HOME/.config/zed/settings.json` | `$HOME/.dotfiles/zed/settings.json` |
| `$HOME/.config/zed/tasks.json` | `$HOME/.dotfiles/zed/tasks.json` |
| `$HOME/.config/nvim` | `$HOME/.dotfiles/nvim` |
| `$HOME/.config/ghostty/config` | `$HOME/.dotfiles/ghostty/config` |
| `$HOME/.emacs.d` | `$HOME/.dotfiles/emacs` |
| `$HOME/.config/fish` | `$HOME/.dotfiles/fish` |
| `$HOME/.vimrc` | `$HOME/.dotfiles/vim/vimrc` |
| `$HOME/.ideavimrc` | `$HOME/.dotfiles/vim/ideavimrc` |
| `$HOME/.config/nix/nix.conf` | `$HOME/.dotfiles/nix/nix.conf` |

## Bootstrapping
Use the Makefile to create the symlinks safely (skips existing destinations):

```bash
# from the repo
make install

# or if the repo lives somewhere else
make DOTFILES=/custom/path/to/.dotfiles install

# remove symlinks that still point into $DOTFILES
make uninstall
```
