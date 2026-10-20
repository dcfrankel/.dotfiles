#!/usr/bin/env -S nu --no-config-file
# Tests for the AGENTS.md hooks.
#
# Run with: nu claude/hooks/test-hooks.nu
#
# Every command named `test ...` is a test. Each runs in its own nu process,
# so one failing assertion doesn't stop the rest.

use std/assert
use cli-tools.nu
use git-branch.nu
use github-pr.nu
use jira-story.nu

const SELF = path self
const HOOKS = path self .

# Decision name for a verdict: deny, ask, or allow.
def decision []: any -> string {
  $in | get -o decision | default allow
}

def bash-input [cmd: string, cwd: string]: nothing -> record {
  {cwd: $cwd, tool_input: {command: $cmd}}
}

# Cases from a [cmd expect] table, as Bash tool inputs run in cwd.
def bash-cases [cwd: string, table: list<record>]: nothing -> list<record> {
  $table | each {|c| {input: (bash-input $c.cmd $cwd), expect: $c.expect} }
}

# Assert every case's verdict matches its `expect`, reporting all mismatches.
def "assert verdicts" [check: closure, cases: list<record>] {
  let bad = $cases
    | each {|c| $c | insert got (do $check $c.input | decision) }
    | where {|c| $c.got != $c.expect }
  let report = $bad | each {|c| $"  expected ($c.expect), got ($c.got) for ($c.input | to nuon)" } | str join "\n"
  assert ($bad | is-empty) $"($bad | length) of ($cases | length) cases failed:\n($report)"
}

# Run body with a temp dir holding long.md and short.md, removed afterwards.
def with-tmp [body: closure]: nothing -> any {
  let dir = mktemp -d
  0..<11 | each { into string } | str join "\n" | save ($dir | path join long.md)
  "short\nbody" | save ($dir | path join short.md)
  try { do $body $dir } finally { rm -rf $dir }
}

# Pipe stdin into a hook script, as Claude Code does, returning its stdout.
def run-hook [script: string, stdin: string]: nothing -> string {
  $stdin | ^($HOOKS | path join $script) | complete | get stdout
}

def heredoc-pr [lines: int]: nothing -> string {
  let body = 0..<$lines | each { into string } | str join "\n"
  $"gh pr create --title \"ABC-1 - x\" --body \"$\(cat <<'EOF'\n($body)\n\nEOF\n\)\""
}

def "test cli-tools" [] {
  with-tmp {|dir|
    assert verdicts {|i| cli-tools verdict $i } (bash-cases $dir [
      [cmd expect];
      ['ps aux | grep foo' deny]
      ['find . -name x' deny]
      ["python3 -c 'print(1)'" deny]
      ['fd x | xargs -0 grep y' deny]
      ['/usr/bin/grep x' deny]
      ['FOO=1 pip install x' deny]
      ['echo $(locate x)' deny]
      ["cd /tmp\ngrep x y" deny]
      ['python3.13 x.py' deny]
      ["bash -c 'grep x'" deny]
      ["zsh -lc 'find .'" deny]
      ["eval 'grep x'" deny]
      ['echo "$(grep x)"' deny]
      ['echo "`grep x`"' deny]
      ['sudo -u root grep x' deny]
      ['fd x | xargs -I {} grep y {}' deny]
      ['timeout 5 grep x' deny]
      ['if grep -q x f; then echo y; fi' deny]
      ['rgrep x' deny]
      ['rg foo' allow]
      ['git grep x' allow]
      ['uv run python x.py' allow]
      ['git commit -m "fix; grep stuff"' allow]
      ["echo '$(grep x)'" allow]
      ['ls -la && cat foo' allow]
      ["cat <<'EOF' > x.txt\nfind foo; it's here\nEOF\nls" allow]
      ["sed -i '' s/a/b/ f.py" ask]
      ['sed --in-place s/a/b/ f.py' ask]
      ['perl -pi -e s/a/b/ f.py' ask]
      ["sed -n '1,5p' f.py" allow]
    ])
  }
}

def "test git-branch" [] {
  with-tmp {|dir|
    assert verdicts {|i| git-branch verdict $i } (bash-cases $dir [
      [cmd expect];
      ['git checkout -b foo' deny]
      ['git switch -c bar origin/main' deny]
      ['git branch new-thing' deny]
      ['git worktree add -b oops ../wt' deny]
      ['git -C repo checkout -b foo' deny]
      ['git fetch && git checkout -b foo' deny]
      ['git branch -m foo' deny]
      ['git branch -M ABC-1/old foo' deny]
      ['git switch --create=foo' deny]
      ['git checkout -b ABC-123/foo' allow]
      ['git branch -m ABC-1/old ABC-1/new' allow]
      ['git branch -d old' allow]
      ['git branch --show-current' allow]
      ['git checkout main' allow]
      ['git worktree add ../wt ABC-1/x' allow]
    ])
  }
}

def "test github-pr" [] {
  with-tmp {|dir|
    assert verdicts {|i| github-pr verdict $i } (bash-cases $dir [
      [cmd expect];
      ['gh pr create --title "fix stuff" --body "x"' deny]
      ['gh pr create --body x' deny]
      ['gh pr edit 12 --title="nope"' deny]
      [(heredoc-pr 11) deny]
      ['gh pr create --title "ABC-1 - x" --body-file long.md' deny]
      ['gh pr create --title "ABC-123 - fix stuff" --body "x"' allow]
      ['gh pr edit 12 --body "y"' allow]
      ["gh pr create -t 'AB-1 - ok' -b 'a\\nb'" allow]
      ['gh pr create --web' allow]
      ['gh pr view 12' allow]
      [(heredoc-pr 10) allow]
      ["gh pr create --title \"ABC-1 - x\" --body \"$(cat <<'EOF'\n1) see (docs\nEOF\n)\"" allow]
      ['gh pr create --title "ABC-1 - x" --body-file short.md' allow]
      ['gh pr create --title "ABC-1 - x" --body-file missing.md' allow]
      ['gh pr create --title "ABC-1 - x" -F -' allow]
    ])
  }
}

def "test github-pr branch ticket" [] {
  with-tmp {|repo|
    ^git init -q -b ABC-123/feature $repo
    assert verdicts {|i| github-pr verdict $i } (bash-cases $repo [
      [cmd expect];
      ['gh pr create --title "ABC-999 - x" --body "y"' ask]
      ['gh pr create --title "ABC-123 - x" --body "y"' allow]
    ])
  }
}

def "test jira-story" [] {
  let full = "### Summary\nx\n### Acceptance Criteria\ny\n### Technical Details / Other Notes\nz"
  let adf_heading = {|text| {type: heading, attrs: {level: 3}, content: [{type: text, text: $text}]} }
  let adf = {type: doc, content: ([Summary 'Acceptance Criteria' 'Technical Details / Other Notes'] | each {|h| do $adf_heading $h })}
  assert verdicts {|i| jira-story verdict $i } [
    [input expect];
    [{tool_input: {issueTypeName: Story, description: 'just text'}} deny]
    [{tool_input: {issueTypeName: Story}} deny]
    [{tool_input: {issueTypeName: Story, description: "Summary, Acceptance Criteria, Technical Details / Other Notes"}} deny]
    [{tool_input: {issueTypeName: Story, description: {type: doc, content: [(do $adf_heading Summary)]}}} deny]
    [{tool_input: {issueTypeName: Story, description: $full}} allow]
    [{tool_input: {issueTypeName: story, description: $full}} allow]
    [{tool_input: {issueTypeName: Story, description: $adf}} allow]
    [{tool_input: {issueTypeName: Story, contentFormat: adf, description: ($adf | to json)}} allow]
    [{tool_input: {issueTypeName: Task, description: x}} allow]
  ]
}

def "test e2e cli-tools deny" [] {
  with-tmp {|dir|
    let out = run-hook cli-tools.nu (bash-input 'grep x' $dir | to json) | from json
    assert equal $out.hookSpecificOutput?.permissionDecision? deny
  }
}

def "test e2e cli-tools allow is silent" [] {
  with-tmp {|dir|
    assert equal (run-hook cli-tools.nu (bash-input 'rg x' $dir | to json)) ''
  }
}

def "test e2e jira-story deny" [] {
  let out = run-hook jira-story.nu ({tool_input: {issueTypeName: Story, description: x}} | to json) | from json
  assert equal $out.hookSpecificOutput?.permissionDecision? deny
}

def "test e2e bad input" [] {
  for script in [cli-tools.nu git-branch.nu github-pr.nu jira-story.nu] {
    let out = run-hook $script 'not json' | from json
    assert str contains ($out.systemMessage? | default '') failed
  }
}

# Run every `test ...` command, each in a fresh nu process.
def main [] {
  let tests = scope commands | where name starts-with 'test ' | get name
  let failed = $tests | each {|name|
    let res = ^$nu.current-exe --no-config-file --commands $"source ($SELF); ($name)" | complete
    if $res.exit_code == 0 {
      print $"PASS ($name)"
    } else {
      print $"FAIL ($name)\n($res.stderr)"
      $name
    }
  } | compact
  if ($failed | is-empty) {
    print $"All ($tests | length) tests passed."
  } else {
    print $"($failed | length) of ($tests | length) tests failed."
    exit 1
  }
}
