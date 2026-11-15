# Источники аудита

Дата чтения 15.11.2026 относится к аудиту. Факты о местах сохраняют собственные даты.
Основные контентные реестры уже существуют; не создавать параллельную базу источников.

| Назначение | Источник | Результат / граница |
|---|---|---|
| Публичный сайт | https://younew.nl/ и шесть маршрутов SPRINT 0 | Прямой HTTP 200; snapshot в evidence, не только поисковая копия |
| Реальные публичные сущности | `admin-dashboard/public-site/src/generated/public-content.json` | 76, виды/источники/checkedAt; опубликованная проекция, не весь Admin |
| География | `admin-dashboard/public-site/src/generated/netherlands-geography.json` → `sources` | 342 municipality / 2502 settlement, effective 01.01.2026 |
| Редакционные EN/NL факты | `DataProject/editorial/`, `public-content.json` → `editorial.sources` | Уже одобренная партия 71; не новая публикация |
| Модель доверия/ссылок | `src/lib/content/types.ts`, governance, placeDetails, source registry DataProject | Источник/назначение поля/дата/связь с сущностью; typed link registry пока PARTIAL |
| Фото городов | `src/content/discovery-media.json` | Пять собственно хранимых WebP-наборов; автор, CC license URL, sourcePageUrl, retrievedAt; новых медиа нет |
| Hostinger | SSH: PHP/Node версии, sanitized health log, QA pointer | Реальное health 15.11 11:00 UTC OK; данные и env не выводятся |
| Apple public | https://itunes.apple.com/lookup?id=6782617312&country=nl | YouNew 1.3, released 03.08.2026, minimum iOS 17.6; не authenticated App Store Connect |
| Код/история | https://github.com/zq87xf5jyp-arch/YouNew | main 7e80634, независимый draft PR59 47813e7 |

## UX-ориентиры, не источники копируемого контента

- [I amsterdam](https://www.iamsterdam.com/en/see-and-do): отдельные входы по интересам и сценариям.
- [Holland.com](https://www.holland.com/global/tourism): разделяет направления, впечатления и практическую подготовку.
- [Lonely Planet](https://www.lonelyplanet.com/the-netherlands): автоматическое чтение 403, NOT VERIFIED; не считать ссылку сломанной.
- [GetYourGuide](https://www.getyourguide.com/amsterdam-l36/): входы по интересам и видам активностей рядом с поиском; цены/рейтинги не заимствуются.
- [Atlas Obscura](https://www.atlasobscura.com/things-to-do/netherlands): города и тематические открытия как разные входы к местам.
- [Tripadvisor](https://www.tripadvisor.com/Attractions-g188590-Activities-Amsterdam_North_Holland_Province.html): автоматическое чтение 403, NOT VERIFIED.

Заимствован только общий навигационный принцип. Тексты, дизайн, фото, код сторонних
сайтов не переносятся. Для двух недоступных ориентиров детальный визуальный аудит
не заявляется; блокировки не обходились.

## Для будущих изменений

Каждая новая factual запись использует существующий entity/source ID, конкретный URL,
назначение, checkedAt и status. Booking/Directions добавлять только при подтверждении.
Новая дата сборки не обновляет checkedAt. Коммерческие ссылки требуют явной маркировки
при наличии реальных отношений; Verified не продаётся.
