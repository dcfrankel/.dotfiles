#!/usr/bin/env -S nu --no-config-file --stdin
# PreToolUse(Bash) hook: enforce the AGENTS.md branch naming convention
# (<PROJECT>-<ID>/<feature>) when creating or renaming a branch.

use hooklib.nu [TICKET_RE deny flag-value run-hook simple-commands strip-wrappers]

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

# Name of the branch this git command creates, if it creates one.
def new-branch-name [argv: list<string>]: nothing -> any {
  match (subcommand-args $argv) {
    [checkout, ..$rest] => (flag-value $rest $CREATE_FLAGS)
    [switch, ..$rest] => (flag-value $rest $CREATE_FLAGS)
    [worktree, add, ..$rest] => (flag-value $rest $CREATE_FLAGS)
    [branch, ..$rest] => (branch-target $rest)
    _ => null
  }
}

export def verdict [input: record]: nothing -> any {
  let commands = simple-commands ($input.tool_input?.command? | default '')
  for argv in ($commands | each {|c| strip-wrappers $c } | where {|c| ($c | get -o 0) == git }) {
    let name = new-branch-name $argv
    if $name != null and not ($name =~ $'^($TICKET_RE)/.+') {
      return (deny $"AGENTS.md: branch '($name)' must be named <PROJECT>-<ID>/<feature> \(e.g. ABC-123/my_feature\). Ask the user for the Jira ticket ID if unknown.")
    }
  }
  null
}

def main [] {
  $in | run-hook git-branch {|input| verdict $input }
}
