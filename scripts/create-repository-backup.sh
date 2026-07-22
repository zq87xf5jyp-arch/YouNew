#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
OUTPUT_DIR="${1:-$ROOT/TestArtifacts/repository-backup}"
TIMESTAMP="${BACKUP_TIMESTAMP:-$(date -u +%Y%m%dT%H%M%SZ)}"
NAME="younew-repository-$TIMESTAMP"

if [[ -n "$(git -C "$ROOT" status --porcelain)" ]]; then
  echo "Refusing to label an incomplete working tree as a repository backup." >&2
  echo "Commit or stash local changes, then run the backup again." >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"
git -C "$ROOT" fsck --full --strict
git -C "$ROOT" bundle create "$OUTPUT_DIR/$NAME.bundle" --all
git -C "$ROOT" bundle verify "$OUTPUT_DIR/$NAME.bundle" > "$OUTPUT_DIR/bundle-verification.txt"
git -C "$ROOT" show-ref --head > "$OUTPUT_DIR/refs.txt"
git -C "$ROOT" log -1 --format='commit=%H%ntimestamp=%cI%nsubject=%s' > "$OUTPUT_DIR/head.txt"

(
  cd "$OUTPUT_DIR"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$NAME.bundle" > SHA256SUMS
  else
    shasum -a 256 "$NAME.bundle" > SHA256SUMS
  fi
)

echo "Verified repository backup: $OUTPUT_DIR/$NAME.bundle"
