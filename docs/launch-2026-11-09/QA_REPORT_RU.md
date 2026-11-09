# Проверки запуска YouNew

Снимок состояния: 9 ноября 2026. Node QA: `852413130f3bc190128e53bebdc997fef7d30d1e`; PHP gate: `dd9b55373874b5229d7e075ddd6743e8166d3853`. Новый production **не опубликован**. PASS относится только к указанной среде и объёму; локальная проверка не подтверждает Hostinger или production.

| Проверка | Среда | Статус | Доказательство и предел |
| --- | --- | --- | --- |
| Главная EN/NL отвечает по HTTPS | Старый production | PASS | Read-only 09.11 16:13 UTC: обе страницы 200. SHA главной совпал с исходным `640029…d254`. Это не полная проверка всех сценариев. |
| Определён commit старого production | Production | NOT TESTED | Исходные файлы сохранены, точное соответствие Git commit не установлено. |
| Файлы, uploads, SQLite и конфигурация сохранены | Hostinger | PASS | `HOSTINGER_BACKUP_EVIDENCE.json`: 5787 файлов, 8 согласованных SQLite, приватная копия cron. |
| Восстановление этой файловой копии | Изолированная папка Hostinger | PASS | Хеши файлов и SQLite integrity_check; рабочие очереди не заменялись снимком. |
| Сохранение старого Supabase database/Storage | Hostinger + локально | PASS | `SUPABASE_PRESERVATION_EVIDENCE.json`; оригинальные экспорты и payload сверены, проект не активирован. |
| Полный runtime restore старого Supabase | Изолированная среда | NOT TESTED | Восстановлены все COPY payload, но не весь provider runtime с расширениями. |
| Node Admin, вход, роли, cookie и logout | Hostinger QA `8524131` | PASS | 43 HTTP-проверки на восьми синтетических аккаунтах; `HOSTINGER_QA_SERVER_EVIDENCE.json`. |
| Подключение QA MariaDB и schema privileges | Hostinger CLI | PASS | MariaDB 11.8.9, utf8mb4, schema grants без GRANT OPTION; `hp1/logs/db-preflight.json`. |
| Global/table/column privileges, active role, исходные таблицы QA | Hostinger | PASS | Global USAGE, без GRANT OPTION; table/column grants пусты, active role NULL, исходная БД пуста. |
| Dump/restore новой QA MariaDB | Hostinger MariaDB 11.8.9 | PASS | 12 таблиц и 12 синтетических строк восстановлены; все 12 исходных таблиц сохранены. `QA_RESTORE_RU.md`. |
| Инструмент MariaDB backup/restore | Локальная MariaDB 13.0.2 | PASS | `QA_BACKUP_TOOL_LOCAL_EVIDENCE.json`: 13 таблиц, 7 строк, совпадение определений и содержимого. Не проверка Hostinger 11.8.9. |
| Совместимость bcrypt/scrypt и ограничения входа | Локально | PASS | `LEGACY_AUTH_COMPATIBILITY_RU.md`: 7 unit и 22 HTTP-проверки, независимые PHP vectors, роли, pending/blocked, restart/logout. Только синтетические аккаунты. |
| Новый Admin build/password tests/anonymous access | CI `a8054da` | PASS | [Admin CI](https://github.com/zq87xf5jyp-arch/YouNew/actions/runs/42654439648), job `Hostinger Admin build and anonymous access`. |
| LIVE/EXPLORE/BUSINESS, EN/NL, поиск, карта, форма | Локальный публичный кандидат | PASS | Браузерные проверки desktop/390 px, Leiden, смена языка, add/claim и обязательные поля; `README_RU.md`. Реальная отправка BUSINESS на Hostinger этим не подтверждена. |
| Снятие просроченных записей, исключение новых черновиков | Локально + CI | PASS | `WITHDRAWAL_QA.md`, publication gates; 172 снятых записи, 71 новый черновик не публиковался. |
| Все применимые PR workflows кандидата кода | GitHub `a8054da` | PASS | Семь workflows завершились успешно; точные SHA/URL в `CI_EVIDENCE_A8054DA.json`. [Product CI](https://github.com/zq87xf5jyp-arch/YouNew/actions/runs/42654439522) включает iOS tests, accessibility и unsigned Release. Последующие commits требуют собственных checks. |
| Архивы выбранного commit | Локально, `8524131` | PASS | 2374 члена двух архивов сверены с manifests; Node-архив размещён, PHP gate обновлён отдельно. Managed runtime сохраняет standalone output, не все исходники. |
| Настоящий BUSINESS cron, retry, dedupe, блокировка worker | Hostinger QA | PASS | Доставка 17:22 UTC; 503 без частичных строк и успешный retry 17:28; worker_running 17:30 и доставка 17:31. Ручной worker не запускался, analytics cron сохранён. |
| Каталог: переключение, ошибка сборки, отзыв, задержка | Hostinger QA `7efb72f` | PASS | 64 HTTP-проверки; настоящий cron каждую минуту. Публикация за 79,74 с, отзыв за 131,42 с с намеренной ошибкой сборки; прежний active pointer сохранён, fault устранён. 71 реальный черновик исключён. |
| Роли, чужие объекты, сохранение и перезапуск | Hostinger QA | PASS | 15 объектных/файловых проверок. Полная замена процессов сохранила прежнюю сессию без повторного входа, identity/inquiries/file побайтно совпали, logout отозвал сессию. `HOSTINGER_CATALOG_RESTART_EVIDENCE.json`. |
| Перенос реальных пользователей, заявок и файлов | Hostinger | NOT TESTED | Экспорты сохранены; назначение workspace, исходные статусы и сверка всех записей требуют законченного импорта. |
| Закрытый QA, секреты, логи, backup paths недоступны | Hostinger QA | PASS | Basic gate, no-store/noindex и запрет приватных путей проверены в 64 catalog checks. |
| Новый production: критические сценарии, CDN и rollback | Production | NOT TESTED | Переключение не выполнялось. |
| Уборка после успешного запуска | GitHub/Hostinger/локальные копии | NOT TESTED | Не начиналась; действия и ограничения в `CLEANUP_MANIFEST.csv`. |

Открытые ограничения перечислены в `OPEN_ISSUES_RU.md`. Подробные логи, скриншоты, дампы и приватные manifests находятся в защищённых каталогах доказательств, а не в GitHub.

Все workflows `7efb72f` прошли; точные SHA и ссылки — `CI_EVIDENCE_7EFB72F.json`. Два сбоя GitHub Internal server error устранены повторным запуском без изменения проверок. Scoped minimatch 11.0.1 проверен локально: lint/typecheck и три полных audit без уязвимостей. Новый commit требует собственных CI и Hostinger deployment.
