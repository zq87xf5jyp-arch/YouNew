# Проверенные возможности Hostinger

Business Web Hosting действует до 20 июля 2027: 50 ГБ, 3 ГБ RAM, 2 CPU, 600000 inodes, 50 сайтов, 120 процессов, 60 PHP workers. Тариф, платные дополнения и продления не менялись.

| Возможность | Доступна / включена | Нужна | Фактическое использование |
| --- | --- | --- | --- |
| Web/PHP | Да, PHP CLI 8.3.36 | Да | Production static/PHP формы/private files, HTTPS checks PASS. |
| Node.js | Да, Node 24 | Да | Новый production Admin; completed exact-archive deploy, ограничены thread pools. |
| MariaDB/права | Да, 11.8.9 | Да | Отдельные QA/prod базы, реальный импорт и restore; права/миграции проверены. |
| Cron | Да | Да | BUSINESS */5 проверен scheduler; health */15 сохранён; analytics сохранён; QA на паузе. |
| Домены/SSL | Да; бесплатные поддомены | Да | Production HTTPS и изолированные QA. DNS-зона и почта не переносились. |
| Backups | Daily и manual включены | Да | Manual 10.11 16:30 завершён; file/SQLite/MariaDB restore проверен; есть локальные copies. |
| Logs/diagnostics | Доступны | Да | Build/runtime/resource панели, private worker/health logs, QA stale detection. Внешнего оповещения нет. |
| Cache/gzip/CDN | Да, public CDN уже включён | Да | Gzip/static cache/HTML revalidation проверены. Admin/session/API no-store; private cache не включался. |
| Защита | SSL, malware scanner, IP Manager, directory protection | Да | TLS/HSTS, server auth/roles, QA isolation, private env0600, secret URLs закрыты. Ранее malware сводка без угроз; новый отдельный scan не заявляется. |
| Private storage | Да | Да | Исторический payload сохранён; signed file service/roles проверены в QA; публичный доступ закрыт. |
| SSH/terminal | Да, SSH active | Да | Web terminal работает; direct key добавляет владелец, пока не подтверждён. |
| GitHub/deploy | Archive build доступен; OAuth только Studio | Да | GitHub canonical, exact-commit archives, protected PR54. Чужие OAuth права не менялись. |
| Mail | support@younew.nl/квота подтверждены; SMTP sending условия не установлены | Для будущих уведомлений | Ящик сохранён; отправка/новые услуги не активированы. Внутренние Admin notifications работают. |
| WebMCP/MCP Server Card | Включение как услуги тарифа не установлено | Нет для этого запуска | Не добавлялись ради AI-score. |

Hostinger Mail не содержит hosting-операций Node/PHP/DB/cron/SSL/backup/CDN. Использован разрешённый официальный hPanel. Отсутствие API плагина не считалось отсутствием функции тарифа.

[Node limits](https://www.hostinger.com/support/hostinger-node-js-limits-for-web-and-cloud-plans/) и [поддерживаемая связность](https://www.hostinger.com/support/which-web-standards-and-connectivity-features-are-supported-at-hostinger/) объясняют ограничение параллелизма и HTTPS QA вместо custom-port preview. Наблюдаемая нагрузка не потребовала upgrade или boost.
