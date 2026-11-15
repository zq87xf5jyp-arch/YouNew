# Фактическая архитектура — 15.11.2026

Это индекс современной web/hosting-архитектуры; [корневой документ](../../ARCHITECTURE.md)
сохраняет описание SwiftUI. Новая база и новый фреймворк не создаются.

| Слой | Действующая реализация | Авторитетные файлы |
|---|---|---|
| Public web | Уже существующие Next.js 15.5.28 + React 19 + TypeScript; `output: export`, trailingSlash, статический HTML/JS | `admin-dashboard/public-site/package.json`, `next.config.ts`, `scripts/build.sh` |
| Hostinger web | Static/PHP 8.3, .htaccess, приватные outbox/analytics; HTTPS, существующий CDN | `hostinger/deployment/`, `hostinger/forms/`, `hostinger/analytics/` |
| Admin/backend | Managed Node 24, Next; MariaDB/InnoDB. Не SQLite-only | `hostinger/runtime/backend/source/admin-dashboard/`, `db/migrations/0001_core.sql`, `0002_catalog.sql` |
| SQL access | profiles/roles, sessions с hash, business_inquiries, receipt dedup, audit_events, private_files; catalog_places с ревизиями и approval | `hostinger/runtime/backend/db/migrations/` |
| Очередь/аналитика | Приватная SQLite, формы → HMAC worker → Node/MariaDB; не дубль каталога | `hostinger/forms/`, `hostinger/runtime/backend/php/private/forms/`, `hostinger/analytics/` |
| Контент | DataProject governed release → generated public-content → только прошедшие публикационный допуск сущности | `DataProject/`, `admin-dashboard/scripts/generate-governed-runtime.mjs`, `public-site/scripts/generate-public-content.mjs` |
| География | Версионированный Netherlands geography, официальные municipality/settlement IDs | `public-site/src/generated/netherlands-geography.json` |
| Web local state | Save/recent/profile/journeys/checklist/arrival route, версия и валидация; поисковые фразы только session-memory | `public-site/src/lib/storage/local-content.ts` |
| iOS | SwiftUI, local services/state, governed data; отдельный цикл подписания/release | `YouNew/`, `YouNewTests/`, `.github/workflows/product-ci.yml` |
| CI/release | GitHub — история; protected main → PR → gates → QA → backup/rollback → отдельное разрешение production | [Repository governance](../REPOSITORY_GOVERNANCE.md) |

Серверные credentials, персональные payload, private dumps в Git не помещаются.
Supabase в зависимостях/историческом коде не означает активный Supabase production.
Новый web framework не внедряется: Next/React уже часть текущего проекта.

## Эксплуатация и откат

Рабочие схемы и команды уже описаны в [OPERATIONS](../launch-2026-11-09/OPERATIONS_RU.md),
[DEPLOYMENT](../launch-2026-11-09/DEPLOYMENT_RU.md), [ROLLBACK](../launch-2026-11-09/ROLLBACK_RU.md).
Их состояние уведомлений дополняет [postlaunch](../postlaunch-2026-11-10/README_RU.md):
email включён, SMS не подключён. Исторические документы не переписываются задним числом.

QA-каталог уже защищён Basic Auth/noindex/no-store; исходный указатель этого запуска:
`hp-seo-review-20261111-r6`. Его приватный Г01 review не заменяется без сохранения.
Production в этом спринте не изменяется, миграции не нужны.

## Границы совместимости

Сохраняются URL, ID, языки, HomeSearchForm, Save, публикационные допуски, фото/лицензии,
Admin/cron. Небольшая доработка меняет только разметку главной и локальные стили.
Ни API, ни зависимости, ни структура данных не меняются.
