import Foundation

enum UserContentCategory: String, CaseIterable, Codable, Hashable, Identifiable {
    case tourist
    case local
    case student
    case business
    case admin
    case general

    var id: String { rawValue }

    nonisolated var personaTags: Set<PersonaTag> {
        switch self {
        case .tourist:
            return [.tourist]
        case .local:
            return [.worker, .refugee, .family, .lgbt, .eu, .nonEU, .highlySkilledMigrant]
        case .student:
            return [.student]
        case .business:
            return [.entrepreneur]
        case .admin:
            return []
        case .general:
            return [.universal]
        }
    }

    nonisolated static func from(persona: PersonaTag?) -> UserContentCategory? {
        guard let persona else { return nil }
        switch persona {
        case .tourist:
            return .tourist
        case .student:
            return .student
        case .entrepreneur:
            return .business
        case .universal:
            return .general
        case .worker, .refugee, .family, .lgbt, .eu, .nonEU, .highlySkilledMigrant:
            return .local
        }
    }

    func localized(_ language: AppLanguage) -> String {
        switch (self, language) {
        case (.tourist, .russian): return "Турист"
        case (.tourist, .dutch): return "Toerist"
        case (.tourist, .english): return "Tourist"
        case (.local, .russian): return "Местный житель"
        case (.local, .dutch): return "Inwoner"
        case (.local, .english): return "Local"
        case (.student, .russian): return "Студент"
        case (.student, .dutch): return "Student"
        case (.student, .english): return "Student"
        case (.business, .russian): return "Бизнес"
        case (.business, .dutch): return "Ondernemer"
        case (.business, .english): return "Business"
        case (.admin, .russian): return "Админ"
        case (.admin, .dutch): return "Admin"
        case (.admin, .english): return "Admin"
        case (.general, .russian): return "Общее"
        case (.general, .dutch): return "Algemeen"
        case (.general, .english): return "General"
        }
    }
}

protocol AudienceTaggedContent {
    nonisolated var audienceTags: Set<PersonaTag> { get }
}

extension AudienceTaggedContent {
    nonisolated func canShow(to selectedCategory: UserContentCategory?, scope: PersonaSearchScope = .currentAndUniversal) -> Bool {
        ContentAccessPolicy.canShowToUser(audience: audienceTags, selectedCategory: selectedCategory, scope: scope)
    }
}

enum ContentAccessPolicy {
    nonisolated static func canShowToUser(
        audience: Set<PersonaTag>,
        selectedCategory: UserContentCategory?,
        scope: PersonaSearchScope = .currentAndUniversal
    ) -> Bool {
        if scope == .allContentWithOutsidePathWarning {
            return true
        }
        guard let selectedCategory else { return false }
        guard !audience.isEmpty else { return false }
        guard selectedCategory != .admin else { return true }

        switch scope {
        case .allContentWithOutsidePathWarning:
            return true
        case .currentPersonaOnly:
            return audience.intersection(selectedCategory.personaTags).isEmpty == false
        case .currentAndUniversal:
            return audience.contains(.universal)
                || audience.intersection(selectedCategory.personaTags).isEmpty == false
        }
    }

    nonisolated static func canShowToUser(
        audience: Set<PersonaTag>,
        selectedPersona: PersonaTag?,
        scope: PersonaSearchScope = .currentAndUniversal
    ) -> Bool {
        canShowToUser(
            audience: audience,
            selectedCategory: UserContentCategory.from(persona: selectedPersona),
            scope: scope
        )
    }
}

nonisolated func canShowToUser(
    audience: Set<PersonaTag>,
    selectedCategory: UserContentCategory?,
    scope: PersonaSearchScope = .currentAndUniversal
) -> Bool {
    ContentAccessPolicy.canShowToUser(audience: audience, selectedCategory: selectedCategory, scope: scope)
}
