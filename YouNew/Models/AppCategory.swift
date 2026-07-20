import SwiftUI

struct AppCategory: Identifiable {
    let id: String
    let titleEN: String
    let titleNL: String
    let titleRU: String
    let subtitleEN: String
    let subtitleNL: String
    let subtitleRU: String
    let icon: String
    let color: Color
    let destination: AppDestination

    func title(_ lang: AppLanguage) -> String {
        switch lang {
        case .english: return titleEN
        case .dutch:   return titleNL
        case .russian: return titleRU
        }
    }

    func subtitle(_ lang: AppLanguage) -> String {
        switch lang {
        case .english: return subtitleEN
        case .dutch:   return subtitleNL
        case .russian: return subtitleRU
        }
    }
}

enum AppCategoryRegistry {
    static func forPersona(_ persona: PersonaTag?) -> [AppCategory] {
        switch persona {
        case .student:
            return [
                category(
                    id: "student-study",
                    titleEN: "Universities",
                    titleNL: "Universiteiten",
                    titleRU: "Университеты",
                    subtitleEN: "MBO, HBO, research universities, DUO",
                    subtitleNL: "MBO, HBO, onderzoeksuniversiteiten, DUO",
                    subtitleRU: "MBO, HBO, исследовательские университеты, DUO",
                    icon: "graduationcap.fill",
                    color: AppColors.emerald,
                    destination: .beginnerGuidesList
                ),
                category(
                    id: "student-housing",
                    titleEN: "Student housing",
                    titleNL: "Studentenhuisvesting",
                    titleRU: "Студенческое жилье",
                    subtitleEN: "Rooms, registration, study spaces",
                    subtitleNL: "Kamers, inschrijving, studieplekken",
                    subtitleRU: "Комнаты, регистрация, места для учебы",
                    icon: "house.fill",
                    color: AppColors.warning,
                    destination: .housingSection(.studentHousing)
                ),
                category(
                    id: "student-finance",
                    titleEN: "Student finance",
                    titleNL: "Studiefinanciering",
                    titleRU: "Студенческие финансы",
                    subtitleEN: "DUO, insurance, discounts, student jobs",
                    subtitleNL: "DUO, verzekering, kortingen, bijbanen",
                    subtitleRU: "DUO, страховка, скидки, подработки",
                    icon: "creditcard.fill",
                    color: AppColors.dutchOrange,
                    destination: .officialSources
                ),
                category(
                    id: "student-language",
                    titleEN: "Dutch language courses",
                    titleNL: "Nederlandse taalcursussen",
                    titleRU: "Курсы нидерландского",
                    subtitleEN: "A1-A2, campus language, daily phrases",
                    subtitleNL: "A1-A2, campustaal, dagelijkse zinnen",
                    subtitleRU: "A1-A2, язык кампуса, бытовые фразы",
                    icon: "text.book.closed.fill",
                    color: AppColors.violet,
                    destination: .dutchA1A2
                ),
                category(
                    id: "student-city-life",
                    titleEN: "City life",
                    titleNL: "Stadsleven",
                    titleRU: "Жизнь в городе",
                    subtitleEN: "Libraries, communities, events, free time",
                    subtitleNL: "Bibliotheken, communities, events, vrije tijd",
                    subtitleRU: "Библиотеки, сообщества, события, свободное время",
                    icon: "building.2.fill",
                    color: AppColors.softBlue,
                    destination: .cityList
                )
            ]
        case .worker:
            return [
                category(id: "worker-documents", titleEN: "BSN and DigiD", titleNL: "BSN en DigiD", titleRU: "BSN и DigiD", subtitleEN: "Registration, identity, official access", subtitleNL: "Inschrijving, identiteit, officiële toegang", subtitleRU: "Регистрация, личность, доступ к госуслугам", icon: "doc.text.fill", color: AppColors.softBlue, destination: .guideSection("documents")),
                category(id: "worker-employment", titleEN: "Work contracts", titleNL: "Arbeidscontracten", titleRU: "Рабочие контракты", subtitleEN: "Salary, rights, UWV, employment rules", subtitleNL: "Salaris, rechten, UWV, werkregels", subtitleRU: "Зарплата, права, UWV, правила работы", icon: "briefcase.fill", color: AppColors.emerald, destination: .workSection(.overview)),
                category(id: "worker-taxes", titleEN: "Taxes", titleNL: "Belastingen", titleRU: "Налоги", subtitleEN: "Belastingdienst, payslips, annual return", subtitleNL: "Belastingdienst, loonstroken, aangifte", subtitleRU: "Belastingdienst, расчетные листы, декларация", icon: "percent", color: AppColors.dutchOrange, destination: .officialSources),
                category(id: "worker-health", titleEN: "Health insurance", titleNL: "Zorgverzekering", titleRU: "Медицинская страховка", subtitleEN: "Insurance, GP, healthcare access", subtitleNL: "Verzekering, huisarts, toegang tot zorg", subtitleRU: "Страховка, huisarts, доступ к медицине", icon: "cross.case.fill", color: AppColors.success, destination: .healthSection(.insurance)),
                category(id: "worker-housing-transport", titleEN: "Housing and transport", titleNL: "Wonen en vervoer", titleRU: "Жилье и транспорт", subtitleEN: "Rent, commute, OV, bike basics", subtitleNL: "Huur, woon-werkreis, OV, fiets", subtitleRU: "Аренда, дорога на работу, OV, велосипед", icon: "tram.fill", color: AppColors.accent, destination: .practicalGuide(.transportBasics))
            ]
        case .refugee:
            return [
                category(id: "refugee-ind", titleEN: "IND and municipality", titleNL: "IND en gemeente", titleRU: "IND и муниципалитет", subtitleEN: "Status, documents, appointments", subtitleNL: "Status, documenten, afspraken", subtitleRU: "Статус, документы, встречи", icon: "building.columns.fill", color: AppColors.softBlue, destination: .governmentHub),
                category(id: "refugee-housing-benefits", titleEN: "Housing and benefits", titleNL: "Wonen en uitkeringen", titleRU: "Жилье и пособия", subtitleEN: "Local housing path and support", subtitleNL: "Lokale woonroute en steun", subtitleRU: "Местный путь к жилью и поддержке", icon: "house.fill", color: AppColors.warning, destination: .housingSection(.overview)),
                category(id: "refugee-integration", titleEN: "Integration", titleNL: "Integratie", titleRU: "Интеграция", subtitleEN: "Language, healthcare, education access", subtitleNL: "Taal, zorg, toegang tot onderwijs", subtitleRU: "Язык, медицина, доступ к образованию", icon: "person.2.fill", color: AppColors.emerald, destination: .guideSection("integration")),
                category(id: "refugee-documents", titleEN: "Documents", titleNL: "Documenten", titleRU: "Документы", subtitleEN: "Letters, permissions, official records", subtitleNL: "Brieven, toestemmingen, officiële gegevens", subtitleRU: "Письма, разрешения, официальные данные", icon: "doc.text.fill", color: AppColors.violet, destination: .journeyDocuments),
                category(id: "refugee-support", titleEN: "Support organizations", titleNL: "Steunorganisaties", titleRU: "Организации поддержки", subtitleEN: "Nearby help and local services", subtitleNL: "Hulp dichtbij en lokale diensten", subtitleRU: "Помощь рядом и местные службы", icon: "map.fill", color: AppColors.accent, destination: .mapFocus(.government))
            ]
        case .family:
            return [
                category(id: "family-schools", titleEN: "Schools", titleNL: "Scholen", titleRU: "Школы", subtitleEN: "Education, enrolment, libraries", subtitleNL: "Onderwijs, inschrijving, bibliotheken", subtitleRU: "Образование, запись, библиотеки", icon: "graduationcap.fill", color: AppColors.emerald, destination: .mapFocus(.education)),
                category(id: "family-childcare", titleEN: "Childcare", titleNL: "Kinderopvang", titleRU: "Детский сад", subtitleEN: "Kinderopvang and municipal services", subtitleNL: "Kinderopvang en gemeentelijke diensten", subtitleRU: "Kinderopvang и муниципальные услуги", icon: "figure.and.child.holdinghands", color: AppColors.softBlue, destination: .officialSources),
                category(id: "family-benefits", titleEN: "SVB and child benefits", titleNL: "SVB en kinderbijslag", titleRU: "SVB и детские пособия", subtitleEN: "Family support and allowances", subtitleNL: "Gezinssteun en toeslagen", subtitleRU: "Поддержка семьи и пособия", icon: "building.columns.fill", color: AppColors.dutchOrange, destination: .officialSources),
                category(id: "family-housing-health", titleEN: "Family housing and healthcare", titleNL: "Gezinswoning en zorg", titleRU: "Семейное жилье и медицина", subtitleEN: "Housing, GP, insurance, children", subtitleNL: "Wonen, huisarts, verzekering, kinderen", subtitleRU: "Жилье, huisarts, страховка, дети", icon: "cross.case.fill", color: AppColors.success, destination: .healthSection(.overview)),
                category(id: "family-activities", titleEN: "Activities", titleNL: "Activiteiten", titleRU: "Активности", subtitleEN: "Child-friendly places and city life", subtitleNL: "Kindvriendelijke plekken en stadsleven", subtitleRU: "Места для детей и городская жизнь", icon: "sparkles", color: AppColors.violet, destination: .cityList)
            ]
        case .highlySkilledMigrant:
            return [
                category(id: "hsm-ind", titleEN: "IND and employer", titleNL: "IND en werkgever", titleRU: "IND и работодатель", subtitleEN: "Residence, sponsor, appointments", subtitleNL: "Verblijf, referent, afspraken", subtitleRU: "ВНЖ, спонсор, встречи", icon: "building.columns.fill", color: AppColors.softBlue, destination: .governmentHub),
                category(id: "hsm-30", titleEN: "Salary and 30% ruling", titleNL: "Salaris en 30%-regeling", titleRU: "Зарплата и 30% ruling", subtitleEN: "Taxes, payroll, employment rights", subtitleNL: "Belasting, loon, arbeidsrechten", subtitleRU: "Налоги, зарплата, трудовые права", icon: "percent", color: AppColors.dutchOrange, destination: .officialSources),
                category(id: "hsm-family", titleEN: "Partner and family", titleNL: "Partner en gezin", titleRU: "Партнер и семья", subtitleEN: "Family arrival, schools, healthcare", subtitleNL: "Gezinskomst, scholen, zorg", subtitleRU: "Переезд семьи, школы, медицина", icon: "person.2.fill", color: AppColors.emerald, destination: .mapFocus(.education)),
                category(id: "hsm-housing", titleEN: "Housing", titleNL: "Wonen", titleRU: "Жилье", subtitleEN: "Renting, registration, utilities", subtitleNL: "Huren, inschrijving, nutsvoorzieningen", subtitleRU: "Аренда, регистрация, коммунальные услуги", icon: "house.fill", color: AppColors.warning, destination: .housingSection(.rent))
            ]
        case .eu:
            return [
                category(id: "eu-registration", titleEN: "Registration", titleNL: "Inschrijving", titleRU: "Регистрация", subtitleEN: "BSN, municipality, DigiD", subtitleNL: "BSN, gemeente, DigiD", subtitleRU: "BSN, муниципалитет, DigiD", icon: "doc.text.fill", color: AppColors.softBlue, destination: .guideSection("documents")),
                category(id: "eu-work-study", titleEN: "Work or study", titleNL: "Werk of studie", titleRU: "Работа или учеба", subtitleEN: "Rights, contracts, education access", subtitleNL: "Rechten, contracten, onderwijs", subtitleRU: "Права, договоры, доступ к образованию", icon: "briefcase.fill", color: AppColors.emerald, destination: .beginnerGuidesList),
                category(id: "eu-health", titleEN: "Healthcare", titleNL: "Zorg", titleRU: "Медицина", subtitleEN: "Insurance, GP, EHIC questions", subtitleNL: "Verzekering, huisarts, EHIC-vragen", subtitleRU: "Страховка, huisarts, вопросы EHIC", icon: "cross.case.fill", color: AppColors.success, destination: .healthSection(.overview)),
                category(id: "eu-housing", titleEN: "Housing and transport", titleNL: "Wonen en vervoer", titleRU: "Жилье и транспорт", subtitleEN: "Rent, OV, bike, city setup", subtitleNL: "Huur, OV, fiets, start in de stad", subtitleRU: "Аренда, OV, велосипед, старт в городе", icon: "tram.fill", color: AppColors.accent, destination: .practicalGuide(.transportBasics))
            ]
        case .tourist:
            return [
                category(id: "tourist-transport", titleEN: "Transport", titleNL: "Vervoer", titleRU: "Транспорт", subtitleEN: "OV, bike, airport, city travel", subtitleNL: "OV, fiets, luchthaven, stadsreizen", subtitleRU: "OV, велосипед, аэропорт, город", icon: "tram.fill", color: AppColors.accent, destination: .practicalGuide(.transportBasics)),
                category(id: "tourist-emergency", titleEN: "Emergency", titleNL: "Noodhulp", titleRU: "Экстренная помощь", subtitleEN: "112, police, urgent healthcare", subtitleNL: "112, politie, spoedzorg", subtitleRU: "112, полиция, срочная помощь", icon: "phone.fill", color: AppColors.error, destination: .emergencyHub),
                category(id: "tourist-cities", titleEN: "Cities and free time", titleNL: "Steden en vrije tijd", titleRU: "Города и свободное время", subtitleEN: "Places, culture, activities", subtitleNL: "Plekken, cultuur, activiteiten", subtitleRU: "Места, культура, активности", icon: "building.2.fill", color: AppColors.softBlue, destination: .cityList),
                category(id: "tourist-health", titleEN: "Travel health", titleNL: "Reisgezondheid", titleRU: "Здоровье в поездке", subtitleEN: "Pharmacy, GP, hospital basics", subtitleNL: "Apotheek, huisarts, ziekenhuis", subtitleRU: "Аптека, huisarts, больница", icon: "cross.case.fill", color: AppColors.success, destination: .healthSection(.overview))
            ]
        case .entrepreneur:
            return [
                category(id: "entrepreneur-kvk", titleEN: "KVK", titleNL: "KVK", titleRU: "KVK", subtitleEN: "Business registration", subtitleNL: "Bedrijfsregistratie", subtitleRU: "Регистрация бизнеса", icon: "building.columns.fill", color: AppColors.softBlue, destination: .officialSources),
                category(id: "entrepreneur-vat", titleEN: "VAT / BTW", titleNL: "BTW", titleRU: "BTW", subtitleEN: "Business taxes and administration", subtitleNL: "Belasting en administratie", subtitleRU: "Налоги и администрация бизнеса", icon: "percent", color: AppColors.dutchOrange, destination: .officialSources),
                category(id: "entrepreneur-banking", titleEN: "Business banking", titleNL: "Zakelijk bankieren", titleRU: "Бизнес-банк", subtitleEN: "Banking, insurance, contracts", subtitleNL: "Bankieren, verzekering, contracten", subtitleRU: "Банк, страхование, договоры", icon: "creditcard.fill", color: AppColors.success, destination: .guideSection("documents")),
                category(id: "entrepreneur-permits", titleEN: "Permits", titleNL: "Vergunningen", titleRU: "Разрешения", subtitleEN: "Municipality rules and setup", subtitleNL: "Gemeentelijke regels en start", subtitleRU: "Муниципальные правила и старт", icon: "doc.badge.gearshape.fill", color: AppColors.warning, destination: .governmentHub)
            ]
        case .lgbt:
            return [
                category(id: "lgbt-support", titleEN: "LGBT support", titleNL: "LGBT steun", titleRU: "ЛГБТ поддержка", subtitleEN: "Safety, rights, community", subtitleNL: "Veiligheid, rechten, gemeenschap", subtitleRU: "Безопасность, права, сообщество", icon: "heart.text.square.fill", color: AppColors.violet, destination: .lgbtqSupport),
                category(id: "lgbt-health", titleEN: "Inclusive healthcare", titleNL: "Inclusieve zorg", titleRU: "Инклюзивная медицина", subtitleEN: "Healthcare, mental health, GP", subtitleNL: "Zorg, mentale gezondheid, huisarts", subtitleRU: "Медицина, психическое здоровье, huisarts", icon: "cross.case.fill", color: AppColors.success, destination: .healthSection(.overview)),
                category(id: "lgbt-safety", titleEN: "Housing safety", titleNL: "Woonveiligheid", titleRU: "Безопасность жилья", subtitleEN: "Safe housing and legal support", subtitleNL: "Veilig wonen en juridische steun", subtitleRU: "Безопасное жилье и юридическая помощь", icon: "house.fill", color: AppColors.warning, destination: .housingSection(.overview)),
                category(id: "lgbt-emotional", titleEN: "Emotional support", titleNL: "Emotionele steun", titleRU: "Эмоциональная поддержка", subtitleEN: "Crisis contacts and safe support", subtitleNL: "Crisiscontacten en veilige steun", subtitleRU: "Кризисные контакты и безопасная поддержка", icon: "figure.mind.and.body", color: AppColors.emerald, destination: .emotionalSupport)
            ]
        case .nonEU, .universal, nil:
            return all
        }
    }

    private static func category(
        id: String,
        titleEN: String,
        titleNL: String,
        titleRU: String,
        subtitleEN: String,
        subtitleNL: String,
        subtitleRU: String,
        icon: String,
        color: Color,
        destination: AppDestination
    ) -> AppCategory {
        AppCategory(
            id: id,
            titleEN: titleEN,
            titleNL: titleNL,
            titleRU: titleRU,
            subtitleEN: subtitleEN,
            subtitleNL: subtitleNL,
            subtitleRU: subtitleRU,
            icon: icon,
            color: color,
            destination: destination
        )
    }

    static let all: [AppCategory] = [
        AppCategory(
            id: "government",
            titleEN: "Government",
            titleNL: "Overheid",
            titleRU: "Государство",
            subtitleEN: "Gemeente, IND, DUO, UWV, Belastingdienst",
            subtitleNL: "Gemeente, IND, DUO, UWV, Belastingdienst",
            subtitleRU: "Gemeente, IND, DUO, UWV, Belastingdienst",
            icon: "building.columns.fill",
            color: AppColors.softBlue,
            destination: .governmentHub
        ),
        AppCategory(
            id: "help",
            titleEN: "Help & Life",
            titleNL: "Hulp & Leven",
            titleRU: "Помощь",
            subtitleEN: "Housing, Work, Health, Transport, Money",
            subtitleNL: "Wonen, Werk, Zorg, Vervoer, Geld",
            subtitleRU: "Жильё, Работа, Здоровье, Транспорт, Деньги",
            icon: "hands.and.sparkles.fill",
            color: AppColors.emerald,
            destination: .helpHub
        ),
        AppCategory(
            id: "language",
            titleEN: "Dutch Language",
            titleNL: "Nederlandse taal",
            titleRU: "Нидерландский",
            subtitleEN: "A1–A2, B1, phrases, exam, vocabulary",
            subtitleNL: "A1–A2, B1, zinnen, examen, woordenschat",
            subtitleRU: "A1–A2, B1, фразы, экзамен, словарь",
            icon: "text.book.closed.fill",
            color: AppColors.violet,
            destination: .languageHub
        ),
        AppCategory(
            id: "history",
            titleEN: "History & KNM",
            titleNL: "Geschiedenis & KNM",
            titleRU: "История и КНМ",
            subtitleEN: "Netherlands history, monarchy, parliament, KNM",
            subtitleNL: "Geschiedenis, monarchie, parlement, KNM",
            subtitleRU: "История, монархия, парламент, KNM",
            icon: "clock.arrow.circlepath",
            color: AppColors.cyanGlow,
            destination: .historyKNMHub
        ),
        AppCategory(
            id: "emergency",
            titleEN: "Emergency",
            titleNL: "Noodgevallen",
            titleRU: "Экстренные службы",
            subtitleEN: "112, police, huisarts, crisis support",
            subtitleNL: "112, politie, huisarts, crisisondersteuning",
            subtitleRU: "112, полиция, huisarts, кризисная помощь",
            icon: "phone.fill",
            color: Color(red: 198/255, green: 72/255, blue: 36/255),
            destination: .emergencyHub
        )
    ]
}
