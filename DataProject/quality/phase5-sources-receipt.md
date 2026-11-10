# Phase 5 source receipt

Дата анализа: 2026-10-24. Среда: локальный workspace. Production data и production credentials не использовались.

## Каталог

- Вход: опубликованный Amsterdam release `amsterdam-v0.1.8`, его 170 fail-closed exclusions и QA overlay `amsterdam-v0.1.9`.
- Официальный источник: NS Amsterdam destination page и десять официальных NS station pages.
- Географическое подтверждение: десять точных OpenStreetMap objects, перечисленных в `DataProject/research/phase5-station-confirmations.json`.
- Результат: 10 field-confirmed QA candidates, 0 добавлено в production runtime, 160 записей без текущего field confirmation.

## Аналитический dashboard

- Consented события: агрегаты `page_view` и `lead_start` из существующего analytics store.
- Сохранённые заявки: точное количество строк `business_inquiries` при доступном store.
- Organic visitors, repeat visits, registered companies, confirmed partners и actual revenue: источник не подключён; dashboard показывает `—`, а не вымышленный ноль.
- Преобразования: сумма `event_count`; сумма `page_views` только по canonical company-card routes; сохранённые заявки — server-side count.

## B2B channel review

- Вход: 14 ранее отмеченных компаний, их уже записанные официальные публичные URLs.
- Нормативные источники: Autoriteit Persoonsgegevens digital direct marketing/direct marketing, ACM spam guidance и Telecommunicatiewet artikel 11.7.
- Результат: 0 каналов признано готовыми к исходящему контакту; 3 требуют human terms/purpose review; 11 ограничены inbound/general-contact-only.

## Технические проверки

- Public pre-deploy: production build, 199 tests, static smoke, links/assets, security package, sitemap/404 and governed health gate.
- Admin: 159 unit/contract tests, lint, typecheck and production build.
- Browser: local EN home → search → verified guide and NL home → free business form; narrow in-app viewport visually checked.
- Storage: metadata-only inventory script and contract tests; live inventory and payload backup intentionally deferred until an authorised deployment window.

Ограничения: Search Console не подключён локально; production metrics и revenue не наблюдались; никакие сообщения компаниям не отправлялись.
