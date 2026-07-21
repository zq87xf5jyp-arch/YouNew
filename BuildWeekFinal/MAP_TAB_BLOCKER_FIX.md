# Map / root tab blocker

Recorded: 2026-07-21 (Europe/Amsterdam)

## Root cause

Корневой tab bar визуально находился поверх Map и имел более высокий `zIndex`, но это не делало области обработки событий физически непересекающимися. В compact/bottom layout `tabContent` размещался через `safeAreaInset`, тогда как корневой `ScrollView` экрана Map (`map.hub`) сохранял accessibility/hit-test frame на всю высоту окна: от `y = 0` до `y = 874`.

Из-за этого gesture arena карты продолжала участвовать в обработке касаний непосредственно под плавающим root tab bar. При повторном переходе Map → Home синтезированное нажатие могло попасть в рамку `tab.home`, но не дойти до tab-selection handler.

Это подтверждено артефактом до исправления:

- касание было синтезировано в точке `(53, 831)`, внутри рамки `tab.home` размером примерно `74 × 48.7 pt`;
- после касания `tab.map` оставался `Selected`;
- `root.tabNavigationMetric` оставался в состоянии `sequence=2;tab=map`, то есть обработчик выбора Home не выполнил commit;
- `map.hub` занимал frame `{{0, 0}, {402, 874}}`, включая область root tab bar.

Следовательно, причиной был не порог теста и не неверный expected value, а пересечение интерактивной области корневого Map `ScrollView` с областью root navigation.

## Why it was a product bug

Обычный пользователь мог нажать Home из Map и остаться на Map без смены выбранной вкладки. Это ломало основной demo flow и не было специфично для XCTest: тест лишь зафиксировал недоставленное нажатие и неизменившееся app-side состояние.

Высокий `zIndex`, `contentShape`, достаточный размер кнопки и корректная accessibility-рамка уже присутствовали. Они не гарантировали доставку события, пока gesture surface карты оставалась под tab bar. Поэтому обход в тесте, повторное нажатие или увеличение timeout скрыли бы реальный дефект.

## Changed files

- `YouNew/App/AppTabView.swift`
  - изменена только ветка compact/bottom layout корневого tab container;
  - `safeAreaInset` оставлен как неинтерактивный layout-reservation;
  - единственный интерактивный `horizontalMenu` перенесён в frontmost root overlay;
  - удалено ставшее неиспользуемым чтение `dynamicTypeSize`.

UI-тесты, expected values и coverage для этого исправления не изменялись.

## Implementation

Compact/bottom layout сохраняет исходный `safeAreaInset`, но его копия `horizontalMenu` теперь скрыта, недоступна accessibility и имеет `allowsHitTesting(false)`. Она служит только точным layout-reservation: поэтому предложенный размер Map, координаты маркеров, scroll geometry и нижние отступы остаются такими же, как до исправления.

Единственный интерактивный `horizontalMenu` размещён следующим root-level `.overlay(alignment: .bottom)`. Он использует прежний компонент, action, identifiers, размеры, отступы, `zIndex` и selection binding, но больше не находится в одной event-delivery плоскости с full-window gesture region, созданной `safeAreaInset` для Map `ScrollView`.

Два исследованных варианта не вошли в итоговый код:

- уменьшение реальной высоты `tabContent` устраняло overlap, но сдвигало map viewport и делало Leiden/Middelburg недоступными;
- parent `contentShape` сохранял layout, но вмешивался в доставку действий дочерних city controls.

Оба варианта были отброшены по результатам существующих тестов, а не подогнаны изменением expected values.

## Why the fix is safe

- Интерактивность самой карты не отключена; `.allowsHitTesting(false)` для Map не добавлялся.
- Province/city interaction surfaces и их gestures не изменялись.
- Переходы к провинциям и городам не переписаны.
- Floating AI control и его hit testing не изменены.
- `FloatingTabBar`, его кнопки и tab-selection logic не изменены.
- Геометрия bar и layout proposal Map не изменены: скрытая reservation-копия измеряется тем же компонентом.
- Скрытая копия не принимает касания и не попадает в accessibility tree; пользователь взаимодействует только с одной панелью.
- Исправление локализовано в одном layout branch; sidebar/vertical layout не затронут.

Оставшийся риск — композиция overlay на вторичных compact screens — проверяется root/map navigation suite и визуальным smoke, а не изменением тестов.

## Tests before

### Finalized full-suite evidence

- Bundle: `/private/tmp/YouNewCleanCloneEfd.20260720/FullUIFinal.xcresult`
- Result: 87 total; 84 passed; 3 failed; 0 skipped.
- Failure: `MapChipUITests/testRootTabNavigationLatency` — `Home destination must become visible on the first tap.`
- Экспортированная доказательная база: `BuildWeekFinal/artifacts/UI_MAP_TAB_FAILURE_EVIDENCE/`.
- Baseline и хеши артефактов: `BuildWeekFinal/UI_BASELINE.md`.

### Current-HEAD targeted run before the layout fix

- Bundle: `/private/tmp/YouNewBuildWeekCurrentPreFixMap.xcresult`
- Result: 1 test; 0 passed; 1 failed; 0 skipped.
- Нажатия в этом повторе доставлялись, но тест всё равно завершился FAIL: один app-side sample занял `110.095 ms` при существующем контракте `< 100 ms`.

Этот повтор не отменяет зафиксированный first-tap blocker из finalized bundle: дефект доставки был intermittent, а сохранённый hierarchy/event trace показывает его непосредственно.

## Tests after

Итоговый вариант проверен одним совместным целевым прогоном без изменения тестов:

- bundle: `/private/tmp/YouNewBuildWeekMapOverlayFix.xcresult`;
- 3 total; 3 passed; 0 failed; 0 skipped;
- `testMapCityMarkersOpenCityRoutes`: PASS — Leiden открыл working city map;
- `testProvincePickerExposesAllProvincesAndTheirCities`: PASS — Zeeland/Middelburg сохранили reachability и activation;
- `testRootTabNavigationLatency`: PASS — 10/10 Map ↔ Home transitions доставлены с первого нажатия;
- samples Home: `[94.1, 28.4, 29.2, 28.1, 29.8] ms`;
- samples Map: `[38.4, 34.0, 34.0, 31.8, 34.1] ms`;
- maximum: `94.1 ms` при неизменённом контракте `< 100 ms`;
- test duration: `67.097 s`; session duration: `73.277 s`.

Дополнительная последовательная проверка после targeted gate:

- `RootNavigationUITests`: 5/5 PASS;
- отдельный `testRootTabNavigationLatency`: PASS, 10/10 first-tap transitions, maximum `94.2 ms` при прежнем `< 100 ms`;
- 100-tap calibration, запуск 1: FAIL — 99 matched, 1 missed, 0 wrong; пропущен самый первый input до изменения `sequence`;
- тот же тест без изменения кода или порога, чистый повтор: PASS — 100 matched, 0 missed, 0 wrong, maximum app handling `5.053 ms`;
- оба calibration artifacts сохранены; наблюдение описывается как 199/200, а не как безусловные 200/200.

Artifacts:

- `/private/tmp/YouNewBuildWeekRootNavigationFinal_DD6314_20260721.xcresult`;
- `/private/tmp/YouNewBuildWeekRootLatencySerialFinal.xcresult`;
- `/private/tmp/YouNewBuildWeekMapCalibrationSerialFinal.xcresult`;
- `/private/tmp/YouNewBuildWeekMapCalibrationSerialRepeat.xcresult`.

Финальный полный UI suite завершён с результатом 79/87. В неизменённом
изолированном повторе latency-теста все переходы были доставлены, но один
app-side sample занял `191.158 ms` и нарушил существующий лимит `< 100 ms`.
Следовательно, исходный blocker доставки считается исправленным в проверенной
конфигурации, а performance-риск остаётся открытым. Результат нельзя описывать
как «all UI tests pass» или как универсальную sub-100-ms гарантию.

## Remaining limitations

1. Targeted PASS подтверждает исправление на iPhone 17 Pro / iOS 26.5, но не доказывает поведение на каждом device class.
2. Полный post-fix UI suite завершён: 79/87 PASS, 8 FAIL, 0 skipped. Последний изолированный latency-тест FAIL при `191.158 ms`; первый 99/100 calibration failure также остаётся раскрытым.
3. Accessibility Dynamic Type и secondary compact screens не входят в подтверждённую границу основного demo.
4. Временные `.xcresult` под `/private/tmp` являются локальными QA-артефактами. Для handoff сохраняется artifact manifest/summary; многогигабайтные bundles не следует коммитить.
