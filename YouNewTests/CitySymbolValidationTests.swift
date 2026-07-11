import Testing
import SwiftUI
@testable import YouNew

@MainActor
struct CitySymbolValidationTests {
    @Test func validFlagAndCoatOfArmsAreAcceptedIndependently() {
        let flag = CitySymbol(
            url: "https://upload.wikimedia.org/wikipedia/commons/example/city_leiden_flag.svg",
            source: "Wikimedia Commons",
            verified: true,
            updatedAt: "2026-05-30",
            type: .flag,
            pixelWidth: 512,
            pixelHeight: 341
        )
        let coat = CitySymbol(
            url: "https://upload.wikimedia.org/wikipedia/commons/example/city_leiden_coat_of_arms.png",
            source: "Wikimedia Commons",
            verified: true,
            updatedAt: "2026-05-30",
            type: .coatOfArms,
            pixelWidth: 512,
            pixelHeight: 512
        )

        #expect(CitySymbolValidator.validate(flag, expectedType: .flag).isValid)
        #expect(CitySymbolValidator.validate(coat, expectedType: .coatOfArms).isValid)
    }

    @Test func cityWithOnlyFlagKeepsCoatOfArmsUnavailable() {
        let symbols = CitySymbols(
            flag: CitySymbol(
                url: "https://upload.wikimedia.org/wikipedia/commons/example/city_flag.webp",
                source: "Wikidata",
                verified: true,
                updatedAt: "2026-05-30",
                type: .flag,
                pixelWidth: 320,
                pixelHeight: 200
            ),
            coatOfArms: nil
        )

        #expect(CitySymbolValidator.validate(symbols.flag, expectedType: .flag).isValid)
        #expect(CitySymbolValidator.validate(symbols.coatOfArms, expectedType: .coatOfArms).failure == .missingSymbol)
    }

    @Test func cityWithOnlyCoatOfArmsKeepsFlagUnavailable() {
        let symbols = CitySymbols(
            flag: nil,
            coatOfArms: CitySymbol(
                url: "https://upload.wikimedia.org/wikipedia/commons/example/city_coat.jpg",
                source: "Official municipality open data",
                verified: true,
                updatedAt: "2026-05-30",
                type: .coatOfArms,
                pixelWidth: 256,
                pixelHeight: 256
            )
        )

        #expect(CitySymbolValidator.validate(symbols.flag, expectedType: .flag).failure == .missingSymbol)
        #expect(CitySymbolValidator.validate(symbols.coatOfArms, expectedType: .coatOfArms).isValid)
    }

    @Test func noVerifiedSymbolsRenderAsUnavailable() {
        #expect(CitySymbolValidator.validate(nil, expectedType: .flag).failure == .missingSymbol)
        #expect(CitySymbolValidator.validate(nil, expectedType: .coatOfArms).failure == .missingSymbol)
    }

    @Test func brokenImageURLIsRejected() {
        let symbol = CitySymbol(
            url: "not a url",
            source: "Wikimedia Commons",
            verified: true,
            updatedAt: "2026-05-30",
            type: .flag
        )

        #expect(CitySymbolValidator.validate(symbol, expectedType: .flag).failure == .invalidURL)
    }

    @Test func wrongSymbolTypeIsRejected() {
        let symbol = CitySymbol(
            url: "https://upload.wikimedia.org/wikipedia/commons/example/city_flag.svg",
            source: "Wikimedia Commons",
            verified: true,
            updatedAt: "2026-05-30",
            type: .flag
        )

        #expect(CitySymbolValidator.validate(symbol, expectedType: .coatOfArms).failure == .wrongSymbolType)
    }

    @Test func countryFlagCannotBeUsedAsCityFlag() {
        let symbol = CitySymbol(
            url: "https://upload.wikimedia.org/wikipedia/commons/2/20/Flag_of_the_Netherlands.svg",
            source: "Wikimedia Commons country flag",
            verified: true,
            updatedAt: "2026-05-30",
            type: .flag,
            pixelWidth: 900,
            pixelHeight: 600
        )

        #expect(CitySymbolValidator.validate(symbol, expectedType: .flag).failure == .countryFlagUsedAsCityFlag)
    }

    @Test func fakeGeneratedPlaceholderImageIsRejected() {
        let symbol = CitySymbol(
            url: "https://upload.wikimedia.org/wikipedia/commons/example/generated_placeholder_flag.svg",
            source: "AI-generated placeholder",
            verified: true,
            updatedAt: "2026-05-30",
            type: .flag,
            pixelWidth: 512,
            pixelHeight: 512
        )

        #expect(CitySymbolValidator.validate(symbol, expectedType: .flag).failure == .placeholderOrGenerated)
    }

    @Test func tooSmallImageIsRejected() {
        let symbol = CitySymbol(
            url: "https://upload.wikimedia.org/wikipedia/commons/example/city_coat.png",
            source: "Wikimedia Commons",
            verified: true,
            updatedAt: "2026-05-30",
            type: .coatOfArms,
            pixelWidth: 32,
            pixelHeight: 32
        )

        #expect(CitySymbolValidator.validate(symbol, expectedType: .coatOfArms).failure == .imageTooSmall)
    }

    @Test func validSVGIsNotRejectedForMissingRasterDimensions() {
        let symbol = CitySymbol(
            url: "https://upload.wikimedia.org/wikipedia/commons/example/city_coat.svg",
            source: "Wikimedia Commons",
            verified: true,
            updatedAt: "2026-05-30",
            type: .coatOfArms,
            pixelWidth: 32,
            pixelHeight: 32
        )

        #expect(CitySymbolValidator.validate(symbol, expectedType: .coatOfArms).isValid)
    }

    @Test func provinceFlagCannotBeUsedAsCityFlag() {
        let symbol = CitySymbol(
            url: "https://upload.wikimedia.org/wikipedia/commons/example/province_flag.svg",
            source: "Wikimedia Commons provincial flag",
            verified: true,
            updatedAt: "2026-05-30",
            type: .flag,
            pixelWidth: 512,
            pixelHeight: 341
        )

        #expect(CitySymbolValidator.validate(symbol, expectedType: .flag).failure == .countryFlagUsedAsCityFlag)
    }

    @Test func leidenCatalogReturnsVerifiedMedia() {
        let city = ProvinceCatalog.city(named: "Leiden", provinceID: "Zuid-Holland")

        #expect(CityMediaValidator.renderableAsset(city.media.heroImage, expectedType: .heroImage) != nil)
        #expect(CitySymbolValidator.renderableSymbol(city.symbols.flag, expectedType: .flag) != nil)
        #expect(CitySymbolValidator.renderableSymbol(city.symbols.coatOfArms, expectedType: .coatOfArms) != nil)
        #expect(city.symbols.flag?.url != city.symbols.coatOfArms?.url)
        #expect(city.media.heroImage?.url?.contains("commons.wikimedia.org/wiki/Special:FilePath") == true)
        #expect(city.media.heroImage?.url?.contains("Oude%20Vest%20canal") == true)
        #expect(city.media.heroImage?.url?.contains("width=2400") == true)
        #expect(city.symbols.flag?.url?.contains("Flag_of_Leiden.svg") == true)
        #expect(city.symbols.coatOfArms?.url?.contains("Leiden_wapen_HRvA.svg") == true)
        #expect(city.media.coatOfArms?.pixelHeight ?? 0 >= 512)
    }

    @Test func priorityCityRegistryReturnsSeparateVerifiedSymbols() {
        let supportedCities = [
            ("Amsterdam", "Noord-Holland"),
            ("Leiden", "Zuid-Holland"),
            ("Rotterdam", "Zuid-Holland"),
            ("Den Haag", "Zuid-Holland"),
            ("Utrecht", "Utrecht")
        ]

        for (name, provinceID) in supportedCities {
            let city = ProvinceCatalog.city(named: name, provinceID: provinceID)

            #expect(CitySymbolValidator.validate(city.symbols.flag, expectedType: .flag).isValid)
            #expect(CitySymbolValidator.validate(city.symbols.coatOfArms, expectedType: .coatOfArms).isValid)
            #expect(city.symbols.flag?.url != city.symbols.coatOfArms?.url)
            #expect(city.symbols.flag?.sourceType == .wikimedia)
            #expect(city.symbols.coatOfArms?.sourceType == .wikimedia)
        }
    }

    @Test func provinceCatalogDoesNotSynthesizeUnverifiedFlags() {
        let provinces = ["Noord-Holland", "Zuid-Holland", "Utrecht"]

        for provinceID in provinces {
            let province = ProvinceCatalog.item(id: provinceID)

            #expect(CitySymbolValidator.validate(province.symbols.flag, expectedType: .flag).failure == .missingSymbol)
            #expect(CitySymbolValidator.validate(province.symbols.coatOfArms, expectedType: .coatOfArms).failure == .missingSymbol)
        }
    }

    @Test func registryAcceptsTrustedSourceTypeForSpecialFilePathURLs() {
        let media = VerifiedPlaceMediaRegistry.media(for: .city, name: "Amsterdam", provinceId: "Noord-Holland")
        let flagValidation = CitySymbolValidator.validate(media.flag?.symbol, expectedType: .flag)
        let coatOfArmsValidation = CitySymbolValidator.validate(media.coatOfArms?.symbol, expectedType: .coatOfArms)

        #expect(flagValidation.isValid)
        #expect(coatOfArmsValidation.isValid)
        #expect(media.flag?.url?.contains("Special:FilePath") == true)
    }

    @Test func oldUnavailableCacheDoesNotBlockLaterVerifiedMedia() {
        #expect(CityMediaValidator.renderableAsset(nil, expectedType: .flag) == nil)

        let verified = CityMediaAsset(
            url: "https://upload.wikimedia.org/wikipedia/commons/example/city_flag.png",
            source: "Wikimedia Commons",
            verified: true,
            updatedAt: "2026-05-30",
            type: .flag,
            pixelWidth: 256,
            pixelHeight: 160
        )

        #expect(CityMediaValidator.renderableAsset(verified, expectedType: .flag) != nil)
    }

    @Test func cityMediaCreditDoesNotExposeDevelopmentNotes() {
        let city = ProvinceCatalog.city(named: "Leiden", provinceID: "Zuid-Holland")
        let credit = city.localizedImageCredit(.english)

        #expect(!credit.contains("add licensed photo"))
        #expect(!credit.contains("Hero photo"))
        #expect(!credit.contains("Flag & coat of arms"))
        #expect(!credit.contains("TODO"))
        #expect(!credit.contains("Flag of Leiden.svg"))
        #expect(!credit.contains("Leiden_wapen_HRvA.svg"))
        #expect(!credit.contains("Leiden_Grachten_20.jpg"))
        #expect(!credit.lowercased().contains("verified media"))
    }

    @Test func russianTabLabelsMatchCanonicalNavigation() {
        #expect(L10n.t("tab.home", .russian) == "Главная")
        #expect(L10n.t("tab.guide", .russian) == "Гид")
        #expect(L10n.t("tab.map", .russian) == "Карта")
        #expect(L10n.t("tab.saved", .russian) == "Избранное")
        #expect(L10n.t("tab.more", .russian) == "Ещё")
        #expect(AppTab.allCases == [.home, .guide, .map, .saved, .more])
    }

    @Test func russianLeidenCopyUsesCompactStrings() {
        let city = ProvinceCatalog.city(named: "Leiden", provinceID: "Zuid-Holland")

        #expect(city.cityIdentityLine(.russian) == "Исторический университетский город")
        #expect(city.localizedShortDescription(.russian) == "Исторический город в Южной Голландии с каналами, музеями и компактным старым центром.")
    }

    @Test func compactLayoutCannotUseSideNavigationInset() {
        #expect(RootTabView.resolvedMenuPosition(menuPosition: .right, horizontalSizeClass: .compact) == .bottom)
        #expect(RootTabView.resolvedMenuPosition(menuPosition: .left, horizontalSizeClass: .compact) == .bottom)
        #expect(RootTabView.resolvedMenuPosition(menuPosition: .automatic, horizontalSizeClass: .compact) == .bottom)
        #expect(RootTabView.resolvedMenuPosition(menuPosition: .right, horizontalSizeClass: .regular) == .right)
    }

    @Test func contextualAIButtonIsGlobalActionNotTab() {
        #expect(!RootTabView.shouldShowContextualAIButton(selectedTab: .home, isMenuPresented: false))
        #expect(!RootTabView.shouldShowContextualAIButton(selectedTab: .guide, isMenuPresented: false))
        #expect(RootTabView.shouldShowContextualAIButton(selectedTab: .map, isMenuPresented: false))
        #expect(!RootTabView.shouldShowContextualAIButton(selectedTab: .saved, isMenuPresented: false))
        #expect(!RootTabView.shouldShowContextualAIButton(selectedTab: .more, isMenuPresented: false))
        #expect(!RootTabView.shouldShowContextualAIButton(selectedTab: .guide, isMenuPresented: true))
        #expect(AppTab.allCases == [.home, .guide, .map, .saved, .more])
    }

    @Test func placeLayoutCardWidthSubtractsPaddingAndGap() {
        let iPhoneWidth: CGFloat = 393
        let available = PlaceResponsiveLayout.availableWidth(viewportWidth: iPhoneWidth)
        let cardWidth = PlaceResponsiveLayout.twoColumnCardWidth(availableWidth: available)

        #expect(available == 357)
        #expect(PlaceResponsiveLayout.shouldUseTwoColumns(availableWidth: available))
        #expect(cardWidth * 2 + AppSpacing.small <= available)
    }

    @Test func narrowPlaceLayoutStacksIdentityCards() {
        let narrowWidth: CGFloat = 360
        let available = PlaceResponsiveLayout.availableWidth(viewportWidth: narrowWidth)

        #expect(!PlaceResponsiveLayout.shouldUseTwoColumns(availableWidth: available))
        #expect(PlaceResponsiveLayout.twoColumnCardWidth(availableWidth: available) == available)
    }

    @Test func cityDetailUsesSingleTopHeroContainer() {
        #expect(CityDetailLayout.heroImageContainerCount == 1)
        #expect(CityDetailLayout.heroHeight >= 320)
        #expect(CityDetailLayout.heroHeight <= 420)
        #expect(CityDetailLayout.headerToHeroSpacing <= AppSpacing.medium)
    }

    @Test func cityDetailHeroPlaceholderAndPhotoShareOneSlot() {
        #expect(CityDetailLayout.heroImageContainerCount == 1)
        #expect(CityDetailLayout.heroContentPadding >= AppSpacing.medium)
        #expect(CityDetailLayout.heroContentBottomPadding >= AppSpacing.large)
    }

    @Test func cityDetailBottomReserveClearsFloatingNavigation() {
        let iPhoneSafeAreaBottom: CGFloat = 34
        let requiredPadding = CityDetailLayout.bottomContentPadding(safeAreaBottom: iPhoneSafeAreaBottom)

        #expect(CityDetailLayout.bottomContentPadding >= requiredPadding)
        #expect(CityDetailLayout.bottomContentPadding >= FloatingTabBarMetrics.height)
    }

    @Test func cityDetailDoesNotHorizontallyOverflowIPhoneWidth() {
        let iPhoneWidth: CGFloat = 393
        let available = CityDetailLayout.availableContentWidth(viewportWidth: iPhoneWidth)

        #expect(available == 357)
        #expect(available + AppSpacing.screenHorizontal * 2 == iPhoneWidth)
    }

    @Test func priorityCityDetailLayoutFitsSupportedLocales() {
        let cases: [(city: String, province: String, language: AppLanguage)] = [
            ("Leiden", "Zuid-Holland", .russian),
            ("Leiden", "Zuid-Holland", .english),
            ("Amsterdam", "Noord-Holland", .english),
            ("Amsterdam", "Noord-Holland", .russian),
            ("Rotterdam", "Zuid-Holland", .english),
            ("Rotterdam", "Zuid-Holland", .russian)
        ]

        for item in cases {
            let city = ProvinceCatalog.city(named: item.city, provinceID: item.province)
            let available = CityDetailLayout.availableContentWidth(viewportWidth: 393)

            #expect(!city.localizedName(item.language).isEmpty)
            #expect(!city.cityIdentityLine(item.language).isEmpty)
            #expect(!city.localizedShortDescription(item.language).isEmpty)
            #expect(available > 0)
            #expect(CityDetailLayout.heroContentPadding * 2 < available)
        }
    }
}
