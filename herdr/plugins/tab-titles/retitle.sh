#!/usr/bin/env bash
# Rename tabs after the program running in their focused pane (nvim, claude, htop, ui.py, zsh...).
# Only touches tabs whose label is still a bare number or what this script set last time,
# so tabs you rename by hand (prefix+shift+t) are left alone.
set -uo pipefail

herdr_bin="${HERDR_BIN_PATH:-herdr}"
state="${HERDR_PLUGIN_STATE_DIR:-$HOME/.cache/herdr-tab-titles}"
mkdir -p "$state"
map="$state/auto.json"
[ -s "$map" ] || echo '{}' >"$map"

# Events arrive in bursts: serialize runs.
exec 9>"$state/lock"
flock -w 10 9 || exit 0

# Program name from the pane's foreground process (the leaf of the process tree).
# Shells with no script -> shell name; interpreters (python, node, bash script...) -> script name.
program_for() {  # $1 = pane id, $2 = agent (may be empty)
  local name
  if [ -n "$2" ] && [ "$2" != "null" ]; then printf '%s' "$2"; return; fi
  name="$("$herdr_bin" pane process-info --pane "$1" 2>/dev/null | jq -r '
    def base: split("/") | last;
    (.result.process_info.foreground_processes // []) | last // empty
    | .name as $n | (.argv // []) as $a
    | if ($n | IN("bash", "sh", "zsh", "fish", "dash")) then
        (if ($a | length) > 1 and ($a[1] | startswith("-") | not) then ($a[1] | base) else $n end)
      elif ($n | test("^(python|ruby|node|perl|bun|deno|elixir|mix)")) then
        (([$a[1:][] | select(startswith("-") | not)][0] // $n) | base)
      else $n end')"
  [ -n "$name" ] || return 1
  [ "${#name}" -gt 20 ] && name="${name:0:19}…"
  printf '%s' "$name"
}

tabs="$("$herdr_bin" tab list 2>/dev/null)" || exit 0
panes="$("$herdr_bin" pane list 2>/dev/null)" || exit 0
new_map='{}'

while IFS=$'\t' read -r id label; do
  [ -n "$id" ] || continue
  auto="$(jq -r --arg t "$id" '.[$t] // empty' "$map")"
  if [[ "$label" =~ ^[0-9]+$ ]] || { [ -n "$auto" ] && [ "$label" = "$auto" ]; }; then
    IFS=$'\t' read -r pane agent < <(jq -r --arg t "$id" '
      [.result.panes[] | select(.tab_id == $t)]
      | (map(select(.focused))[0] // .[0]) // empty
      | [.pane_id, (.agent // "")] | @tsv' <<<"$panes")
    if [ -n "${pane:-}" ] && name="$(program_for "$pane" "${agent:-}")"; then
      # Re-read the label right before renaming: someone (e.g. review-queue) may have named the tab
      # while we were looking up its process.
      cur="$("$herdr_bin" tab get "$id" 2>/dev/null | jq -r '.result.tab.label // empty')"
      if [ -n "$cur" ] && { [[ "$cur" =~ ^[0-9]+$ ]] || [ "$cur" = "$auto" ]; }; then
        [ "$name" != "$cur" ] && "$herdr_bin" tab rename "$id" "$name" >/dev/null 2>&1
        new_map="$(jq -c --arg t "$id" --arg n "$name" '. + {($t): $n}' <<<"$new_map")"
      fi
    fi
  fi
  # else: manually renamed (or no pane yet): leave it and forget it
done < <(jq -r '.result.tabs[] | [.tab_id, .label] | @tsv' <<<"$tabs")

printf '%s\n' "$new_map" >"$map"
