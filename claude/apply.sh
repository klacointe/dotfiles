#!/bin/bash
# Merge the curated settings from this repo into ~/.claude/settings.json.
# Keys defined here win; machine-local keys (hooks, autoMode, ...) are kept.
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)/settings.json"
DEST="$HOME/.claude/settings.json"

mkdir -p "$(dirname "$DEST")"
[ -f "$DEST" ] || echo '{}' > "$DEST"

cp "$DEST" "$DEST.bak"
TMP="$(mktemp)"
jq -s '.[0] * .[1]' "$DEST" "$SRC" > "$TMP"
mv "$TMP" "$DEST"

echo "Merged $SRC into $DEST (backup: $DEST.bak)"
