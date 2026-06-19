import Foundation

struct PathLocalizedText: Hashable {
    let english: String
    let dutch: String
    let russian: String

    func value(_ language: AppLanguage) -> String {
        switch language {
        case .english: return english
        case .dutch: return dutch
        case .russian: return russian
        }
    }
}

enum PathStepPhase: String, CaseIterable, Hashable {
    case foundation
    case setup
    case dailyLife
    case growth
    case longTerm

    func localizedTitle(_ language: AppLanguage) -> String {
        switch self {
        case .foundation: return L10n.t("home.life.phase.foundation", language)
        case .setup: return L10n.t("home.life.phase.setup", language)
        case .dailyLife: return L10n.t("home.life.phase.daily_life", language)
        case .growth: return L10n.t("home.life.phase.growth", language)
        case .longTerm: return L10n.t("home.life.phase.long_term", language)
        }
    }
}

enum PathStepStatus: String, Hashable {
    case recommended
    case optional
    case completed
    case later
}

struct PathStep: Identifiable, Hashable {
    let id: String
    let localizedTitle: PathLocalizedText
    let localizedDescription: PathLocalizedText
    let categoryId: String
    let priority: Int
    let phase: PathStepPhase
    let icon: String
    let status: PathStepStatus
    let destination: AppDestination
}

struct UserPathProfile: Identifiable, Hashable {
    let id: String
    let status: UserStatus?
    let localizedTitle: PathLocalizedText
    let localizedDescription: PathLocalizedText
    let recommendedSteps: [PathStep]
    let priorityCategories: [MainGuideSection]
    let cityRelevantPlaces: [NewcomerPlaceCategory]

    func nextSteps(limit: Int = 2) -> [PathStep] {
        recommendedSteps
            .filter { $0.status == .recommended }
            .sorted { $0.priority < $1.priority }
            .prefix(limit)
            .map { $0 }
    }

    static func profile(for status: UserStatus?) -> UserPathProfile {
        switch status {
        case .student: return student
        case .worker: return worker
        case .expat: return expat
        case .highlySkilledMigrant: return highlySkilledMigrant
        case .euCitizen: return euCitizen
        case .refugee: return refugee
        case .ukrainian: return ukrainian
        case .family: return family
        case .tourist: return tourist
        case .entrepreneur: return entrepreneur
        case .lgbtNewcomer: return lgbtNewcomer
        case .none: return newcomer
        }
    }
}

enum UserPathProfiles {
    static func profile(for status: UserStatus?) -> UserPathProfile {
        UserPathProfile.profile(for: status)
    }
}

private extension UserPathProfile {
    static let newcomer = make(
        id: "newcomer",
        status: nil,
        title: text("Newcomer path", "Nieuwkomerspad", "Путь новичка"),
        description: text("Start with registration, city services, documents, and health basics.", "Begin met registratie, stadsdiensten, documenten en zorgbasis.", "Начните с регистрации, городских сервисов, документов и базовой медицины."),
        steps: [
            step("registration", "Registration", "Registratie", "Регистрация", "Check where municipal registration starts.", "Controleer waar gemeentelijke registratie begint.", "Узнайте, где начинается регистрация в муниципалитете.", "person.text.rectangle", .foundation, 1, .recommended, .mapFocus(.government)),
            step("bsn", "BSN", "BSN", "BSN", "Understand why BSN matters for official services.", "Begrijp waarom BSN belangrijk is voor officiële diensten.", "Поймите, зачем BSN нужен для официальных сервисов.", "number", .foundation, 2, .recommended, .checklistList),
            step("city", "City services", "Stadsdiensten", "Городские сервисы", "Open your city guide and nearby help.", "Open je stadsgids en hulp dichtbij.", "Откройте городской гид и помощь рядом.", "building.2.fill", .dailyLife, 3, .recommended, .mapHub),
            step("documents", "Documents", "Documenten", "Документы", "Keep official letters and scans organized.", "Bewaar officiële brieven en scans overzichtelijk.", "Храните официальные письма и сканы в порядке.", "folder.fill", .setup, 4, .recommended, .lettersList),
            step("language", "Language", "Taal", "Язык", "Find library and taalhuis support.", "Vind bibliotheek- en taalhuisondersteuning.", "Найдите поддержку в библиотеке и taalhuis.", "book.fill", .growth, 5, .optional, .mapFocus(.education))
        ]
    )

    static let student = make(
        id: "student",
        status: .student,
        title: text("Student path", "Studentenpad", "Путь студента"),
        description: text("Universities, DUO, student housing, finance, insurance, transport discounts, language, student jobs, study spaces, city life, and free time.", "Universiteiten, DUO, studentenhuisvesting, financiering, verzekering, vervoerskorting, taal, studentenbanen, studieplekken, stadsleven en vrije tijd.", "Университеты, DUO, студенческое жильё, финансы, страховка, скидки на транспорт, язык, студенческая работа, места для учебы, городская жизнь и свободное время."),
        steps: [
            step("student-universities", "Universities / MBO / HBO", "Universiteiten / MBO / HBO", "Университеты / MBO / HBO", "Compare MBO, HBO, and research university routes.", "Vergelijk MBO-, HBO- en onderzoeksuniversiteitsroutes.", "Сравните маршруты MBO, HBO и исследовательских университетов.", "graduationcap.fill", .foundation, 1, .recommended, .institutionsList),
            step("student-duo", "DUO and student finance", "DUO en studiefinanciering", "DUO и студенческие финансы", "Understand DUO, student finance, and study support sources.", "Begrijp DUO, studiefinanciering en studiebronnen.", "Поймите DUO, студенческие финансы и источники поддержки учебы.", "creditcard.fill", .foundation, 2, .recommended, .officialSources),
            step("student-housing", "Student housing", "Studentenhuisvesting", "Студенческое жильё", "Find a safe student housing route and housing proof.", "Zoek veilige studentenhuisvesting en woonbewijs.", "Найдите безопасный путь к студенческому жилью и подтверждение жилья.", "house.fill", .foundation, 3, .recommended, .beginnerGuidesList),
            step("student-insurance", "Student insurance", "Studentenverzekering", "Студенческая страховка", "Review student insurance and healthcare basics.", "Bekijk studentenverzekering en zorgbasis.", "Изучите студенческую страховку и основы медицины.", "cross.case.fill", .setup, 4, .recommended, .practicalGuide(.healthInsuranceBasics)),
            step("student-transport", "Public transport discounts", "Studentenkorting OV", "Скидки на общественный транспорт", "Learn student transport discounts, OV, and campus routes.", "Leer studentenkorting, OV en routes naar campus kennen.", "Разберитесь со студенческими скидками на транспорт, OV и маршрутами до кампуса.", "tram.fill", .setup, 5, .recommended, .practicalGuide(.transportBasics)),
            step("student-language", "Dutch language courses", "Nederlandse taalcursussen", "Курсы нидерландского языка", "Find Dutch courses, libraries, and learning communities.", "Vind taalcursussen, bibliotheken en leergemeenschappen.", "Найдите курсы нидерландского, библиотеки и учебные сообщества.", "book.fill", .growth, 6, .recommended, .mapFocus(.education)),
            step("student-jobs", "Student jobs", "Studentenbanen", "Студенческая работа", "Explore student jobs without unrelated bureaucracy.", "Verken studentenbanen zonder onnodige bureaucratie.", "Изучите студенческую работу без лишней бюрократии.", "briefcase.fill", .growth, 7, .optional, .searchList),
            step("student-community", "Libraries and student communities", "Bibliotheken en studentengroepen", "Библиотеки и студенческие сообщества", "Find libraries, study spaces, and student groups nearby.", "Vind bibliotheken, studieplekken en studentengroepen dichtbij.", "Найдите библиотеки, места для учебы и студенческие группы рядом.", "person.3.fill", .growth, 8, .optional, .mapFocus(.education)),
            step("student-events", "Student events", "Studentenevenementen", "Студенческие события", "Find communities, events, and campus life.", "Vind communities, evenementen en campusleven.", "Найдите сообщества, события и кампусную жизнь.", "calendar", .dailyLife, 9, .optional, .mapHub),
            step("student-free-time", "City life and free time", "Stadsleven en vrije tijd", "Городская жизнь и свободное время", "Explore student-friendly city life and free time.", "Ontdek studentvriendelijk stadsleven en vrije tijd.", "Изучите городскую жизнь и свободное время для студентов.", "sparkles", .dailyLife, 10, .later, .mapHub)
        ]
    )

    static let worker = make(
        id: "worker",
        status: .worker,
        title: text("Worker path", "Werkerspad", "Путь работника"),
        description: text("BSN, DigiD, work contracts, taxes, UWV, salary, employment rights, health insurance, housing, transport, pension, and worker training.", "BSN, DigiD, arbeidscontracten, belasting, UWV, salaris, arbeidsrechten, zorgverzekering, wonen, vervoer, pensioen en scholing.", "BSN, DigiD, трудовые договоры, налоги, UWV, зарплата, трудовые права, медицинская страховка, жильё, транспорт, пенсия и обучение работников."),
        steps: [
            step("worker-bsn", "BSN", "BSN", "BSN", "Confirm the BSN step for work and official services.", "Controleer de BSN-stap voor werk en officiële diensten.", "Проверьте шаг BSN для работы и официальных сервисов.", "number", .foundation, 1, .recommended, .checklistList),
            step("worker-digid", "DigiD", "DigiD", "DigiD", "Set up official digital access.", "Regel officiële digitale toegang.", "Настройте официальный цифровой доступ.", "key.fill", .foundation, 2, .recommended, .beginnerGuidesList),
            step("worker-contract", "Work contracts", "Arbeidscontracten", "Трудовые договоры", "Know what to review in your contract.", "Weet wat u controleert in uw contract.", "Поймите, что проверять в трудовом договоре.", "doc.text.fill", .foundation, 3, .recommended, .institutionsList),
            step("worker-taxes", "Taxes", "Belasting", "Налоги", "Learn where worker tax information comes from.", "Leer waar belastinginformatie voor werk vandaan komt.", "Поймите источники налоговой информации для работы.", "eurosign.circle.fill", .setup, 4, .recommended, .officialSources),
            step("worker-uwv", "UWV", "UWV", "UWV", "Use UWV for worker-specific employment information.", "Gebruik UWV voor werkspecifieke informatie.", "Используйте UWV для информации по работе.", "building.columns.fill", .setup, 5, .recommended, .governmentHub),
            step("worker-salary", "Salary", "Salaris", "Зарплата", "Understand payslips and salary basics.", "Begrijp loonstroken en salarisbasis.", "Разберитесь с расчетными листками и зарплатой.", "banknote.fill", .dailyLife, 6, .recommended, .institutionsList),
            step("worker-rights", "Employment rights", "Arbeidsrechten", "Трудовые права", "Find employment-rights guidance for questions.", "Vind informatie over arbeidsrechten bij vragen.", "Найдите информацию о трудовых правах.", "shield.lefthalf.filled", .dailyLife, 7, .recommended, .officialSources),
            step("worker-insurance", "Health insurance", "Zorgverzekering", "Медицинская страховка", "Review worker health insurance basics.", "Bekijk zorgverzekering voor werknemers.", "Изучите медицинскую страховку для работников.", "cross.case.fill", .dailyLife, 8, .recommended, .practicalGuide(.healthInsuranceBasics)),
            step("worker-housing", "Housing", "Wonen", "Жильё", "Keep worker housing and rental documents clear.", "Houd woon- en huurdocumenten duidelijk.", "Держите документы жилья и аренды в порядке.", "house.fill", .dailyLife, 9, .optional, .practicalGuide(.housingBasics)),
            step("worker-transport", "Transport", "Vervoer", "Транспорт", "Plan commuting and local transport.", "Plan woon-werkverkeer en lokaal vervoer.", "Планируйте дорогу на работу и местный транспорт.", "tram.fill", .dailyLife, 10, .optional, .practicalGuide(.transportBasics)),
            step("worker-pension", "Pension", "Pensioen", "Пенсия", "Understand pension basics for workers.", "Begrijp pensioenbasis voor werknemers.", "Разберитесь с основами пенсии для работников.", "chart.line.uptrend.xyaxis", .longTerm, 11, .later, .officialSources),
            step("worker-training", "Worker training", "Scholing voor werknemers", "Обучение работников", "Find training routes connected to work.", "Vind scholingsroutes rond werk.", "Найдите маршруты обучения, связанные с работой.", "book.fill", .longTerm, 12, .later, .institutionsList)
        ]
    )

    static let refugee = make(
        id: "refugee",
        status: .refugee,
        title: text("Refugee / status holder path", "Pad voor statushouders", "Путь беженца / статусхолдера"),
        description: text("IND, municipality, housing, benefits, integration, language, healthcare, documents, work permissions, education access, and support organizations.", "IND, gemeente, huisvesting, uitkeringen, integratie, taal, zorg, documenten, werkvergunningen, toegang tot onderwijs en steunorganisaties.", "IND, муниципалитет, жильё, пособия, интеграция, язык, здравоохранение, документы, разрешения на работу, доступ к образованию и организации поддержки."),
        steps: [
            step("refugee-ind", "IND", "IND", "IND", "Keep IND status information organized.", "Houd IND-statusinformatie overzichtelijk.", "Держите информацию IND по статусу в порядке.", "building.columns.fill", .foundation, 1, .recommended, .governmentHub),
            step("refugee-municipality", "Municipality", "Gemeente", "Муниципалитет", "Find city services and registration direction.", "Vind stadsdiensten en registratierichting.", "Найдите городские сервисы и направление регистрации.", "building.columns.fill", .foundation, 2, .recommended, .mapFocus(.government)),
            step("refugee-housing", "Housing", "Wonen", "Жильё", "Track housing documents and official communication.", "Volg woondocumenten en officiële communicatie.", "Отслеживайте документы по жилью и официальную коммуникацию.", "house.fill", .foundation, 3, .recommended, .beginnerGuidesList),
            step("refugee-benefits", "Benefits", "Uitkeringen", "Пособия", "Learn which official sources explain support.", "Leer welke officiële bronnen steun uitleggen.", "Узнайте, какие официальные источники объясняют поддержку.", "eurosign.circle.fill", .setup, 4, .recommended, .officialSources),
            step("refugee-integration", "Integration", "Integratie", "Интеграция", "Find integration steps and official context.", "Vind integratiestappen en officiële context.", "Найдите шаги интеграции и официальный контекст.", "figure.walk.motion", .setup, 5, .recommended, .knm),
            step("refugee-language", "Language", "Taal", "Язык", "Find language and integration support.", "Vind taal- en integratieondersteuning.", "Найдите поддержку по языку и интеграции.", "book.fill", .growth, 6, .recommended, .mapFocus(.education)),
            step("refugee-healthcare", "Healthcare", "Zorg", "Медицина", "Review healthcare access and local points.", "Bekijk toegang tot zorg en lokale punten.", "Изучите доступ к медицине и места рядом.", "cross.case.fill", .growth, 7, .recommended, .mapFocus(.healthcare)),
            step("refugee-documents", "Documents", "Documenten", "Документы", "Keep documents and official letters organized.", "Bewaar documenten en officiële brieven goed.", "Храните документы и официальные письма в порядке.", "doc.text.fill", .growth, 8, .recommended, .journeyDocuments),
            step("refugee-work-permissions", "Work permissions", "Werkvergunningen", "Разрешения на работу", "Check work-permission information for your status.", "Controleer informatie over werkvergunningen voor uw status.", "Проверьте информацию о разрешениях на работу для вашего статуса.", "briefcase.fill", .longTerm, 9, .optional, .officialSources),
            step("refugee-education", "Education access", "Toegang tot onderwijs", "Доступ к образованию", "Find education access and learning routes.", "Vind toegang tot onderwijs en leerroutes.", "Найдите доступ к образованию и учебные маршруты.", "graduationcap.fill", .longTerm, 10, .optional, .mapFocus(.education)),
            step("refugee-support", "Support organizations", "Steunorganisaties", "Организации поддержки", "Find local support organizations.", "Vind lokale steunorganisaties.", "Найдите местные организации поддержки.", "person.3.fill", .longTerm, 11, .optional, .mapHub)
        ]
    )

    static let ukrainian = make(id: "ukrainian", status: .ukrainian, title: text("Ukrainian temporary protection path", "Pad tijdelijke bescherming", "Путь временной защиты"), description: refugee.localizedDescription, steps: refugee.recommendedSteps)
    static let expat = make(id: "expat", status: .expat, title: text("Expat path", "Expatpad", "Путь экспата"), description: worker.localizedDescription, steps: worker.recommendedSteps)
    static let highlySkilledMigrant = make(
        id: "highly-skilled-migrant",
        status: .highlySkilledMigrant,
        title: text("Highly skilled migrant path", "Kennismigrantenpad", "Путь высококвалифицированного мигранта"),
        description: text("IND sponsor, BSN, DigiD, salary, 30% ruling, housing, insurance, and family relocation.", "IND-referent, BSN, DigiD, salaris, 30%-regeling, wonen, verzekering en gezinsverhuizing.", "IND-спонсор, BSN, DigiD, зарплата, 30%-regeling, жильё, страховка и переезд семьи."),
        steps: [
            step("hsm-ind", "IND / sponsor", "IND / referent", "IND / спонсор", "Check your recognized sponsor and IND route.", "Controleer uw erkend referent en IND-route.", "Проверьте признанного спонсора и маршрут IND.", "person.text.rectangle", .foundation, 1, .recommended, .institutionsList),
            step("hsm-bsn", "BSN and registration", "BSN en registratie", "BSN и регистрация", "Register with the municipality and get BSN.", "Schrijf u in bij de gemeente en regel BSN.", "Зарегистрируйтесь в gemeente и получите BSN.", "number", .foundation, 2, .recommended, .checklistList),
            step("hsm-digid", "DigiD", "DigiD", "DigiD", "Set up official digital access.", "Regel officiële digitale toegang.", "Настройте официальный цифровой доступ.", "key.fill", .setup, 3, .recommended, .beginnerGuidesList),
            step("hsm-tax", "30% ruling / tax", "30%-regeling / belasting", "30%-regeling / налоги", "Understand tax and 30% ruling source paths.", "Begrijp belasting- en 30%-regeling-bronnen.", "Поймите источники по налогам и 30%-regeling.", "percent", .setup, 4, .recommended, .institutionsList),
            step("hsm-housing", "Housing and insurance", "Wonen en verzekering", "Жильё и страховка", "Arrange housing documents and health insurance.", "Regel woondocumenten en zorgverzekering.", "Подготовьте документы жилья и медицинскую страховку.", "house.fill", .dailyLife, 5, .recommended, .mapFocus(.healthcare))
        ]
    )
    static let euCitizen = make(
        id: "eu-citizen",
        status: .euCitizen,
        title: text("EU citizen path", "EU-burgerpad", "Путь гражданина ЕС"),
        description: text("Registration, BSN, DigiD, work rights, healthcare, housing, tax, and municipality services.", "Registratie, BSN, DigiD, werkrechten, zorg, wonen, belasting en gemeentelijke diensten.", "Регистрация, BSN, DigiD, права на работу, медицина, жильё, налоги и gemeente."),
        steps: [
            step("eu-registration", "Municipality registration", "Gemeentelijke registratie", "Регистрация в gemeente", "Check when and where to register.", "Controleer wanneer en waar u zich inschrijft.", "Проверьте, когда и где регистрироваться.", "building.columns.fill", .foundation, 1, .recommended, .mapFocus(.government)),
            step("eu-bsn", "BSN", "BSN", "BSN", "Use BSN for work, healthcare, bank, and official services.", "Gebruik BSN voor werk, zorg, bank en officiële diensten.", "BSN нужен для работы, медицины, банка и официальных сервисов.", "number", .foundation, 2, .recommended, .checklistList),
            step("eu-digid", "DigiD", "DigiD", "DigiD", "Set up digital access to services.", "Regel digitale toegang tot diensten.", "Настройте цифровой доступ к сервисам.", "key.fill", .setup, 3, .recommended, .beginnerGuidesList),
            step("eu-health", "Healthcare", "Zorg", "Медицина", "Review health insurance and GP basics.", "Bekijk zorgverzekering en huisartsbasis.", "Изучите медстраховку и huisarts.", "cross.case.fill", .setup, 4, .recommended, .mapFocus(.healthcare)),
            step("eu-work-tax", "Work rights / taxes", "Werkrechten / belasting", "Права на работу / налоги", "Understand work and tax basics.", "Begrijp werk- en belastingbasis.", "Разберитесь с работой и налогами.", "briefcase.fill", .dailyLife, 5, .optional, .institutionsList)
        ]
    )
    static let family = make(
        id: "family",
        status: .family,
        title: text("Family path", "Gezinspad", "Путь семьи"),
        description: text("Schools, childcare, kinderopvang, SVB, child benefits, family housing, healthcare, activities, and municipal services.", "Scholen, opvang, kinderopvang, SVB, kinderbijslag, gezinswoning, zorg, activiteiten en gemeentelijke diensten.", "Школы, уход за детьми, kinderopvang, SVB, детские пособия, семейное жильё, здравоохранение, занятия и муниципальные услуги."),
        steps: [
            step("family-schools", "Schools", "Scholen", "Школы", "Find school information for children.", "Vind schoolinformatie voor kinderen.", "Найдите информацию о школах для детей.", "graduationcap.fill", .foundation, 1, .recommended, .mapFocus(.education)),
            step("family-childcare", "Childcare", "Opvang", "Уход за детьми", "Review childcare options for your family.", "Bekijk opvangopties voor uw gezin.", "Изучите варианты ухода за детьми для семьи.", "figure.2.and.child.holdinghands", .foundation, 2, .recommended, .officialSources),
            step("family-kinderopvang", "Kinderopvang", "Kinderopvang", "Kinderopvang", "Use kinderopvang sources and local services.", "Gebruik kinderopvangbronnen en lokale diensten.", "Используйте источники по kinderopvang и местные сервисы.", "figure.and.child.holdinghands", .setup, 3, .recommended, .officialSources),
            step("family-svb", "SVB", "SVB", "SVB", "Find SVB information for family support.", "Vind SVB-informatie voor gezinsondersteuning.", "Найдите информацию SVB для поддержки семьи.", "building.columns.fill", .setup, 4, .recommended, .officialSources),
            step("family-child-benefits", "Child benefits", "Kinderbijslag", "Детские пособия", "Understand child-benefit sources.", "Begrijp bronnen voor kinderbijslag.", "Разберитесь с источниками по детским пособиям.", "creditcard.fill", .setup, 5, .recommended, .officialSources),
            step("family-housing", "Family housing", "Gezinswoning", "Семейное жильё", "Review family housing and rental basics.", "Bekijk gezinswoning en huurbasis.", "Изучите семейное жильё и основы аренды.", "house.fill", .dailyLife, 6, .recommended, .practicalGuide(.housingBasics)),
            step("family-healthcare", "Healthcare", "Zorg", "Здравоохранение", "Review family healthcare basics.", "Bekijk zorgbasis voor het gezin.", "Изучите основы здравоохранения для семьи.", "cross.case.fill", .dailyLife, 7, .recommended, .practicalGuide(.healthcareBasics)),
            step("family-activities", "Activities", "Activiteiten", "Занятия", "Find family activities nearby.", "Vind gezinsactiviteiten dichtbij.", "Найдите семейные занятия рядом.", "sparkles", .dailyLife, 8, .optional, .mapHub),
            step("family-municipal-services", "Municipal services", "Gemeentelijke diensten", "Муниципальные услуги", "Find municipal services for families.", "Vind gemeentelijke diensten voor gezinnen.", "Найдите муниципальные услуги для семей.", "building.2.fill", .longTerm, 9, .optional, .governmentHub)
        ]
    )
    static let tourist = make(id: "tourist", status: .tourist, title: text("Temporary stay path", "Tijdelijk verblijf", "Временное пребывание"), description: text("Transport, safety, documents, city orientation, and emergency information.", "Vervoer, veiligheid, documenten, stad en noodinformatie.", "Транспорт, безопасность, документы, город и экстренная информация."), steps: [step("tourist-transport", "Transport", "Vervoer", "Транспорт", "Learn OV, station, and local mobility.", "Leer OV, station en lokale mobiliteit.", "Разберитесь с OV, станцией и местным транспортом.", "tram.fill", .dailyLife, 1, .recommended, .mapFocus(.transport)), step("tourist-safety", "Emergency / safety", "Nood / veiligheid", "Экстренно / безопасность", "Know urgent and non-urgent safety directions.", "Ken urgente en niet-urgente veiligheidsroutes.", "Знайте срочные и несрочные направления безопасности.", "phone.fill", .foundation, 2, .recommended, .mapFocus(.emergency)), step("tourist-city", "City services", "Stadsdiensten", "Городские сервисы", "Use the city guide for orientation.", "Gebruik de stadsgids voor orientatie.", "Используйте городской гид для ориентации.", "map.fill", .dailyLife, 3, .recommended, .mapHub)])
    static let entrepreneur = make(
        id: "entrepreneur",
        status: .entrepreneur,
        title: text("Entrepreneur path", "Ondernemerspad", "Путь предпринимателя"),
        description: text("KvK, business registration, VAT, taxes, banking, insurance, permits, and contracts.", "KvK, bedrijfsregistratie, BTW, belasting, bank, verzekering, vergunningen en contracten.", "KvK, регистрация бизнеса, VAT/BTW, налоги, банк, страховка, разрешения и договоры."),
        steps: [
            step("entrepreneur-kvk", "KvK / business setup", "KvK / bedrijf starten", "KvK / старт бизнеса", "Prepare registration and business details.", "Bereid registratie en bedrijfsgegevens voor.", "Подготовьте регистрацию и данные бизнеса.", "building.2.crop.circle", .foundation, 1, .recommended, .institutionsList),
            step("entrepreneur-tax", "VAT / taxes", "BTW / belasting", "VAT / налоги", "Understand VAT and tax source paths.", "Begrijp BTW- en belastingbronnen.", "Поймите источники по VAT/BTW и налогам.", "eurosign.circle.fill", .setup, 2, .recommended, .institutionsList),
            step("entrepreneur-bank", "Banking and insurance", "Bank en verzekering", "Банк и страховка", "Set up business banking and relevant insurance.", "Regel zakelijke bankzaken en relevante verzekering.", "Настройте бизнес-банк и нужную страховку.", "creditcard.fill", .setup, 3, .recommended, .beginnerGuidesList),
            step("entrepreneur-permits", "Permits", "Vergunningen", "Разрешения", "Check municipality and business permit routes.", "Controleer gemeente- en bedrijfsvergunningen.", "Проверьте маршруты разрешений в gemeente.", "checkmark.seal.fill", .dailyLife, 4, .optional, .mapFocus(.government))
        ]
    )
    static let lgbtNewcomer = make(
        id: "lgbt-newcomer",
        status: .lgbtNewcomer,
        title: text("LGBT newcomer path", "LHBTI-nieuwkomerspad", "Путь ЛГБТ-новичка"),
        description: text("Safety, rights, healthcare, mental health, community, legal support, and housing safety.", "Veiligheid, rechten, zorg, mentale gezondheid, gemeenschap, juridische hulp en woonveiligheid.", "Безопасность, права, медицина, психическое здоровье, сообщество, юридическая поддержка и безопасное жильё."),
        steps: [
            step("lgbt-safety", "Safety and support", "Veiligheid en steun", "Безопасность и поддержка", "Find safe support and emergency routes.", "Vind veilige steun en spoedroutes.", "Найдите безопасную поддержку и экстренные маршруты.", "heart.circle", .foundation, 1, .recommended, .lgbtqSupport),
            step("lgbt-health", "Healthcare", "Zorg", "Медицина", "Find healthcare and mental health support.", "Vind zorg en mentale ondersteuning.", "Найдите медицинскую и психологическую поддержку.", "cross.case.fill", .setup, 2, .recommended, .mapFocus(.healthcare)),
            step("lgbt-rights", "Rights and legal help", "Rechten en juridische hulp", "Права и юридическая помощь", "Use legal support routes for rights or discrimination questions.", "Gebruik juridische hulp bij rechten- of discriminatievragen.", "Используйте юридическую поддержку по правам или дискриминации.", "scalemass.fill", .setup, 3, .recommended, .institutionsList),
            step("lgbt-community", "Community", "Gemeenschap", "Сообщество", "Find community organizations and safe spaces.", "Vind organisaties en veilige plekken.", "Найдите организации и безопасные пространства.", "person.3.fill", .growth, 4, .optional, .lgbtqSupport)
        ]
    )

    static func make(id: String, status: UserStatus?, title: PathLocalizedText, description: PathLocalizedText, steps: [PathStep]) -> UserPathProfile {
        UserPathProfile(
            id: id,
            status: status,
            localizedTitle: title,
            localizedDescription: description,
            recommendedSteps: steps,
            priorityCategories: [.documents, .housing, .healthcare, .transport, .government, .helpNearby],
            cityRelevantPlaces: [.municipality, .library, .transport, .healthcare, .legalHelp, .community]
        )
    }

    static func step(_ id: String, _ enTitle: String, _ nlTitle: String, _ ruTitle: String, _ enDescription: String, _ nlDescription: String, _ ruDescription: String, _ icon: String, _ phase: PathStepPhase, _ priority: Int, _ status: PathStepStatus, _ destination: AppDestination) -> PathStep {
        PathStep(
            id: id,
            localizedTitle: text(enTitle, nlTitle, ruTitle),
            localizedDescription: text(enDescription, nlDescription, ruDescription),
            categoryId: phase.rawValue,
            priority: priority,
            phase: phase,
            icon: icon,
            status: status,
            destination: destination
        )
    }

    static func text(_ english: String, _ dutch: String, _ russian: String) -> PathLocalizedText {
        PathLocalizedText(english: english, dutch: dutch, russian: russian)
    }
}
