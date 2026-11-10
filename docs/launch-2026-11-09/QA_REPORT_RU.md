# Проверка релиза 10 ноября 2026

Кандидат `5e0b3e1`, production merge `0c583ef`; деревья совпадают. Все 8 запусков CI успешны: [SHA и ссылки](production-evidence-20261110/ci-5e0b3e1.json). Product, Admin, secrets, governance, data health, dependency audit, disposable Supabase (404 pgTAP, одобренный schema diff). Реальный Supabase не активировался.

| Среда | Проверка | Результат |
| --- | --- | --- |
| Hostinger QA | 44 HTTP checks: owner/admin/viewer/other, history/files, запрет неподдерживаемой публикации, logout/revoke, no-store | PASS |
| QA BUSINESS | Браузерная синтетическая заявка, 6 плановых циклов, 1 inquiry/receipt/notification | PASS |
| QA rollback | Node 5e0b3e1 → cf6ab6f; 44 checks, сохранена сессия/заявка/history/файл | PASS |
| QA static | Защищённый HTTPS, 9 страниц/404, rollback и возврат кандидата | PASS, итоговый gated report |
| Миграция | 90 таблиц/1396 строк; 4 профиля/3 заявки/1 файл; повторный импорт идемпотентен | PASS |
| MariaDB restore | 16 таблиц/1500 строк, definitions/fingerprints совпали; оригиналы сохранены | PASS |
| File restore | 4357 объектов и 8 SQLite, hash/integrity checks | PASS |
| Production HTTP | 22 проверки: страницы/assets/gzip, canonical/hreflang, mail/apple files, invalid PHP/login | PASS |
| Production browser | Desktop home, EN/NL Leiden/empty search, 390px карта/форма, Admin login | PASS; владелец вошёл, /dashboard наблюдён без ошибок консоли |
| Production BUSINESS | 49 реальных циклов, 4 заявки доставлены однократно; профили/роли/архив неизменны | PASS |
| Health | QA normal OK, stale DEGRADED; production read-only OK | PASS; расписание */15 сохранено |

Build, lint/types, ограниченные по параллелизму тесты, ссылки/security/governance/data health выполнены на Hostinger. Полный predeploy:check там не объявляется успешным: loopback preview несовместим с запретом custom ports. Этот слой проверен CI и защищённым HTTPS QA. Тесты не сокращались.

Промежуточные FAIL static reports сохранены: первая попытка выявила отсутствие защиты, следующая — Basic Auth; итог использует PHP gate. В HTTP harness исправлены регистр hrefLang и ожидаемый пустой login (401 по контракту). Это исправления проверки, не скрытые ошибки продукта.

Production не засорялся синтетическими аккаунтами/заявками. Скриншоты: /Users/ivan/YouNew-Launch-Evidence-2026-11-10/. Результаты относятся к указанным датам; email/SMS оповещение не настроено.

Scheduled monitor evidence: [health-scheduled.json](production-evidence-20261110/health-scheduled.json), 2026-11-10 19:45:03 UTC, OK; produced by the actual Hostinger cron.
