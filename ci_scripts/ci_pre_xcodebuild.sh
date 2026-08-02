#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPOSITORY_ROOT=${CI_PRIMARY_REPOSITORY_PATH:-$(dirname "$SCRIPT_DIR")}

cd "$REPOSITORY_ROOT"
./scripts/run-static-qa.sh
