# Откат и восстановление без потери новых данных

Проверено в Hostinger QA: Node 5e0b3e1 → cf6ab6f с сохранением DB/session/заявки/файла, 44 HTTP checks PASS. Static rollback и повторное включение кандидата проверены через защищённый HTTPS. Реальную production БД назад не откатывали.

## Проверенные копии

База серверных копий: /home/u246392949/domains/younew.nl/younew-private/launch-backups/.

| Объект | Подкаталог/файл | SHA-256 |
| --- | --- | --- |
| Файлы/config/uploads + 8 SQLite | production-pre-switch-20261110T144758Z/files.tar.gz | 01cffa54c31a2838e62c85ab96a600b40179fbd62f29711ba3855f7381866960 |
| MariaDB до подключения | production-db-prelaunch-2026-11-10T13-39-28-735Z/database.sql | cadf5eb63c3350444f2c24ae948b05bafe601d648b74299195b9ddc9eda12ad1 |
| Supabase database/Storage | supabase-preservation-20261109/supabase-preservation-20261109.tar.gz | b51073a770006b4df9e7f880451edceb464971a00a79b85394ab98f1394055cb |

Локальные копии: /Users/ivan/YouNew-Launch-Evidence-2026-11-10/private-backups/, 0600. Исходная файловая копия 9 ноября сохранена. Restore сверил 16 таблиц/1500 строк/definitions и 4357 файловых объектов/8 SQLite integrity_check; исходные таблицы сохранены отдельно.

Hostinger Daily включён; ручная копия завершена, панель показывает 2026-11-10 16:30. Provider исключает archives/cache/database exports; отдельные проверенные копии выше обязательны.

## При регрессии кода

1. Сохранить свежие DB/queue/uploads и логи. Если неисправен BUSINESS, создать приватный marker launch-production/PRODUCTION_BUSINESS_PAUSED для остановки только этого worker.
2. Admin: разместить сохранённый younew-admin-cf6ab6f-rollback.tar.gz, SHA-256 b0b2d15f67455b41add556f2028a1d1e9520e4bf9bf54ee0e26d711e9ac38095, с тем же production env/MariaDB. Старый Supabase deployment 01a1c17c-3b68-72f9-892c-e0635e5aab0b сохранён, но не является функциональным rollback нового backend: его Supabase неактивен.
3. Public: после сверки manifest атомарно обменять public_html и public-release-5e0b3e1; для возврата вперёд выполнить обратный exchange. Private forms/HMAC и изменяемые данные не участвуют в обмене. Не возвращать старый Supabase worker.
4. Проверить HTTPS/EN/NL/формы, private API/no-store, вход/роли и последние заявки. Затем снять созданную паузу, оставив единственный BUSINESS cron. Зафиксировать incident/версии.

## Если повреждены данные

Не импортировать старый dump поверх живой базы. Сначала сохранить текущее состояние, восстановить backup в отдельную приватную БД/папку, сверить hashes/definitions/counts/integrity. Объединить новые заявки/uploads после snapshot; только после проверки переключать конфигурацию. Единственные копии не удалять, Supabase автоматически не активировать.
