#!/usr/bin/env zsh
## Custom git helpers

# Bare clone a repo and set it up for worktree usage:
#   <dir>/.bare      the bare repo
#   <dir>/.git       file pointing at ./.bare
# If <dir>/.bare already exists the clone is skipped and only setup is done.
# Usage: git_bare_clone <url> [dir]
function git_bare_clone() {
  local url=$1
  local dir=${2:-${${url:t}%.git}}

  if [[ -z "$url" || -z "$dir" ]]; then
    echo "usage: git_bare_clone <url> [dir]" >&2
    return 1
  fi

  if [[ -d "$dir/.bare" ]]; then
    echo "Found existing $dir/.bare, skipping clone"
  elif [[ -e "$dir" && -n "$(ls -A "$dir" 2>/dev/null)" ]]; then
    echo "git_bare_clone: '$dir' already exists and is not empty" >&2
    return 1
  else
    git clone --bare "$url" "$dir/.bare" || return 1
  fi

  cd "$dir" || return 1

  printf 'gitdir: ./.bare\n' > ".git" || return 1

  git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*" || return 1
  git fetch origin
}
