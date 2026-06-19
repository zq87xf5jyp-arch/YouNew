import SwiftUI
import OSLog
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SafariServices) && canImport(UIKit)
import SafariServices
#endif

// MARK: - Province Directory

struct ProvinceDirectoryView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var selectedProvinceID: String? = nil

    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 920) {
                LazyVStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    headerSection
                    overviewMap
                    selectedProvinceCard
                    provincesList
                    Color.clear.frame(height: AppSpacing.tabBarScrollReserve)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, AppSpacing.medium)
            }
        }
        .appSceneBackground(.province)
        .navigationTitle(titleText)
        .nlNavigationInline()
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Text(titleText)
                .font(.system(.largeTitle, design: .rounded).weight(.bold))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.78)

            Text(subtitleText)
                .font(.system(.subheadline, design: .rounded).weight(.medium))
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 104), spacing: AppSpacing.small)],
                spacing: AppSpacing.small
            ) {
                ProvinceMetricCard(value: "12", label: provincesCountTitle, icon: "map.fill", color: AppColors.orangeGlow)
                ProvinceMetricCard(value: "342", label: municipalitiesTitle, icon: "building.columns.fill", color: AppColors.routeLine)
                ProvinceMetricCard(value: "18.2M", label: populationTitle, icon: "person.3.fill", color: AppColors.cyanGlow)
            }
            .padding(.top, 4)
        }
    }

    private var overviewMap: some View {
        ZStack {
            LinearGradient(
                colors: [
                    AppColors.heroMid,
                    AppColors.graphite,
                    AppColors.backgroundBottom
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [AppColors.cyanGlow.opacity(0.16), .clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 260
            )

            HStack(alignment: .center, spacing: AppSpacing.small) {
                VStack(alignment: .leading, spacing: 10) {
                    NLBadge(text: mapBadgeText, icon: "map.fill", color: AppColors.softBlue)
                    Text(mapTitleText)
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                    Text(mapPromptText)
                        .font(.system(.footnote, design: .rounded).weight(.medium))
                        .foregroundStyle(Color.white.opacity(0.76))
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: 194, alignment: .leading)

                Spacer(minLength: 4)

                ProvinceInteractiveMapView(
                    selectedProvinceID: $selectedProvinceID,
                    showLabels: true
                )
                .frame(width: 132, height: 166)
                .accessibilityIdentifier("provinces.map.interactive")
            }
            .padding(20)
        }
        .frame(minHeight: 210)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.hero, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppCornerRadius.hero, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.30), AppColors.cyanGlow.opacity(0.16), Color.white.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.9
                )
        }
        .shadow(color: AppColors.cyanGlow.opacity(0.12), radius: 22, x: 0, y: 0)
        .shadow(color: Color.black.opacity(0.30), radius: 24, x: 0, y: 14)
    }

    @ViewBuilder
    private var selectedProvinceCard: some View {
        if let selectedProvinceID {
            let province = ProvinceCatalog.item(id: selectedProvinceID)
            NavigationLink(value: AppDestination.provinceDetail(province.id)) {
                ProvinceRowCard(
                    province: province,
                    lang: lang,
                    isSelected: true,
                    subtitleOverride: "\(selectedProvinceTitle) • \(province.capital) • \(province.municipalityCount) \(municipalityShortLabel)"
                )
            }
            .buttonStyle(NLTileButtonStyle())
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    private var provincesList: some View {
        LazyVStack(alignment: .leading, spacing: AppSpacing.medium) {
            NLSectionHeader(title: chooseProvinceTitle)

            LazyVStack(spacing: 12) {
                ForEach(ProvinceCatalog.all) { province in
                    NavigationLink(value: AppDestination.provinceDetail(province.id)) {
                        ProvinceRowCard(
                            province: province,
                            lang: lang,
                            isSelected: selectedProvinceID == province.id
                        )
                    }
                    .buttonStyle(NLTileButtonStyle())
                }
            }
        }
    }

    private var titleText: String {
        switch lang {
        case .russian: return "Провинции Нидерландов"
        case .dutch: return "Provincies van Nederland"
        case .english: return "Provinces of the Netherlands"
        }
    }

    private var subtitleText: String {
        switch lang {
        case .russian: return "Выберите провинцию, чтобы узнать больше"
        case .dutch: return "Kies een provincie om meer te weten"
        case .english: return "Choose a province to learn more"
        }
    }

    private var provincesCountTitle: String {
        switch lang {
        case .russian: return "провинций"
        case .dutch: return "provincies"
        case .english: return "provinces"
        }
    }

    private var municipalitiesTitle: String {
        switch lang {
        case .russian: return "муниципалитета"
        case .dutch: return "gemeenten"
        case .english: return "municipalities"
        }
    }

    private var populationTitle: String {
        switch lang {
        case .russian: return "население"
        case .dutch: return "bevolking"
        case .english: return "population"
        }
    }

    private var mapBadgeText: String {
        switch lang {
        case .russian: return "Интерактивный обзор"
        case .dutch: return "Interactief overzicht"
        case .english: return "Interactive overview"
        }
    }

    private var mapTitleText: String {
        switch lang {
        case .russian: return "Карта провинций"
        case .dutch: return "Provinciekaart"
        case .english: return "Province map"
        }
    }

    private var mapPromptText: String {
        switch lang {
        case .russian: return "Нажмите на область карты, чтобы выбрать провинцию"
        case .dutch: return "Tik op een kaartgebied om een provincie te kiezen"
        case .english: return "Tap a map area to choose a province"
        }
    }

    private var chooseProvinceTitle: String {
        switch lang {
        case .russian: return "Все 12 провинций"
        case .dutch: return "Alle 12 provincies"
        case .english: return "All 12 provinces"
        }
    }

    private var selectedProvinceTitle: String {
        switch lang {
        case .russian: return "Выбрано"
        case .dutch: return "Geselecteerd"
        case .english: return "Selected"
        }
    }

    private var municipalityShortLabel: String {
        switch lang {
        case .russian: return "муниципалитетов"
        case .dutch: return "gemeenten"
        case .english: return "municipalities"
        }
    }
}

// MARK: - Province Detail

struct ProvinceCityDetailView: View {
    let provinceName: String
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var appState: AppStateViewModel

    private var lang: AppLanguage { languageManager.appLanguage }
    private var activePersona: PersonaTag? { appState.selectedUserStatus?.personaTag }
    private var province: ProvinceItem { ProvinceCatalog.item(id: provinceName) }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 920) {
                LazyVStack(alignment: .leading, spacing: AppSpacing.large) {
                    scenicHero
                    askAISection
                    provinceStats
                    officialSiteCard
                    citiesSection
                    provinceKnowledgeSection
                    mapButton
                    Color.clear.frame(height: AppSpacing.tabBarScrollReserveMap)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.medium)
            }
        }
        .appSceneBackground(.province)
        .navigationTitle(province.localizedName(lang))
        .nlNavigationInline()
        .accessibilityIdentifier("province.detail.\(KnowledgeNormalizer.slug(province.id))")
    }

    // MARK: Scenic Hero

    private var scenicHero: some View {
        let resolvedImage = CanonicalPlaceImageResolver.resolveProvinceHero(province: province)
        return ZStack(alignment: .bottomLeading) {

            GeneratedProvinceArtwork(provinceID: province.id, accent: province.mapHighlightColor)

            CityImageView(
                urlString: resolvedImage.urlString,
                height: CityDetailLayout.heroHeight,
                placeId: province.placeId,
                cityName: province.localizedName(lang),
                fallbackColor: province.mapHighlightColor,
                fallbackURLStrings: resolvedImage.fallbackURLStrings,
                debugContext: resolvedImage.debugContext(
                    screen: "Province detail hero",
                    entityType: "province",
                    entityName: province.localizedName(lang)
                )
            )
            .transition(.opacity)

            Canvas { ctx, size in
                ctx.fill(
                    Path(ellipseIn: CGRect(
                        x: size.width * 0.48,
                        y: -size.height * 0.22,
                        width: size.width * 0.72,
                        height: size.height * 0.52
                    )),
                    with: .color(province.mapHighlightColor.opacity(0.22))
                )

                let cloudXs: [CGFloat] = [0.12, 0.48, 0.76]
                let cloudYs: [CGFloat] = [0.18, 0.12, 0.21]
                let cloudWs: [CGFloat] = [0.22, 0.28, 0.19]
                let cloudAs: [Double] = [0.055, 0.045, 0.040]
                for i in 0..<3 {
                    ctx.fill(
                        Path(ellipseIn: CGRect(
                            x: size.width * cloudXs[i], y: size.height * cloudYs[i],
                            width: size.width * cloudWs[i], height: size.width * cloudWs[i] * 0.40
                        )),
                        with: .color(Color.white.opacity(cloudAs[i]))
                    )
                }

                let landY = size.height * 0.54
                ctx.fill(
                    Path(CGRect(x: 0, y: landY, width: size.width, height: size.height * 0.14)),
                    with: .linearGradient(
                        Gradient(colors: [
                            AppColors.emerald.opacity(0.18),
                            AppColors.dutchOrange.opacity(0.10),
                            Color.clear
                        ]),
                        startPoint: CGPoint(x: 0, y: landY),
                        endPoint: CGPoint(x: size.width, y: landY)
                    )
                )

                let wmX = size.width * 0.76
                let poleH = size.height * 0.33
                ctx.fill(
                    Path(CGRect(x: wmX - 3, y: landY - poleH, width: 6, height: poleH)),
                    with: .color(Color.white.opacity(0.20))
                )
                var wmBody = Path()
                wmBody.move(to: CGPoint(x: wmX - 11, y: landY))
                wmBody.addLine(to: CGPoint(x: wmX + 11, y: landY))
                wmBody.addLine(to: CGPoint(x: wmX + 6, y: landY - 28))
                wmBody.addLine(to: CGPoint(x: wmX - 6, y: landY - 28))
                wmBody.closeSubpath()
                ctx.fill(wmBody, with: .color(Color.white.opacity(0.24)))
                let bladeCenter = CGPoint(x: wmX, y: landY - 28)
                for deg in [45.0, 135.0, 225.0, 315.0] {
                    let rad = deg * .pi / 180
                    var b = Path()
                    b.move(to: bladeCenter)
                    b.addLine(to: CGPoint(x: bladeCenter.x + cos(rad) * 34, y: bladeCenter.y + sin(rad) * 34))
                    ctx.stroke(b, with: .color(Color.white.opacity(0.22)), lineWidth: 3)
                }

                let rowBaseY = landY + size.height * 0.03
                let rowData: [(Double, Double, Double, Double)] = [
                    (0.95, 0.14, 0.28, 0.24), (0.96, 0.54, 0.08, 0.20), (0.92, 0.80, 0.12, 0.18)
                ]
                for (i, (r, g, b, a)) in rowData.enumerated() {
                    ctx.fill(
                        Path(CGRect(x: 0, y: rowBaseY + size.height * 0.022 * CGFloat(i),
                                    width: size.width * 0.58, height: size.height * 0.016)),
                        with: .color(Color(red: r, green: g, blue: b).opacity(a))
                    )
                }

                let waterY = size.height * 0.73
                var water = Path()
                water.move(to: CGPoint(x: 0, y: waterY))
                water.addCurve(
                    to: CGPoint(x: size.width, y: waterY + 10),
                    control1: CGPoint(x: size.width * 0.35, y: waterY - 14),
                    control2: CGPoint(x: size.width * 0.65, y: waterY + 20)
                )
                water.addLine(to: CGPoint(x: size.width, y: size.height))
                water.addLine(to: CGPoint(x: 0, y: size.height))
                water.closeSubpath()
                ctx.fill(water, with: .linearGradient(
                    Gradient(colors: [AppColors.routeLine.opacity(0.32), AppColors.backgroundBottom.opacity(0.96)]),
                    startPoint: CGPoint(x: 0, y: waterY),
                    endPoint: CGPoint(x: 0, y: size.height)
                ))
            }
            .drawingGroup()

            LinearGradient(
                colors: [
                    Color.black.opacity(0.20),
                    Color.clear,
                    AppColors.backgroundBottom.opacity(0.92)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 7) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 11, weight: .bold))
                        Text(provinceLabel.uppercased())
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(AppColors.orangeGlow)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 7)
                    .background(Color.black.opacity(0.24))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.white.opacity(0.16), lineWidth: 0.7))

                    Spacer(minLength: 16)

                    Text(province.localizedName(lang))
                        .font(.system(.largeTitle, design: .rounded).weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                    Text(bilingualSubtitle)
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundStyle(Color.white.opacity(0.82))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 12)

                ProvinceHeroMapPanel(province: province)
                    .frame(width: 96, height: 128)
                    .accessibilityHidden(true)
            }
            .padding(20)

        }
        .frame(minHeight: 252)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.hero, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.hero, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.32), province.mapHighlightColor.opacity(0.28), Color.white.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.9
                )
        )
        .shadow(color: province.mapHighlightColor.opacity(0.20), radius: 24, x: 0, y: 4)
        .shadow(color: Color.black.opacity(0.34), radius: 26, x: 0, y: 14)
    }

    private var bilingualSubtitle: String {
        let en = province.nameByLanguage[.english] ?? province.id
        let nl = province.nameByLanguage[.dutch] ?? province.id
        return en == nl ? en : "\(en) / \(nl)"
    }

    // MARK: Province Stats

    private var askAISection: some View {
        AIAskButton(
            title: askAITitle,
            context: AIContextBuilder.provinceContext(
                province: province,
                language: lang,
                appState: nil
            ),
            prompt: askAIPrompt
        )
    }

    private var provinceStats: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 104), spacing: AppSpacing.small)],
            spacing: AppSpacing.small
        ) {
            ProvinceMetricCard(value: province.population, label: populationLabel, icon: "person.3.fill", color: province.mapHighlightColor)
            ProvinceMetricCard(value: province.areaKm2, label: areaLabel, icon: "square.grid.2x2.fill", color: AppColors.routeLine)
            ProvinceMetricCard(value: "\(province.municipalityCount)", label: municipalitiesLabel, icon: "building.columns.fill", color: AppColors.orangeGlow)
        }
    }

    // MARK: Official Site

    private var officialSiteCard: some View {
        ProvinceDarkInfoRow(
            icon: "globe",
            title: officialWebsiteLabel,
            value: province.officialWebsite,
            color: AppColors.dutchOrange
        )
    }

    // MARK: Cities Section

    private var citiesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            HStack(alignment: .lastTextBaseline) {
                NLSectionHeader(title: citiesLabel)
                Spacer(minLength: AppSpacing.small)
                Text("\(province.cities.count)")
                    .font(.system(.footnote, design: .rounded).weight(.bold))
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppColors.glassSurfaceElevated)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.white.opacity(0.18), lineWidth: 0.7))
            }

            LazyVStack(spacing: AppSpacing.small) {
                ForEach(province.cities) { city in
                    NavigationLink(value: AppDestination.cityDetail(province: province.id, city: city.name)) {
                        ProvinceCityPreviewCard(city: city, province: province, lang: lang)
                    }
                    .buttonStyle(NLTileButtonStyle())
                }
            }
        }
    }

    private var provinceKnowledgeSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: provinceCultureTitle)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: AppSpacing.small)], spacing: AppSpacing.small) {
                if isVisible(.cultureAttractions) {
                    NavigationLink(value: AppDestination.cultureAttractions) {
                        CityRelatedChip(title: provinceCultureTitle, icon: "sparkles.rectangle.stack.fill", color: AppColors.dutchOrange)
                    }
                    .buttonStyle(.plain)
                }

                if isVisible(.firstSteps) {
                    NavigationLink(value: AppDestination.firstSteps) {
                        CityRelatedChip(title: provinceGuidesTitle, icon: AppIcons.checklist, color: AppColors.success)
                    }
                    .buttonStyle(.plain)
                }

                if let provinceURL = AppURL.validatedWebURL(URL(string: "https://\(province.officialWebsite)")) {
                    Link(destination: provinceURL) {
                        CityRelatedChip(title: provinceSourcesTitle, icon: AppIcons.officialSource, color: AppColors.emerald)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: Map Button

    private var mapButton: some View {
        Group {
            if isVisible(.mapFocus(.province(province.id))) {
                NavigationLink(value: AppDestination.mapFocus(.province(province.id))) {
                    ProvinceActionButtonContent(
                        title: openOnMapLabel,
                        icon: "map.fill",
                        gradient: LinearGradient(
                            colors: [AppColors.navyDeep.opacity(0.85), AppColors.heroMid.opacity(0.95)],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                }
                .simultaneousGesture(TapGesture().onEnded {
                    appState.pendingMapFocus = .province(province.id)
                })
                .buttonStyle(AppPressableButtonStyle())
            }
        }
    }

    private func isVisible(_ destination: AppDestination) -> Bool {
        RelatedContentEngine.isVisible(destination, for: activePersona)
    }

    // MARK: Localized Labels

    private var populationLabel: String {
        switch lang {
        case .russian: return "Население"
        case .dutch:   return "Bevolking"
        case .english: return "Population"
        }
    }

    private var areaLabel: String {
        switch lang {
        case .russian: return "Площадь"
        case .dutch:   return "Oppervlakte"
        case .english: return "Area"
        }
    }

    private var municipalitiesLabel: String {
        switch lang {
        case .russian: return "Муницип."
        case .dutch:   return "Gemeenten"
        case .english: return "Municipalities"
        }
    }

    private var officialWebsiteLabel: String {
        switch lang {
        case .russian: return "Официальный сайт"
        case .dutch:   return "Officiele website"
        case .english: return "Official website"
        }
    }

    private var citiesLabel: String {
        switch lang {
        case .russian: return "Города провинции"
        case .dutch:   return "Steden van de provincie"
        case .english: return "Cities in this province"
        }
    }

    private var openOnMapLabel: String {
        switch lang {
        case .russian: return "Открыть на карте"
        case .dutch:   return "Open op kaart"
        case .english: return "Open on map"
        }
    }

    private var provinceCultureTitle: String {
        switch lang {
        case .russian: return "Культура и достопримечательности"
        case .dutch: return "Cultuur & attracties"
        case .english: return "Culture & attractions"
        }
    }

    private var provinceGuidesTitle: String {
        switch lang {
        case .russian: return "Связанные гайды"
        case .dutch: return "Gerelateerde gidsen"
        case .english: return "Related guides"
        }
    }

    private var provinceSourcesTitle: String {
        switch lang {
        case .russian: return "Официальные источники"
        case .dutch: return "Officiele bronnen"
        case .english: return "Official sources"
        }
    }

    private var provinceLabel: String {
        switch lang {
        case .russian: return "Провинция"
        case .dutch:   return "Provincie"
        case .english: return "Province"
        }
    }

    private var askAITitle: String {
        switch lang {
        case .russian: return "Спросить AI об этой провинции"
        case .dutch: return "Vraag AI over deze provincie"
        case .english: return "Ask AI about this province"
        }
    }

    private var askAIPrompt: String {
        switch lang {
        case .russian: return "Что новичку важно знать об этой провинции? Покажите полезные официальные источники."
        case .dutch: return "Wat moet een nieuwkomer weten over deze provincie? Toon nuttige officiële bronnen."
        case .english: return "What should a newcomer know about this province? Show useful official sources."
        }
    }
}

// MARK: - Province Cities

struct ProvinceCitiesView: View {
    let provinceName: String
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var appState: AppStateViewModel

    private var lang: AppLanguage { languageManager.appLanguage }
    private var activePersona: PersonaTag? { appState.selectedUserStatus?.personaTag }
    private var province: ProvinceItem { ProvinceCatalog.item(id: provinceName) }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 920) {
                LazyVStack(alignment: .leading, spacing: AppSpacing.medium) {
                    header
                    ForEach(province.cities) { city in
                        NavigationLink(value: AppDestination.cityDetail(province: province.id, city: city.name)) {
                            CityRowCard(city: city, lang: lang)
                        }
                        .buttonStyle(NLTileButtonStyle())
                    }
                    Color.clear.frame(height: AppSpacing.tabBarScrollReserve)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, AppSpacing.medium)
            }
        }
        .appSceneBackground(.province)
        .navigationTitle(citiesTitle)
        .nlNavigationInline()
    }

    private var header: some View {
        ProvinceCard(
            title: province.localizedName(lang),
            subtitle: "\(province.capital) • \(province.cities.count) \(citiesShortLabel)",
            icon: "building.2.crop.circle.fill",
            gradient: LinearGradient(
                colors: [province.mapHighlightColor, province.mapHighlightColor.opacity(0.62)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    private var citiesTitle: String {
        switch lang {
        case .russian: return "Города"
        case .dutch: return "Steden"
        case .english: return "Cities"
        }
    }

    private var citiesShortLabel: String {
        switch lang {
        case .russian: return "городов"
        case .dutch: return "steden"
        case .english: return "cities"
        }
    }
}

// MARK: - City Detail

enum CityDetailLayout {
    static let heroImageContainerCount = 1
    static let heroHeight: CGFloat = 320
    static let heroContentPadding: CGFloat = 20
    static let heroContentBottomPadding: CGFloat = 26
    static let headerToHeroSpacing: CGFloat = AppSpacing.medium
    static let pageHorizontalPadding: CGFloat = DetailPageLayout.pageHorizontalPadding
    static let sectionGap: CGFloat = DetailPageLayout.sectionGap
    static let cardGap: CGFloat = DetailPageLayout.cardGap
    static let maximumPageWidth: CGFloat = DetailPageLayout.maximumPageWidth
    static let bottomContentPadding: CGFloat = AppSpacing.tabBarScrollReserveCity

    static func bottomContentPadding(safeAreaBottom: CGFloat) -> CGFloat {
        FloatingTabBarMetrics.totalClearance + safeAreaBottom + AppLayout.bottomNavReserveExtra
    }

    static func availableContentWidth(viewportWidth: CGFloat) -> CGFloat {
        DetailPageLayout.availableContentWidth(viewportWidth: viewportWidth)
    }

    static func pageWidth(viewportWidth: CGFloat) -> CGFloat {
        DetailPageLayout.pageWidth(viewportWidth: viewportWidth)
    }

    static func singleColumnGrid() -> [GridItem] {
        DetailPageLayout.singleColumnGrid()
    }

    static func columns(for contentWidth: CGFloat, compactBreakpoint: CGFloat = 430, regularMinimum: CGFloat = 220) -> [GridItem] {
        DetailPageLayout.columns(for: contentWidth, compactBreakpoint: compactBreakpoint, regularMinimum: regularMinimum)
    }

    static func twoColumnWhenPossible(for contentWidth: CGFloat, minimumColumnWidth: CGFloat = 160) -> [GridItem] {
        DetailPageLayout.twoColumnWhenPossible(for: contentWidth, minimumColumnWidth: minimumColumnWidth)
    }

    static func statsColumns(for contentWidth: CGFloat) -> [GridItem] {
        if contentWidth < 520 {
            return singleColumnGrid()
        }

        return Array(repeating: GridItem(.flexible(minimum: 0), spacing: cardGap), count: 3)
    }
}

struct CityDetailView: View {
    let provinceName: String
    let cityName: String
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var appState: AppStateViewModel
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var expandedTimelineEventID: String?

    private var lang: AppLanguage { languageManager.appLanguage }
    private var activePersona: PersonaTag? { appState.selectedUserStatus?.personaTag }
    private var province: ProvinceItem { ProvinceCatalog.item(id: provinceName) }
    private var city: CityItem { ProvinceCatalog.city(named: cityName, provinceID: provinceName) }
    private var cityInfoProfile: CityInfoProfile? { MockNetherlandsUnderstandingData.cityInfoProfile(matching: city.name) }
    private var hasResolvedCityBinding: Bool {
        ProvinceCatalog.provinceIfFound(id: provinceName) != nil
            && ProvinceCatalog.cityIfFound(named: cityName, provinceID: provinceName) != nil
    }

    var body: some View {
        Group {
            if hasResolvedCityBinding {
                cityDetailContent
            } else {
                CityDataBindingErrorView(
                    requestedCity: cityName,
                    requestedProvince: provinceName,
                    lang: lang
                )
            }
        }
        .appSceneBackground(.city)
        .navigationTitle(hasResolvedCityBinding ? city.localizedName(lang) : cityName)
        .nlNavigationInline()
        .accessibilityIdentifier("city.detail.\(city.id)")
    }

    private var cityDetailContent: some View {
        GeometryReader { proxy in
            let pageWidth = CityDetailLayout.pageWidth(viewportWidth: proxy.size.width)
            let contentWidth = CityDetailLayout.availableContentWidth(viewportWidth: proxy.size.width)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: CityDetailLayout.sectionGap) {
                    CityHeroImageView(city: city, province: province, lang: lang)
                        .debugPlaceLayoutBounds("city.hero")
                    identitySection(contentWidth: contentWidth)
                        .debugPlaceLayoutBounds("city.identity")
                    statsRow(contentWidth: contentWidth)
                        .debugPlaceLayoutBounds("city.stats")
                    cityInfoProfileSection(contentWidth: contentWidth)
                    firstWeekStepsSection(contentWidth: contentWidth)
                        .debugPlaceLayoutBounds("city.first_steps")
                    newcomerPlacesSection(contentWidth: contentWidth)
                    scorecardSection(contentWidth: contentWidth)
                    whyMoveSection(contentWidth: contentWidth)
                    costOfLivingSection(contentWidth: contentWidth)
                    personalitySection
                    usefulLinksSection
                    localHighlightsSection
                    cityHistorySection
                    if isVisible(.mapFocus(.city(city.id))) {
                        NavigationLink(value: AppDestination.mapFocus(.city(city.id))) {
                            ProvinceActionButtonContent(title: mapButtonTitle, icon: "map.fill")
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            appState.pendingMapFocus = .city(city.id)
                        })
                        .buttonStyle(AppPressableButtonStyle())
                        .frame(maxWidth: sizeClass == .regular ? 480 : .infinity)
                        .accessibilityLabel(String(format: L10n.t("city.accessibility.open_map", lang), city.name))
                    }
                    shortHistorySection
                    timelineSection
                    landmarkCardsSection
                    newcomerGuideSection(contentWidth: contentWidth)
                    localHighlightFactsSection
                    officialSourcesSection
                    citySafeDisclaimer
                    nearbyCitiesSection(contentWidth: contentWidth)
                    imageCreditSection
                    Color.clear.frame(height: CityDetailLayout.bottomContentPadding(safeAreaBottom: proxy.safeAreaInsets.bottom))
                }
                .frame(width: contentWidth, alignment: .leading)
                .padding(.top, AppSpacing.small)
                .padding(.bottom, AppSpacing.medium)
                .padding(.horizontal, CityDetailLayout.pageHorizontalPadding)
                .frame(width: pageWidth, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }

    // MARK: Stats Row

    private func statsRow(contentWidth: CGFloat) -> some View {
        LazyVGrid(
            columns: CityDetailLayout.statsColumns(for: contentWidth),
            alignment: .leading,
            spacing: CityDetailLayout.cardGap
        ) {
            NLStatTile(value: city.populationText, label: populationLabel)
            NLStatTile(value: city.areaText, label: areaLabel)
            NLStatTile(value: province.localizedName(lang), label: provinceLabel)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func cityInfoProfileSection(contentWidth: CGFloat) -> some View {
        if let profile = cityInfoProfile {
            CityPremiumSection(title: profile.title.value(lang), subtitle: profile.subtitle.value(lang)) {
                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    Text(profile.summary.value(lang))
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    LazyVGrid(
                        columns: CityDetailLayout.columns(for: contentWidth, regularMinimum: 190),
                        alignment: .leading,
                        spacing: CityDetailLayout.cardGap
                    ) {
                        profileMetric(icon: "map.fill", title: provinceLabel, value: ProvinceCatalog.item(id: profile.provinceId).localizedName(lang), color: AppColors.routeLine)
                        if let population = profile.populationText {
                            profileMetric(icon: "person.3.fill", title: populationLabel, value: population, color: AppColors.cyanGlow)
                        }
                        if let area = profile.areaText {
                            profileMetric(icon: "square.dashed", title: areaLabel, value: area, color: AppColors.softBlue)
                        }
                    }

                    if !profile.practicalGuideIds.isEmpty {
                        relatedGuideChips(profile.practicalGuideIds)
                    }

                    if !profile.attractionIds.isEmpty || !profile.articleIds.isEmpty {
                        relatedArticleTags(profile)
                    }

                    cityInfoSources(profile)
                }
            }
        }
    }

    private func profileMetric(icon: String, title: String, value: String, color: Color) -> some View {
        CityInfoCard(icon: icon, title: title, value: value, color: color)
    }

    private func relatedGuideChips(_ guideIds: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(relatedGuidesTitle)
                .font(AppTypography.captionStrong)
                .foregroundStyle(AppColors.textPrimary)

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 156), spacing: 8)],
                alignment: .leading,
                spacing: 8
            ) {
                ForEach(guideIds, id: \.self) { guideId in
                    if let topic = PracticalGuideTopic(rawValue: guideId),
                       isVisible(.practicalGuide(topic)) {
                        NavigationLink(value: AppDestination.practicalGuide(topic)) {
                            CityRelatedChip(title: practicalGuideTitle(topic), icon: practicalGuideIcon(topic), color: AppColors.cyanGlow)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func isVisible(_ destination: AppDestination) -> Bool {
        RelatedContentEngine.isVisible(destination, for: activePersona)
    }

    private func relatedArticleTags(_ profile: CityInfoProfile) -> some View {
        let articleTitles = (profile.attractionIds + profile.articleIds).compactMap { articleTitle(for: $0) }
        return VStack(alignment: .leading, spacing: 8) {
            Text(relatedArticlesTitle)
                .font(AppTypography.captionStrong)
                .foregroundStyle(AppColors.textPrimary)
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 156), spacing: 8)],
                alignment: .leading,
                spacing: 8
            ) {
                ForEach(articleTitles, id: \.self) { title in
                    CityRelatedChip(title: title, icon: "text.book.closed.fill", color: AppColors.dutchOrange)
                }
            }
        }
    }

    private func cityInfoSources(_ profile: CityInfoProfile) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.t("city.official_sources", lang))
                .font(AppTypography.captionStrong)
                .foregroundStyle(AppColors.textPrimary)

            ForEach(MockNetherlandsUnderstandingData.sources(for: profile.officialSourceIds)) { source in
                Link(destination: AppURL.safeWebURL(source.url)) {
                    CityRelatedSourceRow(source: source)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func practicalGuideTitle(_ topic: PracticalGuideTopic) -> String {
        switch topic {
        case .firstStepsNetherlands: return firstWeekTitle
        case .municipalityRegistration: return L10n.t("sideMenu.registration", lang)
        case .healthcareBasics: return L10n.t("sideMenu.healthcare", lang)
        case .findingHuisarts:
            switch lang {
            case .russian: return "Найти huisarts"
            case .dutch: return "Huisarts vinden"
            case .english: return "Find a GP"
            }
        case .healthInsuranceBasics:
            switch lang {
            case .russian: return "Медстраховка"
            case .dutch: return "Zorgverzekering"
            case .english: return "Health insurance"
            }
        case .digidSafety: return L10n.t("sideMenu.digidSafety", lang)
        case .transportBasics: return L10n.t("sideMenu.transport", lang)
        case .housingBasics: return L10n.t("sideMenu.housing", lang)
        case .officialSourcesChecklist: return L10n.t("sideMenu.officialSources", lang)
        case .bankingBasics:
            switch lang {
            case .russian: return "Банкинг"
            case .dutch: return "Bankieren"
            case .english: return "Banking"
            }
        }
    }

    private func practicalGuideIcon(_ topic: PracticalGuideTopic) -> String {
        switch topic {
        case .firstStepsNetherlands: return AppIcons.checklist
        case .municipalityRegistration: return "person.badge.plus.fill"
        case .healthcareBasics, .findingHuisarts, .healthInsuranceBasics: return "cross.case.fill"
        case .digidSafety: return "lock.shield.fill"
        case .transportBasics: return "tram.fill"
        case .housingBasics: return "house.lodge.fill"
        case .officialSourcesChecklist: return AppIcons.officialSource
        case .bankingBasics: return "creditcard.fill"
        }
    }

    private func articleTitle(for id: String) -> String? {
        let articles = MockNetherlandsUnderstandingData.cultureArticles + MockNetherlandsUnderstandingData.attractionArticles
        return articles.first { $0.id == id }?.title.value(lang)
    }

    private func scorecardSection(contentWidth: CGFloat) -> some View {
        CityPremiumSection(title: scorecardTitle, subtitle: scorecardSubtitle) {
            LazyVGrid(
                columns: CityDetailLayout.columns(for: contentWidth, regularMinimum: 170),
                alignment: .leading,
                spacing: CityDetailLayout.cardGap
            ) {
                ForEach(city.scorecard) { item in
                    CityScorecardTile(item: item, lang: lang)
                }
            }
        }
    }

    private func firstWeekStepsSection(contentWidth: CGFloat) -> some View {
        CityPremiumSection(title: firstWeekTitle, subtitle: firstWeekSubtitle) {
            LazyVGrid(
                columns: CityDetailLayout.columns(for: contentWidth, regularMinimum: 220),
                alignment: .leading,
                spacing: CityDetailLayout.cardGap
            ) {
                ForEach(city.firstWeekSteps) { item in
                    if let urlString = item.urlString,
                       let url = AppURL.validatedWebURL(URL(string: urlString)) {
                        Link(destination: url) {
                            CityNewcomerGuideCard(item: item, lang: lang)
                        }
                        .buttonStyle(.plain)
                    } else {
                        CityNewcomerGuideCard(item: item, lang: lang)
                    }
                }
            }
        }
    }

    private func newcomerPlacesSection(contentWidth: CGFloat) -> some View {
        CityPremiumSection(title: newcomerPlacesTitle, subtitle: newcomerPlacesSubtitle) {
            LazyVGrid(
                columns: CityDetailLayout.columns(for: contentWidth, regularMinimum: 240),
                alignment: .leading,
                spacing: CityDetailLayout.cardGap
            ) {
                ForEach(city.newcomerPlaces) { place in
                    CityNewcomerPlaceCard(place: place, lang: lang)
                }
            }
        }
    }

    private func whyMoveSection(contentWidth: CGFloat) -> some View {
        CityPremiumSection(title: whyMoveTitle, subtitle: city.localizedShortDescription(lang)) {
            LazyVGrid(
                columns: CityDetailLayout.columns(for: contentWidth, regularMinimum: 190),
                alignment: .leading,
                spacing: CityDetailLayout.cardGap
            ) {
                ForEach(Array(city.moveReasons.enumerated()), id: \.offset) { _, reason in
                    CityReasonPill(text: reason.value(for: lang))
                }
            }
        }
    }

    private func costOfLivingSection(contentWidth: CGFloat) -> some View {
        CityPremiumSection(title: costTitle, subtitle: costSubtitle) {
            LazyVGrid(
                columns: CityDetailLayout.columns(for: contentWidth, regularMinimum: 190),
                alignment: .leading,
                spacing: CityDetailLayout.cardGap
            ) {
                ForEach(city.costOfLiving) { item in
                    CityCostTile(item: item, lang: lang)
                }
            }
        }
    }

    // MARK: Identity

    @ViewBuilder
    private func identitySection(contentWidth: CGFloat) -> some View {
        let flagAsset = city.flagAssetName
        let coatAsset = city.coatOfArmsAssetName
        let hasAnyContent = AssetAvailability.exists(flagAsset) || AssetAvailability.exists(coatAsset) || city.symbols.flag != nil || city.symbols.coatOfArms != nil
        if hasAnyContent {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                NLSectionHeader(title: L10n.t("city.identity.title", lang), subtitle: city.localizedShortDescription(lang))
                LazyVGrid(
                    columns: CityDetailLayout.twoColumnWhenPossible(for: contentWidth),
                    alignment: .leading,
                    spacing: CityDetailLayout.cardGap
                ) {
                    CityFlagBadge(city: city, lang: lang)
                    CityCoatOfArmsBadge(city: city, lang: lang)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: Useful Links

    private var usefulLinksSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: usefulInfoLabel)
            CityInfoCard(icon: "building.columns.fill", title: municipalityLabel, value: city.municipalityName, color: AppColors.softBlue)
            if let transport = city.transportOperator {
                CityInfoCard(icon: "tram.fill", title: transportLabel, value: transport, color: AppColors.accent)
            }
            if let website = city.officialWebsiteTitle {
                CityInfoCard(icon: "globe", title: websiteLabel, value: website, color: AppColors.dutchOrange)
            }
            if let tourist = city.touristInfoURL {
                CityInfoCard(icon: "info.circle.fill", title: touristLabel, value: tourist, color: AppColors.emerald)
            }
        }
    }

    private var cityHistorySection: some View {
        CityHistoryView(city: city, lang: lang)
    }

    private var shortHistorySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            HStack(spacing: 8) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(AppColors.softBlue)
                NLSectionHeader(title: L10n.t("city.short_history", lang))
            }
            Text(city.localizedShortHistory(lang))
                .font(.system(.subheadline, design: .rounded).weight(.medium))
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 2)

            if !city.localizedHistoryTimeline(lang).isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(city.localizedHistoryTimeline(lang), id: \.self) { item in
                        HStack(alignment: .top, spacing: 8) {
                            Circle()
                                .fill(AppColors.softBlue)
                                .frame(width: 6, height: 6)
                                .padding(.top, 5)
                            Text(item)
                                .font(.system(.caption, design: .rounded).weight(.semibold))
                                .foregroundStyle(AppColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(16)
        .appGlassCardStyle(padding: 0, cornerRadius: AppCornerRadius.large, accent: AppColors.softBlue)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(format: L10n.t("city.accessibility.history", lang), city.name))
    }

    private var localHighlightsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: L10n.t("city.local_highlights", lang))
            ForEach(city.localHighlights) { highlight in
                CityInfoCard(
                    icon: highlight.icon,
                    title: highlight.localizedTitle(lang),
                    value: highlight.localizedDescription(lang),
                    color: AppColors.cyanGlow
                )
            }
        }
    }

    private var quickFactsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: quickFactsTitle)
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 150), spacing: AppSpacing.small)],
                alignment: .leading,
                spacing: AppSpacing.small
            ) {
                ForEach(city.quickFacts) { fact in
                    CityQuickFactCard(fact: fact, lang: lang)
                }
            }

            if !city.supportTags.isEmpty {
                FlexibleTagCloud(tags: city.localizedSupportTags(lang))
            }
        }
    }

    private var landmarkCardsSection: some View {
        CityPremiumSection(title: landmarksTitle, subtitle: nil) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.small) {
                    ForEach(city.localHighlights) { highlight in
                        CityLandmarkCard(
                            city: city,
                            highlight: highlight,
                            provinceColor: province.mapHighlightColor,
                            lang: lang
                        )
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 2)
            }
        }
    }

    private var timelineSection: some View {
        CityPremiumSection(title: timelineTitle, subtitle: nil) {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                ForEach(Array(city.timelineEvents.enumerated()), id: \.element.id) { index, event in
                    Button {
                        withAnimation(AppAnimations.standard) {
                            expandedTimelineEventID = expandedTimelineEventID == event.id ? nil : event.id
                        }
                    } label: {
                        CityTimelineRow(
                            event: event,
                            isLast: index == city.timelineEvents.count - 1,
                            isExpanded: expandedTimelineEventID == event.id || (expandedTimelineEventID == nil && index == 0),
                            lang: lang
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func newcomerGuideSection(contentWidth: CGFloat) -> some View {
        CityPremiumSection(title: newcomerTitle, subtitle: newcomerSubtitle) {
            LazyVGrid(
                columns: CityDetailLayout.columns(for: contentWidth, regularMinimum: 220),
                alignment: .leading,
                spacing: CityDetailLayout.cardGap
            ) {
                ForEach(city.newcomerGuide) { item in
                    if let urlString = item.urlString,
                       let url = AppURL.validatedWebURL(URL(string: urlString)) {
                        Link(destination: url) {
                            CityNewcomerGuideCard(item: item, lang: lang)
                        }
                        .buttonStyle(.plain)
                    } else {
                        CityNewcomerGuideCard(item: item, lang: lang)
                    }
                }
            }
        }
    }

    private var personalitySection: some View {
        CityPremiumSection(title: personalityTitle, subtitle: nil) {
            FlexibleTagCloud(tags: city.personalityTags.map { $0.value(for: lang) })
        }
    }

    private var localHighlightFactsSection: some View {
        CityPremiumSection(title: localHighlightsTitle, subtitle: nil) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.small) {
                    ForEach(city.localHighlightFacts) { fact in
                        CityLocalHighlightFactCard(fact: fact, lang: lang)
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 2)
            }
        }
    }

    private func nearbyCitiesSection(contentWidth: CGFloat) -> some View {
        CityPremiumSection(title: nearbyTitle, subtitle: nil) {
            LazyVGrid(
                columns: CityDetailLayout.columns(for: contentWidth, regularMinimum: 170),
                alignment: .leading,
                spacing: CityDetailLayout.cardGap
            ) {
                ForEach(city.nearbyCities, id: \.self) { nearby in
                    CityNearbyChip(name: ProvinceCatalog.localizedCityName(nearby, lang))
                }
            }
        }
    }

    private var officialSourcesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: L10n.t("city.official_sources", lang))
            ForEach(city.officialSourceLinks) { source in
                if let url = AppURL.validatedWebURL(URL(string: source.urlString)) {
                    Link(destination: url) {
                        CityInfoCard(
                            icon: source.icon,
                            title: source.localizedTitle(lang),
                            value: source.urlString,
                            color: AppColors.emerald
                        )
                    }
                    .buttonStyle(.plain)
                } else {
                    CityInfoCard(
                        icon: source.icon,
                        title: source.localizedTitle(lang),
                        value: source.urlString,
                        color: AppColors.emerald
                    )
                }
            }
        }
    }

    private var citySafeDisclaimer: some View {
        InfoCard(
            title: safeDisclaimerTitle,
            subtitle: city.localizedName(lang),
            detail: safeDisclaimerText,
            icon: "checkmark.shield"
        )
    }

    private var imageCreditSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L10n.t("city.image_credit", lang))
                .font(.system(.caption, design: .rounded).weight(.bold))
                .foregroundStyle(AppColors.textTertiary)

            if verifiedMediaCredits.isEmpty {
                Text(city.localizedImageCredit(lang))
                    .font(.system(.caption2, design: .rounded).weight(.medium))
                    .foregroundStyle(AppColors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                ForEach(verifiedMediaCredits, id: \.id) { credit in
                    Text(credit.text)
                        .font(.system(.caption2, design: .rounded).weight(.medium))
                        .foregroundStyle(AppColors.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var verifiedMediaCredits: [MediaCreditLine] {
        [
            creditLine(for: city.media.heroImage, fallbackTitle: city.localizedName(lang)),
            creditLine(for: city.media.flag, fallbackTitle: L10n.t("city.flag", lang)),
            creditLine(for: city.media.coatOfArms, fallbackTitle: L10n.t("city.coat_of_arms", lang))
        ].compactMap { $0 }
    }

    private func creditLine(for asset: CityMediaAsset?, fallbackTitle: String) -> MediaCreditLine? {
        guard let asset, asset.verified else { return nil }
        let source = asset.source ?? L10n.t("city.image_verified_source", lang)
        let license = asset.license ?? L10n.t("city.image_license_unspecified", lang)
        let attribution = asset.attribution ?? fallbackTitle
        return MediaCreditLine(id: "\(asset.type.rawValue)-\(asset.url ?? fallbackTitle)", text: "\(attribution) · \(source) · \(license)")
    }

    // MARK: Localized Labels

    private var populationLabel: String {
        L10n.t("city.population", lang)
    }

    private var areaLabel: String {
        L10n.t("city.area", lang)
    }

    private var provinceLabel: String {
        L10n.t("city.province", lang)
    }

    private var municipalityLabel: String {
        L10n.t("city.municipality", lang)
    }

    private var transportLabel: String {
        switch lang {
        case .russian: return "Общественный транспорт"
        case .dutch:   return "Openbaar vervoer"
        case .english: return "Public transport"
        }
    }

    private var usefulInfoLabel: String {
        L10n.t("city.useful_information", lang)
    }

    private var websiteLabel: String {
        L10n.t("city.official_website", lang)
    }

    private var touristLabel: String {
        switch lang {
        case .russian: return "Туристическая информация"
        case .dutch:   return "Toeristische informatie"
        case .english: return "Tourist information"
        }
    }

    private var mapButtonTitle: String {
        L10n.t("city.open_on_map", lang)
    }

    private var quickFactsTitle: String {
        switch lang {
        case .russian: return "Краткие факты"
        case .dutch: return "Korte feiten"
        case .english: return "Quick facts"
        }
    }

    private var relatedGuidesTitle: String {
        switch lang {
        case .russian: return "Связанные гиды"
        case .dutch: return "Gerelateerde gidsen"
        case .english: return "Related guides"
        }
    }

    private var relatedArticlesTitle: String {
        switch lang {
        case .russian: return "Связанные темы"
        case .dutch: return "Gerelateerde onderwerpen"
        case .english: return "Related topics"
        }
    }

    private var scorecardTitle: String {
        switch lang {
        case .russian: return "Профиль города"
        case .dutch: return "Stadsprofiel"
        case .english: return "City scorecard"
        }
    }

    private var firstWeekTitle: String {
        switch lang {
        case .russian: return "Первые шаги"
        case .dutch: return "Eerste stappen in deze stad"
        case .english: return "First steps in this city"
        }
    }

    private var firstWeekSubtitle: String {
        switch lang {
        case .russian: return "Общие ориентиры. Всегда проверяйте официальные источники для вашей ситуации."
        case .dutch: return "Algemene orientatie. Controleer altijd officiele bronnen voor jouw situatie."
        case .english: return "General orientation. Always verify official sources for your situation."
        }
    }

    private var newcomerPlacesTitle: String {
        switch lang {
        case .russian: return "Полезные места"
        case .dutch: return "Plekken voor nieuwkomers"
        case .english: return "Newcomer places"
        }
    }

    private var newcomerPlacesSubtitle: String {
        switch lang {
        case .russian: return "Муниципалитет, язык, медицина, юридическая помощь, транспорт, документы и безопасность."
        case .dutch: return "Gemeente, taal, zorg, juridische hulp, vervoer, documenten en veiligheid."
        case .english: return "Municipality, language, healthcare, legal help, transport, documents, and safety."
        }
    }

    private var safeDisclaimerTitle: String {
        switch lang {
        case .russian: return "Важное ограничение"
        case .dutch: return "Belangrijke beperking"
        case .english: return "Important limit"
        }
    }

    private var safeDisclaimerText: String {
        switch lang {
        case .russian: return "Приложение даёт только общую информацию. Всегда проверяйте официальные источники для вашей ситуации."
        case .dutch: return "Deze app geeft alleen algemene informatie. Controleer altijd officiële bronnen voor jouw situatie."
        case .english: return "This app gives general information only. Always check official sources for your situation."
        }
    }

    private var scorecardSubtitle: String {
        switch lang {
        case .russian: return "Короткая картина для жизни, учёбы и первых шагов."
        case .dutch: return "Een korte blik op wonen, studeren en starten."
        case .english: return "A compact view for living, studying, and getting started."
        }
    }

    private var whyMoveTitle: String {
        switch lang {
        case .russian: return "Почему выбирают этот город"
        case .dutch: return "Waarom mensen deze stad kiezen"
        case .english: return "Why people choose this city"
        }
    }

    private var costTitle: String {
        switch lang {
        case .russian: return "Стоимость жизни"
        case .dutch: return "Kosten van levensonderhoud"
        case .english: return "Cost of living"
        }
    }

    private var costSubtitle: String {
        switch lang {
        case .russian: return "Ориентиры без выдуманных цен."
        case .dutch: return "Indicaties zonder verzonnen prijzen."
        case .english: return "Simple indicators without invented prices."
        }
    }

    private var landmarksTitle: String {
        switch lang {
        case .russian: return "Ориентиры города"
        case .dutch: return "Stadsoriëntatie"
        case .english: return "Landmarks"
        }
    }

    private var timelineTitle: String {
        switch lang {
        case .russian: return "Хронология города"
        case .dutch: return "Stadstijdlijn"
        case .english: return "City timeline"
        }
    }

    private var newcomerTitle: String {
        switch lang {
        case .russian: return "Новичок в этом городе?"
        case .dutch: return "Nieuw in deze stad?"
        case .english: return "New in this city?"
        }
    }

    private var newcomerSubtitle: String {
        switch lang {
        case .russian: return "Начните с официальных городских источников."
        case .dutch: return "Begin met officiële stadsbronnen."
        case .english: return "Start with official city sources."
        }
    }

    private var personalityTitle: String {
        switch lang {
        case .russian: return "Характер города"
        case .dutch: return "Stadskarakter"
        case .english: return "City personality"
        }
    }

    private var localHighlightsTitle: String {
        switch lang {
        case .russian: return "Местные акценты"
        case .dutch: return "Lokale highlights"
        case .english: return "Local highlights"
        }
    }

    private var nearbyTitle: String {
        switch lang {
        case .russian: return "Рядом"
        case .dutch: return "In de buurt"
        case .english: return "Discover nearby"
        }
    }

    private var visualPreviewTitle: String {
        switch lang {
        case .russian: return "Визуальный предпросмотр"
        case .dutch: return "Visuele preview"
        case .english: return "Visual preview"
        }
    }
}

private struct CityDataBindingErrorView: View {
    let requestedCity: String
    let requestedProvince: String
    let lang: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(AppColors.warning)

            Text(title)
                .font(AppTypography.title)
                .foregroundStyle(AppColors.textPrimary)

            Text(message)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 6) {
                debugLine("requestedCity", requestedCity)
                debugLine("requestedProvince", requestedProvince)
            }
            .padding(AppSpacing.medium)
            .background(AppColors.glassSurface)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous))
        }
        .padding(AppSpacing.screenHorizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var title: String {
        switch lang {
        case .russian: return "Ошибка привязки города"
        case .dutch: return "Stadskoppeling klopt niet"
        case .english: return "City data binding mismatch"
        }
    }

    private var message: String {
        switch lang {
        case .russian: return "Маршрут запросил город и провинцию, которые не совпадают с каталогом. Экран не будет показывать данные другого муниципалитета."
        case .dutch: return "Deze route vroeg om een stad/provincie-combinatie die niet in de catalogus staat. Het scherm toont geen gegevens van een andere gemeente."
        case .english: return "This route requested a city/province pair that does not exist in the catalog. The screen will not display another municipality's data."
        }
    }

    private func debugLine(_ key: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(key)
                .font(.system(.caption, design: .monospaced).weight(.bold))
                .foregroundStyle(AppColors.textTertiary)
            Spacer(minLength: 10)
            Text(value)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(AppColors.textPrimary)
                .textSelection(.enabled)
        }
    }
}

private struct MediaCreditLine: Identifiable {
    let id: String
    let text: String
}

// MARK: - City Identity Components

struct CityHeroImageView: View {
    let city: CityItem
    let province: ProvinceItem
    let lang: AppLanguage
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            heroBackground

            heroTextContent
                .padding(.leading, CityDetailLayout.heroContentPadding)
                .padding(.trailing, CityDetailLayout.heroContentPadding)
                .padding(.top, CityDetailLayout.heroContentPadding)
                .padding(.bottom, CityDetailLayout.heroContentBottomPadding)
                .frame(maxWidth: .infinity, alignment: .bottomLeading)
        }
        .frame(maxWidth: .infinity, minHeight: heroMinimumHeight, alignment: .bottomLeading)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.hero, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.hero, style: .continuous)
                .stroke(Color.white.opacity(0.16), lineWidth: 0.8)
        )
        .shadow(color: Color.black.opacity(0.34), radius: 24, x: 0, y: 12)
        .accessibilityIdentifier("city.hero.image")
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(format: L10n.t("city.accessibility.hero", lang), city.localizedName(lang)))
    }

    private var heroBackground: some View {
        ZStack {
            let resolvedImage = CanonicalPlaceImageResolver.resolveCityHero(city: city)

            fallbackHero
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()

            CityImageView(
                urlString: resolvedImage.urlString,
                height: heroMinimumHeight,
                placeId: city.placeId,
                cityName: city.localizedName(lang),
                fallbackColor: province.mapHighlightColor,
                fallbackURLStrings: resolvedImage.fallbackURLStrings,
                debugContext: resolvedImage.debugContext(
                    screen: "Province city detail hero",
                    entityType: "city",
                    entityName: city.localizedName(lang)
                )
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .transition(.opacity)

            LinearGradient(
                colors: [
                    Color.black.opacity(0.10),
                    AppColors.navyDeep.opacity(0.42),
                    AppColors.navyDeep.opacity(0.88)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

        }
    }

    private func heroTextContent(textWidth: CGFloat) -> some View {
        heroTextContent
            .frame(width: textWidth, alignment: .leading)
    }

    private var heroTextContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 7) {
                Text(city.localizedName(lang))
                    .font(.system(size: heroTitleSize, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(city.cityIdentityLine(lang))
                    .font(.system(size: lang == .russian ? 16 : 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.90))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 8) {
                        heroChip(province.localizedName(lang), icon: "map.fill")
                        heroChip(String(format: residentsFormat, city.populationText), icon: "person.3.fill")
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        heroChip(province.localizedName(lang), icon: "map.fill")
                        heroChip(String(format: residentsFormat, city.populationText), icon: "person.3.fill")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text(city.localizedShortDescription(lang))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.78))
                    .multilineTextAlignment(.leading)
                    .lineLimit(5)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(1)
            }
        }
        .frame(maxWidth: 640, alignment: .leading)
    }

    private func heroChip(_ text: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .bold))
            Text(text)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .lineLimit(2)
                .minimumScaleFactor(0.78)
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundStyle(Color.white.opacity(0.88))
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.13))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.18), lineWidth: 0.7))
    }

    private var heroTitleSize: CGFloat {
        lang == .russian ? 38 : 42
    }

    private var heroMinimumHeight: CGFloat {
        dynamicTypeSize.isAccessibilitySize ? 420 : CityDetailLayout.heroHeight
    }

    private var residentsFormat: String {
        switch lang {
        case .russian: return "%@ жителей"
        case .dutch: return "%@ inwoners"
        case .english: return "%@ residents"
        }
    }

    private var fallbackHero: some View {
        GeneratedCityArtwork(
            cityName: city.localizedName(lang),
            symbol: ProvinceCatalog.identityIconName(for: city.name),
            accent: province.mapHighlightColor
        )
    }
}

struct CityFlagBadge: View {
    let city: CityItem
    let lang: AppLanguage
    var compact = false

    var body: some View {
        let province = ProvinceCatalog.item(id: city.provinceId)
        let flagAssetName = city.flagAssetName
        CityIdentityBadge(
            symbol: city.symbols.flag,
            expectedType: .flag,
            placeholderKind: .flag,
            label: L10n.t("city.flag", lang),
            accessibilityLabel: String(format: L10n.t("city.accessibility.flag", lang), city.localizedName(lang)),
            accentColor: province.mapHighlightColor,
            lang: lang,
            compact: compact,
            localAssetName: flagAssetName
        )
    }
}

struct CityCoatOfArmsBadge: View {
    let city: CityItem
    let lang: AppLanguage
    var compact = false

    var body: some View {
        let coatAssetName = city.coatOfArmsAssetName
        CityIdentityBadge(
            symbol: city.symbols.coatOfArms,
            expectedType: .coatOfArms,
            placeholderKind: .coatOfArms,
            label: L10n.t("city.coat_of_arms", lang),
            accessibilityLabel: String(format: L10n.t("city.accessibility.coat_of_arms", lang), city.localizedName(lang)),
            accentColor: AppColors.softBlue,
            lang: lang,
            compact: compact,
            localAssetName: coatAssetName
        )
    }
}

#if DEBUG && canImport(UIKit)
private struct PlaceLayoutBoundsGuard: ViewModifier {
    let name: String
    private static let logger = Logger(subsystem: "YouNew", category: "PlaceLayout")

    func body(content: Content) -> some View {
        content.background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        audit(proxy: proxy)
                    }
            }
        )
    }

    private func audit(proxy: GeometryProxy) {
        let frame = proxy.frame(in: .global)
        let viewportWidth = UIScreen.main.bounds.width
        guard viewportWidth > 0 else { return }

        if frame.minX < -0.5 || frame.maxX > viewportWidth + 0.5 || frame.width > viewportWidth + 0.5 {
            Self.logger.warning(
                "Place layout overflow in \(name, privacy: .public): minX=\(frame.minX), maxX=\(frame.maxX), width=\(frame.width), viewport=\(viewportWidth)"
            )
        }
    }
}
#endif

private extension View {
    @ViewBuilder
    func debugPlaceLayoutBounds(_ name: String) -> some View {
        #if DEBUG && canImport(UIKit)
        modifier(PlaceLayoutBoundsGuard(name: name))
        #else
        self
        #endif
    }
}

private struct CityIdentityBadge: View {
    let symbol: CitySymbol?
    let expectedType: CitySymbolType
    let placeholderKind: ImagePlaceholderKind
    let label: String
    let accessibilityLabel: String
    let accentColor: Color
    let lang: AppLanguage
    var compact = false
    var localAssetName: String? = nil

    var body: some View {
        let renderableSymbol = CitySymbolValidator.renderableSymbol(symbol, expectedType: expectedType)
        let resolvedLocalAssetName = renderableSymbol.flatMap { localAssetName ?? $0.localAssetName }
        let hasLocalContent = resolvedLocalAssetName.map { AssetAvailability.exists($0) } ?? false
        let hasRemoteContent = renderableSymbol?.isRemoteRenderable == true
        let hasContent = renderableSymbol != nil && (hasLocalContent || hasRemoteContent)
        VStack(spacing: compact ? 0 : AppSpacing.small) {
            ZStack {
                RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous)
                    .fill(AppColors.graphite.opacity(0.72))
                RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .opacity(0.34)

                CityVerifiedSymbolImageView(
                    symbol: renderableSymbol,
                    placeholderKind: placeholderKind,
                    lang: lang,
                    accent: accentColor,
                    showsPlaceholderText: false,
                    localAssetName: resolvedLocalAssetName
                )
                .padding(hasContent ? (compact ? 4 : 6) : 0)
                .onAppear {
                    let result = CitySymbolValidator.validate(symbol, expectedType: expectedType)
                    if !result.isValid {
                        CitySymbolAudit.logRejected(symbol, expectedType: expectedType, failure: result.failure)
                    }
                }
            }
            .frame(height: compact ? 44 : 82)
            .clipped()
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous)
                    .stroke(Color.white.opacity(0.18), lineWidth: 0.8)
            )

            if !compact {
                Text(label)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.78))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.82)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(compact ? 6 : AppSpacing.cardPaddingCompact)
        .frame(maxWidth: compact ? 58 : .infinity, minHeight: compact ? 56 : 132)
        .background(AppColors.glassSurface.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                .stroke(Color.white.opacity(0.14), lineWidth: 0.75)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(hasContent ? accessibilityLabel : label)
    }
}

private struct CityVerifiedSymbolImageView: View {
    let symbol: CitySymbol?
    let placeholderKind: ImagePlaceholderKind
    let lang: AppLanguage
    let accent: Color
    var showsPlaceholderText = true
    var localAssetName: String? = nil

    var body: some View {
        // Use local asset catalog first — iOS AsyncImage cannot decode SVG from URLs
        if let assetName = localAssetName, AssetAvailability.exists(assetName) {
            Image(assetName)
                .resizable()
                .scaledToFit()
                .accessibilityHidden(true)
        } else if let symbol,
                  symbol.isRemoteRenderable,
                  let rawURL = symbol.imageURL ?? symbol.thumbnailURL ?? symbol.url,
                  let url = URL(string: rawURL) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .tint(AppColors.accentLight)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .padding(symbol.type == .coatOfArms ? 4 : 4)
                        .accessibilityHidden(true)
                case .failure:
                    CityOfficialSymbolPlaceholder(kind: placeholderKind, lang: lang, accent: accent, showsText: showsPlaceholderText)
                @unknown default:
                    CityOfficialSymbolPlaceholder(kind: placeholderKind, lang: lang, accent: accent, showsText: showsPlaceholderText)
                }
            }
        } else {
            CityOfficialSymbolPlaceholder(kind: placeholderKind, lang: lang, accent: accent, showsText: showsPlaceholderText)
        }
    }
}

private extension CitySymbol {
    var isRemoteRenderable: Bool {
        guard renderStatus == .renderableRemote else { return false }
        let mime = mimeType?.lowercased() ?? ""
        return mime.contains("png") || mime.contains("jpeg") || mime.contains("jpg") || mime.contains("webp")
    }
}

private enum CityMediaContentMode {
    case fill
    case fit
}

private struct CityVerifiedMediaImageView: View {
    let asset: CityMediaAsset?
    let placeholderKind: ImagePlaceholderKind
    let lang: AppLanguage
    let accent: Color
    var contentMode: CityMediaContentMode = .fit
    var accessibilityLabel: String
    var hidesLoadingBackground: Bool = false
    var debugContext: ImageDebugContext? = nil

    var body: some View {
        AppContentImageView(
            asset: appImageAsset,
            language: lang,
            mode: contentMode == .fill ? .fill : .fit,
            accent: accent,
            aspectRatio: nil,
            cornerRadius: 0,
            showsCaption: false,
            accessibilityLabel: accessibilityLabel,
            fallbackURLs: fallbackURLs,
            debugContext: debugContext
        )
        .background(hidesLoadingBackground ? Color.clear : AppColors.graphite.opacity(0.74))
    }

    private var appImageAsset: AppImageAsset? {
        asset?.appImageAsset(
            id: asset?.placeId ?? asset?.url ?? "verified-place-media",
            title: accessibilityLabel,
            type: .cityHero,
            fallbackURL: fallbackURLs.first
        )
    }

    private var fallbackURLs: [URL] {
        []
    }
}

private struct CityOfficialSymbolPlaceholder: View {
    let kind: ImagePlaceholderKind
    let lang: AppLanguage
    let accent: Color
    var showsText = true

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppColors.graphite.opacity(0.76))

            VStack(spacing: 6) {
                Image(systemName: kind == .flag ? "flag.slash.fill" : "shield.slash.fill")
                    .font(.system(size: showsText ? 18 : 14, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.76))
                    .frame(width: showsText ? 34 : 26, height: showsText ? 34 : 26)
                    .background(accent.opacity(0.16))
                    .clipShape(RoundedRectangle(cornerRadius: showsText ? 10 : 8, style: .continuous))

                if showsText {
                    Text(officialSymbolUnavailableText)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.82))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                        .padding(.horizontal, 8)
                }
            }
        }
    }

    private var officialSymbolUnavailableText: String {
        switch lang {
        case .english: return "Verified local symbol not available"
        case .dutch: return "Geverifieerd lokaal symbool niet beschikbaar"
        case .russian: return "Проверенный местный символ недоступен"
        }
    }
}

private struct CityAssetImageView: View {
    let assetName: String
    let placeholderKind: ImagePlaceholderKind
    let lang: AppLanguage
    let accent: Color
    var showsPlaceholderText = true

    var body: some View {
        if AssetAvailability.exists(assetName) {
            ZStack {
                Image(assetName)
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .accessibilityHidden(true)
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.16),
                        Color.clear,
                        AppColors.navyDeep.opacity(0.28)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        } else {
            ImagePlaceholderView(
                kind: placeholderKind,
                lang: lang,
                accent: accent,
                showsText: showsPlaceholderText
            )
        }
    }
}

private struct CityMissingAssetLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundStyle(Color.white.opacity(0.86))
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.82)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(AppColors.graphite.opacity(0.72))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.18), lineWidth: 0.75))
    }
}

private struct CityImageCreditLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(.caption2, design: .rounded).weight(.medium))
            .foregroundStyle(Color.white.opacity(0.72))
            .lineLimit(2)
            .multilineTextAlignment(.trailing)
            .minimumScaleFactor(0.80)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(Color.black.opacity(0.28))
            .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 0.7)
            )
            .accessibilityLabel(text)
    }
}

struct CityHistoryView: View {
    let city: CityItem
    let lang: AppLanguage
    @Environment(\.openURL) private var openURL
    @State private var activeSource: CityHistorySource?

    private var historyText: String? {
        city.localizedHistoryDetail(lang)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            HStack(alignment: .top, spacing: AppSpacing.small) {
                Image(systemName: "book.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(AppColors.accentLight)
                    .frame(width: 36, height: 36)
                    .background(AppColors.accent.opacity(0.16))
                    .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(.headline, design: .rounded).weight(.bold))
                        .foregroundStyle(AppColors.textPrimary)
                    Text(historyText ?? placeholderText)
                        .font(.system(.subheadline, design: .rounded).weight(.medium))
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                CityHistoryHeraldryCorner(city: city, lang: lang)
                    .frame(width: 82)
            }

            if let sourceURL = city.historySourceURL, historyText != nil {
                Button {
                    guard let url = AppURL.validatedWebURL(URL(string: sourceURL)) else { return }
                    #if canImport(SafariServices) && canImport(UIKit)
                    activeSource = CityHistorySource(url: url)
                    #else
                    openURL(url)
                    #endif
                } label: {
                    Label(readMoreTitle, systemImage: "safari.fill")
                        .font(.system(.caption, design: .rounded).weight(.bold))
                        .foregroundStyle(AppColors.accentLight)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 7)
                        .background(AppColors.accent.opacity(0.12))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(AppColors.accent.opacity(0.24), lineWidth: 0.75))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(readMoreTitle): \(title), \(city.localizedName(lang))")
            }
        }
        .padding(16)
        .background(AppColors.glassSurface.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.14), lineWidth: 0.8)
        )
        .shadow(color: Color.black.opacity(0.20), radius: 18, x: 0, y: 10)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(accessibilityPrefix) \(city.localizedName(lang))")
        .sheet(item: $activeSource) { source in
            #if canImport(SafariServices) && canImport(UIKit)
            CityHistorySafariView(url: source.url)
            #else
            EmptyView()
            #endif
        }
    }

    private var title: String {
        switch lang {
        case .english: return "History"
        case .dutch: return "Geschiedenis"
        case .russian: return "История"
        }
    }

    private var readMoreTitle: String {
        switch lang {
        case .english: return "Read more"
        case .dutch: return "Lees meer"
        case .russian: return "Читать подробнее"
        }
    }

    private var placeholderText: String {
        switch lang {
        case .english: return "Historical background unavailable"
        case .dutch: return "Historische achtergrond niet beschikbaar"
        case .russian: return "Историческая справка недоступна"
        }
    }

    private var accessibilityPrefix: String {
        switch lang {
        case .english: return "City history -"
        case .dutch: return "Stadsgeschiedenis -"
        case .russian: return "История города —"
        }
    }
}

private struct CityHistorySource: Identifiable {
    let id = UUID()
    let url: URL
}

#if canImport(SafariServices) && canImport(UIKit)
private struct CityHistorySafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
#endif

private struct CityHistoryHeraldryCorner: View {
    let city: CityItem
    let lang: AppLanguage

    var body: some View {
        let flagAssetName = city.flagAssetName
        let coatAssetName = city.coatOfArmsAssetName
        HStack(spacing: 6) {
            CityVerifiedSymbolImageView(
                symbol: CitySymbolValidator.renderableSymbol(city.symbols.flag, expectedType: .flag),
                placeholderKind: .flag,
                lang: lang,
                accent: AppColors.accent,
                showsPlaceholderText: false,
                localAssetName: flagAssetName
            )
            .frame(width: 34, height: 34)
            .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))

            ZStack(alignment: .bottom) {
                CityVerifiedSymbolImageView(
                    symbol: CitySymbolValidator.renderableSymbol(city.symbols.coatOfArms, expectedType: .coatOfArms),
                    placeholderKind: .coatOfArms,
                    lang: lang,
                    accent: AppColors.softBlue,
                    showsPlaceholderText: false,
                    localAssetName: coatAssetName
                )
                .frame(width: 34, height: 34)
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))

                if CitySymbolValidator.renderableSymbol(city.symbols.coatOfArms, expectedType: .coatOfArms) == nil {
                    Text(coatPlaceholderText)
                        .font(.system(size: 6, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.92))
                        .lineLimit(2)
                        .minimumScaleFactor(0.60)
                        .multilineTextAlignment(.center)
                        .padding(2)
                        .frame(width: 34)
                        .background(Color.black.opacity(0.42))
                }
            }
        }
        .accessibilityHidden(true)
    }

    private var coatPlaceholderText: String {
        switch lang {
        case .english: return "Official coat of arms unavailable"
        case .dutch: return "Officieel wapen niet beschikbaar"
        case .russian: return "Официальный герб недоступен"
        }
    }
}

private struct CityQuickFactCard: View {
    let fact: CityQuickFact
    let lang: AppLanguage

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: fact.icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(AppColors.accentLight)
                .frame(width: 30, height: 30)
                .background(AppColors.accent.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(fact.localizedTitle(lang))
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
                Text(fact.localizedValue(lang))
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 76, alignment: .topLeading)
        .background(AppColors.glassSurface.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 0.75)
        )
    }
}

private struct CityPremiumSection<Content: View>: View {
    let title: String
    let subtitle: String?
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: title, subtitle: subtitle)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct CityScorecardTile: View {
    let item: CityScorecardItem
    let lang: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: item.icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(item.tint)
                .frame(width: 32, height: 32)
                .background(item.tint.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text(item.localizedTitle(lang))
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
                Text(item.localizedValue(lang))
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 118, alignment: .topLeading)
        .background(AppColors.glassSurface.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.white.opacity(0.13), lineWidth: 0.75))
    }
}

private struct CityReasonPill: View {
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(AppColors.success)
            Text(text)
                .font(.system(.subheadline, design: .rounded).weight(.bold))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 54, alignment: .leading)
        .background(AppColors.glassSurface.opacity(0.70))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.white.opacity(0.12), lineWidth: 0.7))
    }
}

private struct CityRelatedChip: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(color)
            Text(title)
                .font(.system(.caption, design: .rounded).weight(.bold))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.78)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, minHeight: 42, alignment: .leading)
        .background(color.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.white.opacity(0.10), lineWidth: 0.7))
    }
}

private struct CityRelatedSourceRow: View {
    let source: InfoSourceMetadata

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: AppIcons.external)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppColors.emerald)
                .frame(width: 28, height: 28)
                .background(AppColors.emerald.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(source.title)
                    .font(.system(.caption, design: .rounded).weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                Text(source.institution)
                    .font(.system(.caption2, design: .rounded).weight(.medium))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(10)
        .background(AppColors.glassSurface.opacity(0.64))
        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 13, style: .continuous).stroke(Color.white.opacity(0.10), lineWidth: 0.7))
    }
}

private struct CityCostTile: View {
    let item: CityCostItem
    let lang: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: item.icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(item.level.color)
                    .frame(width: 32, height: 32)
                    .background(item.level.color.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                Spacer()
                Text(item.level.localized(lang))
                    .font(.system(.caption, design: .rounded).weight(.bold))
                    .foregroundStyle(item.level.color)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(item.level.color.opacity(0.13))
                    .clipShape(Capsule())
            }
            Text(item.title.value(for: lang))
                .font(.system(.subheadline, design: .rounded).weight(.bold))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 104, alignment: .topLeading)
        .background(AppColors.glassSurface.opacity(0.74))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.white.opacity(0.12), lineWidth: 0.75))
    }
}

private struct CityLandmarkCard: View {
    let city: CityItem
    let highlight: CityLocalHighlight
    let provinceColor: Color
    let lang: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .bottomLeading) {
                let assetName = landmarkAssetName
                if AssetAvailability.exists(assetName) {
                    Image(assetName)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 92)
                        .clipped()
                } else if CityMediaValidator.renderableAsset(city.media.heroImage, expectedType: .heroImage) != nil {
                    CityVerifiedMediaImageView(
                        asset: CityMediaValidator.renderableAsset(city.media.heroImage, expectedType: .heroImage),
                        placeholderKind: .hero,
                        lang: lang,
                        accent: provinceColor,
                        contentMode: .fill,
                        accessibilityLabel: String(format: L10n.t("city.accessibility.hero", lang), city.localizedName(lang))
                    )
                    .frame(height: 92)
                    .clipped()
                } else {
                    GeneratedCategoryArtwork(symbol: highlight.icon, accent: provinceColor)
                }
            }
            .frame(height: 92)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                Text(highlight.localizedTitle(lang))
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                Text(highlight.localizedDescription(lang))
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(3)
            }
        }
        .padding(12)
        .frame(width: 224, alignment: .topLeading)
        .frame(minHeight: 210, alignment: .topLeading)
        .background(AppColors.glassSurface.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(Color.white.opacity(0.12), lineWidth: 0.75))
    }

    private var landmarkAssetName: String {
        "city_\(city.name.lowercased().replacingOccurrences(of: "'", with: "").replacingOccurrences(of: "-", with: "_").replacingOccurrences(of: " ", with: "_"))_\(highlight.id)"
    }
}

private struct CityTimelineRow: View {
    let event: CityTimelineEvent
    let isLast: Bool
    let isExpanded: Bool
    let lang: AppLanguage

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 0) {
                Circle()
                    .fill(AppColors.accentLight)
                    .frame(width: 12, height: 12)
                if !isLast {
                    Rectangle()
                        .fill(AppColors.accentLight.opacity(0.28))
                        .frame(width: 2, height: 58)
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(event.localizedPeriod(lang))
                    .font(.system(.caption, design: .rounded).weight(.bold))
                    .foregroundStyle(AppColors.accentLight)
                Text(event.localizedTitle(lang))
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                if isExpanded {
                    Text(event.localizedDetail(lang))
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundStyle(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.bottom, isLast ? 0 : 10)
        }
    }
}

private struct CityNewcomerGuideCard: View {
    let item: CityNewcomerGuideItem
    let lang: AppLanguage

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: item.icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(AppColors.emerald)
                .frame(width: 32, height: 32)
                .background(AppColors.emerald.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text(item.localizedTitle(lang))
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                Text(item.localizedDetail(lang))
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer(minLength: 4)
            if item.urlString != nil {
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(AppColors.textTertiary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 92, alignment: .topLeading)
        .background(AppColors.glassSurface.opacity(0.74))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.white.opacity(0.12), lineWidth: 0.75))
    }
}

private struct CityNewcomerPlaceCard: View {
    let place: NewcomerPlace
    let lang: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: place.iconName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(place.accentColor)
                    .frame(width: 34, height: 34)
                    .background(place.accentColor.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                VStack(alignment: .leading, spacing: 4) {
                    Text(place.title(lang))
                        .font(.system(.subheadline, design: .rounded).weight(.bold))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(2)
                    Text(place.category.localized(lang))
                        .font(.system(.caption2, design: .rounded).weight(.bold))
                        .foregroundStyle(place.accentColor)
                        .lineLimit(1)
                }
                Spacer(minLength: 4)
                if place.officialWebsiteURL != nil {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(AppColors.textTertiary)
                }
            }

            Text(place.description(lang))
                .font(.system(.caption, design: .rounded).weight(.semibold))
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)

            Text(place.confidenceLevel.localized(lang))
                .font(.system(.caption2, design: .rounded).weight(.bold))
                .foregroundStyle(place.confidenceLevel == .verified ? AppColors.success : AppColors.warning)
                .lineLimit(1)
        }
        .padding(13)
        .frame(maxWidth: .infinity, minHeight: 154, alignment: .topLeading)
        .background(AppColors.glassSurface.opacity(0.76))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(place.accentColor.opacity(0.20), lineWidth: 0.9))
    }
}

private struct CityLocalHighlightFactCard: View {
    let fact: CityLocalHighlightFact
    let lang: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: fact.icon)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(AppColors.orangeGlow)
            Text(fact.localizedTitle(lang))
                .font(.system(.caption, design: .rounded).weight(.semibold))
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(2)
            Text(fact.localizedValue(lang))
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(width: 182, alignment: .topLeading)
        .frame(minHeight: 150, alignment: .topLeading)
        .background(AppColors.glassSurface.opacity(0.76))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.white.opacity(0.12), lineWidth: 0.75))
    }
}

private struct CityNearbyChip: View {
    let name: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "arrow.right.circle.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(AppColors.accentLight)
            Text(name)
                .font(.system(.subheadline, design: .rounded).weight(.bold))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.glassSurface.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).stroke(Color.white.opacity(0.12), lineWidth: 0.7))
    }
}

private struct FlexibleTagCloud: View {
    let tags: [String]

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 116), spacing: 8)],
            alignment: .leading,
            spacing: 8
        ) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(.system(.caption, design: .rounded).weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .frame(maxWidth: .infinity)
                    .background(AppColors.chipBackground.opacity(0.82))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 0.7))
            }
        }
    }
}

private enum CityAssetAudit {
    private static var reportedAssets = Set<String>()

    static func logMissing(_ assetName: String) {
        #if DEBUG
        _ = reportedAssets.insert(assetName)
        #endif
    }
}

private enum CitySymbolAudit {
    private static var reportedSymbols = Set<String>()
    private static let logger = Logger(subsystem: "YouNew", category: "CitySymbols")

    static func logRejected(_ symbol: CitySymbol?, expectedType: CitySymbolType, failure: CitySymbolValidationFailure?) {
        #if DEBUG
        let key = "\(expectedType.rawValue)|\(symbol?.url ?? "nil")|\(String(describing: failure))"
        guard reportedSymbols.insert(key).inserted else { return }
        logger.warning("Rejected city \(expectedType.rawValue, privacy: .public) symbol: \(symbol?.url ?? "nil", privacy: .public) reason: \(String(describing: failure), privacy: .public)")
        #endif
    }
}

// MARK: - Cards and Placeholders

private struct ProvinceHeroMapPanel: View {
    let province: ProvinceItem

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(AppColors.graphite.opacity(0.64))
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial)
                .opacity(0.26)
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    RadialGradient(
                        colors: [province.mapHighlightColor.opacity(0.20), .clear],
                        center: .top,
                        startRadius: 0,
                        endRadius: 120
                    )
                )

            ProvinceHighlightMapView(
                provinceID: province.id,
                highlightColor: province.mapHighlightColor,
                showLabels: false
            )
            .padding(10)
            .opacity(0.92)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.28), province.mapHighlightColor.opacity(0.22), Color.white.opacity(0.06)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.8
                )
        }
        .shadow(color: province.mapHighlightColor.opacity(0.14), radius: 18, x: 0, y: 0)
        .shadow(color: Color.black.opacity(0.24), radius: 16, x: 0, y: 10)
    }
}

private struct ProvinceMetricCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(color)
                    .frame(width: 28, height: 28)
                    .background(color.opacity(0.16))
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .stroke(color.opacity(0.22), lineWidth: 0.7)
                    )
                Spacer(minLength: 4)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(value)
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                Text(label)
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
                    .allowsTightening(true)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .topLeading)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppColors.graphite.opacity(0.92))
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.09), Color.clear, Color.black.opacity(0.12)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        RadialGradient(
                            colors: [color.opacity(0.12), .clear],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 130
                        )
                    )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.22), AppColors.stroke.opacity(0.48)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.75
                )
        }
        .shadow(color: Color.black.opacity(0.18), radius: 14, x: 0, y: 8)
    }
}

private struct ProvinceDarkInfoRow: View {
    let icon: String
    let title: String
    let value: String
    var color: Color = AppColors.softBlue

    var body: some View {
        HStack(spacing: 13) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(color)
                .frame(width: 42, height: 42)
                .background(color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .stroke(color.opacity(0.24), lineWidth: 0.7)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)
                Text(value)
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.86)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 6)
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                .fill(AppColors.graphite.opacity(0.90))
                .overlay(
                    LinearGradient(
                        colors: [Color.white.opacity(0.08), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                .stroke(Color.white.opacity(0.14), lineWidth: 0.75)
        }
        .shadow(color: Color.black.opacity(0.16), radius: 14, x: 0, y: 8)
    }
}

private struct ProvinceCityPreviewCard: View {
    let city: CityItem
    let province: ProvinceItem
    let lang: AppLanguage

    var body: some View {
        HStack(spacing: 14) {
            CityFlagBadge(city: city, lang: lang, compact: true)

            VStack(alignment: .leading, spacing: 5) {
                Text(city.name)
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.86)
                HStack(spacing: 7) {
                    Label(city.population, systemImage: "person.2.fill")
                    Text("•")
                        .foregroundStyle(AppColors.textTertiary)
                    Text(city.municipality)
                        .lineLimit(1)
                }
                .font(.system(.caption, design: .rounded).weight(.semibold))
                .foregroundStyle(AppColors.textSecondary)
                .minimumScaleFactor(0.82)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppColors.textTertiary)
                .frame(width: 28, height: 28)
                .background(Color.white.opacity(0.06))
                .clipShape(Circle())
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 82, alignment: .leading)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppColors.graphite.opacity(0.90))
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.085), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.18), AppColors.stroke.opacity(0.44)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.75
                )
        }
        .shadow(color: Color.black.opacity(0.16), radius: 12, x: 0, y: 7)
        .accessibilityElement(children: .combine)
    }
}

private struct ProvinceRowCard: View {
    let province: ProvinceItem
    let lang: AppLanguage
    var isSelected: Bool = false
    var subtitleOverride: String? = nil

    var body: some View {
        HStack(spacing: 12) {
            ProvinceFlagView(province: province, lang: lang)
                .frame(width: 58, height: 58)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.16), lineWidth: 0.75)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(province.localizedName(lang))
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.86)
                Text(subtitleOverride ?? "\(capitalLabel): \(province.capital)")
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.84)
                Text("\(province.municipalityCount) \(municipalityLabel)")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(AppColors.cyanGlow)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .allowsTightening(true)
            }

            Spacer(minLength: 6)

            NetherlandsMiniMapView(
                provinceID: province.id,
                highlightColor: province.mapHighlightColor
            )
            .frame(width: 54, height: 74)
            .padding(.horizontal, 2)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppColors.textTertiary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppColors.graphite.opacity(0.92))
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.08),
                                province.mapHighlightColor.opacity(isSelected ? 0.16 : 0.08),
                                Color.black.opacity(0.10)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                if isSelected {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            RadialGradient(
                                colors: [AppColors.orangeGlow.opacity(0.18), .clear],
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: 180
                            )
                        )
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(isSelected ? 0.34 : 0.20),
                            province.mapHighlightColor.opacity(isSelected ? 0.34 : 0.14),
                            AppColors.stroke.opacity(0.40)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: isSelected ? 1.0 : 0.75
                )
        }
        .shadow(color: isSelected ? AppColors.orangeGlow.opacity(0.18) : Color.black.opacity(0.18), radius: 16, x: 0, y: 8)
        .accessibilityElement(children: .combine)
    }

    private var capitalLabel: String {
        switch lang {
        case .russian: return "Столица"
        case .dutch: return "Hoofdstad"
        case .english: return "Capital"
        }
    }

    private var municipalityLabel: String {
        switch lang {
        case .russian: return "муниципалитетов"
        case .dutch: return "gemeenten"
        case .english: return "municipalities"
        }
    }
}

private struct CityRowCard: View {
    let city: CityItem
    let lang: AppLanguage

    var body: some View {
        let province = ProvinceCatalog.item(id: city.provinceId)

        HStack(spacing: 12) {
            CityFlagBadge(city: city, lang: lang, compact: true)

            VStack(alignment: .leading, spacing: 4) {
                Text(city.localizedName(lang))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                Text(city.localizedShortDescription(lang))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 6) {
                    Text(city.population)
                    Text("•")
                    Text(province.localizedName(lang))
                    if let website = city.officialWebsite {
                        Text("•")
                        Text(website)
                    }
                }
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.cyanGlow)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
            }

            Spacer()

            VStack(spacing: 8) {
            Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppColors.orangeGlow)
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(AppColors.textTertiary)
            }
        }
        .padding(14)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppColors.graphite.opacity(0.90))
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.085), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 0.75)
        )
        .shadow(color: Color.black.opacity(0.16), radius: 12, x: 0, y: 7)
    }
}

private struct ProvinceActionButtonContent: View {
    let title: String
    let icon: String
    var gradient: LinearGradient = LinearGradient(
        colors: [AppColors.accent, AppColors.accentLight],
        startPoint: .leading,
        endPoint: .trailing
    )

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.84)
            Spacer()
            Image(systemName: "arrow.right")
                .font(.system(size: 13, weight: .bold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(gradient)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous))
        .shadow(color: AppColors.accent.opacity(0.28), radius: 14, x: 0, y: 7)
    }
}

struct ProvinceFlagView: View {
    let province: ProvinceItem
    let lang: AppLanguage

    var body: some View {
        let flag = CitySymbolValidator.renderableSymbol(province.symbols.flag, expectedType: .flag)

        CityVerifiedSymbolImageView(
            symbol: flag,
            placeholderKind: .flag,
            lang: lang,
            accent: province.mapHighlightColor,
            showsPlaceholderText: false,
            localAssetName: provinceFlagAssetName
        )
        .accessibilityLabel(
            flag == nil
            ? officialSymbolUnavailableText
            : String(format: L10n.t("city.accessibility.flag", lang), province.localizedName(lang))
        )
    }

    private var officialSymbolUnavailableText: String {
        switch lang {
        case .english: return "Verified local symbol not available"
        case .dutch: return "Geverifieerd lokaal symbool niet beschikbaar"
        case .russian: return "Проверенный местный символ недоступен"
        }
    }

    private var provinceFlagAssetName: String {
        province.id
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .lowercased()
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: " ", with: "_") + "_flag"
    }
}

struct NetherlandsMiniMapView: View {
    let provinceID: String?
    let highlightColor: Color

    var body: some View {
        ProvinceHighlightMapView(
            provinceID: provinceID,
            highlightColor: highlightColor,
            showLabels: false
        )
    }
}

struct ProvinceInteractiveMapView: View {
    @Binding var selectedProvinceID: String?
    var showLabels: Bool = false

    private var selectedProvince: ProvinceItem? {
        selectedProvinceID.map { ProvinceCatalog.item(id: $0) }
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ProvinceHighlightMapView(
                    provinceID: selectedProvinceID,
                    highlightColor: selectedProvince?.mapHighlightColor ?? AppColors.dutchOrange,
                    showLabels: showLabels
                )
                .allowsHitTesting(false)

                ForEach(ProvinceHitZones.all) { zone in
                    Rectangle()
                        .fill(Color.clear)
                        .frame(
                            width: proxy.size.width * zone.normalizedFrame.width,
                            height: proxy.size.height * zone.normalizedFrame.height
                        )
                        .contentShape(Rectangle())
                        .position(
                            x: proxy.size.width * zone.normalizedFrame.midX,
                            y: proxy.size.height * zone.normalizedFrame.midY
                        )
                        .onTapGesture {
                            selectProvince(zone)
                        }
                        .accessibilityIdentifier(zone.accessibilityIdentifier)
                }
            }
        }
    }

    private func selectProvince(_ hitZone: ProvinceHitZone) {
        withAnimation(AppAnimations.standard) {
            selectedProvinceID = hitZone.id
        }

        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }
}

struct ProvinceHighlightMapView: View {
    let provinceID: String?
    let highlightColor: Color
    var showLabels: Bool = false

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack {
                if provinceID == nil, AssetAvailability.exists("netherlands_map_provinces") {
                    Image("netherlands_map_provinces")
                        .resizable()
                        .scaledToFit()
                        .frame(width: size.width, height: size.height)
                } else if let provinceID, AssetAvailability.exists("netherlands_map_base"), AssetAvailability.exists(ProvinceCatalog.item(id: provinceID).mapOverlayAssetName) {
                    Image("netherlands_map_base")
                        .resizable()
                        .scaledToFit()
                        .opacity(0.55)
                        .frame(width: size.width, height: size.height)
                    Image(ProvinceCatalog.item(id: provinceID).mapOverlayAssetName)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(highlightColor)
                        .shadow(color: highlightColor.opacity(0.45), radius: 10, x: 0, y: 0)
                        .frame(width: size.width, height: size.height)
                } else {
                    fallbackVectorMap(size: size)
                }

                if showLabels {
                    Text(provinceID.flatMap { ProvinceCatalog.item(id: $0).shortName } ?? "NL")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.black.opacity(0.24))
                        .clipShape(Capsule())
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        .padding(8)
                }
            }
        }
        .drawingGroup()
    }

    private func fallbackVectorMap(size: CGSize) -> some View {
        ZStack {
            ForEach(ProvinceMapShape.allCases) { shape in
                RoundedRectangle(cornerRadius: shape.cornerRadius, style: .continuous)
                    .fill(fillColor(for: shape))
                    .frame(width: size.width * shape.width, height: size.height * shape.height)
                    .rotationEffect(.degrees(shape.rotation))
                    .position(x: size.width * shape.x, y: size.height * shape.y)
            }
        }
    }

    private func isHighlighted(_ shape: ProvinceMapShape) -> Bool {
        provinceID == nil || provinceID == shape.id
    }

    private func fillColor(for shape: ProvinceMapShape) -> Color {
        if isHighlighted(shape) {
            return provinceID == nil ? shape.defaultColor.opacity(0.86) : highlightColor
        }
        return AppColors.softBlue.opacity(0.20)
    }
}

struct ProvinceMapShape: Identifiable, CaseIterable {
    let id: String
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat
    let rotation: Double
    let cornerRadius: CGFloat
    let defaultColor: Color

    static let allCases: [ProvinceMapShape] = [
        ProvinceMapShape(id: "Groningen", x: 0.66, y: 0.12, width: 0.28, height: 0.13, rotation: 6, cornerRadius: 12, defaultColor: AppColors.success),
        ProvinceMapShape(id: "Friesland", x: 0.43, y: 0.16, width: 0.32, height: 0.14, rotation: -8, cornerRadius: 13, defaultColor: AppColors.accent),
        ProvinceMapShape(id: "Drenthe", x: 0.63, y: 0.28, width: 0.24, height: 0.16, rotation: 8, cornerRadius: 13, defaultColor: AppColors.error),
        ProvinceMapShape(id: "Overijssel", x: 0.58, y: 0.43, width: 0.30, height: 0.16, rotation: -4, cornerRadius: 13, defaultColor: AppColors.warning),
        ProvinceMapShape(id: "Flevoland", x: 0.43, y: 0.39, width: 0.22, height: 0.12, rotation: -12, cornerRadius: 11, defaultColor: AppColors.softBlue),
        ProvinceMapShape(id: "Noord-Holland", x: 0.27, y: 0.34, width: 0.22, height: 0.28, rotation: -12, cornerRadius: 15, defaultColor: AppColors.dutchOrange),
        ProvinceMapShape(id: "Utrecht", x: 0.39, y: 0.52, width: 0.18, height: 0.12, rotation: 9, cornerRadius: 10, defaultColor: AppColors.violet),
        ProvinceMapShape(id: "Gelderland", x: 0.59, y: 0.58, width: 0.34, height: 0.18, rotation: 5, cornerRadius: 14, defaultColor: AppColors.routeLine),
        ProvinceMapShape(id: "Zuid-Holland", x: 0.25, y: 0.57, width: 0.26, height: 0.18, rotation: -8, cornerRadius: 14, defaultColor: AppColors.warning),
        ProvinceMapShape(id: "Zeeland", x: 0.18, y: 0.76, width: 0.25, height: 0.12, rotation: -12, cornerRadius: 12, defaultColor: AppColors.softBlue),
        ProvinceMapShape(id: "Noord-Brabant", x: 0.48, y: 0.78, width: 0.45, height: 0.16, rotation: 2, cornerRadius: 15, defaultColor: AppColors.dutchOrange),
        ProvinceMapShape(id: "Limburg", x: 0.68, y: 0.90, width: 0.16, height: 0.22, rotation: -8, cornerRadius: 13, defaultColor: AppColors.textTertiary)
    ]
}

enum AssetAvailability {
    private static var cache: [String: Bool] = [:]
    private static let lock = NSLock()

    static func exists(_ name: String) -> Bool {
        lock.lock()
        if let cached = cache[name] {
            lock.unlock()
            return cached
        }
        lock.unlock()

        #if canImport(UIKit)
        let exists = UIImage(named: name) != nil
        #else
        let exists = true
        #endif

        lock.lock()
        cache[name] = exists
        lock.unlock()
        return exists
    }
}

// MARK: - Hit Zones

struct ProvinceHitZone: Identifiable, Hashable {
    let id: String
    let normalizedFrame: CGRect

    var area: CGFloat {
        normalizedFrame.width * normalizedFrame.height
    }

    var accessibilityIdentifier: String {
        "provinces.map.zone.\(id.snakeCasedProvinceID)"
    }
}

enum ProvinceHitZones {
    static let all: [ProvinceHitZone] = [
        ProvinceHitZone(id: "Groningen", normalizedFrame: CGRect(x: 0.58, y: 0.07, width: 0.31, height: 0.18)),
        ProvinceHitZone(id: "Friesland", normalizedFrame: CGRect(x: 0.35, y: 0.07, width: 0.28, height: 0.23)),
        ProvinceHitZone(id: "Drenthe", normalizedFrame: CGRect(x: 0.57, y: 0.23, width: 0.26, height: 0.29)),
        ProvinceHitZone(id: "Noord-Holland", normalizedFrame: CGRect(x: 0.17, y: 0.10, width: 0.22, height: 0.47)),
        ProvinceHitZone(id: "Flevoland", normalizedFrame: CGRect(x: 0.39, y: 0.32, width: 0.20, height: 0.24)),
        ProvinceHitZone(id: "Overijssel", normalizedFrame: CGRect(x: 0.55, y: 0.44, width: 0.31, height: 0.26)),
        ProvinceHitZone(id: "Utrecht", normalizedFrame: CGRect(x: 0.35, y: 0.52, width: 0.18, height: 0.18)),
        ProvinceHitZone(id: "Gelderland", normalizedFrame: CGRect(x: 0.46, y: 0.57, width: 0.32, height: 0.27)),
        ProvinceHitZone(id: "Zuid-Holland", normalizedFrame: CGRect(x: 0.13, y: 0.58, width: 0.30, height: 0.20)),
        ProvinceHitZone(id: "Zeeland", normalizedFrame: CGRect(x: 0.07, y: 0.76, width: 0.28, height: 0.15)),
        ProvinceHitZone(id: "Noord-Brabant", normalizedFrame: CGRect(x: 0.25, y: 0.78, width: 0.51, height: 0.16)),
        ProvinceHitZone(id: "Limburg", normalizedFrame: CGRect(x: 0.66, y: 0.79, width: 0.20, height: 0.20))
    ]

    static func hitTest(_ point: CGPoint) -> ProvinceHitZone? {
        all
            .filter { $0.normalizedFrame.contains(point) }
            .sorted { $0.area < $1.area }
            .first
    }
}

private extension String {
    var snakeCasedProvinceID: String {
        replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: " ", with: "_")
            .lowercased()
    }
}

// MARK: - Data

struct ProvinceItem: Identifiable {
    let id: String
    let nameByLanguage: [AppLanguage: String]
    let capital: String
    let population: String
    let areaKm2: String
    let municipalityCount: Int
    let officialWebsite: String
    let mapOverlayAssetName: String
    let mapHighlightColor: Color
    let cities: [CityItem]

    var shortName: String {
        id.split(separator: "-").map { String($0.prefix(1)) }.joined()
    }

    func localizedName(_ lang: AppLanguage) -> String {
        nameByLanguage[lang] ?? nameByLanguage[.english] ?? id
    }

    var visualAssetBaseName: String {
        switch id {
        case "Noord-Holland": return "province_north_holland"
        case "Zuid-Holland": return "province_south_holland"
        case "Noord-Brabant": return "province_north_brabant"
        default:
            return "province_" + id
                .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "en_US_POSIX"))
                .lowercased()
                .replacingOccurrences(of: "'", with: "")
                .replacingOccurrences(of: "-", with: "_")
                .replacingOccurrences(of: " ", with: "_")
        }
    }

    var visualHeroAssetName: String { "\(visualAssetBaseName)_hero" }
    var visualMapAssetName: String { "\(visualAssetBaseName)_map" }

    var media: CityMedia {
        VerifiedPlaceMediaRegistry.media(for: .province, name: id)
    }

    var placeId: String {
        CuratedPlaceHeroMediaRegistry.provincePlaceId(provinceName: id)
    }

    var symbols: CitySymbols {
        .unavailable
    }
}

struct CityItem: Identifiable {
    let id: String
    let name: String
    let province: String
    let municipalityName: String
    let populationText: String
    let areaText: String
    let officialWebsiteTitle: String?
    let officialWebsiteURL: String?
    let latitude: Double
    let longitude: Double
    let media: CityMedia
    let heroImageAssetName: String
    let shortDescription: LocalizedCityText
    let shortHistory: LocalizedCityText
    var historyEN: String? = nil
    var historyNL: String? = nil
    var historyRU: String? = nil
    var historySourceURL: String? = nil
    let historyTimeline: [LocalizedCityText]
    let localHighlights: [CityLocalHighlight]
    let quickFacts: [CityQuickFact]
    let supportTags: [LocalizedCityText]
    let scorecard: [CityScorecardItem]
    let moveReasons: [LocalizedCityText]
    let costOfLiving: [CityCostItem]
    let timelineEvents: [CityTimelineEvent]
    let newcomerGuide: [CityNewcomerGuideItem]
    let firstWeekSteps: [CityNewcomerGuideItem]
    let newcomerPlaces: [NewcomerPlace]
    let officialServices: [NewcomerPlace]
    let languageAndIntegration: [NewcomerPlace]
    let healthcareAccess: [NewcomerPlace]
    let legalAndRightsHelp: [NewcomerPlace]
    let transportHubs: [NewcomerPlace]
    let communityAndLibraries: [NewcomerPlace]
    let emergencyAndSafety: [NewcomerPlace]
    let familyAndChildren: [NewcomerPlace]
    let lgbtqSupport: [NewcomerPlace]
    let documentAndAdminHelp: [NewcomerPlace]
    let housingSupport: [NewcomerPlace]
    let workAndUWVInfo: [NewcomerPlace]
    let personalityTags: [LocalizedCityText]
    let localHighlightFacts: [CityLocalHighlightFact]
    let nearbyCities: [String]
    let officialSourceLinks: [CitySourceLink]
    let imageCredit: LocalizedCityText
    let searchKeywords: [String]
    let population: String
    let municipality: String
    let provinceId: String
    let officialWebsite: String?
    let coordinate: Coordinate?
    var areaKm2: String?           = nil
    var dutchCode: String?         = nil
    var transportOperator: String? = nil
    var touristInfoURL: String?    = nil

    var mapQuery: String {
        "\(name), \(municipalityName), Netherlands"
    }

    var heroImageName: String? {
        heroImageAssetName.isEmpty ? nil : heroImageAssetName
    }

    var placeId: String {
        CuratedPlaceHeroMediaRegistry.cityPlaceId(cityName: name, provinceName: province)
    }

    var flagImageName: String? {
        CityMediaValidator.renderableAsset(media.flag, expectedType: .flag)?.url
    }

    var coatOfArmsImageName: String? {
        CityMediaValidator.renderableAsset(media.coatOfArms, expectedType: .coatOfArms)?.url
    }

    var flagAssetName: String {
        let id = name.lowercased()
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: " ", with: "_")
        return "city_\(id)_flag"
    }

    var coatOfArmsAssetName: String {
        let id = name.lowercased()
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: " ", with: "_")
        return "city_\(id)_coat_of_arms"
    }

    var symbols: CitySymbols {
        CitySymbols(flag: media.flag?.symbol, coatOfArms: media.coatOfArms?.symbol)
    }
}

enum CityMediaType: String, Codable, Equatable {
    case heroImage
    case flag
    case coatOfArms
}

typealias CitySymbolType = CityMediaType

struct CityMediaAsset: Codable, Equatable {
    let url: String?
    let sourcePageURL: String?
    let thumbnailURL: String?
    let imageURL: String?
    let localAssetName: String?
    let renderStatus: MediaRenderStatus
    let source: String?
    let sourceType: PlaceMediaSourceType?
    let license: String?
    let attribution: String?
    let verified: Bool
    let updatedAt: String?
    let type: CityMediaType
    var pixelWidth: Int? = nil
    var pixelHeight: Int? = nil
    var mimeType: String? = nil
    var placeId: String? = nil

    init(
        url: String?,
        sourcePageURL: String? = nil,
        thumbnailURL: String? = nil,
        imageURL: String? = nil,
        localAssetName: String? = nil,
        renderStatus: MediaRenderStatus = .unavailable,
        source: String?,
        sourceType: PlaceMediaSourceType? = nil,
        license: String? = nil,
        attribution: String? = nil,
        verified: Bool,
        updatedAt: String?,
        type: CityMediaType,
        pixelWidth: Int? = nil,
        pixelHeight: Int? = nil,
        mimeType: String? = nil,
        placeId: String? = nil
    ) {
        self.url = url
        self.sourcePageURL = sourcePageURL
        self.thumbnailURL = thumbnailURL
        self.imageURL = imageURL
        self.localAssetName = localAssetName
        self.renderStatus = renderStatus
        self.source = source
        self.sourceType = sourceType
        self.license = license
        self.attribution = attribution
        self.verified = verified
        self.updatedAt = updatedAt
        self.type = type
        self.pixelWidth = pixelWidth
        self.pixelHeight = pixelHeight
        self.mimeType = mimeType
        self.placeId = placeId
    }

    var symbol: CitySymbol? {
        guard type == .flag || type == .coatOfArms else { return nil }
        return CitySymbol(
            url: url,
            sourcePageURL: sourcePageURL,
            thumbnailURL: thumbnailURL,
            imageURL: imageURL,
            localAssetName: localAssetName,
            renderStatus: renderStatus,
            source: source,
            sourceType: sourceType,
            license: license,
            attribution: attribution,
            verified: verified,
            updatedAt: updatedAt,
            type: type,
            pixelWidth: pixelWidth,
            pixelHeight: pixelHeight,
            mimeType: mimeType,
            placeId: placeId
        )
    }
}

struct CityMedia: Codable, Equatable {
    let heroImage: CityMediaAsset?
    let flag: CityMediaAsset?
    let coatOfArms: CityMediaAsset?

    static let unavailable = CityMedia(heroImage: nil, flag: nil, coatOfArms: nil)
}

struct CitySymbol: Codable, Equatable {
    let url: String?
    let sourcePageURL: String?
    let thumbnailURL: String?
    let imageURL: String?
    let localAssetName: String?
    let renderStatus: MediaRenderStatus
    let source: String?
    let sourceType: PlaceMediaSourceType?
    let license: String?
    let attribution: String?
    let verified: Bool
    let updatedAt: String?
    let type: CityMediaType
    var pixelWidth: Int? = nil
    var pixelHeight: Int? = nil
    var mimeType: String? = nil
    var placeId: String? = nil

    init(
        url: String?,
        sourcePageURL: String? = nil,
        thumbnailURL: String? = nil,
        imageURL: String? = nil,
        localAssetName: String? = nil,
        renderStatus: MediaRenderStatus = .unavailable,
        source: String?,
        sourceType: PlaceMediaSourceType? = nil,
        license: String? = nil,
        attribution: String? = nil,
        verified: Bool,
        updatedAt: String?,
        type: CityMediaType,
        pixelWidth: Int? = nil,
        pixelHeight: Int? = nil,
        mimeType: String? = nil,
        placeId: String? = nil
    ) {
        self.url = url
        self.sourcePageURL = sourcePageURL
        self.thumbnailURL = thumbnailURL
        self.imageURL = imageURL
        self.localAssetName = localAssetName
        self.renderStatus = renderStatus
        self.source = source
        self.sourceType = sourceType
        self.license = license
        self.attribution = attribution
        self.verified = verified
        self.updatedAt = updatedAt
        self.type = type
        self.pixelWidth = pixelWidth
        self.pixelHeight = pixelHeight
        self.mimeType = mimeType
        self.placeId = placeId
    }

    var mediaAsset: CityMediaAsset {
        CityMediaAsset(
            url: url,
            sourcePageURL: sourcePageURL,
            thumbnailURL: thumbnailURL,
            imageURL: imageURL,
            localAssetName: localAssetName,
            renderStatus: renderStatus,
            source: source,
            sourceType: sourceType,
            license: license,
            attribution: attribution,
            verified: verified,
            updatedAt: updatedAt,
            type: type,
            pixelWidth: pixelWidth,
            pixelHeight: pixelHeight,
            mimeType: mimeType,
            placeId: placeId
        )
    }
}

struct CitySymbols: Codable, Equatable {
    let flag: CitySymbol?
    let coatOfArms: CitySymbol?

    static let unavailable = CitySymbols(flag: nil, coatOfArms: nil)
}

enum CitySymbolValidationFailure: Equatable {
    case missingSymbol
    case unverified
    case missingURL
    case invalidURL
    case disallowedFileType
    case untrustedSource
    case placeholderOrGenerated
    case wrongSymbolType
    case imageTooSmall
    case countryFlagUsedAsCityFlag
    case wrongPlace
}

struct CitySymbolValidationResult: Equatable {
    let isValid: Bool
    let failure: CitySymbolValidationFailure?
}

enum CityMediaValidator {
    static func renderableAsset(_ asset: CityMediaAsset?, expectedType: CityMediaType) -> CityMediaAsset? {
        validate(asset, expectedType: expectedType).isValid ? asset : nil
    }

    static func validate(_ asset: CityMediaAsset?, expectedType: CityMediaType) -> CitySymbolValidationResult {
        guard let asset else {
            return CitySymbolValidationResult(isValid: false, failure: .missingSymbol)
        }

        if expectedType == .flag || expectedType == .coatOfArms {
            return CitySymbolValidator.validate(asset.symbol, expectedType: expectedType)
        }

        guard asset.type == expectedType else {
            return CitySymbolValidationResult(isValid: false, failure: .wrongSymbolType)
        }

        guard asset.verified else {
            return CitySymbolValidationResult(isValid: false, failure: .unverified)
        }

        if expectedType == .heroImage {
            if let localAssetName = asset.localAssetName, AssetAvailability.exists(localAssetName) {
                return CitySymbolValidationResult(isValid: true, failure: nil)
            }
            // local asset absent — fall through to URL validation so remote images can render
            #if DEBUG
            if let localAssetName = asset.localAssetName {
                print("Missing local asset \(localAssetName), falling back to URL")
            }
            #endif
        }

        guard let rawURL = asset.url?.trimmingCharacters(in: .whitespacesAndNewlines), !rawURL.isEmpty else {
            return CitySymbolValidationResult(isValid: false, failure: .missingURL)
        }

        guard let components = URLComponents(string: rawURL),
              let scheme = components.scheme?.lowercased(),
              ["https", "http"].contains(scheme),
              let host = components.host?.lowercased(),
              !host.isEmpty else {
            return CitySymbolValidationResult(isValid: false, failure: .invalidURL)
        }

        let pathExtension = (components.path as NSString).pathExtension.lowercased()
        guard ["svg", "png", "jpg", "jpeg", "webp"].contains(pathExtension) else {
            return CitySymbolValidationResult(isValid: false, failure: .disallowedFileType)
        }

        let sourceText = asset.source?.lowercased() ?? ""
        guard CitySymbolValidator.isTrustedSource(sourceText, sourceType: asset.sourceType, host: host) else {
            return CitySymbolValidationResult(isValid: false, failure: .untrustedSource)
        }

        let combinedText = "\(rawURL.lowercased()) \(sourceText) \(asset.attribution?.lowercased() ?? "")"
        guard !CitySymbolValidator.containsPlaceholderOrGeneratedMarker(combinedText) else {
            return CitySymbolValidationResult(isValid: false, failure: .placeholderOrGenerated)
        }

        guard !CitySymbolValidator.containsOppositeSymbolMarker(combinedText, expectedType: expectedType) else {
            return CitySymbolValidationResult(isValid: false, failure: .wrongSymbolType)
        }

        guard CitySymbolValidator.matchesPlaceId(asset.placeId, combinedText: combinedText) else {
            return CitySymbolValidationResult(isValid: false, failure: .wrongPlace)
        }

        if pathExtension != "svg",
           let width = asset.pixelWidth,
           let height = asset.pixelHeight,
           min(width, height) < CitySymbolValidator.minimumDimension {
            return CitySymbolValidationResult(isValid: false, failure: .imageTooSmall)
        }

        return CitySymbolValidationResult(isValid: true, failure: nil)
    }
}

enum CitySymbolValidator {
    private static let allowedFileExtensions: Set<String> = ["svg", "png", "jpg", "jpeg", "webp"]
    fileprivate static let minimumDimension = 64
    private static var validURLCache: [String: CitySymbolValidationResult] = [:]
    private static let lock = NSLock()

    static func renderableSymbol(_ symbol: CitySymbol?, expectedType: CitySymbolType) -> CitySymbol? {
        validate(symbol, expectedType: expectedType).isValid ? symbol : nil
    }

    static func validate(_ symbol: CitySymbol?, expectedType: CitySymbolType) -> CitySymbolValidationResult {
        guard let symbol else {
            return CitySymbolValidationResult(isValid: false, failure: .missingSymbol)
        }

        guard symbol.type == expectedType else {
            return CitySymbolValidationResult(isValid: false, failure: .wrongSymbolType)
        }

        guard symbol.verified else {
            return CitySymbolValidationResult(isValid: false, failure: .unverified)
        }

        guard let rawURL = symbol.url?.trimmingCharacters(in: .whitespacesAndNewlines), !rawURL.isEmpty else {
            return CitySymbolValidationResult(isValid: false, failure: .missingURL)
        }

        let cacheKey = "\(expectedType.rawValue)|\(rawURL)|\(symbol.source ?? "")|\(symbol.updatedAt ?? "")|\(symbol.placeId ?? "")"
        lock.lock()
        if let cached = validURLCache[cacheKey] {
            lock.unlock()
            return cached
        }
        lock.unlock()

        guard let components = URLComponents(string: rawURL),
              let scheme = components.scheme?.lowercased(),
              ["https", "http"].contains(scheme),
              let host = components.host?.lowercased(),
              !host.isEmpty else {
            return CitySymbolValidationResult(isValid: false, failure: .invalidURL)
        }

        let pathExtension = (components.path as NSString).pathExtension.lowercased()
        guard allowedFileExtensions.contains(pathExtension) else {
            return CitySymbolValidationResult(isValid: false, failure: .disallowedFileType)
        }

        let sourceText = symbol.source?.lowercased() ?? ""
        guard isTrustedSource(sourceText, sourceType: symbol.sourceType, host: host) else {
            return CitySymbolValidationResult(isValid: false, failure: .untrustedSource)
        }

        let combinedText = "\(rawURL.lowercased()) \(sourceText) \(symbol.attribution?.lowercased() ?? "")"
        guard !containsPlaceholderOrGeneratedMarker(combinedText) else {
            return CitySymbolValidationResult(isValid: false, failure: .placeholderOrGenerated)
        }

        guard !containsOppositeSymbolMarker(combinedText, expectedType: expectedType) else {
            return CitySymbolValidationResult(isValid: false, failure: .wrongSymbolType)
        }

        guard matchesPlaceId(symbol.placeId, combinedText: combinedText) else {
            return CitySymbolValidationResult(isValid: false, failure: .wrongPlace)
        }

        if expectedType == .flag && containsCountryFlagMarker(combinedText) {
            return CitySymbolValidationResult(isValid: false, failure: .countryFlagUsedAsCityFlag)
        }

        if pathExtension != "svg",
           let width = symbol.pixelWidth,
           let height = symbol.pixelHeight,
           min(width, height) < minimumDimension {
            return CitySymbolValidationResult(isValid: false, failure: .imageTooSmall)
        }

        let result = CitySymbolValidationResult(isValid: true, failure: nil)
        lock.lock()
        validURLCache[cacheKey] = result
        lock.unlock()
        return result
    }

    fileprivate static func isTrustedSource(_ source: String, sourceType: PlaceMediaSourceType? = nil, host: String) -> Bool {
        if let sourceType, [.official, .wikimedia, .wikidata, .local, .otherVerified].contains(sourceType) {
            return true
        }
        if host.contains("wikimedia.org") || host.contains("wikidata.org") {
            return true
        }
        if source.contains("wikimedia commons") || source.contains("wikidata") {
            return true
        }
        if source.contains("official") || source.contains("municipality") || source.contains("gemeente") || source.contains("open data") {
            return true
        }
        return false
    }

    fileprivate static func containsPlaceholderOrGeneratedMarker(_ text: String) -> Bool {
        if text.contains("placeholder") { return true }
        if text.contains("fake") { return true }
        if text.contains("generated") { return true }
        if text.contains("ai-generated") { return true }
        if text.contains("sample") { return true }
        if text.contains("dummy") { return true }
        if text.contains("generic") { return true }
        if text.contains("approximation") { return true }
        if text.contains("inspired") { return true }
        if text.contains("template") { return true }
        if text.contains("blank") { return true }
        return false
    }

    fileprivate static func containsOppositeSymbolMarker(_ text: String, expectedType: CitySymbolType) -> Bool {
        switch expectedType {
        case .flag:
            return text.contains("coat_of_arms") ||
            text.contains("coat-of-arms") ||
            text.contains("coat of arms") ||
            text.contains("wapen") ||
            text.contains("shield")
        case .coatOfArms:
            return text.contains("flag_of") ||
            text.contains("flag-of") ||
            text.contains("_flag") ||
            text.contains(" flag ")
        case .heroImage:
            return false
        }
    }

    fileprivate static func matchesPlaceId(_ placeId: String?, combinedText: String) -> Bool {
        guard let placeId, !placeId.isEmpty else { return true }

        let tokens = placeId
            .replacingOccurrences(of: "nl-city-", with: "")
            .replacingOccurrences(of: "nl-province-", with: "")
            .split(separator: "-")
            .flatMap { $0.split(separator: "_") }
            .map(String.init)
            .filter { $0.count > 2 }

        guard let placeNameToken = tokens.last else { return true }
        return combinedText.contains(placeNameToken)
    }

    private static func containsCountryFlagMarker(_ text: String) -> Bool {
        text.contains("flag_of_the_netherlands") ||
        text.contains("flag-of-the-netherlands") ||
        text.contains("netherlands_flag") ||
        text.contains("dutch_country_flag") ||
        text.contains("country flag") ||
        text.contains("province flag") ||
        text.contains("provincial flag")
    }
}

struct LocalizedCityText: Hashable {
    let english: String
    let dutch: String
    let russian: String

    init(english: String, dutch: String, russian: String? = nil) {
        self.english = english
        self.dutch = dutch
        self.russian = russian ?? english
    }

    func value(for lang: AppLanguage) -> String {
        switch lang {
        case .dutch:    return dutch
        case .russian:  return russian
        case .english:  return english
        }
    }
}

struct CityLocalHighlight: Identifiable {
    let id: String
    let icon: String
    let title: LocalizedCityText
    let description: LocalizedCityText

    func localizedTitle(_ lang: AppLanguage) -> String {
        title.value(for: lang)
    }

    func localizedDescription(_ lang: AppLanguage) -> String {
        description.value(for: lang)
    }
}

struct CityQuickFact: Identifiable {
    let id: String
    let icon: String
    let title: LocalizedCityText
    let value: LocalizedCityText

    func localizedTitle(_ lang: AppLanguage) -> String {
        title.value(for: lang)
    }

    func localizedValue(_ lang: AppLanguage) -> String {
        value.value(for: lang)
    }
}

struct CityScorecardItem: Identifiable {
    let id: String
    let icon: String
    let title: LocalizedCityText
    let value: LocalizedCityText
    let tint: Color

    func localizedTitle(_ lang: AppLanguage) -> String { title.value(for: lang) }
    func localizedValue(_ lang: AppLanguage) -> String { value.value(for: lang) }
}

struct CityCostItem: Identifiable {
    let id: String
    let icon: String
    let title: LocalizedCityText
    let level: CityCostLevel
}

enum CityCostLevel {
    case low
    case medium
    case high

    func localized(_ lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.low, .russian): return "Низкий"
        case (.low, .dutch): return "Laag"
        case (.low, .english): return "Low"
        case (.medium, .russian): return "Средний"
        case (.medium, .dutch): return "Gemiddeld"
        case (.medium, .english): return "Medium"
        case (.high, .russian): return "Высокий"
        case (.high, .dutch): return "Hoog"
        case (.high, .english): return "High"
        }
    }

    var color: Color {
        switch self {
        case .low: return AppColors.success
        case .medium: return AppColors.warning
        case .high: return AppColors.dutchOrange
        }
    }
}

struct CityTimelineEvent: Identifiable {
    let id: String
    let period: LocalizedCityText
    let title: LocalizedCityText
    let detail: LocalizedCityText

    func localizedPeriod(_ lang: AppLanguage) -> String { period.value(for: lang) }
    func localizedTitle(_ lang: AppLanguage) -> String { title.value(for: lang) }
    func localizedDetail(_ lang: AppLanguage) -> String { detail.value(for: lang) }
}

struct CityNewcomerGuideItem: Identifiable {
    let id: String
    let icon: String
    let title: LocalizedCityText
    let detail: LocalizedCityText
    let urlString: String?

    func localizedTitle(_ lang: AppLanguage) -> String { title.value(for: lang) }
    func localizedDetail(_ lang: AppLanguage) -> String { detail.value(for: lang) }
}

struct CityLocalHighlightFact: Identifiable {
    let id: String
    let title: LocalizedCityText
    let value: LocalizedCityText
    let icon: String

    func localizedTitle(_ lang: AppLanguage) -> String { title.value(for: lang) }
    func localizedValue(_ lang: AppLanguage) -> String { value.value(for: lang) }
}

struct CitySourceLink: Identifiable {
    let id: String
    let title: LocalizedCityText
    let urlString: String
    let icon: String

    func localizedTitle(_ lang: AppLanguage) -> String {
        title.value(for: lang)
    }
}

extension CityItem {
    func localizedName(_ lang: AppLanguage) -> String {
        ProvinceCatalog.localizedCityName(name, lang)
    }

    func localizedShortDescription(_ lang: AppLanguage) -> String {
        shortDescription.value(for: lang)
    }

    func localizedShortHistory(_ lang: AppLanguage) -> String {
        shortHistory.value(for: lang)
    }

    func localizedHistoryDetail(_ lang: AppLanguage) -> String? {
        switch lang {
        case .english: return historyEN
        case .dutch: return historyNL ?? historyEN
        case .russian: return historyRU ?? historyEN
        }
    }

    func localizedHistoryTimeline(_ lang: AppLanguage) -> [String] {
        historyTimeline.map { $0.value(for: lang) }
    }

    func localizedSupportTags(_ lang: AppLanguage) -> [String] {
        supportTags.map { $0.value(for: lang) }
    }

    func cityIdentityLine(_ lang: AppLanguage) -> String {
        cityIdentityText(name: name).value(for: lang)
    }

    func localizedImageCredit(_ lang: AppLanguage) -> String {
        imageCredit.value(for: lang)
    }

    private func cityIdentityText(name: String) -> LocalizedCityText {
        switch name {
        case "Leiden":
            return LocalizedCityText(english: "Historic university city of discoveries", dutch: "Historische universiteitsstad van ontdekkingen", russian: "Исторический университетский город")
        case "Amsterdam":
            return LocalizedCityText(english: "Capital city of canals and neighbourhoods", dutch: "Hoofdstad van grachten en buurten", russian: "Столица каналов и районов")
        case "Rotterdam":
            return LocalizedCityText(english: "Port city with modern energy", dutch: "Havenstad met moderne energie", russian: "Портовый город с современной энергией")
        case "Den Haag":
            return LocalizedCityText(english: "Government city by the coast", dutch: "Bestuursstad aan de kust", russian: "Правительственный город у побережья")
        case "Utrecht":
            return LocalizedCityText(english: "Central hub with historic canals", dutch: "Centraal knooppunt met historische grachten", russian: "Центральный узел с историческими каналами")
        case "Eindhoven":
            return LocalizedCityText(english: "Technology and design city", dutch: "Technologie- en designstad", russian: "Город технологий и дизайна")
        case "Groningen":
            return LocalizedCityText(english: "Northern student and cycling city", dutch: "Noordelijke studenten- en fietsstad", russian: "Северный студенческий и велосипедный город")
        case "Maastricht":
            return LocalizedCityText(english: "Historic Maas city with border links", dutch: "Historische Maasstad met grensverbindingen", russian: "Исторический город на Маасе с приграничными связями")
        default:
            return shortDescription
        }
    }
}

struct Coordinate: Hashable {
    let latitude: Double
    let longitude: Double
}

struct CitySpotlightData: Identifiable {
    let city: CityItem
    let province: ProvinceItem

    var id: String { city.id }
}

enum ProvinceCatalog {
    private static let baseItems: [ProvinceItem] = {
        let items = makeItems()
        #if DEBUG
        validateCatalog(items)
        #endif
        return items
    }()

    static var items: [ProvinceItem] { baseItems }
    static var all: [ProvinceItem] { baseItems }
    static let priorityCityNames: Set<String> = ["Amsterdam", "Leiden", "Rotterdam", "Den Haag", "Utrecht", "Eindhoven", "Groningen", "Maastricht"]
    static let priorityCities: [CityItem] = {
        baseItems.flatMap(\.cities).filter { priorityCityNames.contains($0.name) }
    }()
    static let mapCities: [CityItem] = {
        baseItems.flatMap(\.cities)
    }()
    static let citySpotlights: [CitySpotlightData] = {
        baseItems.flatMap { province in
            province.cities.map { city in
                CitySpotlightData(city: city, province: province)
            }
        }
    }()
    private static let citySpotlightById: [String: CitySpotlightData] = {
        Dictionary(
            citySpotlights.map { ($0.city.id, $0) },
            uniquingKeysWith: { first, _ in first }
        )
    }()
    private static let citySpotlightByName: [String: CitySpotlightData] = {
        Dictionary(
            citySpotlights.map { ($0.city.name, $0) },
            uniquingKeysWith: { first, _ in first }
        )
    }()

    private static let provinceByID: [String: ProvinceItem] = {
        Dictionary(
            baseItems.map { ($0.id, $0) },
            uniquingKeysWith: { first, _ in first }
        )
    }()
    private static let provinceByNormalizedID: [String: ProvinceItem] = {
        Dictionary(
            baseItems.map { (normalizedLookupKey($0.id), $0) },
            uniquingKeysWith: { first, _ in first }
        )
    }()
    private static let cityByProvinceAndName: [String: CityItem] = {
        Dictionary(
            baseItems.flatMap { province in
                province.cities.map { city in ("\(province.id)|\(city.name)", city) }
            },
            uniquingKeysWith: { first, _ in first }
        )
    }()
    private static let cityByNormalizedProvinceAndName: [String: CityItem] = {
        Dictionary(
            baseItems.flatMap { province in
                province.cities.map { city in
                    ("\(normalizedLookupKey(province.id))|\(normalizedLookupKey(city.name))", city)
                }
            },
            uniquingKeysWith: { first, _ in first }
        )
    }()

    private static func makeItems() -> [ProvinceItem] {
        let items: [ProvinceItem] = [
        ProvinceItem(
            id: "Noord-Holland",
            nameByLanguage: [.russian: "Северная Голландия", .english: "North Holland", .dutch: "Noord-Holland"],
            capital: "Haarlem",
            population: "2.9M",
            areaKm2: "4 092 km²",
            municipalityCount: 44,
            officialWebsite: "noord-holland.nl",
            mapOverlayAssetName: "map_noord_holland",
            mapHighlightColor: AppColors.dutchOrange,
            cities: [
                city("Amsterdam", "872 000", "Amsterdam", "Noord-Holland", "amsterdam.nl", 52.3676, 4.9041, area: "218,3 km²", code: "A", transport: "GVB", tourist: "iamsterdam.com"),
                city("Haarlem", "162 000", "Haarlem", "Noord-Holland", "haarlem.nl", 52.3874, 4.6462, area: "124,6 km²", code: "HL"),
                city("Alkmaar", "111 000", "Alkmaar", "Noord-Holland", "alkmaar.nl", 52.6324, 4.7534, area: "133,9 km²", code: "AK"),
                city("Hoorn", "74 000", "Hoorn", "Noord-Holland", "hoorn.nl", 52.6424, 5.0597, area: "60,2 km²", code: "HN"),
                city("Zaanstad", "157 000", "Zaanstad", "Noord-Holland", "zaanstad.nl", 52.4579, 4.7510, area: "161,8 km²", code: "ZN"),
                city("Amstelveen", "95 000", "Amstelveen", "Noord-Holland", "amstelveen.nl", 52.3021, 4.8617, area: "54,4 km²", code: "AV"),
                city("Purmerend", "88 000", "Purmerend", "Noord-Holland", "purmerend.nl", 52.5030, 4.9596, area: "22,2 km²", code: "PD"),
                city("Heerhugowaard", "57 000", "Dijk en Waard", "Noord-Holland", nil, 52.6500, 4.8345, area: "43,3 km²", code: "HW")
            ]
        ),
        ProvinceItem(id: "Zuid-Holland", nameByLanguage: [.russian: "Южная Голландия", .english: "South Holland", .dutch: "Zuid-Holland"], capital: "Den Haag", population: "3.8M", areaKm2: "3 308 km²", municipalityCount: 50, officialWebsite: "zuid-holland.nl", mapOverlayAssetName: "map_zuid_holland", mapHighlightColor: AppColors.warning, cities: [
            city("Rotterdam", "664 000", "Rotterdam", "Zuid-Holland", "rotterdam.nl", 51.9244, 4.4777, area: "324,1 km²", code: "R", transport: "RET", tourist: "rotterdam.info"),
            city("Den Haag", "563 000", "Den Haag", "Zuid-Holland", "denhaag.nl", 52.0705, 4.3007, area: "98,1 km²", code: "HG", transport: "HTM"),
            city("Leiden", "127 000", "Leiden", "Zuid-Holland", "leiden.nl", 52.1601, 4.4970, area: "58,0 km²", code: "LI"),
            city("Delft", "104 000", "Delft", "Zuid-Holland", "delft.nl", 52.0116, 4.3571, area: "24,0 km²", code: "DF")
        ]),
        ProvinceItem(id: "Utrecht", nameByLanguage: [.russian: "Утрехт", .english: "Utrecht", .dutch: "Utrecht"], capital: "Utrecht", population: "1.4M", areaKm2: "1 560 km²", municipalityCount: 26, officialWebsite: "provincie-utrecht.nl", mapOverlayAssetName: "map_utrecht", mapHighlightColor: AppColors.violet, cities: [
            city("Utrecht", "367 000", "Utrecht", "Utrecht", "utrecht.nl", 52.0907, 5.1214, area: "99,2 km²", code: "U", transport: "U-OV", tourist: "visit-utrecht.com"),
            city("Amersfoort", "160 000", "Amersfoort", "Utrecht", "amersfoort.nl", 52.1561, 5.3878, area: "149,2 km²", code: "AF")
        ]),
        ProvinceItem(id: "Gelderland", nameByLanguage: [.russian: "Гелдерланд", .english: "Gelderland", .dutch: "Gelderland"], capital: "Arnhem", population: "2.1M", areaKm2: "5 136 km²", municipalityCount: 51, officialWebsite: "gelderland.nl", mapOverlayAssetName: "map_gelderland", mapHighlightColor: AppColors.routeLine, cities: [
            city("Arnhem", "166 000", "Arnhem", "Gelderland", "arnhem.nl", 51.9851, 5.8987, area: "100,5 km²", code: "AH"),
            city("Nijmegen", "182 000", "Nijmegen", "Gelderland", "nijmegen.nl", 51.8126, 5.8372, area: "57,6 km²", code: "NM")
        ]),
        ProvinceItem(id: "Noord-Brabant", nameByLanguage: [.russian: "Северный Брабант", .english: "North Brabant", .dutch: "Noord-Brabant"], capital: "'s-Hertogenbosch", population: "2.6M", areaKm2: "5 082 km²", municipalityCount: 56, officialWebsite: "brabant.nl", mapOverlayAssetName: "map_noord_brabant", mapHighlightColor: AppColors.dutchOrange, cities: [
            city("Eindhoven", "246 000", "Eindhoven", "Noord-Brabant", "eindhoven.nl", 51.4416, 5.4697, area: "88,9 km²", code: "E"),
            city("Tilburg", "229 000", "Tilburg", "Noord-Brabant", "tilburg.nl", 51.5555, 5.0913, area: "118,0 km²", code: "TB"),
            city("Breda", "186 000", "Breda", "Noord-Brabant", "breda.nl", 51.5719, 4.7683, area: "128,3 km²", code: "BD"),
            city("'s-Hertogenbosch", "158 000", "'s-Hertogenbosch", "Noord-Brabant", "s-hertogenbosch.nl", 51.6978, 5.3037, area: "93,2 km²", code: "HT")
        ]),
        ProvinceItem(id: "Limburg", nameByLanguage: [.russian: "Лимбург", .english: "Limburg", .dutch: "Limburg"], capital: "Maastricht", population: "1.1M", areaKm2: "2 210 km²", municipalityCount: 31, officialWebsite: "limburg.nl", mapOverlayAssetName: "map_limburg", mapHighlightColor: AppColors.textTertiary, cities: [
            city("Maastricht", "122 000", "Maastricht", "Limburg", "maastricht.nl", 50.8514, 5.6910, area: "60,0 km²", code: "MS", tourist: "visitmaastricht.nl"),
            city("Venlo", "100 000", "Venlo", "Limburg", "venlo.nl", 51.3703, 6.1724, area: "127,1 km²", code: "VL")
        ]),
        ProvinceItem(id: "Overijssel", nameByLanguage: [.russian: "Оверэйссел", .english: "Overijssel", .dutch: "Overijssel"], capital: "Zwolle", population: "1.2M", areaKm2: "3 421 km²", municipalityCount: 25, officialWebsite: "overijssel.nl", mapOverlayAssetName: "map_overijssel", mapHighlightColor: AppColors.warning, cities: [
            city("Zwolle", "132 000", "Zwolle", "Overijssel", "zwolle.nl", 52.5168, 6.0830)
        ]),
        ProvinceItem(id: "Flevoland", nameByLanguage: [.russian: "Флеволанд", .english: "Flevoland", .dutch: "Flevoland"], capital: "Lelystad", population: "0.4M", areaKm2: "2 412 km²", municipalityCount: 6, officialWebsite: "flevoland.nl", mapOverlayAssetName: "map_flevoland", mapHighlightColor: AppColors.softBlue, cities: [
            city("Almere", "226 000", "Almere", "Flevoland", "almere.nl", 52.3508, 5.2647),
            city("Lelystad", "83 000", "Lelystad", "Flevoland", "lelystad.nl", 52.5185, 5.4714)
        ]),
        ProvinceItem(id: "Groningen", nameByLanguage: [.russian: "Гронинген", .english: "Groningen", .dutch: "Groningen"], capital: "Groningen", population: "0.6M", areaKm2: "2 960 km²", municipalityCount: 10, officialWebsite: "provinciegroningen.nl", mapOverlayAssetName: "map_groningen", mapHighlightColor: AppColors.success, cities: [
            city("Groningen", "244 000", "Groningen", "Groningen", "gemeente.groningen.nl", 53.2194, 6.5665, area: "197,8 km²", code: "GN", transport: "Qbuzz")
        ]),
        ProvinceItem(id: "Friesland", nameByLanguage: [.russian: "Фрисландия", .english: "Friesland", .dutch: "Fryslan"], capital: "Leeuwarden", population: "0.7M", areaKm2: "5 749 km²", municipalityCount: 18, officialWebsite: "fryslan.frl", mapOverlayAssetName: "map_friesland", mapHighlightColor: AppColors.accent, cities: [
            city("Leeuwarden", "127 000", "Leeuwarden", "Friesland", "leeuwarden.nl", 53.2012, 5.7999, area: "301,3 km²", code: "LW")
        ]),
        ProvinceItem(id: "Drenthe", nameByLanguage: [.russian: "Дренте", .english: "Drenthe", .dutch: "Drenthe"], capital: "Assen", population: "0.5M", areaKm2: "2 680 km²", municipalityCount: 12, officialWebsite: "drenthe.nl", mapOverlayAssetName: "map_drenthe", mapHighlightColor: AppColors.error, cities: [
            city("Assen", "69 000", "Assen", "Drenthe", "assen.nl", 52.9928, 6.5642)
        ]),
        ProvinceItem(id: "Zeeland", nameByLanguage: [.russian: "Зеландия", .english: "Zeeland", .dutch: "Zeeland"], capital: "Middelburg", population: "0.4M", areaKm2: "2 934 km²", municipalityCount: 13, officialWebsite: "zeeland.nl", mapOverlayAssetName: "map_zeeland", mapHighlightColor: AppColors.softBlue, cities: [
            city("Middelburg", "49 000", "Middelburg", "Zeeland", "middelburg.nl", 51.4988, 3.6100)
        ])
        ]
        return items
    }

    static func provinceIfFound(id: String) -> ProvinceItem? {
        provinceByID[id] ?? provinceByNormalizedID[normalizedLookupKey(id)]
    }

    static func provinceIfFound(matching identifier: String) -> ProvinceItem? {
        let normalized = normalizedLookupKey(identifier)
        if let province = provinceIfFound(id: identifier) {
            return province
        }
        return baseItems.first { province in
            normalizedLookupKey(province.localizedName(.english)) == normalized
                || normalizedLookupKey(province.localizedName(.dutch)) == normalized
                || normalizedLookupKey(province.localizedName(.russian)) == normalized
        }
    }

    static func item(id: String) -> ProvinceItem {
        if let province = provinceIfFound(id: id) {
            return province
        }
        #if DEBUG
        assertionFailure("[CITY DATA ASSERT] Unknown province id '\(id)'. Falling back to first province only to avoid crash.")
        #endif
        return all[0]
    }

    static func cityIfFound(named name: String, provinceID: String) -> CityItem? {
        cityByProvinceAndName["\(provinceID)|\(name)"]
            ?? cityByNormalizedProvinceAndName["\(normalizedLookupKey(provinceID))|\(normalizedLookupKey(name))"]
    }

    static func city(named name: String, provinceID: String) -> CityItem {
        if let city = cityIfFound(named: name, provinceID: provinceID) {
            return city
        }
        #if DEBUG
        assertionFailure("[CITY DATA ASSERT] Unknown city/province route city='\(name)' province='\(provinceID)'. Falling back only to avoid crash.")
        #endif
        return item(id: provinceID).cities[0]
    }

    static func provinceID(containingCity name: String) -> String? {
        citySpotlight(matching: name)?.province.id
    }

    static func citySpotlight(named name: String) -> CitySpotlightData? {
        citySpotlightByName[name]
    }

    static func citySpotlight(id: String) -> CitySpotlightData? {
        citySpotlightById[id]
    }

    static func citySpotlight(matching identifier: String) -> CitySpotlightData? {
        let trimmed = identifier.trimmingCharacters(in: .whitespacesAndNewlines)
        if let exact = citySpotlightById[trimmed] ?? citySpotlightByName[trimmed] {
            return exact
        }

        let normalized = normalizedLookupKey(trimmed)
        return citySpotlights.first { spotlight in
            spotlight.city.id.caseInsensitiveCompare(trimmed) == .orderedSame
                || spotlight.city.name.caseInsensitiveCompare(trimmed) == .orderedSame
                || normalizedLookupKey(spotlight.city.id) == normalized
                || normalizedLookupKey(spotlight.city.name) == normalized
        }
    }

    private static func normalizedLookupKey(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: "_")
    }

    #if DEBUG
    private static func validateCatalog(_ items: [ProvinceItem]) {
        let provinceIDs = items.map(\.id)
        assert(!provinceIDs.contains(where: { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }), "ProvinceCatalog contains an empty province id")
        assert(Set(provinceIDs).count == provinceIDs.count, "ProvinceCatalog contains duplicate province ids: \(provinceIDs)")

        let cities = items.flatMap(\.cities)
        let cityIDs = cities.map(\.id)
        assert(!cityIDs.contains(where: { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }), "ProvinceCatalog contains an empty city id")
        assert(Set(cityIDs).count == cityIDs.count, "ProvinceCatalog contains duplicate city ids: \(cityIDs)")
        assert(!cities.contains(where: { $0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }), "ProvinceCatalog contains an empty city name")
        assert(!cities.contains(where: { $0.province.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }), "ProvinceCatalog contains a city without a province id")

        let cityNames = cities.map(\.name)
        let duplicateNames = Dictionary(grouping: cityNames, by: { $0 }).filter { $0.value.count > 1 }.keys
        assert(duplicateNames.isEmpty, "ProvinceCatalog contains duplicate display city names: \(Array(duplicateNames))")
    }
    #endif

    static func localizedCityName(_ name: String, _ lang: AppLanguage) -> String {
        switch (name, lang) {
        case ("Amsterdam", .russian): return L10n.t("onboarding.city.amsterdam", lang)
        case ("Rotterdam", .russian): return L10n.t("onboarding.city.rotterdam", lang)
        case ("Den Haag", .english): return "The Hague"
        case ("Den Haag", .russian): return L10n.t("onboarding.city.den_haag", lang)
        case ("Utrecht", .russian): return L10n.t("onboarding.city.utrecht", lang)
        case ("Leiden", .russian): return L10n.t("onboarding.city.leiden", lang)
        case ("Eindhoven", .russian): return L10n.t("onboarding.city.eindhoven", lang)
        case ("Groningen", .russian): return L10n.t("onboarding.city.groningen", lang)
        case ("Maastricht", .russian): return "Маастрихт"
        default: return name
        }
    }

    private static func city(
        _ name: String,
        _ population: String,
        _ municipality: String,
        _ provinceID: String,
        _ website: String?,
        _ latitude: Double,
        _ longitude: Double,
        area: String? = nil,
        code: String? = nil,
        transport: String? = nil,
        tourist: String? = nil
    ) -> CityItem {
        let placeId = CuratedPlaceHeroMediaRegistry.cityPlaceId(cityName: name, provinceName: provinceID)
        let heroAssetName = CuratedPlaceHeroMediaRegistry.media(for: placeId)?.assetName ?? CuratedPlaceHeroMediaRegistry.cityPlaceholderAssetName
        let description = cityShortDescription(name: name, provinceID: provinceID)
        let history = cityShortHistory(name: name, provinceID: provinceID)
        let historyDetail = cityHistory(name: name)
        let timeline = cityTimeline(name: name, provinceID: provinceID)
        let highlights = cityHighlights(name: name, provinceID: provinceID, municipality: municipality, transport: transport, tourist: tourist)
        let facts = cityQuickFacts(name: name, population: population, area: area, municipality: municipality, provinceID: provinceID, transport: transport)
        let tags = citySupportTags(name: name, transport: transport, tourist: tourist)
        let sourceLinks = citySourceLinks(name: name, website: website, tourist: tourist)
        let officialWebsiteURL = website.map { webURLString(for: $0) }
        let newcomerPlaces = CityNewcomerPlacesData.places(for: name, municipalityURL: officialWebsiteURL)

        return CityItem(
            id: "\(provinceID)-\(name)",
            name: name,
            province: provinceID,
            municipalityName: municipality,
            populationText: population,
            areaText: area ?? "—",
            officialWebsiteTitle: website,
            officialWebsiteURL: officialWebsiteURL,
            latitude: latitude,
            longitude: longitude,
            media: VerifiedPlaceMediaRegistry.media(for: .city, name: name, provinceId: provinceID),
            heroImageAssetName: heroAssetName,
            shortDescription: description,
            shortHistory: history,
            historyEN: historyDetail?.english,
            historyNL: historyDetail?.dutch,
            historyRU: historyDetail?.russian,
            historySourceURL: cityHistorySourceURL(name: name),
            historyTimeline: timeline,
            localHighlights: highlights,
            quickFacts: facts,
            supportTags: tags,
            scorecard: cityScorecard(name: name, population: population, area: area, provinceID: provinceID, transport: transport),
            moveReasons: cityMoveReasons(name: name, provinceID: provinceID),
            costOfLiving: cityCostItems(name: name),
            timelineEvents: cityTimelineEvents(name: name, provinceID: provinceID),
            newcomerGuide: cityNewcomerGuide(name: name, website: website, transport: transport),
            firstWeekSteps: CityNewcomerPlacesData.firstWeekSteps(for: name, municipalityURL: officialWebsiteURL),
            newcomerPlaces: newcomerPlaces,
            officialServices: newcomerPlaces.filter { [.municipality, .bsnRegistration].contains($0.category) },
            languageAndIntegration: newcomerPlaces.filter { [.languageLearning, .library, .community].contains($0.category) },
            healthcareAccess: newcomerPlaces.filter { [.healthcare, .hospital].contains($0.category) },
            legalAndRightsHelp: newcomerPlaces.filter { [.legalHelp, .housing, .taxes].contains($0.category) },
            transportHubs: newcomerPlaces.filter { $0.category == .transport },
            communityAndLibraries: newcomerPlaces.filter { [.community, .library].contains($0.category) },
            emergencyAndSafety: newcomerPlaces.filter { [.emergency, .police].contains($0.category) },
            familyAndChildren: newcomerPlaces.filter { $0.category == .family },
            lgbtqSupport: newcomerPlaces.filter { $0.category == .lgbtq },
            documentAndAdminHelp: newcomerPlaces.filter { $0.category == .documents },
            housingSupport: newcomerPlaces.filter { $0.category == .housing },
            workAndUWVInfo: newcomerPlaces.filter { [.work, .uwv].contains($0.category) },
            personalityTags: cityPersonalityTags(name: name),
            localHighlightFacts: cityLocalHighlightFacts(name: name, transport: transport),
            nearbyCities: nearbyCities(name: name, provinceID: provinceID),
            officialSourceLinks: sourceLinks,
            imageCredit: VerifiedPlaceMediaRegistry.credit(for: .city, name: name, provinceId: provinceID),
            searchKeywords: citySearchKeywords(name: name, provinceID: provinceID, municipality: municipality),
            population: population,
            municipality: municipality,
            provinceId: provinceID,
            officialWebsite: website,
            coordinate: Coordinate(latitude: latitude, longitude: longitude),
            areaKm2: area,
            dutchCode: code,
            transportOperator: transport,
            touristInfoURL: tourist
        )
    }

    private static func cityAssetBaseName(_ name: String) -> String {
        let normalized = name
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .lowercased()
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: " ", with: "_")
        return "city_\(normalized)"
    }

    // swiftlint:disable:next function_body_length
    private static func cityHistory(name: String) -> LocalizedCityText? {
        switch name {
        case "Amsterdam":
            return LocalizedCityText(
                english: "Amsterdam began as a settlement around a dam in the Amstel and grew into a powerful trading city. In the seventeenth century it became a major centre of the Dutch Golden Age, with canals, merchant houses, printing, finance, and global maritime links shaping the city. Today Amsterdam is the constitutional capital and an international centre for culture, education, transport, business, and public services.",
                dutch: "Amsterdam ontstond rond een dam in de Amstel en groeide uit tot een machtige handelsstad. In de zeventiende eeuw werd het een belangrijk centrum van de Nederlandse Gouden Eeuw, met grachten, koopmanshuizen, drukwerk, financiën en wereldwijde maritieme verbindingen. Vandaag is Amsterdam de constitutionele hoofdstad en een internationaal centrum voor cultuur, onderwijs, vervoer, bedrijven en publieke diensten.",
                russian: "Amsterdam возник как поселение у дамбы на реке Amstel и вырос в влиятельный торговый город. В XVII веке он стал одним из центров нидерландского Золотого века: каналы, купеческие дома, печать, финансы и морские связи сформировали его облик. Сегодня Amsterdam — конституционная столица и международный центр культуры, образования, транспорта, бизнеса и городских услуг."
            )
        case "Haarlem":
            return LocalizedCityText(
                english: "Haarlem developed in the Middle Ages near the river Spaarne and became an important town in the County of Holland. It was known for textiles, brewing, printing, painting, and later for its role as the capital of North Holland. The historic centre, Grote Markt, churches, museums, and railway links still reflect Haarlem's position as a cultural and administrative city close to Amsterdam.",
                dutch: "Haarlem ontwikkelde zich in de middeleeuwen aan het Spaarne en werd een belangrijke stad in het graafschap Holland. De stad stond bekend om textiel, bier, drukwerk, schilderkunst en later als hoofdstad van Noord-Holland. De historische binnenstad, Grote Markt, kerken, musea en spoorverbindingen tonen nog steeds Haarlem's rol als culturele en bestuurlijke stad bij Amsterdam.",
                russian: "Haarlem развился в Средние века у реки Spaarne и стал важным городом графства Holland. Он был известен текстилем, пивоварением, печатью, живописью, а позднее стал столицей провинции Noord-Holland. Исторический центр, Grote Markt, церкви, музеи и железнодорожные связи до сих пор показывают роль Haarlem как культурного и административного города рядом с Amsterdam."
            )
        case "Alkmaar":
            return LocalizedCityText(
                english: "Alkmaar received city rights in the Middle Ages and became a market town for the surrounding North Holland countryside. It is famous for the 1573 siege during the Dutch Revolt, remembered in the phrase that victory began at Alkmaar, and for its historic cheese market. Today the old centre, canals, regional services, and rail links make Alkmaar a key city in northern North Holland.",
                dutch: "Alkmaar kreeg in de middeleeuwen stadsrechten en werd een marktstad voor het omliggende Noord-Hollandse gebied. De stad is bekend door het beleg van 1573 tijdens de Nederlandse Opstand, herdacht met de uitspraak dat de victorie bij Alkmaar begon, en door de historische kaasmarkt. Vandaag maken de binnenstad, grachten, regionale voorzieningen en spoorverbindingen Alkmaar belangrijk in noordelijk Noord-Holland.",
                russian: "Alkmaar получил городские права в Средние века и стал рыночным городом для северной части Noord-Holland. Город известен осадой 1573 года во время Dutch Revolt, с которой связывают выражение о начале победы у Alkmaar, а также историческим сырным рынком. Сегодня старый центр, каналы, региональные службы и железная дорога делают Alkmaar важным городом северной части провинции."
            )
        case "Hoorn":
            return LocalizedCityText(
                english: "Hoorn grew on the IJsselmeer coast as a harbour and trading town and became one of the important cities of the Dutch East India Company era. In the seventeenth century its ships, merchants, warehouses, and city gates connected West Friesland with overseas trade. Today Hoorn keeps a strong historic harbour identity while serving as a regional centre for housing, culture, tourism, and daily services.",
                dutch: "Hoorn groeide aan de IJsselmeerkust uit tot haven- en handelsstad en werd een van de belangrijke steden uit de tijd van de VOC. In de zeventiende eeuw verbonden schepen, kooplieden, pakhuizen en stadspoorten West-Friesland met overzeese handel. Vandaag bewaart Hoorn een sterke historische havenidentiteit en is het een regionaal centrum voor wonen, cultuur, toerisme en dagelijkse voorzieningen.",
                russian: "Hoorn вырос на побережье IJsselmeer как портовый и торговый город и стал одним из важных городов эпохи VOC. В XVII веке его суда, купцы, склады и городские ворота связывали West Friesland с заморской торговлей. Сегодня Hoorn сохраняет историческую портовую идентичность и служит региональным центром жилья, культуры, туризма и повседневных услуг."
            )
        case "Zaanstad":
            return LocalizedCityText(
                english: "Zaanstad is a modern municipality formed from several Zaan villages and towns, including Zaandam, with a history shaped by water, windmills, shipbuilding, food production, and early industry. The Zaan region became famous for sawmills, oil mills, paper mills, and later factories. Today Zaanstad combines industrial heritage, the Zaanse Schans image, commuter links to Amsterdam, and local municipal services.",
                dutch: "Zaanstad is een moderne gemeente gevormd uit meerdere Zaanse dorpen en steden, waaronder Zaandam, met een geschiedenis van water, molens, scheepsbouw, voedselproductie en vroege industrie. De Zaanstreek werd bekend om houtzaagmolens, oliemolens, papiermolens en later fabrieken. Vandaag combineert Zaanstad industrieel erfgoed, het beeld van de Zaanse Schans, verbindingen met Amsterdam en lokale gemeentelijke diensten.",
                russian: "Zaanstad — современный муниципалитет, созданный из нескольких заанских поселений, включая Zaandam; его история связана с водой, мельницами, судостроением, пищевым производством и ранней промышленностью. Регион Zaan прославился лесопильными, масляными и бумажными мельницами, а позднее фабриками. Сегодня Zaanstad сочетает индустриальное наследие, образ Zaanse Schans, связь с Amsterdam и муниципальные услуги."
            )
        case "Amstelveen":
            return LocalizedCityText(
                english: "Amstelveen developed from the rural municipality of Nieuwer-Amstel south of Amsterdam. Its landscape was shaped by peat, polders, roads, and later suburban growth as Amsterdam expanded. In the twentieth century Amstelveen became a residential and business municipality with international communities, the Amsterdamse Bos nearby, and strong transport links to Amsterdam, Schiphol, education, and regional employment.",
                dutch: "Amstelveen ontwikkelde zich uit de landelijke gemeente Nieuwer-Amstel ten zuiden van Amsterdam. Het landschap werd gevormd door veen, polders, wegen en later suburbanisatie door de groei van Amsterdam. In de twintigste eeuw werd Amstelveen een woon- en werkgemeente met internationale gemeenschappen, het Amsterdamse Bos dichtbij en sterke verbindingen met Amsterdam, Schiphol, onderwijs en regionale banen.",
                russian: "Amstelveen вырос из сельского муниципалитета Nieuwer-Amstel к югу от Amsterdam. Его ландшафт сформировали торфяники, польдеры, дороги и позднее пригородный рост вокруг Amsterdam. В XX веке Amstelveen стал жилым и деловым муниципалитетом с международными сообществами, Amsterdamse Bos рядом и сильными связями с Amsterdam, Schiphol, образованием и работой."
            )
        case "Purmerend":
            return LocalizedCityText(
                english: "Purmerend began as a settlement between waterways and grew into a market town serving Waterland and reclaimed polders such as the Beemster and Purmer. Its cattle and produce markets shaped the town's regional role for centuries. Modern Purmerend expanded as a residential city north of Amsterdam while keeping links to its market history, old centre, transport routes, and surrounding polder landscape.",
                dutch: "Purmerend ontstond tussen waterwegen en groeide uit tot marktstad voor Waterland en droogmakerijen zoals de Beemster en Purmer. Veemarkten en warenmarkten bepaalden eeuwenlang de regionale rol. Het moderne Purmerend breidde uit als woonstad ten noorden van Amsterdam en houdt tegelijk verbinding met de marktgeschiedenis, oude binnenstad, vervoersroutes en het omliggende polderlandschap.",
                russian: "Purmerend возник между водными путями и вырос в рыночный город для Waterland и осушенных польдеров, таких как Beemster и Purmer. Скотные и продуктовые рынки веками определяли его региональную роль. Современный Purmerend расширился как жилой город к северу от Amsterdam, сохранив связь с рыночной историей, старым центром, транспортом и окружающими польдерами."
            )
        case "Heerhugowaard":
            return LocalizedCityText(
                english: "Heerhugowaard grew on reclaimed land in North Holland after a lake was drained in the seventeenth century. Its straight roads, polder layout, farms, and later housing districts reflect the Dutch history of water management and planned settlement. Since 2022 it has been part of the municipality Dijk en Waard, while the name Heerhugowaard remains important for local identity, services, and neighbourhoods.",
                dutch: "Heerhugowaard groeide op drooggelegd land in Noord-Holland nadat een meer in de zeventiende eeuw werd ingepolderd. Rechte wegen, polderstructuur, boerderijen en latere woonwijken tonen de Nederlandse geschiedenis van waterbeheer en geplande vestiging. Sinds 2022 maakt het deel uit van de gemeente Dijk en Waard, terwijl de naam Heerhugowaard belangrijk blijft voor lokale identiteit, diensten en wijken.",
                russian: "Heerhugowaard вырос на осушенной земле в Noord-Holland после осушения озера в XVII веке. Прямые дороги, польдерная структура, фермы и поздние жилые районы отражают нидерландскую историю управления водой и планового заселения. С 2022 года он входит в муниципалитет Dijk en Waard, но название Heerhugowaard остаётся важным для локальной идентичности, услуг и районов."
            )
        case "Rotterdam":
            return LocalizedCityText(
                english: "Rotterdam began near a dam on the Rotte and grew into one of Europe's great port cities. Its harbour, river position, trade, and industry shaped the city, while the bombing of May 1940 destroyed much of the historic centre. Rotterdam rebuilt with modern architecture, infrastructure, and port expansion, and today it is a major logistics, cultural, educational, and healthcare centre.",
                dutch: "Rotterdam ontstond bij een dam in de Rotte en groeide uit tot een van Europa's grote havensteden. Haven, rivierligging, handel en industrie vormden de stad, terwijl het bombardement van mei 1940 een groot deel van de historische binnenstad verwoestte. Rotterdam werd herbouwd met moderne architectuur, infrastructuur en havenuitbreiding en is nu een centrum voor logistiek, cultuur, onderwijs en zorg.",
                russian: "Rotterdam возник у дамбы на реке Rotte и вырос в один из крупнейших портовых городов Европы. Гавань, положение на реке, торговля и промышленность сформировали город, а бомбардировка в мае 1940 года уничтожила значительную часть исторического центра. Rotterdam был восстановлен с современной архитектурой, инфраструктурой и расширением порта и сегодня является центром логистики, культуры, образования и медицины."
            )
        case "Den Haag":
            return LocalizedCityText(
                english: "Den Haag developed around the Binnenhof, where the counts of Holland established their court. Although it did not grow like a classic walled trading city, it became the seat of Dutch government and later a centre of diplomacy and international law. Today Den Haag combines national institutions, embassies, courts, coastal neighbourhoods, museums, and municipal services for a diverse population.",
                dutch: "Den Haag ontwikkelde zich rond het Binnenhof, waar de graven van Holland hun hof vestigden. Hoewel het niet groeide als klassieke ommuurde handelsstad, werd het de zetel van het Nederlandse bestuur en later een centrum van diplomatie en internationaal recht. Vandaag combineert Den Haag nationale instellingen, ambassades, rechtbanken, kustwijken, musea en gemeentelijke diensten voor een diverse bevolking.",
                russian: "Den Haag развился вокруг Binnenhof, где графы Holland разместили свой двор. Хотя город не рос как классический укреплённый торговый центр, он стал местом работы нидерландского правительства, а позднее центром дипломатии и международного права. Сегодня Den Haag сочетает национальные институты, посольства, суды, прибрежные районы, музеи и муниципальные услуги для разнообразного населения."
            )
        case "Leiden":
            return LocalizedCityText(
                english: "Leiden is a medieval canal city in South Holland with city rights dating from the thirteenth century. The siege and relief of Leiden in 1574 became a major event in the Dutch Revolt, and Leiden University was founded shortly afterwards in 1575. The city later became known for scholarship, printing, museums, textile history, and a compact historic centre that still shapes daily life.",
                dutch: "Leiden is een middeleeuwse grachtenstad in Zuid-Holland met stadsrechten uit de dertiende eeuw. Het beleg en ontzet van Leiden in 1574 werden een belangrijk moment in de Nederlandse Opstand, en kort daarna werd in 1575 de Universiteit Leiden gesticht. De stad werd later bekend door wetenschap, drukwerk, musea, textielgeschiedenis en een compacte historische binnenstad die het dagelijks leven nog steeds vormt.",
                russian: "Leiden — средневековый город каналов в Zuid-Holland с городскими правами XIII века. Осада и освобождение Leiden в 1574 году стали важным событием Dutch Revolt, а вскоре после этого, в 1575 году, был основан Leiden University. Позднее город стал известен наукой, печатью, музеями, текстильной историей и компактным историческим центром, который до сих пор формирует повседневную жизнь."
            )
        case "Delft":
            return LocalizedCityText(
                english: "Delft grew as a medieval canal town between Rotterdam and Den Haag and became important for trade, crafts, and administration. It is closely connected with William of Orange, the Dutch Revolt, Delftware pottery, the Dutch East India Company, and later technical education. Today Delft combines a protected historic centre with knowledge institutions, technology, design, tourism, and regional services.",
                dutch: "Delft groeide uit tot een middeleeuwse grachtenstad tussen Rotterdam en Den Haag en werd belangrijk voor handel, ambacht en bestuur. De stad is sterk verbonden met Willem van Oranje, de Nederlandse Opstand, Delfts blauw, de VOC en later technisch onderwijs. Vandaag combineert Delft een beschermde historische binnenstad met kennisinstellingen, technologie, design, toerisme en regionale voorzieningen.",
                russian: "Delft вырос как средневековый город каналов между Rotterdam и Den Haag и стал важным для торговли, ремёсел и управления. Он тесно связан с William of Orange, Dutch Revolt, керамикой Delftware, VOC и позднее техническим образованием. Сегодня Delft сочетает защищённый исторический центр с институтами знаний, технологиями, дизайном, туризмом и региональными услугами."
            )
        case "Utrecht":
            return LocalizedCityText(
                english: "Utrecht has Roman roots in the fort Traiectum and later became a powerful religious and trading centre. Its bishops, churches, canals, markets, and central location shaped the city for centuries. In the modern Netherlands, Utrecht is known for its university, historic centre, national rail hub, healthcare, culture, and a fast-growing urban role in the middle of the country.",
                dutch: "Utrecht heeft Romeinse wortels in het fort Traiectum en werd later een machtig religieus en handelscentrum. Bisschoppen, kerken, grachten, markten en de centrale ligging vormden de stad eeuwenlang. In het moderne Nederland staat Utrecht bekend om de universiteit, historische binnenstad, het nationale spoorwegknooppunt, zorg, cultuur en een snelgroeiende stedelijke rol in het midden van het land.",
                russian: "Utrecht имеет римские корни в форте Traiectum и позднее стал влиятельным религиозным и торговым центром. Епископы, церкви, каналы, рынки и центральное положение веками формировали город. В современных Нидерландах Utrecht известен университетом, историческим центром, национальным железнодорожным узлом, медициной, культурой и быстро растущей городской ролью в центре страны."
            )
        case "Amersfoort":
            return LocalizedCityText(
                english: "Amersfoort grew in the Middle Ages at a strategic place near the Eem and important routes through the central Netherlands. Its city walls, gates, Koppelpoort, churches, and market history show its role as a fortified trading town. Modern Amersfoort expanded strongly with rail connections, housing, military and administrative functions, and today acts as a regional centre in Utrecht province.",
                dutch: "Amersfoort groeide in de middeleeuwen op een strategische plek bij de Eem en belangrijke routes door Midden-Nederland. Stadsmuren, poorten, de Koppelpoort, kerken en marktgeschiedenis tonen de rol als versterkte handelsstad. Het moderne Amersfoort breidde sterk uit met spoorverbindingen, wonen, militaire en bestuurlijke functies en is nu een regionaal centrum in de provincie Utrecht.",
                russian: "Amersfoort вырос в Средние века в стратегическом месте у Eem и важных путей через центральные Нидерланды. Городские стены, ворота, Koppelpoort, церкви и рыночная история показывают его роль укреплённого торгового города. Современный Amersfoort сильно расширился благодаря железной дороге, жилью, военным и административным функциям и сегодня служит региональным центром провинции Utrecht."
            )
        case "Arnhem":
            return LocalizedCityText(
                english: "Arnhem developed on the edge of the Veluwe and near the Rhine routes, gaining importance as a Gelderland town and later provincial capital. Its history includes trade, estates, military events, and major damage during the Second World War, especially around Operation Market Garden. Today Arnhem is known for government, parks, fashion, culture, transport, and its connection to the surrounding landscape.",
                dutch: "Arnhem ontwikkelde zich aan de rand van de Veluwe en bij routes langs de Rijn, en werd belangrijk als Gelderse stad en later provinciehoofdstad. De geschiedenis omvat handel, landgoederen, militaire gebeurtenissen en zware schade in de Tweede Wereldoorlog, vooral rond Operatie Market Garden. Vandaag staat Arnhem bekend om bestuur, parken, mode, cultuur, vervoer en de verbinding met het omliggende landschap.",
                russian: "Arnhem развился на краю Veluwe и у путей вдоль Rhine, став важным городом Gelderland и позднее столицей провинции. Его история включает торговлю, усадьбы, военные события и серьёзные разрушения во время Второй мировой войны, особенно вокруг Operation Market Garden. Сегодня Arnhem известен управлением, парками, модой, культурой, транспортом и связью с окружающим ландшафтом."
            )
        case "Nijmegen":
            return LocalizedCityText(
                english: "Nijmegen has deep Roman origins and is often described as one of the oldest cities in the Netherlands. Its position near the Waal made it important for military, trade, religious, and regional life through many centuries. The city suffered heavy wartime damage but remains a major Gelderland centre, known for Radboud University, healthcare, culture, river landscapes, and the Four Days Marches.",
                dutch: "Nijmegen heeft diepe Romeinse wortels en wordt vaak beschreven als een van de oudste steden van Nederland. De ligging bij de Waal maakte de stad eeuwenlang belangrijk voor militaire, handels-, religieuze en regionale functies. De stad liep zware oorlogsschade op, maar blijft een belangrijk centrum in Gelderland, bekend om Radboud Universiteit, zorg, cultuur, rivierlandschap en de Vierdaagse.",
                russian: "Nijmegen имеет глубокие римские корни и часто описывается как один из старейших городов Нидерландов. Положение у Waal веками делало его важным для военной, торговой, религиозной и региональной жизни. Город серьёзно пострадал во время войны, но остаётся крупным центром Gelderland, известным Radboud University, медициной, культурой, речными ландшафтами и Four Days Marches."
            )
        case "Eindhoven":
            return LocalizedCityText(
                english: "Eindhoven received city rights in the Middle Ages but remained relatively small until industrial growth changed its role. The arrival and expansion of Philips from the late nineteenth century made the city a centre of technology, manufacturing, research, and design. Today Eindhoven is the heart of the Brainport region, with universities, high-tech companies, design culture, and strong regional transport links.",
                dutch: "Eindhoven kreeg in de middeleeuwen stadsrechten maar bleef relatief klein totdat industriële groei de rol veranderde. De komst en uitbreiding van Philips vanaf het einde van de negentiende eeuw maakten de stad een centrum van technologie, productie, onderzoek en design. Vandaag is Eindhoven het hart van de Brainport-regio, met universiteiten, hightechbedrijven, designcultuur en sterke regionale verbindingen.",
                russian: "Eindhoven получил городские права в Средние века, но оставался сравнительно небольшим до индустриального роста. Появление и расширение Philips с конца XIX века сделали город центром технологий, производства, исследований и дизайна. Сегодня Eindhoven — сердце региона Brainport с университетами, высокотехнологичными компаниями, культурой дизайна и сильными региональными связями."
            )
        case "Tilburg":
            return LocalizedCityText(
                english: "Tilburg grew from villages and estates into one of the Netherlands' major textile and wool cities. Industrialisation in the nineteenth and twentieth centuries shaped its neighbourhoods, factories, workers' culture, and later urban renewal. Modern Tilburg is a large North Brabant city with a university, cultural venues, logistics, education, creative industries, and services for a broad regional population.",
                dutch: "Tilburg groeide uit dorpen en landgoederen tot een van de belangrijkste textiel- en wolsteden van Nederland. Industrialisatie in de negentiende en twintigste eeuw vormde wijken, fabrieken, arbeiderscultuur en later stedelijke vernieuwing. Het moderne Tilburg is een grote stad in Noord-Brabant met universiteit, cultuur, logistiek, onderwijs, creatieve sectoren en voorzieningen voor een brede regio.",
                russian: "Tilburg вырос из деревень и поместий в один из главных текстильных и шерстяных городов Нидерландов. Индустриализация XIX и XX веков сформировала районы, фабрики, рабочую культуру и позднее городское обновление. Современный Tilburg — крупный город Noord-Brabant с университетом, культурными площадками, логистикой, образованием, креативными отраслями и услугами для региона."
            )
        case "Breda":
            return LocalizedCityText(
                english: "Breda developed as a fortified town in North Brabant and became closely connected with the House of Nassau. Its castle, old centre, military history, religious institutions, and role in conflicts between Dutch and Spanish forces shaped the city. Today Breda combines historic streets and monuments with education, business parks, hospitality, military heritage, rail links, and a regional service role.",
                dutch: "Breda ontwikkelde zich als vestingstad in Noord-Brabant en raakte sterk verbonden met het Huis Nassau. Kasteel, oude binnenstad, militaire geschiedenis, religieuze instellingen en conflicten tussen Nederlandse en Spaanse troepen vormden de stad. Vandaag combineert Breda historische straten en monumenten met onderwijs, bedrijventerreinen, horeca, militair erfgoed, spoorverbindingen en een regionale voorzieningenrol.",
                russian: "Breda развивалась как укреплённый город в Noord-Brabant и стала тесно связана с House of Nassau. Замок, старый центр, военная история, религиозные учреждения и конфликты между нидерландскими и испанскими силами сформировали город. Сегодня Breda сочетает исторические улицы и памятники с образованием, бизнес-парками, гостеприимством, военным наследием, железной дорогой и региональными услугами."
            )
        case "'s-Hertogenbosch":
            return LocalizedCityText(
                english: "'s-Hertogenbosch was founded as a fortified town in medieval Brabant and became an important administrative, religious, and commercial centre. Its walls, waterways, Saint John's Cathedral, and association with painter Jheronimus Bosch remain central to the city's identity. Today Den Bosch is the capital of North Brabant, combining heritage, courts, provincial services, culture, shopping, and regional transport.",
                dutch: "'s-Hertogenbosch werd gesticht als vestingstad in middeleeuws Brabant en werd een belangrijk bestuurlijk, religieus en commercieel centrum. Muren, waterlopen, de Sint-Janskathedraal en de band met schilder Jheronimus Bosch blijven belangrijk voor de identiteit. Vandaag is Den Bosch de hoofdstad van Noord-Brabant, met erfgoed, rechtbanken, provinciale diensten, cultuur, winkels en regionaal vervoer.",
                russian: "'s-Hertogenbosch был основан как укреплённый город средневекового Brabant и стал важным административным, религиозным и торговым центром. Стены, водные пути, Saint John's Cathedral и связь с художником Jheronimus Bosch остаются ключевыми для идентичности города. Сегодня Den Bosch — столица Noord-Brabant, объединяющая наследие, суды, провинциальные услуги, культуру, торговлю и региональный транспорт."
            )
        case "Maastricht":
            return LocalizedCityText(
                english: "Maastricht is one of the oldest urban settlements in the Netherlands, with Roman roots at a crossing of the Maas. Medieval churches, fortifications, trade, and its position between Dutch, Belgian, and German regions shaped the city's identity. In modern history Maastricht became internationally known through the 1992 Maastricht Treaty, while today it is a Limburg centre for university life, culture, healthcare, tourism, and cross-border work.",
                dutch: "Maastricht is een van de oudste stedelijke nederzettingen van Nederland, met Romeinse wortels bij een oversteek van de Maas. Middeleeuwse kerken, vestingwerken, handel en de ligging tussen Nederlandse, Belgische en Duitse regio's vormden de identiteit. In de moderne geschiedenis werd Maastricht internationaal bekend door het Verdrag van Maastricht van 1992; vandaag is het een Limburgs centrum voor universiteit, cultuur, zorg, toerisme en grensarbeid.",
                russian: "Maastricht — одно из старейших городских поселений Нидерландов, с римскими корнями у переправы через Maas. Средневековые церкви, укрепления, торговля и положение между нидерландскими, бельгийскими и немецкими регионами сформировали идентичность города. В современной истории Maastricht стал международно известен благодаря Maastricht Treaty 1992 года, а сегодня это центр Limburg для университета, культуры, медицины, туризма и трансграничной работы."
            )
        case "Venlo":
            return LocalizedCityText(
                english: "Venlo grew on the Maas near the German border and became a trading town with strong regional and cross-border connections. Its medieval town rights, river position, markets, and later railway and logistics links shaped local life. The city suffered wartime damage but rebuilt as a Limburg centre for commerce, transport, agriculture-related trade, culture, and daily services between the Netherlands and Germany.",
                dutch: "Venlo groeide aan de Maas bij de Duitse grens en werd een handelsstad met sterke regionale en grensoverschrijdende verbindingen. Middeleeuwse stadsrechten, ligging aan de rivier, markten en later spoor- en logistieke verbindingen vormden het lokale leven. De stad liep oorlogsschade op maar herbouwde zich als Limburgs centrum voor handel, vervoer, agrarische handel, cultuur en dagelijkse diensten tussen Nederland en Duitsland.",
                russian: "Venlo вырос на Maas у немецкой границы и стал торговым городом с сильными региональными и трансграничными связями. Средневековые городские права, положение на реке, рынки, а позднее железная дорога и логистика сформировали местную жизнь. Город пострадал во время войны, но был восстановлен как лимбургский центр торговли, транспорта, аграрной коммерции, культуры и повседневных услуг между Нидерландами и Германией."
            )
        case "Zwolle":
            return LocalizedCityText(
                english: "Zwolle developed as a medieval trading city on routes through Overijssel and became part of the Hanseatic network. Its city walls, gates, churches, schools, and merchant houses show a long history of trade, learning, religion, and regional administration. Today Zwolle is the capital of Overijssel, with a historic centre, rail connections, education, healthcare, culture, and services for the IJssel-Vecht region.",
                dutch: "Zwolle ontwikkelde zich als middeleeuwse handelsstad op routes door Overijssel en werd onderdeel van het Hanze-netwerk. Stadsmuren, poorten, kerken, scholen en koopmanshuizen tonen een lange geschiedenis van handel, onderwijs, religie en regionaal bestuur. Vandaag is Zwolle de hoofdstad van Overijssel, met een historische binnenstad, spoorverbindingen, onderwijs, zorg, cultuur en voorzieningen voor de IJssel-Vecht-regio.",
                russian: "Zwolle развился как средневековый торговый город на путях через Overijssel и вошёл в ганзейскую сеть. Городские стены, ворота, церкви, школы и купеческие дома показывают долгую историю торговли, обучения, религии и регионального управления. Сегодня Zwolle — столица Overijssel с историческим центром, железнодорожными связями, образованием, медициной, культурой и услугами для региона IJssel-Vecht."
            )
        case "Almere":
            return LocalizedCityText(
                english: "Almere is one of the Netherlands' newest large cities, built on reclaimed land in Flevoland. Planning began after the creation of the Flevopolder, with the first residents arriving in the 1970s and the municipality later growing quickly. Today Almere is known for modern urban planning, diverse neighbourhoods, water and green space, commuter links to Amsterdam, and a young, expanding population.",
                dutch: "Almere is een van de nieuwste grote steden van Nederland, gebouwd op drooggelegd land in Flevoland. De planning begon na de aanleg van de Flevopolder, met de eerste bewoners in de jaren zeventig en daarna snelle gemeentelijke groei. Vandaag staat Almere bekend om moderne stedenbouw, diverse wijken, water en groen, verbindingen met Amsterdam en een jonge, groeiende bevolking.",
                russian: "Almere — один из самых новых крупных городов Нидерландов, построенный на осушенной земле Flevoland. Планирование началось после создания Flevopolder; первые жители появились в 1970-х, а муниципалитет затем быстро вырос. Сегодня Almere известен современной градостроительной структурой, разнообразными районами, водой и зеленью, связями с Amsterdam и молодым растущим населением."
            )
        case "Lelystad":
            return LocalizedCityText(
                english: "Lelystad was planned on reclaimed land and named after engineer Cornelis Lely, whose work was central to the Zuiderzee project. The city developed after the creation of the eastern Flevoland polders and became the provincial capital. Today Lelystad combines government functions, new-town planning, water heritage, nature areas, aviation, regional transport, and services for a still relatively young province.",
                dutch: "Lelystad werd gepland op drooggelegd land en genoemd naar ingenieur Cornelis Lely, wiens werk centraal stond in de Zuiderzeewerken. De stad ontwikkelde zich na de aanleg van de oostelijke Flevolandse polders en werd provinciehoofdstad. Vandaag combineert Lelystad bestuurlijke functies, new-town-planning, watererfgoed, natuurgebieden, luchtvaart, regionaal vervoer en voorzieningen voor een nog jonge provincie.",
                russian: "Lelystad был спланирован на осушенной земле и назван в честь инженера Cornelis Lely, чья работа была ключевой для Zuiderzee project. Город развился после создания восточных польдеров Flevoland и стал столицей провинции. Сегодня Lelystad сочетает административные функции, планировку нового города, водное наследие, природные территории, авиацию, региональный транспорт и услуги для ещё молодой провинции."
            )
        case "Groningen":
            return LocalizedCityText(
                english: "Groningen grew as the main city of the northern Netherlands, with medieval trade, regional power, and later strong academic influence. The University of Groningen was founded in 1614 and helped shape the city's identity as a student and knowledge centre. Today Groningen combines historic streets, cycling culture, hospitals, culture, regional government, education, and services for a wide northern region.",
                dutch: "Groningen groeide uit tot de belangrijkste stad van Noord-Nederland, met middeleeuwse handel, regionale macht en later sterke academische invloed. De Rijksuniversiteit Groningen werd in 1614 gesticht en vormde de identiteit als studenten- en kennisstad. Vandaag combineert Groningen historische straten, fietscultuur, ziekenhuizen, cultuur, regionaal bestuur, onderwijs en voorzieningen voor een brede noordelijke regio.",
                russian: "Groningen вырос в главный город северных Нидерландов, с средневековой торговлей, региональной властью и позднее сильным академическим влиянием. University of Groningen был основан в 1614 году и сформировал идентичность города как студенческого и научного центра. Сегодня Groningen сочетает исторические улицы, велосипедную культуру, больницы, культуру, региональное управление, образование и услуги для большого северного региона."
            )
        case "Leeuwarden":
            return LocalizedCityText(
                english: "Leeuwarden developed from terps and settlements in Friesland and became the province's capital. It was historically connected with Frisian administration, trade, water routes, and the court of the Frisian stadtholders. Today Leeuwarden is known for its historic centre, Frisian language and culture, education, regional services, museums, and its role as a cultural city in the north of the Netherlands.",
                dutch: "Leeuwarden ontwikkelde zich uit terpen en nederzettingen in Friesland en werd de provinciehoofdstad. De stad was historisch verbonden met Fries bestuur, handel, waterroutes en het hof van de Friese stadhouders. Vandaag staat Leeuwarden bekend om de historische binnenstad, Friese taal en cultuur, onderwijs, regionale voorzieningen, musea en de rol als cultuurstad in Noord-Nederland.",
                russian: "Leeuwarden развился из терповых поселений во Friesland и стал столицей провинции. Исторически город был связан с фризским управлением, торговлей, водными путями и двором фризских stadtholders. Сегодня Leeuwarden известен историческим центром, фризским языком и культурой, образованием, региональными услугами, музеями и ролью культурного города на севере Нидерландов."
            )
        case "Assen":
            return LocalizedCityText(
                english: "Assen grew from a settlement around the medieval convent Maria in Campis and later became the administrative centre of Drenthe. Unlike many older Dutch cities, it developed strongly through provincial government, roads, military functions, and planned urban expansion. Today Assen is the capital of Drenthe, known for government, green surroundings, culture, regional services, and the TT Circuit nearby.",
                dutch: "Assen groeide uit een nederzetting rond het middeleeuwse klooster Maria in Campis en werd later het bestuurlijke centrum van Drenthe. Anders dan veel oudere Nederlandse steden ontwikkelde Assen sterk door provinciaal bestuur, wegen, militaire functies en geplande stadsuitbreiding. Vandaag is Assen de hoofdstad van Drenthe, bekend om bestuur, groene omgeving, cultuur, regionale voorzieningen en het nabijgelegen TT Circuit.",
                russian: "Assen вырос из поселения вокруг средневекового монастыря Maria in Campis и позднее стал административным центром Drenthe. В отличие от многих старых нидерландских городов, он сильно развивался благодаря провинциальному управлению, дорогам, военным функциям и плановому расширению. Сегодня Assen — столица Drenthe, известная управлением, зелёным окружением, культурой, региональными услугами и близким TT Circuit."
            )
        case "Middelburg":
            return LocalizedCityText(
                english: "Middelburg grew in medieval Zeeland as a fortified and trading town and later became one of the important Dutch East India Company chambers. Its abbey, canals, merchant houses, and position in Zeeland shaped a strong administrative and maritime identity. The city suffered wartime destruction in 1940 but rebuilt its centre and remains Zeeland's capital for government, heritage, culture, and regional services.",
                dutch: "Middelburg groeide in middeleeuws Zeeland uit tot vesting- en handelsstad en werd later een van de belangrijke kamers van de VOC. Abdij, grachten, koopmanshuizen en de ligging in Zeeland vormden een sterke bestuurlijke en maritieme identiteit. De stad werd in 1940 zwaar getroffen, maar herbouwde de binnenstad en blijft de Zeeuwse hoofdstad voor bestuur, erfgoed, cultuur en regionale voorzieningen.",
                russian: "Middelburg вырос в средневековой Zeeland как укреплённый и торговый город и позднее стал одной из важных палат VOC. Аббатство, каналы, купеческие дома и положение в Zeeland сформировали сильную административную и морскую идентичность. Город сильно пострадал в 1940 году, но восстановил центр и остаётся столицей Zeeland для управления, наследия, культуры и региональных услуг."
            )
        default:
            return nil
        }
    }

    private static func cityHistorySourceURL(name: String) -> String? {
        switch name {
        case "Amsterdam": return "https://en.wikipedia.org/wiki/Amsterdam"
        case "Haarlem": return "https://en.wikipedia.org/wiki/Haarlem"
        case "Alkmaar": return "https://en.wikipedia.org/wiki/Alkmaar"
        case "Hoorn": return "https://en.wikipedia.org/wiki/Hoorn"
        case "Zaanstad": return "https://en.wikipedia.org/wiki/Zaanstad"
        case "Amstelveen": return "https://en.wikipedia.org/wiki/Amstelveen"
        case "Purmerend": return "https://en.wikipedia.org/wiki/Purmerend"
        case "Heerhugowaard": return "https://en.wikipedia.org/wiki/Heerhugowaard"
        case "Rotterdam": return "https://en.wikipedia.org/wiki/Rotterdam"
        case "Den Haag": return "https://en.wikipedia.org/wiki/The_Hague"
        case "Leiden": return "https://en.wikipedia.org/wiki/Leiden"
        case "Delft": return "https://en.wikipedia.org/wiki/Delft"
        case "Utrecht": return "https://en.wikipedia.org/wiki/Utrecht"
        case "Amersfoort": return "https://en.wikipedia.org/wiki/Amersfoort"
        case "Arnhem": return "https://en.wikipedia.org/wiki/Arnhem"
        case "Nijmegen": return "https://en.wikipedia.org/wiki/Nijmegen"
        case "Eindhoven": return "https://en.wikipedia.org/wiki/Eindhoven"
        case "Tilburg": return "https://en.wikipedia.org/wiki/Tilburg"
        case "Breda": return "https://en.wikipedia.org/wiki/Breda"
        case "'s-Hertogenbosch": return "https://en.wikipedia.org/wiki/%27s-Hertogenbosch"
        case "Maastricht": return "https://en.wikipedia.org/wiki/Maastricht"
        case "Venlo": return "https://en.wikipedia.org/wiki/Venlo"
        case "Zwolle": return "https://en.wikipedia.org/wiki/Zwolle"
        case "Almere": return "https://en.wikipedia.org/wiki/Almere"
        case "Lelystad": return "https://en.wikipedia.org/wiki/Lelystad"
        case "Groningen": return "https://en.wikipedia.org/wiki/Groningen"
        case "Leeuwarden": return "https://en.wikipedia.org/wiki/Leeuwarden"
        case "Assen": return "https://en.wikipedia.org/wiki/Assen"
        case "Middelburg": return "https://en.wikipedia.org/wiki/Middelburg,_Zeeland"
        default: return nil
        }
    }

    private static func cityShortDescription(name: String, provinceID: String) -> LocalizedCityText {
        switch name {
        case "Leiden":
            return LocalizedCityText(
                english: "Historic university city in South Holland with canals, museums, and a compact old centre.",
                dutch: "Historische universiteitsstad in Zuid-Holland met grachten, musea en een compacte oude binnenstad.",
                russian: "Исторический город в Южной Голландии с каналами, музеями и компактным старым центром."
            )
        case "Amsterdam":
            return LocalizedCityText(
                english: "Capital city known for canals, neighbourhood services, major museums, and international transport.",
                dutch: "Hoofdstad bekend om grachten, wijkdiensten, grote musea en internationaal vervoer.",
                russian: "Столица Нидерландов, известная каналами, районами, музеями и международным транспортом."
            )
        case "Rotterdam":
            return LocalizedCityText(
                english: "Port city in South Holland with modern architecture, strong transit links, and major services.",
                dutch: "Havenstad in Zuid-Holland met moderne architectuur, sterke ov-verbindingen en grote voorzieningen.",
                russian: "Портовый город в Южной Голландии с современной архитектурой, развитым транспортом и крупными службами."
            )
        case "Utrecht":
            return LocalizedCityText(
                english: "Central Dutch city with a historic centre, major station, university, and regional services.",
                dutch: "Centrale Nederlandse stad met historische binnenstad, groot station, universiteit en regionale diensten.",
                russian: "Центральный город Нидерландов с историческим центром, крупным вокзалом, университетом и региональными службами."
            )
        case "Den Haag":
            return LocalizedCityText(
                english: "Government city by the coast, with international institutions, resident services, and tram links.",
                dutch: "Bestuursstad bij de kust, met internationale instellingen, bewonersdiensten en tramverbindingen.",
                russian: "Административный город у побережья с международными институтами, службами для жителей и трамвайным сообщением."
            )
        case "Eindhoven":
            return LocalizedCityText(
                english: "Technology and design city in North Brabant with strong education and transport connections.",
                dutch: "Technologie- en designstad in Noord-Brabant met sterke onderwijs- en vervoersverbindingen.",
                russian: "Технологический и дизайнерский город в Северном Брабанте с развитым образованием и транспортом."
            )
        case "Groningen":
            return LocalizedCityText(
                english: "Northern university city with regional services, culture, healthcare, and a busy cycling centre.",
                dutch: "Noordelijke universiteitsstad met regionale diensten, cultuur, zorg en een druk fietscentrum.",
                russian: "Северный университетский город с региональными службами, культурой, здравоохранением и активным велодвижением."
            )
        case "Maastricht":
            return LocalizedCityText(
                english: "Historic Limburg city on the Maas, known for international culture, education, and cross-border links.",
                dutch: "Historische Limburgse stad aan de Maas, bekend om internationale cultuur, onderwijs en grensverbindingen.",
                russian: "Исторический город Лимбурга на Маасе, известный международной культурой, образованием и приграничными связями."
            )
        case "Zwolle":
            return LocalizedCityText(
                english: "Historic Hanseatic city on the IJssel, with medieval gates, canals, and a lively city centre.",
                dutch: "Historische Hanzestad aan de IJssel, met middeleeuwse poorten, grachten en het gezellige stadscentrum.",
                russian: "Исторический ганзейский город на IJssel с средневековыми воротами, каналами и оживлённым центром."
            )
        default:
            return LocalizedCityText(
                english: "\(name) is a municipality in \(provinceID) with local services, transport links, and resident information for newcomers.",
                dutch: "\(name) is een gemeente in \(provinceID) met lokale diensten, vervoersverbindingen en bewonersinformatie voor nieuwkomers.",
                russian: "\(name) — муниципалитет в \(provinceID) с местными службами, транспортными связями и информацией для новых жителей."
            )
        }
    }

    private static func cityShortHistory(name: String, provinceID: String) -> LocalizedCityText {
        switch name {
        case "Leiden":
            return LocalizedCityText(
                english: "Leiden is a historic city in South Holland, known for its university, canals, museums, and old city centre. The city has long been connected with education, science, printing, and textile history.",
                dutch: "Leiden is een historische stad in Zuid-Holland, bekend om de universiteit, grachten, musea en de oude binnenstad. De stad is al lange tijd verbonden met onderwijs, wetenschap, drukwerk en textielgeschiedenis.",
                russian: "Лейден — исторический город в Южной Голландии, известный университетом, каналами, музеями и старым центром. Город долгое время был связан с образованием, наукой, печатным делом и текстильной историей."
            )
        case "Amsterdam":
            return LocalizedCityText(
                english: "Amsterdam grew from a small settlement near the Amstel into the capital of the Netherlands. The city became internationally known for trade, canals, culture, and museums. Today it is a major centre for public services, transport, education, business, and tourism.",
                dutch: "Amsterdam groeide uit van een kleine nederzetting bij de Amstel tot de hoofdstad van Nederland. De stad werd internationaal bekend door handel, grachten, cultuur en musea. Vandaag is Amsterdam een belangrijk centrum voor publieke diensten, vervoer, onderwijs, bedrijven en toerisme.",
                russian: "Амстердам вырос из небольшого поселения у Амстела в столицу Нидерландов. Город стал известен торговлей, каналами, культурой и музеями. Сегодня это крупный центр общественных услуг, транспорта, образования, бизнеса и туризма."
            )
        case "Rotterdam":
            return LocalizedCityText(
                english: "Rotterdam developed as a major port city and was rebuilt with a modern urban identity after heavy wartime damage. The city is now known for shipping, architecture, education, healthcare, and diverse neighbourhoods.",
                dutch: "Rotterdam ontwikkelde zich als grote havenstad en kreeg na zware oorlogsschade een moderne stedelijke identiteit. De stad staat nu bekend om scheepvaart, architectuur, onderwijs, zorg en diverse wijken.",
                russian: "Роттердам развился как крупный портовый город и был отстроен заново с современной городской идентичностью после тяжёлых военных разрушений. Сейчас город известен судоходством, архитектурой, образованием, здравоохранением и разнообразными районами."
            )
        case "Utrecht":
            return LocalizedCityText(
                english: "Utrecht has a long history as a central city with canals, churches, education, and trade routes. Its location makes it a major rail hub, while the old centre and university keep a strong local identity.",
                dutch: "Utrecht heeft een lange geschiedenis als centrale stad met grachten, kerken, onderwijs en handelsroutes. Door de ligging is het een belangrijk spoorwegknooppunt, terwijl de oude binnenstad en universiteit de lokale identiteit sterk houden.",
                russian: "Утрехт имеет долгую историю центрального города с каналами, церквями, образованием и торговыми путями. Его расположение делает его крупным железнодорожным узлом, а старый центр и университет сохраняют сильную местную идентичность."
            )
        case "Den Haag":
            return LocalizedCityText(
                english: "Den Haag has long been connected with Dutch government and international law. It combines national institutions, coastal neighbourhoods, museums, and resident services in one municipality.",
                dutch: "Den Haag is al lang verbonden met het Nederlandse bestuur en internationaal recht. De stad combineert nationale instellingen, kustwijken, musea en bewonersdiensten in een gemeente.",
                russian: "Гаага давно связана с нидерландским правительством и международным правом. Город сочетает национальные институты, прибрежные районы, музеи и услуги для жителей в одном муниципалитете."
            )
        case "Eindhoven":
            return LocalizedCityText(
                english: "Eindhoven grew from an industrial city into a technology and design centre. Today it is known for innovation, education, regional jobs, and practical transport links across North Brabant.",
                dutch: "Eindhoven groeide van industriestad uit tot centrum voor technologie en design. Vandaag staat de stad bekend om innovatie, onderwijs, regionale banen en praktische verbindingen in Noord-Brabant.",
                russian: "Эйндховен вырос из промышленного города в центр технологий и дизайна. Сегодня он известен инновациями, образованием, региональной занятостью и удобными связями по Северному Брабанту."
            )
        case "Groningen":
            return LocalizedCityText(
                english: "Groningen is the main city of the northern Netherlands, with a large student population, regional healthcare, cultural venues, and a strong cycling identity.",
                dutch: "Groningen is de belangrijkste stad van Noord-Nederland, met veel studenten, regionale zorg, culturele voorzieningen en een sterke fietscultuur.",
                russian: "Гронинген — главный город северных Нидерландов с большим студенческим населением, региональной медициной, культурными площадками и сильной велосипедной культурой."
            )
        case "Maastricht":
            return LocalizedCityText(
                english: "Maastricht is one of the Netherlands' oldest cities and a key Limburg centre. It is shaped by the Maas, historic streets, university life, healthcare, culture, and nearby Belgian and German links.",
                dutch: "Maastricht is een van de oudste steden van Nederland en een belangrijk centrum in Limburg. De stad wordt gevormd door de Maas, historische straten, universiteit, zorg, cultuur en verbindingen met Belgie en Duitsland.",
                russian: "Маастрихт — один из старейших городов Нидерландов и важный центр Лимбурга. Его формируют Маас, исторические улицы, университетская жизнь, медицина, культура и связи с Бельгией и Германией."
            )
        default:
            return LocalizedCityText(
                english: "\(name) has local history shaped by its municipality, province, transport links, and public services. For exact dates and heritage details, verify current information through official city or regional sources.",
                dutch: "\(name) heeft lokale geschiedenis die is gevormd door de gemeente, provincie, vervoersverbindingen en publieke diensten. Controleer exacte data en erfgoedinformatie via officiele stads- of regionale bronnen.",
                russian: "\(name) имеет местную историю, сформированную муниципалитетом, провинцией, транспортными связями и государственными службами. Для точных дат и сведений о наследии проверяйте актуальную информацию через официальные городские или региональные источники."
            )
        }
    }

    private static func cityTimeline(name: String, provinceID: String) -> [LocalizedCityText] {
        switch name {
        case "Leiden":
            return [
                LocalizedCityText(english: "Historic canal city in South Holland", dutch: "Historische grachtenstad in Zuid-Holland", russian: "Исторический город с каналами в Южной Голландии"),
                LocalizedCityText(english: "Known for Leiden University and museums", dutch: "Bekend om Universiteit Leiden en musea", russian: "Известен Лейденским университетом и музеями"),
                LocalizedCityText(english: "Important centre for education, science, and culture", dutch: "Belangrijk centrum voor onderwijs, wetenschap en cultuur", russian: "Важный центр образования, науки и культуры")
            ]
        case "Amsterdam":
            return [
                LocalizedCityText(english: "Capital city and major municipality", dutch: "Hoofdstad en grote gemeente", russian: "Столица и крупный муниципалитет"),
                LocalizedCityText(english: "Known for canals, museums, education, and international transport", dutch: "Bekend om grachten, musea, onderwijs en internationaal vervoer", russian: "Известен каналами, музеями, образованием и международным транспортом"),
                LocalizedCityText(english: "Neighbourhood services are important because the city is large and busy", dutch: "Wijkdiensten zijn belangrijk door de grootte en drukte van de stad", russian: "Районные службы важны, потому что город большой и загруженный")
            ]
        case "Rotterdam":
            return [
                LocalizedCityText(english: "Major port and logistics city", dutch: "Grote haven- en logistiekstad", russian: "Крупный портовый и логистический город"),
                LocalizedCityText(english: "Modern centre rebuilt with strong architecture", dutch: "Moderne binnenstad met sterke architectuur", russian: "Современный центр с выразительной архитектурой"),
                LocalizedCityText(english: "Important regional services, education, and healthcare", dutch: "Belangrijke regionale diensten, onderwijs en zorg", russian: "Важные региональные службы, образование и медицина")
            ]
        case "Den Haag":
            return [
                LocalizedCityText(english: "Seat of Dutch government", dutch: "Zetel van de Nederlandse regering", russian: "Место работы правительства Нидерландов"),
                LocalizedCityText(english: "International institutions and coastal neighbourhoods", dutch: "Internationale instellingen en kustwijken", russian: "Международные институты и прибрежные районы"),
                LocalizedCityText(english: "Municipality services are central for residents", dutch: "Gemeentediensten zijn belangrijk voor bewoners", russian: "Муниципальные услуги важны для жителей")
            ]
        case "Utrecht":
            return [
                LocalizedCityText(english: "Central rail and public transport hub", dutch: "Centraal spoor- en ov-knooppunt", russian: "Центральный железнодорожный и транспортный узел"),
                LocalizedCityText(english: "Historic canals, university, and compact centre", dutch: "Historische grachten, universiteit en compacte binnenstad", russian: "Исторические каналы, университет и компактный центр"),
                LocalizedCityText(english: "Strong regional services for daily life", dutch: "Sterke regionale voorzieningen voor dagelijks leven", russian: "Сильные региональные службы для повседневной жизни")
            ]
        case "Eindhoven":
            return [
                LocalizedCityText(english: "Technology, design, and regional jobs", dutch: "Technologie, design en regionale banen", russian: "Технологии, дизайн и региональная занятость"),
                LocalizedCityText(english: "Education and innovation are part of city identity", dutch: "Onderwijs en innovatie horen bij de stadsidentiteit", russian: "Образование и инновации — часть идентичности города"),
                LocalizedCityText(english: "Useful hub for North Brabant services and transport", dutch: "Handig knooppunt voor diensten en vervoer in Noord-Brabant", russian: "Удобный узел для услуг и транспорта в Северном Брабанте")
            ]
        case "Groningen":
            return [
                LocalizedCityText(english: "Northern regional centre with large student population", dutch: "Noordelijk regionaal centrum met veel studenten", russian: "Северный региональный центр с большим числом студентов"),
                LocalizedCityText(english: "Known for cycling, culture, healthcare, and university life", dutch: "Bekend om fietsen, cultuur, zorg en universiteitsleven", russian: "Известен велосипедной культурой, медициной и университетской жизнью"),
                LocalizedCityText(english: "Key service city for the north of the Netherlands", dutch: "Belangrijke dienstenstad voor Noord-Nederland", russian: "Ключевой город услуг для севера Нидерландов")
            ]
        case "Maastricht":
            return [
                LocalizedCityText(english: "Historic Limburg city on the Maas", dutch: "Historische Limburgse stad aan de Maas", russian: "Исторический город Лимбурга на Маасе"),
                LocalizedCityText(english: "University, healthcare, culture, and cross-border links", dutch: "Universiteit, zorg, cultuur en grensverbindingen", russian: "Университет, медицина, культура и приграничные связи"),
                LocalizedCityText(english: "Useful orientation point for southern Limburg", dutch: "Handig orientatiepunt voor Zuid-Limburg", russian: "Удобная точка ориентации для южного Лимбурга")
            ]
        default:
            return [
                LocalizedCityText(english: "Municipality in \(provinceID)", dutch: "Gemeente in \(provinceID)", russian: "Муниципалитет в \(provinceID)"),
                LocalizedCityText(english: "Local public services for residents", dutch: "Lokale publieke diensten voor bewoners", russian: "Местные государственные службы для жителей"),
                LocalizedCityText(english: "Transport and regional links for daily life", dutch: "Vervoer en regionale verbindingen voor dagelijks leven", russian: "Транспорт и региональные связи для повседневной жизни")
            ]
        }
    }

    private static func cityHighlights(name: String, provinceID: String, municipality: String, transport: String?, tourist: String?) -> [CityLocalHighlight] {
        let municipalityHighlight = CityLocalHighlight(
            id: "municipality",
            icon: "building.columns.fill",
            title: LocalizedCityText(english: "Municipality services", dutch: "Gemeentediensten", russian: "Услуги муниципалитета"),
            description: LocalizedCityText(english: "Resident registration, appointments, permits, and local information.", dutch: "Inschrijving, afspraken, vergunningen en lokale informatie.", russian: "Регистрация жителей, запись на приём, разрешения и местная информация.")
        )
        let transportHighlight = CityLocalHighlight(
            id: "transport",
            icon: "tram.fill",
            title: LocalizedCityText(english: transport ?? "Transport links", dutch: transport ?? "Vervoer", russian: transport ?? "Транспортные связи"),
            description: LocalizedCityText(english: "Use rail, bus, tram, metro, or cycling links depending on the city.", dutch: "Gebruik trein, bus, tram, metro of fietsroutes afhankelijk van de stad.", russian: "Используйте поезд, автобус, трамвай, метро или велосипедные маршруты в зависимости от города.")
        )
        let oldCentreHighlight = CityLocalHighlight(
            id: "old-centre",
            icon: "building.2.fill",
            title: LocalizedCityText(english: "City centre", dutch: "Binnenstad", russian: "Центр города"),
            description: LocalizedCityText(english: "Useful area for services, shops, culture, and first orientation.", dutch: "Handig gebied voor diensten, winkels, cultuur en eerste orientatie.", russian: "Удобный район для услуг, магазинов, культуры и первой ориентации.")
        )

        switch name {
        case "Leiden":
            return [
                CityLocalHighlight(id: "university", icon: "graduationcap.fill", title: LocalizedCityText(english: "Leiden University", dutch: "Universiteit Leiden", russian: "Лейденский университет"), description: LocalizedCityText(english: "Major academic institution and part of the city identity.", dutch: "Belangrijke onderwijsinstelling en deel van de stadsidentiteit.", russian: "Крупное учебное заведение и часть городской идентичности.")),
                CityLocalHighlight(id: "canals", icon: "water.waves", title: LocalizedCityText(english: "Historic canals", dutch: "Historische grachten", russian: "Исторические каналы"), description: LocalizedCityText(english: "Canals and bridges shape the compact centre.", dutch: "Grachten en bruggen bepalen de compacte binnenstad.", russian: "Каналы и мосты формируют компактный центр.")),
                CityLocalHighlight(id: "burcht", icon: "building.columns.fill", title: LocalizedCityText(english: "Burcht van Leiden", dutch: "Burcht van Leiden", russian: "Burcht van Leiden"), description: LocalizedCityText(english: "The medieval hill fortress is a core landmark in the historic centre.", dutch: "De middeleeuwse burcht is een belangrijk herkenningspunt in de historische binnenstad.", russian: "Средневековая крепость на холме — важный ориентир исторического центра.")),
                oldCentreHighlight,
                CityLocalHighlight(id: "station", icon: "train.side.front.car", title: LocalizedCityText(english: "Leiden Centraal", dutch: "Leiden Centraal", russian: "Лейден Централ"), description: LocalizedCityText(english: "Main rail link for regional and national travel.", dutch: "Belangrijke treinverbinding voor regionaal en landelijk reizen.", russian: "Основное железнодорожное сообщение для регионального и национального транспорта.")),
                municipalityHighlight
            ]
        case "Amsterdam":
            return [
                CityLocalHighlight(id: "canals", icon: "water.waves", title: LocalizedCityText(english: "Canal area", dutch: "Grachtengordel", russian: "Пояс каналов"), description: LocalizedCityText(english: "Historic waterways shape the central city.", dutch: "Historische waterwegen bepalen de binnenstad.", russian: "Исторические водные пути формируют центр города.")),
                CityLocalHighlight(id: "museums", icon: "paintpalette.fill", title: LocalizedCityText(english: "Museums", dutch: "Musea", russian: "Музеи"), description: LocalizedCityText(english: "Major cultural institutions and public collections.", dutch: "Grote culturele instellingen en publieke collecties.", russian: "Крупные культурные учреждения и общественные коллекции.")),
                transportHighlight,
                municipalityHighlight
            ]
        case "Rotterdam":
            return [
                CityLocalHighlight(id: "erasmus-bridge", icon: "water.waves", title: LocalizedCityText(english: "Erasmus Bridge", dutch: "Erasmusbrug", russian: "Мост Эразма"), description: LocalizedCityText(english: "The Swan connects the Maas river skyline and is the city's signature landmark.", dutch: "De Zwaan verbindt de skyline langs de Maas en is hét stadsicoon.", russian: "«Лебедь» соединяет районы вдоль Мааса и является символом города.")),
                CityLocalHighlight(id: "port", icon: "ferry.fill", title: LocalizedCityText(english: "Port city", dutch: "Havenstad", russian: "Портовый город"), description: LocalizedCityText(english: "Port, logistics, and river connections shape local work and identity.", dutch: "Haven, logistiek en rivierverbindingen vormen werk en identiteit.", russian: "Порт, логистика и речные связи формируют местную работу и идентичность.")),
                CityLocalHighlight(id: "skyline", icon: "building.2.fill", title: LocalizedCityText(english: "Modern skyline", dutch: "Moderne skyline", russian: "Современный силуэт"), description: LocalizedCityText(english: "Rebuilt architecture, high-rises, Markthal, and Cube Houses define the city centre.", dutch: "Wederopbouw, hoogbouw, Markthal en Kubuswoningen bepalen de binnenstad.", russian: "Реконструкция, высотки, Markthal и Кубические дома формируют центр.")),
                CityLocalHighlight(id: "innovation", icon: "lightbulb.fill", title: LocalizedCityText(english: "Innovation economy", dutch: "Innovatie-economie", russian: "Инновационная экономика"), description: LocalizedCityText(english: "Logistics, design, education, and port technology support newcomers and employers.", dutch: "Logistiek, design, onderwijs en haventechnologie ondersteunen nieuwkomers en werkgevers.", russian: "Логистика, дизайн, образование и портовые технологии важны для работы и адаптации.")),
                transportHighlight,
                municipalityHighlight
            ]
        case "Utrecht":
            return [
                CityLocalHighlight(id: "dom-tower", icon: "building.columns.fill", title: LocalizedCityText(english: "Dom Tower", dutch: "Domtoren", russian: "Dom Tower"), description: LocalizedCityText(english: "The Dom Tower is the city's defining landmark and historic orientation point.", dutch: "De Domtoren is het belangrijkste herkenningspunt van de stad.", russian: "Башня Dom — главный исторический ориентир города.")),
                CityLocalHighlight(id: "oudegracht", icon: "water.waves", title: LocalizedCityText(english: "Oudegracht", dutch: "Oudegracht", russian: "Oudegracht"), description: LocalizedCityText(english: "The canal and wharf cellars shape Utrecht's historic centre.", dutch: "De gracht en werfkelders bepalen de historische binnenstad.", russian: "Канал и прибрежные подвалы формируют исторический центр.")),
                CityLocalHighlight(id: "station", icon: "train.side.front.car", title: LocalizedCityText(english: "Utrecht Centraal", dutch: "Utrecht Centraal", russian: "Утрехт Централ"), description: LocalizedCityText(english: "One of the country's busiest public transport hubs.", dutch: "Een van de drukste ov-knooppunten van het land.", russian: "Один из самых загруженных транспортных узлов страны.")),
                municipalityHighlight
            ]
        case "Den Haag":
            return [
                CityLocalHighlight(id: "binnenhof", icon: "building.columns.fill", title: LocalizedCityText(english: "Binnenhof", dutch: "Binnenhof", russian: "Binnenhof"), description: LocalizedCityText(english: "Historic centre of Dutch parliamentary government.", dutch: "Historisch centrum van de Nederlandse parlementaire overheid.", russian: "Исторический центр парламентского правительства Нидерландов.")),
                CityLocalHighlight(id: "peace-palace", icon: "building.columns.fill", title: LocalizedCityText(english: "Peace Palace", dutch: "Vredespaleis", russian: "Дворец мира"), description: LocalizedCityText(english: "International law landmark and seat of major legal institutions.", dutch: "Herkenningspunt voor internationaal recht en belangrijke juridische instellingen.", russian: "Символ международного права и важных юридических институтов.")),
                CityLocalHighlight(id: "scheveningen", icon: "sun.horizon.fill", title: LocalizedCityText(english: "Scheveningen", dutch: "Scheveningen", russian: "Схевенинген"), description: LocalizedCityText(english: "Coastal district, beach, pier, and everyday city escape.", dutch: "Kustwijk met strand, pier en dagelijkse stadsontsnapping.", russian: "Прибрежный район, пляж, пирс и городской отдых.")),
                CityLocalHighlight(id: "mauritshuis", icon: "paintpalette.fill", title: LocalizedCityText(english: "Mauritshuis", dutch: "Mauritshuis", russian: "Mauritshuis"), description: LocalizedCityText(english: "Museum beside the Binnenhof with major Dutch Golden Age works.", dutch: "Museum naast het Binnenhof met topwerken uit de Gouden Eeuw.", russian: "Музей рядом с Binnenhof с шедеврами Золотого века.")),
                transportHighlight,
                municipalityHighlight
            ]
        case "Eindhoven":
            return [
                CityLocalHighlight(id: "technology", icon: "cpu.fill", title: LocalizedCityText(english: "Technology region", dutch: "Technologieregio", russian: "Технологический регион"), description: LocalizedCityText(english: "Design, engineering, and innovation shape many local jobs.", dutch: "Design, techniek en innovatie vormen veel lokale banen.", russian: "Дизайн, инженерия и инновации формируют многие местные рабочие места.")),
                CityLocalHighlight(id: "education", icon: "graduationcap.fill", title: LocalizedCityText(english: "Education and design", dutch: "Onderwijs en design", russian: "Образование и дизайн"), description: LocalizedCityText(english: "University and design institutions are visible in city life.", dutch: "Universiteit en designinstellingen zijn zichtbaar in de stad.", russian: "Университет и дизайнерские учреждения заметны в городской жизни.")),
                transportHighlight,
                municipalityHighlight
            ]
        case "Groningen":
            return [
                CityLocalHighlight(id: "martinitoren", icon: "building.columns.fill", title: LocalizedCityText(english: "Martinitoren", dutch: "Martinitoren", russian: "Martinitoren"), description: LocalizedCityText(english: "The tower on the Grote Markt is Groningen's main landmark.", dutch: "De toren aan de Grote Markt is het belangrijkste icoon van Groningen.", russian: "Башня на Grote Markt — главный символ Гронингена.")),
                CityLocalHighlight(id: "university", icon: "graduationcap.fill", title: LocalizedCityText(english: "University city", dutch: "Universiteitsstad", russian: "Университетский город"), description: LocalizedCityText(english: "A large student population shapes housing, services, and culture.", dutch: "Veel studenten beinvloeden wonen, diensten en cultuur.", russian: "Большое студенческое население влияет на жильё, услуги и культуру.")),
                CityLocalHighlight(id: "cycling", icon: "bicycle", title: LocalizedCityText(english: "Cycling centre", dutch: "Fietsstad", russian: "Велосипедный город"), description: LocalizedCityText(english: "Cycling is a major part of everyday mobility.", dutch: "Fietsen is een belangrijk deel van dagelijkse mobiliteit.", russian: "Велосипед — важная часть повседневной мобильности.")),
                transportHighlight,
                municipalityHighlight
            ]
        case "Maastricht":
            return [
                CityLocalHighlight(id: "maas", icon: "water.waves", title: LocalizedCityText(english: "Maas river city", dutch: "Stad aan de Maas", russian: "Город на Маасе"), description: LocalizedCityText(english: "The river and historic centre shape orientation and identity.", dutch: "De rivier en binnenstad bepalen orientatie en identiteit.", russian: "Река и исторический центр формируют ориентацию и идентичность.")),
                CityLocalHighlight(id: "border", icon: "globe.europe.africa.fill", title: LocalizedCityText(english: "Cross-border links", dutch: "Grensverbindingen", russian: "Приграничные связи"), description: LocalizedCityText(english: "Belgian and German connections matter for travel, work, and culture.", dutch: "Belgische en Duitse verbindingen zijn belangrijk voor reizen, werk en cultuur.", russian: "Связи с Бельгией и Германией важны для поездок, работы и культуры.")),
                CityLocalHighlight(id: "university", icon: "graduationcap.fill", title: LocalizedCityText(english: "University and healthcare", dutch: "Universiteit en zorg", russian: "Университет и медицина"), description: LocalizedCityText(english: "Education and medical services are important local anchors.", dutch: "Onderwijs en medische diensten zijn belangrijke lokale ankers.", russian: "Образование и медицинские услуги — важные городские опоры.")),
                municipalityHighlight
            ]
        case "Nijmegen":
            return [
                CityLocalHighlight(id: "waalbrug", icon: "water.waves", title: LocalizedCityText(english: "Waalbrug", dutch: "Waalbrug", russian: "Waalbrug"), description: LocalizedCityText(english: "The bridge over the Waal is a defining Nijmegen landmark.", dutch: "De brug over de Waal is een bepalend herkenningspunt van Nijmegen.", russian: "Мост через Waal — один из главных символов Неймегена.")),
                CityLocalHighlight(id: "stevenskerk", icon: "building.columns.fill", title: LocalizedCityText(english: "Stevenskerk", dutch: "Stevenskerk", russian: "Stevenskerk"), description: LocalizedCityText(english: "Historic church and old-centre anchor in one of the Netherlands' oldest cities.", dutch: "Historische kerk en ankerpunt in de binnenstad van een van de oudste steden van Nederland.", russian: "Историческая церковь и ориентир старого центра одного из древнейших городов Нидерландов.")),
                oldCentreHighlight,
                transportHighlight,
                municipalityHighlight
            ]
        case "Arnhem":
            return [
                CityLocalHighlight(id: "john-frost-bridge", icon: "road.lanes", title: LocalizedCityText(english: "John Frost Bridge", dutch: "John Frostbrug", russian: "Мост John Frost"), description: LocalizedCityText(english: "The Rhine bridge is central to Arnhem's WWII history and city identity.", dutch: "De Rijnbrug staat centraal in de WOII-geschiedenis en identiteit van Arnhem.", russian: "Мост через Рейн важен для истории Второй мировой войны и идентичности Арнема.")),
                CityLocalHighlight(id: "sonsbeek", icon: "leaf.fill", title: LocalizedCityText(english: "Sonsbeek", dutch: "Sonsbeek", russian: "Sonsbeek"), description: LocalizedCityText(english: "Large urban park and everyday green landmark near the city centre.", dutch: "Groot stadspark en dagelijks groen herkenningspunt bij de binnenstad.", russian: "Большой городской парк и зелёный ориентир рядом с центром.")),
                transportHighlight,
                municipalityHighlight
            ]
        default:
            return [municipalityHighlight, transportHighlight, oldCentreHighlight]
        }
    }

    private static func cityQuickFacts(
        name: String,
        population: String,
        area: String?,
        municipality: String,
        provinceID: String,
        transport: String?
    ) -> [CityQuickFact] {
        var facts: [CityQuickFact] = [
            CityQuickFact(
                id: "population",
                icon: "person.3.fill",
                title: LocalizedCityText(english: "Population", dutch: "Bevolking", russian: "Население"),
                value: LocalizedCityText(english: population, dutch: population, russian: population)
            ),
            CityQuickFact(
                id: "area",
                icon: "square.grid.2x2.fill",
                title: LocalizedCityText(english: "Area", dutch: "Oppervlakte", russian: "Площадь"),
                value: LocalizedCityText(english: area ?? "Check municipality", dutch: area ?? "Controleer gemeente", russian: area ?? "Проверьте муниципалитет")
            ),
            CityQuickFact(
                id: "municipality",
                icon: "building.columns.fill",
                title: LocalizedCityText(english: "Municipality", dutch: "Gemeente", russian: "Муниципалитет"),
                value: LocalizedCityText(english: municipality, dutch: municipality, russian: ProvinceCatalog.localizedCityName(municipality, .russian))
            )
        ]

        facts.append(
            CityQuickFact(
                id: "identity",
                icon: identityIcon(for: name),
                title: LocalizedCityText(english: "Known for", dutch: "Bekend om", russian: "Известен"),
                value: cityKnownFor(name: name, provinceID: provinceID)
            )
        )

        if let transport {
            facts.append(
                CityQuickFact(
                    id: "transport",
                    icon: "tram.fill",
                    title: LocalizedCityText(english: "Public transport", dutch: "Openbaar vervoer", russian: "Общественный транспорт"),
                    value: LocalizedCityText(english: transport, dutch: transport, russian: transport)
                )
            )
        }

        return facts
    }

    private static func citySupportTags(name: String, transport: String?, tourist: String?) -> [LocalizedCityText] {
        var tags: [LocalizedCityText] = [
            LocalizedCityText(english: "Municipality", dutch: "Gemeente", russian: "Муниципалитет"),
            LocalizedCityText(english: "Registration", dutch: "Inschrijving", russian: "Регистрация")
        ]

        if transport != nil {
            tags.append(LocalizedCityText(english: "Public transport", dutch: "Openbaar vervoer", russian: "Общественный транспорт"))
        }

        switch name {
        case "Amsterdam", "Rotterdam", "Den Haag":
            tags.append(LocalizedCityText(english: "Major services", dutch: "Grote voorzieningen", russian: "Крупные службы"))
        case "Leiden", "Utrecht", "Groningen", "Maastricht", "Eindhoven":
            tags.append(LocalizedCityText(english: "Education", dutch: "Onderwijs", russian: "Образование"))
        default:
            break
        }

        if tourist != nil {
            tags.append(LocalizedCityText(english: "Visitor info", dutch: "Bezoekersinfo", russian: "Информация для посетителей"))
        }

        return tags
    }

    private static func cityKnownFor(name: String, provinceID: String) -> LocalizedCityText {
        switch name {
        case "Amsterdam":
            return LocalizedCityText(english: "Canals, museums, capital services", dutch: "Grachten, musea, hoofdstadfuncties", russian: "Каналы, музеи, столичные службы")
        case "Leiden":
            return LocalizedCityText(english: "University, canals, museums", dutch: "Universiteit, grachten, musea", russian: "Университет, каналы, музеи")
        case "Rotterdam":
            return LocalizedCityText(english: "Port, architecture, logistics", dutch: "Haven, architectuur, logistiek", russian: "Порт, архитектура, логистика")
        case "Den Haag":
            return LocalizedCityText(english: "Government, law, coast", dutch: "Bestuur, recht, kust", russian: "Правительство, право, побережье")
        case "Utrecht":
            return LocalizedCityText(english: "Rail hub, university, old centre", dutch: "Spoorknooppunt, universiteit, binnenstad", russian: "Железнодорожный узел, университет, старый центр")
        case "Eindhoven":
            return LocalizedCityText(english: "Technology, design, innovation", dutch: "Technologie, design, innovatie", russian: "Технологии, дизайн, инновации")
        case "Groningen":
            return LocalizedCityText(english: "University, cycling, northern services", dutch: "Universiteit, fietsen, noordelijke diensten", russian: "Университет, велосипеды, службы севера")
        case "Maastricht":
            return LocalizedCityText(english: "History, Maas, cross-border culture", dutch: "Historie, Maas, grenscultuur", russian: "История, Маас, приграничная культура")
        default:
            return LocalizedCityText(english: "Local services in \(provinceID)", dutch: "Lokale diensten in \(provinceID)", russian: "Местные службы в \(provinceID)")
        }
    }

    static func identityIconName(for name: String) -> String {
        identityIcon(for: name)
    }

    private static func identityIcon(for name: String) -> String {
        switch name {
        case "Amsterdam", "Leiden", "Maastricht": return "water.waves"
        case "Rotterdam": return "ferry.fill"
        case "Den Haag": return "building.columns.fill"
        case "Utrecht", "Groningen": return "graduationcap.fill"
        case "Eindhoven": return "cpu.fill"
        default: return "mappin.and.ellipse"
        }
    }

    private static func cityScorecard(name: String, population: String, area: String?, provinceID: String, transport: String?) -> [CityScorecardItem] {
        [
            CityScorecardItem(id: "population", icon: "person.3.fill", title: LocalizedCityText(english: "Population", dutch: "Bevolking", russian: "Население"), value: LocalizedCityText(english: population, dutch: population, russian: population), tint: AppColors.softBlue),
            CityScorecardItem(id: "province", icon: "map.fill", title: LocalizedCityText(english: "Province", dutch: "Provincie", russian: "Провинция"), value: provinceNameText(provinceID), tint: AppColors.accentLight),
            CityScorecardItem(id: "founded", icon: "clock.fill", title: LocalizedCityText(english: "Founded", dutch: "Ontstaan", russian: "Основан"), value: cityFoundedText(name: name), tint: AppColors.warning),
            CityScorecardItem(id: "area", icon: "square.grid.2x2.fill", title: LocalizedCityText(english: "Area", dutch: "Oppervlakte", russian: "Площадь"), value: LocalizedCityText(english: area ?? "Official source", dutch: area ?? "Officiële bron", russian: area ?? "Официальный источник"), tint: AppColors.violet),
            CityScorecardItem(id: "language", icon: "text.bubble.fill", title: LocalizedCityText(english: "Language", dutch: "Taal", russian: "Язык"), value: LocalizedCityText(english: "Dutch, English common", dutch: "Nederlands, vaak Engels", russian: "Нидерландский, часто английский"), tint: AppColors.emerald),
            CityScorecardItem(id: "university", icon: "graduationcap.fill", title: LocalizedCityText(english: "University presence", dutch: "Universiteit", russian: "Университетская среда"), value: universityPresence(name: name), tint: AppColors.cyanGlow),
            CityScorecardItem(id: "international", icon: "globe.europe.africa.fill", title: LocalizedCityText(english: "International friendliness", dutch: "Internationaal", russian: "Международность"), value: internationalFriendliness(name: name), tint: AppColors.dutchOrange),
            CityScorecardItem(id: "transport", icon: "tram.fill", title: LocalizedCityText(english: "Public transport score", dutch: "Ov-score", russian: "Общественный транспорт"), value: transportScore(name: name, transport: transport), tint: AppColors.routeLine)
        ]
    }

    private static func cityMoveReasons(name: String, provinceID: String) -> [LocalizedCityText] {
        switch name {
        case "Leiden":
            return [
                LocalizedCityText(english: "University city", dutch: "Universiteitsstad", russian: "Университетский город"),
                LocalizedCityText(english: "Strong expat community", dutch: "Sterke expatgemeenschap", russian: "Заметное международное сообщество"),
                LocalizedCityText(english: "Close to Amsterdam and Den Haag", dutch: "Dicht bij Amsterdam en Den Haag", russian: "Рядом с Амстердамом и Гаагой"),
                LocalizedCityText(english: "Historic centre", dutch: "Historische binnenstad", russian: "Исторический центр"),
                LocalizedCityText(english: "High quality of life", dutch: "Hoge leefkwaliteit", russian: "Высокое качество жизни")
            ]
        case "Amsterdam":
            return [
                LocalizedCityText(english: "International jobs and services", dutch: "Internationale banen en diensten", russian: "Международная работа и услуги"),
                LocalizedCityText(english: "Strong public transport", dutch: "Sterk openbaar vervoer", russian: "Сильный общественный транспорт"),
                LocalizedCityText(english: "Cultural life", dutch: "Cultureel leven", russian: "Культурная жизнь"),
                LocalizedCityText(english: "Neighbourhood variety", dutch: "Veel verschillende buurten", russian: "Разнообразие районов")
            ]
        case "Rotterdam":
            return [
                LocalizedCityText(english: "Port and logistics jobs", dutch: "Haven- en logistieke banen", russian: "Работа в порту и логистике"),
                LocalizedCityText(english: "Modern city energy", dutch: "Moderne stadsenergie", russian: "Современная городская энергия"),
                LocalizedCityText(english: "Good regional connections", dutch: "Goede regionale verbindingen", russian: "Хорошие региональные связи"),
                LocalizedCityText(english: "Diverse neighbourhoods", dutch: "Diverse wijken", russian: "Разнообразные районы")
            ]
        case "Den Haag":
            return [
                LocalizedCityText(english: "Government and international law", dutch: "Bestuur en internationaal recht", russian: "Правительство и международное право"),
                LocalizedCityText(english: "Coast nearby", dutch: "Kust dichtbij", russian: "Побережье рядом"),
                LocalizedCityText(english: "Strong tram network", dutch: "Sterk tramnetwerk", russian: "Развитая трамвайная сеть"),
                LocalizedCityText(english: "International institutions", dutch: "Internationale instellingen", russian: "Международные институты")
            ]
        case "Utrecht":
            return [
                LocalizedCityText(english: "Central location", dutch: "Centrale ligging", russian: "Центральное расположение"),
                LocalizedCityText(english: "Major rail hub", dutch: "Groot spoorknooppunt", russian: "Крупный железнодорожный узел"),
                LocalizedCityText(english: "University life", dutch: "Universiteitsleven", russian: "Университетская жизнь"),
                LocalizedCityText(english: "Compact historic centre", dutch: "Compacte historische binnenstad", russian: "Компактный исторический центр")
            ]
        case "Eindhoven":
            return [
                LocalizedCityText(english: "Technology jobs", dutch: "Technologische banen", russian: "Работа в технологиях"),
                LocalizedCityText(english: "Design and innovation", dutch: "Design en innovatie", russian: "Дизайн и инновации"),
                LocalizedCityText(english: "Regional education", dutch: "Regionaal onderwijs", russian: "Региональное образование"),
                LocalizedCityText(english: "North Brabant connections", dutch: "Verbindingen in Noord-Brabant", russian: "Связи по Северному Брабанту")
            ]
        case "Groningen":
            return [
                LocalizedCityText(english: "Student-friendly city", dutch: "Studentvriendelijke stad", russian: "Город, удобный для студентов"),
                LocalizedCityText(english: "Cycling culture", dutch: "Fietscultuur", russian: "Велосипедная культура"),
                LocalizedCityText(english: "Northern service hub", dutch: "Dienstencentrum van het noorden", russian: "Центр услуг севера"),
                LocalizedCityText(english: "Active cultural life", dutch: "Actief cultureel leven", russian: "Активная культурная жизнь")
            ]
        case "Maastricht":
            return [
                LocalizedCityText(english: "Historic centre", dutch: "Historische binnenstad", russian: "Исторический центр"),
                LocalizedCityText(english: "Cross-border life", dutch: "Leven rond de grens", russian: "Жизнь у границы"),
                LocalizedCityText(english: "University and healthcare", dutch: "Universiteit en zorg", russian: "Университет и медицина"),
                LocalizedCityText(english: "Culture and tourism", dutch: "Cultuur en toerisme", russian: "Культура и туризм")
            ]
        default:
            return [
                LocalizedCityText(english: "Local municipality services", dutch: "Lokale gemeentediensten", russian: "Местные муниципальные услуги"),
                LocalizedCityText(english: "Regional transport links", dutch: "Regionale vervoersverbindingen", russian: "Региональные транспортные связи"),
                LocalizedCityText(english: "Daily-life orientation", dutch: "Oriëntatie voor dagelijks leven", russian: "Ориентация для повседневной жизни")
            ]
        }
    }

    private static func cityCostItems(name: String) -> [CityCostItem] {
        let highRentCities = ["Amsterdam", "Utrecht", "Leiden", "Den Haag"]
        let mediumRentCities = ["Rotterdam", "Eindhoven", "Maastricht", "Groningen"]
        let rentLevel: CityCostLevel = highRentCities.contains(name) ? .high : (mediumRentCities.contains(name) ? .medium : .medium)
        let studentLevel: CityCostLevel = ["Leiden", "Groningen", "Eindhoven", "Maastricht", "Utrecht"].contains(name) ? .medium : .high
        return [
            CityCostItem(id: "rent", icon: "house.fill", title: LocalizedCityText(english: "Rent", dutch: "Huur", russian: "Аренда"), level: rentLevel),
            CityCostItem(id: "transport", icon: "tram.fill", title: LocalizedCityText(english: "Transport", dutch: "Vervoer", russian: "Транспорт"), level: .medium),
            CityCostItem(id: "food", icon: "cart.fill", title: LocalizedCityText(english: "Food", dutch: "Boodschappen", russian: "Еда"), level: .medium),
            CityCostItem(id: "student", icon: "graduationcap.fill", title: LocalizedCityText(english: "Student friendliness", dutch: "Studentvriendelijkheid", russian: "Удобство для студентов"), level: studentLevel)
        ]
    }

    private static func cityTimelineEvents(name: String, provinceID: String) -> [CityTimelineEvent] {
        switch name {
        case "Leiden":
            return [
                CityTimelineEvent(id: "1575", period: LocalizedCityText(english: "1575", dutch: "1575", russian: "1575"), title: LocalizedCityText(english: "Leiden University founded", dutch: "Universiteit Leiden opgericht", russian: "Основан Лейденский университет"), detail: LocalizedCityText(english: "Education and science became central to the city identity.", dutch: "Onderwijs en wetenschap werden belangrijk voor de stadsidentiteit.", russian: "Образование и наука стали центральной частью идентичности города.")),
                CityTimelineEvent(id: "1800s", period: LocalizedCityText(english: "1800s", dutch: "19e eeuw", russian: "XIX век"), title: LocalizedCityText(english: "Industrial growth", dutch: "Industriële groei", russian: "Промышленный рост"), detail: LocalizedCityText(english: "Printing, textile history, and city services shaped daily life.", dutch: "Drukwerk, textielgeschiedenis en stadsdiensten vormden het dagelijks leven.", russian: "Печать, текстильная история и городские службы влияли на повседневность.")),
                CityTimelineEvent(id: "modern", period: LocalizedCityText(english: "Modern era", dutch: "Moderne tijd", russian: "Современность"), title: LocalizedCityText(english: "Science and biotech hub", dutch: "Wetenschap en biotech", russian: "Наука и биотехнологии"), detail: LocalizedCityText(english: "The city remains linked to research, healthcare, and culture.", dutch: "De stad blijft verbonden met onderzoek, zorg en cultuur.", russian: "Город остаётся связанным с исследованиями, медициной и культурой."))
            ]
        default:
            return cityTimeline(name: name, provinceID: provinceID).enumerated().map { index, text in
                CityTimelineEvent(
                    id: "generic-\(index)",
                    period: index == 0 ? LocalizedCityText(english: "Origins", dutch: "Oorsprong", russian: "Истоки") : (index == 1 ? LocalizedCityText(english: "Growth", dutch: "Groei", russian: "Рост") : LocalizedCityText(english: "Today", dutch: "Vandaag", russian: "Сегодня")),
                    title: text,
                    detail: LocalizedCityText(english: "Use official local sources for exact dates and heritage details.", dutch: "Gebruik officiële lokale bronnen voor exacte data en erfgoeddetails.", russian: "Для точных дат и деталей наследия используйте официальные местные источники.")
                )
            }
        }
    }

    private static func cityNewcomerGuide(name: String, website: String?, transport: String?) -> [CityNewcomerGuideItem] {
        let municipalityURL = website.map { webURLString(for: $0) }
        let transportDetail = transport.map {
            LocalizedCityText(
                english: "Check \($0) and official route planners.",
                dutch: "Controleer \($0) en officiële routeplanners.",
                russian: "Проверьте \($0) и официальные планировщики маршрутов."
            )
        } ?? LocalizedCityText(
            english: "Check local route planners and operators.",
            dutch: "Controleer lokale routeplanners en vervoerders.",
            russian: "Проверьте местные планировщики маршрутов и операторов."
        )
        return [
            CityNewcomerGuideItem(id: "registration", icon: "person.badge.plus.fill", title: LocalizedCityText(english: "Registration", dutch: "Inschrijving", russian: "Регистрация"), detail: LocalizedCityText(english: "Start with the municipality appointment and address rules.", dutch: "Begin met de gemeenteafspraak en adresregels.", russian: "Запишитесь в муниципалитет и проверьте правила адреса."), urlString: municipalityURL),
            CityNewcomerGuideItem(id: "municipality", icon: "building.columns.fill", title: LocalizedCityText(english: "Municipality", dutch: "Gemeente", russian: "Муниципалитет"), detail: LocalizedCityText(english: "Use the official city website for current resident services.", dutch: "Gebruik de officiële stadswebsite voor actuele bewonersdiensten.", russian: "Проверьте запись и требования на официальном сайте города."), urlString: municipalityURL),
            CityNewcomerGuideItem(id: "transport", icon: "tram.fill", title: LocalizedCityText(english: "Public transport", dutch: "Openbaar vervoer", russian: "Общественный транспорт"), detail: transportDetail, urlString: nil),
            CityNewcomerGuideItem(id: "healthcare", icon: "cross.case.fill", title: LocalizedCityText(english: "Healthcare", dutch: "Zorg", russian: "Базовая медицина"), detail: LocalizedCityText(english: "Register with a huisarts and verify urgent care routes locally.", dutch: "Schrijf u in bij een huisarts en controleer spoedroutes lokaal.", russian: "Найдите huisarts и проверьте условия страховки по официальным источникам."), urlString: municipalityURL),
            CityNewcomerGuideItem(id: "language", icon: "text.book.closed.fill", title: LocalizedCityText(english: "Language schools", dutch: "Taalscholen", russian: "Языковые школы"), detail: LocalizedCityText(english: "Check municipal and library language support.", dutch: "Controleer taalondersteuning via gemeente en bibliotheek.", russian: "Проверьте языковую поддержку через муниципалитет и библиотеку."), urlString: municipalityURL),
            CityNewcomerGuideItem(id: "library", icon: "books.vertical.fill", title: LocalizedCityText(english: "Libraries", dutch: "Bibliotheken", russian: "Библиотеки"), detail: LocalizedCityText(english: "Libraries often provide language, computer, and civic help.", dutch: "Bibliotheken bieden vaak taal-, computer- en burgerhulp.", russian: "Библиотеки часто помогают с языком, компьютером и городскими вопросами."), urlString: municipalityURL)
        ]
    }

    private static func cityPersonalityTags(name: String) -> [LocalizedCityText] {
        let base: [LocalizedCityText] = [
            LocalizedCityText(english: "International", dutch: "Internationaal", russian: "Международный"),
            LocalizedCityText(english: "Family Friendly", dutch: "Gezinsvriendelijk", russian: "Для семьи")
        ]
        switch name {
        case "Leiden":
            return [LocalizedCityText(english: "Historic", dutch: "Historisch", russian: "Исторический"), LocalizedCityText(english: "Student Friendly", dutch: "Studentvriendelijk", russian: "Для студентов"), LocalizedCityText(english: "Quiet", dutch: "Rustig", russian: "Спокойный")] + base
        case "Amsterdam":
            return [LocalizedCityText(english: "Historic", dutch: "Historisch", russian: "Исторический"), LocalizedCityText(english: "Tourism", dutch: "Toerisme", russian: "Туризм"), LocalizedCityText(english: "Business", dutch: "Zakelijk", russian: "Бизнес")] + base
        case "Rotterdam":
            return [LocalizedCityText(english: "Business", dutch: "Zakelijk", russian: "Бизнес"), LocalizedCityText(english: "Technology", dutch: "Technologie", russian: "Технологии"), LocalizedCityText(english: "International", dutch: "Internationaal", russian: "Международный")]
        case "Den Haag":
            return [LocalizedCityText(english: "International", dutch: "Internationaal", russian: "Международный"), LocalizedCityText(english: "Business", dutch: "Zakelijk", russian: "Бизнес"), LocalizedCityText(english: "Nature", dutch: "Natuur", russian: "Природа")]
        case "Utrecht":
            return [LocalizedCityText(english: "Historic", dutch: "Historisch", russian: "Исторический"), LocalizedCityText(english: "Student Friendly", dutch: "Studentvriendelijk", russian: "Для студентов"), LocalizedCityText(english: "Business", dutch: "Zakelijk", russian: "Бизнес")] + base
        case "Eindhoven":
            return [LocalizedCityText(english: "Technology", dutch: "Technologie", russian: "Технологии"), LocalizedCityText(english: "Business", dutch: "Zakelijk", russian: "Бизнес"), LocalizedCityText(english: "International", dutch: "Internationaal", russian: "Международный")]
        case "Groningen":
            return [LocalizedCityText(english: "Student Friendly", dutch: "Studentvriendelijk", russian: "Для студентов"), LocalizedCityText(english: "Quiet", dutch: "Rustig", russian: "Спокойный"), LocalizedCityText(english: "Nature", dutch: "Natuur", russian: "Природа")] + base
        case "Maastricht":
            return [LocalizedCityText(english: "Historic", dutch: "Historisch", russian: "Исторический"), LocalizedCityText(english: "Tourism", dutch: "Toerisme", russian: "Туризм"), LocalizedCityText(english: "International", dutch: "Internationaal", russian: "Международный")]
        default:
            return base
        }
    }

    private static func cityLocalHighlightFacts(name: String, transport: String?) -> [CityLocalHighlightFact] {
        let district = cityFamousDistrict(name: name)
        return [
            CityLocalHighlightFact(id: "known", title: LocalizedCityText(english: "Best known for", dutch: "Vooral bekend om", russian: "Больше всего известен"), value: cityKnownFor(name: name, provinceID: ""), icon: "star.fill"),
            CityLocalHighlightFact(id: "district", title: LocalizedCityText(english: "Famous district", dutch: "Bekende wijk", russian: "Известный район"), value: district, icon: "mappin.circle.fill"),
            CityLocalHighlightFact(id: "building", title: LocalizedCityText(english: "Famous building", dutch: "Bekend gebouw", russian: "Известное здание"), value: cityFamousBuilding(name: name), icon: "building.2.fill"),
            CityLocalHighlightFact(id: "event", title: LocalizedCityText(english: "Famous event", dutch: "Bekend evenement", russian: "Известное событие"), value: cityFamousEvent(name: name), icon: "calendar")
        ]
    }

    private static func nearbyCities(name: String, provinceID: String) -> [String] {
        switch name {
        case "Leiden": return ["Den Haag", "Haarlem", "Amsterdam", "Delft"]
        case "Amsterdam": return ["Haarlem", "Amstelveen", "Utrecht", "Leiden"]
        case "Rotterdam": return ["Delft", "Den Haag", "Leiden", "Breda"]
        case "Den Haag": return ["Leiden", "Delft", "Rotterdam", "Amsterdam"]
        case "Utrecht": return ["Amersfoort", "Amsterdam", "Rotterdam", "Eindhoven"]
        case "Eindhoven": return ["Tilburg", "Breda", "'s-Hertogenbosch", "Maastricht"]
        case "Groningen": return ["Leeuwarden", "Assen", "Zwolle", "Amsterdam"]
        case "Maastricht": return ["Venlo", "Eindhoven", "Nijmegen", "Rotterdam"]
        default:
            return nearbyCityFallbacks(for: provinceID).filter { $0 != name }.prefix(4).map { $0 }
        }
    }

    private static func provinceNameText(_ provinceID: String) -> LocalizedCityText {
        switch provinceID {
        case "Noord-Holland":
            return LocalizedCityText(english: "North Holland", dutch: "Noord-Holland", russian: "Северная Голландия")
        case "Zuid-Holland":
            return LocalizedCityText(english: "South Holland", dutch: "Zuid-Holland", russian: "Южная Голландия")
        case "Utrecht":
            return LocalizedCityText(english: "Utrecht", dutch: "Utrecht", russian: "Утрехт")
        case "Gelderland":
            return LocalizedCityText(english: "Gelderland", dutch: "Gelderland", russian: "Гелдерланд")
        case "Noord-Brabant":
            return LocalizedCityText(english: "North Brabant", dutch: "Noord-Brabant", russian: "Северный Брабант")
        case "Limburg":
            return LocalizedCityText(english: "Limburg", dutch: "Limburg", russian: "Лимбург")
        case "Overijssel":
            return LocalizedCityText(english: "Overijssel", dutch: "Overijssel", russian: "Оверэйссел")
        case "Flevoland":
            return LocalizedCityText(english: "Flevoland", dutch: "Flevoland", russian: "Флеволанд")
        case "Groningen":
            return LocalizedCityText(english: "Groningen", dutch: "Groningen", russian: "Гронинген")
        case "Friesland":
            return LocalizedCityText(english: "Friesland", dutch: "Fryslân", russian: "Фрисландия")
        case "Drenthe":
            return LocalizedCityText(english: "Drenthe", dutch: "Drenthe", russian: "Дренте")
        case "Zeeland":
            return LocalizedCityText(english: "Zeeland", dutch: "Zeeland", russian: "Зеландия")
        default:
            return LocalizedCityText(english: provinceID, dutch: provinceID, russian: provinceID)
        }
    }

    private static func nearbyCityFallbacks(for provinceID: String) -> [String] {
        switch provinceID {
        case "Noord-Holland": return ["Amsterdam", "Haarlem", "Alkmaar", "Hoorn", "Zaanstad", "Amstelveen", "Purmerend"]
        case "Zuid-Holland": return ["Rotterdam", "Den Haag", "Leiden", "Delft"]
        case "Utrecht": return ["Utrecht", "Amersfoort"]
        case "Gelderland": return ["Arnhem", "Nijmegen"]
        case "Noord-Brabant": return ["Eindhoven", "Tilburg", "Breda", "'s-Hertogenbosch"]
        case "Limburg": return ["Maastricht", "Venlo"]
        case "Overijssel": return ["Zwolle"]
        case "Flevoland": return ["Almere", "Lelystad"]
        case "Groningen": return ["Groningen"]
        case "Friesland": return ["Leeuwarden"]
        case "Drenthe": return ["Assen"]
        case "Zeeland": return ["Middelburg"]
        default: return []
        }
    }

    private static func cityFoundedText(name: String) -> LocalizedCityText {
        switch name {
        case "Leiden": return LocalizedCityText(english: "City rights 1266", dutch: "Stadsrechten 1266", russian: "Городские права 1266")
        case "Amsterdam": return LocalizedCityText(english: "City rights c. 1306", dutch: "Stadsrechten ca. 1306", russian: "Городские права ок. 1306")
        case "Rotterdam": return LocalizedCityText(english: "City rights 1340", dutch: "Stadsrechten 1340", russian: "Городские права 1340")
        case "Den Haag": return LocalizedCityText(english: "Medieval court town", dutch: "Middeleeuwse hofstad", russian: "Средневековый придворный город")
        case "Utrecht": return LocalizedCityText(english: "Roman roots", dutch: "Romeinse oorsprong", russian: "Римские корни")
        case "Eindhoven": return LocalizedCityText(english: "City rights 1232", dutch: "Stadsrechten 1232", russian: "Городские права 1232")
        case "Groningen": return LocalizedCityText(english: "City rights 1040", dutch: "Stadsrechten 1040", russian: "Городские права 1040")
        case "Maastricht": return LocalizedCityText(english: "Roman roots", dutch: "Romeinse oorsprong", russian: "Римские корни")
        default: return LocalizedCityText(english: "Check city source", dutch: "Controleer stadsbron", russian: "Проверьте городской источник")
        }
    }

    private static func universityPresence(name: String) -> LocalizedCityText {
        switch name {
        case "Leiden", "Utrecht", "Groningen", "Maastricht":
            return LocalizedCityText(english: "High", dutch: "Hoog", russian: "Высокая")
        case "Eindhoven", "Amsterdam", "Rotterdam":
            return LocalizedCityText(english: "Strong", dutch: "Sterk", russian: "Сильная")
        default:
            return LocalizedCityText(english: "Local / regional", dutch: "Lokaal / regionaal", russian: "Местная / региональная")
        }
    }

    private static func internationalFriendliness(name: String) -> LocalizedCityText {
        switch name {
        case "Amsterdam", "Den Haag", "Rotterdam", "Eindhoven", "Maastricht":
            return LocalizedCityText(english: "High", dutch: "Hoog", russian: "Высокая")
        case "Leiden", "Utrecht", "Groningen":
            return LocalizedCityText(english: "Strong", dutch: "Sterk", russian: "Сильная")
        default:
            return LocalizedCityText(english: "Moderate", dutch: "Gemiddeld", russian: "Средняя")
        }
    }

    private static func transportScore(name: String, transport: String?) -> LocalizedCityText {
        switch name {
        case "Amsterdam", "Rotterdam", "Den Haag", "Utrecht":
            return LocalizedCityText(english: "High", dutch: "Hoog", russian: "Высокий")
        case "Leiden", "Eindhoven", "Groningen", "Maastricht":
            return LocalizedCityText(english: transport == nil ? "Medium" : "Good", dutch: transport == nil ? "Gemiddeld" : "Goed", russian: transport == nil ? "Средний" : "Хороший")
        default:
            return LocalizedCityText(english: "Check local routes", dutch: "Controleer routes", russian: "Проверьте маршруты")
        }
    }

    private static func cityFamousDistrict(name: String) -> LocalizedCityText {
        switch name {
        case "Amsterdam": return LocalizedCityText(english: "Canal Belt", dutch: "Grachtengordel", russian: "Пояс каналов")
        case "Leiden": return LocalizedCityText(english: "Old centre", dutch: "Oude binnenstad", russian: "Старый центр")
        case "Rotterdam": return LocalizedCityText(english: "Kop van Zuid", dutch: "Kop van Zuid", russian: "Коп ван Зёйд")
        case "Den Haag": return LocalizedCityText(english: "Scheveningen", dutch: "Scheveningen", russian: "Схевенинген")
        case "Utrecht": return LocalizedCityText(english: "Oudegracht", dutch: "Oudegracht", russian: "Аудеграхт")
        case "Eindhoven": return LocalizedCityText(english: "Strijp-S", dutch: "Strijp-S", russian: "Стрейп-S")
        case "Groningen": return LocalizedCityText(english: "City centre", dutch: "Binnenstad", russian: "Центр города")
        case "Maastricht": return LocalizedCityText(english: "Wyck", dutch: "Wyck", russian: "Вейк")
        default: return LocalizedCityText(english: "City centre", dutch: "Binnenstad", russian: "Центр города")
        }
    }

    private static func cityFamousBuilding(name: String) -> LocalizedCityText {
        switch name {
        case "Amsterdam": return LocalizedCityText(english: "Central Station", dutch: "Centraal Station", russian: "Центральный вокзал")
        case "Leiden": return LocalizedCityText(english: "Academy Building", dutch: "Academiegebouw", russian: "Здание академии")
        case "Rotterdam": return LocalizedCityText(english: "Erasmus Bridge", dutch: "Erasmusbrug", russian: "Мост Эразма")
        case "Den Haag": return LocalizedCityText(english: "Binnenhof", dutch: "Binnenhof", russian: "Бинненхоф")
        case "Utrecht": return LocalizedCityText(english: "Dom Tower", dutch: "Domtoren", russian: "Башня Дом")
        case "Eindhoven": return LocalizedCityText(english: "Evoluon", dutch: "Evoluon", russian: "Эволюон")
        case "Groningen": return LocalizedCityText(english: "Forum Groningen", dutch: "Forum Groningen", russian: "Форум Гронинген")
        case "Maastricht": return LocalizedCityText(english: "Basilica of Saint Servatius", dutch: "Sint-Servaasbasiliek", russian: "Базилика Святого Серватия")
        default: return LocalizedCityText(english: "City hall", dutch: "Stadhuis", russian: "Ратуша")
        }
    }

    private static func cityFamousEvent(name: String) -> LocalizedCityText {
        switch name {
        case "Amsterdam": return LocalizedCityText(english: "King's Day", dutch: "Koningsdag", russian: "День короля")
        case "Leiden": return LocalizedCityText(english: "Leidens Ontzet", dutch: "Leidens Ontzet", russian: "Лейденс Онтзет")
        case "Rotterdam": return LocalizedCityText(english: "Rotterdam Marathon", dutch: "Marathon Rotterdam", russian: "Роттердамский марафон")
        case "Den Haag": return LocalizedCityText(english: "Prinsjesdag", dutch: "Prinsjesdag", russian: "Принсесдах")
        case "Utrecht": return LocalizedCityText(english: "Cultural Sunday", dutch: "Culturele Zondag", russian: "Культурное воскресенье")
        case "Eindhoven": return LocalizedCityText(english: "Dutch Design Week", dutch: "Dutch Design Week", russian: "Dutch Design Week")
        case "Groningen": return LocalizedCityText(english: "Noorderzon", dutch: "Noorderzon", russian: "Noorderzon")
        case "Maastricht": return LocalizedCityText(english: "TEFAF Maastricht", dutch: "TEFAF Maastricht", russian: "TEFAF Maastricht")
        default: return LocalizedCityText(english: "Local events", dutch: "Lokale evenementen", russian: "Местные события")
        }
    }

    private static func citySourceLinks(name: String, website: String?, tourist: String?) -> [CitySourceLink] {
        var links: [CitySourceLink] = []
        if let website {
            links.append(
                CitySourceLink(
                    id: "municipality",
                    title: LocalizedCityText(english: "\(name) municipality", dutch: "Gemeente \(name)", russian: "Муниципалитет \(name)"),
                    urlString: webURLString(for: website),
                    icon: "globe"
                )
            )
        }
        if let tourist {
            links.append(
                CitySourceLink(
                    id: "visitor-info",
                    title: LocalizedCityText(english: "Visitor and culture information", dutch: "Bezoekers- en cultuurinformatie", russian: "Информация для посетителей и культурная информация"),
                    urlString: webURLString(for: tourist),
                    icon: "info.circle.fill"
                )
            )
        }
        links.append(
            CitySourceLink(
                id: "background",
                title: LocalizedCityText(english: "Background reference", dutch: "Achtergrondbron", russian: "Справочная информация"),
                urlString: "https://en.wikipedia.org/wiki/\(name.replacingOccurrences(of: " ", with: "_"))",
                icon: "book.closed.fill"
            )
        )
        return links
    }

    private static func citySearchKeywords(name: String, provinceID: String, municipality: String) -> [String] {
        [name, provinceID, municipality, "municipality", "gemeente", "population", "area", "history", "flag", "coat of arms"]
    }

    private static func webURLString(for host: String) -> String {
        if host.hasPrefix("http://") || host.hasPrefix("https://") {
            return host
        }
        if host.hasPrefix("www.") || host.components(separatedBy: ".").count > 2 {
            return "https://\(host)"
        }
        return "https://www.\(host)"
    }
}

// Backward-compatible alias for older call sites in this file's history.
typealias ProvinceCityItem = ProvinceItem

#if DEBUG && os(iOS)
private struct ProvincePreviewEnvironment<Content: View>: View {
    @StateObject private var languageManager: LanguageManager
    @StateObject private var appState = AppStateViewModel()
    @StateObject private var savedItemsStore = SavedItemsStore()
    @StateObject private var documentStore = DocumentStore()
    private let content: Content

    init(language: AppLanguage, @ViewBuilder content: () -> Content) {
        let manager = LanguageManager()
        manager.appLanguage = language
        _languageManager = StateObject(wrappedValue: manager)
        self.content = content()
    }

    var body: some View {
        NavigationStack {
            content
                .navigationDestination(for: AppDestination.self) { destination in
                    AppDestinationView(destination: destination)
                }
        }
        .environmentObject(languageManager)
        .environmentObject(appState)
        .environmentObject(savedItemsStore)
        .environmentObject(documentStore)
    }
}

#Preview("Provinces QA - RU iPhone SE", traits: .fixedLayout(width: 375, height: 667)) {
    ProvincePreviewEnvironment(language: .russian) {
        ProvinceDirectoryView()
    }
    .environment(\.dynamicTypeSize, .large)
    .transaction { $0.animation = nil }
}

#Preview("Province Detail QA - RU iPhone SE", traits: .fixedLayout(width: 375, height: 667)) {
    ProvincePreviewEnvironment(language: .russian) {
        ProvinceCityDetailView(provinceName: "Noord-Holland")
    }
    .environment(\.dynamicTypeSize, .large)
    .transaction { $0.animation = nil }
}

#Preview("City QA - RU iPhone SE", traits: .fixedLayout(width: 375, height: 667)) {
    ProvincePreviewEnvironment(language: .russian) {
        CityDetailView(provinceName: "Noord-Holland", cityName: "Amsterdam")
    }
    .environment(\.dynamicTypeSize, .large)
    .transaction { $0.animation = nil }
}

#Preview("City QA - Leiden RU iPhone 17 Pro", traits: .fixedLayout(width: 402, height: 874)) {
    ProvincePreviewEnvironment(language: .russian) {
        CityDetailView(provinceName: "Zuid-Holland", cityName: "Leiden")
    }
    .environment(\.dynamicTypeSize, .large)
    .transaction { $0.animation = nil }
}
#endif
