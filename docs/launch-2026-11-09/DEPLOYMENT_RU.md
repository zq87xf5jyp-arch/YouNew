# Фактически выполненное развёртывание

1. Кандидат 5e0b3e152c7619f967fc7b518854bd6d8c9cb374: 2382 файла Node/PHP архивов сверены с Git objects; QA и rollback пройдены; свежие backups созданы.
2. PR 54 объединён после обязательных CI без обхода branch protection. Merge 0c583ef093ae57863df7f7ea938d3c1dd32ff995 имеет то же дерево.
3. Admin: younew-admin-5e0b3e1.tar.gz, SHA-256 e07769de608885752a60ffa86bb1620f819d0ec471e2d185448f61db044d9445. Deployment 01a1c60e-ea4b-70f6-87a3-5b2a74f6d03b — Completed/Current. Build `pnpm run build`, Node 24, Next 15.5.28.
4. Env: /home/u246392949/domains/admin.younew.nl/younew-private/launch.env, 0600. hPanel содержит YOUNEW_RUNTIME_ENV_FILE, production origin/mode, private drafts path, NODE_OPTIONS=--v8-pool-size=1 и UV_THREADPOOL_SIZE=1. База u246392949_younp1; QA credentials не переиспользованы.
5. 1133 public build files активированы атомарным exchange каталогов в 15:26:29 UTC. Добавлены 81 прежний hashed asset для открытых клиентов и bootstrap private files; всего 1215 файлов. Прежний public код теперь в /domains/younew.nl/public-release-5e0b3e1: имя обозначает операцию переключения, не текущий релиз.
6. PHP private forms используют HMAC worker из hostinger/runtime/backend/php/private/forms, а не прежний Supabase sync. Очередь/uploads/mail/apple association сохранены. BUSINESS cron включён в 15:27:38 UTC; в 15:30 доставил 4 реальные заявки.

GitHub — источник кода. Архивный deploy выбран потому, что Hostinger OAuth видит только Studio; права другого проекта не менялись. Runtime/cron не зависят от компьютера владельца.

Следующий релиз: exact-commit archive → QA → fresh backup → rollback rehearsal → protected merge → deploy → public checks. Одноразовые операторы этой даты повторно не запускать без новых manifest и каталогов.
