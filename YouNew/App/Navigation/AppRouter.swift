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
        case .document(let id): return "document:\(id.uuidString)"
        case .statusDirection(let status): return "statusDirection:\(status.rawValue)"
        case .provinceDetail(let province): return "province:\(KnowledgeNormalizer.slug(province))"
        case .provinceCities(let province): return "provinceCities:\(KnowledgeNormalizer.slug(province))"
        case .cityDetail(let province, let city): return "cityDetail:\(KnowledgeNormalizer.slug(province)):\(KnowledgeNormalizer.slug(city))"
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
        case "document":
            return uuidPart(parts, 1).map(AppDestination.document)
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
            let sectionID = valuePart(parts, 1)
            return GuideContent.section(id: sectionID) == nil ? nil : .guideSection(sectionID)
        case "article":
            guard parts.count >= 3,
                  GuideContent.article(sectionID: parts[1], articleID: parts[2]) != nil
            else { return nil }
            return .guideArticle(sectionID: parts[1], articleID: parts[2])
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

    nonisolated private static func valuePart(_ parts: [String], _ index: Int) -> String {
        guard parts.indices.contains(index) else { return "" }
        return parts[index]
    }
}
