import Foundation
import CoreLocation

enum CityNewcomerPlacesData {
    static let priorityCities = [
        "Amsterdam", "Leiden", "Rotterdam", "Den Haag", "Utrecht", "Eindhoven", "Groningen", "Maastricht",
        "Haarlem", "Arnhem", "Nijmegen", "Delft", "Zwolle", "Assen", "Leeuwarden", "Middelburg", "Almere"
    ]

    static func places(for cityId: String) -> [NewcomerPlace] {
        places(for: cityId, municipalityURL: officialWebsiteByCity[cityId])
    }

    static func places(for cityId: String, municipalityURL: String?) -> [NewcomerPlace] {
        placesByCity[cityId] ?? fallbackPlaces(cityId: cityId, municipalityURL: municipalityURL)
    }

    static func firstWeekSteps(for cityId: String) -> [CityNewcomerGuideItem] {
        firstWeekSteps(for: cityId, municipalityURL: officialWebsiteByCity[cityId])
    }

    static func firstWeekSteps(for cityId: String, municipalityURL: String?) -> [CityNewcomerGuideItem] {
        return [
            step("register", "building.columns.fill", en: "Check municipality registration", nl: "Controleer registratie bij de gemeente", ru: "Проверьте регистрацию в муниципалитете", den: "Use the official city website for appointments and requirements.", dnl: "Gebruik de officiële stadswebsite voor afspraken en voorwaarden.", dru: "Используйте официальный сайт города для записи и требований.", url: municipalityURL),
            step("insurance", "checkmark.shield.fill", en: "Arrange healthcare basics", nl: "Regel basiszaken voor zorg", ru: "Разберитесь с базовой медициной", den: "Find a GP route and verify health-insurance guidance from official sources.", dnl: "Zoek een huisartsroute en controleer zorgverzekeringsinformatie via officiële bronnen.", dru: "Найдите путь к huisarts и сверяйте информацию о страховке с официальными источниками.", url: "https://www.government.nl/topics/health-insurance"),
            step("digid", "key.fill", en: "Set up DigiD safely", nl: "Stel DigiD veilig in", ru: "Безопасно настройте DigiD", den: "Open DigiD directly from the official domain and avoid unknown links.", dnl: "Open DigiD direct via het officiële domein en vermijd onbekende links.", dru: "Открывайте DigiD только с официального домена и избегайте неизвестных ссылок.", url: "https://www.digid.nl/en"),
            step("transport", "tram.fill", en: "Learn local transport", nl: "Leer lokaal vervoer kennen", ru: "Изучите городской транспорт", den: "Save the main station and local operator, then verify tickets and check-in rules.", dnl: "Sla het hoofdstation en de vervoerder op en controleer kaartjes en incheckregels.", dru: "Сохраните главный вокзал и оператора транспорта, проверьте билеты и правила check-in.", url: "https://www.ns.nl"),
            step("language", "books.vertical.fill", en: "Find language/community support", nl: "Vind taal- en buurtsteun", ru: "Найдите языковую и городскую поддержку", den: "Libraries and Taalhuis-style services are useful orientation points.", dnl: "Bibliotheken en Taalhuis-achtige diensten zijn nuttige oriëntatiepunten.", dru: "Библиотеки и Taalhuis-подобные услуги помогают с ориентацией.", url: nil)
        ]
    }

    static func searchKeywords(for cityId: String) -> [String] {
        let base = [
            "BSN", "municipality", "city hall", "library", "Dutch language", "hospital", "legal help", "transport", "police", "housing", "student", "expat",
            "bsn", "gemeente", "stadhuis", "bibliotheek", "Nederlandse taal", "ziekenhuis", "juridisch loket", "vervoer", "politie", "wonen",
            "бсн", "муниципалитет", "регистрация", "библиотека", "нидерландский язык", "больница", "юридическая помощь", "транспорт", "полиция", "жильё"
        ]
        return base + places(for: cityId).flatMap { [$0.localizedTitle.english, $0.category.rawValue] + $0.localizedTags(.english) + $0.localizedTags(.dutch) + $0.localizedTags(.russian) }
    }

    static func cityCenter(for cityId: String) -> CLLocationCoordinate2D {
        cityCenterByCity[cityId] ?? CLLocationCoordinate2D(latitude: 52.1326, longitude: 5.2913)
    }

    private static let placesByCity: [String: [NewcomerPlace]] = Dictionary(
        priorityCities.map { city in
            (city, richPlaces(city: city, officialWebsite: officialWebsiteByCity[city]))
        },
        uniquingKeysWith: { first, _ in first }
    )

    private static let officialWebsiteByCity: [String: String] = [
        "Amsterdam": "https://www.amsterdam.nl",
        "Leiden": "https://www.leiden.nl",
        "Rotterdam": "https://www.rotterdam.nl",
        "Den Haag": "https://www.denhaag.nl",
        "Utrecht": "https://www.utrecht.nl",
        "Eindhoven": "https://www.eindhoven.nl",
        "Groningen": "https://gemeente.groningen.nl",
        "Maastricht": "https://www.maastricht.nl",
        "Haarlem": "https://www.haarlem.nl",
        "Arnhem": "https://www.arnhem.nl",
        "Nijmegen": "https://www.nijmegen.nl",
        "Delft": "https://www.delft.nl",
        "Zwolle": "https://www.zwolle.nl",
        "Assen": "https://www.assen.nl",
        "Leeuwarden": "https://www.leeuwarden.nl",
        "Middelburg": "https://www.middelburg.nl",
        "Almere": "https://www.almere.nl"
    ]

    private static let cityCenterByCity: [String: CLLocationCoordinate2D] = [
        "Amsterdam": CLLocationCoordinate2D(latitude: 52.3676, longitude: 4.9041),
        "Leiden": CLLocationCoordinate2D(latitude: 52.1601, longitude: 4.4970),
        "Rotterdam": CLLocationCoordinate2D(latitude: 51.9244, longitude: 4.4777),
        "Den Haag": CLLocationCoordinate2D(latitude: 52.0705, longitude: 4.3007),
        "Utrecht": CLLocationCoordinate2D(latitude: 52.0907, longitude: 5.1214),
        "Eindhoven": CLLocationCoordinate2D(latitude: 51.4416, longitude: 5.4697),
        "Groningen": CLLocationCoordinate2D(latitude: 53.2194, longitude: 6.5665),
        "Maastricht": CLLocationCoordinate2D(latitude: 50.8514, longitude: 5.6910),
        "Haarlem": CLLocationCoordinate2D(latitude: 52.3874, longitude: 4.6462),
        "Arnhem": CLLocationCoordinate2D(latitude: 51.9851, longitude: 5.8987),
        "Nijmegen": CLLocationCoordinate2D(latitude: 51.8426, longitude: 5.8528),
        "Delft": CLLocationCoordinate2D(latitude: 52.0116, longitude: 4.3571),
        "Zwolle": CLLocationCoordinate2D(latitude: 52.5168, longitude: 6.0830),
        "Assen": CLLocationCoordinate2D(latitude: 52.9928, longitude: 6.5642),
        "Leeuwarden": CLLocationCoordinate2D(latitude: 53.2012, longitude: 5.7999),
        "Middelburg": CLLocationCoordinate2D(latitude: 51.4988, longitude: 3.6100),
        "Almere": CLLocationCoordinate2D(latitude: 52.3508, longitude: 5.2647)
    ]

    private static func richPlaces(city: String, officialWebsite: String?) -> [NewcomerPlace] {
        let libraryURL: String?
        let transportURL: String?
        let hospitalName: String
        switch city {
        case "Amsterdam":
            libraryURL = "https://www.oba.nl"
            transportURL = "https://www.gvb.nl"
            hospitalName = "Amsterdam hospitals"
        case "Leiden":
            libraryURL = "https://www.bplusc.nl"
            transportURL = "https://www.ns.nl"
            hospitalName = "LUMC"
        case "Rotterdam":
            libraryURL = "https://www.bibliotheek.rotterdam.nl"
            transportURL = "https://www.ret.nl"
            hospitalName = "Rotterdam hospitals"
        case "Den Haag":
            libraryURL = "https://www.bibliotheekdenhaag.nl"
            transportURL = "https://www.htm.nl"
            hospitalName = "Den Haag hospitals"
        case "Utrecht":
            libraryURL = "https://www.bibliotheekutrecht.nl"
            transportURL = "https://www.u-ov.info"
            hospitalName = "Utrecht hospitals"
        case "Eindhoven":
            libraryURL = "https://www.bibliotheekeindhoven.nl"
            transportURL = "https://www.hermes.nl"
            hospitalName = "Eindhoven hospitals"
        case "Groningen":
            libraryURL = "https://forum.nl"
            transportURL = "https://www.qbuzz.nl"
            hospitalName = "UMCG"
        case "Maastricht":
            libraryURL = "https://www.centreceramique.nl"
            transportURL = "https://webshop.arriva.nl/"
            hospitalName = "Maastricht UMC+"
        default:
            libraryURL = nil
            transportURL = nil
            hospitalName = "Local healthcare access"
        }

        return [
            place(city, "municipality", .municipality, en: "Municipality services", nl: "Gemeentediensten", ru: "Муниципальные услуги", den: "Official city website for registration, BSN orientation, address changes, documents, appointments, and local services. Check current requirements before booking.", dnl: "Officiële stadswebsite voor inschrijving, BSN-oriëntatie, verhuizing, documenten, afspraken en lokale diensten. Controleer actuele voorwaarden voor je boekt.", dru: "Официальный сайт города для регистрации, BSN, смены адреса, документов, записи и местных услуг. Проверяйте актуальные требования перед записью.", url: officialWebsite, source: .municipal, confidence: officialWebsite == nil ? .needsManualVerification : .verified, tags: ["BSN", "registration", "gemeente", "регистрация"]),
            place(city, "library", .library, en: "Library and Taalhuis-style support", nl: "Bibliotheek en Taalhuis-achtige steun", ru: "Библиотека и языковая поддержка", den: "Use the library as a general guide for Dutch learning, reading help, digital skills, and community orientation. Verify exact programs locally.", dnl: "Gebruik de bibliotheek als algemene gids voor Nederlands leren, leesondersteuning, digitale vaardigheden en buurtoriëntatie. Controleer lokale programma's.", dru: "Используйте библиотеку как общий ориентир для нидерландского языка, чтения, цифровых навыков и городской ориентации. Проверяйте программы на месте.", url: libraryURL, source: libraryURL == nil ? .referenceOnly : .community, confidence: libraryURL == nil ? .needsManualVerification : .verified, tags: ["library", "Dutch language", "bibliotheek", "нидерландский язык"]),
            place(city, "healthcare", .healthcare, en: "Healthcare access orientation", nl: "Oriëntatie op zorgtoegang", ru: "Ориентация в доступе к медицине", den: "General route for GP, health insurance, pharmacies, and urgent/non-urgent distinction. This is not medical advice.", dnl: "Algemene route voor huisarts, zorgverzekering, apotheek en onderscheid spoed/niet-spoed. Dit is geen medisch advies.", dru: "Общий маршрут: huisarts, страховка, аптеки и отличие срочного от несрочного. Это не медицинская консультация.", url: "https://www.government.nl/topics/health-insurance", source: .publicService, confidence: .verified, tags: ["healthcare", "huisarts", "hospital", "медицина"]),
            place(city, "hospital", .hospital, en: hospitalName, nl: hospitalName, ru: hospitalName, den: "Hospital landmark for orientation only. Verify departments, referrals, and urgent-care routes through official hospital or GP channels.", dnl: "Ziekenhuis als oriëntatiepunt. Controleer afdelingen, verwijzingen en spoedroutes via officiële ziekenhuis- of huisartskanalen.", dru: "Больничный ориентир. Проверяйте отделения, направления и срочную помощь через официальные каналы больницы или huisarts.", url: nil, source: .referenceOnly, confidence: .generalReference, tags: ["hospital", "ziekenhuis", "больница"]),
            place(city, "legal", .legalHelp, en: "Juridisch Loket and rights help", nl: "Juridisch Loket en rechtshulp", ru: "Juridisch Loket и помощь с правами", den: "First-line legal orientation for letters, work, housing, discrimination, and tenant questions. Do not treat this app as legal advice.", dnl: "Eerste oriëntatie bij brieven, werk, wonen, discriminatie en huurvragen. Beschouw deze app niet als juridisch advies.", dru: "Первичная юридическая ориентация по письмам, работе, жилью, дискриминации и аренде. Это приложение не даёт юридические советы.", url: "https://www.juridischloket.nl", source: .publicService, confidence: .verified, tags: ["legal help", "juridisch loket", "юридическая помощь"]),
            place(city, "transport", .transport, en: "Main transport hub", nl: "Belangrijk vervoersknooppunt", ru: "Главный транспортный узел", den: "Use this as a reference for the central station, local operator, NS trains, cycling orientation, and OV information.", dnl: "Gebruik dit als referentie voor station, lokale vervoerder, NS, fietsoriëntatie en ov-informatie.", dru: "Ориентир для вокзала, местного оператора, NS, велосипедной и OV-информации.", url: transportURL, source: transportURL == nil ? .referenceOnly : .publicService, confidence: transportURL == nil ? .needsManualVerification : .verified, tags: ["station", "transport", "OV", "транспорт"]),
            place(city, "community", .community, en: "Community and newcomer orientation", nl: "Buurt- en nieuwkomersoriëntatie", ru: "Сообщество и ориентация для newcomers", den: "General guide to community centres, international/student support where relevant, city information points, and local networks.", dnl: "Algemene gids voor buurthuizen, internationale/studentensteun waar relevant, stadsinformatiepunten en lokale netwerken.", dru: "Общий ориентир для общественных центров, международной/студенческой поддержки, городских инфопунктов и местных сетей.", url: nil, source: .referenceOnly, confidence: .generalReference, tags: ["community", "student", "expat", "сообщество"]),
            place(city, "emergency", .emergency, en: "Emergency and safety", nl: "Noodhulp en veiligheid", ru: "Экстренная помощь и безопасность", den: "For immediate danger use 112. For non-urgent safety questions, verify police and municipality channels. No phone numbers are stored here beyond the national emergency number.", dnl: "Gebruik 112 bij direct gevaar. Controleer politie- en gemeentekanalen voor niet-spoed. Hier worden geen telefoonnummers opgeslagen behalve het nationale noodnummer.", dru: "При непосредственной опасности используйте 112. Для несрочных вопросов проверяйте каналы полиции и муниципалитета. Здесь нет телефонов, кроме национального экстренного номера.", url: "https://www.government.nl/themes/justice-security-and-defence/emergency-number-112", source: .official, confidence: .verified, tags: ["112", "police", "emergency", "полиция"]),
            place(city, "documents", .documents, en: "Documents and administration", nl: "Documenten en administratie", ru: "Документы и администрация", den: "Keep official letters, DigiD, appointments, scans, and municipality source links organized. Verify procedures on official domains.", dnl: "Bewaar officiële brieven, DigiD, afspraken, scans en gemeentelijke bronlinks overzichtelijk. Controleer procedures via officiële domeinen.", dru: "Храните официальные письма, DigiD, записи, сканы и ссылки муниципалитета организованно. Проверяйте процедуры на официальных доменах.", url: "https://www.digid.nl/en", source: .official, confidence: .verified, tags: ["DigiD", "documents", "letters", "документы"]),
            place(city, "lgbtq", .lgbtq, en: "LGBTQ+ support and reporting", nl: "LGBTQ+-steun en melden", ru: "LGBTQ+-поддержка и сообщения", den: "Use trusted national/local LGBTQ+ and anti-discrimination sources when local verified city support is unclear.", dnl: "Gebruik betrouwbare landelijke/lokale LGBTQ+- en antidiscriminatiebronnen wanneer lokale geverifieerde hulp onduidelijk is.", dru: "Используйте надёжные национальные/местные LGBTQ+ и антидискриминационные источники, если городская поддержка неясна.", url: "https://www.discriminatie.nl", source: .publicService, confidence: .verified, tags: ["LGBTQ", "discrimination", "support", "дискриминация"]),
            place(city, "work", .work, en: "Work and UWV orientation", nl: "Werk en UWV-oriëntatie", ru: "Работа и UWV", den: "General direction for work-related public services, official letters, and UWV information. This app does not decide eligibility.", dnl: "Algemene richting voor werkgerelateerde publieke diensten, officiële brieven en UWV-informatie. Deze app bepaalt geen recht op regelingen.", dru: "Общий ориентир по рабочим госуслугам, официальным письмам и UWV. Приложение не определяет право на услуги.", url: "https://www.uwv.nl", source: .publicService, confidence: .verified, tags: ["work", "UWV", "werk", "работа"])
        ]
    }

    private static func fallbackPlaces(cityId: String, municipalityURL: String?) -> [NewcomerPlace] {
        [
            place(cityId, "municipality", .municipality, en: "Municipality services", nl: "Gemeentediensten", ru: "Муниципальные услуги", den: "General guide for registration, address changes, documents, and appointments. Verify the official municipality website.", dnl: "Algemene gids voor inschrijving, verhuizing, documenten en afspraken. Controleer de officiële gemeentesite.", dru: "Общий ориентир по регистрации, смене адреса, документам и записи. Проверяйте официальный сайт муниципалитета.", url: municipalityURL, source: municipalityURL == nil ? .referenceOnly : .municipal, confidence: municipalityURL == nil ? .needsManualVerification : .verified, tags: ["BSN", "gemeente", "регистрация"]),
            place(cityId, "library", .library, en: "Library and language support", nl: "Bibliotheek en taalsteun", ru: "Библиотека и языковая поддержка", den: "Reference only. Search locally for library, Taalhuis, and digital skills support.", dnl: "Alleen referentie. Zoek lokaal naar bibliotheek, Taalhuis en digitale vaardigheden.", dru: "Только ориентир. Ищите местную библиотеку, Taalhuis и поддержку цифровых навыков.", url: nil, source: .referenceOnly, confidence: .needsManualVerification, tags: ["library", "Dutch language", "библиотека"]),
            place(cityId, "emergency", .emergency, en: "Emergency and safety", nl: "Noodhulp en veiligheid", ru: "Экстренная помощь и безопасность", den: "For immediate danger use 112. Verify non-urgent safety information through official police or municipality channels.", dnl: "Gebruik 112 bij direct gevaar. Controleer niet-spoedinformatie via politie of gemeente.", dru: "При непосредственной опасности используйте 112. Несрочную информацию проверяйте у полиции или муниципалитета.", url: "https://www.government.nl/themes/justice-security-and-defence/emergency-number-112", source: .official, confidence: .verified, tags: ["112", "police", "полиция"])
        ]
    }

    private static func place(_ city: String, _ id: String, _ category: NewcomerPlaceCategory, en: String, nl: String, ru: String, den: String, dnl: String, dru: String, url: String?, source: NewcomerPlaceSourceType, confidence: NewcomerPlaceConfidenceLevel, tags: [String]) -> NewcomerPlace {
        NewcomerPlace(
            id: "\(city)-\(id)",
            localizedTitle: LocalizedCityText(english: en, dutch: nl, russian: ru),
            localizedDescription: LocalizedCityText(english: den, dutch: dnl, russian: dru),
            category: category,
            cityId: city,
            officialWebsiteURL: url.flatMap { AppURL.make($0) },
            mapQuery: "\(en), \(city), Netherlands",
            sourceType: source,
            confidenceLevel: confidence,
            iconName: category.iconName,
            accentColor: category.accentColor,
            tags: tags.map { tag in LocalizedCityText(english: tag, dutch: tag, russian: tag) }
        )
    }

    private static func step(_ id: String, _ icon: String, en: String, nl: String, ru: String, den: String, dnl: String, dru: String, url: String?) -> CityNewcomerGuideItem {
        CityNewcomerGuideItem(
            id: id,
            icon: icon,
            title: LocalizedCityText(english: en, dutch: nl, russian: ru),
            detail: LocalizedCityText(english: den, dutch: dnl, russian: dru),
            urlString: url
        )
    }
}
