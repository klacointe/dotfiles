#!/usr/bin/env bash
# Run cockpit's ensure-spaces.sh when one of its pinned spaces is missing (see herdr-plugin.toml for why).
# Runs on every tab.focused, so the common case is a single `workspace list` and nothing else.
set -uo pipefail

herdr_bin="${HERDR_BIN_PATH:-herdr}"
cockpit="$HOME/.config/cockpit/herdr"
state="${HERDR_PLUGIN_STATE_DIR:-$HOME/.cache/herdr-pinned-spaces}"
mkdir -p "$state"

[ -f "$cockpit/ensure-spaces.sh" ] || exit 0

# The config cockpit's scripts read: the one its mod resolved, or the raw file before any session has run.
settings="$HOME/.cache/cockpit/config.json"
[ -f "$settings" ] || settings="$HOME/.config/cockpit/config.json"
[ -f "$settings" ] || exit 0

# Pinned space names, with cockpit's defaults when the config lists none.
names=$(jq -c '[(.spaces // ["inbox", "terminal", "actions", "to-do", "runbook", "meetings"])[]
  | if type == "object" then .name else . end]' "$settings" 2>/dev/null) || exit 0

# Names of pinned spaces with no workspace labelled "<icon>  <name>" (cockpit's pinned-space label).
missing() {
  "$herdr_bin" workspace list 2>/dev/null | jq -r --argjson names "$names" '
    [.result.workspaces[]?.label] as $labels
    | $names[] | select(. as $n | $labels | any(endswith("  " + $n)) | not)'
}

# On pane.exited the space the pane was in may not be gone yet.
[ "${1:-}" = exited ] && sleep 1

[ -n "$(missing)" ] || exit 0

# Focus events come in bursts: one run at a time, the others leave.
exec 9>"$state/lock"
flock -n 9 || exit 0

# An explicit close sends workspace.closed, and cockpit's own ensure-spaces.sh is already recreating the space:
# let it finish, then look again, so the same space is not created twice.
for _ in 1 2 3 4 5 6 7 8 9 10; do
  pgrep -f "ensure-spaces.sh" >/dev/null 2>&1 || break
  sleep 1
done
sleep 2
[ -n "$(missing)" ] || exit 0
pgrep -f "ensure-spaces.sh" >/dev/null 2>&1 && exit 0

sh "$cockpit/ensure-spaces.sh"
