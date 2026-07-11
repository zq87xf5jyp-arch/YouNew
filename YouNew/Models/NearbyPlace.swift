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
    let imageURL: URL?
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
        openingHoursPlaceholder: String = "Check current opening hours with the official source before visiting.",
        websiteURL: URL?,
        imageURL: URL? = nil,
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
        self.imageURL = imageURL
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
    var discoverySymbolName: String {
        let text = discoveryText
        if text.contains("museum") || text.contains("rijksmuseum") || text.contains("lakenhal") || text.contains("oudheden") {
            return "building.columns.fill"
        }
        if text.contains("restaurant") || text.contains("cafe") || text.contains("café") || text.contains("bakery") || text.contains("market") || text.contains("food") || text.contains("markthal") {
            return "fork.knife"
        }
        if text.contains("hotel") || text.contains("stay") || text.contains("hostel") {
            return "bed.double.fill"
        }
        if text.contains("park") || text.contains("hortus") || text.contains("botanic") || text.contains("nature") {
            return "leaf.fill"
        }
        if text.contains("canal") || text.contains("gracht") || text.contains("molen") || text.contains("windmill") || text.contains("bridge") || text.contains("burcht") || text.contains("castle") || text.contains("landmark") || text.contains("historic") || text.contains("viewpoint") || text.contains("euromast") || text.contains("cube houses") {
            return "camera.viewfinder"
        }
        return category.systemImageName
    }

    func discoveryCategoryTitle(_ lang: AppLanguage) -> String {
        let text = discoveryText
        if text.contains("museum") || text.contains("rijksmuseum") || text.contains("lakenhal") || text.contains("oudheden") {
            return localized(en: "Museum", nl: "Museum", ru: "Музей", lang: lang)
        }
        if text.contains("restaurant") {
            return localized(en: "Restaurant", nl: "Restaurant", ru: "Ресторан", lang: lang)
        }
        if text.contains("cafe") || text.contains("café") || text.contains("coffee") || text.contains("bakery") {
            return localized(en: "Cafe", nl: "Cafe", ru: "Кафе", lang: lang)
        }
        if text.contains("market") || text.contains("food") || text.contains("markthal") {
            return localized(en: "Food", nl: "Eten", ru: "Еда", lang: lang)
        }
        if text.contains("hotel") || text.contains("stay") || text.contains("hostel") {
            return localized(en: "Hotel", nl: "Hotel", ru: "Отель", lang: lang)
        }
        if text.contains("park") || text.contains("hortus") || text.contains("botanic") || text.contains("nature") {
            return localized(en: "Park", nl: "Park", ru: "Парк", lang: lang)
        }
        if text.contains("canal") || text.contains("gracht") || text.contains("molen") || text.contains("windmill") || text.contains("bridge") || text.contains("burcht") || text.contains("castle") || text.contains("landmark") || text.contains("historic") || text.contains("viewpoint") || text.contains("euromast") || text.contains("cube houses") {
            return localized(en: "Attraction", nl: "Bezienswaardigheid", ru: "Достопримечательность", lang: lang)
        }
        return category.localized(lang)
    }

    init?(dashboardPlace place: PlaceItem) {
        guard let coordinates = place.coordinates else { return nil }

        self.init(
            name: place.title,
            category: Self.category(for: place.primaryCategory),
            description: place.description,
            newcomerUseCase: Self.useCase(for: place),
            coordinate: coordinates.coordinate,
            address: place.address ?? place.cityId,
            openingHoursPlaceholder: Self.openingHoursNote(for: place),
            websiteURL: place.externalUrl ?? place.source?.url,
            imageURL: place.image.flatMap { AppURL.validatedWebURL(URL(string: $0)) },
            phone: nil,
            isOfficialSource: place.source != nil,
            sourceLabel: place.source?.institution ?? place.source?.title ?? "City guide",
            lastUpdated: place.lastChecked ?? "Reference data",
            city: place.cityId,
            trustNote: Self.trustNote(for: place),
            relatedLinks: [
                PlaceRelatedLink(
                    title: "Place details",
                    subtitle: place.title,
                    symbol: place.primaryCategory.symbol,
                    destination: place.destination
                )
            ],
            isReferenceLocation: place.source == nil
        )
    }

    private static func category(for category: VisitPlaceCategory) -> PlaceCategory {
        switch category {
        case .museum, .rainyDay:
            return .education
        case .park, .family, .free:
            return .communitySupport
        case .market, .food:
            return .foodBank
        case .landmark, .historic, .viewpoint, .hiddenGem:
            return .communitySupport
        }
    }

    private static func useCase(for place: PlaceItem) -> String {
        let city = place.cityId
        switch place.primaryCategory {
        case .museum, .rainyDay:
            return "Museum or indoor culture stop in \(city). Check opening hours and tickets with the official source."
        case .park, .family, .free:
            return "Low-barrier place in \(city) for a walk, family time, or a free city break."
        case .market, .food:
            return "Food or market stop in \(city). Useful for local routines, casual meals, or discovering the neighbourhood."
        case .landmark, .historic:
            return "Recognizable city landmark in \(city) with historical or cultural context."
        case .viewpoint:
            return "Viewpoint in \(city) for orientation, photos, and understanding the city layout."
        case .hiddenGem:
            return "Local discovery spot in \(city), useful when you want something beyond the obvious highlights."
        }
    }

    private static func openingHoursNote(for place: PlaceItem) -> String {
        if let estimatedVisitTime = place.estimatedVisitTime,
           !estimatedVisitTime.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Typical visit: \(estimatedVisitTime). Check current opening hours with the source."
        }

        switch place.primaryCategory {
        case .park, .viewpoint, .landmark, .historic, .hiddenGem:
            return "Public access may vary by area or season. Check local signs before visiting."
        case .market, .food:
            return "Market and restaurant hours vary by day. Check the official source before going."
        case .museum, .rainyDay, .family, .free:
            return "Opening hours can change. Verify with the official source before visiting."
        }
    }

    private static func trustNote(for place: PlaceItem) -> String {
        if let source = place.source?.institution, !source.isEmpty {
            return "Based on \(source). Prices, access, and opening hours should be checked before visiting."
        }
        return "Reference city data. Prices, access, and opening hours are not inferred."
    }

    private var discoveryText: String {
        "\(name) \(description) \(newcomerUseCase) \(sourceLabel)".lowercased()
    }

    private func localized(en: String, nl: String, ru: String, lang: AppLanguage) -> String {
        switch lang {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }

    var personaTags: Set<PersonaTag> {
        if relatedLinks.contains(where: { link in
            if case .placeDetail = link.destination { return true }
            return false
        }) {
            return [.student, .worker, .refugee, .family, .tourist, .entrepreneur, .lgbt, .eu, .nonEU, .highlySkilledMigrant]
        }

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
            return "Проверьте актуальные часы работы в официальном источнике перед визитом."
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
