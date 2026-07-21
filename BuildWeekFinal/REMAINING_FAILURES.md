# Frozen verification status

Recorded: 2026-07-21 (Europe/Amsterdam)

## Reading this report

Здесь разделены четыре состояния: подтверждённый дефект, исправленный дефект с targeted evidence, failure без повторного воспроизведения и проверка без текущего результата. Исторический PASS не заменяет текущий результат, а прерванный тест не считается ни PASS, ни FAIL.

Build Week packaging freeze не добавляет новых runtime-прогонов. Поэтому aggregate post-fix числа здесь нет; это честная граница evidence, а не подтверждённый дефект основного demo.

## Status summary

| Area | Baseline evidence | Current evidence | Demo/release relevance | Status |
|---|---|---|---|---|
| Map → root tab delivery | Finalized failure: первое нажатие Home не доставлено | Итоговый targeted bundle: 10/10 Map ↔ Home transitions с первого нажатия | Критично для основного demo | Fixed; targeted-verified |
| Map/root-tab latency | Targeted pre-fix sample `110.095 ms` при лимите `< 100 ms` | Итоговый targeted run: max `94.1 ms`, тест PASS при неизменённом `< 100 ms` | Deterministic UI gate | Targeted PASS; no all-device claim |
| Guide placeholder copy | Baseline: видимое `Verified materials will appear here` / `will appear here` | Targeted test 1/1 PASS; applicable static completeness check PASS | Judge-facing primary surface | Fixed and targeted-verified |
| Accessibility search focus | Baseline: typing event не доставлен, потому что search field не получил keyboard focus | 5/5 последовательных повторов PASS после исключения декоративного input outline из hit testing | Важно для accessibility и demo search | Fixed in targeted verification |
| City cafes typed route | Baseline: открылся неверный detail `category.list.cafes.leiden` | Без изменения routing code: 3/3 независимых targeted runs PASS; discovery route 1/1 PASS | Не входит в основной demo | Not reproduced; no speculative code change |
| Deep content scrolling | Control run прерван без outcome после старта теста | Исторический focused run: 1/1 PASS; post-fix outcome отсутствует | Не входит в основной demo | Evidence limitation, not a confirmed blocker |

## 1. Navigation blockers

### Map / root tab

Причина, изменение и доказательства подробно зафиксированы в `BuildWeekFinal/MAP_TAB_BLOCKER_FIX.md`.

Что закрыто: интерактивный tab bar вынесен из `safeAreaInset` в frontmost root overlay, а исходный safe-area proposal сохранён неинтерактивной reservation-копией. Совместный targeted bundle `/private/tmp/YouNewBuildWeekMapOverlayFix.xcresult` прошёл 3/3: Leiden route, Zeeland/Middelburg route и root-tab latency/delivery.

В `testRootTabNavigationLatency` доставлены 10/10 переходов с первого нажатия; maximum app-side sample `94.1 ms` при неизменённом контракте `< 100 ms`. Это закрывает целевой blocker в проверенной конфигурации, но не заменяет расширенный map/root или полный UI suite.

Решение для demo: путь Map → Home включён в основной сценарий. Не использовать публичное утверждение о гарантированной sub-100-ms навигации на всех устройствах.

### City cafes typed route

Baseline failure: `CategoryRoutingRuntimeUITests/testEveryCityScopedCategoryListReachesItsTypedDetailAndReturns` открыл `category.list.cafes.leiden`, не совпавший с ожидаемым typed destination.

Routing code для этого случая не менялся. Три независимых targeted запуска прошли, также отдельный discovery-route запуск прошёл 1/1:

- `/private/tmp/YouNewBuildWeekCafeRoutePostFix1.xcresult`;
- `/private/tmp/YouNewBuildWeekCafeRoutePostFix2.xcresult`;
- `/private/tmp/YouNewBuildWeekCafeRoutePostFix3.xcresult`;
- `/private/tmp/YouNewBuildWeekCafeDiscoveryRoute.xcresult`.

Вывод: исходный failure реален как наблюдение baseline, но точная product root cause не доказана и повторно не воспроизведена. Без доказанной причины менять route mapping или expected value рискованно. Код оставлен без изменения; для основного BSN → address → DigiD demo этот city/category путь не требуется.

## 2. Crashes and data corruption

В текущем частичном UI baseline не зафиксированы crashes или data corruption. Это ограниченное утверждение только о наблюдавшихся тестах; оно не является доказательством отсутствия таких дефектов во всём приложении.

Текущий unit suite прошёл 460/460. Структурные DataProject/import проверки также прошли, включая dry-run `cities-v0.1.0` для 5/5 городов. Scoped secret scan не обнаружил high-confidence секретов.

Отдельный fresh external-link check остаётся красным: 18 подтверждённых HTTP 404 из 2 494 URL. Поэтому нельзя объединять структурный import PASS и сетевую health-проверку в одно утверждение «all data passes».

## 3. Broken primary demo flow

### Guide unfinished placeholder

Причина: `RootGuideView` хранил popular и recently-updated данные в двух изначально пустых массивах. Пока асинхронная загрузка не завершилась, оба раздела отображали текст о материалах, которые «появятся здесь». Автоматическая проверка корректно считала эту judge-facing фразу незавершённым контентом.

Локальное изменение в `YouNew/Views/RootGuideView.swift`:

- введён единый optional `GuideContentSnapshot`, который публикуется атомарно;
- до загрузки показывается честное состояние `Loading verified guides…`;
- если подтверждённых элементов действительно нет, показывается действующая ссылка на каталог официальных источников;
- заполненные sections и destinations сохранены.

Проверка:

- `ContentCompletionRuntimeUITests/testPrimaryTabsRenderCompletedSurfacesWithoutPlaceholderCopy`: 1/1 PASS;
- artifact: `/private/tmp/YouNewBuildWeekContentPrimaryPostFix.xcresult`;
- соответствующая static completeness проверка: PASS.

Это точечное исправление judge-facing состояния, а не маскировка строки: fallback ведёт к существующему разделу официальных источников.

## 4. Accessibility blockers

### Search field focus / overlay delivery

Baseline failure: `AccessibilityRuntimeUITests/testAccessibilityTextSizeKeepsSearchUsable` не смог синтезировать ввод, потому что search field и его descendants не имели keyboard focus.

После того как декоративный `RoundedRectangle.stroke` в общем `AppInputModifier` был явно исключён из hit testing, targeted тест был выполнен с пятью повторениями и прошёл 5/5:

- artifact: `/private/tmp/YouNewBuildWeekAccessibilitySearchPostFix.xcresult`;
- simulator: iPhone 17 Pro, iOS 26.5.

Пять последовательных PASS подтверждают исправленную доставку focus в targeted конфигурации. Этот результат не расширяется до claim «все accessibility tests проходят».

## 5. Deterministic test failures

### Root-tab latency targeted gate is green

`MapChipUITests/testRootTabNavigationLatency` сохранил лимит `< 100 ms` для каждого app-side sample и прошёл в итоговом targeted bundle с maximum `94.1 ms`. Ранее наблюдавшиеся `110–157 ms` остаются частью диагностической истории и показывают, почему нельзя обобщать targeted PASS на все среды.

### Deep-scroll test has no current verdict

`ContentCompletionRuntimeUITests/testRequiredContentSurfacesStayCompletedWhileScrolling` был начат в control run, но orchestration была прервана до XCTest outcome. Он не является failure и не является pass.

Исторический focused bundle `/private/tmp/YouNewFocusedUIAfterSyncFix.20260721/FocusedUI.xcresult` содержит PASS этого теста, но в том же bundle другой тест failed. Исторический focused PASS полезен как сигнал, однако не заменяет текущую post-fix проверку.

Статус заморожен как ограничение evidence. Этот вторичный путь не является подтверждённым blocker основного demo и не запускает новый QA-цикл.

## 6. Cosmetic and secondary issues

Новые косметические исправления по результатам этих targeted запусков не выполнялись. Приоритет остаётся у основного demo flow, доставки navigation events, accessibility focus и честных content states. Вторичные экраны не следует перерабатывать без воспроизводимого blocker.

## Frozen limitations

- Полного post-fix UI aggregate нет; targeted results остаются targeted.
- Deep-scroll не имеет текущего post-fix outcome, но не входит в основной demo.
- Static QA имеет 43/44 известных PASS; единственный FAIL относится к 18 governed broken links.
- Structural Data/import и bounded secret scan завершены в ранее зафиксированной границе.
- Новые runtime, visual, accessibility или performance проверки в Build Week packaging scope не требуются.

## Honest current conclusion

- Критический дефект недоставленного первого нажатия Map → root tab устранён и подтверждён итоговым targeted тестом: 10/10 transitions, 3/3 map/navigation tests PASS.
- Latency assertion в итоговом targeted artifact зелёный: maximum `94.1 ms` при неизменённом `< 100 ms`; это не all-device гарантия.
- Judge-facing Guide placeholder исправлен и прошёл targeted + static проверку.
- Accessibility search прошёл 5/5 targeted repetitions.
- Cafe routing failure не воспроизведён в трёх независимых route-повторах и одном discovery-повторе; код без доказанной причины не менялся.
- Unit suite: 460/460 PASS. Static QA: 43/44 известных PASS; единственный FAIL — 18 governed broken links.
- Structural DataProject/import: PASS; fresh external link-health: FAIL с 18 подтверждёнными 404.
- Deep-scroll и полный UI suite не имеют текущего post-fix aggregate результата; это раскрыто как limitation, а не как подтверждённый critical blocker.
