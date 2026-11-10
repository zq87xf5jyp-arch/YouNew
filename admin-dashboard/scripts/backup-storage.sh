#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "backup-storage: $*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "$1 is required"
}

required_sha="${APPROVED_RELEASE_SHA256:-}"
authorization_sha="${PHASE6_OWNER_AUTHORIZATION_SHA:-}"
[ -n "$required_sha" ] || fail "APPROVED_RELEASE_SHA256 is required"
[ "$authorization_sha" = "$required_sha" ] || fail "PHASE6_OWNER_AUTHORIZATION_SHA must exactly match APPROVED_RELEASE_SHA256"
[ -n "${DATABASE_URL:-}" ] || fail "DATABASE_URL is required"
[ -n "${SUPABASE_ACCESS_TOKEN:-}" ] || fail "SUPABASE_ACCESS_TOKEN is required"
[ -n "${SUPABASE_PROJECT_REF:-}" ] || fail "SUPABASE_PROJECT_REF is required"
[ -n "${AGE_RECIPIENT:-}" ] || fail "AGE_RECIPIENT is required"

for command_name in supabase psql age tar shasum jq; do
  require_command "$command_name"
done

backup_dir="${STORAGE_BACKUP_DIR:-./backups}"
mkdir -p "$backup_dir"
backup_dir="$(cd "$backup_dir" && pwd -P)"
case "$backup_dir" in
  /) fail "refusing to use filesystem root as STORAGE_BACKUP_DIR" ;;
esac

umask 077
timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
archive="$backup_dir/younew-storage-$timestamp.tar.gz.age"
manifest="$archive.manifest.json"
[ ! -e "$archive" ] || fail "refusing to overwrite existing archive: $archive"

work_root="$(mktemp -d "${TMPDIR:-/tmp}/younew-storage-backup.XXXXXX")"
case "$work_root" in
  *younew-storage-backup.*) ;;
  *) fail "unexpected temporary path: $work_root" ;;
esac
partial="$archive.partial.$$"
cleanup() {
  rm -rf "$work_root"
  rm -f "$partial"
}
trap cleanup EXIT HUP INT TERM

payload_root="$work_root/payloads"
mkdir -p "$payload_root"
bucket_rows="$work_root/buckets.tsv"
psql \
  --dbname "$DATABASE_URL" \
  --tuples-only \
  --no-align \
  --field-separator $'\t' \
  --set ON_ERROR_STOP=1 \
  --command "
    select b.id, count(o.id)
    from storage.buckets b
    left join storage.objects o on o.bucket_id = b.id
    group by b.id
    order by b.id;" > "$bucket_rows"

bucket_count=0
expected_objects=0
while IFS=$'\t' read -r bucket_id object_count; do
  [ -n "$bucket_id" ] || continue
  case "$bucket_id" in
    *[!A-Za-z0-9._-]*) fail "unsafe bucket id returned by database" ;;
  esac
  case "$object_count" in
    ''|*[!0-9]*) fail "invalid object count for bucket $bucket_id" ;;
  esac
  bucket_count=$((bucket_count + 1))
  expected_objects=$((expected_objects + object_count))
  mkdir -p "$payload_root/$bucket_id"
  if [ "$object_count" -gt 0 ]; then
    supabase storage cp \
      --recursive \
      --jobs "${STORAGE_BACKUP_JOBS:-4}" \
      --project-ref "$SUPABASE_PROJECT_REF" \
      "ss:///$bucket_id" \
      "$payload_root/$bucket_id"
  fi
done < "$bucket_rows"

(
  if find "$payload_root" -type f -print -quit | grep -q .; then
    cd "$payload_root"
    find . -type f -print0 | LC_ALL=C sort -z | xargs -0 shasum -a 256
  fi
) > "$work_root/STORAGE-SHA256SUMS.txt"
downloaded_objects="$(find "$payload_root" -type f | wc -l | tr -d ' ')"
[ "$downloaded_objects" -eq "$expected_objects" ] || fail "downloaded object count $downloaded_objects does not match database metadata $expected_objects"
downloaded_bytes="$(find "$payload_root" -type f -exec stat -f '%z' {} + | awk '{ total += $1 } END { print total + 0 }')"

COPYFILE_DISABLE=1 tar -czf - -C "$work_root" payloads STORAGE-SHA256SUMS.txt \
  | age --recipient "$AGE_RECIPIENT" --output "$partial"
chmod 600 "$partial"
mv "$partial" "$archive"
archive_sha256="$(shasum -a 256 "$archive" | awk '{print $1}')"
archive_bytes="$(wc -c < "$archive" | tr -d ' ')"

jq -n \
  --arg created_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg archive "$(basename "$archive")" \
  --arg archive_sha256 "$archive_sha256" \
  --arg release_sha256 "$required_sha" \
  --arg project_ref_sha256 "$(printf '%s' "$SUPABASE_PROJECT_REF" | shasum -a 256 | awk '{print $1}')" \
  --argjson archive_bytes "$archive_bytes" \
  --argjson bucket_count "$bucket_count" \
  --argjson object_count "$downloaded_objects" \
  --argjson payload_bytes "$downloaded_bytes" \
  '{
    schema_version: 1,
    created_at_utc: $created_at,
    archive: $archive,
    archive_sha256: $archive_sha256,
    archive_bytes: $archive_bytes,
    approved_release_sha256: $release_sha256,
    project_ref_sha256: $project_ref_sha256,
    bucket_count: $bucket_count,
    object_count: $object_count,
    payload_bytes: $payload_bytes,
    encrypted: true,
    object_names_in_external_manifest: false,
    remote_mutation_performed: false,
    restore_status: "not_yet_verified"
  }' > "$manifest"
chmod 600 "$manifest"

trap - EXIT HUP INT TERM
rm -rf "$work_root"
printf '%s\n' "$archive"
printf '%s\n' "$manifest"
