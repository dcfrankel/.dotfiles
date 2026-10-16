# Command Line Tools — Mandatory Rules

The following rules are MANDATORY for all shell interactions. Violations are never acceptable, even when the prohibited tool seems simpler.

| Task | REQUIRED | NEVER use |
|------|----------|-----------|
| Find files by name/path | `fd` | `find`, `locate` |
| Search text within files | `rg` | `grep`, `egrep`, `ack` |
| Structural/syntax-aware code search | `ast-grep --lang <lang> -p '<pattern>'` | `rg` for AST patterns, `sed` for transforms |
| JSON processing | `jq` | `python -c`, manual parsing |
| YAML processing | `yq` | `python -c`, manual parsing |
| Python scripts & environments | `uv` | bare `python`, `pip`, `pip install` |

These tools are installed and available. Never fall back to alternatives "for simplicity."

# Git and Github
- Always structure branches as the Jira ticket ID and feature work separated by a forward slach eg `<PROJECT>-<ID>/<my_feature>`.

## For Github Pull Requests
- Always prefix the title with the Jira ticket ID eg `<PROJECT>-<ID> - <short_summary>`. The ID can usually be derived from the active git branch name.
- Github PR message bodies should be brief, and be no longer than 5-10 lines.

# Jira Tickets
## Stories
- All new Jira **story** tickets should use the following template when being created:
```markdown
### Summary
<The purpose of this story is to...>

### Acceptance Criteria
<What needs to be done to consider the ticket comple...>

### Technical Details / Other Notes
<Any additional technical details that need to be known to complete the work...>
```
