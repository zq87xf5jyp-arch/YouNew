#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "storage-inventory: $*" >&2
  exit 1
}

[ -n "${DATABASE_URL:-}" ] || fail "DATABASE_URL is required"
command -v psql >/dev/null 2>&1 || fail "psql is required"
command -v jq >/dev/null 2>&1 || fail "jq is required"
command -v shasum >/dev/null 2>&1 || fail "shasum is required"

output_path="${STORAGE_INVENTORY_PATH:-./storage-inventory.json}"
output_dir="$(dirname "$output_path")"
mkdir -p "$output_dir"
output_dir="$(cd "$output_dir" && pwd -P)"
case "$output_dir" in
  /) fail "refusing to write inventory at filesystem root" ;;
esac
output_path="$output_dir/$(basename "$output_path")"

umask 077
partial="$output_path.partial.$$"
rows="$output_path.rows.$$"
trap 'rm -f "$partial" "$rows"' EXIT HUP INT TERM

# Object names are deliberately excluded: names can contain personal or
# customer-provided data. This inventories metadata only and never claims that
# Storage payload bytes are present in the PostgreSQL backup.
psql \
  --dbname "$DATABASE_URL" \
  --tuples-only \
  --no-align \
  --field-separator $'\t' \
  --set ON_ERROR_STOP=1 \
  --command "
    select
      b.id,
      b.name,
      b.public,
      b.file_size_limit,
      coalesce(array_to_json(b.allowed_mime_types)::text, 'null'),
      count(o.id),
      coalesce(sum(coalesce((o.metadata ->> 'size')::bigint, 0)), 0),
      max(o.updated_at)
    from storage.buckets b
    left join storage.objects o on o.bucket_id = b.id
    group by b.id, b.name, b.public, b.file_size_limit, b.allowed_mime_types
    order by b.id;" > "$rows"

jq -Rn \
  --arg generated_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  'def bool: . == "t";
   [inputs | split("\t") | {
     id: .[0], name: .[1], public: (.[2] | bool),
     file_size_limit: (if .[3] == "" then null else (.[3] | tonumber) end),
     allowed_mime_types: (.[4] | fromjson),
     object_count: (.[5] | tonumber), total_metadata_bytes: (.[6] | tonumber),
     latest_object_update: (if .[7] == "" then null else .[7] end)
   }] as $buckets |
   {
     schema_version: 1,
     generated_at_utc: $generated_at,
     source: "DATABASE_URL (redacted)",
     privacy: "object names and owner identifiers intentionally excluded",
     payload_backup_status: "not_performed_metadata_only",
     payload_warning: "PostgreSQL logical backups contain Storage metadata, not object payload bytes.",
     bucket_count: ($buckets | length),
     object_count: ($buckets | map(.object_count) | add // 0),
     total_metadata_bytes: ($buckets | map(.total_metadata_bytes) | add // 0),
     buckets: $buckets
   }' < "$rows" > "$partial"

chmod 600 "$partial"
mv "$partial" "$output_path"
digest="$(shasum -a 256 "$output_path" | awk '{print $1}')"
trap - EXIT HUP INT TERM
rm -f "$rows"
printf '%s\n' "$output_path"
printf '%s\n' "$digest"
