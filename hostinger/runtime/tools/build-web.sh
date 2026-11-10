#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
exec "${NODE_BINARY:-node}" "$root/tools/publish-catalog.mjs" "$@"
