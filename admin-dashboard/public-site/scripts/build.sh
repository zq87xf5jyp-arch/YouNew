#!/usr/bin/env bash
set -euo pipefail

project_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$project_root"

next build

mkdir -p dist/server dist/client dist/.openai
cp worker/index.js dist/server/index.js
cp .openai/hosting.json dist/.openai/hosting.json
cp -R out/. dist/client/

echo "Prepared Sites package in $project_root/dist"
