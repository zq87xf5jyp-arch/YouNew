#!/usr/bin/env bash
set -euo pipefail

project_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$project_root"

node_command=${NODE_BINARY:-node}
next_cli="$project_root/node_modules/next/dist/bin/next"
if [[ ! -f "$next_cli" ]]; then
  next_cli="$project_root/../node_modules/next/dist/bin/next"
fi

"$node_command" scripts/generate-public-content.mjs
mkdir -p public/data
cp src/config/status.json public/data/status.json
cp src/config/site-config.json public/data/site-config.json
"$node_command" scripts/version-service-worker.mjs

rm -rf "$project_root/.next" "$project_root/out"
"$node_command" "$next_cli" build
"$node_command" scripts/strip-static-client.mjs
"$node_command" scripts/finalize-service-worker.mjs

rm -rf "$project_root/dist"
mkdir -p dist/client
cp -R out/. dist/client/

if [[ -f worker/index.js && -f .openai/hosting.json ]]; then
  mkdir -p dist/server dist/.openai
  cp worker/index.js dist/server/index.js
  cp .openai/hosting.json dist/.openai/hosting.json
fi

echo "Prepared static Hostinger package in $project_root/out and mirrored it to $project_root/dist/client"
