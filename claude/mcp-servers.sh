#!/bin/bash
# Register personal MCP servers at user scope (stored in ~/.claude.json).
# Each server's environment is read from a gitignored private/mcp/<name>.env
# file (KEY=value per line), so nothing about it is stored in this repo.
set -euo pipefail

ENV_DIR="$(cd "$(dirname "$0")/.." && pwd)/private/mcp"

add() {
    local name=$1; shift
    local env_file="$ENV_DIR/$name.env" env_args=() line
    [ -f "$env_file" ] || { echo "Missing $env_file" >&2; exit 1; }
    while IFS= read -r line || [ -n "$line" ]; do
        [[ -z "$line" || "$line" == \#* ]] && continue
        env_args+=(-e "$line")
    done < "$env_file"

    claude mcp remove --scope user "$name" >/dev/null 2>&1 || true
    claude mcp add --scope user "$name" "${env_args[@]}" -- "$@"
}

add circleci-mcp-server npx -y @circleci/mcp-server-circleci@latest
add mealie uv tool run --from git+https://github.com/rldiao/mealie-mcp-server mealie-mcp-server
