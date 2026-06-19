import Foundation

struct ReminderItem: Identifiable {
    enum Category: String {
        case insurance = "Insurance"
        case municipalityRegistration = "Municipality Registration"
        case documentRenewal = "Document Renewal"
        case appointmentPreparation = "Appointment Preparation"
        case taxDeadline = "Tax Deadline"
        case housing = "Housing"
    }

    enum Urgency: String {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
    }

    let title: String
    let detail: String
    let category: Category
    let urgency: Urgency
    let date: Date?
    let localOnly: Bool
    var id: UUID { StableRouteID.uuid("expansion.reminder.\(category.rawValue).\(title)") }
    var personaTags: Set<PersonaTag> {
        switch category {
        case .insurance:
            return [.student, .worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        case .municipalityRegistration, .appointmentPreparation, .documentRenewal:
            return [.worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        case .taxDeadline:
            return [.worker, .family, .eu, .highlySkilledMigrant, .entrepreneur]
        case .housing:
            return [.student, .worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant, .lgbt]
        }
    }

    func isVisible(for persona: PersonaTag?, scope: PersonaSearchScope = .currentAndUniversal) -> Bool {
        PersonaContentPolicy.isVisible(tags: personaTags, activePersona: persona, scope: scope)
    }
}

struct SurvivalGuideItem: Identifiable {
    let title: String
    let shortText: String
    let detailText: String
    var id: UUID { StableRouteID.uuid("expansion.survival.\(title)") }
    var personaTags: Set<PersonaTag> {
        PersonaContentPolicy.assignedTags(
            category: "Survival",
            title: title,
            summary: "\(shortText) \(detailText)",
            keywords: [title, shortText, detailText],
            sources: []
        )
    }

    func isVisible(for persona: PersonaTag?, scope: PersonaSearchScope = .currentAndUniversal) -> Bool {
        PersonaContentPolicy.isVisible(tags: personaTags, activePersona: persona, scope: scope)
    }
}

struct DocumentReferenceItem: Identifiable {
    let title: String
    let category: String
    let tags: [String]
    let note: String
    let linkedReminderTitle: String?
    var id: UUID { StableRouteID.uuid("expansion.document.\(category).\(title)") }
    var personaTags: Set<PersonaTag> {
        PersonaContentPolicy.assignedTags(category: category, title: title, summary: note, keywords: tags, sources: [])
    }

    func isVisible(for persona: PersonaTag?, scope: PersonaSearchScope = .currentAndUniversal) -> Bool {
        PersonaContentPolicy.isVisible(tags: personaTags, activePersona: persona, scope: scope)
    }
}

struct MunicipalityProfile: Identifiable {
    let name: String
    let website: URL
    let appointmentPage: URL
    let registrationInfo: String
    let wasteGuide: String
    let parkingBasics: String
    let emergencyContact: String
    var id: UUID { StableRouteID.uuid("expansion.municipality.\(name)") }
}

struct KnowledgeTopic: Identifiable {
    let category: String
    let title: String
    let summary: String
    let beginnerExplanation: String
    let practicalSteps: [String]
    let commonMistakes: [String]
    let officialSourceName: String
    let officialSourceURL: URL
    let relatedLinks: [URL]
    let relatedQuestions: [String]
    let tags: [String]
    let lastReviewed: Date
    let updateStatus: String
    let safetyDisclaimer: String
    var id: UUID { StableRouteID.uuid("expansion.knowledge.\(category).\(title)") }
    var personaTags: Set<PersonaTag> {
        PersonaContentPolicy.assignedTags(
            category: category,
            title: title,
            summary: "\(summary) \(beginnerExplanation)",
            keywords: tags + practicalSteps + commonMistakes + relatedQuestions,
            sources: [OfficialSource(title: officialSourceName, url: officialSourceURL, institution: officialSourceName)]
        )
    }

    func isVisible(for persona: PersonaTag?, scope: PersonaSearchScope = .currentAndUniversal) -> Bool {
        PersonaContentPolicy.isVisible(tags: personaTags, activePersona: persona, scope: scope)
    }
}

struct LifeScenario: Identifiable {
    let title: String
    let situation: String
    let firstActions: [String]
    let documentsToPrepare: [String]
    let officialSourceName: String
    let officialSourceURL: URL
    let relatedTopics: [String]
    var id: UUID { StableRouteID.uuid("expansion.scenario.\(title)") }
    var personaTags: Set<PersonaTag> {
        PersonaContentPolicy.assignedTags(
            category: "Workflow",
            title: title,
            summary: situation,
            keywords: firstActions + documentsToPrepare + relatedTopics,
            sources: [OfficialSource(title: officialSourceName, url: officialSourceURL, institution: officialSourceName)]
        )
    }

    func isVisible(for persona: PersonaTag?, scope: PersonaSearchScope = .currentAndUniversal) -> Bool {
        PersonaContentPolicy.isVisible(tags: personaTags, activePersona: persona, scope: scope)
    }
}

struct OfficialServiceDirectoryItem: Identifiable {
    let name: String
    let domain: String
    let purpose: String
    let whenToUse: String
    let officialURL: URL
    let tags: [String]
    var id: UUID { StableRouteID.uuid("expansion.service.\(domain).\(name)") }
    var personaTags: Set<PersonaTag> {
        PersonaContentPolicy.assignedTags(
            category: "Official Service",
            title: name,
            summary: "\(purpose) \(whenToUse)",
            keywords: tags + [domain, purpose, whenToUse],
            sources: [OfficialSource(title: name, url: officialURL, institution: name)]
        )
    }

    func isVisible(for persona: PersonaTag?, scope: PersonaSearchScope = .currentAndUniversal) -> Bool {
        PersonaContentPolicy.isVisible(tags: personaTags, activePersona: persona, scope: scope)
    }
}

struct ProvinceProfile: Identifiable {
    let name: String
    let capital: String
    let population: String
    let majorCities: [String]
    let rentContext: String
    let transportContext: String
    let workContext: String
    let universityContext: String
    let expatFriendliness: String
    let officialWebsite: URL
    let emergencyContacts: [String]
    let municipalityLinks: [URL]
    var id: UUID { StableRouteID.uuid("expansion.province.\(name)") }
}

struct CityProfile: Identifiable {
    let name: String
    var localizedName: [AppLanguage: String] = [:]
    let province: String
    var provinceId: String = ""
    var municipalityName: String = ""
    var population: String = ""
    var areaKm2: String = ""
    var officialWebsite: String = ""
    var mapQuery: String = ""
    var shortSummary: [AppLanguage: String] = [:]
    var shortHistory: [AppLanguage: String] = [:]
    var localIdentity: [AppLanguage: String] = [:]
    let newcomerSummary: String
    var firstWeekSteps: [CityNewcomerGuideItem] = []
    var newcomerPlaces: [NewcomerPlace] = []
    var officialServices: [NewcomerPlace] = []
    var languageAndIntegration: [NewcomerPlace] = []
    var healthcareAccess: [NewcomerPlace] = []
    var legalAndRightsHelp: [NewcomerPlace] = []
    var transportHubs: [NewcomerPlace] = []
    var communityAndLibraries: [NewcomerPlace] = []
    var emergencyAndSafety: [NewcomerPlace] = []
    var familyAndChildren: [NewcomerPlace] = []
    var lgbtqSupport: [NewcomerPlace] = []
    var documentAndAdminHelp: [NewcomerPlace] = []
    var housingSupport: [NewcomerPlace] = []
    var workAndUWVInfo: [NewcomerPlace] = []
    let housingContext: String
    let transportContext: String
    let workStudyContext: String
    let municipalityURL: URL
    let expatNotes: String
    var officialSourceLinks: [CitySourceLink] = []
    var relatedCategories: [String] = []
    var heroImageName: String? = nil
    var flagImageName: String? = nil
    var coatOfArmsImageName: String? = nil
    var imageCredit: [AppLanguage: String] = [:]
    var heroImageAssetName: String = ""
    var flagAssetName: String = ""
    var coatOfArmsAssetName: String = ""
    let tags: [String]
    var id: UUID { StableRouteID.uuid("expansion.city.\(province).\(name)") }
}

struct NewcomerRoadmapWeek: Identifiable {
    let title: String
    let focus: String
    let steps: [String]
    let officialSourceNames: [String]
    var id: UUID { StableRouteID.uuid("expansion.roadmap.\(title).\(focus)") }
}

struct SearchResultItem: Identifiable {
    let category: String
    let title: String
    let subtitle: String
    var id: UUID { StableRouteID.uuid("expansion.search-result.\(category).\(title)") }
}

struct TrustMetadata {
    let sourceUpdatedAt: String
    let sourceLabel: String
    let updateIndicator: String
}

enum PremiumPlaceholderFeature: String, CaseIterable {
    case advancedTranslation = "Advanced translation"
    case unlimitedSavedLetters = "Unlimited saved letters"
    case advancedOnboardingFlows = "Advanced onboarding flows"
    case municipalityPacks = "Municipality packs"
    case offlinePacks = "Offline packs"
}

enum AnalyticsPlaceholderEvent: String {
    case onboardingStepViewed
    case resourceOpened
    case searchPerformed
    case reminderCreated
}
