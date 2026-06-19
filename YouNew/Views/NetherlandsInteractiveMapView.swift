import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Netherlands Map Hub (Map Tab Root)

struct NetherlandsMapHubView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var router: TabRouter
    @State private var selectedProvinceID: String?
    @State private var selectedTerritory: OverseasTerritory?
    @State private var mapScale: CGFloat = 1
    @State private var mapOffset: CGSize = .zero
    @State private var glowPhase: Double = 0.20

    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        ZStack(alignment: .bottom) {
            mapBackground.ignoresSafeArea()

            GeometryReader { geo in
                ZStack {
                    PremiumProvinceMapCanvas(
                        selectedProvinceID: selectedProvinceID,
                        glowPhase: glowPhase
                    )
                    .drawingGroup()
                    .allowsHitTesting(false)

                    ProvinceMapLabelLayer(
                        selectedProvinceID: selectedProvinceID,
                        size: geo.size
                    )
                    .allowsHitTesting(false)

                    CityDotMapLayer()
                        .allowsHitTesting(false)

                    MapDecorationLayer()
                        .allowsHitTesting(false)

                    ProvinceTapLayer(selectedProvinceID: $selectedProvinceID)
                }
                .scaleEffect(mapScale)
                .offset(mapOffset)
                .simultaneousGesture(mapZoomGesture(), including: mapGestureMask)
            }
            .ignoresSafeArea()

            VStack {
                mapHeader
                    .padding(.top, 8)
                Spacer()
            }
            .safeAreaPadding(.top, 8)

            VStack {
                Spacer()
                HStack(alignment: .bottom) {
                    mapLegend
                        .padding(.leading, 12)
                        .padding(.bottom, FloatingTabBarMetrics.rootContentInset + 12)
                    Spacer()
                    OverseasTerritoriesInset { territory in
                        selectedTerritory = territory
                    }
                    .padding(.trailing, 12)
                    .padding(.bottom, selectedProvinceID == nil ? FloatingTabBarMetrics.rootContentInset + 12 : 174)
                }
            }
            .zIndex(9)

            // Province info card
            if let id = selectedProvinceID {
                ProvinceSelectionCard(
                    provinceID: id,
                    lang: lang,
                    onDismiss: {
                        withAnimation(.spring(response: 0.35)) {
                            selectedProvinceID = nil
                        }
                    }
                )
                .padding(.horizontal, 16)
                .padding(.bottom, FloatingTabBarMetrics.rootContentInset + 8)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(10)
            }
        }
        .animation(.spring(response: 0.38, dampingFraction: 0.86), value: selectedProvinceID)
        .onAppear {
            withAnimation(.easeInOut(duration: 3.6).repeatForever(autoreverses: true)) {
                glowPhase = 1.0
            }
        }
        .onReceive(router.mapReset) { _ in
            resetMapInteractionState()
        }
        .nlNavigationBarHidden()
        .sheet(item: $selectedTerritory) { territory in
            TerritorySheet(territory: territory)
        }
    }

    private var mapGestureMask: GestureMask {
        selectedProvinceID == nil && selectedTerritory == nil ? .all : .subviews
    }

    private func resetMapInteractionState() {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.84)) {
            selectedProvinceID = nil
            selectedTerritory = nil
            mapScale = 1
            mapOffset = .zero
        }
    }

    private func mapZoomGesture() -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                mapScale = min(max(value, 1), 3.2)
            }
            .onEnded { _ in
                if mapScale <= 1.03 {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                        mapScale = 1
                        mapOffset = .zero
                    }
                }
            }
            .simultaneously(with:
                DragGesture()
                    .onChanged { value in
                        guard mapScale > 1.05 else { return }
                        mapOffset = value.translation
                    }
                    .onEnded { _ in
                        guard mapScale <= 1.05 else { return }
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                            mapOffset = .zero
                        }
                    }
            )
    }

    // MARK: - Background

    private var mapBackground: some View {
        ZStack {
            Color(hex: "#060D1A")

            RadialGradient(
                colors: [
                    Color(hex: "#0D2035").opacity(0.80),
                    Color.clear
                ],
                center: UnitPoint(x: 0.55, y: 0.50),
                startRadius: 0,
                endRadius: backgroundGlowEndRadius
            )

            OceanWaveTextureLayer()

            LinearGradient(
                colors: [
                    Color(hex: "#071222").opacity(0.18),
                    Color(hex: "#030813").opacity(0.82)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            CartographicGridLayer()
                .opacity(0.95)
        }
    }

    private var backgroundGlowEndRadius: CGFloat {
#if canImport(UIKit)
        UIScreen.main.bounds.width * 0.85
#else
        640
#endif
    }

    // MARK: - Header

    private var mapHeader: some View {
        ViewThatFits(in: .horizontal) {
            mapHeaderHorizontal
            mapHeaderVertical
        }
    }

    private var mapHeaderHorizontal: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(headerTitle)
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
                    .fixedSize(horizontal: false, vertical: true)
                    .contentTransition(.interpolate)
                    .animation(.spring(response: 0.3), value: selectedProvinceID)
                Text(headerSubtitle)
                    .font(AppTypography.captionScale.weight(.semibold))
                    .foregroundStyle(AppColors.cyanGlow.opacity(0.78))
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            if selectedProvinceID != nil {
                Button {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                        selectedProvinceID = nil
                    }
                    #if canImport(UIKit)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    #endif
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.82))
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(0.12))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            } else {
                NavigationLink(value: AppDestination.mapHub) {
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 14, weight: .bold))
                        Text(nearbyLabel)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(AppColors.dutchOrange)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(AppColors.dutchOrange.opacity(0.12))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(AppColors.dutchOrange.opacity(0.28), lineWidth: 0.8))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .background(Color(red: 6 / 255, green: 13 / 255, blue: 26 / 255).opacity(0.72))
        .overlay(alignment: .bottom) {
            LinearGradient(
                colors: [.clear, AppColors.cyanGlow.opacity(0.16), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 0.6)
        }
    }

    private var mapHeaderVertical: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(headerTitle)
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
                    .fixedSize(horizontal: false, vertical: true)
                    .contentTransition(.interpolate)
                    .animation(.spring(response: 0.3), value: selectedProvinceID)
                Text(headerSubtitle)
                    .font(AppTypography.captionScale.weight(.semibold))
                    .foregroundStyle(AppColors.cyanGlow.opacity(0.78))
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
        VStack(alignment: .leading, spacing: 8) {
            mapLegendRow(color: AppColors.dutchOrange, title: localizedLegendText(en: "Selected province", nl: "Geselecteerde provincie", ru: "Выбранная провинция"))
            mapLegendRow(color: AppColors.cyanGlow, title: localizedLegendText(en: "City markers", nl: "Stadsmarkeringen", ru: "Города"))
            mapLegendRow(color: AppColors.routeLine, title: localizedLegendText(en: "Water and routes", nl: "Water en routes", ru: "Вода и маршруты"))
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .background(Color(red: 6 / 255, green: 13 / 255, blue: 26 / 255).opacity(0.64))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 0.8)
        )
        .shadow(color: Color.black.opacity(0.24), radius: 18, x: 0, y: 10)
    }

    private func mapLegendRow(color: Color, title: String) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .shadow(color: color.opacity(0.55), radius: 6, x: 0, y: 0)
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.76))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
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
        if let selectedProvinceID {
            return ProvinceCatalog.item(id: selectedProvinceID).localizedName(lang)
        }

        switch lang {
        case .russian: return "Нидерланды"
        case .dutch: return "Nederland"
        case .english: return "Netherlands"
        }
    }

    private var headerSubtitle: String {
        if selectedProvinceID != nil {
            switch lang {
            case .russian: return "Нажмите карточку, чтобы открыть детали"
            case .dutch: return "Tik op de kaart voor details"
            case .english: return "Tap the card to open details"
            }
        }

        switch lang {
        case .russian: return "Нажмите провинцию для навигации"
        case .dutch: return "Tik op een provincie om te navigeren"
        case .english: return "Tap a province to navigate"
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
                context.stroke(wave, with: .color(.white.opacity(0.025)), lineWidth: 0.4)
                y += 18
            }
        }
        .allowsHitTesting(false)
    }
}

private struct PremiumProvinceMapCanvas: View {
    let selectedProvinceID: String?
    let glowPhase: Double

    var body: some View {
        Canvas { context, size in
            drawCountrySilhouette(ctx: context, size: size)
            for shape in ProvinceMapShape.allCases {
                drawProvince(ctx: context, size: size, shape: shape)
            }
            drawWaterBodies(ctx: context, size: size)
            drawCoastline(ctx: context, size: size)
        }
    }

    private func drawCountrySilhouette(ctx: GraphicsContext, size: CGSize) {
        let path = RealProvinceMapData.countryPath(in: size)
        ctx.fill(path, with: .color(ProvinceStyle.land.opacity(0.12)))
        ctx.stroke(path, with: .color(ProvinceStyle.borderCoast.opacity(0.32)), lineWidth: 5.5)
    }

    private func drawWaterBodies(ctx: GraphicsContext, size: CGSize) {
        let waddenzee = RealProvinceMapData.path(points: [
            CGPoint(x: 0.27, y: 0.055),
            CGPoint(x: 0.42, y: 0.032),
            CGPoint(x: 0.62, y: 0.035),
            CGPoint(x: 0.79, y: 0.058),
            CGPoint(x: 0.75, y: 0.095),
            CGPoint(x: 0.56, y: 0.086),
            CGPoint(x: 0.38, y: 0.100),
            CGPoint(x: 0.24, y: 0.090)
        ], in: size)
        ctx.fill(waddenzee, with: .color(Color(hex: "#0A2440").opacity(0.66)))
        ctx.stroke(waddenzee, with: .color(Color(hex: "#4DD0E1").opacity(0.16)), lineWidth: 0.5)

        let ijsselmeer = RealProvinceMapData.path(points: [
            CGPoint(x: 0.36, y: 0.23),
            CGPoint(x: 0.48, y: 0.20),
            CGPoint(x: 0.58, y: 0.25),
            CGPoint(x: 0.59, y: 0.34),
            CGPoint(x: 0.51, y: 0.39),
            CGPoint(x: 0.40, y: 0.36)
        ], in: size)
        ctx.fill(ijsselmeer, with: .color(ProvinceStyle.water.opacity(0.90)))
        ctx.stroke(ijsselmeer, with: .color(Color(hex: "#4DD0E1").opacity(0.22)), lineWidth: 0.7)

        let markermeer = RealProvinceMapData.path(points: [
            CGPoint(x: 0.36, y: 0.36),
            CGPoint(x: 0.46, y: 0.38),
            CGPoint(x: 0.50, y: 0.45),
            CGPoint(x: 0.44, y: 0.50),
            CGPoint(x: 0.36, y: 0.47),
            CGPoint(x: 0.34, y: 0.41)
        ], in: size)
        ctx.fill(markermeer, with: .color(Color(hex: "#0C2840").opacity(0.76)))
        ctx.stroke(markermeer, with: .color(Color(hex: "#4DD0E1").opacity(0.16)), lineWidth: 0.45)
    }

    private func drawCoastline(ctx: GraphicsContext, size: CGSize) {
        let path = RealProvinceMapData.countryPath(in: size)
        ctx.stroke(
            path,
            with: .linearGradient(
                Gradient(colors: [Color(hex: "#4DD0E1").opacity(0.70), Color(hex: "#4DD0E1").opacity(0.45)]),
                startPoint: CGPoint(x: size.width * 0.50, y: 0),
                endPoint: CGPoint(x: size.width * 0.50, y: size.height)
            ),
            lineWidth: 2.0
        )
        ctx.stroke(path, with: .color(Color.white.opacity(0.07)), lineWidth: 0.6)
    }

    private func drawProvince(ctx: GraphicsContext, size: CGSize, shape: ProvinceMapShape) {
        guard let province = RealProvinceMapData.province(id: shape.id) else { return }
        let isSelected = selectedProvinceID == shape.id
        let isOther = selectedProvinceID != nil && !isSelected

        let path = province.path(in: size)

        let fill = ProvinceStyle.provinceFill(id: shape.id)
        let pulse = CGFloat(sin(glowPhase * 1.4) * 0.5 + 0.5)

        if isSelected {
            var glowContext = ctx
            glowContext.addFilter(.blur(radius: 6))
            glowContext.stroke(path, with: .color(ProvinceStyle.borderSelected.opacity(0.30 + 0.10 * pulse)), lineWidth: 10.0)
            ctx.fill(path, with: ProvinceStyle.selectedFill.shading(in: size, opacity: 0.92))
            drawProvinceDepth(ctx: ctx, size: size, path: path, selected: true)
            ctx.stroke(path, with: .color(Color.white.opacity(0.08)), lineWidth: 0.55)
            ctx.stroke(path, with: .color(ProvinceStyle.borderSelected), lineWidth: 1.8)
        } else if isOther {
            ctx.fill(path, with: fill.shading(in: size, opacity: 0.42))
            drawProvinceDepth(ctx: ctx, size: size, path: path, selected: false)
            ctx.stroke(path, with: .color(ProvinceStyle.border.opacity(0.30)), lineWidth: 0.7)
        } else {
            ctx.fill(path, with: fill.shading(in: size, opacity: 1))
            drawProvinceDepth(ctx: ctx, size: size, path: path, selected: false)
            ctx.stroke(path, with: .color(ProvinceStyle.border), lineWidth: 0.7)
            ctx.stroke(path, with: .color(Color.white.opacity(0.06)), lineWidth: 0.5)
        }
    }

    private func drawProvinceDepth(ctx: GraphicsContext, size: CGSize, path: Path, selected: Bool) {
        var depthContext = ctx
        depthContext.blendMode = .multiply
        depthContext.fill(
            path,
            with: .linearGradient(
                Gradient(colors: [
                    Color.black.opacity(selected ? 0.12 : 0.20),
                    Color.clear,
                    Color.white.opacity(selected ? 0.02 : 0.03)
                ]),
                startPoint: CGPoint(x: size.width * 0.50, y: 0),
                endPoint: CGPoint(x: size.width * 0.50, y: size.height)
            )
        )
    }
}

private enum ProvinceStyle {
    static let land = Color(hex: "#1C3A4A")
    static let border = Color(hex: "#4DD0E1").opacity(0.30)
    static let borderHover = Color(hex: "#4DD0E1").opacity(0.75)
    static let borderCoast = Color(hex: "#4DD0E1").opacity(0.58)
    static let borderSelected = AppColors.dutchOrange
    static let water = Color(hex: "#0D2A44")

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
            top: Color(hex: "#1A3040"),
            bottom: Color(hex: "#1F3A4C")
        )
    }

    static let selectedFill = ProvinceFill(
        top: Color(hex: "#F97316").opacity(0.30),
        bottom: Color(hex: "#F97316").opacity(0.15)
    )

    static let provinceFills: [String: ProvinceFill] = [
        "Groningen": ProvinceFill(top: Color(hex: "#1A3040"), bottom: Color(hex: "#1F3A4C")),
        "Friesland": ProvinceFill(top: Color(hex: "#183040"), bottom: Color(hex: "#1D3A4A")),
        "Drenthe": ProvinceFill(top: Color(hex: "#192E3C"), bottom: Color(hex: "#1E3848")),
        "Overijssel": ProvinceFill(top: Color(hex: "#1A3040"), bottom: Color(hex: "#1F3A4C")),
        "Gelderland": ProvinceFill(top: Color(hex: "#183A30"), bottom: Color(hex: "#1D4438")),
        "Utrecht": ProvinceFill(top: Color(hex: "#1A3040"), bottom: Color(hex: "#1F3A4C")),
        "Noord-Holland": ProvinceFill(top: Color(hex: "#183848"), bottom: Color(hex: "#1D4254")),
        "Zuid-Holland": ProvinceFill(top: Color(hex: "#1C3E50"), bottom: Color(hex: "#224858")),
        "Zeeland": ProvinceFill(top: Color(hex: "#163040"), bottom: Color(hex: "#1B3A4A")),
        "Noord-Brabant": ProvinceFill(top: Color(hex: "#1A3430"), bottom: Color(hex: "#1F3E3A")),
        "Limburg": ProvinceFill(top: Color(hex: "#1C3240"), bottom: Color(hex: "#213C4A")),
        "Flevoland": ProvinceFill(top: Color(hex: "#0E2030"), bottom: Color(hex: "#132838"))
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
        OverseasTerritory(name: "St. Eustatius", flag: "🇧🇶", region: "BES Islands", population: "3.2k", area: "21", status: "Municipality", description: "Special municipality. Historically known as the Golden Rock, once an important Caribbean trade hub.", color: Color(red: 34 / 255, green: 197 / 255, blue: 94 / 255)),
        OverseasTerritory(name: "Saba", flag: "🇧🇶", region: "BES Islands", population: "1.9k", area: "13", status: "Municipality", description: "Smallest special municipality. Mount Scenery is the highest point of the Kingdom of the Netherlands.", color: Color(red: 34 / 255, green: 197 / 255, blue: 94 / 255))
    ]
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

            LazyVGrid(columns: gridColumns, spacing: 6) {
                ForEach(OverseasTerritory.all) { territory in
                    TerritoryTile(territory: territory, onSelect: onSelect)
                }
            }
        }
        .padding(12)
        .background(Color(hex: "#0A1828").opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 0.5)
        )
    }

    private var gridColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 6),
            GridItem(.flexible(), spacing: 6),
            GridItem(.flexible(), spacing: 6)
        ]
    }
}

private struct TerritoryTile: View {
    let territory: OverseasTerritory
    let onSelect: (OverseasTerritory) -> Void

    var body: some View {
        Button {
            onSelect(territory)
        } label: {
            VStack(spacing: 3) {
                Text(territory.flag).font(.system(size: 18))
                Text(territory.name)
                    .font(.system(size: 8, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.75))
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)
                Text(territory.population)
                    .font(.system(size: 7, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.40))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, minHeight: 54)
            .padding(6)
            .background(territory.color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).strokeBorder(territory.color.opacity(0.25), lineWidth: 0.5))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .pressable()
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
        let points: [CGPoint]

        func path(in size: CGSize) -> Path {
            Self.path(points: points, in: size)
        }

        static func path(points: [CGPoint], in size: CGSize) -> Path {
            Path.smoothClosed(points.map { CGPoint(x: $0.x * size.width, y: $0.y * size.height) })
        }
    }

    static let provinces: [Province] = [
        Province(id: "Groningen", points: [p(0.58,0.08), p(0.68,0.07), p(0.79,0.09), p(0.88,0.15), p(0.89,0.20), p(0.83,0.25), p(0.72,0.24), p(0.63,0.21), p(0.59,0.15)]),
        Province(id: "Friesland", points: [p(0.35,0.09), p(0.45,0.07), p(0.58,0.08), p(0.60,0.15), p(0.63,0.22), p(0.57,0.30), p(0.44,0.30), p(0.39,0.23), p(0.38,0.16)]),
        Province(id: "Drenthe", points: [p(0.62,0.23), p(0.73,0.25), p(0.82,0.28), p(0.83,0.40), p(0.75,0.49), p(0.67,0.52), p(0.59,0.43), p(0.57,0.32)]),
        Province(id: "Noord-Holland", points: [p(0.25,0.10), p(0.35,0.09), p(0.38,0.16), p(0.39,0.24), p(0.36,0.33), p(0.38,0.45), p(0.34,0.56), p(0.25,0.57), p(0.20,0.49), p(0.17,0.38), p(0.18,0.27), p(0.21,0.16)]),
        Province(id: "Flevoland", points: [p(0.41,0.33), p(0.56,0.32), p(0.59,0.42), p(0.53,0.50), p(0.47,0.56), p(0.39,0.48), p(0.39,0.39)]),
        Province(id: "Overijssel", points: [p(0.59,0.44), p(0.68,0.53), p(0.78,0.49), p(0.86,0.55), p(0.84,0.62), p(0.77,0.70), p(0.65,0.66), p(0.55,0.56)]),
        Province(id: "Utrecht", points: [p(0.39,0.52), p(0.49,0.53), p(0.53,0.62), p(0.46,0.70), p(0.38,0.63), p(0.35,0.58)]),
        Province(id: "Gelderland", points: [p(0.54,0.57), p(0.65,0.67), p(0.78,0.70), p(0.78,0.80), p(0.66,0.84), p(0.55,0.82), p(0.46,0.70)]),
        Province(id: "Zuid-Holland", points: [p(0.20,0.58), p(0.35,0.58), p(0.43,0.67), p(0.36,0.78), p(0.24,0.75), p(0.13,0.66), p(0.15,0.61)]),
        Province(id: "Zeeland", points: [p(0.10,0.76), p(0.23,0.76), p(0.35,0.84), p(0.28,0.91), p(0.13,0.88), p(0.07,0.82)]),
        Province(id: "Noord-Brabant", points: [p(0.30,0.78), p(0.48,0.80), p(0.73,0.78), p(0.76,0.86), p(0.62,0.94), p(0.42,0.92), p(0.25,0.84)]),
        Province(id: "Limburg", points: [p(0.76,0.79), p(0.86,0.84), p(0.82,0.95), p(0.73,0.99), p(0.66,0.90), p(0.72,0.84)])
    ]

    static func province(id: String) -> Province? {
        provinces.first { $0.id == id }
    }

    static func countryPath(in size: CGSize) -> Path {
        path(points: [
            p(0.25,0.10), p(0.35,0.09), p(0.45,0.07), p(0.58,0.08), p(0.68,0.07),
            p(0.79,0.09), p(0.88,0.15), p(0.89,0.20), p(0.83,0.25), p(0.82,0.28),
            p(0.83,0.40), p(0.86,0.55), p(0.84,0.62), p(0.78,0.70), p(0.78,0.80),
            p(0.86,0.84), p(0.82,0.95), p(0.73,0.99), p(0.66,0.90), p(0.62,0.94),
            p(0.42,0.92), p(0.28,0.91), p(0.13,0.88), p(0.07,0.82), p(0.10,0.76),
            p(0.13,0.66), p(0.15,0.61), p(0.20,0.58), p(0.17,0.38), p(0.18,0.27),
            p(0.21,0.16)
        ], in: size)
    }

    static func path(points: [CGPoint], in size: CGSize) -> Path {
        Province.path(points: points, in: size)
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
    static func smoothClosed(_ points: [CGPoint]) -> Path {
        var path = Path()
        guard points.count > 2 else {
            guard let first = points.first else { return path }
            path.move(to: first)
            points.dropFirst().forEach { path.addLine(to: $0) }
            path.closeSubpath()
            return path
        }

        func midpoint(_ a: CGPoint, _ b: CGPoint) -> CGPoint {
            CGPoint(x: (a.x + b.x) * 0.5, y: (a.y + b.y) * 0.5)
        }

        let start = midpoint(points[points.count - 1], points[0])
        path.move(to: start)
        for index in points.indices {
            let current = points[index]
            let next = points[(index + 1) % points.count]
            path.addQuadCurve(to: midpoint(current, next), control: current)
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
        CityPoint(name: "Amsterdam", provinceID: "Noord-Holland", x: 0.44, y: 0.28, isUserCity: false, size: .capital, labelOffset: CGSize(width: 24, height: -9)),
        CityPoint(name: "Rotterdam", provinceID: "Zuid-Holland", x: 0.40, y: 0.50, isUserCity: false, size: .major, labelOffset: CGSize(width: 30, height: 10)),
        CityPoint(name: "Den Haag", provinceID: "Zuid-Holland", x: 0.34, y: 0.46, isUserCity: false, size: .major, labelOffset: CGSize(width: -29, height: -3)),
        CityPoint(name: "Utrecht", provinceID: "Utrecht", x: 0.55, y: 0.40, isUserCity: false, size: .major, labelOffset: CGSize(width: 25, height: -2)),
        CityPoint(name: "Eindhoven", provinceID: "Noord-Brabant", x: 0.60, y: 0.62, isUserCity: false, size: .medium, labelOffset: CGSize(width: 25, height: 2)),
        CityPoint(name: "Groningen", provinceID: "Groningen", x: 0.76, y: 0.08, isUserCity: false, size: .medium, labelOffset: CGSize(width: 27, height: -1)),
        CityPoint(name: "Maastricht", provinceID: "Limburg", x: 0.74, y: 0.80, isUserCity: false, size: .medium, labelOffset: CGSize(width: 30, height: 2)),
        CityPoint(name: "Leiden", provinceID: "Zuid-Holland", x: 0.37, y: 0.44, isUserCity: true, size: .major, labelOffset: CGSize(width: -2, height: -22)),
    ]

    @State private var pulseScale: CGFloat = 1

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
                        Circle()
                            .fill(Color(hex: "#F97316").opacity(0.10))
                            .frame(width: 24, height: 24)
                            .scaleEffect(pulseScale)
                        Circle()
                            .fill(Color(hex: "#F97316").opacity(0.30))
                            .frame(width: 15, height: 15)
                        Circle()
                            .fill(Color(hex: "#F97316"))
                            .frame(width: 8, height: 8)
                            .shadow(color: Color(hex: "#F97316").opacity(0.70), radius: 5, x: 0, y: 0)
                        Circle()
                            .fill(.white)
                            .frame(width: 3, height: 3)
                    } else {
                        let dotSize = dotSize(for: city.size)
                        if city.size == .capital {
                            Circle()
                                .fill(Color(hex: "#60A5FA").opacity(0.18))
                                .frame(width: 16, height: 16)
                            Circle()
                                .fill(Color(hex: "#60A5FA"))
                                .frame(width: 7, height: 7)
                                .shadow(color: Color(hex: "#60A5FA").opacity(0.50), radius: 4, x: 0, y: 0)
                            Circle()
                                .fill(.white)
                                .frame(width: 2.5, height: 2.5)
                        } else {
                            Circle()
                                .fill(Color(hex: "#60A5FA").opacity(city.size == .major ? 0.14 : 0.10))
                                .frame(width: city.size == .major ? 12 : 10, height: city.size == .major ? 12 : 10)
                            Circle()
                                .fill(Color(hex: "#60A5FA").opacity(city.size == .major ? 0.85 : 0.74))
                                .frame(width: dotSize, height: dotSize)
                        }
                    }

                    Text(city.name)
                        .font(.system(
                            size: city.isUserCity ? 10 : city.size == .capital ? 10.5 : city.size == .major ? 9.2 : 8.2,
                            weight: city.size == .capital || city.isUserCity ? .bold : .semibold,
                            design: .rounded
                        ))
                        .foregroundStyle(city.isUserCity ? AppColors.dutchOrange.opacity(0.96) : .white.opacity(city.size == .capital ? 0.95 : 0.75))
                        .shadow(color: .black.opacity(0.95), radius: 2, x: 0, y: 1)
                        .offset(city.labelOffset)
                        .fixedSize()
                        .allowsHitTesting(false)
                }
                .position(x: x, y: y)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                pulseScale = 1.72
            }
        }
    }

    private func dotSize(for size: CitySize) -> CGFloat {
        switch size {
        case .capital: return 7
        case .major: return 5.5
        case .medium: return 4.5
        }
    }
}

// MARK: - Province Label Layer

private struct ProvinceMapLabelLayer: View {
    let selectedProvinceID: String?
    let size: CGSize

    private let items: [(id: String, title: String, cx: CGFloat, cy: CGFloat, fontSize: CGFloat)] = [
        ("Groningen", "Groningen", 0.74, 0.16, 9.0),
        ("Friesland", "Friesland", 0.50, 0.19, 9.0),
        ("Drenthe", "Drenthe", 0.70, 0.36, 9.0),
        ("Overijssel", "Overijssel", 0.73, 0.58, 8.4),
        ("Gelderland", "Gelderland", 0.63, 0.76, 8.4),
        ("Utrecht", "Utrecht", 0.45, 0.61, 7.4),
        ("Noord-Holland", "N. Holland", 0.27, 0.35, 8.0),
        ("Zuid-Holland", "Z. Holland", 0.28, 0.68, 7.8),
        ("Zeeland", "Zeeland", 0.19, 0.83, 8.0),
        ("Noord-Brabant", "N. Brabant", 0.54, 0.86, 8.4),
        ("Limburg", "Limburg", 0.75, 0.90, 8.6),
        ("Flevoland", "Flevoland", 0.49, 0.45, 7.0),
    ]

    var body: some View {
        ZStack {
            ForEach(items, id: \.id) { item in
                let isSelected = selectedProvinceID == item.id
                let isOther = selectedProvinceID != nil && !isSelected
                Text(item.title)
                    .font(.system(
                        size: isSelected ? item.fontSize + 1.2 : item.fontSize,
                        weight: isSelected ? .bold : .semibold,
                        design: .rounded
                    ))
                    .foregroundStyle(
                        isSelected ? Color.white :
                        isOther ? Color.white.opacity(0.36) :
                        Color.white.opacity(0.60)
                    )
                    .multilineTextAlignment(.center)
                    .fixedSize()
                    .allowsHitTesting(false)
                    .scaleEffect(isSelected ? 1.10 : 1.0)
                    .shadow(
                        color: Color.black,
                        radius: 3,
                        x: 0,
                        y: 0
                    )
                    .shadow(
                        color: Color.black.opacity(0.80),
                        radius: 1,
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
            Text("Waddenzee")
                .font(.system(size: 8, weight: .light, design: .rounded))
                .italic()
                .tracking(1.1)
                .foregroundStyle(Color(red: 96 / 255, green: 165 / 255, blue: 250 / 255).opacity(0.28))
                .fixedSize()
                .position(x: geo.size.width * 0.52, y: geo.size.height * 0.055)
                .allowsHitTesting(false)

            Text("IJsselmeer")
                .font(.system(size: 9, weight: .light, design: .rounded))
                .italic()
                .tracking(1.3)
                .foregroundStyle(Color(red: 96 / 255, green: 165 / 255, blue: 250 / 255).opacity(0.38))
                .fixedSize()
                .position(x: geo.size.width * 0.49, y: geo.size.height * 0.31)
                .allowsHitTesting(false)

            Text("Markermeer")
                .font(.system(size: 7, weight: .light, design: .rounded))
                .italic()
                .tracking(1.2)
                .foregroundStyle(Color(hex: "#60A5FA").opacity(0.35))
                .shadow(color: .black.opacity(0.60), radius: 2, x: 0, y: 0)
                .fixedSize()
                .position(x: geo.size.width * 0.47, y: geo.size.height * 0.36)
                .allowsHitTesting(false)

            Text("Noordzee")
                .font(.system(size: 12, weight: .light, design: .rounded))
                .italic()
                .tracking(2.0)
                .foregroundStyle(Color(hex: "#60A5FA").opacity(0.35))
                .shadow(color: .black.opacity(0.60), radius: 2, x: 0, y: 0)
                .fixedSize()
                .rotationEffect(.degrees(-12))
                .position(x: geo.size.width * 0.13, y: geo.size.height * 0.42)
                .allowsHitTesting(false)

            VStack(alignment: .trailing, spacing: 8) {
                CompassView()
                ScaleBarView()
            }
            .padding(10)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)

            VStack(alignment: .leading, spacing: 7) {
                LegendItem(symbolColor: AppColors.dutchOrange, diameter: 8, label: userCityLegendLabel)
                LegendItem(symbolColor: Color(red: 96 / 255, green: 165 / 255, blue: 250 / 255), diameter: 7, label: cityLegendLabel)
            }
            .padding(10)
            .background(Color(red: 10 / 255, green: 24 / 255, blue: 40 / 255).opacity(0.74))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 0.5)
            )
            .padding(.leading, 10)
            .padding(.bottom, 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
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

private struct ProvinceSelectionCard: View {
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
        LazyVStack(alignment: .leading, spacing: 0) {
            // ── Province hero image ──────────────────────────────────────
            ZStack(alignment: .bottom) {
                let resolvedImage = provinceHeroImage
                let provincePlaceId = CuratedPlaceHeroMediaRegistry.provincePlaceId(provinceName: province.id)
                let provinceURLString = resolvedImage.urlString ?? nlProvince?.imageURL
                CityImageView(
                    urlString: provinceURLString,
                    height: 168,
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
                    )
                )
                .frame(maxWidth: .infinity, minHeight: 168)

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
                            .font(.custom("Syne-ExtraBold", size: 22))
                            .foregroundStyle(.white)
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
                        .font(.system(size: 22))
                        .foregroundStyle(Color.white.opacity(0.55))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(.top, 8)
                .padding(.trailing, 12)
            }
            .frame(maxWidth: .infinity, minHeight: 168)
            .clipped()

            if let description = provinceDescription, !description.isEmpty {
                Text(description)
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.65))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
            }

            if !provinceCities.isEmpty {
                Text(provinceCitiesTitle)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.35))
                    .tracking(1.0)
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 8)

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 10) {
                        ForEach(provinceCities) { spotlight in
                            NavigationLink(value: AppDestination.cityDetail(province: spotlight.province.id, city: spotlight.city.name)) {
                                ProvinceSheetCityCard(spotlight: spotlight, lang: lang)
                            }
                            .buttonStyle(.plain)
                            .pressable()
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(height: 120)
            }

            ViewThatFits(in: .horizontal) {
                provinceActionButtons(axis: .horizontal)
                provinceActionButtons(axis: .vertical)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 18)
        }
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

    private struct ProvinceSheetCityCard: View {
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
                    )
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
