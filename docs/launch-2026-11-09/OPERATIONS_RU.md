# Эксплуатация на Hostinger

Static/PHP younew.nl, managed Node admin.younew.nl, MariaDB u246392949_younp1, private files/legacy archive и SQLite outbox работают без компьютера владельца. GitHub сохраняет историю.

## Задания

- BUSINESS: */5 * * * * /bin/bash /home/u246392949/domains/younew.nl/younew-private/launch-production/cron-business-production.sh. 49 реальных циклов, 4 доставки однократно. PRODUCTION_BUSINESS_PAUSED ставит паузу; PRODUCTION_BUSINESS_PRELAUNCH_PAUSE.saved не останавливает worker.
- Health: */15 * * * * /usr/bin/python3 /home/u246392949/domains/younew.nl/younew-private/launch-production/health-check.py /home/u246392949/domains/younew.nl/younew-private/launch-production/health-config.json. Проверяет public/login, private API/no-store, pending outbox старше 20 минут, cron без завершения более 12 минут. QA OK/DEGRADED и production ручная проверка OK; расписание сохранено.
- Analytics: прежний maintenance */5 сохранён. QA business/catalog приостановлены приватными markers; QA данные сохранены.

Приватные логи: launch-production/logs/business-cron.jsonl, logs/health/health-latest.json и health-transitions.jsonl. Последний пополняется при изменении статуса. Email/SMS не настроены. Читать через File Manager/terminal. При полном отказе Hostinger независимого внешнего оповещения нет.

## Ресурсы и защита

Ограничены Node thread pools и параллелизм тестов; QA cron на паузе. Снимок после запуска: 13 потоков, два Next server по 5, при лимите 120. Панель сохраняет предупреждение о прежних пиках — это не доказательство текущего превышения. Stop all processes не использовался: он затронул бы другие сайты.

Env/backup/source exports вне web-root, credentials 0600. Admin/session/API private/no-store. Assets gzip/cache, HTML revalidate; HTTPS/HSTS и уже включённый public CDN сохранены. SMTP/почтовый DNS/Studio не менялись.

Следить за доступностью, pending age, cron completions и daily backups. При инциденте [откат](ROLLBACK_RU.md); старой копией новые заявки не стирать. 71 draft не публиковать без одобрения.

Scheduled monitor evidence: [health-scheduled.json](production-evidence-20261110/health-scheduled.json), 2026-11-10 19:45:03 UTC, OK; produced by the actual Hostinger cron.
