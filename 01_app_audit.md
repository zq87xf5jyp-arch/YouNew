# YouNew Guide — полный аудит информационной архитектуры

Дата: 2026-07-11. Метод: статическая инвентаризация Swift-кода и данных, запуск `scripts/run-static-qa.sh`, визуальная проверка установленной сборки в iOS 26.5 Simulator и анализ существующих QA-материалов. Исходный код не изменялся. Существующие незакоммиченные изменения пользователя сохранены.

## Итог

Общая оценка: **5.2/10**. Полезного контента много, но продукт пока организован как несколько параллельных каталогов. Главный дефект — отсутствие единого канонического владельца материала на уровне данных и маршрутов.

Статические проверки прошли почти полностью, но `PERSONA IA STATIC QA` упал: маршруты Guide не фильтруются по активной persona. Это одновременно выявляет более важное противоречие: `IAUserMode.allowedSections` в `InformationArchitecture.swift` скрывает целые разделы от части аудиторий, хотя требование продукта допускает только сортировку и рекомендации.

Runtime: установленная сборка `YouNew` на iOS 26.5 после запуска оставалась на чёрном экране не менее 5 секунд. Статус: **confirmed для установленной сборки**, но причина не установлена без успешной пересборки и логов. Сборка из рабочей копии была недоступна в sandbox из-за CoreSimulator/SwiftPM cache permissions; это не считается ошибкой приложения.

## Десять наиболее критичных проблем

| ID | Priority | Экран / компонент | Доказательство | Влияние | Первопричина | Исправление | Риск | Проверка |
|---|---|---|---|---|---|---|---|---|
| IA-01 | P0 | Global content policy | `IAUserMode.allowedSections` и `canShow` в `Models/InformationArchitecture.swift` исключают разделы | Полезный материал может стать недоступен туристу/резиденту | Persona реализована как ACL | Всегда разрешать доступ; persona влияет только на rank/filter UI | Medium | тест для каждой persona × каждого canonical item |
| RT-01 | P1 | Launch | Чёрный экран >5 с на установленной сборке iOS 26.5 | Пользователь не может начать работу | Требуются launch logs | Захватить console/signpost, устранить блокировку startup | High | cold launch 20 раз, p95 <2 с до usable UI |
| IA-02 | P1 | Root navigation | `AppTab` содержит 7 состояний, `TabItem` — 5; search/map сводятся к `.places` | Неоднозначный selected state и разные mental models | Legacy tabs поверх новой навигации | Один enum: Home, Guide, Map, Saved, More | High | snapshot/UI tests всех tab transitions |
| IA-03 | P1 | Bottom navigation | `compactTabBarItems`: Home, Places, AI, Saved, More — не целевая структура | Guide и Map не имеют ясного постоянного дома | Places агрегирует search/map/guide | Заменить Places на Guide и Map; AI сделать global action | High | 5 вкладок в одном порядке на всех compact devices |
| IA-04 | P1 | Home | `HomeView.swift` + 20+ `Home*Components.swift` | Длинная лента без приоритета; контент дублирует Guide/More | Home стал библиотекой и dashboard одновременно | Оставить status, next step, city, emergency, search; остальное deep-link | High | core task доступен ≤2 taps, Home ≤7 секций |
| IA-05 | P1 | More / side menu | `MoreHubView` и `RightSideMenuOverlay` в `AppTabView.swift` дают два полных каталога | Пользователь учит две структуры | Параллельное развитие navigation hubs | More — единый каталог; side menu убрать либо оставить 3–5 recent shortcuts | Medium | один canonical entry на категорию |
| IA-06 | P1 | Category model | `IASection`: Places, DocumentsGovernment, WorkStudy, FoodLifestyle; не совпадает с требуемыми 8 категориями | География и темы смешаны | Taxonomy кодирует UI-группы, не content ontology | Ввести Category, Geography, ContentType, AudienceTag как независимые поля | High | schema validation всех items |
| IA-07 | P1 | Content layer | GuideContent, PracticalGuide, HelpHub, Survival, Home, More содержат параллельные версии тем | Расхождения фактов и обновлений | Контент встроен в View/static mock structures | CanonicalContentItem repository + references | High | duplicate scan и единый content_id |
| IA-08 | P1 | Search | Источники распределены по множеству Mock*Data; статический QA проверяет лишь набор запросов | Материал может не индексироваться | Нет обязательного index contract для каждого item | Индексировать canonical repository; CI coverage=100% | Medium | каждый public content_id находится по title + aliases |
| IA-09 | P1 | Facts / sources | Существующий `CONTENT_INVENTORY.md` фиксирует uneven source metadata | Устаревшие юридические/финансовые факты снижают доверие | `updatedDate/source` не обязательны | Обязать sourceURL, publisher, reviewedAt, expiresAt для sensitive facts | Medium | CI отклоняет неполные high-risk items |
| IA-10 | P2 | Localization | В русской локали `IASection.startHere` возвращает “Start Here”; контент содержит inline RU/EN/NL | Смешанный язык и непредсказуемый VoiceOver | Локализация частично в коде | Только keys/structured localized values; language lint | Medium | pseudo-localization + 3 locale UI suite |

## Дубликаты и пересечения

Подтверждены тематические группы Housing, Healthcare, Transport, Documents, Government, Emergency, Work/Money, History, Culture/Places и AI. Точные строковые повторы также присутствуют: наборы “Goedemorgen”, “Dank je wel”, “Fijne dag” одновременно в `HomeProgressComponents.swift` и двух блоках `AppTabView.swift`. Полная нормализация описана в `03_duplicate_content.csv`.

## Целевая модель

Каждый материал имеет один `content_id`, один `content_type`, одну primary category, необязательные secondary categories, geography scope и audience tags. Audience tags никогда не ограничивают доступ. Home, Guide, Map, Saved, Search и AI получают проекции одного репозитория.

AI рекомендуется разместить как действие в глобальном поиске плюс компактная кнопка верхней панели на контекстных экранах. Отдельная вкладка не доказана: текущая вкладка конкурирует с Guide/Map и создаёт отдельный knowledge silo. AI обязан возвращать `content_id`/deep links и официальные источники.

## Десять быстрых исправлений

1. Убрать access-control семантику из `allowedSections`.
2. Зафиксировать один порядок пяти вкладок.
3. Переименовать Places в Guide до полной миграции.
4. Сделать Search доступным из Home и Guide top bar.
5. Скрыть полный каталог side menu, оставив recent shortcuts.
6. Удалить повторные Dutch phrase arrays в пользу одного источника.
7. Добавить обязательный `content_id` для карточек Home/More/Help.
8. Добавить source/review date badge для sensitive content.
9. Добавить CI-тест: каждый public item присутствует в Search index.
10. Захватить launch logs и закрыть чёрный startup screen.

## Оценки

- Information architecture: 4/10
- UX: 5/10
- UI hierarchy: 6/10
- Accessibility confidence: 6/10 (static pass; runtime matrix не завершена)
- Content trust: 5/10
- Stability: 5/10 (runtime launch symptom)
- App Store readiness: 5/10

## Как доказать устранение хаоса

- 100% public items имеют уникальный stable `content_id` и ровно одного canonical owner.
- 0 audience-based inaccessible items.
- 100% public items находятся через Search.
- 0 exact duplicate bodies вне локализаций/цитат.
- Одна корневая навигация из пяти вкладок на всех size classes.
- Home содержит не более семи приоритетных секций.
- Все noncanonical cards хранят только reference на canonical item.
- Все sensitive facts имеют источник и дату проверки.
- Любой существующий материал отображён в `06_content_migration_map.csv` и доступен через Guide, Search, Map либо contextual link.

