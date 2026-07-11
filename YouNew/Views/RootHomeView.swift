import SwiftUI

struct RootHomeView: View {
    @Binding var selectedTab: AppTab
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var savedStore: SavedItemsStore
    @EnvironmentObject private var router: TabRouter

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
    private var cityHeroAssetName: String {
        let placeID = NLCity.all.first { $0.name.caseInsensitiveCompare(appState.selectedCity) == .orderedSame }?.placeId
        return placeID
            .flatMap(LocalNetherlandsImagePackRegistry.cityHero(placeId:))?
            .localAssetName ?? "home_leiden_canals"
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 22) {
                    Color.clear.frame(height: 1).id("home.top")
                    cityHeader
                    globalSearch
                    urgentHelp
                    nextActions
                    categoryShortcuts
                    recentlyViewed
                    savedSummary
                    nearbySection
                    recommendationSection
                    Color.clear.frame(height: AppSpacing.tabBarScrollReserve)
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)
            }
            .safeAreaPadding(.top, 4)
            .onReceive(router.homeScrollTop) {
                withAnimation(.easeInOut(duration: 0.22)) {
                    proxy.scrollTo("home.top", anchor: .top)
                }
            }
        }
        .accessibilityIdentifier("screen.home")
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
        .accessibilityIdentifier("home.currentCity")
    }

    private var globalSearch: some View {
        NavigationLink(value: AppDestination.searchList) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.headline.bold())
                Text(localized(en: "Search guides, services and places", nl: "Zoek gidsen, diensten en plekken", ru: "Поиск материалов, сервисов и мест"))
                    .font(AppTypography.body.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 4)
                Image(systemName: "sparkles")
                    .foregroundStyle(AppColors.violet)
                    .accessibilityLabel(localized(en: "AI assistance available", nl: "AI-hulp beschikbaar", ru: "Доступна помощь AI"))
            }
            .foregroundStyle(AppColors.textPrimary)
            .padding(16)
            .appGlassCardStyle(padding: 0, cornerRadius: 20, accent: AppColors.cyanGlow)
        }
        .buttonStyle(.plain)
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
            .padding(16)
            .background(AppColors.error.gradient, in: RoundedRectangle(cornerRadius: 19, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityHint(localized(en: "Opens emergency actions and official numbers", nl: "Opent noodacties en officiële nummers", ru: "Открывает экстренные действия и официальные номера"))
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
                    Text(localized(en: "View Guide", nl: "Open Gids", ru: "Открыть Guide"))
                }
                .font(AppTypography.footnote.weight(.semibold))
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: 10)], spacing: 10) {
                ForEach(Array(Category.canonical.sorted { $0.displayOrder < $1.displayOrder }.prefix(6))) { category in
                    NavigationLink(value: categoryDestination(category.id)) {
                        Text(categoryTitle(category))
                            .font(AppTypography.footnote.weight(.semibold))
                            .foregroundStyle(AppColors.textPrimary)
                            .frame(maxWidth: .infinity, minHeight: 50, alignment: .leading)
                            .padding(.horizontal, 12)
                            .background(AppColors.cardElevated.opacity(0.72), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .buttonStyle(.plain)
                }
            }
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

    private func localized(en: String, nl: String, ru: String) -> String {
        switch language {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }
}
