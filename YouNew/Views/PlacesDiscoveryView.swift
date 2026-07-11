import SwiftUI
import MapKit

private enum PlacesDisplayMode: String, CaseIterable, Identifiable {
    case map
    case list

    var id: String { rawValue }

    func title(_ lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.map, .russian): return "Карта"
        case (.list, .russian): return "Список"
        case (.map, .dutch): return "Kaart"
        case (.list, .dutch): return "Lijst"
        case (.map, .english): return "Map"
        case (.list, .english): return "List"
        }
    }
}

private enum PlacesDiscoveryFilter: String, CaseIterable, Identifiable {
    case all
    case places
    case food
    case restaurants
    case cafes
    case hotels
    case healthcare
    case government
    case shopping
    case transport
    case education
    case localPartners

    var id: String { rawValue }

    func title(_ lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.all, .russian): return "Все"
        case (.places, .russian): return "Места"
        case (.food, .russian): return "Еда"
        case (.restaurants, .russian): return "Рестораны"
        case (.cafes, .russian): return "Кафе"
        case (.hotels, .russian): return "Отели"
        case (.healthcare, .russian): return "Медицина"
        case (.government, .russian): return "Госуслуги"
        case (.shopping, .russian): return "Покупки"
        case (.transport, .russian): return "Транспорт"
        case (.education, .russian): return "Образование"
        case (.localPartners, .russian): return "Партнеры"
        case (.all, .dutch): return "Alles"
        case (.places, .dutch): return "Plaatsen"
        case (.food, .dutch): return "Eten"
        case (.restaurants, .dutch): return "Restaurants"
        case (.cafes, .dutch): return "Cafés"
        case (.hotels, .dutch): return "Hotels"
        case (.healthcare, .dutch): return "Zorg"
        case (.government, .dutch): return "Overheid"
        case (.shopping, .dutch): return "Winkelen"
        case (.transport, .dutch): return "Vervoer"
        case (.education, .dutch): return "Onderwijs"
        case (.localPartners, .dutch): return "Partners"
        case (.all, .english): return "All"
        case (.places, .english): return "Places"
        case (.food, .english): return "Food"
        case (.restaurants, .english): return "Restaurants"
        case (.cafes, .english): return "Cafes"
        case (.hotels, .english): return "Hotels"
        case (.healthcare, .english): return "Healthcare"
        case (.government, .english): return "Government"
        case (.shopping, .english): return "Shopping"
        case (.transport, .english): return "Transport"
        case (.education, .english): return "Education"
        case (.localPartners, .english): return "Partners"
        }
    }

    var symbol: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .places: return "mappin.and.ellipse"
        case .food: return "fork.knife"
        case .restaurants: return "fork.knife"
        case .cafes: return "cup.and.saucer.fill"
        case .hotels: return "bed.double.fill"
        case .healthcare: return "cross.case.fill"
        case .government: return "building.columns.fill"
        case .shopping: return "bag.fill"
        case .transport: return "tram.fill"
        case .education: return "graduationcap.fill"
        case .localPartners: return "storefront.fill"
        }
    }

    func matches(_ place: NearbyPlace) -> Bool {
        switch self {
        case .all:
            return true
        case .places:
            return [.communitySupport, .library, .legalHelp, .police].contains(place.category)
        case .food, .restaurants, .cafes:
            return place.category == .foodBank || place.category == .communitySupport
        case .hotels:
            return place.category == .shelter
        case .healthcare:
            return [.healthcare, .hospital, .huisarts, .pharmacy, .nightPharmacy].contains(place.category)
        case .government:
            return [.municipality, .ind, .uwv, .duo, .immigrationSupport, .expatCenter, .police].contains(place.category)
        case .shopping:
            return place.category == .communitySupport
        case .transport:
            return [.transport, .transportOffice, .bikeRepair].contains(place.category)
        case .education:
            return [.education, .library, .studentHelp, .duo].contains(place.category)
        case .localPartners:
            return false
        }
    }

    func matches(_ partner: LocalPartner) -> Bool {
        switch self {
        case .all, .localPartners:
            return true
        case .places:
            return [.leisure].contains(partner.category)
        case .food:
            return partner.category == .foodDrinks
        case .restaurants:
            return partner.category == .foodDrinks && partner.subcategory.localizedCaseInsensitiveContains("restaurant")
        case .cafes:
            return partner.category == .foodDrinks && (partner.subcategory.localizedCaseInsensitiveContains("cafe") || partner.subcategory.localizedCaseInsensitiveContains("bakery"))
        case .hotels:
            return partner.category == .stay
        case .healthcare:
            return partner.category == .healthcare
        case .government:
            return [.legal, .finance, .jobs].contains(partner.category)
        case .shopping:
            return [.shopping, .home].contains(partner.category)
        case .transport:
            return partner.category == .transport
        case .education:
            return partner.category == .education
        }
    }
}

struct PlacesDiscoveryView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var savedItemsStore: SavedItemsStore
    @EnvironmentObject private var router: TabRouter
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @StateObject private var mapViewModel = MapViewModel()
    @State private var displayMode: PlacesDisplayMode = .map
    @State private var selectedFilter: PlacesDiscoveryFilter = .all
    @State private var query = ""
    @State private var selectedPlace: NearbyPlace?
    @State private var selectedProvinceID: String?
    @State private var isCityMapOpen = false
    @State private var premiumMapGlowPhase: Double = 0.42
    @FocusState private var isInputFocused: Bool

    let onNavigate: (AppDestination) -> Void
    let onAskAI: (String) -> Void

    private var lang: AppLanguage { languageManager.appLanguage }
    private var partners: [LocalPartner] {
        MockLocalPartnersData.partners(in: mapViewModel.selectedCity).filter { selectedFilter.matches($0) }
    }
    private var visibleFilters: [PlacesDiscoveryFilter] {
        [.all, .places, .food, .hotels, .transport, .healthcare]
    }
    private var moreFilters: [PlacesDiscoveryFilter] {
        [.restaurants, .cafes, .government, .shopping, .education, .localPartners]
    }
    private var places: [NearbyPlace] {
        mapViewModel.filteredPlaces.filter { selectedFilter == .localPartners ? false : selectedFilter.matches($0) }
    }
    private var visiblePlaceAnnotations: [NearbyPlace] { Array(places.prefix(28)) }
    private var visiblePartnerAnnotations: [LocalPartner] { Array(partners.prefix(16)) }
    private var usesAccessibilityLayout: Bool { dynamicTypeSize.isAccessibilitySize }
    private var placesBottomReserve: CGFloat {
        usesAccessibilityLayout ? AppSpacing.tabBarScrollReserveLarge + 44 : AppSpacing.tabBarScrollReserve
    }
    private var mapCameraPosition: Binding<MapCameraPosition> {
        Binding {
            .region(mapViewModel.region)
        } set: { position in
            if let region = position.region {
                mapViewModel.region = region
            }
        }
    }

    var body: some View {
        GeometryReader { proxy in
            let horizontalPadding = AppSpacing.screenHorizontal
            let contentWidth = max(0, proxy.size.width - horizontalPadding * 2)

            ScrollViewReader { scrollProxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                        Color.clear.frame(height: 0).id("placesTop")
                        universalInput
                        filterRow

                        explorationPanel

                        belowMapSections
                        sourceNote
                        Color.clear.frame(height: placesBottomReserve)
                    }
                    .frame(width: contentWidth, alignment: .leading)
                    .padding(.horizontal, horizontalPadding)
                    .padding(.vertical, AppSpacing.medium)
                }
                .safeAreaInset(edge: .top, spacing: 0) {
                    Color.clear.frame(height: 8)
                }
                .onReceive(router.placesScrollTop) { _ in
                    isInputFocused = false
                    withAnimation(.easeInOut(duration: 0.24)) {
                        scrollProxy.scrollTo("placesTop", anchor: .top)
                    }
                }
            }
        }
        .appSceneBackground(.map)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: configure)
        .onChange(of: appState.selectedCity) { _, city in
            guard MockNearbyPlacesData.supportedCities.contains(city) else { return }
            mapViewModel.selectedCity = city
        }
        .onChange(of: languageManager.appLanguage) { _, newLanguage in
            mapViewModel.language = newLanguage
        }
        .onChange(of: appState.selectedUserStatus) { _, newStatus in
            mapViewModel.activePersona = newStatus?.personaTag
        }
        .onChange(of: query) { _, newValue in
            mapViewModel.searchText = newValue
        }
        .sheet(item: $selectedPlace) { place in
            NavigationStack {
                PlaceDetailView(
                    place: place,
                    distanceText: mapViewModel.distancePlaceholderText(for: place, language: lang),
                    travelTimeText: mapViewModel.travelTimePlaceholder(for: place, mode: mapViewModel.selectedTravelMode, language: lang),
                    onOpenMaps: { mapViewModel.openInAppleMaps(place) },
                    onOpenWalkRoute: { mapViewModel.openInAppleMaps(place, mode: .walking) },
                    onOpenTransitRoute: { mapViewModel.openInAppleMaps(place, mode: .transit) },
                    onOpenCyclingRoute: { mapViewModel.openInAppleMaps(place, mode: .cycling) },
                    onToggleSaved: {
                        savedItemsStore.toggle(
                            id: place.saveKey,
                            kind: .place,
                            title: place.localizedName(lang),
                            subtitle: "\(place.city) · \(place.discoveryCategoryTitle(lang))",
                            destination: .mapFocus(.place(place.saveKey))
                        )
                    },
                    isSaved: savedItemsStore.isSaved(place.saveKey),
                    relatedLinks: mapViewModel.relatedLinks(for: place)
                )
                .navigationDestination(for: AppDestination.self) { AppDestinationView(destination: $0) }
            }
            .presentationDetents([.medium, .large])
            .presentationBackground(.regularMaterial)
        }
    }

    private func configure() {
        mapViewModel.language = lang
        mapViewModel.activePersona = appState.selectedUserStatus?.personaTag
        if MockNearbyPlacesData.supportedCities.contains(appState.selectedCity) {
            mapViewModel.selectedCity = appState.selectedCity
        }
        selectedProvinceID = provinceID(forCity: mapViewModel.selectedCity)
        mapViewModel.showLocalPartners = true
        withAnimation(AppAnimations.gentleBreathe) {
            premiumMapGlowPhase = 0.92
        }
    }

    @ViewBuilder
    private var universalInput: some View {
        if usesAccessibilityLayout {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(AppColors.textSecondary)
                    TextField(inputPlaceholder, text: $query)
                        .focused($isInputFocused)
                        .submitLabel(.search)
                        .onSubmit(handleUniversalInput)
                }

                HStack(spacing: 10) {
                    aiInputButton
                    submitInputButton
                }
            }
            .placesInputChrome()
        } else {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(AppColors.textSecondary)
                TextField(inputPlaceholder, text: $query)
                    .focused($isInputFocused)
                    .submitLabel(.search)
                    .onSubmit(handleUniversalInput)
                aiInputButton
                submitInputButton
            }
            .placesInputChrome()
        }
    }

    private var aiInputButton: some View {
        Button(action: askAIFromInput) {
            Image(systemName: "sparkles")
                .font(.headline.weight(.bold))
                .foregroundStyle(AppColors.violet)
                .frame(width: 32, height: 32)
                .background(AppColors.violet.opacity(0.12), in: Circle())
        }
        .accessibilityLabel(aiButtonLabel)
    }

    private var submitInputButton: some View {
        Button(action: handleUniversalInput) {
            Image(systemName: "arrow.right.circle.fill")
                .font(.title3.weight(.bold))
                .foregroundStyle(AppColors.dutchOrange)
                .frame(width: 44, height: 44)
        }
        .accessibilityLabel(inputSubmitLabel)
    }

    @ViewBuilder
    private var modePicker: some View {
        let stack = usesAccessibilityLayout ? AnyLayout(VStackLayout(spacing: 8)) : AnyLayout(HStackLayout(spacing: 8))
        stack {
            ForEach(PlacesDisplayMode.allCases) { mode in
                Button {
                    withAnimation(AppAnimations.standard) {
                        displayMode = mode
                    }
                } label: {
                    Label(mode.title(lang), systemImage: mode == .map ? "map.fill" : "list.bullet")
                        .font(AppTypography.captionStrong)
                        .lineLimit(usesAccessibilityLayout ? 2 : 1)
                        .minimumScaleFactor(0.86)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .foregroundStyle(displayMode == mode ? .white : AppColors.textPrimary)
                        .background(displayMode == mode ? AppColors.accent : AppColors.chipBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .accessibilityIdentifier("places.displayMode")
    }

    @ViewBuilder
    private var filterRow: some View {
        if usesAccessibilityLayout {
            LazyVGrid(columns: [GridItem(.flexible(minimum: 0), spacing: 8)], alignment: .leading, spacing: 8) {
                ForEach(visibleFilters) { filter in
                    filterChip(filter)
                }
                moreFilterMenu
            }
            .accessibilityIdentifier("places.filters")
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(visibleFilters) { filter in
                        filterChip(filter)
                    }
                    moreFilterMenu
                }
                .padding(.vertical, 2)
            }
            .accessibilityIdentifier("places.filters")
        }
    }

    private var moreFilterMenu: some View {
        Menu {
            ForEach(moreFilters) { filter in
                Button {
                    withAnimation(AppAnimations.standard) {
                        selectedFilter = filter
                    }
                } label: {
                    Label(filter.title(lang), systemImage: filter.symbol)
                }
            }
        } label: {
            Label(moreFilterTitle, systemImage: "ellipsis.circle.fill")
                .font(AppTypography.captionStrong)
                .lineLimit(usesAccessibilityLayout ? 2 : 1)
                .minimumScaleFactor(0.86)
                .foregroundStyle(moreFilters.contains(selectedFilter) ? .white : AppColors.textPrimary)
                .frame(maxWidth: usesAccessibilityLayout ? .infinity : nil, alignment: .center)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(moreFilters.contains(selectedFilter) ? AppColors.routeLine : AppColors.chipBackground, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private func filterChip(_ filter: PlacesDiscoveryFilter) -> some View {
        Button {
            withAnimation(AppAnimations.standard) {
                selectedFilter = filter
            }
        } label: {
            Label(filter.title(lang), systemImage: filter.symbol)
                .font(AppTypography.captionStrong)
                .lineLimit(usesAccessibilityLayout ? 2 : 1)
                .minimumScaleFactor(0.86)
                .foregroundStyle(selectedFilter == filter ? .white : AppColors.textPrimary)
                .frame(maxWidth: usesAccessibilityLayout ? .infinity : nil, alignment: .center)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(selectedFilter == filter ? AppColors.routeLine : AppColors.chipBackground, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private var explorationPanel: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            if usesAccessibilityLayout {
                VStack(alignment: .leading, spacing: 10) {
                    explorationHeaderText
                    modePicker
                }
            } else {
                HStack(alignment: .center) {
                    explorationHeaderText
                    Spacer()
                    modePicker
                        .frame(width: 178)
                }
            }

            if displayMode == .map {
                if isCityMapOpen {
                    mapPanel
                } else {
                    premiumNetherlandsMapPanel
                }
            } else {
                listPanel
            }
        }
        .accessibilityIdentifier("places.explorationPanel")
    }

    private var explorationHeaderText: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(exploreMapTitle)
                .font(.system(.title3, design: .rounded).weight(.bold))
                .foregroundStyle(AppColors.textPrimary)
            Text(resultSummary)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(usesAccessibilityLayout ? 3 : 2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var premiumNetherlandsMapPanel: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [
                    Color(hex: "#06111F"),
                    Color(hex: "#0A2136"),
                    Color(hex: "#030914")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [AppColors.cyanGlow.opacity(0.22), .clear],
                center: UnitPoint(x: 0.74, y: 0.20),
                startRadius: 0,
                endRadius: 320
            )
            RadialGradient(
                colors: [AppColors.dutchOrange.opacity(0.14), .clear],
                center: UnitPoint(x: 0.22, y: 0.76),
                startRadius: 0,
                endRadius: 260
            )

            GeometryReader { proxy in
                let mapRect = PremiumNetherlandsMapCanvas.mapRect(in: proxy.size)
                PremiumNetherlandsMapCanvas(
                    selectedProvinceID: selectedProvinceID,
                    selectedCity: mapViewModel.selectedCity,
                    glowPhase: selectedProvinceID == nil ? premiumMapGlowPhase : max(0.78, premiumMapGlowPhase),
                    displayMode: .provinces
                )
                .padding(.top, 88)
                .padding(.bottom, 112)
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
                            chooseProvince(zone.id)
                        }
                        .accessibilityLabel(provinceName(zone.id))
                        .accessibilityIdentifier("places.province.\(zone.id)")
                }
            }

            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(countryMapTitle)
                            .font(.system(size: usesAccessibilityLayout ? 24 : 28, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(usesAccessibilityLayout ? 2 : 1)
                            .minimumScaleFactor(0.84)
                        Text(countryMapSubtitle)
                            .font(AppTypography.body)
                            .foregroundStyle(Color.white.opacity(0.72))
                            .lineLimit(usesAccessibilityLayout ? 3 : 2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 6) {
                        Label(ProvinceCatalog.localizedCityName(mapViewModel.selectedCity, lang), systemImage: "location.fill")
                            .font(AppTypography.captionStrong)
                            .foregroundStyle(AppColors.dutchOrange)
                            .lineLimit(2)
                            .minimumScaleFactor(0.82)
                        Text("12 \(provinceCountLabel)")
                            .font(AppTypography.caption)
                            .foregroundStyle(Color.white.opacity(0.66))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                }

                Spacer(minLength: 0)

                selectedProvinceTray
            }
            .padding(18)
        }
        .frame(height: usesAccessibilityLayout ? 600 : 520)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.20),
                            AppColors.cyanGlow.opacity(0.28),
                            AppColors.dutchOrange.opacity(0.16),
                            Color.white.opacity(0.07)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: AppColors.cyanGlow.opacity(0.16), radius: 28, x: 0, y: 16)
        .accessibilityIdentifier("places.premiumNetherlandsMap")
    }

    private var selectedProvinceTray: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Label(selectedProvinceTitle, systemImage: "map.fill")
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(.white)
                    .lineLimit(usesAccessibilityLayout ? 2 : 1)
                    .minimumScaleFactor(0.84)
                Spacer()
                Button {
                    withAnimation(AppAnimations.standard) {
                        isCityMapOpen = true
                    }
                } label: {
                    Label(openCityMapTitle, systemImage: "arrow.up.left.and.arrow.down.right")
                        .font(AppTypography.captionStrong)
                        .lineLimit(usesAccessibilityLayout ? 2 : 1)
                        .minimumScaleFactor(0.84)
                }
                .buttonStyle(SecondaryPremiumButtonStyle())
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(selectedProvinceCities, id: \.self) { city in
                        Button {
                            chooseCity(city)
                        } label: {
                            Text(ProvinceCatalog.localizedCityName(city, lang))
                                .font(AppTypography.captionStrong)
                                .foregroundStyle(city.caseInsensitiveCompare(mapViewModel.selectedCity) == .orderedSame ? .white : AppColors.textPrimary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 9)
                                .background(city.caseInsensitiveCompare(mapViewModel.selectedCity) == .orderedSame ? AppColors.dutchOrange : AppColors.glassSurfaceElevated, in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(14)
        .background(.black.opacity(0.26), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(Color.white.opacity(0.12), lineWidth: 0.8))
    }

    private var mapPanel: some View {
        ZStack(alignment: .bottomLeading) {
            Map(position: mapCameraPosition) {
                UserAnnotation()
                ForEach(mapAnnotations) { item in
                    Annotation(item.title, coordinate: item.coordinate) {
                        Button {
                            handleAnnotation(item)
                        } label: {
                            Image(systemName: item.symbol)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                                .frame(width: 30, height: 30)
                                .background(item.tint, in: Circle())
                                .shadow(color: .black.opacity(0.18), radius: 6, x: 0, y: 3)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(height: 470)

            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(mapOverlayTitle)
                        .font(AppTypography.captionStrong)
                        .foregroundStyle(.white)
                    Text(mapOverlaySubtitle)
                        .font(AppTypography.caption)
                        .foregroundStyle(.white.opacity(0.82))
                }
                Spacer()
                Button {
                    onNavigate(.mapHub)
                } label: {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(.white.opacity(0.18), in: Circle())
                }
                .accessibilityLabel(openFullMapTitle)
            }
            .padding(14)
            .background(.black.opacity(0.28), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .padding(14)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(AppColors.stroke.opacity(0.8), lineWidth: 0.8))
        .accessibilityIdentifier("places.mapMode")
    }

    private var listPanel: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: AppSpacing.small) {
                ForEach(places.prefix(8)) { place in
                    Button { selectedPlace = place } label: {
                        placeRow(place)
                    }
                    .buttonStyle(AppPressableCardButtonStyle())
                }
                ForEach(partners.prefix(6)) { partner in
                    NavigationLink(value: AppDestination.localPartnerDetail(partner.id)) {
                        partnerRow(partner)
                    }
                    .buttonStyle(AppPressableCardButtonStyle())
                }
            }
            .padding(14)
        }
        .frame(height: 470)
        .background(AppColors.glassSurfaceElevated, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(AppColors.stroke.opacity(0.8), lineWidth: 0.8))
        .accessibilityIdentifier("places.listMode")
    }

    private var belowMapSections: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
            ForEach(mapSupportSections) { section in
                compactContentSection(section)
            }
        }
        .accessibilityIdentifier("places.supportSections")
    }

    private func compactContentSection(_ section: PlacesDiscoverySection) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            SectionHeader(title: section.title, subtitle: section.subtitle)
            LazyVGrid(columns: discoveryGridColumns, spacing: AppSpacing.small) {
                ForEach(section.items.prefix(section.id == "today-events" ? 3 : 5)) { item in
                    discoveryCard(item)
                        .frame(maxWidth: .infinity)
                }
            }
            if section.id == "nearby" {
                Button {
                    selectedFilter = .all
                    displayMode = .list
                } label: {
                    Label(viewAllTitle, systemImage: "list.bullet")
                        .font(AppTypography.captionStrong)
                }
                .buttonStyle(SecondaryPremiumButtonStyle())
            }
        }
    }

    private var discoveryGridColumns: [GridItem] {
        [
            GridItem(.flexible(minimum: 0), spacing: AppSpacing.small, alignment: .top)
        ]
    }

    @ViewBuilder
    private func discoveryCard(_ item: PlacesDiscoveryItem) -> some View {
        switch item.kind {
        case .place(let place):
            Button { selectedPlace = place } label: {
                supportCard(
                    title: item.title,
                    subtitle: item.subtitle,
                    detail: compactAISummary(for: place),
                    badge: place.isReferenceLocation ? place.localizedSourceLabel(lang) : nil,
                    symbol: item.symbol,
                    accent: item.tint,
                    asset: imageAsset(for: place),
                    fallbackCategory: fallbackCategory(for: place)
                )
            }
            .buttonStyle(AppPressableCardButtonStyle())
        case .partner(let partner):
            NavigationLink(value: AppDestination.localPartnerDetail(partner.id)) {
                supportCard(
                    title: item.title,
                    subtitle: item.subtitle,
                    detail: compactAISummary(for: partner),
                    badge: partner.isOpenNow ? openNowTitle : partner.plan.label(lang),
                    symbol: item.symbol,
                    accent: item.tint,
                    asset: partnerImageAsset(partner) ?? partnerFallbackImageAsset(partner),
                    fallbackCategory: .nearbyHelp
                )
            }
            .buttonStyle(AppPressableCardButtonStyle())
        case .destination(let destination):
            NavigationLink(value: destination) {
                supportCard(
                    title: item.title,
                    subtitle: item.subtitle,
                    detail: officialDetailsTitle,
                    badge: nil,
                    symbol: item.symbol,
                    accent: item.tint,
                    asset: imageAsset(for: destination),
                    fallbackCategory: fallbackCategory(for: destination)
                )
            }
            .buttonStyle(AppPressableCardButtonStyle())
        }
    }

    private func supportCard(
        title: String,
        subtitle: String,
        detail: String,
        badge: String?,
        symbol: String,
        accent: Color,
        asset: AppImageAsset?,
        fallbackCategory: PremiumImageFallbackCategory
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            supportCardImage(
                title: title,
                asset: asset,
                symbol: symbol,
                accent: accent,
                fallbackCategory: fallbackCategory
            )
            Text(title)
                .font(AppTypography.bodyStrong)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
            Text(subtitle)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(usesAccessibilityLayout ? 2 : 1)
                .fixedSize(horizontal: false, vertical: true)
            Text(detail)
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(2)
            if let badge {
                Text(badge)
                    .font(AppTypography.captionStrong)
                    .foregroundStyle(accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.86)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(accent.opacity(0.12), in: Capsule())
            }
        }
        .frame(maxWidth: .infinity, minHeight: usesAccessibilityLayout ? 284 : 232, alignment: .topLeading)
        .padding(14)
        .background(AppColors.glassSurfaceElevated, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(AppColors.stroke.opacity(0.7), lineWidth: 0.8))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .clipped()
    }

    private func supportCardImage(
        title: String,
        asset: AppImageAsset?,
        symbol: String,
        accent: Color,
        fallbackCategory: PremiumImageFallbackCategory,
        height: CGFloat = 92,
        cornerRadius: CGFloat = 16
    ) -> some View {
        ZStack(alignment: .bottomLeading) {
            PremiumImageView(
                asset: asset,
                language: lang,
                height: height,
                aspectRatio: nil,
                mode: .fill,
                cornerRadius: cornerRadius,
                overlayStyle: .none,
                fallbackCategory: fallbackCategory,
                accessibilityLabel: title,
                targetPixelWidth: 520,
                role: .thumbnail,
                overlayPolicy: .none,
                focalPoint: .center
            )
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .clipped()
            .accessibilityHidden(true)

            LinearGradient(
                colors: [
                    Color.black.opacity(0.02),
                    AppColors.navyDeep.opacity(0.18),
                    AppColors.navyDeep.opacity(0.46)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: height)
            .allowsHitTesting(false)

            Image(systemName: symbol)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: height < 90 ? 38 : 42, height: height < 90 ? 38 : 42)
                .background(accent.opacity(0.90), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                .padding(height < 90 ? 10 : 12)
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .clipped()
    }

    private func partnerImageAsset(_ partner: LocalPartner) -> AppImageAsset? {
        let asset = partner.media.thumbnail
        guard isDirectImageURL(asset.url) else { return nil }
        return AppImageAsset(
            id: "partner-thumbnail-\(partner.id)",
            url: asset.url,
            imageURL: asset.url,
            thumbnailURL: asset.url,
            title: partner.name,
            description: asset.altText,
            sourceName: asset.sourceTitle,
            sourceURL: partner.website,
            license: asset.licenseNote,
            attribution: asset.sourceTitle,
            width: nil,
            height: nil,
            type: .cardThumbnail,
            verified: true
        )
    }

    private func isDirectImageURL(_ url: URL) -> Bool {
        ["jpg", "jpeg", "png", "webp", "gif", "heic"].contains(url.pathExtension.lowercased())
    }

    private func imageAsset(for place: NearbyPlace) -> AppImageAsset? {
        if let directAsset = directPlaceImageAsset(for: place) {
            return directAsset
        }
        if let tourismAsset = tourismImageAsset(for: place) {
            return tourismAsset
        }
        switch place.category {
        case .healthcare, .hospital, .huisarts, .pharmacy, .nightPharmacy:
            return ContentMediaRegistry.healthcareBasicsImage ?? ContentMediaRegistry.healthcarePharmacyImage
        case .municipality, .ind, .duo, .immigrationSupport, .expatCenter, .police:
            return ContentMediaRegistry.governmentBasicsImage ?? ContentMediaRegistry.municipalityCityHallImage
        case .uwv, .legalHelp:
            return ContentMediaRegistry.workImage ?? ContentMediaRegistry.governmentBasicsImage
        case .transport, .transportOffice:
            return ContentMediaRegistry.transportBasicsImage ?? ContentMediaRegistry.transportHero
        case .bikeRepair:
            return ContentMediaRegistry.transportHero
        case .education, .library, .studentHelp:
            return ContentMediaRegistry.dailyCultureImage ?? ContentMediaRegistry.officialSourcesHero
        case .foodBank:
            return ContentMediaRegistry.foodImage ?? ContentMediaRegistry.marketsLocalLifeImage
        case .shelter:
            return ContentMediaRegistry.premiumHousingImage ?? ContentMediaRegistry.housingWonenImage
        case .communitySupport, .lgbtqSupport:
            return ContentMediaRegistry.dailyCultureImage ?? ContentMediaRegistry.marketsLocalLifeImage ?? ContentMediaRegistry.officialSourcesHero
        case .animalEmergency:
            return ContentMediaRegistry.emergencyImage
        }
    }

    private func directPlaceImageAsset(for place: NearbyPlace) -> AppImageAsset? {
        guard let imageURL = place.imageURL else { return nil }
        return AppImageAsset(
            id: "nearby-place-\(place.saveKey)-image",
            url: imageURL,
            sourcePageURL: place.websiteURL,
            imageURL: imageURL,
            thumbnailURL: imageURL,
            title: place.localizedName(lang),
            description: place.localizedDescription(lang),
            sourceName: place.sourceLabel,
            sourceURL: place.websiteURL,
            license: nil,
            attribution: place.sourceLabel,
            width: nil,
            height: nil,
            type: .cardThumbnail,
            verified: place.isOfficialSource
        )
    }

    private func tourismImageAsset(for place: NearbyPlace) -> AppImageAsset? {
        let normalizedName = place.name.lowercased()
        if normalizedName.contains("canal") || normalizedName.contains("gracht") {
            return ContentMediaRegistry.leidenCanalsHero ?? ContentMediaRegistry.canalHousesHero
        }
        if normalizedName.contains("molen") || normalizedName.contains("windmill") || normalizedName.contains("valk") {
            return ContentMediaRegistry.cultureWindmillHero ?? ContentMediaRegistry.cultureWideHero
        }
        if normalizedName.contains("museum") || normalizedName.contains("rijksmuseum") || normalizedName.contains("lakenhal") || normalizedName.contains("oudheden") {
            return ContentMediaRegistry.museumsCultureImage ?? ContentMediaRegistry.dailyCultureImage ?? ContentMediaRegistry.canalsCityCentresImage
        }
        if normalizedName.contains("hortus") || normalizedName.contains("botanic") || normalizedName.contains("park") {
            return ContentMediaRegistry.natureImage ?? ContentMediaRegistry.dailyCultureImage
        }
        if normalizedName.contains("burcht") || normalizedName.contains("castle") || normalizedName.contains("historic") {
            return ContentMediaRegistry.canalsCityCentresImage ?? ContentMediaRegistry.mapImage
        }
        return nil
    }

    private func imageAsset(for destination: AppDestination) -> AppImageAsset? {
        switch destination {
        case .calendarEvent:
            return ContentMediaRegistry.calendarImage
        case .localPartners, .businessGrowth, .localPartnerDetail:
            return ContentMediaRegistry.workImage
        case .officialSources:
            return ContentMediaRegistry.officialSourcesHero ?? ContentMediaRegistry.governmentBasicsImage
        case .cultureAttractions:
            return ContentMediaRegistry.cultureWideHero ?? ContentMediaRegistry.dailyCultureImage
        case .mapHub:
            return ContentMediaRegistry.mapImage ?? ContentMediaRegistry.searchImage
        default:
            return ContentMediaRegistry.mapImage ?? ContentMediaRegistry.officialSourcesHero ?? ContentMediaRegistry.dailyCultureImage
        }
    }

    private func fallbackCategory(for category: PlaceCategory) -> PremiumImageFallbackCategory {
        switch category {
        case .healthcare, .hospital, .huisarts, .pharmacy, .nightPharmacy:
            return .healthcare
        case .municipality, .ind, .uwv, .duo, .immigrationSupport, .expatCenter, .police:
            return .government
        case .transport, .transportOffice, .bikeRepair:
            return .transport
        case .education, .library, .studentHelp:
            return .dutchA1A2
        case .legalHelp:
            return .documents
        case .foodBank, .communitySupport, .lgbtqSupport:
            return .integration
        case .shelter:
            return .housing
        case .animalEmergency:
            return .emergency
        }
    }

    private func fallbackCategory(for place: NearbyPlace) -> PremiumImageFallbackCategory {
        let text = "\(place.name) \(place.newcomerUseCase) \(place.description)".lowercased()
        if text.contains("museum") || text.contains("canal") || text.contains("gracht") || text.contains("molen") || text.contains("windmill") || text.contains("bridge") || text.contains("burcht") || text.contains("historic") || text.contains("landmark") || text.contains("park") || text.contains("hortus") {
            return .city
        }
        if text.contains("restaurant") || text.contains("cafe") || text.contains("café") || text.contains("food") || text.contains("market") {
            return .nearbyHelp
        }
        if text.contains("hotel") || text.contains("hostel") || text.contains("stay") {
            return .housing
        }
        return fallbackCategory(for: place.category)
    }

    private func fallbackCategory(for destination: AppDestination) -> PremiumImageFallbackCategory {
        switch destination {
        case .calendarEvent:
            return .city
        case .localPartners, .businessGrowth, .localPartnerDetail:
            return .work
        case .officialSources:
            return .government
        case .cultureAttractions:
            return .city
        case .mapHub:
            return .map
        default:
            return .city
        }
    }

    private var sourceNote: some View {
        DisclaimerBanner(text: sourceNoteText)
    }

    private func placeRow(_ place: NearbyPlace) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            supportCardImage(
                title: place.localizedName(lang),
                asset: imageAsset(for: place),
                symbol: place.discoverySymbolName,
                accent: color(for: place.category),
                fallbackCategory: fallbackCategory(for: place),
                height: 112,
                cornerRadius: 18
            )
            .frame(maxWidth: .infinity)
            .frame(height: 112)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .clipped()

            Text(place.localizedName(lang))
                .font(AppTypography.bodyStrong)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
            Text("\(place.discoveryCategoryTitle(lang)) · \(mapViewModel.distancePlaceholderText(for: place, language: lang)) · \(place.city)")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(1)
            Text(aiSummary(for: place))
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(2)
            listCardFooter(tint: AppColors.routeLine)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .appCardStyle()
        .clipped()
    }

    private func partnerRow(_ partner: LocalPartner) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            supportCardImage(
                title: partner.name,
                asset: partnerImageAsset(partner) ?? partnerFallbackImageAsset(partner),
                symbol: partner.category.symbol,
                accent: AppColors.dutchOrange,
                fallbackCategory: partnerFallbackCategory(partner),
                height: 112,
                cornerRadius: 18
            )
            .frame(maxWidth: .infinity)
            .frame(height: 112)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .clipped()

            Text(partner.name)
                .font(AppTypography.bodyStrong)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
            Text("\(partner.plan.label(lang)) · \(partner.category.title(lang)) · \(partner.city)")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(1)
            Text(aiSummary(for: partner))
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(2)
            listCardFooter(tint: AppColors.dutchOrange)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .appCardStyle()
        .clipped()
    }

    private func listCardFooter(tint: Color) -> some View {
        HStack {
            Label(openTitle, systemImage: "arrow.up.right")
                .font(AppTypography.captionStrong)
                .foregroundStyle(.white)
                .lineLimit(1)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(tint, in: Capsule())
            Spacer(minLength: 0)
        }
    }

    private func partnerFallbackImageAsset(_ partner: LocalPartner) -> AppImageAsset? {
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

    private func partnerFallbackCategory(_ partner: LocalPartner) -> PremiumImageFallbackCategory {
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

    private var cityPlaces: [NearbyPlace] {
        mapViewModel.cityHubPlaces.filter { $0.city == mapViewModel.selectedCity }
    }

    private var cityPartners: [LocalPartner] {
        MockLocalPartnersData.partners(in: mapViewModel.selectedCity)
    }
    private var selectedAudience: UserContentCategory? {
        UserContentCategory.from(persona: appState.selectedUserStatus?.personaTag)
    }
    private var todayEvents: [CalendarEvent] {
        DashboardCalendarData.upcomingEvents(cityId: mapViewModel.selectedCity, audience: selectedAudience, limit: 3)
    }
    private var topPartners: [LocalPartner] {
        Array(cityPartners.sorted {
            let lhs = partnerRank($0)
            let rhs = partnerRank($1)
            if lhs == rhs { return $0.name < $1.name }
            return lhs < rhs
        }.prefix(5))
    }

    private var recommendedPlaces: [NearbyPlace] {
        let persona = appState.selectedUserStatus?.personaTag
        return cityPlaces.filter { $0.isVisible(for: persona) }
    }

    private var mapSupportSections: [PlacesDiscoverySection] {
        var usedPlaces = Set<String>()
        var usedPartners = Set<String>()

        func takePlaces<S: Sequence>(_ source: S, limit: Int) -> [PlacesDiscoveryItem] where S.Element == NearbyPlace {
            var items: [PlacesDiscoveryItem] = []
            for place in source {
                let key = place.saveKey
                guard !usedPlaces.contains(key) else { continue }
                usedPlaces.insert(key)
                items.append(placeItem(place))
                if items.count == limit { break }
            }
            return items
        }

        func takePartners<S: Sequence>(_ source: S, limit: Int) -> [PlacesDiscoveryItem] where S.Element == LocalPartner {
            var items: [PlacesDiscoveryItem] = []
            for partner in source {
                guard !usedPartners.contains(partner.id) else { continue }
                usedPartners.insert(partner.id)
                items.append(partnerItem(partner))
                if items.count == limit { break }
            }
            return items
        }

        return [
            PlacesDiscoverySection(
                id: "nearby",
                title: nearbySectionTitle,
                subtitle: nearbySectionSubtitle,
                items: takePlaces(places.isEmpty ? recommendedPlaces : places, limit: 5)
            ),
            PlacesDiscoverySection(
                id: "local-partners",
                title: localPartnersSectionTitle,
                subtitle: localPartnersSectionSubtitle,
                items: takePartners(topPartners, limit: 5)
            ),
            PlacesDiscoverySection(
                id: "today-events",
                title: todaysEventsSectionTitle,
                subtitle: todaysEventsSectionSubtitle,
                items: todayEvents.map(eventItem)
            ),
        ]
        .filter { !$0.items.isEmpty }
    }

    private func partnerRank(_ partner: LocalPartner) -> Int {
        switch partner.plan {
        case .verifiedPartner: return 0
        case .premium, .featured, .aiFeatured: return 1
        case .sponsoredPlacement: return 2
        case .freeListing: return 3
        }
    }

    private func placeItem(_ place: NearbyPlace) -> PlacesDiscoveryItem {
        PlacesDiscoveryItem(
            title: place.localizedName(lang),
            subtitle: placeDiscoverySubtitle(for: place),
            symbol: place.discoverySymbolName,
            tint: color(for: place.category),
            kind: .place(place)
        )
    }

    private func placeDiscoverySubtitle(for place: NearbyPlace) -> String {
        if place.isReferenceLocation {
            return "\(place.discoveryCategoryTitle(lang)) · \(place.localizedSourceLabel(lang))"
        }
        return "\(place.discoveryCategoryTitle(lang)) · \(mapViewModel.distancePlaceholderText(for: place, language: lang))"
    }

    private func partnerItem(_ partner: LocalPartner) -> PlacesDiscoveryItem {
        PlacesDiscoveryItem(
            title: partner.name,
            subtitle: "\(partner.plan.label(lang)) · \(partner.category.title(lang))",
            symbol: partner.category.symbol,
            tint: partner.plan == .sponsoredPlacement ? AppColors.warning : AppColors.dutchOrange,
            kind: .partner(partner)
        )
    }

    private func eventItem(_ event: CalendarEvent) -> PlacesDiscoveryItem {
        PlacesDiscoveryItem(
            title: event.localTitle ?? event.title,
            subtitle: eventSubtitle(event),
            symbol: event.type.symbol,
            tint: event.type.accent,
            kind: .destination(.calendarEvent(event.id))
        )
    }

    private func eventSubtitle(_ event: CalendarEvent) -> String {
        let formatter = DateFormatter()
        formatter.calendar = CalendarEventData.calendar
        formatter.locale = Locale(identifier: lang == .dutch ? "nl_NL" : lang == .russian ? "ru_RU" : "en_US")
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return "\(event.type.title(lang)) · \(formatter.string(from: event.date))"
    }

    private func compactAISummary(for place: NearbyPlace) -> String {
        place.localizedUseCase(lang)
    }

    private func compactAISummary(for partner: LocalPartner) -> String {
        partner.description
    }

    private func handleUniversalInput() {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        isInputFocused = false

        if isNaturalLanguageQuestion(trimmed) {
            onAskAI(trimmed)
            return
        }

        if let partner = cityPartners.first(where: { partnerMatches($0, query: trimmed) }) {
            onNavigate(.localPartnerDetail(partner.id))
            return
        }

        mapViewModel.searchText = trimmed
        mapViewModel.commitSearch()

        let result = AppSearchEngine().answerContext(
            for: trimmed,
            language: lang,
            context: AIContext(
                screen: .map,
                category: selectedFilter.title(lang),
                topicTitle: "Places",
                topicSummary: "Unified discovery query: \(trimmed)",
                officialSources: [],
                lastReviewed: nil,
                userLanguage: lang,
                userSituation: appState.selectedUserStatus?.localized(lang),
                selectedCity: mapViewModel.selectedCity,
                selectedProvince: nil,
                selectedAudience: UserContentCategory.from(persona: appState.selectedUserStatus?.personaTag),
                savedItemTitles: [],
                lastSearches: mapViewModel.recentSearches,
                disclaimer: AISafetyRules.mandatoryDisclaimer(for: lang),
                activePersonaTag: appState.selectedUserStatus?.personaTag
            )
        )

        if let destination = result.destination, destination != AppDestination.searchList {
            onNavigate(destination)
        } else if let filter = discoveryFilter(for: trimmed) {
            selectedFilter = filter
            displayMode = .list
            mapViewModel.searchText = ""
        } else if let place = places.first {
            selectedPlace = place
        } else {
            onAskAI(trimmed)
        }
    }

    private func askAIFromInput() {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        isInputFocused = false
        onAskAI(trimmed.isEmpty ? "Help me discover useful places, services, and local partners in \(mapViewModel.selectedCity)." : trimmed)
    }

    private func isNaturalLanguageQuestion(_ text: String) -> Bool {
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard normalized.contains(" ") else { return false }
        if normalized.hasSuffix("?") { return true }
        return ["how ", "what ", "where ", "when ", "why ", "can i ", "do i ", "should i ", "как ", "что ", "где ", "когда ", "можно ли ", "hoe ", "wat ", "waar ", "wanneer "].contains { normalized.hasPrefix($0) }
    }

    private func discoveryFilter(for text: String) -> PlacesDiscoveryFilter? {
        let normalized = text.lowercased()
        let filters: [(PlacesDiscoveryFilter, [String])] = [
            (.food, ["dinner", "lunch", "breakfast", "eat", "food", "еда", "eten"]),
            (.restaurants, ["restaurant", "restaurants", "ресторан"]),
            (.cafes, ["cafe", "cafes", "café", "coffee", "bakery", "кафе", "кофе", "koffie"]),
            (.hotels, ["hotel", "hotels", "hostel", "stay", "отель", "гостиница"]),
            (.healthcare, ["doctor", "hospital", "huisarts", "pharmacy", "apotheek", "health", "врач", "больница", "аптека"]),
            (.government, ["bsn", "gemeente", "municipality", "ind", "duo", "uwv", "government", "муниципалитет"]),
            (.shopping, ["shopping", "shop", "supermarket", "ikea", "grocery", "магазин", "покупки"]),
            (.transport, ["train", "tram", "bus", "metro", "bike", "transport", "ov", "транспорт"]),
            (.education, ["university", "school", "library", "education", "student", "образование", "университет"]),
            (.localPartners, ["partner", "partners", "verified", "featured", "sponsored", "service", "lawyer", "legal", "jurist", "advocaat", "юрист", "адвокат", "партнер"])
        ]
        return filters.first { _, keywords in
            keywords.contains { normalized.contains($0) }
        }?.0
    }

    private func partnerMatches(_ partner: LocalPartner, query: String) -> Bool {
        let normalized = query.lowercased()
        return [partner.name, partner.category.title(lang), partner.subcategory, partner.description, partner.city]
            .map { $0.lowercased() }
            .contains { $0.contains(normalized) || normalized.contains($0) }
    }

    private var mapAnnotations: [PlacesMapAnnotation] {
        let placeItems = visiblePlaceAnnotations.map { PlacesMapAnnotation(place: $0, tint: color(for: $0.category)) }
        let partnerItems = visiblePartnerAnnotations.map { PlacesMapAnnotation(partner: $0) }
        return placeItems + partnerItems
    }

    private func handleAnnotation(_ item: PlacesMapAnnotation) {
        switch item.kind {
        case .place(let place):
            selectedPlace = place
        case .partner(let partner):
            onNavigate(.localPartnerDetail(partner.id))
        }
    }

    private func chooseProvince(_ provinceID: String) {
        withAnimation(.easeInOut(duration: 0.22)) {
            selectedProvinceID = provinceID
        }
    }

    private func chooseCity(_ city: String) {
        withAnimation(AppAnimations.standard) {
            appState.selectedCity = city
            mapViewModel.selectedCity = city
            selectedProvinceID = provinceID(forCity: city)
            isCityMapOpen = true
            displayMode = .map
        }
    }

    private func provinceName(_ id: String) -> String {
        ProvinceCatalog.item(id: id).localizedName(lang)
    }

    private var selectedProvinceTitle: String {
        provinceName(selectedProvinceID ?? provinceID(forCity: mapViewModel.selectedCity))
    }

    private var selectedProvinceCities: [String] {
        let provinceID = selectedProvinceID ?? provinceID(forCity: mapViewModel.selectedCity)
        return (citiesByProvince[provinceID] ?? [mapViewModel.selectedCity])
            .filter { MockNearbyPlacesData.supportedCities.contains($0) }
    }

    private func provinceID(forCity city: String) -> String {
        let normalized = city.lowercased()
        return cityProvinceLookup.first { key, _ in key.lowercased() == normalized }?.value ?? "Zuid-Holland"
    }

    private var citiesByProvince: [String: [String]] {
        [
            "Noord-Holland": ["Amsterdam", "Haarlem", "Alkmaar", "Hoorn", "Zaanstad", "Amstelveen", "Purmerend"],
            "Zuid-Holland": ["Leiden", "Rotterdam", "Den Haag", "Delft"],
            "Utrecht": ["Utrecht", "Amersfoort"],
            "Noord-Brabant": ["Eindhoven", "Tilburg", "Breda", "s-Hertogenbosch"],
            "Gelderland": ["Arnhem", "Nijmegen"],
            "Limburg": ["Maastricht", "Venlo"],
            "Overijssel": ["Zwolle"],
            "Flevoland": ["Almere", "Lelystad"],
            "Groningen": ["Groningen"],
            "Friesland": ["Leeuwarden"],
            "Drenthe": ["Assen"],
            "Zeeland": ["Middelburg"]
        ]
    }

    private var cityProvinceLookup: [String: String] {
        Dictionary(uniqueKeysWithValues: citiesByProvince.flatMap { province, cities in
            cities.map { ($0, province) }
        })
    }

    private func color(for category: PlaceCategory) -> Color {
        switch category {
        case .healthcare, .hospital, .huisarts, .pharmacy, .nightPharmacy: return AppColors.error
        case .municipality, .ind, .uwv, .duo, .immigrationSupport, .expatCenter: return AppColors.softBlue
        case .transport, .transportOffice, .bikeRepair: return AppColors.dutchOrange
        case .education, .library, .studentHelp: return AppColors.emerald
        case .legalHelp, .police: return AppColors.violet
        default: return AppColors.routeLine
        }
    }

    private func aiSummary(for place: NearbyPlace) -> String {
        switch lang {
        case .russian: return "AI: \(place.localizedUseCase(lang))"
        case .dutch: return "AI: \(place.localizedUseCase(lang))"
        case .english: return "AI: \(place.localizedUseCase(lang))"
        }
    }

    private func aiSummary(for partner: LocalPartner) -> String {
        switch lang {
        case .russian: return "AI: \(partner.description)"
        case .dutch: return "AI: \(partner.description)"
        case .english: return "AI: \(partner.description)"
        }
    }

    private var title: String {
        switch lang {
        case .russian: return "Places"
        case .dutch: return "Places"
        case .english: return "Places"
        }
    }

    private var subtitle: String {
        switch lang {
        case .russian: return "Карта, места, партнеры и единый поиск через AI."
        case .dutch: return "Kaart, plekken, partners en één zoekingang met AI."
        case .english: return "Map, nearby places, partners, and one AI-aware discovery entry point."
        }
    }

    private var inputPlaceholder: String {
        switch lang {
        case .russian: return "Поиск или вопрос AI"
        case .dutch: return "Zoek of vraag AI"
        case .english: return "Search or ask AI"
        }
    }

    private var inputSubmitLabel: String {
        switch lang {
        case .russian: return "Найти или спросить AI"
        case .dutch: return "Zoeken of AI vragen"
        case .english: return "Ask or search"
        }
    }
    private var aiButtonLabel: String {
        switch lang {
        case .russian: return "Спросить AI"
        case .dutch: return "Vraag AI"
        case .english: return "Ask AI"
        }
    }
    private var moreFilterTitle: String {
        switch lang {
        case .russian: return "Еще"
        case .dutch: return "Meer"
        case .english: return "More"
        }
    }
    private var viewAllTitle: String {
        switch lang {
        case .russian: return "Показать все"
        case .dutch: return "Bekijk alles"
        case .english: return "View all"
        }
    }
    private var openNowTitle: String {
        switch lang {
        case .russian: return "Открыто сейчас"
        case .dutch: return "Nu open"
        case .english: return "Open now"
        }
    }
    private var officialDetailsTitle: String {
        switch lang {
        case .russian: return "Откройте источник для актуальных деталей."
        case .dutch: return "Open de bron voor actuele details."
        case .english: return "Open the source for current details."
        }
    }

    private var mapTitle: String { displayMode == .map ? "Interactive map" : "Map" }
    private var exploreMapTitle: String { lang == .russian ? "Исследуйте город" : lang == .dutch ? "Verken de stad" : "Explore the city" }
    private var mapOverlayTitle: String { lang == .russian ? "Карта — главный экран" : lang == .dutch ? "De kaart is centraal" : "Explore through the map" }
    private var mapOverlaySubtitle: String { lang == .russian ? "Нажмите маркер, чтобы открыть место." : lang == .dutch ? "Tik op een marker om een plek te openen." : "Tap a marker to open a place." }
    private var listTitle: String { "Nearby places" }
    private var openTitle: String { lang == .russian ? "Открыть" : lang == .dutch ? "Open" : "Open" }
    private var openFullMapTitle: String { "Open full map" }
    private var openCityMapTitle: String { lang == .russian ? "Карта города" : lang == .dutch ? "Stadskaart" : "City map" }
    private var countryMapTitle: String {
        switch lang {
        case .russian: return "Нидерланды"
        case .dutch: return "Nederland"
        case .english: return "Netherlands"
        }
    }
    private var countryMapSubtitle: String {
        switch lang {
        case .russian: return "Выберите провинцию, затем город, чтобы открыть рабочую карту."
        case .dutch: return "Kies een provincie en daarna een stad om de werkkaart te openen."
        case .english: return "Choose a province, then a city to open the working map."
        }
    }
    private var provinceCountLabel: String {
        switch lang {
        case .russian: return "провинций"
        case .dutch: return "provincies"
        case .english: return "provinces"
        }
    }
    private var sourceNoteText: String { "Information only. Opening hours, prices, eligibility, and availability must be verified with the official source or business." }
    private var resultSummary: String { "\(places.count + partners.count) results in \(ProvinceCatalog.localizedCityName(mapViewModel.selectedCity, lang))" }
    private var nearbySectionTitle: String { lang == .russian ? "Рядом" : lang == .dutch ? "Dichtbij" : "Nearby" }
    private var nearbySectionSubtitle: String { lang == .russian ? "Самое полезное рядом с выбранным городом." : lang == .dutch ? "De nuttigste plekken rond de gekozen stad." : "The most useful places around the selected city." }
    private var localPartnersSectionTitle: String { "Local Partners" }
    private var localPartnersSectionSubtitle: String { lang == .russian ? "Коммерческие карточки честно помечены статусом." : lang == .dutch ? "Commerciele vermeldingen hebben een duidelijk label." : "Commercial listings are clearly labeled." }
    private var todaysEventsSectionTitle: String { lang == .russian ? "Сегодня" : lang == .dutch ? "Vandaag" : "Today's Events" }
    private var todaysEventsSectionSubtitle: String { lang == .russian ? "Актуальность проверяйте у источника." : lang == .dutch ? "Controleer actuele details bij de bron." : "Check current details with the source." }
}

private struct PlacesDiscoverySection: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let items: [PlacesDiscoveryItem]
}

private struct PlacesDiscoveryItem: Identifiable {
    enum Kind {
        case place(NearbyPlace)
        case partner(LocalPartner)
        case destination(AppDestination)
    }

    let id: String
    let title: String
    let subtitle: String
    let symbol: String
    let tint: Color
    let kind: Kind

    init(title: String, subtitle: String, symbol: String, tint: Color, kind: Kind) {
        self.title = title
        self.subtitle = subtitle
        self.symbol = symbol
        self.tint = tint
        self.kind = kind
        switch kind {
        case .place(let place):
            id = "place-\(place.saveKey)"
        case .partner(let partner):
            id = "partner-\(partner.id)"
        case .destination(let destination):
            id = "destination-\(StableRouteID.uuid(String(describing: destination)).uuidString)"
        }
    }
}

private struct PlacesMapAnnotation: Identifiable {
    enum Kind {
        case place(NearbyPlace)
        case partner(LocalPartner)
    }

    let id: String
    let title: String
    let coordinate: CLLocationCoordinate2D
    let symbol: String
    let tint: Color
    let kind: Kind

    init(place: NearbyPlace, tint: Color) {
        id = "place-\(place.saveKey)"
        title = place.name
        coordinate = place.coordinate
        symbol = place.discoverySymbolName
        self.tint = tint
        kind = .place(place)
    }

    init(partner: LocalPartner) {
        id = "partner-\(partner.id)"
        title = partner.name
        coordinate = partner.coordinate
        switch partner.plan {
        case .verifiedPartner:
            symbol = "checkmark.seal.fill"
            tint = AppColors.success
        case .featured, .aiFeatured, .premium:
            symbol = "star.fill"
            tint = AppColors.dutchOrange
        case .sponsoredPlacement:
            symbol = "megaphone.fill"
            tint = AppColors.warning
        case .freeListing:
            symbol = partner.category.symbol
            tint = AppColors.routeLine
        }
        kind = .partner(partner)
    }
}

private extension View {
    func placesInputChrome() -> some View {
        self
            .font(AppTypography.body)
            .padding(14)
            .background(AppColors.glassSurfaceElevated, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(AppColors.stroke.opacity(0.8), lineWidth: 0.8))
            .padding(.top, 8)
            .accessibilityIdentifier("places.universalInput")
    }
}
