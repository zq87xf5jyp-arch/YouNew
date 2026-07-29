# Админ-панель YouNew.nl

Это административный проект YouNew.nl. Сейчас подтверждённая production-граница — чтение защищённых таблиц Supabase, отдельные server actions контента/настроек, public API и версионированная раздача опубликованного governed runtime. Общая таблица `CrudTable` работает в режиме просмотра: она не показывает фиктивные кнопки создания, редактирования или удаления.

## Что есть на сайте

- **Панель** — общий обзор: сколько статей, категорий, городов, открытых ошибок, визуальных проверок и насколько готов релиз.
- **Аналитика** — активные пользователи, сессии, популярные экраны, поиски, AI-вопросы, стабильность и события приложения.
- **Синхронизация** — fingerprint канонического runtime, опубликованные релизы, подтверждённое административное состояние Supabase и история задач.
- **Контент** — создание и редактирование статей, гайдов, FAQ, справочных материалов и источников для AI.
- **Категории** — управление основными разделами приложения: документы, транспорт, жилье, здоровье, штрафы и т.д.
- **Города** — страницы городов: Amsterdam, Rotterdam, The Hague, Utrecht, Leiden, Eindhoven, Groningen, Maastricht.
- **Карта** — точки карты: города, муниципалитеты, больницы, транспортные точки, государственные места.
- **Проверка UI** — загрузка скриншотов, ручные маркеры проблем, статус “хорошо / нужна проверка / сломано / исправлено”.
- **Ошибки** — bug tracker с таблицей и канбаном по статусам.
- **Релизы** — чек-лист перед публикацией в App Store / Google Play / Web.
- **Ссылки** — каталог официальных URL: government, municipality, transport, healthcare, education.
- **Знания AI** — база проверенных вопросов и ответов для AI-ассистента. Важные ответы должны иметь официальный источник.
- **Отзывы** — сообщения пользователей, идеи и проблемы.
- **Настройки** — название приложения, support email, ссылки App Store / Google Play, язык и город по умолчанию.
- **Журнал** — audit log: кто, что и когда изменил.

## Как это работает

Админка построена так:

1. Администратор входит через Supabase Auth.
2. Supabase проверяет таблицу `profiles`: пользователь должен быть одобрен и иметь роль.
3. Внутри админки можно редактировать таблицы Supabase: `articles`, `categories`, `cities`, `map_points`, `bugs`, `releases` и другие.
4. Row Level Security защищает данные: обычный публичный доступ видит только опубликованный контент.
5. Public API читает опубликованные данные из Supabase и возвращает HTTP 503, если production-источник недоступен; демо-данные никогда не выдаются как production.
6. `/api/mobile/sync` отдаёт копию того же опубликованного runtime-артефакта, который встраивается в production-приложение и генерирует публичный сайт. ETag равен dataset fingerprint; совпадающий `If-None-Match` получает HTTP 304.
7. Для аналитики приложение отправляет события в `/api/mobile/analytics/events`.
8. Скриншоты UI хранятся в приватном Supabase Storage bucket `screenshots`.
9. Изображения материалов загружаются только в публичный bucket `content-images`: браузер оптимизирует их в WebP и автоматически получает URL полной версии и миниатюры.
10. Все важные изменения пишутся в `audit_logs`.

## Роли

- **Admin** (`owner` / `admin`) — полный доступ, управление синхронизацией и настройками.
- **Editor** (`editor`) — создание и редактирование контента, категорий, городов, карты, ссылок и AI-знаний.
- **Read Only** (`viewer`) — просмотр без права менять контент.
- Существующая техническая роль **QA** (`qa`) сохраняется для проверок интерфейса, ошибок и релизов.

Доступ проверяется на четырёх уровнях: middleware, защищённый layout, server actions и PostgreSQL Row Level Security. Скрытие пунктов меню — дополнительный слой интерфейса, а не единственная защита.

## Локальный запуск

```bash
cd admin-dashboard
pnpm install
cp .env.example .env.local
pnpm dev
```

Открыть: `http://localhost:3000`

Без Supabase-переменных вход закрывается с ошибкой конфигурации. Локальные демо-данные доступны только при явной установке `YOUNEW_ADMIN_DEMO_MODE=true` и никогда не включаются в production.

## Переменные окружения

```bash
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
NEXT_PUBLIC_APP_URL=http://localhost:3000
YOUNEW_ADMIN_DEMO_MODE=false
```

Важно: `SUPABASE_SERVICE_ROLE_KEY` нельзя использовать в клиентском коде. Только сервер.

## Настройка Supabase

1. Создать проект Supabase.
2. Запустить SQL из `supabase/migrations/` по порядку, включая `0006_lock_down_analytics_ingest.sql`.
3. Не запускать `supabase/seed/seed.sql` в production. Это только локальные демонстрационные записи; файл требует явного `set younew.allow_demo_seed = 'on'` в той же SQL-сессии.
4. Создать пользователя в Supabase Auth.
5. Добавить его в `profiles`:

```sql
insert into public.profiles (id, email, full_name, role, is_approved)
values ('AUTH_USER_ID', 'owner@younew.nl', 'Owner', 'owner', true)
on conflict (id) do update set role = 'owner', is_approved = true;
```

## Public API для мобильного приложения

Мобильное приложение может читать опубликованные данные:

- `/api/public/categories`
- `/api/public/articles`
- `/api/public/cities`
- `/api/public/map-points`
- `/api/public/resources`
- `/api/public/faq`
- `/api/public/settings`

Эти endpoints не отдают админские данные: ошибки, скриншоты, профили и audit log не раскрываются.

## Mobile Sync и аналитика

Для приложения определены отдельные endpoints:

- `GET /api/mobile/sync` — версионированный published-only governed runtime с ETag и условным HTTP 304.
- `POST /api/mobile/analytics/events` — прием событий аналитики из приложения.

Подробная инструкция для iOS лежит в `docs/mobile-sync-ios.md`.

## Резервное копирование PostgreSQL

Проект содержит скрипт переносимого dump через `pg_dump`. Наличие, расписание и восстановимость production-бэкапов — **NOT VERIFIED**:

```bash
DATABASE_URL='postgresql://...' pnpm backup
```

Файлы создаются в приватной папке `backups/`, не попадают в Git и по умолчанию хранятся 30 дней. Команду можно запускать ежедневно через cron/CI и копировать dump во внешнее зашифрованное хранилище. Восстановление сначала следует проверять на отдельной базе:

```bash
pg_restore --clean --if-exists --no-owner --dbname="$RESTORE_DATABASE_URL" backups/younew-TIMESTAMP.dump
```

## Деплой на Vercel

1. Создать Vercel project из папки `admin-dashboard`.
2. Добавить environment variables.
3. В Supabase Auth добавить домен Vercel в redirect URLs.
4. Выполнить deploy.

## Неподтверждённые production-возможности

- Реализовать и проверить полный CRUD для всех административных разделов; общая таблица сейчас read-only.
- Подключить реальные графики на основе `app_events` и `app_sessions`.
- Подключить iOS-приложение к `/api/mobile/sync` только после live-проверки DNS/TLS, rate limiting, мониторинга и rollback drill; `/api/mobile/analytics/events` требует отдельной privacy-проверки.
- Добавить полноценное рисование маркеров на скриншотах.
- Подключить настоящий предпросмотр Leaflet/MapLibre.
- Добавить server-side проверку ссылок по расписанию.
- Подключить OpenAI Vision API только после добавления ключа и явного включения AI-анализа.
