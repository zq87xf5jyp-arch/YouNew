#!/bin/sh
set -eu
umask 077
STATE=/home/u246392949/domains/younew.nl/younew-private/launch-production
[ ! -f "$STATE/PRODUCTION_BUSINESS_PAUSED" ] || exit 0
[ -f "$STATE/production-active-release.json" ] || exit 0
PATH=/usr/bin:/bin
export PATH
exec >> "$STATE/logs/business-cron.jsonl" 2>&1
printf '{"event":"cron_start","at":"%s"}\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
/usr/bin/php /home/u246392949/domains/younew.nl/younew-private/forms-v1/sync.php
printf '{"event":"cron_end","at":"%s"}\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
