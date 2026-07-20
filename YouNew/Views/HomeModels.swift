import SwiftUI

struct HomeLifeScenario: Identifiable {
    let id: String
    let titleRU: String
    let titleNL: String
    let titleEN: String
    let subtitleRU: String
    let subtitleNL: String
    let subtitleEN: String
    let asset: AppImageAsset?
    let accent: Color
    let destination: AppDestination

    func title(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return titleRU
        case .dutch: return titleNL
        case .english: return titleEN
        }
    }

    func subtitle(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return subtitleRU
        case .dutch: return subtitleNL
        case .english: return subtitleEN
        }
    }
}

struct HomeCityMoment: Identifiable {
    let id: String
    let titleRU: String
    let titleNL: String
    let titleEN: String
    let subtitleRU: String
    let subtitleNL: String
    let subtitleEN: String
    let asset: AppImageAsset?
    let accent: Color
    let destination: AppDestination?

    func title(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return titleRU
        case .dutch: return titleNL
        case .english: return titleEN
        }
    }

    func subtitle(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return subtitleRU
        case .dutch: return subtitleNL
        case .english: return subtitleEN
        }
    }
}

struct HomeHeroCity: Identifiable {
    let id: String
    let name: String
    let provinceRU: String
    let provinceNL: String
    let provinceEN: String
    let descriptionRU: String
    let descriptionNL: String
    let descriptionEN: String
    let statOneValue: String
    let statOneRU: String
    let statOneNL: String
    let statOneEN: String
    let statTwoValue: String
    let statTwoRU: String
    let statTwoNL: String
    let statTwoEN: String
    let statThreeValue: String
    let statThreeRU: String
    let statThreeNL: String
    let statThreeEN: String
    let symbol: String
    let asset: AppImageAsset?
    let destination: AppDestination

    func province(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return provinceRU
        case .dutch: return provinceNL
        case .english: return provinceEN
        }
    }

    func description(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return descriptionRU
        case .dutch: return descriptionNL
        case .english: return descriptionEN
        }
    }

    func statOneTitle(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return statOneRU
        case .dutch: return statOneNL
        case .english: return statOneEN
        }
    }

    func statTwoTitle(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return statTwoRU
        case .dutch: return statTwoNL
        case .english: return statTwoEN
        }
    }

    func statThreeTitle(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return statThreeRU
        case .dutch: return statThreeNL
        case .english: return statThreeEN
        }
    }
}

struct HomeQuickAction: Identifiable {
    let id: String
    let titleRU: String
    let titleNL: String
    let titleEN: String
    let shortTitleRU: String
    let shortTitleNL: String
    let shortTitleEN: String
    let subtitleRU: String
    let subtitleNL: String
    let subtitleEN: String
    let icon: String
    let accent: Color
    let destination: AppDestination
    let audienceTags: Set<PersonaTag>
    let priority: Int
    let hidden: Bool
    let draft: Bool

    func title(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return titleRU
        case .dutch: return titleNL
        case .english: return titleEN
        }
    }

    func shortTitle(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return shortTitleRU
        case .dutch: return shortTitleNL
        case .english: return shortTitleEN
        }
    }

    func subtitle(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return subtitleRU
        case .dutch: return subtitleNL
        case .english: return subtitleEN
        }
    }
}

struct HomeHelpTopic: Identifiable {
    let id: String
    let titleEN: String
    let titleNL: String
    let titleRU: String
    let shortTitleEN: String
    let shortTitleNL: String
    let shortTitleRU: String
    let subtitleEN: String
    let subtitleNL: String
    let subtitleRU: String
    let icon: String
    let tint: Color
    let destination: AppDestination
    let audienceTags: Set<PersonaTag>
    let priority: Int
    let hidden: Bool
    let draft: Bool

    func title(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return titleRU
        case .dutch: return titleNL
        case .english: return titleEN
        }
    }

    func shortTitle(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return shortTitleRU
        case .dutch: return shortTitleNL
        case .english: return shortTitleEN
        }
    }

    func subtitle(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return subtitleRU
        case .dutch: return subtitleNL
        case .english: return subtitleEN
        }
    }
}

struct HomeSecondaryTool: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color
    let tab: AppTab
    let audienceTags: Set<PersonaTag>
    let priority: Int
}

struct HomePersonaJourney: Identifiable {
    let id: String
    let titleEN: String
    let titleNL: String
    let titleRU: String
    let subtitleEN: String
    let subtitleNL: String
    let subtitleRU: String
    let icon: String
    let tint: Color
    let destination: AppDestination

    func title(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return titleRU
        case .dutch: return titleNL
        case .english: return titleEN
        }
    }

    func subtitle(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return subtitleRU
        case .dutch: return subtitleNL
        case .english: return subtitleEN
        }
    }
}

struct HomeCategoryItem: Identifiable {
    let id: String
    let titleRU: String
    let titleNL: String
    let titleEN: String
    let icon: String
    let gradient: [Color]
    let destination: AppDestination
    let audienceTags: Set<PersonaTag>
    let priority: Int

    func title(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return titleRU
        case .dutch: return titleNL
        case .english: return titleEN
        }
    }
}

enum HomeDefaultCategoryCatalog {
    static func defaultCategories(selectedCityName: String) -> [HomeCategoryItem] {
        [
            HomeCategoryItem(
                id: "rules_fines",
                titleRU: "Правила и штрафы",
                titleNL: "Regels & boetes",
                titleEN: "Rules & fines",
                icon: "exclamationmark.triangle.fill",
                gradient: AppColors.gradFines,
                destination: .finesAndLettersHub,
                audienceTags: [.tourist, .student, .worker, .refugee, .family, .entrepreneur, .lgbt, .eu, .nonEU, .highlySkilledMigrant],
                priority: 1
            ),
            HomeCategoryItem(
                id: "documents",
                titleRU: "Документы и услуги",
                titleNL: "Documenten en diensten",
                titleEN: "Documents & services",
                icon: "doc.text.fill",
                gradient: AppColors.gradDocs,
                destination: .journeyDocuments,
                audienceTags: [.student, .worker, .refugee, .family, .entrepreneur, .lgbt, .eu, .nonEU, .highlySkilledMigrant],
                priority: 2
            ),
            HomeCategoryItem(
                id: "lost_documents",
                titleRU: "Потерянные документы",
                titleNL: "Verloren documenten",
                titleEN: "Lost documents",
                icon: "doc.badge.exclamationmark.fill",
                gradient: AppColors.gradDocs,
                destination: .guideArticle(sectionID: "tourist-documents", articleID: "lost-documents"),
                audienceTags: [.tourist, .universal],
                priority: 1
            ),
            HomeCategoryItem(
                id: "transport",
                titleRU: "Транспорт",
                titleNL: "Vervoer",
                titleEN: "Transport",
                icon: "tram.fill",
                gradient: AppColors.gradTransport,
                destination: .practicalGuide(.transportBasics),
                audienceTags: [.tourist, .student, .worker, .refugee, .family, .entrepreneur, .lgbt, .eu, .nonEU, .highlySkilledMigrant, .universal],
                priority: 1
            ),
            HomeCategoryItem(
                id: "work_taxes",
                titleRU: "Работа и налоги",
                titleNL: "Werk & belasting",
                titleEN: "Work & taxes",
                icon: "briefcase.fill",
                gradient: AppColors.gradWork,
                destination: .workSection(.salaryTaxes),
                audienceTags: [.worker, .student, .entrepreneur, .eu, .nonEU, .highlySkilledMigrant],
                priority: 2
            ),
            HomeCategoryItem(
                id: "housing",
                titleRU: "Жильё",
                titleNL: "Wonen",
                titleEN: "Housing",
                icon: "house.fill",
                gradient: AppColors.gradHousing,
                destination: .practicalGuide(.housingBasics),
                audienceTags: [.student, .worker, .refugee, .family, .lgbt, .eu, .nonEU, .highlySkilledMigrant],
                priority: 2
            ),
            HomeCategoryItem(
                id: "healthcare",
                titleRU: "Здоровье",
                titleNL: "Gezondheid",
                titleEN: "Healthcare",
                icon: "cross.case.fill",
                gradient: AppColors.gradHealth,
                destination: .practicalGuide(.healthcareBasics),
                audienceTags: [.tourist, .student, .worker, .refugee, .family, .entrepreneur, .lgbt, .eu, .nonEU, .highlySkilledMigrant, .universal],
                priority: 2
            ),
            HomeCategoryItem(
                id: "government",
                titleRU: "Правительство",
                titleNL: "Overheid",
                titleEN: "Government",
                icon: "building.columns.fill",
                gradient: AppColors.gradGovernment,
                destination: .governmentHub,
                audienceTags: [.student, .worker, .refugee, .family, .entrepreneur, .lgbt, .eu, .nonEU, .highlySkilledMigrant],
                priority: 3
            ),
            HomeCategoryItem(
                id: "education",
                titleRU: "Образование",
                titleNL: "Onderwijs",
                titleEN: "Education",
                icon: "graduationcap.fill",
                gradient: AppColors.gradEducation,
                destination: .institutionsList,
                audienceTags: [.student, .refugee, .family],
                priority: 3
            ),
            HomeCategoryItem(
                id: "help_nearby",
                titleRU: "Помощь рядом",
                titleNL: "Hulp dichtbij",
                titleEN: "Help nearby",
                icon: "map.fill",
                gradient: AppColors.gradProvince,
                destination: .mapHub,
                audienceTags: [.tourist, .student, .worker, .refugee, .family, .entrepreneur, .lgbt, .eu, .nonEU, .highlySkilledMigrant, .universal],
                priority: 3
            ),
            HomeCategoryItem(
                id: "emergency_112",
                titleRU: "Экстренно 112",
                titleNL: "Nood 112",
                titleEN: "Emergency 112",
                icon: "phone.fill",
                gradient: AppColors.gradEmergency,
                destination: .emergencyHub,
                audienceTags: [.tourist, .student, .worker, .refugee, .family, .entrepreneur, .lgbt, .eu, .nonEU, .highlySkilledMigrant, .universal],
                priority: 1
            ),
            HomeCategoryItem(
                id: "places",
                titleRU: "Места",
                titleNL: "Plekken",
                titleEN: "Places",
                icon: "mappin.circle.fill",
                gradient: AppColors.gradProvince,
                destination: .mapFocus(.city(selectedCityName)),
                audienceTags: [.tourist, .universal],
                priority: 2
            ),
            HomeCategoryItem(
                id: "museums",
                titleRU: "Музеи",
                titleNL: "Musea",
                titleEN: "Museums",
                icon: "building.columns.fill",
                gradient: AppColors.gradEducation,
                destination: .cultureAttractions,
                audienceTags: [.tourist, .universal],
                priority: 2
            ),
            HomeCategoryItem(
                id: "cycling",
                titleRU: "Велосипед",
                titleNL: "Fietsen",
                titleEN: "Cycling",
                icon: "bicycle",
                gradient: AppColors.gradTransport,
                destination: .finesAndLettersHub,
                audienceTags: [.tourist, .universal],
                priority: 2
            ),
            HomeCategoryItem(
                id: "food_events",
                titleRU: "Еда и события",
                titleNL: "Eten & events",
                titleEN: "Food / events",
                icon: "fork.knife",
                gradient: AppColors.gradTransport,
                destination: .mapFocus(.city(selectedCityName)),
                audienceTags: [.tourist, .universal],
                priority: 2
            )
        ]
    }
}

extension HomeCategoryItem: AudienceTaggedContent {}

extension HomeQuickAction: DashboardRenderableCard {
    var dashboardTitle: String { titleEN }
    var dashboardRouteID: String? { AppNavigationResolver.routeID(from: destination) }
    var dashboardActionID: String? { nil }
    var dashboardURL: URL? { nil }
    var dashboardAudienceTags: Set<PersonaTag> { audienceTags }
    var dashboardCityID: String? { nil }
    var dashboardHidden: Bool { hidden }
    var dashboardDraft: Bool { draft }
    var dashboardPriority: Int { priority }
}

extension HomeHelpTopic: DashboardRenderableCard {
    var dashboardTitle: String { titleEN }
    var dashboardRouteID: String? { AppNavigationResolver.routeID(from: destination) }
    var dashboardActionID: String? { nil }
    var dashboardURL: URL? { nil }
    var dashboardAudienceTags: Set<PersonaTag> { audienceTags }
    var dashboardCityID: String? { nil }
    var dashboardHidden: Bool { hidden }
    var dashboardDraft: Bool { draft }
    var dashboardPriority: Int { priority }
}

extension HomeSecondaryTool: DashboardRenderableCard {
    var dashboardTitle: String { title }
    var dashboardRouteID: String? { nil }
    var dashboardActionID: String? { "tab.\(id)" }
    var dashboardURL: URL? { nil }
    var dashboardAudienceTags: Set<PersonaTag> { audienceTags }
    var dashboardCityID: String? { nil }
    var dashboardHidden: Bool { false }
    var dashboardDraft: Bool { false }
    var dashboardPriority: Int { priority }
}

extension HomeCategoryItem: DashboardRenderableCard {
    var dashboardTitle: String { titleEN }
    var dashboardRouteID: String? { AppNavigationResolver.routeID(from: destination) }
    var dashboardActionID: String? { nil }
    var dashboardURL: URL? { nil }
    var dashboardAudienceTags: Set<PersonaTag> { audienceTags }
    var dashboardCityID: String? { nil }
    var dashboardHidden: Bool { false }
    var dashboardDraft: Bool { false }
    var dashboardPriority: Int { priority }
}

struct HomePersonaDashboard {
    let quickActions: [HomeQuickAction]
    let helpTopics: [HomeHelpTopic]
    let journeys: [HomePersonaJourney]
    let categories: [HomeCategoryItem]
}

enum HomeEditorialContentCatalog {
    static var historyCultureCards: [HistoryCultureItem] {
        [
            HistoryCultureItem(
                id: "golden_age",
                titleRU: "Золотой Век", titleNL: "Gouden Eeuw", titleEN: "Dutch Golden Age",
                subtitleRU: "XVII век: торговля, искусство и наука", subtitleNL: "17e eeuw: handel, kunst en wetenschap", subtitleEN: "17th century: trade, art & science",
                icon: "crown.fill", accent: AppColors.dutchOrange, destination: .netherlandsHistory
            ),
            HistoryCultureItem(
                id: "traditions",
                titleRU: "Традиции", titleNL: "Tradities", titleEN: "Traditions",
                subtitleRU: "Праздники, обычаи и символы", subtitleNL: "Feesten, gebruiken en symbolen", subtitleEN: "Holidays, customs & symbols",
                icon: "party.popper.fill", accent: AppColors.violet, destination: .dutchHolidays
            ),
            HistoryCultureItem(
                id: "monarchy",
                titleRU: "Монархия", titleNL: "Monarchie", titleEN: "Monarchy",
                subtitleRU: "Королевский дом Нидерландов", subtitleNL: "Het Nederlandse koningshuis", subtitleEN: "The Dutch Royal House",
                icon: "building.columns.fill", accent: AppColors.softBlue, destination: .knm
            ),
            HistoryCultureItem(
                id: "wwii",
                titleRU: "Вторая мировая", titleNL: "Tweede Wereldoorlog", titleEN: "World War II",
                subtitleRU: "Оккупация и освобождение", subtitleNL: "Bezetting en bevrijding", subtitleEN: "Occupation and liberation",
                icon: "shield.fill", accent: AppColors.error, destination: .netherlandsHistory
            )
        ]
    }

    static var newsItems: [HomeNewsItem] {
        [
            HomeNewsItem(
                id: "bsn_update",
                titleRU: "Изменения в процедуре BSN", titleNL: "Wijzigingen BSN-procedure", titleEN: "BSN procedure updates",
                subtitleRU: "Новые требования для регистрации", subtitleNL: "Nieuwe vereisten voor inschrijving", subtitleEN: "New requirements for registration",
                icon: "person.text.rectangle.fill", accent: AppColors.cyanGlow
            ),
            HomeNewsItem(
                id: "integration",
                titleRU: "Гид по интеграции", titleNL: "Integratiegids", titleEN: "Integration guide",
                subtitleRU: "Полный путь от прибытия до гражданства", subtitleNL: "Volledig traject van aankomst tot burgerschap", subtitleEN: "Full path from arrival to citizenship",
                icon: "figure.2.arms.open", accent: AppColors.emerald
            ),
            HomeNewsItem(
                id: "housing",
                titleRU: "Советы по жилью", titleNL: "Huisvestingstips", titleEN: "Housing tips",
                subtitleRU: "Как найти жильё в Нидерландах", subtitleNL: "Hoe woonruimte te vinden in Nederland", subtitleEN: "How to find housing in the Netherlands",
                icon: "house.fill", accent: AppColors.softBlue
            )
        ]
    }
}

struct HistoryCultureItem: Identifiable {
    let id: String
    let titleRU: String
    let titleNL: String
    let titleEN: String
    let subtitleRU: String
    let subtitleNL: String
    let subtitleEN: String
    let icon: String
    let accent: Color
    let destination: AppDestination

    func title(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return titleRU
        case .dutch: return titleNL
        case .english: return titleEN
        }
    }

    func subtitle(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return subtitleRU
        case .dutch: return subtitleNL
        case .english: return subtitleEN
        }
    }
}

struct HomeNewsItem: Identifiable {
    let id: String
    let titleRU: String
    let titleNL: String
    let titleEN: String
    let subtitleRU: String
    let subtitleNL: String
    let subtitleEN: String
    let icon: String
    let accent: Color

    func title(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return titleRU
        case .dutch: return titleNL
        case .english: return titleEN
        }
    }

    func subtitle(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return subtitleRU
        case .dutch: return subtitleNL
        case .english: return subtitleEN
        }
    }
}

struct HomeChecklistSnapshot {
    let completedCount: Int
    let totalCount: Int
    let progress: Double
    let nextItem: ChecklistItem?

    init(visibleItems: [ChecklistItem], recommendedItems: [ChecklistItem]) {
        completedCount = visibleItems.reduce(into: 0) { count, item in
            if item.isCompleted {
                count += 1
            }
        }
        totalCount = visibleItems.count
        progress = totalCount > 0 ? min(1, max(0, Double(completedCount) / Double(totalCount))) : 0
        nextItem = recommendedItems.first { !$0.isCompleted } ?? visibleItems.first { !$0.isCompleted }
    }
}

struct HomeContextualRecommendationsSnapshot {
    let contextual: [HomeCityGuideActionItem]

    init(actions: [HomeCityGuideActionItem]) {
        contextual = Array(actions.lazy.filter { $0.id != "release-ai" }.prefix(3))
    }
}

enum HomeLocalizedSuggestions {
    static func journeyMilestoneTitles(language: AppLanguage, isTouristMode: Bool) -> [String] {
        if isTouristMode {
            switch language {
            case .russian: return ["Приезд", "Транспорт", "Правила", "Помощь", "Места"]
            case .dutch: return ["Aankomst", "Vervoer", "Regels", "Hulp", "Plekken"]
            case .english: return ["Arrival", "Transport", "Rules", "Help", "Places"]
            }
        }

        switch language {
        case .russian: return ["Приезд", "Адрес", "BSN", "DigiD", "Врач", "Язык", "Жильё", "Работа"]
        case .dutch: return ["Aankomst", "Adres", "BSN", "DigiD", "Zorg", "Taal", "Wonen", "Werk"]
        case .english: return ["Arrival", "Address", "BSN", "DigiD", "Health", "Language", "Housing", "Work"]
        }
    }

    static func defaultBookmarks(language: AppLanguage, isTouristMode: Bool) -> [String] {
        if isTouristMode {
            switch language {
            case .russian: return ["112", "Транспорт", "Потерянные документы"]
            case .dutch: return ["112", "Vervoer", "Verloren documenten"]
            case .english: return ["112", "Transport", "Lost documents"]
            }
        }

        switch language {
        case .russian: return ["BSN", "DigiD", "Huisarts"]
        case .dutch: return ["BSN", "DigiD", "Huisarts"]
        case .english: return ["BSN", "DigiD", "GP"]
        }
    }

    static func aiQuestionExamples(language: AppLanguage, isTouristMode: Bool, cityName: String) -> [String] {
        if isTouristMode {
            switch language {
            case .russian: return ["Что делать, если потерян паспорт?", "Как пользоваться OV?", "Какие штрафы туристу важно знать?", "Куда пойти в \(cityName)?"]
            case .dutch: return ["Wat als ik mijn paspoort kwijt ben?", "Hoe gebruik ik OV?", "Welke boetes zijn belangrijk voor toeristen?", "Waar ga ik heen in \(cityName)?"]
            case .english: return ["What if I lost my passport?", "How do I use OV?", "Which fines should tourists know?", "Where should I go in \(cityName)?"]
            }
        }

        switch language {
        case .russian: return ["Как получить BSN?", "Как найти huisarts?", "Как зарегистрировать адрес?", "Что делать после приезда?"]
        case .dutch: return ["Hoe krijg ik BSN?", "Hoe vind ik een huisarts?", "Hoe registreer ik mijn adres?", "Wat doe ik na aankomst?"]
        case .english: return ["How do I get BSN?", "How do I find a GP?", "How do I register my address?", "What should I do after arrival?"]
        }
    }
}

struct HomeCityGuideActionItem: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let symbol: String
    let tint: Color
    let url: URL?
    let destination: AppDestination?
    let provider: String?
    let cta: String?
    let externalLink: DashboardExternalLink?
}
