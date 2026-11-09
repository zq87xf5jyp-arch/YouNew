#!/bin/sh
set -eu
umask 077
NODE=/opt/alt/alt-nodejs24/root/bin/node
ENVFILE=/home/u246392949/domains/qa-admin.younew.nl/younew-private/launch.env
STATE=/home/u246392949/domains/qa-catalog.younew.nl/younew-private/hp1
BUILDER="$STATE/catalog-builders/current"
PATH=/opt/alt/alt-nodejs24/root/bin:/usr/bin:/bin
export PATH
# Apply the same per-process limits as the managed QA app on shared hosting.
NODE_OPTIONS="--v8-pool-size=1 --max-old-space-size=768"
UV_THREADPOOL_SIZE=1
RAYON_NUM_THREADS=1
YOUNEW_HOSTINGER_QA_BUILD=1
export NODE_OPTIONS UV_THREADPOOL_SIZE RAYON_NUM_THREADS YOUNEW_HOSTINGER_QA_BUILD
test -r "$BUILDER/tools/publish-catalog.mjs"
test -r "$ENVFILE"
cd "$BUILDER"
exec >> "$STATE/logs/catalog-cron.jsonl" 2>&1
printf '{"event":"cron_start","at":"%s"}\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
"$NODE" --env-file="$ENVFILE" tools/publish-catalog.mjs --if-changed
printf '{"event":"cron_end","at":"%s"}\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
