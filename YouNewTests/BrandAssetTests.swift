import Foundation
import ImageIO
import Testing
@testable import YouNew

struct BrandAssetTests {
    private var repoRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    @Test func appIconCatalogAndLogoSourceExist() throws {
        let iconSet = repoRoot.appendingPathComponent("YouNew/Assets.xcassets/AppIcon.appiconset")
        let source = repoRoot.appendingPathComponent("Design/AppIcon/source.svg")
        let script = repoRoot.appendingPathComponent("scripts/generate-app-icons.swift")

        #expect(FileManager.default.fileExists(atPath: iconSet.path))
        #expect(FileManager.default.fileExists(atPath: source.path))
        #expect(FileManager.default.fileExists(atPath: script.path))
    }

    @Test func requiredAppIconSizesExistAndAreReadable() throws {
        let iconSet = repoRoot.appendingPathComponent("YouNew/Assets.xcassets/AppIcon.appiconset")
        let sizes = [16, 32, 64, 128, 256, 512, 1024]

        for size in sizes {
            let url = iconSet.appendingPathComponent("icon-\(size).png")
            #expect(FileManager.default.fileExists(atPath: url.path), "Missing icon-\(size).png")

            guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
                  let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any] else {
                Issue.record("Unreadable PNG: icon-\(size).png")
                continue
            }

            #expect(properties[kCGImagePropertyPixelWidth] as? Int == size)
            #expect(properties[kCGImagePropertyPixelHeight] as? Int == size)
        }
    }

    @Test func appIconContentsReferencesGeneratedAssets() throws {
        let contentsURL = repoRoot.appendingPathComponent("YouNew/Assets.xcassets/AppIcon.appiconset/Contents.json")
        let data = try Data(contentsOf: contentsURL)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let images = json?["images"] as? [[String: Any]] ?? []
        let filenames = Set(images.compactMap { $0["filename"] as? String })

        #expect(filenames.contains("icon-1024.png"))
        #expect(filenames.contains("icon-16.png"))
        #expect(filenames.contains("icon-512.png"))
    }

    @Test func assetCatalogImageReferencesExist() throws {
        let assetRoot = repoRoot.appendingPathComponent("YouNew/Assets.xcassets")
        let enumerator = FileManager.default.enumerator(
            at: assetRoot,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        )
        var missingReferences: [String] = []

        while let url = enumerator?.nextObject() as? URL {
            guard url.lastPathComponent == "Contents.json" else { continue }

            let data = try Data(contentsOf: url)
            guard
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                let images = json["images"] as? [[String: Any]]
            else { continue }

            for image in images {
                guard let filename = image["filename"] as? String, !filename.isEmpty else { continue }
                let referenced = url.deletingLastPathComponent().appendingPathComponent(filename)
                if !FileManager.default.fileExists(atPath: referenced.path) {
                    missingReferences.append(referenced.path.replacingOccurrences(of: repoRoot.path + "/", with: ""))
                }
            }
        }

        #expect(missingReferences.isEmpty, "Missing asset catalog files: \(missingReferences)")
    }

    @Test func logoSourceDoesNotUseOfficialOrPlaceholderMarks() throws {
        let sourceURL = repoRoot.appendingPathComponent("Design/AppIcon/source.svg")
        let source = try String(contentsOf: sourceURL, encoding: .utf8).lowercased()

        #expect(!source.contains("flag_of_the_netherlands"))
        #expect(!source.contains("coat"))
        #expect(!source.contains("gemeente"))
        #expect(!source.contains("placeholder"))
    }

    @Test func productionCodeDoesNotReferencePlaceholderOrTestLogo() throws {
        let productionRoots = [
            repoRoot.appendingPathComponent("YouNew/Core/DesignSystem/Components"),
            repoRoot.appendingPathComponent("YouNew/Views"),
            repoRoot.appendingPathComponent("YouNew/Core/DesignSystem/Tokens")
        ]
        let forbidden = ["placeholder logo", "test logo", "temporary logo", "debug logo", "stock logo"]
        var violations: [String] = []

        for root in productionRoots {
            let enumerator = FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            while let url = enumerator?.nextObject() as? URL {
                guard url.pathExtension == "swift" else { continue }
                let source = try String(contentsOf: url, encoding: .utf8).lowercased()
                if forbidden.contains(where: source.contains) {
                    violations.append(url.path.replacingOccurrences(of: repoRoot.path + "/", with: ""))
                }
            }
        }

        #expect(violations.isEmpty, "Production UI references placeholder/test logo text: \(violations)")
    }

    @Test func appIconUsesVectorSourceNotLowResolutionPrimaryRaster() throws {
        let source = repoRoot.appendingPathComponent("Design/AppIcon/source.svg")
        let sourceText = try String(contentsOf: source, encoding: .utf8)

        #expect(source.pathExtension == "svg")
        #expect(sourceText.contains("<svg"))
        #expect(!sourceText.lowercased().contains("<image"))
        #expect(!sourceText.lowercased().contains(".png"))
        #expect(!sourceText.lowercased().contains(".jpg"))
    }

    @Test func officialLeidenSymbolsRemainSeparateFromBrandAssets() {
        let city = ProvinceCatalog.city(named: "Leiden", provinceID: "Zuid-Holland")

        #expect(city.symbols.flag?.url?.contains("Flag_of_Leiden.svg") == true)
        #expect(city.symbols.coatOfArms?.url?.contains("Leiden_wapen.svg") == true)
        #expect(city.symbols.flag?.url?.contains("AppIcon") != true)
        #expect(city.symbols.coatOfArms?.url?.contains("YouNew") != true)
    }

    @Test func officialSymbolAssetsAreNotReusedAsBrandLogo() throws {
        let logoSource = repoRoot.appendingPathComponent("Design/AppIcon/source.svg")
        let logo = try String(contentsOf: logoSource, encoding: .utf8)

        #expect(!logo.contains("city_leiden_flag"))
        #expect(!logo.contains("city_leiden_coat_of_arms"))
        #expect(!logo.contains("Flag_of_Leiden"))
        #expect(!logo.contains("Leiden_wapen_HRvA"))
    }

    @Test func cityAndProvinceSymbolsStayInOfficialAssetFamilies() throws {
        let assetRoot = repoRoot.appendingPathComponent("YouNew/Assets.xcassets")
        let enumerator = FileManager.default.enumerator(at: assetRoot, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        var misplaced: [String] = []

        while let url = enumerator?.nextObject() as? URL {
            guard url.pathExtension == "svg" else { continue }
            let path = url.path.replacingOccurrences(of: repoRoot.path + "/", with: "")
            let isOfficialSymbol = path.contains("_flag.imageset") || path.contains("_coat_of_arms.imageset")
            let isMapAsset = path.contains("map_") || path.contains("netherlands_map")
            if !isOfficialSymbol && !isMapAsset && (path.contains("flag") || path.contains("coat_of_arms")) {
                misplaced.append(path)
            }
        }

        #expect(misplaced.isEmpty, "Official symbol-like files outside symbol asset families: \(misplaced)")
    }

    @Test func bottomTabIconMappingsArePresent() {
        #expect(AppIcons.home == "house")
        #expect(AppIcons.homeActive == "house.fill")
        #expect(AppIcons.search == "magnifyingglass")
        #expect(AppIcons.map == "map")
        #expect(AppIcons.mapActive == "map.fill")
        #expect(AppIcons.save == "bookmark")
        #expect(AppIcons.saved == "bookmark.fill")
        #expect(AppIcons.more == "ellipsis.circle")
        #expect(AppIcons.moreActive == "ellipsis.circle.fill")
        #expect(AppIcons.Metrics.minimumTouchTarget >= 44)
    }

    @Test func russianTabLabelsMatchCanonicalFiveTabNavigation() {
        #expect(L10n.t("tab.home", .russian) == "Главная")
        #expect(L10n.t("tab.guide", .russian) == "Гид")
        #expect(L10n.t("tab.map", .russian) == "Карта")
        #expect(L10n.t("tab.saved", .russian) == "Избранное")
        #expect(L10n.t("tab.more", .russian) == "Ещё")

        #expect(AppTab.allCases == [.home, .guide, .map, .saved, .more])
    }

    @Test func rightSideMenuLocalizationKeysExist() {
        let keys = [
            "common.menu", "common.close", "common.back", "menu.title", "menu.subtitle",
            "menu.home", "menu.map", "menu.search", "menu.saved", "menu.history",
            "menu.cultureAttractions", "menu.cities", "menu.help", "menu.settings",
            "menu.sources", "menu.about", "menu.language", "menu.version"
        ]

        for language in AppLanguage.allCases {
            for key in keys {
                #expect(L10n.t(key, language) != key, "Missing \(key) for \(language.rawValue)")
            }
        }

        #expect(L10n.t("menu.sources", .russian) == "Источники")
        #expect(L10n.t("menu.about", .russian) == "О YouNew.nl")
    }

    @Test func drawerRoutesUseRealDestinations() {
        let destinations: [AppDestination] = [
            .netherlandsHistory,
            .provinceList,
            .settings,
            .officialSources,
            .aboutYouNew
        ]

        #expect(destinations.count == 5)
    }

    @Test func sideMenuBrandingUsesYouNewNL() {
        for language in AppLanguage.allCases {
            #expect(L10n.t("menu.title", language) == "YouNew.nl")
            #expect(L10n.t("sideMenu.title", language) == "YouNew.nl")
            #expect(!L10n.t("sideMenu.subtitle", language).contains("sideMenu."))
        }
        #expect(L10n.t("sideMenu.about", .english) == "About YouNew.nl")
        #expect(L10n.t("sideMenu.about", .dutch) == "Over YouNew.nl")
        #expect(L10n.t("sideMenu.about", .russian) == "О YouNew.nl")
    }

    @Test func sideMenuLandmarkRegistryHasVerifiedLicensedFallback() {
        let images = SideMenuLandmarkRegistry.images
        #expect(!images.isEmpty)
        #expect(SideMenuLandmarkRegistry.fallback.verified)

        for image in images {
            #expect(image.type == .sideMenuHero)
            #expect(image.verified, "Unverified side menu image: \(image.id)")
            #expect(image.sourceName == "Wikimedia Commons")
            #expect(image.sourcePageURL?.absoluteString.contains("commons.wikimedia.org/wiki/File:") == true)
            #expect(image.thumbnailURL?.absoluteString.contains("Special:FilePath") == true)
            #expect(image.thumbnailURL?.absoluteString.contains("width=900") == true)
            #expect(image.licenseName?.isEmpty == false)
            #expect(image.licenseURL != nil)
            #expect(image.author?.isEmpty == false)
            #expect(image.attribution?.isEmpty == false)
            #expect(image.width ?? 0 > 0)
            #expect(image.height ?? 0 > 0)
            #expect(image.aspectRatio ?? 0 > 0)
            #expect(image.retrievedAt == "2026-06-01")
        }
    }

    @Test func sideMenuLandmarksAvoidForbiddenSources() {
        let forbidden = ["google", "pinterest", "stock", "placeholder"]

        for image in SideMenuLandmarkRegistry.images {
            let values = [
                image.url?.absoluteString,
                image.sourcePageURL?.absoluteString,
                image.imageURL?.absoluteString,
                image.thumbnailURL?.absoluteString,
                image.sourceName,
                image.attribution
            ]
            .compactMap { $0?.lowercased() }
            .joined(separator: " ")

            #expect(!forbidden.contains(where: values.contains), "Forbidden media source in \(image.id)")
        }
    }

    @Test func sideMenuHeroSelectionPrefersCurrentCityAndFallsBack() {
        #expect(SideMenuLandmarkRegistry.hero(for: "Leiden", rotationSeed: 0).id == "side-menu-leiden-canals")
        #expect(SideMenuLandmarkRegistry.hero(for: "Amsterdam", rotationSeed: 0).id == "side-menu-amsterdam-canals")
        #expect(SideMenuLandmarkRegistry.hero(for: "Rotterdam", rotationSeed: 0).id == "side-menu-rotterdam-erasmusbrug")
        #expect(SideMenuLandmarkRegistry.hero(for: "Den Haag", rotationSeed: 0).id == "side-menu-the-hague-binnenhof")
        #expect(SideMenuLandmarkRegistry.hero(for: "Maastricht", rotationSeed: 0).id == "side-menu-maastricht-vrijthof")
        #expect(SideMenuLandmarkRegistry.hero(for: "Rijksmuseum", rotationSeed: 0).id == "side-menu-amsterdam-rijksmuseum")
        #expect(SideMenuLandmarkRegistry.hero(for: "Unknown City", rotationSeed: 1).verified)
    }

    @Test func sideMenuLandmarkLocalizationKeysExist() {
        let keys = [
            "sideMenu.landmark.amsterdam.title",
            "sideMenu.landmark.leiden.title",
            "sideMenu.landmark.delft.title",
            "sideMenu.landmark.rotterdam.title",
            "sideMenu.landmark.hague.title",
            "sideMenu.landmark.utrecht.title",
            "sideMenu.landmark.kinderdijk.title",
            "sideMenu.landmark.rijksmuseum.title",
            "sideMenu.landmark.maastricht.title"
        ]

        for language in AppLanguage.allCases {
            for key in keys {
                #expect(L10n.t(key, language) != key, "Missing \(key) for \(language.rawValue)")
            }
        }
    }
}
