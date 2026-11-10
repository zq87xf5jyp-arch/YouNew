# Откат редакционного выпуска

Состояние до выпуска сохранено на Hostinger в `/home/u246392949/domains/younew.nl/younew-private/editorial-backup-20261110/` и отдельно на компьютере владельца. Архив проверен целиком; SHA-256 `88704e24011976159b9259a5e54db84860db49c6b16928bc815500c0b906ec49`. SQLite прошла integrity_check; 4 BUSINESS и 1 feedback сохранены.

До активации не выполнять откат: каталог `public-editorial-20261110` содержит новый кандидат. После активации тот же каталог будет содержать прежний сайт (атомарный обмен), а `production-result.json` подтвердит ACTIVE и SHA корня.

После активации, если нужен откат именно этого выпуска:

1. Сверить текущие rootSha256 и Node buildId с `production-result.json` и `node-production-result.json`. При несовпадении остановиться: мог выйти следующий выпуск.
2. Атомарно обменять `/domains/younew.nl/public_html` и `/domains/younew.nl/public-editorial-20261110` через Linux renameat2(RENAME_EXCHANGE), как в `hostinger/editorial/release.py`. Новый сайт сохранить в каталоге кандидата.
3. Сохранить текущий `launch-production/editorial-drafts.json` отдельно, затем восстановить **только этот файл** из `editorial-backup-20261110/editorial-drafts.json`. Заявки и БД не восстанавливать поверх текущих: новые обращения должны сохраниться.
4. Для Admin использовать `node-production-result.json`: атомарно обменять текущий `nodejs` с указанным rollbackDirectory и обновить `nodejs/tmp/restart.txt`. Аналогично вернуть `hbuilds/last-source` из `managed-source-production.json`, сохраняя новую версию в соседнем каталоге.
5. Проверить корневой SHA старого сайта `93dc9eab6fdd320adb7833904be83c89906d4667911bf134d6ba5080887a7ebc`, HTTPS, login 200, приватные API 401 + no-store, BUSINESS endpoint GET 405 + no-store, реальный 404, health OK. Записать факт отката рядом с результатом активации.

Приватные env, почта, DNS, cron и реальные данные не заменяются при откате кода. Отдельный кодовый откат уже успешно отрепетирован на закрытом Hostinger QA как для PHP-каталога, так и для Node.
