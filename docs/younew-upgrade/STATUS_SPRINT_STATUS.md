# YouNew 2.0 · P0 status · 15.11.2026

Область: достоверная страница `/status/`, отдельный Draft PR, без production.
Исходный main: `7e806340808b7c8476c9da5f88ec83470d674374`.
Ветка: `fix/younew-status-20261115`. После этого P0 работа останавливается.

## Использованные результаты SPRINT 0

Прочитаны [FEATURE_INVENTORY](https://github.com/zq87xf5jyp-arch/YouNew/blob/3ede1a7ba837b6745f1a9953d22cbb278c39fc8e/docs/younew-upgrade/FEATURE_INVENTORY.md),
[SPRINT_STATUS](https://github.com/zq87xf5jyp-arch/YouNew/blob/3ede1a7ba837b6745f1a9953d22cbb278c39fc8e/docs/younew-upgrade/SPRINT_STATUS.md),
[QA_REPORT](https://github.com/zq87xf5jyp-arch/YouNew/blob/3ede1a7ba837b6745f1a9953d22cbb278c39fc8e/docs/younew-upgrade/QA_REPORT.md) и
[ARCHITECTURE](https://github.com/zq87xf5jyp-arch/YouNew/blob/3ede1a7ba837b6745f1a9953d22cbb278c39fc8e/docs/younew-upgrade/ARCHITECTURE.md)
из [PR60](https://github.com/zq87xf5jyp-arch/YouNew/pull/60).
Их выводы повторно проверены по текущим публичным артефактам и Hostinger SSH.

## Результат P0

- Один основной `admin-dashboard/public-site/src/config/status.json` (schema 2).
  Публичная копия создаётся прежней командой `cp` в штатном `scripts/build.sh`.
- Удалены `SystemEvidence` и его отдельный августовский конфиг с устаревшими числами.
  История сохраняется в Git; прошлые отчёты не переписываются задним числом.
- Статический HTML и JSON выпускаются вместе. Клиентский fetch больше не подменяет
  проверенный HTML потенциально другой копией статуса после загрузки.
- Подтверждены 76 сущностей: 54 места, 17 кратких гидов, 5 городов, 0 полных гидов.
  Это не количество URL, документов поискового индекса или всех записей Admin.
- Разделены дата аудита, релиза редакционной партии, проверки источников и Apple release.
  Нет обещаний live monitoring, полевых CWV, проверенного ASC или равенства web/iOS.
- `/app/` и `/updates/` используют этот же JSON: исправлены только зависимые подписи,
  убрано неподтверждённое утверждение о submitted build. Функции и CTA сохранены.
- Существующая KnowledgeTrustSummary продолжает показывать автоматические governance
  gates и PARTIAL. Новый ручной реестр статусов или новая аналитика не создаются.

## Независимость от PR59/PR60

PR60 ещё не объединён с main. Пробная проверка `git merge-tree` обнаружила уже
существующий конфликт между PR59 и PR60 в сгенерированном `public/sw.js`.
Поэтому P0 подготовлен от main, без наследования главной PR60 и без слияния веток.
Этот отдельный файл обновляет историю спринтов, не создавая add/add-конфликт с
`SPRINT_STATUS.md`, который пока существует только в PR60.

Переиспользован точно такой же исправленный Admin CI workflow, как в PR59 и PR60:
официальный закреплённый Playwright image, прежние тесты и версия пакета. Новых
зависимостей и платных сервисов нет. Сгенерированные SW/служебные отчёты сохраняются
в проверенном артефакте, но их зависящий от запуска diff не включён в PR.
Production-пакет всегда нужно пересобирать штатно; публиковать исходную public-папку нельзя.

Проверки и откат: [STATUS_QA](STATUS_QA.md). Никакие PR не объединены и production
не развёрнут. Его августовский status останется видимым до отдельного разрешения
на выпуск. Следующий спринт не начат.
