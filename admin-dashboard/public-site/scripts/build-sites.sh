#!/usr/bin/env bash
set -euo pipefail

project_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$project_root"

bash scripts/build.sh

payload_root="$project_root/dist/client/__site_payloads"
mkdir -p "$payload_root"

association_source="$project_root/dist/client/.well-known/apple-app-site-association"
association_payload="$payload_root/.well-known/apple-app-site-association.payload"
if [[ ! -f "$association_source" ]]; then
  echo "Sites packaging failed: Apple app-site association file is missing." >&2
  exit 1
fi
mkdir -p "$(dirname "$association_payload")"
mv "$association_source" "$association_payload"

service_worker_source="$project_root/dist/client/sw.js"
service_worker_payload="$payload_root/sw.js.payload"
if [[ ! -f "$service_worker_source" ]]; then
  echo "Sites packaging failed: service worker is missing." >&2
  exit 1
fi
mv "$service_worker_source" "$service_worker_payload"

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
