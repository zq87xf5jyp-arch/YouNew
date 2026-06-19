import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

private struct HomeLifeScenario: Identifiable {
    let id: String
    let titleRU: String
    let titleNL: String
    let titleEN: String
    let subtitleRU: String
    let subtitleNL: String
    let subtitleEN: String
    let asset: AppImageAsset?
    let accent: Color
    let destination: AppDestination

    func title(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return titleRU
        case .dutch: return titleNL
        case .english: return titleEN
        }
    }

    func subtitle(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return subtitleRU
        case .dutch: return subtitleNL
        case .english: return subtitleEN
        }
    }
}

private struct HomeCityMoment: Identifiable {
    let id: String
    let titleRU: String
    let titleNL: String
    let titleEN: String
    let subtitleRU: String
    let subtitleNL: String
    let subtitleEN: String
    let asset: AppImageAsset?
    let accent: Color
    let destination: AppDestination?

    func title(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return titleRU
        case .dutch: return titleNL
        case .english: return titleEN
        }
    }

    func subtitle(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return subtitleRU
        case .dutch: return subtitleNL
        case .english: return subtitleEN
        }
    }
}

private struct HomeHeroCity: Identifiable {
    let id: String
    let name: String
    let provinceRU: String
    let provinceNL: String
    let provinceEN: String
    let descriptionRU: String
    let descriptionNL: String
    let descriptionEN: String
    let statOneValue: String
    let statOneRU: String
    let statOneNL: String
    let statOneEN: String
    let statTwoValue: String
    let statTwoRU: String
    let statTwoNL: String
    let statTwoEN: String
    let statThreeValue: String
    let statThreeRU: String
    let statThreeNL: String
    let statThreeEN: String
    let symbol: String
    let asset: AppImageAsset?
    let destination: AppDestination

    func province(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return provinceRU
        case .dutch: return provinceNL
        case .english: return provinceEN
        }
    }

    func description(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return descriptionRU
        case .dutch: return descriptionNL
        case .english: return descriptionEN
        }
    }

    func statOneTitle(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return statOneRU
        case .dutch: return statOneNL
        case .english: return statOneEN
        }
    }

    func statTwoTitle(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return statTwoRU
        case .dutch: return statTwoNL
        case .english: return statTwoEN
        }
    }

    func statThreeTitle(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return statThreeRU
        case .dutch: return statThreeNL
        case .english: return statThreeEN
        }
    }
}

private struct HomeQuickAction: Identifiable {
    let id: String
    let titleRU: String
    let titleNL: String
    let titleEN: String
    let icon: String
    let accent: Color
    let destination: AppDestination

    func title(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return titleRU
        case .dutch: return titleNL
        case .english: return titleEN
        }
    }
}

private struct HomeHelpTopic: Identifiable {
    let id: String
    let titleEN: String
    let titleNL: String
    let titleRU: String
    let icon: String
    let tint: Color
    let destination: AppDestination

    func title(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return titleRU
        case .dutch: return titleNL
        case .english: return titleEN
        }
    }
}

private struct HomePersonaJourney: Identifiable {
    let id: String
    let titleEN: String
    let titleNL: String
    let titleRU: String
    let subtitleEN: String
    let subtitleNL: String
    let subtitleRU: String
    let icon: String
    let tint: Color
    let destination: AppDestination

    func title(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return titleRU
        case .dutch: return titleNL
        case .english: return titleEN
        }
    }

    func subtitle(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return subtitleRU
        case .dutch: return subtitleNL
        case .english: return subtitleEN
        }
    }
}

private struct HomeCategoryItem: Identifiable {
    let id: String
    let titleRU: String
    let titleNL: String
    let titleEN: String
    let icon: String
    let gradient: [Color]
    let destination: AppDestination

    func title(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return titleRU
        case .dutch: return titleNL
        case .english: return titleEN
        }
    }
}

private struct HomePersonaDashboard {
    let quickActions: [HomeQuickAction]
    let helpTopics: [HomeHelpTopic]
    let journeys: [HomePersonaJourney]
    let categories: [HomeCategoryItem]
}

private struct HistoryCultureItem: Identifiable {
    let id: String
    let titleRU: String
    let titleNL: String
    let titleEN: String
    let subtitleRU: String
    let subtitleNL: String
    let subtitleEN: String
    let icon: String
    let accent: Color
    let destination: AppDestination

    func title(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return titleRU
        case .dutch: return titleNL
        case .english: return titleEN
        }
    }

    func subtitle(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return subtitleRU
        case .dutch: return subtitleNL
        case .english: return subtitleEN
        }
    }
}

private struct HomeNewsItem: Identifiable {
    let id: String
    let titleRU: String
    let titleNL: String
    let titleEN: String
    let subtitleRU: String
    let subtitleNL: String
    let subtitleEN: String
    let icon: String
    let accent: Color

    func title(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return titleRU
        case .dutch: return titleNL
        case .english: return titleEN
        }
    }

    func subtitle(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return subtitleRU
        case .dutch: return subtitleNL
        case .english: return subtitleEN
        }
    }
}

struct HomeView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var router: TabRouter
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Binding var selectedTab: AppTab
    var onOpenMenu: () -> Void = {}

    @State private var heroVisible = true
    @State private var contentVisible = true
    @State private var mapGlowPhase: Double = 0.45
    @State private var featuredCities = NLCity.all
    @State private var currentIndex = 0

    private var lang: AppLanguage { languageManager.appLanguage }
    private var cityName: String { ProvinceCatalog.localizedCityName(appState.selectedCity, lang) }
    private var selectedHeroCity: NLCity {
        featuredCities[min(max(currentIndex, 0), max(featuredCities.count - 1, 0))]
    }
    private var selectedHeroCityAsset: AppImageAsset {
        cityImageAsset(selectedHeroCity)
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                HomeUnifiedVisualBackdrop(asset: selectedHeroCityAsset, accent: AppColors.cyanGlow)

                ScrollViewReader { scrollProxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            Color.clear
                                .frame(height: 0)
                                .id("homeTop")

                            welcomeHeroSection(viewportHeight: proxy.size.height)
                                .opacity(heroVisible ? 1 : 0)
                                .offset(y: heroVisible ? 0 : 24)
                                .animation(.spring(response: 0.54, dampingFraction: 0.82), value: heroVisible)

                            cityPillsSection

                            personaJourneySection

                            helpTopicsSection

                            if shouldShowPersonaActionSection {
                                categoriesGridSection
                                    .homeReadableBand()
                                    .padding(.bottom, 34)
                            }

                            featuredCitySection

                            netherlandsMapSection

                            quickActionsSection

                            if shouldShowHistoryAndCultureSection {
                                historyAndCultureSection
                            }

                            aiNavigatorCard

                            disclaimerFooter

                            Color.clear.frame(height: 1)
                        }
                        .opacity(contentVisible ? 1 : 0)
                        .offset(y: contentVisible ? 0 : 18)
                        .animation(.spring(response: 0.52, dampingFraction: 0.86).delay(0.10), value: contentVisible)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .scrollContentBackground(.hidden)
                    .scrollIndicators(.hidden)
                    .safeAreaInset(edge: .bottom) {
                        Color.clear.frame(height: homeBottomReserve)
                    }
                    .onReceive(router.homeScrollTop) { _ in
                        withAnimation(.easeInOut(duration: 0.24)) {
                            scrollProxy.scrollTo("homeTop", anchor: .top)
                        }
                    }
                }
            }
        }
        .coordinateSpace(name: "masterScroll")
        .appSceneBackground(.home)
        .nlNavigationBarHidden()
        .onAppear {
            heroVisible = true
            Task { @MainActor in
                do {
                    try await Task.sleep(for: .seconds(0.12))
                    contentVisible = true
                } catch is CancellationError {
                    return
                }
            }
        }
    }

    // MARK: - Home Story

    private func welcomeHeroSection(viewportHeight: CGFloat) -> some View {
        let heroHeight = dynamicTypeSize.isAccessibilitySize
            ? max(680, viewportHeight * 0.92)
            : max(620, viewportHeight * 0.90)

        return ZStack(alignment: .bottomLeading) {
            let resolvedImage = CanonicalPlaceImageResolver.resolveCityHero(city: selectedHeroCity)
            // Parallax image: lags behind scroll for depth perception.
            ParallaxHero {
                CityImageView(
                    urlString: resolvedImage.urlString,
                    height: heroHeight,
                    placeId: selectedHeroCity.placeId,
                    cityName: selectedHeroCity.name,
                    fallbackColor: Color(hex: selectedHeroCity.heroColor),
                    fallbackURLStrings: resolvedImage.fallbackURLStrings,
                    debugContext: resolvedImage.debugContext(
                        screen: "Home hero",
                        entityType: "city",
                        entityName: selectedHeroCity.name
                    )
                )
            }
            .frame(height: heroHeight)
            .clipped()

            // Seamless gradient: end color exactly matches AppSurface.base.
            AppSurface.heroGradient()

            LinearGradient(
                colors: [
                    Color.black.opacity(0.40),
                    Color.clear,
                    AppSurface.base.opacity(0.96)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            LinearGradient(
                colors: [
                    AppColors.cyanGlow.opacity(0.20),
                    Color.clear,
                    AppColors.dutchOrange.opacity(0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack {
                HStack {
                    YouNewLogoMark()
                        .frame(width: 38, height: 38)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("YouNew.nl")
                            .font(.system(size: 20, weight: .heavy, design: .default))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        Text(localizedText(en: "Premium Netherlands Guide", nl: "Premium gids voor Nederland", ru: "Премиальный гид по Нидерландам"))
                            .font(.system(size: 12, weight: .semibold, design: .default))
                            .foregroundStyle(Color.white.opacity(0.72))
                            .lineLimit(2)
                            .minimumScaleFactor(0.74)
                    }

                    Spacer()

                    Button(action: onOpenMenu) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.black.opacity(0.20))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.12), lineWidth: 0.7))
                    }
                    .buttonStyle(NLTileButtonStyle())
                    .accessibilityLabel(L10n.t("accessibility.openMenu", lang))
                }
                .padding(.horizontal, 22)
                .padding(.top, 18)

                Spacer()
            }

            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 6) {
                    ForEach(featuredCities.indices, id: \.self) { index in
                        Capsule()
                            .fill(index == currentIndex ? AppColors.dutchOrange : Color.white.opacity(0.32))
                            .frame(width: index == currentIndex ? 34 : 18, height: 4)
                            .animation(.easeInOut(duration: 0.22), value: currentIndex)
                    }
                }
                .padding(.bottom, 2)

                Text(selectedHeroCity.province)
                    .font(.system(size: 12, weight: .semibold, design: .default))
                    .foregroundStyle(AppColors.cyanGlow)
                    .textCase(.uppercase)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
                    .fixedSize(horizontal: false, vertical: true)

                Text(selectedHeroCity.name)
                    .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 50 : 44, weight: .semibold, design: .default))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.76)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 390, alignment: .leading)
                    .shadow(color: Color.black.opacity(0.34), radius: 12, x: 0, y: 5)

                if let kw = selectedHeroCity.keywords(lang: lang) {
                    Text(kw)
                        .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 17 : 13.5, weight: .semibold, design: .default))
                        .foregroundStyle(AppColors.cyanGlow.opacity(0.92))
                        .lineLimit(2)
                        .frame(maxWidth: 520, alignment: .leading)
                } else {
                    Text(selectedHeroCity.desc(short: true, lang: lang))
                        .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 18 : 14.5, weight: .regular, design: .default))
                        .foregroundStyle(Color.white.opacity(0.84))
                        .lineLimit(dynamicTypeSize.isAccessibilitySize ? 5 : 4)
                        .minimumScaleFactor(0.86)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: 520, alignment: .leading)
                }

                heroCityStats

                heroQuickIntelligence

                ViewThatFits(in: .horizontal) {
                    heroCityActionsHorizontal
                    heroCityActionsWrapped
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 22)
            .padding(.bottom, dynamicTypeSize.isAccessibilitySize ? 58 : 52)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, minHeight: heroHeight, alignment: .bottomLeading)
        .accessibilityIdentifier("home.hero.netherlands")
    }

    private var heroQuickIntelligence: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: 8)], spacing: 8) {
            NavigationLink(value: AppDestination.emergencyHub) {
                heroIntelligenceTile(icon: "phone.fill", title: "112", subtitle: localizedText(en: "Emergency", nl: "Noodgeval", ru: "Экстренно"), tint: AppColors.error)
            }
            .buttonStyle(NLTileButtonStyle())

            NavigationLink(value: AppDestination.practicalGuide(.municipalityRegistration)) {
                heroIntelligenceTile(icon: "building.columns.fill", title: localizedText(en: "Municipality", nl: "Gemeente", ru: "Муниципалитет"), subtitle: cityName, tint: AppColors.softBlue)
            }
            .buttonStyle(NLTileButtonStyle())

            heroIntelligenceTile(icon: "cloud.sun.fill", title: localizedText(en: "Weather", nl: "Weer", ru: "Погода"), subtitle: localizedText(en: "Check official forecast", nl: "Controleer officiële verwachting", ru: "Проверьте официальный прогноз"), tint: AppColors.warning)

            Button {
                openAssistantPrompt(nil)
            } label: {
                heroIntelligenceTile(icon: "sparkles", title: localizedText(en: "Ask AI", nl: "Vraag AI", ru: "Спросить AI"), subtitle: localizedText(en: "Personal navigator", nl: "Persoonlijke navigator", ru: "Личный навигатор"), tint: AppColors.violet)
            }
            .buttonStyle(NLTileButtonStyle())
        }
        .frame(maxWidth: 520)
    }

    private func heroIntelligenceTile(icon: String, title: String, subtitle: String, tint: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(tint)
                .frame(width: 30, height: 30)
                .background(tint.opacity(0.16))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
                Text(subtitle)
                    .font(.system(size: 9.5, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.62))
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
            }
            Spacer(minLength: 0)
        }
        .padding(9)
        .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
        .background(Color.black.opacity(0.28))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(tint.opacity(0.24), lineWidth: 0.8))
    }

    private var cityPillsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                ForEach(Array(featuredCities.enumerated()), id: \.element.id) { index, city in
                    Button {
                        #if canImport(UIKit)
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        #endif
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            currentIndex = index
                        }
                    } label: {
                        HStack(spacing: 6) {
                            CityOfficialFlagView(city: city, width: 18, height: 12, showLabel: false)
                            Text(city.name)
                                .font(.system(size: 13, weight: currentIndex == index ? .bold : .medium, design: .rounded))
                                .lineLimit(1)
                        }
                        .foregroundStyle(index == currentIndex ? .white : .white.opacity(0.50))
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(index == currentIndex ? Color(hex: "#F97316") : Color.white.opacity(0.08))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(index == currentIndex ? Color.clear : Color.white.opacity(0.08), lineWidth: 0.8)
                        )
                    }
                    .buttonStyle(.plain)
                    .pressable()
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, 18)
        }
        .background(.clear)
    }

    private var personaJourneySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .lastTextBaseline, spacing: 12) {
                    Text(personaJourneyTitle)
                        .font(.system(size: 20, weight: .semibold, design: .default))
                        .foregroundStyle(AppColors.textPrimary)
                    Spacer(minLength: 12)
                    Text(personaJourneySubtitle)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColors.textTertiary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(personaJourneyTitle)
                        .font(.system(size: 20, weight: .semibold, design: .default))
                        .foregroundStyle(AppColors.textPrimary)
                    Text(personaJourneySubtitle)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColors.textTertiary)
                        .lineLimit(2)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(personaJourneys) { journey in
                        NavigationLink(value: journey.destination) {
                            PersonaJourneyCard(journey: journey, language: lang)
                        }
                        .buttonStyle(NLTileButtonStyle())
                    }
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, 2)
            }
            .padding(.horizontal, -AppSpacing.screenHorizontal)
            .clipped()
        }
        .homeReadableBand()
        .padding(.top, 4)
        .padding(.bottom, 30)
    }

    private var heroCityStats: some View {
        HStack(spacing: 0) {
            ForEach(Array(selectedHeroCity.facts.prefix(3).enumerated()), id: \.element.id) { index, fact in
                heroCityStat(value: fact.localizedValue(lang), title: fact.label(lang))
                if index < selectedHeroCity.facts.prefix(3).count - 1 {
                    statDivider
                }
            }
        }
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.26))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(Color.white.opacity(0.10), lineWidth: 0.8))
        .frame(maxWidth: 440)
    }

    private var statDivider: some View {
        LinearGradient(
            colors: [.clear, AppSurface.b2, .clear],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(width: 0.5, height: 34)
    }

    private func heroCityStat(value: String, title: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .semibold, design: .default))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.55)
                .contentTransition(.numericText())
            Text(title)
                .font(.system(size: 9.5, weight: .semibold, design: .default))
                .foregroundStyle(Color.white.opacity(0.52))
                .textCase(.uppercase)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
    }

    private var heroCityActionsHorizontal: some View {
        HStack(spacing: 10) {
            NavigationLink(value: AppDestination.nlCityDetail(selectedHeroCity.id)) {
                Label(exploreCityTitle, systemImage: "arrow.right")
                    .font(.system(size: 14, weight: .semibold, design: .default))
                    .frame(maxWidth: .infinity, minHeight: 48)
            }
            .buttonStyle(HomePrimaryHeroButtonStyle())
            .contentShape(Rectangle())
            .accessibilityIdentifier("home.hero.exploreCity")
            .zIndex(2)

            Button {
                selectedTab = .favorites
            } label: {
                Image(systemName: "bookmark")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 48, height: 48)
            }
            .buttonStyle(HomeSecondaryIconButtonStyle())
        }
        .frame(maxWidth: 440)
    }

    private var heroCityActionsWrapped: some View {
        VStack(spacing: 10) {
            NavigationLink(value: AppDestination.nlCityDetail(selectedHeroCity.id)) {
                Label(exploreCityTitle, systemImage: "arrow.right")
                    .font(.system(size: 14, weight: .semibold, design: .default))
                    .frame(maxWidth: .infinity, minHeight: 48)
            }
            .buttonStyle(HomePrimaryHeroButtonStyle())
            .contentShape(Rectangle())
            .accessibilityIdentifier("home.hero.exploreCity")
            .zIndex(2)
        }
    }

    private var heroActionsHorizontal: some View {
        HStack(spacing: 5) {
            NavigationLink(value: AppDestination.provinceList) {
                HeroActionLabel(title: exploreNetherlandsTitle, symbol: "map.fill")
            }
            .buttonStyle(HomeHeroButtonStyle(tint: AppColors.cyanGlow))

            NavigationLink(value: AppDestination.checklistList) {
                HeroActionLabel(title: startJourneyTitle, symbol: "figure.walk")
            }
            .buttonStyle(HomeHeroButtonStyle(tint: AppColors.dutchOrange))

            Button {
                openAssistantPrompt(nil)
            } label: {
                HeroActionLabel(title: askAITitle, symbol: "sparkles")
            }
            .buttonStyle(HomeHeroButtonStyle(tint: AppColors.violet))
        }
    }

    private var heroActionsWrapped: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    NavigationLink(value: AppDestination.provinceList) {
                        HeroActionLabel(title: exploreNetherlandsTitle, symbol: "map.fill")
                    }
                    .buttonStyle(HomeHeroButtonStyle(tint: AppColors.cyanGlow))

                    NavigationLink(value: AppDestination.checklistList) {
                        HeroActionLabel(title: startJourneyTitle, symbol: "figure.walk")
                    }
                    .buttonStyle(HomeHeroButtonStyle(tint: AppColors.dutchOrange))

                    Button {
                        openAssistantPrompt(nil)
                    } label: {
                        HeroActionLabel(title: askAITitle, symbol: "sparkles")
                    }
                    .buttonStyle(HomeHeroButtonStyle(tint: AppColors.violet))

        }
    }

    private var helpTopicsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .lastTextBaseline) {
                    helpTopicsHeaderTitle
                    Spacer(minLength: 12)
                    helpTopicsViewAllLink
                }

                VStack(alignment: .leading, spacing: 8) {
                    helpTopicsHeaderTitle
                    helpTopicsViewAllLink
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(helpTopics) { topic in
                        NavigationLink(value: topic.destination) {
                            HelpTopicIcon(topic: topic, language: lang)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, 2)
            }
            .padding(.horizontal, -AppSpacing.screenHorizontal)
            .clipped()
        }
        .homeReadableBand()
        .padding(.top, 10)
        .padding(.bottom, 34)
        .background(.clear)
    }

    private var helpTopicsHeaderTitle: some View {
        Text(helpTopicsTitle)
            .font(.system(size: 20, weight: .semibold, design: .default))
            .foregroundStyle(AppColors.textPrimary)
            .lineLimit(2)
            .minimumScaleFactor(0.84)
            .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private var helpTopicsViewAllLink: some View {
        if shouldShowAllCategoriesLink {
            NavigationLink(value: AppDestination.categoriesHub) {
                Label(viewAllLabel, systemImage: "square.grid.2x2")
                    .font(.system(size: 13, weight: .semibold, design: .default))
                    .foregroundStyle(AppColors.dutchOrange)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
        }
    }

    private var featuredCitySection: some View {
        let city = selectedHeroCity
        let resolvedImage = CanonicalPlaceImageResolver.resolveCityHero(city: city)
        return NavigationLink(value: AppDestination.nlCityDetail(city.id)) {
            GeometryReader { proxy in
                ZStack(alignment: .bottomLeading) {
                    CityImageView(
                        urlString: resolvedImage.urlString,
                        height: dynamicTypeSize.isAccessibilitySize ? 620 : 540,
                        placeId: city.placeId,
                        cityName: city.name,
                        fallbackColor: Color(hex: city.heroColor),
                        fallbackURLStrings: resolvedImage.fallbackURLStrings,
                        debugContext: resolvedImage.debugContext(
                            screen: "Home featured city",
                            entityType: "city",
                            entityName: city.name
                        )
                    )

                    LinearGradient(
                        colors: [
                            AppColors.navyDeep.opacity(0.96),
                            AppColors.navyDeep.opacity(0.58),
                            Color.black.opacity(0.26),
                            AppColors.navyDeep.opacity(0.98)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    LinearGradient(
                        colors: [
                            AppColors.navyDeep.opacity(0.86),
                            Color.clear,
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )

                    LinearGradient(
                        colors: [
                            AppColors.cyanGlow.opacity(0.18),
                            Color.clear,
                            AppColors.dutchOrange.opacity(0.16)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    CityOfficialFlagView(city: city, width: 36, height: 24, showLabel: false)
                        .position(x: max(54, proxy.size.width - 42), y: 42)
                        .zIndex(2)

                    VStack(alignment: .leading, spacing: 14) {
                        Text(featuredCityEyebrow)
                            .font(.system(size: 13, weight: .semibold, design: .default))
                            .foregroundStyle(AppColors.cyanGlow)
                            .textCase(.uppercase)
                            .lineLimit(2)
                            .minimumScaleFactor(0.82)
                            .fixedSize(horizontal: false, vertical: true)

                        VStack(alignment: .leading, spacing: 7) {
                            Text(ProvinceCatalog.localizedCityName(city.name, lang))
                                .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 42 : 36, weight: .semibold, design: .default))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.64)
                                .allowsTightening(true)

                            Text(localizedProvinceName(city.province))
                                .font(.system(size: 16, weight: .medium, design: .default))
                                .foregroundStyle(Color.white.opacity(0.78))
                                .lineLimit(2)
                                .minimumScaleFactor(0.82)
                                .fixedSize(horizontal: false, vertical: true)

                            Text(city.desc(short: true, lang: lang))
                                .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 18 : 15.5, weight: .regular, design: .default))
                                .foregroundStyle(Color.white.opacity(0.92))
                                .lineLimit(dynamicTypeSize.isAccessibilitySize ? 6 : 3)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        featuredCityStats(for: city)

                        HStack(spacing: 8) {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .bold))
                            Text(exploreCityTitle)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#F97316"), Color(hex: "#AE1C28")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color(hex: "#F97316").opacity(0.45), radius: 14, y: 5)
                    }
                    .padding(dynamicTypeSize.isAccessibilitySize ? 20 : 18)
                    .frame(width: min(max(0, proxy.size.width - AppSpacing.screenHorizontal * 2), 560), alignment: .leading)
                    .background(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.58),
                                AppColors.navyDeep.opacity(0.42)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.bottom, dynamicTypeSize.isAccessibilitySize ? 34 : 28)
                }
            }
            .frame(maxWidth: .infinity, minHeight: dynamicTypeSize.isAccessibilitySize ? 620 : 540)
            .tiltCard()
        }
        .buttonStyle(NLTileButtonStyle())
        .pressable()
        .cardGlowingTopEdge(color: AppColors.softBlue, cornerRadius: 0)
    }

    private func featuredCityStats(for city: NLCity) -> some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(minimum: 0), spacing: 8),
                GridItem(.flexible(minimum: 0), spacing: 8),
                GridItem(.flexible(minimum: 0), spacing: 0)
            ],
            alignment: .leading,
            spacing: 8
        ) {
            featuredCityStatItems(for: city)
        }
        .padding(8)
        .background(Color.black.opacity(0.24))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    @ViewBuilder
    private func featuredCityStatItems(for city: NLCity) -> some View {
        ForEach(Array(city.facts.prefix(3)), id: \.id) { fact in
            FeaturedCityStatChip(title: fact.label(lang), value: fact.localizedValue(lang))
        }
    }

    private func localizedProvinceName(_ province: String) -> String {
        switch (province, lang) {
        case ("Noord-Holland", .russian): return "Северная Голландия"
        case ("Zuid-Holland", .russian): return "Южная Голландия"
        case ("Noord-Brabant", .russian): return "Северный Брабант"
        default: return province
        }
    }

    private var netherlandsMapSection: some View {
        ZStack(alignment: .topLeading) {
            AppSurface.base

            NetherlandsMapCanvas(glowPhase: mapGlowPhase, selectedCity: appState.selectedCity)
                .opacity(0.12)
                .padding(.horizontal, 18)
                .padding(.vertical, 34)
                .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(netherlandsMapTitle)
                        .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 31 : 26, weight: .semibold, design: .default))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(netherlandsMapSubtitle)
                        .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 18 : 15, weight: .regular, design: .default))
                        .foregroundStyle(Color.white.opacity(0.70))
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .homeReadableBand()

                HomeRealisticNetherlandsMapCard(
                    title: mapCardTitle,
                    subtitle: mapCardSubtitle,
                    openMapLabel: exploreMapLabel,
                    selectedCity: appState.selectedCity,
                    language: lang,
                    glowPhase: mapGlowPhase,
                    onOpenMap: { selectedTab = .map }
                )
                .homeReadableBand(horizontalPadding: 10)
            }
            .padding(.top, 42)
            .padding(.bottom, 38)
        }
        .accessibilityLabel(netherlandsMapTitle)
    }

    // MARK: - 1. Netherlands Map Card

    private var netherlandsMapCard: some View {
        Button { selectedTab = .map } label: {
            ZStack {
                LinearGradient(
                    colors: [
                        AppColors.navyDeep,
                        Color(red: 8/255, green: 28/255, blue: 58/255),
                        Color(red: 4/255, green: 14/255, blue: 34/255)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                NetherlandsMapCanvas(glowPhase: mapGlowPhase, selectedCity: appState.selectedCity)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(netherlandsMapTitle)
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .foregroundStyle(AppColors.cyanGlow)
                                .textCase(.uppercase)
                                .lineLimit(2)
                                .minimumScaleFactor(0.82)
                                .fixedSize(horizontal: false, vertical: true)
                            Text(netherlandsMapSubtitle)
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.white.opacity(0.54))
                                .lineLimit(3)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                        HStack(spacing: 6) {
                            Circle()
                                .fill(AppColors.dutchOrange)
                                .frame(width: 7, height: 7)
                                .shadow(color: AppColors.dutchOrange.opacity(0.8), radius: 4)
                            Text(cityName)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.78)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AppSurface.base.opacity(0.72))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.white.opacity(0.14), lineWidth: 0.7))
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 16)

                    Spacer()

                    HStack(spacing: 0) {
                        Spacer()
                        Label(exploreMapLabel, systemImage: "map.fill")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                            .minimumScaleFactor(0.82)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 9)
                            .background(
                                LinearGradient(
                                    colors: [AppColors.cyanGlow.opacity(0.88), AppColors.softBlue.opacity(0.72)],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                            .shadow(color: AppColors.cyanGlow.opacity(0.38), radius: 10, x: 0, y: 0)
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 18)
                }
            }
            .frame(height: dynamicTypeSize.isAccessibilitySize ? 310 : 260)
            .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 36, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [AppColors.cyanGlow.opacity(0.40), Color.white.opacity(0.12), AppColors.dutchOrange.opacity(0.18)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: AppColors.cyanGlow.opacity(0.18), radius: 28, x: 0, y: 14)
        }
        .buttonStyle(NLTileButtonStyle())
        .accessibilityLabel(netherlandsMapTitle)
    }

    // MARK: - 2. Welcome Greeting Card

    private var welcomeGreetingCard: some View {
        ZStack(alignment: .bottom) {
            HomeImageFill(asset: ContentMediaRegistry.officialSourcesHero, accent: AppColors.cyanGlow)
                .allowsHitTesting(false)

            LinearGradient(
                colors: [Color.black.opacity(0.02), AppColors.navyDeep.opacity(0.36), AppColors.navyDeep.opacity(0.97)],
                startPoint: .top, endPoint: .bottom
            )
            .allowsHitTesting(false)

            DutchFlagRibbon(opacity: 0.22)
                .blendMode(.screen)
                .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 0) {
                // App identity badge at top
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(heroAppName)
                            .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 14 : 11, weight: .black, design: .rounded))
                            .foregroundStyle(AppColors.cyanGlow)
                            .textCase(.uppercase)
                            .lineLimit(2)
                            .minimumScaleFactor(0.82)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(heroAppTagline)
                            .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 16 : 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.72))
                            .lineLimit(2)
                            .minimumScaleFactor(0.84)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 8)
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(currentTime)
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        Text(fullDate)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.60))
                            .lineLimit(2)
                            .minimumScaleFactor(0.78)
                            .multilineTextAlignment(.trailing)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                Spacer()

                // City info + actions at bottom
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(cityName)
                            .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 36 : 40, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.66)

                        HStack(spacing: 6) {
                            Circle()
                                .fill(AppColors.cyanGlow)
                                .frame(width: 6, height: 6)
                            Text(provinceName)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(AppColors.cyanGlow)
                                .lineLimit(1)
                                .minimumScaleFactor(0.78)
                        }

                        Text(cityDescription)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.72))
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: 8) {
                            welcomeHeroActions
                        }

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            welcomeHeroActions
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .frame(height: dynamicTypeSize.isAccessibilitySize ? 360 : 310)
        .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .stroke(LinearGradient(colors: [Color.white.opacity(0.28), AppColors.cyanGlow.opacity(0.18), Color.white.opacity(0.06)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 0.9)
        )
        .shadow(color: AppColors.navyDeep.opacity(0.54), radius: 32, x: 0, y: 18)
        .accessibilityIdentifier("home.welcome.greeting.card")
    }

    private var heroAppName: String {
        switch lang {
        case .russian: return "Добро пожаловать в YouNew"
        case .dutch: return "Welkom bij YouNew"
        case .english: return "Welcome to YouNew"
        }
    }

    private var heroAppTagline: String {
        switch lang {
        case .russian: return "Ваш гид по жизни в Нидерландах."
        case .dutch: return "Uw gids voor het leven in Nederland."
        case .english: return "Your guide to life in the Netherlands."
        }
    }

    private var exploreNetherlandsTitle: String {
        switch lang {
        case .russian: return "Открыть Нидерланды"
        case .dutch: return "Verken Nederland"
        case .english: return "Explore Netherlands"
        }
    }

    private var askAITitle: String {
        switch lang {
        case .russian: return "Спросить AI"
        case .dutch: return "Vraag AI"
        case .english: return "Ask AI"
        }
    }

    private var helpTopicsTitle: String {
        switch lang {
        case .russian: return "С чем поможет YouNew?"
        case .dutch: return "Waarmee helpt YouNew?"
        case .english: return "What can YouNew help with?"
        }
    }

    private var personaJourneyTitle: String {
        switch lang {
        case .russian: return "Начните с вашей ситуации"
        case .dutch: return "Start met uw situatie"
        case .english: return "Start by situation"
        }
    }

    private var personaJourneySubtitle: String {
        switch lang {
        case .russian: return "Нужный маршрут за 1 нажатие"
        case .dutch: return "De juiste route in 1 tik"
        case .english: return "The right path in 1 tap"
        }
    }

    private var featuredCityEyebrow: String {
        switch lang {
        case .russian: return "Город недели"
        case .dutch: return "Uitgelichte stad"
        case .english: return "Featured City"
        }
    }

    private var featuredCityDescription: String {
        switch lang {
        case .russian: return "Исторический университетский город с каналами, музеями и студенческой жизнью."
        case .dutch: return "Historische universiteitsstad met grachten, musea en studentenleven."
        case .english: return "Historic university city with canals, museums and student life."
        }
    }

    @ViewBuilder
    private var welcomeHeroActions: some View {
        NavigationLink(value: AppDestination.provinceList) {
            HeroActionLabel(title: exploreNetherlandsTitle, symbol: "map.fill")
        }
        .buttonStyle(HomeHeroButtonStyle(tint: AppColors.cyanGlow))

        NavigationLink(value: AppDestination.cityDetail(province: provinceName, city: appState.selectedCity)) {
            HeroActionLabel(title: exploreCityTitle, symbol: "building.2.fill")
        }
        .buttonStyle(HomeHeroButtonStyle(tint: AppColors.softBlue))

        NavigationLink(value: AppDestination.checklistList) {
            HeroActionLabel(title: startJourneyTitle, symbol: "figure.walk")
        }
        .buttonStyle(HomeHeroButtonStyle(tint: AppColors.dutchOrange))
    }

    private func localizedText(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .russian: return ru
        case .dutch: return nl
        case .english: return en
        }
    }

    // MARK: - 3. Quick Actions

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            NLSectionHeader(title: quickActionsTitle)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(minimum: 0), spacing: 10),
                    GridItem(.flexible(minimum: 0), spacing: 10)
                ],
                spacing: 10
            ) {
                ForEach(quickActions, id: \.id) { action in
                    NavigationLink(value: action.destination) {
                        QuickActionChip(action: action, language: lang)
                    }
                    .buttonStyle(NLTileButtonStyle())
                }
            }
            .sectionPadding()
        }
    }

    // MARK: - 5. Categories Grid

    private var categoriesGridSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .lastTextBaseline, spacing: 12) {
                    Text(categoriesTitle)
                        .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 31 : 28, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.86)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 12)

                    if shouldShowAllCategoriesLink {
                        NavigationLink(value: AppDestination.categoriesHub) {
                            Label(viewAllLabel, systemImage: "chevron.right")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.82)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(AppColors.softBlue.opacity(0.28))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Color.white.opacity(0.14), lineWidth: 0.8))
                        }
                        .buttonStyle(NLTileButtonStyle())
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text(categoriesTitle)
                        .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 31 : 28, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.86)
                        .fixedSize(horizontal: false, vertical: true)

                    if shouldShowAllCategoriesLink {
                        NavigationLink(value: AppDestination.categoriesHub) {
                            Label(viewAllLabel, systemImage: "chevron.right")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.82)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(AppColors.softBlue.opacity(0.28))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Color.white.opacity(0.14), lineWidth: 0.8))
                        }
                        .buttonStyle(NLTileButtonStyle())
                    }
                }
            }

            if !homeCategories.isEmpty {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(minimum: 0), spacing: 12),
                        GridItem(.flexible(minimum: 0), spacing: 12)
                    ],
                    spacing: 12
                ) {
                    ForEach(homeCategories.prefix(6), id: \.id) { cat in
                        NavigationLink(value: cat.destination) {
                            HomeCategoryCard(category: cat, language: lang)
                        }
                        .buttonStyle(NLTileButtonStyle())
                    }
                }
            }

            VStack(spacing: 12) {
                ForEach(lifeScenarios.prefix(3)) { scenario in
                    NavigationLink(value: scenario.destination) {
                        LifeScenarioCard(scenario: scenario, language: lang)
                    }
                    .buttonStyle(NLTileButtonStyle())
                    .accessibilityLabel("\(scenario.title(lang)). \(scenario.subtitle(lang))")
                }
            }
        }
    }

    // MARK: - 6. History & Culture

    private var historyAndCultureSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(historyAndCultureTitle)
                .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 31 : 26, weight: .semibold, design: .default))
                .foregroundStyle(.white)
                .lineLimit(3)
                .minimumScaleFactor(0.86)
                .fixedSize(horizontal: false, vertical: true)
                .sectionPadding()

            GeometryReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 10) {
                        NavigationLink(value: AppDestination.netherlandsHistory) {
                            CultureImageBlock(
                                title: localizedText(en: "History", nl: "Geschiedenis", ru: "История"),
                                subtitle: localizedText(en: "Water, trade, cities, and the Dutch state.", nl: "Water, handel, steden en de Nederlandse staat.", ru: "Вода, торговля, города и государство."),
                                asset: ContentMediaRegistry.canalHousesHero,
                                tint: AppColors.dutchOrange,
                                width: cultureCardWidth(for: proxy.size.width)
                            )
                        }
                        .buttonStyle(NLTileButtonStyle())

                        NavigationLink(value: AppDestination.cultureAttractions) {
                            CultureImageBlock(
                                title: localizedText(en: "Culture", nl: "Cultuur", ru: "Культура"),
                                subtitle: localizedText(en: "Traditions, daily habits, museums, and local life.", nl: "Tradities, dagelijkse gewoontes, musea en lokaal leven.", ru: "Традиции, привычки, музеи и местная жизнь."),
                                asset: ContentMediaRegistry.cultureHero,
                                tint: AppColors.softBlue,
                                width: cultureCardWidth(for: proxy.size.width)
                            )
                        }
                        .buttonStyle(NLTileButtonStyle())

                        NavigationLink(value: AppDestination.cityList) {
                            CultureImageBlock(
                                title: localizedText(en: "Places to Visit", nl: "Plaatsen om te bezoeken", ru: "Места для посещения"),
                                subtitle: localizedText(en: "Canals, windmills, tulip fields, and historic cities.", nl: "Grachten, molens, tulpenvelden en historische steden.", ru: "Каналы, мельницы, тюльпаны и исторические города."),
                                asset: ContentMediaRegistry.cultureWindmillHero,
                                tint: AppColors.emerald,
                                width: cultureCardWidth(for: proxy.size.width)
                            )
                        }
                        .buttonStyle(NLTileButtonStyle())
                    }
                    .padding(.leading, AppSpacing.screenHorizontal)
                    .padding(.trailing, max(AppSpacing.screenHorizontal, 24))
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
            }
            .frame(height: dynamicTypeSize.isAccessibilitySize ? 360 : 300)
            .clipped()
        }
        .padding(.top, 42)
        .padding(.bottom, 40)
        .background(.clear)
    }

    private func cultureCardWidth(for availableWidth: CGFloat) -> CGFloat {
        min(420, max(310, availableWidth * 0.92))
    }

    // MARK: - 7. Nearby Attractions

    private var nearbyAttractionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            NLSectionHeader(title: nearbyAttractionsTitle)

            GeometryReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(cityMoments) { moment in
                            if let destination = moment.destination {
                                NavigationLink(value: destination) {
                                    CityMomentCard(moment: moment, language: lang, width: max(0, proxy.size.width - 4))
                                }
                                .buttonStyle(NLTileButtonStyle())
                            } else {
                                CityMomentCard(moment: moment, language: lang, width: max(0, proxy.size.width - 4))
                            }
                        }
                    }
                    .padding(.horizontal, 2)
                    .padding(.vertical, 2)
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
            }
            .frame(height: dynamicTypeSize.isAccessibilitySize ? 292 : 226)
            .clipped()
        }
    }

    // MARK: - 8. News & Updates

    private var newsUpdatesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            NLSectionHeader(title: newsUpdatesTitle)

            VStack(spacing: 10) {
                ForEach(newsItems, id: \.id) { item in
                    NewsItemRow(item: item, language: lang)
                }
            }
        }
    }

    // MARK: - 9. Reviews & Feedback

    private var reviewsFeedbackSection: some View {
        NavigationLink(value: AppDestination.supportFeedback) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 14) {
                    ZStack {
                        LinearGradient(
                            colors: [AppColors.dutchOrange, AppColors.dutchOrange.opacity(0.72)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                        Image(systemName: "star.bubble.fill")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 52, height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(reviewsFeedbackTitle)
                            .font(.system(size: 17, weight: .black, design: .rounded))
                            .foregroundStyle(AppColors.textPrimary)
                        Text(reviewsFeedbackSubtitle)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppColors.textSecondary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(AppColors.textTertiary)
                }

                Text(feedbackStorageNotice)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(20)
            .background(GlassPanelBackground(accent: AppColors.dutchOrange, cornerRadius: 28))
        }
        .buttonStyle(NLTileButtonStyle())
    }

    private var aiNavigatorCard: some View {
        Button {
            openAssistantPrompt(nil)
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 17, weight: .black))
                        .foregroundStyle(AppColors.cyanGlow)
                        .frame(width: 38, height: 38)
                        .background(AppColors.cyanGlow.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    VStack(alignment: .leading, spacing: 3) {
                        Text(aiNavigatorTitle)
                            .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 20 : 17, weight: .semibold, design: .default))
                            .foregroundStyle(AppColors.textPrimary)
                            .lineLimit(3)
                            .minimumScaleFactor(0.86)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(aiNavigatorSubtitle)
                            .font(.system(size: 13, weight: .regular, design: .default))
                            .foregroundStyle(AppColors.textSecondary)
                            .lineLimit(3)
                            .minimumScaleFactor(0.88)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AppColors.textTertiary)
                }

                aiQuestionChips
            }
            .homeReadableBand()
            .padding(.vertical, 30)
            .background(
                LinearGradient(
                    colors: [
                        AppSurface.base,
                        AppColors.violet.opacity(0.16),
                        AppSurface.base
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        .buttonStyle(NLTileButtonStyle())
        .cardGlowingTopEdge(color: AppColors.cyanGlow, cornerRadius: 0)
        .accessibilityIdentifier("home.ai.navigator.card")
    }

    private var aiQuestionChips: some View {
        ViewThatFits(in: .vertical) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 126), spacing: 8)], alignment: .leading, spacing: 8) {
                ForEach(aiQuestionExamples.prefix(4), id: \.self) { question in
                    aiQuestionChip(question)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 8) {
                    ForEach(aiQuestionExamples.prefix(4), id: \.self) { question in
                        aiQuestionChip(question)
                            .frame(width: 184)
                    }
                }
                .padding(.trailing, max(AppSpacing.screenHorizontal, 24))
            }
        }
    }

    private func aiQuestionChip(_ question: String) -> some View {
        Text(question)
            .font(.system(size: 11, weight: .semibold, design: .default))
            .foregroundStyle(AppColors.textSecondary)
            .lineLimit(3)
            .minimumScaleFactor(0.84)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity, minHeight: AppIcons.Metrics.minimumTouchTarget, alignment: .leading)
            .background(Color.white.opacity(0.055))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    // MARK: - Dutch Phrase of the Day

    private var dutchPhraseCard: some View {
        let dayIndex = (Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1) - 1
        let phrase = dutchDailyPhrases[dayIndex % dutchDailyPhrases.count]
        return HStack(spacing: 16) {
            ZStack {
                LinearGradient(
                    colors: [AppColors.dutchOrange, AppColors.dutchOrange.opacity(0.72)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                Text("🇳🇱")
                    .font(.system(size: 22))
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: AppColors.dutchOrange.opacity(0.32), radius: 10, x: 0, y: 4)

            VStack(alignment: .leading, spacing: 4) {
                Text(dutchPhraseOfDayTitle)
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(AppColors.dutchOrange)
                    .textCase(.uppercase)
                    .tracking(1.0)
                TypewriterText(fullText: phrase.dutch, speed: 0.05)
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.84)
                    .fixedSize(horizontal: false, vertical: true)
                Text(phrase.translation(lang))
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.84)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(AppColors.textTertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(GlassPanelBackground(accent: AppColors.dutchOrange, cornerRadius: 22))
        .accessibilityIdentifier("home.dutch.phrase.card")
    }

    private struct DutchDailyPhrase {
        let dutch: String
        let ru: String
        let en: String
        let nl: String

        func translation(_ lang: AppLanguage) -> String {
            switch lang {
            case .russian: return ru
            case .english: return en
            case .dutch:   return nl
            }
        }
    }

    private var dutchDailyPhrases: [DutchDailyPhrase] {
        [
            DutchDailyPhrase(dutch: "Goedemorgen!", ru: "Доброе утро!", en: "Good morning!", nl: "Goedemorgen!"),
            DutchDailyPhrase(dutch: "Hoe gaat het?", ru: "Как дела?", en: "How are you?", nl: "Hoe gaat het?"),
            DutchDailyPhrase(dutch: "Dank je wel!", ru: "Большое спасибо!", en: "Thank you very much!", nl: "Dank je wel!"),
            DutchDailyPhrase(dutch: "Tot ziens!", ru: "До свидания!", en: "Goodbye!", nl: "Tot ziens!"),
            DutchDailyPhrase(dutch: "Mag ik u helpen?", ru: "Могу ли я вам помочь?", en: "Can I help you?", nl: "Mag ik u helpen?"),
            DutchDailyPhrase(dutch: "Waar is het station?", ru: "Где находится вокзал?", en: "Where is the station?", nl: "Waar is het station?"),
            DutchDailyPhrase(dutch: "Ik woon in Nederland.", ru: "Я живу в Нидерландах.", en: "I live in the Netherlands.", nl: "Ik woon in Nederland."),
            DutchDailyPhrase(dutch: "Spreekt u Engels?", ru: "Вы говорите по-английски?", en: "Do you speak English?", nl: "Spreekt u Engels?"),
            DutchDailyPhrase(dutch: "Alsjeblieft!", ru: "Пожалуйста!", en: "Please / Here you go!", nl: "Alsjeblieft!"),
            DutchDailyPhrase(dutch: "Ik begrijp het niet.", ru: "Я не понимаю.", en: "I don't understand.", nl: "Ik begrijp het niet."),
            DutchDailyPhrase(dutch: "Welkom in Nederland!", ru: "Добро пожаловать в Нидерланды!", en: "Welcome to the Netherlands!", nl: "Welkom in Nederland!"),
            DutchDailyPhrase(dutch: "Gezellig!", ru: "Уютно и хорошо!", en: "Cozy / Convivial!", nl: "Gezellig!"),
            DutchDailyPhrase(dutch: "Fijne dag!", ru: "Хорошего дня!", en: "Have a nice day!", nl: "Fijne dag!"),
            DutchDailyPhrase(dutch: "Ik ben nieuwkomer.", ru: "Я новоприбывший.", en: "I am a newcomer.", nl: "Ik ben nieuwkomer."),
        ]
    }

    private var dutchPhraseOfDayTitle: String {
        switch lang {
        case .russian: return "Фраза дня"
        case .dutch: return "Zin van de dag"
        case .english: return "Phrase of the Day"
        }
    }

    private var progressSection: some View {
        NavigationLink(value: AppDestination.checklistList) {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(myProgressTitle)
                        .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 34 : 30, weight: .black, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.76)
                    Text(nextStepText)
                        .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 19 : 16, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                ProgressView(value: homeChecklistProgress)
                    .tint(AppColors.cyanGlow)

                journeyMilestones

                HStack {
                    Text(completedStepsText)
                        .font(.system(.subheadline, design: .rounded).weight(.bold))
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(3)
                        .minimumScaleFactor(0.82)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 10)
                    Text("\(completedChecklistCount) / \(totalChecklistCount)")
                        .font(.system(.headline, design: .rounded).weight(.black))
                        .foregroundStyle(AppColors.cyanGlow)
                }
            }
            .padding(22)
            .background(GlassPanelBackground(accent: AppColors.cyanGlow, cornerRadius: 34))
        }
        .buttonStyle(NLTileButtonStyle())
    }

    private var journeyMilestones: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                ForEach(Array(journeyMilestoneTitles.enumerated()), id: \.offset) { index, title in
                    let isComplete = index < completedJourneyMilestones
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(isComplete ? AppColors.cyanGlow.opacity(0.92) : Color.white.opacity(0.08))
                                .frame(width: 34, height: 34)
                            Image(systemName: isComplete ? "checkmark" : "\(index + 1)")
                                .font(.system(size: 12, weight: .black, design: .rounded))
                                .foregroundStyle(isComplete ? AppColors.navyDeep : AppColors.textSecondary)
                        }

                        Text(title)
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundStyle(isComplete ? AppColors.textPrimary : AppColors.textTertiary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.78)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(width: dynamicTypeSize.isAccessibilitySize ? 84 : 72, alignment: .top)
                }
            }
            .padding(.vertical, 2)
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
    }

    private var homeSectionSpacing: CGFloat {
        dynamicTypeSize.isAccessibilitySize ? 64 : 54
    }

    private var heroCardHeight: CGFloat {
        dynamicTypeSize.isAccessibilitySize ? 470 : 390
    }

    private var homeBottomReserve: CGFloat {
        dynamicTypeSize.isAccessibilitySize ? AppSpacing.tabBarScrollReserveLarge : AppSpacing.tabBarScrollReserve
    }

    private var shouldShowPersonaActionSection: Bool {
        !homeCategories.isEmpty || !lifeScenarios.isEmpty
    }

    private var shouldShowAllCategoriesLink: Bool {
        appState.selectedUserStatus == nil
    }

    private var shouldShowHistoryAndCultureSection: Bool {
        switch appState.selectedUserStatus?.personaTag {
        case .tourist, .eu, .universal, nil:
            return true
        case .student, .worker, .refugee, .family, .entrepreneur, .lgbt, .nonEU, .highlySkilledMigrant:
            return false
        }
    }

    private func homeContentWidth(for viewportWidth: CGFloat) -> CGFloat {
        max(0, min(viewportWidth, 760))
    }

    private func homeInnerContentWidth(for viewportWidth: CGFloat) -> CGFloat {
        max(0, homeContentWidth(for: viewportWidth) - AppSpacing.screenHorizontal * 2)
    }

    private var disclaimerFooter: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppColors.success)
            Text(disclaimerText)
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .homeReadableBand()
        .padding(.top, 8)
        .padding(.bottom, 18)
        .background(.clear)
    }

    private var lifeScenarios: [HomeLifeScenario] {
        switch appState.selectedUserStatus?.personaTag {
        case .student:
            return [
                scenario(id: "universities", title: "Universities", subtitle: "MBO, HBO, research universities", asset: "premium_home_language", accent: AppColors.emerald, destination: .institutionsList),
                scenario(id: "student-housing", title: "Student Housing", subtitle: "Rooms, contracts, registration", asset: "premium_home_housing", accent: AppColors.violet, destination: .practicalGuide(.housingBasics)),
                scenario(id: "duo", title: "DUO", subtitle: "Finance, insurance, transport", asset: "premium_home_documents", accent: AppColors.softBlue, destination: .officialSources)
            ]
        case .worker, .highlySkilledMigrant:
            return [
                scenario(id: "work-contracts", title: "Work Contracts", subtitle: "Salary, rights, conditions", asset: "premium_home_work", accent: AppColors.violet, destination: .institutionsList),
                scenario(id: "bsn-digid", title: "BSN and DigiD", subtitle: "Registration and identity", asset: "premium_home_documents", accent: AppColors.cyanGlow, destination: .checklistList),
                scenario(id: "taxes", title: "Taxes", subtitle: "Official worker basics", asset: "premium_home_documents", accent: AppColors.emerald, destination: .officialSources)
            ]
        case .refugee:
            return [
                scenario(id: "ind", title: "IND", subtitle: "Status, documents, permissions", asset: "premium_home_documents", accent: AppColors.softBlue, destination: .governmentHub),
                scenario(id: "municipality", title: "Municipality", subtitle: "Housing, benefits, local support", asset: "home_documents_city_hall", accent: AppColors.cyanGlow, destination: .governmentHub),
                scenario(id: "integration", title: "Integration", subtitle: "Language, healthcare, education access", asset: "premium_home_language", accent: AppColors.emerald, destination: .languageHub)
            ]
        case .family:
            return [
                scenario(id: "schools", title: "Schools", subtitle: "Education for children", asset: "premium_home_language", accent: AppColors.emerald, destination: .institutionsList),
                scenario(id: "childcare", title: "Childcare", subtitle: "Kinderopvang and SVB", asset: "premium_home_housing", accent: AppColors.softBlue, destination: .officialSources),
                scenario(id: "family-healthcare", title: "Healthcare", subtitle: "Family care and activities", asset: "premium_home_healthcare", accent: AppColors.dutchOrange, destination: .practicalGuide(.healthcareBasics))
            ]
        case .tourist:
            return [
                scenario(id: "stay-rules", title: "Stay Rules", subtitle: "Short stay and documents", asset: "premium_home_documents", accent: AppColors.softBlue, destination: .officialSources),
                scenario(id: "transport", title: "Transport", subtitle: "OV, city travel, places", asset: ContentMediaRegistry.transportHero, accent: AppColors.dutchOrange, destination: .practicalGuide(.transportBasics)),
                scenario(id: "emergency", title: "Emergency", subtitle: "112, healthcare, lost documents", asset: "premium_home_healthcare", accent: AppColors.error, destination: .emergencyHub)
            ]
        case .entrepreneur:
            return [
                scenario(id: "kvk", title: "KVK", subtitle: "Business registration", asset: "premium_home_work", accent: AppColors.softBlue, destination: .officialSources),
                scenario(id: "vat", title: "VAT / BTW", subtitle: "Tax and banking basics", asset: "premium_home_documents", accent: AppColors.dutchOrange, destination: .officialSources),
                scenario(id: "permits", title: "Permits", subtitle: "Municipality rules", asset: "home_documents_city_hall", accent: AppColors.violet, destination: .governmentHub)
            ]
        case .lgbt:
            return [
                scenario(id: "safety", title: "Safety", subtitle: "Rights and legal support", asset: "premium_home_documents", accent: AppColors.softBlue, destination: .lgbtqSupport),
                scenario(id: "healthcare", title: "Healthcare", subtitle: "Inclusive care and mental health", asset: "premium_home_healthcare", accent: AppColors.emerald, destination: .practicalGuide(.healthcareBasics)),
                scenario(id: "community", title: "Community", subtitle: "Support and safe housing", asset: nil, accent: AppColors.dutchOrange, destination: .lgbtqSupport)
            ]
        case .eu, .nonEU, .universal, nil:
            return [
                scenario(id: "registration", title: "Registration", subtitle: "Municipality, BSN, DigiD", asset: "premium_home_documents", accent: AppColors.cyanGlow, destination: .checklistList),
                scenario(id: "healthcare", title: "Healthcare", subtitle: "GP and insurance", asset: "premium_home_healthcare", accent: AppColors.emerald, destination: .practicalGuide(.healthcareBasics)),
                scenario(id: "housing", title: "Housing", subtitle: "Renting safely", asset: "premium_home_housing", accent: AppColors.violet, destination: .practicalGuide(.housingBasics))
            ]
        }
    }

    private func scenario(id: String, title: String, subtitle: String, asset: String, accent: Color, destination: AppDestination) -> HomeLifeScenario {
        scenario(
            id: id,
            title: title,
            subtitle: subtitle,
            asset: premiumLocalImage(id: "scenario-\(id)", localAssetName: asset, title: title),
            accent: accent,
            destination: destination
        )
    }

    private func scenario(id: String, title: String, subtitle: String, asset: AppImageAsset?, accent: Color, destination: AppDestination) -> HomeLifeScenario {
        HomeLifeScenario(
            id: id,
            titleRU: title,
            titleNL: title,
            titleEN: title,
            subtitleRU: subtitle,
            subtitleNL: subtitle,
            subtitleEN: subtitle,
            asset: asset,
            accent: accent,
            destination: destination
        )
    }

    private var homeHeroCities: [HomeHeroCity] {
        [
            HomeHeroCity(
                id: "amsterdam",
                name: "Amsterdam",
                provinceRU: "Северная Голландия",
                provinceNL: "Noord-Holland",
                provinceEN: "North Holland",
                descriptionRU: "Столица Нидерландов: каналы, музеи, велосипеды и ночная жизнь в одном маршруте.",
                descriptionNL: "De hoofdstad van Nederland: grachten, musea, fietsen en avondleven in een route.",
                descriptionEN: "The Dutch capital: canals, museums, cycling and nightlife in one route.",
                statOneValue: "900k",
                statOneRU: "Население",
                statOneNL: "Inwoners",
                statOneEN: "Population",
                statTwoValue: "165",
                statTwoRU: "Каналы",
                statTwoNL: "Grachten",
                statTwoEN: "Canals",
                statThreeValue: "1275",
                statThreeRU: "Основан",
                statThreeNL: "Ontstaan",
                statThreeEN: "Founded",
                symbol: "🏙",
                asset: premiumLocalImage(id: "premium-home-background", localAssetName: "premium_home_background", title: "Amsterdam canals"),
                destination: .cityDetail(province: "Noord-Holland", city: "Amsterdam")
            ),
            HomeHeroCity(
                id: "rotterdam",
                name: "Rotterdam",
                provinceRU: "Южная Голландия",
                provinceNL: "Zuid-Holland",
                provinceEN: "South Holland",
                descriptionRU: "Крупнейший порт Европы, мост Эразма и современная архитектура рядом с водой.",
                descriptionNL: "Europa's grootste haven, de Erasmusbrug en moderne architectuur aan het water.",
                descriptionEN: "Europe's largest port, the Erasmus Bridge and modern waterfront architecture.",
                statOneValue: "650k",
                statOneRU: "Население",
                statOneNL: "Inwoners",
                statOneEN: "Population",
                statTwoValue: "#1",
                statTwoRU: "Порт",
                statTwoNL: "Haven",
                statTwoEN: "Port",
                statThreeValue: "1340",
                statThreeRU: "Основан",
                statThreeNL: "Stad",
                statThreeEN: "City",
                symbol: "🌉",
                asset: ContentMediaRegistry.transportStationHero ?? ContentMediaRegistry.transportHero,
                destination: .cityDetail(province: "Zuid-Holland", city: "Rotterdam")
            ),
            HomeHeroCity(
                id: "den-haag",
                name: "Den Haag",
                provinceRU: "Южная Голландия",
                provinceNL: "Zuid-Holland",
                provinceEN: "South Holland",
                descriptionRU: "Парламент, международные суды, посольства и пляж Схевенинген в одном городе.",
                descriptionNL: "Parlement, internationale hoven, ambassades en Scheveningen in een stad.",
                descriptionEN: "Parliament, international courts, embassies and Scheveningen in one city.",
                statOneValue: "550k",
                statOneRU: "Население",
                statOneNL: "Inwoners",
                statOneEN: "Population",
                statTwoValue: "3",
                statTwoRU: "Станции",
                statTwoNL: "Stations",
                statTwoEN: "Stations",
                statThreeValue: "13 c.",
                statThreeRU: "История",
                statThreeNL: "Historie",
                statThreeEN: "History",
                symbol: "⚖️",
                asset: ContentMediaRegistry.cultureHero,
                destination: .cityDetail(province: "Zuid-Holland", city: "Den Haag")
            ),
            HomeHeroCity(
                id: "leiden",
                name: "Leiden",
                provinceRU: "Южная Голландия · ваш город",
                provinceNL: "Zuid-Holland · jouw stad",
                provinceEN: "South Holland · your city",
                descriptionRU: "Исторический университетский город с каналами, музеями и спокойной студенческой жизнью.",
                descriptionNL: "Historische universiteitsstad met grachten, musea en rustig studentenleven.",
                descriptionEN: "Historic university city with canals, museums and calm student life.",
                statOneValue: "130k",
                statOneRU: "Население",
                statOneNL: "Inwoners",
                statOneEN: "Population",
                statTwoValue: "1575",
                statTwoRU: "Университет",
                statTwoNL: "Universiteit",
                statTwoEN: "University",
                statThreeValue: "28 km",
                statThreeRU: "Каналы",
                statThreeNL: "Grachten",
                statThreeEN: "Canals",
                symbol: "🎓",
                asset: premiumLocalImage(id: "home-leiden-canals", localAssetName: "home_leiden_canals", title: "Leiden canals"),
                destination: .cityDetail(province: "Zuid-Holland", city: "Leiden")
            ),
            HomeHeroCity(
                id: "utrecht",
                name: "Utrecht",
                provinceRU: "Утрехт",
                provinceNL: "Utrecht",
                provinceEN: "Utrecht",
                descriptionRU: "Средневековый центр, башня Дом и каналы с кафе прямо у воды.",
                descriptionNL: "Middeleeuws centrum, de Domtoren en werfkelders direct aan het water.",
                descriptionEN: "Medieval centre, the Dom Tower and canalside wharf cellars.",
                statOneValue: "360k",
                statOneRU: "Население",
                statOneNL: "Inwoners",
                statOneEN: "Population",
                statTwoValue: "112m",
                statTwoRU: "Домторен",
                statTwoNL: "Domtoren",
                statTwoEN: "Dom Tower",
                statThreeValue: "47 BC",
                statThreeRU: "Корни",
                statThreeNL: "Wortels",
                statThreeEN: "Roots",
                symbol: "⛪",
                asset: ContentMediaRegistry.cultureWindmillHero,
                destination: .cityDetail(province: "Utrecht", city: "Utrecht")
            )
        ]
    }

    private func premiumLocalImage(id: String, localAssetName: String, title: String) -> AppImageAsset {
        return AppImageAsset(
            id: id,
            url: nil,
            localAssetName: localAssetName,
            title: title,
            description: "Premium editorial category image for the YouNew home screen.",
            sourceName: "Generated project asset",
            sourceURL: nil,
            creator: "OpenAI image generation",
            license: nil,
            attribution: "Generated for YouNew",
            width: nil,
            height: nil,
            aspectRatio: 16.0 / 10.0,
            type: .cardThumbnail,
            verified: true,
            retrievedAt: "2026-06-02"
        )
    }

    private func cityImageAsset(_ city: NLCity) -> AppImageAsset {
        let resolvedImage = CanonicalPlaceImageResolver.resolveCityHero(city: city)
        let url = resolvedImage.url
        return AppImageAsset(
            id: city.placeId,
            url: url,
            imageURL: url,
            thumbnailURL: url,
            localAssetName: CuratedPlaceHeroMediaRegistry.cityPlaceholderAssetName,
            title: "\(city.name) hero",
            description: city.shortDescription,
            sourceName: "Wikimedia Commons",
            sourceURL: url,
            creator: nil,
            license: "CC BY-SA 4.0",
            attribution: nil,
            width: nil,
            height: nil,
            aspectRatio: 16.0 / 10.0,
            type: .cityHero,
            verified: true,
            retrievedAt: "2026-06-07"
        )
    }

    // MARK: - Quick Actions Data

    private var quickActions: [HomeQuickAction] {
        activePersonaDashboard.quickActions
    }

    private var helpTopics: [HomeHelpTopic] {
        activePersonaDashboard.helpTopics
    }

    private var personaJourneys: [HomePersonaJourney] {
        activePersonaDashboard.journeys
    }

    // MARK: - Categories Grid Data

    private var homeCategories: [HomeCategoryItem] {
        activePersonaDashboard.categories
    }

    private var activePersonaDashboard: HomePersonaDashboard {
        guard let status = appState.selectedUserStatus else {
            return HomePersonaDashboard(quickActions: [], helpTopics: [], journeys: [], categories: [])
        }
        return dashboard(for: status)
    }

    private func dashboard(for status: UserStatus) -> HomePersonaDashboard {
        switch status {
        case .student:
            return HomePersonaDashboard(
                quickActions: [
                    action("universities", "Universities", "graduationcap.fill", AppColors.emerald, .institutionsList),
                    action("duo", "DUO", "building.columns.fill", AppColors.softBlue, .officialSources),
                    action("student-housing", "Student Housing", "house.fill", AppColors.violet, .practicalGuide(.housingBasics)),
                    action("student-transport", "Public Transport Discounts", "tram.fill", AppColors.dutchOrange, .practicalGuide(.transportBasics))
                ],
                helpTopics: [
                    topic("mbo", "MBO", "book.closed.fill", AppColors.emerald, .knm),
                    topic("hbo", "HBO", "books.vertical.fill", AppColors.softBlue, .knm),
                    topic("research-universities", "Research Universities", "building.2.fill", AppColors.violet, .institutionsList),
                    topic("student-finance", "Student Finance", "creditcard.fill", AppColors.dutchOrange, .officialSources),
                    topic("student-insurance", "Student Insurance", "cross.case.fill", AppColors.emerald, .practicalGuide(.healthInsuranceBasics)),
                    topic("dutch-language-courses", "Dutch Language Courses", "text.book.closed.fill", AppColors.routeLine, .languageHub)
                ],
                journeys: [
                    journey(.student, "Student", "DUO, university, housing, insurance, transport, student jobs")
                ],
                categories: [
                    category("student-jobs", "Student Jobs", "briefcase.fill", AppColors.gradWork, .institutionsList),
                    category("libraries", "Libraries", "books.vertical.fill", AppColors.gradEducation, .mapFocus(.education)),
                    category("student-communities", "Student Communities", "person.3.fill", AppColors.gradProvince, .mapFocus(.category(.studentHelp))),
                    category("student-events", "Student Events", "calendar", AppColors.gradTransport, .mapFocus(.city(appState.selectedCity))),
                    category("study-spaces", "Study Spaces", "deskclock.fill", AppColors.gradGovernment, .mapFocus(.education)),
                    category("city-life", "City Life", "building.2.fill", AppColors.gradProvince, .mapFocus(.city(appState.selectedCity))),
                    category("free-time", "Free Time", "sparkles", AppColors.gradTransport, .mapFocus(.category(.communitySupport)))
                ]
            )
        case .worker, .expat:
            return HomePersonaDashboard(
                quickActions: [
                    action("bsn", "BSN", "person.text.rectangle.fill", AppColors.cyanGlow, .checklistList),
                    action("digid", "DigiD", "lock.shield.fill", AppColors.softBlue, .practicalGuide(.digidSafety)),
                    action("contracts", "Work Contracts", "doc.text.fill", AppColors.violet, .institutionsList),
                    action("taxes", "Taxes", "creditcard.fill", AppColors.dutchOrange, .officialSources)
                ],
                helpTopics: [
                    topic("uwv", "UWV", "building.columns.fill", AppColors.softBlue, .governmentHub),
                    topic("salary", "Salary", "eurosign.circle.fill", AppColors.emerald, .institutionsList),
                    topic("employment-rights", "Employment Rights", "shield.lefthalf.filled", AppColors.violet, .officialSources),
                    topic("health-insurance", "Health Insurance", "cross.case.fill", AppColors.emerald, .practicalGuide(.healthInsuranceBasics)),
                    topic("housing", "Housing", "house.fill", AppColors.violet, .practicalGuide(.housingBasics)),
                    topic("transport", "Transport", "tram.fill", AppColors.routeLine, .practicalGuide(.transportBasics))
                ],
                journeys: [
                    journey(status, status == .expat ? "Expat Worker" : "Worker", "BSN, DigiD, work rights, salary, taxes, insurance, pension")
                ],
                categories: [
                    category("pension", "Pension", "chart.line.uptrend.xyaxis", AppColors.gradGovernment, .officialSources),
                    category("worker-training", "Worker Training", "wrench.and.screwdriver.fill", AppColors.gradEducation, .institutionsList)
                ]
            )
        case .refugee, .ukrainian:
            return HomePersonaDashboard(
                quickActions: [
                    action("ind", "IND", "building.columns.fill", AppColors.softBlue, .governmentHub),
                    action("municipality", "Municipality", "building.2.fill", AppColors.cyanGlow, .governmentHub),
                    action("refugee-housing", "Housing", "house.fill", AppColors.violet, .practicalGuide(.housingBasics)),
                    action("benefits", "Benefits", "creditcard.fill", AppColors.dutchOrange, .officialSources)
                ],
                helpTopics: [
                    topic("integration", "Integration", "figure.2.arms.open", AppColors.success, .firstSteps),
                    topic("language", "Language", "text.book.closed.fill", AppColors.routeLine, .languageHub),
                    topic("healthcare", "Healthcare", "cross.case.fill", AppColors.emerald, .practicalGuide(.healthcareBasics)),
                    topic("documents", "Documents", "doc.text.fill", AppColors.dutchOrange, .journeyDocuments),
                    topic("work-permissions", "Work Permissions", "briefcase.fill", AppColors.softBlue, .officialSources),
                    topic("education-access", "Education Access", "graduationcap.fill", AppColors.emerald, .knm)
                ],
                journeys: [
                    journey(status, status == .ukrainian ? "Ukrainian Newcomer" : "Refugee", "IND, municipality, housing, benefits, integration, documents")
                ],
                categories: [
                    category("support-organizations", "Support Organizations", "hands.and.sparkles.fill", AppColors.gradDocs, .survivalHub)
                ]
            )
        case .family:
            return HomePersonaDashboard(
                quickActions: [
                    action("schools", "Schools", "graduationcap.fill", AppColors.emerald, .mapFocus(.education)),
                    action("childcare", "Childcare", "figure.and.child.holdinghands", AppColors.softBlue, .institutionsList),
                    action("kinderopvang", "Kinderopvang", "figure.2.and.child.holdinghands", AppColors.violet, .officialSources),
                    action("svb", "SVB", "building.columns.fill", AppColors.dutchOrange, .officialSources)
                ],
                helpTopics: [
                    topic("child-benefits", "Child Benefits", "creditcard.fill", AppColors.dutchOrange, .officialSources),
                    topic("family-housing", "Family Housing", "house.fill", AppColors.violet, .practicalGuide(.housingBasics)),
                    topic("healthcare", "Healthcare", "cross.case.fill", AppColors.emerald, .practicalGuide(.healthcareBasics)),
                    topic("activities", "Activities", "calendar", AppColors.routeLine, .mapFocus(.category(.communitySupport))),
                    topic("municipal-services", "Municipal Services", "building.2.fill", AppColors.softBlue, .governmentHub)
                ],
                journeys: [
                    journey(.family, "Family", "Schools, childcare, SVB, benefits, housing, healthcare, activities")
                ],
                categories: []
            )
        case .highlySkilledMigrant:
            return HomePersonaDashboard(
                quickActions: [
                    action("sponsor", "Recognized Sponsor", "checkmark.seal.fill", AppColors.softBlue, .officialSources),
                    action("ind", "IND", "building.columns.fill", AppColors.cyanGlow, .governmentHub),
                    action("bsn-digid", "BSN and DigiD", "person.text.rectangle.fill", AppColors.violet, .checklistList),
                    action("salary-tax", "Salary and Tax", "eurosign.circle.fill", AppColors.dutchOrange, .officialSources)
                ],
                helpTopics: [
                    topic("housing", "Housing", "house.fill", AppColors.violet, .practicalGuide(.housingBasics)),
                    topic("insurance", "Health Insurance", "cross.case.fill", AppColors.emerald, .practicalGuide(.healthInsuranceBasics)),
                    topic("family-relocation", "Family Relocation", "person.3.fill", AppColors.softBlue, .statusDirection(.family)),
                    topic("transport", "Transport", "tram.fill", AppColors.routeLine, .practicalGuide(.transportBasics))
                ],
                journeys: [
                    journey(.highlySkilledMigrant, "Highly Skilled Migrant", "Sponsor, IND, BSN, DigiD, salary, tax, housing, family")
                ],
                categories: []
            )
        case .euCitizen:
            return HomePersonaDashboard(
                quickActions: [
                    action("registration", "Municipality Registration", "building.2.fill", AppColors.cyanGlow, .governmentHub),
                    action("bsn", "BSN", "person.text.rectangle.fill", AppColors.softBlue, .checklistList),
                    action("work-rights", "Work Rights", "briefcase.fill", AppColors.violet, .officialSources),
                    action("healthcare", "Healthcare", "cross.case.fill", AppColors.emerald, .practicalGuide(.healthcareBasics))
                ],
                helpTopics: [
                    topic("housing", "Housing", "house.fill", AppColors.violet, .practicalGuide(.housingBasics)),
                    topic("taxes", "Taxes", "creditcard.fill", AppColors.dutchOrange, .officialSources),
                    topic("transport", "Transport", "tram.fill", AppColors.routeLine, .practicalGuide(.transportBasics)),
                    topic("municipal-services", "Municipal Services", "building.columns.fill", AppColors.softBlue, .governmentHub)
                ],
                journeys: [
                    journey(.euCitizen, "EU Citizen", "Registration, BSN, work rights, healthcare, housing, taxes")
                ],
                categories: []
            )
        case .tourist:
            return HomePersonaDashboard(
                quickActions: [
                    action("stay-rules", "Stay Rules", "calendar.badge.clock", AppColors.softBlue, .officialSources),
                    action("transport", "Transport", "tram.fill", AppColors.dutchOrange, .practicalGuide(.transportBasics)),
                    action("emergency", "Emergency", "phone.fill", AppColors.error, .emergencyHub),
                    action("places", "Places", "mappin.circle.fill", AppColors.emerald, .mapFocus(.city(appState.selectedCity)))
                ],
                helpTopics: [
                    topic("city-life", "City Life", "building.2.fill", AppColors.softBlue, .mapFocus(.city(appState.selectedCity))),
                    topic("healthcare", "Healthcare", "cross.case.fill", AppColors.emerald, .practicalGuide(.healthcareBasics)),
                    topic("official-sources", "Official Sources", "checkmark.shield.fill", AppColors.violet, .officialSources)
                ],
                journeys: [
                    journey(.tourist, "Tourist", "Stay rules, transport, emergency help, city places")
                ],
                categories: []
            )
        case .entrepreneur:
            return HomePersonaDashboard(
                quickActions: [
                    action("kvk", "KVK", "building.columns.fill", AppColors.softBlue, .officialSources),
                    action("btw", "VAT", "percent", AppColors.dutchOrange, .officialSources),
                    action("business-banking", "Business Banking", "creditcard.fill", AppColors.emerald, .practicalGuide(.bankingBasics)),
                    action("permits", "Permits", "doc.text.fill", AppColors.violet, .governmentHub)
                ],
                helpTopics: [
                    topic("taxes", "Taxes", "eurosign.circle.fill", AppColors.dutchOrange, .officialSources),
                    topic("insurance", "Insurance", "cross.case.fill", AppColors.emerald, .practicalGuide(.healthInsuranceBasics)),
                    topic("housing", "Housing", "house.fill", AppColors.violet, .practicalGuide(.housingBasics)),
                    topic("networking", "Networking", "person.3.fill", AppColors.softBlue, .institutionsList)
                ],
                journeys: [
                    journey(.entrepreneur, "Entrepreneur", "KVK, VAT, banking, permits, tax, insurance")
                ],
                categories: []
            )
        case .lgbtNewcomer:
            return HomePersonaDashboard(
                quickActions: [
                    action("rights", "Rights", "shield.lefthalf.filled", AppColors.softBlue, .lgbtqSupport),
                    action("healthcare", "Healthcare", "cross.case.fill", AppColors.emerald, .practicalGuide(.healthcareBasics)),
                    action("mental-health", "Mental Health", "heart.fill", AppColors.violet, .emotionalSupport),
                    action("community", "Community", "person.3.fill", AppColors.dutchOrange, .lgbtqSupport)
                ],
                helpTopics: [
                    topic("legal-support", "Legal Support", "doc.text.fill", AppColors.softBlue, .officialSources),
                    topic("housing-safety", "Housing Safety", "house.fill", AppColors.violet, .practicalGuide(.housingBasics)),
                    topic("emergency", "Emergency", "phone.fill", AppColors.error, .emergencyHub),
                    topic("municipality", "Municipality", "building.2.fill", AppColors.cyanGlow, .governmentHub)
                ],
                journeys: [
                    journey(.lgbtNewcomer, "LGBT Newcomer", "Safety, rights, healthcare, community, legal support")
                ],
                categories: []
            )
        }
    }

    private func action(_ id: String, _ title: String, _ icon: String, _ accent: Color, _ destination: AppDestination) -> HomeQuickAction {
        HomeQuickAction(id: id, titleRU: title, titleNL: title, titleEN: title, icon: icon, accent: accent, destination: destination)
    }

    private func topic(_ id: String, _ title: String, _ icon: String, _ tint: Color, _ destination: AppDestination) -> HomeHelpTopic {
        HomeHelpTopic(id: id, titleEN: title, titleNL: title, titleRU: title, icon: icon, tint: tint, destination: destination)
    }

    private func journey(_ status: UserStatus, _ title: String, _ subtitle: String) -> HomePersonaJourney {
        HomePersonaJourney(
            id: status.rawValue,
            titleEN: title,
            titleNL: title,
            titleRU: title,
            subtitleEN: subtitle,
            subtitleNL: subtitle,
            subtitleRU: subtitle,
            icon: status.icon,
            tint: AppColors.cyanGlow,
            destination: .statusDirection(status)
        )
    }

    private func category(_ id: String, _ title: String, _ icon: String, _ gradient: [Color], _ destination: AppDestination) -> HomeCategoryItem {
        HomeCategoryItem(id: id, titleRU: title, titleNL: title, titleEN: title, icon: icon, gradient: gradient, destination: destination)
    }

    // MARK: - History & Culture Data

    private var historyCultureCards: [HistoryCultureItem] {
        [
            HistoryCultureItem(
                id: "golden_age",
                titleRU: "Золотой Век", titleNL: "Gouden Eeuw", titleEN: "Dutch Golden Age",
                subtitleRU: "XVII век: торговля, искусство и наука", subtitleNL: "17e eeuw: handel, kunst en wetenschap", subtitleEN: "17th century: trade, art & science",
                icon: "crown.fill", accent: AppColors.dutchOrange, destination: .netherlandsHistory
            ),
            HistoryCultureItem(
                id: "traditions",
                titleRU: "Традиции", titleNL: "Tradities", titleEN: "Traditions",
                subtitleRU: "Праздники, обычаи и символы", subtitleNL: "Feesten, gebruiken en symbolen", subtitleEN: "Holidays, customs & symbols",
                icon: "party.popper.fill", accent: AppColors.violet, destination: .dutchHolidays
            ),
            HistoryCultureItem(
                id: "monarchy",
                titleRU: "Монархия", titleNL: "Monarchie", titleEN: "Monarchy",
                subtitleRU: "Королевский дом Нидерландов", subtitleNL: "Het Nederlandse koningshuis", subtitleEN: "The Dutch Royal House",
                icon: "building.columns.fill", accent: AppColors.softBlue, destination: .knm
            ),
            HistoryCultureItem(
                id: "wwii",
                titleRU: "Вторая мировая", titleNL: "Tweede Wereldoorlog", titleEN: "World War II",
                subtitleRU: "Оккупация и освобождение", subtitleNL: "Bezetting en bevrijding", subtitleEN: "Occupation and liberation",
                icon: "shield.fill", accent: AppColors.error, destination: .netherlandsHistory
            )
        ]
    }

    // MARK: - News Data

    private var newsItems: [HomeNewsItem] {
        [
            HomeNewsItem(
                id: "bsn_update",
                titleRU: "Изменения в процедуре BSN", titleNL: "Wijzigingen BSN-procedure", titleEN: "BSN procedure updates",
                subtitleRU: "Новые требования для регистрации", subtitleNL: "Nieuwe vereisten voor inschrijving", subtitleEN: "New requirements for registration",
                icon: "person.text.rectangle.fill", accent: AppColors.cyanGlow
            ),
            HomeNewsItem(
                id: "integration",
                titleRU: "Гид по интеграции", titleNL: "Integratiegids", titleEN: "Integration guide",
                subtitleRU: "Полный путь от прибытия до гражданства", subtitleNL: "Volledig traject van aankomst tot burgerschap", subtitleEN: "Full path from arrival to citizenship",
                icon: "figure.2.arms.open", accent: AppColors.emerald
            ),
            HomeNewsItem(
                id: "housing",
                titleRU: "Советы по жилью", titleNL: "Huisvestingstips", titleEN: "Housing tips",
                subtitleRU: "Как найти жильё в Нидерландах", subtitleNL: "Hoe woonruimte te vinden in Nederland", subtitleEN: "How to find housing in the Netherlands",
                icon: "house.fill", accent: AppColors.softBlue
            )
        ]
    }

    // MARK: - Localised strings for new sections

    private var netherlandsMapTitle: String {
        switch lang {
        case .russian: return "Карта Нидерландов"
        case .dutch: return "Kaart van Nederland"
        case .english: return "Netherlands Map"
        }
    }

    private var netherlandsMapSubtitle: String {
        switch lang {
        case .russian: return "Исследуйте провинции, города и сервисы через интерактивную карту."
        case .dutch: return "Verken provincies, steden en diensten via de interactieve kaart."
        case .english: return "Explore provinces, cities and services through the interactive map."
        }
    }

    private var mapCardTitle: String {
        switch lang {
        case .russian: return "Интерактивная карта"
        case .dutch: return "Interactieve kaart"
        case .english: return "Interactive Map"
        }
    }

    private var mapCardSubtitle: String {
        switch lang {
        case .russian: return "Нажмите провинцию или город"
        case .dutch: return "Tik op een provincie of stad"
        case .english: return "Tap a province or city"
        }
    }

    private var exploreMapLabel: String {
        switch lang {
        case .russian: return "Открыть карту"
        case .dutch: return "Open kaart"
        case .english: return "Explore Map"
        }
    }

    private var quickActionsTitle: String {
        switch lang {
        case .russian: return "Быстрые действия"
        case .dutch: return "Snelle acties"
        case .english: return "Quick Actions"
        }
    }

    private var categoriesTitle: String {
        switch lang {
        case .russian: return "Разделы"
        case .dutch: return "Categorieën"
        case .english: return "Categories"
        }
    }

    private var historyAndCultureTitle: String {
        switch lang {
        case .russian: return "История и культура"
        case .dutch: return "Geschiedenis & Cultuur"
        case .english: return "History & Culture"
        }
    }

    private var nearbyAttractionsTitle: String {
        switch lang {
        case .russian: return "Рядом с вами"
        case .dutch: return "Bij jou in de buurt"
        case .english: return "Nearby & Around You"
        }
    }

    private var newsUpdatesTitle: String {
        switch lang {
        case .russian: return "Новости и обновления"
        case .dutch: return "Nieuws & Updates"
        case .english: return "News & Updates"
        }
    }

    private var reviewsFeedbackTitle: String {
        switch lang {
        case .russian: return "Отзывы и пожелания"
        case .dutch: return "Reviews & Feedback"
        case .english: return "Reviews & Feedback"
        }
    }

    private var reviewsFeedbackSubtitle: String {
        switch lang {
        case .russian: return "Расскажите, что помогло — это улучшает гид для всех"
        case .dutch: return "Vertel wat hielp — dit verbetert de gids voor iedereen"
        case .english: return "Tell us what helped — it improves the guide for everyone"
        }
    }

    private var feedbackStorageNotice: String {
        switch lang {
        case .russian: return "Отзыв сохраняется локально с видимым подтверждением."
        case .dutch: return "Feedback wordt lokaal bewaard met zichtbare bevestiging."
        case .english: return "Feedback is saved locally with visible confirmation."
        }
    }

    private var viewAllLabel: String {
        switch lang {
        case .russian: return "Все"
        case .dutch: return "Alles"
        case .english: return "See all"
        }
    }

    private var feedbackPrompt: String {
        switch lang {
        case .russian: return "Я хочу оставить отзыв о приложении YouNew. Что мне следует знать?"
        case .dutch: return "Ik wil feedback geven over de YouNew-app. Wat moet ik weten?"
        case .english: return "I'd like to give feedback about the YouNew app. What should I know?"
        }
    }

    private var cityMoments: [HomeCityMoment] {
        [
            HomeCityMoment(id: "weather", titleRU: "Погода", titleNL: "Weer", titleEN: "Weather", subtitleRU: "Проверьте день перед выходом", subtitleNL: "Check je dag voor vertrek", subtitleEN: "Check your day before leaving", asset: nil, accent: AppColors.softBlue, destination: nil),
            HomeCityMoment(id: "transport", titleRU: "Транспорт", titleNL: "Openbaar vervoer", titleEN: "Transport", subtitleRU: "OV, поезд, велосипед и маршруты рядом", subtitleNL: "OV, trein, fiets en routes dichtbij", subtitleEN: "OV, trains, bikes, and nearby routes", asset: ContentMediaRegistry.transportHero, accent: AppColors.emerald, destination: .practicalGuide(.transportBasics)),
            HomeCityMoment(id: "municipality", titleRU: "Муниципалитет", titleNL: "Gemeente", titleEN: "Municipality", subtitleRU: "Адрес, BSN и городские услуги", subtitleNL: "Adres, BSN en stadsdiensten", subtitleEN: "Address, BSN, and city services", asset: ContentMediaRegistry.municipalityCityHallImage, accent: AppColors.cyanGlow, destination: .governmentHub),
            HomeCityMoment(id: "emergency", titleRU: "Экстренно", titleNL: "Noodhulp", titleEN: "Emergency", subtitleRU: "112 и помощь рядом", subtitleNL: "112 en hulp dichtbij", subtitleEN: "112 and nearby help", asset: premiumLocalImage(id: "premium-home-emergency", localAssetName: "premium_home_emergency", title: "Dutch emergency services"), accent: AppColors.error, destination: .emergencyHub),
            HomeCityMoment(id: "events", titleRU: "События", titleNL: "Evenementen", titleEN: "Events", subtitleRU: "Что происходит в городе", subtitleNL: "Wat er in de stad gebeurt", subtitleEN: "What is happening nearby", asset: ContentMediaRegistry.cultureHero, accent: AppColors.dutchOrange, destination: .mapFocus(.city(appState.selectedCity))),
            HomeCityMoment(id: "tip", titleRU: "Совет дня", titleNL: "Tip van de dag", titleEN: "Local tip", subtitleRU: "Маленький шаг, который поможет сегодня", subtitleNL: "Een kleine stap voor vandaag", subtitleEN: "A small step that helps today", asset: nil, accent: AppColors.violet, destination: nil),
            HomeCityMoment(id: "official", titleRU: "Официальные сервисы", titleNL: "Officiele diensten", titleEN: "Official services", subtitleRU: "Проверенные источники перед следующим шагом", subtitleNL: "Gecontroleerde bronnen voor je volgende stap", subtitleEN: "Verified sources before your next step", asset: ContentMediaRegistry.officialSourcesHero, accent: AppColors.cyanGlow, destination: .officialSources)
        ]
    }

    private var currentTime: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "nl_NL")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }

    private var fullDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: lang == .dutch ? "nl_NL" : lang == .russian ? "ru_RU" : "en_GB")
        formatter.setLocalizedDateFormatFromTemplate("d MMMM")
        return formatter.string(from: Date())
    }

    private var completedChecklistCount: Int { appState.visibleChecklistItems.filter(\.isCompleted).count }
    private var totalChecklistCount: Int { appState.visibleChecklistItems.count }

    private var homeChecklistProgress: Double {
        guard totalChecklistCount > 0 else { return 0 }
        return min(1, max(0, Double(completedChecklistCount) / Double(totalChecklistCount)))
    }

    private var nextChecklistItem: ChecklistItem? {
        let recommended = appState.prioritizedChecklist.recommended.first { !$0.isCompleted }
        return recommended ?? appState.visibleChecklistItems.first { !$0.isCompleted }
    }

    private var recentBookmarks: [String] {
        let topics = appState.visibleRecentlyViewedTopics().prefix(3).map { appState.displayTitle(forRecentlyViewedTopic: $0, language: lang) }
        return topics.isEmpty ? defaultBookmarks : Array(topics)
    }

    private var provinceName: String {
        ProvinceCatalog.provinceID(containingCity: appState.selectedCity) ?? "Zuid-Holland"
    }

    private func openTodayPrompt() {
        openAssistantPrompt(todayPrompt)
    }

    private func openAssistantPrompt(_ prompt: String?) {
        appState.pendingAIContext = AIContext(
            screen: .home,
            category: "Personal guide",
            topicTitle: aiNavigatorTitle,
            topicSummary: cityDescription,
            officialSources: [],
            lastReviewed: nil,
            userLanguage: lang,
            userSituation: appState.selectedUserStatus?.rawValue,
            selectedCity: appState.selectedCity,
            selectedProvince: provinceName,
            savedItemTitles: recentBookmarks,
            disclaimer: AISafetyRules.mandatoryDisclaimer(for: lang),
            activePersonaTag: appState.selectedUserStatus?.personaTag,
            personaSearchScope: .currentAndUniversal
        )
        appState.pendingAIPrompt = prompt
        selectedTab = .assistant
    }

    private var cityDescription: String {
        switch appState.selectedCity {
        case "Amsterdam":
            switch lang {
            case .russian: return "Город каналов, транспорта и международной жизни"
            case .dutch: return "Stad van grachten, vervoer en internationaal leven"
            case .english: return "Canal city with strong transport and international life"
            }
        case "Rotterdam":
            switch lang {
            case .russian: return "Портовый город архитектуры, работы и движения"
            case .dutch: return "Havenstad van architectuur, werk en beweging"
            case .english: return "Port city of architecture, work, and movement"
            }
        case "Den Haag":
            switch lang {
            case .russian: return "Город правительства, моря и международных институтов"
            case .dutch: return "Stad van overheid, zee en internationale instellingen"
            case .english: return "City of government, the sea, and international institutions"
            }
        case "Utrecht":
            switch lang {
            case .russian: return "Центральный город поездов, каналов и студентов"
            case .dutch: return "Centrale stad van treinen, grachten en studenten"
            case .english: return "Central city of trains, canals, and students"
            }
        default:
            switch lang {
            case .russian: return "Исторический университетский город"
            case .dutch: return "Historische universiteitsstad"
            case .english: return "Historic university city"
            }
        }
    }

    private var heroPromise: String {
        switch lang {
        case .russian: return "Ваш гид по жизни в Нидерландах"
        case .dutch: return "Uw gids voor het leven in Nederland"
        case .english: return "Your guide to life in the Netherlands"
        }
    }

    private var exploreCityTitle: String {
        switch lang {
        case .russian: return "Открыть город"
        case .dutch: return "Verken stad"
        case .english: return "Explore city"
        }
    }

    private var todayQuestionTitle: String {
        switch lang {
        case .russian: return "Что делать сегодня?"
        case .dutch: return "Wat vandaag?"
        case .english: return "What today?"
        }
    }

    private var startJourneyTitle: String {
        switch lang {
        case .russian: return "Начать путь"
        case .dutch: return "Start route"
        case .english: return "Start journey"
        }
    }

    private var lifeScenariosTitle: String {
        switch lang {
        case .russian: return "Что вам нужно сегодня?"
        case .dutch: return "Wat heeft u vandaag nodig?"
        case .english: return "What do you need today?"
        }
    }

    private var aiNavigatorTitle: String {
        switch lang {
        case .russian: return "AI-навигатор"
        case .dutch: return "AI-navigator"
        case .english: return "AI Navigator"
        }
    }

    private var aiNavigatorSubtitle: String {
        switch lang {
        case .russian: return "Спросите о жизни в Нидерландах и получите следующий шаг"
        case .dutch: return "Vraag alles over leven in Nederland"
        case .english: return "Ask anything about life in the Netherlands"
        }
    }

    private var todayInCityTitle: String {
        switch lang {
        case .russian: return "Сегодня в моём городе"
        case .dutch: return "Vandaag in mijn stad"
        case .english: return "Today in My City"
        }
    }

    private var myProgressTitle: String {
        switch lang {
        case .russian: return "Мой путь"
        case .dutch: return "Mijn route"
        case .english: return "My Progress"
        }
    }

    private var completedStepsText: String {
        switch lang {
        case .russian: return "\(completedChecklistCount) из \(totalChecklistCount) шагов выполнено"
        case .dutch: return "\(completedChecklistCount) van \(totalChecklistCount) stappen klaar"
        case .english: return "\(completedChecklistCount) of \(totalChecklistCount) steps completed"
        }
    }

    private var nextStepText: String {
        let next = nextChecklistItem?.title(lang) ?? defaultNextStep
        switch lang {
        case .russian: return "Дальше: \(next)"
        case .dutch: return "Volgende stap: \(next)"
        case .english: return "Next: \(next)"
        }
    }

    private var defaultNextStep: String {
        switch lang {
        case .russian: return "Зарегистрировать адрес"
        case .dutch: return "Adres registreren"
        case .english: return "Register your address"
        }
    }

    private var completedJourneyMilestones: Int {
        guard !journeyMilestoneTitles.isEmpty else { return 0 }
        let calculated = Int((homeChecklistProgress * Double(journeyMilestoneTitles.count)).rounded(.up))
        return min(journeyMilestoneTitles.count, max(1, calculated))
    }

    private var journeyMilestoneTitles: [String] {
        switch lang {
        case .russian: return ["Приезд", "Адрес", "BSN", "DigiD", "Врач", "Язык", "Жильё", "Работа"]
        case .dutch: return ["Aankomst", "Adres", "BSN", "DigiD", "Zorg", "Taal", "Wonen", "Werk"]
        case .english: return ["Arrival", "Address", "BSN", "DigiD", "Health", "Language", "Housing", "Work"]
        }
    }

    private var defaultBookmarks: [String] {
        switch lang {
        case .russian: return ["BSN", "DigiD", "Huisarts"]
        case .dutch: return ["BSN", "DigiD", "Huisarts"]
        case .english: return ["BSN", "DigiD", "GP"]
        }
    }

    private var aiQuestionExamples: [String] {
        switch lang {
        case .russian: return ["Как получить BSN?", "Как найти huisarts?", "Как зарегистрировать адрес?", "Что делать после приезда?"]
        case .dutch: return ["Hoe krijg ik BSN?", "Hoe vind ik een huisarts?", "Hoe registreer ik mijn adres?", "Wat doe ik na aankomst?"]
        case .english: return ["How do I get BSN?", "How do I find a GP?", "How do I register my address?", "What should I do after arrival?"]
        }
    }

    private var todayPrompt: String {
        switch lang {
        case .russian: return "Что мне сделать сегодня в \(cityName), если мой следующий шаг: \(nextChecklistItem?.title(lang) ?? defaultNextStep)? Ответь кратко, по шагам, с официальными источниками."
        case .dutch: return "Wat moet ik vandaag doen in \(cityName) als mijn volgende stap is: \(nextChecklistItem?.title(lang) ?? defaultNextStep)? Antwoord kort, stap voor stap, met officiele bronnen."
        case .english: return "What should I do today in \(cityName) if my next step is: \(nextChecklistItem?.title(lang) ?? defaultNextStep)? Answer briefly, step by step, with official sources."
        }
    }

    private var disclaimerText: String {
        switch lang {
        case .russian: return "Только для ориентации. Всегда проверяйте официальные источники."
        case .dutch: return "Alleen ter oriëntatie. Controleer altijd officiële bronnen."
        case .english: return "Information only. Always verify with official sources."
        }
    }
}

private extension View {
    func homeReadableBand(horizontalPadding: CGFloat = AppSpacing.screenHorizontal) -> some View {
        self
            .padding(.horizontal, horizontalPadding)
            .frame(maxWidth: 760, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

private struct HelpTopicIcon: View {
    let topic: HomeHelpTopic
    let language: AppLanguage

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [topic.tint.opacity(0.96), AppColors.dutchOrange.opacity(0.72)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 66, height: 66)

                Circle()
                    .fill(AppColors.card.opacity(0.98))
                    .frame(width: 60, height: 60)

                Image(systemName: topic.icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(topic.tint)
            }

            Text(topic.title(language))
                .font(.system(size: 13, weight: .semibold, design: .default))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.76)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: 82, height: 106, alignment: .top)
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

private struct PersonaJourneyCard: View {
    let journey: HomePersonaJourney
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: journey.icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(journey.tint)
                    .frame(width: 38, height: 38)
                    .background(journey.tint.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(journey.tint.opacity(0.28), lineWidth: 0.8)
                    )

                Spacer(minLength: 6)

                Image(systemName: "arrow.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppColors.textTertiary)
                    .frame(width: 28, height: 28)
                    .background(AppColors.card.opacity(0.72))
                    .clipShape(Circle())
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(journey.title(language))
                    .font(.system(size: 14, weight: .bold, design: .default))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
                    .fixedSize(horizontal: false, vertical: true)

                Text(journey.subtitle(language))
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .frame(width: 168, height: 128, alignment: .topLeading)
        .background(
            LinearGradient(
                colors: [
                    AppColors.cardElevated,
                    journey.tint.opacity(0.10)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(journey.tint.opacity(0.22), lineWidth: 0.8)
        )
        .contentShape(Rectangle())
    }
}

private struct CultureImageBlock: View {
    let title: String
    let subtitle: String
    let asset: AppImageAsset?
    let tint: Color
    let width: CGFloat
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            HomeImageFill(asset: asset, accent: tint)
                .frame(width: width, height: dynamicTypeSize.isAccessibilitySize ? 310 : 258)
                .clipped()
            LinearGradient(
                colors: [
                    AppColors.navyDeep.opacity(0.24),
                    Color.clear,
                    AppColors.navyDeep.opacity(0.94)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            LinearGradient(
                colors: [
                    Color.black.opacity(0.34),
                    Color.clear
                ],
                startPoint: .leading,
                endPoint: .trailing
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 25 : 22, weight: .semibold, design: .default))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                    .fixedSize(horizontal: false, vertical: true)
                Text(subtitle)
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundStyle(Color.white.opacity(0.80))
                    .lineLimit(3)
                    .minimumScaleFactor(0.82)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: width)
        .frame(height: dynamicTypeSize.isAccessibilitySize ? 310 : 258)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(Color.white.opacity(0.14), lineWidth: 0.8))
        .clipped()
    }
}

private struct RealNetherlandsMapPreview: View {
    let selectedCity: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppColors.card.opacity(0.46))
            NetherlandsMapCanvas(glowPhase: 0.45, selectedCity: selectedCity)
                .padding(.horizontal, 28)
                .padding(.vertical, 12)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct HomeRealisticNetherlandsMapCard: View {
    let title: String
    let subtitle: String
    let openMapLabel: String
    let selectedCity: String
    let language: AppLanguage
    let glowPhase: Double
    let onOpenMap: () -> Void

    @State private var selectedProvinceID: String?
    @State private var tooltipProvinceID: String?
    @State private var selectedFilterID = "provinces"
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [
                    Color(red: 4 / 255, green: 16 / 255, blue: 32 / 255),
                    AppColors.cyanGlow.opacity(0.10),
                    Color(red: 3 / 255, green: 12 / 255, blue: 25 / 255)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .allowsHitTesting(false)

            GeometryReader { proxy in
                let mapRect = HomeRealisticNetherlandsMapCanvas.mapRect(in: proxy.size)
                ZStack {
                    HomeRealisticNetherlandsMapCanvas(
                        selectedProvinceID: selectedProvinceID,
                        selectedCity: selectedCity,
                        glowPhase: selectedProvinceID == nil ? glowPhase : 0.90
                    )
                    .padding(.top, 28)
                    .padding(.bottom, 8)
                    .allowsHitTesting(false)

                    ForEach(ProvinceHitZones.all) { zone in
                        Rectangle()
                            .fill(Color.white.opacity(0.001))
                            .frame(
                                width: mapRect.width * zone.normalizedFrame.width,
                                height: mapRect.height * zone.normalizedFrame.height
                            )
                            .position(
                                x: mapRect.minX + mapRect.width * zone.normalizedFrame.midX,
                                y: mapRect.minY + mapRect.height * zone.normalizedFrame.midY
                            )
                            .onTapGesture {
                                selectProvince(zone)
                            }
                            .accessibilityHidden(true)
                    }
                }
            }

            LinearGradient(
                colors: [
                    Color.black.opacity(0.26),
                    Color.black.opacity(0.04),
                    Color.black.opacity(0.30)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                ViewThatFits(in: .horizontal) {
                    mapHeader
                    VStack(alignment: .leading, spacing: 10) {
                        mapTitleBlock
                        cityLegendPill
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 14)
                .padding(.bottom, 8)

                Spacer(minLength: 0)

                ViewThatFits(in: .horizontal) {
                    mapFooter
                    VStack(alignment: .leading, spacing: 10) {
                        legendRow
                        openMapButton
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
            }

            if let tooltipProvinceID {
                Text(ProvinceCatalog.item(id: tooltipProvinceID).localizedName(language))
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(AppColors.navyDeep.opacity(0.94))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(AppColors.cyanGlow.opacity(0.42), lineWidth: 0.8)
                    )
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding(.top, 76)
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
        }
        .frame(maxWidth: .infinity, minHeight: dynamicTypeSize.isAccessibilitySize ? 500 : 420)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var mapPlaceholderHint: some View {
        VStack(spacing: 8) {
            Image(systemName: "map")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(AppColors.cyanGlow.opacity(0.78))
            Text(missingMapText)
                .font(.system(size: 13, weight: .semibold, design: .default))
                .foregroundStyle(Color.white.opacity(0.72))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [
                    AppColors.cyanGlow.opacity(0.08),
                    Color.clear,
                    AppColors.dutchOrange.opacity(0.06)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .accessibilityHidden(true)
    }

    private func selectProvince(_ hit: ProvinceHitZone) {
        withAnimation(.easeInOut(duration: 0.18)) {
            selectedProvinceID = hit.id
            tooltipProvinceID = hit.id
        }

        Task { @MainActor in
            do {
                try await Task.sleep(for: .seconds(2.5))
                if tooltipProvinceID == hit.id {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        tooltipProvinceID = nil
                    }
                }
            } catch is CancellationError {
                return
            }
        }
    }

    private var mapHeader: some View {
        HStack(alignment: .top, spacing: 12) {
            mapTitleBlock
            Spacer(minLength: 8)
            cityLegendPill
        }
    }

    private var mapTitleBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 25, weight: .heavy, design: .default))
                .foregroundStyle(.white)
                .lineLimit(3)
                .minimumScaleFactor(0.84)
                .fixedSize(horizontal: false, vertical: true)
            Text(subtitle)
                .font(.system(size: 14, weight: .medium, design: .default))
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(3)
                .minimumScaleFactor(0.88)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var cityLegendPill: some View {
        Label(cityLegend, systemImage: "mappin.circle.fill")
            .font(.system(size: 12, weight: .black, design: .rounded))
            .foregroundStyle(AppColors.dutchOrange)
            .lineLimit(2)
            .minimumScaleFactor(0.80)
            .padding(.horizontal, 11)
            .padding(.vertical, 8)
            .background(AppColors.dutchOrange.opacity(0.10))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(AppColors.dutchOrange.opacity(0.18), lineWidth: 0.7))
    }

    private var mapFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(mapFilters, id: \.id) { filter in
                    Button {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            selectedFilterID = filter.id
                        }
                    } label: {
                        Text(filter.title)
                            .font(.system(size: 11, weight: .semibold, design: .default))
                            .foregroundStyle(selectedFilterID == filter.id ? .white : AppColors.textSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.80)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedFilterID == filter.id ? AppColors.dutchOrange : Color.white.opacity(0.055))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(selectedFilterID == filter.id ? Color.clear : Color.white.opacity(0.07), lineWidth: 0.7)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var mapFooter: some View {
        HStack(spacing: 12) {
            legendRow
            Spacer(minLength: 8)
            openMapButton
        }
    }

    private var legendRow: some View {
        HStack(spacing: 12) {
            legendDot(color: AppColors.dutchOrange, title: locationLegend)
            legendDot(color: AppColors.softBlue, title: cityLegend)
        }
    }

    private var openMapButton: some View {
        Button(action: onOpenMap) {
            Label(openMapLabel, systemImage: "arrow.right")
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(AppColors.cyanGlow)
                .lineLimit(2)
                .minimumScaleFactor(0.84)
                .frame(minWidth: 44, minHeight: 44)
                .padding(.horizontal, 12)
                .background(AppColors.cyanGlow.opacity(0.08))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(AppColors.cyanGlow.opacity(0.20), lineWidth: 0.7))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func legendDot(color: Color, title: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 9, height: 9)
                .shadow(color: color.opacity(0.52), radius: 5)
            Text(title)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.textTertiary)
                .lineLimit(1)
                .minimumScaleFactor(0.74)
        }
    }

    private var locationLegend: String {
        switch language {
        case .russian: return "Вы"
        case .dutch: return "Jij"
        case .english: return "You"
        }
    }

    private var cityLegend: String {
        switch language {
        case .russian: return "Города"
        case .dutch: return "Steden"
        case .english: return "Cities"
        }
    }

    private var missingMapText: String {
        switch language {
        case .russian: return "Карта загружается. Провинции и города появятся здесь."
        case .dutch: return "Kaart wordt geladen. Provincies en steden verschijnen hier."
        case .english: return "Map is loading. Provinces and cities will appear here."
        }
    }

    private var mapFilters: [(id: String, title: String)] {
        switch language {
        case .russian:
            return [("provinces", "Провинции"), ("cities", "Города"), ("services", "Сервисы"), ("fines", "Штрафы")]
        case .dutch:
            return [("provinces", "Provincies"), ("cities", "Steden"), ("services", "Services"), ("fines", "Boetes")]
        case .english:
            return [("provinces", "Provinces"), ("cities", "Cities"), ("services", "Services"), ("fines", "Fines")]
        }
    }
}

private struct HomeRealisticNetherlandsMapCanvas: View {
    let selectedProvinceID: String?
    let selectedCity: String
    let glowPhase: Double

    private static let cities: [(name: String, x: CGFloat, y: CGFloat, labelX: CGFloat, labelY: CGFloat, anchor: UnitPoint)] = [
        ("Groningen", 0.73, 0.15, 0.62, 0.11, .trailing),
        ("Amsterdam", 0.30, 0.41, 0.36, 0.36, .leading),
        ("Leiden", 0.21, 0.58, 0.28, 0.53, .leading),
        ("The Hague", 0.16, 0.62, 0.10, 0.58, .trailing),
        ("Rotterdam", 0.23, 0.66, 0.31, 0.66, .leading),
        ("Utrecht", 0.43, 0.58, 0.51, 0.55, .leading),
        ("Eindhoven", 0.55, 0.84, 0.62, 0.80, .leading),
        ("Maastricht", 0.76, 0.94, 0.70, 0.98, .trailing)
    ]

    private static let provinceLabels: [(name: String, x: CGFloat, y: CGFloat)] = [
        ("Groningen", 0.78, 0.24),
        ("Friesland", 0.48, 0.18),
        ("Drenthe", 0.70, 0.35),
        ("Overijssel", 0.73, 0.59),
        ("Flevoland", 0.49, 0.44),
        ("Noord-Holland", 0.25, 0.32),
        ("Utrecht", 0.43, 0.67),
        ("Gelderland", 0.64, 0.75),
        ("Zuid-Holland", 0.19, 0.75),
        ("Zeeland", 0.19, 0.84),
        ("Noord-Brabant", 0.47, 0.91),
        ("Limburg", 0.72, 0.87)
    ]

    var body: some View {
        ZStack {
            Canvas { context, size in
                let rect = Self.mapRect(in: size)
                drawProvinceOverlay(in: &context, rect: rect)
                drawProvinceLabels(in: &context, rect: rect)
                drawCities(in: &context, rect: rect)
            }
        }
        .allowsHitTesting(false)
    }

    private static var mapPadding: EdgeInsets {
        EdgeInsets(top: 18, leading: 38, bottom: 28, trailing: 38)
    }

    fileprivate static func mapRect(in size: CGSize) -> CGRect {
        let paddedWidth = max(1, size.width - mapPadding.leading - mapPadding.trailing)
        let paddedHeight = max(1, size.height - mapPadding.top - mapPadding.bottom)
        let aspect: CGFloat = 0.54
        let fittedHeight = min(paddedHeight, paddedWidth / aspect)
        let fittedWidth = fittedHeight * aspect
        return CGRect(
            x: mapPadding.leading + (paddedWidth - fittedWidth) / 2,
            y: mapPadding.top + (paddedHeight - fittedHeight) / 2,
            width: fittedWidth,
            height: fittedHeight
        )
    }

    private func drawProvinceOverlay(in context: inout GraphicsContext, rect: CGRect) {
        let countryPath = RealProvinceMapData.countryPath(in: rect.size).offsetBy(dx: rect.minX, dy: rect.minY)

        for province in RealProvinceMapData.provinces {
            let path = province.path(in: rect.size).offsetBy(dx: rect.minX, dy: rect.minY)
            let isSelected = selectedProvinceID == province.id
            context.fill(path, with: .color(isSelected ? AppColors.dutchOrange.opacity(0.20) : Color.clear))
            context.stroke(
                path,
                with: .color(Color.white.opacity(isSelected ? 0.60 : 0.24)),
                lineWidth: isSelected ? 1.6 : 0.65
            )
        }

        context.stroke(countryPath, with: .color(Color.white.opacity(0.34)), lineWidth: 1.1)
    }

    private func drawProvinceLabels(in context: inout GraphicsContext, rect: CGRect) {
        for label in Self.provinceLabels {
            context.draw(
                Text(label.name)
                    .font(.system(size: 6.2, weight: .semibold, design: .default))
                    .foregroundStyle(Color.white.opacity(selectedProvinceID == label.name ? 0.95 : 0.56)),
                at: p(label.x, label.y, rect),
                anchor: .center
            )
        }
    }

    private func drawCities(in context: inout GraphicsContext, rect: CGRect) {
        for city in Self.cities {
            let center = p(city.x, city.y, rect)
            let isSelected = city.name == selectedCity
            let radius: CGFloat = isSelected ? 6.2 : 4.4

            context.fill(
                Path(ellipseIn: CGRect(x: center.x - radius * 2, y: center.y - radius * 2, width: radius * 4, height: radius * 4)),
                with: .color((isSelected ? AppColors.dutchOrange : AppColors.softBlue).opacity(isSelected ? 0.20 : 0.10))
            )
            context.fill(
                Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)),
                with: .color(isSelected ? AppColors.dutchOrange : AppColors.softBlue)
            )
            context.stroke(
                Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)),
                with: .color(Color.white.opacity(0.78)),
                lineWidth: 1
            )
            context.draw(
                Text(city.name)
                    .font(.system(size: 6.8, weight: .black, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.90)),
                at: p(city.labelX, city.labelY, rect),
                anchor: city.anchor
            )
        }
    }

    fileprivate static func hitTestCity(_ point: CGPoint) -> String? {
        cities.first { city in
            hypot(point.x - city.x, point.y - city.y) <= 0.045
        }?.name
    }

    private func p(_ x: CGFloat, _ y: CGFloat, _ rect: CGRect) -> CGPoint {
        CGPoint(x: rect.minX + x * rect.width, y: rect.minY + y * rect.height)
    }
}

private struct FeaturedCityStatChip: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 18, weight: .semibold, design: .default))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text(title)
                .font(.system(size: 11.5, weight: .regular, design: .default))
                .foregroundStyle(Color.white.opacity(0.70))
                .lineLimit(3)
                .minimumScaleFactor(0.76)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 13)
        .padding(.vertical, 11)
        .background(Color.black.opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct LifeScenarioCard: View {
    let scenario: HomeLifeScenario
    let language: AppLanguage
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            HomeImageFill(asset: scenario.asset, accent: scenario.accent)

            LinearGradient(
                colors: [
                    Color.black.opacity(0.02),
                    AppColors.navyDeep.opacity(0.34),
                    AppColors.navyDeep.opacity(0.94)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 5) {
                Text(scenario.title(language))
                    .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 27 : 24, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(3)
                    .minimumScaleFactor(0.78)
                    .fixedSize(horizontal: false, vertical: true)

                Text(scenario.subtitle(language))
                    .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 16 : 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.74))
                    .lineLimit(3)
                    .minimumScaleFactor(0.82)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity, minHeight: dynamicTypeSize.isAccessibilitySize ? 280 : 236)
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(LinearGradient(colors: [Color.white.opacity(0.20), scenario.accent.opacity(0.22), Color.white.opacity(0.06)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
        )
        .shadow(color: scenario.accent.opacity(0.16), radius: 26, x: 0, y: 14)
    }
}

private struct PremiumAssistantField: View {
    let phase: TimeInterval

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(
                x: size.width * (0.72 + CGFloat(sin(phase * 0.11)) * 0.04),
                y: size.height * (0.28 + CGFloat(cos(phase * 0.09)) * 0.05)
            )

            context.fill(
                Path(ellipseIn: CGRect(x: center.x - 150, y: center.y - 150, width: 300, height: 300)),
                with: .radialGradient(
                    Gradient(colors: [AppColors.cyanGlow.opacity(0.34), AppColors.cyanGlow.opacity(0.02), .clear]),
                    center: center,
                    startRadius: 0,
                    endRadius: 150
                )
            )

            let orangeCenter = CGPoint(x: size.width * 0.12, y: size.height * 0.82)
            context.fill(
                Path(ellipseIn: CGRect(x: orangeCenter.x - 120, y: orangeCenter.y - 120, width: 240, height: 240)),
                with: .radialGradient(
                    Gradient(colors: [AppColors.dutchOrange.opacity(0.20), AppColors.dutchOrange.opacity(0.02), .clear]),
                    center: orangeCenter,
                    startRadius: 0,
                    endRadius: 130
                )
            )

            for index in 0..<11 {
                let progress = CGFloat(index) / 10
                let x = size.width * (0.10 + progress * 0.78)
                let y = size.height * (0.20 + CGFloat(sin(phase * 0.20 + Double(index))) * 0.18 + progress * 0.18)
                let rect = CGRect(x: x, y: y, width: index.isMultiple(of: 3) ? 3.2 : 2.0, height: index.isMultiple(of: 3) ? 3.2 : 2.0)
                context.fill(Path(ellipseIn: rect), with: .color(Color.white.opacity(index.isMultiple(of: 2) ? 0.20 : 0.11)))
            }

            var wave = Path()
            wave.move(to: CGPoint(x: -size.width * 0.08, y: size.height * 0.64))
            wave.addCurve(
                to: CGPoint(x: size.width * 1.08, y: size.height * 0.44),
                control1: CGPoint(x: size.width * 0.24, y: size.height * 0.30),
                control2: CGPoint(x: size.width * 0.62, y: size.height * 0.82)
            )
            context.stroke(wave, with: .color(Color.white.opacity(0.08)), style: StrokeStyle(lineWidth: 1.1, lineCap: .round, dash: [10, 16]))
        }
    }
}

private struct CityMomentCard: View {
    let moment: HomeCityMoment
    let language: AppLanguage
    let width: CGFloat
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            HomeImageFill(asset: moment.asset, accent: moment.accent)
            LinearGradient(colors: [AppColors.navyDeep.opacity(0.20), AppColors.navyDeep.opacity(0.94)], startPoint: .top, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 7) {
                Text(moment.title(language))
                    .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 24 : 21, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(3)
                    .minimumScaleFactor(0.80)
                    .fixedSize(horizontal: false, vertical: true)
                Text(moment.subtitle(language))
                    .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 18 : 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.78))
                    .lineLimit(3)
                    .minimumScaleFactor(0.84)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(18)
        }
        .frame(width: width)
        .frame(height: dynamicTypeSize.isAccessibilitySize ? 314 : 248)
        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 34, style: .continuous).stroke(Color.white.opacity(0.16), lineWidth: 1))
        .shadow(color: moment.accent.opacity(0.13), radius: 24, x: 0, y: 14)
    }
}

private struct HomeUnifiedVisualBackdrop: View {
    let asset: AppImageAsset?
    let accent: Color

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 4 / 255, green: 8 / 255, blue: 18 / 255),
                    Color(red: 8 / 255, green: 20 / 255, blue: 38 / 255),
                    AppSurface.base
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [accent.opacity(0.16), .clear],
                center: UnitPoint(x: 0.02, y: 0.05),
                startRadius: 0,
                endRadius: 430
            )

            RadialGradient(
                colors: [AppColors.dutchOrange.opacity(0.10), .clear],
                center: UnitPoint(x: 1.03, y: 0.16),
                startRadius: 0,
                endRadius: 390
            )

            RadialGradient(
                colors: [AppColors.violet.opacity(0.08), .clear],
                center: UnitPoint(x: 0.82, y: 0.92),
                startRadius: 0,
                endRadius: 520
            )

            LinearGradient(
                colors: [
                    Color.white.opacity(0.045),
                    Color.clear,
                    Color.black.opacity(0.22)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            DutchFlagRibbon(opacity: 0.035)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private struct HomeImageFill: View {
    let asset: AppImageAsset?
    let accent: Color
    var contentMode: ContentMode = .fill

    var body: some View {
        ZStack {
            fallback

            if let localAssetName = asset?.localAssetName, VisualAssetHelper.exists(localAssetName) {
                Image(localAssetName)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if let url = asset?.thumbnailURL ?? asset?.imageURL ?? asset?.url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: contentMode)
                    case .empty, .failure:
                        fallback
                    @unknown default:
                        fallback
                    }
                }
            }

            LinearGradient(
                colors: [
                    Color.white.opacity(0.03),
                    Color.clear,
                    AppColors.navyDeep.opacity(0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .allowsHitTesting(false)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }

    private var fallback: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.navyDeep.opacity(0.96), accent.opacity(0.28), AppColors.graphite.opacity(0.86)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            DutchFlagRibbon(opacity: 0.18)
            AbstractCanalLines(color: accent, lineCount: 3)
                .opacity(0.28)
        }
    }

}

// MARK: - Netherlands Map Canvas

private struct NetherlandsMapCanvas: View {
    let glowPhase: Double
    let selectedCity: String

    // Approximate Netherlands silhouette — North Holland peninsula top-left,
    // Frisian coast across top, German border on right, Belgian border at bottom,
    // Zeeland & North Sea coast on left.
    private let nlOutline: [(CGFloat, CGFloat)] = [
        // North Holland tip (Den Helder)
        (0.20, 0.08),
        // Frisian coast eastward
        (0.32, 0.03),
        (0.48, 0.01),
        // Groningen coast
        (0.66, 0.03),
        (0.80, 0.06),
        // East: German border going south
        (0.92, 0.12),
        (0.97, 0.24),
        (0.96, 0.38),
        (0.94, 0.52),
        // Gelderland / Limburg east
        (0.90, 0.62),
        (0.86, 0.72),
        // Maastricht / south Limburg
        (0.80, 0.82),
        (0.72, 0.90),
        // South: Belgian border going west
        (0.58, 0.96),
        (0.42, 0.97),
        // Zeeland delta
        (0.28, 0.94),
        (0.18, 0.86),
        // West: North Sea coast going north
        (0.10, 0.76),
        (0.08, 0.64),
        (0.08, 0.50),
        (0.10, 0.38),
        // Hook of Holland — narrows toward North Holland
        (0.12, 0.28),
        (0.14, 0.20),
        (0.18, 0.13),
        // Back to Den Helder
        (0.20, 0.08)
    ]

    private let cities: [(name: String, x: CGFloat, y: CGFloat)] = [
        ("Amsterdam",  0.38, 0.26),
        ("Rotterdam",  0.24, 0.68),
        ("Den Haag",   0.17, 0.72),
        ("Utrecht",    0.44, 0.50),
        ("Eindhoven",  0.56, 0.76),
        ("Groningen",  0.73, 0.12),
        ("Maastricht", 0.70, 0.90),
        ("Leiden",     0.22, 0.60)
    ]

    var body: some View {
        Canvas { context, size in
            let scaleX = size.width
            let scaleY = size.height

            let countryPath = RealProvinceMapData.countryPath(in: size)
            context.fill(countryPath, with: .color(AppColors.cyanGlow.opacity(0.045 + 0.02 * glowPhase)))

            for province in RealProvinceMapData.provinces {
                let path = province.path(in: size)
                context.fill(path, with: .color(AppColors.softBlue.opacity(0.070)))
                context.stroke(path, with: .color(AppColors.routeLine.opacity(0.30)), lineWidth: 0.7)
            }
            context.stroke(countryPath, with: .color(AppColors.cyanGlow.opacity(0.42)), lineWidth: 1.2)

            // City dots and labels
            for city in cities {
                let cx = city.x * scaleX
                let cy = city.y * scaleY
                let isSelected = city.name == selectedCity

                // Glow ring for selected city
                if isSelected {
                    let ringRect = CGRect(x: cx - 14, y: cy - 14, width: 28, height: 28)
                    context.fill(Path(ellipseIn: ringRect), with: .radialGradient(
                        Gradient(colors: [AppColors.dutchOrange.opacity(0.38 + 0.20 * glowPhase), .clear]),
                        center: CGPoint(x: cx, y: cy), startRadius: 0, endRadius: 14
                    ))
                }

                let radius: CGFloat = isSelected ? 5.5 : 3.2
                let dotRect = CGRect(x: cx - radius, y: cy - radius, width: radius * 2, height: radius * 2)
                let dotColor = isSelected ? AppColors.dutchOrange : AppColors.cyanGlow.opacity(0.80)
                context.fill(Path(ellipseIn: dotRect), with: .color(dotColor))

                // White border around dot
                context.stroke(Path(ellipseIn: dotRect.insetBy(dx: -0.6, dy: -0.6)), with: .color(Color.white.opacity(isSelected ? 0.60 : 0.28)), lineWidth: 0.7)
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Quick Action Chip (vertical layout — no word break)

private struct QuickActionChip: View {
    let action: HomeQuickAction
    let language: AppLanguage

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                LinearGradient(
                    colors: [action.accent, action.accent.opacity(0.68)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                Image(systemName: action.icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
            }
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .shadow(color: action.accent.opacity(0.32), radius: 9, x: 0, y: 4)

            Text(action.title(language))
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.78)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 132)
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .background(GlassPanelBackground(accent: action.accent, cornerRadius: 20))
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// MARK: - Home Category Card

private struct HomeCategoryCard: View {
    let category: HomeCategoryItem
    let language: AppLanguage
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                accent.opacity(0.22),
                                accent.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: dynamicTypeSize.isAccessibilitySize ? 96 : 88)

                Circle()
                    .fill(accent.opacity(0.12))
                    .frame(width: 60, height: 60)
                    .offset(x: 50, y: -15)

                Text(emoji)
                    .font(.system(size: 32))
                    .padding(14)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(category.title(language))
                    .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 15 : 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
                    .fixedSize(horizontal: false, vertical: true)

                Text(subtitle)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundStyle(.white.opacity(0.40))
                    .lineLimit(2)
                    .minimumScaleFactor(0.70)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, minHeight: dynamicTypeSize.isAccessibilitySize ? 198 : 178, alignment: .topLeading)
        .background(Color(red: 17 / 255, green: 28 / 255, blue: 46 / 255))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(accent.opacity(0.20), lineWidth: 0.8)
        )
        .overlay(alignment: .top) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(accent.opacity(0.60))
                .frame(height: 1.5)
                .padding(.horizontal, 12)
        }
        .shadow(color: accent.opacity(0.12), radius: 12, y: 4)
    }

    private var accent: Color {
        category.gradient.first ?? AppColors.dutchOrange
    }

    private var emoji: String {
        switch category.id {
        case "government": return "🏛"
        case "healthcare": return "❤️"
        case "transport": return "🚌"
        case "education": return "🎓"
        case "law": return "⚖️"
        case "emergency": return "📞"
        case "financial": return "💳"
        case "documents": return "📋"
        case "police": return "🛡"
        case "integration": return "🌍"
        case "social": return "🤝"
        case "lgbtq": return "🏳️‍🌈"
        case "ukraine": return "🇺🇦"
        case "refugees": return "👥"
        case "fines": return "⚠️"
        case "culture": return "🎭"
        case "history": return "📜"
        case "places": return "📍"
        case "language": return "🇳🇱"
        default: return "✨"
        }
    }

    private var subtitle: String {
        switch (category.id, language) {
        case ("government", .russian): return "Gemeente и службы"
        case ("government", .dutch): return "Gemeente & diensten"
        case ("government", .english): return "Services near you"
        case ("healthcare", .russian): return "GP и страховка"
        case ("healthcare", .dutch): return "Huisarts & verzekering"
        case ("healthcare", .english): return "GP & insurance"
        case ("transport", .russian): return "OV и велосипед"
        case ("transport", .dutch): return "OV & fiets"
        case ("transport", .english): return "OV & bike"
        case ("education", .russian): return "KNM и учёба"
        case ("education", .dutch): return "KNM & studie"
        case ("education", .english): return "KNM & study"
        case ("law", .russian): return "Права и защита"
        case ("law", .dutch): return "Rechten & hulp"
        case ("law", .english): return "Rights & help"
        case ("emergency", .russian): return "112 и помощь"
        case ("emergency", .dutch): return "112 & hulp"
        case ("emergency", .english): return "112 & crisis"
        case ("financial", .russian): return "Банк и налоги"
        case ("financial", .dutch): return "Bank & belasting"
        case ("financial", .english): return "Bank & taxes"
        case ("documents", .russian): return "BSN, DigiD"
        case ("documents", .dutch): return "BSN, DigiD"
        case ("documents", .english): return "BSN, DigiD"
        case ("language", .russian): return "A1-A2 и фразы"
        case ("language", .dutch): return "A1-A2 & zinnen"
        case ("language", .english): return "A1-A2 & phrases"
        default:
            return category.title(language)
        }
    }
}

// MARK: - History Culture Card

private struct HistoryCultureCard: View {
    let item: HistoryCultureItem
    let language: AppLanguage
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [AppColors.navyDeep, item.accent.opacity(0.30), AppColors.navyDeep.opacity(0.92)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )

            AbstractCanalLines(color: item.accent, lineCount: 3)
                .opacity(0.18)

            VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    Circle()
                        .fill(item.accent.opacity(0.22))
                        .frame(width: 48, height: 48)
                    Image(systemName: item.icon)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(item.accent)
                }

                Spacer()

                Text(item.title(language))
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(3)
                    .minimumScaleFactor(0.82)
                    .fixedSize(horizontal: false, vertical: true)

                Text(item.subtitle(language))
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.72))
                    .lineLimit(3)
                    .minimumScaleFactor(0.84)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(18)
        }
        .frame(width: dynamicTypeSize.isAccessibilitySize ? 244 : 212, height: dynamicTypeSize.isAccessibilitySize ? 252 : 214)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(LinearGradient(colors: [item.accent.opacity(0.38), Color.white.opacity(0.10)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
        )
        .shadow(color: item.accent.opacity(0.18), radius: 20, x: 0, y: 10)
    }
}

// MARK: - News Item Row

private struct NewsItemRow: View {
    let item: HomeNewsItem
    let language: AppLanguage

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                item.accent.opacity(0.15)
                Image(systemName: item.icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(item.accent)
            }
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title(language))
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(3)
                    .minimumScaleFactor(0.84)
                    .fixedSize(horizontal: false, vertical: true)
                Text(item.subtitle(language))
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(3)
                    .minimumScaleFactor(0.84)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(AppColors.textTertiary)
                .padding(.top, 4)
        }
        .padding(14)
        .background(GlassPanelBackground(accent: item.accent, cornerRadius: 20))
    }
}

private struct HomeHeroButtonStyle: ButtonStyle {
    let tint: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 13)
            .background(
                LinearGradient(
                    colors: [
                        Color.white.opacity(configuration.isPressed ? 0.18 : 0.12),
                        tint.opacity(configuration.isPressed ? 0.22 : 0.14)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(Color.white.opacity(configuration.isPressed ? 0.20 : 0.11), lineWidth: 0.8))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.24, dampingFraction: 0.78), value: configuration.isPressed)
    }
}

private struct HomePrimaryHeroButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .background(AppColors.dutchOrange.opacity(configuration.isPressed ? 0.82 : 0.96))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: AppColors.dutchOrange.opacity(configuration.isPressed ? 0.20 : 0.34), radius: 18, x: 0, y: 8)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.68), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed {
#if canImport(UIKit)
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
#endif
                }
            }
    }
}

private struct HomeSecondaryIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .background(Color.white.opacity(configuration.isPressed ? 0.18 : 0.11))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.16), lineWidth: 0.8)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

private struct HeroActionLabel: View {
    let title: String
    let symbol: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.system(size: 14, weight: .semibold))
                .frame(width: 16)
            Text(title)
                .font(.system(size: 12.5, weight: .semibold, design: .default))
                .lineLimit(2)
                .minimumScaleFactor(0.72)
                .multilineTextAlignment(.center)
                .allowsTightening(true)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 46)
    }
}

#if DEBUG && os(iOS)
private struct HomeViewPreviewContainer: View {
    @StateObject private var appState: AppStateViewModel
    @StateObject private var languageManager: LanguageManager
    @StateObject private var savedItemsStore = SavedItemsStore()
    @StateObject private var documentStore = DocumentStore()
    @StateObject private var router = TabRouter()
    @State private var selectedTab: AppTab = .home

    init(language: AppLanguage, status: UserStatus? = nil, city: String = "Leiden") {
        let manager = LanguageManager()
        manager.appLanguage = language
        _languageManager = StateObject(wrappedValue: manager)

        let state = AppStateViewModel()
        state.selectedUserStatus = status
        state.selectedCity = city
        _appState = StateObject(wrappedValue: state)
    }

    var body: some View {
        NavigationStack {
            HomeView(selectedTab: $selectedTab)
                .navigationDestination(for: AppDestination.self) { destination in
                    AppDestinationView(destination: destination)
                }
        }
        .environmentObject(appState)
        .environmentObject(languageManager)
        .environmentObject(savedItemsStore)
        .environmentObject(documentStore)
        .environmentObject(router)
    }
}

#Preview("Home RU - iPhone 15", traits: .fixedLayout(width: 390, height: 844)) {
    HomeViewPreviewContainer(language: .russian)
        .environment(\.dynamicTypeSize, .large)
        .transaction { $0.animation = nil }
}

#Preview("Home EN - iPhone SE", traits: .fixedLayout(width: 375, height: 667)) {
    HomeViewPreviewContainer(language: .english)
        .environment(\.dynamicTypeSize, .large)
        .transaction { $0.animation = nil }
}

#Preview("Home NL - iPhone 15 Pro Max", traits: .fixedLayout(width: 430, height: 932)) {
    HomeViewPreviewContainer(language: .dutch, city: "Amsterdam")
        .environment(\.dynamicTypeSize, .accessibility2)
        .transaction { $0.animation = nil }
}

#Preview("Home Map Section - iPhone 15", traits: .fixedLayout(width: 390, height: 844)) {
    ZStack {
        GlobalBackgroundView()
        VStack(alignment: .leading, spacing: 16) {
            Text("Netherlands Map")
                .font(.system(size: 26, weight: .semibold, design: .default))
                .foregroundStyle(.white)
            Text("Explore provinces, cities and services through the interactive map.")
                .font(.system(size: 15, weight: .regular, design: .default))
                .foregroundStyle(Color.white.opacity(0.70))
            HomeRealisticNetherlandsMapCard(
                title: "Interactive Map",
                subtitle: "Tap a province or city",
                openMapLabel: "Explore Map",
                selectedCity: "Leiden",
                language: .english,
                glowPhase: 0.45,
                onOpenMap: {}
            )
        }
        .padding(.horizontal, 16)
    }
    .environment(\.dynamicTypeSize, .large)
    .transaction { $0.animation = nil }
}
#endif
