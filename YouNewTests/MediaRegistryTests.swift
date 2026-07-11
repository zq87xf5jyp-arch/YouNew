import Foundation
import Testing
@testable import YouNew

struct MediaRegistryTests {
    @Test func contentTransportHeroHasCompleteVerifiedMetadata() throws {
        let asset = try #require(ContentMediaRegistry.transportHero)

        #expect(asset.id == "content-transport-amsterdam-bike-parking")
        #expect(asset.type == .transportHero)
        #expect(asset.verified)
        #expect(asset.sourceName == "Wikimedia Commons")
        #expect(asset.sourcePageURL?.absoluteString == "https://commons.wikimedia.org/wiki/File:Amsterdam_bicycle_parking.jpg")
        #expect(asset.thumbnailURL?.absoluteString.contains("width=1600") == true)
        #expect(asset.originalFileURL?.host == "upload.wikimedia.org")
        #expect(asset.licenseName == "Creative Commons Attribution-Share Alike 3.0 Unported")
        #expect(asset.licenseURL?.absoluteString == "https://creativecommons.org/licenses/by-sa/3.0/")
        #expect(asset.author == "Tezd")
        #expect(asset.attribution?.contains("Wikimedia Commons") == true)
        #expect(asset.width == 1620)
        #expect(asset.height == 1080)
        #expect(asset.aspectRatio == 1620.0 / 1080.0)
        #expect(asset.retrievedAt == "2026-06-01")
    }

    @Test func amsterdamCityHeroUsesVerifiedPhotoNotOfficialSymbols() throws {
        let media = VerifiedPlaceMediaRegistry.media(for: .city, name: "Amsterdam", provinceId: "Noord-Holland")
        let hero = try #require(media.heroImage)

        #expect(hero.type == .heroImage)
        #expect(hero.verified)
        #expect(hero.renderStatus == .renderableRemote)
        #expect(hero.sourcePageURL == "https://commons.wikimedia.org/wiki/File:Canal%20houses%20and%20Oude%20Kerk%20at%20blue%20hour%20with%20water%20reflection%20in%20Damrak%20Amsterdam%20Netherlands.jpg")
        #expect(hero.thumbnailURL?.contains("width=2400") == true)
        #expect(hero.license == "Wikimedia Commons file license")
        #expect(hero.pixelWidth == 2400)
        #expect(hero.pixelHeight == 1350)
        #expect(hero.url?.lowercased().contains("flag") != true)
        #expect(hero.url?.lowercased().contains("coat") != true)
        #expect(hero.url?.lowercased().contains("appicon") != true)
    }

    @Test func cityMediaConversionPreservesSourcePageAndThumbnailURLs() throws {
        let media = VerifiedPlaceMediaRegistry.media(for: .city, name: "Amsterdam", provinceId: "Noord-Holland")
        let appImage = try #require(media.heroImage?.appImageAsset(id: "amsterdam-hero", title: "Amsterdam", type: .cityHero))

        #expect(appImage.sourcePageURL?.host == "commons.wikimedia.org")
        #expect(appImage.sourcePageURL?.path.hasPrefix("/wiki/File:") == true)
        #expect(appImage.thumbnailURL?.absoluteString.contains("Special:FilePath") == true)
        #expect(appImage.sourcePageURL != appImage.thumbnailURL)
        #expect(appImage.width == 2400)
        #expect(appImage.height == 1350)
        #expect(appImage.verified)
    }

    @Test func imageLocalizationKeysExistInAllSupportedLanguages() {
        for language in AppLanguage.allCases {
            for key in ["image.source", "image.license", "image.unavailable", "image.openSource"] {
                #expect(L10n.t(key, language) != key, "Missing \(key) for \(language.rawValue)")
            }
        }

        #expect(L10n.t("image.unavailable", .russian) == "Проверенный визуальный контекст")
        #expect(L10n.t("image.openSource", .dutch) == "Bron openen")
    }

    @Test func contentArtworkRegistryKeepsPrimarySearchArtworkDistinct() throws {
        let healthcare = try #require(ContentArtworkRegistry.asset(for: .searchHealthcare))
        let housing = try #require(ContentArtworkRegistry.asset(for: .searchHousing))
        let transport = try #require(ContentArtworkRegistry.asset(for: .searchTransport))
        let work = try #require(ContentArtworkRegistry.asset(for: .searchWork))
        let legal = try #require(ContentArtworkRegistry.asset(for: .searchLegal))

        let identities = [
            healthcare.stableArtworkIdentity,
            housing.stableArtworkIdentity,
            transport.stableArtworkIdentity,
            work.stableArtworkIdentity,
            legal.stableArtworkIdentity
        ]

        #expect(Set(identities).count == identities.count, "Primary Search categories must not reuse visible artwork")
    }

    @Test func assistantHeroDoesNotUseGenericAmsterdamFallback() throws {
        let assistantHero = try #require(ContentArtworkRegistry.asset(for: .aiHero))
        let amsterdamFallback = ContentMediaRegistry.canalHousesHero

        #expect(assistantHero.stableArtworkIdentity != amsterdamFallback?.stableArtworkIdentity)
        #expect(assistantHero.id != "content-home-amsterdam-canal-houses")
    }

    @Test func premiumCategoryCoverAccessorsAreRenderableAndSpecific() throws {
        let covers: [(String, AppImageAsset?)] = [
            ("food", ContentMediaRegistry.foodImage),
            ("calendar", ContentMediaRegistry.calendarImage),
            ("ai", ContentMediaRegistry.aiImage),
            ("search", ContentMediaRegistry.searchImage),
            ("saved", ContentMediaRegistry.savedImage),
            ("profile", ContentMediaRegistry.profileImage),
            ("emergency", ContentMediaRegistry.emergencyImage),
            ("map", ContentMediaRegistry.mapImage),
            ("work", ContentMediaRegistry.workImage),
            ("housing", ContentMediaRegistry.premiumHousingImage)
        ]

        for (name, optionalAsset) in covers {
            let asset = try #require(optionalAsset, "\(name) cover is missing")
            #expect(asset.verified, "\(name) cover must be verified")
            #expect(asset.localAssetName != nil || asset.url != nil, "\(name) cover must be renderable")
            #expect(!asset.title.isGenericImageLabel, "\(name) cover needs a specific title")
            #expect(asset.description?.isGenericImageLabel != true, "\(name) cover needs a specific description")
        }
    }

    @Test func contentArtworkSlotsResolveToRenderableAssets() throws {
        for slot in ContentArtworkSlot.allCases {
            let asset = try #require(ContentArtworkRegistry.asset(for: slot), "\(slot.rawValue) is missing")
            #expect(asset.verified, "\(slot.rawValue) must use verified media")
            #expect(asset.localAssetName != nil || asset.url != nil, "\(slot.rawValue) must be renderable")
            #expect(!asset.title.isGenericImageLabel, "\(slot.rawValue) needs a specific image label")
        }
    }

    @Test func contentArtworkSlotsDoNotReuseVisibleArtwork() {
        #expect(ContentArtworkRegistry.duplicateArtworkViolations().isEmpty)
    }

    @Test func priorityNetherlandsCitiesHavePremiumVisualRoleCoverage() throws {
        let priorityCities = [
            "nl-city-noord_holland-amsterdam",
            "nl-city-zuid_holland-rotterdam",
            "nl-city-zuid_holland-leiden",
            "nl-city-zuid_holland-den_haag",
            "nl-city-utrecht-utrecht",
            "nl-city-noord_brabant-eindhoven",
            "nl-city-limburg-maastricht",
            "nl-city-groningen-groningen"
        ]

        for placeId in priorityCities {
            let visuals = try #require(CuratedPlaceHeroMediaRegistry.cityVisualsByPlaceId[placeId], "\(placeId) has no city gallery")
            #expect(Set(visuals.keys) == Set(CityVisualRole.allCases), "\(placeId) must cover every core city visual role")

            let identities = visuals.values.map(\.stableVisualIdentity)
            #expect(Set(identities).count == identities.count, "\(placeId) must not reuse the same image across core roles")

            for role in CityVisualRole.allCases {
                let visual = try #require(visuals[role], "\(placeId) missing \(role.rawValue)")
                #expect(visual.remoteURL?.scheme == "https", "\(placeId) \(role.rawValue) must use an HTTPS visual")
                #expect(visual.minimumPixelWidth >= role.minimumRequiredPixelWidth, "\(placeId) \(role.rawValue) below minimum width")
                #expect(!visual.title.isGenericImageLabel, "\(placeId) \(role.rawValue) needs a specific title")
                #expect(!visual.why.isGenericImageLabel, "\(placeId) \(role.rawValue) needs a specific rationale")
            }
        }
    }
}

private extension AppImageAsset {
    var stableArtworkIdentity: String {
        if let localAssetName, !localAssetName.isEmpty {
            return "local:\(localAssetName)"
        }
        if let url = thumbnailURL ?? imageURL ?? self.url {
            return "url:\(url.absoluteString.lowercased())"
        }
        return "asset:\(id.lowercased())"
    }
}

private extension CuratedPlaceVisualMedia {
    var stableVisualIdentity: String {
        if let remoteURL {
            return remoteURL.absoluteString.lowercased()
        }
        return assetName.lowercased()
    }
}

private extension CityVisualRole {
    var minimumRequiredPixelWidth: Int {
        switch self {
        case .hero:
            return 2400
        case .landmark, .culture, .night:
            return 1200
        case .thumbnail:
            return 600
        case .card:
            return 1200
        }
    }
}

private extension String {
    var isGenericImageLabel: Bool {
        let normalized = trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return normalized.isEmpty
            || normalized == "image"
            || normalized == "photo"
            || normalized == "picture"
            || normalized == "afbeelding"
            || normalized == "фото"
            || normalized == "изображение"
    }
}
