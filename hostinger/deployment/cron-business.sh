#!/bin/sh
if [ -f /home/u246392949/domains/qa-catalog.younew.nl/younew-private/hp1/QA_PAUSED ]; then exit 0; fi
set -eu
umask 077
PATH=/usr/bin:/bin
export PATH
cd /home/u246392949/domains/qa-catalog.younew.nl/younew-private/hp1
exec >> logs/business-cron.jsonl 2>&1
printf '{"event":"cron_start","at":"%s"}\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
/usr/bin/php deployment/php-preflight.php
/usr/bin/php kit/backend/php/private/forms/sync.php
printf '{"event":"cron_end","at":"%s"}\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
