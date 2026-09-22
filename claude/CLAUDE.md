# Agent Guidelines

> **CRITICAL: These rules must be followed at all times**

> **OPERATIONAL SAFETY OVERRIDE:** ALWAYS ASK FOR EXPLICIT APPROVAL BEFORE ANY ACTION THAT MODIFIES STATE (local or remote). NEVER EXECUTE COMMANDS, EDIT FILES, COMMIT, PUSH, OR UPDATE EXTERNAL SYSTEMS WITHOUT USER CONFIRMATION FIRST. Ask for confirmation before each individual state-changing action (do not batch implicit approvals).

## Version Control Rules

### Git Operations

**NEVER perform these actions without explicit user approval:**

- Push to remote repositories
- Push to protected branches (main, master, production)
- Commit changes
- Push force on remote branches

**CRITICAL COMMIT RULE:**

- **ALWAYS ask before committing, even if the user previously authorized commits**
- Each commit requires explicit confirmation from the user at the time of commit
- Never assume prior authorization applies to subsequent commits

**ALWAYS do these before committing:**

- Run compilation checks, tests, or other available code analysis tools
- Check for documentation updates when renaming or moving files:
  - Search for references to old names in moduledocs, README.md, comments, etc.
  - Use `grep` to find all occurrences

**ALWAYS ask to update PR description after committing (if any)**

### GitHub Actions

**NEVER perform these without explicit user approval:**

- Creating pull requests
- Updating PR descriptions
- Adding comments to PRs/issues
- Merging PRs
- Any `gh` CLI command that modifies remote state
- Mark PR as "Ready to review", only create "Draft" PRs.

**NEVER include in PR descriptions:**

- Real names of team members or commenters
- References to specific people in commit messages or PR descriptions
- Keep all public-facing content anonymous and professional

### Branch Workflow

**CRITICAL: Never use git worktrees unless explicitly asked:**

- When switching repos to a feature branch, always `git checkout <branch>` in the main repo folder
- Never use `git worktree add` unless the user explicitly asks for a worktree

**CRITICAL: Never merge on feature branches, always rebase:**

- Use `git rebase origin/main` (or target branch) to update feature branches
- Never use `git merge main` on feature branches
- This keeps a clean, linear git history
- Example: `git fetch origin && git rebase origin/main`

**Creating a feature branch:**

**CRITICAL: Always set remote tracking branch when creating a feature branch**

- After creating a branch locally, always push it to the remote immediately to set up tracking:
  ```bash
  git checkout -b <type>/[LINEAR-REF-]feature-name
  git push -u origin <type>/[LINEAR-REF-]feature-name
  ```
- Ask for user approval before pushing (per the rules above), but ask at branch creation time
- Never set `--set-upstream-to=origin/main` — the tracking branch must match the feature branch name on the remote

Branch names MUST be prefixed with the appropriate type:

- `fix/` - Bug fixes
- `feat/` - New features
- `chore/` - Maintenance tasks, dependency updates, tooling
- `refactor/` - Code refactoring without behavior changes
- `docs/` - Documentation only changes
- `test/` - Adding or updating tests
- `perf/` - Performance improvements

**Format:**

```bash
git checkout -b <type>/[LINEAR-REF-]feature-name
```

**Linear Reference:**

- Include Linear issue reference (e.g., `proj-123-`) between type prefix and feature name when available
- Use lowercase and convert issue ID to kebab-case format
- If no Linear issue exists, omit the reference

**Examples:**

```bash
git checkout -b fix/proj-123-handle-empty-names
git checkout -b feat/proj-456-add-user-authentication
git checkout -b chore/update-dependencies  # No Linear issue
```

**Commit message format:**

```
<type>: brief description of change

- Detailed explanation of what changed
- Why it was changed
- Impacts

Relates to: #${LINEAR_PROJECT}-${LINEAR_ISSUE_NUMBER}
```

**Type must match branch prefix** (e.g., `fix/` branch should have `fix:` commits)

**Linear Reference Format:**

- Use `#${LINEAR_PROJECT}-${LINEAR_ISSUE_NUMBER}` format (e.g., `#PROJ-123`)
- Include in commit messages: `Relates to: #PROJ-123`
- Include in PR titles: `<type>: description of changes #PROJ-123` (reference at end, no brackets)
- Example commit: `feat: add pagination to the search endpoint\n\nRelates to: #PROJ-123`
- Example PR title: `feat: add pagination to the search endpoint #PROJ-123`

**PR title format:**

**CRITICAL: PR titles MUST follow the Conventional Commits convention**

```
<type>: brief description of change #LINEAR-REF
```

- `type` must match the branch prefix (`feat`, `fix`, `chore`, `refactor`, `docs`, `test`, `perf`)
- Linear reference goes at the end, no brackets (omit it when there is no Linear issue)
- Why: PRs are squash-merged, so the PR title becomes the commit message on the target branch. `release-please` parses those messages to compute the next version and changelog — a non-semantic title means the change is silently missed in the release
- Applies when editing an existing PR title too

## Project Management

### Linear

**NEVER perform these actions without explicit user approval:**

- Creating Linear issues
- Updating Linear issues
- Commenting on Linear issues
- Changing issue status
- Any Linear operation that modifies state

**CRITICAL LINEAR RULE:**

- **ALWAYS ask before creating Linear issues, even if the user asked you to create them**
- List the issues you plan to create and wait for explicit confirmation
- Never assume permission to create issues without asking first

## Observability & Monitoring

### Datadog

**NEVER perform these actions without explicit user approval:**

- Creating or updating monitors
- Creating or updating dashboards
- Creating or updating notebooks
- Modifying SLOs
- Creating or updating incidents
- Adding comments to incidents
- Updating incident status
- Any Datadog API or MCP operation that modifies state

**Read-only operations are allowed:**

- Searching logs, metrics, traces, spans
- Retrieving monitor/dashboard/notebook details
- Querying metrics and APM data
- Viewing incidents and their details

## File Management

### Configuration Files

**NEVER commit per-project AGENTS.md** - This file is for local development guidance only

**NEVER commit /docs directory** - This is for local development documentation only

## Local Context

Machine-local, non-public context (project locations, repository layout) is not version-controlled and is imported from:

@~/.claude/CLAUDE.private.md
