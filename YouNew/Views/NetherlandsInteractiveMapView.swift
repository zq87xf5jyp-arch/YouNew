import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Netherlands Map Hub (Map Tab Root)

struct NetherlandsMapHubView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var router: TabRouter
    @State private var selectedProvinceID: String? = "Noord-Holland"
    @State private var selectedTerritory: OverseasTerritory?
    @State private var showsTerritoriesGallery = false
    @State private var mapScale: CGFloat = 1
    @State private var mapOffset: CGSize = .zero
    @GestureState private var gestureScale: CGFloat = 1
    @GestureState private var gestureOffset: CGSize = .zero

    private var lang: AppLanguage { languageManager.appLanguage }
    private var displayedMapScale: CGFloat { min(max(mapScale * gestureScale, 1), 3.2) }
    private var displayedMapOffset: CGSize {
        CGSize(
            width: mapOffset.width + gestureOffset.width,
            height: mapOffset.height + gestureOffset.height
        )
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                mapBackground.ignoresSafeArea()

                mapContent(viewport: proxy.size)
            }
        }
        .animation(.spring(response: 0.38, dampingFraction: 0.86), value: selectedProvinceID)
        .onReceive(router.mapReset) { _ in
            resetMapInteractionState()
        }
        .nlNavigationBarHidden()
        .accessibilityIdentifier("map.hub")
        .sheet(item: $selectedTerritory) { territory in
            TerritorySheet(territory: territory)
        }
        .sheet(isPresented: $showsTerritoriesGallery) {
            TerritoriesGallerySheet { territory in
                showsTerritoriesGallery = false
                selectedTerritory = territory
            }
        }
    }

    private var mapGestureMask: GestureMask {
        selectedProvinceID == nil && selectedTerritory == nil ? .all : .subviews
    }

    private func resetMapInteractionState() {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.84)) {
            selectedProvinceID = "Noord-Holland"
            selectedTerritory = nil
            mapScale = 1
            mapOffset = .zero
        }
    }

    private func mapZoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureScale) { value, state, _ in
                state = min(max(value, 1 / max(mapScale, 0.01)), 3.2 / max(mapScale, 0.01))
            }
            .onEnded { value in
                mapScale = min(max(mapScale * value, 1), 3.2)
                if mapScale <= 1.03 {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                        mapScale = 1
                        mapOffset = .zero
                    }
                }
            }
    }

    // MARK: - Background

    private var mapBackground: some View {
        ZStack {
            Color(hex: "#04101A")

            RadialGradient(
                colors: [
                    Color(hex: "#12324A").opacity(0.80),
                    Color.clear
                ],
                center: UnitPoint(x: 0.55, y: 0.50),
                startRadius: 0,
                endRadius: backgroundGlowEndRadius
            )

            OceanWaveTextureLayer()

            LinearGradient(
                colors: [
                    Color(hex: "#0A2131").opacity(0.16),
                    Color(hex: "#020811").opacity(0.88)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            CartographicGridLayer()
                .opacity(0.72)
        }
    }

    private var backgroundGlowEndRadius: CGFloat {
        520
    }

    private func mapContent(viewport size: CGSize) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                mapControlDeck

                mapViewport
                    .frame(height: MapDashboardLayout.mapViewportHeight(for: size))
                    .padding(.bottom, MapDashboardLayout.sectionSpacing)

                mapDashboardSection
            }
            .padding(.bottom, MapDashboardLayout.tabClearance)
        }
        .scrollDismissesKeyboard(.interactively)
        .accessibilityIdentifier("map.controls")
        .accessibilityIdentifier("map.scroll")
    }

    // MARK: - Header

    private var mapControlDeck: some View {
        VStack(spacing: 4) {
            mapHeader

            mapChipRow
                .padding(.horizontal, 10)

            mapDiscoveryStrip
                .padding(.horizontal, 10)
        }
        .padding(.bottom, 5)
        .safeAreaPadding(.top, 2)
        .background {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(.ultraThinMaterial)
                LinearGradient(
                    colors: [
                        Color(hex: "#07111E").opacity(0.96),
                        Color(hex: "#0A1726").opacity(0.90),
                        Color(hex: "#07111E").opacity(0.76)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                Rectangle()
                    .fill(Color.white.opacity(0.035))
                    .frame(height: 1)
            }
        }
        .shadow(color: Color.black.opacity(0.26), radius: 22, x: 0, y: 16)
        .zIndex(20)
    }

    private var mapViewport: some View {
        GeometryReader { geo in
            let mapContentHeight = max(1, geo.size.height)

            ZStack {
                mapViewportBackground

                ZStack {
                    PremiumProvinceMapCanvas(
                        selectedProvinceID: selectedProvinceID
                    )
                    .allowsHitTesting(false)

                    ProvinceMapLabelLayer(
                        selectedProvinceID: selectedProvinceID,
                        size: geo.size
                    )
                    .allowsHitTesting(false)

                    CityDotMapLayer()
                        .allowsHitTesting(false)

                    MapLandmarkLayer()
                        .opacity(0.46)
                        .allowsHitTesting(false)

                    MapDecorationLayer()
                        .allowsHitTesting(false)

                    ProvinceTapLayer(selectedProvinceID: $selectedProvinceID)

                    CityNavigationTapLayer()
                        .allowsHitTesting(selectedProvinceID == nil)
                }
                .padding(.horizontal, 8)
                .padding(.top, 8)
                .frame(height: mapContentHeight, alignment: .top)
                .frame(maxHeight: .infinity, alignment: .top)
                .scaleEffect(displayedMapScale * MapDashboardLayout.baseMapScale)
                .offset(
                    x: displayedMapOffset.width,
                    y: displayedMapOffset.height + MapDashboardLayout.baseMapYOffset
                )
                .simultaneousGesture(mapZoomGesture(), including: mapGestureMask)

                mapSideToolbar
                    .padding(.trailing, 10)
                    .padding(.top, 46)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .zIndex(10)
            }
            .clipShape(Rectangle())
        }
    }

    private var mapViewportBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "#020A14"),
                    Color(hex: "#052A42"),
                    Color(hex: "#04101A")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [
                    Color(hex: "#0EA5E9").opacity(0.28),
                    Color(hex: "#075985").opacity(0.10),
                    Color.clear
                ],
                center: UnitPoint(x: 0.46, y: 0.42),
                startRadius: 16,
                endRadius: 250
            )
            RadialGradient(
                colors: [
                    Color(hex: "#22D3EE").opacity(0.14),
                    Color.clear
                ],
                center: UnitPoint(x: 0.28, y: 0.62),
                startRadius: 0,
                endRadius: 300
            )
            OceanWaveTextureLayer()
                .opacity(0.54)
        }
    }

    private var mapHeader: some View {
        mapHeaderHorizontal
    }

    private var mapChipRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                mapChip(
                    title: localizedMapChipText(en: "All", nl: "Alles", ru: "Все"),
                    symbol: "square.grid.2x2.fill",
                    destination: .mapHub,
                    accessibilityIdentifier: "map.chip.all"
                )

                mapChip(
                    title: MapFocus.emergency.localized(lang),
                    symbol: MapFocus.emergency.symbol,
                    destination: .mapFocus(.emergency),
                    accessibilityIdentifier: "map.chip.emergency"
                )

                ForEach(mapChipCategories, id: \.id) { category in
                    mapChip(
                        title: category.localized(lang),
                        symbol: category.systemImageName,
                        destination: .mapFocus(.category(category)),
                        accessibilityIdentifier: accessibilityIdentifier(for: category)
                    )
                }
            }
            .padding(.horizontal, 1)
            .padding(.vertical, 1)
        }
        .frame(height: 38)
        .contentShape(Rectangle())
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("map.chip.row")
    }

    private var mapCityRouteShortcutRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(CityDotMapLayer.cities, id: \.name) { city in
                    NavigationLink(value: AppDestination.cityDetail(province: city.provinceID, city: city.name)) {
                        HStack(spacing: 6) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 12, weight: .bold))
                            Text(city.name)
                                .font(.system(.footnote, design: .rounded).weight(.bold))
                                .lineLimit(1)
                        }
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 9)
                        .background {
                            Capsule()
                                .fill(Color(red: 6 / 255, green: 13 / 255, blue: 26 / 255).opacity(0.72))
                            Capsule()
                                .stroke(Color.white.opacity(0.15), lineWidth: 0.85)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(city.name)
                    .accessibilityIdentifier("map.city.\(city.name.snakeCasedProvinceID)")
                }
            }
            .padding(.horizontal, 2)
            .padding(.vertical, 2)
        }
        .frame(height: 48)
        .accessibilityIdentifier("map.city.routes")
    }

    private var mapDiscoveryStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(discoveryCities, id: \.name) { city in
                    NavigationLink(value: AppDestination.cityDetail(province: city.provinceID, city: city.name)) {
                        mapDiscoveryPill(
                            title: city.name,
                            symbol: city.name == "Leiden" ? "sparkles" : "mappin.and.ellipse",
                            tint: discoveryTint(for: city.name),
                            isSelected: city.name == "Amsterdam"
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("map.discovery.city.\(city.name.snakeCasedProvinceID)")
                }
            }
            .padding(4)
        }
        .background(.ultraThinMaterial)
        .background(Color(hex: "#07111E").opacity(0.56))
        .clipShape(RoundedRectangle(cornerRadius: 19, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 19, style: .continuous).stroke(Color.white.opacity(0.10), lineWidth: 0.8))
        .shadow(color: Color.black.opacity(0.24), radius: 16, x: 0, y: 10)
    }

    private var discoveryCities: [CityDotMapLayer.CityPoint] {
        ["Amsterdam", "Rotterdam", "Den Haag", "Leiden"].compactMap { name in
            CityDotMapLayer.cities.first { $0.name == name }
        }
    }

    private func discoveryTint(for city: String) -> Color {
        switch city {
        case "Amsterdam": return AppColors.dutchOrange
        case "Rotterdam": return Color(hex: "#6366F1")
        case "Den Haag": return AppColors.cyanGlow
        case "Leiden": return Color(hex: "#FBBF24")
        default: return AppColors.cyanGlow
        }
    }

    private func mapDiscoveryPill(title: String, symbol: String, tint: Color, isSelected: Bool = false) -> some View {
        HStack(spacing: 4) {
            Image(systemName: symbol)
                .font(.system(size: 9.5, weight: .bold))
            Text(title)
                .font(.system(size: 10.5, weight: .bold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.70)
        }
        .foregroundStyle(isSelected ? tint : Color.white.opacity(0.82))
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            LinearGradient(
                colors: [
                    tint.opacity(isSelected ? 0.26 : 0.13),
                    Color(hex: "#081624").opacity(0.78)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(tint.opacity(isSelected ? 0.68 : 0.30), lineWidth: isSelected ? 1.0 : 0.7))
        .shadow(color: tint.opacity(isSelected ? 0.34 : 0.10), radius: isSelected ? 12 : 6, x: 0, y: 6)
    }

    private var mapChipCategories: [PlaceCategory] {
        let status = appState.selectedUserStatus ?? UserStatus(rawValue: appState.selectedStatus)
        if let status {
            return Array(MapCategoryPriorityEngine.prioritizedCategories(for: status).prefix(4))
        }

        return [.municipality, .transport, .legalHelp, .healthcare]
    }

    private func mapChip(
        title: String,
        symbol: String,
        destination: AppDestination,
        accessibilityIdentifier: String
    ) -> some View {
        NavigationLink(value: destination) {
            HStack(spacing: 6) {
                Image(systemName: symbol)
                    .font(.system(size: 10, weight: .semibold))

                Text(title)
                    .font(.system(size: 10.5, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)
                    .allowsTightening(true)
            }
            .foregroundStyle(Color.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 7)
            .fixedSize(horizontal: true, vertical: false)
            .background {
                Capsule()
                    .fill(Color(red: 7 / 255, green: 16 / 255, blue: 28 / 255).opacity(0.76))
                Capsule()
                    .stroke(Color.white.opacity(0.18), lineWidth: 0.85)
            }
            .shadow(color: Color.black.opacity(0.18), radius: 10, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityIdentifier(accessibilityIdentifier)
    }

    private func localizedMapChipText(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }

    private func accessibilityIdentifier(for category: PlaceCategory) -> String {
        switch category {
        case .legalHelp:
            return "map.chip.legal_help"
        default:
            return "map.chip.\(category.rawValue)"
        }
    }

    private var mapSideToolbar: some View {
        VStack(spacing: 18) {
            mapToolbarButton("square.3.layers.3d.down.right", accessibilityLabel: "Show all provinces") {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.84)) {
                    selectedProvinceID = nil
                }
            }
            mapToolbarButton("location.viewfinder", accessibilityLabel: "Reset map") {
                resetMapInteractionState()
            }
            mapToolbarButton("ruler", accessibilityLabel: "Select North Holland") {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.84)) {
                    selectedProvinceID = "Noord-Holland"
                }
            }
            mapToolbarButton("globe.europe.africa.fill", accessibilityLabel: "Open overseas territories") {
                showsTerritoriesGallery = true
            }
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 13)
        .background(.ultraThinMaterial)
        .background(Color(hex: "#07111E").opacity(0.68))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color.white.opacity(0.13), lineWidth: 0.8))
        .shadow(color: Color.black.opacity(0.28), radius: 20, x: 0, y: 12)
        .accessibilityIdentifier("map.side.toolbar")
    }

    private func mapToolbarButton(_ symbol: String, accessibilityLabel: String, action: @escaping () -> Void = {}) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.78))
                .frame(width: 28, height: 28)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }

    private var mapDashboardSection: some View {
        GeometryReader { geo in
            let layout = MapDashboardLayout.metrics(for: geo.size)

            VStack(spacing: layout.verticalGap) {
                HStack(alignment: .top, spacing: layout.cardGap) {
                    MapProvinceSummaryCard(
                        province: ProvinceCatalog.item(id: selectedProvinceID ?? "Noord-Holland"),
                        lang: lang
                    )
                    .frame(width: layout.provinceWidth, height: layout.cardHeight)
                    .accessibilityIdentifier("map.summary.noord_holland")

                    MapQuickExplorePanel(lang: lang)
                        .frame(width: layout.quickExploreWidth, height: layout.cardHeight)
                }

                MapOverseasTerritoriesCarousel(lang: lang) { territory in
                    selectedTerritory = territory
                }
                .frame(height: layout.carouselHeight)
            }
            .padding(.horizontal, layout.horizontalPadding)
            .padding(.top, layout.topPadding)
            .padding(.bottom, layout.bottomPadding)
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
        }
        .frame(height: MapDashboardLayout.dashboardHeight)
    }

    private var mapHeaderHorizontal: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(headerTitle)
                    .font(.system(size: 29, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
                    .fixedSize(horizontal: false, vertical: true)
                    .contentTransition(.interpolate)
                    .animation(.spring(response: 0.3), value: selectedProvinceID)
                Text(headerSubtitle)
                    .font(.system(size: 11.5, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.52))
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            NavigationLink(value: AppDestination.mapHub) {
                HStack(spacing: 8) {
                    Image(systemName: "location.north.circle.fill")
                        .font(.system(size: 18, weight: .bold))
                    Text(nearbyLabel)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .foregroundStyle(AppColors.dutchOrange)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color(hex: "#1B1511").opacity(0.74))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(AppColors.dutchOrange.opacity(0.72), lineWidth: 1.0))
                .shadow(color: AppColors.dutchOrange.opacity(0.24), radius: 18, x: 0, y: 7)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 18)
        .padding(.top, 6)
        .padding(.bottom, 4)
    }

    private var mapHeaderVertical: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(headerTitle)
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
                    .fixedSize(horizontal: false, vertical: true)
                    .contentTransition(.interpolate)
                    .animation(.spring(response: 0.3), value: selectedProvinceID)
                Text(headerSubtitle)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.52))
                    .lineLimit(3)
                    .minimumScaleFactor(0.82)
                    .fixedSize(horizontal: false, vertical: true)
            }

            NavigationLink(value: AppDestination.mapHub) {
                Label(nearbyLabel, systemImage: "mappin.circle.fill")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.dutchOrange)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(AppColors.dutchOrange.opacity(0.12))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(AppColors.dutchOrange.opacity(0.28), lineWidth: 0.8))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .background(Color(red: 6 / 255, green: 13 / 255, blue: 26 / 255).opacity(0.72))
    }

    private var mapLegend: some View {
        VStack(alignment: .leading, spacing: 7) {
            mapLegendRow(color: AppColors.dutchOrange, title: localizedLegendText(en: "Selected", nl: "Gekozen", ru: "Выбор"))
            mapLegendRow(color: AppColors.cyanGlow, title: localizedLegendText(en: "Cities", nl: "Steden", ru: "Города"))
            mapLegendRow(color: AppColors.routeLine, title: localizedLegendText(en: "Water routes", nl: "Waterroutes", ru: "Вода"))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .background(.ultraThinMaterial)
        .background(Color(red: 6 / 255, green: 13 / 255, blue: 26 / 255).opacity(0.64))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 0.8)
        )
        .shadow(color: Color.black.opacity(0.24), radius: 18, x: 0, y: 10)
        .frame(width: 132, alignment: .leading)
    }

    private func mapLegendRow(color: Color, title: String) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .shadow(color: color.opacity(0.55), radius: 6, x: 0, y: 0)
            Text(title)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.76))
                .lineLimit(1)
                .minimumScaleFactor(0.58)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func localizedLegendText(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .russian: return ru
        case .dutch: return nl
        case .english: return en
        }
    }

    // MARK: - Localized strings

    private var headerTitle: String {
        switch lang {
        case .russian: return "Где сделать следующий шаг"
        case .dutch: return "Waar je volgende stap gebeurt"
        case .english: return "Where your next step happens"
        }
    }

    private var headerSubtitle: String {
        switch lang {
        case .russian: return "Выберите город, службу или категорию под текущий сценарий."
        case .dutch: return "Kies een stad, dienst of categorie voor je huidige scenario."
        case .english: return "Choose a city, service, or category for your current scenario."
        }
    }

    private var nearbyLabel: String {
        switch lang {
        case .russian: return "Рядом"
        case .dutch: return "Nabij"
        case .english: return "Nearby"
        }
    }
}

// MARK: - Premium Province Canvas

private struct ProvinceTapLayer: View {
    @Binding var selectedProvinceID: String?

    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.spring(response: 0.35)) {
                        selectedProvinceID = nil
                    }
                }

            ForEach(RealProvinceMapData.provinces, id: \.id) { province in
                ProvinceRealMapShape(provinceID: province.id)
                    .fill(Color.clear)
                    .contentShape(ProvinceRealMapShape(provinceID: province.id))
                    .onTapGesture {
                        if selectedProvinceID == province.id {
                            withAnimation(.spring(response: 0.35)) {
                                selectedProvinceID = nil
                            }
                        } else {
                            withAnimation(.spring(response: 0.35)) {
                                selectedProvinceID = province.id
                            }
#if canImport(UIKit)
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
#endif
                        }
                    }
                    .accessibilityLabel(ProvinceCatalog.item(id: province.id).localizedName(.english))
                    .accessibilityIdentifier("provinces.map.zone.\(province.id.snakeCasedProvinceID)")
            }
        }
    }
}

private struct CartographicGridLayer: View {
    var body: some View {
        Canvas { context, size in
            drawGrid(context: context, size: size, spacing: 22, opacity: 0.028, lineWidth: 0.35)
            drawGrid(context: context, size: size, spacing: 88, opacity: 0.055, lineWidth: 0.55)
        }
        .allowsHitTesting(false)
    }

    private func drawGrid(context: GraphicsContext, size: CGSize, spacing: CGFloat, opacity: Double, lineWidth: CGFloat) {
        var x: CGFloat = 0
        while x <= size.width {
            var path = Path()
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: size.height))
            context.stroke(path, with: .color(.white.opacity(opacity)), lineWidth: lineWidth)
            x += spacing
        }

        var y: CGFloat = 0
        while y <= size.height {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: size.width, y: y))
            context.stroke(path, with: .color(.white.opacity(opacity)), lineWidth: lineWidth)
            y += spacing
        }
    }
}

private struct OceanWaveTextureLayer: View {
    var body: some View {
        Canvas { context, size in
            var y: CGFloat = 0
            while y <= size.height {
                var wave = Path()
                wave.move(to: CGPoint(x: 0, y: y))
                var x: CGFloat = 0
                while x <= size.width {
                    let waveY = y + sin(x * 0.04) * 2
                    wave.addLine(to: CGPoint(x: x, y: waveY))
                    x += 4
                }
            context.stroke(wave, with: .color(Color(hex: "#67E8F9").opacity(0.018)), lineWidth: 0.35)
                y += 18
            }

            for index in 0..<9 {
                let inset = CGFloat(index) * 15
                var shelf = Path()
                shelf.addEllipse(in: CGRect(
                    x: size.width * 0.02 + inset,
                    y: size.height * 0.08 + inset * 0.34,
                    width: size.width * 0.94 - inset * 1.45,
                    height: size.height * 0.92 - inset * 1.05
                ))
                context.stroke(
                    shelf,
                    with: .color(Color(hex: "#7DD3FC").opacity(0.014)),
                    style: StrokeStyle(lineWidth: 0.5, dash: [5, 8])
                )
            }
        }
        .allowsHitTesting(false)
    }
}

private struct PremiumProvinceMapCanvas: View {
    let selectedProvinceID: String?

    var body: some View {
        Canvas { context, size in
            drawSeaShelf(ctx: context, size: size)
            drawCountrySilhouette(ctx: context, size: size)
            for shape in ProvinceMapShape.allCases {
                drawProvince(ctx: context, size: size, shape: shape)
            }
            drawProvinceAtmosphere(ctx: context, size: size)
            drawDeltaAndRouteNetwork(ctx: context, size: size)
            drawWaterBodies(ctx: context, size: size)
            drawCoastline(ctx: context, size: size)
        }
    }

    private func drawDeepSeaBackdrop(ctx: GraphicsContext, size: CGSize) {
        for index in 0..<18 {
            let y = size.height * (0.08 + CGFloat(index) * 0.052)
            var current = Path()
            current.move(to: CGPoint(x: -size.width * 0.08, y: y))
            current.addQuadCurve(
                to: CGPoint(x: size.width * 1.08, y: y + sin(CGFloat(index) * 0.9) * 8),
                control: CGPoint(x: size.width * 0.42, y: y + cos(CGFloat(index) * 0.55) * 15)
            )
            ctx.stroke(
                current,
                with: .color(Color(hex: "#67E8F9").opacity(index.isMultiple(of: 3) ? 0.034 : 0.018)),
                style: StrokeStyle(lineWidth: index.isMultiple(of: 3) ? 0.58 : 0.36, lineCap: .round, dash: [5, 20])
            )
        }

        for index in 0..<8 {
            let inset = CGFloat(index) * 14 + 18
            let rect = CGRect(
                x: inset,
                y: size.height * 0.05 + CGFloat(index) * 3,
                width: max(20, size.width - inset * 2),
                height: max(20, size.height * (0.84 - CGFloat(index) * 0.025))
            )
            ctx.stroke(
                Path(ellipseIn: rect),
                with: .color(Color(hex: "#0EA5E9").opacity(0.028)),
                style: StrokeStyle(lineWidth: 0.55, lineCap: .round, dash: [7, 14])
            )
        }
    }

    private func drawSeaShelf(ctx: GraphicsContext, size: CGSize) {
        let country = RealProvinceMapData.countryPath(in: size)

        var shadow = ctx
        shadow.addFilter(.blur(radius: 8))
        shadow.stroke(country, with: .color(Color(hex: "#67E8F9").opacity(0.24)), lineWidth: 9)
        shadow.stroke(country, with: .color(Color(hex: "#14B8A6").opacity(0.10)), lineWidth: 14)
        shadow.stroke(country, with: .color(Color.black.opacity(0.22)), lineWidth: 5)

        var atmosphere = ctx
        atmosphere.addFilter(.blur(radius: 12))
        atmosphere.fill(country, with: .color(Color(hex: "#22D3EE").opacity(0.07)))

        let tidalPaths: [[CGPoint]] = [
            [CGPoint(x: 0.13, y: 0.18), CGPoint(x: 0.10, y: 0.33), CGPoint(x: 0.10, y: 0.48), CGPoint(x: 0.13, y: 0.62), CGPoint(x: 0.10, y: 0.77)],
            [CGPoint(x: 0.19, y: 0.13), CGPoint(x: 0.16, y: 0.30), CGPoint(x: 0.17, y: 0.47), CGPoint(x: 0.20, y: 0.62), CGPoint(x: 0.17, y: 0.82)],
            [CGPoint(x: 0.82, y: 0.18), CGPoint(x: 0.82, y: 0.34), CGPoint(x: 0.84, y: 0.52), CGPoint(x: 0.82, y: 0.70), CGPoint(x: 0.78, y: 0.90)]
        ]

        for (index, points) in tidalPaths.enumerated() {
            let path = RealProvinceMapData.openPath(points: points, in: size)
            ctx.stroke(
                path,
                with: .color(Color(hex: "#67E8F9").opacity(index == 1 ? 0.22 : 0.13)),
                style: StrokeStyle(lineWidth: index == 1 ? 0.9 : 0.58, lineCap: .round, lineJoin: .round, dash: [7, 11])
            )
        }
    }

    private func drawCountrySilhouette(ctx: GraphicsContext, size: CGSize) {
        let path = RealProvinceMapData.countryPath(in: size)
        ctx.fill(path, with: .color(ProvinceStyle.land.opacity(0.24)))
        ctx.stroke(path, with: .color(ProvinceStyle.borderCoast.opacity(0.26)), lineWidth: 4.8)
        ctx.stroke(path, with: .color(Color.black.opacity(0.26)), lineWidth: 1.4)
    }

    private func drawWaterBodies(ctx: GraphicsContext, size: CGSize) {
        let waddenzee = RealProvinceMapData.path(points: [
            CGPoint(x: 0.255, y: 0.058),
            CGPoint(x: 0.326, y: 0.043),
            CGPoint(x: 0.414, y: 0.034),
            CGPoint(x: 0.522, y: 0.030),
            CGPoint(x: 0.632, y: 0.036),
            CGPoint(x: 0.735, y: 0.050),
            CGPoint(x: 0.812, y: 0.066),
            CGPoint(x: 0.776, y: 0.092),
            CGPoint(x: 0.654, y: 0.088),
            CGPoint(x: 0.538, y: 0.082),
            CGPoint(x: 0.420, y: 0.094),
            CGPoint(x: 0.308, y: 0.102),
            CGPoint(x: 0.226, y: 0.088)
        ], in: size)
        ctx.fill(waddenzee, with: ProvinceStyle.waterShading(in: size, opacity: 0.82))
        ctx.stroke(waddenzee, with: .color(Color(hex: "#A7F3D0").opacity(0.28)), lineWidth: 0.75)
        ctx.stroke(waddenzee, with: .color(Color.white.opacity(0.10)), lineWidth: 0.35)

        let ijsselmeer = RealProvinceMapData.path(points: [
            CGPoint(x: 0.365, y: 0.224),
            CGPoint(x: 0.436, y: 0.203),
            CGPoint(x: 0.512, y: 0.209),
            CGPoint(x: 0.580, y: 0.248),
            CGPoint(x: 0.604, y: 0.315),
            CGPoint(x: 0.576, y: 0.365),
            CGPoint(x: 0.506, y: 0.394),
            CGPoint(x: 0.428, y: 0.376),
            CGPoint(x: 0.386, y: 0.314)
        ], in: size)
        ctx.fill(ijsselmeer, with: ProvinceStyle.waterShading(in: size, opacity: 0.94))
        ctx.stroke(ijsselmeer, with: .color(Color(hex: "#A7F3D0").opacity(0.34)), lineWidth: 0.95)
        ctx.stroke(ijsselmeer, with: .color(Color.white.opacity(0.12)), lineWidth: 0.35)

        let markermeer = RealProvinceMapData.path(points: [
            CGPoint(x: 0.360, y: 0.357),
            CGPoint(x: 0.423, y: 0.365),
            CGPoint(x: 0.486, y: 0.402),
            CGPoint(x: 0.508, y: 0.456),
            CGPoint(x: 0.460, y: 0.500),
            CGPoint(x: 0.386, y: 0.484),
            CGPoint(x: 0.340, y: 0.426)
        ], in: size)
        ctx.fill(markermeer, with: .color(Color(hex: "#123852").opacity(0.90)))
        ctx.stroke(markermeer, with: .color(Color(hex: "#A7F3D0").opacity(0.28)), lineWidth: 0.65)
        ctx.stroke(markermeer, with: .color(Color.white.opacity(0.08)), lineWidth: 0.3)
    }

    private func drawDeltaAndRouteNetwork(ctx: GraphicsContext, size: CGSize) {
        let waterways: [[CGPoint]] = [
            [CGPoint(x: 0.23, y: 0.58), CGPoint(x: 0.30, y: 0.57), CGPoint(x: 0.39, y: 0.55), CGPoint(x: 0.48, y: 0.58), CGPoint(x: 0.56, y: 0.61), CGPoint(x: 0.66, y: 0.66)],
            [CGPoint(x: 0.25, y: 0.67), CGPoint(x: 0.34, y: 0.66), CGPoint(x: 0.43, y: 0.68), CGPoint(x: 0.53, y: 0.70), CGPoint(x: 0.65, y: 0.72)],
            [CGPoint(x: 0.42, y: 0.40), CGPoint(x: 0.49, y: 0.45), CGPoint(x: 0.51, y: 0.54), CGPoint(x: 0.48, y: 0.65)],
            [CGPoint(x: 0.58, y: 0.44), CGPoint(x: 0.65, y: 0.50), CGPoint(x: 0.75, y: 0.54), CGPoint(x: 0.82, y: 0.60)]
        ]

        for points in waterways {
            let path = RealProvinceMapData.openPath(points: points, in: size)
            var glow = ctx
            glow.addFilter(.blur(radius: 1.8))
            glow.stroke(path, with: .color(Color(hex: "#7DD3FC").opacity(0.15)), style: StrokeStyle(lineWidth: 2.8, lineCap: .round, lineJoin: .round))
            ctx.stroke(path, with: .color(Color(hex: "#7DD3FC").opacity(0.22)), style: StrokeStyle(lineWidth: 1.7, lineCap: .round, lineJoin: .round))
            ctx.stroke(path, with: .color(Color.white.opacity(0.12)), style: StrokeStyle(lineWidth: 0.75, lineCap: .round, lineJoin: .round))
        }

        let premiumRoutes: [[CGPoint]] = [
            [CGPoint(x: 0.44, y: 0.28), CGPoint(x: 0.55, y: 0.40), CGPoint(x: 0.60, y: 0.62), CGPoint(x: 0.74, y: 0.80)],
            [CGPoint(x: 0.34, y: 0.46), CGPoint(x: 0.37, y: 0.44), CGPoint(x: 0.40, y: 0.50), CGPoint(x: 0.55, y: 0.40)],
            [CGPoint(x: 0.44, y: 0.28), CGPoint(x: 0.57, y: 0.20), CGPoint(x: 0.76, y: 0.08)]
        ]

        for points in premiumRoutes {
            let path = RealProvinceMapData.openPath(points: points, in: size)
            ctx.stroke(path, with: .color(Color(hex: "#FBBF24").opacity(0.13)), style: StrokeStyle(lineWidth: 1.0, lineCap: .round, lineJoin: .round, dash: [4, 7]))
        }
    }

    private func drawIslandFragments(ctx: GraphicsContext, size: CGSize) {
        let islands: [[CGPoint]] = [
            [CGPoint(x: 0.295, y: 0.066), CGPoint(x: 0.326, y: 0.054), CGPoint(x: 0.372, y: 0.050), CGPoint(x: 0.425, y: 0.056), CGPoint(x: 0.397, y: 0.070), CGPoint(x: 0.346, y: 0.076)],
            [CGPoint(x: 0.450, y: 0.048), CGPoint(x: 0.490, y: 0.039), CGPoint(x: 0.550, y: 0.040), CGPoint(x: 0.592, y: 0.049), CGPoint(x: 0.552, y: 0.060), CGPoint(x: 0.492, y: 0.061)],
            [CGPoint(x: 0.617, y: 0.046), CGPoint(x: 0.660, y: 0.036), CGPoint(x: 0.712, y: 0.040), CGPoint(x: 0.742, y: 0.049), CGPoint(x: 0.704, y: 0.060), CGPoint(x: 0.650, y: 0.058)],
            [CGPoint(x: 0.770, y: 0.054), CGPoint(x: 0.810, y: 0.046), CGPoint(x: 0.860, y: 0.050), CGPoint(x: 0.890, y: 0.058), CGPoint(x: 0.846, y: 0.070), CGPoint(x: 0.792, y: 0.067)],
            [CGPoint(x: 0.104, y: 0.786), CGPoint(x: 0.146, y: 0.768), CGPoint(x: 0.205, y: 0.774), CGPoint(x: 0.238, y: 0.796), CGPoint(x: 0.196, y: 0.818), CGPoint(x: 0.132, y: 0.812)],
            [CGPoint(x: 0.118, y: 0.852), CGPoint(x: 0.176, y: 0.828), CGPoint(x: 0.248, y: 0.840), CGPoint(x: 0.302, y: 0.865), CGPoint(x: 0.240, y: 0.894), CGPoint(x: 0.162, y: 0.884)],
            [CGPoint(x: 0.226, y: 0.736), CGPoint(x: 0.278, y: 0.724), CGPoint(x: 0.334, y: 0.742), CGPoint(x: 0.360, y: 0.764), CGPoint(x: 0.302, y: 0.784), CGPoint(x: 0.246, y: 0.766)]
        ]

        for (index, points) in islands.enumerated() {
            let path = RealProvinceMapData.path(points: points, in: size)
            let tint = index < 4 ? Color(hex: "#A7F3D0") : Color(hex: "#2DD4BF")
            var glow = ctx
            glow.addFilter(.blur(radius: 4))
            glow.stroke(path, with: .color(tint.opacity(0.45)), lineWidth: 4.4)
            ctx.fill(path, with: .color(tint.opacity(index < 4 ? 0.18 : 0.24)))
            ctx.stroke(path, with: .color(tint.opacity(0.86)), lineWidth: 0.9)
            ctx.stroke(path, with: .color(Color.white.opacity(0.16)), lineWidth: 0.35)
        }
    }

    private func drawProvinceAtmosphere(ctx: GraphicsContext, size: CGSize) {
        let country = RealProvinceMapData.countryPath(in: size)
        var haze = ctx
        haze.clip(to: country)

        for index in 0..<16 {
            var contour = Path()
            let baseY = size.height * (0.12 + CGFloat(index) * 0.048)
            contour.move(to: CGPoint(x: size.width * 0.04, y: baseY))
            contour.addCurve(
                to: CGPoint(x: size.width * 0.92, y: baseY + sin(CGFloat(index) * 0.8) * 13),
                control1: CGPoint(x: size.width * 0.28, y: baseY - 18),
                control2: CGPoint(x: size.width * 0.62, y: baseY + 22)
            )
            haze.stroke(
                contour,
                with: .color(Color.white.opacity(index.isMultiple(of: 3) ? 0.060 : 0.034)),
                style: StrokeStyle(lineWidth: 0.46, lineCap: .round, dash: [2, 11])
            )
        }
    }

    private func drawCoastline(ctx: GraphicsContext, size: CGSize) {
        let path = RealProvinceMapData.countryPath(in: size)
        var outerGlow = ctx
        outerGlow.addFilter(.blur(radius: 4.8))
        outerGlow.stroke(path, with: .color(Color(hex: "#67E8F9").opacity(0.34)), lineWidth: 4.6)
        ctx.stroke(
            path,
            with: .linearGradient(
                Gradient(colors: [
                    Color(hex: "#D9F99D").opacity(0.82),
                    Color(hex: "#67E8F9").opacity(0.76),
                    Color(hex: "#38BDF8").opacity(0.54)
                ]),
                startPoint: CGPoint(x: size.width * 0.50, y: 0),
                endPoint: CGPoint(x: size.width * 0.50, y: size.height)
            ),
            lineWidth: 1.55
        )
        ctx.stroke(path, with: .color(Color.white.opacity(0.22)), lineWidth: 0.55)
    }

    private func drawProvince(ctx: GraphicsContext, size: CGSize, shape: ProvinceMapShape) {
        guard let province = RealProvinceMapData.province(id: shape.id) else { return }
        let isSelected = selectedProvinceID == shape.id
        let isOther = selectedProvinceID != nil && !isSelected

        let path = province.path(in: size)

        let fill = ProvinceStyle.provinceFill(id: shape.id)
        let selectedGlowBoost: CGFloat = isSelected ? 0.08 : 0

        if isSelected {
            var glowContext = ctx
            glowContext.addFilter(.blur(radius: 7.5))
            glowContext.stroke(path, with: .color(ProvinceStyle.borderSelected.opacity(0.42 + selectedGlowBoost)), lineWidth: 9.5)
            ctx.fill(path, with: ProvinceStyle.selectedFill.shading(in: size, opacity: 0.94))
            drawProvinceDepth(ctx: ctx, size: size, path: path, selected: true)
            drawProvinceTexture(ctx: ctx, size: size, path: path, selected: true)
            ctx.stroke(path, with: .color(Color.white.opacity(0.26)), lineWidth: 0.65)
            ctx.stroke(path, with: .color(ProvinceStyle.borderSelected), lineWidth: 1.45)
        } else if isOther {
            ctx.fill(path, with: fill.shading(in: size, opacity: 0.50))
            drawProvinceDepth(ctx: ctx, size: size, path: path, selected: false)
            drawProvinceTexture(ctx: ctx, size: size, path: path, selected: false)
            ctx.stroke(path, with: .color(fill.top.opacity(0.48)), lineWidth: 0.95)
            ctx.stroke(path, with: .color(Color.white.opacity(0.13)), lineWidth: 0.35)
        } else {
            var glowContext = ctx
            glowContext.addFilter(.blur(radius: 5.2))
            glowContext.stroke(path, with: .color(fill.top.opacity(0.42)), lineWidth: 5.8)
            ctx.fill(path, with: fill.shading(in: size, opacity: 1))
            drawProvinceDepth(ctx: ctx, size: size, path: path, selected: false)
            drawProvinceTexture(ctx: ctx, size: size, path: path, selected: false)
            ctx.stroke(path, with: .color(fill.top.opacity(0.92)), lineWidth: 1.45)
            ctx.stroke(path, with: .color(Color.white.opacity(0.24)), lineWidth: 0.48)
        }
    }

    private func drawProvinceDepth(ctx: GraphicsContext, size: CGSize, path: Path, selected: Bool) {
        var depthContext = ctx
        depthContext.blendMode = .multiply
        depthContext.fill(
            path,
            with: .linearGradient(
                Gradient(colors: [
                    Color.white.opacity(selected ? 0.10 : 0.08),
                    Color.clear,
                    Color.black.opacity(selected ? 0.22 : 0.30)
                ]),
                startPoint: CGPoint(x: size.width * 0.12, y: size.height * 0.05),
                endPoint: CGPoint(x: size.width * 0.88, y: size.height * 0.96)
            )
        )
    }

    private func drawProvinceTexture(ctx: GraphicsContext, size: CGSize, path: Path, selected: Bool) {
        var textureContext = ctx
        textureContext.clip(to: path)

        let lineOpacity = selected ? 0.12 : 0.060
        var y: CGFloat = -size.height * 0.10
        while y < size.height * 1.05 {
            var contour = Path()
            contour.move(to: CGPoint(x: -size.width * 0.12, y: y))
            contour.addQuadCurve(
                to: CGPoint(x: size.width * 1.10, y: y + size.height * 0.03),
                control: CGPoint(x: size.width * 0.48, y: y + sin(y * 0.025) * 13)
            )
            textureContext.stroke(
                contour,
                with: .color(Color.white.opacity(lineOpacity)),
                style: StrokeStyle(lineWidth: 0.34, lineCap: .butt, dash: [1.5, 12])
            )
            y += 22
        }

        var ridgeX: CGFloat = size.width * 0.06
        while ridgeX < size.width * 0.98 {
            var ridge = Path()
            ridge.move(to: CGPoint(x: ridgeX, y: -size.height * 0.08))
            ridge.addQuadCurve(
                to: CGPoint(x: ridgeX + size.width * 0.08, y: size.height * 1.06),
                control: CGPoint(x: ridgeX + sin(ridgeX * 0.014) * 10, y: size.height * 0.52)
            )
            textureContext.stroke(
                ridge,
                with: .color(Color.black.opacity(selected ? 0.045 : 0.055)),
                style: StrokeStyle(lineWidth: 0.28, lineCap: .butt, dash: [1.2, 16])
            )
            ridgeX += 34
        }

        textureContext.fill(
            path,
            with: .radialGradient(
                Gradient(colors: [
                    Color.white.opacity(selected ? 0.12 : 0.085),
                    Color.clear
                ]),
                center: CGPoint(x: size.width * 0.35, y: size.height * 0.24),
                startRadius: 0,
                endRadius: size.width * 0.62
            )
        )
    }
}

private enum ProvinceStyle {
    static let land = Color(hex: "#2D4B3B")
    static let border = Color(hex: "#E8D9A8").opacity(0.30)
    static let borderHover = Color(hex: "#A7F3D0").opacity(0.72)
    static let borderCoast = Color(hex: "#7DD3FC").opacity(0.68)
    static let borderSelected = AppColors.dutchOrange
    static let water = Color(hex: "#103852")

    static func waterShading(in size: CGSize, opacity: Double) -> GraphicsContext.Shading {
        .linearGradient(
            Gradient(colors: [
                Color(hex: "#1BAFAF").opacity(opacity * 0.36),
                Color(hex: "#087EAA").opacity(opacity * 0.48),
                Color(hex: "#06263E").opacity(opacity)
            ]),
            startPoint: CGPoint(x: size.width * 0.10, y: size.height * 0.04),
            endPoint: CGPoint(x: size.width * 0.82, y: size.height)
        )
    }

    struct ProvinceFill {
        let top: Color
        let bottom: Color

        func shading(in size: CGSize, opacity: Double) -> GraphicsContext.Shading {
            .linearGradient(
                Gradient(colors: [top.opacity(opacity), bottom.opacity(opacity)]),
                startPoint: CGPoint(x: 0, y: 0),
                endPoint: CGPoint(x: size.width, y: size.height)
            )
        }
    }

    static func provinceFill(id: String) -> ProvinceFill {
        provinceFills[id] ?? ProvinceFill(
            top: Color(hex: "#314A38"),
            bottom: Color(hex: "#20372E")
        )
    }

    static let selectedFill = ProvinceFill(
        top: Color(hex: "#F6C45E").opacity(0.72),
        bottom: Color(hex: "#65411D").opacity(0.84)
    )

    static let provinceFills: [String: ProvinceFill] = [
        "Groningen": ProvinceFill(top: Color(hex: "#A7E957"), bottom: Color(hex: "#21451E")),
        "Friesland": ProvinceFill(top: Color(hex: "#35E5F2"), bottom: Color(hex: "#073F4C")),
        "Drenthe": ProvinceFill(top: Color(hex: "#F080F2"), bottom: Color(hex: "#3B194D")),
        "Overijssel": ProvinceFill(top: Color(hex: "#FFC04A"), bottom: Color(hex: "#58330E")),
        "Gelderland": ProvinceFill(top: Color(hex: "#FF8A2B"), bottom: Color(hex: "#55240D")),
        "Utrecht": ProvinceFill(top: Color(hex: "#EF5CFF"), bottom: Color(hex: "#421653")),
        "Noord-Holland": ProvinceFill(top: Color(hex: "#FBD56C"), bottom: Color(hex: "#684716")),
        "Zuid-Holland": ProvinceFill(top: Color(hex: "#2CE7F2"), bottom: Color(hex: "#074A55")),
        "Zeeland": ProvinceFill(top: Color(hex: "#3AF4D8"), bottom: Color(hex: "#0A484A")),
        "Noord-Brabant": ProvinceFill(top: Color(hex: "#FB7EC2"), bottom: Color(hex: "#54173F")),
        "Limburg": ProvinceFill(top: Color(hex: "#B7F345"), bottom: Color(hex: "#314F16")),
        "Flevoland": ProvinceFill(top: Color(hex: "#56CCFF"), bottom: Color(hex: "#103B67"))
    ]
}

private struct OverseasTerritory: Identifiable {
    let name: String
    let flag: String
    let region: String
    let population: String
    let area: String
    let status: String
    let description: String
    let color: Color

    var id: String { name }

    static let all: [OverseasTerritory] = [
        OverseasTerritory(name: "Aruba", flag: "🇦🇼", region: "Caribbean", population: "112k", area: "180", status: "Country", description: "Autonomous constituent country. Part of the Kingdom of the Netherlands since 1986. Located near Venezuela.", color: Color(red: 245 / 255, green: 158 / 255, blue: 11 / 255)),
        OverseasTerritory(name: "Curaçao", flag: "🇨🇼", region: "Caribbean", population: "153k", area: "444", status: "Country", description: "Autonomous constituent country since 2010. Largest of the ABC islands. Dutch is an official language.", color: Color(red: 59 / 255, green: 130 / 255, blue: 246 / 255)),
        OverseasTerritory(name: "Sint Maarten", flag: "🇸🇽", region: "Caribbean", population: "42k", area: "34", status: "Country", description: "Autonomous country comprising the southern half of Saint Martin island. Smallest country by area in the Kingdom.", color: Color(red: 139 / 255, green: 92 / 255, blue: 246 / 255)),
        OverseasTerritory(name: "Bonaire", flag: "🇧🇶", region: "BES Islands", population: "24k", area: "294", status: "Municipality", description: "Special municipality of the Netherlands since 2010. Famous for diving. Uses the US dollar as currency.", color: Color(red: 34 / 255, green: 197 / 255, blue: 94 / 255)),
        OverseasTerritory(name: "Sint Eustatius", flag: "🇧🇶", region: "BES Islands", population: "3.2k", area: "21", status: "Municipality", description: "Special municipality. Historically known as the Golden Rock, once an important Caribbean trade hub.", color: Color(red: 34 / 255, green: 197 / 255, blue: 94 / 255)),
        OverseasTerritory(name: "Saba", flag: "🇧🇶", region: "BES Islands", population: "1.9k", area: "13", status: "Municipality", description: "Smallest special municipality. Mount Scenery is the highest point of the Kingdom of the Netherlands.", color: Color(red: 34 / 255, green: 197 / 255, blue: 94 / 255))
    ]
}

private enum MapDashboardLayout {
    struct Metrics {
        let horizontalPadding: CGFloat
        let cardGap: CGFloat
        let verticalGap: CGFloat
        let cardHeight: CGFloat
        let carouselHeight: CGFloat
        let topPadding: CGFloat
        let bottomPadding: CGFloat
        let provinceWidth: CGFloat
        let quickExploreWidth: CGFloat
    }

    static let headerHeight: CGFloat = 204
    static let sectionSpacing: CGFloat = 12
    static let cardHeight: CGFloat = 150
    static let carouselHeight: CGFloat = 115
    static let dashboardTopPadding: CGFloat = 0
    static let dashboardBottomPadding: CGFloat = 0
    static let dashboardHeight: CGFloat = cardHeight + sectionSpacing + carouselHeight + dashboardTopPadding + dashboardBottomPadding
    static let tabClearance: CGFloat = FloatingTabBarMetrics.totalClearance + 16
    static let baseMapScale: CGFloat = 0.84
    static let baseMapYOffset: CGFloat = -3

    static func mapViewportHeight(for size: CGSize) -> CGFloat {
        let reservedHeight = headerHeight
            + dashboardHeight
            + sectionSpacing
            + tabClearance
        let availableMapHeight = size.height - reservedHeight
        return min(max(availableMapHeight, 260), 390)
    }

    static func metrics(for size: CGSize) -> Metrics {
        let horizontalPadding: CGFloat = size.width < 390 ? 10 : 12
        let cardGap: CGFloat = size.width < 390 ? 8 : 10
        let verticalGap: CGFloat = sectionSpacing
        let availableWidth = max(0, size.width - horizontalPadding * 2 - cardGap)
        let provinceWidth = floor(availableWidth * 0.50)
        let quickExploreWidth = max(0, availableWidth - provinceWidth)
        let topPadding: CGFloat = dashboardTopPadding
        let bottomPadding: CGFloat = dashboardBottomPadding

        return Metrics(
            horizontalPadding: horizontalPadding,
            cardGap: cardGap,
            verticalGap: verticalGap,
            cardHeight: cardHeight,
            carouselHeight: carouselHeight,
            topPadding: topPadding,
            bottomPadding: bottomPadding,
            provinceWidth: provinceWidth,
            quickExploreWidth: quickExploreWidth
        )
    }
}

private extension View {
    func mapGlassCardStyle() -> some View {
        self
            .background(.ultraThinMaterial)
            .background(Color(hex: "#081624").opacity(0.70))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 0.8)
            )
            .shadow(color: Color.black.opacity(0.26), radius: 16, x: 0, y: 10)
    }
}

private struct MapProvinceSummaryCard: View {
    let province: ProvinceItem
    let lang: AppLanguage

    var body: some View {
        VStack(spacing: 7) {
            HStack(alignment: .top, spacing: 6) {
                provinceArtTile

                VStack(alignment: .leading, spacing: 2) {
                    Text(province.localizedName(lang))
                        .font(.system(size: 13.5, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                        .allowsTightening(true)

                    Text("Capital: \(province.capital)")
                        .lineLimit(1)
                    Text("Population: \(province.population)")
                        .lineLimit(1)
                    Text("Area: \(formattedArea)")
                        .lineLimit(1)
                    Text("Largest city: \(largestCity)")
                        .lineLimit(1)
                    HStack(spacing: 5) {
                        Image(systemName: "cloud.sun.fill")
                            .foregroundStyle(Color(hex: "#C7D2FE"))
                        Text("12°C · Partly cloudy")
                            .lineLimit(1)
                    }
                }
                .font(.system(size: 8.5, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.72))
                .minimumScaleFactor(0.72)
                .layoutPriority(1)

                Spacer(minLength: 0)
            }

            HStack(spacing: 5) {
                ForEach(summaryActions, id: \.accessibilityIdentifier) { action in
                    NavigationLink(value: action.destination) {
                        Image(systemName: action.0)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(action.1)
                            .frame(width: 28, height: 28)
                            .background(action.1.opacity(0.12))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(action.1.opacity(0.25), lineWidth: 0.8))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(action.accessibilityLabel)
                    .accessibilityIdentifier(action.accessibilityIdentifier)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .mapGlassCardStyle()
    }

    private var provinceArtTile: some View {
        PremiumImageView(
            asset: summaryImageAsset,
            language: lang,
            height: 64,
            aspectRatio: 1.0,
            mode: .fill,
            cornerRadius: 16,
            overlayStyle: .none,
            fallbackCategory: .city,
            accessibilityLabel: province.localizedName(lang),
            targetPixelWidth: 360,
            role: .thumbnail,
            overlayPolicy: .none,
            focalPoint: .center
        )
        .overlay(alignment: .bottomLeading) {
            LinearGradient(
                colors: [Color.black.opacity(0.02), Color.black.opacity(0.58)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .frame(width: 64, height: 64)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 0.8)
        )
    }

    private var formattedArea: String {
        province.id == "Noord-Holland" ? "4.100 km²" : province.areaKm2
    }

    private var largestCity: String {
        province.cities.first?.name ?? "Amsterdam"
    }

    private var summaryImageAsset: AppImageAsset? {
        VerifiedPlaceMediaRegistry
            .media(for: .city, name: "Amsterdam", provinceId: "Noord-Holland")
            .heroImage?
            .appImageAsset(
                id: "map-summary-amsterdam",
                title: "Amsterdam canals",
                description: "North Holland visual reference for the map summary.",
                type: .cityHero
            )
    }

    private var summaryActions: [(String, Color, destination: AppDestination, accessibilityLabel: String, accessibilityIdentifier: String)] {
        [
            ("paperplane.fill", AppColors.cyanGlow, .provinceDetail(province.id), "Open province", "map.summary.action.province"),
            ("building.2.fill", Color(hex: "#D9F99D"), .provinceCities(province.id), "Open municipalities", "map.summary.action.cities"),
            ("tram.fill", Color(hex: "#60A5FA"), .mapFocus(.category(.transport)), "Open transport nearby", "map.summary.action.transport"),
            ("house.fill", Color(hex: "#38BDF8"), .practicalGuide(.housingBasics), "Open housing guide", "map.summary.action.housing"),
            ("heart", Color.white.opacity(0.82), .savedTopics, "Open saved", "map.summary.action.saved")
        ]
    }
}

private struct MapQuickExplorePanel: View {
    let lang: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.78))

            LazyVGrid(columns: columns, spacing: 3) {
                ForEach(visibleItems, id: \.title) { item in
                    NavigationLink(value: item.destination) {
                        VStack(spacing: 2) {
                            Image(systemName: item.symbol)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(item.tint)
                            Text(item.title)
                                .font(.system(size: 7.8, weight: .medium, design: .rounded))
                                .foregroundStyle(Color.white.opacity(0.74))
                                .lineLimit(1)
                                .minimumScaleFactor(0.80)
                        }
                        .frame(maxWidth: .infinity, minHeight: 31, maxHeight: 31)
                        .background(
                            LinearGradient(
                                colors: [item.tint.opacity(0.16), Color(hex: "#101827").opacity(0.72)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(item.tint.opacity(0.15), lineWidth: 0.7))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(item.title)
                    .accessibilityIdentifier("map.quick.\(item.title.snakeCasedProvinceID)")
                }
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .mapGlassCardStyle()
    }

    private var title: String {
        switch lang {
        case .english: return "One-tap tasks"
        case .dutch: return "Taken in een tik"
        case .russian: return "Задачи в один тап"
        }
    }

    private var columns: [GridItem] {
        [GridItem(.flexible(), spacing: 3), GridItem(.flexible(), spacing: 3)]
    }

    private var items: [(title: String, symbol: String, tint: Color, destination: AppDestination)] {
        [
            (localized(en: "Municipalities", nl: "Gemeenten", ru: "Муниципалитеты"), "building.2.fill", Color(hex: "#D9F99D"), .mapFocus(.category(.municipality))),
            (localized(en: "Transport", nl: "Vervoer", ru: "Транспорт"), "tram.fill", Color(hex: "#818CF8"), .mapFocus(.category(.transport))),
            (localized(en: "Housing", nl: "Wonen", ru: "Жильё"), "house.fill", Color(hex: "#F9A8D4"), .practicalGuide(.housingBasics)),
            (localized(en: "Healthcare", nl: "Zorg", ru: "Медицина"), "heart.text.square.fill", Color(hex: "#60A5FA"), .mapFocus(.healthcare)),
            (localized(en: "Jobs", nl: "Werk", ru: "Работа"), "briefcase.fill", Color(hex: "#FB923C"), .resourcesHub),
            (localized(en: "Education", nl: "Onderwijs", ru: "Учёба"), "graduationcap.fill", Color(hex: "#A78BFA"), .mapFocus(.education)),
            (localized(en: "Emergency", nl: "Noodhulp", ru: "Экстренно"), "bell.fill", Color(hex: "#F43F5E"), .mapFocus(.emergency)),
            (localized(en: "Tourism", nl: "Toerisme", ru: "Туризм"), "camera.fill", Color(hex: "#3B82F6"), .cultureAttractions)
        ]
    }

    private var visibleItems: [(title: String, symbol: String, tint: Color, destination: AppDestination)] {
        items
    }

    private func localized(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }
}

private struct MapOverseasTerritoriesCarousel: View {
    let lang: AppLanguage
    let onSelect: (OverseasTerritory) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.78))

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 8) {
                    ForEach(OverseasTerritory.all) { territory in
                        Button {
                            onSelect(territory)
                        } label: {
                            territoryTile(territory)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(territory.name), \(territoryCapital(territory))")
                        .accessibilityIdentifier("map.overseas.\(territory.name.snakeCasedProvinceID)")
                    }
                }
                .padding(.horizontal, 2)
            }
            .frame(height: 88)
        }
        .padding(10)
        .mapGlassCardStyle()
    }

    private var title: String {
        switch lang {
        case .english: return "Overseas Territories"
        case .dutch: return "Overzeese Gebieden"
        case .russian: return "Заморские территории"
        }
    }

    private func territoryTile(_ territory: OverseasTerritory) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                if let urlString = territoryPhotoURL(territory), let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        default:
                            territoryImageFallback(territory)
                        }
                    }
                } else {
                    territoryImageFallback(territory)
                }

                LinearGradient(
                    colors: [.clear, Color.black.opacity(0.62)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                Text(territory.flag)
                    .font(.system(size: 16))
                    .padding(6)
            }
            .frame(width: 104, height: 54)
            .clipped()

            VStack(alignment: .leading, spacing: 2) {
                Text(territory.name)
                    .font(.system(size: 10.2, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.64)
                Text(territoryCapital(territory))
                    .font(.system(size: 8.8, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.58))
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
        }
        .frame(width: 104, height: 84, alignment: .topLeading)
        .background(territory.color.opacity(0.13))
        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 13, style: .continuous).stroke(territory.color.opacity(0.24), lineWidth: 0.8))
    }

    private func territoryImageFallback(_ territory: OverseasTerritory) -> some View {
        LinearGradient(
            colors: [
                territory.color.opacity(0.62),
                Color(hex: "#082235"),
                Color(hex: "#04101A")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            Image(systemName: "sun.horizon.fill")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.24))
        }
    }

    private func territoryCapital(_ territory: OverseasTerritory) -> String {
        switch territory.name {
        case "Aruba": return "Oranjestad"
        case "Curaçao": return "Willemstad"
        case "Sint Maarten": return "Philipsburg"
        case "Bonaire": return "Kralendijk"
        case "Sint Eustatius": return "Oranjestad"
        case "Saba": return "The Bottom"
        default: return territory.region
        }
    }

    private func territoryPhotoURL(_ territory: OverseasTerritory) -> String? {
        switch territory.name {
        case "Aruba":
            return "https://commons.wikimedia.org/wiki/Special:FilePath/Eagle%20Beach%2C%20Aruba.jpg?width=800"
        case "Curaçao":
            return "https://commons.wikimedia.org/wiki/Special:FilePath/Willemstad%2C%20Curacao.jpg?width=800"
        case "Sint Maarten":
            return "https://commons.wikimedia.org/wiki/Special:FilePath/Sint%20Maarten%20-%20Great%20Bay.jpg?width=800"
        case "Bonaire":
            return "https://commons.wikimedia.org/wiki/Special:FilePath/Bonaire%20salt%20pier.jpg?width=800"
        case "Sint Eustatius":
            return "https://commons.wikimedia.org/wiki/Special:FilePath/The%20Quill%2C%20Sint%20Eustatius.jpg?width=800"
        case "Saba":
            return "https://commons.wikimedia.org/wiki/Special:FilePath/Saba%20island.jpg?width=800"
        default:
            return nil
        }
    }
}

private struct OverseasTerritoriesInset: View {
    let onSelect: (OverseasTerritory) -> Void
    @EnvironmentObject private var languageManager: LanguageManager
    private var lang: AppLanguage { languageManager.appLanguage }

    private var overseasTitle: String {
        switch lang {
        case .english: return "Overseas Territories"
        case .dutch: return "Overzeese Gebieden"
        case .russian: return "Заморские территории"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(overseasTitle)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.35))
                .textCase(.uppercase)
                .tracking(1.0)

            HStack(spacing: 6) {
                ForEach(OverseasTerritory.all) { territory in
                    Button {
                        onSelect(territory)
                    } label: {
                        VStack(spacing: 2) {
                            Text(territory.flag)
                                .font(.system(size: 15))
                            Text(territory.name)
                                .font(.system(size: 7.5, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.white.opacity(0.75))
                                .lineLimit(1)
                                .minimumScaleFactor(0.58)
                        }
                        .frame(width: 42, height: 44)
                        .background(territory.color.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).strokeBorder(territory.color.opacity(0.25), lineWidth: 0.5))
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .pressable()
                }
            }
        }
        .padding(10)
        .background(.ultraThinMaterial)
        .background(Color(hex: "#0A1828").opacity(0.76))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 0.5)
        )
        .frame(maxWidth: 330, alignment: .leading)
    }
}

private struct TerritorySheet: View {
    let territory: OverseasTerritory
    @EnvironmentObject private var languageManager: LanguageManager
    private var lang: AppLanguage { languageManager.appLanguage }

    private var populationLabel: String {
        switch lang {
        case .english: return "Population"
        case .dutch: return "Inwoners"
        case .russian: return "Население"
        }
    }
    private var areaLabel: String {
        switch lang {
        case .english: return "Area km²"
        case .dutch: return "Oppervlakte km²"
        case .russian: return "Площадь км²"
        }
    }
    private var statusLabel: String {
        switch lang {
        case .english: return "Status"
        case .dutch: return "Status"
        case .russian: return "Статус"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(territory.flag)
                    .font(.system(size: 40))
                VStack(alignment: .leading) {
                    Text(territory.name)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(territory.region)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppColors.cyanGlow)
                }
                Spacer()
            }

            Text(territory.description)
                .font(.system(size: 14))
                .foregroundStyle(Color.white.opacity(0.7))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 0) {
                MapStatCell(value: territory.population, label: populationLabel)
                Divider().frame(height: 30).opacity(0.2)
                MapStatCell(value: territory.area, label: areaLabel)
                Divider().frame(height: 30).opacity(0.2)
                MapStatCell(value: territory.status, label: statusLabel)
            }
        }
        .padding(20)
        .presentationDetents([.fraction(0.35)])
        .presentationBackground(Color(red: 17 / 255, green: 24 / 255, blue: 39 / 255))
        .presentationCornerRadius(24)
        .presentationDragIndicator(.visible)
    }
}

private struct TerritoriesGallerySheet: View {
    let onSelect: (OverseasTerritory) -> Void
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var languageManager: LanguageManager
    private var lang: AppLanguage { languageManager.appLanguage }

    private var title: String {
        switch lang {
        case .english: return "Kingdom islands"
        case .dutch: return "Koninkrijk eilanden"
        case .russian: return "Острова королевства"
        }
    }

    private var subtitle: String {
        switch lang {
        case .english: return "Explore the Caribbean territories without covering the map."
        case .dutch: return "Ontdek de Caribische gebieden zonder de kaart te bedekken."
        case .russian: return "Карибские территории отдельно, без перекрытия карты."
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppAtmosphereBackground()
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(title)
                                .font(.custom("Syne-ExtraBold", size: 30))
                                .foregroundStyle(.white)
                                .lineLimit(2)
                                .minimumScaleFactor(0.78)

                            Text(subtitle)
                                .font(AppTypography.body)
                                .foregroundStyle(AppColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.top, 20)

                        LazyVGrid(columns: gridColumns, spacing: 12) {
                            ForEach(OverseasTerritory.all) { territory in
                                Button {
                                    onSelect(territory)
                                } label: {
                                    territoryCard(territory)
                                }
                                .buttonStyle(.plain)
                                .pressable()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
            .toolbar {
                ToolbarItem(placement: closeToolbarPlacement) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 34, height: 34)
                            .background(Color.white.opacity(0.10))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private var gridColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
    }

    private func territoryCard(_ territory: OverseasTerritory) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(territory.flag)
                    .font(.system(size: 28))
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(territory.color.opacity(0.86))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(territory.name)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Text("\(territory.population) · \(territory.status)")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            Text(territory.region)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(territory.color.opacity(0.92))
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(territory.color.opacity(0.13))
                .clipShape(Capsule())
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 136, alignment: .topLeading)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "#122238").opacity(0.96),
                            territory.color.opacity(0.16)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(territory.color.opacity(0.24), lineWidth: 0.8)
        )
    }
}

private struct MapStatCell: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.48))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }
}

struct RealProvinceMapData {
    struct Province {
        let id: String
        let rings: [[CGPoint]]

        func path(in size: CGSize) -> Path {
            Self.path(rings: rings, in: size)
        }

        static func path(rings: [[CGPoint]], in size: CGSize) -> Path {
            var combined = Path()
            for ring in rings where ring.count >= 3 {
                combined.addPath(Path.preciseClosed(ring.map { CGPoint(x: $0.x * size.width, y: $0.y * size.height) }))
            }
            return combined
        }
    }

    static let provinces: [Province] = [
        Province(id: "Groningen", rings: [
            [p(0.7955,0.0000), p(0.8100,0.0045), p(0.8067,0.0073), p(0.7973,0.0052), p(0.7926,0.0029), p(0.7920,0.0006),
             p(0.7955,0.0000)],
            [p(0.9724,0.2469), p(0.9656,0.2402), p(0.9574,0.2373), p(0.9621,0.2252), p(0.9599,0.2220), p(0.9461,0.2094),
             p(0.9330,0.1965), p(0.9127,0.1808), p(0.9010,0.1725), p(0.8793,0.1549), p(0.8752,0.1532), p(0.8682,0.1529),
             p(0.8510,0.1584), p(0.8468,0.1518), p(0.8373,0.1425), p(0.8322,0.1398), p(0.8229,0.1291), p(0.8201,0.1296),
             p(0.8064,0.1251), p(0.7974,0.1325), p(0.7928,0.1351), p(0.7858,0.1423), p(0.7805,0.1544), p(0.7787,0.1603),
             p(0.7747,0.1667), p(0.7673,0.1666), p(0.7554,0.1608), p(0.7507,0.1597), p(0.7373,0.1587), p(0.7311,0.1538),
             p(0.7295,0.1463), p(0.7309,0.1386), p(0.7334,0.1342), p(0.7424,0.1232), p(0.7406,0.1148), p(0.7470,0.1039),
             p(0.7489,0.0976), p(0.7572,0.0896), p(0.7542,0.0884), p(0.7546,0.0805), p(0.7530,0.0774), p(0.7481,0.0762),
             p(0.7434,0.0779), p(0.7371,0.0735), p(0.7283,0.0713), p(0.7254,0.0637), p(0.7290,0.0548), p(0.7516,0.0533),
             p(0.7592,0.0571), p(0.7639,0.0571), p(0.7702,0.0526), p(0.8082,0.0418), p(0.8687,0.0316), p(0.8945,0.0340),
             p(0.9000,0.0359), p(0.9046,0.0394), p(0.9153,0.0682), p(0.9232,0.0720), p(0.9284,0.0768), p(0.9368,0.0786),
             p(0.9474,0.0830), p(0.9519,0.0815), p(0.9574,0.0840), p(0.9643,0.0809), p(0.9616,0.0860), p(0.9641,0.0961),
             p(0.9723,0.0995), p(0.9913,0.1026), p(0.9943,0.1025), p(0.9964,0.1182), p(0.9946,0.1299), p(0.9915,0.1379),
             p(0.9915,0.1450), p(0.9953,0.1520), p(0.9995,0.1773), p(1.0000,0.1900), p(0.9984,0.2014), p(0.9936,0.2135),
             p(0.9741,0.2421), p(0.9724,0.2469)]
        ]),
        Province(id: "Friesland", rings: [
            [p(0.4074,0.1298), p(0.4009,0.1348), p(0.3928,0.1319), p(0.4034,0.1200), p(0.4198,0.1068), p(0.4372,0.0980),
             p(0.4504,0.0992), p(0.4504,0.1016), p(0.4435,0.1018), p(0.4328,0.1059), p(0.4129,0.1228), p(0.4074,0.1298)],
            [p(0.5326,0.0627), p(0.5212,0.0672), p(0.5121,0.0693), p(0.4767,0.0832), p(0.4692,0.0832), p(0.4658,0.0780),
             p(0.4685,0.0718), p(0.4823,0.0675), p(0.4867,0.0639), p(0.4927,0.0639), p(0.5272,0.0571), p(0.5347,0.0520),
             p(0.5728,0.0448), p(0.5671,0.0518), p(0.5599,0.0541), p(0.5448,0.0550), p(0.5466,0.0601), p(0.5433,0.0617),
             p(0.5326,0.0627)],
            [p(0.6574,0.0349), p(0.6682,0.0391), p(0.6428,0.0448), p(0.6162,0.0456), p(0.6096,0.0473), p(0.5974,0.0524),
             p(0.5908,0.0513), p(0.5860,0.0462), p(0.5873,0.0409), p(0.5915,0.0378), p(0.5955,0.0391), p(0.6574,0.0349)],
            [p(0.7194,0.0346), p(0.7145,0.0402), p(0.7142,0.0351), p(0.7113,0.0303), p(0.7175,0.0254), p(0.7269,0.0215),
             p(0.7337,0.0198), p(0.7592,0.0171), p(0.7665,0.0186), p(0.7666,0.0210), p(0.7631,0.0212), p(0.7194,0.0346)],
            [p(0.7673,0.1666), p(0.7671,0.1714), p(0.7797,0.1761), p(0.7838,0.1885), p(0.7988,0.2034), p(0.8023,0.2088),
             p(0.8014,0.2123), p(0.7932,0.2238), p(0.7811,0.2312), p(0.7720,0.2267), p(0.7661,0.2256), p(0.7591,0.2259),
             p(0.7547,0.2294), p(0.7463,0.2380), p(0.7249,0.2527), p(0.7141,0.2567), p(0.7048,0.2585), p(0.7000,0.2651),
             p(0.6896,0.2648), p(0.6826,0.2591), p(0.6736,0.2610), p(0.6678,0.2678), p(0.6601,0.2718), p(0.6493,0.2715),
             p(0.6450,0.2691), p(0.6354,0.2734), p(0.6326,0.2680), p(0.6231,0.2614), p(0.6168,0.2623), p(0.6151,0.2604),
             p(0.5958,0.2564), p(0.5876,0.2582), p(0.5794,0.2628), p(0.5710,0.2627), p(0.5614,0.2589), p(0.5448,0.2589),
             p(0.5364,0.2574), p(0.5251,0.2502), p(0.5241,0.2443), p(0.5295,0.2385), p(0.5360,0.2336), p(0.5322,0.2280),
             p(0.5364,0.2239), p(0.5372,0.2182), p(0.5360,0.2125), p(0.5333,0.2086), p(0.5347,0.1997), p(0.5335,0.1954),
             p(0.5309,0.1941), p(0.5263,0.1874), p(0.5231,0.1798), p(0.5015,0.1919), p(0.4761,0.2114), p(0.4744,0.2067),
             p(0.4737,0.2052), p(0.4991,0.1855), p(0.5074,0.1782), p(0.5194,0.1755), p(0.5246,0.1726), p(0.5297,0.1636),
             p(0.5357,0.1393), p(0.5406,0.1283), p(0.5494,0.1193), p(0.5548,0.1150), p(0.5643,0.1113), p(0.5768,0.0982),
             p(0.5820,0.0965), p(0.5944,0.0944), p(0.6030,0.0878), p(0.6440,0.0726), p(0.6530,0.0669), p(0.6590,0.0663),
             p(0.6760,0.0583), p(0.7009,0.0565), p(0.7290,0.0548), p(0.7254,0.0637), p(0.7283,0.0713), p(0.7371,0.0735),
             p(0.7434,0.0779), p(0.7481,0.0762), p(0.7530,0.0774), p(0.7546,0.0805), p(0.7542,0.0884), p(0.7572,0.0896),
             p(0.7489,0.0976), p(0.7470,0.1039), p(0.7406,0.1148), p(0.7424,0.1232), p(0.7334,0.1342), p(0.7309,0.1386),
             p(0.7295,0.1463), p(0.7311,0.1538), p(0.7373,0.1587), p(0.7507,0.1597), p(0.7554,0.1608), p(0.7673,0.1666)]
        ]),
        Province(id: "Drenthe", rings: [
            [p(0.9724,0.2469), p(0.9701,0.2532), p(0.9687,0.2651), p(0.9689,0.3034), p(0.9678,0.3160), p(0.9635,0.3238),
             p(0.9498,0.3207), p(0.9370,0.3228), p(0.9228,0.3199), p(0.8979,0.3214), p(0.8892,0.3240), p(0.8846,0.3270),
             p(0.8815,0.3257), p(0.8806,0.3201), p(0.8780,0.3183), p(0.8586,0.3119), p(0.8475,0.3134), p(0.8351,0.3194),
             p(0.8315,0.3241), p(0.8328,0.3346), p(0.8216,0.3307), p(0.8149,0.3328), p(0.8081,0.3297), p(0.7989,0.3334),
             p(0.7961,0.3331), p(0.7911,0.3255), p(0.7821,0.3193), p(0.7799,0.3166), p(0.7662,0.3171), p(0.7513,0.3112),
             p(0.7460,0.3139), p(0.7424,0.3137), p(0.7372,0.3091), p(0.7271,0.2899), p(0.7294,0.2862), p(0.7362,0.2833),
             p(0.7453,0.2751), p(0.7463,0.2721), p(0.7249,0.2527), p(0.7463,0.2380), p(0.7547,0.2294), p(0.7591,0.2259),
             p(0.7661,0.2256), p(0.7720,0.2267), p(0.7811,0.2312), p(0.7932,0.2238), p(0.8014,0.2123), p(0.8023,0.2088),
             p(0.7988,0.2034), p(0.7838,0.1885), p(0.7797,0.1761), p(0.7671,0.1714), p(0.7673,0.1666), p(0.7747,0.1667),
             p(0.7787,0.1603), p(0.7805,0.1544), p(0.7858,0.1423), p(0.7928,0.1351), p(0.7974,0.1325), p(0.8064,0.1251),
             p(0.8201,0.1296), p(0.8229,0.1291), p(0.8322,0.1398), p(0.8373,0.1425), p(0.8468,0.1518), p(0.8510,0.1584),
             p(0.8682,0.1529), p(0.8752,0.1532), p(0.8793,0.1549), p(0.9010,0.1725), p(0.9127,0.1808), p(0.9330,0.1965),
             p(0.9461,0.2094), p(0.9599,0.2220), p(0.9621,0.2252), p(0.9574,0.2373), p(0.9656,0.2402), p(0.9724,0.2469)]
        ]),
        Province(id: "Noord-Holland", rings: [
            [p(0.3975,0.1708), p(0.3976,0.1730), p(0.4029,0.1728), p(0.3981,0.1832), p(0.3911,0.1925), p(0.3790,0.2010),
             p(0.3735,0.2105), p(0.3647,0.2128), p(0.3555,0.2099), p(0.3502,0.2010), p(0.3515,0.1917), p(0.3564,0.1811),
             p(0.3626,0.1725), p(0.3746,0.1634), p(0.3805,0.1527), p(0.3867,0.1438), p(0.3949,0.1440), p(0.3967,0.1478),
             p(0.3952,0.1513), p(0.3990,0.1561), p(0.4018,0.1623), p(0.4020,0.1679), p(0.3975,0.1708)],
            [p(0.3745,0.4867), p(0.3662,0.4915), p(0.3634,0.4904), p(0.3611,0.4835), p(0.3591,0.4823), p(0.3426,0.4877),
             p(0.3313,0.4904), p(0.3248,0.4906), p(0.3156,0.4855), p(0.3188,0.4808), p(0.3207,0.4703), p(0.3316,0.4548),
             p(0.3255,0.4538), p(0.3201,0.4562), p(0.3153,0.4554), p(0.3020,0.4508), p(0.3043,0.4471), p(0.3194,0.4083),
             p(0.3213,0.3956), p(0.3263,0.3865), p(0.3356,0.3174), p(0.3398,0.2998), p(0.3425,0.2833), p(0.3530,0.2596),
             p(0.3551,0.2479), p(0.3560,0.2328), p(0.3577,0.2256), p(0.3607,0.2224), p(0.3769,0.2241), p(0.3794,0.2220),
             p(0.3814,0.2246), p(0.3778,0.2355), p(0.3842,0.2419), p(0.3950,0.2443), p(0.4053,0.2434), p(0.4112,0.2406),
             p(0.4220,0.2324), p(0.4274,0.2306), p(0.4378,0.2292), p(0.4479,0.2253), p(0.4737,0.2052), p(0.4744,0.2067),
             p(0.4761,0.2114), p(0.4612,0.2229), p(0.4501,0.2289), p(0.4392,0.2327), p(0.4449,0.2364), p(0.4587,0.2580),
             p(0.4604,0.2656), p(0.4619,0.2882), p(0.4656,0.2928), p(0.4747,0.2984), p(0.4840,0.2927), p(0.4918,0.2922),
             p(0.5054,0.2968), p(0.5073,0.2986), p(0.5105,0.3114), p(0.5018,0.3151), p(0.4981,0.3182), p(0.4949,0.3268),
             p(0.4910,0.3309), p(0.4751,0.3395), p(0.4674,0.3415), p(0.4608,0.3366), p(0.4536,0.3346), p(0.4443,0.3361),
             p(0.4406,0.3422), p(0.4414,0.3511), p(0.4453,0.3614), p(0.4546,0.3771), p(0.4569,0.3857), p(0.4517,0.3905),
             p(0.4539,0.3955), p(0.4466,0.3979), p(0.4497,0.3999), p(0.4536,0.4058), p(0.4579,0.4076), p(0.4538,0.4144),
             p(0.4451,0.4204), p(0.4410,0.4296), p(0.4368,0.4271), p(0.4369,0.4297), p(0.4295,0.4273), p(0.4297,0.4299),
             p(0.4260,0.4325), p(0.4428,0.4403), p(0.4472,0.4414), p(0.4592,0.4420), p(0.4647,0.4434), p(0.4784,0.4505),
             p(0.4896,0.4529), p(0.5010,0.4514), p(0.5064,0.4517), p(0.5256,0.4623), p(0.5089,0.4630), p(0.5057,0.4643),
             p(0.5011,0.4711), p(0.4962,0.4822), p(0.4954,0.4864), p(0.4904,0.4961), p(0.4853,0.4992), p(0.4705,0.4988),
             p(0.4605,0.5006), p(0.4489,0.5039), p(0.4455,0.4911), p(0.4472,0.4838), p(0.4515,0.4793), p(0.4460,0.4736),
             p(0.4437,0.4689), p(0.4450,0.4672), p(0.4530,0.4645), p(0.4423,0.4638), p(0.4380,0.4655), p(0.4319,0.4627),
             p(0.4254,0.4658), p(0.4178,0.4666), p(0.4123,0.4737), p(0.4017,0.4752), p(0.3959,0.4776), p(0.3921,0.4811),
             p(0.3868,0.4835), p(0.3745,0.4867)]
        ]),
        Province(id: "Flevoland", rings: [
            [p(0.6536,0.3556), p(0.6595,0.3711), p(0.6598,0.3781), p(0.6567,0.3873), p(0.6529,0.3943), p(0.6474,0.4016),
             p(0.6407,0.4073), p(0.6334,0.4097), p(0.6257,0.4111), p(0.6132,0.4165), p(0.6033,0.4196), p(0.5980,0.4265),
             p(0.5861,0.4297), p(0.5788,0.4332), p(0.5815,0.4440), p(0.5803,0.4529), p(0.5750,0.4595), p(0.5656,0.4628),
             p(0.5481,0.4639), p(0.5409,0.4617), p(0.5246,0.4517), p(0.5159,0.4481), p(0.4975,0.4429), p(0.4930,0.4425),
             p(0.4811,0.4434), p(0.4754,0.4410), p(0.4724,0.4318), p(0.4696,0.4264), p(0.4740,0.4242), p(0.4814,0.4179),
             p(0.4976,0.4102), p(0.5086,0.4007), p(0.5281,0.3937), p(0.5396,0.3843), p(0.5495,0.3807), p(0.5529,0.3782),
             p(0.5586,0.3646), p(0.5607,0.3632), p(0.5685,0.3630), p(0.5798,0.3532), p(0.5843,0.3504), p(0.5994,0.3458),
             p(0.6039,0.3425), p(0.6114,0.3487), p(0.6536,0.3556)],
            [p(0.6354,0.2734), p(0.6551,0.2814), p(0.6676,0.2892), p(0.6728,0.2949), p(0.6771,0.3037), p(0.6795,0.3127),
             p(0.6749,0.3190), p(0.6887,0.3225), p(0.6939,0.3246), p(0.7000,0.3302), p(0.6919,0.3343), p(0.6793,0.3384),
             p(0.6675,0.3377), p(0.6537,0.3439), p(0.6449,0.3408), p(0.6101,0.3434), p(0.6057,0.3425), p(0.5967,0.3304),
             p(0.5933,0.3283), p(0.5884,0.3224), p(0.5874,0.3086), p(0.5885,0.2938), p(0.5904,0.2849), p(0.5953,0.2760),
             p(0.6014,0.2688), p(0.6089,0.2640), p(0.6168,0.2623), p(0.6231,0.2614), p(0.6326,0.2680), p(0.6354,0.2734)]
        ]),
        Province(id: "Overijssel", rings: [
            [p(0.8846,0.3270), p(0.8802,0.3299), p(0.8826,0.3335), p(0.8813,0.3397), p(0.8835,0.3448), p(0.8926,0.3504),
             p(0.8784,0.3572), p(0.8740,0.3576), p(0.8776,0.3631), p(0.8797,0.3756), p(0.8816,0.3808), p(0.8871,0.3856),
             p(0.8943,0.3881), p(0.9154,0.3896), p(0.9293,0.3933), p(0.9369,0.3940), p(0.9503,0.3914), p(0.9558,0.3862),
             p(0.9734,0.4069), p(0.9777,0.4158), p(0.9763,0.4289), p(0.9717,0.4392), p(0.9701,0.4446), p(0.9705,0.4511),
             p(0.9751,0.4637), p(0.9637,0.4701), p(0.9554,0.4816), p(0.9503,0.4857), p(0.9391,0.4903), p(0.9343,0.4950),
             p(0.9290,0.5050), p(0.9258,0.5077), p(0.9101,0.5098), p(0.9068,0.5080), p(0.8805,0.5045), p(0.8828,0.4990),
             p(0.8809,0.4913), p(0.8752,0.4896), p(0.8636,0.4915), p(0.8621,0.4872), p(0.8516,0.4884), p(0.8414,0.4878),
             p(0.8349,0.4886), p(0.8268,0.4828), p(0.8113,0.4657), p(0.8034,0.4651), p(0.7879,0.4718), p(0.7711,0.4728),
             p(0.7498,0.4704), p(0.7433,0.4749), p(0.7398,0.4717), p(0.7401,0.4668), p(0.7347,0.4643), p(0.7345,0.4591),
             p(0.7292,0.4491), p(0.7237,0.4472), p(0.7186,0.4416), p(0.7207,0.4312), p(0.7230,0.4282), p(0.7213,0.4242),
             p(0.7313,0.4204), p(0.7347,0.4117), p(0.7339,0.4058), p(0.7281,0.3994), p(0.7231,0.3896), p(0.7144,0.3823),
             p(0.7104,0.3768), p(0.7052,0.3750), p(0.6977,0.3786), p(0.6896,0.3847), p(0.6816,0.3869), p(0.6778,0.3855),
             p(0.6683,0.3728), p(0.6638,0.3727), p(0.6623,0.3661), p(0.6564,0.3474), p(0.6537,0.3439), p(0.6675,0.3377),
             p(0.6793,0.3384), p(0.6919,0.3343), p(0.7000,0.3302), p(0.6939,0.3246), p(0.6887,0.3225), p(0.6749,0.3190),
             p(0.6795,0.3127), p(0.6771,0.3037), p(0.6728,0.2949), p(0.6676,0.2892), p(0.6551,0.2814), p(0.6354,0.2734),
             p(0.6450,0.2691), p(0.6493,0.2715), p(0.6601,0.2718), p(0.6678,0.2678), p(0.6736,0.2610), p(0.6826,0.2591),
             p(0.6896,0.2648), p(0.7000,0.2651), p(0.7048,0.2585), p(0.7141,0.2567), p(0.7249,0.2527), p(0.7463,0.2721),
             p(0.7453,0.2751), p(0.7362,0.2833), p(0.7294,0.2862), p(0.7271,0.2899), p(0.7372,0.3091), p(0.7424,0.3137),
             p(0.7460,0.3139), p(0.7513,0.3112), p(0.7662,0.3171), p(0.7799,0.3166), p(0.7821,0.3193), p(0.7911,0.3255),
             p(0.7961,0.3331), p(0.7989,0.3334), p(0.8081,0.3297), p(0.8149,0.3328), p(0.8216,0.3307), p(0.8328,0.3346),
             p(0.8315,0.3241), p(0.8351,0.3194), p(0.8475,0.3134), p(0.8586,0.3119), p(0.8780,0.3183), p(0.8806,0.3201),
             p(0.8815,0.3257), p(0.8846,0.3270)]
        ]),
        Province(id: "Utrecht", rings: [
            [p(0.5256,0.4623), p(0.5317,0.4658), p(0.5437,0.4699), p(0.5419,0.4833), p(0.5435,0.4853), p(0.5533,0.4914),
             p(0.5530,0.4949), p(0.5497,0.4988), p(0.5515,0.5012), p(0.5635,0.5035), p(0.5740,0.5120), p(0.5732,0.5201),
             p(0.5702,0.5200), p(0.5670,0.5275), p(0.5630,0.5315), p(0.5716,0.5356), p(0.5787,0.5326), p(0.5817,0.5292),
             p(0.5809,0.5238), p(0.5852,0.5228), p(0.5888,0.5339), p(0.5888,0.5424), p(0.5917,0.5530), p(0.5953,0.5579),
             p(0.6009,0.5626), p(0.6051,0.5706), p(0.6044,0.5777), p(0.5953,0.5763), p(0.5742,0.5667), p(0.5626,0.5650),
             p(0.5516,0.5702), p(0.5416,0.5683), p(0.5356,0.5695), p(0.5280,0.5747), p(0.5224,0.5760), p(0.5072,0.5695),
             p(0.4985,0.5735), p(0.4882,0.5743), p(0.4804,0.5720), p(0.4740,0.5643), p(0.4669,0.5617), p(0.4621,0.5644),
             p(0.4560,0.5659), p(0.4501,0.5716), p(0.4474,0.5727), p(0.4362,0.5708), p(0.4272,0.5756), p(0.4198,0.5822),
             p(0.4112,0.5829), p(0.4095,0.5852), p(0.3920,0.5659), p(0.3998,0.5617), p(0.3984,0.5575), p(0.3862,0.5590),
             p(0.3850,0.5568), p(0.3931,0.5461), p(0.4036,0.5416), p(0.4054,0.5391), p(0.3933,0.5393), p(0.3895,0.5262),
             p(0.3817,0.5225), p(0.3894,0.5153), p(0.3921,0.5147), p(0.3998,0.5174), p(0.4015,0.5165), p(0.3980,0.5067),
             p(0.4003,0.5050), p(0.3870,0.4962), p(0.3812,0.4944), p(0.3745,0.4867), p(0.3868,0.4835), p(0.3921,0.4811),
             p(0.3959,0.4776), p(0.4017,0.4752), p(0.4123,0.4737), p(0.4178,0.4666), p(0.4254,0.4658), p(0.4319,0.4627),
             p(0.4380,0.4655), p(0.4423,0.4638), p(0.4530,0.4645), p(0.4450,0.4672), p(0.4437,0.4689), p(0.4460,0.4736),
             p(0.4515,0.4793), p(0.4472,0.4838), p(0.4455,0.4911), p(0.4489,0.5039), p(0.4605,0.5006), p(0.4705,0.4988),
             p(0.4853,0.4992), p(0.4904,0.4961), p(0.4954,0.4864), p(0.4962,0.4822), p(0.5011,0.4711), p(0.5057,0.4643),
             p(0.5089,0.4630), p(0.5256,0.4623)]
        ]),
        Province(id: "Gelderland", rings: [
            [p(0.9101,0.5098), p(0.9045,0.5122), p(0.9002,0.5162), p(0.8950,0.5252), p(0.8867,0.5280), p(0.8851,0.5318),
             p(0.8860,0.5371), p(0.8964,0.5406), p(0.9143,0.5478), p(0.9216,0.5535), p(0.9239,0.5576), p(0.9239,0.5619),
             p(0.9186,0.5655), p(0.9131,0.5748), p(0.9072,0.5812), p(0.9001,0.5847), p(0.8764,0.5862), p(0.8502,0.5948),
             p(0.8375,0.6036), p(0.8277,0.6056), p(0.8103,0.6021), p(0.8130,0.6100), p(0.8121,0.6136), p(0.8021,0.6163),
             p(0.8010,0.6107), p(0.7965,0.6089), p(0.7861,0.6080), p(0.7816,0.6025), p(0.7775,0.6010), p(0.7691,0.6028),
             p(0.7599,0.6001), p(0.7510,0.5946), p(0.7422,0.5916), p(0.7333,0.5960), p(0.7471,0.6061), p(0.7510,0.6107),
             p(0.7315,0.6072), p(0.7206,0.6101), p(0.7115,0.6154), p(0.7064,0.6174), p(0.6955,0.6194), p(0.6912,0.6221),
             p(0.6904,0.6253), p(0.6967,0.6289), p(0.7007,0.6356), p(0.7006,0.6428), p(0.6963,0.6465), p(0.6870,0.6426),
             p(0.6807,0.6361), p(0.6736,0.6378), p(0.6737,0.6426), p(0.6460,0.6424), p(0.6267,0.6323), p(0.6189,0.6298),
             p(0.6136,0.6216), p(0.6016,0.6198), p(0.5846,0.6225), p(0.5753,0.6188), p(0.5651,0.6240), p(0.5596,0.6259),
             p(0.5487,0.6255), p(0.5435,0.6280), p(0.5404,0.6409), p(0.5371,0.6455), p(0.5274,0.6511), p(0.4784,0.6568),
             p(0.4760,0.6562), p(0.4787,0.6503), p(0.4786,0.6446), p(0.4684,0.6393), p(0.4590,0.6402), p(0.4487,0.6342),
             p(0.4444,0.6305), p(0.4435,0.6256), p(0.4436,0.6186), p(0.4418,0.6166), p(0.4496,0.6159), p(0.4700,0.6084),
             p(0.4727,0.6069), p(0.4718,0.6014), p(0.4818,0.5857), p(0.4882,0.5743), p(0.4985,0.5735), p(0.5072,0.5695),
             p(0.5224,0.5760), p(0.5280,0.5747), p(0.5356,0.5695), p(0.5416,0.5683), p(0.5516,0.5702), p(0.5626,0.5650),
             p(0.5742,0.5667), p(0.5953,0.5763), p(0.6044,0.5777), p(0.6051,0.5706), p(0.6009,0.5626), p(0.5953,0.5579),
             p(0.5917,0.5530), p(0.5888,0.5424), p(0.5888,0.5339), p(0.5852,0.5228), p(0.5809,0.5238), p(0.5817,0.5292),
             p(0.5787,0.5326), p(0.5716,0.5356), p(0.5630,0.5315), p(0.5670,0.5275), p(0.5702,0.5200), p(0.5732,0.5201),
             p(0.5740,0.5120), p(0.5635,0.5035), p(0.5515,0.5012), p(0.5497,0.4988), p(0.5530,0.4949), p(0.5533,0.4914),
             p(0.5435,0.4853), p(0.5419,0.4833), p(0.5437,0.4699), p(0.5548,0.4704), p(0.5775,0.4652), p(0.5805,0.4623),
             p(0.5884,0.4455), p(0.6001,0.4332), p(0.6079,0.4275), p(0.6231,0.4232), p(0.6321,0.4191), p(0.6405,0.4136),
             p(0.6460,0.4082), p(0.6561,0.3954), p(0.6609,0.3881), p(0.6637,0.3798), p(0.6638,0.3727), p(0.6683,0.3728),
             p(0.6778,0.3855), p(0.6816,0.3869), p(0.6896,0.3847), p(0.6977,0.3786), p(0.7052,0.3750), p(0.7104,0.3768),
             p(0.7144,0.3823), p(0.7231,0.3896), p(0.7281,0.3994), p(0.7339,0.4058), p(0.7347,0.4117), p(0.7313,0.4204),
             p(0.7213,0.4242), p(0.7230,0.4282), p(0.7207,0.4312), p(0.7186,0.4416), p(0.7237,0.4472), p(0.7292,0.4491),
             p(0.7345,0.4591), p(0.7347,0.4643), p(0.7401,0.4668), p(0.7398,0.4717), p(0.7433,0.4749), p(0.7498,0.4704),
             p(0.7711,0.4728), p(0.7879,0.4718), p(0.8034,0.4651), p(0.8113,0.4657), p(0.8268,0.4828), p(0.8349,0.4886),
             p(0.8414,0.4878), p(0.8516,0.4884), p(0.8621,0.4872), p(0.8636,0.4915), p(0.8752,0.4896), p(0.8809,0.4913),
             p(0.8828,0.4990), p(0.8805,0.5045), p(0.9068,0.5080), p(0.9101,0.5098)]
        ]),
        Province(id: "Zuid-Holland", rings: [
            [p(0.2035,0.6930), p(0.2037,0.6845), p(0.2072,0.6814), p(0.2118,0.6797), p(0.2210,0.6790), p(0.2113,0.6727),
             p(0.1924,0.6682), p(0.1884,0.6637), p(0.1866,0.6519), p(0.1818,0.6446), p(0.1753,0.6398), p(0.1676,0.6356),
             p(0.1626,0.6388), p(0.1558,0.6406), p(0.1488,0.6406), p(0.1382,0.6437), p(0.1356,0.6338), p(0.1433,0.6294),
             p(0.1601,0.6250), p(0.1623,0.6225), p(0.1676,0.6221), p(0.1766,0.6237), p(0.1841,0.6269), p(0.1873,0.6268),
             p(0.1932,0.6235), p(0.1842,0.6126), p(0.1807,0.6099), p(0.1806,0.6049), p(0.1837,0.6004), p(0.1826,0.5950),
             p(0.1773,0.5812), p(0.1743,0.5753), p(0.1776,0.5702), p(0.1900,0.5723), p(0.2003,0.5707), p(0.2094,0.5658),
             p(0.2468,0.5272), p(0.2785,0.4876), p(0.3020,0.4508), p(0.3153,0.4554), p(0.3201,0.4562), p(0.3255,0.4538),
             p(0.3316,0.4548), p(0.3207,0.4703), p(0.3188,0.4808), p(0.3156,0.4855), p(0.3248,0.4906), p(0.3313,0.4904),
             p(0.3426,0.4877), p(0.3591,0.4823), p(0.3611,0.4835), p(0.3634,0.4904), p(0.3662,0.4915), p(0.3745,0.4867),
             p(0.3812,0.4944), p(0.3870,0.4962), p(0.4003,0.5050), p(0.3980,0.5067), p(0.4015,0.5165), p(0.3998,0.5174),
             p(0.3921,0.5147), p(0.3894,0.5153), p(0.3817,0.5225), p(0.3895,0.5262), p(0.3933,0.5393), p(0.4054,0.5391),
             p(0.4036,0.5416), p(0.3931,0.5461), p(0.3850,0.5568), p(0.3862,0.5590), p(0.3984,0.5575), p(0.3998,0.5617),
             p(0.3920,0.5659), p(0.4095,0.5852), p(0.4112,0.5829), p(0.4198,0.5822), p(0.4272,0.5756), p(0.4362,0.5708),
             p(0.4474,0.5727), p(0.4501,0.5716), p(0.4560,0.5659), p(0.4621,0.5644), p(0.4669,0.5617), p(0.4740,0.5643),
             p(0.4804,0.5720), p(0.4882,0.5743), p(0.4818,0.5857), p(0.4718,0.6014), p(0.4727,0.6069), p(0.4700,0.6084),
             p(0.4496,0.6159), p(0.4418,0.6166), p(0.4436,0.6186), p(0.4435,0.6256), p(0.4371,0.6262), p(0.4234,0.6243),
             p(0.4165,0.6245), p(0.4063,0.6325), p(0.3998,0.6343), p(0.3849,0.6348), p(0.3775,0.6398), p(0.3717,0.6451),
             p(0.3680,0.6514), p(0.3549,0.6649), p(0.3464,0.6652), p(0.3402,0.6669), p(0.3293,0.6714), p(0.3200,0.6739),
             p(0.3097,0.6743), p(0.2817,0.6701), p(0.2738,0.6826), p(0.2635,0.6886), p(0.2490,0.6919), p(0.2380,0.6928),
             p(0.2269,0.6959), p(0.2206,0.6941), p(0.2148,0.6908), p(0.2087,0.6889), p(0.2035,0.6930)]
        ]),
        Province(id: "Zeeland", rings: [
            [p(0.1773,0.6739), p(0.1832,0.6794), p(0.1945,0.6818), p(0.1997,0.6848), p(0.2003,0.6905), p(0.1976,0.6941),
             p(0.1884,0.6982), p(0.1678,0.7017), p(0.1630,0.7016), p(0.1529,0.6987), p(0.1470,0.6954), p(0.1426,0.6861),
             p(0.1383,0.6834), p(0.1277,0.6800), p(0.1219,0.6752), p(0.1183,0.6750), p(0.1101,0.6828), p(0.0981,0.6835),
             p(0.0926,0.6822), p(0.0890,0.6779), p(0.0895,0.6664), p(0.0992,0.6612), p(0.1219,0.6583), p(0.1274,0.6582),
             p(0.1310,0.6598), p(0.1568,0.6602), p(0.1627,0.6612), p(0.1672,0.6638), p(0.1773,0.6739)],
            [p(0.2353,0.7914), p(0.2319,0.8047), p(0.2214,0.8168), p(0.2081,0.8256), p(0.1746,0.8399), p(0.1623,0.8480),
             p(0.1563,0.8497), p(0.1241,0.8503), p(0.1166,0.8451), p(0.1165,0.8376), p(0.1150,0.8329), p(0.1099,0.8302),
             p(0.0766,0.8215), p(0.0629,0.8209), p(0.0437,0.8240), p(0.0408,0.8266), p(0.0404,0.8385), p(0.0275,0.8403),
             p(0.0187,0.8394), p(0.0105,0.8364), p(0.0038,0.8305), p(0.0000,0.8216), p(0.0012,0.8045), p(0.0425,0.7791),
             p(0.0464,0.7764), p(0.0506,0.7759), p(0.0679,0.7850), p(0.0944,0.7909), p(0.1032,0.7971), p(0.1090,0.7992),
             p(0.1200,0.7991), p(0.1303,0.8014), p(0.1369,0.8005), p(0.1632,0.7909), p(0.1667,0.7874), p(0.1681,0.7803),
             p(0.1707,0.7771), p(0.1766,0.7773), p(0.1868,0.7812), p(0.1943,0.7910), p(0.2038,0.7924), p(0.2083,0.7948),
             p(0.2177,0.7953), p(0.2240,0.7882), p(0.2293,0.7886), p(0.2353,0.7914)],
            [p(0.2366,0.7377), p(0.2269,0.7364), p(0.2157,0.7324), p(0.2029,0.7332), p(0.1989,0.7327), p(0.1923,0.7296),
             p(0.1707,0.7134), p(0.1849,0.7077), p(0.1920,0.7060), p(0.2162,0.7066), p(0.2233,0.7083), p(0.2299,0.7127),
             p(0.2380,0.7205), p(0.2400,0.7250), p(0.2398,0.7306), p(0.2366,0.7377)],
            [p(0.2514,0.7909), p(0.2460,0.7908), p(0.2426,0.7855), p(0.2413,0.7748), p(0.2384,0.7733), p(0.2354,0.7767),
             p(0.2294,0.7782), p(0.2051,0.7780), p(0.1939,0.7738), p(0.1788,0.7634), p(0.1744,0.7620), p(0.1630,0.7612),
             p(0.1593,0.7631), p(0.1515,0.7756), p(0.1485,0.7793), p(0.1443,0.7812), p(0.1346,0.7822), p(0.1282,0.7844),
             p(0.1253,0.7834), p(0.1178,0.7770), p(0.1014,0.7706), p(0.0908,0.7624), p(0.0865,0.7620), p(0.0753,0.7655),
             p(0.0692,0.7658), p(0.0538,0.7630), p(0.0489,0.7609), p(0.0378,0.7462), p(0.0289,0.7398), p(0.0259,0.7360),
             p(0.0248,0.7303), p(0.0276,0.7271), p(0.0552,0.7129), p(0.1276,0.7059), p(0.1336,0.7065), p(0.1421,0.7117),
             p(0.1460,0.7160), p(0.1486,0.7211), p(0.1395,0.7261), p(0.1395,0.7283), p(0.1654,0.7302), p(0.1786,0.7344),
             p(0.1899,0.7422), p(0.1935,0.7477), p(0.1991,0.7599), p(0.2032,0.7643), p(0.2097,0.7657), p(0.2237,0.7639),
             p(0.2291,0.7662), p(0.2344,0.7646), p(0.2462,0.7641), p(0.2476,0.7695), p(0.2459,0.7733), p(0.2474,0.7841),
             p(0.2499,0.7858), p(0.2514,0.7909)],
            [p(0.2239,0.7034), p(0.2133,0.7031), p(0.2055,0.6987), p(0.2035,0.6930), p(0.2087,0.6889), p(0.2148,0.6908),
             p(0.2206,0.6941), p(0.2269,0.6959), p(0.2268,0.6961), p(0.2239,0.7034)]
        ]),
        Province(id: "Noord-Brabant", rings: [
            [p(0.2514,0.7909), p(0.2499,0.7858), p(0.2474,0.7841), p(0.2459,0.7733), p(0.2476,0.7695), p(0.2462,0.7641),
             p(0.2514,0.7629), p(0.2549,0.7548), p(0.2525,0.7472), p(0.2468,0.7415), p(0.2366,0.7377), p(0.2398,0.7306),
             p(0.2400,0.7250), p(0.2380,0.7205), p(0.2299,0.7127), p(0.2284,0.7061), p(0.2239,0.7034), p(0.2268,0.6961),
             p(0.2269,0.6959), p(0.2380,0.6928), p(0.2490,0.6919), p(0.2635,0.6886), p(0.2738,0.6826), p(0.2817,0.6701),
             p(0.3097,0.6743), p(0.3200,0.6739), p(0.3293,0.6714), p(0.3402,0.6669), p(0.3464,0.6652), p(0.3549,0.6649),
             p(0.3680,0.6514), p(0.3717,0.6451), p(0.3775,0.6398), p(0.3849,0.6348), p(0.3998,0.6343), p(0.4063,0.6325),
             p(0.4165,0.6245), p(0.4234,0.6243), p(0.4371,0.6262), p(0.4435,0.6256), p(0.4444,0.6305), p(0.4487,0.6342),
             p(0.4590,0.6402), p(0.4684,0.6393), p(0.4786,0.6446), p(0.4787,0.6503), p(0.4760,0.6562), p(0.4784,0.6568),
             p(0.5274,0.6511), p(0.5371,0.6455), p(0.5404,0.6409), p(0.5435,0.6280), p(0.5487,0.6255), p(0.5596,0.6259),
             p(0.5651,0.6240), p(0.5753,0.6188), p(0.5846,0.6225), p(0.6016,0.6198), p(0.6136,0.6216), p(0.6189,0.6298),
             p(0.6267,0.6323), p(0.6460,0.6424), p(0.6737,0.6426), p(0.6791,0.6447), p(0.6786,0.6489), p(0.6811,0.6531),
             p(0.6855,0.6553), p(0.6964,0.6558), p(0.7007,0.6584), p(0.7048,0.6711), p(0.7092,0.6748), p(0.7077,0.6782),
             p(0.7144,0.6832), p(0.7216,0.6931), p(0.7273,0.7093), p(0.7233,0.7125), p(0.7139,0.7085), p(0.7008,0.7127),
             p(0.6904,0.7140), p(0.6799,0.7115), p(0.6702,0.7109), p(0.6754,0.7332), p(0.6825,0.7532), p(0.6923,0.7634),
             p(0.6994,0.7746), p(0.6839,0.7861), p(0.6756,0.7881), p(0.6304,0.8011), p(0.6249,0.8074), p(0.6187,0.8169),
             p(0.6168,0.8289), p(0.6135,0.8333), p(0.5982,0.8374), p(0.5965,0.8363), p(0.5954,0.8283), p(0.5931,0.8215),
             p(0.5878,0.8162), p(0.5814,0.8131), p(0.5754,0.8127), p(0.5702,0.8150), p(0.5591,0.8218), p(0.5534,0.8238),
             p(0.5212,0.8235), p(0.5110,0.8258), p(0.5062,0.8250), p(0.5056,0.8123), p(0.5007,0.8074), p(0.4852,0.8082),
             p(0.4804,0.8062), p(0.4744,0.7931), p(0.4648,0.7849), p(0.4629,0.7815), p(0.4636,0.7738), p(0.4665,0.7680),
             p(0.4672,0.7621), p(0.4616,0.7540), p(0.4525,0.7489), p(0.4485,0.7498), p(0.4443,0.7597), p(0.4343,0.7726),
             p(0.4276,0.7782), p(0.4219,0.7797), p(0.4062,0.7749), p(0.3873,0.7748), p(0.3814,0.7729), p(0.3829,0.7686),
             p(0.3859,0.7682), p(0.3979,0.7724), p(0.3957,0.7663), p(0.3982,0.7558), p(0.3975,0.7505), p(0.3900,0.7452),
             p(0.3812,0.7435), p(0.3723,0.7474), p(0.3520,0.7689), p(0.3457,0.7719), p(0.3414,0.7721), p(0.3327,0.7705),
             p(0.3213,0.7716), p(0.3161,0.7686), p(0.3187,0.7607), p(0.3189,0.7548), p(0.3167,0.7519), p(0.3053,0.7527),
             p(0.2909,0.7573), p(0.2769,0.7642), p(0.2803,0.7672), p(0.2779,0.7760), p(0.2862,0.7850), p(0.2880,0.7885),
             p(0.2868,0.7946), p(0.2817,0.7969), p(0.2691,0.7965), p(0.2539,0.7909), p(0.2514,0.7909)]
        ]),
        Province(id: "Limburg", rings: [
            [p(0.6737,0.6426), p(0.6736,0.6378), p(0.6807,0.6361), p(0.6870,0.6426), p(0.6963,0.6465), p(0.6948,0.6517),
             p(0.7053,0.6521), p(0.7174,0.6589), p(0.7143,0.6690), p(0.7207,0.6753), p(0.7393,0.6812), p(0.7354,0.6943),
             p(0.7369,0.6987), p(0.7559,0.7182), p(0.7673,0.7282), p(0.7715,0.7461), p(0.7692,0.7607), p(0.7692,0.7673),
             p(0.7735,0.7711), p(0.7722,0.7743), p(0.7717,0.7821), p(0.7680,0.7898), p(0.7585,0.7963), p(0.7457,0.8178),
             p(0.7377,0.8277), p(0.7357,0.8348), p(0.7353,0.8428), p(0.7377,0.8493), p(0.7442,0.8520), p(0.7573,0.8439),
             p(0.7637,0.8454), p(0.7556,0.8509), p(0.7614,0.8551), p(0.7576,0.8596), p(0.7425,0.8670), p(0.7180,0.8840),
             p(0.7145,0.8876), p(0.7098,0.8969), p(0.7065,0.9000), p(0.7016,0.9005), p(0.6944,0.8946), p(0.6905,0.8930),
             p(0.6830,0.8965), p(0.6850,0.9048), p(0.6896,0.9148), p(0.6904,0.9238), p(0.7047,0.9189), p(0.7158,0.9209),
             p(0.7256,0.9196), p(0.7238,0.9275), p(0.7253,0.9354), p(0.7340,0.9403), p(0.7432,0.9425), p(0.7409,0.9483),
             p(0.7436,0.9555), p(0.7422,0.9620), p(0.7393,0.9651), p(0.7331,0.9649), p(0.7294,0.9667), p(0.7272,0.9704),
             p(0.7283,0.9767), p(0.7271,0.9809), p(0.7233,0.9841), p(0.7191,0.9833), p(0.7205,0.9878), p(0.7274,0.9943),
             p(0.7271,0.9990), p(0.7215,1.0000), p(0.6954,0.9987), p(0.6716,0.9999), p(0.6629,0.9935), p(0.6601,0.9927),
             p(0.6537,0.9998), p(0.6478,0.9999), p(0.6426,0.9977), p(0.6454,0.9853), p(0.6351,0.9823), p(0.6287,0.9789),
             p(0.6240,0.9736), p(0.6231,0.9657), p(0.6421,0.9471), p(0.6484,0.9450), p(0.6530,0.9395), p(0.6602,0.9268),
             p(0.6549,0.9256), p(0.6488,0.9271), p(0.6590,0.9127), p(0.6629,0.9040), p(0.6590,0.9000), p(0.6607,0.8918),
             p(0.6662,0.8927), p(0.6713,0.8828), p(0.6691,0.8779), p(0.6751,0.8776), p(0.6803,0.8751), p(0.6737,0.8698),
             p(0.6744,0.8658), p(0.6781,0.8626), p(0.6747,0.8565), p(0.6701,0.8563), p(0.6618,0.8583), p(0.6581,0.8559),
             p(0.6521,0.8497), p(0.6441,0.8475), p(0.6281,0.8498), p(0.6185,0.8439), p(0.6029,0.8404), p(0.5982,0.8374),
             p(0.6135,0.8333), p(0.6168,0.8289), p(0.6187,0.8169), p(0.6249,0.8074), p(0.6304,0.8011), p(0.6756,0.7881),
             p(0.6839,0.7861), p(0.6994,0.7746), p(0.6923,0.7634), p(0.6825,0.7532), p(0.6754,0.7332), p(0.6702,0.7109),
             p(0.6799,0.7115), p(0.6904,0.7140), p(0.7008,0.7127), p(0.7139,0.7085), p(0.7233,0.7125), p(0.7273,0.7093),
             p(0.7216,0.6931), p(0.7144,0.6832), p(0.7077,0.6782), p(0.7092,0.6748), p(0.7048,0.6711), p(0.7007,0.6584),
             p(0.6964,0.6558), p(0.6855,0.6553), p(0.6811,0.6531), p(0.6786,0.6489), p(0.6791,0.6447), p(0.6737,0.6426)]
        ])
    ]

    static func province(id: String) -> Province? {
        provinces.first { $0.id == id }
    }

    static func countryPath(in size: CGSize) -> Path {
        var combined = Path()
        for province in provinces {
            combined.addPath(province.path(in: size))
        }
        return combined
    }

    static func path(points: [CGPoint], in size: CGSize) -> Path {
        Path.smoothClosed(points.map { CGPoint(x: $0.x * size.width, y: $0.y * size.height) })
    }

    static func openPath(points: [CGPoint], in size: CGSize) -> Path {
        var path = Path()
        let scaled = points.map { CGPoint(x: $0.x * size.width, y: $0.y * size.height) }
        guard let first = scaled.first else { return path }
        path.move(to: first)

        if scaled.count == 2, let last = scaled.last {
            path.addLine(to: last)
            return path
        }

        for index in 1..<scaled.count {
            let current = scaled[index]
            let previous = scaled[index - 1]
            let midpoint = CGPoint(x: (previous.x + current.x) * 0.5, y: (previous.y + current.y) * 0.5)
            path.addQuadCurve(to: midpoint, control: previous)
            if index == scaled.count - 1 {
                path.addQuadCurve(to: current, control: current)
            }
        }

        return path
    }

    private static func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: x, y: y)
    }
}

struct ProvinceRealMapShape: Shape {
    let provinceID: String

    func path(in rect: CGRect) -> Path {
        RealProvinceMapData.province(id: provinceID)?.path(in: rect.size) ?? Path()
    }
}

extension Path {
    static func preciseClosed(_ points: [CGPoint]) -> Path {
        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: first)
        points.dropFirst().forEach { path.addLine(to: $0) }
        path.closeSubpath()
        return path
    }

    static func smoothClosed(_ points: [CGPoint]) -> Path {
        var path = Path()
        guard points.count > 2 else {
            guard let first = points.first else { return path }
            path.move(to: first)
            points.dropFirst().forEach { path.addLine(to: $0) }
            path.closeSubpath()
            return path
        }

        let tension: CGFloat = 0.62
        path.move(to: points[0])
        for index in points.indices {
            let previous = points[(index - 1 + points.count) % points.count]
            let current = points[index]
            let next = points[(index + 1) % points.count]
            let afterNext = points[(index + 2) % points.count]

            let control1 = CGPoint(
                x: current.x + (next.x - previous.x) * tension / 6,
                y: current.y + (next.y - previous.y) * tension / 6
            )
            let control2 = CGPoint(
                x: next.x - (afterNext.x - current.x) * tension / 6,
                y: next.y - (afterNext.y - current.y) * tension / 6
            )
            path.addCurve(to: next, control1: control1, control2: control2)
        }
        path.closeSubpath()
        return path
    }
}

private extension String {
    var snakeCasedProvinceID: String {
        replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: " ", with: "_")
            .lowercased()
    }
}

// MARK: - City Dot Layer

private struct CityDotMapLayer: View {
    enum CitySize {
        case capital
        case major
        case medium
    }

    struct CityPoint {
        let name: String
        let provinceID: String
        let x: CGFloat
        let y: CGFloat
        let isUserCity: Bool
        let size: CitySize
        let labelOffset: CGSize
    }

    static let cities: [CityPoint] = [
        CityPoint(name: "Amsterdam", provinceID: "Noord-Holland", x: 0.38, y: 0.42, isUserCity: true, size: .capital, labelOffset: CGSize(width: 28, height: -5)),
        CityPoint(name: "Rotterdam", provinceID: "Zuid-Holland", x: 0.31, y: 0.56, isUserCity: false, size: .major, labelOffset: CGSize(width: 18, height: 22)),
        CityPoint(name: "Den Haag", provinceID: "Zuid-Holland", x: 0.25, y: 0.53, isUserCity: false, size: .major, labelOffset: CGSize(width: -38, height: -3)),
        CityPoint(name: "Utrecht", provinceID: "Utrecht", x: 0.50, y: 0.52, isUserCity: false, size: .major, labelOffset: CGSize(width: 42, height: -16)),
        CityPoint(name: "Eindhoven", provinceID: "Noord-Brabant", x: 0.58, y: 0.72, isUserCity: false, size: .medium, labelOffset: CGSize(width: 25, height: 2)),
        CityPoint(name: "Groningen", provinceID: "Groningen", x: 0.74, y: 0.15, isUserCity: false, size: .medium, labelOffset: CGSize(width: 29, height: -1)),
        CityPoint(name: "Leeuwarden", provinceID: "Friesland", x: 0.55, y: 0.18, isUserCity: false, size: .medium, labelOffset: CGSize(width: 31, height: 1)),
        CityPoint(name: "Assen", provinceID: "Drenthe", x: 0.68, y: 0.31, isUserCity: false, size: .medium, labelOffset: CGSize(width: 26, height: 1)),
        CityPoint(name: "Zwolle", provinceID: "Overijssel", x: 0.65, y: 0.43, isUserCity: false, size: .medium, labelOffset: CGSize(width: 26, height: 1)),
        CityPoint(name: "Arnhem", provinceID: "Gelderland", x: 0.60, y: 0.62, isUserCity: false, size: .medium, labelOffset: CGSize(width: 30, height: 1)),
        CityPoint(name: "Lelystad", provinceID: "Flevoland", x: 0.47, y: 0.39, isUserCity: false, size: .medium, labelOffset: CGSize(width: 42, height: -18)),
        CityPoint(name: "Middelburg", provinceID: "Zeeland", x: 0.16, y: 0.76, isUserCity: false, size: .medium, labelOffset: CGSize(width: 36, height: 1)),
        CityPoint(name: "'s-Hertogenbosch", provinceID: "Noord-Brabant", x: 0.45, y: 0.74, isUserCity: false, size: .medium, labelOffset: CGSize(width: 48, height: 1)),
        CityPoint(name: "Maastricht", provinceID: "Limburg", x: 0.72, y: 0.86, isUserCity: false, size: .medium, labelOffset: CGSize(width: 36, height: 2)),
        CityPoint(name: "Leiden", provinceID: "Zuid-Holland", x: 0.32, y: 0.50, isUserCity: false, size: .major, labelOffset: CGSize(width: -4, height: -22)),
    ]

    static func hitTest(_ point: CGPoint) -> CityPoint? {
        cities.first { city in
            hypot(point.x - city.x, point.y - city.y) <= 0.045
        }
    }

    var body: some View {
        GeometryReader { geo in
            ForEach(Self.cities, id: \.name) { city in
                let x = city.x * geo.size.width
                let y = city.y * geo.size.height
                ZStack {
                    if city.isUserCity {
                        HStack(spacing: 4) {
                            Image(systemName: "sparkle")
                                .font(.system(size: 7, weight: .black))
                            Text(city.name)
                                .font(.system(size: 9.4, weight: .heavy, design: .rounded))
                        }
                        .foregroundStyle(AppColors.dutchOrange)
                        .padding(.horizontal, 6.8)
                        .padding(.vertical, 3)
                        .background(Color(hex: "#2A160B").opacity(0.96))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(AppColors.dutchOrange.opacity(0.84), lineWidth: 0.75))
                        .shadow(color: AppColors.dutchOrange.opacity(0.32), radius: 5, x: 0, y: 0)
                        .shadow(color: Color.black.opacity(0.68), radius: 4, x: 0, y: 2)
                        .offset(city.labelOffset)
                    } else {
                        let dotSize = dotSize(for: city.size)
                        if city.size == .capital {
                            Circle()
                                .fill(Color(hex: "#7DD3FC").opacity(0.22))
                                .frame(width: 14, height: 14)
                            Circle()
                                .stroke(Color.white.opacity(0.20), lineWidth: 0.6)
                                .frame(width: 9, height: 9)
                            Circle()
                                .fill(Color(hex: "#7DD3FC"))
                                .frame(width: 6.2, height: 6.2)
                                .shadow(color: Color(hex: "#7DD3FC").opacity(0.50), radius: 3, x: 0, y: 0)
                            Circle()
                                .fill(.white)
                                .frame(width: 2.2, height: 2.2)
                        } else {
                            Circle()
                                .fill(Color(hex: "#7DD3FC").opacity(city.size == .major ? 0.18 : 0.13))
                                .frame(width: city.size == .major ? 14 : 11, height: city.size == .major ? 14 : 11)
                            Circle()
                                .fill(Color(hex: "#7DD3FC").opacity(city.size == .major ? 0.92 : 0.80))
                                .frame(width: dotSize, height: dotSize)
                                .shadow(color: Color(hex: "#7DD3FC").opacity(0.44), radius: 3, x: 0, y: 0)
                        }
                    }

                    if !city.isUserCity {
                        Text(city.name)
                            .font(.system(
                                size: city.size == .capital ? 9.4 : city.size == .major ? 8.2 : 7.1,
                                weight: city.size == .capital ? .bold : .semibold,
                                design: .rounded
                            ))
                            .foregroundStyle(.white.opacity(city.size == .medium ? 0.72 : city.size == .capital ? 0.94 : 0.82))
                            .shadow(color: .black.opacity(0.96), radius: 2.4, x: 0, y: 1)
                            .shadow(color: .black.opacity(0.82), radius: 0.7, x: 0, y: 0)
                            .offset(city.labelOffset)
                            .fixedSize()
                            .allowsHitTesting(false)
                    }
                }
                .position(x: x, y: y)
            }
        }
    }

    private func dotSize(for size: CitySize) -> CGFloat {
        switch size {
        case .capital: return 7.5
        case .major: return 6
        case .medium: return 4.8
        }
    }
}

private struct CityNavigationTapLayer: View {
    var body: some View {
        GeometryReader { geo in
            ForEach(CityDotMapLayer.cities, id: \.name) { city in
                NavigationLink(value: AppDestination.cityDetail(province: city.provinceID, city: city.name)) {
                    Circle()
                        .fill(Color.white.opacity(0.001))
                        .frame(width: tapDiameter(for: city.size), height: tapDiameter(for: city.size))
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(city.name)
                .accessibilityIdentifier("map.city.\(city.name.snakeCasedProvinceID)")
                .position(x: city.x * geo.size.width, y: city.y * geo.size.height)
            }
        }
    }

    private func tapDiameter(for size: CityDotMapLayer.CitySize) -> CGFloat {
        switch size {
        case .capital: return 62
        case .major: return 56
        case .medium: return 50
        }
    }
}

// MARK: - Landmark Layer

private struct MapLandmarkLayer: View {
    struct MapPOI: Identifiable {
        let id: String
        let symbol: String
        let x: CGFloat
        let y: CGFloat
        let tint: Color
        let scale: CGFloat
    }

    private let points: [MapPOI] = [
        MapPOI(id: "north-sea-ship-1", symbol: "ferry.fill", x: 0.11, y: 0.21, tint: Color(hex: "#7DD3FC"), scale: 0.76),
        MapPOI(id: "north-sea-ship-2", symbol: "ferry.fill", x: 0.10, y: 0.61, tint: Color(hex: "#7DD3FC"), scale: 0.74),
        MapPOI(id: "wadden-ferry", symbol: "ferry.fill", x: 0.28, y: 0.14, tint: Color(hex: "#7DD3FC"), scale: 0.84),
        MapPOI(id: "friesland-wind-1", symbol: "wind", x: 0.58, y: 0.11, tint: Color(hex: "#E0F2FE"), scale: 1.05),
        MapPOI(id: "friesland-wind-2", symbol: "wind", x: 0.53, y: 0.25, tint: Color(hex: "#A7F3D0"), scale: 0.95),
        MapPOI(id: "afsluitdijk-line", symbol: "road.lanes", x: 0.43, y: 0.13, tint: Color(hex: "#BAE6FD"), scale: 0.62),
        MapPOI(id: "groningen-nature", symbol: "tree.fill", x: 0.75, y: 0.18, tint: Color(hex: "#86EFAC"), scale: 0.84),
        MapPOI(id: "groningen-wind", symbol: "wind", x: 0.84, y: 0.22, tint: Color(hex: "#D9F99D"), scale: 0.84),
        MapPOI(id: "drenthe-forest", symbol: "tree.fill", x: 0.76, y: 0.33, tint: Color(hex: "#C084FC"), scale: 0.86),
        MapPOI(id: "amsterdam-culture", symbol: "building.columns.fill", x: 0.36, y: 0.36, tint: Color(hex: "#FDE68A"), scale: 0.90),
        MapPOI(id: "alkmaar-wind", symbol: "wind", x: 0.31, y: 0.27, tint: Color(hex: "#FDE68A"), scale: 0.82),
        MapPOI(id: "haarlem-landmark", symbol: "building.2.fill", x: 0.30, y: 0.39, tint: Color(hex: "#FDE68A"), scale: 0.58),
        MapPOI(id: "rotterdam-harbor", symbol: "sailboat.fill", x: 0.28, y: 0.60, tint: Color(hex: "#67E8F9"), scale: 0.82),
        MapPOI(id: "flevoland-wind", symbol: "wind", x: 0.50, y: 0.34, tint: Color(hex: "#93C5FD"), scale: 0.82),
        MapPOI(id: "utrecht-tree", symbol: "tree.fill", x: 0.42, y: 0.57, tint: Color(hex: "#E879F9"), scale: 0.82),
        MapPOI(id: "overijssel-castle", symbol: "building.columns.fill", x: 0.77, y: 0.48, tint: Color(hex: "#FBBF24"), scale: 0.88),
        MapPOI(id: "twente-rail", symbol: "tram.fill", x: 0.80, y: 0.55, tint: Color(hex: "#FBBF24"), scale: 0.58),
        MapPOI(id: "veluwe-park", symbol: "leaf.fill", x: 0.64, y: 0.59, tint: Color(hex: "#86EFAC"), scale: 0.86),
        MapPOI(id: "gelderland-castle", symbol: "building.columns.fill", x: 0.66, y: 0.71, tint: Color(hex: "#FDBA74"), scale: 0.92),
        MapPOI(id: "delta-water", symbol: "water.waves", x: 0.22, y: 0.74, tint: Color(hex: "#67E8F9"), scale: 0.88),
        MapPOI(id: "delta-harbor", symbol: "ferry.fill", x: 0.19, y: 0.67, tint: Color(hex: "#67E8F9"), scale: 0.58),
        MapPOI(id: "brabant-design", symbol: "graduationcap.fill", x: 0.59, y: 0.78, tint: Color(hex: "#FDBA74"), scale: 0.84),
        MapPOI(id: "brabant-wind", symbol: "wind", x: 0.37, y: 0.82, tint: Color(hex: "#F0ABFC"), scale: 0.80),
        MapPOI(id: "brabant-health", symbol: "cross.case.fill", x: 0.50, y: 0.84, tint: Color(hex: "#F9A8D4"), scale: 0.56),
        MapPOI(id: "limburg-hills", symbol: "mountain.2.fill", x: 0.74, y: 0.84, tint: Color(hex: "#D9F99D"), scale: 0.86),
        MapPOI(id: "limburg-wind", symbol: "wind", x: 0.71, y: 0.78, tint: Color(hex: "#BEF264"), scale: 0.82)
    ]

    var body: some View {
        GeometryReader { geo in
            ForEach(points) { point in
                ZStack {
                    Circle()
                        .fill(point.tint.opacity(0.075))
                        .frame(width: 14 * point.scale, height: 14 * point.scale)
                        .blur(radius: 0.7)
                    Image(systemName: point.symbol)
                        .font(.system(size: 10.4 * point.scale, weight: .semibold))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(point.tint.opacity(0.72))
                        .shadow(color: point.tint.opacity(0.34), radius: 3, x: 0, y: 0)
                        .shadow(color: Color.black.opacity(0.88), radius: 1.4, x: 0, y: 1)
                }
                .position(x: point.x * geo.size.width, y: point.y * geo.size.height)
                .accessibilityHidden(true)
                }
            }
        }
    }

    private var closeToolbarPlacement: ToolbarItemPlacement {
        #if os(iOS)
        .topBarTrailing
        #else
        .automatic
        #endif
    }

// MARK: - Province Label Layer

private struct ProvinceMapLabelLayer: View {
    let selectedProvinceID: String?
    let size: CGSize

    private let items: [(id: String, title: String, cx: CGFloat, cy: CGFloat, fontSize: CGFloat)] = [
        ("Groningen", "GRONINGEN", 0.735, 0.118, 8.8),
        ("Friesland", "FRIESLAND", 0.545, 0.150, 8.8),
        ("Drenthe", "DRENTHE", 0.725, 0.294, 8.8),
        ("Overijssel", "OVERIJSSEL", 0.765, 0.485, 8.3),
        ("Gelderland", "GELDERLAND", 0.645, 0.675, 8.3),
        ("Utrecht", "UTRECHT", 0.452, 0.612, 6.8),
        ("Noord-Holland", "NOORD\nHOLLAND", 0.300, 0.298, 8.2),
        ("Zuid-Holland", "ZUID\nHOLLAND", 0.275, 0.490, 7.8),
        ("Zeeland", "ZEELAND", 0.178, 0.704, 8.2),
        ("Noord-Brabant", "NOORD BRABANT", 0.510, 0.800, 8.2),
        ("Limburg", "LIMBURG", 0.762, 0.835, 8.4),
        ("Flevoland", "FLEVOLAND", 0.535, 0.332, 6.8),
    ]

    var body: some View {
        ZStack {
            ForEach(items, id: \.id) { item in
                let isSelected = selectedProvinceID == item.id
                let isOther = selectedProvinceID != nil && !isSelected
                Text(item.title)
                    .font(.system(
                        size: isSelected ? item.fontSize + 1.2 : item.fontSize,
                        weight: isSelected ? .heavy : .bold,
                        design: .rounded
                    ))
                    .foregroundStyle(
                        isSelected ? Color.white :
                        isOther ? Color.white.opacity(0.46) :
                        ProvinceStyle.provinceFill(id: item.id).top.opacity(0.92)
                    )
                    .tracking(0.72)
                    .multilineTextAlignment(.center)
                    .fixedSize()
                    .allowsHitTesting(false)
                    .scaleEffect(isSelected ? 1.10 : 1.0)
                    .shadow(color: Color.black.opacity(0.98), radius: 3.2, x: 0, y: 0)
                    .shadow(
                        color: Color.black.opacity(0.92),
                        radius: 1.0,
                        x: 0,
                        y: 1
                    )
                    .animation(.spring(response: 0.28), value: selectedProvinceID)
                    .position(x: item.cx * size.width, y: item.cy * size.height)
            }
        }
    }
}

private struct MapDecorationLayer: View {
    @EnvironmentObject private var languageManager: LanguageManager
    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        GeometryReader { geo in
            Text("Wadden Sea")
                .font(.system(size: 9, weight: .light, design: .rounded))
                .italic()
                .tracking(1.3)
                .foregroundStyle(Color(hex: "#38BDF8").opacity(0.48))
                .shadow(color: Color.black.opacity(0.68), radius: 2, x: 0, y: 1)
                .fixedSize()
                .position(x: geo.size.width * 0.35, y: geo.size.height * 0.075)
                .allowsHitTesting(false)

            Text("IJsselmeer")
                .font(.system(size: 9, weight: .light, design: .rounded))
                .italic()
                .tracking(1.3)
                .foregroundStyle(Color(hex: "#7DD3FC").opacity(0.50))
                .shadow(color: Color.black.opacity(0.70), radius: 2, x: 0, y: 1)
                .fixedSize()
                .position(x: geo.size.width * 0.49, y: geo.size.height * 0.31)
                .allowsHitTesting(false)

            Text("Markermeer")
                .font(.system(size: 7, weight: .light, design: .rounded))
                .italic()
                .tracking(1.2)
                .foregroundStyle(Color(hex: "#7DD3FC").opacity(0.42))
                .shadow(color: .black.opacity(0.60), radius: 2, x: 0, y: 0)
                .fixedSize()
                .position(x: geo.size.width * 0.47, y: geo.size.height * 0.36)
                .allowsHitTesting(false)

            Text("N o r t h   S e a")
                .font(.system(size: 12, weight: .light, design: .rounded))
                .italic()
                .tracking(2.1)
                .foregroundStyle(Color(hex: "#38BDF8").opacity(0.44))
                .shadow(color: .black.opacity(0.60), radius: 2, x: 0, y: 0)
                .fixedSize()
                .rotationEffect(.degrees(-12))
                .position(x: geo.size.width * 0.13, y: geo.size.height * 0.32)
                .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 8) {
                CompassView()
            }
            .padding(.leading, 26)
            .padding(.top, 32)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    private var userCityLegendLabel: String {
        switch lang {
        case .english: return "Your city"
        case .dutch: return "Jouw stad"
        case .russian: return "Ваш город"
        }
    }
    private var cityLegendLabel: String {
        switch lang {
        case .english: return "Cities"
        case .dutch: return "Steden"
        case .russian: return "Города"
        }
    }
}

private struct CompassView: View {
    @State private var appeared = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "#0A1828").opacity(0.88))
                .frame(width: 48, height: 48)
                .overlay(Circle().strokeBorder(Color(hex: "#4DD0E1").opacity(0.30), lineWidth: 1))

            ForEach(0..<8) { index in
                Rectangle()
                    .fill(index.isMultiple(of: 2) ? Color.white.opacity(0.50) : Color.white.opacity(0.22))
                    .frame(width: index.isMultiple(of: 2) ? 1.5 : 0.8, height: index.isMultiple(of: 2) ? 6 : 4)
                    .offset(y: -19)
                    .rotationEffect(.degrees(Double(index) * 45))
            }

            VStack(spacing: 0) {
                Triangle()
                    .fill(AppColors.dutchOrange)
                    .frame(width: 7, height: 12)
                Triangle()
                    .fill(Color.white.opacity(0.30))
                    .frame(width: 7, height: 12)
                    .rotationEffect(.degrees(180))
            }

            Circle()
                .fill(Color(hex: "#0A1828"))
                .frame(width: 5, height: 5)
                .overlay(Circle().strokeBorder(AppColors.dutchOrange, lineWidth: 1.4))

            Text("N")
                .font(.system(size: 8, weight: .black, design: .rounded))
                .foregroundStyle(AppColors.dutchOrange)
                .offset(y: -24)

            Text("E")
                .font(.system(size: 7, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.34))
                .offset(x: 22)

            Text("S")
                .font(.system(size: 7, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.34))
                .offset(y: 22)

            Text("W")
                .font(.system(size: 7, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.34))
                .offset(x: -22)
        }
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.60)
        .shadow(color: .black.opacity(0.5), radius: 8)
        .onAppear {
            withAnimation(.spring(response: 0.50, dampingFraction: 0.70).delay(0.30)) {
                appeared = true
            }
        }
    }
}

private struct ScaleBarView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 0) {
                ForEach(0..<4) { index in
                    Rectangle()
                        .fill(index.isMultiple(of: 2) ? Color.white.opacity(0.75) : Color.white.opacity(0.28))
                        .frame(width: 18, height: 4)
                }
            }
            .overlay {
                HStack {
                    Rectangle()
                        .fill(Color.white.opacity(0.75))
                        .frame(width: 1, height: 8)
                    Spacer()
                    Rectangle()
                        .fill(Color.white.opacity(0.75))
                        .frame(width: 1, height: 8)
                }
            }

            HStack {
                Text("0")
                Spacer()
                Text("50 km")
            }
            .font(.system(size: 7.5, weight: .medium, design: .rounded))
            .foregroundStyle(Color.white.opacity(0.48))
        }
        .frame(width: 72)
        .shadow(color: .black.opacity(0.5), radius: 4)
    }
}

private struct LegendItem: View {
    let symbolColor: Color
    let diameter: CGFloat
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(symbolColor)
                .frame(width: diameter, height: diameter)
            Text(label)
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.56))
                .lineLimit(1)
        }
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Province Selection Card

private struct ProvinceSelectionSurface: View {
    let provinceID: String
    let lang: AppLanguage
    let onDismiss: () -> Void

    private var province: ProvinceItem { ProvinceCatalog.item(id: provinceID) }
    private var nlProvince: NLProvince? { NLProvince.all.first { $0.id == provinceID || $0.name == provinceID } }
    private var provinceCities: [CitySpotlightData] {
        ProvinceCatalog.citySpotlights.filter { $0.province.id == province.id }
    }

    private var provinceHeroImage: ResolvedPlaceImage {
        if let nlProvince {
            return CanonicalPlaceImageResolver.resolveProvinceHero(province: nlProvince)
        }
        return CanonicalPlaceImageResolver.resolveProvinceHero(province: province)
    }

    private var provinceDescription: String? {
        switch lang {
        case .english:
            return nlProvince?.description ?? englishProvinceSummary
        case .dutch:
            return "\(province.localizedName(lang)) is een Nederlandse provincie met \(province.capital) als hoofdstad, ongeveer \(province.population) inwoners en \(province.municipalityCount) gemeenten. Gebruik deze kaart om steden, diensten en praktische informatie in de provincie te verkennen."
        case .russian:
            return "\(province.localizedName(lang)) - провинция Нидерландов со столицей \(province.capital), населением около \(province.population) и \(province.municipalityCount) муниципалитетами. Используйте эту карту, чтобы открыть города, услуги и практическую информацию по провинции."
        }
    }

    private var englishProvinceSummary: String {
        "\(province.localizedName(lang)) is a Dutch province with \(province.capital) as its capital, about \(province.population) residents, and \(province.municipalityCount) municipalities. Use this map to explore cities, services, and practical local information."
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ── Province hero image ──────────────────────────────────────
            ZStack(alignment: .bottom) {
                let resolvedImage = provinceHeroImage
                let provincePlaceId = CuratedPlaceHeroMediaRegistry.provincePlaceId(provinceName: province.id)
                let provinceURLString = resolvedImage.urlString ?? nlProvince?.imageURL
                CityImageView(
                    urlString: provinceURLString,
                    height: 132,
                    placeId: provincePlaceId,
                    cityName: province.localizedName(lang),
                    fallbackColor: province.mapHighlightColor,
                    fallbackURLStrings: resolvedImage.fallbackURLStrings,
                    debugContext: ImageDebugContext(
                        screen: "Map province modal hero",
                        entityType: "province",
                        entityName: province.localizedName(lang),
                        requestedURL: provinceURLString ?? "",
                        fallbackLevel: resolvedImage.fallbackLevel.rawValue,
                        sourceRegistry: resolvedImage.sourceRegistry,
                        modelID: provincePlaceId
                    ),
                    renderRole: .mapPreview
                )
                .frame(maxWidth: .infinity, minHeight: 132)

                LinearGradient(
                    colors: [.clear, Color(hex: "#0A1020").opacity(0.92)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .allowsHitTesting(false)

                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 3) {
                        provinceAccentMark
                        Text(province.localizedName(lang))
                            .font(.custom("Syne-ExtraBold", size: 20))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                        Text("\(provinceLabel) · \(province.capital)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color(hex: "#2DD4BF"))
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 1) {
                        Text(province.population)
                            .font(.custom("Syne-Bold", size: 15))
                            .foregroundStyle(.white)
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                        Text(populationLabel)
                            .font(.system(size: 9))
                            .foregroundStyle(.white.opacity(0.50))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 14)

                Capsule()
                    .fill(Color.white.opacity(0.40))
                    .frame(width: 38, height: 4)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, 8)

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Color.white.opacity(0.82))
                        .frame(width: AppIcons.Metrics.minimumTouchTarget, height: AppIcons.Metrics.minimumTouchTarget)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(.top, 6)
                .padding(.trailing, 8)
                .zIndex(3)
            }
            .frame(maxWidth: .infinity, minHeight: 132, maxHeight: 132)
            .clipped()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    if let description = provinceDescription, !description.isEmpty {
                        Text(description)
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.68))
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                    }

                    if !provinceCities.isEmpty {
                        Text(provinceCitiesTitle)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.40))
                            .tracking(1.0)
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .padding(.bottom, 8)

                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 10) {
                                ForEach(provinceCities) { spotlight in
                                    NavigationLink(value: AppDestination.cityDetail(province: spotlight.province.id, city: spotlight.city.name)) {
                                        ProvinceSheetCitySurface(spotlight: spotlight, lang: lang)
                                    }
                                    .buttonStyle(.plain)
                                    .pressable()
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .frame(height: 112)
                    }

                    Color.clear.frame(height: 12)
                }
            }
            .frame(maxHeight: 238)

            ViewThatFits(in: .horizontal) {
                provinceActionButtons(axis: .horizontal)
                provinceActionButtons(axis: .vertical)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: 438)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 0.8)
        )
        .shadow(color: Color.black.opacity(0.38), radius: 24, x: 0, y: -6)
        .onAppear {
            CanonicalPlaceImageResolver.assertUniqueVisibleCityImages(
                provinceCities.map { (name: $0.city.name, image: CanonicalPlaceImageResolver.resolveProvinceCityCard(city: $0.city)) },
                screen: "Map province modal city carousel"
            )
        }
    }

    @ViewBuilder
    private func provinceActionButtons(axis: Axis) -> some View {
        let spacing: CGFloat = 10
        if axis == .horizontal {
            HStack(spacing: spacing) {
                provinceExploreButton
                provinceCitiesButton
            }
        } else {
            VStack(spacing: spacing) {
                provinceExploreButton
                provinceCitiesButton
            }
        }
    }

    private var provinceExploreButton: some View {
        NavigationLink(value: AppDestination.provinceDetail(provinceID)) {
            Label(exploreLabel, systemImage: "arrow.right.circle.fill")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
                .frame(maxWidth: .infinity, minHeight: AppIcons.Metrics.minimumTouchTarget)
                .padding(.vertical, 8)
                .background(
                    LinearGradient(
                        colors: [
                            province.mapHighlightColor,
                            province.mapHighlightColor.opacity(0.78)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(NLTileButtonStyle())
    }

    private var provinceCitiesButton: some View {
        NavigationLink(value: AppDestination.provinceCities(provinceID)) {
            Label(citiesLabel, systemImage: "building.2.fill")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(province.mapHighlightColor)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
                .frame(maxWidth: .infinity, minHeight: AppIcons.Metrics.minimumTouchTarget)
                .padding(.vertical, 8)
                .background(province.mapHighlightColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(province.mapHighlightColor.opacity(0.40), lineWidth: 0.9)
                )
        }
        .buttonStyle(NLTileButtonStyle())
    }

    @ViewBuilder
    private var provinceAccentMark: some View {
        Capsule()
            .fill(province.mapHighlightColor)
            .frame(width: 44, height: 4)
    }

    private var provinceLabel: String {
        switch lang {
        case .russian: return "Провинция"
        case .dutch: return "Provincie"
        case .english: return "Province"
        }
    }

    private var populationLabel: String {
        switch lang {
        case .russian: return "Население"
        case .dutch: return "Inwoners"
        case .english: return "Population"
        }
    }

    private var provinceCitiesTitle: String {
        switch lang {
        case .russian: return "Города провинции"
        case .dutch: return "Steden in de provincie"
        case .english: return "Province cities"
        }
    }

    private struct ProvinceSheetCitySurface: View {
        let spotlight: CitySpotlightData
        let lang: AppLanguage

        private var city: CityItem { spotlight.city }
        private var cityHeroImage: ResolvedPlaceImage {
            CanonicalPlaceImageResolver.resolveProvinceCityCard(city: city)
        }

        var body: some View {
            ZStack(alignment: .bottomLeading) {
                let resolvedImage = cityHeroImage
                CityImageView(
                    urlString: resolvedImage.urlString,
                    height: 120,
                    placeId: city.placeId,
                    cityName: city.localizedName(lang),
                    fallbackColor: spotlight.province.mapHighlightColor,
                    fallbackURLStrings: resolvedImage.fallbackURLStrings,
                    debugContext: resolvedImage.debugContext(
                        screen: "Map province modal city card",
                        entityType: "city",
                        entityName: city.localizedName(lang)
                    ),
                    renderRole: .mapPreview
                )
                    .frame(width: 140, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                LinearGradient(
                    colors: [.clear, .black.opacity(0.80)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Image(systemName: ProvinceCatalog.identityIconName(for: city.name))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(.white.opacity(0.16))
                        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                    Text(city.localizedName(lang))
                        .font(.custom("Syne-Bold", size: 13))
                        .foregroundStyle(.white)
                    Text(city.populationText)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.white.opacity(0.55))
                }
                .padding(10)
            }
            .frame(width: 140, height: 120)
        }
    }

    private func statChip(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(AppColors.textTertiary)
            Text(text)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(1)
        }
    }

    private var exploreLabel: String {
        switch lang {
        case .russian: return "Открыть"
        case .dutch:   return "Verkennen"
        case .english: return "Explore"
        }
    }

    private var citiesLabel: String {
        switch lang {
        case .russian: return "Города"
        case .dutch:   return "Steden"
        case .english: return "Cities"
        }
    }
}

#if DEBUG && os(iOS)
private struct NetherlandsMapPreviewContainer: View {
    @StateObject private var languageManager = LanguageManager()
    @StateObject private var appState = AppStateViewModel()
    @StateObject private var savedItemsStore = SavedItemsStore()
    @StateObject private var documentStore = DocumentStore()
    @StateObject private var router = TabRouter()

    var body: some View {
        NavigationStack {
            NetherlandsMapHubView()
        }
        .environmentObject(languageManager)
        .environmentObject(appState)
        .environmentObject(savedItemsStore)
        .environmentObject(documentStore)
        .environmentObject(router)
        .environment(\.dynamicTypeSize, .large)
        .transaction { $0.animation = nil }
    }
}

#Preview("Map Hub - iPhone 15", traits: .fixedLayout(width: 390, height: 844)) {
    NetherlandsMapPreviewContainer()
}
#endif
