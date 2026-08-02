#!/usr/bin/env bash
set -euo pipefail

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
migration_manifest="${RESTORE_MIGRATION_MANIFEST:-$(CDPATH= cd -- "$(dirname "$0")/../supabase" && pwd -P)/production-migration-manifest.json}"
migration_source_dir="${RESTORE_MIGRATION_SOURCE_DIR:-$(CDPATH= cd -- "$(dirname "$0")/../supabase/migrations" && pwd -P)}"

[ -n "$archive" ] || fail "BACKUP_ARCHIVE or argument 1 is required"
[ -f "$archive" ] || fail "backup archive does not exist: $archive"
[ -n "$identity_file" ] || fail "AGE_IDENTITY_FILE or argument 2 is required"
[ -f "$identity_file" ] || fail "age identity file does not exist: $identity_file"
[ -f "$migration_manifest" ] || fail "production migration manifest does not exist: $migration_manifest"
[ -d "$migration_source_dir" ] || fail "migration source directory does not exist: $migration_source_dir"

require_command supabase
require_command docker
require_command jq
require_command psql
docker info >/dev/null 2>&1 || fail "Docker daemon is not available"

umask 077
rehearsal_base_dir="${RESTORE_REHEARSAL_BASE_DIR:-${TMPDIR:-/tmp}}"
mkdir -p "$rehearsal_base_dir"
rehearsal_base_dir="$(cd "$rehearsal_base_dir" && pwd -P)"
case "$rehearsal_base_dir" in
  /) fail "refusing to use filesystem root as RESTORE_REHEARSAL_BASE_DIR" ;;
esac
rehearsal_root="$(mktemp -d "$rehearsal_base_dir/younew-supabase-restore.XXXXXX")"
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
local_url="$(printf '%s' "$status_json" | jq -r '.DB_URL // .db_url // empty')"
[ -n "$local_url" ] || fail "Supabase status did not return DB_URL"
restore_url="$(printf '%s' "$local_url" | sed 's#^postgresql://postgres:#postgresql://supabase_admin:#')"
[ "$restore_url" != "$local_url" ] || fail "local DB_URL did not contain the expected postgres role"

admin_is_superuser="$(psql --dbname "$restore_url" --tuples-only --no-align --set ON_ERROR_STOP=1 --command "select current_setting('is_superuser')")"
[ "$admin_is_superuser" = "on" ] || fail "local supabase_admin role is not a superuser"

postgres_major="$(psql --dbname "$restore_url" --tuples-only --no-align --set ON_ERROR_STOP=1 --command "show server_version_num" | cut -c1-2)"
[ "$postgres_major" -ge 17 ] || fail "PostgreSQL 17 or newer is required; found major $postgres_major"

required_schemas="$(psql --dbname "$restore_url" --tuples-only --no-align --set ON_ERROR_STOP=1 --command "
select count(*) from pg_namespace where nspname in ('auth','storage');")"
[ "$required_schemas" -eq 2 ] || fail "local Supabase target is missing required managed schemas"

managed_entries="$rehearsal_root/managed-migrations.tsv"
jq -r '.managedMigrations[]? | [.version, .name] | @tsv' "$migration_manifest" > "$managed_entries"
managed_count="$(awk 'NF { count += 1 } END { print count + 0 }' "$managed_entries")"
[ "$managed_count" -gt 0 ] || fail "production migration manifest has no managed versions"
mkdir -p "$rehearsal_root/supabase/migrations"
while IFS=$'\t' read -r managed_version managed_name; do
  case "$managed_version" in
    20????????????) ;;
    *) fail "invalid managed migration version: $managed_version" ;;
  esac
  case "$managed_name" in
    ''|*[!a-z0-9_]*) fail "invalid managed migration name: $managed_name" ;;
  esac
  managed_file="$migration_source_dir/${managed_version}_${managed_name}.sql"
  [ -f "$managed_file" ] || fail "managed migration file is missing: $managed_file"
  cp "$managed_file" "$rehearsal_root/supabase/migrations/"
done < "$managed_entries"
managed_versions="$(cut -f1 "$managed_entries")"

# Supabase excludes its internal migration schema from logical dumps. Rebuild
# only the immutable managed history; historical bootstrap files stay untracked.
supabase migration repair \
  --workdir "$rehearsal_root" \
  --local \
  --status applied \
  --yes \
  $managed_versions \
  >/dev/null

repaired_migrations="$(psql --dbname "$restore_url" --tuples-only --no-align --set ON_ERROR_STOP=1 --command "
select count(*) from supabase_migrations.schema_migrations;")"
[ "$repaired_migrations" -eq "$managed_count" ] || fail "local migration history does not match the production manifest"

BACKUP_ARCHIVE="$archive" \
AGE_IDENTITY_FILE="$identity_file" \
RESTORE_DATABASE_URL="$restore_url" \
RESTORE_REPORT_PATH="$report_path" \
  bash "$(dirname "$0")/restore-postgres.sh"

printf '%s\n' "$report_path"
