#!/usr/bin/env bash
set -euo pipefail

project_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$project_root"

bash scripts/build.sh

payload_root="$project_root/dist/client/__site_payloads"
mkdir -p "$payload_root"

html_count=0
while IFS= read -r -d '' html_file; do
  relative_path=${html_file#"$project_root/dist/client/"}
  payload_file="$payload_root/$relative_path.payload"
  mkdir -p "$(dirname "$payload_file")"
  mv "$html_file" "$payload_file"
  html_count=$((html_count + 1))
done < <(find "$project_root/dist/client" -type f -name '*.html' -not -path "$payload_root/*" -print0)

rm -f "$project_root/dist/client/.htaccess" "$project_root/dist/client/_headers"

if [[ "$html_count" -lt 1 ]]; then
  echo "Sites packaging failed: no HTML payloads were prepared." >&2
  exit 1
fi

if find "$project_root/dist/client" -type f -name '*.html' -not -path "$payload_root/*" | grep -q .; then
  echo "Sites packaging failed: directly served HTML remains." >&2
  exit 1
fi

echo "Prepared $html_count worker-first HTML payloads for Sites."
