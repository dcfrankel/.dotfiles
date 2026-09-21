# POSIX Makefile for linking this dotfiles repo into $HOME.
#
# Usage:
#   make install                    # create missing symlinks
#   make DOTFILES=/path install     # override the source repo location
#   make uninstall                  # remove symlinks that still point into $DOTFILES
.POSIX:

# "$$HOME/dest:relative/source" pairs. Sources are relative to $DOTFILES.
# The doubled '$$' escapes make's own '$' so the shell sees a literal '$HOME'.
LINKS = \
	$$HOME/.zshrc:zsh/zshrc \
	$$HOME/.editorconfig:.editorconfig \
	$$HOME/.gitconfig:git/gitconfig \
	$$HOME/.config/zed/keymap.json:zed/keymap.json \
	$$HOME/.config/zed/settings.json:zed/settings.json \
	$$HOME/.config/zed/tasks.json:zed/tasks.json \
	$$HOME/.config/nvim:nvim \
	$$HOME/.config/ghostty/config:ghostty/config \
	$$HOME/.emacs.d:emacs \
	$$HOME/.config/fish:fish \
	$$HOME/.vimrc:vim/vimrc \
	$$HOME/.ideavimrc:vim/ideavimrc \
	$$HOME/.config/nix/nix.conf:nix/nix.conf

.PHONY: all install uninstall

all: install

install:
	@dotfiles="$(DOTFILES)"; \
	dotfiles=$${dotfiles:-$$HOME/.dotfiles}; \
	if [ ! -d "$$dotfiles" ]; then \
		echo "Dotfiles directory not found at $$dotfiles" >&2; \
		exit 1; \
	fi; \
	for pair in $(LINKS); do \
		dest=$${pair%%:*}; \
		relsrc=$${pair#*:}; \
		src="$$dotfiles/$$relsrc"; \
		if [ ! -e "$$src" ]; then \
			echo "Missing source $$src; skipping..."; \
			continue; \
		fi; \
		if [ -e "$$dest" ] || [ -L "$$dest" ]; then \
			echo "Exists, skipping: $$dest..."; \
			continue; \
		fi; \
		dir=`dirname "$$dest"`; \
		mkdir -p "$$dir"; \
		ln -s "$$src" "$$dest"; \
		echo "Linked $$dest -> $$src"; \
	done

uninstall:
	@dotfiles="$(DOTFILES)"; \
	dotfiles=$${dotfiles:-$$HOME/.dotfiles}; \
	for pair in $(LINKS); do \
		dest=$${pair%%:*}; \
		relsrc=$${pair#*:}; \
		src="$$dotfiles/$$relsrc"; \
		if [ -L "$$dest" ]; then \
			target=`readlink "$$dest"`; \
			if [ "$$target" = "$$src" ]; then \
				rm "$$dest"; \
				echo "Removed $$dest"; \
			fi; \
		fi; \
	done
