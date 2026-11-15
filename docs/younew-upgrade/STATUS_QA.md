# P0 status — проверка 15.11.2026

Кандидат проверен локально и на защищённом Hostinger QA. Это не production release.
История спринта и независимость от PR59/PR60: [STATUS_SPRINT_STATUS](STATUS_SPRINT_STATUS.md).

## Фактическая исходная точка

Прямой HTTP и браузер подтвердили устаревшие 177/182, Sites v53 и Supabase в live
`/status/`. Они удалены из кандидата. Исторические документы и история Git сохранены.
Данные сверены повторно, а не приняты только из SPRINT 0: [STATUS_EVIDENCE](STATUS_EVIDENCE.json).

- Live `/data/content-provenance.json` и generated `public-content.json` имеют один
  fingerprint `32fb2435ffb84b46b7d0c2e3c2371a217b1bb5280e8aa13cff9bc394f8812e17`.
- 76 опубликованных entities = 54 place + 17 summary guide + 5 city; 0 full guides.
  71 non-city ID есть в live search index. Пять city routes отдельно проверены: HTTP 200
  и правильный заголовок. Географические search documents не приравниваются к entities.
- Source dates: 24.10, 09.11, 10.11.2026. Редакционный релиз: 10.11; аудит: 15.11.
- SSH: PHP 8.3.36, Node 24.22.3; существующий Node/MariaDB Admin и приватная очередь
  описаны в production-коде. Health 15.11 12:00 UTC: OK, public/login 200,
  private Admin 401, BUSINESS pending 0, последнее выполнение worker 11:55 UTC.
- Apple public lookup: версия 1.3, выпуск 03.08.2026. Это не authenticated ASC.
- ID comparison: 5 общих, 71 только web, 0 только iOS source bundle.
  Бинарник из App Store не извлекался и не проверялся.

## Проверки кандидата

| Проверка | Результат |
|---|---|
| `pnpm predeploy:check` | Все 10 этапов PASS: сборка, TS, ESLint, unit/schema, smoke, ссылки, security, package/404, governance, data health |
| Unit/schema | 248/248 PASS, включая 5 новых status regression tests |
| Регрессия | Числа и fingerprint против реального артефакта; source/release dates; ID sets web/iOS; static/PARTIAL/unknowns; штатная публичная копия |
| Smoke | HTML соответствует основному JSON: summaries, числа, даты, ограничения, ссылки; старые утверждения отсутствуют |
| Внутренние ссылки | 36 488 references/fragments/assets, 636 HTML, 608 sitemap routes; 0 ошибок |
| Отображение | Правильные URL/title, один H1, содержательный HTML, нет framework overlay |
| Мобильная версия | 1440×900, 390×844, 320×740; viewport = scrollWidth, нет горизонтального скролла |
| Действия | Status → App → release status; Enter на JSON → schema 2 и дата; Updates использует те же факты |
| Console | Чистая загрузка `/status/`: 0 error/warn. При Back из raw JSON один неблокирующий ViewTransition InvalidStateError; подробности ниже |
| Hostinger QA | 8 URL, точные SHA, HTTP 200, noindex/no-store; анонимные status/JSON/app → 401 |
| Откат QA | Точные прежние pointer, homepage и Г01 EN/NL восстановлены; снова активен `hp-seo-review-20261111-r6` |
| Границы | iOS, каталог, главная, зависимости, DB/cron/DNS/mail и production не изменены |

Browser: CUA. Превью: http://127.0.0.1:8813/status/ пока работает локальный сервер.
Артефакт QA: `hp-status-20261115-r1`, SHA-256
`0a9ce7e943cad7c7b7a3fd5afb0e3f03b0a7a00e38cc2031e792ac21209969ee`.
Полные логи, manifest 1428 файлов, скриншоты и приватные config hashes находятся вне Git:
`/Users/ivan/YouNew-Status-Evidence-2026-11-15/`.

Существующие GitHub workflows выполняются для точного head Draft PR. Их итоговые
ссылки и статусы сохраняются в PR и `CI_FINAL.json`; результаты прежних PR не
подменяют новый CI. Ночная network source-health задача выполняется по расписанию,
её отсутствие в PR не означает, что все внешние ссылки проверены.

## Найденное во время проверки

- Первый build обнаружил использование старых testedVersion/testedBuild на `/app/`.
  Зависимые подписи обновлены; неподтверждённый App Review claim удалён.
- Первая smoke-проверка ошибочно ожидала lower-case `datetime` в сыром React HTML.
  Проверка сделана нечувствительной к регистру атрибута; финальный полный прогон PASS.
- При возврате Back из raw JSON браузер записал `InvalidStateError: Transition was
  aborted ... Page already revealed`. Существующий глобальный CSS включает
  `@view-transition { navigation:auto; }`. JSON открылся, возврат и страница работали;
  новая чистая загрузка status не воспроизвела ошибку. Глобальная анимация и дизайн
  не менялись в этом P0; наблюдение не скрыто как «нулевой console на всех переходах».

## Не подтверждено

Live uptime monitoring на этой странице отсутствует; полевые CWV, authenticated
App Store Connect, содержимое shipped iOS binary, полный внешний link crawl и
повторный authenticated Admin E2E в production не проверены. Read-only health не
доказывает готовность всех функций. PARTIAL остаётся видимым.

## Сборка и откат

Единственный редактируемый snapshot: `src/config/status.json`. Schema 2 удаляет
неподтверждённые testedVersion/testedBuild, добавляет source comparison и provenance.
Неизвестных внешних потребителей JSON не проверяли; внутренние потребители обновлены.
`public/data/status.json` получен штатной сборкой. SW и служебные отчёты генерируются
при каждой сборке; их временные изменения не коммитятся и не конфликтуют с PR59/60.

Production не выкладывался: откат production не нужен. QA-оператор сохранил исходный
pointer и восстановил его в `finally`, сравнив прежние тела homepage и Г01 EN/NL.
Для отката кода вернуть P0 commit через review и пересобрать прежний main; хранить
HTML и JSON одним артефактом, не редактировать публичную копию отдельно.
