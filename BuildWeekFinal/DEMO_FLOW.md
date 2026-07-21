# Build Week demo flow

Статус документа: **candidate script; bounded flow verified, full UI aggregate 79/87**
Evidence cutoff: 2026-07-21, Europe/Amsterdam  
Рекомендуемый язык записи: English — он совпадает с проверяемыми ниже подписями.

## Truth boundary

В этом сценарии показывается существующий **local guided assistant**: детерминированный workflow `BSN → наличие адреса → DigiD`, реализованный в `AIWorkflowEngine` и дополненный индексированными материалами приложения. Ответ должен иметь видимую маркировку **Local guide mode** (`assistant.response.origin.localGuide`).

Это не демонстрация live OpenAI и не доказательство GPT-5.6. Не произносить и не выводить в титрах `powered by GPT-5.6`, `live OpenAI assistant` или `generative AI answer`. Не вводить настоящий BSN, полный адрес, номер паспорта, DigiD-коды или другие персональные данные.

Основные источники сценария:

- [`AIWorkflowEngine.swift`](../YouNew/Services/AIWorkflowEngine.swift) — локальные вопросы об адресе и DigiD;
- [`AIResponseComposer.swift`](../YouNew/Services/AIResponseComposer.swift) и [`KnowledgeIndex.swift`](../YouNew/Services/KnowledgeIndex.swift) — структурированный поиск и сборка ответа;
- [`YouNewUITests.swift`](../YouNewUITests/YouNewUITests.swift) — UI-контракт `testAssistantBSNWorkflowExposesMunicipalityDocumentsGuideAndSource`;
- [`GuideContentView.swift`](../YouNew/Views/GuideContentView.swift) — BSN guide и блок официальных источников;
- [`PublishedCitiesRuntimeUITests.swift`](../YouNewUITests/PublishedCitiesRuntimeUITests.swift) — runtime-контракт пяти опубликованных городов.

Внутренние accessibility identifiers ниже приведены для воспроизводимости и QA. Пользователь видит локализованные подписи, а не сами identifiers.

## Preconditions

Перед записью:

1. Использовать только финальный candidate build после успешного targeted map/root-tab теста.
2. Запустить приложение в English, с обычным Dynamic Type и без debug overlays.
3. Убедиться, что root tab bar показывает Home, Guide, Map, Saved и More.
4. Очистить старый диалог кнопкой `assistant.clearConversation`, если он мешает чистому сценарию; не применять скрытые тестовые маршруты в публичном видео.
5. Сеть не обязательна для assistant workflow. Для фактического открытия внешнего сайта нужна сеть; отсутствие сети не следует маскировать.
6. Начальный город может быть любым. В конце сценарий явно выбирает Amsterdam из `cities-v0.1.0`.

## Exact sequence

| # | Действие пользователя | Ожидаемый экран или результат | Проверяемый UI contract |
|---:|---|---|---|
| 1 | Открыть YouNew. | Видна Home с карточкой текущего города и постоянным root tab bar. | `screen.home`, `tab.home`, `root.tabBar` |
| 2 | Нажать кнопку со sparkles в поисковой строке Home — **Open AI assistant**. | Открывается assistant внутри Home navigation stack; доступны поле и Send. | `home.aiButton` → `assistant.input`, `assistant.send` |
| 3 | Ввести ровно **How do I get BSN?** и нажать **Send**. | Локальный workflow спрашивает: **Do you already have a fixed address in the Netherlands?** | `assistant.response.structured`, `assistant.response.origin.localGuide`, `assistant.quickAction.askFollowUp.yes.address` |
| 4 | Нажать **Yes, fixed address**. | Появляется второй детерминированный вопрос: **Do you want to set up DigiD after BSN?** | `assistant.quickAction.askFollowUp.yes.digid` |
| 5 | Нажать **Yes, include DigiD**. | Появляется структурированный результат: сначала регистрация в gemeente/BSN и документы, затем DigiD через официальный источник. Видны действия для municipality, documents, BSN guide и official source. | `assistant.response.structured`, `assistant.response.origin.localGuide`, `assistant.quickAction.openScreen.government`, `assistant.quickAction.openScreen.journeydocuments`, `assistant.quickAction.openGuide.article.documents.bsn`, префикс `assistant.quickAction.openSource.` |
| 6 | На 2–3 секунды задержаться на бейдже **Local guide mode**, результате и quick actions. | Зрителю ясно, что это локальный структурированный workflow, а не live LLM. | `assistant.response.origin.localGuide` |
| 7 | Нажать **Open BSN Guide**. Если действие ниже видимой области, сначала прокрутить ответ. | Открывается статья **BSN - citizen service number**. | `assistant.quickAction.openGuide.article.documents.bsn` → `guide.article.bsn` |
| 8 | Прокрутить статью до **Official sources** и показать карточку **BSN - Rijksoverheid**. При стабильной сети можно открыть её и сразу вернуться в YouNew системной кнопкой Back. | В приложении виден именованный официальный источник; при открытии домен должен быть `rijksoverheid.nl`. | `guide.article.sources.dashboard`; источник задан в `GuideContentView.swift` как `bsn-gov` |
| 9 | Нажать root tab **Map**. | Открывается интерактивная карта Нидерландов с province/city selectors. | `tab.map` → `map.hub`, `places.premiumNetherlandsMap`, `map.provinceInteractionSurface` |
| 10 | В province selector выбрать **North Holland**; при необходимости сдвинуть горизонтальный ряд. Затем нажать **Amsterdam**. | Выбор города открывает рабочий MapKit city map и обновляет выбранный город на Amsterdam. Жесты карты остаются доступны. | `places.provincePicker.noord-holland` → `map.city.amsterdam` → `places.mapMode` |
| 11 | Не делая повторного нажатия, один раз нажать root tab **Home**. | Home появляется с первого нажатия. Это непрерывное доказательство устранения map/tab blocker; выбранным городом остаётся Amsterdam. | `tab.home` → `screen.home`; `home.currentCity` содержит `Amsterdam` |
| 12 | Нажать карточку текущего города **Amsterdam**. | Открывается детальная страница одного из пяти импортированных городов, с hero и связанными материалами/официальными источниками. | `home.currentCity` → `city.detail.amsterdam`, `city.hero.image`, `city.relatedArticles.dashboard` |

## Expected story for the judge

1. YouNew начинается с практического Home, а не с технического экрана.
2. Assistant уточняет контекст вместо выдачи одного универсального ответа.
3. Ответ явно обозначен как локальный и ведёт в существующий guide и к официальному источнику.
4. Root navigation связывает knowledge flow с интерактивной картой.
5. Выбор Amsterdam на Map переносится в Home и открывает typed city detail.
6. Показанный город относится к внутреннему governed release `cities-v0.1.0`; это не утверждение об App Store release.

## Known limitations

- Live OpenAI/GPT-5.6 runtime не подтверждён и не является частью этого demo flow.
- Assistant даёт общую ориентацию, а не юридическое, медицинское или индивидуальное решение. Важные действия нужно проверять у официального источника и своей gemeente.
- Внешний сайт зависит от сети и может менять содержимое, редиректы или доступность. Последний data-health report имеет статус `attention_required` и отдельно фиксирует 18 confirmed broken governed URLs; поэтому нельзя утверждать, что все внешние ссылки здоровы.
- `cities-v0.1.0` подтверждает пять внутренних city records, но не одинаковую глубину контента по всем городам.
- Map/root-tab delivery подтверждён targeted-проверками: blocker gate 3/3, root navigation 5/5, isolated 10/10 и один manual accessibility action PASS. При этом отдельный финальный latency-тест зафиксировал 191.158 ms при неизменённом лимите `<100 ms`; это открытый performance-риск, а не повтор исходного недоставленного нажатия.
- Не использовать в записи Assistant shortcut **Open Leiden**: в изолированном тесте он не достигает city detail. Не использовать и длинный composite Guide → Transport, который воспроизводимо зависает на UI query после прокрутки.
- Контент и media rights не завершены для всего приложения; этот сценарий не доказывает production readiness или полную лицензионную очистку.

## Fallback path

Fallback нужен для прозрачной демонстрации, а не для сокрытия дефекта.

- **Assistant action ниже экрана:** прокрутить текущий assistant response; не менять запрос и не запускать другой сценарий.
- **Старый диалог мешает:** вернуться и использовать видимую Clear conversation, затем повторить последовательность с начала.
- **Внешний источник не открывается из-за сети:** оставить на экране in-app блок `Official sources`, произнести «external opening is network-dependent» и продолжить. Не показывать кэшированную или подменённую страницу как live proof.
- **North Holland не виден:** сдвинуть `places.provincePicker` до North Holland либо открыть `map.cityMenu` и выбрать Amsterdam после выбора провинции.
- **City Map открыт, но Home ещё показывает прежний город:** подождать завершения обычной анимации интерфейса, затем сделать один тап Home. Не использовать artificial sleep в тестах и не делать двойной тап в видео.
- **Map не отдаёт первый тап root tab:** остановить запись, сохранить evidence и считать candidate незавершённым. Не делать монтаж, который скрывает повторный тап.
- **Amsterdam detail не открылся из Home:** fallback для диагностики — Guide → Search → `Amsterdam` → result `search.directResult.link.city.amsterdam`; это не заменяет обязательную проверку map-to-root-tab перехода.

## Screen-recording checklist

Перед нажатием Record:

- [ ] Финальный build и commit/hash записаны отдельно в validation report.
- [ ] Нет уведомлений, персональных данных, debug labels, test launch arguments или секретов.
- [ ] Язык English; интерфейс и клавиатура читаемы.
- [ ] Assistant conversation пустой.
- [ ] Сеть либо проверена для optional external-source step, либо заранее выбран честный in-app-only вариант.
- [ ] Map/root-tab targeted test уже PASS на том же candidate snapshot.

В непрерывном основном дубле:

- [ ] Показаны Home и `home.aiButton`.
- [ ] Введён только синтетический запрос `How do I get BSN?`.
- [ ] Показаны оба выбора: fixed address и include DigiD.
- [ ] Бейдж **Local guide mode** читаем не менее двух секунд.
- [ ] Показаны structured result и BSN guide action.
- [ ] Показаны BSN guide и именованный официальный источник.
- [ ] Показана интерактивная Map и выбор North Holland → Amsterdam.
- [ ] Переход Map → Home выполнен одним видимым нажатием без склейки.
- [ ] На Home виден Amsterdam, затем открыт `city.detail.amsterdam`.

Перед публикацией видео:

- [ ] Нет титров `GPT-5.6 powered`, `all tests pass`, `production ready` или `fully licensed`.
- [ ] Нет TestFlight/App Store кадров без ручного подтверждения владельца.
- [ ] Все показанные изображения входят в owner-approved media allowlist; спорные кадры заменены или исключены.
- [ ] Видео проверено со звуком и без раскрытия имени устройства, Apple ID, email, токенов или локальных путей.
