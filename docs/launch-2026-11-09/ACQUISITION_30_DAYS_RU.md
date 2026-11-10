# Первые 30 дней привлечения: рабочий черновик

Обновлено 9 ноября 2026. Цель — проверить путь «найти место в Лейдене → официальный сайт или маршрут» и гипотезу первых 100 реальных пользователей. Это не прогноз. Новые карточки и подборки не одобрены; публикации ниже никому не отправлены. Развёртывание исправленного сайта уже разрешено после технических проверок. Для новых материалов сохраняется отдельное редакторское согласование; публикация в соцсетях и включение нового production tracking не выполняются в этой работе.

## Готовность посадочных страниц

В текущем кандидате есть общий маршрут `/cities/[slug]/` и существующие BUSINESS-формы EN/NL. Старые отдельные Leiden-маршруты и фрагменты `#collection=art-history`, `nature`, `first-visit` не входят в подтверждённую каноническую реализацию. Поэтому заменять ими ссылки в постах нельзя.

| Метка ссылки в тексте | Требование перед использованием | Сейчас |
| --- | --- | --- |
| `{LEIDEN_EN}` / `{LEIDEN_NL}` | Реально опубликованная EN/NL страница с одобренными местами, адресами, источниками и действиями | Ожидает редакторского одобрения и проверки production |
| `{ART_EN}` / `{ART_NL}` | Опубликованная подборка искусства и истории с утверждёнными фактами | Черновик, публичный URL не назначен |
| `{NATURE_EN}` / `{NATURE_NL}` | Опубликованная подборка природы | Черновик, публичный URL не назначен |
| `{FIRST_EN}` / `{FIRST_NL}` | Опубликованная подборка первого визита | Черновик, публичный URL не назначен |
| `{BUSINESS_EN}` | `https://younew.nl/for-business/local/apply/` | Маршрут есть в исходниках; delivery/cron нового production ещё не проверены |
| `{BUSINESS_NL}` | `https://younew.nl/nl/voor-bedrijven/aanmelden/` | То же |

Метки намеренно не изображают работающие ссылки. Перед публикацией подставить проверенный публичный URL и статические UTM: `utm_source=linkedin` или `pinterest`, `utm_medium=organic_social`, `utm_campaign=leiden30`, `utm_content=p01`…`p05`. Никаких email, имён, поисковых фраз или идентификаторов людей в ссылках. SEO-ссылки остаются каноническими, без UTM. При недоступной посадочной публикацию отложить.

## Три бесплатных канала

| Канал | Аудитория и полезная страница | Где и как | Измерение и решение |
| --- | --- | --- | --- |
| LinkedIn | Переехавшие специалисты — первый визит; местные владельцы — BUSINESS | Собственный профиль со связью с YouNew либо уже доступная собственная страница. P01/P04/P05; без личных рассылок и повторяющихся комментариев. | Штатные клики, если доступны. После двух постов/14 дней: ≥10 кликов и ≥3 полезных действий — продолжить; ≥20 кликов и 0 действий — исправить посадочную; <5 кликов — один раз пересмотреть текст, затем прекратить дополнительные усилия. |
| Pinterest | Планирующие музейный или природный день — подборки P02/P03 | Собственная доска существующего аккаунта. Два разных Pins, собственная типографика, без чужих фото/логотипов, сокращателей и массового дублирования. | Исходящие клики, если доступны. На 30-й день ≥5 кликов и ≥2 полезных действий — оставить ещё на месяц; ≥20 кликов и 0 действий — проверить страницу; отсутствие кликов не повод массово размножать Pins. |
| Органический поиск | Ищущие проверенные места и контакты Лейдена — содержательные одобренные EN/NL страницы | Собственный сайт, источники, внутренние ссылки, canonical/hreflang и sitemap только публичных материалов. | Через уже подключённые средства — индексирование, показы, клики. День 30: техническая оценка; спрос оценивать через 60–90 дней. Пустые страницы и неверные факты исправлять до продвижения. |

Аудитории и пороги — гипотезы для решения, не наблюдаемые результаты. Доступ к социальным аккаунтам и Search Console не подтверждён; новые аккаунты, сервисы или платные инструменты не создаются. Если полезные действия не измеряются из-за выключенной аналитики, их значение — «нет данных», а не ноль; критерий конверсии тогда не оценён.

LinkedIn требует релевантного оригинального профессионального контента и запрещает спам/искусственную активность. Эти условия поддерживают публикации на собственном профиле, но не дают разрешения на размещение в любой группе. [LinkedIn Community Policies](https://www.linkedin.com/legal/professional-community-policies).

Pinterest запрещает навязчивые повторы, неразрешённую автоматизацию и обманные ссылки. На странице объявлено обновление с **12 ноября 2026**; проверены действующая версия и опубликованный preview. До фактического размещения сверить вступившую в силу версию. [Действующие правила](https://policy.pinterest.com/en/community-guidelines), [объявленное обновление](https://policy.pinterest.com/en/community-guidelines-preview).

Google рекомендует оригинальную полезную информацию для читателя; массовые страницы без ценности не подходят. SEO здесь долгосрочный канал, без обещания быстрых посетителей. [Helpful content](https://developers.google.com/search/docs/fundamentals/creating-helpful-content), [Spam policies](https://developers.google.com/search/docs/essentials/spam-policies). Официальные страницы прочитаны 09.11.2026. Чужие сообщества с непроверенными правилами не включены.

## Календарь

День 1 начинается после технического запуска и редакторского одобрения нужных посадочных страниц. Соцпубликации ниже — действия владельца либо отдельного будущего поручения; сейчас подготовлены только тексты.

| Дни | Действие | Проверяемый результат |
| --- | --- | --- |
| 1–3 | Проверить одобренный набор, источники, EN/NL и все конечные ссылки | Нет черновиков, пустых обещаний и неверных переходов |
| 4–5 | Проверить 390 px/desktop, путь до официального сайта/маршрута, BUSINESS и доступные метрики | Записаны фактическая версия и исходные значения либо «нет данных» |
| 6 | P01 в собственном LinkedIn | Сохранены URL, дата, язык и код p01 |
| 7–10 | P02 в Pinterest | Одна полезная картинка и прямая ссылка на обещанную подборку |
| 11–14 | P03 в Pinterest; первая оценка | Зафиксированы наблюдения; единичные клики не объявлены успехом |
| 15–18 | P04 в LinkedIn; перепроверка изменившихся сведений | Один приоритетный дефект пути исправлен, если обнаружен |
| 19–23 | P05 как собственная публикация | BUSINESS оценивается отдельно от посетительского сценария |
| 24–27 | Проверить индексирование и качество пустых результатов | Нет массовых страниц и сохранения текстов поиска |
| 28–30 | Сопоставить факты с порогами | Продолжить, исправить либо остановить конкретный канал |

## Пять текстов EN/NL

Выбрать язык аудитории. Не размещать одинаковые языковые версии подряд. Упоминания мест — редакционные черновики; перед размещением сверить с одобренной партией и актуальными официальными источниками. Тексты не заявляют партнёрство с организациями.

### P01 — LinkedIn, понятный первый шаг

**EN:** Planning a day in Leiden? I’m building YouNew to make the next step easier: compare a small selection of places, check the address and source, then open the official website or directions. Start here: {LEIDEN_EN}. Confirm current visitor details with the venue before travelling.

**NL:** Een dag in Leiden plannen? Ik bouw YouNew om de volgende stap makkelijker te maken: vergelijk een kleine selectie plekken, controleer het adres en de bron, en open de officiële website of route. Begin hier: {LEIDEN_NL}. Controleer actuele bezoekersinformatie vóór vertrek bij de locatie.

### P02 — Pinterest, искусство и история

**EN title:** Leiden: choose your art and history stop

**EN:** Museum De Lakenhal or the Rijksmuseum van Oudheden? Compare two different ways to explore art and history, with checked addresses and official visitor links in this short YouNew selection. {ART_EN}

**NL title:** Leiden: kies je stop voor kunst en geschiedenis

**NL:** Museum De Lakenhal of het Rijksmuseum van Oudheden? Vergelijk twee verschillende manieren om kunst en geschiedenis te ontdekken, met gecontroleerde adressen en officiële bezoekerslinks in deze korte YouNew-selectie. {ART_NL}

Графика: собственная типографика «Leiden / Art & history / 2 places to compare» на нейтральном фоне. Без чужих фотографий и логотипов; изображение пока не создано.

### P03 — Pinterest, природа

**EN title:** Plants or natural history in Leiden?

**EN:** Compare the Hortus botanicus and Naturalis for your next Leiden visit. YouNew brings together addresses and official sources so you can choose, check and plan. Check opening times and admission details with the venue. {NATURE_EN}

**NL title:** Planten of natuurhistorie in Leiden?

**NL:** Vergelijk de Hortus botanicus en Naturalis voor je volgende bezoek aan Leiden. YouNew zet adressen en officiële bronnen bij elkaar, zodat je kunt kiezen, controleren en plannen. Bekijk openingstijden en toegangsvoorwaarden bij de locatie. {NATURE_NL}

Графика: собственная типографика «Leiden / Nieuwsgierig naar de natuur / Hortus & Naturalis», без фотографий организаций.

### P04 — LinkedIn, первое знакомство

**EN:** New to Leiden and looking for a starting point? Our short YouNew selection brings together VVV Leiden for visitor information and Café Laken as a café option, with separate checked addresses and official links. I work on YouNew; this is an editorial selection. {FIRST_EN}

**NL:** Nieuw in Leiden en op zoek naar een vertrekpunt? Onze korte YouNew-selectie brengt VVV Leiden voor bezoekersinformatie en Café Laken als caféoptie samen, met afzonderlijk gecontroleerde adressen en officiële links. Ik werk aan YouNew; dit is een redactionele selectie. {FIRST_NL}

### P05 — LinkedIn, местный бизнес

**EN:** Help newcomers understand your business with clear public facts: what you do, where to visit and how to contact you officially. YouNew offers a free basic profile request for editorial review. A request does not guarantee publication, leads or revenue. {BUSINESS_EN}

**NL:** Help nieuwkomers je bedrijf te begrijpen met duidelijke openbare gegevens: wat je doet, waar ze terechtkunnen en hoe ze officieel contact opnemen. Bij YouNew kun je gratis een basisprofiel ter beoordeling aanvragen. Een aanvraag garandeert geen publicatie, leads of omzet. {BUSINESS_NL}

## Одно предложение местному бизнесу

Текст для собственной публикации или ответа на входящий запрос; никому не отправлен. Бесплатной является заявка на базовый профиль, как в текущем коде BUSINESS; цена продажи проекта и условия платных продуктов не меняются.

**EN:** Request a concise EN/NL business profile based on public facts: category, visitor address, official website and contact route. You can submit factual corrections before editorial review. The basic profile request is free, requires no payment details and does not guarantee publication, traffic or ranking. Submit only details you are authorized to provide through the YouNew business form: {BUSINESS_EN}.

**NL:** Vraag een beknopt EN/NL-bedrijfsprofiel aan op basis van openbare feiten: categorie, bezoekadres, officiële website en contactgegevens. Je kunt feitelijke correcties indienen vóór de redactionele beoordeling. De aanvraag voor een basisprofiel is gratis, vraagt geen betaalgegevens en garandeert geen publicatie, bezoekers of positie in de zoekresultaten. Verstrek via het YouNew-bedrijfsformulier alleen gegevens die je bevoegd bent te delen: {BUSINESS_NL}.
