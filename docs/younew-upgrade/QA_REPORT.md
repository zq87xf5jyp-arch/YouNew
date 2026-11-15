# QA SPRINT 0 + ограниченный шаг 1

Дата: 15.11.2026. Статус: локальная и Hostinger QA приёмка PASS; не production release.

## До изменений

- main `7e806340808b7c8476c9da5f88ec83470d674374`, чистое дерево перед генераторами.
- `pnpm --dir admin-dashboard/public-site test`: **243/243 PASS**.
- Предыдущая независимая SEO-ветка: 260/260 PASS; generated delta теста сохранена
  вне репозитория и возвращена к HEAD перед переключением. Редакционные файлы не менялись.
- 12 прямых HTTP-проверок: 11 HTML и sitemap — HTTP 200; workspace следует redirect
  на pilot. Все шесть обязательных URL задания включены.
- SSH PHP 8.3.36 / Node 24.22.3; health OK, outbox 0; QA pointer r6.
- Browser/CUA: production homepage 1440×900 и 390×844, Local services category с 9 местами.

## Приёмка изменения

| Проверка | Фактический результат |
|---|---|
| `pnpm predeploy:check` | PASS, все 10 этапов: build, TS, ESLint, 243 unit/schema, smoke, ссылки, security, package/404, governance, source health |
| Внутренние ссылки | 36 493 references/fragments/assets, 636 HTML, 608 sitemap URL, 0 ошибок |
| Первый прогон | 242/243: старый тест требовал organizations. Обновлено ожидаемое направление на существующую наполненную категорию; полный повтор PASS |
| Идентичность/рендер | EN/NL заголовки и lang, один H1, содержательные страницы, без framework overlay |
| Мобильный вид | EN/NL 390×844; NL 320×740; viewport = scrollWidth, нет горизонтального скролла; ссылки ≥44 px |
| Клавиатура | Tab переводит focus между быстрыми ссылками; видимая сплошная обводка 2 px; Enter на Eten & drinken открывает правильную NL-категорию |
| Тема | Светлая и тёмная версии, 1440 px; существующие цветовые переменные, без overflow; после теста возвращена светлая тема |
| Музей | Главная → Places & culture → Museum De Lakenhal → официальный `https://www.lakenhal.nl/en/`, реальная новая вкладка + HTTP 200; источник/даты видны |
| Город | Главная → Rotterdam → Chabot Museum: правильная карточка и источник; старый ошибочный breadcrumb Leiden отдельно записан в inventory |
| Поиск | Главная: Lakenhal → 3 полезных результата; URL `/search/` без поисковой фразы |
| Save | Save Museum De Lakenhal → pressed/Saved → переход на `/saved/` показывает сохранённое место; только localhost origin |
| NL Local services | `Ontdek op interesse` → `Lokale diensten` → `/nl/categorieen/local-services/`, 9 опубликованных items |
| Console | В пройденных сценариях relevant error/warn = 0 |
| Hostinger | 18 точных HTML checks: 200, SHA соответствует локальному артефакту, noindex + no-store; 3 анонимных URL → 401 |
| Откат QA | Восстановлены точные исходные pointer/home/G01 EN/NL; `hp-seo-review-20261111-r6` снова активен |
| Объём | EN HTML gzip 15 176 → 15 589 байт; NL 15 867 → 16 316; script tags 9 → 9. Это сравнение файлов, не полевые CWV |
| Контент/зависимости | Данные мест, источники, даты, медиа, IDs и routes не изменены; нет новых пакетов/API |

CI для новой ветки выполняет существующие репозиторные workflows. Его актуальный
статус относится к точному SHA в PR, а не автоматически к зелёному прогону PR59.
Финальный результат сохраняется в PR и отдельном `CI_FINAL.json` evidence.

Санитизированные доказательства: [inventory](inventory-baseline.json),
[QA Hostinger](hostinger-qa.json), [Apple](apple-public-lookup.json),
[размеры HTML](payload-comparison.json). Browser: CUA, без внешнего браузерного fallback.
Превью: http://127.0.0.1:8812/ и http://127.0.0.1:8812/nl/ пока работает локальный сервер.

## Границы

Полный authenticated Admin/iOS UI, App Store Connect, все внешние ссылки, все экраны
и WCAG 2.2 AA целиком **NOT VERIFIED** в этом спринте. Полевые LCP/INP/CLS N/A.
Августовский status — известная неподтверждённая современным состоянием поверхность,
не скрывать её за общим PASS.

## Откат

Два UI-файла и ожидание теста можно вернуть из base commit и пересобрать штатный SW;
данные/схемы не затронуты. Ветка PR59 и его QA r6 сохраняются. QA-кандидат
`hp-upgrade-20261115-r1` хранится неизменяемым, но не активен после проверки.
Архив SHA-256: `f571dc8bda2fe537490e817f06a7ae064eb41744c8f5600bcf3a76dfe22d9498`.
Оператор с `finally` вернул предыдущий pointer; backup pointer сохранён в приватном
`upgrade-20261115-r1/qa-pointer-before.json`. В production ничего не отправляется. Evidence:
`/Users/ivan/YouNew-Upgrade-Evidence-2026-11-15/`.
