import Foundation

enum PlaceImageFallbackLevel: String, Equatable {
    case curatedCity = "curated-city"
    case curatedProvince = "curated-province"
    case explicitModelURL = "explicit-model-url"
    case verifiedMedia = "verified-media"
    case figurePortrait = "figure-portrait"
    case figureSymbolicFallback = "figure-symbolic-fallback"
    case provinceFallback = "province-fallback"
    case netherlandsFallback = "netherlands-fallback"
    case bundledEmergencyFallback = "bundled-emergency-fallback"
}

struct ResolvedPlaceImage: Equatable {
    let url: URL?
    let fallbackURLs: [URL]
    let sourceLabel: String
    let fallbackLevel: PlaceImageFallbackLevel
    let attribution: String?
    let sourceRegistry: String
    let localAssetName: String?
    let fallbackSymbolName: String?
    let modelID: String

    var urlString: String? { url?.absoluteString }
    var fallbackURLStrings: [String] { fallbackURLs.map(\.absoluteString) }
    var cacheKey: String {
        ([url].compactMap { $0 } + fallbackURLs).map(\.absoluteString).joined(separator: "|")
    }

    func debugContext(screen: String, entityType: String, entityName: String) -> ImageDebugContext {
        ImageDebugContext(
            screen: screen,
            entityType: entityType,
            entityName: entityName,
            requestedURL: url?.absoluteString ?? "",
            fallbackLevel: fallbackLevel.rawValue,
            sourceRegistry: sourceRegistry,
            modelID: modelID
        )
    }
}

struct ImageDebugContext: Equatable {
    let screen: String
    let entityType: String
    let entityName: String
    let requestedURL: String
    let fallbackLevel: String
    let sourceRegistry: String
    let modelID: String

    init(
        screen: String,
        entityType: String,
        entityName: String,
        requestedURL: String,
        fallbackLevel: String,
        sourceRegistry: String,
        modelID: String = "unknown"
    ) {
        self.screen = screen
        self.entityType = entityType
        self.entityName = entityName
        self.requestedURL = requestedURL
        self.fallbackLevel = fallbackLevel
        self.sourceRegistry = sourceRegistry
        self.modelID = modelID
    }
}

enum ImageDebugLogger {
    static func log(
        context: ImageDebugContext?,
        resolvedURL: String?,
        fallbackLevel: String?,
        cacheKey: String,
        cacheHit: Bool
    ) {
        #if DEBUG
        let context = context ?? ImageDebugContext(
            screen: "unknown",
            entityType: "image",
            entityName: "unknown",
            requestedURL: "",
            fallbackLevel: fallbackLevel ?? "unknown",
            sourceRegistry: "unknown",
            modelID: "unknown"
        )
        print("""
        [IMAGE DEBUG]
        screen=\(context.screen)
        entityType=\(context.entityType)
        entityName=\(context.entityName)
        requestedURL=\(context.requestedURL)
        resolvedURL=\(resolvedURL ?? "")
        fallbackLevel=\(fallbackLevel ?? context.fallbackLevel)
        cacheKey=\(cacheKey)
        cacheHit=\(cacheHit)
        sourceRegistry=\(context.sourceRegistry)
        modelID=\(context.modelID)
        """)
        #endif
    }
}

enum CanonicalPlaceImageResolver {
    static func resolveCityHero(city: NLCity) -> ResolvedPlaceImage {
        resolveCity(
            placeId: city.placeId,
            explicitURLString: city.imageURL,
            entityName: city.name,
            sourceLabel: "NLCity.imageURL"
        )
    }

    static func resolveCityThumbnail(city: NLCity) -> ResolvedPlaceImage {
        resolveCityVisual(
            placeId: city.placeId,
            role: .thumbnail,
            entityName: city.name,
            fallback: resolveCityHero(city: city)
        )
    }

    static func resolveProvinceCityCard(city: NLCity) -> ResolvedPlaceImage {
        resolveCityVisual(
            placeId: city.placeId,
            role: .card,
            entityName: city.name,
            fallback: resolveCityHero(city: city)
        )
    }

    static func resolveCityHero(city: CityItem) -> ResolvedPlaceImage {
        let placeId = city.media.heroImage?.placeId
            ?? CuratedPlaceHeroMediaRegistry.cityPlaceId(cityName: city.name, provinceName: city.province)
        return resolveCity(
            placeId: placeId,
            mediaAsset: city.media.heroImage,
            explicitURLString: city.media.heroImage?.url,
            entityName: city.name,
            sourceLabel: "CityItem.media.heroImage"
        )
    }

    static func resolveCityThumbnail(city: CityItem) -> ResolvedPlaceImage {
        let placeId = city.media.heroImage?.placeId
            ?? CuratedPlaceHeroMediaRegistry.cityPlaceId(cityName: city.name, provinceName: city.province)
        return resolveCityVisual(
            placeId: placeId,
            role: .thumbnail,
            entityName: city.name,
            fallback: resolveCityHero(city: city)
        )
    }

    static func resolveProvinceCityCard(city: CityItem) -> ResolvedPlaceImage {
        let placeId = city.media.heroImage?.placeId
            ?? CuratedPlaceHeroMediaRegistry.cityPlaceId(cityName: city.name, provinceName: city.province)
        let resolved = resolveCityVisual(
            placeId: placeId,
            role: .card,
            entityName: city.name,
            fallback: resolveCityHero(city: city)
        )
        #if DEBUG
        if let cityURL = resolved.url,
           let provinceURL = CuratedPlaceHeroMediaRegistry.media(
            for: CuratedPlaceHeroMediaRegistry.provincePlaceId(provinceName: city.province)
           )?.remoteURL,
           cityURL == provinceURL,
           CuratedPlaceHeroMediaRegistry.media(
            for: CuratedPlaceHeroMediaRegistry.cityPlaceId(cityName: city.name, provinceName: city.province)
           )?.remoteURL != nil {
            assertionFailure("[IMAGE ASSERT] Province city card for \(city.name) resolved to province hero despite city-specific media: \(cityURL.absoluteString)")
        }
        #endif
        return resolved
    }

    static func resolveProvinceHero(province: NLProvince) -> ResolvedPlaceImage {
        let placeId = CuratedPlaceHeroMediaRegistry.provincePlaceId(provinceName: province.id)
        return resolveProvince(
            placeId: placeId,
            mediaAsset: nil,
            explicitURLString: province.imageURL,
            entityName: province.name,
            sourceLabel: "NLProvince.imageURL"
        )
    }

    static func resolveProvinceHero(province: ProvinceItem) -> ResolvedPlaceImage {
        resolveProvince(
            placeId: province.placeId,
            mediaAsset: province.media.heroImage,
            explicitURLString: province.media.heroImage?.url,
            entityName: province.id,
            sourceLabel: "ProvinceItem.media.heroImage"
        )
    }

    static func resolveFigureThumbnail(figure: HistoricalFigure) -> ResolvedPlaceImage {
        let url = validURL(figure.imageURL)
        let resolved = ResolvedPlaceImage(
            url: url,
            fallbackURLs: [],
            sourceLabel: url == nil ? "HistoricalFigure.symbolicFallback" : "HistoricalFigure.imageURL",
            fallbackLevel: url == nil ? .figureSymbolicFallback : .figurePortrait,
            attribution: url == nil ? nil : "Portrait media verified for \(figure.name)",
            sourceRegistry: "HistoricalFigure",
            localAssetName: nil,
            fallbackSymbolName: figureFallbackSymbol(field: figure.fieldEN, id: figure.id),
            modelID: figure.id
        )

        #if DEBUG
        if let url, isPlaceLandscapeURL(url.absoluteString) {
            assertionFailure("[IMAGE ASSERT] Figure \(figure.name) uses a place/province landscape URL: \(url.absoluteString)")
        }
        #endif

        return resolved
    }

    static func resolvePlaceImage(place: Attraction) -> ResolvedPlaceImage {
        let url = validURL(place.imageURL)
        let resolved = ResolvedPlaceImage(
            url: url,
            fallbackURLs: [],
            sourceLabel: url == nil ? "Generated place artwork" : "Attraction.imageURL",
            fallbackLevel: url == nil ? .bundledEmergencyFallback : .explicitModelURL,
            attribution: url == nil ? nil : "Place media verified for \(place.name)",
            sourceRegistry: "NetherlandsData.Attraction",
            localAssetName: nil,
            fallbackSymbolName: "mappin.and.ellipse",
            modelID: place.id
        )

        #if DEBUG
        if isDeniedDenHaagPlaceURL(placeName: place.name, urlString: resolved.urlString ?? "") {
            assertionFailure("[IMAGE ASSERT] Den Haag place \(place.name) resolved to windmill imagery: \(resolved.urlString ?? "")")
        }
        #endif

        return resolved
    }

    static func assertUniqueVisibleCityImages(_ images: [(name: String, image: ResolvedPlaceImage)], screen: String) {
        #if DEBUG
        let grouped = Dictionary(grouping: images.compactMap { item -> (String, String)? in
            guard let url = item.image.url?.absoluteString else { return nil }
            return (url, item.name)
        }, by: { $0.0 })

        let duplicates = grouped.filter { $0.value.count > 1 }
        if !duplicates.isEmpty {
            let details = duplicates.map { url, values in
                "\(url): \(values.map(\.1).joined(separator: ", "))"
            }.joined(separator: " | ")
            assertionFailure("[IMAGE ASSERT] Duplicate visible city images on \(screen): \(details)")
        }
        #endif
    }

    private static func resolveCity(
        placeId: String,
        mediaAsset: CityMediaAsset? = nil,
        explicitURLString: String?,
        entityName: String,
        sourceLabel: String
    ) -> ResolvedPlaceImage {
        if let curated = CuratedPlaceHeroMediaRegistry.media(for: placeId),
           let remoteURL = curated.remoteURL {
            let resolved = ResolvedPlaceImage(
                url: remoteURL,
                fallbackURLs: [],
                sourceLabel: "CuratedPlaceHeroMediaRegistry.media",
                fallbackLevel: .curatedCity,
                attribution: curated.license,
                sourceRegistry: "CuratedPlaceHeroMediaRegistry",
                localAssetName: curated.assetName,
                fallbackSymbolName: "building.2.crop.circle",
                modelID: placeId
            )
            assertCityHero(entityName: entityName, placeId: placeId, resolved: resolved)
            return resolved
        }

        if let asset = mediaAsset,
           asset.verified,
           asset.type == .heroImage,
           let url = validURL(asset.thumbnailURL ?? asset.imageURL ?? asset.url) {
            let resolved = ResolvedPlaceImage(
                url: url,
                fallbackURLs: [],
                sourceLabel: "VerifiedPlaceMediaRegistry.media",
                fallbackLevel: .verifiedMedia,
                attribution: asset.attribution,
                sourceRegistry: "VerifiedPlaceMediaRegistry",
                localAssetName: asset.localAssetName,
                fallbackSymbolName: "building.2.crop.circle",
                modelID: placeId
            )
            assertCityHero(entityName: entityName, placeId: placeId, resolved: resolved)
            return resolved
        }

        if let explicit = validURL(explicitURLString) {
            let resolved = ResolvedPlaceImage(
                url: explicit,
                fallbackURLs: [],
                sourceLabel: sourceLabel,
                fallbackLevel: .explicitModelURL,
                attribution: "Explicit model image for \(entityName)",
                sourceRegistry: "Model field",
                localAssetName: nil,
                fallbackSymbolName: "building.2.crop.circle",
                modelID: placeId
            )
            assertCityHero(entityName: entityName, placeId: placeId, resolved: resolved)
            return resolved
        }

        return ResolvedPlaceImage(
            url: nil,
            fallbackURLs: [],
            sourceLabel: "Generated city artwork",
            fallbackLevel: .bundledEmergencyFallback,
            attribution: nil,
            sourceRegistry: "CuratedPlaceHeroMediaRegistry",
            localAssetName: CuratedPlaceHeroMediaRegistry.bundledEmergencyFallbackAssetName,
            fallbackSymbolName: "building.2.crop.circle",
            modelID: placeId
        )
    }

    private static func resolveCityVisual(
        placeId: String,
        role: CityVisualRole,
        entityName: String,
        fallback: ResolvedPlaceImage
    ) -> ResolvedPlaceImage {
        guard let visual = CuratedPlaceHeroMediaRegistry.cityVisual(for: placeId, role: role),
              let remoteURL = visual.remoteURL else {
            return fallback
        }

        return ResolvedPlaceImage(
            url: remoteURL,
            fallbackURLs: [],
            sourceLabel: "CuratedPlaceHeroMediaRegistry.cityVisual.\(role.rawValue)",
            fallbackLevel: .curatedCity,
            attribution: visual.license,
            sourceRegistry: "CuratedPlaceHeroMediaRegistry.cityVisualsByPlaceId",
            localAssetName: visual.assetName,
            fallbackSymbolName: "building.2.crop.circle",
            modelID: "\(placeId)#\(role.rawValue)"
        )
    }

    private static func resolveProvince(
        placeId: String,
        mediaAsset: CityMediaAsset?,
        explicitURLString: String?,
        entityName: String,
        sourceLabel: String
    ) -> ResolvedPlaceImage {
        if let curated = CuratedPlaceHeroMediaRegistry.media(for: placeId),
           let remoteURL = curated.remoteURL {
            return ResolvedPlaceImage(
                url: remoteURL,
                fallbackURLs: [],
                sourceLabel: "CuratedPlaceHeroMediaRegistry.media",
                fallbackLevel: .curatedProvince,
                attribution: curated.license,
                sourceRegistry: "CuratedPlaceHeroMediaRegistry",
                localAssetName: curated.assetName,
                fallbackSymbolName: "map.fill",
                modelID: placeId
            )
        }

        if let asset = mediaAsset,
           asset.verified,
           asset.type == .heroImage,
           let url = validURL(asset.thumbnailURL ?? asset.imageURL ?? asset.url) {
            return ResolvedPlaceImage(
                url: url,
                fallbackURLs: [],
                sourceLabel: "VerifiedPlaceMediaRegistry.media",
                fallbackLevel: .verifiedMedia,
                attribution: asset.attribution,
                sourceRegistry: "VerifiedPlaceMediaRegistry",
                localAssetName: asset.localAssetName,
                fallbackSymbolName: "map.fill",
                modelID: placeId
            )
        }

        if let explicit = validURL(explicitURLString) {
            return ResolvedPlaceImage(
                url: explicit,
                fallbackURLs: [],
                sourceLabel: sourceLabel,
                fallbackLevel: .explicitModelURL,
                attribution: "Explicit model image for \(entityName)",
                sourceRegistry: "Model field",
                localAssetName: nil,
                fallbackSymbolName: "map.fill",
                modelID: placeId
            )
        }

        return ResolvedPlaceImage(
            url: nil,
            fallbackURLs: [],
            sourceLabel: "Generated province artwork",
            fallbackLevel: .bundledEmergencyFallback,
            attribution: nil,
            sourceRegistry: "CuratedPlaceHeroMediaRegistry",
            localAssetName: CuratedPlaceHeroMediaRegistry.bundledEmergencyFallbackAssetName,
            fallbackSymbolName: "map.fill",
            modelID: placeId
        )
    }

    private static func validURL(_ raw: String?) -> URL? {
        guard let raw = raw?.trimmingCharacters(in: .whitespacesAndNewlines),
              raw.lowercased().hasPrefix("https://") || raw.lowercased().hasPrefix("http://"),
              let url = URL(string: raw) else { return nil }
        return url
    }

    private static func figureFallbackSymbol(field: String, id: String) -> String {
        let searchable = "\(field) \(id)".lowercased()
        if searchable.contains("paint") || searchable.contains("artist") || searchable.contains("vermeer") || searchable.contains("rembrandt") || searchable.contains("gogh") {
            return "paintpalette.fill"
        }
        if searchable.contains("philosoph") || searchable.contains("humanist") || searchable.contains("scholar") {
            return "book.closed.fill"
        }
        if searchable.contains("science") || searchable.contains("physic") || searchable.contains("astronom") || searchable.contains("microbiology") {
            return "atom"
        }
        if searchable.contains("diarist") || searchable.contains("literature") {
            return "pencil.and.outline"
        }
        if searchable.contains("state") || searchable.contains("nation") || searchable.contains("orange") {
            return "crown.fill"
        }
        if searchable.contains("law") {
            return "scalemass.fill"
        }
        return "person.crop.square.fill"
    }

    private static func isPlaceLandscapeURL(_ urlString: String) -> Bool {
        let lowercased = urlString.lowercased()
        return [
            "kinderdijk",
            "windmill",
            "windmills",
            "dom_tower",
            "erasmusbrug",
            "oudegracht",
            "john_frost",
            "haarlemgrotemarkt",
            "martinitoren",
            "magisch_maastricht"
        ].contains { lowercased.contains($0) }
    }

    private static func isDeniedDenHaagPlaceURL(placeName: String, urlString: String) -> Bool {
        let place = placeName.lowercased()
        guard ["binnenhof", "peace palace", "scheveningen", "mauritshuis"].contains(where: { place.contains($0) }) else {
            return false
        }
        let url = urlString.lowercased()
        return url.contains("kinderdijk") || url.contains("windmill") || url.contains("molen")
    }

    private static func assertCityHero(entityName: String, placeId: String, resolved: ResolvedPlaceImage) {
        #if DEBUG
        guard let urlString = resolved.urlString?.lowercased() else { return }
        if entityName.caseInsensitiveCompare("Haarlem") == .orderedSame,
           urlString.contains("cloud") || urlString.contains("sky") {
            assertionFailure("[IMAGE ASSERT] Haarlem resolved to sky/cloud imagery: \(urlString)")
        }
        if resolved.fallbackLevel == .netherlandsFallback,
           CuratedPlaceHeroMediaRegistry.media(for: placeId)?.remoteURL != nil {
            assertionFailure("[IMAGE ASSERT] \(entityName) resolved to Netherlands fallback despite city-specific media.")
        }
        #endif
    }
}
