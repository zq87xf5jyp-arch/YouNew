import Foundation

typealias ContentID = String
typealias CategoryID = String
typealias CountryID = String
typealias ProvinceID = String
typealias CityID = String
typealias PlaceID = String
typealias SourceID = String

enum ContentType: String, CaseIterable, Codable, Hashable, Sendable {
    case article
    case officialService
    case place
    case city
    case province
    case checklist
    case emergencyAction
    case externalResource
    case appTool
}

enum ContentActionType: String, CaseIterable, Codable, Hashable, Sendable {
    case openContent
    case openOfficialSource
    case openMap
    case call
    case startChecklist
    case askAssistant
    case none
}

enum ContentStatus: String, CaseIterable, Codable, Hashable, Sendable {
    case draft
    case published
    case archived
}

enum EmergencyLevel: String, CaseIterable, Codable, Hashable, Sendable {
    case none
    case advisory
    case urgent
    case immediate
}

struct GeoCoordinates: Codable, Hashable, Sendable {
    let latitude: Double
    let longitude: Double

    var isValid: Bool {
        (-90 ... 90).contains(latitude) && (-180 ... 180).contains(longitude)
    }
}

struct Category: Identifiable, Codable, Hashable, Sendable {
    let id: CategoryID
    let title: String
    let localTitle: [String: String]
    let subcategoryIDs: [String]
    let relatedCategoryIDs: [CategoryID]
    let displayOrder: Int

    static let canonical: [Category] = [
        Category(id: "getting-started", title: "Getting started", localTitle: ["nl": "Beginnen", "ru": "Первые шаги"], subcategoryIDs: ["arrival", "registration", "first-week", "settling-in"], relatedCategoryIDs: ["official-services", "housing", "health-safety", "transport"], displayOrder: 1),
        Category(id: "housing", title: "Housing", localTitle: ["nl": "Wonen", "ru": "Жильё"], subcategoryIDs: ["find-home", "rent-contract", "address-registration", "costs-benefits", "tenant-rights"], relatedCategoryIDs: ["getting-started", "official-services", "work-money"], displayOrder: 2),
        Category(id: "official-services", title: "Official services", localTitle: ["nl": "Officiële diensten", "ru": "Государственные сервисы"], subcategoryIDs: ["municipality-brp", "bsn-digid", "immigration", "tax-benefits", "documents-letters", "institutions"], relatedCategoryIDs: ["getting-started", "housing", "work-money", "study", "health-safety"], displayOrder: 3),
        Category(id: "work-money", title: "Work and money", localTitle: ["nl": "Werk en geld", "ru": "Работа и деньги"], subcategoryIDs: ["find-work", "contracts-rights", "salary-tax", "banking", "entrepreneurship"], relatedCategoryIDs: ["official-services", "housing", "study"], displayOrder: 4),
        Category(id: "study", title: "Study", localTitle: ["nl": "Studie", "ru": "Учёба"], subcategoryIDs: ["schools-childcare", "higher-education", "student-admin", "dutch-language", "integration-knm"], relatedCategoryIDs: ["getting-started", "official-services", "work-money", "explore"], displayOrder: 5),
        Category(id: "health-safety", title: "Health and safety", localTitle: ["nl": "Gezondheid en veiligheid", "ru": "Здоровье и безопасность"], subcategoryIDs: ["insurance", "care", "mental-support", "emergency", "police-scams"], relatedCategoryIDs: ["getting-started", "official-services", "housing"], displayOrder: 6),
        Category(id: "transport", title: "Transport", localTitle: ["nl": "Vervoer", "ru": "Транспорт"], subcategoryIDs: ["public-transport", "trains", "cycling", "driving", "airports"], relatedCategoryIDs: ["getting-started", "official-services", "explore"], displayOrder: 7),
        Category(id: "explore", title: "Explore", localTitle: ["nl": "Ontdekken", "ru": "Исследовать"], subcategoryIDs: ["country", "culture", "history", "attractions", "events"], relatedCategoryIDs: ["study", "transport"], displayOrder: 8)
    ]
}

struct Country: Identifiable, Codable, Hashable, Sendable {
    let id: CountryID
    let name: String
    let localName: String
    let isoCode: String
}

struct Province: Identifiable, Codable, Hashable, Sendable {
    let id: ProvinceID
    let countryID: CountryID
    let name: String
    let localName: String
    let center: GeoCoordinates?
}

struct City: Identifiable, Codable, Hashable, Sendable {
    let id: CityID
    let countryID: CountryID
    let provinceID: ProvinceID
    let name: String
    let localName: String
    let center: GeoCoordinates?
}

struct Place: Identifiable, Codable, Hashable, Sendable {
    let id: PlaceID
    let countryID: CountryID
    let provinceID: ProvinceID?
    let cityID: CityID?
    let name: String
    let localName: String?
    let coordinates: GeoCoordinates
    let officialSourceID: SourceID?
}

struct SourceReference: Identifiable, Codable, Hashable, Sendable {
    let id: SourceID
    let title: String
    let publisher: String?
    let url: URL
    let isOfficial: Bool
    let lastVerifiedAt: Date?

    var canonicalURL: String {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.fragment = nil
        if components?.path == "/" { components?.path = "" }
        return (components?.url?.absoluteString ?? url.absoluteString)
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            .lowercased()
    }
}

enum ContentRelationType: String, CaseIterable, Codable, Hashable, Sendable {
    case related
    case prerequisite
    case nextStep
    case officialSource
    case geographicContext
    case replaces
}

struct ContentRelation: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let fromContentID: ContentID
    let toContentID: ContentID
    let type: ContentRelationType
    let weight: Double
}

struct ContentItem: Identifiable, Codable, Hashable, Sendable {
    let id: ContentID
    let contentType: ContentType
    let title: String
    let localTitle: [String: String]
    let shortDescription: String
    let fullDescription: String
    let primaryCategoryID: CategoryID
    let subcategoryIDs: [String]
    let audienceTags: Set<String>
    let countryID: CountryID
    let provinceID: ProvinceID?
    let cityIDs: [CityID]
    let placeID: PlaceID?
    let keywords: [String]
    let officialSourceURL: URL?
    let additionalSourceURLs: [URL]
    let lastVerifiedAt: Date?
    let coordinates: GeoCoordinates?
    let actionType: ContentActionType
    let relatedContentIDs: [ContentID]
    let priority: Int
    let emergencyLevel: EmergencyLevel
    let isSearchable: Bool
    let isMapVisible: Bool
    let status: ContentStatus
    let deepLink: String?
    let legacySourcePath: String?

    var allSourceURLs: [URL] {
        [officialSourceURL].compactMap { $0 } + additionalSourceURLs
    }

    var normalizedTitle: String {
        ContentNormalization.text(title)
    }

    var normalizedBody: String {
        ContentNormalization.text(fullDescription)
    }
}

enum ContentNormalization {
    static func text(_ value: String) -> String {
        value
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}
