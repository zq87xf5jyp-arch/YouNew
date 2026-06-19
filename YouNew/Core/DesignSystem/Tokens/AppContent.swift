import Foundation

// MARK: - Disclaimers

enum AppDisclaimers {
    static func short(_ lang: AppLanguage = .english) -> String {
        L10n.t("disclaimer.short", lang)
    }
    static func medium(_ lang: AppLanguage = .english) -> String {
        L10n.t("disclaimer.medium", lang)
    }
    static func expanded(_ lang: AppLanguage = .english) -> String {
        L10n.t("disclaimer.expanded", lang)
    }
    static let short    = L10n.t("disclaimer.short", .english)
    static let medium   = L10n.t("disclaimer.medium", .english)
    static let expanded = L10n.t("disclaimer.expanded", .english)
}

// MARK: - Empty States

enum AppEmptyStates {
    static func noReminders(_ lang: AppLanguage = .english) -> String {
        L10n.t("empty.no_reminders", lang)
    }
    static func checklistComplete(_ lang: AppLanguage = .english) -> String {
        L10n.t("empty.checklist_complete", lang)
    }
    static func noLetterSummaries(_ lang: AppLanguage = .english) -> String {
        L10n.t("empty.no_letter_summaries", lang)
    }
    static func resourcesUnavailable(_ lang: AppLanguage = .english) -> String {
        L10n.t("empty.resources_unavailable", lang)
    }
    static func noSearchResults(_ lang: AppLanguage = .english) -> String {
        L10n.t("empty.no_results", lang)
    }
    static func noNearbyPlaces(_ lang: AppLanguage = .english) -> String {
        L10n.t("empty.no_nearby_places", lang)
    }
    static func noSavedItems(_ lang: AppLanguage = .english) -> String {
        L10n.t("empty.no_saved_items", lang)
    }
    static let noReminders         = L10n.t("empty.no_reminders", .english)
    static let checklistComplete   = L10n.t("empty.checklist_complete", .english)
    static let noLetterSummaries   = L10n.t("empty.no_letter_summaries", .english)
    static let resourcesUnavailable = L10n.t("empty.resources_unavailable", .english)
    static let noSearchResults     = L10n.t("empty.no_results", .english)
    static let noNearbyPlaces      = L10n.t("empty.no_nearby_places", .english)
    static let noSavedItems        = L10n.t("empty.no_saved_items", .english)

    static let noRemindersDetail        = "Add reminders to track important steps."
    static let checklistCompleteDetail  = "You have completed all adaptation steps. Great work."
    static let noSavedItemsDetail       = "Save guides, letters, and institutions so you can return quickly."
    static let noSearchResultsDetail    = "Try another query or open official sources."
    static let noNearbyPlacesDetail     = "Allow location access to find help nearby."
    static let noLetterSummariesDetail  = "Saved letter explanations will appear here."
}

// MARK: - Microcopy

enum AppMicrocopy {
    static func possibleNextStep(_ lang: AppLanguage = .english) -> String {
        L10n.t("common.possible_next_step", lang)
    }
    static func learnMore(_ lang: AppLanguage = .english) -> String {
        L10n.t("common.learn_more", lang)
    }
    static func officialInfo(_ lang: AppLanguage = .english) -> String {
        L10n.t("common.official_info", lang)
    }
    static func open(_ lang: AppLanguage = .english) -> String {
        L10n.t("common.open", lang)
    }
    static func verifiedSource(_ lang: AppLanguage = .english) -> String {
        L10n.t("common.verified_source", lang)
    }
    static func continueOnboarding(_ lang: AppLanguage = .english) -> String {
        L10n.t("common.continue_onboarding", lang)
    }
    static let continueOnboarding    = L10n.t("common.continue_onboarding", .english)
    static let viewOfficialResource  = L10n.t("resource.open_source", .english)
    static let learnMore             = L10n.t("common.learn_more", .english)
    static let checkRequirements     = "Check requirements"
    static let possibleNextStep      = L10n.t("common.possible_next_step", .english)
    static let verifiedSource        = L10n.t("common.verified_source", .english)
    static let officialInfo          = L10n.t("common.official_info", .english)
    static let guideOnly             = "Guide only"
    static let lastVerified          = "Last verified"
    static let educationalContent    = "Educational material"
    static let reviewPeriodically    = "Review periodically"
}

// MARK: - App Store Marketing

enum AppStoreMarketing {
    static let appName    = "YouNew"
    static let tagline    = "Your private Netherlands manual."
    static let subTagline = "Dutch life, made readable."

    static let screenshot1Title = "The Netherlands\nmakes sense here."
    static let screenshot2Title = "Official sources,\nplain meaning."
    static let screenshot3Title = "Your personal\nclarity map."
    static let screenshot4Title = "Understand Dutch\nlife admin."
    static let screenshot5Title = "Avoid mistakes\nbefore they matter."
    static let screenshot6Title = "Know where\nto verify."
    static let screenshot7Title = "Ask about\nreal situations."
    static let screenshot8Title = "Save what\nyou'll need again."

    static let screenshot1Sub = "A private manual for building life in the Netherlands."
    static let screenshot2Sub = "Simple explanations with official links close by."
    static let screenshot3Sub = "See what matters for your stage, city, and documents."
    static let screenshot4Sub = "DigiD, BSN, gemeente, healthcare, housing, and taxes."
    static let screenshot5Sub = "Spot deadlines, documents, and risks newcomers often miss."
    static let screenshot6Sub = "Open the source when the decision is important."
    static let screenshot7Sub = "Get calm context without turning the app into a chatbot."
    static let screenshot8Sub = "Keep useful answers in your own Netherlands manual."

    static let shortDescription = "Your private Netherlands manual. Understand Dutch life admin, documents, rules, and everyday decisions with calm, source-aware guidance."

    static let feature1 = "Onboarding checklist tailored to your profile"
    static let feature2 = "Official institution directory with contact details"
    static let feature3 = "Letter and fine explainer in plain language"
    static let feature4 = "Plain-language explanations for real-life questions"
    static let feature5 = "Nearby help map for local support points"
    static let feature6 = "Newcomer mistake library to stay ahead"
    static let feature7 = "Official-source-first information throughout"
    static let feature8 = "Privacy-first: no unnecessary data collected"

    static let heroHeadline    = "Your private manual\nfor life in the Netherlands."
    static let heroSubheadline = "Understand Dutch systems before small confusion becomes a real problem."
    static let heroCallToAction = "Download on the App Store"
}

// MARK: - Icon Concept Guide

enum AppIconConcepts {
    static let concept1Name = "Navigation Route"
    static let concept1Description = """
    A single clean route arc from bottom-left to top-right on a deep navy-to-teal gradient. \
    Dutch amber origin dot. White destination arrowhead. \
    Symbolizes: your personal onboarding journey. \
    Feeling: calm forward momentum — 'you are on your way.' \
    App Store strength: strong contrast, readable at 60pt, premium silhouette.
    """

    static let concept2Name = "Modern Compass"
    static let concept2Description = """
    A minimal geometric compass — four cardinal arms, two in clean white, two in muted teal, \
    north arm in Dutch amber — on a navy radial gradient. \
    Symbolizes: precision navigation, structured guidance. \
    Feeling: professional, trustworthy, precise. \
    App Store strength: iconic silhouette, instantly scalable.
    """

    static let concept3Name = "Canal Geometry"
    static let concept3Description = """
    Abstract bird's-eye Amsterdam canal: three horizontal teal bands (water) separated by \
    narrow navy bands (land), crossed by a single arc bridge. Midnight navy background. \
    Symbolizes: Dutch identity without clichés, calm crossing, architectural structure. \
    Feeling: deeply original, architectural calm, unmistakably Dutch. \
    App Store strength: highly distinctive, deeply memorable.
    """

    static let concept4Name = "Connected Pathway"
    static let concept4Description = """
    Three to four soft nodes connected by smooth curves. Primary path in teal glow; \
    branches in soft blue; destination node in Dutch amber. Deep navy background with depth. \
    Symbolizes: guided journey, options, connection, progress. \
    Feeling: modern startup quality, forward-thinking. \
    App Store strength: contemporary tech aesthetic, premium depth, excellent at all sizes.
    """
}
