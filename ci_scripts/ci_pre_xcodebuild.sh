#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPOSITORY_ROOT=${CI_PRIMARY_REPOSITORY_PATH:-$(dirname "$SCRIPT_DIR")}

if [ ! -f "$REPOSITORY_ROOT/YouNew.xcodeproj/project.pbxproj" ]; then
    echo "Source checkout unavailable on this Xcode Cloud worker; static QA already ran on the build worker."
    exit 0
fi

cd "$REPOSITORY_ROOT"
./scripts/run-static-qa.sh
