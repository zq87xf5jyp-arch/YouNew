#!/bin/sh
set -eu

fail() {
  echo "restore-rehearsal: $*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "$1 is required"
}

archive="${BACKUP_ARCHIVE:-${1:-}}"
identity_file="${AGE_IDENTITY_FILE:-${2:-}}"
report_path="${RESTORE_REPORT_PATH:-./restore-verification.json}"

[ -n "$archive" ] || fail "BACKUP_ARCHIVE or argument 1 is required"
[ -f "$archive" ] || fail "backup archive does not exist: $archive"
[ -n "$identity_file" ] || fail "AGE_IDENTITY_FILE or argument 2 is required"
[ -f "$identity_file" ] || fail "age identity file does not exist: $identity_file"

require_command supabase
require_command docker
require_command jq
require_command psql
docker info >/dev/null 2>&1 || fail "Docker daemon is not available"

rehearsal_root="$(mktemp -d "${TMPDIR:-/tmp}/younew-supabase-restore.XXXXXX")"
case "$rehearsal_root" in
  *younew-supabase-restore.*) ;;
  *) fail "unexpected rehearsal directory: $rehearsal_root" ;;
esac

cleanup() {
  supabase stop --workdir "$rehearsal_root" --no-backup >/dev/null 2>&1 || true
  rm -rf "$rehearsal_root"
}
trap cleanup EXIT HUP INT TERM

supabase init --workdir "$rehearsal_root" >/dev/null
supabase start --workdir "$rehearsal_root" \
  --exclude studio,imgproxy,mailpit,logflare,vector,supavisor,realtime,edge-runtime \
  >/dev/null

status_json="$(supabase status --workdir "$rehearsal_root" --output json)"
restore_url="$(printf '%s' "$status_json" | jq -r '.DB_URL // .db_url // empty')"
[ -n "$restore_url" ] || fail "Supabase status did not return DB_URL"

postgres_major="$(psql --dbname "$restore_url" --tuples-only --no-align --set ON_ERROR_STOP=1 --command "show server_version_num" | cut -c1-2)"
[ "$postgres_major" -ge 17 ] || fail "PostgreSQL 17 or newer is required; found major $postgres_major"

required_schemas="$(psql --dbname "$restore_url" --tuples-only --no-align --set ON_ERROR_STOP=1 --command "
select count(*) from pg_namespace where nspname in ('auth','storage','supabase_migrations');")"
[ "$required_schemas" -eq 3 ] || fail "local Supabase target is missing required managed schemas"

BACKUP_ARCHIVE="$archive" \
AGE_IDENTITY_FILE="$identity_file" \
RESTORE_DATABASE_URL="$restore_url" \
RESTORE_REPORT_PATH="$report_path" \
  sh "$(dirname "$0")/restore-postgres.sh"

printf '%s\n' "$report_path"
