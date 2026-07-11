import Foundation

nonisolated enum MapFocus: Hashable, Sendable {
    case transport
    case healthcare
    case government
    case education
    case emergency
    case category(PlaceCategory)
    case city(String)
    case province(String)
    case place(String)

    init?(rawValue: String) {
        if rawValue.hasPrefix("category:") {
            guard let category = PlaceCategory(rawValue: String(rawValue.dropFirst(9))) else { return nil }
            self = .category(category)
            return
        }
        if rawValue.hasPrefix("city:") {
            let cityID = String(rawValue.dropFirst(5))
            let resolvedCityID = MainActor.assumeIsolated {
                ProvinceCatalog.cityID(matching: cityID)
            }
            guard let resolvedCityID else { return nil }
            self = .city(resolvedCityID)
            return
        }
        if rawValue.hasPrefix("province:") {
            let provinceID = String(rawValue.dropFirst(9))
            let resolvedProvinceID = MainActor.assumeIsolated {
                ProvinceCatalog.provinceID(matching: provinceID)
            }
            guard let resolvedProvinceID else { return nil }
            self = .province(resolvedProvinceID)
            return
        }
        if rawValue.hasPrefix("place:") {
            let placeID = String(rawValue.dropFirst(6))
            let saveKey = MainActor.assumeIsolated {
                MockNearbyPlacesData.saveKey(matching: placeID)
            }
            guard let saveKey else { return nil }
            self = .place(saveKey)
            return
        }

        switch rawValue {
        case "transport": self = .transport
        case "healthcare": self = .healthcare
        case "government": self = .government
        case "education": self = .education
        case "emergency": self = .emergency
        default: return nil
        }
    }

    var rawValue: String {
        switch self {
        case .transport: return "transport"
        case .healthcare: return "healthcare"
        case .government: return "government"
        case .education: return "education"
        case .emergency: return "emergency"
        case .category(let category): return "category:\(category.rawValue)"
        case .city(let id): return "city:\(id)"
        case .province(let id): return "province:\(id)"
        case .place(let id): return "place:\(id)"
        }
    }

    @MainActor
    func localized(_ lang: AppLanguage) -> String {
        switch self {
        case .transport: return L10n.t("home.category.transport", lang)
        case .healthcare: return L10n.t("home.category.healthcare", lang)
        case .government: return L10n.t("home.category.government", lang)
        case .education: return L10n.t("home.category.education", lang)
        case .emergency: return L10n.t("home.category.emergency_112", lang)
        case .category(let category): return category.localized(lang)
        case .city(let id):
            return ProvinceCatalog.citySpotlight(matching: id)?.city.localizedName(lang) ?? id
        case .province(let id):
            return ProvinceCatalog.provinceIfFound(matching: id)?.localizedName(lang) ?? id
        case .place:
            return L10n.t("tab.map", lang)
        }
    }

    @MainActor
    var symbol: String {
        switch self {
        case .transport: return "tram.fill"
        case .healthcare: return "cross.case.fill"
        case .government: return "building.columns.fill"
        case .education: return "graduationcap.fill"
        case .emergency: return "phone.fill"
        case .category(let category): return category.systemImageName
        case .city: return "building.2.fill"
        case .province: return "map.fill"
        case .place: return "mappin.and.ellipse"
        }
    }

    func matches(_ place: NearbyPlace) -> Bool {
        switch self {
        case .transport:
            return [.transport, .transportOffice, .bikeRepair].contains(place.category)
        case .healthcare:
            return [.healthcare, .hospital, .huisarts, .pharmacy, .nightPharmacy].contains(place.category)
        case .government:
            return [.municipality, .ind, .uwv, .immigrationSupport, .expatCenter].contains(place.category)
        case .education:
            return [.education, .duo, .studentHelp, .library, .communitySupport].contains(place.category)
        case .emergency:
            return place.category == .police || place.emergencyNote != nil
        case .category(let category):
            return place.category == category
        case .city, .province, .place:
            return true
        }
    }
}

nonisolated enum PracticalGuideTopic: String, CaseIterable, Hashable, Sendable {
    case firstStepsNetherlands
    case municipalityRegistration
    case healthcareBasics
    case findingHuisarts
    case healthInsuranceBasics
    case digidSafety
    case transportBasics
    case housingBasics
    case officialSourcesChecklist
    case bankingBasics
}

nonisolated enum AppDestination: Hashable, Sendable {

    // MARK: - Individual Items
    case checklist(UUID)
    case dutchTerm(UUID)
    case fineInfo(UUID)
    case institution(String)
    case searchAnswer(UUID)
    case letter(String)
    case mistake(UUID)
    case beginnerGuide(UUID)
    case statusDirection(UserStatus)
    case ruleTopic(UUID)
    case ruleScenario(UUID)
    case resource(UUID)
    case document(UUID)
    case placeDetail(String)
    case calendarEvent(String)
    case provinceList
    case cityList
    case provinceDetail(String)
    case provinceCities(String)
    case cityDetail(province: String, city: String)
    case homeExploreList(String)

    // MARK: - Lists
    case checklistList
    case institutionsList
    case finesList
    case lettersList
    case dutchTermsList
    case searchList
    case mistakesList
    case beginnerGuidesList
    case survivalHub
    case emotionalSupport
    case lgbtqSupport
    case mapHub
    case mapFocus(MapFocus)
    case assistantHub
    case informationHub
    case firstSteps
    case knm
    case knmModule(String)
    case dutchA1A2
    case dutchA1A2Module(String)
    case practicalGuide(PracticalGuideTopic)
    case netherlandsOverview
    case nlCityDetail(String)
    case netherlandsHistory
    case cultureAttractions
    case netherlandsCalendar
    case settings
    case profileSelection
    case savedTopics
    case recentlyViewedTopics
    case resourcesHub
    case lifeTimeline
    case documentVault
    case deadlineCenter
    case verifiedExperts
    case aiLetterGenerator
    case discoverNetherlands
    case localPartners
    case localPartnerDetail(String)
    case businessGrowth
    case businessLogin
    case businessDashboard
    case finesAndLettersHub
    case legalHelp
    case officialSources
    case aboutYouNew
    case supportFeedback
    case privacyDataControl
    case termsOfUse
    case legalDisclaimer
    // MARK: - Journeys
    case journeyDocuments
    case scamWarningsList
    case scamWarning(UUID)

    // MARK: - Guide Sections
    case guideSection(String)
    case guideArticle(sectionID: String, articleID: String)

    // MARK: - Category Hubs
    case governmentHub
    case helpHub
    case languageHub
    case historyKNMHub
    case emergencyHub
    case categoriesHub

    // MARK: - Culture & Heritage
    case dutchHolidays
    case dutchFigures
    case dutchMonarchy
}

extension AppDestination {
    nonisolated static func aiRoute(for rawID: String?) -> AppDestination? {
        guard let rawID else { return nil }
        if rawID.hasPrefix("practicalGuide:") {
            let topicID = String(rawID.dropFirst("practicalGuide:".count))
            if let topic = PracticalGuideTopic(rawValue: topicID) {
                return .practicalGuide(topic)
            }
        }
        let normalized = rawID
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: " ", with: "")
            .lowercased()

        switch normalized {
        case "search", "searchlist":
            return .searchList
        case "officialsources", "sources", "officalsources", "officialsource":
            return .officialSources
        case "netherlandscalendar", "calendar", "dutchcalendar", "holidays":
            return .netherlandsCalendar
        case "firststeps", "firststepsnetherlands", "registration":
            return .firstSteps
        case "checklist", "checklistlist":
            return .checklistList
        case "mistakes", "mistakeslist":
            return .mistakesList
        case "beginnerguides", "beginnerguideslist":
            return .beginnerGuidesList
        case "documents", "document", "journeydocuments", "journeydocument":
            return .journeyDocuments
        case "documentvault", "vault":
            return .documentVault
        case "lifetimeline", "timeline", "smarttimeline":
            return .lifeTimeline
        case "deadlinecenter", "deadlines", "deadlinecentre":
            return .deadlineCenter
        case "verifiedexperts", "experts":
            return .verifiedExperts
        case "lettergenerator", "ailettergenerator", "templates":
            return .aiLetterGenerator
        case "discovernetherlands", "explorenetherlands", "explore":
            return .discoverNetherlands
        case "survival", "survivalhub":
            return .survivalHub
        case "emotionalsupport", "support":
            return .emotionalSupport
        case "lgbtq", "lgbtqsupport":
            return .lgbtqSupport
        case "municipalityregistration", "gemeenteregistration", "brpregistration":
            return .practicalGuide(.municipalityRegistration)
        case "transport", "transportbasic", "transportbasics":
            return .practicalGuide(.transportBasics)
        case "housing", "housingbasic", "housingbasics":
            return .practicalGuide(.housingBasics)
        case "healthcare", "health", "healthcarebasic", "healthcarebasics":
            return .practicalGuide(.healthcareBasics)
        case "healthinsurance", "healthinsurancebasic", "healthinsurancebasics", "zorgverzekering":
            return .practicalGuide(.healthInsuranceBasics)
        case "huisarts", "findinghuisarts", "gp":
            return .practicalGuide(.findingHuisarts)
        case "digid", "digidsafety":
            return .practicalGuide(.digidSafety)
        case "officialsourceschecklist":
            return .practicalGuide(.officialSourcesChecklist)
        case "banking", "bankingbasics":
            return .practicalGuide(.bankingBasics)
        case "practicalguidefirststepsnetherlands":
            return .practicalGuide(.firstStepsNetherlands)
        case "practicalguidemunicipalityregistration":
            return .practicalGuide(.municipalityRegistration)
        case "practicalguidedigidsafety":
            return .practicalGuide(.digidSafety)
        case "practicalguideofficialsourceschecklist":
            return .practicalGuide(.officialSourcesChecklist)
        case "practicalguidehealthinsurancebasics":
            return .practicalGuide(.healthInsuranceBasics)
        case "practicalguidefindinghuisarts":
            return .practicalGuide(.findingHuisarts)
        case "practicalguidebankingbasics":
            return .practicalGuide(.bankingBasics)
        case "government", "governmenthub", "municipality", "immigration", "ind":
            return .governmentHub
        case "emergency", "emergencies", "police":
            return .emergencyHub
        case "map", "maphub":
            return .mapHub
        case "assistant", "ai":
            return .assistantHub
        case "information", "informationhub":
            return .informationHub
        case "knm", "nlk":
            return .knm
        case "historyknm", "historyknmhub":
            return .historyKNMHub
        case "dutch", "language", "a1", "a1a2":
            return .dutchA1A2
        case "dutchterms", "dutchtermslist", "terms", "glossary":
            return .dutchTermsList
        case "cities", "city":
            return .cityList
        case "provinces", "province":
            return .provinceList
        case "fines", "rules":
            return .finesList
        case "letters", "letter":
            return .lettersList
        case "institutions", "institution", "education", "universities", "schools":
            return .institutionsList
        case "settings", "setting":
            return .settings
        case "profile", "profileselection", "editprofile", "changeprofile":
            return .profileSelection
        case "savedtopics", "saveditems", "bookmarks":
            return .savedTopics
        case "recentlyviewed", "recentlyviewedtopics", "recenttopics", "historytopics":
            return .recentlyViewedTopics
        case "resources", "resourceshub", "resourcehub":
            return .resourcesHub
        case "localpartners", "trustedlocalservices", "recommendedbusinesses", "partners":
            return .localPartners
        case "businessgrowth", "growbusiness", "growyourbusiness":
            return .businessGrowth
        case "businesslogin", "partnerlogin", "businesssignin":
            return .businessLogin
        case "businessdashboard", "partnerdashboard":
            return .businessDashboard
        case "finesletters", "finesandletters", "finesandlettershub":
            return .finesAndLettersHub
        case "legalhelp", "legaladvice":
            return .legalHelp
        case "privacy", "privacydatacontrol", "datacontrol":
            return .privacyDataControl
        case "termsofuse", "termsuse", "termsandconditions":
            return .termsOfUse
        case "legaldisclaimer", "disclaimer":
            return .legalDisclaimer
        case "help", "helphub", "helpcentre", "helpcenter":
            return .helpHub
        case "languagehub", "languagecenter", "languagecentre":
            return .languageHub
        case "categories", "categorieshub":
            return .categoriesHub
        case "overview", "netherlandsoverview", "aboutnetherlands":
            return .netherlandsOverview
        case "history", "netherlandshistory":
            return .netherlandsHistory
        case "culture", "cultureattractions":
            return .cultureAttractions
        case "about", "aboutyounew":
            return .aboutYouNew
        case "feedback", "supportfeedback":
            return .supportFeedback
        case "scams", "scamwarnings", "scamwarningslist":
            return .scamWarningsList
        case "dutchholidays":
            return .dutchHolidays
        case "figures", "dutchfigures":
            return .dutchFigures
        case "monarchy", "dutchmonarchy":
            return .dutchMonarchy
        default:
            return nil
        }
    }

    nonisolated static func aiRouteID(from destination: AppDestination) -> String? {
        switch destination {
        case .searchList:
            return "search"
        case .officialSources:
            return "officialSources"
        case .firstSteps:
            return "firstSteps"
        case .checklistList:
            return "checklist"
        case .mistakesList:
            return "mistakes"
        case .beginnerGuidesList:
            return "beginnerGuides"
        case .journeyDocuments:
            return "journeyDocuments"
        case .survivalHub:
            return "survival"
        case .emotionalSupport:
            return "emotionalSupport"
        case .lgbtqSupport:
            return "lgbtq"
        case .practicalGuide(.transportBasics):
            return "transport"
        case .practicalGuide(.housingBasics):
            return "housing"
        case .practicalGuide(.healthcareBasics):
            return "healthcare"
        case .practicalGuide(let topic):
            return "practicalGuide:\(topic.rawValue)"
        case .governmentHub:
            return "government"
        case .emergencyHub:
            return "emergency"
        case .mapHub:
            return "map"
        case .assistantHub:
            return "assistant"
        case .informationHub:
            return "information"
        case .knm:
            return "knm"
        case .historyKNMHub:
            return "historyKNM"
        case .dutchA1A2:
            return "dutch"
        case .dutchTermsList:
            return "dutchTerms"
        case .cityList:
            return "cities"
        case .provinceList:
            return "provinces"
        case .finesList:
            return "fines"
        case .lettersList:
            return "letters"
        case .institutionsList:
            return "institutions"
        case .settings:
            return "settings"
        case .profileSelection:
            return "profileSelection"
        case .savedTopics:
            return "savedTopics"
        case .recentlyViewedTopics:
            return "recentlyViewedTopics"
        case .resourcesHub:
            return "resourcesHub"
        case .lifeTimeline:
            return "lifeTimeline"
        case .documentVault:
            return "documentVault"
        case .deadlineCenter:
            return "deadlineCenter"
        case .verifiedExperts:
            return "verifiedExperts"
        case .aiLetterGenerator:
            return "aiLetterGenerator"
        case .discoverNetherlands:
            return "discoverNetherlands"
        case .localPartners:
            return "localPartners"
        case .businessGrowth:
            return "businessGrowth"
        case .businessLogin:
            return "businessLogin"
        case .businessDashboard:
            return "businessDashboard"
        case .finesAndLettersHub:
            return "finesAndLettersHub"
        case .legalHelp:
            return "legalHelp"
        case .privacyDataControl:
            return "privacyDataControl"
        case .termsOfUse:
            return "termsOfUse"
        case .legalDisclaimer:
            return "legalDisclaimer"
        case .helpHub:
            return "help"
        case .languageHub:
            return "languagehub"
        case .categoriesHub:
            return "categories"
        case .netherlandsOverview:
            return "netherlandsOverview"
        case .netherlandsHistory:
            return "history"
        case .cultureAttractions:
            return "culture"
        case .netherlandsCalendar:
            return "netherlandsCalendar"
        case .aboutYouNew:
            return "aboutYouNew"
        case .supportFeedback:
            return "supportFeedback"
        case .scamWarningsList:
            return "scamWarnings"
        case .dutchHolidays:
            return "dutchHolidays"
        case .dutchFigures:
            return "dutchFigures"
        case .dutchMonarchy:
            return "dutchMonarchy"
        default:
            return nil
        }
    }

    nonisolated static func allKnownAIRouteIDs() -> [String] {
        [
            "search",
            "officialSources",
            "firstSteps",
            "firstStepsNetherlands",
            "journeyDocuments",
            "survival",
            "emotionalSupport",
            "lgbtq",
            "municipalityRegistration",
            "transport",
            "transportBasics",
            "housing",
            "housingBasics",
            "healthcare",
            "healthcareBasics",
            "government",
            "emergency",
            "map",
            "assistant",
            "information",
            "knm",
            "historyKNM",
            "dutch",
            "dutchTerms",
            "cities",
            "provinces",
            "fines",
            "letters",
            "institutions",
            "settings",
            "profileSelection",
            "savedTopics",
            "recentlyViewedTopics",
            "resourcesHub",
            "lifeTimeline",
            "documentVault",
            "deadlineCenter",
            "verifiedExperts",
            "aiLetterGenerator",
            "discoverNetherlands",
            "localPartners",
            "businessGrowth",
            "businessLogin",
            "businessDashboard",
            "finesAndLettersHub",
            "legalHelp",
            "privacyDataControl",
            "termsOfUse",
            "legalDisclaimer",
            "help",
            "languagehub",
            "categories",
            "netherlandsOverview",
            "history",
            "culture",
            "aboutYouNew",
            "supportFeedback",
            "scamWarnings",
            "dutchHolidays",
            "dutchFigures",
            "dutchMonarchy",
            "mistakes",
            "beginnerGuides",
            "healthinsurance",
            "healthInsuranceBasics",
            "huisarts",
            "findingHuisarts",
            "digidSafety",
            "officialSourcesChecklist",
            "bankingBasics"
        ]
    }
}
