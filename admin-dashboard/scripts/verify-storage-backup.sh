#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "verify-storage-backup: $*" >&2
  exit 1
}

archive="${STORAGE_BACKUP_ARCHIVE:-${1:-}}"
identity="${AGE_IDENTITY_FILE:-${2:-}}"
manifest="${STORAGE_BACKUP_MANIFEST:-${archive}.manifest.json}"
report="${STORAGE_RESTORE_REPORT_PATH:-./storage-restore-verification.json}"

[ -n "$archive" ] && [ -f "$archive" ] || fail "STORAGE_BACKUP_ARCHIVE is required"
[ -n "$identity" ] && [ -f "$identity" ] || fail "AGE_IDENTITY_FILE is required"
[ -f "$manifest" ] || fail "storage backup manifest is missing"
for command_name in age tar shasum jq; do
  command -v "$command_name" >/dev/null 2>&1 || fail "$command_name is required"
done

expected_archive_sha="$(jq -er '.archive_sha256' "$manifest")"
actual_archive_sha="$(shasum -a 256 "$archive" | awk '{print $1}')"
[ "$actual_archive_sha" = "$expected_archive_sha" ] || fail "archive SHA-256 does not match its manifest"

umask 077
verify_root="$(mktemp -d "${TMPDIR:-/tmp}/younew-storage-restore.XXXXXX")"
case "$verify_root" in
  *younew-storage-restore.*) ;;
  *) fail "unexpected verification path: $verify_root" ;;
esac
cleanup() { rm -rf "$verify_root"; }
trap cleanup EXIT HUP INT TERM

listing="$verify_root/archive-list.txt"
age --decrypt --identity "$identity" "$archive" | tar -tzf - > "$listing"
if grep -Eq '(^/|(^|/)\.\.(/|$))' "$listing"; then
  fail "archive contains an unsafe path"
fi
age --decrypt --identity "$identity" "$archive" | tar -xzf - -C "$verify_root"
[ -d "$verify_root/payloads" ] || fail "archive has no payloads directory"
[ -f "$verify_root/STORAGE-SHA256SUMS.txt" ] || fail "archive has no checksum manifest"
(
  cd "$verify_root/payloads"
  if [ -s "$verify_root/STORAGE-SHA256SUMS.txt" ]; then
    shasum -a 256 -c "$verify_root/STORAGE-SHA256SUMS.txt" >/dev/null
  fi
)

object_count="$(find "$verify_root/payloads" -type f | wc -l | tr -d ' ')"
payload_bytes="$(find "$verify_root/payloads" -type f -exec stat -f '%z' {} + | awk '{ total += $1 } END { print total + 0 }')"
expected_objects="$(jq -er '.object_count' "$manifest")"
expected_bytes="$(jq -er '.payload_bytes' "$manifest")"
[ "$object_count" -eq "$expected_objects" ] || fail "restored object count does not match manifest"
[ "$payload_bytes" -eq "$expected_bytes" ] || fail "restored payload bytes do not match manifest"

jq -n \
  --arg checked_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg archive_sha256 "$actual_archive_sha" \
  --argjson object_count "$object_count" \
  --argjson payload_bytes "$payload_bytes" \
  '{
    schema_version: 1,
    checked_at_utc: $checked_at,
    status: "passed",
    archive_sha256: $archive_sha256,
    object_count: $object_count,
    payload_bytes: $payload_bytes,
    checksum_verification: "passed",
    unsafe_path_check: "passed",
    remote_restore_performed: false
  }' > "$report"
chmod 600 "$report"
trap - EXIT HUP INT TERM
rm -rf "$verify_root"
printf '%s\n' "$report"
