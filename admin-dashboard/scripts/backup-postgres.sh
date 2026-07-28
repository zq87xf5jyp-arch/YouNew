#!/bin/sh
set -eu

if [ -z "${DATABASE_URL:-}" ]; then
  echo "DATABASE_URL is required" >&2
  exit 1
fi

backup_dir="${BACKUP_DIR:-./backups}"
timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$backup_dir"
umask 077
output="$backup_dir/younew-$timestamp.dump"
pg_dump --format=custom --no-owner --no-acl --file="$output" "$DATABASE_URL"
find "$backup_dir" -type f -name 'younew-*.dump' -mtime +"${BACKUP_RETENTION_DAYS:-30}" -delete
echo "$output"
