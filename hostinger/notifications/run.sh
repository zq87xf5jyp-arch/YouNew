#!/bin/sh
set -eu
umask 077
PATH=/usr/bin:/bin
export PATH
STATE=/home/u246392949/domains/younew.nl/younew-private/notifications
exec >> "$STATE/cron.jsonl" 2>&1
printf '{"event":"notification_cron","at":"%s"}\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
/usr/bin/php "$STATE/worker.php" "$STATE/config.json" run
