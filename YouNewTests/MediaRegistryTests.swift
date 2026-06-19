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

        #expect(L10n.t("image.unavailable", .russian) == "Изображение недоступно")
        #expect(L10n.t("image.openSource", .dutch) == "Bron openen")
    }
}
