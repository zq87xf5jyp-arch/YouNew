import Foundation
import OSLog

struct DataProjectRuntimeLoadResult {
    let entities: [NetherlandsKnowledgeEntity]
    let migrationRegistry: [String: DataProjectMigration]

    static let empty = DataProjectRuntimeLoadResult(entities: [], migrationRegistry: [:])
}

struct DataProjectMigration: Decodable {
    let canonicalID: String
    let status: String

    var retiresLegacyRuntimeRecord: Bool {
        ["migrated", "verified", "retired"].contains(status)
    }
}

enum DataProjectRuntimeLoader {
    private static let logger = Logger(subsystem: "com.younew.app", category: "DataProjectRuntime")

    static func load(bundle: Bundle = .main) -> DataProjectRuntimeLoadResult {
        guard let url = runtimeArtifactURL(bundle: bundle) else {
            logger.error("Canonical runtime artifact is missing; using legacy fallback")
            return .empty
        }

        do {
            let artifactData = try Data(contentsOf: url, options: .mappedIfSafe)
            return load(data: artifactData)
        } catch {
            logger.error("Canonical runtime artifact could not be read: \(error.localizedDescription, privacy: .public); using legacy fallback")
            return .empty
        }
    }

    static func load(data artifactData: Data) -> DataProjectRuntimeLoadResult {
        do {
            let artifact = try JSONDecoder().decode(RuntimeArtifact.self, from: artifactData)
            guard artifact.schemaVersion == 1, artifact.mode == "production" else {
                logger.error("Canonical runtime artifact has an unsupported schema or non-production mode; using legacy fallback")
                return .empty
            }
            let entities = artifact.entities.compactMap { record -> NetherlandsKnowledgeEntity? in
                guard record.publicationStatus == "published", record.verificationStatus == "verified" else {
                    logger.warning("Excluded non-published canonical entity: \(record.id, privacy: .public)")
                    return nil
                }
                return record.entity
            }
            logger.info("Loaded \(entities.count, privacy: .public) canonical Data Project entities")
            return DataProjectRuntimeLoadResult(entities: entities, migrationRegistry: artifact.migrationRegistry)
        } catch {
            logger.error("Canonical runtime artifact failed to decode: \(error.localizedDescription, privacy: .public); using legacy fallback")
            return .empty
        }
    }

    private static func runtimeArtifactURL(bundle: Bundle) -> URL? {
        bundle.url(forResource: "younew-runtime-data", withExtension: "json", subdirectory: "Resources/Data")
            ?? bundle.url(forResource: "younew-runtime-data", withExtension: "json")
    }
}

private struct RuntimeArtifact: Decodable {
    let schemaVersion: Int
    let mode: String
    let migrationRegistry: [String: DataProjectMigration]
    let entities: [RuntimeEntity]
}

private struct RuntimeEntity: Decodable {
    let id: String
    let kind: NetherlandsEntityKind
    let title: String
    let summary: String
    let cityId: String?
    let provinceId: String?
    let category: String
    let coordinate: NetherlandsDataCoordinate?
    let source: RuntimeSource
    let lastChecked: String
    let images: [RuntimeMedia]
    let aiSummary: String
    let relatedEntityIDs: [String]
    let attributes: [String: String]
    let keywords: [String]
    let publicationStatus: String
    let verificationStatus: String

    var entity: NetherlandsKnowledgeEntity {
        let visualSet = NetherlandsVisualSet(
            hero: image(role: "hero"),
            gallery: images.filter { $0.role == "gallery" }.compactMap { $0.asset(title: title) },
            thumbnail: image(role: "thumbnail"),
            mapPreview: image(role: "map_preview"),
            categoryCover: image(role: "category_cover")
        )
        return NetherlandsKnowledgeEntity(
            id: id,
            kind: kind,
            title: title,
            summary: summary,
            cityId: cityId,
            provinceId: provinceId,
            category: category,
            coordinate: coordinate,
            source: source.officialSource,
            lastChecked: lastChecked,
            images: visualSet,
            aiSummary: aiSummary,
            relatedEntityIDs: relatedEntityIDs,
            route: runtimeRoute,
            attributes: attributes,
            keywords: keywords,
            explicitPersonaTags: nil
        )
    }

    private func image(role: String) -> AppImageAsset? {
        images.first(where: { $0.role == role })?.asset(title: title)
    }

    private var runtimeRoute: AppDestination? {
        let normalized = KnowledgeNormalizer.normalize("\(category) \(title)")
        switch kind {
        case .city:
            return .nlCityDetail(cityId ?? id)
        case .place, .attraction, .museum, .park, .restaurant, .cafe, .hotel, .healthcare, .university, .transport, .localPartner, .event:
            // A published Data Project record is itself a supported detail
            // destination. The map remains a consumer of its coordinates, but
            // using the map hub as the record's route discards the record's
            // description, sources and Saved action after a Search/Guide tap.
            return .guideArticle(sectionID: "data-project", articleID: id)
        case .governmentService:
            return .governmentHub
        case .knowledgeTopic, .checklist:
            if normalized.contains("health") { return .healthSection(.overview) }
            if normalized.contains("housing") || normalized.contains("rent") { return .housingSection(.overview) }
            if normalized.contains("transport") || normalized.contains("bicycle") || normalized.contains("rail") { return .transportSection(.overview) }
            if normalized.contains("tax") || normalized.contains("government") || normalized.contains("registration") || normalized.contains("digid") { return .governmentHub }
            if normalized.contains("work") { return .workSection(.overview) }
            if normalized.contains("education") { return .educationSection(.overview) }
            return .searchList
        case .officialSource:
            return .officialSources
        case .country, .province, .district:
            return nil
        }
    }
}

private struct RuntimeSource: Decodable {
    let title: String
    let publisher: String
    let url: URL

    var officialSource: OfficialSource {
        OfficialSource(title: title, url: url, institution: publisher)
    }
}

private struct RuntimeMedia: Decodable {
    let id: String
    let role: String
    let assetURL: URL
    let sourcePageURL: URL
    let license: String
    let licenseURL: URL
    let attribution: String
    let verified: Bool
    let retrievedAt: String

    func asset(title: String) -> AppImageAsset? {
        guard verified else { return nil }
        return AppImageAsset(
            id: id,
            url: assetURL,
            sourcePageURL: sourcePageURL,
            imageURL: assetURL,
            thumbnailURL: assetURL,
            title: title,
            description: "Licensed Data Project visual for \(title)",
            sourceName: sourcePageURL.host ?? "Verified source",
            sourceURL: sourcePageURL,
            license: license,
            licenseName: license,
            licenseURL: licenseURL,
            attribution: attribution,
            width: nil,
            height: nil,
            type: .cardThumbnail,
            verified: verified,
            retrievedAt: retrievedAt
        )
    }
}
