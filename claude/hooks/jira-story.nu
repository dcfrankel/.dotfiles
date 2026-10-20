#!/usr/bin/env -S nu --no-config-file --stdin
# PreToolUse(mcp__atlassian__createJiraIssue) hook: require new Jira stories
# to use the AGENTS.md story template's `###` sections.

use hooklib.nu [deny run-hook]

const HEADINGS = ['Summary' 'Acceptance Criteria' 'Technical Details / Other Notes']

# Text of every level-3 heading in an ADF document node.
def adf-headings [node: any]: nothing -> list<string> {
  if ($node | describe | str starts-with 'record') == false { return [] }
  let children = $node.content? | default []
  let own = if $node.type? == heading and $node.attrs?.level? == 3 {
    [($children | each {|c| $c.text? | default '' } | str join | str trim)]
  } else {
    []
  }
  $own ++ ($children | each {|c| adf-headings $c } | flatten)
}

# Level-3 headings in a description: markdown text, or ADF as a record or a
# JSON string.
def headings [tool_input: record]: nothing -> list<string> {
  let desc = $tool_input.description? | default ''
  if ($desc | describe | str starts-with 'record') {
    adf-headings $desc
  } else if $tool_input.contentFormat? == adf {
    adf-headings ($desc | from json)
  } else {
    $desc | lines | parse --regex '^###\s+(?<h>.+?)\s*$' | get h
  }
}

export def verdict [input: record]: nothing -> any {
  let tool_input = $input.tool_input? | default {}
  if ($tool_input.issueTypeName? | default '' | str lowercase) != story { return null }
  let found = headings $tool_input
  let missing = $HEADINGS | where {|h| $h not-in $found }
  if ($missing | is-not-empty) {
    let expected = $HEADINGS | each {|h| $"'### ($h)'" } | str join ', '
    let absent = $missing | each {|h| $"### ($h)" } | str join ', '
    deny $"AGENTS.md: Jira stories must use the template with sections ($expected). Missing: ($absent)."
  }
}

def main [] {
  $in | run-hook jira-story {|input| verdict $input }
}
