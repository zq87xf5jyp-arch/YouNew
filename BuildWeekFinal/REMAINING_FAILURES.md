# Remaining failures and verification status

Recorded: 2026-07-21 (Europe/Amsterdam)
Candidate: `main` at `7a1f6bc8fcffac84e5798338380bb97aca815b3d`, dirty workspace

## Итог

Критический Map → root-tab blocker доставки нажатия исправлен в проверенной
конфигурации. Финальный full UI suite, однако, не зелёный: **79/87 PASS**, а
неизменённый изолированный повтор восьми failures дал **5/8 PASS**. Три UI-сбоя
воспроизводятся и остаются открытыми. Static QA имеет **43/44** PASS из-за 18
подтверждённых broken governed URLs.

Targeted PASS не заменяет aggregate, а product delivery и latency учитываются
раздельно.

## Текущая таблица

| Приоритет | Область | Текущий результат | Решение для candidate |
|---:|---|---|---|
| 1 | Map → root tab delivery | FIXED: 10/10 serialized first-action transitions и manual Map → Home PASS | Оставить в demo; остановить запись, если первый тап не доставлен |
| 2 | Guide composite route | FAIL: после исправленного First Steps marker длинный тест воспроизводимо зависает на UI query при прокрутке к Transport | Исключить длинный Guide → Transport composite из demo |
| 3 | Root-tab latency | FAIL: все переходы доставлены, один sample `191.158 ms` при контракте `<100 ms` | Не заявлять универсальную sub-100-ms стабильность |
| 4 | Assistant selected city | FAIL: **Open Leiden** не достигает city detail | Не использовать shortcut; открыть city через Map/Home/Search |
| 5 | External link health | FAIL: 18 confirmed broken из 2,494 URL | Предварительно проверить ровно один источник для записи |
| 6 | Aggregate-only UI failures | 5 из 8 исходных failures прошли без изменения тестов в isolated rerun | Сохранять aggregate 79/87; не подменять его 5/8 |

## 1. Navigation blockers

### Map / root tab

Исходный product bug был вызван пересечением full-window gesture surface Map с
корневой tab bar, размещённой через `safeAreaInset`. Исправление в
`YouNew/App/AppTabView.swift` оставляет неинтерактивную reservation-копию для
геометрии и переносит единственную интерактивную панель в frontmost root overlay.
Карта, province/city routes, AI overlay, expected values и test coverage не
ослаблены.

Подтверждение доставки:

- targeted map/navigation bundle: 3/3 PASS;
- `RootNavigationUITests`: 5/5 PASS;
- serialized latency test: 10/10 first-action transitions PASS;
- manual Computer Use Map → Home: `sequence=1;tab=home;delayMs=95.108`;
- calibration: 99/100, затем неизменённый повтор 100/100.

Открытый риск: в последнем isolated rerun `testRootTabNavigationLatency` все
нажатия дошли, но один app-side sample занял `191.158 ms`. Это performance
failure, не повтор исходного event-delivery failure.

### Guide composite routing

Первоначальный failure выглядел как неверный переход Getting Started. Ручная
проверка и artifact показали, что экран First Steps открывался правильно, но
маркер `firstSteps.screen` отсутствовал в accessibility tree. В
`YouNew/Views/FirstStepsView.swift` маркер локально перенесён на видимый hero без
группировки всего длинного ScrollView.

После этого неизменённый тест проходит First Steps, detail и back, затем
воспроизводимо зависает при запросе Guide UI после прокрутки к Transport:
`Failed to get matching snapshots: Timed out while evaluating UI query`.
Повтор после чистого старта Simulator дал тот же результат. Большая перестройка
Guide под дедлайн не выполнялась; путь исключён из demo.

### Assistant selected-city shortcut

`Open Leiden` не достигает `city.detail.leiden` в isolated workflow. Два узких
варианта `NavigationLink` были проверены, не дали доказанного улучшения и были
откачены. Тест и expected destination не менялись. Базовый BSN/address/DigiD
assistant flow остаётся частью demo; city detail открывается через Map/Home или
Search.

## 2. Aggregate failures, прошедшие отдельно

В полном suite дополнительно падали leisure/education route, discovery route,
transport route, published-city traversal и assistant health guide. Все пять
прошли без изменения тестов в едином isolated rerun восьми failures. Это
указывает на suite-level state/timing sensitivity, но не доказывает, что дефекты
исчезли из aggregate. Публичный результат остаётся **79/87**, а 5/8 — только
дополнительное диагностическое evidence.

## 3. Unit, crashes и data safety

- Clean build: PASS.
- Unit: **460/460 PASS**, 0 failed, 0 skipped.
- В финальных артефактах не зафиксирован crash или data corruption; это не
  универсальная гарантия отсутствия таких дефектов.
- Structural DataProject/import: PASS — 17 work packages, 7 milestones,
  7 releases, 27 batches, 450 records.
- `cities-v0.1.0`: 5/5 — Amsterdam, Rotterdam, Den Haag, Utrecht, Eindhoven.
- Scoped secret scan: 1,039 files, 23,040,033 bytes, 0 high-confidence hits.
- Current link health: 2,494 checked, 1,821 reachable, 18 confirmed broken,
  623 restricted, 32 transient.

Structural import PASS нельзя объединять с link-health FAIL в утверждение
«all data validation passes».

## 4. Исправления, подтверждённые отдельно

- Judge-facing Guide placeholder заменён атомарным content snapshot и честным
  fallback; targeted runtime и applicable static check PASS.
- Декоративный input outline исключён из hit testing; search focus прошёл 5/5
  targeted repetitions.
- City cafes route не менялся: три независимых targeted запуска и отдельный
  discovery route PASS. Без доказанной причины speculative routing fix не вносился.

## Ограничение заявки

Использовать только bounded flow:

`Home → local Assistant → BSN → address → DigiD → BSN guide/source → Map → Home → city detail via Map/Home`.

Не использовать Assistant **Open Leiden** и длинный Guide → Transport composite.
Не заявлять `all tests pass`, production readiness, live OpenAI/GPT-5.6,
универсальную sub-100-ms навигацию или здоровье всех внешних ссылок.

Артефакты и точные числа приведены в
[`../BuildWeekSubmission/FINAL_VALIDATION.md`](../BuildWeekSubmission/FINAL_VALIDATION.md).
