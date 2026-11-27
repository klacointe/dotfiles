#!/usr/bin/env bash
# Reports $project, $branch and $ticket on every agent pane, for the sidebar's agent rows
# ([ui.sidebar.agents.rows_by_agent] in config.toml).
#   agent-meta.sh          report once
#   agent-meta.sh --loop   report every 5s (values expire after 20s, so they vanish if the loop dies)
# project = git repo name, branch = current branch, ticket = Linear key found in the branch (feat/pla-4293-x -> PLA-4293).
set -u
H=${HERDR_BIN_PATH:-herdr}
SOURCE=agent-meta
INTERVAL=5

report() {
  "$H" api snapshot 2>/dev/null |
    jq -r '.. | objects | select(.pane_id? and .agent? != null) | [.pane_id, (.foreground_cwd // .cwd)] | @tsv' |
    while IFS=$'\t' read -r pane dir; do
      dir=${dir% (deleted)}
      [ -d "$dir" ] || continue
      top=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null) || continue
      project=${top##*/}
      branch=$(git -C "$dir" branch --show-current 2>/dev/null)
      ticket=$(printf '%s' "$branch" | grep -oiE '[a-z]{2,6}-[0-9]+' | head -1 | tr '[:lower:]' '[:upper:]')
      args=()
      for pair in "project=$project" "branch=$branch" "ticket=$ticket"; do
        name=${pair%%=*} value=${pair#*=}
        if [ -n "$value" ]; then args+=(--token "$pair"); else args+=(--clear-token "$name"); fi
      done
      "$H" pane report-metadata "$pane" --source "$SOURCE" --ttl-ms 20000 "${args[@]}" >/dev/null 2>&1
    done
}

if [ "${1:-}" = "--loop" ]; then
  while :; do report; sleep "$INTERVAL"; done
else
  report
fi
