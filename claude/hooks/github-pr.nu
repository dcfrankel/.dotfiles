#!/usr/bin/env -S nu --no-config-file --stdin
# PreToolUse(Bash) hook: enforce the AGENTS.md GitHub PR conventions on
# `gh pr create` / `gh pr edit`:
#   - title is prefixed with "<PROJECT>-<ID> - " (asks if the ID differs from
#     the current branch's)
#   - body is no longer than MAX_BODY_LINES lines (inline, heredoc, or file)
#   - in a bare+worktree repo's container dir (which has no branch of its own),
#     the PR's branch is given explicitly or the command runs in a worktree

use hooklib.nu [TICKET_RE ask bare-root branch-ticket deny flag-value in-worktree run-hook simple-commands strip-wrappers ticket-of with-cwd]

const MAX_BODY_LINES = 10

const HEREDOC_RE = r#'^\$\(\s*cat\s*<<-?\s*['"]?(?<delim>\w+)['"]?[^\n]*\n(?<body>(?s:.*?))\n\s*\k<delim>\s*\)$'#

# Literal PR body text, unwrapping a `$(cat <<EOF ... EOF)` heredoc.
def body-text [body: string]: nothing -> string {
  let heredoc = $body | str trim | parse --regex $HEREDOC_RE | get -o 0.body
  $heredoc | default ($body | str replace --all '\n' "\n")
}

# PR body from --body, or the file given to --body-file (not stdin).
def pr-body [argv: list<string>, cwd: string]: nothing -> any {
  let body = flag-value $argv [--body -b]
  if $body != null { return (body-text $body) }
  let file = flag-value $argv [--body-file -F]
  let path = if $file != null and $file != '-' { $cwd | path join $file }
  if $path != null and ($path | path exists) {
    open --raw $path | into string
  }
}

# Verdict for one `gh pr create|edit` argv.
def check-pr [argv: list<string>, cwd: string]: nothing -> any {
  let head = flag-value $argv [--head -H]
  let action = $argv | get 2
  if (bare-root $cwd) != null and not (in-worktree $cwd) {
    let target = $argv | get -o 3 | default '-'
    if ($action == create and $head == null) or ($action == edit and ($target | str starts-with '-')) {
      return (deny $"AGENTS.md: ($cwd) is a bare repo's container dir, not a checkout, so `gh pr ($action)` can't tell which branch the PR is for. Run it inside the worktree \(`cd <repo>/<branch>`\) or name the branch \(--head <branch> / gh pr edit <branch>\).")
    }
  }
  let ticket = if $head != null { ticket-of $head } else { branch-ticket $cwd }
  let example = $"($ticket | default 'ABC-123') - <short_summary>"
  let title = flag-value $argv [--title -t]

  if $title != null {
    let title_ticket = $title | parse --regex ('^(?<id>' + $TICKET_RE + ') - .+') | get -o 0.id
    if $title_ticket == null {
      return (deny $"AGENTS.md: PR title must be prefixed with the Jira ticket ID, e.g. \"($example)\". Got: \"($title)\".")
    }
    if $ticket != null and $title_ticket != $ticket {
      return (ask $"AGENTS.md: PR title uses ($title_ticket) but the branch is for ($ticket). Confirm this is intended.")
    }
  } else if $action == create and not ($argv | any {|a| $a in [--web -w] }) {
    return (deny $"AGENTS.md: pass an explicit --title of the form \"($example)\".")
  }

  let body = pr-body $argv $cwd
  if $body != null {
    let count = $body | str trim --right | lines | length
    if $count > $MAX_BODY_LINES {
      return (deny $"AGENTS.md: PR body must be brief \(no more than ($MAX_BODY_LINES) lines\); it is ($count) lines. Shorten it.")
    }
  }
  null
}

export def verdict [input: record]: nothing -> any {
  let cwd = $input.cwd? | default '.'
  let commands = simple-commands ($input.tool_input?.command? | default '')
  for c in (with-cwd $cwd $commands) {
    let argv = strip-wrappers $c.argv
    if ($argv | take 2) == [gh pr] and ($argv | get -o 2) in [create edit] {
      let result = check-pr $argv $c.cwd
      if $result != null { return $result }
    }
  }
  null
}

def main [] {
  $in | run-hook github-pr {|input| verdict $input }
}
