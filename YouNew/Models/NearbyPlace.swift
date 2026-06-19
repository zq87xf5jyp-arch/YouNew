import Foundation
import CoreLocation

struct PlaceRelatedLink: Identifiable {
    let title: String
    let subtitle: String
    let symbol: String
    let destination: AppDestination
    var id: UUID { StableRouteID.uuid("place-related-link:\(title).\(subtitle).\(symbol)") }
}

struct NearbyPlace: Identifiable {
    let name: String
    let localizedNameText: LocalizedCityText?
    let localizedDescriptionText: LocalizedCityText?
    let localizedUseCaseText: LocalizedCityText?
    let category: PlaceCategory
    let description: String
    let newcomerUseCase: String
    let coordinate: CLLocationCoordinate2D
    let address: String
    let openingHoursPlaceholder: String
    let websiteURL: URL?
    let phone: String?
    let isOfficialSource: Bool
    let sourceLabel: String
    let lastUpdated: String
    let city: String
    let trustNote: String
    let emergencyNote: String?
    let relatedLinks: [PlaceRelatedLink]
    let saveKey: String
    let isReferenceLocation: Bool
    var id: UUID { StableRouteID.uuid("nearby-place:\(saveKey)") }

    init(
        name: String,
        localizedNameText: LocalizedCityText? = nil,
        localizedDescriptionText: LocalizedCityText? = nil,
        localizedUseCaseText: LocalizedCityText? = nil,
        category: PlaceCategory,
        description: String,
        newcomerUseCase: String = "Useful for newcomer onboarding and local services.",
        coordinate: CLLocationCoordinate2D,
        address: String,
        openingHoursPlaceholder: String = "Opening hours unavailable — verify official source.",
        websiteURL: URL?,
        phone: String?,
        isOfficialSource: Bool,
        sourceLabel: String,
        lastUpdated: String,
        city: String,
        trustNote: String = "Reference data — verify details with official sources before visiting.",
        emergencyNote: String? = nil,
        relatedLinks: [PlaceRelatedLink] = [],
        isReferenceLocation: Bool = false
    ) {
        self.name = name
        self.localizedNameText = localizedNameText
        self.localizedDescriptionText = localizedDescriptionText
        self.localizedUseCaseText = localizedUseCaseText
        self.category = category
        self.description = description
        self.newcomerUseCase = newcomerUseCase
        self.coordinate = coordinate
        self.address = address
        self.openingHoursPlaceholder = openingHoursPlaceholder
        self.websiteURL = websiteURL
        self.phone = phone
        self.isOfficialSource = isOfficialSource
        self.sourceLabel = sourceLabel
        self.lastUpdated = lastUpdated
        self.city = city
        self.trustNote = trustNote
        self.emergencyNote = emergencyNote
        self.relatedLinks = relatedLinks
        self.saveKey = "\(city.lowercased())::\(category.rawValue)::\(name.lowercased())"
        self.isReferenceLocation = isReferenceLocation
    }
}

extension NearbyPlace {
    var personaTags: Set<PersonaTag> {
        switch category {
        case .duo, .studentHelp:
            return [.student]
        case .uwv:
            return [.worker]
        case .ind, .immigrationSupport:
            return [.refugee, .nonEU, .highlySkilledMigrant]
        case .expatCenter:
            return [.highlySkilledMigrant, .eu, .nonEU]
        case .education, .library:
            return [.student, .family, .refugee]
        case .communitySupport:
            return [.refugee, .family, .lgbt, .eu, .nonEU]
        case .lgbtqSupport:
            return [.lgbt]
        case .foodBank, .shelter:
            return [.refugee, .family]
        case .municipality:
            return [.worker, .refugee, .family, .tourist, .entrepreneur, .lgbt, .eu, .nonEU, .highlySkilledMigrant]
        case .healthcare, .hospital, .huisarts, .pharmacy, .nightPharmacy:
            return [.student, .worker, .refugee, .family, .tourist, .entrepreneur, .lgbt, .eu, .nonEU, .highlySkilledMigrant]
        case .transport, .transportOffice, .bikeRepair:
            return [.student, .worker, .refugee, .family, .tourist, .entrepreneur, .lgbt, .eu, .nonEU, .highlySkilledMigrant]
        case .legalHelp:
            return [.worker, .refugee, .family, .entrepreneur, .lgbt, .eu, .nonEU, .highlySkilledMigrant]
        case .police:
            return [.student, .worker, .refugee, .family, .tourist, .entrepreneur, .lgbt, .eu, .nonEU, .highlySkilledMigrant]
        case .animalEmergency:
            return [.family, .tourist, .eu]
        }
    }

    func isVisible(for persona: PersonaTag?, scope: PersonaSearchScope = .currentAndUniversal) -> Bool {
        PersonaContentPolicy.isVisible(tags: personaTags, activePersona: persona, scope: scope)
    }

    func localizedName(_ lang: AppLanguage) -> String {
        localizedNameText?.value(for: lang) ?? name
    }

    func localizedDescription(_ lang: AppLanguage) -> String {
        if let localizedDescriptionText {
            return localizedDescriptionText.value(for: lang)
        }
        guard lang == .russian else { return description }
        if looksEnglish(description) {
            return "Ориентирная точка поддержки по теме: \(category.localized(lang))."
        }
        return description
    }

    func localizedUseCase(_ lang: AppLanguage) -> String {
        if let localizedUseCaseText {
            return localizedUseCaseText.value(for: lang)
        }
        guard lang == .russian else { return newcomerUseCase }
        if looksEnglish(newcomerUseCase) {
            return "Подходит для базовой адаптации: документы, сервисы и следующие шаги в городе."
        }
        return newcomerUseCase
    }

    func localizedSourceLabel(_ lang: AppLanguage) -> String {
        guard lang == .russian else { return sourceLabel }
        switch sourceLabel {
        case "Official source": return "Официальный источник"
        case "Trusted source": return "Надёжный источник"
        case "Reference data": return "Справочные данные"
        default: return sourceLabel
        }
    }

    func localizedOpeningHours(_ lang: AppLanguage) -> String {
        guard lang == .russian else { return openingHoursPlaceholder }
        if looksEnglish(openingHoursPlaceholder) {
            return "Часы работы не указаны — проверьте официальный источник."
        }
        return openingHoursPlaceholder
    }

    func localizedTrustNote(_ lang: AppLanguage) -> String {
        guard lang == .russian else { return trustNote }
        if looksEnglish(trustNote) {
            return "Справочные данные. Перед визитом сверяйте детали в официальных источниках."
        }
        return trustNote
    }

    func localizedEmergencyNote(_ lang: AppLanguage) -> String? {
        guard let emergencyNote else { return nil }
        guard lang == .russian else { return emergencyNote }
        if looksEnglish(emergencyNote) {
            return "При экстренной угрозе звоните 112."
        }
        return emergencyNote
    }

    private func looksEnglish(_ text: String) -> Bool {
        let letters = text.unicodeScalars.filter { CharacterSet.letters.contains($0) }
        guard !letters.isEmpty else { return false }
        let latin = letters.filter { $0.properties.isAlphabetic && $0.isASCII }
        return Double(latin.count) / Double(letters.count) > 0.65
    }
}
