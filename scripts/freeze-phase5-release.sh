#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "freeze-phase5-release: $*" >&2
  exit 1
}

root="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd -P)"
public_root="$root/admin-dashboard/public-site"
admin_root="$root/admin-dashboard"
output_root="${PHASE5_RELEASE_DIR:-$root/release-artifacts/controlled-launch-2026-10-24}"

command -v git >/dev/null 2>&1 || fail "git is required"
command -v jq >/dev/null 2>&1 || fail "jq is required"
command -v shasum >/dev/null 2>&1 || fail "shasum is required"
command -v tar >/dev/null 2>&1 || fail "tar is required"
[ -d "$public_root/out" ] || fail "public out/ is missing; run the public predeploy check first"
[ -f "$public_root/out/sitemap.xml" ] || fail "public sitemap is missing"
[ -f "$admin_root/.next/BUILD_ID" ] || fail "Admin .next/BUILD_ID is missing; run the Admin build first"

mkdir -p "$output_root"
output_root="$(cd "$output_root" && pwd -P)"
case "$output_root" in
  /|"$root") fail "unsafe release output path: $output_root" ;;
esac

umask 077
archive="$output_root/younew-public-phase5-2026-10-24.tar.gz"
sums="$output_root/SOURCE-SHA256SUMS.txt"
manifest="$output_root/RELEASE-MANIFEST.json"

(
  cd "$root"
  find \
    admin-dashboard/src \
    admin-dashboard/tests \
    admin-dashboard/scripts \
    admin-dashboard/package.json \
    admin-dashboard/supabase/functions \
    admin-dashboard/supabase/migrations \
    admin-dashboard/public-site/src \
    admin-dashboard/public-site/scripts \
    admin-dashboard/public-site/tests \
    DataProject/overlays/WP-06/amsterdam-v0.1.9.json \
    DataProject/research/phase5-station-confirmations.json \
    DataProject/research/phase5-contact-channel-review.json \
    DataProject/research/phase5-contact-channel-review.csv \
    DataProject/research/phase5-contact-channel-review.md \
    DataProject/quality/phase5-catalog-restoration.json \
    DataProject/quality/phase5-stale-route-impact.json \
    DataProject/quality/phase5-sources-receipt.md \
    docs \
    scripts/audit-phase5-stale-route-impact.py \
    scripts/build-phase5-station-verification.py \
    scripts/build-phase5-contact-channel-review.py \
    scripts/data-health-gate.py \
    scripts/freeze-phase5-release.sh \
    -type f ! -name '.DS_Store' -print0 \
    | LC_ALL=C sort -z \
    | xargs -0 shasum -a 256
) > "$sums"

COPYFILE_DISABLE=1 tar -czf "$archive" -C "$public_root/out" .

archive_sha="$(shasum -a 256 "$archive" | awk '{print $1}')"
sums_sha="$(shasum -a 256 "$sums" | awk '{print $1}')"
git_head="$(git -C "$root" rev-parse HEAD)"
git_branch="$(git -C "$root" branch --show-current)"
if git -C "$root" diff --quiet --ignore-submodules -- && [ -z "$(git -C "$root" ls-files --others --exclude-standard)" ]; then
  dirty=false
else
  dirty=true
fi
public_files="$(find "$public_root/out" -type f | wc -l | tr -d ' ')"
html_files="$(find "$public_root/out" -type f -name '*.html' | wc -l | tr -d ' ')"
sitemap_urls="$(grep -c '<url>' "$public_root/out/sitemap.xml" | tr -d ' ')"
public_records="$(jq '.entities | length' "$public_root/src/generated/public-content.json")"
freshness_exclusions="$(jq '.count' "$public_root/src/generated/public-freshness-exclusions.json")"
admin_build_id="$(tr -d '\n' < "$admin_root/.next/BUILD_ID")"

jq -n \
  --arg created_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg git_head "$git_head" \
  --arg git_branch "$git_branch" \
  --argjson dirty "$dirty" \
  --arg archive "$(basename "$archive")" \
  --arg archive_sha256 "$archive_sha" \
  --arg source_sums "$(basename "$sums")" \
  --arg source_sums_sha256 "$sums_sha" \
  --arg admin_build_id "$admin_build_id" \
  --argjson public_files "$public_files" \
  --argjson html_files "$html_files" \
  --argjson sitemap_urls "$sitemap_urls" \
  --argjson public_records "$public_records" \
  --argjson freshness_exclusions "$freshness_exclusions" \
  '{
    schema_version: 1,
    release_name: "YouNew Phase 5 controlled-launch candidate",
    created_at_utc: $created_at,
    production_authorized: false,
    production_deployed: false,
    repository: {
      head: $git_head,
      branch: $git_branch,
      dirty_worktree: $dirty,
      freeze_method: "artifact and source checksum manifest; no commit created"
    },
    public_artifact: {
      archive: $archive,
      sha256: $archive_sha256,
      files: $public_files,
      html_files: $html_files,
      sitemap_urls: $sitemap_urls,
      governed_public_records: $public_records,
      freshness_exclusions: $freshness_exclusions
    },
    admin_artifact: {
      next_build_id: $admin_build_id,
      deployment_package: "not_created_without_host-specific authorised release step"
    },
    source_manifest: {
      path: $source_sums,
      sha256: $source_sums_sha256
    },
    catalog_candidate: {
      release_id: "amsterdam-v0.1.9",
      state: "qa_not_production_authorized",
      newly_field_confirmed_records: 10,
      production_runtime_unchanged: true
    },
    safety: {
      contains_database_backup: false,
      contains_storage_payloads: false,
      contains_credentials: false,
      production_user_data_touched: false
    }
  }' > "$manifest"
chmod 600 "$archive" "$sums" "$manifest"

printf '%s\n' "$manifest"
printf '%s\n' "$archive_sha"
