# YouNew Phase 5 — Controlled Launch & First Users

Дата: 24 октября 2026 года. Решение: **локальный release candidate готов к фиксации; production остаётся NO-GO до отдельного разрешения и live-only backup gates**.

## Что реализовано

- Подтверждены на уровне полей 10 востребованных железнодорожных станций Amsterdam по официальным NS страницам и точным OpenStreetMap objects.
- Создан QA overlay `amsterdam-v0.1.9`; production runtime и 170 exclusions не изменены.
- Проверено влияние 170 исключений: они отсутствуют в публичном JSON, статических страницах и sitemap; пустых страниц нет; существующие canonical URL сохранены для безопасного возвращения десяти кандидатов.
- Data Health gate поддерживает безопасную переходную модель: deny-list может быть строже текущей freshness debt, но никогда слабее.
- В Admin Analytics добавлен честный launch scorecard из восьми KPI. Доступные агрегаты показывают измеренное значение; неподключённые источники показывают `—`.
- Добавлен privacy-minimized Storage inventory и явное предупреждение, что PostgreSQL backup не содержит Storage payload bytes.
- Подготовлены controlled-launch, rollback, first-100 visitors и first-10 business registrations планы.
- Проверены 14 ранее ожидавших legal/channel review компаний: готовых к исходящему контакту нет; отправок не было.

## Каталог

| Показатель | Результат |
|---|---:|
| Production-safe public records | 7 |
| Новые field-confirmed QA candidates | 10 |
| Production records added | 0 |
| Candidate public records after separate acceptance | 17 |
| Production exclusions | 170 |
| Осталось без текущего field confirmation | 160 |

## Аналитика и воронка

- Измеряются: consented просмотры карточек, начала формы, сохранённые заявки.
- Search Console organic visitors появятся только после domain verification/submission.
- Repeat visits, registered/activated companies, confirmed partners и revenue не подменяются косвенными показателями.
- NL/EN форма и Edge persistence не менялись после успешного Phase 4 EN/NL E2E; Phase 5 выполняет повторную статическую, unit и browser-проверку без production writes.

## Проверка release candidate

| Проверка | Результат |
|---|---|
| Public tests | 199/199 PASS |
| Public package | 464 indexable URLs, 493 HTML |
| Internal links/assets | 37 956 references, 0 broken |
| Security/package/404 | PASS |
| Admin tests | 159/159 PASS |
| Admin lint/typecheck/build | PASS |
| Browser path | EN home → search → verified guide PASS |
| NL browser path | NL home → free business form PASS |
| Narrow in-app viewport visual review | no horizontal overflow or hidden primary form controls observed |

Браузерная проверка выполнялась на локальном статическом артефакте. Она не заменяет post-deploy smoke на production origin.

## B2B

| Статус среди 14 | Количество |
|---|---:|
| Ready for lawful outbound | 0 |
| Human terms/purpose validation required | 3 |
| General contact / inbound only | 11 |
| Messages sent | 0 |

Использовать только входящую бесплатную регистрацию до отдельного разрешения и проверки конкретного канала.

## Что остаётся до production

1. Явное разрешение владельца на точный archive SHA-256.
2. Production DB backup, отдельная копия Storage payloads, inventory reconciliation и disposable restore в окне запуска.
3. Staging parity smoke и две маркированные NL/EN synthetic submissions с безопасной очисткой только их строк.
4. Search Console domain access и sitemap submission.
5. Отдельное принятие `amsterdam-v0.1.9`, если 10 карточек должны войти в первый пакет.
6. Подключение доказуемого статуса company activation и источника actual revenue, когда они появятся.

## Статус безопасности

Production deployment, database migration, B2B outreach, платное обогащение, доступ к персональным контактам и необратимые production-изменения не выполнялись.
