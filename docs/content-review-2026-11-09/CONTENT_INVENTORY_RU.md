# YouNew — инвентарь контента

Проверено 9 ноября 2026 года. Рабочая копия: `/Users/ivan/YouNew-Content-2026-11-09/work`. Исходные комплекты сохранены. Все 71 реальные записи имеют `draft` и `needs_review`; это подготовка к редакторскому решению, а не разрешение на публикацию.

## Состав

| Раздел | Подготовлено |
|---|---:|
| EXPLORE: Лейден | 40 |
| EXPLORE: прежние места других городов | 14 |
| LIVE: инструкции EN/NL | 10 |
| Подборки EN/NL | 5 |
| BUSINESS: тексты EN/NL | 2 |

Лейден: 10 ресторанов, 8 кафе, 6 отелей, 7 музеев/достопримечательностей, 8 парков и 1 VVV. Существующая VVV сохранена отдельно, поэтому в пределах лимита 40 карточек музеев/достопримечательностей семь вместо ориентира восемь. VVV не переименована искусственно в музей.

## Каноническое хранение

Единственный редактируемый источник — существующий `source/DataProject/batches/WP-*/WP-*-M1-leiden-20261109.json`. Команда `python3 tools/project-content.py` из корня комплекта строит существующий импорт `work/backend/db/catalog-drafts.json` и CSV-отчёты. Импорт `scripts/integration-seed.mjs` из каталога backend/admin-dashboard синхронизирует только эти черновики в существующую таблицу `catalog_places`. Веб-превью получает записи из обычного закрытого API редактора.

Исторические 14 записей в `source/DataProject/staging/catalog-20261103` сохранены без изменений. Это прежний архив, а не второй активный импорт. Старые координаты сохранены как исторические атрибуты; без нового подтверждения они не используются на карте. Новые записи не добавлены в published release manifests.

## Неподтверждённые поля

**199 пустых полей** из 408 проверяемых позиций: по 7 на каждое из 54 мест (адрес, сайт, email, телефон, пара координат, часы, цены) и по 3 на каждую из 10 инструкций (документы, стоимость, срок). Пара координат считается одним полем. Это не количество ошибочных фактов. Общие документы, тарифы и сроки могут быть неприменимы без индивидуальной ситуации.

| Поле | Пусто |
|---|---:|
| Стоимость LIVE | 6 |
| Документы LIVE | 6 |
| Срок LIVE | 5 |
| Координаты | 51 |
| Часы работы | 44 |
| Цены | 50 |
| Деловой email | 20 |
| Деловой телефон | 17 |

Все 54 места имеют адрес/местоположение и официальный сайт. Для нескольких парков подтверждено название территории, без вымышленного номера дома. Три подтверждённые пары координат: Hortus, Lakenhal, ibis. Подробный список пробелов — `evidence/UNCONFIRMED_FIELDS.csv`.

## Места

| ID | Название | Город | Категория | Адрес |
|---|---|---|---|---|
| `cafe.den-haag-kaafi` | Kaafi | den-haag | cafe | Prinsestraat 25, 2513 CA Den Haag |
| `nature.den-haag-westbroekpark` | Westbroekpark | den-haag | city-park | Kapelweg 35, 2587 BK Den Haag |
| `hotel.den-haag-collector` | The Collector | den-haag | hotel | Haagsche Bluf 52, 2511 CP Den Haag |
| `museum.den-haag-fotomuseum` | Fotomuseum Den Haag | den-haag | photography | Stadhouderslaan 43, 2517 HV Den Haag |
| `museum.eindhoven-inkijkmuseum` | Inkijkmuseum | eindhoven | art | Dommelstraat 2 A, 5611 CK Eindhoven |
| `restaurant.eindhoven-kazerne` | Kazerne BarBistro | eindhoven | restaurant | Paradijslaan 2–8, 5611 KN Eindhoven |
| `cafe.leiden-30ml` | 30ML Leiden | leiden | cafe | Botermarkt 3, 2311 EM Leiden |
| `cafe.leiden-annemax` | Anne&Max Leiden | leiden | cafe | Gangetje 2, 2311 ER Leiden |
| `cafe.leiden-barista` | Barista Cafe Leiden | leiden | cafe | Catharinasteeg 5, Leiden |
| `cafe.leiden-borgman` | Borgman Borgman | leiden | cafe | Nieuwe Rijn 41, 2312 JG Leiden |
| `cafe.leiden-brownies` | Brownies&downieS Leiden | leiden | cafe | Aalmarkt 11, 2311 EC Leiden |
| `place.leiden-cafe-laken` | Café Laken | leiden | cafe | Oude Singel 30, 2312 RA Leiden |
| `cafe.leiden-paco-ciao` | Paco Ciao | leiden | cafe | Stationsweg 25, Leiden |
| `cafe.leiden-roos` | ROOS Leiden | leiden | cafe | Botermarkt 12, 2311 EM Leiden |
| `hotel.leiden-oude-morsch` | Boutique Hotel d’Oude Morsch | leiden | hotel | Park de Put 1, 2312 BM Leiden |
| `hotel.leiden-rembrandt-hotel` | City Hotel Rembrandt | leiden | hotel | Nieuwe Beestenmarkt 10, 2312 CH Leiden |
| `hotel.leiden-golden-tulip` | Golden Tulip Leiden Centre | leiden | hotel | Schipholweg 3, 2316 XB Leiden |
| `hotel.leiden-huys-van-leyden` | Huys van Leyden | leiden | hotel | Oude Singel 212, 2312 RJ Leiden |
| `hotel.leiden-steenhof` | Steenhof Suites | leiden | hotel | Steenschuur 11, 2311 ES Leiden |
| `hotel.leiden-ibis` | ibis Leiden Centre | leiden | hotel | Stationsplein 240–242, 2312 AR Leiden |
| `place.leiden-burcht` | De Burcht | leiden | museums-sights | Burgsteeg, 2312 JR Leiden |
| `place.leiden-hortus` | Hortus botanicus Leiden | leiden | museums-sights | Rapenburg 73, 2311 GJ Leiden |
| `place.leiden-lakenhal` | Museum De Lakenhal | leiden | museums-sights | Oude Singel 32, 2312 RA Leiden |
| `place.leiden-naturalis` | Naturalis | leiden | museums-sights | Darwinweg 2, 2333 CR Leiden |
| `museum.leiden-boerhaave` | Rijksmuseum Boerhaave | leiden | museums-sights | Lange St. Agnietenstraat 10, 2312 WC Leiden |
| `place.leiden-rmo` | Rijksmuseum van Oudheden | leiden | museums-sights | Rapenburg 28, 2311 EW Leiden |
| `museum.leiden-wereldmuseum` | Wereldmuseum Leiden | leiden | museums-sights | Steenstraat 1, 2312 BS Leiden |
| `nature.leiden-ankerpark` | Ankerpark | leiden | parks-walks | Ankerpark, Leiden |
| `nature.leiden-blekerspark` | Blekerspark | leiden | parks-walks | Blekerspark, Leiden |
| `nature.leiden-plantsoen` | Het Plantsoen | leiden | parks-walks | Plantsoen, Leiden |
| `nature.leiden-huigpark` | Huigpark | leiden | parks-walks | Huigpark, Leiden |
| `nature.leiden-leidse-hout` | Leidse Hout | leiden | parks-walks | Van Beuningenlaan 1, 2334 CC Leiden |
| `nature.leiden-park-de-put` | Park de Put | leiden | parks-walks | Park de Put, Leiden |
| `nature.leiden-cronesteyn` | Polderpark Cronesteyn | leiden | parks-walks | Polderpad, 2322 LB Leiden |
| `nature.leiden-rembrandtpark` | Rembrandtpark | leiden | parks-walks | Rembrandtpark, 2311 WX Leiden |
| `restaurant.leiden-bikini` | Bikini Bikini | leiden | restaurant | Haven 1, 2312 MG Leiden |
| `restaurant.leiden-engelenbak` | De Engelenbak | leiden | restaurant | Lange Mare 38, 2312 GS Leiden |
| `restaurant.leiden-grand-cafe-burcht` | Grand Café De Burcht | leiden | restaurant | Burgsteeg 14, 2312 JS Leiden |
| `restaurant.leiden-prentenkabinet` | Het Prentenkabinet | leiden | restaurant | Kloksteeg 25, 2311 SK Leiden |
| `restaurant.leiden-oudt-leyden` | Oudt Leyden | leiden | restaurant | Steenstraat 49, 2312 BV Leiden |
| `restaurant.leiden-dende` | Restaurant Dende | leiden | restaurant | Nieuwe Rijn 5, 2312 JB Leiden |
| `restaurant.leiden-in-den-doofpot` | Restaurant In den Doofpot | leiden | restaurant | Turfmarkt 9, 2312 CE Leiden |
| `restaurant.leiden-verboden-toegang` | Restaurant Verboden Toegang | leiden | restaurant | Kaiserstraat 7, 2311 GN Leiden |
| `restaurant.leiden-tabu` | Tabú | leiden | restaurant | Rembrandtstraat 27, 2311 VV Leiden |
| `restaurant.leiden-waag` | Waag Leiden | leiden | restaurant | Aalmarkt 21, 2311 EC Leiden |
| `place.leiden-vvv` | VVV Leiden | leiden | visitor-information | Stationsweg 26, 2312 AV Leiden |
| `museum.rotterdam-chabot` | Chabot Museum | rotterdam | art | Museumpark 11, 3015 CB Rotterdam |
| `nature.rotterdam-trompenburg` | Trompenburg Tuinen & Arboretum | rotterdam | botanical-garden | Honingerdijk 86, 3062 NX Rotterdam |
| `hotel.rotterdam-supernova` | Supernova Hotel | rotterdam | hotel | ’s-Gravendijkwal 68, 3014 EG Rotterdam |
| `nature.utrecht-oog-in-al` | Park Oog in Al | utrecht | city-park | Park Oog in Al, 3533 HE Utrecht |
| `cafe.utrecht-koffie-leute` | Koffie Leute | utrecht | coffee | Westerkade 30, 3511 HC Utrecht |
| `hotel.utrecht-nox` | The Nox Hotel Utrecht | utrecht | hotel | Keistraat 8, 3512 HV Utrecht |
| `place.utrecht-neude` | Bibliotheek Neude | utrecht | public-library | Neude 11, 3512 AE Utrecht |
| `museum.utrecht-sonnenborgh` | Sonnenborgh museum & sterrenwacht | utrecht | science | Zonnenburg 2, 3512 NL Utrecht |

## Инструкции

| ID | EN | NL |
|---|---|---|
| `guide.leiden-transport` | Use trains and local buses | Reizen met trein en bus |
| `guide.leiden-bicycle` | Park your bicycle in Leiden | Je fiets parkeren in Leiden |
| `guide.leiden-gp` | Find a general practitioner | Een huisarts vinden |
| `guide.leiden-pharmacy` | Medicines and out-of-hours care | Medicijnen en zorg buiten kantooruren |
| `guide.leiden-registration` | Register your address | Je woonadres registreren |
| `guide.leiden-bsn` | Get or find your BSN | Een BSN krijgen of terugvinden |
| `guide.leiden-digid` | Apply for and activate DigiD | DigiD aanvragen en activeren |
| `guide.leiden-waste` | Sort and dispose of household waste | Huisafval scheiden en aanbieden |
| `guide.leiden-contacts` | Emergency and non-emergency contacts | Contact bij spoed en zonder spoed |
| `guide.leiden-municipal-services` | Arrange municipal services | Gemeentezaken regelen |

## Подборки

| ID | EN | NL |
|---|---|---|
| `collection.leiden-first-day` | First day in Leiden | Eerste dag in Leiden |
| `collection.leiden-free` | Free places | Gratis plekken |
| `collection.leiden-centre-walk` | A walk through the centre | Wandeling door de binnenstad |
| `collection.leiden-rain` | A rainy day in Leiden | Een regenachtige dag in Leiden |
| `collection.leiden-weekend` | A weekend in Leiden | Een weekend in Leiden |

## BUSINESS

| ID | EN | NL |
|---|---|---|
| `business.leiden-add` | Add a business | Een bedrijf toevoegen |
| `business.leiden-claim-correct` | Claim or correct a business | Een bedrijf claimen of corrigeren |

## Перепроверка прежних 14 карточек

Стабильные ID и исходные города сохранены. Проверены официальные страницы адресов и контактов Koffie Leute, KAAFI, Kazerne, Trompenburg, Oog in Al, Westbroekpark, Chabot Museum, Sonnenborgh, Fotomuseum Den Haag, Inkijkmuseum, Bibliotheek Neude, Supernova, The Nox и The Collector. Полевая привязка — в `SOURCES.csv`. Существенные уточнения: Westbroekpark — Kapelweg 35; Bibliotheek Neude — отдельные страницы доступности и службы поддержки; Inkijkmuseum — просмотр через окна не равен круглосуточному входу. Старые неподтверждённые координаты, часы и тарифы не перенесены в действующие поля.

## Открытые вопросы и исключения

- VVV: EN/NL расходятся по воскресенью. Часы пустые.
- In den Doofpot: закрыто в воскресенье/понедельник против «по запросу». Часы пустые.
- Dende: расписание в основном блоке и подвале различается. Часы пустые.
- Anne&Max: воскресенье 09:00 в таблице против 08:00 в FAQ. Часы пустые; скрытый email не угадывался.
- DigiD: оператор пишет пять рабочих дней, Government.nl — три. В тексте выбран оператор; расхождение показано редактору и читателю.
- Naturalis: адрес посетителя Darwinweg 2; въезд/велоподъезд через Mendelweg необходимо смотреть по текущей схеме.
- Tabú: главная страница нестабильно открывается при автоматической проверке; FAQ доступен через веб-проверку и подтверждает адрес и деловые контакты.
- WOODS не включён: временное закрытие на дату проверки. Lot en de Walvis не продублирован после смены на BikiniBikini. Mayflower и Chummy не включены из-за недостаточного подтверждения на официальном сайте.
- Бесплатными названы только De Burcht, Plantsoen и Blekerspark, подтверждённые туристическим источником. Питание и платные части маршрута не названы бесплатными.
- Длительность центральной прогулки не указана: проверенного маршрута и расчёта длины нет. Подборка содержит предлагаемые остановки.
- Фотографии не заимствованы. Везде нейтральная заглушка; 71 строка в MEDIA_RIGHTS.csv.
- BUSINESS подготовлен как два черновика текста в редакторе; действующие публичные страницы и реальные заявки не изменены. Тексты не обещают сроки модерации, клиентов, продвижение или партнёрство.
