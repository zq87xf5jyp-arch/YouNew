import Foundation

enum ContentValidationSeverity: String, Codable, Hashable {
    case error
    case warning
}

enum ContentValidationKind: String, Codable, Hashable {
    case duplicateID
    case duplicateCanonicalURL
    case duplicateNormalizedTitle
    case duplicateNormalizedBody
    case unknownCategory
    case unknownCity
    case missingSource
    case staleVerificationDate
    case unusedObject
    case unreachableThroughGuideOrSearch
    case invalidCoordinates
}

struct ContentValidationIssue: Identifiable, Codable, Hashable {
    let id: String
    let severity: ContentValidationSeverity
    let kind: ContentValidationKind
    let contentIDs: [ContentID]
    let detail: String
}

struct ContentMigrationMetrics: Codable, Hashable {
    let sourceObjects: Int
    let migratedObjects: Int
    let duplicatesMerged: Int
    let referencesUpdated: Int
    let lostObjects: Int
    let remainingErrors: Int
    let remainingWarnings: Int
}

struct ContentRepository {
    static let netherlands = Country(
        id: "nl",
        name: "Netherlands",
        localName: "Nederland",
        isoCode: "NL"
    )

    static let shared = ContentRepository(legacyItems: KnowledgeIndex.shared.items)

    let items: [ContentItem]
    let categories: [Category]
    let countries: [Country]
    let provinces: [Province]
    let cities: [City]
    let places: [Place]
    let sources: [SourceReference]
    let relations: [ContentRelation]
    let aliases: [ContentID: ContentID]
    let validationIssues: [ContentValidationIssue]
    let metrics: ContentMigrationMetrics

    private let itemsByID: [ContentID: ContentItem]
    private let sourcesByID: [SourceID: SourceReference]

    init(legacyItems: [KnowledgeItem], now: Date = Date()) {
        categories = Category.canonical
        countries = [Self.netherlands]
        provinces = Self.makeProvinces()
        cities = Self.makeCities()
        places = []
        relations = []

        let cityIDsByName = cities.reduce(into: [String: CityID]()) { result, city in
            result[ContentNormalization.text(city.name)] = city.id
            result[ContentNormalization.text(city.localName)] = city.id
        }
        let provinceIDsByName = provinces.reduce(into: [String: ProvinceID]()) { result, province in
            result[ContentNormalization.text(province.name)] = province.id
            result[ContentNormalization.text(province.localName)] = province.id
        }

        var sourceByCanonicalURL: [String: SourceReference] = [:]
        var sourceMergeCount = 0
        for legacy in legacyItems {
            for source in legacy.sources {
                guard let url = source.url else { continue }
                let candidate = SourceReference(
                    id: "source:\(ContentNormalization.text(url.absoluteString).replacingOccurrences(of: " ", with: "-"))",
                    title: source.title,
                    publisher: source.institution,
                    url: url,
                    isOfficial: legacy.safetyLevel != .general,
                    lastVerifiedAt: legacy.lastReviewed
                )
                if sourceByCanonicalURL[candidate.canonicalURL] == nil {
                    sourceByCanonicalURL[candidate.canonicalURL] = candidate
                } else {
                    sourceMergeCount += 1
                }
            }
        }
        sources = sourceByCanonicalURL.values.sorted { $0.id < $1.id }
        sourcesByID = Dictionary(uniqueKeysWithValues: sources.map { ($0.id, $0) })

        var canonicalItems: [ContentItem] = []
        var canonicalByID: [ContentID: ContentItem] = [:]
        var duplicateAliases: [ContentID: ContentID] = [:]
        var duplicateIDCount = 0

        for legacy in legacyItems {
            let item = Self.makeContentItem(
                from: legacy,
                cityIDsByName: cityIDsByName,
                provinceIDsByName: provinceIDsByName
            )
            if let existing = canonicalByID[item.id] {
                duplicateIDCount += 1
                duplicateAliases[legacy.id] = existing.id
                continue
            }
            canonicalItems.append(item)
            canonicalByID[item.id] = item
        }

        items = canonicalItems
        itemsByID = canonicalByID
        aliases = duplicateAliases
        validationIssues = ContentRepositoryValidator.validate(
            items: canonicalItems,
            categories: categories,
            cities: cities,
            sources: sources,
            now: now
        )

        let errors = validationIssues.filter { $0.severity == .error }.count
        let warnings = validationIssues.filter { $0.severity == .warning }.count
        metrics = ContentMigrationMetrics(
            sourceObjects: legacyItems.count,
            migratedObjects: canonicalItems.count,
            duplicatesMerged: duplicateIDCount + sourceMergeCount,
            referencesUpdated: 0,
            lostObjects: legacyItems.count - canonicalItems.count - duplicateIDCount,
            remainingErrors: errors,
            remainingWarnings: warnings
        )
    }

    func item(id: ContentID) -> ContentItem? {
        let canonicalID = aliases[id] ?? id
        return itemsByID[canonicalID]
    }

    func source(id: SourceID) -> SourceReference? {
        sourcesByID[id]
    }

    func guideItems(categoryID: CategoryID? = nil) -> [ContentItem] {
        items.filter { item in
            item.status == .published && (categoryID == nil || item.primaryCategoryID == categoryID)
        }
        .sorted { ($0.priority, $0.title) > ($1.priority, $1.title) }
    }

    func searchableItems() -> [ContentItem] {
        items.filter { $0.status == .published && $0.isSearchable }
    }

    func mapItems() -> [ContentItem] {
        items.filter { item in
            item.status == .published && item.isMapVisible && item.coordinates?.isValid == true
        }
    }

    func homeReferences(audienceTags: Set<String>, limit: Int = 12) -> [ContentID] {
        guideItems()
            .sorted { lhs, rhs in
                let lhsMatch = lhs.audienceTags.isDisjoint(with: audienceTags) ? 0 : 1
                let rhsMatch = rhs.audienceTags.isDisjoint(with: audienceTags) ? 0 : 1
                return (lhsMatch, lhs.priority, lhs.title) > (rhsMatch, rhs.priority, rhs.title)
            }
            .prefix(limit)
            .map(\.id)
    }
}

private extension ContentRepository {
    static func makeContentItem(
        from legacy: KnowledgeItem,
        cityIDsByName: [String: CityID],
        provinceIDsByName: [String: ProvinceID]
    ) -> ContentItem {
        let cityID = legacy.city.flatMap { cityIDsByName[ContentNormalization.text($0)] }
        let provinceID = legacy.province.flatMap { provinceIDsByName[ContentNormalization.text($0)] }
        let city = cityID.flatMap { id in makeCities().first(where: { $0.id == id }) }
        let sourceURLs = legacy.sources.compactMap(\.url)
        let type = contentType(for: legacy.type, safetyLevel: legacy.safetyLevel)
        let coordinates = city?.center

        return ContentItem(
            id: legacy.id,
            contentType: type,
            title: legacy.title(.english),
            localTitle: [
                "nl": legacy.title(.dutch),
                "ru": legacy.title(.russian)
            ].filter { !$0.value.isEmpty && $0.value != legacy.title(.english) },
            shortDescription: legacy.summary(.english),
            fullDescription: legacy.summary(.english),
            primaryCategoryID: categoryID(for: legacy),
            subcategoryIDs: [ContentNormalization.text(legacy.category).replacingOccurrences(of: " ", with: "-")],
            audienceTags: Set(legacy.personaTags.map(\.rawValue)),
            countryID: netherlands.id,
            provinceID: provinceID ?? city?.provinceID,
            cityIDs: [cityID].compactMap { $0 },
            placeID: type == .place ? legacy.id : nil,
            keywords: legacy.keywords,
            officialSourceURL: sourceURLs.first,
            additionalSourceURLs: Array(sourceURLs.dropFirst()),
            lastVerifiedAt: legacy.lastReviewed,
            coordinates: coordinates,
            actionType: actionType(for: type, hasSource: !sourceURLs.isEmpty),
            relatedContentIDs: [],
            priority: priority(for: legacy),
            emergencyLevel: emergencyLevel(for: legacy.safetyLevel),
            isSearchable: true,
            isMapVisible: coordinates != nil && [.place, .city, .province, .officialService].contains(type),
            status: .published,
            deepLink: "younew://content/\(legacy.id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? legacy.id)",
            legacySourcePath: legacy.sourcePath
        )
    }

    static func categoryID(for item: KnowledgeItem) -> CategoryID {
        let value = ContentNormalization.text([item.category, item.title(.english), item.summary(.english)].joined(separator: " "))
        if contains(value, ["emergency", "health", "huisarts", "insurance", "risk", "scam", "lgbtq", "support"]) { return "health-safety" }
        if contains(value, ["housing", "rent", "huur", "tenant", "address"]) { return "housing" }
        if contains(value, ["transport", "train", "fiets", "bicycle", "parking", "airport", "ov chip"]) { return "transport" }
        if contains(value, ["work", "salary", "tax", "bank", "money", "business", "partner"]) { return "work-money" }
        if contains(value, ["study", "education", "school", "dutch", "language", "knm", "history"]) { return "study" }
        if contains(value, ["government", "official", "document", "digid", "bsn", "municipality", "institution", "letter", "fine", "legal", "rule", "source"]) { return "official-services" }
        if contains(value, ["city", "province", "place", "culture", "calendar", "event", "tour", "food", "museum", "explore"]) { return "explore" }
        return "getting-started"
    }

    static func contains(_ value: String, _ terms: [String]) -> Bool {
        terms.contains(where: value.contains)
    }

    static func contentType(for type: KnowledgeItemType, safetyLevel: KnowledgeSafetyLevel) -> ContentType {
        if safetyLevel == .emergency { return .emergencyAction }
        switch type {
        case .officialService, .institution: return .officialService
        case .nearbyPlace, .localPartner: return .place
        case .city: return .city
        case .province: return .province
        case .checklist: return .checklist
        case .resource: return .externalResource
        case .appTool, .appScreen: return .appTool
        default: return .article
        }
    }

    static func actionType(for type: ContentType, hasSource: Bool) -> ContentActionType {
        switch type {
        case .place, .city, .province: return .openMap
        case .checklist: return .startChecklist
        case .externalResource where hasSource: return .openOfficialSource
        case .officialService where hasSource: return .openOfficialSource
        default: return .openContent
        }
    }

    static func priority(for item: KnowledgeItem) -> Int {
        switch item.safetyLevel {
        case .emergency: return 100
        case .officialSourceRequired: return 70
        case .officialSourceRecommended: return 50
        case .general: return 30
        }
    }

    static func emergencyLevel(for safety: KnowledgeSafetyLevel) -> EmergencyLevel {
        safety == .emergency ? .immediate : .none
    }

    static func makeProvinces() -> [Province] {
        NLProvince.all.map { province in
            Province(
                id: "nl-province-\(ContentNormalization.text(province.id).replacingOccurrences(of: " ", with: "-"))",
                countryID: netherlands.id,
                name: province.nameEN,
                localName: province.name,
                center: nil
            )
        }
    }

    static func makeCities() -> [City] {
        let provinceByName = makeProvinces().reduce(into: [String: ProvinceID]()) { result, province in
            result[ContentNormalization.text(province.name)] = province.id
            result[ContentNormalization.text(province.localName)] = province.id
        }
        return NLCity.all.compactMap { city in
            guard let provinceID = provinceByName[ContentNormalization.text(city.province)] else { return nil }
            return City(
                id: city.placeId,
                countryID: netherlands.id,
                provinceID: provinceID,
                name: city.name,
                localName: city.name,
                center: parseCoordinates(city.coordinates)
            )
        }
    }

    static func parseCoordinates(_ value: String) -> GeoCoordinates? {
        let numbers = value
            .replacingOccurrences(of: ",", with: " ")
            .split(separator: " ")
            .compactMap { Double($0.filter { $0.isNumber || $0 == "." || $0 == "-" }) }
        guard numbers.count >= 2 else { return nil }
        let coordinates = GeoCoordinates(latitude: numbers[0], longitude: numbers[1])
        return coordinates.isValid ? coordinates : nil
    }
}

enum ContentRepositoryValidator {
    static func validate(
        items: [ContentItem],
        categories: [Category],
        cities: [City],
        sources: [SourceReference],
        now: Date = Date(),
        staleAfterDays: Int = 365
    ) -> [ContentValidationIssue] {
        var issues: [ContentValidationIssue] = []
        let categoryIDs = Set(categories.map(\.id))
        let cityIDs = Set(cities.map(\.id))

        issues += duplicateIssues(items, key: \.id, kind: .duplicateID, severity: .error)
        issues += duplicateIssues(items.filter { !$0.normalizedTitle.isEmpty }, key: \.normalizedTitle, kind: .duplicateNormalizedTitle, severity: .warning)
        issues += duplicateIssues(items.filter { !$0.normalizedBody.isEmpty }, key: \.normalizedBody, kind: .duplicateNormalizedBody, severity: .warning)
        issues += duplicateIssues(sources, key: \.canonicalURL, kind: .duplicateCanonicalURL, severity: .error)

        for item in items {
            if !categoryIDs.contains(item.primaryCategoryID) {
                issues.append(issue(.error, .unknownCategory, [item.id], item.primaryCategoryID))
            }
            let unknownCities = item.cityIDs.filter { !cityIDs.contains($0) }
            if !unknownCities.isEmpty {
                issues.append(issue(.error, .unknownCity, [item.id], unknownCities.joined(separator: ", ")))
            }
            if requiresSource(item), item.officialSourceURL == nil {
                issues.append(issue(.error, .missingSource, [item.id], "Official or high-risk content requires a source"))
            }
            if let verified = item.lastVerifiedAt,
               now.timeIntervalSince(verified) > Double(staleAfterDays) * 86_400 {
                issues.append(issue(.warning, .staleVerificationDate, [item.id], verified.formatted(.iso8601)))
            }
            if item.isMapVisible, item.coordinates?.isValid != true {
                issues.append(issue(.error, .invalidCoordinates, [item.id], "Map-visible item has no valid coordinates"))
            }
            if item.status == .published, !item.isSearchable {
                issues.append(issue(.error, .unreachableThroughGuideOrSearch, [item.id], "Published item is not searchable"))
            }
            if item.status == .published, item.deepLink == nil, item.actionType == .none {
                issues.append(issue(.warning, .unusedObject, [item.id], "No deep link or action"))
            }
        }
        return issues.sorted { ($0.severity.rawValue, $0.kind.rawValue, $0.id) < ($1.severity.rawValue, $1.kind.rawValue, $1.id) }
    }

    private static func requiresSource(_ item: ContentItem) -> Bool {
        item.contentType == .officialService || item.contentType == .emergencyAction || item.emergencyLevel != .none
    }

    private static func duplicateIssues<T, Key: Hashable>(
        _ values: [T],
        key: KeyPath<T, Key>,
        kind: ContentValidationKind,
        severity: ContentValidationSeverity,
        id: (T) -> String = { value in
            if let content = value as? ContentItem { return content.id }
            if let source = value as? SourceReference { return source.id }
            return "unknown"
        }
    ) -> [ContentValidationIssue] {
        let groups = Dictionary(grouping: values, by: { $0[keyPath: key] })
        return groups.values.filter { $0.count > 1 }.map { group in
            let ids = group.map(id).sorted()
            return issue(severity, kind, ids, "Duplicate normalized value")
        }
    }

    private static func issue(
        _ severity: ContentValidationSeverity,
        _ kind: ContentValidationKind,
        _ contentIDs: [ContentID],
        _ detail: String
    ) -> ContentValidationIssue {
        ContentValidationIssue(
            id: "\(kind.rawValue):\(contentIDs.joined(separator: "|"))",
            severity: severity,
            kind: kind,
            contentIDs: contentIDs,
            detail: detail
        )
    }
}
