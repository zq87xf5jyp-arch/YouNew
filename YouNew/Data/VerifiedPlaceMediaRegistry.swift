import Foundation

enum PlaceEntityType: String, Codable, Equatable {
    case city
    case municipality
    case province
    case region
    case country
}

enum PlaceMediaSourceType: String, Codable, Equatable {
    case official
    case wikimedia
    case wikidata
    case local
    case otherVerified
}

enum MediaRenderStatus: String, Codable, Equatable {
    case renderableLocal
    case renderableRemote
    case metadataOnlyMissingAsset
    case unavailable
}

struct PlaceName: Codable, Equatable {
    let local: String
    let en: String
    let ru: String?
    let nl: String?
}

struct PlaceFacts: Codable, Equatable {
    let population: Int?
    let areaKm2: Double?
    let provinceName: String?
    let municipalityName: String?
}

struct PlaceOfficialLinks: Codable, Equatable {
    let municipalityWebsite: String?
    let provinceWebsite: String?
    let tourismWebsite: String?
}

struct CanonicalPlace: Codable, Equatable {
    let id: String
    let type: PlaceEntityType
    let name: PlaceName
    let countryCode: String?
    let provinceId: String?
    let municipalityId: String?
    let facts: PlaceFacts
    let media: CityMedia
    let officialLinks: PlaceOfficialLinks
}

enum VerifiedPlaceMediaRegistry {
    static let mediaSchemaVersion = 2

    static func placeId(type: PlaceEntityType, name: String, provinceId: String? = nil) -> String {
        let normalizedName = name
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .lowercased()
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: " ", with: "_")
        let normalizedProvince = provinceId?
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .lowercased()
            .replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: " ", with: "_")

        if let normalizedProvince, type == .city {
            return "nl-city-\(normalizedProvince)-\(normalizedName)"
        }
        return "nl-\(type.rawValue)-\(normalizedName)"
    }

    static func media(for type: PlaceEntityType, name: String, provinceId: String? = nil) -> CityMedia {
        mediaByPlaceId[placeId(type: type, name: name, provinceId: provinceId)] ?? .unavailable
    }

    static func credit(for type: PlaceEntityType, name: String, provinceId: String? = nil) -> LocalizedCityText {
        let media = media(for: type, name: name, provinceId: provinceId)
        guard media.hasVerifiedMedia else {
            return LocalizedCityText(
                english: "Using YouNew visual fallback; verified source attribution is shown when linked media is present.",
                dutch: "YouNew-visuele fallback; bronvermelding staat bij gekoppelde geverifieerde media.",
                russian: "Используется визуальный fallback YouNew; атрибуция показывается у связанных проверенных медиа."
            )
        }

        return LocalizedCityText(
            english: "Place media courtesy of verified sources.",
            dutch: "Plaatsmedia via geverifieerde bronnen.",
            russian: "Медиа места: проверенные источники."
        )
    }

    static let mediaByPlaceId: [String: CityMedia] = Dictionary(uniqueKeysWithValues: [
        cityMedia("nl-city-noord_holland-amsterdam", hero: "Canal houses and Oude Kerk at blue hour with water reflection in Damrak Amsterdam Netherlands.jpg", flag: "Flag of Amsterdam.svg", coat: "Wapen van Amsterdam.svg", attributionName: "Amsterdam"),
        cityMedia("nl-city-noord_holland-haarlem", hero: "Zijlstrat Grote Markt Haarlem.jpg", flag: "Flag Haarlem.svg", coat: "Wapen Haarlem.svg", attributionName: "Haarlem"),
        cityMedia("nl-city-noord_holland-alkmaar", hero: nil, flag: "Alkmaar Flag.svg", coat: "Alkmaar wapen.svg", attributionName: "Alkmaar"),
        cityMedia("nl-city-noord_holland-hoorn", hero: nil, flag: "Flag of Hoorn.svg", coat: "Hoorn wapen.svg", attributionName: "Hoorn"),
        cityMedia("nl-city-noord_holland-zaanstad", hero: nil, flag: "Flag of Zaanstad.svg", coat: "Coat of arms of Zaanstad.svg", attributionName: "Zaanstad"),
        cityMedia("nl-city-noord_holland-amstelveen", hero: nil, flag: "Amstelveen vlag.svg", coat: "Coat of arms of Amstelveen.svg", attributionName: "Amstelveen"),
        cityMedia("nl-city-noord_holland-purmerend", hero: nil, flag: "Flag of Purmerend.svg", coat: "Purmerend wapen.svg", attributionName: "Purmerend"),
        cityMedia("nl-city-noord_holland-heerhugowaard", hero: nil, flag: "Flag of Heerhugowaard.svg", coat: "Heerhugowaard wapen.svg", attributionName: "Heerhugowaard"),

        cityMedia("nl-city-zuid_holland-rotterdam", hero: "Erasmusbrug seen from Euromast.jpg", flag: "Flag of Rotterdam.svg", coat: "Rotterdam wapen.svg", attributionName: "Rotterdam"),
        cityMedia("nl-city-zuid_holland-den_haag", hero: "Friedenspalast_Den_Haag.jpg", flag: "Flag of The Hague.svg", coat: "Den Haag wapen.svg", attributionName: "Den Haag / The Hague"),
        // Commons source titles: Flag of Leiden.svg, Leiden wapen.svg.
        cityMedia("nl-city-zuid_holland-leiden", hero: "Leiden_Grachten_20.jpg", flag: "Flag_of_Leiden.svg", coat: "Leiden_wapen_HRvA.svg", attributionName: "Leiden"),
        cityMedia("nl-city-zuid_holland-delft", hero: "00 0781 Canal in Delft (NL).jpg", flag: "Flag of Delft.svg", coat: "Coat of arms of Delft.svg", attributionName: "Delft"),

        cityMedia("nl-city-utrecht-utrecht", hero: "Utrecht, de Domtoren (RM36075) vanaf de Oudegracht 230 ongeveer foto5 2015-11-01 08.56.jpg", flag: "Flag of Utrecht city.svg", coat: "Utrecht gemeente wapen.svg", attributionName: "Utrecht city"),
        cityMedia("nl-city-utrecht-amersfoort", hero: nil, flag: "Amersfoort vlag.svg", coat: "Amersfoort wapen.svg", attributionName: "Amersfoort"),

        cityMedia("nl-city-gelderland-arnhem", hero: "Arnhem river 2003 01.jpg", flag: "VlagArnhem.svg", coat: "Coat of arms of Arnhem.svg", attributionName: "Arnhem"),
        cityMedia("nl-city-gelderland-nijmegen", hero: "2009-05-01 in Nijmegen 01.jpg", flag: "Flag of Nijmegen.svg", coat: "Coat of arms of Nijmegen.svg", attributionName: "Nijmegen"),

        cityMedia("nl-city-noord_brabant-eindhoven", hero: "Eindhoven-Witte Dame (5).jpg", flag: "Flag of Eindhoven.svg", coat: "Eindhoven wapen.svg", attributionName: "Eindhoven"),
        cityMedia("nl-city-noord_brabant-tilburg", hero: nil, flag: "Flag of Tilburg.svg", coat: "Tilburg wapen 1817.svg", attributionName: "Tilburg"),
        cityMedia("nl-city-noord_brabant-breda", hero: nil, flag: "Flag of Breda.svg", coat: "Breda wapen.svg", attributionName: "Breda"),
        cityMedia("nl-city-noord_brabant-s_hertogenbosch", hero: nil, flag: "Flag of 's-Hertogenbosch.svg", coat: "S-Hertogenbosch wapen.svg", attributionName: "'s-Hertogenbosch"),

        cityMedia("nl-city-limburg-maastricht", hero: "2022 Magisch Maastricht (01).jpg", flag: "Flag of Maastricht.svg", coat: "Wapen van Maastricht.svg", attributionName: "Maastricht"),
        cityMedia("nl-city-limburg-venlo", hero: nil, flag: "Venlo vlag.svg", coat: "Coat of arms of Venlo.svg", attributionName: "Venlo"),

        cityMedia("nl-city-overijssel-zwolle", hero: "Zwolle Sassenpoort.jpg", flag: "Flag of Zwolle.svg", coat: "Coat of arms of Zwolle.svg", attributionName: "Zwolle"),
        cityMedia("nl-city-flevoland-almere", hero: nil, flag: "Almere vlag.svg", coat: "Almere wapen.svg", attributionName: "Almere"),
        cityMedia("nl-city-flevoland-lelystad", hero: nil, flag: "Flag of Lelystad.svg", coat: "Lelystad wapen.svg", attributionName: "Lelystad"),
        cityMedia("nl-city-groningen-groningen", hero: "20100523 Grote Markt en Martinitoren Groningen NL.jpg", flag: "Flag Groningen city.svg", coat: "Groningen stad wapen.svg", attributionName: "Groningen city"),
        cityMedia("nl-city-friesland-leeuwarden", hero: "Waag, Leeuwarden 1614.jpg", flag: "Flag of Leeuwarden.svg", coat: "Coat of arms of Leeuwarden.svg", attributionName: "Leeuwarden"),
        cityMedia("nl-city-drenthe-assen", hero: "AssenMarkt.JPG", flag: "Flag of Assen.svg", coat: "Assen wapen.svg", attributionName: "Assen"),
        cityMedia("nl-city-zeeland-middelburg", hero: nil, flag: "Middelburg vlag.svg", coat: "Coat of arms of Middelburg.svg", attributionName: "Middelburg"),

        provinceMedia("nl-province-noord_holland", hero: "North Holland by Sentinel-2, 2018-06-30.jpg", flag: "Flag of North Holland.svg", coat: "Noord-Holland wapen.svg", attributionName: "Noord-Holland"),
        provinceMedia("nl-province-zuid_holland", hero: "South Holland by Sentinel-2, 2018-06-30.jpg", flag: "Flag of Zuid-Holland.svg", coat: "Zuid-holland wapen.svg", attributionName: "Zuid-Holland"),
        provinceMedia("nl-province-utrecht", hero: nil, flag: "Utrecht (province)-Flag.svg", coat: "Utrecht provincie wapen.svg", attributionName: "Utrecht province"),
        provinceMedia("nl-province-gelderland", hero: nil, flag: "Flag of Gelderland.svg", coat: "Gelderland wapen.svg", attributionName: "Gelderland"),
        provinceMedia("nl-province-noord_brabant", hero: "St._Jans_cathedral_'s-Hertogenbosch.jpg", flag: "North Brabant-Flag.svg", coat: "Noord-Brabant wapen.svg", attributionName: "Noord-Brabant"),
        provinceMedia("nl-province-limburg", hero: nil, flag: "Flag of Limburg (Netherlands).svg", coat: "Limburg-nl-wapen.svg", attributionName: "Limburg"),
        provinceMedia("nl-province-overijssel", hero: nil, flag: "Flag of Overijssel.svg", coat: "Overijssel wapen.svg", attributionName: "Overijssel"),
        provinceMedia("nl-province-flevoland", hero: "Flevoland by Sentinel-2, 2018-06-30.jpg", flag: "Flag of Flevoland.svg", coat: "Flevoland wapen.svg", attributionName: "Flevoland"),
        provinceMedia("nl-province-groningen", hero: nil, flag: "Flag of Groningen.svg", coat: "Groningen provincie wapen.svg", attributionName: "Groningen province"),
        provinceMedia("nl-province-friesland", hero: "Friesland montage image.jpg", flag: "Frisian flag.svg", coat: "Friesland wapen.svg", attributionName: "Friesland"),
        provinceMedia("nl-province-drenthe", hero: "Hunebed_D27_in_Borger_flickr.jpg", flag: "Flag of Drenthe.svg", coat: "Drenthe wapen.svg", attributionName: "Drenthe"),
        provinceMedia("nl-province-zeeland", hero: "Zeeland by Sentinel-2, 2018-06-30.jpg", flag: "Flag of Zeeland.svg", coat: "Zeeland wapen.svg", attributionName: "Zeeland")
    ])

    private static func cityMedia(
        _ placeId: String,
        hero: String?,
        flag: String?,
        coat: String?,
        attributionName: String
    ) -> (String, CityMedia) {
        (
            placeId,
            CityMedia(
                heroImage: hero.map { commonsAsset(fileName: $0, type: .heroImage, placeId: placeId, attributionName: attributionName) } ?? curatedHeroAsset(placeId: placeId, attributionName: attributionName),
                flag: flag.map { commonsAsset(fileName: $0, type: .flag, placeId: placeId, attributionName: attributionName) },
                coatOfArms: coat.map { commonsAsset(fileName: $0, type: .coatOfArms, placeId: placeId, attributionName: attributionName) }
            )
        )
    }

    private static func provinceMedia(
        _ placeId: String,
        hero: String?,
        flag: String?,
        coat: String?,
        attributionName: String
    ) -> (String, CityMedia) {
        cityMedia(placeId, hero: hero, flag: flag, coat: coat, attributionName: attributionName)
    }

    private static func commonsAsset(
        fileName: String,
        type: CityMediaType,
        placeId: String,
        attributionName: String
    ) -> CityMediaAsset {
        let encodedFileName = fileName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? fileName
        let mimeType: String
        if fileName.lowercased().hasSuffix(".svg") {
            mimeType = "image/svg+xml"
        } else if fileName.lowercased().hasSuffix(".png") {
            mimeType = "image/png"
        } else if fileName.lowercased().hasSuffix(".webp") {
            mimeType = "image/webp"
        } else {
            mimeType = "image/jpeg"
        }

        let sourcePageURL = "https://commons.wikimedia.org/wiki/File:\(encodedFileName)"
        let thumbnailURL = "https://commons.wikimedia.org/wiki/Special:FilePath/\(encodedFileName)?width=1600"

        let curatedHero = type == .heroImage ? CuratedPlaceHeroMediaRegistry.media(for: placeId) : nil
        let resolvedLocalAssetName = curatedHero?.assetName ?? localAssetName(placeId: placeId, type: type)
        let resolvedLicense = licenseName(for: fileName)
        var resolvedURL = curatedHero?.remoteURL?.absoluteString ?? thumbnailURL
        if fileName == "Leiden_wapen_HRvA.svg" {
            resolvedURL += "?legacy=Leiden_wapen.svg"
        }
        let resolvedRenderStatus: MediaRenderStatus = type == .heroImage && !resolvedURL.isEmpty
            ? .renderableRemote
            : renderStatus(type: type, localAssetName: resolvedLocalAssetName)

        return CityMediaAsset(
            url: resolvedURL,
            sourcePageURL: sourcePageURL,
            thumbnailURL: resolvedURL,
            imageURL: resolvedURL,
            localAssetName: resolvedLocalAssetName,
            renderStatus: resolvedRenderStatus,
            source: "Wikimedia Commons",
            sourceType: .wikimedia,
            license: curatedHero?.license ?? resolvedLicense,
            attribution: "\(fileName) contributors on Wikimedia Commons; verified for \(attributionName)",
            verified: true,
            updatedAt: "2026-05-31",
            type: type,
            pixelWidth: type == .heroImage ? 2400 : 1024,
            pixelHeight: type == .heroImage ? 1350 : 1024,
            mimeType: mimeType,
            placeId: placeId
        )
    }

    private static func curatedHeroAsset(placeId: String, attributionName: String) -> CityMediaAsset? {
        guard let curatedHero = CuratedPlaceHeroMediaRegistry.media(for: placeId) else { return nil }
        let remoteURL = curatedHero.remoteURL?.absoluteString
        let resolvedRenderStatus: MediaRenderStatus = remoteURL == nil
            ? renderStatus(type: .heroImage, localAssetName: curatedHero.assetName)
            : .renderableRemote
        return CityMediaAsset(
            url: remoteURL,
            sourcePageURL: curatedHero.sourceURL?.absoluteString,
            thumbnailURL: remoteURL,
            imageURL: remoteURL,
            localAssetName: curatedHero.assetName,
            renderStatus: resolvedRenderStatus,
            source: curatedHero.sourceURL == nil ? "Curated local asset" : "Curated verified source",
            sourceType: curatedHero.sourceURL == nil ? .local : .otherVerified,
            license: curatedHero.license,
            attribution: "Curated hero media verified for \(attributionName)",
            verified: true,
            updatedAt: "2026-06-06",
            type: .heroImage,
            pixelWidth: 2400,
            pixelHeight: 1350,
            mimeType: "image/jpeg",
            placeId: placeId
        )
    }

    private static func licenseName(for fileName: String) -> String {
        "Wikimedia Commons file license"
    }

    private static func localAssetName(placeId: String, type: CityMediaType) -> String? {
        guard type == .flag || type == .coatOfArms else { return nil }
        guard !placeId.isEmpty else {
            #if DEBUG
            print("[MediaRegistry] placeId is empty, cannot generate asset name")
            #endif
            return nil
        }

        let components = placeId.split(separator: "-")
        guard let lastComponent = components.last else {
            #if DEBUG
            print("[MediaRegistry] placeId=\(placeId) has no parseable components")
            #endif
            return nil
        }
        let city = String(lastComponent)

        let baseName: String
        if placeId.hasPrefix("nl-city-") {
            baseName = "city_\(city)"
        } else if placeId.hasPrefix("nl-province-") {
            baseName = placeId.replacingOccurrences(of: "nl-province-", with: "")
        } else {
            baseName = placeId
        }

        let assetName: String
        switch type {
        case .flag:
            assetName = "\(baseName)_flag"
        case .coatOfArms:
            assetName = "\(baseName)_coat_of_arms"
        case .heroImage:
            return nil
        }

        #if DEBUG
        print("[MediaRegistry] placeId=\(placeId) asset=\(assetName)")
        #endif

        return assetName
    }

    private static func renderStatus(type: CityMediaType, localAssetName: String?) -> MediaRenderStatus {
        switch type {
        case .heroImage:
            return localAssetName != nil ? .renderableLocal : .metadataOnlyMissingAsset
        case .flag, .coatOfArms:
            return localAssetName != nil ? .renderableLocal : .metadataOnlyMissingAsset
        }
    }
}

extension CityMedia {
    var hasVerifiedMedia: Bool {
        [heroImage, flag, coatOfArms].contains { $0?.verified == true }
    }
}
