import Foundation

enum LGBTQSupportSection: String, CaseIterable, Identifiable {
    case community
    case places
    case wellbeing
    case legalSafety
    case events

    var id: String { rawValue }

    func title(_ lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.community, .russian): return "Сообщество и поддержка"
        case (.community, .dutch): return "Community & ondersteuning"
        case (.community, .english): return "Community & Support"
        case (.places, .russian): return "Безопасные места встреч"
        case (.places, .dutch): return "Veilige ontmoetingsplekken"
        case (.places, .english): return "Safe Meeting Places"
        case (.wellbeing, .russian): return "Психическое здоровье и благополучие"
        case (.wellbeing, .dutch): return "Mentale gezondheid & welzijn"
        case (.wellbeing, .english): return "Mental Health & Wellbeing"
        case (.legalSafety, .russian): return "Право и безопасность"
        case (.legalSafety, .dutch): return "Recht & veiligheid"
        case (.legalSafety, .english): return "Legal & Safety"
        case (.events, .russian): return "Мероприятия и общение"
        case (.events, .dutch): return "Events & sociaal"
        case (.events, .english): return "Events & Social"
        }
    }

    var symbol: String {
        switch self {
        case .community: return "person.2.fill"
        case .places: return "mappin.and.ellipse"
        case .wellbeing: return "heart.text.square.fill"
        case .legalSafety: return "shield.lefthalf.filled"
        case .events: return "calendar"
        }
    }
}

enum LGBTQSupportCategory: String, CaseIterable, Identifiable {
    case communityCenter
    case newcomerSupport
    case expatCommunity
    case studentSupport
    case volunteerHelp
    case onlineCommunity
    case cafe
    case coworking
    case communityHub
    case culturalSpace
    case event
    case helpline
    case counseling
    case crisis
    case antiDiscrimination
    case legalInfo
    case healthcareInfo

    var id: String { rawValue }

    func title(_ lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.communityCenter, .russian): return "Общественный центр"
        case (.communityCenter, .dutch): return "Communitycentrum"
        case (.communityCenter, .english): return "Community center"
        case (.newcomerSupport, .russian): return "Поддержка новоприбывших"
        case (.newcomerSupport, .dutch): return "Nieuwkomers"
        case (.newcomerSupport, .english): return "Newcomer support"
        case (.expatCommunity, .russian): return "Сообщество экспатов"
        case (.expatCommunity, .dutch): return "Expatcommunity"
        case (.expatCommunity, .english): return "Expat community"
        case (.studentSupport, .russian): return "Поддержка студентов"
        case (.studentSupport, .dutch): return "Studenten"
        case (.studentSupport, .english): return "Student support"
        case (.volunteerHelp, .russian): return "Волонтёрская помощь"
        case (.volunteerHelp, .dutch): return "Vrijwilligershulp"
        case (.volunteerHelp, .english): return "Volunteer help"
        case (.onlineCommunity, .russian): return "Онлайн-сообщество"
        case (.onlineCommunity, .dutch): return "Online community"
        case (.onlineCommunity, .english): return "Online community"
        case (.cafe, .russian): return "Кафе"
        case (.cafe, .dutch): return "Cafe"
        case (.cafe, .english): return "Cafe"
        case (.coworking, .russian): return "Коворкинг"
        case (.coworking, .dutch): return "Coworking"
        case (.coworking, .english): return "Coworking"
        case (.communityHub, .russian): return "Центр сообщества"
        case (.communityHub, .dutch): return "Communityhub"
        case (.communityHub, .english): return "Community hub"
        case (.culturalSpace, .russian): return "Культурное пространство"
        case (.culturalSpace, .dutch): return "Culturele plek"
        case (.culturalSpace, .english): return "Cultural space"
        case (.event, .russian): return "Мероприятие"
        case (.event, .dutch): return "Event"
        case (.event, .english): return "Event"
        case (.helpline, .russian): return "Горячая линия"
        case (.helpline, .dutch): return "Hulplijn"
        case (.helpline, .english): return "Helpline"
        case (.counseling, .russian): return "Консультирование"
        case (.counseling, .dutch): return "Begeleiding"
        case (.counseling, .english): return "Counseling"
        case (.crisis, .russian): return "Кризисная помощь"
        case (.crisis, .dutch): return "Crisishulp"
        case (.crisis, .english): return "Crisis help"
        case (.antiDiscrimination, .russian): return "Борьба с дискриминацией"
        case (.antiDiscrimination, .dutch): return "Discriminatie melden"
        case (.antiDiscrimination, .english): return "Anti-discrimination"
        case (.legalInfo, .russian): return "Юридическая информация"
        case (.legalInfo, .dutch): return "Juridische informatie"
        case (.legalInfo, .english): return "Legal information"
        case (.healthcareInfo, .russian): return "Информация о здравоохранении"
        case (.healthcareInfo, .dutch): return "Zorginformatie"
        case (.healthcareInfo, .english): return "Healthcare information"
        }
    }
}

struct LGBTQSupportItem: Identifiable, Hashable {
    let id: String
    let section: LGBTQSupportSection
    let category: LGBTQSupportCategory
    let title: String
    let descriptionEN: String
    let descriptionNL: String
    let city: String
    let websiteURL: URL?
    let mapsQuery: String?
    let isTrusted: Bool
    let accessibilityTags: [String]
    let publicTransportInfoEN: String?
    let publicTransportInfoNL: String?
    let openingHoursEN: String?
    let openingHoursNL: String?
    let organizer: String?
    let dateTextEN: String?
    let dateTextNL: String?
    let imageURL: URL?
    let keywords: [String]

    func description(_ lang: AppLanguage) -> String {
        lang == .dutch ? descriptionNL : descriptionEN
    }

    func publicTransportInfo(_ lang: AppLanguage) -> String? {
        lang == .dutch ? publicTransportInfoNL : publicTransportInfoEN
    }

    func openingHours(_ lang: AppLanguage) -> String? {
        lang == .dutch ? openingHoursNL : openingHoursEN
    }

    func dateText(_ lang: AppLanguage) -> String? {
        lang == .dutch ? dateTextNL : dateTextEN
    }

    var saveKey: String { "lgbtq::\(id)" }

    var personaTags: Set<PersonaTag> { [.lgbt] }

    func isVisible(for persona: PersonaTag?, scope: PersonaSearchScope = .currentAndUniversal) -> Bool {
        PersonaContentPolicy.isVisible(tags: personaTags, activePersona: persona, scope: scope)
    }

    var searchableText: String {
        ([title, descriptionEN, descriptionNL, city, category.rawValue, section.rawValue] + keywords)
            .joined(separator: " ")
            .lowercased()
    }
}
