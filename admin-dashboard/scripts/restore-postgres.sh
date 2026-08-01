#!/bin/sh
set -eu

fail() {
  echo "restore-postgres: $*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "$1 is required"
}

archive="${BACKUP_ARCHIVE:-${1:-}}"
identity_file="${AGE_IDENTITY_FILE:-${2:-}}"
restore_url="${RESTORE_DATABASE_URL:-${3:-}}"
report_path="${RESTORE_REPORT_PATH:-./restore-verification.json}"

[ -n "$archive" ] || fail "BACKUP_ARCHIVE or argument 1 is required"
[ -f "$archive" ] || fail "backup archive does not exist: $archive"
[ -n "$identity_file" ] || fail "AGE_IDENTITY_FILE or argument 2 is required"
[ -f "$identity_file" ] || fail "age identity file does not exist: $identity_file"
[ -n "$restore_url" ] || fail "RESTORE_DATABASE_URL or argument 3 is required"

case "$restore_url" in
  *"@localhost"*|*"@127.0.0.1"*|*"host=/"*|*"host=%2F"*) ;;
  *) fail "RESTORE_DATABASE_URL must target an isolated local database" ;;
esac

require_command age
require_command psql
require_command shasum

umask 077
started_epoch="$(date +%s)"
archive_sha256="$(shasum -a 256 "$archive" | awk '{print $1}')"
manifest_path="${BACKUP_MANIFEST:-$archive.manifest.json}"
if [ -f "$manifest_path" ]; then
  expected_sha256="$(sed -n 's/.*"archive_sha256": "\([0-9a-f][0-9a-f]*\)".*/\1/p' "$manifest_path" | head -n 1)"
  [ -n "$expected_sha256" ] || fail "archive_sha256 is missing from manifest: $manifest_path"
  [ "$archive_sha256" = "$expected_sha256" ] || fail "archive checksum does not match manifest"
fi

age --decrypt --identity "$identity_file" "$archive" | \
  psql --dbname "$restore_url" --single-transaction --set ON_ERROR_STOP=1

verification_sql="${RESTORE_VERIFICATION_SQL:-$(CDPATH= cd -- "$(dirname "$0")/.." && pwd -P)/supabase/verification/verify_after_migration.sql}"
if [ -f "$verification_sql" ]; then
  psql --dbname "$restore_url" --set ON_ERROR_STOP=1 --file "$verification_sql"
fi

metrics="$(psql --dbname "$restore_url" --tuples-only --no-align --field-separator '|' --set ON_ERROR_STOP=1 --command "
select
  current_setting('server_version'),
  pg_size_pretty(pg_database_size(current_database())),
  (select count(*) from pg_tables where schemaname = 'public'),
  (select count(*) from pg_policies where schemaname = 'public'),
  (select count(*) from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname in ('public','private')),
  (select count(*) from auth.users),
  (select count(*) from storage.buckets),
  (select count(*) from storage.objects),
  (select count(*) from supabase_migrations.schema_migrations);")"

old_ifs="$IFS"
IFS='|'
set -- $metrics
IFS="$old_ifs"
[ "$#" -eq 9 ] || fail "verification query returned an unexpected field count"
postgres_version="$1"
database_size="$2"
public_tables="$3"
public_policies="$4"
database_functions="$5"
auth_users="$6"
storage_buckets="$7"
storage_objects="$8"
migrations="$9"

row_counts_json="$(psql --dbname "$restore_url" --tuples-only --no-align --set ON_ERROR_STOP=1 --command "
select json_build_object(
  'profiles', (select count(*) from public.profiles),
  'business_inquiries', (select count(*) from public.business_inquiries),
  'feedback', (select count(*) from public.feedback),
  'app_sessions', (select count(*) from public.app_sessions),
  'app_events', (select count(*) from public.app_events),
  'audit_logs', (select count(*) from public.audit_logs)
);")"

finished_epoch="$(date +%s)"
rto_seconds="$((finished_epoch - started_epoch))"
report_dir="$(dirname "$report_path")"
mkdir -p "$report_dir"

cat > "$report_path" <<EOF
{
  "verification_version": "1.0",
  "verified_at_utc": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "status": "pass",
  "archive": "$(basename "$archive")",
  "archive_sha256": "$archive_sha256",
  "target": "isolated-local-database",
  "postgres_version": "$postgres_version",
  "database_size": "$database_size",
  "public_tables": $public_tables,
  "public_policies": $public_policies,
  "database_functions": $database_functions,
  "auth_users": $auth_users,
  "storage_buckets": $storage_buckets,
  "storage_objects": $storage_objects,
  "migration_records": $migrations,
  "control_row_counts": $row_counts_json,
  "rto_seconds": $rto_seconds,
  "rpo_hours": null,
  "rpo_status": "requires source-backup timestamp review",
  "edge_functions_status": "verify separately from source manifest",
  "storage_object_payload_status": "not included in database dump"
}
EOF
chmod 600 "$report_path"
printf '%s\n' "$report_path"
