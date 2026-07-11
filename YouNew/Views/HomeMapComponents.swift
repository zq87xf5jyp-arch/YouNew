import SwiftUI

struct HomeCityMapShortcutSection: View {
    let title: String
    let subtitle: String
    let destination: AppDestination
    let cardTitle: String
    let cardSubtitle: String
    let cta: String

    var body: some View {
        ProductScreenSection(title: title, subtitle: subtitle) {
            NavigationLink(value: destination) {
                ProductTaskCard(
                    title: cardTitle,
                    subtitle: cardSubtitle,
                    symbol: "map.fill",
                    accent: AppColors.dutchOrange,
                    cta: cta,
                    minHeight: 104,
                    prominence: .normal
                )
            }
            .buttonStyle(NLTileButtonStyle())
            .accessibilityIdentifier("home.cityMap")
        }
    }
}

struct HomeNetherlandsMapSection: View {
    let title: String
    let subtitle: String
    let mapCardTitle: String
    let mapCardSubtitle: String
    let openMapLabel: String
    let selectedCity: String
    let language: AppLanguage
    let glowPhase: Double
    let onOpenMap: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        ZStack(alignment: .topLeading) {
            AppSurface.base

            PremiumNetherlandsMapCanvas(
                selectedProvinceID: nil,
                selectedCity: selectedCity,
                glowPhase: glowPhase,
                displayMode: .services
            )
            .opacity(0.10)
            .padding(.horizontal, 18)
            .padding(.vertical, 34)
            .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 16) {
                titleBlock
                    .homeReadableBand()

                HomeRealisticNetherlandsMapSurface(
                    title: mapCardTitle,
                    subtitle: mapCardSubtitle,
                    openMapLabel: openMapLabel,
                    selectedCity: selectedCity,
                    language: language,
                    glowPhase: glowPhase,
                    onOpenMap: onOpenMap
                )
                .homeReadableBand(horizontalPadding: 10)
            }
            .padding(.top, 42)
            .padding(.bottom, 38)
        }
        .accessibilityLabel(title)
        .onAppear {
            LaunchDiagnostics.mark("map init start")
            LaunchDiagnostics.mark("map init end")
        }
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 31 : 26, weight: .semibold, design: .default))
                .foregroundStyle(.white)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text(subtitle)
                .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 18 : 15, weight: .regular, design: .default))
                .foregroundStyle(Color.white.opacity(0.70))
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct HomeRealisticNetherlandsMapSurface: View {
    let title: String
    let subtitle: String
    let openMapLabel: String
    let selectedCity: String
    let language: AppLanguage
    let glowPhase: Double
    let onOpenMap: () -> Void

    @State private var selectedProvinceID: String?
    @State private var tooltipProvinceID: String?
    @State private var selectedMode: PremiumMapDisplayMode = .cities
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
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
            .allowsHitTesting(false)

            RadialGradient(
                colors: [AppColors.cyanGlow.opacity(0.20), .clear],
                center: UnitPoint(x: 0.72, y: 0.24),
                startRadius: 0,
                endRadius: 290
            )
            .allowsHitTesting(false)

            RadialGradient(
                colors: [AppColors.dutchOrange.opacity(0.12), .clear],
                center: UnitPoint(x: 0.18, y: 0.86),
                startRadius: 0,
                endRadius: 260
            )
            .allowsHitTesting(false)

            GeometryReader { proxy in
                let mapRect = PremiumNetherlandsMapCanvas.mapRect(in: proxy.size)
                ZStack {
                    PremiumNetherlandsMapCanvas(
                        selectedProvinceID: selectedProvinceID,
                        selectedCity: selectedCity,
                        glowPhase: selectedProvinceID == nil ? glowPhase : 0.90,
                        displayMode: selectedMode
                    )
                    .padding(.top, 92)
                    .padding(.bottom, 78)
                    .allowsHitTesting(false)

                    if selectedMode == .provinces {
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
            }

            LinearGradient(
                colors: [
                    Color.black.opacity(0.12),
                    Color.clear,
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
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .padding(.bottom, 8)

                mapFilterRow
                    .padding(.horizontal, 18)

                Spacer(minLength: 0)

                ViewThatFits(in: .horizontal) {
                    mapFooter
                    VStack(alignment: .leading, spacing: 10) {
                        legendRow
                        openMapButton
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
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
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.20),
                            AppColors.cyanGlow.opacity(0.26),
                            AppColors.dutchOrange.opacity(0.12),
                            Color.white.opacity(0.07)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: AppColors.cyanGlow.opacity(0.14), radius: 28, x: 0, y: 18)
    }

    private func selectProvince(_ hit: ProvinceHitZone) {
        withAnimation(.easeInOut(duration: 0.18)) {
            selectedProvinceID = hit.id
            tooltipProvinceID = hit.id
        }

        let selectedID = hit.id
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            guard !Task.isCancelled else { return }
            if tooltipProvinceID == selectedID {
                withAnimation(.easeInOut(duration: 0.18)) {
                    tooltipProvinceID = nil
                }
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
                .font(.system(size: 25, weight: .heavy, design: .rounded))
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
            HStack(spacing: 8) {
                ForEach(PremiumMapDisplayMode.allCases) { mode in
                    mapModeButton(mode)
                }
            }
        }
    }

    private func mapModeButton(_ mode: PremiumMapDisplayMode) -> some View {
        let isSelected = selectedMode == mode
        let title = title(for: mode)
        let foreground = isSelected ? Color.white : Color.white.opacity(0.68)
        let background = isSelected ? AppColors.dutchOrange.opacity(0.92) : Color.white.opacity(0.075)
        let stroke = isSelected ? Color.white.opacity(0.18) : Color.white.opacity(0.10)
        let shadow = isSelected ? AppColors.dutchOrange.opacity(0.22) : Color.clear

        return Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                selectedMode = mode
                if mode != .provinces {
                    selectedProvinceID = nil
                    tooltipProvinceID = nil
                }
            }
        } label: {
            Text(title)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(foreground)
                .lineLimit(1)
                .minimumScaleFactor(0.80)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(background)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(stroke, lineWidth: 0.7))
                .shadow(color: shadow, radius: 10, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("home.map.mode.\(mode.rawValue)")
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

    private func title(for mode: PremiumMapDisplayMode) -> String {
        switch (mode, language) {
        case (.cities, .russian): return "Города"
        case (.cities, .dutch): return "Steden"
        case (.cities, .english): return "Cities"
        case (.provinces, .russian): return "Провинции"
        case (.provinces, .dutch): return "Provincies"
        case (.provinces, .english): return "Provinces"
        case (.services, .russian): return "Сервисы"
        case (.services, .dutch): return "Services"
        case (.services, .english): return "Services"
        }
    }
}

struct PremiumNetherlandsMapCanvas: View {
    let selectedProvinceID: String?
    let selectedCity: String
    let glowPhase: Double
    let displayMode: PremiumMapDisplayMode

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
                drawPremiumBase(in: &context, rect: rect)
                drawProvinceOverlay(in: &context, rect: rect)
                if displayMode == .provinces {
                    drawProvinceLabels(in: &context, rect: rect)
                }
                if displayMode == .services {
                    drawServiceNetwork(in: &context, rect: rect)
                }
                drawCities(in: &context, rect: rect)
            }
        }
        .allowsHitTesting(false)
    }

    private static var mapPadding: EdgeInsets {
        EdgeInsets(top: 12, leading: 30, bottom: 18, trailing: 30)
    }

    static func mapRect(in size: CGSize) -> CGRect {
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

    private func drawPremiumBase(in context: inout GraphicsContext, rect: CGRect) {
        let countryPath = RealProvinceMapData.countryPath(in: rect.size).offsetBy(dx: rect.minX, dy: rect.minY)

        var glowContext = context
        glowContext.addFilter(.blur(radius: 12))
        glowContext.stroke(countryPath, with: .color(AppColors.cyanGlow.opacity(0.18 + 0.08 * glowPhase)), lineWidth: 16)

        context.fill(
            countryPath,
            with: .linearGradient(
                Gradient(colors: [
                    Color(hex: "#173A4C").opacity(0.94),
                    Color(hex: "#102A3C").opacity(0.96),
                    Color(hex: "#0E2032").opacity(0.98)
                ]),
                startPoint: CGPoint(x: rect.midX, y: rect.minY),
                endPoint: CGPoint(x: rect.midX, y: rect.maxY)
            )
        )

        drawWaterBodies(in: &context, rect: rect)
        drawTravelArcs(in: &context, rect: rect)
    }

    private func drawWaterBodies(in context: inout GraphicsContext, rect: CGRect) {
        let ijsselmeer = RealProvinceMapData.path(points: [
            CGPoint(x: 0.36, y: 0.23),
            CGPoint(x: 0.48, y: 0.20),
            CGPoint(x: 0.58, y: 0.25),
            CGPoint(x: 0.59, y: 0.34),
            CGPoint(x: 0.51, y: 0.39),
            CGPoint(x: 0.40, y: 0.36)
        ], in: rect.size).offsetBy(dx: rect.minX, dy: rect.minY)
        context.fill(ijsselmeer, with: .color(Color(hex: "#08243A").opacity(0.82)))
        context.stroke(ijsselmeer, with: .color(AppColors.cyanGlow.opacity(0.22)), lineWidth: 0.7)

        let markermeer = RealProvinceMapData.path(points: [
            CGPoint(x: 0.36, y: 0.36),
            CGPoint(x: 0.46, y: 0.38),
            CGPoint(x: 0.50, y: 0.45),
            CGPoint(x: 0.44, y: 0.50),
            CGPoint(x: 0.36, y: 0.47),
            CGPoint(x: 0.34, y: 0.41)
        ], in: rect.size).offsetBy(dx: rect.minX, dy: rect.minY)
        context.fill(markermeer, with: .color(Color(hex: "#0A2B42").opacity(0.72)))
        context.stroke(markermeer, with: .color(AppColors.cyanGlow.opacity(0.16)), lineWidth: 0.55)
    }

    private func drawTravelArcs(in context: inout GraphicsContext, rect: CGRect) {
        let routes: [(CGPoint, CGPoint)] = [
            (point(0.355, 0.405, rect), point(0.285, 0.645, rect)),
            (point(0.355, 0.405, rect), point(0.485, 0.545, rect)),
            (point(0.485, 0.545, rect), point(0.570, 0.805, rect)),
            (point(0.485, 0.545, rect), point(0.730, 0.150, rect))
        ]

        for route in routes {
            var path = Path()
            path.move(to: route.0)
            let mid = CGPoint(x: (route.0.x + route.1.x) * 0.5, y: (route.0.y + route.1.y) * 0.5 - rect.height * 0.045)
            path.addQuadCurve(to: route.1, control: mid)
            context.stroke(
                path,
                with: .color(AppColors.cyanGlow.opacity(displayMode == .services ? 0.28 : 0.12)),
                style: StrokeStyle(lineWidth: displayMode == .services ? 1.05 : 0.65, lineCap: .round, dash: [4, 7])
            )
        }
    }

    private func drawProvinceOverlay(in context: inout GraphicsContext, rect: CGRect) {
        let countryPath = RealProvinceMapData.countryPath(in: rect.size).offsetBy(dx: rect.minX, dy: rect.minY)

        for province in RealProvinceMapData.provinces {
            let path = province.path(in: rect.size).offsetBy(dx: rect.minX, dy: rect.minY)
            let isSelected = selectedProvinceID == province.id
            let baseOpacity: Double = displayMode == .provinces ? 0.055 : 0.016
            context.fill(path, with: .color(isSelected ? AppColors.dutchOrange.opacity(0.20) : AppColors.softBlue.opacity(baseOpacity)))
            context.stroke(
                path,
                with: .color(isSelected ? AppColors.dutchOrange.opacity(0.72) : Color.white.opacity(displayMode == .provinces ? 0.18 : 0.070)),
                lineWidth: isSelected ? 1.8 : displayMode == .provinces ? 0.62 : 0.38
            )
        }

        context.stroke(countryPath, with: .color(Color.white.opacity(0.24)), lineWidth: 1.0)
        context.stroke(countryPath, with: .color(AppColors.cyanGlow.opacity(0.42)), lineWidth: 1.6)
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
        let markers = PremiumNetherlandsMapModel.markers(selectedCity: selectedCity, mode: displayMode)
        for city in markers {
            let center = point(city.normalizedPosition.x, city.normalizedPosition.y, rect)
            let isSelected = city.role == .activeCity
            let isService = city.role == .serviceHub
            let radius: CGFloat = isSelected ? 6.4 : isService ? 5.2 : 4.2
            let markerColor = isSelected ? AppColors.dutchOrange : isService ? AppColors.emerald : AppColors.cyanGlow

            context.fill(
                Path(ellipseIn: CGRect(x: center.x - radius * 2.5, y: center.y - radius * 2.5, width: radius * 5, height: radius * 5)),
                with: .radialGradient(
                    Gradient(colors: [markerColor.opacity(isSelected ? 0.42 : 0.22), .clear]),
                    center: center,
                    startRadius: 0,
                    endRadius: radius * 2.6
                )
            )
            context.fill(
                Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)),
                with: .color(markerColor)
            )
            context.stroke(
                Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)),
                with: .color(Color.white.opacity(isSelected ? 0.88 : 0.54)),
                lineWidth: isSelected ? 1.15 : 0.75
            )
            if isSelected {
                context.stroke(
                    Path(ellipseIn: CGRect(x: center.x - radius * 1.65, y: center.y - radius * 1.65, width: radius * 3.3, height: radius * 3.3)),
                    with: .color(AppColors.dutchOrange.opacity(0.26 + 0.18 * glowPhase)),
                    lineWidth: 1.1
                )
            }

            drawLabel(city.name, marker: city, selected: isSelected, in: &context, rect: rect)
        }
    }

    private func drawServiceNetwork(in context: inout GraphicsContext, rect: CGRect) {
        for service in PremiumNetherlandsMapModel.serviceMarkers {
            let center = point(service.normalizedPosition.x, service.normalizedPosition.y, rect)
            let ring = CGRect(x: center.x - 15, y: center.y - 15, width: 30, height: 30)
            context.stroke(Path(ellipseIn: ring), with: .color(AppColors.emerald.opacity(0.22)), lineWidth: 1.1)
        }
    }

    private func drawLabel(_ text: String, marker: PremiumMapCityMarker, selected: Bool, in context: inout GraphicsContext, rect: CGRect) {
        let labelPoint = point(marker.normalizedLabelPosition.x, marker.normalizedLabelPosition.y, rect)
        let labelWidth: CGFloat = selected ? 74 : 62
        let labelHeight: CGFloat = selected ? 19 : 16
        let labelRect = CGRect(x: labelPoint.x - labelWidth / 2, y: labelPoint.y - labelHeight / 2, width: labelWidth, height: labelHeight)

        context.fill(
            Path(roundedRect: labelRect, cornerRadius: labelHeight / 2),
            with: .color(Color(hex: "#06111F").opacity(selected ? 0.76 : 0.54))
        )
        context.stroke(
            Path(roundedRect: labelRect, cornerRadius: labelHeight / 2),
            with: .color((selected ? AppColors.dutchOrange : AppColors.cyanGlow).opacity(selected ? 0.34 : 0.16)),
            lineWidth: 0.55
        )
        context.draw(
            Text(text)
                .font(.system(size: selected ? 7.2 : 6.4, weight: selected ? .black : .bold, design: .rounded))
                .foregroundStyle(selected ? AppColors.dutchOrange.opacity(0.98) : Color.white.opacity(0.88)),
            at: labelPoint,
            anchor: .center
        )
    }

    private func p(_ x: CGFloat, _ y: CGFloat, _ rect: CGRect) -> CGPoint {
        point(x, y, rect)
    }

    private func point(_ x: CGFloat, _ y: CGFloat, _ rect: CGRect) -> CGPoint {
        CGPoint(x: rect.minX + x * rect.width, y: rect.minY + y * rect.height)
    }
}
