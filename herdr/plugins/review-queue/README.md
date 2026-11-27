# review-queue

A herdr plugin: one list of open WTTJ PRs, with two views.

- **requested**: PRs waiting for your review, PRs you already reviewed (follow-up) and bots (collapsed).
- **mine**: your own open PRs, grouped by what blocks them (CI, comments, conflicts, drafts).

Actions start a Claude session in a new tab of the actions space. They are read-only: nothing is posted,
approved, resolved or pushed without your approval.

## Keys in the list

| Key | Action |
|---|---|
| `Tab` | switch view (requested / mine) |
| `1` / `2` | jump to requested / mine |
| `↵` | review (re-review if you follow it); on mine: fix CI, else address comments, else open on GitHub |
| `r` | review (re-review if you follow it) |
| `a` | analyze the PR |
| `c` | address unresolved comments |
| `f` | fix failing CI |
| `o` (or `b`) | open the PR on github.com |
| `y` | copy the PR link |
| `j` / `k`, `↑` / `↓` | move one PR |
| `PgUp` / `PgDn` | move 6 PRs (`PAGE_STEP` in `ui.py`) |
| `g` / `G`, `Home` / `End` | first / last PR |
| `/` | filter (`↵` keeps it, `Esc` clears it) |
| `h` | expand / collapse the bots section (requested) |
| `R` (or `ctrl+r`) | refresh both views |
| `w` | reload the list (restart it in place, same view; picks up code changes) |
| `?` | show / hide the CI and review symbol legend |
| `q` | quit |

Mouse: click selects, double-click or right-click opens on GitHub, the wheel moves one PR, the buttons under
"This PR" and the view tabs are clickable.

## Herdr keys (`herdr/config.toml`, prefix is `ctrl+a`)

| Key | Action |
|---|---|
| `prefix+r` | focus the reviews space (on the view you left) |
| `prefix+shift+r` | reviews space, requested view |
| `prefix+shift+m` | reviews space, mine view |
| `prefix+ctrl+r` | refresh the list from anywhere |
| `prefix+shift+q` | open the list in its own tab |

## Files

- `ui.py`: the list (stdlib curses).
- `review-queue`: engine (workspace and tab handling, starts Claude sessions).
- `actions.sh`, `herdr-plugin.toml`: plugin actions behind the herdr keys.
- `*.graphql`: the GitHub queries.
