#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "phase6-launch-preflight: $*" >&2
  exit 1
}

root="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd -P)"
manifest="${PHASE6_RELEASE_MANIFEST:-${1:-}}"
[ -n "$manifest" ] && [ -f "$manifest" ] || fail "PHASE6_RELEASE_MANIFEST or argument 1 is required"
for command_name in jq shasum pnpm python3; do
  command -v "$command_name" >/dev/null 2>&1 || fail "$command_name is required"
done

archive_name="$(jq -er '.public_artifact.archive' "$manifest")"
archive="$(dirname "$manifest")/$archive_name"
[ -f "$archive" ] || fail "public archive is missing"
expected_sha="$(jq -er '.public_artifact.sha256' "$manifest")"
actual_sha="$(shasum -a 256 "$archive" | awk '{print $1}')"
[ "$actual_sha" = "$expected_sha" ] || fail "public archive SHA-256 mismatch"
[ "$(jq -r '.production_authorized' "$manifest")" = "false" ] || fail "local preflight expects an unauthorised candidate manifest"
[ "$(jq -r '.production_deployed' "$manifest")" = "false" ] || fail "candidate manifest already claims deployment"

source_sums_name="$(jq -er '.source_manifest.path' "$manifest")"
source_sums="$(dirname "$manifest")/$source_sums_name"
[ -f "$source_sums" ] || fail "source checksum manifest is missing"
expected_sums_sha="$(jq -er '.source_manifest.sha256' "$manifest")"
actual_sums_sha="$(shasum -a 256 "$source_sums" | awk '{print $1}')"
[ "$actual_sums_sha" = "$expected_sums_sha" ] || fail "source checksum manifest digest mismatch"
(
  cd "$root"
  shasum -a 256 -c "$source_sums" >/dev/null
) || fail "working sources no longer match the candidate manifest"

(
  cd "$root/admin-dashboard"
  pnpm audit --prod --audit-level high >/dev/null
)
(
  cd "$root/admin-dashboard/public-site"
  pnpm audit --prod --audit-level high >/dev/null
)

public_records="$(jq -er '.entities | length' "$root/admin-dashboard/public-site/src/generated/public-content.json")"
exclusions="$(jq -er '.count' "$root/admin-dashboard/public-site/src/generated/public-freshness-exclusions.json")"
[ "$public_records" -eq 7 ] || fail "unexpected public record count: $public_records"
[ "$exclusions" -eq 170 ] || fail "all 170 freshness exclusions must remain active"

python3 "$root/scripts/audit-phase6-indexable-value.py" --require-all-pass

printf 'PHASE6 LOCAL PREFLIGHT PASS\n'
printf 'artifact_sha256=%s\n' "$actual_sha"
printf 'public_records=%s\n' "$public_records"
printf 'freshness_exclusions=%s\n' "$exclusions"
