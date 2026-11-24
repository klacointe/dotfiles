#!/usr/bin/env bash
# Entry point for the plugin actions declared in herdr-plugin.toml.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
herdr_bin="${HERDR_BIN_PATH:-herdr}"
export PATH="$HOME/.local/bin:$PATH"   # gh, jq, claude

case "${1:-}" in
  open)       "$herdr_bin" plugin pane open --plugin "${HERDR_PLUGIN_ID:-wttj.review-queue}" --entrypoint list ;;
  workspace)  "$here/review-queue" --workspace ;;
  review-url) "$here/review-queue" --open "${HERDR_PLUGIN_CLICKED_URL:?no clicked url}" ;;
  *) echo "usage: actions.sh open|workspace|review-url" >&2; exit 2 ;;
esac
