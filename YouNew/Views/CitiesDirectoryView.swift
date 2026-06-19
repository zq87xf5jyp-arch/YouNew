import SwiftUI

struct CitiesDirectoryView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var searchText = ""

    private var lang: AppLanguage { languageManager.appLanguage }

    private var filteredCities: [CitySpotlightData] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return ProvinceCatalog.citySpotlights }
        return ProvinceCatalog.citySpotlights.filter { spotlight in
            [
                spotlight.city.localizedName(lang),
                spotlight.city.name,
                spotlight.province.localizedName(lang),
                spotlight.city.municipality,
                spotlight.city.localizedShortDescription(lang)
            ]
            .joined(separator: " ")
            .lowercased()
            .contains(query)
        }
    }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 920) {
                LazyVStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    headerSection
                    searchField
                    prioritySection
                    allCitiesSection
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
        CategoryHeroVisual(
            assetName: "home_leiden_canals",
            title: titleText,
            subtitle: subtitleText,
            symbol: "building.2.fill",
            badgeText: badgeText,
            accent: AppColors.softBlue
        )
    }

    private var searchField: some View {
        HStack(spacing: AppSpacing.small) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColors.textTertiary)

            TextField(searchPlaceholder, text: $searchText)
                .font(AppTypography.body)
                .nlTextInputAutocapitalizationWords()
                .disableAutocorrection(true)
        }
        .padding(.horizontal, 14)
        .frame(minHeight: 50)
        .background(AppColors.cardElevated)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous)
                .stroke(AppColors.stroke.opacity(0.7), lineWidth: 0.8)
        }
    }

    @ViewBuilder
    private var prioritySection: some View {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                NLSectionHeader(title: priorityTitle)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 156), spacing: AppSpacing.small)], spacing: AppSpacing.small) {
                    ForEach(ProvinceCatalog.citySpotlights.filter { ProvinceCatalog.priorityCityNames.contains($0.city.name) }) { spotlight in
                        NavigationLink(value: AppDestination.cityDetail(province: spotlight.province.id, city: spotlight.city.name)) {
                            cityTile(spotlight)
                        }
                        .buttonStyle(NLTileButtonStyle())
                    }
                }
            }
        }
    }

    private var allCitiesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: allCitiesTitle)

            LazyVStack(spacing: AppSpacing.small) {
                ForEach(filteredCities) { spotlight in
                    NavigationLink(value: AppDestination.cityDetail(province: spotlight.province.id, city: spotlight.city.name)) {
                        cityRow(spotlight)
                    }
                    .buttonStyle(NLTileButtonStyle())
                }
            }
        }
    }

    private func cityTile(_ spotlight: CitySpotlightData) -> some View {
        let resolvedImage = CanonicalPlaceImageResolver.resolveCityThumbnail(city: spotlight.city)
        return ZStack(alignment: .bottomLeading) {
            CityImageView(
                urlString: resolvedImage.urlString,
                height: 152,
                placeId: spotlight.city.placeId,
                cityName: spotlight.city.localizedName(lang),
                fallbackColor: spotlight.province.mapHighlightColor,
                fallbackURLStrings: resolvedImage.fallbackURLStrings,
                debugContext: resolvedImage.debugContext(
                    screen: "Cities directory tile",
                    entityType: "city",
                    entityName: spotlight.city.localizedName(lang)
                )
            )
            .frame(maxWidth: .infinity)
            .frame(height: 152)

            LinearGradient(
                colors: [
                    .black.opacity(0.06),
                    .black.opacity(0.22),
                    .black.opacity(0.82)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .allowsHitTesting(false)

            Image(systemName: ProvinceCatalog.identityIconName(for: spotlight.city.name))
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(.black.opacity(0.30))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(.white.opacity(0.18), lineWidth: 0.8)
                )
                .padding(12)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)

            VStack(alignment: .leading, spacing: 4) {
                Text(spotlight.city.localizedName(lang))
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                Text(spotlight.province.localizedName(lang))
                    .font(AppTypography.caption)
                    .foregroundStyle(.white.opacity(0.76))
                    .lineLimit(1)
            }
            .padding(14)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 152)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 0.8)
        )
        .shadow(color: .black.opacity(0.18), radius: 14, x: 0, y: 8)
    }

    private func cityRow(_ spotlight: CitySpotlightData) -> some View {
        let resolvedImage = CanonicalPlaceImageResolver.resolveCityThumbnail(city: spotlight.city)
        return HStack(spacing: AppSpacing.medium) {
            ZStack(alignment: .bottomLeading) {
                CityImageView(
                    urlString: resolvedImage.urlString,
                    height: 78,
                    placeId: spotlight.city.placeId,
                    cityName: spotlight.city.localizedName(lang),
                    fallbackColor: spotlight.province.mapHighlightColor,
                    fallbackURLStrings: resolvedImage.fallbackURLStrings,
                    debugContext: resolvedImage.debugContext(
                        screen: "Cities directory row",
                        entityType: "city",
                        entityName: spotlight.city.localizedName(lang)
                    )
                )
                .frame(width: 96, height: 78)
                .clipped()

                LinearGradient(
                    colors: [.clear, .black.opacity(0.72)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                Image(systemName: ProvinceCatalog.identityIconName(for: spotlight.city.name))
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
                    .background(.black.opacity(0.32))
                    .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                    .padding(8)
            }
            .frame(width: 96, height: 78)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(spotlight.city.localizedName(lang))
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                Text("\(spotlight.province.localizedName(lang)) • \(spotlight.city.population)")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(AppColors.textTertiary)
        }
        .padding(10)
        .appCardStyle()
    }

    private var titleText: String {
        switch lang {
        case .russian: return "Города"
        case .dutch: return "Steden"
        case .english: return "Cities"
        }
    }

    private var subtitleText: String {
        switch lang {
        case .russian: return "Поддерживаемые города с практической информацией, картой и официальными ссылками."
        case .dutch: return "Ondersteunde steden met praktische informatie, kaart en officiële links."
        case .english: return "Supported cities with practical info, maps, and official links."
        }
    }

    private var badgeText: String {
        switch lang {
        case .russian: return "Каталог"
        case .dutch: return "Gids"
        case .english: return "Directory"
        }
    }

    private var searchPlaceholder: String {
        switch lang {
        case .russian: return "Найти город"
        case .dutch: return "Zoek stad"
        case .english: return "Search city"
        }
    }

    private var priorityTitle: String {
        switch lang {
        case .russian: return "Популярные города"
        case .dutch: return "Belangrijke steden"
        case .english: return "Key cities"
        }
    }

    private var allCitiesTitle: String {
        switch lang {
        case .russian: return "Все города"
        case .dutch: return "Alle steden"
        case .english: return "All cities"
        }
    }
}
