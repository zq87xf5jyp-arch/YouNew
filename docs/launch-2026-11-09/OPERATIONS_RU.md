# Запуск и откат: подтверждённое состояние и оставшиеся шаги

Канонический код: `https://github.com/zq87xf5jyp-arch/YouNew`, ветка `release/younew-hostinger-launch-2026-11-09`, PR 54. Секреты, очереди, пользовательские файлы и резервные копии не входят в репозиторий.

## Что работает сейчас

- `https://younew.nl/` — прежний production. Главная при исходной проверке отвечала 200; её SHA-256 `640029346dbd00c7fd626acc65bbd2badbd5560f340d6629681a1babd8a2d254`. Точный Git commit этого старого размещения не подтверждён.
- `https://qa-runtime.younew.nl/login` — изолированный Admin из архива `852413130f3bc190128e53bebdc997fef7d30d1e`, Node 24.x. Предыдущий `1dab9d8` сохранён. Вход/роли/logout: 43 проверки PASS; bcrypt cost-10: PASS. Это синтетическая QA, не перенесённые реальные аккаунты.
- Приватная серверная Git-копия и отдельный builder обновлены до `2c74249782f32cd36c406d42b8eb654c0153a193`. PHP gate остаётся из `dd9b5537`. Исходники каждого сборочного worktree проверяются по точному commit.
- `admin.younew.nl` сохранён. Его конфигурация ссылается на неактивный Supabase `pgdzdxsiagfjioxwuqxf`. Экспорт реальных данных сохранён; полное восстановление старого Supabase runtime и перенос аккаунтов/данных в новый backend ещё не выполнены.

## Резервные копии

Ручная копия Hostinger завершена 09.11.2026 в 13:22 по времени панели. Дополнительная приватная копия:

`/home/u246392949/domains/younew.nl/younew-private/launch-backups/20261109T124105Z`

В ней `files.tar.gz`, согласованные SQLite-снимки в `sqlite/`, приватный manifest, сохранённое расписание cron и уже проверенная изолированная папка `restore-check/`. Архив содержит 5787 файлов, отдельно сохранены восемь SQLite. SHA-256 архива:

`bac4d687c5ff3817ce84873539eee39ed1b3a808f513caac3af321bac96b8239`

Восстановление в `restore-check/`, файловые хеши и SQLite `integrity_check` прошли. Эта копия не включает реальные удалённые данные Supabase и не является проверкой восстановления новой MariaDB.

Для повторной проверки сначала сверить SHA-256, затем распаковать в **новую приватную папку**, заменить SQLite в этой папке их согласованными снимками и повторить проверки. Не распаковывать старый архив поверх работающих очередей, БД или uploads. Скрипт `scripts/hostinger/backup-current.py` делает новую копию и изолированную проверку, а не откат production.

### Резервирование новой QA MariaDB

`hostinger/deployment/backup-qa.mjs` — отдельная операторская команда, не часть запуска приложения. Она допускает только `127.0.0.1`, базу и пользователя `u246392949_younq1`, `R4_LOCAL=false` и проверенную MariaDB 11.8.9. На время копирования должны быть остановлены изменения схемы. Из каталога серверного `hostinger/runtime/backend/source/admin-dashboard`, где установлен `mysql2`, команда:

```sh
R4_LOCAL=false NODE_OPTIONS=--v8-pool-size=1 UV_THREADPOOL_SIZE=1 \
/opt/alt/alt-nodejs24/root/bin/node \
  --env-file=/home/u246392949/domains/qa-admin.younew.nl/younew-private/launch.env \
  /home/u246392949/domains/qa-catalog.younew.nl/younew-private/launch-source/hostinger/deployment/backup-qa.mjs \
  --approved-qa --no-schema-changes
```

Скрипт создаёт новую папку в приватном `hp1/backups/`, не перезаписывает предыдущие копии, проверяет InnoDB и неизменность определений таблиц. Пароль используется через временный файл 0600 и удаляется из него после завершения клиента; в аргументы процесса и отчёт он не попадает. SQL, manifest и stderr остаются приватными. Частичный dump после ошибки нельзя использовать. Наличие routines/events/triggers требует отдельного расширения проверки и останавливает текущую команду.

Успех команды означает только `BACKUP_WRITTEN_RESTORE_PENDING`. Затем нужно восстановить **эту** копию в отдельной пустой базе, сравнить определения и строки, записать результат. Production и рабочую QA-базу для проверки восстановления не использовать. Dump согласован для InnoDB при отсутствии параллельного DDL; это соответствует [документации MariaDB](https://mariadb.com/docs/server/clients-and-utilities/backup-restore-and-import-clients/mariadb-dump).

Для первоначальной QA до application keys и трафика подготовлен отдельный сохраняющий вариант: `QA_RESTORE_RU.md`. Он принимает только известные синтетические fixtures и сохраняет все исходные таблицы внутри изолированной базы до восстановления. Его нельзя применять к уже работающей QA или production.

Локальная проверка инструмента запускается командой `node hostinger/runtime/tests/db-backup.integration.mjs --local-disposable` при установленных MariaDB CLI и зависимостях нового Admin. Она поднимает собственный сервер без сетевого слушателя, проверяет dump/restore всей схемы миграций и синтетических строк, затем останавливает сервер. Подтверждённый результат на локальной MariaDB 13.0.2: 13 таблиц, 7 строк, совпадение определений и отпечатков данных; включая Unicode, JSON, binary, NULL и timestamps. Это **не** доказательство восстановления Hostinger MariaDB 11.8.9.

## Условия перед публикацией

1. Обязательные проверки PR должны пройти для публикуемого commit. Старый PostgreSQL schema-diff одобрен владельцем; запись и digest находятся в `SUPABASE_SCHEMA_REVIEW_RU.md`.
2. Владелец сохранил пароль новой QA-базы в приватном `launch.env`; подключение прошло. Сам пароль не переносится в GitHub, чат, командную строку или отчёт. Копия конфигурации: `/home/u246392949/domains/qa-catalog.younew.nl/younew-private/hp1/backups/20261109T153346Z`, права файла 0600.
3. Полный preflight подтвердил scoped privileges, отсутствие GRANT OPTION, global USAGE, пустые table/column grants, NULL active role и исходную пустоту базы. Две миграции применены. Dump/restore 12 таблиц и 12 синтетических строк прошёл, все оригиналы сохранены; см. `HOSTINGER_QA_SERVER_EVIDENCE.json`.
4. BUSINESS проверен настоящим cron Hostinger каждую минуту: доставка, два 503 без частичных строк, успешный retry, отсутствие дублей и worker_running при занятом lock. Действующий analytics cron не менялся. Каталожный cron ещё не активирован.
5. Экспорт старого Supabase получен без активации. База, Storage и отчёты находятся на Hostinger в `younew-private/launch-backups/supabase-preservation-20261109/`; SHA-256 архива — `b51073a770006b4df9e7f880451edceb464971a00a79b85394ab98f1394055cb`. Данные COPY восстановлены и сверены побайтно; Storage payload сопоставлен с метаданными. Полный Supabase runtime и безопасный перенос в MariaDB остаются отдельной проверкой. Не активировать проект автоматически.
   Совместимость проверки старых bcrypt-паролей подготовлена и испытана на синтетических аккаунтах: `LEGACY_AUTH_COMPATIBILITY_RU.md`. Перенос реальных пользователей, workspace, исторических заявок и остальных таблиц этим не закрывается.
6. Прогнать весь сценарий на Hostinger QA, включая PHP → backend → Admin, EN/NL, LIVE/EXPLORE/BUSINESS, поиск, карту, мобильную форму, роли, reload и сохранение.

## Публикация и безопасный откат

Архивы для Hostinger готовятся из **зафиксированного Git commit**, не из рабочего дерева:

```sh
python3 hostinger/deployment/package.py --ref FULL_COMMIT_SHA \
  --output-dir /path/outside/checkout/new-release-directory --archive
```

Указать новую папку вне checkout. Упаковщик читает Git blobs, игнорирует локальные изменения, неотслеживаемые файлы, `.env`, приватные каталоги, зависимости, сборки и симлинки. `release.json` содержит исходный commit, SHA-256 обоих архивов и manifests; он появляется только после успешного завершения. Node-архив содержит Admin, исходники и инструменты `catalog-builder`, миграции и операторские команды. Это не установка зависимостей и не проверка работы cron. Старые `node-app-files.json` / `php-site-files.json` в репозитории — историческая инвентаризация; актуальные manifests брать только из новой папки релиза.

Перед переключением сохранить свежие конфигурации, текущие заявки, uploads и согласованный dump. Публиковать архив точного Git commit и записать его в release manifest. GitHub остаётся источником кода; серверная работа не должна зависеть от локального preview.

После переключения повторить критические сценарии через публичные домены и проверить реальные заголовки: приватные Admin/API не должны кэшироваться. Оставить предыдущий рабочий код.

При критической регрессии переключить **код** на предыдущий deployment/сохранённый release. Не откатывать базу или очередь старым снимком поверх новых заявок. Восстановление данных требует отдельного сопоставления новых записей, uploads и схемы. Реальный production rollback нового кандидата пока не испытан и не объявляется готовым.

Уборка выполняется после этих проверок. Текущая ведомость `CLEANUP_INVENTORY.md` сохраняет все 21 локальный каталог; ни один пока не удалён и не перемещён в карантин.

## Особенности фактического QA-размещения

Managed Node разворачивает standalone build, оставляя `.next`, `node_modules`, `server.js` и package metadata; он не сохраняет 2359 исходных файлов из Node-архива. Поэтому попытка сопоставить весь source manifest с runtime не прошла и не используется как подтверждение идентичности compiled output. Связь с commit фиксируется через проверенный загруженный архив, deployment ID и HTTP-проверки. Catalog builder размещается отдельно в приватном `hp1/catalog-builders/`, с сохранением собственного Git commit и проверкой исходных файлов.

Файловый Basic gate не смог читать credential внутри каталогов 0700 от пользователя веб-сервера. PHP router теперь проверяет те же QA credentials, остающиеся 0600. Единственное исключение — `/private-files.php`, где проверяются отдельные HMAC, timestamp и nonce. Прежние `.htaccess`/router сохранены в `hp1/backups/qa-gate-20261109T172050Z`. Для отката защитных файлов сначала установить прежний `.htaccess`, затем прежний router; не оставлять маршрут без проверки доступа.

При установке catalog dependencies pnpm сначала получил `ERR_WORKER_INIT_FAILED EAGAIN`. Повтор с `PNPM_MAX_WORKERS=1`, `UV_THREADPOOL_SIZE=1`, `NODE_OPTIONS=--v8-pool-size=1`, `--child-concurrency=1 --network-concurrency=2 --frozen-lockfile --ignore-scripts` прошёл за 12.6 секунд (pnpm 11.17.0). Оба журнала сохранены в `hp1/logs/catalog-dependencies-dd9b553*.log`; другие приложения не останавливались. Новое ограничение Rayon относится только к процессу QA-сборки; [официальная документация Rayon](https://docs.rs/rayon/latest/rayon/struct.ThreadPoolBuilder.html#method.num_threads) описывает `RAYON_NUM_THREADS`.

Первое испытание каталога остановилось на многопоточном Git lstat. Для одного QA-процесса задаются `core.preloadIndex=false` и `index.threads=1` через `GIT_CONFIG_*`, без изменения глобального config; [документация Git](https://git-scm.com/docs/git-config) описывает оба ограничения. Следующие испытания дошли до компиляции, но останавливались с EAGAIN при запуске lint/typecheck. Диагностика измерила 38 потоков у Next; ограничение `TOKIO_WORKER_THREADS=1` снизило это число до 6, после чего lint и TypeScript прошли. Режим workerThreads столкнулся с `ERR_WORKER_INVALID_EXEC_ARGV` при сборе страниц из-за `--v8-pool-size`. Итоговая QA-конфигурация использует `cpus=1`, `workerThreads=false` и отдельные ограниченные пулы. Проверки не отключаются. [Документация Tokio](https://docs.rs/tokio/latest/tokio/runtime/struct.Builder.html#method.worker_threads) описывает переменную; измерения находятся в `hp1/logs/catalog-sixth-pressure.private.jsonl` и `catalog-seventh-pressure.private.jsonl`.

## Ресурсы прежнего Admin, 18:05–18:14 UTC

До настройки сохранены файлы `hbuilds/config`, включая `.env` с правами 0600, и исходные ответы login в приватной копии `younew-private/launch-backups/admin-resource-20261109T180435Z`. Через hPanel добавлены только `NODE_OPTIONS=--v8-pool-size=1` и `UV_THREADPOOL_SIZE=1`; шесть прежних значений остались неизменны. Те же параметры предварительно работали в QA. Hostinger автоматически пересобрал прежний архив `younew-admin-sync-20260920.zip` и завершил deployment `01a1c17c-3b68-72f9-892c-e0635e5aab0b`. Новый кандидат и публичный сайт этим действием не публиковались; Supabase не активирован.

После пересборки login возвращает 200 и содержит password input; наблюдались два процесса по 5 потоков. Побайтное совпадение HTML после новой сборки не заявляется. Результаты и откат только двух параметров — `ADMIN_RESOURCE_EVIDENCE.json`. Другие сайты и почта не менялись.
