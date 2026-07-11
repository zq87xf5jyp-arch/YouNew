import SwiftUI

struct RootHomeView: View {
    @Binding var selectedTab: AppTab
    var onAskAI: () -> Void = {}
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var savedStore: SavedItemsStore
    @EnvironmentObject private var router: TabRouter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isHeaderSearchExpanded = false
    @StateObject private var connectivity = ConnectivityStatus.shared

    private var language: AppLanguage { languageManager.appLanguage }
    private var selectedCity: String { ProvinceCatalog.localizedCityName(appState.selectedCity, language) }
    private var personaTags: Set<String> {
        Set([appState.selectedUserStatus?.personaTag.rawValue].compactMap { $0 })
    }
    private var recommendations: [ContentItem] {
        ContentRepository.shared.homeReferences(audienceTags: personaTags, limit: 4)
            .compactMap(ContentRepository.shared.item(id:))
    }
    private var nearbyPlaces: [NearbyPlace] {
        Array(MockNearbyPlacesData.places.filter { $0.city.caseInsensitiveCompare(appState.selectedCity) == .orderedSame }.prefix(3))
    }
    @MainActor private var cityHeroAssetName: String {
        let placeID = NLCity.all.first { $0.name.caseInsensitiveCompare(appState.selectedCity) == .orderedSame }?.placeId
        return placeID
            .flatMap(LocalNetherlandsImagePackRegistry.cityHero(placeId:))?
            .localAssetName ?? "home_leiden_canals"
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 18) {
                    Color.clear.frame(height: 1).id("home.top")
                    premiumHeader.staggeredAppear(index: 0)
                    if !connectivity.isOnline {
                        offlineStatus.staggeredAppear(index: 1)
                    }
                    cityHeader.staggeredAppear(index: 2)
                    globalSearch.staggeredAppear(index: 2)
                    urgentHelp.staggeredAppear(index: 3)
                    nextActions.staggeredAppear(index: 4)
                    categoryShortcuts.staggeredAppear(index: 5)
                    cityGallery.staggeredAppear(index: 6)
                    recentlyViewed.staggeredAppear(index: 7)
                    savedSummary.staggeredAppear(index: 8)
                    nearbySection.staggeredAppear(index: 9)
                    recommendationSection.staggeredAppear(index: 10)
                    Color.clear.frame(height: AppSpacing.tabBarScrollReserve)
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)
            }
            .accessibilityIdentifier("home.scrollContent")
            .safeAreaPadding(.top, 4)
            .onReceive(router.homeScrollTop) {
                withAnimation(.easeInOut(duration: 0.22)) {
                    proxy.scrollTo("home.top", anchor: .top)
                }
            }
        }
        .accessibilityIdentifier("screen.home")
    }

    private var premiumHeader: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text("YouNew")
                        .font(.system(.title2, design: .serif).weight(.bold))
                    Text("🇳🇱")
                        .font(.footnote)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(AppColors.glassSurfaceElevated, in: Capsule())
                }
                Text(localized(en: "Your Netherlands guide", nl: "Jouw gids voor Nederland", ru: "Ваш гид по Нидерландам"))
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .foregroundStyle(AppColors.textPrimary)
            Spacer(minLength: 8)
            HStack(spacing: 6) {
                if isHeaderSearchExpanded {
                    NavigationLink(value: AppDestination.searchList) {
                        Text(localized(en: "Search all", nl: "Alles zoeken", ru: "Искать везде"))
                            .font(AppTypography.footnoteStrong)
                            .lineLimit(1)
                            .padding(.leading, 10)
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
                Button {
                    withAnimation(reduceMotion ? nil : AppAnimations.softSpring) {
                        isHeaderSearchExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isHeaderSearchExpanded ? "xmark" : "magnifyingglass")
                        .font(.body.weight(.semibold))
                        .frame(width: 44, height: 44)
                }
            }
            .background(AppColors.glassSurfaceElevated, in: Capsule())
            .accessibilityLabel(localized(en: "Search", nl: "Zoeken", ru: "Поиск"))
            .buttonStyle(AppPressableButtonStyle())
            NavigationLink(value: AppDestination.profileSelection) {
                Image(systemName: "person.fill")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        LinearGradient(colors: [AppColors.dutchOrange, AppColors.routeLine], startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: Circle()
                    )
            }
            .accessibilityLabel(localized(en: "Profile", nl: "Profiel", ru: "Профиль"))
            .buttonStyle(AppPressableButtonStyle())
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("home.premiumHeader")
    }

    private var cityHeader: some View {
        NavigationLink(value: AppDestination.cityList) {
            ZStack(alignment: .bottomLeading) {
                Image(cityHeroAssetName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, minHeight: 158, maxHeight: 158)
                    .clipped()
                LinearGradient(
                    colors: [.clear, AppColors.navyDeep.opacity(0.92)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                HStack(alignment: .bottom, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(localized(en: "Your city", nl: "Jouw stad", ru: "Ваш город"))
                        .font(AppTypography.footnote.weight(.semibold))
                        .foregroundStyle(AppColors.textSecondary)
                    Text(selectedCity)
                        .font(.title.bold())
                        .foregroundStyle(AppColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Label(
                        localized(en: "Weather and local services", nl: "Weer en lokale diensten", ru: "Погода и городские сервисы"),
                        systemImage: "cloud.sun.fill"
                    )
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.warning)
                    .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 6)
                Image(systemName: "location.fill")
                    .font(.title2.bold())
                    .foregroundStyle(AppColors.dutchOrange)
                    .accessibilityHidden(true)
                }
                .padding(16)
            }
            .frame(height: 158)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(AppColors.dutchOrange.opacity(0.22), lineWidth: 0.8))
        }
        .buttonStyle(.plain)
        .immersiveTilt(intensity: 3.2)
        .accessibilityIdentifier("home.currentCity")
    }

    private var offlineStatus: some View {
        Label(
            localized(en: "Offline · local guides and saved content remain available", nl: "Offline · lokale gidsen en opgeslagen inhoud blijven beschikbaar", ru: "Офлайн · локальные гайды и сохранённое доступны"),
            systemImage: "wifi.slash"
        )
        .font(AppTypography.captionStrong)
        .foregroundStyle(AppColors.warning)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(AppColors.warning.opacity(0.10), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .accessibilityIdentifier("home.offlineStatus")
    }

    private var globalSearch: some View {
        HStack(spacing: 10) {
            NavigationLink(value: AppDestination.searchList) {
                HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.headline.bold())
                Text(localized(en: "Search guides, services and places", nl: "Zoek gidsen, diensten en plekken", ru: "Поиск материалов, сервисов и мест"))
                    .font(AppTypography.body.weight(.semibold))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 4)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button(action: onAskAI) {
                Image(systemName: "sparkles")
                    .font(.headline.bold())
                    .foregroundStyle(AppColors.violet)
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(localized(en: "Open AI assistant", nl: "Open AI-assistent", ru: "Открыть AI-помощника"))
            .accessibilityHint(localized(en: "Opens the assistant without starting a search", nl: "Opent de assistent zonder te zoeken", ru: "Открывает помощника без запуска поиска"))
            .accessibilityIdentifier("home.aiButton")
        }
        .foregroundStyle(AppColors.textPrimary)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .frame(minHeight: 64)
        .appGlassCardStyle(padding: 0, cornerRadius: 20, accent: AppColors.cyanGlow)
        .accessibilityIdentifier("home.globalSearch")
    }

    private var urgentHelp: some View {
        NavigationLink(value: AppDestination.emergencyHub) {
            Label(
                localized(en: "Urgent help", nl: "Dringende hulp", ru: "Срочная помощь"),
                systemImage: "cross.case.fill"
            )
            .font(.headline.bold())
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(minHeight: 56)
            .background(AppColors.error.gradient, in: RoundedRectangle(cornerRadius: 19, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityHint(localized(en: "Opens emergency actions and official numbers", nl: "Opent noodacties en officiële nummers", ru: "Открывает экстренные действия и официальные номера"))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("home.urgentHelp")
    }

    private var nextActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(localized(en: "Next actions", nl: "Volgende stappen", ru: "Следующие действия"))
            actionRow("checklist", title: localized(en: "Continue your checklist", nl: "Ga verder met je checklist", ru: "Продолжить чек-лист"), destination: .checklistList)
            actionRow("doc.text.fill", title: localized(en: "Documents and registration", nl: "Documenten en registratie", ru: "Документы и регистрация"), destination: .firstSteps)
        }
    }

    private var categoryShortcuts: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionTitle(localized(en: "Main categories", nl: "Hoofdcategorieën", ru: "Основные категории"))
                Spacer()
                Button {
                    selectedTab = .guide
                } label: {
                    Text(localized(en: "View Guide", nl: "Open Gids", ru: "Открыть Гид"))
                }
                .font(AppTypography.footnote.weight(.semibold))
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: 10)], spacing: 10) {
                ForEach(Array(Array(Category.canonical.sorted { $0.displayOrder < $1.displayOrder }.prefix(6)).enumerated()), id: \.element.id) { index, category in
                    NavigationLink(value: categoryDestination(category.id)) {
                        HStack(spacing: 10) {
                            Image(systemName: categorySymbol(category.id))
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.white)
                                .frame(width: 34, height: 34)
                                .background(.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
                            Text(categoryTitle(category))
                                .font(AppTypography.footnote.weight(.semibold))
                                .foregroundStyle(.white)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: 2)
                            Image(systemName: "arrow.up.right")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(.white.opacity(0.66))
                                .accessibilityHidden(true)
                        }
                        .frame(maxWidth: .infinity, minHeight: 58, alignment: .leading)
                        .padding(.horizontal, 12)
                        .background(
                            LinearGradient(colors: categoryGradient(category.id), startPoint: .topLeading, endPoint: .bottomTrailing),
                            in: RoundedRectangle(cornerRadius: 17, style: .continuous)
                        )
                        .overlay(RoundedRectangle(cornerRadius: 17, style: .continuous).stroke(.white.opacity(0.08)))
                    }
                    .buttonStyle(AppPressableCardButtonStyle())
                    .staggeredAppear(index: index)
                }
            }
        }
    }

    private var cityGallery: some View {
        let motionEnabled = !reduceMotion
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionTitle(localized(en: "Netherlands in focus", nl: "Nederland in beeld", ru: "Нидерланды в кадре"))
                Spacer()
                NavigationLink(value: AppDestination.cityList) {
                    Text(localized(en: "View all", nl: "Bekijk alles", ru: "Смотреть всё"))
                        .font(AppTypography.footnote.weight(.semibold))
                }
                .buttonStyle(AppPressableButtonStyle())
            }

            ScrollView(.horizontal) {
                LazyHStack(spacing: 12) {
                    ForEach(PremiumGalleryItem.items) { item in
                        NavigationLink(value: AppDestination.cityList) {
                            ZStack(alignment: .bottomLeading) {
                                Image(item.assetName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 244, height: 154)
                                    .clipped()
                                LinearGradient(colors: [.clear, AppColors.navyDeep.opacity(0.90)], startPoint: .center, endPoint: .bottom)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(item.title(language))
                                        .font(AppTypography.cardTitle)
                                        .foregroundStyle(.white)
                                    Text(item.subtitle(language))
                                        .font(AppTypography.caption)
                                        .foregroundStyle(.white.opacity(0.76))
                                }
                                .padding(14)
                            }
                            .frame(width: 244, height: 154)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(.white.opacity(0.10)))
                        }
                        .buttonStyle(AppPressableCardButtonStyle())
                        .immersiveTilt(intensity: 2.2)
                        .contextMenu {
                            Button {
                                selectedTab = .map
                            } label: {
                                Label(localized(en: "Open Map", nl: "Open kaart", ru: "Открыть карту"), systemImage: "map")
                            }
                            Button {
                                selectedTab = .guide
                            } label: {
                                Label(localized(en: "Open Guide", nl: "Open gids", ru: "Открыть Гид"), systemImage: "books.vertical")
                            }
                        }
                        .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                            content
                                .scaleEffect(motionEnabled ? 1 - abs(phase.value) * 0.06 : 1)
                                .offset(x: motionEnabled ? phase.value * -18 : 0)
                                .opacity(motionEnabled ? 1 - abs(phase.value) * 0.14 : 1)
                        }
                    }
                }
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .accessibilityIdentifier("home.cityGallery")
        }
    }

    private var nearbySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionTitle(localized(en: "Useful nearby", nl: "Handig in de buurt", ru: "Полезное рядом"))
                Spacer()
                Button { selectedTab = .map } label: {
                    Text(localized(en: "Open Map", nl: "Open kaart", ru: "Открыть карту"))
                }
                .font(AppTypography.footnote.weight(.semibold))
            }
            if nearbyPlaces.isEmpty {
                emptyRow(localized(en: "Nearby services will appear here.", nl: "Diensten in de buurt verschijnen hier.", ru: "Здесь появятся полезные места и сервисы рядом."))
            } else {
                ForEach(nearbyPlaces) { place in
                    NavigationLink(value: AppDestination.mapFocus(.place(place.saveKey))) {
                        HStack(spacing: 12) {
                            Image(systemName: place.discoverySymbolName)
                                .foregroundStyle(AppColors.cyanGlow)
                                .frame(width: 36, height: 36)
                                .background(AppColors.cyanGlow.opacity(0.12), in: RoundedRectangle(cornerRadius: 11))
                            VStack(alignment: .leading, spacing: 3) {
                                Text(place.localizedName(language))
                                    .font(AppTypography.body.weight(.semibold))
                                    .foregroundStyle(AppColors.textPrimary)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text(place.address)
                                    .font(AppTypography.footnote)
                                    .foregroundStyle(AppColors.textSecondary)
                                    .lineLimit(2)
                            }
                            Spacer(minLength: 4)
                            Image(systemName: "chevron.right").accessibilityHidden(true)
                        }
                        .padding(13)
                        .appGlassCardStyle(padding: 0, cornerRadius: 17, accent: AppColors.cyanGlow)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var recentlyViewed: some View {
        let topics = appState.visibleRecentlyViewedTopics().prefix(3)
        return VStack(alignment: .leading, spacing: 12) {
            sectionTitle(localized(en: "Recently viewed", nl: "Recent bekeken", ru: "Недавно просмотренное"))
            if topics.isEmpty {
                emptyRow(localized(en: "Your recently opened guides will appear here.", nl: "Recent geopende gidsen verschijnen hier.", ru: "Здесь появятся недавно открытые материалы."))
            } else {
                ForEach(Array(topics), id: \.self) { topic in
                    Text(appState.displayTitle(forRecentlyViewedTopic: topic, language: language))
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                        .appGlassCardStyle(padding: 0, cornerRadius: 17, accent: AppColors.softBlue)
                }
            }
        }
    }

    private var savedSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(localized(en: "Saved", nl: "Bewaard", ru: "Сохранённое"))
            Button {
                selectedTab = .saved
            } label: {
                HStack {
                    Label(localized(en: "Saved items", nl: "Bewaarde items", ru: "Сохранённые материалы"), systemImage: "bookmark.fill")
                    Spacer()
                    Text("\(savedStore.savedItems.count)")
                        .font(.headline.monospacedDigit())
                }
                .font(AppTypography.body.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)
                .padding(15)
                .appGlassCardStyle(padding: 0, cornerRadius: 18, accent: AppColors.softBlue)
            }
            .buttonStyle(.plain)
        }
    }

    private var recommendationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(localized(en: "Recommended for you", nl: "Aanbevolen voor jou", ru: "Рекомендовано для вас"))
            ForEach(recommendations) { item in
                if let destination = ContentRepository.shared.legacyDestination(id: item.id) {
                    NavigationLink(value: destination) {
                        recommendationRow(item)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier(item.id == recommendations.last?.id ? "home.lastElement" : "home.recommendation.\(item.id)")
                }
            }
        }
    }

    private func recommendationRow(_ item: ContentItem) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(item.title)
                .font(AppTypography.body.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Text(item.shortDescription)
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .appGlassCardStyle(padding: 0, cornerRadius: 18, accent: AppColors.violet)
    }

    private func actionRow(_ icon: String, title: String, destination: AppDestination) -> some View {
        NavigationLink(value: destination) {
            Label(title, systemImage: icon)
                .font(AppTypography.body.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .appGlassCardStyle(padding: 0, cornerRadius: 17, accent: AppColors.cyanGlow)
                .fixedSize(horizontal: false, vertical: true)
        }
        .buttonStyle(.plain)
    }

    private func emptyRow(_ text: String) -> some View {
        Text(text)
            .font(AppTypography.footnote)
            .foregroundStyle(AppColors.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .appGlassCardStyle(padding: 0, cornerRadius: 17, accent: AppColors.softBlue)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.title3.bold())
            .foregroundStyle(AppColors.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func categoryDestination(_ id: String) -> AppDestination {
        switch id {
        case "getting-started": return .firstSteps
        case "housing": return .practicalGuide(.housingBasics)
        case "official-services": return .officialSources
        case "work-money": return .guideSection("work")
        case "study": return .languageHub
        case "health-safety": return .practicalGuide(.healthcareBasics)
        case "transport": return .practicalGuide(.transportBasics)
        default: return .cultureAttractions
        }
    }

    private func categoryTitle(_ category: Category) -> String {
        switch language {
        case .english: return category.title
        case .dutch: return category.localTitle["nl"] ?? category.title
        case .russian: return category.localTitle["ru"] ?? category.title
        }
    }

    private func categorySymbol(_ id: String) -> String {
        switch id {
        case "getting-started": return "figure.walk"
        case "housing": return "house.fill"
        case "official-services": return "building.columns.fill"
        case "work-money": return "briefcase.fill"
        case "study": return "graduationcap.fill"
        case "health-safety": return "cross.case.fill"
        case "transport": return "tram.fill"
        default: return "sailboat.fill"
        }
    }

    private func categoryGradient(_ id: String) -> [Color] {
        switch id {
        case "getting-started": return [AppColors.routeLine, AppColors.accent]
        case "housing": return AppColors.gradHousing
        case "official-services": return AppColors.gradGovernment
        case "work-money": return AppColors.gradWork
        case "study": return AppColors.gradEducation
        case "health-safety": return AppColors.gradHealth
        case "transport": return AppColors.gradTransport
        default: return [AppColors.dutchOrange, AppColors.warning]
        }
    }

    private func localized(en: String, nl: String, ru: String) -> String {
        switch language {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }
}

private struct PremiumGalleryItem: Identifiable {
    let id: String
    let assetName: String
    let enTitle: String
    let nlTitle: String
    let ruTitle: String
    let enSubtitle: String
    let nlSubtitle: String
    let ruSubtitle: String

    func title(_ language: AppLanguage) -> String {
        switch language { case .english: enTitle; case .dutch: nlTitle; case .russian: ruTitle }
    }

    func subtitle(_ language: AppLanguage) -> String {
        switch language { case .english: enSubtitle; case .dutch: nlSubtitle; case .russian: ruSubtitle }
    }

    static let items = [
        PremiumGalleryItem(id: "leiden", assetName: "nl_leiden_hero_01", enTitle: "Leiden", nlTitle: "Leiden", ruTitle: "Лейден", enSubtitle: "Canals and university life", nlSubtitle: "Grachten en studentenleven", ruSubtitle: "Каналы и университетская жизнь"),
        PremiumGalleryItem(id: "amsterdam", assetName: "nl_amsterdam_hero_01", enTitle: "Amsterdam", nlTitle: "Amsterdam", ruTitle: "Амстердам", enSubtitle: "Museums, neighbourhoods and services", nlSubtitle: "Musea, buurten en diensten", ruSubtitle: "Музеи, районы и сервисы"),
        PremiumGalleryItem(id: "rotterdam", assetName: "nl_rotterdam_hero_01", enTitle: "Rotterdam", nlTitle: "Rotterdam", ruTitle: "Роттердам", enSubtitle: "Architecture and working city", nlSubtitle: "Architectuur en werkstad", ruSubtitle: "Архитектура и деловой город")
    ]
}
