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
- Always structure branches as the Jira ticket ID and feature work separated by a forward slash eg `<PROJECT>-<ID>/<my_feature>`.

## For Github Pull Requests
- Always prefix the title with the Jira ticket ID eg `<PROJECT>-<ID> - <short_summary>`. The ID can usually be derived from the active git branch name.
- Github PR message bodies should be brief, and be no longer than 5-10 lines.

# Git Bare Repository Layout for Worktrees
- Most git repos are a bare repo with worktrees: `<repo>/.bare/` is the repo, `<repo>/.git` is a file containing `gitdir: ./.bare`, and each worktree lives at `<repo>/<branch>/` (branch slashes become nested dirs, eg `access-log/SRE-4343/add-device-id/`). Repos outside `~/work` (eg `~/.dotfiles`) are normal clones.
- `<repo>/` itself is not a checkout: `git status`, `diff`, `stash`, and `gh pr create`/`edit` only work inside a worktree dir. Do the work there.
- Never switch or create branches inside an existing worktree. Add a worktree from `<repo>/` instead, always naming the branch explicitly (without it, git names the branch after the path's last component):
  - New branch: `git fetch && git worktree add <PROJECT>-<ID>/<feature> -b <PROJECT>-<ID>/<feature> --no-track origin/<default-branch>` (`--no-track` keeps origin/main from becoming the upstream; `push.autoSetupRemote` sets it on first push)
  - Existing local or remote branch: `git worktree add <branch> <branch>`
- Remove worktrees with `git worktree remove <path>`, not `rm -rf`; run `git worktree prune` if a dir was deleted by hand.
- Each worktree has its own untracked files, so install dependencies per worktree (`npm`/`yarn install`, `terraform init`, `uv sync`).
- Stashes are shared by all worktrees of a repo; prefer a WIP commit over `git stash`.
- New clones use the same layout:
```sh
git clone --bare <url> .bare && printf 'gitdir: ./.bare\n' > .git
git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*' && git fetch
git worktree add <default-branch> <default-branch>
```

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
