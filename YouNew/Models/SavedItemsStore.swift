import Foundation
import Combine

final class SavedItemsStore: ObservableObject {
    private struct CanonicalPersistedSavedItem: Codable {
        let id: ContentID
        let savedAt: Date
    }

    private struct LegacyPersistedSavedItem: Codable {
        let id: String
        let kind: SavedItemKind
        let title: String
        let subtitle: String?
        let destination: PersistedDestination?
        let savedAt: Date
    }

    private enum PersistedDestination: Codable {
        case checklist(String)
        case dutchTerm(String)
        case fineInfo(String)
        case institution(String)
        case searchAnswer(String)
        case letter(String)
        case mistake(String)
        case beginnerGuide(String)
        case statusDirection(String)
        case ruleTopic(String)
        case ruleScenario(String)
        case resource(String)
        case document(String)
        case placeDetail(String)
        case calendarEvent(String)
        case provinceList
        case cityList
        case provinceDetail(String)
        case provinceCities(String)
        case cityDetail(String, String)
        case homeExploreList(String)
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
        case mapFocus(String)
        case assistantHub
        case informationHub
        case governmentHub
        case helpHub
        case languageHub
        case historyKNMHub
        case emergencyHub
        case categoriesHub
        case firstSteps
        case knm
        case knmModule(String)
        case dutchA1A2
        case dutchA1A2Module(String)
        case practicalGuide(String)
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
        case journeyDocuments
        case scamWarningsList
        case scamWarning(String)
        case guideSection(String)
        case guideArticle(String, String)
        case dutchHolidays
        case dutchFigures
        case dutchMonarchy
    }

    enum SavedItemKind: String, Codable, CaseIterable {
        case rule
        case city
        case institution
        case document
        case resource
        case place
        case other
    }

    struct SavedItem: Identifiable, Hashable {
        let id: String
        let kind: SavedItemKind
        let title: String
        let subtitle: String?
        let destination: AppDestination?
        let savedAt: Date

        func displayTitle(_ language: AppLanguage) -> String {
            if let content = ContentRepository.shared.item(id: id) {
                switch language {
                case .english: return content.title
                case .dutch: return content.localTitle["nl"] ?? content.title
                case .russian: return content.localTitle["ru"] ?? content.title
                }
            }
            switch destination {
            case .checklist(let id):
                return MockChecklistData.items.first(where: { $0.id == id })?.title(language) ?? title
            case .dutchTerm(let id):
                return MockDutchTermsData.items.first(where: { $0.id == id })?.dutchTerm ?? title
            case .fineInfo(let id):
                return MockFineInfoData.items.first(where: { $0.id == id })?.title(language) ?? title
            case .searchAnswer(let id):
                return MockSearchAnswersData.items.first(where: { $0.id == id })?.title(language) ?? title
            case .letter(let title):
                return MockLettersData.examples.first(where: { $0.title.caseInsensitiveCompare(title) == .orderedSame })?.title(language) ?? self.title
            case .mistake(let id):
                return MockNewcomerMistakesData.items.first(where: { $0.id == id })?.title(language) ?? title
            case .beginnerGuide(let id):
                return MockBeginnerGuidesData.items.first(where: { $0.id == id })?.title(language) ?? title
            case .resource(let id):
                return MockResourcesData.items.first(where: { $0.id == id })?.localizedTitle(language) ?? title
            default:
                return title
            }
        }

        func displaySubtitle(_ language: AppLanguage) -> String? {
            if let content = ContentRepository.shared.item(id: id),
               let category = Category.canonical.first(where: { $0.id == content.primaryCategoryID }) {
                switch language {
                case .english: return category.title
                case .dutch: return category.localTitle["nl"] ?? category.title
                case .russian: return category.localTitle["ru"] ?? category.title
                }
            }
            switch destination {
            case .checklist(let id):
                return MockChecklistData.items.first(where: { $0.id == id })?.category.localized(language) ?? subtitle
            case .dutchTerm(let id):
                return MockDutchTermsData.items.first(where: { $0.id == id })?.category.localizedTitle(language) ?? subtitle
            case .fineInfo(let id):
                return MockFineInfoData.items.first(where: { $0.id == id })?.category.localized(language) ?? subtitle
            case .searchAnswer(let id):
                return MockSearchAnswersData.items.first(where: { $0.id == id })?.category.localized(language) ?? subtitle
            case .letter(let title):
                return MockLettersData.examples.first(where: { $0.title.caseInsensitiveCompare(title) == .orderedSame })?.institutionName(language) ?? subtitle
            case .mistake(let id):
                return MockNewcomerMistakesData.items.first(where: { $0.id == id })?.category.localized(language) ?? subtitle
            case .resource(let id):
                return MockResourcesData.items.first(where: { $0.id == id })?.localizedCategory(language) ?? subtitle
            default:
                return subtitle
            }
        }
    }

    static let shared = SavedItemsStore()
    private static let savedItemsStorageKey = "SavedItemsStore.savedItems.v1"

    @Published private(set) var savedItemsByID: [String: SavedItem] = [:] {
        didSet { persistSavedItems() }
    }
    @Published var recentlyViewedGuideIDs: [String] = []

    init() {
        savedItemsByID = Self.loadSavedItems()
    }

    var savedGuideIDs: Set<String> {
        Set(savedItemsByID.keys)
    }

    var savedItems: [SavedItem] {
        savedItemsByID.values.sorted { $0.savedAt > $1.savedAt }
    }

    func isSaved(_ id: String) -> Bool {
        savedItemsByID[id] != nil
    }

    func toggle(_ id: String) {
        if isSaved(id) {
            savedItemsByID.removeValue(forKey: id)
        } else {
            let item = SavedItem(
                id: id,
                kind: .other,
                title: id,
                subtitle: nil,
                destination: nil,
                savedAt: Date()
            )
            savedItemsByID[id] = item
        }
    }

    func toggle(item: SavedItem) {
        if isSaved(item.id) {
            savedItemsByID.removeValue(forKey: item.id)
        } else {
            savedItemsByID[item.id] = item
        }
    }

    func toggle(
        id: String,
        kind: SavedItemKind,
        title: String,
        subtitle: String? = nil,
        destination: AppDestination? = nil
    ) {
        let item = SavedItem(
            id: id,
            kind: kind,
            title: title,
            subtitle: subtitle,
            destination: destination,
            savedAt: Date()
        )
        toggle(item: item)
    }

    func save(_ id: String) {
        toggle(
            id: id,
            kind: .other,
            title: id,
            subtitle: nil,
            destination: nil
        )
    }

    func remove(_ id: String) {
        savedItemsByID.removeValue(forKey: id)
    }

    func removeAll() {
        savedItemsByID.removeAll()
        recentlyViewedGuideIDs.removeAll()
        UserDefaults.standard.removeObject(forKey: Self.savedItemsStorageKey)
    }

    func clearCachedSavedItemsForSchemaMigration() {
        savedItemsByID.removeAll()
        recentlyViewedGuideIDs.removeAll()
    }

    private func persistSavedItems() {
        let payload = savedItemsByID.values.map { item in
            CanonicalPersistedSavedItem(
                id: item.id,
                savedAt: item.savedAt
            )
        }

        guard let data = try? JSONEncoder().encode(payload) else { return }
        UserDefaults.standard.set(data, forKey: Self.savedItemsStorageKey)
    }

    private static func loadSavedItems() -> [String: SavedItem] {
        guard let data = UserDefaults.standard.data(forKey: savedItemsStorageKey) else {
            return [:]
        }

        if let payload = try? JSONDecoder().decode([CanonicalPersistedSavedItem].self, from: data) {
            return payload.reduce(into: [:]) { result, item in
                guard !item.id.isEmpty else { return }
                let content = ContentRepository.shared.item(id: item.id)
                result[item.id] = SavedItem(
                    id: item.id,
                    kind: savedItemKind(for: content?.contentType),
                    title: content?.title ?? item.id,
                    subtitle: content?.primaryCategoryID,
                    destination: ContentRepository.shared.legacyDestination(id: item.id),
                    savedAt: item.savedAt
                )
            }
        }

        guard let legacyPayload = try? JSONDecoder().decode([LegacyPersistedSavedItem].self, from: data) else {
            return [:]
        }
        return legacyPayload.reduce(into: [:]) { result, item in
            guard !item.id.isEmpty else { return }
            let content = ContentRepository.shared.item(id: item.id)
            result[item.id] = SavedItem(
                id: item.id,
                kind: content.map { savedItemKind(for: $0.contentType) } ?? item.kind,
                title: content?.title ?? item.title,
                subtitle: content?.primaryCategoryID ?? item.subtitle,
                destination: ContentRepository.shared.legacyDestination(id: item.id) ?? destination(from: item.destination),
                savedAt: item.savedAt
            )
        }
    }

    private static func savedItemKind(for contentType: ContentType?) -> SavedItemKind {
        switch contentType {
        case .city: return .city
        case .place: return .place
        case .officialService: return .institution
        case .externalResource: return .resource
        default: return .other
        }
    }

    private static func persistedDestination(from destination: AppDestination?) -> PersistedDestination? {
        guard let destination else { return nil }
        switch destination {
        case .checklist(let id): return .checklist(id.uuidString)
        case .dutchTerm(let id): return .dutchTerm(id.uuidString)
        case .fineInfo(let id): return .fineInfo(id.uuidString)
        case .institution(let name): return .institution(name)
        case .searchAnswer(let id): return .searchAnswer(id.uuidString)
        case .letter(let title): return .letter(title)
        case .mistake(let id): return .mistake(id.uuidString)
        case .beginnerGuide(let id): return .beginnerGuide(id.uuidString)
        case .statusDirection(let status): return .statusDirection(status.rawValue)
        case .ruleTopic(let id): return .ruleTopic(id.uuidString)
        case .ruleScenario(let id): return .ruleScenario(id.uuidString)
        case .resource(let id): return .resource(id.uuidString)
        case .document(let id): return .document(id.uuidString)
        case .placeDetail(let id): return .placeDetail(id)
        case .calendarEvent(let id): return .calendarEvent(id)
        case .provinceList: return .provinceList
        case .cityList: return .cityList
        case .provinceDetail(let provinceName): return .provinceDetail(provinceName)
        case .provinceCities(let provinceName): return .provinceCities(provinceName)
        case .cityDetail(let province, let city): return .cityDetail(province, city)
        case .homeExploreList(let id): return .homeExploreList(id)
        case .checklistList: return .checklistList
        case .institutionsList: return .institutionsList
        case .finesList: return .finesList
        case .lettersList: return .lettersList
        case .dutchTermsList: return .dutchTermsList
        case .searchList: return .searchList
        case .mistakesList: return .mistakesList
        case .beginnerGuidesList: return .beginnerGuidesList
        case .survivalHub: return .survivalHub
        case .emotionalSupport: return .emotionalSupport
        case .lgbtqSupport: return .lgbtqSupport
        case .mapHub: return .mapHub
        case .mapFocus(let focus): return .mapFocus(focus.rawValue)
        case .assistantHub: return .assistantHub
        case .informationHub: return .informationHub
        case .governmentHub: return .governmentHub
        case .helpHub: return .helpHub
        case .languageHub: return .languageHub
        case .historyKNMHub: return .historyKNMHub
        case .emergencyHub: return .emergencyHub
        case .categoriesHub: return .categoriesHub
        case .firstSteps: return .firstSteps
        case .knm: return .knm
        case .knmModule(let id): return .knmModule(id)
        case .dutchA1A2: return .dutchA1A2
        case .dutchA1A2Module(let id): return .dutchA1A2Module(id)
        case .practicalGuide(let topic): return .practicalGuide(topic.rawValue)
        case .netherlandsOverview: return .netherlandsOverview
        case .nlCityDetail(let cityID): return .nlCityDetail(cityID)
        case .netherlandsHistory: return .netherlandsHistory
        case .cultureAttractions: return .cultureAttractions
        case .netherlandsCalendar: return .netherlandsCalendar
        case .settings: return .settings
        case .profileSelection: return .profileSelection
        case .savedTopics: return .savedTopics
        case .recentlyViewedTopics: return .recentlyViewedTopics
        case .resourcesHub: return .resourcesHub
        case .lifeTimeline: return .lifeTimeline
        case .documentVault: return .documentVault
        case .deadlineCenter: return .deadlineCenter
        case .verifiedExperts: return .verifiedExperts
        case .aiLetterGenerator: return .aiLetterGenerator
        case .discoverNetherlands: return .discoverNetherlands
        case .localPartners: return .localPartners
        case .localPartnerDetail(let id): return .localPartnerDetail(id)
        case .businessGrowth: return .businessGrowth
        case .businessLogin: return .businessLogin
        case .businessDashboard: return .businessDashboard
        case .finesAndLettersHub: return .finesAndLettersHub
        case .legalHelp: return .legalHelp
        case .officialSources: return .officialSources
        case .aboutYouNew: return .aboutYouNew
        case .supportFeedback: return .supportFeedback
        case .privacyDataControl: return .privacyDataControl
        case .termsOfUse: return .termsOfUse
        case .legalDisclaimer: return .legalDisclaimer
        case .journeyDocuments: return .journeyDocuments
        case .scamWarningsList: return .scamWarningsList
        case .scamWarning(let id): return .scamWarning(id.uuidString)
        case .guideSection(let id): return .guideSection(id)
        case .guideArticle(let sectionID, let articleID): return .guideArticle(sectionID, articleID)
        case .dutchHolidays: return .dutchHolidays
        case .dutchFigures: return .dutchFigures
        case .dutchMonarchy: return .dutchMonarchy
        }
    }

    private static func destination(from persistedDestination: PersistedDestination?) -> AppDestination? {
        guard let persistedDestination else { return nil }
        switch persistedDestination {
        case .checklist(let id):
            return restoredUUIDDestination(id, in: MockChecklistData.items.map(\.id), AppDestination.checklist)
        case .dutchTerm(let id):
            return restoredUUIDDestination(id, in: MockDutchTermsData.items.map(\.id), AppDestination.dutchTerm)
        case .fineInfo(let id):
            return restoredUUIDDestination(id, in: MockFineInfoData.items.map(\.id), AppDestination.fineInfo)
        case .institution(let name):
            return MockInstitutionsData.items.contains(where: { $0.name.caseInsensitiveCompare(name) == .orderedSame }) ? .institution(name) : nil
        case .searchAnswer(let id):
            return restoredUUIDDestination(id, in: MockSearchAnswersData.items.map(\.id), AppDestination.searchAnswer)
        case .letter(let title):
            return MockLettersData.examples.contains(where: { $0.title.caseInsensitiveCompare(title) == .orderedSame }) ? .letter(title) : nil
        case .mistake(let id):
            return restoredUUIDDestination(id, in: MockNewcomerMistakesData.items.map(\.id), AppDestination.mistake)
        case .beginnerGuide(let id):
            return restoredUUIDDestination(id, in: MockBeginnerGuidesData.items.map(\.id), AppDestination.beginnerGuide)
        case .statusDirection(let status): return UserStatus(rawValue: status).map(AppDestination.statusDirection)
        case .ruleTopic(let id):
            return restoredUUIDDestination(id, in: MockRulesGuideData.topics.map(\.id), AppDestination.ruleTopic)
        case .ruleScenario(let id):
            return restoredUUIDDestination(id, in: MockRulesGuideData.scenarios.map(\.id), AppDestination.ruleScenario)
        case .resource(let id):
            return restoredUUIDDestination(id, in: MockResourcesData.items.map(\.id), AppDestination.resource)
        case .document(let id): return UUID(uuidString: id).map(AppDestination.document)
        case .placeDetail(let id):
            return DashboardPlacesData.places.contains(where: { $0.id == id }) ? .placeDetail(id) : nil
        case .calendarEvent(let id):
            return DashboardCalendarData.events.contains(where: { $0.id == id }) ? .calendarEvent(id) : nil
        case .provinceList: return .provinceList
        case .cityList: return .cityList
        case .provinceDetail(let provinceName):
            return ProvinceCatalog.provinceIfFound(matching: provinceName) == nil ? nil : .provinceDetail(provinceName)
        case .provinceCities(let provinceName):
            return ProvinceCatalog.provinceIfFound(matching: provinceName) == nil ? nil : .provinceCities(provinceName)
        case .cityDetail(let province, let city):
            guard let provinceItem = ProvinceCatalog.provinceIfFound(matching: province),
                  ProvinceCatalog.cityIfFound(named: city, provinceID: provinceItem.id) != nil else { return nil }
            return .cityDetail(province: province, city: city)
        case .homeExploreList(let id): return id.isEmpty ? nil : .homeExploreList(id)
        case .checklistList: return .checklistList
        case .institutionsList: return .institutionsList
        case .finesList: return .finesList
        case .lettersList: return .lettersList
        case .dutchTermsList: return .dutchTermsList
        case .searchList: return .searchList
        case .mistakesList: return .mistakesList
        case .beginnerGuidesList: return .beginnerGuidesList
        case .survivalHub: return .survivalHub
        case .emotionalSupport: return .emotionalSupport
        case .lgbtqSupport: return .lgbtqSupport
        case .mapHub: return .mapHub
        case .mapFocus(let focus): return MapFocus(rawValue: focus).map(AppDestination.mapFocus)
        case .assistantHub: return .assistantHub
        case .informationHub: return .informationHub
        case .governmentHub: return .governmentHub
        case .helpHub: return .helpHub
        case .languageHub: return .languageHub
        case .historyKNMHub: return .historyKNMHub
        case .emergencyHub: return .emergencyHub
        case .categoriesHub: return .categoriesHub
        case .firstSteps: return .firstSteps
        case .knm: return .knm
        case .knmModule(let id): return KNMGuideData.module(with: id) == nil ? nil : .knmModule(id)
        case .dutchA1A2: return .dutchA1A2
        case .dutchA1A2Module(let id): return DutchA1A2CourseData.module(with: id) == nil ? nil : .dutchA1A2Module(id)
        case .practicalGuide(let topic): return PracticalGuideTopic(rawValue: topic).map(AppDestination.practicalGuide)
        case .netherlandsOverview: return .netherlandsOverview
        case .nlCityDetail(let cityID):
            return ProvinceCatalog.citySpotlight(matching: cityID) == nil && NLCity.all.first(where: { $0.id == cityID || $0.name.caseInsensitiveCompare(cityID) == .orderedSame }) == nil ? nil : .nlCityDetail(cityID)
        case .netherlandsHistory: return .netherlandsHistory
        case .cultureAttractions: return .cultureAttractions
        case .netherlandsCalendar: return .netherlandsCalendar
        case .settings: return .settings
        case .profileSelection: return .profileSelection
        case .savedTopics: return .savedTopics
        case .recentlyViewedTopics: return .recentlyViewedTopics
        case .resourcesHub: return .resourcesHub
        case .lifeTimeline: return .lifeTimeline
        case .documentVault: return .documentVault
        case .deadlineCenter: return .deadlineCenter
        case .verifiedExperts: return .verifiedExperts
        case .aiLetterGenerator: return .aiLetterGenerator
        case .discoverNetherlands: return .discoverNetherlands
        case .localPartners: return .localPartners
        case .localPartnerDetail(let id):
            return MockLocalPartnersData.partner(id: id) == nil ? nil : .localPartnerDetail(id)
        case .businessGrowth: return .businessGrowth
        case .businessLogin: return .businessLogin
        case .businessDashboard: return .businessDashboard
        case .finesAndLettersHub: return .finesAndLettersHub
        case .legalHelp: return .legalHelp
        case .officialSources: return .officialSources
        case .aboutYouNew: return .aboutYouNew
        case .supportFeedback: return .supportFeedback
        case .privacyDataControl: return .privacyDataControl
        case .termsOfUse: return .termsOfUse
        case .legalDisclaimer: return .legalDisclaimer
        case .journeyDocuments: return .journeyDocuments
        case .scamWarningsList: return .scamWarningsList
        case .scamWarning(let id):
            return restoredUUIDDestination(id, in: MockScamWarningsData.items.map(\.id), AppDestination.scamWarning)
        case .guideSection(let id): return GuideContent.section(id: id) == nil ? nil : .guideSection(id)
        case .guideArticle(let sectionID, let articleID):
            return GuideContent.article(sectionID: sectionID, articleID: articleID) == nil ? nil : .guideArticle(sectionID: sectionID, articleID: articleID)
        case .dutchHolidays: return .dutchHolidays
        case .dutchFigures: return .dutchFigures
        case .dutchMonarchy: return .dutchMonarchy
        }
    }

    private static func restoredUUIDDestination(
        _ id: String,
        in validIDs: [UUID],
        _ destination: (UUID) -> AppDestination
    ) -> AppDestination? {
        guard let uuid = UUID(uuidString: id), validIDs.contains(uuid) else { return nil }
        return destination(uuid)
    }
}
