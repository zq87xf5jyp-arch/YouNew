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
require_command psql
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
managed_boundaries="$archive.managed-boundaries.json"
managed_boundaries_partial="$managed_boundaries.partial.$$"

cleanup() {
  rm -f "$partial"
  rm -f "$managed_boundaries_partial"
}
trap cleanup EXIT HUP INT TERM

# Logical dumps intentionally rely on the target Supabase installation for
# managed schemas. Capture the application-owned configuration inside those
# schemas and bind it to the encrypted archive through the manifest digest.
psql \
  --dbname "$DATABASE_URL" \
  --tuples-only \
  --no-align \
  --set ON_ERROR_STOP=1 \
  --command "
    select jsonb_build_object(
      'metadata', jsonb_build_object(
        'buckets', coalesce((
          select jsonb_agg(jsonb_build_object(
            'id', id, 'name', name, 'public', public,
            'file_size_limit', file_size_limit,
            'allowed_mime_types', allowed_mime_types
          ) order by id)
          from storage.buckets
        ), '[]'::jsonb),
        'storage_policies', coalesce((
          select jsonb_agg(jsonb_build_object(
            'name', policyname, 'permissive', permissive, 'roles', roles,
            'command', cmd, 'using', qual, 'withCheck', with_check
          ) order by policyname)
          from pg_policies
          where schemaname = 'storage' and tablename = 'objects'
        ), '[]'::jsonb),
        'auth_user_triggers', coalesce((
          select jsonb_agg(jsonb_build_object(
            'name', tgname, 'definition', pg_get_triggerdef(oid)
          ) order by tgname)
          from pg_trigger
          where tgrelid = 'auth.users'::regclass and not tgisinternal
        ), '[]'::jsonb),
        'cron_jobs', coalesce((
          select jsonb_agg(jsonb_build_object(
            'name', jobname, 'schedule', schedule, 'command', command
          ) order by jobname)
          from cron.job
          where jobname like 'younew-%'
        ), '[]'::jsonb)
      )
    );" > "$managed_boundaries_partial"
# Shell environment variables cannot preserve trailing newlines. Store the
# companion in the exact no-trailing-newline representation used by restore.
managed_boundaries_json="$(cat "$managed_boundaries_partial")"
printf '%s' "$managed_boundaries_json" > "$managed_boundaries_partial"
chmod 600 "$managed_boundaries_partial"
mv "$managed_boundaries_partial" "$managed_boundaries"
managed_boundaries_sha256="$(shasum -a 256 "$managed_boundaries" | awk '{print $1}')"

dump_section() {
  section="$1"
  shift
  printf '\n-- YOUNEW_BACKUP_SECTION:%s\n' "$section"
  if [ "${SUPABASE_TEMPORARY_ACCESS:-false}" = "true" ]; then
    # Execute the provider-generated dump locally so JIT options reach libpq.
    # Preserve its --role postgres: the temporary login is allowed to SET ROLE,
    # but has no direct SELECT on application tables. Do not bypass that role
    # boundary or silently produce a partial archive.
    {
      printf '%s\n' 'export PGOPTIONS="-c jit=true -c default_transaction_read_only=on -c statement_timeout=300000"' 'export PGSSLMODE="require"'
      supabase db dump \
        --db-url "$DATABASE_URL" \
        --file /dev/stdout \
        --dry-run \
        "$@"
    } | bash
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
  "managed_boundaries": "$(basename "$managed_boundaries")",
  "managed_boundaries_sha256": "$managed_boundaries_sha256",
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

find "$backup_dir" -type f \( -name 'younew-*.dump.age' -o -name 'younew-*.dump.age.manifest.json' -o -name 'younew-*.dump.age.managed-boundaries.json' \) \
  -mtime +"$retention_days" -delete

trap - EXIT HUP INT TERM
printf '%s\n' "$archive"
printf '%s\n' "$manifest"
