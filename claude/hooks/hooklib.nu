# Shared helpers for Claude Code PreToolUse hooks.
#
# Each rule script exports `verdict [input: record]`, which returns
# `deny`/`ask` (or null to allow), and wires it up with `run-hook`.

# Jira ticket ID, e.g. ABC-123.
export const TICKET_RE = '[A-Z][A-Z0-9]+-[0-9]+'

# A quoted string, or an unquoted heredoc. Replacing with '$1$2' keeps quoted
# strings intact and drops heredoc bodies, so a body is never read as commands.
const HEREDOC_RE = r#'("(?:\\.|[^"\\])*"|'[^']*')|(<<-?\s*(['"]?)(\w+)\3[^\n]*)\n(?s:.*?)\n\s*\4(?=\n|$)'#

# One shell token: a word (including any quoted parts) or an operator.
const TOKEN_RE = r#'(?<tok>(?:[^\s|;&()`'"]+|'[^']*'|"(?:\\.|[^"\\])*")+|\|\||&&|;;|[|;&()`\n])'#

# The quoted parts of a word, for unquoting.
const QUOTED_RE = r#''([^']*)'|"((?:\\.|[^"\\])*)"'#

# The double-quoted parts of a word, where `$(...)` and backticks still expand.
const DOUBLE_QUOTED_RE = r#'"(?<dq>(?:\\.|[^"\\])*)"'#

# Tokens that end one simple command and start the next.
const SEPARATORS = ['|' '||' '&' '&&' ';' ';;' '(' ')' '{' '}' '`' "\n"]

# Words that run the command that follows them, mapped to their flags that
# take a value (so the value isn't mistaken for the command). Shell keywords
# are included so `if grep …; then` is still checked.
const WRAPPERS = {
  sudo: [-u -g -h -p -C -U -r -t -D]
  doas: [-u -C]
  env: [-u -C -S]
  xargs: [-I -n -P -L -d -E -s -a]
  timeout: [-s -k]
  nice: [-n]
  nohup: []
  command: []
  exec: [-a]
  time: []
  '!': []
  if: [] then: [] else: [] elif: [] do: [] while: [] until: []
}

# Shells whose `-c` argument is itself a command line.
const SHELLS = [sh bash zsh dash ksh]

# A PreToolUse verdict that blocks the tool call.
export def deny [reason: string]: nothing -> record {
  {decision: deny, reason: $reason}
}

# A PreToolUse verdict that asks the user to confirm the tool call.
export def ask [reason: string]: nothing -> record {
  {decision: ask, reason: $reason}
}

# Run a hook: parse the hook input JSON from stdin, apply `check`, and print
# its verdict. Internal errors become a visible warning instead of a silent
# failure, without blocking the tool call.
export def run-hook [name: string, check: closure]: string -> nothing {
  let raw = $in
  try {
    let verdict = do $check ($raw | from json)
    if $verdict != null {
      {
        hookSpecificOutput: {
          hookEventName: PreToolUse
          permissionDecision: $verdict.decision
          permissionDecisionReason: $verdict.reason
        }
      } | to json --raw | print
    }
  } catch {|err|
    {systemMessage: $"AGENTS.md hook ($name) failed, rule not enforced: ($err.msg)"}
    | to json --raw | print
  }
}

# Ticket ID derived from the current git branch in cwd, if any.
export def branch-ticket [cwd: string]: nothing -> any {
  let branch = do { ^git -C $cwd branch --show-current } | complete | get stdout | str trim
  $branch | parse --regex ('^(?<id>' + $TICKET_RE + ')/') | get -o 0.id
}

# Contents of each top-level `$(...)` in s.
def command-substitutions [s: string]: nothing -> list<string> {
  if not ($s | str contains '$(') { return [] }
  let chars = $s | split chars
  mut found = []
  mut depth = 0
  mut start = 0
  mut i = 0
  while $i < ($chars | length) {
    let c = $chars | get $i
    if $depth == 0 {
      if $c == '$' and ($chars | get -o ($i + 1)) == '(' {
        $depth = 1
        $i += 1
        $start = $i + 1
      }
    } else if $c == '(' {
      $depth += 1
    } else if $c == ')' {
      $depth -= 1
      if $depth == 0 {
        $found = $found | append ($chars | slice $start..<$i | str join)
      }
    }
    $i += 1
  }
  $found
}

# Command lines nested inside a raw (still quoted) word: `$(...)` and
# backticks within its double-quoted parts.
def nested-in-word [word: string]: nothing -> list<string> {
  $word | parse --regex $DOUBLE_QUOTED_RE | get dq | each {|dq|
    let inner = $dq | str replace -ar $HEREDOC_RE '$1$2'
    let backticks = $inner | parse --regex '`(?<cmd>[^`]*)`' | get cmd
    (command-substitutions $inner) ++ $backticks
  } | flatten
}

# Command lines run by a simple command, e.g. the script in `bash -c '…'`,
# `eval …`, or `watch …`.
def nested-in-argv [argv: list<string>]: nothing -> list<string> {
  let argv = strip-wrappers $argv
  let prog = program $argv
  if $prog in $SHELLS {
    let i = $argv | enumerate | where {|a| $a.item =~ '^-[a-z]*c$' } | get -o 0.index
    let script = if $i != null { $argv | get -o ($i + 1) }
    if $script != null { [$script] } else { [] }
  } else if $prog in [eval watch] {
    [($argv | skip 1 | where {|a| not ($a | str starts-with '-') } | str join ' ')]
  } else {
    []
  }
}

# Split a shell command line into the argv of each simple command, including
# commands nested in substitutions and `bash -c` style arguments. Quoted
# strings stay single words, so their contents are never taken for commands.
export def simple-commands [cmd: string]: nothing -> list<list<string>> {
  let raw_words = $cmd
    | str replace -ar $HEREDOC_RE '$1$2'
    | parse --regex $TOKEN_RE
    | get tok

  mut commands = []
  mut current = []
  mut nested = []
  for raw in $raw_words {
    if $raw in $SEPARATORS {
      if ($current | is-not-empty) { $commands = $commands | append [$current] }
      $current = []
    } else {
      $nested = $nested ++ (nested-in-word $raw)
      $current = $current | append ($raw | str replace -ar $QUOTED_RE '$1$2')
    }
  }
  if ($current | is-not-empty) { $commands = $commands | append [$current] }

  for argv in $commands {
    $nested = $nested ++ (nested-in-argv $argv)
  }
  $commands ++ ($nested | where {|c| $c | is-not-empty } | each {|c| simple-commands $c } | flatten)
}

# Drop leading env assignments, wrapper commands, and the wrappers' flags.
export def strip-wrappers [argv: list<string>]: nothing -> list<string> {
  mut args = $argv
  while ($args | is-not-empty) {
    let word = $args | first
    if $word =~ '^[A-Za-z_][A-Za-z0-9_]*=' {
      $args = $args | skip 1
    } else if $word in $WRAPPERS {
      let value_flags = $WRAPPERS | get $word
      $args = $args | skip 1
      while ($args | is-not-empty) and ($args | first | str starts-with '-') {
        let flag = $args | first
        $args = $args | skip 1
        if $flag == '--' { break }
        if $flag in $value_flags { $args = $args | skip 1 }
      }
      # timeout's first positional is the duration, not the command.
      if $word == timeout { $args = $args | skip 1 }
    } else {
      break
    }
  }
  $args
}

# Basename of the command actually being run, ignoring wrappers.
export def program [argv: list<string>]: nothing -> any {
  strip-wrappers $argv | get -o 0 | if $in != null { path basename }
}

# Value of the first matching flag, as `--flag value` or `--flag=value`.
export def flag-value [argv: list<string>, names: list<string>]: nothing -> any {
  for i in 0..<($argv | length) {
    let arg = $argv | get $i
    if $arg in $names {
      return ($argv | get -o ($i + 1))
    }
    for name in ($names | where {|n| $n | str starts-with '--' }) {
      if ($arg | str starts-with $"($name)=") {
        return ($arg | str substring ($name | str length | $in + 1)..)
      }
    }
  }
  null
}
