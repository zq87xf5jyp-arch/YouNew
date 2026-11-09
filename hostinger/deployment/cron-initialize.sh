#!/bin/sh
set -eu
umask 077
STATE=/home/u246392949/domains/qa-catalog.younew.nl/younew-private/hp1
SOURCE=/home/u246392949/domains/qa-catalog.younew.nl/younew-private/launch-source
APP="$SOURCE/hostinger/runtime/backend/source/admin-dashboard"
ENVFILE=/home/u246392949/domains/qa-admin.younew.nl/younew-private/launch.env
NODE=/opt/alt/alt-nodejs24/root/bin/node
PATH=/opt/alt/alt-nodejs24/root/bin:/usr/bin:/bin
export PATH
cd "$APP"
exec >> "$STATE/logs/initialize.jsonl" 2>&1
[ ! -f "$STATE/initialize.done" ] || exit 0
[ ! -f "$STATE/initialize.failed" ] || exit 1
mkdir "$STATE/initialize.lock" || exit 75
trap 'rmdir "$STATE/initialize.lock"' EXIT
if "$NODE" --env-file="$ENVFILE" "$SOURCE/hostinger/deployment/host-preflight.mjs" --approved-probe && /usr/bin/php "$STATE/deployment/php-preflight.php" && "$NODE" --env-file="$ENVFILE" "$SOURCE/hostinger/deployment/init-qa.mjs" --apply; then
 date -u +%Y-%m-%dT%H:%M:%SZ > "$STATE/initialize.done"
else
 date -u +%Y-%m-%dT%H:%M:%SZ > "$STATE/initialize.failed"
 exit 1
fi
