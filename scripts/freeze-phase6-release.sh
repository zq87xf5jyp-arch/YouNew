#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "freeze-phase6-release: $*" >&2
  exit 1
}

root="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd -P)"
public_root="$root/admin-dashboard/public-site"
admin_root="$root/admin-dashboard"
output_root="${PHASE6_RELEASE_DIR:-$root/release-artifacts/final-release-phase6-1-2026-10-24}"

for command_name in git jq shasum tar pnpm python3; do
  command -v "$command_name" >/dev/null 2>&1 || fail "$command_name is required"
done
[ -d "$public_root/out" ] || fail "public out/ is missing"
[ -f "$public_root/out/sitemap.xml" ] || fail "public sitemap is missing"
[ -f "$admin_root/.next/BUILD_ID" ] || fail "Admin .next/BUILD_ID is missing"

(
  cd "$admin_root"
  pnpm audit >/dev/null
)
(
  cd "$public_root"
  pnpm audit >/dev/null
)
python3 "$root/scripts/audit-phase6-indexable-value.py"

mkdir -p "$output_root"
output_root="$(cd "$output_root" && pwd -P)"
case "$output_root" in
  /|"$root") fail "unsafe release output path: $output_root" ;;
esac

umask 077
archive="$output_root/younew-public-phase6-1-2026-10-24.tar.gz"
sums="$output_root/SOURCE-SHA256SUMS.txt"
manifest="$output_root/RELEASE-MANIFEST.json"

(
  cd "$root"
  find \
    admin-dashboard/src \
    admin-dashboard/tests \
    admin-dashboard/scripts \
    admin-dashboard/supabase/functions \
    admin-dashboard/supabase/migrations \
    admin-dashboard/package.json \
    admin-dashboard/pnpm-lock.yaml \
    admin-dashboard/pnpm-workspace.yaml \
    admin-dashboard/next.config.ts \
    admin-dashboard/public-site/src \
    admin-dashboard/public-site/scripts \
    admin-dashboard/public-site/tests \
    admin-dashboard/public-site/worker \
    admin-dashboard/public-site/package.json \
    admin-dashboard/public-site/pnpm-lock.yaml \
    admin-dashboard/public-site/pnpm-workspace.yaml \
    admin-dashboard/public-site/next.config.ts \
    DataProject/overlays/WP-06/amsterdam-v0.1.9.json \
    DataProject/releases/amsterdam-v0.1.9-acceptance-packet.json \
    DataProject/releases/amsterdam-v0.1.9-acceptance-packet.md \
    DataProject/releases/releases.json \
    DataProject/research/phase5-station-confirmations.json \
    DataProject/research/phase6-1-station-reverification.json \
    DataProject/research/phase5-contact-channel-review.json \
    DataProject/research/phase5-contact-channel-review.csv \
    DataProject/research/phase5-contact-channel-review.md \
    DataProject/quality/phase5-catalog-restoration.json \
    DataProject/quality/phase5-stale-route-impact.json \
    DataProject/quality/phase6-indexable-value-audit.json \
    DataProject/quality/phase6-indexable-value-audit.md \
    DataProject/quality/phase6-sources-receipt.md \
    DataProject/quality/phase6-1-public-record-confirmations.json \
    docs \
    scripts \
    -type f ! -name '.DS_Store' ! -path '*/__pycache__/*' -print0 \
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
confirmed_public_records="$(jq '[.entities[] | select(.indexable == true)] | length' "$public_root/src/generated/public-content.json")"
freshness_exclusions="$(jq '.count' "$public_root/src/generated/public-freshness-exclusions.json")"
admin_build_id="$(tr -d '\n' < "$admin_root/.next/BUILD_ID")"
content_pass="$(jq '.summary.pass' "$root/DataProject/quality/phase6-indexable-value-audit.json")"
content_review="$(jq '.summary.review' "$root/DataProject/quality/phase6-indexable-value-audit.json")"
content_fail="$(jq '.summary.fail' "$root/DataProject/quality/phase6-indexable-value-audit.json")"
all_useful="$(jq '.summary.all_pages_independently_useful' "$root/DataProject/quality/phase6-indexable-value-audit.json")"
next_version="$(jq -r '.dependencies.next' "$public_root/package.json")"
zod_version="$(jq -r '.dependencies.zod' "$admin_root/package.json")"

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
  --arg next_version "$next_version" \
  --arg zod_version "$zod_version" \
  --argjson public_files "$public_files" \
  --argjson html_files "$html_files" \
  --argjson sitemap_urls "$sitemap_urls" \
  --argjson public_records "$public_records" \
  --argjson confirmed_public_records "$confirmed_public_records" \
  --argjson freshness_exclusions "$freshness_exclusions" \
  --argjson content_pass "$content_pass" \
  --argjson content_review "$content_review" \
  --argjson content_fail "$content_fail" \
  --argjson all_useful "$all_useful" \
  '{
    schema_version: 1,
    release_name: "YouNew Phase 6.1 final local release candidate",
    created_at_utc: $created_at,
    production_authorized: false,
    production_deployed: false,
    launch_gate_passed: $all_useful,
    supersedes_candidate_sha256: "3c7bfac9a0037e211a3c06747d135a1a41d395f8892796d1fd4837401929b5ca",
    supersession_reason: "Phase 6.1 closes the seven indexable-content reviews, adds source-bound fail-closed legacy dispositions and refreshes the complete local preflight evidence.",
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
      confirmed_indexable_public_records: $confirmed_public_records,
      freshness_exclusions: $freshness_exclusions
    },
    dependency_gate: {
      audit: "passed_no_known_vulnerabilities",
      next: $next_version,
      zod: $zod_version,
      sharp_override: "0.35.5",
      source_map_js_override: "1.2.2"
    },
    indexable_value_gate: {
      pass: $content_pass,
      review: $content_review,
      fail: $content_fail,
      all_pages_independently_useful: $all_useful
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
      state: "qa_not_accepted_not_production_authorized",
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
