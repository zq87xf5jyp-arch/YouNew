import Foundation
import Combine

@MainActor
final class AppStateViewModel: ObservableObject {
    static let onboardingCompletionKey = "younew.onboarding.completed.v1"
    static let selectedUserStatusKey = "younew.profile.selectedUserStatus.v1"

    struct PrioritizedChecklist {
        let recommended: [ChecklistItem]
        let later: [ChecklistItem]
        let notRelevant: [ChecklistItem]
        let rationaleByLanguage: [AppLanguage: String]
    }

    struct HomeGuidance {
        let focusNow: [AppLanguage: String]
        let blockedNow: [AppLanguage: String]
        let unlocksNext: [AppLanguage: String]
        let urgentThisWeek: [AppLanguage: String]
    }

    @Published var hasCompletedQuestionnaire: Bool {
        didSet {
            defaults.set(hasCompletedQuestionnaire, forKey: Self.onboardingCompletionKey)
        }
    }
    @Published var selectedLanguage = AppLanguage.english.rawValue
    @Published var selectedStatus = "unsure"
    @Published var selectedCity = "Leiden"
    @Published var selectedHousingSituation = "unknown"
    @Published var checklistItems: [ChecklistItem] = MockChecklistData.items
    @Published var selectedUserStatus: UserStatus? = nil {
        didSet {
            if let selectedUserStatus {
                defaults.set(selectedUserStatus.rawValue, forKey: Self.selectedUserStatusKey)
            } else {
                defaults.removeObject(forKey: Self.selectedUserStatusKey)
            }
        }
    }
    @Published var userProfile: UserProfile = .default
    @Published var preferredMapCategory: PlaceCategory? = nil
    @Published var defaultMapCategory: PlaceCategory? = nil
    @Published var pendingMapFocus: MapFocus? = nil
    @Published var useCurrentLocationForMap = false
    @Published var toastMessage: String? = nil
    @Published var savedGuideIDs: [String] = []
    @Published var completedGuideIDs: [String] = []
    @Published var recentlyViewedTopics: [String] = []
    @Published var recentRouteIDs: [String] = []
    @Published var pendingAIContext: AIContext? = nil
    @Published var pendingAIPrompt: String? = nil
    private let defaults: UserDefaults
    private var toastDismissTask: Task<Void, Never>?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.hasCompletedQuestionnaire = defaults.bool(forKey: Self.onboardingCompletionKey)
        if let savedStatus = defaults.string(forKey: Self.selectedUserStatusKey) {
            self.selectedUserStatus = UserStatus(rawValue: savedStatus)
        }

#if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("-uiTesting"),
           let cityIndex = arguments.firstIndex(of: "-uiTestingCity"),
           arguments.indices.contains(cityIndex + 1),
           MockNearbyPlacesData.supportedCities.contains(arguments[cityIndex + 1]) {
            selectedCity = arguments[cityIndex + 1]
        }
#endif
    }

    deinit {
        toastDismissTask?.cancel()
    }

    var prioritizedGuideSections: [MainGuideSection] {
        guard let status = selectedUserStatus else {
            return MainGuideSection.allCases
        }
        switch status {
        case .tourist:
            return [.transport, .emergency, .helpNearby, .dailyLife, .assistant]
        case .student:
            return [.housing, .transport, .healthcare, .helpNearby, .dailyLife, .assistant]
        case .worker:
            return [.documents, .workAndTaxes, .healthcare, .housing, .transport, .government, .assistant]
        case .expat:
            return [.documents, .workAndTaxes, .government, .housing, .healthcare, .transport, .assistant]
        case .highlySkilledMigrant:
            return [.government, .documents, .workAndTaxes, .housing, .healthcare, .transport, .assistant]
        case .euCitizen:
            return [.government, .documents, .healthcare, .housing, .workAndTaxes, .transport, .assistant]
        case .family:
            return [.housing, .healthcare, .documents, .government, .helpNearby, .dailyLife, .assistant]
        case .refugee, .ukrainian:
            return [.government, .helpNearby, .documents, .healthcare, .housing, .emergency, .assistant]
        case .entrepreneur:
            return [.government, .workAndTaxes, .documents, .healthcare, .housing, .transport, .assistant]
        case .lgbtNewcomer:
            return [.helpNearby, .healthcare, .government, .emergency, .documents, .housing, .assistant]
        }
    }

    var visibleChecklistItems: [ChecklistItem] {
        checklistItems.filter {
            $0.isVisible(for: selectedUserStatus?.personaTag, scope: .currentAndUniversal)
        }
    }

    func destination(for section: MainGuideSection) -> AppDestination {
        switch section {
        case .startHere: return .statusDirection(selectedUserStatus ?? .worker)
        case .dailyLife: return .informationHub
        case .transport: return .guideSection("transport")
        case .documents: return .guideSection("documents")
        case .finesAndRules: return .finesList
        case .workAndTaxes: return .guideSection("work")
        case .housing: return .guideSection("housing")
        case .healthcare: return .guideSection("healthcare")
        case .government: return .governmentHub
        case .emergency: return .emergencyHub
        case .helpNearby: return .mapHub
        case .assistant: return .assistantHub
        }
    }

    func sectionSummary(_ section: MainGuideSection, language: AppLanguage) -> String {
        switch (section, language) {
        case (.startHere, .russian): return "Выберите ситуацию и откройте подходящие маршруты."
        case (.startHere, .dutch): return "Kies je situatie en open relevante routes."
        case (.startHere, .english): return "Select your situation and unlock relevant routes."
        case (.dailyLife, .russian): return "Городские основы, повседневные правила и практические советы."
        case (.dailyLife, .dutch): return "Stadsbasis, routines en praktische tips voor nieuwkomers."
        case (.dailyLife, .english): return "City basics, routines, and practical newcomer tips."
        case (.transport, .russian): return "OV, велосипед, оплата и правила, которые важно проверить."
        case (.transport, .dutch): return "OV, fiets, betalen en regels die je moet controleren."
        case (.transport, .english): return "OV, bike, parking, and what fines to avoid."
        case (.documents, .russian): return "BSN, DigiD, письма и нужные подтверждения."
        case (.documents, .dutch): return "BSN, DigiD, brieven en bewijs dat je nodig hebt."
        case (.documents, .english): return "BSN, DigiD, letters, and proof you need."
        case (.finesAndRules, .russian): return "Правила, штрафы и что делать, если пришло письмо."
        case (.finesAndRules, .dutch): return "Regels, boetes en wat je doet bij een brief."
        case (.finesAndRules, .english): return "Rules, fine ranges, and what to do if fined."
        case (.workAndTaxes, .russian): return "Договор, зарплатный лист, налоги и рабочие права."
        case (.workAndTaxes, .dutch): return "Contract, loonstrook, belasting en rechten op werk."
        case (.workAndTaxes, .english): return "Contract, payslip, tax letters, and rights."
        case (.housing, .russian): return "Проверка аренды, мошенничество, ремонт и адрес."
        case (.housing, .dutch): return "Huurchecks, oplichting, reparaties en adres."
        case (.housing, .english): return "Rental checks, scams, and repair escalation."
        case (.healthcare, .russian): return "Huisarts, страховка, аптека и срочная помощь."
        case (.healthcare, .dutch): return "Huisarts, verzekering, apotheek en spoedzorg."
        case (.healthcare, .english): return "GP, insurance, pharmacy, and urgent care."
        case (.government, .russian): return "Gemeente, IND, UWV и официальные процедуры."
        case (.government, .dutch): return "Gemeente, IND, UWV en officiele procedures."
        case (.government, .english): return "Gemeente, IND, UWV, and official procedures."
        case (.emergency, .russian): return "112, полиция и действия в срочных ситуациях."
        case (.emergency, .dutch): return "112, politie en stappen bij spoed."
        case (.emergency, .english): return "112, police actions, and urgent scenarios."
        case (.helpNearby, .russian): return "Найдите учреждения рядом по категориям."
        case (.helpNearby, .dutch): return "Vind instanties dichtbij met categoriefilters."
        case (.helpNearby, .english): return "Find nearby institutions with category filters."
        case (.assistant, .russian): return "Спросите по теме и получите практические следующие шаги."
        case (.assistant, .dutch): return "Vraag per categorie en krijg praktische vervolgstappen."
        case (.assistant, .english): return "Ask by category and get practical next actions."
        }
    }

    var prioritizedChecklist: PrioritizedChecklist {
        guard let status = selectedUserStatus else {
            return PrioritizedChecklist(recommended: [], later: [], notRelevant: checklistItems, rationaleByLanguage: [:])
        }

        let context = ProfileChecklistContext(
            status: status,
            hasBSN: userProfile.hasBSN,
            hasDigiD: userProfile.hasDigiD,
            hasHealthInsurance: userProfile.hasHealthInsuranceNL,
            hasRegisteredAddress: userProfile.hasRegisteredAddress
        )

        var recommended: [ChecklistItem] = []
        var later: [ChecklistItem] = []
        var notRelevant: [ChecklistItem] = []

        for item in visibleChecklistItems {
            switch ProfileChecklistEngine.categorize(item, context: context) {
            case .recommended: recommended.append(item)
            case .later: later.append(item)
            case .notRelevant: notRelevant.append(item)
            }
        }

        return PrioritizedChecklist(
            recommended: recommended,
            later: later,
            notRelevant: notRelevant,
            rationaleByLanguage: [
                .russian: ProfileChecklistEngine.rationale(for: status, language: .russian),
                .english: ProfileChecklistEngine.rationale(for: status, language: .english),
                .dutch: ProfileChecklistEngine.rationale(for: status, language: .dutch)
            ]
        )
    }

    var homeGuidance: HomeGuidance? {
        guard let status = selectedUserStatus else { return nil }
        let prioritized = prioritizedChecklist
        let next = prioritized.recommended.first(where: { !$0.isCompleted })
        let blueprint = ProfileBlueprint.forStatus(status)
        let firstPriority = blueprint.topPriorities.first?.text ?? [:]

        let blocked = blockedText(for: status)
        let unlocks = unlocksText(for: status)
        let urgent = next?.titleByLanguage ?? firstPriority

        return HomeGuidance(
            focusNow: firstPriority,
            blockedNow: blocked,
            unlocksNext: unlocks,
            urgentThisWeek: urgent
        )
    }

    func toggleChecklistItem(_ item: ChecklistItem) {
        guard item.isVisible(for: selectedUserStatus?.personaTag, scope: .currentAndUniversal),
              let idx = checklistItems.firstIndex(where: { $0.id == item.id })
        else { return }
        checklistItems[idx].isCompleted.toggle()
    }

    func showToast(_ message: String) {
        toastDismissTask?.cancel()
        toastMessage = message
        toastDismissTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                self?.toastMessage = nil
            }
        }
    }

    var requiresPersonaSelection: Bool {
        !hasCompletedQuestionnaire || selectedUserStatus == nil
    }

    func completeQuestionnaire() {
        hasCompletedQuestionnaire = true
    }

    func addRecentlyViewedTopic(_ topic: String) {
        guard !topic.isEmpty else { return }
        recentlyViewedTopics = [topic] + recentlyViewedTopics.filter { $0 != topic }
    }

    func addRecentRouteID(_ routeID: String?) {
        guard let routeID,
              !routeID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else { return }
        recentRouteIDs = [routeID] + recentRouteIDs.filter { $0 != routeID }
        recentRouteIDs = Array(recentRouteIDs.prefix(12))
    }

    func markGuideCompleted(routeID: String?) {
        guard let routeID,
              routeID.hasPrefix("guide:") || routeID.hasPrefix("article:")
        else { return }
        completedGuideIDs = [routeID] + completedGuideIDs.filter { $0 != routeID }
        completedGuideIDs = Array(completedGuideIDs.prefix(40))
    }

    func displayTitle(forRecentlyViewedTopic topic: String, language: AppLanguage) -> String {
        if let idText = topic.removingPrefix("searchAnswer::"),
           let id = UUID(uuidString: idText),
           let answer = MockSearchAnswersData.items.first(where: {
               $0.id == id && $0.isVisible(for: selectedUserStatus?.personaTag, scope: .currentAndUniversal)
           }) {
            return answer.title(language)
        }
        if let idText = topic.removingPrefix("checklist::"),
           let id = UUID(uuidString: idText),
           let item = checklistItems.first(where: {
               $0.id == id && $0.isVisible(for: selectedUserStatus?.personaTag, scope: .currentAndUniversal)
           }) {
            return item.title(language)
        }
        if MockNearbyPlacesData.places.contains(where: {
            $0.name == topic && $0.isVisible(for: selectedUserStatus?.personaTag)
        }) {
            return topic
        }
        if selectedUserStatus?.personaTag != nil {
            return ""
        }
        return topic
    }

    func visibleRecentlyViewedTopics() -> [String] {
        recentlyViewedTopics.filter {
            !displayTitle(forRecentlyViewedTopic: $0, language: .english)
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .isEmpty
        }
    }

    func visibleRecentRouteIDs() -> [String] {
        let persona = selectedUserStatus?.personaTag
        return recentRouteIDs.filter { routeID in
            guard let destination = AppNavigationResolver.destination(for: routeID) else { return false }
            return RelatedContentEngine.isVisible(destination, for: persona)
        }
    }

    func visibleCompletedGuideIDs() -> [String] {
        let persona = selectedUserStatus?.personaTag
        return completedGuideIDs.filter { routeID in
            AppNavigationResolver.destination(for: routeID, visibleFor: persona) != nil
        }
    }

    func resetPersonalState() {
        hasCompletedQuestionnaire = false
        selectedLanguage = AppLanguage.english.rawValue
        selectedStatus = "unsure"
        selectedCity = "Leiden"
        selectedHousingSituation = "unknown"
        checklistItems = MockChecklistData.items
        selectedUserStatus = nil
        userProfile = .default
        preferredMapCategory = nil
        defaultMapCategory = nil
        useCurrentLocationForMap = false
        savedGuideIDs = []
        completedGuideIDs = []
        recentlyViewedTopics = []
        recentRouteIDs = []
        pendingAIContext = nil
        pendingAIPrompt = nil
    }

    func privacyExportPayload(
        savedItemsCount: Int,
        documentMetadata: [DocumentItem]
    ) -> PrivacyExportPayload {
        PrivacyExportPayload(
            exportedAt: Date(),
            selectedLanguage: selectedLanguage,
            selectedStatus: selectedUserStatus?.rawValue,
            selectedCity: selectedCity,
            userProfile: PrivacyExportPayload.ProfileSummary(
                profileType: userProfile.profileType.rawValue,
                municipality: userProfile.municipality,
                hasBSN: userProfile.hasBSN,
                hasDigiD: userProfile.hasDigiD,
                hasHealthInsuranceNL: userProfile.hasHealthInsuranceNL,
                hasRegisteredAddress: userProfile.hasRegisteredAddress,
                remindersEnabled: userProfile.remindersEnabled
            ),
            checklist: checklistItems.map {
                PrivacyExportPayload.ChecklistSummary(
                    id: $0.id.uuidString,
                    title: $0.title,
                    isCompleted: $0.isCompleted
                )
            },
            savedItemsCount: savedItemsCount,
            recentlyViewedTopics: recentlyViewedTopics,
            recentRouteIDs: recentRouteIDs,
            completedGuideIDs: completedGuideIDs,
            documents: documentMetadata.map {
                PrivacyExportPayload.DocumentSummary(
                    id: $0.id.uuidString,
                    title: $0.title,
                    category: $0.category.rawValue,
                    createdAt: $0.createdAt,
                    isSensitive: $0.isSensitive,
                    hasNotes: !$0.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                    fileName: $0.fileURL.lastPathComponent
                )
            }
        )
    }

    private func blockedText(for status: UserStatus) -> [AppLanguage: String] {
        switch status {
        case .worker, .expat, .highlySkilledMigrant, .euCitizen, .entrepreneur:
            if !userProfile.hasBSN {
                return [.russian: "Без BSN будут ограничены налоги, DigiD и часть рабочих процессов.", .english: "Without BSN, taxes, DigiD, and some work processes stay limited.", .dutch: "Zonder BSN blijven belastingen, DigiD en sommige werkprocessen beperkt."]
            }
            if !userProfile.hasDigiD {
                return [.russian: "Без DigiD медленнее доступ к государственным кабинетам.", .english: "Without DigiD, access to government portals is slower.", .dutch: "Zonder DigiD is toegang tot overheidsportalen trager."]
            }
        case .student:
            if !userProfile.hasBSN {
                return [.russian: "Без BSN часть студенческих и административных шагов будет недоступна.", .english: "Without BSN, some student and admin steps remain unavailable.", .dutch: "Zonder BSN blijven sommige studenten- en administratiestappen beperkt."]
            }
        case .tourist:
            return [.russian: "Если не проверить срок пребывания, можно нарушить правила въезда.", .english: "If you do not check stay duration, you may violate entry rules.", .dutch: "Als u verblijfsduur niet controleert, kunt u regels overtreden."]
        case .refugee, .ukrainian, .family, .lgbtNewcomer:
            if !userProfile.hasRegisteredAddress {
                return [.russian: "Без подтверждённого адреса часть сервисов и писем может задерживаться.", .english: "Without confirmed address, some services and letters can be delayed.", .dutch: "Zonder bevestigd adres kunnen sommige diensten en brieven vertragen."]
            }
        }
        return [.russian: "Критических блокировок не обнаружено, продолжайте следующие шаги.", .english: "No critical blocker detected; continue with next steps.", .dutch: "Geen kritieke blokkade gevonden; ga verder met de volgende stappen."]
    }

    private func unlocksText(for status: UserStatus) -> [AppLanguage: String] {
        switch status {
        case .worker:
            return [.russian: "После базовой регистрации откроются налоговые действия, страховка и стабильная работа с документами.", .english: "After core registration, tax actions, insurance, and stable document workflows unlock.", .dutch: "Na basisregistratie komen belastingacties, verzekering en stabiele documentprocessen vrij."]
        case .expat:
            return [.russian: "После основных шагов откроются налоговая оптимизация и полноценный доступ к госкабинетам.", .english: "After core steps, tax optimization and full access to government portals unlock.", .dutch: "Na kernstappen komen fiscale optimalisatie en volledige toegang tot overheidsportalen vrij."]
        case .highlySkilledMigrant:
            return [.russian: "После основных шагов станет проще управлять IND, 30%-regeling, жильём и страховкой.", .english: "After core steps, IND, 30% ruling, housing, and insurance become easier to manage.", .dutch: "Na kernstappen worden IND, 30%-regeling, wonen en verzekering eenvoudiger."]
        case .euCitizen:
            return [.russian: "После регистрации проще управлять BSN, DigiD, работой, медициной и налогами.", .english: "After registration, BSN, DigiD, work, healthcare, and taxes become easier to manage.", .dutch: "Na registratie worden BSN, DigiD, werk, zorg en belastingen eenvoudiger."]
        case .student:
            return [.russian: "После ключевых шагов станет проще использовать DUO, транспорт и учебные сервисы.", .english: "After key steps, DUO, transport, and study services become easier to use.", .dutch: "Na kernstappen worden DUO, vervoer en onderwijsdiensten eenvoudiger."]
        case .tourist:
            return [.russian: "После проверки документов и страховки легче управлять безопасным краткосрочным пребыванием.", .english: "After document and insurance checks, short-stay safety management becomes easier.", .dutch: "Na document- en verzekeringscontrole wordt veilig kort verblijf eenvoudiger."]
        case .refugee:
            return [.russian: "После ключевых шагов упростится доступ к поддержке, медицине и интеграционным маршрутам.", .english: "After core steps, access to support, healthcare, and integration routes improves.", .dutch: "Na kernstappen verbetert toegang tot ondersteuning, zorg en integratieroutes."]
        case .ukrainian:
            return [.russian: "После базовых шагов станет понятнее работа, медицина и официальные процедуры.", .english: "After core steps, work, healthcare, and official procedures become clearer.", .dutch: "Na basisstappen worden werk, zorg en officiële procedures duidelijker."]
        case .family:
            return [.russian: "После базовых шагов проще организовать школу, страхование и семейные документы.", .english: "After core steps, school, insurance, and family document setup become easier.", .dutch: "Na basisstappen worden school, verzekering en gezinsdocumenten eenvoudiger."]
        case .entrepreneur:
            return [.russian: "После базовых шагов проще управлять KvK, BTW/VAT, налогами, банком и разрешениями.", .english: "After core steps, KvK, VAT/BTW, taxes, banking, and permits become easier to manage.", .dutch: "Na basisstappen worden KvK, BTW, belasting, bankzaken en vergunningen eenvoudiger."]
        case .lgbtNewcomer:
            return [.russian: "После базовых шагов проще находить безопасную поддержку, медицину, юридическую помощь и сообщество.", .english: "After core steps, safe support, healthcare, legal help, and community become easier to find.", .dutch: "Na basisstappen worden veilige steun, zorg, juridische hulp en gemeenschap makkelijker te vinden."]
        }
    }
}

struct PrivacyExportPayload: Codable {
    struct ProfileSummary: Codable {
        let profileType: String
        let municipality: String
        let hasBSN: Bool
        let hasDigiD: Bool
        let hasHealthInsuranceNL: Bool
        let hasRegisteredAddress: Bool
        let remindersEnabled: Bool
    }

    struct ChecklistSummary: Codable {
        let id: String
        let title: String
        let isCompleted: Bool
    }

    struct DocumentSummary: Codable {
        let id: String
        let title: String
        let category: String
        let createdAt: Date
        let isSensitive: Bool
        let hasNotes: Bool
        let fileName: String
    }

    let exportedAt: Date
    let selectedLanguage: String
    let selectedStatus: String?
    let selectedCity: String
    let userProfile: ProfileSummary
    let checklist: [ChecklistSummary]
    let savedItemsCount: Int
    let recentlyViewedTopics: [String]
    let recentRouteIDs: [String]
    let completedGuideIDs: [String]
    let documents: [DocumentSummary]
}

private extension String {
    func removingPrefix(_ prefix: String) -> String? {
        guard hasPrefix(prefix) else { return nil }
        return String(dropFirst(prefix.count))
    }
}
