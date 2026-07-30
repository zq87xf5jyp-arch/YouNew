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

enum GovernancePublicationStatus: String, CaseIterable, Codable, Hashable, Sendable {
    case draft
    case qa
    case published
    case archived
}

enum GovernanceVerificationStatus: String, CaseIterable, Codable, Hashable, Sendable {
    case unverified
    case verified
    case reviewDueSoon = "review_due_soon"
    case overdue
    case sourceUnavailable = "source_unavailable"
    case disputed
    case archived
}

enum GovernanceReviewState: String, CaseIterable, Codable, Hashable, Sendable {
    case needsReview = "needs_review"
    case assigned
    case inReview = "in_review"
    case approved
    case monitoring
    case expired
    case closed
}

enum GovernanceContentOrigin: String, CaseIterable, Codable, Hashable, Sendable {
    case imported
    case manuallyCreated = "manually_created"
    case municipalityRelease = "municipality_release"
    case governmentPublication = "government_publication"
    case aiGeneratedDraft = "ai_generated_draft"
    case migrated
}

enum GovernanceCriticality: String, CaseIterable, Codable, Hashable, Sendable {
    case standard
    case critical
}

enum GovernanceConfidenceLevel: String, CaseIterable, Codable, Hashable, Sendable {
    case low
    case medium
    case high
}

enum GovernanceJurisdictionLevel: String, CaseIterable, Codable, Hashable, Sendable {
    case national
    case provincial
    case municipal
    case mixed
}

struct ContentJurisdiction: Codable, Hashable, Sendable {
    let countryCode: String
    let level: GovernanceJurisdictionLevel
    let municipalityDependent: Bool
    let applicabilityVerified: Bool
    let provinceCode: String?
    let provinceName: String?
    let municipalityCode: String?
    let municipalityName: String?

    func matches(municipality: String?) -> Bool {
        guard municipalityDependent else { return applicabilityVerified }
        guard let municipality, !municipality.isEmpty else { return false }
        return municipalityCode?.caseInsensitiveCompare(municipality) == .orderedSame
            || municipalityName?.caseInsensitiveCompare(municipality) == .orderedSame
    }
}

struct GovernanceConfidenceBreakdown: Codable, Hashable, Sendable {
    let officialSource: Int
    let humanReviewer: Int
    let independentReview: Int
    let freshness: Int
    let jurisdictionApplicability: Int

    var score: Int {
        officialSource
            + humanReviewer
            + independentReview
            + freshness
            + jurisdictionApplicability
    }

    var isFormulaV1Valid: Bool {
        [0, 40].contains(officialSource)
            && [0, 20].contains(humanReviewer)
            && [0, 15].contains(independentReview)
            && [0, 10].contains(freshness)
            && [0, 15].contains(jurisdictionApplicability)
    }
}

struct ContentGovernanceEnvelope: Codable, Hashable, Sendable {
    let id: String
    let title: String
    let contentType: String
    let jurisdiction: ContentJurisdiction
    let officialSourceURL: URL?
    let sourceTitle: String?
    let sourcePublisher: String?
    let lastVerifiedAt: Date?
    let nextReviewAt: Date?
    let reviewIntervalDays: Int?
    let contentOwner: String?
    let reviewedBy: String?
    let verificationStatus: GovernanceVerificationStatus
    let confidenceLevel: GovernanceConfidenceLevel
    let validityStart: Date?
    let validityEnd: Date?
    let changeNotes: String?
    let version: Int
    let updatedAt: Date
    let publicationStatus: GovernancePublicationStatus
    let reviewState: GovernanceReviewState
    let criticality: GovernanceCriticality
    let contentOrigin: GovernanceContentOrigin
    let originReference: String?
    let originCapturedAt: Date?
    let originArtifactDigest: String?
    let confidenceScore: Int
    let confidenceScoreVersion: Int
    let confidenceBreakdown: GovernanceConfidenceBreakdown

    static func reviewDueLeadDays(reviewIntervalDays: Int?) -> Int {
        let interval = max(1, reviewIntervalDays ?? 90)
        return max(1, min(14, Int(Double(interval) * 0.25)))
    }

    func effectiveStatus(at now: Date = Date()) -> GovernanceVerificationStatus {
        if publicationStatus == .archived || verificationStatus == .archived { return .archived }
        if verificationStatus == .disputed { return .disputed }
        if verificationStatus == .sourceUnavailable { return .sourceUnavailable }

        guard verificationStatus != .unverified,
              officialSourceURL?.scheme?.lowercased() == "https",
              lastVerifiedAt != nil
        else { return .unverified }

        if let validityStart, now < validityStart { return .unverified }
        if verificationStatus == .overdue { return .overdue }
        if let validityEnd, now > validityEnd { return .overdue }
        if let nextReviewAt, now > nextReviewAt { return .overdue }
        if verificationStatus == .reviewDueSoon { return .reviewDueSoon }
        if let nextReviewAt {
            let lead = TimeInterval(Self.reviewDueLeadDays(reviewIntervalDays: reviewIntervalDays) * 86_400)
            if now >= nextReviewAt.addingTimeInterval(-lead) { return .reviewDueSoon }
        }
        return .verified
    }

    var hasValidConfidenceEvidence: Bool {
        confidenceScoreVersion == 1
            && confidenceBreakdown.isFormulaV1Valid
            && confidenceScore == confidenceBreakdown.score
    }

    func aiEligibility(at now: Date = Date()) -> GovernanceAIEligibility {
        switch effectiveStatus(at: now) {
        case .archived, .disputed, .sourceUnavailable, .unverified:
            return .excluded
        case .overdue:
            return .secondaryOnly
        case .verified, .reviewDueSoon:
            return .primary
        }
    }
}

enum GovernanceAIEligibility: String, Codable, Hashable, Sendable {
    case excluded
    case secondaryOnly = "secondary_only"
    case primary
}

struct GovernedRetrievalCandidate: Hashable, Sendable {
    let recordID: String
    let governance: ContentGovernanceEnvelope
}

struct GovernedRetrievalResult: Sendable {
    let primary: [GovernedRetrievalCandidate]
    let secondary: [GovernedRetrievalCandidate]
    let excludedCandidateReasons: [String: Int]
    let policyVersion = "retrieval-policy-v1"
}

enum GovernedRetrievalPolicy {
    static func rank(
        _ candidates: [GovernedRetrievalCandidate],
        municipality: String?,
        at now: Date = Date()
    ) -> GovernedRetrievalResult {
        var primary: [GovernedRetrievalCandidate] = []
        var secondary: [GovernedRetrievalCandidate] = []
        var excluded: [String: Int] = [:]

        for candidate in candidates {
            let jurisdiction = candidate.governance.jurisdiction
            if jurisdiction.municipalityDependent && !jurisdiction.matches(municipality: municipality) {
                excluded["wrong_municipality", default: 0] += 1
                continue
            }
            switch candidate.governance.aiEligibility(at: now) {
            case .excluded:
                excluded[candidate.governance.effectiveStatus(at: now).rawValue, default: 0] += 1
            case .secondaryOnly:
                secondary.append(candidate)
            case .primary:
                primary.append(candidate)
            }
        }

        return GovernedRetrievalResult(
            primary: primary.sorted(by: { precedes($0, $1) }),
            secondary: secondary.sorted(by: { precedes($0, $1) }),
            excludedCandidateReasons: excluded
        )
    }

    private static func precedes(
        _ lhs: GovernedRetrievalCandidate,
        _ rhs: GovernedRetrievalCandidate
    ) -> Bool {
        let left = lhs.governance
        let right = rhs.governance
        let leftJurisdiction = left.jurisdiction.municipalityDependent ? 2 : (
            left.jurisdiction.level == .national && left.jurisdiction.applicabilityVerified ? 1 : 0
        )
        let rightJurisdiction = right.jurisdiction.municipalityDependent ? 2 : (
            right.jurisdiction.level == .national && right.jurisdiction.applicabilityVerified ? 1 : 0
        )
        if leftJurisdiction != rightJurisdiction { return leftJurisdiction > rightJurisdiction }

        let leftOfficial = left.confidenceBreakdown.officialSource == 40
        let rightOfficial = right.confidenceBreakdown.officialSource == 40
        if leftOfficial != rightOfficial { return leftOfficial && !rightOfficial }

        let leftFreshness = left.lastVerifiedAt ?? .distantPast
        let rightFreshness = right.lastVerifiedAt ?? .distantPast
        if leftFreshness != rightFreshness { return leftFreshness > rightFreshness }

        let leftConfidence = left.hasValidConfidenceEvidence ? left.confidenceScore : 0
        let rightConfidence = right.hasValidConfidenceEvidence ? right.confidenceScore : 0
        if leftConfidence != rightConfidence { return leftConfidence > rightConfidence }
        return lhs.recordID < rhs.recordID
    }
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
    let governance: ContentGovernanceEnvelope?

    var allSourceURLs: [URL] {
        [officialSourceURL].compactMap { $0 } + additionalSourceURLs
    }

    var normalizedTitle: String {
        ContentNormalization.text(title)
    }

    var normalizedBody: String {
        ContentNormalization.text(fullDescription)
    }

    func effectiveGovernanceStatus(at now: Date = Date()) -> GovernanceVerificationStatus {
        governance?.effectiveStatus(at: now) ?? .unverified
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
