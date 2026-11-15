# Карта YouNew 2.0

Проверено 15.11.2026. Исходный `main`: `7e806340808b7c8476c9da5f88ec83470d674374`.
Область этого запуска: SPRINT 0 и один небольшой шаг SPRINT 1, без production.
Состояния относятся к конкретному поведению, а не ко всему продукту:
`EXISTS` — найдено в коде; `PARTIAL` — неполное покрытие; `MISSING` — не найдено;
`BROKEN` — подтверждён неправильный результат; `OBSOLETE` — устаревшее описание;
`VERIFIED` — выполнена указанная проверка. Наличие кода не доказывает работу UI.

| Модуль / спринт | Состояние до изменения | Уже работает / доказательство | Требует улучшения или отсутствует | Приоритет |
|---|---|---|---|---|
| Главная, Header, Footer / 1 | VERIFIED | `/`, `/nl/`: 200; общий `DiscoveryHome`, LIVE/EXPLORE/BUSINESS, мобильное меню | Категории открытия мест далеко ниже поиска | P1, выбранный шаг |
| Hero и City Card / 1 | EXISTS | `ContentMedia`, пять городских WebP, автор/CC/источник, responsive sizes | Hero скрыт на ≤760 px; нет оснований называть направления популярными | P2 |
| Global Search / 1 | EXISTS | `HomeSearchForm`, EN/NL `SearchExperience`, приватная передача запроса, поиск/фильтры/сортировка | Не создавать второй поиск; NL-фильтры и EN-паритет проверять отдельно | P1 |
| Категории / 1 | VERIFIED | 33 категории; culture 10, food-drink 21, outdoors 11, local-services 9 | Главная отправляет Local services в `/organizations/`, где 0 сущностей organization | P1, выбранный шаг |
| Тематические коллекции / 1–2 | PARTIAL | Категории и связанные карточки уже есть | Авторские travel-подборки с собственной ценностью отсутствуют | P2 |
| Городские страницы / 2 | PARTIAL | 5 `city-guides`, отдельный Leiden EN/NL; фото, вводный текст, источники, ссылки | Шаблон пяти городов ориентирован на муниципальные задачи; не полноценные travel-гиды | P1 |
| География / 2, 8 | VERIFIED | Артефакт: 12 провинций, 342 муниципалитета, 2502 поселения; дата справочника 01.01.2026 | Не путать справочник с редакционным покрытием | P1 |
| Карта / 2 | PARTIAL | `CoverageMap`: SVG, зум, кластеры, фильтры, list view; нет обязательного paid API | Координаты есть лишь у 3 из 54 мест; карту нельзя считать картой всех мест | P1 |
| Карточки мест / 2 | PARTIAL | 54 места, адрес/official URL/контакты по источнику, Save, related, report | Ни у одного из 54 мест нет опубликованного изображения; часы/цены/доступность не заполнены универсально | P1 |
| Directions / Booking / 2 | PARTIAL | Контактные данные и официальный источник есть; карта только при координате | Нет общего проверенного Booking/Directions-контракта для всех мест | P2 |
| Save / 3 | EXISTS | `SaveButton`, `SavedItems`, `localContentRepository`, лимиты/валидация, local export | Не дублировать хранилище; нет коллекций по городам/интересам | P1 |
| Travel Itinerary / 3 | MISSING | `JourneyExplorer` — адаптационные шаги, не путешествие | Добавление/порядок остановок, карта маршрута, безопасный общий список | P2 |
| Персонализация / 4 | EXISTS | Tourist/Student/Expat/Refugee/Worker/Resident, профиль в browser storage | Два существующих profile-selector: сопоставить перед расширением | P1 |
| LIVE-трекер / 4 | PARTIAL | `NextStepPlanner` выбирает профиль/город/цели; `JourneyExplorer` хранит прогресс | Arrival planner и journey — разные задачи; нет единого полного локального чек-листа всех 9 тем | P1 |
| Budget Planner / 5 | MISSING | Поле business budget — бюджет заявки, не калькулятор жизни | Месяц/год/сценарии/сравнение расходов отсутствуют | P2 |
| Транспортный калькулятор / 5 | MISSING | Есть официальные транспортные маршруты и категории | Нет проверенных тарифных данных; нельзя подставить выдуманные цены | P3 |
| Полные практические гиды / 6 | PARTIAL | На main 17 кратких гидов, 0 полных; контракт PracticalGuide существует | Полный EN/NL-шаблон и 6 пар подготовлены отдельно в PR59, не повторять | P0, отдельное review |
| Community / 6 | PARTIAL | `PublicFeedbackForm`, приватная очередь; редакционная модерация Admin | Нет публичного UGC-форума; анонимные советы не считаются фактами | P2 |
| Add / Claim / Review / 7 | EXISTS | EN/NL формы, human review, Hostinger outbox → Admin | Нет доступного самостоятельного кабинета владельца бизнес-карточки | P1 |
| Business Workspace / 7 | PARTIAL | Исходный `BusinessWorkspace` — локальный preview | Production `/business/workspace/` редиректит на `/for-business/pilot/`; это не работающий кабинет | P2 |
| Каталог BUSINESS / 7 | PARTIAL | `catalog_places` с draft/review/published, ревизиями и approval; факты адреса/website | 0 сущностей типа organization; местные компании представлены типом place; не заводить дубликаты | P1 |
| Sponsored / Premium / 7 | PARTIAL | Модель и disclosure есть; покупка не активирована | На pilot отдельное предложение €1500, без checkout; никакого запуска платежей в этом задании | P3 |
| SEO / 8 | PARTIAL | Canonical, EN/NL hreflang, OpenGraph, sitemap; 608 URL в live sitemap | Keywords/travel и BreadcrumbList исправлены в PR59, не копировать изменения | P1, отдельное review |
| Система ссылок / 8 | PARTIAL | Источники, checkedAt, entity ID, media source/license, `placeDetails` | Нет одного обязательного typed registry для всех Internal/Official/Booking/Directions/Report; расширять текущие модели | P2 |
| Admin / 9 | EXISTS | Node 24, Next 15.5.28, MariaDB, роли, audit, private files; live anonymous API 401 | Реальный вход подтверждён владельцем 10.11; повторный authenticated UI 15.11 NOT VERIFIED | P1 |
| Hostinger / 9 | VERIFIED | SSH, PHP 8.3.36, Node 24.22.3; health 15.11 11:00 UTC OK, outbox 0, реальный cron | Hosting plugin отсутствует (есть только Mail); это не отсутствие функции тарифа | P1 |
| iOS / 9 | PARTIAL | SwiftUI, общий базовый runtime 5 сущностей; public Apple lookup: 1.3, iOS ≥17.6 | 71 новый web ID отсутствует в исходном iOS bundle; App Store Connect authenticated access NOT VERIFIED; Save не синхронизируется | P1 |
| Доступность/скорость / 9 | PARTIAL | Существующие focus/alt/reduced-motion, responsive фото и тесты | Полный WCAG-аудит и полевые CWV не подтверждены; новые UI-проверки описаны в QA_REPORT | P1 |
| Публичный status | OBSOLETE | В live HTML одновременно 177/182 исторических записей и 76 текущих; августовские Sites/Supabase | Обновить датированные конфиги статуса по современному evidence, не объявлять всё готовым | P0, следующий безопасный шаг |
| Навигация редакционных карточек | BROKEN | Chabot Museum корректно связан с Rotterdam в related/source, но верхний breadcrumb общего `EditorialDetail` ведёт в Leiden | Исправить городскую привязку общего шаблона отдельным регрессионным шагом | P1 |

## Исходные числа и расхождения

76 публичных сущностей = 54 места + 17 кратких гидов + 5 городов; 0 полных гидов,
0 organizations. 57 сущностей привязаны к Leiden (это не 57 мест). 608 sitemap URL
не равны сущностям. Источники публичного набора датированы 24.10, 09.11 и 10.11;
аудит интерфейса 15.11 не переименовывает эти даты в свежую проверку фактов.

iOS: исходный `YouNew/Resources/Data/younew-runtime-data.json` содержит 5 entities и
183 withheld IDs; web импортирует этот базовый runtime и отдельно добавляет
71 одобренную editorial entity. Совпадают 5 ID, 71 web ID отсутствует в исходном
iOS bundle. Это сравнение исходников, не выгрузка бинарника из App Store.
Основной target Xcode: версия 1.3, build 8, iOS 17.6. Отправка новой сборки не выполнялась.

Прямые HTTP-запросы 15.11 подтвердили все шесть URL из задания: `/`, `/discover/`,
`/categories/`, `/cities/`, `/for-business/`, `/status/` → 200. Web search отдавал
старую копию `/discover/` (188 записей), поэтому исходная точка взята из прямого HTTP.
Корневой README описывает старый Build Week, корневой ARCHITECTURE — прежде всего iOS.
Использовать их как историю, а не полную современную архитектуру hosting.

## Потенциальные дубликаты — не создавать

- `DiscoveryHome` уже общий для EN/NL; расширять его, не вторую главную.
- `EntityCard` / `NlEntityCard`, `EntityDetail`, `ContentMedia`, `PlaceContactDetails` уже используются в категориях.
- `/city-guides/*`, `/cities/*`, `/municipalities/*`, `/leiden/` обслуживают разные виды покрытия; не массово объединять URL.
- `SavedItems` и iOS `SavedItemsStore` — отдельные устройства, не две серверные базы.
- `JourneyExplorer` и `NextStepPlanner` использовать в своих ролях, не переименовывать в travel itinerary.
- Исторический Supabase Admin и Hostinger runtime: production — Hostinger; не активировать Supabase.
- PR59: SEO, полные гиды, выключенная аналитика — уже подготовленная независимая работа.

Следующие действия и границы: [SPRINT_STATUS](SPRINT_STATUS.md). Доказательства: [QA_REPORT](QA_REPORT.md).
