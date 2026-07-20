import Foundation

enum AppNavigationResolver {
    nonisolated static func routeID(from destination: AppDestination?) -> String? {
        guard let destination else { return nil }
        if let hubID = AppDestination.aiRouteID(from: destination) {
            return hubID
        }

        switch destination {
        case .checklist(let id): return "checklist:\(id.uuidString)"
        case .dutchTerm(let id): return "dutchTerm:\(id.uuidString)"
        case .fineInfo(let id): return "fine:\(id.uuidString)"
        case .institution(let name): return "institution:\(KnowledgeNormalizer.slug(name))"
        case .searchAnswer(let id): return "searchAnswer:\(id.uuidString)"
        case .letter(let title): return "letter:\(KnowledgeNormalizer.slug(title))"
        case .mistake(let id): return "mistake:\(id.uuidString)"
        case .beginnerGuide(let id): return "beginnerGuide:\(id.uuidString)"
        case .ruleTopic(let id): return "rule:\(id.uuidString)"
        case .ruleScenario(let id): return "ruleScenario:\(id.uuidString)"
        case .resource(let id): return "resource:\(id.uuidString)"
        case .localPartnerDetail(let id): return "localPartner:\(id)"
        case .document(let id): return "document:\(id.uuidString)"
        case .placeDetail(let id): return "placeDetail:\(id)"
        case .calendarEvent(let id): return "calendarEvent:\(id)"
        case .statusDirection(let status): return "statusDirection:\(status.rawValue)"
        case .provinceDetail(let province): return "province:\(KnowledgeNormalizer.slug(province))"
        case .provinceCities(let province): return "provinceCities:\(KnowledgeNormalizer.slug(province))"
        case .cityDetail(let province, let city): return "cityDetail:\(KnowledgeNormalizer.slug(province)):\(KnowledgeNormalizer.slug(city))"
        case .placeList(let city): return "placeList:\(city.rawValue)"
        case .museumList(let city): return "museumList:\(city.rawValue)"
        case .natureList(let city): return "natureList:\(city.rawValue)"
        case .landmarkList(let city): return "landmarkList:\(city.rawValue)"
        case .eventList(let city): return "eventList:\(city.rawValue)"
        case .restaurantList(let city): return "restaurantList:\(city.rawValue)"
        case .cafeList(let city): return "cafeList:\(city.rawValue)"
        case .discoveryList(let city, let type): return "discoveryList:\(city.rawValue):\(type.rawValue)"
        case .restaurantDetail(let city, let itemID): return "restaurantDetail:\(city.rawValue):\(itemID)"
        case .cafeDetail(let city, let itemID): return "cafeDetail:\(city.rawValue):\(itemID)"
        case .housingSection(let type): return "housingSection:\(type.rawValue)"
        case .governmentSection(let type): return "governmentSection:\(type.rawValue)"
        case .transportSection(let type): return "transportSection:\(type.rawValue)"
        case .educationSection(let type): return "educationSection:\(type.rawValue)"
        case .workSection(let type): return "workSection:\(type.rawValue)"
        case .healthSection(let type): return "healthSection:\(type.rawValue)"
        case .leisureSection(let city, let type): return "leisureSection:\(city.rawValue):\(type.rawValue)"
        case .nlCityDetail(let cityID): return "city:\(KnowledgeNormalizer.slug(cityID))"
        case .knmModule(let id): return "knmModule:\(id)"
        case .dutchA1A2Module(let id): return "dutchCourseModule:\(id)"
        case .practicalGuide(let topic): return "practicalGuide:\(topic.rawValue)"
        case .guideSection(let id): return "guide:\(id)"
        case .guideArticle(let sectionID, let articleID): return "article:\(sectionID):\(articleID)"
        case .scamWarning(let id): return "scam:\(id.uuidString)"
        case .mapFocus(let focus): return "mapFocus:\(focus.rawValue)"
        default:
            return nil
        }
    }

    static func destination(for rawID: String?) -> AppDestination? {
        guard let rawID,
              !rawID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else { return nil }

        if let hubDestination = AppDestination.aiRoute(for: rawID) {
            return hubDestination
        }

        let parts = rawID.split(separator: ":", omittingEmptySubsequences: false).map(String.init)
        guard let kind = parts.first else { return nil }

        switch kind {
        case "checklist":
            return uuidDestination(parts, 1, in: MockChecklistData.items.map(\.id), AppDestination.checklist)
        case "dutchTerm":
            return uuidDestination(parts, 1, in: MockDutchTermsData.items.map(\.id), AppDestination.dutchTerm)
        case "fine":
            return uuidDestination(parts, 1, in: MockFineInfoData.items.map(\.id), AppDestination.fineInfo)
        case "institution":
            guard let institution = MockInstitutionsData.items.first(where: { KnowledgeNormalizer.slug($0.name) == valuePart(parts, 1) }) else {
                return nil
            }
            return .institution(institution.name)
        case "searchAnswer":
            return uuidDestination(parts, 1, in: MockSearchAnswersData.items.map(\.id), AppDestination.searchAnswer)
        case "letter":
            guard let letter = MockLettersData.examples.first(where: { KnowledgeNormalizer.slug($0.title) == valuePart(parts, 1) }) else {
                return nil
            }
            return .letter(letter.title)
        case "mistake":
            return uuidDestination(parts, 1, in: MockNewcomerMistakesData.items.map(\.id), AppDestination.mistake)
        case "beginnerGuide":
            return uuidDestination(parts, 1, in: MockBeginnerGuidesData.items.map(\.id), AppDestination.beginnerGuide)
        case "rule":
            return uuidDestination(parts, 1, in: MockRulesGuideData.topics.map(\.id), AppDestination.ruleTopic)
        case "ruleScenario":
            return uuidDestination(parts, 1, in: MockRulesGuideData.scenarios.map(\.id), AppDestination.ruleScenario)
        case "resource":
            return uuidDestination(parts, 1, in: MockResourcesData.items.map(\.id), AppDestination.resource)
        case "localPartner":
            let id = valuePart(parts, 1)
            return MockLocalPartnersData.partner(id: id) == nil ? nil : .localPartnerDetail(id)
        case "document":
            return uuidPart(parts, 1).map(AppDestination.document)
        case "placeDetail":
            let id = valuePart(parts, 1)
            return DashboardPlacesData.detailPlace(id: id) != nil ? .placeDetail(id) : nil
        case "calendarEvent":
            let id = valuePart(parts, 1)
            return DashboardCalendarData.detailEvent(id: id) != nil ? .calendarEvent(id) : nil
        case "statusDirection":
            return UserStatus(rawValue: valuePart(parts, 1)).map(AppDestination.statusDirection)
        case "province":
            let slug = valuePart(parts, 1)
            guard let province = NLProvince.all.first(where: {
                KnowledgeNormalizer.slug($0.id) == slug
                    || KnowledgeNormalizer.slug($0.name) == slug
                    || KnowledgeNormalizer.slug($0.nameEN) == slug
                    || KnowledgeNormalizer.slug($0.nameRU) == slug
            }) else {
                if let province = ProvinceCatalog.provinceIfFound(matching: slug) {
                    return .provinceDetail(province.id)
                }
                return nil
            }
            return .provinceDetail(province.name)
        case "provinceCities":
            let slug = valuePart(parts, 1)
            if let province = ProvinceCatalog.provinceIfFound(matching: slug) {
                return .provinceCities(province.id)
            }
            guard let province = NLProvince.all.first(where: { KnowledgeNormalizer.slug($0.id) == slug || KnowledgeNormalizer.slug($0.name) == slug }) else {
                return nil
            }
            return .provinceCities(province.name)
        case "cityDetail":
            let provinceSlug = valuePart(parts, 1)
            let citySlug = valuePart(parts, 2)
            guard !provinceSlug.isEmpty, !citySlug.isEmpty,
                  let province = ProvinceCatalog.provinceIfFound(matching: provinceSlug),
                  let spotlight = ProvinceCatalog.citySpotlight(matching: citySlug),
                  spotlight.province.id == province.id
            else {
                return nil
            }
            return .cityDetail(province: province.id, city: spotlight.city.name)
        case "placeList":
            return cityListDestination(parts, AppDestination.placeList)
        case "museumList":
            return cityListDestination(parts, AppDestination.museumList)
        case "natureList":
            return cityListDestination(parts, AppDestination.natureList)
        case "landmarkList":
            return cityListDestination(parts, AppDestination.landmarkList)
        case "eventList":
            return cityListDestination(parts, AppDestination.eventList)
        case "restaurantList":
            return cityListDestination(parts, AppDestination.restaurantList)
        case "cafeList":
            return cityListDestination(parts, AppDestination.cafeList)
        case "discoveryList":
            guard parts.count == 3,
                  let city = CityId(rawValue: parts[1]),
                  let type = DiscoveryListType(rawValue: parts[2])
            else { return nil }
            return .discoveryList(city: city, type: type)
        case "restaurantDetail":
            return foodGuideDetailDestination(parts, categories: [.restaurant, .localFood, .market, .vegetarian, .budget, .fineDining]) {
                .restaurantDetail(city: $0, itemID: $1)
            }
        case "cafeDetail":
            return foodGuideDetailDestination(parts, categories: [.cafe, .breakfast]) {
                .cafeDetail(city: $0, itemID: $1)
            }
        case "housingSection":
            return enumSectionDestination(parts, HousingSectionType.self, AppDestination.housingSection)
        case "governmentSection":
            return enumSectionDestination(parts, GovernmentSectionType.self, AppDestination.governmentSection)
        case "transportSection":
            return enumSectionDestination(parts, TransportSectionType.self, AppDestination.transportSection)
        case "educationSection":
            return enumSectionDestination(parts, EducationSectionType.self, AppDestination.educationSection)
        case "workSection":
            return enumSectionDestination(parts, WorkSectionType.self, AppDestination.workSection)
        case "healthSection":
            return enumSectionDestination(parts, HealthSectionType.self, AppDestination.healthSection)
        case "leisureSection":
            guard parts.count == 3,
                  let city = CityId(rawValue: parts[1]),
                  let type = LeisureSectionType(rawValue: parts[2])
            else { return nil }
            return .leisureSection(city: city, type: type)
        case "city":
            let slug = valuePart(parts, 1)
            guard let city = NLCity.all.first(where: { KnowledgeNormalizer.slug($0.id) == slug || KnowledgeNormalizer.slug($0.name) == slug }) else {
                if let spotlight = ProvinceCatalog.citySpotlight(matching: slug) {
                    return .nlCityDetail(spotlight.city.id)
                }
                return nil
            }
            return .nlCityDetail(city.id)
        case "knmModule":
            let moduleID = valuePart(parts, 1)
            return KNMGuideData.module(with: moduleID) == nil ? nil : .knmModule(moduleID)
        case "dutchCourseModule":
            let moduleID = valuePart(parts, 1)
            return DutchA1A2CourseData.module(with: moduleID) == nil ? nil : .dutchA1A2Module(moduleID)
        case "practicalGuide":
            return PracticalGuideTopic(rawValue: valuePart(parts, 1)).map(AppDestination.practicalGuide)
        case "guide":
            guard parts.count == 2 else { return nil }
            let sectionID = valuePart(parts, 1)
            if sectionID == "work" { return .workSection(.overview) }
            if sectionID == "healthcare" { return .healthSection(.overview) }
            if sectionID == "housing" { return .housingSection(.overview) }
            if sectionID == "transport" { return .transportSection(.overview) }
            return GuideContent.section(id: sectionID) == nil ? nil : .guideSection(sectionID)
        case "article":
            guard parts.count >= 3 else { return nil }
            let sectionID = parts[1]
            let articleID = parts.dropFirst(2).joined(separator: ":")
            if sectionID == GuideContent.dataProjectSectionID,
               ContentRepository.shared.item(id: articleID)?.status == .published {
                return .guideArticle(sectionID: sectionID, articleID: articleID)
            }
            guard GuideContent.article(sectionID: sectionID, articleID: articleID) != nil else {
                return nil
            }
            return .guideArticle(sectionID: sectionID, articleID: articleID)
        case "scam":
            return uuidDestination(parts, 1, in: MockScamWarningsData.items.map(\.id), AppDestination.scamWarning)
        case "mapFocus":
            return MapFocus(rawValue: parts.dropFirst().joined(separator: ":")).map(AppDestination.mapFocus)
        default:
            return nil
        }
    }

    static func destination(for rawID: String?, visibleFor persona: PersonaTag?) -> AppDestination? {
        guard let destination = destination(for: rawID) else { return nil }
        guard let persona else { return destination }
        guard RelatedContentEngine.isVisible(destination, for: persona) else { return nil }
        return destination
    }

    nonisolated private static func uuidPart(_ parts: [String], _ index: Int) -> UUID? {
        guard parts.indices.contains(index) else { return nil }
        return UUID(uuidString: parts[index])
    }

    private static func uuidDestination(
        _ parts: [String],
        _ index: Int,
        in validIDs: [UUID],
        _ destination: (UUID) -> AppDestination
    ) -> AppDestination? {
        guard let uuid = uuidPart(parts, index), validIDs.contains(uuid) else { return nil }
        return destination(uuid)
    }

    private static func cityListDestination(
        _ parts: [String],
        _ destination: (CityId) -> AppDestination
    ) -> AppDestination? {
        guard parts.count == 2, let city = CityId(rawValue: parts[1]) else { return nil }
        return destination(city)
    }

    private static func foodGuideDetailDestination(
        _ parts: [String],
        categories: Set<FoodGuideCategory>,
        _ destination: (CityId, String) -> AppDestination
    ) -> AppDestination? {
        guard parts.count >= 3,
              let city = CityId(rawValue: parts[1])
        else { return nil }

        let itemID = parts.dropFirst(2).joined(separator: ":")
        guard !itemID.isEmpty else { return nil }

        let dashboardCity = CityDashboardContentData.city(for: city)
        guard CityDashboardContentData.foodGuideItems(for: dashboardCity, audience: nil, limit: nil).contains(where: {
            $0.id == itemID && categories.contains($0.category)
        }) else { return nil }

        return destination(city, itemID)
    }

    private static func enumSectionDestination<Value: RawRepresentable>(
        _ parts: [String],
        _ type: Value.Type,
        _ destination: (Value) -> AppDestination
    ) -> AppDestination? where Value.RawValue == String {
        guard parts.count == 2, let value = Value(rawValue: parts[1]) else { return nil }
        return destination(value)
    }

    nonisolated private static func valuePart(_ parts: [String], _ index: Int) -> String {
        guard parts.indices.contains(index) else { return "" }
        return parts[index]
    }
}

struct ReleaseNavigationArea: Hashable {
    let id: String
    let title: String
    let rootTab: AppTab
    let destination: AppDestination?
    let tapCountFromHome: Int
    let supportsBackNavigation: Bool

    var routeID: String? {
        AppNavigationResolver.routeID(from: destination)
    }
}

enum ReleaseNavigationContract {
    static let maximumTapCountFromHome = 3

    static let publicAreas: [ReleaseNavigationArea] = [
        .init(id: "home", title: "Home", rootTab: .home, destination: nil, tapCountFromHome: 0, supportsBackNavigation: true),
        .init(id: "dashboard", title: "Dashboard", rootTab: .home, destination: nil, tapCountFromHome: 1, supportsBackNavigation: true),
        .init(id: "search", title: "Search", rootTab: .search, destination: .searchList, tapCountFromHome: 1, supportsBackNavigation: true),
        .init(id: "map", title: "Map", rootTab: .map, destination: .mapHub, tapCountFromHome: 1, supportsBackNavigation: true),
        .init(id: "places", title: "Places", rootTab: .places, destination: .mapHub, tapCountFromHome: 1, supportsBackNavigation: true),
        .init(id: "aiAssistant", title: "AI Assistant", rootTab: .assistant, destination: .assistantHub, tapCountFromHome: 1, supportsBackNavigation: true),
        .init(id: "saved", title: "Saved", rootTab: .favorites, destination: .savedTopics, tapCountFromHome: 1, supportsBackNavigation: true),
        .init(id: "more", title: "More", rootTab: .more, destination: nil, tapCountFromHome: 1, supportsBackNavigation: true),
        .init(id: "calendar", title: "Calendar", rootTab: .more, destination: .netherlandsCalendar, tapCountFromHome: 2, supportsBackNavigation: true),
        .init(id: "transport", title: "Transport", rootTab: .home, destination: .practicalGuide(.transportBasics), tapCountFromHome: 2, supportsBackNavigation: true),
        .init(id: "emergency", title: "Emergency", rootTab: .home, destination: .emergencyHub, tapCountFromHome: 1, supportsBackNavigation: true),
        .init(id: "documents", title: "Documents", rootTab: .home, destination: .journeyDocuments, tapCountFromHome: 2, supportsBackNavigation: true),
        .init(id: "settings", title: "Settings", rootTab: .more, destination: .settings, tapCountFromHome: 2, supportsBackNavigation: true)
    ]
}
