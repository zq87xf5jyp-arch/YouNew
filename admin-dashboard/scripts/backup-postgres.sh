#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "backup-postgres: $*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "$1 is required"
}

[ -n "${DATABASE_URL:-}" ] || fail "DATABASE_URL is required"
[ -n "${AGE_RECIPIENT:-}" ] || fail "AGE_RECIPIENT is required"

require_command supabase
require_command age
require_command shasum

backup_dir="${BACKUP_DIR:-./backups}"
retention_days="${BACKUP_RETENTION_DAYS:-30}"
case "$retention_days" in
  *[!0-9]*|'') fail "BACKUP_RETENTION_DAYS must be a non-negative integer" ;;
esac

umask 077
mkdir -p "$backup_dir"
backup_dir="$(cd "$backup_dir" && pwd -P)"
case "$backup_dir" in
  /) fail "refusing to use filesystem root as BACKUP_DIR" ;;
esac

timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
archive="$backup_dir/younew-$timestamp.dump.age"
partial="$archive.partial.$$"
manifest="$archive.manifest.json"

cleanup() {
  rm -f "$partial"
}
trap cleanup EXIT HUP INT TERM

dump_section() {
  section="$1"
  shift
  printf '\n-- YOUNEW_BACKUP_SECTION:%s\n' "$section"
  if [ "${SUPABASE_TEMPORARY_ACCESS:-false}" = "true" ]; then
    # The CLI currently drops libpq URI options from its generated container
    # environment and forces `--role postgres`. Execute the CLI-generated,
    # Supabase-filtered script locally so JIT authentication remains read-only.
    {
      printf '%s\n' 'export PGOPTIONS="-c jit=true"' 'export PGSSLMODE="require"'
      supabase db dump \
        --db-url "$DATABASE_URL" \
        --file /dev/stdout \
        --dry-run \
        "$@"
    } | sed -E '/^[[:space:]]*--role "postgres"[[:space:]]*\\$/d' | bash
  else
    supabase db dump \
      --db-url "$DATABASE_URL" \
      --file /dev/stdout \
      "$@"
  fi
}

{
  dump_section roles --role-only
  dump_section schema
  dump_section data --data-only --use-copy
} | age --recipient "$AGE_RECIPIENT" --output "$partial"

chmod 600 "$partial"
mv "$partial" "$archive"
archive_sha256="$(shasum -a 256 "$archive" | awk '{print $1}')"
archive_bytes="$(wc -c < "$archive" | tr -d ' ')"
supabase_version="$(supabase --version | head -n 1)"
age_version="$(age --version | head -n 1)"

cat > "$manifest" <<EOF
{
  "manifest_version": "1.0",
  "created_at_utc": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "archive": "$(basename "$archive")",
  "archive_format": "age-encrypted-supabase-logical-sql-v1",
  "archive_sha256": "$archive_sha256",
  "archive_bytes": $archive_bytes,
  "source": "DATABASE_URL (redacted)",
  "sections": ["roles", "schema", "data"],
  "storage_objects_included": false,
  "edge_functions_included": false,
  "supabase_cli_version": "$supabase_version",
  "age_version": "$age_version",
  "restore_status": "not_yet_verified"
}
EOF
chmod 600 "$manifest"

find "$backup_dir" -type f \( -name 'younew-*.dump.age' -o -name 'younew-*.dump.age.manifest.json' \) \
  -mtime +"$retention_days" -delete

trap - EXIT HUP INT TERM
printf '%s\n' "$archive"
printf '%s\n' "$manifest"
