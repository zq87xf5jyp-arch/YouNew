import SwiftUI
import CoreLocation

struct LocalPartnersView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var appState: AppStateViewModel
    @State private var selectedCategory: LocalPartnerCategory?

    private var lang: AppLanguage { languageManager.appLanguage }
    private var partners: [LocalPartner] {
        let cityPartners = MockLocalPartnersData.partners(in: appState.selectedCity)
        guard let selectedCategory else { return cityPartners }
        return cityPartners.filter { $0.category == selectedCategory }
    }

    private var selectedCategoryTitle: String {
        selectedCategory?.title(lang) ?? listTitle
    }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 920) {
                VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    header
                    categories
                    partnerList
                    businessEntry
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, AppSpacing.medium)
            }
        }
        .appSceneBackground(.more)
        .navigationTitle(title)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            CategoryHeroVisual(
                assetName: nil,
                title: title,
                subtitle: subtitle,
                symbol: "storefront.fill",
                badgeText: appState.selectedCity,
                accent: AppColors.dutchOrange,
                asset: ContentMediaRegistry.workImage ?? ContentMediaRegistry.marketsLocalLifeImage ?? ContentMediaRegistry.mapImage,
                height: 238,
                language: lang
            )
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("localPartners.hero")

            Text(disclosure)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .padding(10)
                .background(AppColors.chipBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private var categories: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                categoryButton(nil)
                ForEach(LocalPartnerCategory.allCases) { category in
                    categoryButton(category)
                }
            }
        }
    }

    private func categoryButton(_ category: LocalPartnerCategory?) -> some View {
        let selected = selectedCategory == category
        let label = category?.title(lang) ?? allTitle
        let symbol = category?.symbol ?? "square.grid.2x2.fill"
        return Button {
            withAnimation(AppAnimations.standard) {
                selectedCategory = category
            }
        } label: {
            Label(label, systemImage: symbol)
                .font(AppTypography.captionStrong)
                .foregroundStyle(selected ? .white : AppColors.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(selected ? AppColors.accent : AppColors.chipBackground, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private var partnerList: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            SectionHeader(title: listTitle, subtitle: listSubtitle)
            if partners.isEmpty {
                categorySupportDashboard
            } else {
                ForEach(partners) { partner in
                    NavigationLink(value: AppDestination.localPartnerDetail(partner.id)) {
                        LocalPartnerRow(partner: partner, language: lang)
                    }
                    .buttonStyle(AppPressableCardButtonStyle())
                }
            }
        }
    }

    private var categorySupportDashboard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            CategoryHeroVisual(
                assetName: nil,
                title: emptyCategoryTitle,
                subtitle: emptyCategoryDetail,
                symbol: selectedCategory?.symbol ?? "storefront.fill",
                badgeText: ProvinceCatalog.localizedCityName(appState.selectedCity, lang),
                accent: AppColors.dutchOrange,
                asset: emptyCategoryAsset,
                height: 206,
                language: lang
            )
            .accessibilityIdentifier("partners.category.support.hero")

            LazyVGrid(columns: DetailPageLayout.twoColumnWhenPossible(for: 360, minimumColumnWidth: 170), spacing: AppSpacing.small) {
                SmartNavigationRow(
                    title: becomePartnerTitle,
                    subtitle: becomePartnerSubtitle,
                    symbol: "plus.viewfinder",
                    destination: .businessGrowth
                )
                SmartNavigationRow(
                    title: officialAlternativesTitle,
                    subtitle: officialAlternativesSubtitle,
                    symbol: "building.columns.fill",
                    destination: .officialSources
                )
                SmartNavigationRow(
                    title: placesFallbackTitle,
                    subtitle: placesFallbackSubtitle,
                    symbol: "mappin.and.ellipse",
                    destination: .mapHub
                )
                SmartNavigationRow(
                    title: aiFallbackTitle,
                    subtitle: aiFallbackSubtitle,
                    symbol: "sparkles",
                    destination: .assistantHub
                )
            }
        }
        .accessibilityIdentifier("partners.category.support")
    }

    private var emptyCategoryAsset: AppImageAsset? {
        switch selectedCategory {
        case .stay:
            return ContentMediaRegistry.premiumHousingImage ?? ContentMediaRegistry.housingTerracedHousesImage
        case .foodDrinks:
            return ContentMediaRegistry.foodImage ?? ContentMediaRegistry.marketsLocalLifeImage
        case .healthcare:
            return ContentMediaRegistry.healthcareBasicsImage ?? ContentMediaRegistry.healthcarePharmacyImage
        case .education:
            return ContentMediaRegistry.museumsCultureImage ?? ContentMediaRegistry.dailyCultureImage
        case .transport:
            return ContentMediaRegistry.transportHero ?? ContentMediaRegistry.transportBasicsImage
        case .legal, .finance:
            return ContentMediaRegistry.officialSourcesHero ?? ContentMediaRegistry.municipalityCityHallImage
        case .shopping, .home:
            return ContentMediaRegistry.marketsLocalLifeImage ?? ContentMediaRegistry.mapImage
        case .jobs:
            return ContentMediaRegistry.workImage
        case .leisure:
            return ContentMediaRegistry.canalsCityCentresImage ?? ContentMediaRegistry.cultureWideHero
        case nil:
            return ContentMediaRegistry.workImage ?? ContentMediaRegistry.marketsLocalLifeImage ?? ContentMediaRegistry.mapImage
        }
    }

    private var businessEntry: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            SmartNavigationRow(
                title: growTitle,
                subtitle: growSubtitle,
                symbol: "chart.line.uptrend.xyaxis",
                destination: .businessGrowth
            )
            SmartNavigationRow(
                title: loginTitle,
                subtitle: loginSubtitle,
                symbol: "person.crop.circle.badge.checkmark",
                destination: .businessLogin
            )
        }
    }

    private var title: String { "Local Partners" }

    private var subtitle: String {
        switch lang {
        case .russian: return "Подборка локальных сервисов рядом с вами. Каталог продолжает расти."
        case .dutch: return "Uitgelichte lokale diensten in de buurt. De gids wordt verder uitgebreid."
        case .english: return "Featured local services near you. The partner directory continues to grow."
        }
    }

    private var disclosure: String {
        switch lang {
        case .russian: return "Карточки помогают сравнить сервисы. Цены, доступность и детали проверяйте напрямую у бизнеса."
        case .dutch: return "Kaarten helpen diensten vergelijken. Controleer prijzen, beschikbaarheid en details rechtstreeks bij het bedrijf."
        case .english: return "Listings help you compare services. Check prices, availability, and details directly with the business."
        }
    }

    private var allTitle: String { lang == .russian ? "Все" : lang == .dutch ? "Alles" : "All" }
    private var listTitle: String { lang == .russian ? "Локальные сервисы" : lang == .dutch ? "Lokale diensten" : "Local Services" }
    private var listSubtitle: String {
        let city = ProvinceCatalog.localizedCityName(appState.selectedCity, lang)
        let countText = partners.isEmpty ? noListingsCountText : "\(partners.count)"
        return "\(city) · \(selectedCategoryTitle) · \(countText)"
    }
    private var noListingsCountText: String {
        switch lang {
        case .russian: return "подборка готовится"
        case .dutch: return "selectie in voorbereiding"
        case .english: return "curated alternatives"
        }
    }
    private var emptyCategoryTitle: String {
        switch lang {
        case .russian: return "\(selectedCategoryTitle): альтернативы для этого города"
        case .dutch: return "\(selectedCategoryTitle): alternatieven voor deze stad"
        case .english: return "\(selectedCategoryTitle): city alternatives"
        }
    }
    private var emptyCategoryDetail: String {
        switch lang {
        case .russian: return "Для этой категории в городе показаны полезные альтернативы: официальные источники, Places, AI и заявка для бизнеса."
        case .dutch: return "Voor deze categorie tonen we nuttige alternatieven: officiële bronnen, Places, AI en de partneraanvraag."
        case .english: return "For this category, use useful alternatives: official resources, Places, AI, and the business partner application."
        }
    }
    private var emptyCategorySuggestions: [String] {
        switch lang {
        case .russian: return ["Официальные источники", "Places рядом", "Спросить AI", "Стать партнером"]
        case .dutch: return ["Officiële bronnen", "Places dichtbij", "Vraag AI", "Partner worden"]
        case .english: return ["Official resources", "Nearby Places", "Ask AI", "Become a Partner"]
        }
    }
    private var becomePartnerTitle: String { lang == .russian ? "Стать партнером" : lang == .dutch ? "Partner worden" : "Become a Partner" }
    private var becomePartnerSubtitle: String {
        switch lang {
        case .russian: return "Добавьте реальную карточку в эту категорию."
        case .dutch: return "Voeg een echte vermelding toe aan deze categorie."
        case .english: return "Add a real listing to this category."
        }
    }
    private var officialAlternativesTitle: String { lang == .russian ? "Официальные ресурсы" : lang == .dutch ? "Officiële bronnen" : "Official Resources" }
    private var officialAlternativesSubtitle: String {
        switch lang {
        case .russian: return "Проверьте правила и услуги у надежного источника."
        case .dutch: return "Controleer regels en diensten bij een betrouwbare bron."
        case .english: return "Check rules and services with a trusted source."
        }
    }
    private var placesFallbackTitle: String { "Places" }
    private var placesFallbackSubtitle: String {
        switch lang {
        case .russian: return "Откройте карту и ближайшие места."
        case .dutch: return "Open kaart en plekken dichtbij."
        case .english: return "Open the map and nearby places."
        }
    }
    private var aiFallbackTitle: String { lang == .russian ? "Спросить AI" : lang == .dutch ? "Vraag AI" : "Ask AI" }
    private var aiFallbackSubtitle: String {
        switch lang {
        case .russian: return "Подберите следующий практический шаг."
        case .dutch: return "Vind een praktische volgende stap."
        case .english: return "Find a practical next step."
        }
    }
    private var growTitle: String { lang == .russian ? "Grow your Business with YouNew" : "Grow your Business with YouNew" }
    private var growSubtitle: String { lang == .russian ? "Как YouNew продвигает локальные сервисы." : "How YouNew promotes local services." }
    private var loginTitle: String { lang == .russian ? "Вход для бизнеса" : lang == .dutch ? "Business login" : "Business login" }
    private var loginSubtitle: String { lang == .russian ? "Только по email или телефону." : lang == .dutch ? "Alleen met e-mail of telefoon." : "Email or phone only." }
}

struct LocalPartnerDetailView: View {
    let partner: LocalPartner
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var savedItemsStore: SavedItemsStore
    @EnvironmentObject private var appState: AppStateViewModel

    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        GeometryReader { proxy in
            let pageWidth = DetailPageLayout.pageWidth(viewportWidth: proxy.size.width)
            let contentWidth = DetailPageLayout.availableContentWidth(viewportWidth: proxy.size.width)

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    hero
                    contactGrid
                    actionRow
                    details
                }
                .frame(width: contentWidth, alignment: .leading)
                .padding(.vertical, AppSpacing.medium)
                .padding(.horizontal, DetailPageLayout.pageHorizontalPadding)
                .frame(width: pageWidth, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .center)
                .tabBarScrollReserve()
            }
        }
        .appSceneBackground(.map)
        .navigationTitle(partner.name)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            PremiumImageHeader(
                title: partner.name,
                asset: partnerHeroAsset,
                language: lang,
                symbol: partner.category.symbol,
                accent: partnerAccent,
                height: 188,
                cornerRadius: 24,
                fallbackCategory: partnerFallbackCategory
            )
            .accessibilityIdentifier("localPartner.detail.hero")

            partnerSummaryCard
            partnerGalleryStrip
        }
    }

    private var partnerSummaryCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(partner.name)
                        .font(AppTypography.sectionTitle)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                    Text("\(partner.category.title(lang)) · \(partner.subcategory)")
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                }
                Spacer()
                Text(partner.plan.label(lang))
                    .font(AppTypography.captionStrong)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(AppColors.accent, in: Capsule())
            }
            Text(partner.description)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(4)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardStyle()
    }

    private var partnerGalleryStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(partnerGalleryItems, id: \.id) { item in
                    PremiumImageHeader(
                        title: item.title,
                        asset: item.asset,
                        language: lang,
                        symbol: item.symbol,
                        accent: partnerAccent,
                        height: 68,
                        width: 86,
                        cornerRadius: 16,
                        fallbackCategory: partnerFallbackCategory
                    )
                }
            }
            .padding(.vertical, 2)
        }
        .accessibilityIdentifier("localPartner.detail.gallery")
    }

    private var partnerHeroAsset: AppImageAsset? {
        directImageAsset(from: partner.media.hero, id: "partner-hero-\(partner.id)") ?? partnerCategoryAsset
    }

    private var partnerGalleryItems: [PartnerGalleryItem] {
        let directItems = partner.media.gallery.enumerated().compactMap { index, media in
            directImageAsset(from: media, id: "partner-gallery-\(partner.id)-\(index)").map {
                PartnerGalleryItem(id: "direct-\(index)", title: media.altText, symbol: gallerySymbol(at: index), asset: $0)
            }
        }
        if !directItems.isEmpty { return Array(directItems.prefix(3)) }

        let symbols = Array((partner.photoSymbols.isEmpty ? [partner.category.symbol] : partner.photoSymbols).prefix(3))
        return symbols.enumerated().map { index, symbol in
            PartnerGalleryItem(
                id: "fallback-\(index)-\(symbol)",
                title: partner.subcategory,
                symbol: symbol,
                asset: partnerCategoryAsset
            )
        }
    }

    private var partnerCategoryAsset: AppImageAsset? {
        switch partner.category {
        case .stay:
            return ContentMediaRegistry.premiumHousingImage ?? ContentMediaRegistry.housingTerracedHousesImage ?? ContentMediaRegistry.officialSourcesHero
        case .foodDrinks:
            return ContentMediaRegistry.foodImage ?? ContentMediaRegistry.marketsLocalLifeImage
        case .healthcare:
            return ContentMediaRegistry.healthcarePharmacyImage
        case .legal:
            return ContentMediaRegistry.municipalityCityHallImage ?? ContentMediaRegistry.officialSourcesHero
        case .education:
            return ContentMediaRegistry.dailyCultureImage ?? ContentMediaRegistry.officialSourcesHero
        case .finance, .jobs:
            return ContentMediaRegistry.workImage ?? ContentMediaRegistry.officialSourcesHero
        case .home:
            return ContentMediaRegistry.premiumHousingImage ?? ContentMediaRegistry.housingTerracedHousesImage
        case .transport:
            return ContentMediaRegistry.transportStationHero ?? ContentMediaRegistry.transportHero
        case .shopping:
            return ContentMediaRegistry.marketsLocalLifeImage ?? ContentMediaRegistry.foodImage
        case .leisure:
            return ContentMediaRegistry.cultureWideHero ?? ContentMediaRegistry.dailyCultureImage
        }
    }

    private var partnerFallbackCategory: PremiumImageFallbackCategory {
        switch partner.category {
        case .stay, .home:
            return .housing
        case .foodDrinks, .shopping, .leisure:
            return .city
        case .healthcare:
            return .healthcare
        case .legal:
            return .government
        case .education:
            return .dutchA1A2
        case .finance, .jobs:
            return .work
        case .transport:
            return .transport
        }
    }

    private var partnerAccent: Color {
        partner.plan == .sponsoredPlacement ? AppColors.warning : AppColors.accent
    }

    private func directImageAsset(from media: LocalPartnerVisualAsset, id: String) -> AppImageAsset? {
        guard isDirectImageURL(media.url) else { return nil }
        return AppImageAsset(
            id: id,
            url: media.url,
            imageURL: media.url,
            thumbnailURL: media.url,
            title: partner.name,
            description: media.altText,
            sourceName: media.sourceTitle,
            sourceURL: partner.website,
            license: media.licenseNote,
            attribution: media.sourceTitle,
            width: nil,
            height: nil,
            type: .cardThumbnail,
            verified: true
        )
    }

    private func isDirectImageURL(_ url: URL) -> Bool {
        ["jpg", "jpeg", "png", "webp", "gif", "heic"].contains(url.pathExtension.lowercased())
    }

    private func gallerySymbol(at index: Int) -> String {
        guard partner.photoSymbols.indices.contains(index) else { return partner.category.symbol }
        return partner.photoSymbols[index]
    }

    private var contactGrid: some View {
        LazyVGrid(columns: DetailPageLayout.twoColumnWhenPossible(for: 360, minimumColumnWidth: 160), spacing: AppSpacing.small) {
            info("mappin.and.ellipse", "Address", partner.address)
            info("phone.fill", "Phone", partner.phone)
            info("envelope.fill", "Email", partner.email)
            info("safari.fill", "Website", partner.website.host() ?? partner.website.absoluteString)
            info("clock.fill", "Opening Hours", partner.openingHours)
            info("globe", "Languages", partner.languages.joined(separator: ", "))
            info("calendar.badge.checkmark", "Listing checked", partner.lastVerified)
        }
    }

    private func info(_ symbol: String, _ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: symbol)
                .font(AppTypography.captionStrong)
                .foregroundStyle(AppColors.accent)
            Text(value)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardStyle()
    }

    private var actionRow: some View {
        LazyVGrid(columns: DetailPageLayout.twoColumnWhenPossible(for: 320, minimumColumnWidth: 130), spacing: AppSpacing.small) {
            if let mapsURL {
                Link(destination: mapsURL) { actionLabel("map.fill", "Map") }
            }
            if let navigationURL {
                Link(destination: navigationURL) { actionLabel("location.north.line.fill", "Navigation") }
            }
            if let callURL {
                Link(destination: callURL) { actionLabel("phone.fill", "Call") }
            }
            Link(destination: partner.website) { actionLabel("safari.fill", "Website") }
            Button {
                savedItemsStore.toggle(
                    id: partner.id,
                    kind: .resource,
                    title: partner.name,
                    subtitle: partner.subcategory,
                    destination: .localPartnerDetail(partner.id)
                )
                appState.showToast(L10n.t("common.saved", lang))
            } label: {
                actionLabel("bookmark.fill", "Save")
            }
            .buttonStyle(.plain)
            ShareLink(item: partner.website) {
                actionLabel("square.and.arrow.up.fill", "Share")
            }
        }
    }

    private func actionLabel(_ symbol: String, _ title: String) -> some View {
        Label(title, systemImage: symbol)
            .font(AppTypography.bodyStrong)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(AppColors.chipBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            HStack(spacing: 8) {
                disclosurePill(partner.plan.label(lang), symbol: disclosureSymbol)
                disclosurePill(openStatusText, symbol: "clock.fill")
                disclosurePill(localized(en: "Listing", nl: "Vermelding", ru: "Карточка"), symbol: "storefront.fill")
            }
            Text(commercialNotice)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
            SmartNavigationRow(
                title: "Open on Partner Layer",
                subtitle: partner.address,
                symbol: partner.category.symbol,
                destination: .mapFocus(.place(partner.mapPlace.saveKey))
            )
        }
    }

    private func disclosurePill(_ text: String, symbol: String) -> some View {
        Label(text, systemImage: symbol)
            .font(AppTypography.metadata)
            .foregroundStyle(AppColors.textPrimary)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(AppColors.chipBackground, in: Capsule())
    }

    private var openStatusText: String {
        if partner.isOpenNow {
            return localized(en: "Open now", nl: "Nu open", ru: "Открыто")
        }
        return localized(en: "Check hours", nl: "Controleer tijden", ru: "Проверьте часы")
    }

    private func localized(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }

    private var disclosureSymbol: String {
        switch partner.plan {
        case .premium, .featured, .aiFeatured: return "star.fill"
        case .verifiedPartner: return "storefront.fill"
        case .sponsoredPlacement: return "megaphone.fill"
        case .freeListing: return "storefront.fill"
        }
    }

    private var commercialNotice: String {
        switch lang {
        case .russian: return "Это партнерская карточка. YouNew показывает справочную информацию, но цены, доступность, лицензии и условия нужно проверять напрямую у бизнеса."
        case .dutch: return "Dit is een partnervermelding. YouNew toont informatieve gegevens, maar prijzen, beschikbaarheid, vergunningen en voorwaarden moeten rechtstreeks bij het bedrijf worden gecontroleerd."
        case .english: return "This is a partner listing. YouNew shows informational details, but prices, availability, licenses, and terms must be checked directly with the business."
        }
    }

    private var mapsURL: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "maps.apple.com"
        components.path = "/"
        components.queryItems = [
            URLQueryItem(name: "ll", value: "\(partner.coordinate.latitude),\(partner.coordinate.longitude)"),
            URLQueryItem(name: "q", value: partner.name)
        ]
        return components.url
    }

    private var navigationURL: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "maps.apple.com"
        components.path = "/"
        components.queryItems = [
            URLQueryItem(name: "daddr", value: "\(partner.coordinate.latitude),\(partner.coordinate.longitude)")
        ]
        return components.url
    }

    private var callURL: URL? {
        let dialableNumber = partner.phone.filter { $0.isNumber || $0 == "+" }
        guard !dialableNumber.isEmpty else { return nil }
        return URL(string: "tel://\(dialableNumber)")
    }
}

struct BusinessGrowthView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        BusinessPortalLandingView()
    }

    private var businessHero: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            CategoryHeroVisual(
                assetName: nil,
                title: lang == .russian ? "Станьте партнером YouNew" : "Partner with YouNew",
                subtitle: lang == .russian ? "Ваш бизнес на карте, в рекомендациях и AI-поиске. Вход в кабинет доступен только по email или телефону." : "Connect with your local audience. Business dashboard access is email or phone only.",
                symbol: "storefront.fill",
                badgeText: lang == .russian ? "Для бизнеса" : "For businesses",
                accent: AppColors.accent,
                asset: ContentMediaRegistry.workImage ?? ContentMediaRegistry.mapImage ?? ContentMediaRegistry.officialSourcesHero,
                height: 230,
                language: lang
            )

            SmartNavigationRow(
                title: lang == .russian ? "Войти или стать партнером" : "Log in or become a partner",
                subtitle: lang == .russian ? "Только email или телефон. Без соцсетей и внешних аккаунтов." : "Email or phone only. No social sign-in or external account buttons.",
                symbol: "person.crop.circle.badge.checkmark",
                destination: .businessLogin
            )
        }
        .appCardStyle()
    }

    private var serviceFitSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text(lang == .russian ? "Кому это подходит" : "Who this is for")
                .font(Font.title2.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)

            LazyVGrid(columns: DetailPageLayout.twoColumnWhenPossible(for: 360, minimumColumnWidth: 132), spacing: AppSpacing.small) {
                businessFitTile("bed.double.fill", lang == .russian ? "Отелям" : "Hotels")
                businessFitTile("fork.knife", lang == .russian ? "Ресторанам" : "Restaurants")
                businessFitTile("storefront.fill", lang == .russian ? "Магазинам" : "Shops")
                businessFitTile("cross.case.fill", lang == .russian ? "Клиникам" : "Clinics")
                businessFitTile("car.fill", lang == .russian ? "Транспорту" : "Transport")
            }
        }
    }

    private func businessFitTile(_ symbol: String, _ title: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.title3.weight(.bold))
                .foregroundStyle(AppColors.accent)
                .frame(width: 44, height: 44)
                .background(AppColors.accent.opacity(0.14), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            Text(title)
                .font(AppTypography.captionStrong)
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, minHeight: 96)
        .appCardStyle()
    }

    private var pricingSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text(lang == .russian ? "Тарифы для партнеров" : "Partner pricing")
                .font(Font.title2.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.small) {
                    pricingCard("Free Listing", price: "€0", detail: lang == .russian ? "Базовая карточка" : "Basic profile", highlighted: false)
                    pricingCard("Business Profile", price: "€29", detail: lang == .russian ? "Профиль и контакты" : "Profile and contacts", highlighted: false)
                    pricingCard("Featured Partner", price: "€79", detail: lang == .russian ? "Выше в категориях" : "Higher category placement", highlighted: true)
                    pricingCard("Premium Placement", price: "€149", detail: lang == .russian ? "Карта и показ в разделах" : "Map and section placement", highlighted: false)
                    pricingCard("City Sponsor", price: lang == .russian ? "Инд." : "Custom", detail: lang == .russian ? "Городское размещение" : "City-level placement", highlighted: false)
                }
                .padding(.vertical, 2)
            }
        }
        .accessibilityIdentifier("business.pricing")
    }

    private func pricingCard(_ title: String, price: String, detail: String, highlighted: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: highlighted ? "star.fill" : "storefront.fill")
                    .foregroundStyle(highlighted ? AppColors.warning : AppColors.accent)
                Spacer()
                if highlighted {
                    Text(lang == .russian ? "Рекомендуем" : "Recommended")
                        .font(AppTypography.metadata)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(AppColors.accent, in: Capsule())
                }
            }
            Text(title)
                .font(AppTypography.bodyStrong)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2)
            Text("\(price) / " + (lang == .russian ? "мес." : "month"))
                .font(.title3.weight(.bold))
                .foregroundStyle(AppColors.textPrimary)
            Text(detail)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(2)
            Label(lang == .russian ? "Выбрать" : "Choose", systemImage: "arrow.right")
                .font(AppTypography.captionStrong)
                .foregroundStyle(highlighted ? .white : AppColors.accent)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(highlighted ? AppColors.accent : AppColors.chipBackground, in: Capsule())
        }
        .frame(width: 168, alignment: .topLeading)
        .frame(minHeight: 180, alignment: .topLeading)
        .padding(12)
        .background(AppColors.glassSurfaceElevated, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(highlighted ? AppColors.accent.opacity(0.85) : AppColors.stroke.opacity(0.65), lineWidth: highlighted ? 1.4 : 0.8)
        )
    }

    private var contactCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Label(lang == .russian ? "Готовы привлечь больше клиентов?" : "Ready to attract more customers?", systemImage: "envelope.fill")
                .font(AppTypography.cardTitle)
                .foregroundStyle(AppColors.textPrimary)
            Text(lang == .russian ? "Оставьте заявку через бизнес-вход. Мы свяжемся с вами и подключим карточку без навязчивой рекламы." : "Use business login to leave a request. We will contact you and set up the profile without intrusive advertising.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
            SmartNavigationRow(
                title: lang == .russian ? "Войти по email или телефону" : "Continue with email or phone",
                subtitle: lang == .russian ? "Единственный способ входа в кабинет." : "The only dashboard sign-in method.",
                symbol: "person.crop.circle.badge.checkmark",
                destination: .businessLogin
            )
        }
        .appCardStyle()
    }

    private func section(_ title: String, _ items: [String], symbol: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Label(title, systemImage: symbol)
                .font(Font.title2.weight(.semibold))
            ForEach(items, id: \.self) { item in
                Label(item, systemImage: "checkmark.circle.fill")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textPrimary)
            }
        }
        .appCardStyle()
    }
}

struct BusinessLoginView: View {
    private enum LoginMethod: String, CaseIterable, Identifiable {
        case email
        case phone
        var id: String { rawValue }
        var symbol: String { self == .email ? "envelope.fill" : "phone.fill" }
    }

    @EnvironmentObject private var languageManager: LanguageManager
    @State private var method: LoginMethod = .email
    @State private var email = ""
    @State private var phone = ""
    @State private var didSubmit = false

    private var lang: AppLanguage { languageManager.appLanguage }
    private var activeValue: String { method == .email ? email : phone }
    private var trimmedValue: String { activeValue.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var isValidInput: Bool {
        switch method {
        case .email:
            return trimmedValue.contains("@") && trimmedValue.contains(".")
        case .phone:
            return trimmedValue.filter(\.isNumber).count >= 7
        }
    }
    private var validationMessage: String {
        switch (method, lang) {
        case (.email, .russian): return "Введите рабочий email, например business@company.com."
        case (.phone, .russian): return "Введите номер телефона с кодом страны или минимум 7 цифр."
        case (.email, _): return "Enter a work email, for example business@company.com."
        case (.phone, _): return "Enter a phone number with country code or at least 7 digits."
        }
    }

    var body: some View {
        BusinessPortalLoginView()
    }

    private var loginHero: some View {
        CategoryHeroVisual(
            assetName: nil,
            title: lang == .russian ? "Кабинет партнера" : "Partner Dashboard",
            subtitle: lang == .russian ? "Войдите по email или телефону, чтобы посмотреть демо кабинета: профиль компании, размещение на карте и контактные действия." : "Sign in with email or phone to preview the dashboard: company profile, map placement, and contact actions.",
            symbol: "storefront.fill",
            badgeText: lang == .russian ? "Email или телефон" : "Email or phone",
            accent: AppColors.accent,
            asset: ContentMediaRegistry.workImage ?? ContentMediaRegistry.officialSourcesHero,
            height: 220,
            language: lang
        )
    }

    private var loginForm: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            HStack(spacing: 8) {
                ForEach(LoginMethod.allCases) { item in
                    Button {
                        withAnimation(AppAnimations.standard) {
                            method = item
                            didSubmit = false
                        }
                    } label: {
                        Label(label(for: item), systemImage: item.symbol)
                            .font(AppTypography.bodyStrong)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(method == item ? AppColors.accent : AppColors.chipBackground, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .foregroundStyle(method == item ? .white : AppColors.textPrimary)
                    }
                    .buttonStyle(.plain)
                }
            }

            credentialField
            .font(AppTypography.body)
            .padding(14)
            .background(AppColors.glassSurfaceElevated, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(inputStrokeColor, lineWidth: 1))

            Label(validationMessage, systemImage: isValidInput ? "checkmark.circle.fill" : "info.circle.fill")
                .font(AppTypography.caption)
                .foregroundStyle(isValidInput ? AppColors.success : AppColors.textSecondary)

            Button {
                didSubmit = true
            } label: {
                Label(lang == .russian ? "Продолжить" : "Continue", systemImage: "arrow.right")
                    .font(AppTypography.bodyStrong)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryPremiumButtonStyle())
            .disabled(!isValidInput)
            .opacity(isValidInput ? 1 : 0.45)

            Text(lang == .russian ? "Только email или телефон. Социальный вход, рекламные pop-up и внешние аккаунты не используются." : "Email or phone only. No social login, aggressive pop-ups, or external account buttons.")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .appCardStyle()
        .accessibilityIdentifier("business.login.form")
    }

    @ViewBuilder
    private var credentialField: some View {
        if method == .email {
            emailField
        } else {
            phoneField
        }
    }

    @ViewBuilder
    private var emailField: some View {
        #if os(iOS)
        TextField("business@company.com", text: $email)
            .textInputAutocapitalization(.never)
            .keyboardType(.emailAddress)
        #else
        TextField("business@company.com", text: $email)
        #endif
    }

    @ViewBuilder
    private var phoneField: some View {
        #if os(iOS)
        TextField("+31 6 1234 5678", text: $phone)
            .keyboardType(.phonePad)
        #else
        TextField("+31 6 1234 5678", text: $phone)
        #endif
    }

    private var inputStrokeColor: Color {
        if trimmedValue.isEmpty { return AppColors.stroke.opacity(0.8) }
        return isValidInput ? AppColors.success.opacity(0.85) : AppColors.warning.opacity(0.9)
    }

    private var verifiedPanel: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Label(lang == .russian ? "Вход подтвержден" : "Access ready", systemImage: "checkmark.seal.fill")
                .font(AppTypography.cardTitle)
                .foregroundStyle(AppColors.success)
            Text(lang == .russian ? "Заявка привязана к: \(activeValue). Ниже показано, какие данные и настройки доступны партнеру после подключения." : "Request linked to: \(activeValue). The preview below shows what partners can manage after onboarding.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
            BusinessDashboardContent()
        }
        .accessibilityIdentifier("business.login.verified")
    }

    private func label(for method: LoginMethod) -> String {
        switch (method, lang) {
        case (.email, .russian): return "Email"
        case (.phone, .russian): return "Телефон"
        case (.email, _): return "Email"
        case (.phone, _): return "Phone"
        }
    }
}

struct BusinessDashboardView: View {
    var body: some View {
        BusinessPortalDashboardView()
    }
}

private struct BusinessDashboardContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
            dashboardHeader
            metricsGrid
            analyticsCard
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                dashboard("Company profile", "Edit business description and service category.", "text.alignleft")
                dashboard("Photos", "Upload and reorder partner card photos.", "photo.on.rectangle.angled")
                dashboard("Map placement", "Keep your address, route, and partner layer visible.", "mappin.and.ellipse")
                dashboard("Opening hours", "Update daily hours and temporary closures.", "clock.fill")
                dashboard("Promotions", "Add calm, non-intrusive offers.", "tag.fill")
                dashboard("Service languages", "List languages your team can support.", "globe")
                dashboard("Analytics", "Track views, calls, website taps, and navigation taps.", "chart.line.uptrend.xyaxis")
            }
        }
    }

    private var dashboardHeader: some View {
        CategoryHeroVisual(
            assetName: nil,
            title: "Van der Valk Hotel Amsterdam",
            subtitle: "Partner listing workspace with profile, map placement, contacts, photos, and activity tracking.",
            symbol: "chart.line.uptrend.xyaxis",
            badgeText: "YouNew Business",
            accent: AppColors.accent,
            asset: ContentMediaRegistry.workImage ?? ContentMediaRegistry.mapImage ?? ContentMediaRegistry.officialSourcesHero,
            height: 230,
            language: .english
        )
    }

    private var metricsGrid: some View {
        LazyVGrid(columns: DetailPageLayout.twoColumnWhenPossible(for: 360, minimumColumnWidth: 150), spacing: AppSpacing.small) {
            dashboard("Profile visibility", "Views and profile opens", "eye.fill")
            dashboard("Contact actions", "Calls and website taps", "phone.fill")
            dashboard("Map placement", "City and category discovery", "mappin.and.ellipse")
            dashboard("Listing health", "Photos, labels, and source checks", "checkmark.seal.fill")
        }
    }

    private var analyticsCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            HStack {
                Label("Partner activity", systemImage: "chart.line.uptrend.xyaxis")
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Text("Live account")
                    .font(AppTypography.captionStrong)
                    .foregroundStyle(AppColors.success)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(AppColors.success.opacity(0.14), in: Capsule())
            }

            VStack(alignment: .leading, spacing: 10) {
                ForEach(partnerActivityRows, id: \.title) { row in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: row.symbol)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(AppColors.accent)
                            .frame(width: 28, height: 28)
                            .background(AppColors.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(row.title)
                                .font(AppTypography.captionStrong)
                                .foregroundStyle(AppColors.textPrimary)
                            Text(row.detail)
                                .font(AppTypography.caption)
                                .foregroundStyle(AppColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }

            Text("Activity metrics appear only after a real partner listing is connected and users interact with it.")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .appCardStyle()
    }

    private var partnerActivityRows: [(title: String, detail: String, symbol: String)] {
        [
            ("Profile opens", "How often users open the partner card from Places, Search, or Local Partners.", "person.crop.circle.fill"),
            ("Contact taps", "Calls, website opens, and route actions tracked from the listing.", "phone.fill"),
            ("Discovery source", "Which city, category, or filter led the user to the listing.", "point.topleft.down.curvedto.point.bottomright.up")
        ]
    }

    private func dashboard(_ title: String, _ subtitle: String, _ symbol: String, badge: String? = nil) -> some View {
        HStack(spacing: AppSpacing.small) {
            Image(systemName: symbol)
                .foregroundStyle(AppColors.accent)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.textPrimary)
                Text(subtitle)
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
            if let badge {
                Text(badge)
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(AppColors.chipBackground, in: Capsule())
            }
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(AppColors.textSecondary)
        }
        .appCardStyle()
    }
}

private struct PartnerGalleryItem: Identifiable {
    let id: String
    let title: String
    let symbol: String
    let asset: AppImageAsset?
}

struct LocalPartnerRow: View {
    let partner: LocalPartner
    let language: AppLanguage

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            partnerPhoto
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 7) {
                    Text(partner.category.title(language))
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.accent)
                    statusPill(displayPlanLabel, symbol: planSymbol, tint: AppColors.success)
                }
                Text(partner.name)
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(AppColors.textPrimary)
                Text(partner.description)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
                HStack(spacing: 8) {
                    Label(partner.city, systemImage: "mappin.and.ellipse")
                        .foregroundStyle(AppColors.textSecondary)
                    statusPill(openStatusText, symbol: "clock.fill", tint: partner.isOpenNow ? AppColors.success : AppColors.warning)
                }
                .font(AppTypography.metadata)
                .lineLimit(1)

                HStack(spacing: 8) {
                    miniAction("map.fill")
                    miniAction("phone.fill")
                    miniAction("safari.fill")
                    miniAction("bookmark")
                }
            }
            .layoutPriority(1)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(12)
        .background(AppColors.glassSurfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var partnerPhoto: some View {
        ZStack(alignment: .bottomLeading) {
            PremiumImageView(
                asset: directImageAsset(from: partner.media.thumbnail, id: "partner-row-thumbnail-\(partner.id)") ?? partnerCategoryAsset,
                language: language,
                height: 88,
                aspectRatio: nil,
                mode: .fill,
                cornerRadius: 16,
                overlayStyle: .subtle,
                fallbackCategory: partnerFallbackCategory,
                accessibilityLabel: partner.name,
                targetPixelWidth: 420,
                role: .thumbnail
            )
            .frame(width: 88, height: 88)
            .clipped()

            Image(systemName: partner.photoSymbols.first ?? partner.category.symbol)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(AppColors.accent)
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .stroke(Color.white.opacity(0.18), lineWidth: 0.8)
                )
                .padding(8)
        }
        .frame(width: 88, height: 88)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .layoutPriority(0)
    }

    private func directImageAsset(from media: LocalPartnerVisualAsset, id: String) -> AppImageAsset? {
        guard isDirectImageURL(media.url) else { return nil }
        return AppImageAsset(
            id: id,
            url: media.url,
            imageURL: media.url,
            thumbnailURL: media.url,
            title: partner.name,
            description: media.altText,
            sourceName: media.sourceTitle,
            sourceURL: partner.website,
            license: media.licenseNote,
            attribution: media.sourceTitle,
            width: nil,
            height: nil,
            type: .cardThumbnail,
            verified: true
        )
    }

    private func isDirectImageURL(_ url: URL) -> Bool {
        ["jpg", "jpeg", "png", "webp", "gif", "heic"].contains(url.pathExtension.lowercased())
    }

    private var partnerCategoryAsset: AppImageAsset? {
        switch partner.category {
        case .stay:
            return ContentMediaRegistry.premiumHousingImage ?? ContentMediaRegistry.housingTerracedHousesImage ?? ContentMediaRegistry.officialSourcesHero
        case .foodDrinks:
            return ContentMediaRegistry.foodImage ?? ContentMediaRegistry.dailyCultureImage
        case .healthcare:
            return ContentMediaRegistry.healthcarePharmacyImage
        case .legal:
            return ContentMediaRegistry.municipalityCityHallImage ?? ContentMediaRegistry.officialSourcesHero
        case .education:
            return ContentMediaRegistry.dailyCultureImage ?? ContentMediaRegistry.officialSourcesHero
        case .finance, .jobs:
            return ContentMediaRegistry.workImage ?? ContentMediaRegistry.officialSourcesHero
        case .home:
            return ContentMediaRegistry.premiumHousingImage ?? ContentMediaRegistry.housingTerracedHousesImage
        case .transport:
            return ContentMediaRegistry.transportStationHero ?? ContentMediaRegistry.transportHero
        case .shopping:
            return ContentMediaRegistry.marketsLocalLifeImage ?? ContentMediaRegistry.foodImage
        case .leisure:
            return ContentMediaRegistry.cultureWideHero ?? ContentMediaRegistry.dailyCultureImage
        }
    }

    private var partnerFallbackCategory: PremiumImageFallbackCategory {
        switch partner.category {
        case .stay, .home:
            return .housing
        case .healthcare:
            return .healthcare
        case .legal:
            return .government
        case .finance, .jobs:
            return .work
        case .transport:
            return .transport
        case .education, .foodDrinks, .shopping, .leisure:
            return .city
        }
    }

    private func statusPill(_ text: String, symbol: String, tint: Color) -> some View {
        Label(text, systemImage: symbol)
            .font(AppTypography.metadata)
            .foregroundStyle(tint)
            .lineLimit(1)
    }

    private func miniAction(_ symbol: String) -> some View {
        Image(systemName: symbol)
            .font(.caption.weight(.semibold))
            .foregroundStyle(AppColors.textSecondary)
            .frame(width: 24, height: 24)
            .background(AppColors.chipBackground, in: Circle())
    }

    private var displayPlanLabel: String {
        partner.plan.label(language)
    }

    private var planSymbol: String {
        switch partner.plan {
        case .premium, .featured, .aiFeatured, .sponsoredPlacement:
            return "star.fill"
        case .verifiedPartner:
            return "checkmark.seal.fill"
        default: return "storefront.fill"
        }
    }

    private var openStatusText: String {
        if partner.isOpenNow {
            return localized(en: "Open now", nl: "Nu open", ru: "Открыто")
        }
        return localized(en: "Check hours", nl: "Controleer tijden", ru: "Проверьте часы")
    }

    private func localized(en: String, nl: String, ru: String) -> String {
        switch language {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }
}
