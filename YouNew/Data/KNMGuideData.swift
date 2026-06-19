import Foundation

@MainActor
enum KNMGuideData {
    static let retrievedAt = "2026-06-01"

    static let sources: [KNMSource] = [
        source("duo-knowledge", "DUO / Inburgeren - Knowledge exams", "DUO / Inburgeren - Kennisexamens", "DUO / Inburgeren - экзамены по знаниям", "https://www.inburgeren.nl/en/taking-the-integration-exam/content-knowledge-exams.jsp", "Official exam information", "en"),
        source("duo-practice", "DUO / Inburgeren - Practice exams", "DUO / Inburgeren - Oefenen", "DUO / Inburgeren - тренировочные экзамены", "https://www.inburgeren.nl/examen-doen/oefenen.jsp", "Official practice information", "nl"),
        source("duo-register", "DUO / Inburgeren - Registering for an exam", "DUO / Inburgeren - Aanmelden examen", "DUO / Inburgeren - запись на экзамен", "https://www.inburgeren.nl/examen-doen/aanmelden-examen.jsp", "Official exam registration", "nl"),
        source("government-municipalities", "Government.nl - Municipalities", "Government.nl - Gemeenten", "Government.nl - муниципалитеты", "https://www.government.nl/topics/municipalities", "Government topic page", "en"),
        source("government-housing", "Government.nl - Housing", "Government.nl - Wonen", "Government.nl - жильё", "https://www.government.nl/topics/housing", "Government topic page", "en"),
        source("belastingdienst", "Belastingdienst - Income tax and benefits", "Belastingdienst - belasting en toeslagen", "Belastingdienst - налоги и toeslagen", "https://www.belastingdienst.nl/wps/wcm/connect/en/home/home", "Official tax authority", "en"),
        source("zorgverzekering", "Government.nl - Health insurance", "Government.nl - Zorgverzekering", "Government.nl - медицинская страховка", "https://www.government.nl/topics/health-insurance", "Government topic page", "en"),
        source("politie", "Politie.nl", "Politie.nl", "Politie.nl", "https://www.politie.nl/en", "Official police", "en"),
        source("112", "112 Netherlands", "112 Nederland", "112 Нидерланды", "https://www.112.nl/en", "Official emergency information", "en"),
        source("ns", "NS - Train travel", "NS - treinreizen", "NS - поезда", "https://www.ns.nl/en", "Official transport operator", "en"),
        source("ovpay", "OVpay", "OVpay", "OVpay", "https://www.ovpay.nl/en", "Official public transport payment info", "en"),
        source("9292", "9292 journey planner", "9292 reisplanner", "9292 планировщик", "https://9292.nl/en", "Official journey planner", "en")
    ]

    static let modules: [KNMModule] = [
        module(
            id: "housing",
            title: ("Housing", "Wonen", "Жильё"),
            summary: ("Renting, registration, waste rules, utilities, neighbours, and moving address.", "Huren, inschrijving, afvalregels, energie, buren en verhuizen.", "Аренда, регистрация адреса, мусор, коммунальные услуги, соседи и переезд."),
            icon: "house.lodge.fill",
            accent: .violet,
            sourceIds: ["duo-knowledge", "government-housing", "government-municipalities"],
            aliases: ["KNM", "housing", "wonen", "жильё", "жилье", "rent", "huur", "address", "gemeente", "waste", "afval"],
            lessons: [
                lesson(
                    id: "housing-basics",
                    title: ("Renting and address registration", "Huren en adresinschrijving", "Аренда и регистрация адреса"),
                    body: ("In Dutch daily life your registered address matters. It connects to municipality records, letters, taxes, benefits, healthcare, and many contracts. Before renting, check whether registration is allowed, what is included in the rent, how the deposit is handled, and which waste and noise rules apply locally.",
                           "In Nederland is uw ingeschreven adres belangrijk. Het is verbonden met gemeentegegevens, brieven, belastingen, toeslagen, zorg en contracten. Controleer bij huren of inschrijving mag, wat in de huur zit, hoe borg werkt en welke afval- en geluidsregels lokaal gelden.",
                           "В Нидерландах зарегистрированный адрес очень важен. Он связан с gemeente, письмами, налогами, toeslagen, медициной и договорами. Перед арендой проверьте, можно ли зарегистрироваться, что входит в huur, как работает borg и какие местные правила по мусору и шуму."),
                    example: ("You move to another city. You report the move to the new municipality and check the local waste calendar instead of using the old city rules.",
                              "U verhuist naar een andere stad. U meldt de verhuizing bij de nieuwe gemeente en controleert de lokale afvalkalender.",
                              "Вы переехали в другой город. Вы сообщаете о переезде в новую gemeente и проверяете местный календарь вывоза мусора."),
                    terms: [term("gemeente", "Municipality.", "Gemeente.", "Муниципалитет."), term("borg", "Rental deposit.", "Waarborgsom bij huur.", "Депозит по аренде."), term("huurcontract", "Rental contract.", "Huurcontract.", "Договор аренды.")],
                    questions: [
                        question("housing-q1", ("What should you check before signing a rental contract?", "Wat controleert u voor het tekenen van een huurcontract?", "Что нужно проверить перед подписанием договора аренды?"), [("Whether address registration is allowed", "Of inschrijving op het adres mag", "Можно ли зарегистрироваться по адресу"), ("Only the wall color", "Alleen de kleur van de muren", "Только цвет стен"), ("The nearest museum", "Het dichtstbijzijnde museum", "Ближайший музей"), ("The weather forecast", "De weersverwachting", "Прогноз погоды")], 0, ("Registration affects official letters and public administration.", "Inschrijving is belangrijk voor brieven en administratie.", "Регистрация влияет на официальные письма и администрацию.")),
                        question("housing-q2", ("Who usually publishes local waste collection rules?", "Wie publiceert meestal lokale afvalregels?", "Кто обычно публикует местные правила по мусору?"), [("The municipality", "De gemeente", "Gemeente"), ("NS", "NS", "NS"), ("The pharmacy", "De apotheek", "Аптека"), ("A random landlord forum", "Een willekeurig huurforum", "Случайный форум арендаторов")], 0, ("Waste rules are local and can differ by address.", "Afvalregels zijn lokaal en verschillen per adres.", "Правила по мусору местные и могут отличаться по адресу."))
                    ],
                    sourceIds: ["government-housing", "government-municipalities"]
                )
            ]
        ),
        module(id: "work-income", title: ("Work and income", "Werk en inkomen", "Работа и доход"), summary: ("Contracts, salary, taxes, benefits, UWV, sick leave, applications, rights, and duties.", "Contracten, loon, belasting, toeslagen, UWV, ziekte, solliciteren, rechten en plichten.", "Договор, зарплата, налоги, toeslagen, UWV, больничный, поиск работы, права и обязанности."), icon: "briefcase.fill", accent: .emerald, sourceIds: ["duo-knowledge", "belastingdienst"], aliases: ["work", "income", "werk", "inkomen", "работа", "доход", "salary", "loon", "toeslagen", "uwv"], lessons: [compactLesson("work-contracts", ("Contracts, payslips, and taxes", "Contracten, loonstroken en belasting", "Договоры, payslip и налоги"), ("Work life often uses written contracts, payslips, and official tax records. Keep employment documents, check gross and net salary, and verify tax or benefit questions with Belastingdienst or the relevant institution.", "Werk gebruikt vaak contracten, loonstroken en belastinggegevens. Bewaar documenten, controleer bruto en netto loon en verifieer belasting- of toeslagvragen bij de juiste instantie.", "Работа часто связана с договором, расчётным листом и налоговыми данными. Храните документы, проверяйте bruto/netto зарплату и уточняйте налоги или toeslagen у официальных организаций."), ["arbeidscontract", "loonstrook", "toeslagen"], ["belastingdienst"], ("What document shows salary details each pay period?", "Welk document toont loongegevens per betaalperiode?", "Какой документ показывает детали зарплаты за период?"), ("Payslip", "Loonstrook", "Расчётный лист"))]),
        module(id: "health", title: ("Health", "Gezondheid", "Здоровье"), summary: ("Insurance, huisarts, pharmacy, emergency care, mental health, dental care, eigen risico, and 112.", "Verzekering, huisarts, apotheek, spoed, mentale zorg, tandarts, eigen risico en 112.", "Страховка, huisarts, аптека, срочная помощь, психическое здоровье, стоматология, eigen risico и 112."), icon: "cross.case.fill", accent: .red, sourceIds: ["duo-knowledge", "zorgverzekering", "112"], aliases: ["health", "gezondheid", "здоровье", "huisarts", "врач", "pharmacy", "apotheek", "112", "zorgverzekering"], lessons: [compactLesson("health-navigation", ("Huisarts, insurance, and urgent care", "Huisarts, verzekering en spoedzorg", "Huisarts, страховка и срочная помощь"), ("For non-emergency care, the huisarts is usually the first contact. Health insurance and eigen risico affect costs. For immediate danger or life-threatening emergency call 112; for urgent non-life-threatening care outside office hours use the huisartsenpost.", "Bij niet-spoedeisende zorg is de huisarts meestal het eerste contact. Zorgverzekering en eigen risico beïnvloeden kosten. Bel 112 bij direct gevaar; gebruik de huisartsenpost voor dringende zorg buiten kantooruren.", "При несрочной помощи первым контактом обычно является huisarts. Страховка и eigen risico влияют на расходы. При немедленной опасности звоните 112; для срочной, но не угрожающей жизни помощи вне рабочего времени используйте huisartsenpost."), ["huisarts", "zorgverzekering", "eigen risico"], ["zorgverzekering", "112"], ("When should you call 112?", "Wanneer belt u 112?", "Когда нужно звонить 112?"), ("Immediate danger or life-threatening emergency", "Bij direct gevaar of levensbedreigende spoed", "При немедленной опасности или угрозе жизни"))]),
        module(id: "education-upbringing", title: ("Education and upbringing", "Onderwijs en opvoeding", "Образование и дети"), summary: ("School system, primary and secondary school, MBO/HBO/university, childcare, compulsory education, and parent contact.", "Schoolsysteem, basis- en voortgezet onderwijs, mbo/hbo/universiteit, kinderopvang, leerplicht en oudercontact.", "Школьная система, начальная и средняя школа, MBO/HBO/university, детский сад, leerplicht и контакт родителей со школой."), icon: "graduationcap.fill", accent: .blue, sourceIds: ["duo-knowledge", "government-municipalities"], aliases: ["education", "school", "onderwijs", "opvoeding", "образование", "дети", "leerplicht", "mbo", "hbo"], lessons: [compactLesson("school-contact", ("School and parent contact", "School en oudercontact", "Школа и контакт родителей"), ("Schools expect parents to read messages, attend meetings when needed, and report absence. Children must follow compulsory education rules unless an official exception applies.", "Scholen verwachten dat ouders berichten lezen, gesprekken voeren wanneer nodig en afwezigheid melden. Kinderen vallen onder leerplicht, behalve bij officiële uitzonderingen.", "Школы ожидают, что родители читают сообщения, приходят на встречи при необходимости и сообщают об отсутствии. Дети обязаны соблюдать leerplicht, кроме официальных исключений."), ["leerplicht", "basisschool", "oudergesprek"], ["government-municipalities"], ("What is a normal school expectation for parents?", "Wat is een normale verwachting van school aan ouders?", "Что школа обычно ожидает от родителей?"), ("Read school messages and report absence", "Schoolberichten lezen en afwezigheid melden", "Читать сообщения школы и сообщать об отсутствии"))]),
        module(id: "government-institutions", title: ("Government and institutions", "Instanties en overheid", "Государство и организации"), summary: ("Municipality, DigiD, BSN, IND, Belastingdienst, UWV, SVB, police, elections, democracy, and official letters.", "Gemeente, DigiD, BSN, IND, Belastingdienst, UWV, SVB, politie, verkiezingen, democratie en brieven.", "Gemeente, DigiD, BSN, IND, Belastingdienst, UWV, SVB, полиция, выборы, демократия и официальные письма."), icon: "building.columns.fill", accent: .cyan, sourceIds: ["duo-knowledge", "government-municipalities", "belastingdienst", "politie"], aliases: ["government", "institutions", "overheid", "instanties", "государство", "организации", "digid", "bsn", "gemeente", "belastingdienst", "uwv", "svb"], lessons: [compactLesson("official-letters", ("DigiD, BSN, and official letters", "DigiD, BSN en officiële brieven", "DigiD, BSN и официальные письма"), ("Dutch institutions often communicate by letter or secure online portals. Use official domains, keep reference numbers, and never share DigiD codes with anyone.", "Instanties communiceren vaak per brief of via beveiligde portalen. Gebruik officiële domeinen, bewaar kenmerknummers en deel nooit DigiD-codes.", "Организации часто общаются письмами или через защищённые порталы. Используйте официальные домены, храните номера дел и никому не передавайте коды DigiD."), ["DigiD", "BSN", "kenmerk"], ["government-municipalities"], ("What should you do with a reference number in an official letter?", "Wat doet u met een kenmerk in een officiële brief?", "Что делать с номером дела в официальном письме?"), ("Keep it for contact about the case", "Bewaren voor contact over de zaak", "Сохранить для контакта по делу"))]),
        module(id: "norms-values", title: ("Norms, values, and society", "Normen, waarden en samenleving", "Нормы, ценности и общество"), summary: ("Equality, religion, expression, privacy, discrimination, LGBTQ+ rights, gender equality, direct communication, appointments, and punctuality.", "Gelijkheid, religie, meningsuiting, privacy, discriminatie, LHBTIQ+-rechten, gendergelijkheid, directe communicatie, afspraken en op tijd komen.", "Равенство, религия, свобода выражения, приватность, дискриминация, права LGBTQ+, гендерное равенство, прямое общение, встречи и пунктуальность."), icon: "person.2.fill", accent: .teal, sourceIds: ["duo-knowledge", "government-municipalities"], aliases: ["norms", "values", "society", "normen", "waarden", "samenleving", "нормы", "ценности", "общество", "discrimination", "privacy", "lgbtq"], lessons: [compactLesson("public-values", ("Everyday social values", "Dagelijkse sociale waarden", "Повседневные общественные ценности"), ("Dutch civic life strongly values equal treatment, privacy, personal autonomy, and keeping agreements. Direct communication can feel blunt, but it is often meant to be clear and practical.", "In Nederland zijn gelijke behandeling, privacy, autonomie en afspraken nakomen belangrijk. Directe communicatie kan bot voelen, maar is vaak bedoeld als duidelijk en praktisch.", "В Нидерландах важны равное отношение, приватность, личная автономия и соблюдение договорённостей. Прямое общение может казаться резким, но часто означает ясность и практичность."), ["afspraak", "privacy", "gelijkheid"], ["duo-knowledge"], ("What does arriving on time for an appointment usually show?", "Wat laat op tijd komen meestal zien?", "Что обычно показывает приход вовремя?"), ("Respect for the agreement", "Respect voor de afspraak", "Уважение к договорённости"))]),
        module(id: "transport", title: ("Transport", "Vervoer", "Транспорт"), summary: ("NS, bus, tram, metro, OV-chipkaart, OVpay, check-in/out, cycling, parking, traffic rules, and planning.", "NS, bus, tram, metro, OV-chipkaart, OVpay, in- en uitchecken, fietsen, parkeren, verkeersregels en plannen.", "NS, автобус, трамвай, метро, OV-chipkaart, OVpay, check-in/out, велосипед, парковка, ПДД и планирование."), icon: "tram.fill", accent: .orange, sourceIds: ["duo-knowledge", "ns", "ovpay", "9292"], aliases: TransportGuideData.guide.searchAliases + ["KNM vervoer", "транспорт knm"], lessons: [compactLesson("ov-basics", ("Public transport and cycling", "Openbaar vervoer en fietsen", "Общественный транспорт и велосипед"), ("Plan trips before travel, check in and out when required, and follow operator rules. Cycling is common, but lights, parking rules, priority, and traffic signs still matter.", "Plan reizen vooraf, check in en uit waar nodig en volg regels van vervoerders. Fietsen is normaal, maar verlichting, parkeren, voorrang en verkeersborden blijven belangrijk.", "Планируйте поездки заранее, делайте check-in/out где нужно и соблюдайте правила операторов. Велосипед очень распространён, но важны свет, парковка, приоритет и дорожные знаки."), ["OVpay", "OV-chipkaart", "inchecken"], ["ns", "ovpay", "9292"], ("What is important on many public transport trips?", "Wat is belangrijk bij veel ov-reizen?", "Что важно во многих поездках на общественном транспорте?"), ("Check in and check out correctly", "Goed in- en uitchecken", "Правильно делать check-in и check-out"))]),
        module(id: "safety", title: ("Safety", "Veiligheid", "Безопасность"), summary: ("112, police non-emergency, scams, DigiD fraud, domestic violence help, fire safety, and emergency preparation.", "112, politie zonder spoed, oplichting, DigiD-fraude, hulp bij huiselijk geweld, brandveiligheid en voorbereiding.", "112, полиция не для срочных случаев, мошенничество, DigiD-фрод, помощь при домашнем насилии, пожарная безопасность и подготовка."), icon: "shield.lefthalf.filled", accent: .yellow, sourceIds: ["duo-knowledge", "112", "politie"], aliases: ["safety", "veiligheid", "безопасность", "112", "police", "politie", "scam", "fraud", "digid fraud"], lessons: [compactLesson("emergency-and-fraud", ("Emergency numbers and fraud", "Noodnummers en fraude", "Экстренные номера и мошенничество"), ("Call 112 only for urgent danger. For police help without immediate danger, use the non-emergency police route. Treat unexpected DigiD, bank, tax, or delivery links as suspicious and go to the official website yourself.", "Bel 112 alleen bij direct gevaar. Voor politie zonder spoed gebruikt u de niet-spoedroute. Wantrouw onverwachte DigiD-, bank-, belasting- of pakketlinks en ga zelf naar de officiële website.", "Звоните 112 только при немедленной опасности. Для полиции без срочности используйте неэкстренный канал. Не доверяйте неожиданным ссылкам DigiD, банка, налоговой или доставки; заходите на официальный сайт сами."), ["112", "spoed", "phishing"], ["112", "politie"], ("What is a safe response to an unexpected DigiD login link?", "Wat is veilig bij een onverwachte DigiD-loginlink?", "Что безопасно сделать при неожиданной ссылке входа DigiD?"), ("Do not use it; go to the official site yourself", "Niet gebruiken; ga zelf naar de officiële site", "Не использовать; самостоятельно зайти на официальный сайт"))]),
        module(id: "free-time", title: ("Free time, culture, and participation", "Vrije tijd, cultuur en participatie", "Досуг, культура и участие"), summary: ("Libraries, sports clubs, volunteering, neighbourhood centres, museums, holidays, and social participation.", "Bibliotheken, sportclubs, vrijwilligerswerk, buurthuizen, musea, feestdagen en meedoen.", "Библиотеки, спортивные клубы, волонтёрство, buurtcentrum, музеи, праздники и участие в обществе."), icon: "figure.socialdance", accent: .green, sourceIds: ["duo-knowledge", "government-municipalities"], aliases: ["free time", "culture", "participation", "vrije tijd", "cultuur", "participatie", "досуг", "культура", "участие", "library", "bibliotheek"], lessons: [compactLesson("local-participation", ("Participating locally", "Lokaal meedoen", "Участие на местном уровне"), ("Libraries, sports clubs, volunteering, neighbourhood centres, and local events can help people practice language and understand society. Municipalities often list local support and activities.", "Bibliotheken, sportclubs, vrijwilligerswerk, buurthuizen en evenementen helpen met taal en samenleving. Gemeenten tonen vaak lokale hulp en activiteiten.", "Библиотеки, спортклубы, волонтёрство, buurtcentrum и местные события помогают практиковать язык и понимать общество. Gemeente часто публикует местную поддержку и активности."), ["bibliotheek", "vrijwilligerswerk", "buurthuis"], ["government-municipalities"], ("Where can newcomers often find local activities?", "Waar vinden nieuwkomers vaak lokale activiteiten?", "Где новички часто находят местные активности?"), ("Municipality pages, libraries, and neighbourhood centres", "Gemeentepagina's, bibliotheken en buurthuizen", "На сайтах gemeente, в библиотеках и buurtcentrum"))]),
        module(id: "money", title: ("Money matters", "Geldzaken", "Деньги и платежи"), summary: ("Bank account, iDEAL, insurance, budgeting, debts, taxes, benefits, and payment reminders.", "Bankrekening, iDEAL, verzekeringen, budgetteren, schulden, belasting, toeslagen en betalingsherinneringen.", "Банковский счёт, iDEAL, страховки, бюджет, долги, налоги, toeslagen и напоминания об оплате."), icon: "creditcard.fill", accent: .cyan, sourceIds: ["duo-knowledge", "belastingdienst"], aliases: ["money", "geld", "деньги", "bank", "ideal", "insurance", "budget", "debt", "taxes", "toeslagen", "платежи"], lessons: [compactLesson("payments-and-budget", ("Payments, reminders, and benefits", "Betalen, herinneringen en toeslagen", "Платежи, напоминания и toeslagen"), ("Dutch administration is deadline-driven. Open letters quickly, check payment reminders, and verify taxes or benefits through official portals. Ask for help early if debts or confusing letters appear.", "Nederlandse administratie werkt met deadlines. Open brieven snel, controleer betalingsherinneringen en verifieer belasting of toeslagen via officiële portalen. Vraag vroeg hulp bij schulden of onduidelijke brieven.", "Нидерландская администрация завязана на сроках. Быстро открывайте письма, проверяйте betalingsherinnering и сверяйте налоги или toeslagen через официальные порталы. При долгах или непонятных письмах обращайтесь за помощью рано."), ["iDEAL", "toeslagen", "betalingsherinnering"], ["belastingdienst"], ("What should you do with a payment reminder you do not understand?", "Wat doet u met een betalingsherinnering die u niet begrijpt?", "Что делать с непонятным напоминанием об оплате?"), ("Check the official source and ask for help early", "Controleer de officiële bron en vraag vroeg hulp", "Проверить официальный источник и рано попросить помощи"))])
    ]

    static var allQuestions: [KNMPracticeQuestion] {
        modules.flatMap(\.allQuestions)
    }

    static func module(with id: String) -> KNMModule? {
        if id == "registration" {
            return modules.first { $0.id == "housing" }
        }
        return modules.first { $0.id == id }
    }

    static func source(with id: String) -> KNMSource? {
        sources.first { $0.id == id }
    }

    private static func module(id: String, title: (String, String, String), summary: (String, String, String), icon: String, accent: KNMAccentToken, sourceIds: [String], aliases: [String], lessons: [KNMLesson]) -> KNMModule {
        KNMModule(id: id, title: l(title), summary: l(summary), icon: icon, accent: accent, lessons: lessons, sources: sourceIds.compactMap(source(with:)), updatedAt: retrievedAt, verified: true, searchAliases: aliases)
    }

    private static func compactLesson(_ id: String, _ title: (String, String, String), _ body: (String, String, String), _ terms: [String], _ sourceIds: [String], _ questionText: (String, String, String), _ correct: (String, String, String)) -> KNMLesson {
        lesson(id: id, title: title, body: body, example: ("Use the official source for current details before making a personal decision.", "Gebruik de officiële bron voor actuele details voordat u een persoonlijke beslissing neemt.", "Проверяйте актуальные детали на официальном сайте перед личным решением."), terms: terms.map { term($0, "Key KNM word in this topic.", "Belangrijk KNM-woord bij dit thema.", "Важное слово KNM по этой теме.") }, questions: [question("\(id)-q1", questionText, [correct, ("Ask a neighbour to decide for you", "Laat een buur beslissen", "Попросить соседа решить за вас"), ("Ignore official letters", "Officiële brieven negeren", "Игнорировать официальные письма"), ("Use only social media comments", "Alleen sociale media gebruiken", "Использовать только комментарии в соцсетях")], 0, ("The safest answer is the one linked to official or direct practical action.", "Het veiligste antwoord past bij officiële of directe praktische actie.", "Самый безопасный ответ связан с официальным или прямым практическим действием."))], sourceIds: sourceIds)
    }

    private static func lesson(id: String, title: (String, String, String), body: (String, String, String), example: (String, String, String), terms: [KNMKeyTerm], questions: [KNMPracticeQuestion], sourceIds: [String]) -> KNMLesson {
        let pack = knowledgePack(for: id)
        return KNMLesson(
            id: id,
            title: l(title),
            body: l(body),
            example: l(example),
            everydaySituations: pack.situations.map(l),
            keyTerms: terms,
            rememberItems: pack.remember.map(l),
            practiceQuestions: minimumPracticeQuestions(for: id, title: title, terms: terms, existing: questions, sourceIds: sourceIds),
            sourceIds: sourceIds
        )
    }

    private static func question(_ id: String, _ question: (String, String, String), _ options: [(String, String, String)], _ correctIndex: Int, _ explanation: (String, String, String)) -> KNMPracticeQuestion {
        KNMPracticeQuestion(id: id, question: l(question), options: options.map(l), correctIndex: correctIndex, explanation: l(explanation), sourceIds: ["duo-knowledge"], isOfficial: false)
    }

    private static func minimumPracticeQuestions(for lessonID: String, title: (String, String, String), terms: [KNMKeyTerm], existing: [KNMPracticeQuestion], sourceIds: [String]) -> [KNMPracticeQuestion] {
        guard existing.count < 5 else { return existing }
        let firstTerm = terms.first?.term ?? "official source"
        let secondTerm = terms.dropFirst().first?.term ?? "gemeente"
        let thirdTerm = terms.dropFirst(2).first?.term ?? "DigiD"
        let additions: [KNMPracticeQuestion] = [
            generatedQuestion("\(lessonID)-q-topic", ("What is the best first step in this topic?", "Wat is de beste eerste stap bij dit thema?", "Какой лучший первый шаг в этой теме?"), (title.0, title.1, title.2), sourceIds),
            generatedQuestion("\(lessonID)-q-source", ("Where should you verify current rules?", "Waar controleert u actuele regels?", "Где проверять актуальные правила?"), ("On the official source for this topic", "Bij de officiële bron voor dit thema", "В официальном источнике по этой теме"), sourceIds),
            generatedQuestion("\(lessonID)-q-term-1", ("Which word is important for this KNM topic?", "Welk woord is belangrijk voor dit KNM-thema?", "Какое слово важно для этой темы KNM?"), (firstTerm, firstTerm, firstTerm), sourceIds),
            generatedQuestion("\(lessonID)-q-term-2", ("Which detail should you keep or check carefully?", "Welk detail bewaart of controleert u goed?", "Какую деталь нужно внимательно сохранить или проверить?"), (secondTerm, secondTerm, secondTerm), sourceIds),
            generatedQuestion("\(lessonID)-q-action", ("What is safer than relying on social media comments?", "Wat is veiliger dan vertrouwen op sociale media?", "Что безопаснее, чем полагаться на комментарии в соцсетях?"), ("Use official information and direct contact routes", "Officiële informatie en directe contactroutes gebruiken", "Использовать официальную информацию и прямые каналы контакта"), sourceIds),
            generatedQuestion("\(lessonID)-q-term-3", ("Which term may appear in letters or conversations about this topic?", "Welke term kan in brieven of gesprekken over dit thema staan?", "Какой термин может встретиться в письмах или разговорах по этой теме?"), (thirdTerm, thirdTerm, thirdTerm), sourceIds),
            generatedQuestion("\(lessonID)-q-mistake", ("What is a common mistake to avoid?", "Welke veelgemaakte fout voorkomt u?", "Какой частой ошибки стоит избежать?"), ("Acting before checking the official route", "Handelen voordat u de officiële route controleert", "Действовать до проверки официального маршрута"), sourceIds)
        ]
        return Array((existing + additions).prefix(8))
    }

    private static func knowledgePack(for lessonID: String) -> (situations: [(String, String, String)], remember: [(String, String, String)]) {
        switch lessonID {
        case "housing-basics":
            return (
                [
                    ("You receive a rental offer and need to know whether address registration is allowed.", "U krijgt een huuraanbod en moet weten of adresinschrijving mag.", "Вы получили предложение аренды и должны понять, разрешена ли регистрация адреса."),
                    ("You move to another municipality and must update your address.", "U verhuist naar een andere gemeente en moet uw adres aanpassen.", "Вы переезжаете в другой муниципалитет и должны обновить адрес."),
                    ("You need to follow local waste, noise, deposit, energy, and water rules.", "U moet lokale regels voor afval, geluid, borg, energie en water volgen.", "Вам нужно соблюдать местные правила по мусору, шуму, депозиту, энергии и воде.")
                ],
                [
                    ("A rental contract is not the same as municipality registration.", "Een huurcontract is niet hetzelfde als inschrijving bij de gemeente.", "Договор аренды не равен регистрации в gemeente."),
                    ("Local housing and waste rules can differ by address.", "Lokale woon- en afvalregels kunnen per adres verschillen.", "Жилищные и мусорные правила могут отличаться по адресу."),
                    ("Keep written proof of rent, deposit, registration, and meter readings.", "Bewaar bewijs van huur, borg, inschrijving en meterstanden.", "Сохраняйте подтверждения аренды, депозита, регистрации и показаний счётчиков."),
                    ("Verify current rules through official or direct sources before paying.", "Controleer actuele regels via officiële of directe bronnen voordat u betaalt.", "Проверяйте актуальные правила через официальные или прямые источники до оплаты.")
                ]
            )
        case "work-contracts":
            return (
                [
                    ("You receive an employment contract and need to understand salary, hours, and sick reporting.", "U krijgt een arbeidscontract en moet loon, uren en ziekmelden begrijpen.", "Вы получили трудовой договор и должны понять зарплату, часы и сообщение о болезни."),
                    ("You compare gross salary, net salary, payslip, taxes, and benefits.", "U vergelijkt brutoloon, nettoloon, loonstrook, belasting en toeslagen.", "Вы сравниваете bruto, netto, расчётный лист, налоги и toeslagen."),
                    ("You become sick and must follow the employer's reporting process.", "U wordt ziek en moet het ziekmeldproces van de werkgever volgen.", "Вы заболели и должны следовать правилам работодателя по sick leave.")
                ],
                [
                    ("Keep contracts, payslips, schedules, and tax letters.", "Bewaar contracten, loonstroken, roosters en belastingbrieven.", "Храните договоры, расчётные листы, графики и налоговые письма."),
                    ("Rights and duties at work are usually written down.", "Rechten en plichten op werk staan meestal schriftelijk.", "Права и обязанности на работе обычно записаны письменно."),
                    ("Tax and benefit questions should be checked with official institutions.", "Belasting- en toeslagvragen controleert u bij officiële instanties.", "Вопросы налогов и пособий проверяйте у официальных организаций."),
                    ("Report sickness clearly and on time according to workplace rules.", "Meld ziekte duidelijk en op tijd volgens werkregels.", "Сообщайте о болезни ясно и вовремя по правилам работы.")
                ]
            )
        case "health-navigation":
            return (
                [
                    ("You need non-emergency care and decide whether to contact the huisarts.", "U heeft niet-spoedeisende zorg nodig en kiest of u de huisarts belt.", "Вам нужна несрочная помощь, и вы решаете, обращаться ли к huisarts."),
                    ("You have urgent symptoms outside office hours and check the huisartsenpost route.", "U heeft buiten kantooruren dringende klachten en controleert de huisartsenpost-route.", "У вас срочные симптомы вне рабочего времени, и вы проверяете маршрут huisartsenpost."),
                    ("You receive a bill and need to understand insurance and eigen risico.", "U krijgt een rekening en moet verzekering en eigen risico begrijpen.", "Вы получили счёт и должны понять страховку и eigen risico.")
                ],
                [
                    ("Call 112 only for immediate danger or life-threatening emergency.", "Bel 112 alleen bij direct gevaar of levensbedreigende spoed.", "Звоните 112 только при немедленной опасности или угрозе жизни."),
                    ("The huisarts is usually the first contact for non-emergency care.", "De huisarts is meestal het eerste contact voor niet-spoedzorg.", "Huisarts обычно первый контакт для несрочной медицины."),
                    ("Insurance and eigen risico can affect costs.", "Verzekering en eigen risico kunnen kosten beïnvloeden.", "Страховка и eigen risico могут влиять на расходы."),
                    ("This app does not give medical diagnosis or treatment advice.", "Deze app geeft geen diagnose of behandeladvies.", "Приложение не даёт диагнозов или медицинских назначений.")
                ]
            )
        case "school-contact":
            return (
                [
                    ("A child starts school and parents need to follow messages, absence rules, and meetings.", "Een kind start op school en ouders volgen berichten, verzuimregels en gesprekken.", "Ребёнок начинает школу, и родители должны следить за сообщениями, отсутствиями и встречами."),
                    ("You need to understand primary school, secondary school, MBO, HBO, and university as different routes.", "U moet basisschool, voortgezet onderwijs, mbo, hbo en universiteit als verschillende routes begrijpen.", "Нужно понимать начальную школу, среднюю школу, MBO, HBO и университет как разные маршруты."),
                    ("You arrange childcare or contact school about support.", "U regelt kinderopvang of neemt contact op met school over ondersteuning.", "Вы оформляете childcare или связываетесь со школой по поддержке.")
                ],
                [
                    ("Parents are expected to read school communication.", "Ouders worden verwacht schoolcommunicatie te lezen.", "От родителей ожидают чтения школьных сообщений."),
                    ("Absence usually has to be reported.", "Afwezigheid moet meestal worden gemeld.", "Об отсутствии обычно нужно сообщать."),
                    ("Compulsory education rules apply unless an official exception exists.", "Leerplicht geldt tenzij er een officiële uitzondering is.", "Leerplicht действует, если нет официального исключения."),
                    ("School systems and support differ by age and route.", "Schoolsystemen en ondersteuning verschillen per leeftijd en route.", "Школьные системы и поддержка отличаются по возрасту и маршруту.")
                ]
            )
        case "official-letters":
            return (
                [
                    ("You receive a letter with a reference number and deadline.", "U krijgt een brief met kenmerk en deadline.", "Вы получили письмо с номером дела и сроком."),
                    ("You need DigiD to log in to a secure government portal.", "U heeft DigiD nodig om in te loggen op een beveiligd overheidsportaal.", "Вам нужен DigiD для входа в защищённый государственный портал."),
                    ("You contact municipality, Belastingdienst, IND, UWV, SVB, or police and must keep records.", "U neemt contact op met gemeente, Belastingdienst, IND, UWV, SVB of politie en bewaart gegevens.", "Вы связываетесь с gemeente, Belastingdienst, IND, UWV, SVB или полицией и храните данные.")
                ],
                [
                    ("Never share DigiD codes or approvals.", "Deel nooit DigiD-codes of goedkeuringen.", "Никогда не передавайте коды или подтверждения DigiD."),
                    ("Keep reference numbers, dates, letters, and screenshots of official portals.", "Bewaar kenmerken, datums, brieven en screenshots van officiële portalen.", "Сохраняйте номера, даты, письма и скриншоты официальных порталов."),
                    ("Use official domains instead of links from unexpected messages.", "Gebruik officiële domeinen in plaats van links uit onverwachte berichten.", "Используйте официальные домены, а не ссылки из неожиданных сообщений."),
                    ("Municipality registration, BSN, DigiD, and official letters are connected.", "Gemeente-inschrijving, BSN, DigiD en officiële brieven hangen samen.", "Регистрация, BSN, DigiD и официальные письма связаны.")
                ]
            )
        case "public-values":
            return (
                [
                    ("You work or study in a place where equality, privacy, and direct communication are expected.", "U werkt of studeert op een plek waar gelijkheid, privacy en directe communicatie verwacht worden.", "Вы работаете или учитесь там, где ожидаются равенство, приватность и прямое общение."),
                    ("You make an appointment and need to arrive on time or reschedule early.", "U maakt een afspraak en moet op tijd komen of vroeg verzetten.", "Вы записались на встречу и должны прийти вовремя или заранее перенести."),
                    ("You see discrimination or unsafe behaviour and need to know that official help routes exist.", "U ziet discriminatie of onveilig gedrag en moet weten dat officiële hulproutes bestaan.", "Вы сталкиваетесь с дискриминацией или небезопасным поведением и должны знать об официальных маршрутах помощи.")
                ],
                [
                    ("Equal treatment and non-discrimination are important civic principles.", "Gelijke behandeling en non-discriminatie zijn belangrijke maatschappelijke principes.", "Равное отношение и недискриминация - важные общественные принципы."),
                    ("Freedom of religion and expression exists within the law.", "Vrijheid van religie en meningsuiting bestaan binnen de wet.", "Свобода религии и выражения действует в рамках закона."),
                    ("Appointments, privacy, and personal boundaries are taken seriously.", "Afspraken, privacy en persoonlijke grenzen worden serieus genomen.", "Договорённости, приватность и личные границы воспринимаются серьёзно."),
                    ("Direct communication often aims at clarity, not personal hostility.", "Directe communicatie is vaak bedoeld als duidelijkheid, niet persoonlijke vijandigheid.", "Прямое общение часто означает ясность, а не личную неприязнь.")
                ]
            )
        case "ov-basics":
            return (
                [
                    ("You plan a train, bus, tram, or metro trip and check delays before leaving.", "U plant trein, bus, tram of metro en controleert vertraging voor vertrek.", "Вы планируете поездку на поезде, автобусе, трамвае или метро и проверяете задержки."),
                    ("You need to check in and check out correctly.", "U moet goed in- en uitchecken.", "Вам нужно правильно сделать check-in и check-out."),
                    ("You cycle in traffic and need lights, parking rules, and priority awareness.", "U fietst in het verkeer en let op verlichting, parkeren en voorrang.", "Вы едете на велосипеде и должны учитывать свет, парковку и приоритет.")
                ],
                [
                    ("Use NS, 9292, OVpay, OV-chipkaart, or local operators for current travel information.", "Gebruik NS, 9292, OVpay, OV-chipkaart of lokale vervoerders voor actuele reisinformatie.", "Используйте NS, 9292, OVpay, OV-chipkaart или местных операторов для актуальной информации."),
                    ("Check-in/check-out mistakes can cost money.", "Fouten met in- en uitchecken kunnen geld kosten.", "Ошибки check-in/check-out могут стоить денег."),
                    ("Operator rules can differ by route and region.", "Vervoerdersregels kunnen verschillen per route en regio.", "Правила операторов могут отличаться по маршруту и региону."),
                    ("Cycling is normal transport, but traffic rules still apply.", "Fietsen is normaal vervoer, maar verkeersregels blijven gelden.", "Велосипед - обычный транспорт, но правила движения действуют.")
                ]
            )
        case "emergency-and-fraud":
            return (
                [
                    ("You must decide whether a situation is immediate danger and needs 112.", "U moet beoordelen of er direct gevaar is en 112 nodig is.", "Вы должны понять, есть ли немедленная опасность и нужен ли 112."),
                    ("You receive a suspicious DigiD, bank, delivery, or tax message.", "U krijgt een verdacht DigiD-, bank-, pakket- of belastingbericht.", "Вы получили подозрительное сообщение от DigiD, банка, доставки или налоговой."),
                    ("You need police help without immediate emergency.", "U heeft politiehulp nodig zonder directe spoed.", "Вам нужна полиция, но без немедленной срочности.")
                ],
                [
                    ("112 is for immediate danger, accident, fire, or life-threatening emergency.", "112 is voor direct gevaar, ongeluk, brand of levensbedreigende spoed.", "112 - для немедленной опасности, аварии, пожара или угрозы жизни."),
                    ("Do not use unexpected login or payment links.", "Gebruik geen onverwachte login- of betaallinks.", "Не используйте неожиданные ссылки входа или оплаты."),
                    ("For non-emergency police help, use the official police route.", "Voor politie zonder spoed gebruikt u de officiële politieroute.", "Для полиции без срочности используйте официальный маршрут."),
                    ("Ask for help early if letters, threats, or fraud attempts feel confusing.", "Vraag vroeg hulp als brieven, dreiging of fraude onduidelijk zijn.", "Обращайтесь за помощью рано, если письма, угрозы или мошенничество непонятны.")
                ]
            )
        case "local-participation":
            return (
                [
                    ("You want to practise Dutch and meet people through library, sports, or volunteering.", "U wilt Nederlands oefenen en mensen ontmoeten via bibliotheek, sport of vrijwilligerswerk.", "Вы хотите практиковать нидерландский и знакомиться через библиотеку, спорт или волонтёрство."),
                    ("You look for neighbourhood activities or local support.", "U zoekt buurtactiviteiten of lokale ondersteuning.", "Вы ищете районные активности или местную поддержку."),
                    ("You check museums, holidays, or public events before visiting.", "U controleert musea, feestdagen of evenementen voor bezoek.", "Вы проверяете музеи, праздники или события перед посещением.")
                ],
                [
                    ("Participation can help with language, routines, and local contacts.", "Meedoen helpt met taal, routines en lokale contacten.", "Участие помогает с языком, привычками и местными контактами."),
                    ("Municipalities, libraries, and neighbourhood centres often list activities.", "Gemeenten, bibliotheken en buurthuizen tonen vaak activiteiten.", "Gemeente, библиотеки и buurtcentrum часто публикуют активности."),
                    ("Volunteering is useful but should still be clear about time and expectations.", "Vrijwilligerswerk is nuttig, maar tijd en verwachtingen moeten duidelijk zijn.", "Волонтёрство полезно, но время и ожидания должны быть понятны."),
                    ("Culture is optional participation, not an administrative requirement.", "Cultuur is vrijwillig meedoen, geen administratieve verplichting.", "Культура - добровольное участие, а не административная обязанность.")
                ]
            )
        case "payments-and-budget":
            return (
                [
                    ("You open a bank account or need IBAN for salary, rent, insurance, or benefits.", "U opent een bankrekening of heeft IBAN nodig voor loon, huur, verzekering of toeslagen.", "Вы открываете счёт или нужен IBAN для зарплаты, аренды, страховки или toeslagen."),
                    ("You receive a payment reminder, tax letter, or benefits message.", "U krijgt een betalingsherinnering, belastingbrief of toeslagenbericht.", "Вы получили напоминание об оплате, налоговое письмо или сообщение по toeslagen."),
                    ("You need to budget for insurance, rent, energy, transport, and unexpected costs.", "U budgetteert voor verzekering, huur, energie, vervoer en onverwachte kosten.", "Вы планируете бюджет на страховку, аренду, энергию, транспорт и неожиданные расходы.")
                ],
                [
                    ("Open official letters quickly because deadlines matter.", "Open officiële brieven snel, want deadlines zijn belangrijk.", "Быстро открывайте официальные письма, потому что сроки важны."),
                    ("Verify taxes and benefits through official portals.", "Controleer belasting en toeslagen via officiële portalen.", "Проверяйте налоги и toeslagen через официальные порталы."),
                    ("Use traceable payments and keep proof.", "Gebruik traceerbare betalingen en bewaar bewijs.", "Используйте отслеживаемые платежи и храните подтверждения."),
                    ("Ask for help early if debts or unclear reminders appear.", "Vraag vroeg hulp bij schulden of onduidelijke herinneringen.", "При долгах или непонятных напоминаниях обращайтесь за помощью рано.")
                ]
            )
        default:
            return (
                [
                    ("You face a practical situation and need to choose the safest next step.", "U staat voor een praktische situatie en kiest de veiligste volgende stap.", "Вы столкнулись с практической ситуацией и выбираете безопасный следующий шаг."),
                    ("You compare informal advice with official information.", "U vergelijkt informeel advies met officiële informatie.", "Вы сравниваете неформальный совет с официальной информацией."),
                    ("You keep documents and check deadlines before acting.", "U bewaart documenten en controleert deadlines voordat u handelt.", "Вы храните документы и проверяете сроки перед действием.")
                ],
                [
                    ("Use official sources for current rules.", "Gebruik officiële bronnen voor actuele regels.", "Используйте официальные источники для актуальных правил."),
                    ("Keep written proof and reference numbers.", "Bewaar bewijs en kenmerknummers.", "Сохраняйте подтверждения и номера дел."),
                    ("These are app practice materials, not DUO exam material.", "Dit zijn app-oefenmaterialen, geen DUO-examenmateriaal.", "Это материалы приложения, а не экзаменационные материалы DUO."),
                    ("Ask a qualified institution when consequences are serious.", "Vraag een bevoegde instantie wanneer gevolgen ernstig zijn.", "Обращайтесь в компетентную организацию, если последствия серьёзные.")
                ]
            )
        }
    }

    private static func generatedQuestion(_ id: String, _ prompt: (String, String, String), _ correct: (String, String, String), _ sourceIds: [String]) -> KNMPracticeQuestion {
        KNMPracticeQuestion(
            id: id,
            question: l(prompt),
            options: [
                l(correct),
                l(("Ignore official letters", "Officiële brieven negeren", "Игнорировать официальные письма")),
                l(("Use only a neighbour's opinion", "Alleen de mening van een buur gebruiken", "Использовать только мнение соседа")),
                l(("Wait without checking anything", "Wachten zonder iets te controleren", "Ждать и ничего не проверять"))
            ],
            correctIndex: 0,
            explanation: l(("This is an app-created practice question. The safest answer uses official, current, and practical information.", "Dit is een oefenvraag van de app. Het veiligste antwoord gebruikt officiële, actuele en praktische informatie.", "Это тренировочный вопрос приложения. Самый безопасный ответ использует официальную, актуальную и практическую информацию.")),
            sourceIds: sourceIds,
            isOfficial: false
        )
    }

    private static func term(_ value: String, _ en: String, _ nl: String, _ ru: String) -> KNMKeyTerm {
        KNMKeyTerm(id: value.lowercased().replacingOccurrences(of: " ", with: "-"), term: value, definition: l((en, nl, ru)))
    }

    private static func source(_ id: String, _ en: String, _ nl: String, _ ru: String, _ url: String, _ type: String, _ language: String) -> KNMSource {
        KNMSource(id: id, title: l((en, nl, ru)), url: url, sourceType: type, language: language, retrievedAt: retrievedAt, verified: true)
    }

    private static func l(_ value: (String, String, String)) -> KNMLocalizedString {
        KNMLocalizedString(en: value.0, nl: value.1, ru: value.2)
    }
}
