#!/bin/sh
# Run after Copy Bundle Resources. Fail closed; never delete or rewrite a product.
set -eu
[ "${CONFIGURATION:-}" = Release ] || exit 0
bundle="${TARGET_BUILD_DIR:?}/${UNLOCALIZED_RESOURCES_FOLDER_PATH:?}"
[ -d "$bundle" ] || { echo 'error: Release resources directory missing'; exit 1; }
blocked=$(/usr/bin/find "$bundle" -type f \( -name 'younew-approved-local-test.json' -o -name 'approved-travel-*.webp' \) -print)
[ -z "$blocked" ] || { echo "error: Local-test content in Release product: $blocked"; exit 1; }
source_file="${SRCROOT:?}/YouNew/Resources/Data/younew-approved-places.json"
production_files=$(/usr/bin/find "$bundle" -type f -name 'younew-approved-places.json' -print)
[ -n "$production_files" ] || { echo 'error: Production content missing from Release product'; exit 1; }
printf '%s\n' "$production_files" | while IFS= read -r file; do
    /usr/bin/cmp -s "$source_file" "$file" || { echo 'error: Release production artifact differs from governed source'; exit 1; }
done
echo 'Release content guard passed: local-test resources absent; production artifact intact.'
