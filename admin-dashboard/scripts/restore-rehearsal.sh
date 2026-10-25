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

restore_target_marker="$(python3 -c 'import uuid; print(uuid.uuid4())')"
psql --dbname "$restore_url" --set ON_ERROR_STOP=1 --command "
create schema if not exists younew_restore_guard;
create table if not exists younew_restore_guard.target_marker (
  singleton boolean primary key default true check (singleton),
  marker text not null
);
truncate table younew_restore_guard.target_marker;
insert into younew_restore_guard.target_marker (singleton, marker)
values (true, '$restore_target_marker');" >/dev/null

migration_entries="$rehearsal_root/full-migration-chain.tsv"
jq -r '(.managedMigrations + .pendingMigrations)[]? | [.version, (.localVersion // .version), .name] | @tsv' \
  "$migration_manifest" > "$migration_entries"
migration_count="$(awk 'NF { count += 1 } END { print count + 0 }' "$migration_entries")"
[ "$migration_count" -gt 0 ] || fail "production migration manifest has no versions"
mkdir -p "$rehearsal_root/supabase/migrations"
while IFS=$'\t' read -r migration_version local_version migration_name; do
  case "$migration_version" in
    20????????????) ;;
    *) fail "invalid migration version: $migration_version" ;;
  esac
  case "$local_version" in
    20????????????) ;;
    *) fail "invalid local migration version: $local_version" ;;
  esac
  case "$migration_name" in
    ''|*[!a-z0-9_]*) fail "invalid migration name: $migration_name" ;;
  esac
  migration_file="$migration_source_dir/${local_version}_${migration_name}.sql"
  [ -f "$migration_file" ] || fail "migration file is missing: $migration_file"
  cp "$migration_file" "$rehearsal_root/supabase/migrations/${migration_version}_${migration_name}.sql"
done < "$migration_entries"
migration_versions="$(cut -f1 "$migration_entries")"

# Supabase excludes its internal migration schema from logical dumps. Rebuild
# the exact post-migration manifest history; historical bootstrap files stay intentionally untracked.
# This drill is therefore a post-migration backup and
# restore rehearsal, never evidence of a production rollback/downgrade.
supabase migration repair \
  --workdir "$rehearsal_root" \
  --local \
  --status applied \
  --yes \
  $migration_versions \
  >/dev/null

repaired_migrations="$(psql --dbname "$restore_url" --tuples-only --no-align --set ON_ERROR_STOP=1 --command "
select count(*) from supabase_migrations.schema_migrations;")"
[ "$repaired_migrations" -eq "$migration_count" ] || fail "local migration history does not match the full migration manifest"

BACKUP_ARCHIVE="$archive" \
AGE_IDENTITY_FILE="$identity_file" \
RESTORE_DATABASE_URL="$restore_url" \
RESTORE_TARGET_MARKER="$restore_target_marker" \
RESTORE_REPORT_PATH="$report_path" \
RESTORE_EXPECTED_MIGRATION_COUNT="$migration_count" \
  bash "$(dirname "$0")/restore-postgres.sh"

inventory_sql="${RESTORE_INVENTORY_SQL:-}"
inventory_path="${RESTORE_INVENTORY_PATH:-}"
if [ -n "$inventory_sql" ] || [ -n "$inventory_path" ]; then
  [ -n "$inventory_sql" ] || fail "RESTORE_INVENTORY_SQL is required when RESTORE_INVENTORY_PATH is set"
  [ -f "$inventory_sql" ] || fail "restore inventory SQL does not exist: $inventory_sql"
  [ -n "$inventory_path" ] || fail "RESTORE_INVENTORY_PATH is required when RESTORE_INVENTORY_SQL is set"
  inventory_dir="$(dirname "$inventory_path")"
  mkdir -p "$inventory_dir"
  inventory_partial="$inventory_path.partial.$$"
  psql \
    --dbname "$restore_url" \
    --tuples-only \
    --no-align \
    --set ON_ERROR_STOP=1 \
    --set expected_migration_count="$migration_count" \
    --file "$inventory_sql" \
    > "$inventory_partial"
  chmod 600 "$inventory_partial"
  mv "$inventory_partial" "$inventory_path"
fi

schema_inventory_sql="${RESTORE_SCHEMA_INVENTORY_SQL:-}"
schema_inventory_path="${RESTORE_SCHEMA_INVENTORY_PATH:-}"
if [ -n "$schema_inventory_sql" ] || [ -n "$schema_inventory_path" ]; then
  [ -n "$schema_inventory_sql" ] || fail "RESTORE_SCHEMA_INVENTORY_SQL is required when RESTORE_SCHEMA_INVENTORY_PATH is set"
  [ -f "$schema_inventory_sql" ] || fail "restore schema inventory SQL does not exist: $schema_inventory_sql"
  [ -n "$schema_inventory_path" ] || fail "RESTORE_SCHEMA_INVENTORY_PATH is required when RESTORE_SCHEMA_INVENTORY_SQL is set"
  schema_inventory_dir="$(dirname "$schema_inventory_path")"
  mkdir -p "$schema_inventory_dir"
  schema_inventory_partial="$schema_inventory_path.partial.$$"
  psql \
    --dbname "$restore_url" \
    --tuples-only \
    --no-align \
    --field-separator '|' \
    --set ON_ERROR_STOP=1 \
    --set expected_migration_count="$migration_count" \
    --file "$schema_inventory_sql" \
    > "$schema_inventory_partial"
  chmod 600 "$schema_inventory_partial"
  mv "$schema_inventory_partial" "$schema_inventory_path"
fi

printf '%s\n' "$report_path"
