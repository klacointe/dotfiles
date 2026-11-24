#!/usr/bin/env bash
# Startup hook: re-run retitle.sh every POLL_SECONDS (default 2) so a tab is renamed as soon as
# you start a program in it (herdr does not emit a hook event for that).
#
# Lifecycle (herdr startup hooks are one-shot, so this is deliberately self-limiting):
#   - single instance: a lock file makes extra copies exit immediately
#   - stops when the herdr server stops answering (3 failed checks in a row) or on TERM/INT/HUP
#   - never leaves a child behind: the sleep is waited on and killed in the trap
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
herdr_bin="${HERDR_BIN_PATH:-herdr}"
state="${HERDR_PLUGIN_STATE_DIR:-$HOME/.cache/herdr-tab-titles}"
interval="${POLL_SECONDS:-2}"
mkdir -p "$state"

exec 8>"$state/poll.lock"
flock -n 8 || exit 0          # already polling
echo $$ >"$state/poll.pid"

sleeper=""
cleanup() {
  [ -n "$sleeper" ] && kill "$sleeper" 2>/dev/null
  rm -f "$state/poll.pid"
  exit 0
}
trap cleanup TERM INT HUP EXIT

fails=0
while true; do
  if "$herdr_bin" workspace list >/dev/null 2>&1; then
    fails=0
    bash "$here/retitle.sh" >/dev/null 2>&1
  else
    fails=$((fails + 1))
    [ "$fails" -ge 3 ] && break   # server is gone: stop
  fi
  sleep "$interval" &
  sleeper=$!
  wait "$sleeper"
  sleeper=""
done
