#!/usr/bin/env bash
set -euo pipefail

project_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$project_root"

node_command=${NODE_BINARY:-node}
typescript_cli="$project_root/node_modules/typescript/bin/tsc"
eslint_cli="$project_root/node_modules/eslint/bin/eslint.js"
if [[ ! -f "$typescript_cli" ]]; then
  typescript_cli="$project_root/../node_modules/typescript/bin/tsc"
  eslint_cli="$project_root/../node_modules/eslint/bin/eslint.js"
fi

echo "[1/10] Production build and static Hostinger package"
bash scripts/build.sh
echo "[2/10] TypeScript"
"$node_command" "$typescript_cli" --noEmit
echo "[3/10] ESLint"
"$node_command" "$eslint_cli" src tests --max-warnings=0
echo "[4/10] Unit and schema tests"
"$node_command" --test tests/*.test.ts
echo "[5/10] Static smoke tests"
"$node_command" scripts/smoke-test.mjs
echo "[6/10] Links, fragments and assets"
"$node_command" scripts/check-links.mjs
echo "[7/10] Security package scan"
"$node_command" scripts/check-security.mjs
echo "[8/10] Deployment invariants and runtime 404"
"$node_command" scripts/check-pre-deploy.mjs
echo "[9/10] Upstream practical-guide governance"
python3 ../../scripts/generate-data-dashboard.py
python3 ../../scripts/generate-data-observability.py
python3 ../../scripts/data-project-import-static-qa.py
python3 ../../scripts/practical-guide-static-qa.py
python3 ../../scripts/priority-research-static-qa.py
python3 ../../scripts/build-priority-1-editorial-handoff.py --check
python3 ../../scripts/content-readiness-audit.py --check
echo "[10/10] Current governed and released source health"
python3 ../../scripts/data-health-gate.py

echo "PRE-DEPLOY PASS — package is locally verified; no public deployment was performed."
