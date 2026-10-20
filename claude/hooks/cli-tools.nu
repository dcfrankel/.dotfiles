#!/usr/bin/env -S nu --no-config-file --stdin
# PreToolUse(Bash) hook: enforce the preferred CLI tools from AGENTS.md.
#
# Denies find/locate, grep and friends, and bare python/pip. Asks before
# in-place `sed -i` / `perl -i` edits, which should use ast-grep or the Edit
# tool for code transforms.

use hooklib.nu [ask deny program run-hook simple-commands strip-wrappers]

const FD = 'use `fd` instead of `{prog}` to find files by name/path.'
const RG = 'use `rg` instead of `{prog}` to search text (or `ast-grep` for structural code search).'
const UV = 'use `uv` instead of bare `{prog}` (`uv run`, `uv pip`, `uvx`). For JSON/YAML use `jq`/`yq`, not `python -c`.'

const BANNED = {
  find: $FD
  locate: $FD
  grep: $RG
  egrep: $RG
  fgrep: $RG
  rgrep: $RG
  ack: $RG
}

# Message for a banned program, or null.
def banned [prog: string]: nothing -> any {
  if $prog =~ '^(python|pip)[0-9.]*$' { return $UV }
  $BANNED | get -o $prog
}

# Whether argv edits files in place with sed or perl.
def in-place-edit [argv: list<string>]: nothing -> bool {
  let argv = strip-wrappers $argv
  match (program $argv) {
    sed => ($argv | skip 1 | any {|a| $a =~ '^-[a-zA-Z]*i' or $a starts-with '--in-place' })
    perl => ($argv | skip 1 | any {|a| $a =~ '^-[a-zA-Z]*i' })
    _ => false
  }
}

export def verdict [input: record]: nothing -> any {
  let commands = simple-commands ($input.tool_input?.command? | default '')
  for argv in $commands {
    let prog = program $argv
    let message = if $prog != null { banned $prog }
    if $message != null {
      return (deny $"AGENTS.md: ($message | str replace '{prog}' $prog)")
    }
  }
  if ($commands | any {|argv| in-place-edit $argv }) {
    return (ask 'AGENTS.md: in-place `sed -i`/`perl -i` edit. Use `ast-grep` (or the Edit tool) for code transforms; approve only for non-code files.')
  }
  null
}

def main [] {
  $in | run-hook cli-tools {|input| verdict $input }
}
