import Foundation

enum MockNetherlandsUnderstandingData {
    static let timeline: [CivicTimelineItem] = [
        timelineItem("prehistory", "leaf.fill", .beginner),
        timelineItem("roman", "building.columns.fill", .beginner),
        timelineItem("middleAges", "shield.lefthalf.filled", .beginner),
        timelineItem("towns", "map.fill", .beginner),
        timelineItem("burgundian", "seal.fill", .intermediate),
        timelineItem("habsburg", "crown.fill", .intermediate),
        timelineItem("revolt", "flag.fill", .intermediate),
        timelineItem("goldenAge", "shippingbox.fill", .beginner),
        timelineItem("frenchPeriod", "scroll.fill", .intermediate),
        timelineItem("kingdom", "crown.fill", .beginner),
        timelineItem("worldWars", "flame.fill", .beginner),
        timelineItem("decolonization", "globe.europe.africa.fill", .intermediate),
        timelineItem("modern", "person.3.sequence.fill", .beginner)
    ]

    static let monarchyCards: [CivicInfoCardItem] = [
        card("king-role", .monarchy, ("What does the King actually do?", "Wat doet de Koning eigenlijk?", "Что на практике делает король?"), ("The King is head of state in a constitutional monarchy.", "De Koning is staatshoofd in een constitutionele monarchie.", "Король является главой государства в конституционной монархии."), ("The King signs laws and royal decrees, reads the Speech from the Throne, receives foreign ambassadors, and represents the Kingdom. Ministers are politically responsible for government policy.", "De Koning ondertekent wetten en koninklijke besluiten, leest de Troonrede, ontvangt buitenlandse ambassadeurs en vertegenwoordigt het Koninkrijk. Ministers zijn politiek verantwoordelijk voor regeringsbeleid.", "Король подписывает законы и королевские указы, зачитывает тронную речь, принимает иностранных послов и представляет Королевство. Политическую ответственность за политику правительства несут министры."), "crown.fill", .beginner, "https://www.government.nl/topics/constitution/constitutional-monarchy", ["king", "monarchy", "constitution", "head of state", "король", "монархия"]),
        card("monarchy-funded", .monarchy, ("How is the monarchy funded?", "Hoe wordt de monarchie betaald?", "Как финансируется монархия?"), ("Funding is set through public budgets and official arrangements.", "De financiering loopt via publieke begrotingen en officiële regelingen.", "Финансирование определяется через государственный бюджет и официальные правила."), ("The Royal House has budget lines for constitutional duties, staff, and official expenses. Details are published by government sources and can change over time.", "Het Koninklijk Huis heeft begrotingsposten voor constitutionele taken, personeel en officiële kosten. Details worden door overheidsbronnen gepubliceerd en kunnen veranderen.", "У Королевского дома есть бюджетные статьи для конституционных обязанностей, персонала и официальных расходов. Детали публикуются государственными источниками и могут меняться."), "banknote.fill", .intermediate, "https://www.royal-house.nl/topics/themes/monarchy", ["funding", "budget", "royal house", "бюджет"]),
        card("why-monarchy", .monarchy, ("Why does the Netherlands still have a monarchy?", "Waarom heeft Nederland nog een monarchie?", "Почему в Нидерландах всё ещё есть монархия?"), ("The monarchy is part of the constitutional structure and national tradition.", "De monarchie is onderdeel van de constitutionele structuur en nationale traditie.", "Монархия является частью конституционного устройства и национальной традиции."), ("In practice, elected politicians make policy decisions. The monarch has a formal and representative role within rules set by the Constitution.", "In de praktijk maken gekozen politici beleidskeuzes. De monarch heeft een formele en representatieve rol binnen regels van de Grondwet.", "На практике политические решения принимают избранные политики. Монарх выполняет формальную и представительскую роль в рамках Конституции."), "building.columns.fill", .beginner, "https://www.royal-house.nl/topics/themes/monarchy", ["tradition", "constitution", "ceremonial", "конституция"]),
        card("kings-day", .monarchy, ("King's Day", "Koningsdag", "День короля"), ("King's Day is a national public celebration around the monarch's birthday.", "Koningsdag is een nationale publieke viering rond de verjaardag van de monarch.", "День короля — национальный праздник, связанный с днём рождения монарха."), ("Many towns have markets, music, and local events. It is a cultural celebration, not a requirement to participate.", "Veel plaatsen hebben markten, muziek en lokale events. Het is een culturele viering, geen verplichting om mee te doen.", "Во многих городах проходят рынки, музыка и местные события. Это культурный праздник, участие не является обязанностью."), "flag.fill", .beginner, "https://www.royal-house.nl", ["king's day", "koningsdag", "culture", "день короля"])
    ]

    static let politicsCards: [CivicInfoCardItem] = [
        card("who-makes-laws", .politics, ("Who makes laws?", "Wie maakt wetten?", "Кто принимает законы?"), ("Government and parliament both have legislative powers.", "Regering en parlement hebben beide wetgevende bevoegdheden.", "Законодательные полномочия есть и у правительства, и у парламента."), ("A law usually needs approval by the Tweede Kamer and Eerste Kamer. The government proposes many bills, but parliament reviews, amends, and votes.", "Een wet heeft meestal goedkeuring nodig van de Tweede Kamer en Eerste Kamer. De regering stelt veel wetsvoorstellen voor, maar het parlement beoordeelt, wijzigt en stemt.", "Закон обычно должен пройти Tweede Kamer и Eerste Kamer. Правительство часто предлагает законопроекты, но парламент рассматривает, меняет и голосует."), "doc.text.fill", .beginner, "https://www.government.nl/topics/parliament/relationship-between-government-and-parliament", ["laws", "parliament", "government", "законы", "парламент"]),
        card("elections", .politics, ("How are elections organized?", "Hoe worden verkiezingen georganiseerd?", "Как устроены выборы?"), ("Dutch voters elect representatives at different government levels.", "Nederlandse kiezers kiezen vertegenwoordigers op verschillende bestuursniveaus.", "Избиратели выбирают представителей на разных уровнях власти."), ("There are elections for the Tweede Kamer, municipal councils, provincial councils, water authorities, and the European Parliament. Eligibility differs by election type.", "Er zijn verkiezingen voor de Tweede Kamer, gemeenteraden, Provinciale Staten, waterschappen en het Europees Parlement. Kiesrecht verschilt per verkiezingstype.", "Выборы проходят в Tweede Kamer, муниципальные советы, провинциальные советы, водные управления и Европейский парламент. Право голоса зависит от типа выборов."), "checkmark.seal.fill", .beginner, "https://www.government.nl/themes/government-and-democracy/elections", ["elections", "voting", "municipality", "province", "выборы"]),
        card("tweede-kamer", .politics, ("What is the Tweede Kamer?", "Wat is de Tweede Kamer?", "Что такое Tweede Kamer?"), ("The Tweede Kamer is the directly elected House of Representatives.", "De Tweede Kamer is de rechtstreeks gekozen volksvertegenwoordiging.", "Tweede Kamer — напрямую избираемая нижняя палата парламента."), ("It debates laws, checks the government, asks questions, and can change proposed legislation. It has 150 members.", "Zij debatteert over wetten, controleert de regering, stelt vragen en kan wetsvoorstellen wijzigen. De Kamer heeft 150 leden.", "Она обсуждает законы, контролирует правительство, задаёт вопросы и может менять законопроекты. В палате 150 депутатов."), "person.3.fill", .beginner, "https://www.houseofrepresentatives.nl/how-parliament-works/democracy-netherlands", ["tweede kamer", "house of representatives", "150", "парламент"]),
        card("eerste-kamer", .politics, ("What is the Eerste Kamer?", "Wat is de Eerste Kamer?", "Что такое Eerste Kamer?"), ("The Eerste Kamer is the Senate.", "De Eerste Kamer is de senaat.", "Eerste Kamer — сенат, верхняя палата парламента."), ("It reviews bills after the Tweede Kamer. It cannot amend a bill, but it can approve or reject it. Senators are elected indirectly.", "Zij beoordeelt wetsvoorstellen na de Tweede Kamer. Zij kan een wetsvoorstel niet wijzigen, maar wel aannemen of verwerpen. Senatoren worden indirect gekozen.", "Она рассматривает законопроекты после Tweede Kamer. Изменять текст она не может, но может одобрить или отклонить закон. Сенаторов выбирают непрямым способом."), "building.2.fill", .intermediate, "https://www.houseofrepresentatives.nl/how-parliament-works/democracy-netherlands", ["eerste kamer", "senate", "indirect", "сенат"]),
        card("prime-minister", .politics, ("What does the Prime Minister do?", "Wat doet de minister-president?", "Что делает премьер-министр?"), ("The Prime Minister chairs the cabinet and coordinates government policy.", "De minister-president leidt de ministerraad en coordineert regeringsbeleid.", "Премьер-министр возглавляет совет министров и координирует политику правительства."), ("The Prime Minister is not a president. The role is important, but policy depends on the cabinet, coalition agreements, parliament, and law.", "De minister-president is geen president. De rol is belangrijk, maar beleid hangt af van kabinet, coalitieafspraken, parlement en wet.", "Премьер-министр не является президентом. Роль важная, но политика зависит от кабинета, коалиционных договорённостей, парламента и закона."), "person.crop.circle.badge.checkmark", .beginner, "https://www.government.nl/topics/constitution", ["prime minister", "minister-president", "cabinet", "премьер-министр"]),
        card("local-government", .politics, ("Municipalities and provinces", "Gemeenten en provincies", "Муниципалитеты и провинции"), ("Local government handles many practical parts of daily life.", "Lokaal bestuur regelt veel praktische onderdelen van het dagelijks leven.", "Местное управление отвечает за многие практические части повседневной жизни."), ("Municipalities handle registration, local permits, waste rules, social support, and local services. Provinces handle regional planning, transport, nature, and supervision tasks.", "Gemeenten regelen inschrijving, lokale vergunningen, afvalregels, sociale ondersteuning en lokale diensten. Provincies regelen regionale planning, vervoer, natuur en toezichtstaken.", "Gemeente занимается регистрацией, местными разрешениями, мусором, социальной поддержкой и городскими услугами. Провинции отвечают за региональное планирование, транспорт, природу и надзорные задачи."), "map.fill", .beginner, "https://www.government.nl/topics/municipalities", ["gemeente", "province", "local government", "муниципалитет", "провинция"])
    ]

    static let societyCards: [CivicInfoCardItem] = [
        card("direct-communication", .society, ("Direct communication", "Directe communicatie", "Прямое общение"), ("Dutch communication can be clear and direct, especially in work and appointments.", "Nederlandse communicatie kan duidelijk en direct zijn, vooral op werk en bij afspraken.", "Нидерландское общение часто ясное и прямое, особенно на работе и при записях."), ("Directness is not always meant as rudeness. It often reflects a preference for clarity, planning, and practical next steps.", "Directheid is niet altijd onbeleefd bedoeld. Het weerspiegelt vaak een voorkeur voor duidelijkheid, planning en praktische vervolgstappen.", "Прямота не всегда означает грубость. Часто это стремление к ясности, планированию и практическим следующим шагам."), "bubble.left.and.text.bubble.right.fill", .beginner, nil, ["communication", "culture", "work", "общение"]),
        card("planning", .society, ("Planning culture", "Planningscultuur", "Культура планирования"), ("Appointments, calendars, and advance notice are common.", "Afspraken, agenda's en vooraf plannen zijn gebruikelijk.", "Записи, календари и предупреждение заранее здесь обычны."), ("Many services require booking. Friends, doctors, municipalities, and schools may expect appointments rather than walk-ins.", "Veel diensten vragen om een afspraak. Vrienden, artsen, gemeenten en scholen verwachten vaak afspraken in plaats van spontaan langskomen.", "Многие услуги требуют записи. Друзья, врачи, gemeente и школы часто ожидают afspraak, а не внезапный визит."), "calendar", .beginner, nil, ["appointments", "planning", "calendar", "afspraak", "планирование"]),
        card("equality", .society, ("Equality and informal manners", "Gelijkheid en informele omgang", "Равенство и неформальное общение"), ("Many workplaces and schools use informal communication and first names.", "Veel werkplekken en scholen gebruiken informele communicatie en voornamen.", "Во многих школах и на работе используют неформальное общение и имена."), ("This does not mean hierarchy never exists. It means people often value approachable communication and being able to ask questions.", "Dit betekent niet dat hierarchie niet bestaat. Het betekent dat mensen vaak toegankelijke communicatie en vragen stellen waarderen.", "Это не значит, что иерархии нет. Это значит, что часто ценят доступное общение и возможность задавать вопросы."), "equal.circle.fill", .beginner, nil, ["equality", "school", "work", "равенство"]),
        card("cycling", .society, ("Cycling culture", "Fietscultuur", "Велосипедная культура"), ("Cycling is everyday transport, not only sport.", "Fietsen is dagelijks vervoer, niet alleen sport.", "Велосипед — повседневный транспорт, а не только спорт."), ("Bike lanes, lights, parking rules, and priority rules matter. Newcomers should learn local cycling norms before riding in busy areas.", "Fietspaden, verlichting, parkeerregels en voorrangsregels zijn belangrijk. Nieuwkomers doen er goed aan lokale fietsnormen te leren voor drukke gebieden.", "Важны велодорожки, свет, парковка и правила приоритета. Новичкам стоит изучить местные нормы до поездок в загруженных местах."), "bicycle", .beginner, nil, ["fiets", "cycling", "traffic", "велосипед"]),
        card("work-life", .society, ("Work-life balance", "Werk-privébalans", "Баланс работы и личной жизни"), ("Many people value predictable work hours and private time.", "Veel mensen hechten waarde aan voorspelbare werktijden en privé-tijd.", "Многие ценят предсказуемые рабочие часы и личное время."), ("This varies by job and sector, but boundaries around evenings, weekends, holidays, and childcare are often taken seriously.", "Dit verschilt per baan en sector, maar grenzen rond avonden, weekenden, vakanties en kinderopvang worden vaak serieus genomen.", "Это зависит от работы и сектора, но границы вечеров, выходных, отпусков и ухода за детьми часто воспринимаются серьёзно."), "briefcase.fill", .beginner, nil, ["work", "life", "balance", "работа"]),
        card("volunteer", .society, ("Volunteer culture", "Vrijwilligerscultuur", "Культура волонтёрства"), ("Local clubs, schools, sports, and neighborhoods often rely on volunteers.", "Lokale verenigingen, scholen, sportclubs en buurten steunen vaak op vrijwilligers.", "Местные клубы, школы, спорт и районы часто опираются на волонтёров."), ("Volunteering can be a practical way to meet people, learn Dutch, and understand local routines.", "Vrijwilligerswerk kan een praktische manier zijn om mensen te ontmoeten, Nederlands te oefenen en lokale routines te begrijpen.", "Волонтёрство может помочь познакомиться с людьми, практиковать нидерландский и понять местные привычки."), "hands.sparkles.fill", .beginner, nil, ["volunteer", "community", "local", "волонтёрство"])
    ]

    static let cultureArticles: [InfoArticle] = [
        infoArticle(
            id: "dutch-daily-culture",
            type: .culture,
            title: infoText("Dutch daily culture", "Nederlandse dagelijkse cultuur", "Повседневная культура Нидерландов"),
            subtitle: infoText("Planning, equality, directness, and local routines.", "Plannen, gelijkheid, directheid en lokale routines.", "Планирование, равенство, прямота и местные привычки."),
            summary: infoText("Daily life often runs through appointments, clear communication, cycling or public transport, and local rules set by the municipality.", "Het dagelijks leven loopt vaak via afspraken, duidelijke communicatie, fiets of ov, en lokale regels van de gemeente.", "Повседневная жизнь часто строится вокруг записей, ясного общения, велосипеда или OV и местных правил gemeente."),
            practicalNote: infoText("Check local opening hours, book appointments early, and keep written confirmations.", "Controleer lokale openingstijden, maak afspraken op tijd en bewaar bevestigingen.", "Проверяйте часы работы, записывайтесь заранее и сохраняйте подтверждения."),
            symbol: "person.3.sequence.fill",
            tags: ["culture", "daily life", "planning"],
            sources: [source("workinnl-culture")]
        ),
        infoArticle(
            id: "cycling-culture",
            type: .culture,
            title: infoText("Cycling culture", "Fietscultuur", "Велосипедная культура"),
            subtitle: infoText("Bikes are everyday transport, not only recreation.", "Fietsen is dagelijks vervoer, niet alleen recreatie.", "Велосипед - повседневный транспорт, а не только отдых."),
            summary: infoText("Cycling is built into ordinary trips, but newcomers still need to learn lights, parking, priority, and phone-use rules.", "Fietsen hoort bij gewone ritten, maar nieuwkomers moeten verlichting, parkeren, voorrang en telefoongebruik leren.", "Велосипед входит в обычные поездки, но новичкам нужно изучить свет, парковку, приоритет и правила телефона."),
            practicalNote: infoText("Start on quieter routes, use lights in the dark, and check municipality bike-parking rules near stations.", "Begin op rustigere routes, gebruik licht in het donker en controleer fietsparkeerregels bij stations.", "Начинайте на спокойных маршрутах, включайте свет в темноте и проверяйте правила парковки у станций."),
            symbol: "bicycle",
            tags: ["cycling", "transport", "rules"],
            sources: [source("government-bicycles"), source("dutch-cycling-embassy")]
        ),
        infoArticle(
            id: "water-and-netherlands",
            type: .culture,
            title: infoText("Water and the Netherlands", "Water en Nederland", "Вода и Нидерланды"),
            subtitle: infoText("Water management shaped cities, landscapes, and institutions.", "Waterbeheer vormde steden, landschappen en instituties.", "Управление водой сформировало города, ландшафты и институты."),
            summary: infoText("Canals, dikes, polders, windmills, and flood works are practical infrastructure as well as heritage.", "Kanalen, dijken, polders, molens en deltawerken zijn praktische infrastructuur en erfgoed.", "Каналы, дамбы, польдеры, мельницы и защитные сооружения - инфраструктура и наследие."),
            practicalNote: infoText("Use this topic to understand why water boards, local drainage, and flood protection appear in Dutch public life.", "Gebruik dit onderwerp om waterschappen, afwatering en hoogwaterbescherming in het openbare leven te begrijpen.", "Эта тема помогает понять waterschappen, дренаж и защиту от наводнений."),
            symbol: "water.waves",
            tags: ["water", "history", "heritage"],
            sources: [source("government-water"), source("kinderdijk-official")]
        ),
        infoArticle(
            id: "canals-city-centres",
            type: .culture,
            title: infoText("Canals and city centres", "Grachten en binnensteden", "Каналы и исторические центры"),
            subtitle: infoText("Historic canals are transport history, water management, and urban design.", "Historische grachten zijn vervoersgeschiedenis, waterbeheer en stadsontwerp.", "Исторические каналы - транспортная история, управление водой и городская структура."),
            summary: infoText("Amsterdam, Leiden, Delft, and Utrecht show different canal patterns; check local access and boating rules before using the water.", "Amsterdam, Leiden, Delft en Utrecht tonen verschillende grachtenpatronen; controleer lokale toegang en vaarregels.", "Амстердам, Лейден, Делфт и Утрехт показывают разные типы каналов; проверяйте местные правила."),
            practicalNote: infoText("For walking, choose compact routes around stations and old centres; for boats, use local operator or municipality guidance.", "Kies wandelroutes rond stations en binnensteden; gebruik voor varen lokale aanbieder- of gemeentelijke informatie.", "Для прогулок выбирайте маршруты от станции и центра; для лодок смотрите местные правила."),
            symbol: "sailboat.fill",
            tags: ["canals", "cities", "heritage"],
            sources: [source("unesco-amsterdam-canals"), source("utrecht-canals")]
        ),
        infoArticle(
            id: "museums-public-culture",
            type: .culture,
            title: infoText("Museums and public culture", "Musea en publieke cultuur", "Музеи и общественная культура"),
            subtitle: infoText("Museums are common entry points into Dutch art, history, science, and civic life.", "Musea zijn toegankelijke ingangen tot kunst, geschiedenis, wetenschap en samenleving.", "Музеи - удобный вход в искусство, историю, науку и общественную жизнь."),
            summary: infoText("Major museums publish practical visitor information and many cities have local museums, archives, libraries, and cultural centres.", "Grote musea publiceren praktische bezoekersinformatie en veel steden hebben lokale musea, archieven, bibliotheken en cultuurcentra.", "Крупные музеи публикуют практическую информацию, а города имеют местные музеи, архивы, библиотеки и центры культуры."),
            practicalNote: infoText("Book timed tickets when required and check free library or museum-card options separately.", "Boek tijdsloten waar nodig en controleer bibliotheek- of museumkaartopties apart.", "Бронируйте слоты, если нужно, и отдельно проверяйте библиотеки или Museumkaart."),
            symbol: "building.columns.fill",
            tags: ["museums", "culture", "public life"],
            sources: [source("rijksmuseum-visit"), source("cbs-culture")]
        ),
        infoArticle(
            id: "markets-local-life",
            type: .culture,
            title: infoText("Markets and local life", "Markten en lokaal leven", "Рынки и местная жизнь"),
            subtitle: infoText("Weekly markets are useful for food, routines, and neighbourhood orientation.", "Weekmarkten zijn handig voor eten, routines en buurtoriëntatie.", "Еженедельные рынки помогают с едой, привычками и знакомством с районом."),
            summary: infoText("Market days, locations, and rules are local. Municipality websites usually list permits, street markets, and public-space rules.", "Marktdagen, locaties en regels zijn lokaal. Gemeentesites vermelden meestal markten, vergunningen en regels voor openbare ruimte.", "Дни, места и правила рынков местные. Сайты gemeente обычно публикуют рынки и правила."),
            practicalNote: infoText("Check your municipality before assuming a market runs every day or accepts every payment method.", "Controleer je gemeente voordat je aanneemt dat een markt elke dag open is of elke betaalmethode accepteert.", "Проверяйте gemeente: рынок может быть не каждый день и не всегда принимает все способы оплаты."),
            symbol: "basket.fill",
            tags: ["markets", "municipality", "daily life"],
            sources: [source("government-municipalities")]
        ),
        infoArticle(
            id: "direct-communication-style",
            type: .culture,
            title: infoText("Dutch direct communication style", "Nederlandse directe communicatie", "Нидерландский прямой стиль общения"),
            subtitle: infoText("Directness often signals clarity, not personal hostility.", "Directheid betekent vaak duidelijkheid, niet persoonlijke vijandigheid.", "Прямота часто означает ясность, а не личную неприязнь."),
            summary: infoText("In work, school, and appointments, people may state problems and next steps plainly. Written confirmation is normal for practical agreements.", "Op werk, school en bij afspraken benoemen mensen problemen en vervolgstappen vaak duidelijk. Schriftelijke bevestiging is normaal.", "На работе, учебе и встречах проблемы и следующие шаги часто формулируют прямо. Письменные подтверждения нормальны."),
            practicalNote: infoText("Ask follow-up questions and confirm deadlines, documents, and responsibilities in writing.", "Stel vervolgvragen en bevestig deadlines, documenten en verantwoordelijkheden schriftelijk.", "Задавайте уточняющие вопросы и подтверждайте сроки, документы и ответственность письменно."),
            symbol: "bubble.left.and.text.bubble.right.fill",
            tags: ["communication", "work", "culture"],
            sources: [source("workinnl-culture")]
        )
    ]

    static let attractionArticles: [InfoArticle] = [
        attraction("amsterdam-canals", "Amsterdam canals", "Amsterdamse grachten", "Каналы Амстердама", "UNESCO canal-ring area and compact city walking routes.", "UNESCO-grachtengordel en compacte stadswandelroutes.", "Каналное кольцо UNESCO и компактные маршруты по городу.", "The 17th-century canal ring is useful for understanding Amsterdam's water, trade, and urban-planning history.", "De 17e-eeuwse grachtengordel helpt water-, handels- en stadsplanningsgeschiedenis te begrijpen.", "Каналное кольцо XVII века помогает понять историю воды, торговли и планировки.", "Walk or use public transport; verify boat tours and crowd rules locally.", "Loop of gebruik ov; controleer rondvaart- en drukteregels lokaal.", "Ходите пешком или на OV; правила лодок и толпы проверяйте на месте.", "sailboat.fill", ["Amsterdam"], ["unesco-amsterdam-canals"]),
        attraction("rijksmuseum-museumplein", "Rijksmuseum / Museumplein", "Rijksmuseum / Museumplein", "Rijksmuseum / Museumplein", "National museum area in Amsterdam with official visitor information.", "Nationaal museumgebied in Amsterdam met officiële bezoekersinformatie.", "Музейный район Амстердама с официальной информацией для посетителей.", "Use Museumplein as a practical orientation point for major museums and public transport.", "Gebruik Museumplein als praktisch oriëntatiepunt voor grote musea en ov.", "Используйте Museumplein как ориентир для крупных музеев и транспорта.", "Book tickets and check opening hours directly with each museum.", "Boek tickets en controleer openingstijden direct bij elk museum.", "Бронируйте билеты и проверяйте часы напрямую у музеев.", "paintpalette.fill", ["Amsterdam"], ["rijksmuseum-visit"]),
        attraction("leiden-old-centre-canals", "Leiden old centre and canals", "Oude centrum en grachten van Leiden", "Старый центр и каналы Лейдена", "University-city streets, canals, courtyards, museums, and station-friendly walks.", "Universiteitsstad met straten, grachten, hofjes, musea en wandelroutes vanaf station.", "Университетский город с улицами, каналами, двориками, музеями и прогулками от станции.", "Leiden is a compact historic city where newcomers can combine culture with practical city orientation.", "Leiden is een compacte historische stad waar cultuur en praktische oriëntatie samenkomen.", "Лейден - компактный исторический город, где культура сочетается с ориентацией.", "Start near Leiden Centraal and check museum or boat information before planning.", "Begin bij Leiden Centraal en controleer museum- of vaartinformatie vooraf.", "Начинайте у Leiden Centraal и заранее проверяйте музеи или лодки.", "building.2.crop.circle.fill", ["Leiden"], ["holland-leiden"]),
        attraction("delft-historic-centre", "Delft historic centre", "Historische binnenstad Delft", "Исторический центр Делфта", "Canals, Delft Blue, Vermeer links, and a walkable centre.", "Grachten, Delfts Blauw, Vermeer-links en een beloopbare binnenstad.", "Каналы, Delfts Blauw, связь с Вермеером и удобный центр.", "The municipality presents Delft as a cultural destination with a historic inner city and well-known heritage themes.", "De gemeente presenteert Delft als culturele bestemming met historische binnenstad en bekend erfgoed.", "Муниципалитет представляет Делфт как культурное направление с историческим центром.", "Use the municipality or official visitor site for current access and events.", "Gebruik de gemeente of officiële bezoekerssite voor actuele toegang en events.", "Проверяйте доступ и события на официальных городских ресурсах.", "camera.aperture", ["Delft"], ["delft-tourists"]),
        attraction("the-hague-binnenhof", "The Hague political centre / Binnenhof area", "Politiek centrum Den Haag / Binnenhofgebied", "Политический центр Гааги / район Binnenhof", "Historic government area with renovation-related visitor limits.", "Historisch regeringsgebied met bezoekersbeperkingen door renovatie.", "Исторический правительственный район с ограничениями из-за ремонта.", "The Binnenhof area is central to Dutch political history, but access can change during renovation works.", "Het Binnenhofgebied is belangrijk voor politieke geschiedenis, maar toegang kan veranderen tijdens renovatie.", "Binnenhof важен для политической истории, но доступ меняется из-за ремонта.", "Check official renovation or city visitor information before visiting.", "Controleer officiële renovatie- of stadsinformatie voor bezoek.", "Проверяйте официальную информацию о ремонте или городе перед визитом.", "building.columns.fill", ["Den Haag"], ["binnenhof-renovation"]),
        attraction("kinderdijk-windmills", "Dutch windmill water heritage", "Nederlands molenerfgoed", "Нидерландское наследие мельниц", "UNESCO water-management heritage near Rotterdam and Dordrecht.", "UNESCO-watererfgoed bij Rotterdam en Dordrecht.", "Водное наследие UNESCO рядом с Роттердамом и Дордрехтом.", "This heritage site explains Dutch polder water management through windmills, waterways, and pumping stations.", "Dit erfgoed legt Nederlands polderwaterbeheer uit via molens, watergangen en gemalen.", "Этот объект наследия объясняет управление водой в польдерах через мельницы, каналы и насосные станции.", "Use official ticket and route information; protect residential and heritage areas.", "Gebruik officiële ticket- en routeinformatie; respecteer woon- en erfgoedgebied.", "Используйте официальные билеты и маршруты; уважайте жилую и наследную территорию.", "wind", ["Rotterdam"], ["kinderdijk-official", "unesco-kinderdijk"]),
        attraction("delta-works", "Delta Works", "Deltawerken", "Delta Works"),
        attraction("utrecht-canals", "Utrecht canals", "Utrechtse grachten", "Каналы Утрехта", "Wharf-level canals and a compact historic centre.", "Werfgrachten en een compacte historische binnenstad.", "Каналы с нижним уровнем набережных и компактный исторический центр.", "Utrecht's canals are closely tied to city logistics, heritage, and public-space use.", "Utrechtse grachten zijn verbonden met logistiek, erfgoed en gebruik van openbare ruimte.", "Каналы Утрехта связаны с логистикой, наследием и городским пространством.", "Check municipality boating and public-space rules before using the water.", "Controleer gemeentelijke vaar- en openbare-ruimteregels voor je het water op gaat.", "Перед выходом на воду проверяйте правила gemeente.", "water.waves", ["Utrecht"], ["utrecht-canals"]),
        attraction("rotterdam-architecture", "Rotterdam architecture", "Architectuur in Rotterdam", "Архитектура Роттердама", "Modern architecture, port-city identity, and experimental urban development.", "Moderne architectuur, havenidentiteit en experimentele stadsontwikkeling.", "Современная архитектура, портовая идентичность и экспериментальное развитие.", "Rotterdam is useful for understanding how post-war rebuilding and port-city growth shaped a different Dutch urban image.", "Rotterdam laat zien hoe wederopbouw en havengroei een ander Nederlands stadsbeeld vormden.", "Роттердам показывает, как восстановление и порт сформировали другой городской образ.", "Use official visitor information for routes and building access.", "Gebruik officiële bezoekersinformatie voor routes en toegang tot gebouwen.", "Проверяйте маршруты и доступ к зданиям на официальных ресурсах.", "building.2.fill", ["Rotterdam"], ["rotterdam-tourism"]),
        attraction("maastricht-historic-centre", "Maastricht historic centre", "Historische binnenstad Maastricht", "Исторический центр Маастрихта", "River-city centre with historic streets, churches, squares, and reused heritage buildings.", "Rivierstad met historische straten, kerken, pleinen en hergebruikte monumenten.", "Речной город с историческими улицами, церквями, площадями и переиспользованными зданиями.", "Maastricht helps newcomers see a southern, border-region version of Dutch urban history.", "Maastricht laat een zuidelijke grensregio-versie van Nederlandse stadsgeschiedenis zien.", "Маастрихт показывает южную, пограничную версию городской истории Нидерландов.", "Plan around station distance, hills, and opening hours for churches or museums.", "Plan rond stationsafstand, hoogteverschillen en openingstijden van kerken of musea.", "Учитывайте расстояние от станции, подъемы и часы церквей или музеев.", "map.fill", ["Maastricht"], ["visit-maastricht-centre"])
    ]

    static let cityInfoProfiles: [CityInfoProfile] = {
        let profiles = [
            cityInfo(
                cityId: "Amsterdam",
                provinceId: "Noord-Holland",
                population: "872 000",
                area: "218,3 km²",
                website: "https://www.amsterdam.nl",
                title: infoText("Amsterdam", "Amsterdam", "Амстердам"),
                subtitle: infoText("International capital city with strong culture, transport, and housing pressure.", "Internationale hoofdstad met veel cultuur, vervoer en woningdruk.", "Международная столица с сильной культурой, транспортом и давлением на жильё."),
                summary: infoText("Start with municipality registration, DigiD, health insurance, transport choices, and careful housing verification.", "Begin met inschrijving, DigiD, zorgverzekering, vervoer en zorgvuldige woningcontrole.", "Начните с регистрации, DigiD, страховки, транспорта и тщательной проверки жилья."),
                guides: ["firstStepsNetherlands", "municipalityRegistration", "digidSafety", "healthInsuranceBasics", "transportBasics", "housingBasics"],
                attractions: ["amsterdam-canals", "rijksmuseum-museumplein"],
                articles: ["cycling-culture", "canals-city-centres", "museums-public-culture"],
                sources: ["municipality-amsterdam", "gvb", "iamsterdam", "government-municipalities"]
            ),
            cityInfo(
                cityId: "Leiden",
                provinceId: "Zuid-Holland",
                population: "127 000",
                area: "58,0 km²",
                website: "https://www.leiden.nl",
                title: infoText("Leiden", "Leiden", "Лейден"),
                subtitle: infoText("Historic university city between Amsterdam and The Hague.", "Historische universiteitsstad tussen Amsterdam en Den Haag.", "Исторический университетский город между Амстердамом и Гаагой."),
                summary: infoText("Use the city centre, station, university context, museums, library, and municipality services as practical orientation points.", "Gebruik binnenstad, station, universiteitscontext, musea, bibliotheek en gemeente als oriëntatiepunten.", "Используйте центр, вокзал, университетскую среду, музеи, библиотеку и gemeente как ориентиры."),
                guides: ["firstStepsNetherlands", "municipalityRegistration", "findingHuisarts", "transportBasics", "officialSourcesChecklist"],
                attractions: ["leiden-old-centre-canals"],
                articles: ["canals-city-centres", "museums-public-culture", "direct-communication-style"],
                sources: ["municipality-leiden", "holland-leiden", "government-municipalities"]
            ),
            cityInfo(
                cityId: "Rotterdam",
                provinceId: "Zuid-Holland",
                population: "664 000",
                area: "324,1 km²",
                website: "https://www.rotterdam.nl",
                title: infoText("Rotterdam", "Rotterdam", "Роттердам"),
                subtitle: infoText("Large port city with modern architecture and strong regional transport.", "Grote havenstad met moderne architectuur en sterk regionaal vervoer.", "Крупный портовый город с современной архитектурой и сильным транспортом."),
                summary: infoText("Newcomers should combine municipality registration, transport basics, work orientation, housing checks, and local official sources.", "Nieuwkomers combineren best inschrijving, vervoer, werkoriëntatie, woningcontrole en lokale bronnen.", "Новичкам важно объединить регистрацию, транспорт, работу, проверку жилья и местные источники."),
                guides: ["firstStepsNetherlands", "municipalityRegistration", "transportBasics", "housingBasics", "bankingBasics"],
                attractions: ["rotterdam-architecture", "kinderdijk-windmills"],
                articles: ["water-and-netherlands", "cycling-culture", "markets-local-life"],
                sources: ["municipality-rotterdam", "rotterdam-tourism", "ret", "government-municipalities"]
            ),
            cityInfo(
                cityId: "Den Haag",
                provinceId: "Zuid-Holland",
                population: "563 000",
                area: "98,1 km²",
                website: "https://www.denhaag.nl",
                title: infoText("The Hague", "Den Haag", "Гаага"),
                subtitle: infoText("Government city with international institutions and a large newcomer community.", "Regeringsstad met internationale instellingen en veel nieuwkomers.", "Правительственный город с международными институтами и большим сообществом newcomers."),
                summary: infoText("Focus on registration, official letters, legal orientation, healthcare, transport, and verifying city-specific instructions.", "Focus op inschrijving, officiële brieven, juridische oriëntatie, zorg, vervoer en lokale instructies.", "Сфокусируйтесь на регистрации, письмах, правовой ориентации, медицине, транспорте и местных инструкциях."),
                guides: ["firstStepsNetherlands", "municipalityRegistration", "officialSourcesChecklist", "healthcareBasics", "transportBasics"],
                attractions: ["the-hague-binnenhof"],
                articles: ["direct-communication-style", "museums-public-culture"],
                sources: ["municipality-den-haag", "binnenhof-renovation", "htm", "government-municipalities"]
            ),
            cityInfo(
                cityId: "Utrecht",
                provinceId: "Utrecht",
                population: "367 000",
                area: "99,2 km²",
                website: "https://www.utrecht.nl",
                title: infoText("Utrecht", "Utrecht", "Утрехт"),
                subtitle: infoText("Central rail hub and historic canal city.", "Centraal spoorknooppunt en historische grachtenstad.", "Центральный железнодорожный узел и исторический город каналов."),
                summary: infoText("Use Utrecht as a practical base for transport, cycling, municipality registration, healthcare access, and canal-city orientation.", "Gebruik Utrecht als basis voor vervoer, fietsen, inschrijving, zorg en grachtenoriëntatie.", "Используйте Утрехт как базу для транспорта, велосипеда, регистрации, медицины и ориентации по каналам."),
                guides: ["firstStepsNetherlands", "municipalityRegistration", "transportBasics", "findingHuisarts", "digidSafety"],
                attractions: ["utrecht-canals"],
                articles: ["cycling-culture", "canals-city-centres", "water-and-netherlands"],
                sources: ["municipality-utrecht", "utrecht-canals", "u-ov", "government-municipalities"]
            ),
            cityInfo(
                cityId: "Eindhoven",
                provinceId: "Noord-Brabant",
                population: "246 000",
                area: "88,9 km²",
                website: "https://www.eindhoven.nl",
                title: infoText("Eindhoven", "Eindhoven", "Эйндховен"),
                subtitle: infoText("North Brabant technology and design city.", "Technologie- en designstad in Noord-Brabant.", "Технологический и дизайнерский город Северного Брабанта."),
                summary: infoText("For settling in, prioritise municipality registration, housing checks, banking, transport, and work-study administration.", "Prioriteer inschrijving, woningcontrole, bankieren, vervoer en werk- of studieadministratie.", "Для адаптации важны регистрация, жильё, банк, транспорт и рабочие или учебные документы."),
                guides: ["firstStepsNetherlands", "municipalityRegistration", "housingBasics", "bankingBasics", "transportBasics"],
                attractions: [],
                articles: ["cycling-culture", "direct-communication-style", "markets-local-life"],
                sources: ["municipality-eindhoven", "hermes", "government-municipalities"]
            ),
            cityInfo(
                cityId: "Groningen",
                provinceId: "Groningen",
                population: "244 000",
                area: "197,8 km²",
                website: "https://gemeente.groningen.nl",
                title: infoText("Groningen", "Groningen", "Гронинген"),
                subtitle: infoText("Northern student city with strong cycling and regional services.", "Noordelijke studentenstad met sterke fietscultuur en regionale diensten.", "Северный студенческий город с сильной велосипедной культурой и региональными услугами."),
                summary: infoText("Newcomers should check student or work administration, municipality registration, local transport, healthcare access, and housing timing.", "Nieuwkomers controleren studie- of werkadministratie, inschrijving, vervoer, zorg en woningtiming.", "Новичкам стоит проверить учебные или рабочие документы, регистрацию, транспорт, медицину и сроки поиска жилья."),
                guides: ["firstStepsNetherlands", "municipalityRegistration", "healthInsuranceBasics", "findingHuisarts", "transportBasics"],
                attractions: [],
                articles: ["cycling-culture", "museums-public-culture", "direct-communication-style"],
                sources: ["municipality-groningen", "qbuzz", "government-municipalities"]
            ),
            cityInfo(
                cityId: "Maastricht",
                provinceId: "Limburg",
                population: "122 000",
                area: "60,0 km²",
                website: "https://www.maastricht.nl",
                title: infoText("Maastricht", "Maastricht", "Маастрихт"),
                subtitle: infoText("Historic Limburg city with international and border-region context.", "Historische Limburgse stad met internationale en grensregionale context.", "Исторический город Лимбурга с международным и пограничным контекстом."),
                summary: infoText("Check municipality registration, healthcare, banking, housing, local transport, and cross-border practical details where relevant.", "Controleer inschrijving, zorg, bankieren, wonen, lokaal vervoer en grenspraktijk waar relevant.", "Проверьте регистрацию, медицину, банк, жильё, местный транспорт и пограничные детали при необходимости."),
                guides: ["firstStepsNetherlands", "municipalityRegistration", "healthcareBasics", "bankingBasics", "housingBasics"],
                attractions: ["maastricht-historic-centre"],
                articles: ["museums-public-culture", "markets-local-life", "direct-communication-style"],
                sources: ["municipality-maastricht", "visit-maastricht-centre", "arriva", "government-municipalities"]
            )
        ]
        #if DEBUG
        assert(validateCityInfoProfiles(profiles).isEmpty, "City info profiles contain missing source references")
        #endif
        return profiles
    }()

    static var cityInfoProfileById: [String: CityInfoProfile] {
        Dictionary(cityInfoProfiles.map { ($0.cityId, $0) }, uniquingKeysWith: { first, _ in first })
    }

    static func cityInfoProfile(matching cityId: String) -> CityInfoProfile? {
        cityInfoProfileById[cityId] ?? cityInfoProfiles.first { $0.cityId.caseInsensitiveCompare(cityId) == .orderedSame }
    }

    static func infoSource(id: String) -> InfoSourceMetadata? {
        sourcesById[id]
    }

    static func sources(for ids: [String]) -> [InfoSourceMetadata] {
        ids.compactMap { sourcesById[$0] }
    }

    static func validateCityInfoProfiles(_ profiles: [CityInfoProfile] = cityInfoProfiles) -> [SourceValidationIssue] {
        profiles.flatMap { profile in
            profile.officialSourceIds.compactMap { sourceId in
                guard sourcesById[sourceId] == nil else { return nil }
                return SourceValidationIssue(
                    id: "\(profile.cityId)-\(sourceId)",
                    ownerId: profile.cityId,
                    sourceId: sourceId,
                    message: "Missing source metadata for \(sourceId)"
                )
            }
        }
    }

    static let glossary: [CivicGlossaryTerm] = [
        term("constitutional-monarchy", "Constitutional monarchy", "Constitutionele monarchie", "A system where a monarch is head of state, but political power is limited by the constitution and democratic institutions.", "Een systeem waarin een monarch staatshoofd is, maar politieke macht wordt beperkt door de grondwet en democratische instituties.", "Система, в которой монарх является главой государства, но политическая власть ограничена конституцией и демократическими институтами.", "The Netherlands is a constitutional monarchy.", "Nederland is een constitutionele monarchie.", "Нидерланды - конституционная монархия.", ["king", "constitution", "monarchy", "конституция", "монархия"]),
        term("tweede-kamer", "House of Representatives", "Tweede Kamer", "The directly elected chamber of parliament with 150 members.", "De rechtstreeks gekozen kamer van het parlement met 150 leden.", "Нижняя палата парламента, которую выбирают напрямую; в ней 150 депутатов.", "The Tweede Kamer debates laws and checks the government.", "De Tweede Kamer debatteert over wetten en controleert de regering.", "Tweede Kamer обсуждает законы и контролирует правительство.", ["parliament", "election", "laws", "парламент"]),
        term("eerste-kamer", "Senate", "Eerste Kamer", "The chamber that reviews bills after the Tweede Kamer and votes to approve or reject them.", "De kamer die wetsvoorstellen na de Tweede Kamer beoordeelt en stemt voor aannemen of verwerpen.", "Палата, которая рассматривает законопроекты после Tweede Kamer и голосует за одобрение или отклонение.", "The Eerste Kamer is elected indirectly.", "De Eerste Kamer wordt indirect gekozen.", "Eerste Kamer выбирается непрямым способом.", ["senate", "parliament", "сенат"]),
        term("coalition", "Coalition government", "Coalitieregering", "A government formed by multiple parties that agree to govern together.", "Een regering gevormd door meerdere partijen die afspreken samen te regeren.", "Правительство, сформированное несколькими партиями, которые договорились управлять вместе.", "Coalitions are common because many parties win seats.", "Coalities zijn gebruikelijk omdat veel partijen zetels halen.", "Коалиции обычны, потому что места получают разные партии.", ["parties", "government", "коалиция"]),
        term("gemeente", "Municipality", "Gemeente", "Local government for a city, town, or area.", "Lokaal bestuur voor een stad, dorp of gebied.", "Местная администрация города, посёлка или района.", "You register your address at the gemeente.", "Je schrijft je adres in bij de gemeente.", "Адрес регистрируют в gemeente.", ["local", "registration", "муниципалитет"]),
        term("provincie", "Province", "Provincie", "Regional government level between municipalities and the national government.", "Bestuurslaag tussen gemeenten en de nationale overheid.", "Региональный уровень управления между gemeente и национальным правительством.", "The Netherlands has 12 provinces.", "Nederland heeft 12 provincies.", "В Нидерландах 12 провинций.", ["region", "province", "провинция"]),
        term("overleg", "Consultation", "Overleg", "A structured discussion to coordinate decisions or solve practical problems.", "Een gestructureerd gesprek om besluiten af te stemmen of praktische problemen op te lossen.", "Структурированное обсуждение для согласования решений или практических вопросов.", "Many workplaces use overleg before changing plans.", "Veel werkplekken gebruiken overleg voor plannen veranderen.", "На многих работах overleg используют перед изменением планов.", ["culture", "planning", "обсуждение"])
    ]

    static let quiz: [CivicQuizQuestion] = [
        quiz("q-monarchy", ("In the Dutch constitutional system, who is politically responsible for government policy?", "Wie is in het Nederlandse constitutionele systeem politiek verantwoordelijk voor regeringsbeleid?", "Кто политически отвечает за политику правительства в нидерландской системе?"), (["The ministers", "The King alone", "Municipalities"], ["De ministers", "Alleen de Koning", "Gemeenten"], ["Министры", "Только король", "Муниципалитеты"]), 0, ("Ministers are accountable to parliament for government policy.", "Ministers leggen verantwoording af aan het parlement voor regeringsbeleid.", "Министры отвечают перед парламентом за политику правительства.")),
        quiz("q-tweede-kamer", ("What is the Tweede Kamer?", "Wat is de Tweede Kamer?", "Что такое Tweede Kamer?"), (["The directly elected House of Representatives", "A municipality office", "A royal advisory family"], ["De rechtstreeks gekozen volksvertegenwoordiging", "Een gemeentekantoor", "Een koninklijke adviesfamilie"], ["Напрямую избираемая нижняя палата парламента", "Офис gemeente", "Королевский консультативный круг"]), 0, ("The Tweede Kamer has 150 directly elected members.", "De Tweede Kamer heeft 150 rechtstreeks gekozen leden.", "В Tweede Kamer 150 депутатов, избираемых напрямую.")),
        quiz("q-gemeente", ("Which institution usually handles address registration?", "Welke organisatie regelt meestal adresinschrijving?", "Какая организация обычно занимается регистрацией адреса?"), (["Gemeente", "Eerste Kamer", "European Central Bank"], ["Gemeente", "Eerste Kamer", "Europese Centrale Bank"], ["Gemeente", "Eerste Kamer", "Европейский центральный банк"]), 0, ("Address registration is handled by your municipality.", "Adresinschrijving wordt geregeld door je gemeente.", "Регистрацией адреса занимается ваш муниципалитет, gemeente."))
    ]

    private static func timelineItem(_ id: String, _ symbol: String, _ difficulty: CivicDifficulty) -> CivicTimelineItem {
        CivicTimelineItem(
            id: id,
            localizationKey: "historyNetherlands.periods.\(id)",
            symbol: symbol,
            difficulty: difficulty
        )
    }

    private static func attraction(_ id: String, _ titleEN: String, _ titleNL: String, _ titleRU: String) -> InfoArticle {
        infoArticle(
            id: id,
            type: .attraction,
            title: infoText(titleEN, titleNL, titleRU),
            subtitle: infoText("Large flood-protection works in the south-western delta.", "Grote hoogwaterbescherming in de zuidwestelijke delta.", "Крупные защитные сооружения в юго-западной дельте."),
            summary: infoText("The Delta Works are a core example of modern Dutch flood protection after the 1953 North Sea flood.", "De Deltawerken zijn een kernvoorbeeld van moderne Nederlandse hoogwaterbescherming na de Watersnoodramp van 1953.", "Delta Works - ключевой пример современной защиты от наводнений после шторма 1953 года."),
            practicalNote: infoText("Use official visitor or water-management sources before choosing a specific dam or museum stop.", "Gebruik officiële bezoekers- of waterbeheerbronnen voordat je een dam of museum kiest.", "Перед выбором дамбы или музея смотрите официальные источники."),
            symbol: "water.waves",
            relatedPlaceIds: ["Zeeland", "South Holland"],
            tags: ["water", "heritage", "engineering"],
            sources: [source("delta-works-official"), source("government-water")]
        )
    }

    private static func attraction(_ id: String, _ titleEN: String, _ titleNL: String, _ titleRU: String, _ subtitleEN: String, _ subtitleNL: String, _ subtitleRU: String, _ summaryEN: String, _ summaryNL: String, _ summaryRU: String, _ noteEN: String, _ noteNL: String, _ noteRU: String, _ symbol: String, _ relatedPlaceIds: [String], _ sourceIds: [String]) -> InfoArticle {
        infoArticle(
            id: id,
            type: .attraction,
            title: infoText(titleEN, titleNL, titleRU),
            subtitle: infoText(subtitleEN, subtitleNL, subtitleRU),
            summary: infoText(summaryEN, summaryNL, summaryRU),
            practicalNote: infoText(noteEN, noteNL, noteRU),
            symbol: symbol,
            relatedPlaceIds: relatedPlaceIds,
            tags: ["attraction", "culture", "heritage"],
            sources: sourceIds.map { source($0) }
        )
    }

    private static func infoArticle(id: String, type: InfoArticleType, title: LocalizedInfoText, subtitle: LocalizedInfoText, summary: LocalizedInfoText, practicalNote: LocalizedInfoText, symbol: String, relatedPlaceIds: [String] = [], tags: [String], sources: [InfoSourceMetadata]) -> InfoArticle {
        InfoArticle(
            id: id,
            type: type,
            title: title,
            subtitle: subtitle,
            summary: summary,
            practicalNote: practicalNote,
            relatedPlaceIds: relatedPlaceIds,
            tags: tags,
            sources: sources,
            image: ContentMediaRegistry.image(forContentID: id),
            readingTimeMinutes: 2,
            updatedAt: "2026-06-01",
            verified: !sources.isEmpty,
            symbol: symbol
        )
    }

    private static func infoText(_ english: String, _ dutch: String, _ russian: String) -> LocalizedInfoText {
        LocalizedInfoText(english: english, dutch: dutch, russian: russian)
    }

    private static func source(_ id: String) -> InfoSourceMetadata {
        sourcesById[id] ?? InfoSourceMetadata(id: id, title: "Government.nl", institution: "Government of the Netherlands", url: AppURL.make("https://www.government.nl"), sourceType: "fallback")
    }

    private static func cityInfo(cityId: String, provinceId: String, population: String?, area: String?, website: String, title: LocalizedInfoText, subtitle: LocalizedInfoText, summary: LocalizedInfoText, guides: [String], attractions: [String], articles: [String], sources: [String]) -> CityInfoProfile {
        CityInfoProfile(
            cityId: cityId,
            title: title,
            subtitle: subtitle,
            summary: summary,
            provinceId: provinceId,
            populationText: population,
            areaText: area,
            municipalityWebsite: AppURL.validatedWebURL(URL(string: website)),
            practicalGuideIds: guides,
            attractionIds: attractions,
            articleIds: articles,
            officialSourceIds: sources,
            updatedAt: "2026-06-01",
            verified: !sources.isEmpty
        )
    }

    private static let sourcesById: [String: InfoSourceMetadata] = [
        "workinnl-culture": InfoSourceMetadata(id: "workinnl-culture", title: "Culture", institution: "Work in NL", url: AppURL.make("https://www.workinnl.nl/en/living-in-nl/culture/default.aspx"), sourceType: "public information"),
        "government-bicycles": InfoSourceMetadata(id: "government-bicycles", title: "Bicycles", institution: "Government.nl", url: AppURL.make("https://www.government.nl/themes/transport/bicycles"), sourceType: "official government"),
        "dutch-cycling-embassy": InfoSourceMetadata(id: "dutch-cycling-embassy", title: "Dutch cycling knowledge", institution: "Dutch Cycling Embassy", url: AppURL.make("https://dutchcycling.nl"), sourceType: "sector knowledge"),
        "government-water": InfoSourceMetadata(id: "government-water", title: "Water management", institution: "Government.nl", url: AppURL.make("https://www.government.nl/topics/water-management"), sourceType: "official government"),
        "kinderdijk-official": InfoSourceMetadata(id: "kinderdijk-official", title: "Windmills and pumping stations", institution: "Windmill heritage site", url: AppURL.make("https://kinderdijk.nl/en/windmills-pumping-stations/"), sourceType: "heritage site"),
        "unesco-amsterdam-canals": InfoSourceMetadata(id: "unesco-amsterdam-canals", title: "Seventeenth-Century Canal Ring Area of Amsterdam", institution: "UNESCO World Heritage Centre", url: AppURL.make("https://whc.unesco.org/en/list/1349/"), sourceType: "UNESCO"),
        "utrecht-canals": InfoSourceMetadata(id: "utrecht-canals", title: "Recreational boating", institution: "Municipality of Utrecht", url: AppURL.make("https://www.utrecht.nl/wonen-en-leven/verkeer/boot/recreatievaart-plezierboten"), sourceType: "municipality"),
        "rijksmuseum-visit": InfoSourceMetadata(id: "rijksmuseum-visit", title: "Visit the Rijksmuseum", institution: "Rijksmuseum", url: AppURL.make("https://www.rijksmuseum.nl/en/visit"), sourceType: "museum"),
        "cbs-culture": InfoSourceMetadata(id: "cbs-culture", title: "Leisure and culture", institution: "Statistics Netherlands", url: AppURL.make("https://www.cbs.nl/nl-nl/maatschappij/vrije-tijd-en-cultuur"), sourceType: "official statistics"),
        "government-municipalities": InfoSourceMetadata(id: "government-municipalities", title: "Municipalities", institution: "Government.nl", url: AppURL.make("https://www.government.nl/topics/municipalities"), sourceType: "official government"),
        "holland-leiden": InfoSourceMetadata(id: "holland-leiden", title: "Leiden - City of Discoveries", institution: "Holland.com", url: AppURL.make("https://www.holland.com/global/tourism/discover-the-netherlands/visit-the-cities/leiden"), sourceType: "official tourism"),
        "delft-tourists": InfoSourceMetadata(id: "delft-tourists", title: "Tourists", institution: "Municipality Delft", url: AppURL.make("https://www.delft.nl/en/tourists"), sourceType: "municipality"),
        "binnenhof-renovation": InfoSourceMetadata(id: "binnenhof-renovation", title: "Binnenhof Renovation", institution: "Municipality of The Hague", url: AppURL.make("https://www.denhaag.nl/nl/projecten-in-den-haag/binnenhof-renovatiewerkzaamheden/"), sourceType: "municipality"),
        "unesco-kinderdijk": InfoSourceMetadata(id: "unesco-kinderdijk", title: "Mill Network at Elshout", institution: "UNESCO World Heritage Centre", url: AppURL.make("https://whc.unesco.org/en/list/818"), sourceType: "UNESCO"),
        "delta-works-official": InfoSourceMetadata(id: "delta-works-official", title: "Delta Works", institution: "Deltawerken", url: AppURL.make("https://www.deltawerken.com/Deltaworks/23.html"), sourceType: "heritage information"),
        "rotterdam-tourism": InfoSourceMetadata(id: "rotterdam-tourism", title: "Travel trade and tourism", institution: "Rotterdam Partners", url: AppURL.make("https://www.rotterdam.info/en/visit/travel-trade"), sourceType: "official tourism"),
        "visit-maastricht-centre": InfoSourceMetadata(id: "visit-maastricht-centre", title: "The city centre", institution: "Visit Maastricht", url: AppURL.make("https://www.visitmaastricht.com/en/doing/city-districts/city-center"), sourceType: "official tourism"),
        "municipality-amsterdam": InfoSourceMetadata(id: "municipality-amsterdam", title: "Amsterdam municipality", institution: "Gemeente Amsterdam", url: AppURL.make("https://www.amsterdam.nl"), sourceType: "municipality"),
        "municipality-leiden": InfoSourceMetadata(id: "municipality-leiden", title: "Leiden municipality", institution: "Gemeente Leiden", url: AppURL.make("https://www.leiden.nl"), sourceType: "municipality"),
        "municipality-rotterdam": InfoSourceMetadata(id: "municipality-rotterdam", title: "Rotterdam municipality", institution: "Gemeente Rotterdam", url: AppURL.make("https://www.rotterdam.nl"), sourceType: "municipality"),
        "municipality-den-haag": InfoSourceMetadata(id: "municipality-den-haag", title: "The Hague municipality", institution: "Gemeente Den Haag", url: AppURL.make("https://www.denhaag.nl"), sourceType: "municipality"),
        "municipality-utrecht": InfoSourceMetadata(id: "municipality-utrecht", title: "Utrecht municipality", institution: "Gemeente Utrecht", url: AppURL.make("https://www.utrecht.nl"), sourceType: "municipality"),
        "municipality-eindhoven": InfoSourceMetadata(id: "municipality-eindhoven", title: "Eindhoven municipality", institution: "Gemeente Eindhoven", url: AppURL.make("https://www.eindhoven.nl"), sourceType: "municipality"),
        "municipality-groningen": InfoSourceMetadata(id: "municipality-groningen", title: "Groningen municipality", institution: "Gemeente Groningen", url: AppURL.make("https://gemeente.groningen.nl"), sourceType: "municipality"),
        "municipality-maastricht": InfoSourceMetadata(id: "municipality-maastricht", title: "Maastricht municipality", institution: "Gemeente Maastricht", url: AppURL.make("https://www.maastricht.nl"), sourceType: "municipality"),
        "gvb": InfoSourceMetadata(id: "gvb", title: "Amsterdam public transport", institution: "GVB", url: AppURL.make("https://www.gvb.nl"), sourceType: "transport"),
        "ret": InfoSourceMetadata(id: "ret", title: "Rotterdam public transport", institution: "RET", url: AppURL.make("https://www.ret.nl"), sourceType: "transport"),
        "htm": InfoSourceMetadata(id: "htm", title: "The Hague public transport", institution: "HTM", url: AppURL.make("https://www.htm.nl"), sourceType: "transport"),
        "u-ov": InfoSourceMetadata(id: "u-ov", title: "Utrecht public transport", institution: "U-OV", url: AppURL.make("https://www.u-ov.info"), sourceType: "transport"),
        "hermes": InfoSourceMetadata(id: "hermes", title: "Eindhoven regional transport", institution: "Hermes", url: AppURL.make("https://www.hermes.nl"), sourceType: "transport"),
        "qbuzz": InfoSourceMetadata(id: "qbuzz", title: "Groningen regional transport", institution: "Qbuzz", url: AppURL.make("https://www.qbuzz.nl"), sourceType: "transport"),
        "arriva": InfoSourceMetadata(id: "arriva", title: "Limburg regional transport", institution: "Arriva", url: AppURL.make("https://webshop.arriva.nl/"), sourceType: "transport"),
        "iamsterdam": InfoSourceMetadata(id: "iamsterdam", title: "Amsterdam visitor information", institution: "I amsterdam", url: AppURL.make("https://www.iamsterdam.com"), sourceType: "official tourism")
    ]

    private static func card(_ id: String, _ section: CivicLearningSection, _ title: (String, String, String), _ summary: (String, String, String), _ detail: (String, String, String), _ symbol: String, _ difficulty: CivicDifficulty, _ source: String?, _ keywords: [String]) -> CivicInfoCardItem {
        CivicInfoCardItem(id: id, section: section, titleEN: title.0, titleNL: title.1, titleRU: title.2, summaryEN: summary.0, summaryNL: summary.1, summaryRU: summary.2, detailEN: detail.0, detailNL: detail.1, detailRU: detail.2, symbol: symbol, difficulty: difficulty, sourceURL: source.flatMap(URL.init(string:)), keywords: keywords)
    }

    private static func term(_ id: String, _ term: String, _ dutchTerm: String, _ definitionEN: String, _ definitionNL: String, _ definitionRU: String, _ exampleEN: String, _ exampleNL: String, _ exampleRU: String, _ keywords: [String]) -> CivicGlossaryTerm {
        CivicGlossaryTerm(id: id, term: term, dutchTerm: dutchTerm, definitionEN: definitionEN, definitionNL: definitionNL, definitionRU: definitionRU, exampleEN: exampleEN, exampleNL: exampleNL, exampleRU: exampleRU, keywords: keywords)
    }

    private static func quiz(_ id: String, _ question: (String, String, String), _ options: ([String], [String], [String]), _ correctIndex: Int, _ explanation: (String, String, String)) -> CivicQuizQuestion {
        CivicQuizQuestion(id: id, questionEN: question.0, questionNL: question.1, questionRU: question.2, optionsEN: options.0, optionsNL: options.1, optionsRU: options.2, correctIndex: correctIndex, explanationEN: explanation.0, explanationNL: explanation.1, explanationRU: explanation.2)
    }
}
