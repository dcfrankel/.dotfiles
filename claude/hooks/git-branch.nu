#!/usr/bin/env -S nu --no-config-file --stdin
# PreToolUse(Bash) hook: enforce the AGENTS.md branch conventions.
#
#   - New or renamed branches are named <PROJECT>-<ID>/<feature> (deny).
#   - In bare+worktree repos (<repo>/.bare plus one <repo>/<branch>/ dir per
#     worktree), worktree dirs match their branch (deny when git would silently
#     name the branch after the last path component, ask otherwise), and
#     branches are not switched or created inside an existing worktree (ask).
#   - Branches made from a remote-tracking ref (e.g. origin/main) pass
#     --no-track, so they don't get it as their upstream (deny).

use hooklib.nu [TICKET_RE ask bare-root deny flag-value git-dir git-out in-worktree local-branch resolve-path run-hook simple-commands strip-wrappers with-cwd]

const CREATE_FLAGS = [-b -B -c -C --create --force-create]
const MOVE_FLAGS = [-m -M --move -c -C --copy]

# git global options that take a value, e.g. `git -C dir checkout -b x`.
const GLOBAL_OPTS_WITH_VALUE = [-C -c --git-dir --work-tree]

# Args of a git invocation starting at the subcommand.
def subcommand-args [argv: list<string>]: nothing -> list<string> {
  mut args = $argv | skip 1
  while ($args | is-not-empty) and ($args | first | str starts-with '-') {
    $args = $args | skip (if ($args | first) in $GLOBAL_OPTS_WITH_VALUE { 2 } else { 1 })
  }
  $args
}

# Name of the branch a `git branch …` invocation creates or renames to.
def branch-target [args: list<string>]: nothing -> any {
  let positional = $args | where {|a| not ($a | str starts-with '-') }
  if ($args | any {|a| $a in $MOVE_FLAGS }) {
    $positional | get -o 1 | default ($positional | get -o 0)
  } else if ($args | get -o 0 | default '-' | str starts-with '-') == false {
    $args | first
  }
}

# Parsed `git worktree add` args: path, commit-ish, -b/-B branch, --detach.
def worktree-add [args: list<string>]: nothing -> record {
  mut positional = []
  mut new: any = null
  mut detach = false
  mut i = 0
  while $i < ($args | length) {
    let a = $args | get $i
    if $a in [-b -B --reason] {
      if $a != '--reason' { $new = $args | get -o ($i + 1) }
      $i += 2
      continue
    }
    if $a == '--' {
      $positional = $positional ++ ($args | skip ($i + 1))
      break
    }
    if $a in [-d --detach] {
      $detach = true
    } else if not ($a | str starts-with '-') {
      $positional = $positional | append $a
    }
    $i += 1
  }
  {path: ($positional | get -o 0), commit: ($positional | get -o 1), new: $new, detach: $detach}
}

# Whether some remote has a branch called name.
def remote-branch [dir: string, name: string]: nothing -> bool {
  (git-out $dir [for-each-ref --count=1 '--format=%(refname)' $"refs/remotes/*/($name)"] | default '') != ''
}

# Branch a `git worktree add` checks out: its -b/-B name, a branch-name
# commit-ish, or (with neither) the one git names after the path's basename.
def worktree-branch [wa: record, dir: string]: nothing -> any {
  if $wa.detach or $wa.path == null { return null }
  if $wa.new != null { return $wa.new }
  if $wa.commit == null { return ($wa.path | path basename) }
  if (local-branch $dir $wa.commit) or (remote-branch $dir $wa.commit) { $wa.commit }
}

# Name of the branch this git command creates, if it creates one.
def new-branch-name [argv: list<string>, dir: string]: nothing -> any {
  match (subcommand-args $argv) {
    [checkout, ..$rest] => (flag-value $rest $CREATE_FLAGS)
    [switch, ..$rest] => (flag-value $rest $CREATE_FLAGS)
    [worktree, add, ..$rest] => {
      let wa = worktree-add $rest
      if $wa.new != null { return $wa.new }
      # With no branch given, git creates one named after the path's basename
      # unless a local or remote branch of that name already exists.
      if $wa.path == null or $wa.commit != null or $wa.detach { return null }
      let name = $wa.path | path basename
      if not ((local-branch $dir $name) or (remote-branch $dir $name)) { $name }
    }
    [branch, ..$rest] => (branch-target $rest)
    _ => null
  }
}

# Flags that say how a new branch's upstream is set; any of them is deliberate.
const TRACK_FLAGS = [--no-track --track -t]

# `git branch` flags under which positionals aren't <name> [<start-point>].
const BRANCH_NON_CREATE = [-m -M -c -C -d -D -l -u --move --copy --delete --list --set-upstream-to --unset-upstream --edit-description]

# Start point of a branch-creating command, if it gives one.
def start-point [argv: list<string>]: nothing -> any {
  match (subcommand-args $argv) {
    [worktree, add, ..$rest] => {
      let wa = worktree-add $rest
      if $wa.new != null { $wa.commit }
    }
    [$sub, ..$rest] if $sub in [checkout switch] => {
      if (flag-value $rest $CREATE_FLAGS) == null { return null }
      mut positional = []
      mut i = 0
      while $i < ($rest | length) {
        let a = $rest | get $i
        if $a == '--' { break }
        if $a in $CREATE_FLAGS {
          $i += 2
          continue
        }
        if not ($a | str starts-with '-') { $positional = $positional | append $a }
        $i += 1
      }
      $positional | get -o 0
    }
    [branch, ..$rest] => {
      if ($rest | any {|a| ($a in $BRANCH_NON_CREATE) or ($a | str starts-with '--set-upstream-to=') }) { return null }
      $rest | where {|a| not ($a | str starts-with '-') } | get -o 1
    }
    _ => null
  }
}

# Deny branching from a remote-tracking ref without --no-track: git would set
# the new branch's upstream to it (e.g. origin/main), so pushes target it.
def track-verdict [argv: list<string>, dir: string]: nothing -> any {
  let args = subcommand-args $argv
  if ($args | any {|a| ($a in $TRACK_FLAGS) or ($a | str starts-with '--track=') }) { return null }
  let start = start-point $argv
  if $start == null or (git-out $dir [show-ref --verify $"refs/remotes/($start)"]) == null { return null }
  deny $"AGENTS.md: branching from remote-tracking '($start)' sets the new branch's upstream to ($start), which must be unset before pushing a feature branch. Re-run with --no-track \(e.g. `git worktree add <ID>/<feat> -b <ID>/<feat> --no-track ($start)`\); push.autoSetupRemote sets the right upstream on first push."
}

def ticket-verdict [argv: list<string>, dir: string]: nothing -> any {
  let name = new-branch-name $argv $dir
  if $name != null and not ($name =~ $'^($TICKET_RE)/.+') {
    deny $"AGENTS.md: branch '($name)' must be named <PROJECT>-<ID>/<feature> \(e.g. ABC-123/my_feature\). Ask the user for the Jira ticket ID if unknown."
  }
}

# Command that creates a worktree for branch at <root>/<branch>.
def suggest [root: string, branch: string, new: bool]: nothing -> string {
  if $new {
    $"git -C ($root) worktree add ($branch) -b ($branch)"
  } else {
    $"git -C ($root) worktree add ($branch) ($branch)"
  }
}

# Layout rules for bare+worktree repos; null for normal clones.
def layout-verdict [argv: list<string>, dir: string]: nothing -> any {
  let root = bare-root $dir
  if $root == null { return null }
  # git reports real paths, so compare against dir with symlinks resolved.
  let dir = $dir | path expand
  match (subcommand-args $argv) {
    [worktree, add, ..$rest] => {
      let wa = worktree-add $rest
      let branch = worktree-branch $wa $dir
      if $branch == null { return null }
      let target = resolve-path $dir $wa.path
      let rel = try { $target | path relative-to $root } catch { null }
      if $wa.new == null and $wa.commit == null and ($rel == null or ($rel | str contains '/')) {
        return (deny $"AGENTS.md: without -b or a branch, git names the branch after the path's last component \('($branch)'\), so the worktree dir won't match its branch. Name it explicitly: `(suggest $root ($rel | default $wa.path) true)` for a new branch, or `(suggest $root ($rel | default $wa.path) false)` for an existing one.")
      }
      if $rel != $branch {
        return (ask $"AGENTS.md: worktree dirs should be <repo>/<branch>, but this puts branch '($branch)' at ($target). Prefer `(suggest $root $branch ($wa.new != null))`.")
      }
      null
    }
    [switch, ..$rest] => {
      if not (in-worktree $dir) or ($rest | is-empty) { return null }
      let target = flag-value $rest $CREATE_FLAGS | default ($rest | where {|a| not ($a | str starts-with '-') } | get -o 0)
      switch-ask $root $dir $target ($rest | any {|a| $a in $CREATE_FLAGS })
    }
    [checkout, ..$rest] => {
      if not (in-worktree $dir) or ('--' in $rest) { return null }
      let new = flag-value $rest [-b -B]
      if $new != null { return (switch-ask $root $dir $new true) }
      let target = $rest | where {|a| not ($a | str starts-with '-') } | get -o 0
      if $target != null and (local-branch $dir $target) {
        switch-ask $root $dir $target false
      } else if '--detach' in $rest {
        switch-ask $root $dir null false
      }
    }
    _ => null
  }
}

def switch-ask [root: string, dir: string, target: any, new: bool]: nothing -> record {
  let current = git-out $dir [branch --show-current] | default 'a detached HEAD'
  let hint = if $target != null { $": `(suggest $root $target $new)`" } else { '' }
  ask $"AGENTS.md: this worktree is for ($current); switching branches here breaks the <repo>/<branch> layout. Create a separate worktree instead($hint)."
}

export def verdict [input: record]: nothing -> any {
  let cwd = $input.cwd? | default '.'
  let commands = simple-commands ($input.tool_input?.command? | default '')
  mut asks = []
  for c in (with-cwd $cwd $commands) {
    let argv = strip-wrappers $c.argv
    if ($argv | get -o 0) != git { continue }
    let dir = git-dir $c.cwd $argv
    let found = [(layout-verdict $argv $dir) (ticket-verdict $argv $dir) (track-verdict $argv $dir)] | compact
    let denied = $found | where decision == deny | get -o 0
    if $denied != null { return $denied }
    $asks = $asks ++ $found
  }
  $asks | get -o 0
}

def main [] {
  $in | run-hook git-branch {|input| verdict $input }
}
