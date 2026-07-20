import Foundation

enum ContentValidationSeverity: String, Codable, Hashable, Sendable {
    case error
    case warning
}

enum ContentValidationKind: String, Codable, Hashable, Sendable {
    case duplicateID
    case duplicateCanonicalURL
    case duplicateNormalizedTitle
    case duplicateNormalizedBody
    case semanticDuplicateBody
    case unknownCategory
    case unknownCity
    case missingSource
    case staleVerificationDate
    case unusedObject
    case unreachableThroughGuideOrSearch
    case invalidCoordinates
}

struct ContentValidationIssue: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let severity: ContentValidationSeverity
    let kind: ContentValidationKind
    let contentIDs: [ContentID]
    let detail: String
}

struct ContentMigrationMetrics: Codable, Hashable, Sendable {
    let sourceObjects: Int
    let migratedObjects: Int
    let duplicatesMerged: Int
    let referencesUpdated: Int
    let lostObjects: Int
    let remainingErrors: Int
    let remainingWarnings: Int
}

struct ContentRepository: Sendable {
    static let netherlands = Country(
        id: "nl",
        name: "Netherlands",
        localName: "Nederland",
        isoCode: "NL"
    )

    nonisolated static let shared = ContentRepository(
        legacyItems: KnowledgeIndex.shared.items,
        performsValidation: runtimePerformsValidation
    )

    private static let canonicalPlaces = makePlaces(cities: makeCities())

    private static var runtimePerformsValidation: Bool {
#if DEBUG
        // Unit/static QA constructs repositories directly and retains full
        // validation. The app runtime only opts in explicitly, avoiding the
        // quadratic semantic-duplicate audit during normal Debug launches.
        return ProcessInfo.processInfo.arguments.contains("-validateContentRepository")
#else
        // Release content has passed the publication/static-QA gates already.
        return false
#endif
    }

    let items: [ContentItem]
    let categories: [Category]
    let countries: [Country]
    let provinces: [Province]
    let cities: [City]
    var places: [Place] { Self.canonicalPlaces }
    let sources: [SourceReference]
    let relations: [ContentRelation]
    let aliases: [ContentID: ContentID]
    let validationIssues: [ContentValidationIssue]
    let metrics: ContentMigrationMetrics

    private let itemsByID: [ContentID: ContentItem]
    private let sourcesByID: [SourceID: SourceReference]
    private let searchableItemsSnapshot: [ContentItem]
    private let mapItemsSnapshot: [ContentItem]

    init(legacyItems: [KnowledgeItem], now: Date = Date(), performsValidation: Bool = true) {
        categories = Category.canonical
        countries = [Self.netherlands]
        provinces = Self.makeProvinces()
        cities = Self.makeCities()
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
        var duplicateContentCount = 0
        var canonicalIDByFingerprint: [String: ContentID] = [:]

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
            let fingerprint = Self.canonicalFingerprint(item)
            if let existingID = canonicalIDByFingerprint[fingerprint] {
                duplicateContentCount += 1
                duplicateAliases[legacy.id] = existingID
                continue
            }
            canonicalItems.append(item)
            canonicalByID[item.id] = item
            canonicalIDByFingerprint[fingerprint] = item.id
        }

        items = canonicalItems
        itemsByID = canonicalByID
        searchableItemsSnapshot = canonicalItems.filter { $0.status == .published && $0.isSearchable }
        mapItemsSnapshot = canonicalItems.filter {
            $0.status == .published && $0.isMapVisible && $0.coordinates?.isValid == true
        }
        aliases = duplicateAliases
        validationIssues = performsValidation
            ? ContentRepositoryValidator.validate(
                items: canonicalItems,
                categories: categories,
                cities: cities,
                sources: sources,
                now: now
            )
            : []

        let errors = validationIssues.filter { $0.severity == .error }.count
        let warnings = validationIssues.filter { $0.severity == .warning }.count
        metrics = ContentMigrationMetrics(
            sourceObjects: legacyItems.count,
            migratedObjects: canonicalItems.count,
            duplicatesMerged: duplicateIDCount + duplicateContentCount + sourceMergeCount,
            referencesUpdated: duplicateAliases.count,
            lostObjects: legacyItems.count - canonicalItems.count - duplicateIDCount - duplicateContentCount,
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

    func legacyDestination(id: ContentID) -> AppDestination? {
        let canonicalID = aliases[id] ?? id
        return KnowledgeIndex.shared.itemsByID[canonicalID]?.route
    }

    func destination(id: ContentID) -> AppDestination? {
        let canonicalID = aliases[id] ?? id
        if let route = KnowledgeIndex.shared.itemsByID[canonicalID]?.route {
            return route
        }
        guard let item = itemsByID[canonicalID], item.status == .published else { return nil }
        return .guideArticle(sectionID: GuideContent.dataProjectSectionID, articleID: canonicalID)
    }

    nonisolated func guideItems(categoryID: CategoryID? = nil) -> [ContentItem] {
        items.filter { item in
            item.status == .published && (categoryID == nil || item.primaryCategoryID == categoryID)
        }
        .sorted { ($0.priority, $0.title) > ($1.priority, $1.title) }
    }

    func searchableItems() -> [ContentItem] {
        searchableItemsSnapshot
    }

    func mapItems() -> [ContentItem] {
        mapItemsSnapshot
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
    static func canonicalFingerprint(_ item: ContentItem) -> String {
        [
            item.normalizedTitle,
            item.normalizedBody,
            item.cityIDs.sorted().joined(separator: ","),
            item.provinceID ?? "",
            item.placeID ?? ""
        ].joined(separator: "|")
    }

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
        return ProvinceCatalog.mapCities.compactMap { city in
            let normalizedProvince = ContentNormalization.text(city.province)
            let provinceID = provinceByName[normalizedProvince]
                ?? provinceByName.first(where: { key, _ in
                    key.contains(normalizedProvince) || normalizedProvince.contains(key)
                })?.value
            guard let provinceID else { return nil }
            return City(
                id: city.id,
                countryID: netherlands.id,
                provinceID: provinceID,
                name: city.name,
                localName: city.name,
                center: GeoCoordinates(latitude: city.latitude, longitude: city.longitude)
            )
        }
    }

    static func makePlaces(cities: [City]) -> [Place] {
        let citiesByName = cities.reduce(into: [String: City]()) { result, city in
            result[ContentNormalization.text(city.name)] = city
            result[ContentNormalization.text(city.localName)] = city
        }

        return CanonicalPlaceCatalog.items.compactMap { item in
            guard let coordinates = item.coordinates,
                  let city = citiesByName[ContentNormalization.text(item.cityId)]
            else { return nil }

            return Place(
                id: item.id,
                countryID: netherlands.id,
                provinceID: city.provinceID,
                cityID: city.id,
                name: item.title,
                localName: item.shortTitle,
                coordinates: GeoCoordinates(latitude: coordinates.lat, longitude: coordinates.lng),
                officialSourceID: nil
            )
        }
        .sorted { $0.id < $1.id }
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
        issues += duplicateTitleIssues(items)
        issues += duplicateBodyIssues(items)
        issues += semanticDuplicateIssues(items)
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

    private static func semanticDuplicateIssues(_ items: [ContentItem]) -> [ContentValidationIssue] {
        let candidates = items.compactMap { item -> (ContentItem, Set<String>)? in
            let tokens = Set(item.normalizedBody.split(separator: " ").map(String.init))
            return tokens.count >= 8 ? (item, tokens) : nil
        }
        var results: [ContentValidationIssue] = []
        for leftIndex in candidates.indices {
            for rightIndex in candidates.index(after: leftIndex)..<candidates.endIndex {
                let left = candidates[leftIndex]
                let right = candidates[rightIndex]
                guard left.0.id != right.0.id,
                      left.0.normalizedBody != right.0.normalizedBody,
                      geographicScopeKey(left.0) == geographicScopeKey(right.0)
                else { continue }
                let union = left.1.union(right.1)
                guard !union.isEmpty else { continue }
                let similarity = Double(left.1.intersection(right.1).count) / Double(union.count)
                if similarity >= 0.86 {
                    results.append(issue(
                        .warning,
                        .semanticDuplicateBody,
                        [left.0.id, right.0.id].sorted(),
                        "Near-duplicate descriptions (Jaccard \(String(format: "%.2f", similarity)))"
                    ))
                }
            }
        }
        return results
    }

    private static func duplicateTitleIssues(_ items: [ContentItem]) -> [ContentValidationIssue] {
        let titleGroups = Dictionary(
            grouping: items.filter { !$0.normalizedTitle.isEmpty },
            by: \.normalizedTitle
        )
        var results: [ContentValidationIssue] = []

        for group in titleGroups.values where group.count > 1 {
            let scopedGroups = Dictionary(grouping: group) { item in
                geographicScopeKey(item)
            }
            for scopedGroup in scopedGroups.values where scopedGroup.count > 1 {
                let ids = scopedGroup.map(\.id).sorted()
                results.append(issue(
                    .warning,
                    .duplicateNormalizedTitle,
                    ids,
                    "Duplicate normalized title within the same geographic scope"
                ))
            }
        }
        return results
    }

    private static func duplicateBodyIssues(_ items: [ContentItem]) -> [ContentValidationIssue] {
        let bodyGroups = Dictionary(
            grouping: items.filter { !$0.normalizedBody.isEmpty },
            by: \.normalizedBody
        )
        var results: [ContentValidationIssue] = []

        for group in bodyGroups.values where group.count > 1 {
            let scopedGroups = Dictionary(grouping: group, by: geographicScopeKey)
            for scopedGroup in scopedGroups.values where scopedGroup.count > 1 {
                results.append(issue(
                    .warning,
                    .duplicateNormalizedBody,
                    scopedGroup.map(\.id).sorted(),
                    "Duplicate normalized body within the same geographic scope"
                ))
            }
        }
        return results
    }

    nonisolated private static func geographicScopeKey(_ item: ContentItem) -> String {
        if !item.cityIDs.isEmpty {
            return "cities:\(item.cityIDs.sorted().joined(separator: ","))"
        }
        if let provinceID = item.provinceID {
            return "province:\(provinceID)"
        }
        return "national"
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
