import Foundation

enum DataVerificationStatus: String, CaseIterable, Codable {
    case verified = "Verified"
    case needsReview = "Needs review"
    case outdated = "Outdated"
    case pending = "Pending"
    case unknown = "Unknown"
}

enum DataUpdateFrequency: String, CaseIterable, Codable {
    case live = "Live"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case annually = "Annually"

    var maximumAgeDays: Int {
        switch self {
        case .live: return 1
        case .daily: return 2
        case .weekly: return 10
        case .monthly: return 45
        case .quarterly: return 120
        case .annually: return 400
        }
    }
}

enum KnowledgeDataIssueKind: String, Codable {
    case duplicateEntity
    case duplicateWebsite
    case wrongCity
    case wrongProvince
    case missingPhoto
    case missingPhotoLicense
    case duplicatePhoto
    case missingOfficialSource
    case outdatedRecord
    case expiredEvent
    case invalidWebsite
    case incompleteRecord
}

struct KnowledgeDataIssue: Identifiable, Codable {
    let id: String
    let kind: KnowledgeDataIssueKind
    let entityIDs: [String]
    let detail: String
}

struct PremiumKnowledgeDatabaseReport {
    let cities: Int
    let museums: Int
    let restaurants: Int
    let cafes: Int
    let governmentServices: Int
    let partners: Int
    let events: Int
    let images: Int
    let verifiedWebsites: Int
    let currentRecordPercentage: Double
    let uniquePhotoPercentage: Double

    var lines: [String] {
        [
            "Cities: \(cities)",
            "Museums: \(museums)",
            "Restaurants: \(restaurants)",
            "Cafés: \(cafes)",
            "Official services: \(governmentServices)",
            "Partners: \(partners)",
            "Events: \(events)",
            "Images: \(images)",
            "Verified websites: \(verifiedWebsites)",
            String(format: "Records with a current verification date: %.1f%%", currentRecordPercentage),
            String(format: "Entities with unique primary photography: %.1f%%", uniquePhotoPercentage)
        ]
    }
}

extension NetherlandsKnowledgeEntity {
    var updateFrequency: DataUpdateFrequency {
        switch kind {
        case .event: return .daily
        case .governmentService, .officialSource, .healthcare: return .monthly
        case .localPartner, .restaurant, .cafe, .hotel: return .monthly
        case .place, .attraction, .museum, .park, .transport, .university: return .quarterly
        case .city, .province, .country: return .annually
        case .district, .checklist, .knowledgeTopic: return .quarterly
        }
    }

    var verificationStatus: DataVerificationStatus {
        guard let checked = Self.parseReviewDate(lastChecked) else { return .unknown }
        let age = Calendar(identifier: .gregorian).dateComponents([.day], from: checked, to: Date()).day ?? 0
        if age > updateFrequency.maximumAgeDays { return .outdated }
        if requiresOfficialSource && source?.url == nil { return .needsReview }
        if !hasCompleteVisualSet { return .pending }
        return .verified
    }

    var hasCompleteVisualSet: Bool {
        images.hero != nil && !images.gallery.isEmpty && images.thumbnail != nil && images.mapPreview != nil
    }

    var hasReusablePrimaryMedia: Bool {
        guard let media = images.hero, media.verified else { return false }
        if media.localAssetName != nil { return true }
        return !(media.licenseName ?? media.license ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
            && media.sourcePageURL != nil
            && media.attribution?.isEmpty == false
    }

    var isPublishableRecord: Bool {
        let requiredText = [id, title, summary, category, lastChecked, aiSummary]
        guard requiredText.allSatisfy({ !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) else { return false }
        guard !requiresOfficialSource || source?.url?.scheme?.lowercased() == "https" else { return false }
        guard !requiresCoordinates || coordinate != nil else { return false }
        guard hasCompleteVisualSet else { return false }
        guard kind != .event || isActiveEvent() else { return false }
        return verificationStatus != .outdated && verificationStatus != .unknown
    }

    func isActiveEvent(now: Date = Date()) -> Bool {
        guard kind == .event else { return true }
        let endValue = attributes["endDate"].flatMap(Self.parseReviewDate)
        let startValue = attributes["startDate"].flatMap(Self.parseReviewDate)
        guard let activeThrough = endValue ?? startValue else { return false }
        return activeThrough >= CalendarEventData.calendar.startOfDay(for: now)
    }

    fileprivate var primaryMediaIdentity: String? {
        guard let image = images.hero else { return nil }
        if let local = image.localAssetName { return "local:\(local.lowercased())" }
        if let url = image.imageURL ?? image.url { return "url:\(Self.canonicalURL(url))" }
        return "source:\(image.sourceName.lowercased())"
    }

    fileprivate var requiresOfficialSource: Bool {
        switch kind {
        case .governmentService, .place, .attraction, .museum, .park, .restaurant, .cafe, .hotel, .healthcare, .university, .transport, .localPartner, .event, .officialSource, .city, .province, .country:
            return true
        case .district, .knowledgeTopic, .checklist:
            return false
        }
    }

    fileprivate var requiresCoordinates: Bool {
        switch kind {
        case .place, .attraction, .museum, .park, .restaurant, .cafe, .hotel, .healthcare, .university, .transport, .localPartner:
            return true
        default:
            return false
        }
    }

    nonisolated fileprivate static func parseReviewDate(_ value: String) -> Date? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if let date = ISO8601DateFormatter().date(from: trimmed) { return date }
        if let date = ISO8601DateFormatter().date(from: "\(trimmed)T00:00:00Z") { return date }
        for format in ["MMMM yyyy", "MMM yyyy"] {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
            formatter.dateFormat = format
            if let date = formatter.date(from: trimmed) { return date }
        }
        return nil
    }

    nonisolated fileprivate static func canonicalURL(_ url: URL) -> String {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.fragment = nil
        components?.query = nil
        if components?.path == "/" { components?.path = "" }
        return (components?.url?.absoluteString ?? url.absoluteString)
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            .lowercased()
    }
}

extension NetherlandsKnowledgeDatabase {
    var publishedEntities: [NetherlandsKnowledgeEntity] {
        let canonicalCities = Set(entities.filter { $0.kind == .city }.map { KnowledgeNormalizer.normalize($0.title) })
        return entities.filter { entity in
            guard entity.isPublishableRecord else { return false }
            guard let city = entity.cityId else { return true }
            return canonicalCities.contains(KnowledgeNormalizer.normalize(city))
        }
    }

    func premiumReport(now: Date = Date()) -> PremiumKnowledgeDatabaseReport {
        let records = publishedEntities
        let websites: Set<String> = Set(records.compactMap { entity -> String? in
            guard entity.verificationStatus == .verified, let url = entity.source?.url else { return nil }
            return NetherlandsKnowledgeEntity.canonicalURL(url)
        })
        let mediaCounts = Dictionary(grouping: records.compactMap(\.primaryMediaIdentity), by: { $0 }).mapValues(\.count)
        let recordsWithMedia = records.filter { $0.primaryMediaIdentity != nil }
        let uniqueMediaRecords = recordsWithMedia.filter { mediaCounts[$0.primaryMediaIdentity ?? ""] == 1 }.count
        let currentCount = records.filter { $0.verificationStatus == .verified || $0.verificationStatus == .pending }.count

        return PremiumKnowledgeDatabaseReport(
            cities: records.filter { $0.kind == .city }.count,
            museums: records.filter { $0.kind == .museum }.count,
            restaurants: records.filter { $0.kind == .restaurant }.count,
            cafes: records.filter { $0.kind == .cafe }.count,
            governmentServices: records.filter { $0.kind == .governmentService }.count,
            partners: records.filter { $0.kind == .localPartner }.count,
            events: records.filter { $0.kind == .event && $0.isActiveEvent(now: now) }.count,
            images: records.reduce(0) { $0 + $1.images.allImages.count },
            verifiedWebsites: websites.count,
            currentRecordPercentage: records.isEmpty ? 0 : (Double(currentCount) / Double(records.count)) * 100,
            uniquePhotoPercentage: recordsWithMedia.isEmpty ? 0 : (Double(uniqueMediaRecords) / Double(recordsWithMedia.count)) * 100
        )
    }

    func dataQualityIssues(now: Date = Date()) -> [KnowledgeDataIssue] {
        KnowledgeDataValidator.validate(entities: entities, now: now)
    }
}

enum KnowledgeDataValidator {
    static func validate(entities: [NetherlandsKnowledgeEntity], now: Date = Date()) -> [KnowledgeDataIssue] {
        var issues: [KnowledgeDataIssue] = []

        for group in Dictionary(grouping: entities, by: \.id).values where group.count > 1 {
            issues.append(issue(.duplicateEntity, group.map(\.id), "Entity ID is not unique."))
        }

        let photoGroups = Dictionary(grouping: entities.compactMap { entity in
            entity.primaryMediaIdentity.map { ($0, entity.id) }
        }, by: { $0.0 })
        for (_, group) in photoGroups where group.count > 1 {
            let ids = group.map(\.1)
            issues.append(issue(.duplicatePhoto, ids, "Primary photography is reused by multiple entities."))
        }

        let websiteGroups = Dictionary(grouping: entities.filter { $0.kind != .officialSource }) { entity in
            entity.source?.url.map(NetherlandsKnowledgeEntity.canonicalURL) ?? ""
        }
        for (website, group) in websiteGroups where !website.isEmpty && group.count > 1 {
            let distinctTitles = Set(group.map { KnowledgeNormalizer.normalize($0.title) })
            if distinctTitles.count < group.count {
                issues.append(issue(.duplicateWebsite, group.map(\.id), "Repeated entity and canonical website: \(website)"))
            }
        }

        let cities = Set(entities.filter { $0.kind == .city }.map { KnowledgeNormalizer.normalize($0.title) })
        let provinces = Set(entities.filter { $0.kind == .province }.flatMap { [$0.id.replacingOccurrences(of: "province:", with: ""), KnowledgeNormalizer.normalize($0.title), KnowledgeNormalizer.normalize($0.provinceId ?? "")] })

        for entity in entities {
            if let city = entity.cityId, !cities.contains(KnowledgeNormalizer.normalize(city)) {
                issues.append(issue(.wrongCity, [entity.id], "Unknown city: \(city)."))
            }
            if let province = entity.provinceId,
               !provinces.contains(KnowledgeNormalizer.normalize(province)),
               !provinces.contains(KnowledgeNormalizer.slug(province)) {
                issues.append(issue(.wrongProvince, [entity.id], "Unknown province: \(province)."))
            }
            if !entity.hasCompleteVisualSet {
                issues.append(issue(.missingPhoto, [entity.id], "Hero, gallery, thumbnail and preview are required."))
            }
            if !entity.hasReusablePrimaryMedia {
                issues.append(issue(.missingPhotoLicense, [entity.id], "Primary media needs a verified source, reusable licence and attribution."))
            }
            if entity.requiresOfficialSource && entity.source?.url == nil {
                issues.append(issue(.missingOfficialSource, [entity.id], "A verified source URL is required."))
            }
            if let url = entity.source?.url, url.scheme?.lowercased() != "https" {
                issues.append(issue(.invalidWebsite, [entity.id], "Source URL must use HTTPS."))
            }
            if entity.verificationStatus == .outdated {
                issues.append(issue(.outdatedRecord, [entity.id], "Review date exceeds \(entity.updateFrequency.rawValue.lowercased()) policy."))
            }
            if entity.kind == .event && !entity.isActiveEvent(now: now) {
                issues.append(issue(.expiredEvent, [entity.id], "Completed event must not be published or indexed."))
            }
            if !entity.isPublishableRecord && entity.verificationStatus != .outdated {
                issues.append(issue(.incompleteRecord, [entity.id], "Record does not satisfy publication gates."))
            }
        }
        return issues
    }

    private static func issue(_ kind: KnowledgeDataIssueKind, _ ids: [String], _ detail: String) -> KnowledgeDataIssue {
        KnowledgeDataIssue(id: "\(kind.rawValue):\(ids.sorted().joined(separator: "|"))", kind: kind, entityIDs: ids.sorted(), detail: detail)
    }
}
