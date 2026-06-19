import SwiftUI
import MapKit
import CoreLocation

struct NearbyMapView: View {
    private enum Layout {
        static let xSmall: CGFloat = 6
        static let small: CGFloat = 10
        static let medium: CGFloat = 16
        static let sectionGap: CGFloat = 16
        static let screenHorizontal: CGFloat = AppLayout.pagePadding
        static let cornerRadius: CGFloat = 16
    }

    private enum Palette {
        static let accent = AppColors.accent
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let stroke = Color.secondary.opacity(0.24)
    }

    @StateObject private var viewModel: MapViewModel
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var savedItemsStore: SavedItemsStore
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var mapCameraPosition: MapCameraPosition = .automatic
    @State private var selectedProvinceID: String?
    @State private var didConfigureInitialState = false
    @State private var showInteractiveMap = false
    @State private var showFullScreenMap = false
    @State private var visiblePlacesLimit = 6
    private let initialFocus: MapFocus?
    private let initialCategory: PlaceCategory?
    private let provinceOverviewItems: [ProvinceItem]

    private var lang: AppLanguage { languageManager.appLanguage }

    init(initialFocus: MapFocus? = nil, initialCategory: PlaceCategory? = nil, viewModel: MapViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? MapViewModel())
        self.initialFocus = initialFocus
        self.initialCategory = initialCategory
        self.provinceOverviewItems = ProvinceCatalog.all
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollViewReader { scrollProxy in
                ScrollView {
                    ResponsiveContentContainer(maxWidth: 920) {
                        LazyVStack(alignment: .leading, spacing: Layout.sectionGap) {
                            cityHubHeader
                            citySpotlightCard
                            journeyPresetCard
                            trustAndLocationRow
                            manualCityPicker
                            mapSearchCard
                            provincesOverviewCard
                                .id(MapScrollAnchor.provinceMap.rawValue)
                            mapSection
                                .id(MapScrollAnchor.visualMap.rawValue)
                            journeyGuideSection
                            placesListSection
                                .id(MapScrollAnchor.nearbyPlaces.rawValue)
                            Color.clear.frame(height: bottomScrollReserve(safeAreaBottom: proxy.safeAreaInsets.bottom))
                        }
                        .padding(.horizontal, Layout.screenHorizontal)
                        .padding(.top, 14)
                    }
                }
                .onAppear {
                    configureInitialState(scrollProxy: scrollProxy)
                    scheduleInteractiveMapLoad()
                }
            }
        }
        .appSceneBackground(.map)
        .navigationTitle(L10n.t("nearby.title", lang))
        .onChange(of: viewModel.selectedCity) { _, newCity in
            appState.selectedCity = newCity
            visiblePlacesLimit = 6
        }
        .onChange(of: viewModel.selectedCategory) { _, newCategory in
            appState.defaultMapCategory = newCategory
            visiblePlacesLimit = 6
        }
        .onChange(of: viewModel.selectedQuickFilter) { _, _ in visiblePlacesLimit = 6 }
        .onChange(of: viewModel.selectedFocus) { _, _ in visiblePlacesLimit = 6 }
        .onChange(of: viewModel.searchText) { _, _ in visiblePlacesLimit = 6 }
        .onChange(of: appState.preferredMapCategory) { _, newCategory in
            guard let newCategory else { return }
            withAnimation(AppAnimations.standard) {
                applyPreferredCategory(newCategory)
            }
            appState.preferredMapCategory = nil
        }
        .onChange(of: lang) { _, newLanguage in
            viewModel.language = newLanguage
        }
        .onChange(of: appState.pendingMapFocus) { _, newFocus in
            applyExternalFocus(newFocus, clearAfterApply: true)
        }
        .onChange(of: appState.selectedUserStatus) { _, newStatus in
            viewModel.activePersona = newStatus?.personaTag
            if let status = newStatus {
                viewModel.applyProfilePriority(status: status)
            }
            visiblePlacesLimit = 6
        }
        .sheet(item: $viewModel.selectedPlace) { place in
            NavigationStack {
                PlaceDetailView(
                    place: place,
                    distanceText: viewModel.distancePlaceholderText(for: place, language: lang),
                    travelTimeText: viewModel.travelTimePlaceholder(for: place, mode: viewModel.selectedTravelMode, language: lang),
                    onOpenMaps: {
                        appState.showToast(L10n.t("map.opened_apple_maps", lang))
                        viewModel.openInAppleMaps(place)
                    },
                    onOpenWalkRoute: {
                        appState.showToast(L10n.t("map.route_walking", lang))
                        viewModel.openInAppleMaps(place, mode: .walking)
                    },
                    onOpenTransitRoute: {
                        appState.showToast(L10n.t("map.route_transit", lang))
                        viewModel.openInAppleMaps(place, mode: .transit)
                    },
                    onOpenCyclingRoute: {
                        appState.showToast(L10n.t("map.route_cycling", lang))
                        viewModel.openInAppleMaps(place, mode: .cycling)
                    },
                    onToggleSaved: {
                        savedItemsStore.toggle(
                            id: place.saveKey,
                            kind: .place,
                            title: place.name,
                            subtitle: "\(place.city) · \(place.category.localized(lang))",
                            destination: .mapHub
                        )
                    },
                    isSaved: savedItemsStore.isSaved(place.saveKey),
                    relatedLinks: viewModel.relatedLinks(for: place)
                )
                .navigationDestination(for: AppDestination.self) {
                    AppDestinationView(destination: $0)
                }
            }
            .presentationDetents([.medium, .large])
            .presentationBackground(.regularMaterial)
        }
        .nlFullScreenCover(isPresented: $showFullScreenMap) {
            NearbyFullScreenMapView(
                viewModel: viewModel,
                lang: lang,
                annotationColor: annotationColor(for:),
                onDismiss: { showFullScreenMap = false }
            )
        }
    }

    private enum MapScrollAnchor: String {
        case visualMap
        case provinceMap
        case nearbyPlaces
    }

    private func bottomScrollReserve(safeAreaBottom: CGFloat) -> CGFloat {
        FloatingTabBarMetrics.height
            + FloatingTabBarMetrics.bottomOffset
            + safeAreaBottom
            + AppLayout.bottomNavReserveExtra
    }

    private func configureInitialState(scrollProxy: ScrollViewProxy) {
        guard !didConfigureInitialState else { return }
        didConfigureInitialState = true

        viewModel.language = lang
        viewModel.activePersona = appState.selectedUserStatus?.personaTag
        let focusToApply = initialFocus ?? appState.pendingMapFocus
        if let focusToApply {
            applyExternalFocus(focusToApply, clearAfterApply: initialFocus == nil)
        } else if MockNearbyPlacesData.supportedCities.contains(appState.selectedCity) {
            viewModel.selectedCity = appState.selectedCity
            viewModel.applyCityCenter()
        }

        let targetAnchor: MapScrollAnchor
        if let focusToApply {
            switch focusToApply {
            case .province(let provinceId):
                selectedProvinceID = provinceId
                targetAnchor = .provinceMap
            case .city:
                targetAnchor = .visualMap
            case .place:
                targetAnchor = .nearbyPlaces
            case .transport, .healthcare, .government, .education, .emergency, .category:
                targetAnchor = .visualMap
            }
        } else {
            targetAnchor = .visualMap
            if let preferred = initialCategory ?? appState.preferredMapCategory ?? appState.defaultMapCategory {
                applyPreferredCategory(preferred)
                if initialCategory == nil, appState.preferredMapCategory != nil {
                    appState.preferredMapCategory = nil
                }
            } else if let status = appState.selectedUserStatus {
                viewModel.applyProfilePriority(status: status)
            }
        }

        if appState.useCurrentLocationForMap {
            viewModel.useMyLocation()
        }

        if initialFocus != nil {
            Task { @MainActor in
                withAnimation(AppAnimations.standard) {
                    scrollProxy.scrollTo(targetAnchor.rawValue, anchor: .top)
                }
            }
        }
    }

    private func applyExternalFocus(_ focus: MapFocus?, clearAfterApply: Bool) {
        guard let focus else { return }
        viewModel.applyFocus(focus)
        appState.selectedCity = viewModel.selectedCity

        if case .province(let provinceId) = focus {
            selectedProvinceID = provinceId
        }

        if clearAfterApply {
            appState.pendingMapFocus = nil
        }
    }

    private func applyPreferredCategory(_ category: PlaceCategory) {
        viewModel.selectedFocus = nil
        viewModel.selectedQuickFilter = nil
        viewModel.selectedCategory = category
        visiblePlacesLimit = 6
    }

    private func scheduleInteractiveMapLoad() {
        guard !showInteractiveMap else { return }
        Task { @MainActor in
            do {
                try await Task.sleep(for: .seconds(0.22))
                showInteractiveMap = true
            } catch is CancellationError {
                return
            }
        }
    }

    private var cityHubHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L10n.t("nearby.title", lang))
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .accessibilityIdentifier("map.screen")
            Text(cityHeaderSubtitle)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(2)
                .accessibilityIdentifier(mapFocusIdentifier)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var mapFocusIdentifier: String {
        guard let focus = viewModel.selectedFocus else { return "map.focus.none" }
        return "map.focus.\(identifierSegment(focus.rawValue))"
    }

    private var provincesOverviewCard: some View {
        VStack(alignment: .leading, spacing: Layout.small) {
            NavigationLink(value: AppDestination.provinceList) {
                HStack(spacing: 10) {
                    Text(L10n.t("nearby.all_provinces", lang))
                        .font(AppTypography.sectionTitle)
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.white.opacity(0.7))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Text(L10n.t("nearby.choose_region", lang))
                .font(AppTypography.footnote)
                .foregroundStyle(Color.white.opacity(0.78))

            if let selectedProvinceID,
               let province = provinceOverviewItems.first(where: { $0.id == selectedProvinceID }) {
                HStack(spacing: 12) {
                    ProvinceMapSilhouette(provinceID: province.id, accent: province.mapHighlightColor)
                        .frame(width: 86, height: 106)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(provinceDisplayName(province))
                            .font(.system(.title3, design: .rounded).weight(.bold))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                        Text(provinceCapitalSummary(province))
                            .font(AppTypography.caption)
                            .foregroundStyle(Color.white.opacity(0.72))
                            .lineLimit(3)
                    }
                    Spacer(minLength: 0)
                }
                .padding(12)
                .background(province.mapHighlightColor.opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(province.mapHighlightColor.opacity(0.45), lineWidth: 1)
                )
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(provinceOverviewItems) { province in
                    Button {
                        withAnimation(AppAnimations.standard) {
                            selectedProvinceID = province.id
                            visiblePlacesLimit = 6
                            viewModel.applyFocus(.province(province.id))
                        }
                    } label: {
                        provinceOverviewChip(province)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(14)
        .background(AppColors.navyDeep.opacity(0.55))
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous))
    }

    private func provinceOverviewChip(_ province: ProvinceItem) -> some View {
        let isSelected = selectedProvinceID == province.id

        return HStack(spacing: 6) {
            ProvinceMapSilhouette(provinceID: province.id, accent: province.mapHighlightColor)
                .frame(width: 24, height: 28)
            Text(provinceDisplayName(province))
                .font(AppTypography.caption)
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.74)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isSelected ? province.mapHighlightColor.opacity(0.34) : AppColors.softBlue.opacity(0.25))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(isSelected ? province.mapHighlightColor.opacity(0.78) : Color.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: isSelected ? province.mapHighlightColor.opacity(0.18) : .clear, radius: 10, x: 0, y: 0)
        .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .accessibilityLabel(provinceDisplayName(province))
    }

    private var citySpotlightCard: some View {
        let spotlight = selectedCitySpotlight
        let city = spotlight?.city
        let province = spotlight?.province

        return VStack(alignment: .leading, spacing: 13) {
            HStack(alignment: .top, spacing: 12) {
                cityPreviewImage(city: city, color: province?.mapHighlightColor ?? AppColors.accent)
                VStack(alignment: .leading, spacing: 6) {
                    Text(city?.localizedName(lang) ?? ProvinceCatalog.localizedCityName(viewModel.selectedCity, lang))
                        .font(.system(size: 25, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                    if let city {
                        Text(city.localizedShortDescription(lang))
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.80))
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            LazyVGrid(columns: cityStatColumns, spacing: 8) {
                spotlightStat(title: populationTitle, value: city?.populationText ?? cityPopulation(for: viewModel.selectedCity))
                spotlightStat(title: areaTitle, value: city?.areaText ?? cityArea(for: viewModel.selectedCity))
                spotlightStat(title: provinceTitle, value: province.map(provinceDisplayName) ?? cityProvince(for: viewModel.selectedCity))
            }
        }
        .padding(14)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(AppColors.navyDeep.opacity(0.92))
                CompactCityRouteBackground(tint: province?.mapHighlightColor ?? AppColors.cyanGlow)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var cityStatColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 96), spacing: 8)]
    }

    @ViewBuilder
    private func cityPreviewImage(city: CityItem?, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(color.opacity(0.20))
            if let city {
                let resolvedImage = CanonicalPlaceImageResolver.resolveCityThumbnail(city: city)
                CityImageView(
                    urlString: resolvedImage.urlString,
                    height: 58,
                    placeId: city.placeId,
                    cityName: city.localizedName(lang),
                    fallbackColor: color,
                    fallbackURLStrings: resolvedImage.fallbackURLStrings,
                    debugContext: resolvedImage.debugContext(
                        screen: "Nearby map city preview",
                        entityType: "city",
                        entityName: city.localizedName(lang)
                    )
                )
                .frame(width: 58, height: 58)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                GeneratedCityArtwork(
                    cityName: city?.localizedName(lang) ?? viewModel.selectedCity,
                    symbol: city.map { ProvinceCatalog.identityIconName(for: $0.name) } ?? "building.2.fill",
                    accent: color
                )
            }
        }
        .frame(width: 58, height: 58)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.18), lineWidth: 0.75)
        )
    }

    private func spotlightStat(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.72))
                .lineLimit(1)
                .minimumScaleFactor(0.68)
                .allowsTightening(true)
            Text(value)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.76)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var journeyPresetCard: some View {
        VStack(alignment: .leading, spacing: Layout.small) {
            Text(L10n.t("map.direction_flows", lang))
                .font(.headline.weight(.semibold))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(quickRoutes) { route in
                        quickRouteChip(route)
                    }
                }
                .padding(.horizontal, 2)
                .padding(.trailing, AppSpacing.screenHorizontal)
            }
            .frame(height: 48)
        }
        .appCardStyle()
    }

    private func quickRouteChip(_ route: QuickRouteAction) -> some View {
        let isSelected = route.isSelected(viewModel)

        return Group {
            if let destination = route.destination {
                NavigationLink(value: destination) {
                    quickRouteChipLabel(route, isSelected: false)
                }
            } else {
                Button {
                    withAnimation(AppAnimations.softSpring) {
                        route.apply(viewModel)
                    }
                } label: {
                    quickRouteChipLabel(route, isSelected: isSelected)
                }
            }
        }
        .buttonStyle(AppPressableCardButtonStyle())
        .accessibilityLabel(route.accessibilityLabel(lang))
    }

    private func quickRouteChipLabel(_ route: QuickRouteAction, isSelected: Bool) -> some View {
        Label(route.title(lang), systemImage: route.icon)
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundStyle(isSelected ? .white : AppColors.textPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.80)
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(isSelected ? route.tint : AppColors.cardElevated)
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.white.opacity(0.22) : AppColors.stroke.opacity(0.70), lineWidth: 0.8)
            )
            .clipShape(Capsule())
    }

    private var trustAndLocationRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "location.viewfinder")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(AppColors.cyanGlow)
                    .frame(width: 34, height: 34)
                    .background(AppColors.cyanGlow.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.t("map.trust_privacy", lang))
                        .font(.headline.weight(.semibold))
                    Text(L10n.t("map.data_note", lang))
                        .font(.footnote)
                        .foregroundStyle(Palette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Label(L10n.t("map.no_auto_send", lang), systemImage: "checkmark.shield")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }

            let status = viewModel.locationService.authorizationStatus
            if status == .denied || status == .restricted {
                HStack(spacing: 8) {
                    Image(systemName: "location.slash.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppColors.warning)
                    Text(locationDeniedMessage)
                        .font(.footnote)
                        .foregroundStyle(Palette.textSecondary)
                }
                Button(locationOpenSettingsLabel) {
#if os(iOS)
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
#endif
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.accent)
                .frame(minHeight: AppButtonMetrics.minTouchSize)
                .contentShape(Rectangle())
                .buttonStyle(.plain)
            } else {
                Button(L10n.t("map.use_location", lang)) {
                    viewModel.useMyLocation()
                }
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity, minHeight: 44)
                .buttonStyle(.borderedProminent)
                .tint(AppColors.accent)
                .accessibilityLabel(L10n.t("map.use_location", lang))
            }
        }
        .appCardStyle()
    }

    private var locationDeniedMessage: String {
        switch lang {
        case .russian: return "Доступ к геолокации отключён. Разрешите в настройках."
        case .dutch: return "Locatietoegang is uitgeschakeld. Sta dit toe in Instellingen."
        case .english: return "Location access is disabled. Enable it in Settings."
        }
    }

    private var locationOpenSettingsLabel: String {
        switch lang {
        case .russian: return "Открыть настройки"
        case .dutch: return "Instellingen openen"
        case .english: return "Open Settings"
        }
    }

    private var manualCityPicker: some View {
        HStack(spacing: 12) {
            Image(systemName: "building.2")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(AppColors.cyanGlow)
                .frame(width: 36, height: 36)
                .background(AppColors.cyanGlow.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.t("map.city", lang))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppColors.textSecondary)
                    .textCase(.uppercase)
                Text(ProvinceCatalog.localizedCityName(viewModel.selectedCity, lang))
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .allowsTightening(true)
            }
            .layoutPriority(1)

            Spacer(minLength: 8)

            Menu {
                ForEach(MockNearbyPlacesData.supportedCities, id: \.self) { city in
                    Button(ProvinceCatalog.localizedCityName(city, lang)) {
                        viewModel.selectedCity = city
                        viewModel.applyCityCenter()
                    }
                }
            } label: {
                Label(L10n.t("map.select_city", lang), systemImage: "slider.horizontal.3")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.dutchOrange)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(AppColors.dutchOrange.opacity(0.10))
                    .clipShape(Capsule())
            }
            .frame(minWidth: 104, alignment: .trailing)
        }
        .frame(maxWidth: .infinity, minHeight: 58, alignment: .leading)
        .appCardStyle()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(L10n.t("map.select_city", lang))
    }

    private func categoryChip(
        title: String,
        symbol: String,
        count: Int,
        isSelected: Bool,
        accessibilityIdentifier: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: symbol)
                    .font(.system(size: 13, weight: .semibold))
                Text(title)
                    .font(.system(.footnote, design: .rounded).weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.88)
                    .allowsTightening(true)
                Text("\(count)")
                    .font(.system(.caption2, design: .rounded).weight(.bold))
                    .foregroundStyle(isSelected ? AppColors.accent : AppColors.textSecondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(isSelected ? Color.white.opacity(0.96) : AppColors.chipBackground)
                    .clipShape(Capsule())
            }
            .foregroundStyle(isSelected ? .white : AppColors.textPrimary)
            .padding(.horizontal, 13)
            .padding(.vertical, 9)
            .fixedSize(horizontal: true, vertical: false)
            .background {
                ZStack {
                    Capsule()
                        .fill(isSelected ? AppColors.accent : AppColors.cardElevated)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(isSelected ? 0.18 : 0.08), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.white.opacity(0.22) : AppColors.stroke.opacity(0.85), lineWidth: 0.85)
            )
            .clipShape(Capsule())
            .shadow(color: isSelected ? AppColors.accent.opacity(0.24) : Color.black.opacity(0.10), radius: 10, x: 0, y: 6)
        }
        .buttonStyle(AppPressableCardButtonStyle())
        .accessibilityLabel(String(format: L10n.t("map.places_count_accessibility", lang), title, count))
        .accessibilityIdentifier(accessibilityIdentifier)
    }

    private func accessibilityIdentifier(for category: PlaceCategory) -> String {
        switch category {
        case .legalHelp:
            return "map.chip.legal_help"
        default:
            return "map.chip.\(category.rawValue)"
        }
    }

    private func identifierSegment(_ raw: String) -> String {
        let allowed = CharacterSet.alphanumerics
        let normalized = raw
            .lowercased()
            .unicodeScalars
            .map { allowed.contains($0) ? Character($0) : "." }
        let collapsed = String(normalized)
            .split(separator: ".")
            .joined(separator: ".")
        return collapsed.isEmpty ? "focus" : collapsed
    }

    private var mapSearchCard: some View {
        VStack(alignment: .leading, spacing: Layout.small) {
            Text(L10n.t("map.search_places", lang))
                .font(.headline.weight(.semibold))
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.textSecondary)
                TextField(L10n.t("nearby.search", lang), text: $viewModel.searchText)
                    .nlTextInputAutocapitalizationNever()
                    .autocorrectionDisabled()
                    .onSubmit { viewModel.commitSearch() }
                    .accessibilityLabel(L10n.t("map.search_places", lang))
            }
            .frame(minHeight: 44)
            .padding(.horizontal, 12)
            .background(AppColors.cardElevated)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(AppColors.stroke.opacity(0.75), lineWidth: 0.8)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [GridItem(.fixed(44), spacing: 8)], spacing: 8) {
                    ForEach(searchCategoryActions) { action in
                        searchCategoryButton(action)
                    }
                }
                .padding(.horizontal, 2)
            }
            .frame(height: 48)

            if !viewModel.searchSuggestions.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Layout.xSmall) {
                        ForEach(viewModel.searchSuggestions, id: \.self) { suggestion in
                            Button(suggestion) {
                                viewModel.searchText = suggestion
                                viewModel.commitSearch()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            }

        }
        .appCardStyle()
        .accessibilityIdentifier("map.search.card")
    }

    private var searchCategoryColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 118), spacing: 8)]
    }

    private func searchCategoryButton(_ action: SearchCategoryAction) -> some View {
        let isSelected = action.matches(viewModel)

        return Button {
            withAnimation(AppAnimations.standard) {
                action.apply(viewModel)
            }
        } label: {
            HStack(spacing: 7) {
                Image(systemName: action.icon)
                    .font(.system(size: 13, weight: .bold))
                Text(action.title(lang))
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
            }
            .foregroundStyle(isSelected ? .white : AppColors.textPrimary)
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .padding(.horizontal, 10)
            .background(isSelected ? action.tint : AppColors.chipBackground.opacity(0.82))
            .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .stroke(isSelected ? Color.white.opacity(0.22) : AppColors.stroke.opacity(0.65), lineWidth: 0.75)
            }
        }
        .buttonStyle(AppPressableCardButtonStyle())
        .accessibilityLabel(action.accessibilityLabel(lang))
        .accessibilityIdentifier("map.search.category.\(action.id)")
    }

    private var mapSection: some View {
        Group {
            if showInteractiveMap {
                Map(position: $mapCameraPosition) {
                    if viewModel.mapOverlayRouteCoordinates.count > 1 {
                        MapPolyline(coordinates: viewModel.mapOverlayRouteCoordinates)
                            .stroke(AppColors.routeLine, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round, dash: [7, 6]))
                    }

                    ForEach(viewModel.clusteredPlaces) { cluster in
                        if cluster.count == 1, let place = cluster.places.first {
                            Annotation(place.name, coordinate: place.coordinate) {
                                placeAnnotation(for: place)
                            }
                        } else {
                            Annotation("Cluster", coordinate: cluster.coordinate) {
                                clusterAnnotation(cluster)
                            }
                        }
                    }
                }
                .allowsHitTesting(false)
                .onAppear {
                    mapCameraPosition = .region(viewModel.region)
                }
                .onReceive(viewModel.$region) { newRegion in
                    mapCameraPosition = .region(newRegion)
                }
            } else {
                LightweightNearbyMapPlaceholder(
                    cityName: ProvinceCatalog.localizedCityName(viewModel.selectedCity, lang),
                    placeCount: viewModel.filteredPlaces.count,
                    tint: Palette.accent
                )
            }
        }
        .frame(height: 320)
        .clipShape(RoundedRectangle(cornerRadius: Layout.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Layout.cornerRadius, style: .continuous)
                .stroke(Palette.stroke, lineWidth: 1)
        )
        .overlay(alignment: .topTrailing) {
            Button {
                showFullScreenMap = true
            } label: {
                Label(fullScreenMapLabel, systemImage: "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(Capsule().stroke(Color.white.opacity(0.18), lineWidth: 0.8))
            }
            .buttonStyle(.plain)
            .padding(10)
        }
        .overlay(alignment: .topLeading) {
            VStack(spacing: 0) {
                Text("Map")
                    .font(.caption2)
                    .frame(width: 1, height: 1)
                    .opacity(0.01)
                    .accessibilityIdentifier("map.screen")
                if let focus = viewModel.selectedFocus {
                    Text(focus.rawValue)
                        .font(.caption2)
                        .frame(width: 1, height: 1)
                        .opacity(0.01)
                        .accessibilityIdentifier("map.focus.\(identifierSegment(focus.rawValue))")
                }
            }
            .allowsHitTesting(false)
        }
    }

    private func clusterAnnotation(_ cluster: MapViewModel.PlaceCluster) -> some View {
        Button {
            viewModel.selectCluster(cluster)
        } label: {
            ZStack {
                Circle()
                    .fill(annotationColor(for: cluster.topCategory).opacity(0.9))
                    .frame(width: 42, height: 42)
                Circle()
                    .stroke(Color.white.opacity(0.85), lineWidth: 2)
                    .frame(width: 42, height: 42)
                Text("\(cluster.count)")
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(.white)
            }
            .shadow(color: annotationColor(for: cluster.topCategory).opacity(0.35), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(AppPressableCardButtonStyle())
        .accessibilityLabel(String(format: L10n.t("map.cluster_accessibility", lang), cluster.count))
    }

    private var journeyGuideSection: some View {
        if !viewModel.routeHintSteps.isEmpty {
            return AnyView(
                VStack(alignment: .leading, spacing: Layout.small) {
                    Text(L10n.t("map.guided_route_flow", lang))
                        .font(.headline.weight(.semibold))
                    ForEach(viewModel.routeHintSteps) { step in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(step.title)
                                .font(AppTypography.bodyStrong)
                                .foregroundStyle(AppColors.textPrimary)
                            Text(step.subtitle)
                                .font(AppTypography.footnote)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .appCardStyle()
                    }
                }
            )
        }
        return AnyView(EmptyView())
    }

    private var placesListSection: some View {
        VStack(alignment: .leading, spacing: Layout.small) {
            VStack(alignment: .leading, spacing: Layout.xSmall) {
                Text(L10n.t("nearby.support_points", lang))
                    .font(.title3.weight(.semibold))
                Text(L10n.t("nearby.tap_place", lang))
                    .font(.footnote)
                    .foregroundStyle(Palette.textSecondary)
            }
            ForEach(groupedVisiblePlaceSections) { section in
                VStack(alignment: .leading, spacing: Layout.xSmall) {
                    Label(section.title, systemImage: section.icon)
                        .font(AppTypography.caption)
                        .foregroundStyle(section.color)
                        .textCase(.uppercase)

                    ForEach(section.places) { place in
                        placeRow(place)
                    }
                }
            }
            if viewModel.filteredPlaces.count > visiblePlacesLimit {
                Button {
                    withAnimation(AppAnimations.standard) {
                        visiblePlacesLimit += 6
                    }
                } label: {
                    Label(showMorePlacesTitle, systemImage: "chevron.down.circle.fill")
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColors.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(AppColors.chipBackground.opacity(0.78))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            if viewModel.filteredPlaces.isEmpty {
                InfoCard(
                    title: L10n.t("map.no_places_title", lang),
                    subtitle: L10n.t("map.no_places_subtitle", lang),
                    detail: L10n.t("map.no_places_detail", lang),
                    icon: "mappin.slash"
                )
            }
        }
    }

    private var showMorePlacesTitle: String {
        switch lang {
        case .russian: return "Показать ещё места"
        case .dutch: return "Meer plekken tonen"
        case .english: return "Show more places"
        }
    }

    private var groupedVisiblePlaceSections: [SupportPlaceSection] {
        let visiblePlaces = Array(viewModel.filteredPlaces.prefix(visiblePlacesLimit))
        return SupportPlaceSection.templates(lang).compactMap { template in
            let places = visiblePlaces.filter { template.categories.contains($0.category) }
            guard !places.isEmpty else { return nil }
            return template.withPlaces(places)
        }
    }

    private func placeRow(_ place: NearbyPlace) -> some View {
        Button {
            viewModel.selectPlace(place)
            appState.addRecentlyViewedTopic(place.name)
        } label: {
            HStack(spacing: 10) {
                GlassImageBadge(size: 44, cornerRadius: 13, accent: annotationColor(for: place.category)) {
                    GeneratedCategoryArtwork(
                        symbol: place.category.systemImageName,
                        accent: annotationColor(for: place.category)
                    )
                }
                VStack(alignment: .leading, spacing: Layout.xSmall) {
                    Text(place.localizedName(lang))
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Palette.textPrimary)
                    Text(place.category.localized(lang) + " • " + viewModel.distancePlaceholderText(for: place, language: lang))
                        .font(.caption)
                        .foregroundStyle(Palette.accent)
                    if savedItemsStore.isSaved(place.saveKey) {
                        Text(L10n.t("common.saved", lang))
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.success)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Palette.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .appCardStyle()
        }
        .buttonStyle(.plain)
    }

    private func placeAnnotation(for place: NearbyPlace) -> some View {
        let isSelected = viewModel.selectedPlace?.id == place.id
        return Button {
            viewModel.selectPlace(place)
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(annotationColor(for: place.category).opacity(0.22))
                            .frame(width: 46, height: 46)
                    }
                    Circle()
                        .fill(annotationColor(for: place.category))
                        .frame(width: 36, height: 36)
                    Circle()
                        .stroke(Color.white.opacity(0.85), lineWidth: 2)
                        .frame(width: 36, height: 36)
                    Image(systemName: place.category.systemImageName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                }
                .scaleEffect(isSelected ? 1.12 : 1)
                .shadow(color: annotationColor(for: place.category).opacity(isSelected ? 0.5 : 0.28), radius: isSelected ? 11 : 6, x: 0, y: 3)

                if isSelected {
                    Text(place.name)
                        .font(.caption2)
                        .lineLimit(1)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(AppColors.card.opacity(0.96))
                        .clipShape(Capsule())
                }
            }
        }
        .buttonStyle(AppPressableCardButtonStyle())
        .animation(AppAnimations.softSpring, value: isSelected)
                    .accessibilityLabel("\(place.localizedName(lang)), \(place.category.localized(lang))")
    }

    private func annotationColor(for category: PlaceCategory) -> Color {
        switch category {
        case .municipality:       return AppColors.accent
        case .healthcare:         return AppColors.success
        case .hospital:           return AppColors.success
        case .huisarts:           return AppColors.success
        case .pharmacy:           return AppColors.softBlue
        case .nightPharmacy:      return AppColors.softBlue
        case .police:             return AppColors.warning
        case .library:            return Color(red: 80 / 255, green: 116 / 255, blue: 177 / 255)
        case .transport:          return Color(red: 67 / 255, green: 127 / 255, blue: 149 / 255)
        case .transportOffice:    return Color(red: 67 / 255, green: 127 / 255, blue: 149 / 255)
        case .bikeRepair:         return Color(red: 67 / 255, green: 127 / 255, blue: 149 / 255)
        case .legalHelp:          return Color(red: 126 / 255, green: 99 / 255, blue: 167 / 255)
        case .uwv:                return Color(red: 126 / 255, green: 99 / 255, blue: 167 / 255)
        case .education:          return Color(red: 80 / 255, green: 146 / 255, blue: 120 / 255)
        case .duo:                return Color(red: 80 / 255, green: 146 / 255, blue: 120 / 255)
        case .communitySupport:   return Color(red: 112 / 255, green: 142 / 255, blue: 170 / 255)
        case .foodBank:           return Color(red: 112 / 255, green: 142 / 255, blue: 170 / 255)
        case .shelter:            return Color(red: 112 / 255, green: 142 / 255, blue: 170 / 255)
        case .lgbtqSupport:       return Color(red: 112 / 255, green: 142 / 255, blue: 170 / 255)
        case .animalEmergency:    return Color(red: 112 / 255, green: 142 / 255, blue: 170 / 255)
        case .immigrationSupport: return Color(red: 78 / 255, green: 122 / 255, blue: 168 / 255)
        case .ind:                return Color(red: 78 / 255, green: 122 / 255, blue: 168 / 255)
        case .expatCenter:        return Color(red: 64 / 255, green: 150 / 255, blue: 160 / 255)
        case .studentHelp:        return Color(red: 130 / 255, green: 124 / 255, blue: 177 / 255)
        }
    }

    private func provinceDisplayName(_ province: ProvinceItem) -> String {
        NLProvince.all.first { $0.id == province.id || $0.name == province.id }?.displayName(lang) ?? province.localizedName(lang)
    }

    private func provinceCapitalSummary(_ province: ProvinceItem) -> String {
        let cityName = ProvinceCatalog.localizedCityName(province.capital, lang)
        let activePersona = appState.selectedUserStatus?.personaTag
        let placeCount = MockNearbyPlacesData.places.filter {
            $0.city == province.capital && $0.isVisible(for: activePersona)
        }.count
        return "\(cityName) • \(placeCount) \(supportPointCountLabel(placeCount))"
    }

    private func supportPointCountLabel(_ count: Int) -> String {
        switch lang {
        case .english: return count == 1 ? "point" : "points"
        case .dutch: return count == 1 ? "punt" : "punten"
        case .russian: return count == 1 ? "точка" : "точек"
        }
    }

    private var fullScreenMapLabel: String {
        switch lang {
        case .english: return "Full screen"
        case .dutch: return "Volledig scherm"
        case .russian: return "На весь экран"
        }
    }

    private var provincesTitle: String {
        switch lang {
        case .russian: return "Все провинции"
        case .dutch: return "Alle provincies"
        case .english: return "All provinces"
        }
    }

    private var provincesSubtitle: String {
        switch lang {
        case .russian: return "Выберите регион для просмотра городов и служб"
        case .dutch: return "Kies een regio om steden en diensten te bekijken"
        case .english: return "Choose a region to explore cities and services"
        }
    }

    private var citySpotlightTitle: String {
        switch lang {
        case .russian: return "Город"
        case .dutch: return "Stad"
        case .english: return "City"
        }
    }

    private var populationTitle: String {
        switch lang {
        case .russian: return "Население"
        case .dutch: return "Bevolking"
        case .english: return "Population"
        }
    }

    private var areaTitle: String {
        switch lang {
        case .russian: return "Площадь"
        case .dutch: return "Oppervlakte"
        case .english: return "Area"
        }
    }

    private var provinceTitle: String {
        switch lang {
        case .russian: return "Провинция"
        case .dutch: return "Provincie"
        case .english: return "Province"
        }
    }

    private func cityPopulation(for city: String) -> String {
        switch city {
        case "Amsterdam": return "872 000"
        case "Rotterdam": return "672 000"
        case "Utrecht": return "374 000"
        case "Den Haag": return "565 000"
        case "Leiden": return "127 000"
        case "Eindhoven": return "246 000"
        case "Groningen": return "238 000"
        default: return "—"
        }
    }

    private func cityArea(for city: String) -> String {
        switch city {
        case "Amsterdam": return "219.3 km²"
        case "Rotterdam": return "324.1 km²"
        case "Utrecht": return "99.2 km²"
        case "Den Haag": return "98.1 km²"
        case "Leiden": return "58.0 km²"
        case "Eindhoven": return "88.9 km²"
        case "Groningen": return "180.2 km²"
        default: return "—"
        }
    }

    private func cityProvince(for city: String) -> String {
        ProvinceCatalog.citySpotlight(named: city)?.province.localizedName(lang) ?? fallbackCountryName
    }

    private var selectedCitySpotlight: CitySpotlightData? {
        ProvinceCatalog.citySpotlight(named: viewModel.selectedCity)
    }

    private var fallbackCountryName: String {
        switch lang {
        case .russian: return "Нидерланды"
        case .dutch: return "Nederland"
        case .english: return "Netherlands"
        }
    }

    private var cityHeaderSubtitle: String {
        "\(ProvinceCatalog.localizedCityName(viewModel.selectedCity, lang)) · \(cityProvince(for: viewModel.selectedCity))"
    }

    private var quickRoutes: [QuickRouteAction] {
        [
            QuickRouteAction(kind: .bsn, icon: "person.text.rectangle", tint: AppColors.dutchOrange),
            QuickRouteAction(kind: .healthcare, icon: "cross.case.fill", tint: AppColors.success),
            QuickRouteAction(kind: .digid, icon: "checkmark.shield.fill", tint: AppColors.cyanGlow),
            QuickRouteAction(kind: .transport, icon: "tram.fill", tint: AppColors.routeLine),
            QuickRouteAction(kind: .housing, icon: "house.fill", tint: AppColors.violet),
            QuickRouteAction(kind: .sources, icon: "link", tint: AppColors.softBlue)
        ]
    }

    private var searchCategoryActions: [SearchCategoryAction] {
        let base = [
            SearchCategoryAction(kind: .municipality, category: .municipality, icon: "building.2.fill", tint: AppColors.dutchOrange),
            SearchCategoryAction(kind: .health, category: .huisarts, icon: "stethoscope", tint: AppColors.success),
            SearchCategoryAction(kind: .transport, category: .transport, icon: "tram.fill", tint: AppColors.routeLine),
            SearchCategoryAction(kind: .pharmacy, category: .pharmacy, icon: "pills.fill", tint: AppColors.softBlue),
            SearchCategoryAction(kind: .police, category: .police, icon: "shield.fill", tint: AppColors.warning),
            SearchCategoryAction(kind: .documents, category: .ind, icon: "doc.text.fill", tint: AppColors.cyanGlow),
            SearchCategoryAction(kind: .housing, category: .shelter, icon: "house.fill", tint: AppColors.violet),
            SearchCategoryAction(kind: .education, category: .education, icon: "graduationcap.fill", tint: AppColors.emerald),
            SearchCategoryAction(kind: .library, category: .library, icon: "books.vertical.fill", tint: AppColors.violet),
            SearchCategoryAction(kind: .studentHelp, category: .studentHelp, icon: "studentdesk", tint: AppColors.emerald),
            SearchCategoryAction(kind: .duo, category: .duo, icon: "graduationcap.circle.fill", tint: AppColors.softBlue),
            SearchCategoryAction(kind: .uwv, category: .uwv, icon: "briefcase.circle.fill", tint: AppColors.dutchOrange),
            SearchCategoryAction(kind: .lgbtqSupport, category: .lgbtqSupport, icon: "heart.circle.fill", tint: AppColors.violet)
        ]
        guard let persona = appState.selectedUserStatus?.personaTag else { return base }
        return base.filter { $0.isVisible(for: persona) }
    }

}

private struct QuickRouteAction: Identifiable {
    enum Kind: String {
        case bsn
        case healthcare
        case digid
        case transport
        case housing
        case sources
    }

    let kind: Kind
    let icon: String
    let tint: Color

    var id: String { kind.rawValue }
    var destination: AppDestination? {
        switch kind {
        case .transport:
            return .practicalGuide(.transportBasics)
        case .sources:
            return .officialSources
        default:
            return nil
        }
    }

    func title(_ lang: AppLanguage) -> String {
        switch (kind, lang) {
        case (.bsn, _): return "BSN"
        case (.healthcare, .russian): return "Медицина"
        case (.healthcare, .dutch): return "Zorg"
        case (.healthcare, .english): return "Healthcare"
        case (.digid, _): return "DigiD"
        case (.transport, .russian): return "Транспорт"
        case (.transport, .dutch): return "Vervoer"
        case (.transport, .english): return "Transport"
        case (.housing, .russian): return "Жильё"
        case (.housing, .dutch): return "Wonen"
        case (.housing, .english): return "Housing"
        case (.sources, .russian): return "Источники"
        case (.sources, .dutch): return "Bronnen"
        case (.sources, .english): return "Sources"
        }
    }

    func accessibilityLabel(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return "Открыть маршрут \(title(lang))"
        case .dutch: return "Route \(title(lang)) openen"
        case .english: return "Open \(title(lang)) route"
        }
    }

    @MainActor
    func apply(_ viewModel: MapViewModel) {
        viewModel.selectedFocus = nil
        viewModel.selectedQuickFilter = nil
        switch kind {
        case .bsn:
            viewModel.applyJourneyPreset(.bsn)
        case .healthcare:
            viewModel.applyJourneyPreset(.healthcare)
        case .digid:
            viewModel.activeJourneyPreset = nil
            viewModel.selectedCategory = .municipality
            viewModel.searchText = "DigiD"
            viewModel.commitSearch()
        case .transport:
            viewModel.activeJourneyPreset = nil
            viewModel.selectedCategory = .transport
            viewModel.searchText = PlaceCategory.transport.localized(viewModel.language)
        case .housing:
            viewModel.activeJourneyPreset = nil
            viewModel.selectedCategory = .shelter
            viewModel.searchText = PlaceCategory.shelter.localized(viewModel.language)
        case .sources:
            break
        }
    }

    @MainActor
    func isSelected(_ viewModel: MapViewModel) -> Bool {
        switch kind {
        case .bsn: return viewModel.activeJourneyPreset == .bsn
        case .healthcare: return viewModel.activeJourneyPreset == .healthcare
        case .digid: return viewModel.searchText.caseInsensitiveCompare("DigiD") == .orderedSame
        case .transport: return viewModel.selectedCategory == .transport
        case .housing: return viewModel.selectedCategory == .shelter
        case .sources: return false
        }
    }
}

private struct SearchCategoryAction: Identifiable {
    enum Kind: String {
        case municipality
        case health
        case transport
        case pharmacy
        case police
        case documents
        case housing
        case education
        case library
        case studentHelp
        case duo
        case uwv
        case lgbtqSupport
    }

    let kind: Kind
    let category: PlaceCategory
    let icon: String
    let tint: Color

    var id: String { kind.rawValue }

    func title(_ lang: AppLanguage) -> String {
        switch (kind, lang) {
        case (.municipality, _): return L10n.t("nearby.municipality", lang)
        case (.health, _): return L10n.t("nearby.hospital", lang)
        case (.transport, _): return L10n.t("nearby.transport", lang)
        case (.pharmacy, .russian): return "Аптека"
        case (.pharmacy, .dutch): return "Apotheek"
        case (.pharmacy, .english): return "Pharmacy"
        case (.police, .russian): return "Полиция"
        case (.police, .dutch): return "Politie"
        case (.police, .english): return "Police"
        case (.documents, .russian): return "Документы"
        case (.documents, .dutch): return "Documenten"
        case (.documents, .english): return "Documents"
        case (.housing, .russian): return "Жильё"
        case (.housing, .dutch): return "Wonen"
        case (.housing, .english): return "Housing"
        case (.education, .russian): return "Учеба"
        case (.education, .dutch): return "Studie"
        case (.education, .english): return "Study"
        case (.library, .russian): return "Библиотеки"
        case (.library, .dutch): return "Bibliotheken"
        case (.library, .english): return "Libraries"
        case (.studentHelp, .russian): return "Помощь студентам"
        case (.studentHelp, .dutch): return "Studentenhulp"
        case (.studentHelp, .english): return "Student help"
        case (.duo, _): return "DUO"
        case (.uwv, _): return "UWV"
        case (.lgbtqSupport, .russian): return "LGBTQ-поддержка"
        case (.lgbtqSupport, .dutch): return "LGBTQ-steun"
        case (.lgbtqSupport, .english): return "LGBTQ support"
        }
    }

    func isVisible(for persona: PersonaTag) -> Bool {
        switch persona {
        case .student:
            return [.education, .library, .studentHelp, .duo, .transport, .health, .pharmacy].contains(kind)
        case .worker, .highlySkilledMigrant, .eu:
            return [.municipality, .health, .transport, .pharmacy, .uwv, .housing].contains(kind)
        case .refugee:
            return [.municipality, .documents, .health, .pharmacy, .education, .police, .housing].contains(kind)
        case .family:
            return [.municipality, .education, .library, .health, .pharmacy, .transport, .housing].contains(kind)
        case .tourist:
            return [.transport, .health, .pharmacy, .police].contains(kind)
        case .entrepreneur:
            return [.municipality, .health, .transport, .pharmacy, .housing].contains(kind)
        case .lgbt:
            return [.lgbtqSupport, .health, .pharmacy, .police, .housing].contains(kind)
        case .nonEU, .universal:
            return true
        }
    }

    func accessibilityLabel(_ lang: AppLanguage) -> String {
        title(lang)
    }

    @MainActor
    func apply(_ viewModel: MapViewModel) {
        viewModel.selectedFocus = nil
        viewModel.selectedQuickFilter = nil
        viewModel.activeJourneyPreset = nil
        viewModel.selectedCategory = category
        viewModel.searchText = title(viewModel.language)
    }

    @MainActor
    func matches(_ viewModel: MapViewModel) -> Bool {
        viewModel.selectedCategory == category
    }
}

private struct CompactCityRouteBackground: View {
    let tint: Color

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Canvas { context, size in
                    var canal = Path()
                    canal.move(to: CGPoint(x: size.width * 0.02, y: size.height * 0.72))
                    canal.addCurve(
                        to: CGPoint(x: size.width * 0.96, y: size.height * 0.26),
                        control1: CGPoint(x: size.width * 0.30, y: size.height * 0.48),
                        control2: CGPoint(x: size.width * 0.56, y: size.height * 0.84)
                    )
                    context.stroke(canal, with: .color(AppColors.cyanGlow.opacity(0.26)), style: StrokeStyle(lineWidth: 1.1, lineCap: .round))

                    var route = Path()
                    route.move(to: CGPoint(x: size.width * 0.10, y: size.height * 0.24))
                    route.addLine(to: CGPoint(x: size.width * 0.42, y: size.height * 0.42))
                    route.addLine(to: CGPoint(x: size.width * 0.78, y: size.height * 0.36))
                    context.stroke(route, with: .color(AppColors.dutchOrange.opacity(0.20)), style: StrokeStyle(lineWidth: 1, lineCap: .round))
                }

                Circle()
                    .fill(tint)
                    .frame(width: 7, height: 7)
                    .shadow(color: tint.opacity(0.70), radius: 9)
                    .position(x: proxy.size.width * 0.80, y: proxy.size.height * 0.36)

                Circle()
                    .fill(AppColors.cyanGlow)
                    .frame(width: 6, height: 6)
                    .shadow(color: AppColors.cyanGlow.opacity(0.65), radius: 8)
                    .position(x: proxy.size.width * 0.30, y: proxy.size.height * 0.64)
            }
            .background(
                LinearGradient(
                    colors: [tint.opacity(0.18), Color.clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        .accessibilityHidden(true)
    }
}

private struct LightweightNearbyMapPlaceholder: View {
    let cityName: String
    let placeCount: Int
    let tint: Color

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    AppColors.navyDeep.opacity(0.96),
                    tint.opacity(0.34),
                    AppColors.graphite.opacity(0.88)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            ProvinceMapMiniGraphic(accent: tint)
                .opacity(0.30)
                .padding(36)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 15, weight: .bold))
                    Text(cityName)
                        .font(.system(.headline, design: .rounded).weight(.bold))
                }
                .foregroundStyle(.white)

                Text("\(placeCount)")
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())

                HStack(spacing: 6) {
                    Circle()
                        .fill(tint)
                        .frame(width: 8, height: 8)
                    Rectangle()
                        .fill(Color.white.opacity(0.32))
                        .frame(width: 46, height: 2)
                    Circle()
                        .fill(AppColors.dutchOrange)
                        .frame(width: 8, height: 8)
                    Rectangle()
                        .fill(Color.white.opacity(0.32))
                        .frame(width: 30, height: 2)
                    Circle()
                        .fill(AppColors.success)
                        .frame(width: 8, height: 8)
                }
                .accessibilityHidden(true)
            }
            .padding(22)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
    }
}

private struct NearbyFullScreenMapView: View {
    @ObservedObject var viewModel: MapViewModel
    let lang: AppLanguage
    let annotationColor: (PlaceCategory) -> Color
    let onDismiss: () -> Void
    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Map(position: $cameraPosition) {
                if viewModel.mapOverlayRouteCoordinates.count > 1 {
                    MapPolyline(coordinates: viewModel.mapOverlayRouteCoordinates)
                        .stroke(AppColors.routeLine, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round, dash: [7, 6]))
                }

                ForEach(viewModel.filteredPlaces) { place in
                    Annotation(place.localizedName(lang), coordinate: place.coordinate) {
                        Button {
                            viewModel.selectPlace(place)
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(annotationColor(place.category))
                                    .frame(width: 36, height: 36)
                                Circle()
                                    .stroke(Color.white.opacity(0.88), lineWidth: 2)
                                    .frame(width: 36, height: 36)
                                Image(systemName: place.category.systemImageName)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.white)
                            }
                            .shadow(color: annotationColor(place.category).opacity(0.32), radius: 7, x: 0, y: 3)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .ignoresSafeArea()
            .onAppear {
                cameraPosition = .region(viewModel.region)
            }
            .onReceive(viewModel.$region) { newRegion in
                cameraPosition = .region(newRegion)
            }

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.18), lineWidth: 0.8))
            }
            .buttonStyle(.plain)
            .padding(18)
        }
    }
}

private struct SupportPlaceSection: Identifiable {
    let id: String
    let title: String
    let icon: String
    let color: Color
    let categories: Set<PlaceCategory>
    var places: [NearbyPlace] = []

    func withPlaces(_ places: [NearbyPlace]) -> SupportPlaceSection {
        SupportPlaceSection(id: id, title: title, icon: icon, color: color, categories: categories, places: places)
    }

    static func templates(_ lang: AppLanguage) -> [SupportPlaceSection] {
        [
            SupportPlaceSection(id: "municipality", title: L10n.t("nearby.registration", lang), icon: "building.2.fill", color: AppColors.dutchOrange, categories: [.municipality, .ind, .immigrationSupport, .expatCenter]),
            SupportPlaceSection(id: "language", title: L10n.t("nearby.lang_learning", lang), icon: "books.vertical.fill", color: AppColors.softBlue, categories: [.library, .education, .duo, .studentHelp]),
            SupportPlaceSection(id: "health", title: localized(lang, "Health", "Zorg", "Медицина"), icon: "cross.case.fill", color: AppColors.success, categories: [.healthcare, .hospital, .huisarts, .pharmacy, .nightPharmacy]),
            SupportPlaceSection(id: "legal", title: localized(lang, "Legal and official help", "Juridische en officiële hulp", "Юридическая и официальная помощь"), icon: "doc.text.fill", color: AppColors.violet, categories: [.legalHelp, .uwv]),
            SupportPlaceSection(id: "transport", title: localized(lang, "Transport", "Vervoer", "Транспорт"), icon: "tram.fill", color: AppColors.routeLine, categories: [.transport, .transportOffice, .bikeRepair]),
            SupportPlaceSection(id: "community", title: localized(lang, "Community and shelter", "Buurtsteun en opvang", "Сообщество и ночлег"), icon: "person.3.fill", color: AppColors.emerald, categories: [.communitySupport, .foodBank, .shelter, .lgbtqSupport]),
            SupportPlaceSection(id: "emergency", title: localized(lang, "Emergency", "Nood", "Экстренно"), icon: "phone.fill", color: AppColors.error, categories: [.police, .animalEmergency])
        ]
    }

    private static func localized(_ lang: AppLanguage, _ en: String, _ nl: String, _ ru: String) -> String {
        switch lang {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }
}

#if DEBUG && os(iOS)
private struct NearbyMapPreviewContainer: View {
    @StateObject private var appState = AppStateViewModel()
    @StateObject private var languageManager: LanguageManager
    @StateObject private var savedItemsStore = SavedItemsStore()
    @StateObject private var documentStore = DocumentStore()
    private let focus: MapFocus

    init(language: AppLanguage, focus: MapFocus) {
        self.focus = focus
        let manager = LanguageManager()
        manager.appLanguage = language
        _languageManager = StateObject(wrappedValue: manager)
    }

    var body: some View {
        NavigationStack {
            NearbyMapView(initialFocus: focus)
                .navigationDestination(for: AppDestination.self) { destination in
                    AppDestinationView(destination: destination)
                }
        }
        .environmentObject(appState)
        .environmentObject(languageManager)
        .environmentObject(savedItemsStore)
        .environmentObject(documentStore)
    }
}

private struct NearbyMapChipRowPreview: View {
    let language: AppLanguage

    private var focusItems: [(title: String, symbol: String, count: Int, isSelected: Bool)] {
        [
            (L10n.t("common.all", language), "square.grid.2x2", 19, false),
            (MapFocus.healthcare.localized(language), MapFocus.healthcare.symbol, 6, true),
            (L10n.t("map.emergency", language), "cross.case.fill", 4, false),
            (MapFocus.government.localized(language), MapFocus.government.symbol, 7, false),
            (MapFocus.education.localized(language), MapFocus.education.symbol, 5, false),
            (MapFocus.transport.localized(language), MapFocus.transport.symbol, 5, false)
        ]
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(focusItems, id: \.title) { item in
                    HStack(spacing: 6) {
                        Image(systemName: item.symbol)
                            .imageScale(.small)
                        Text(item.title)
                            .font(AppTypography.footnote)
                            .lineLimit(1)
                            .minimumScaleFactor(0.88)
                            .allowsTightening(true)
                        Text("\(item.count)")
                            .font(AppTypography.caption)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background((item.isSelected ? Color.white : AppColors.chipBackground).opacity(0.6))
                            .clipShape(Capsule())
                    }
                    .foregroundStyle(item.isSelected ? .white : AppColors.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .fixedSize(horizontal: true, vertical: false)
                    .background(item.isSelected ? AppColors.accent : AppColors.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(item.isSelected ? AppColors.accent : AppColors.stroke, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
        }
        .padding(.horizontal, -AppSpacing.screenHorizontal)
        .padding(.vertical, AppSpacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppSurface.base.opacity(0.62))
    }
}

#Preview("Map Focus RU - iPhone SE", traits: .fixedLayout(width: 375, height: 667)) {
    NearbyMapPreviewContainer(language: .russian, focus: .emergency)
        .environment(\.dynamicTypeSize, .large)
}

#Preview("Map Focus EN - iPhone 13 mini", traits: .fixedLayout(width: 375, height: 812)) {
    NearbyMapPreviewContainer(language: .english, focus: .transport)
}

#Preview("Map Focus NL - iPhone", traits: .fixedLayout(width: 390, height: 844)) {
    NearbyMapPreviewContainer(language: .dutch, focus: .government)
}

#Preview("Map Focus RU - Pro Max", traits: .fixedLayout(width: 430, height: 932)) {
    NearbyMapPreviewContainer(language: .russian, focus: .education)
        .environment(\.dynamicTypeSize, .xLarge)
}

#Preview("Map Chips RU - iPhone SE", traits: .fixedLayout(width: 375, height: 96)) {
    NearbyMapChipRowPreview(language: .russian)
        .environment(\.dynamicTypeSize, .large)
}

#Preview("Map Chips NL - iPhone SE", traits: .fixedLayout(width: 375, height: 96)) {
    NearbyMapChipRowPreview(language: .dutch)
        .environment(\.dynamicTypeSize, .large)
}
#endif
