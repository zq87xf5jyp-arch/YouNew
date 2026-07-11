import Foundation

enum AppImageType: String, Codable, Equatable {
    case timeline
    case historyHero
    case historyContext
    case homeHero
    case cityHero
    case provinceHero
    case cultureHero
    case transportHero
    case officialSourcesHero
    case sideMenuHero
    case officialSymbol
    case cardThumbnail
}

struct AppImageAsset: Identifiable, Codable, Equatable {
    let id: String
    let url: URL?
    let sourcePageURL: URL?
    let imageURL: URL?
    let thumbnailURL: URL?
    let originalFileURL: URL?
    let localAssetName: String?
    let title: String
    let description: String?
    let sourceName: String
    let sourceURL: URL?
    let creator: String?
    let author: String?
    let license: String?
    let licenseName: String?
    let licenseURL: URL?
    let attribution: String?
    let width: Int?
    let height: Int?
    let aspectRatio: Double?
    let type: AppImageType
    let verified: Bool
    let retrievedAt: String?
    let titleKey: String?
    let descriptionKey: String?

    init(
        id: String,
        url: URL?,
        sourcePageURL: URL? = nil,
        imageURL: URL? = nil,
        thumbnailURL: URL? = nil,
        originalFileURL: URL? = nil,
        localAssetName: String? = nil,
        title: String,
        description: String? = nil,
        sourceName: String,
        sourceURL: URL?,
        creator: String? = nil,
        author: String? = nil,
        license: String?,
        licenseName: String? = nil,
        licenseURL: URL? = nil,
        attribution: String?,
        width: Int?,
        height: Int?,
        aspectRatio: Double? = nil,
        type: AppImageType,
        verified: Bool,
        retrievedAt: String? = nil,
        titleKey: String? = nil,
        descriptionKey: String? = nil
    ) {
        let resolvedSourcePageURL = sourcePageURL ?? sourceURL
        let resolvedImageURL = imageURL ?? url
        let resolvedThumbnailURL = thumbnailURL ?? url
        let resolvedLicenseName = licenseName ?? license
        let resolvedAuthor = author ?? creator
        let resolvedAspectRatio = aspectRatio ?? Self.makeAspectRatio(width: width, height: height)

        self.id = id
        self.url = url ?? resolvedThumbnailURL ?? resolvedImageURL
        self.sourcePageURL = resolvedSourcePageURL
        self.imageURL = resolvedImageURL
        self.thumbnailURL = resolvedThumbnailURL
        self.originalFileURL = originalFileURL
        self.localAssetName = localAssetName
        self.title = title
        self.description = description
        self.sourceName = sourceName
        self.sourceURL = sourceURL ?? resolvedSourcePageURL
        self.creator = creator ?? resolvedAuthor
        self.author = resolvedAuthor
        self.license = license ?? resolvedLicenseName
        self.licenseName = resolvedLicenseName
        self.licenseURL = licenseURL
        self.attribution = attribution
        self.width = width
        self.height = height
        self.aspectRatio = resolvedAspectRatio
        self.type = type
        self.verified = verified
        self.retrievedAt = retrievedAt
        self.titleKey = titleKey
        self.descriptionKey = descriptionKey
    }

    func displayTitle(_ language: AppLanguage) -> String {
        guard let titleKey else { return title }
        let localized = L10n.t(titleKey, language)
        return localized == titleKey ? title : localized
    }

    func displayDescription(_ language: AppLanguage) -> String? {
        guard let descriptionKey else { return description }
        let localized = L10n.t(descriptionKey, language)
        return localized == descriptionKey ? description : localized
    }

    private static func makeAspectRatio(width: Int?, height: Int?) -> Double? {
        guard let width, let height, height > 0 else { return nil }
        return Double(width) / Double(height)
    }
}

extension CityMediaAsset {
    func appImageAsset(
        id: String,
        title: String,
        description: String? = nil,
        type: AppImageType,
        sourceURL: URL? = nil,
        fallbackURL: URL? = nil
    ) -> AppImageAsset? {
        guard verified else { return nil }

        return AppImageAsset(
            id: id,
            url: url.flatMap(URL.init(string:)),
            sourcePageURL: sourcePageURL.flatMap(URL.init(string:)),
            imageURL: imageURL.flatMap(URL.init(string:)),
            thumbnailURL: thumbnailURL.flatMap(URL.init(string:)),
            originalFileURL: fallbackURL,
            localAssetName: localAssetName,
            title: title,
            description: description,
            sourceName: source ?? "Verified source",
            sourceURL: sourceURL ?? sourcePageURL.flatMap(URL.init(string:)) ?? url.flatMap(URL.init(string:)),
            license: license,
            licenseName: license,
            attribution: attribution,
            width: pixelWidth,
            height: pixelHeight,
            type: type,
            verified: verified
        )
    }
}

extension CuratedPlaceVisualMedia {
    func appImageAsset(id: String? = nil, type: AppImageType = .cityHero) -> AppImageAsset {
        AppImageAsset(
            id: id ?? "\(placeId)-\(role)",
            url: remoteURL,
            sourcePageURL: sourceURL,
            imageURL: remoteURL,
            thumbnailURL: remoteURL,
            localAssetName: nil,
            title: title,
            description: why,
            sourceName: "Wikimedia Commons",
            sourceURL: sourceURL ?? remoteURL,
            creator: nil,
            author: nil,
            license: license,
            licenseName: license,
            licenseURL: nil,
            attribution: "Wikimedia Commons contributors",
            width: minimumPixelWidth,
            height: nil,
            aspectRatio: 16.0 / 10.0,
            type: type,
            verified: true,
            retrievedAt: "2026-06-27"
        )
    }
}
