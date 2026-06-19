import SwiftUI

enum YouNewScreenBackgroundStyle: String, CaseIterable, Identifiable {
    case home
    case map
    case province
    case city
    case search
    case saved
    case assistant
    case more
    case settings
    case documents
    case fines
    case onboarding
    case support
    case general

    var id: String { rawValue }

    var accent: Color {
        switch self {
        case .home: return AppColors.cyanGlow
        case .map: return AppColors.routeLine
        case .province: return AppColors.dutchOrange
        case .city: return AppColors.softBlue
        case .search: return AppColors.emerald
        case .saved: return AppColors.warning
        case .assistant: return AppColors.violet
        case .more: return AppColors.cyanGlow
        case .settings: return AppColors.softBlue
        case .documents: return AppColors.accent
        case .fines: return AppColors.error
        case .onboarding: return AppColors.dutchOrange
        case .support: return AppColors.emerald
        case .general: return AppColors.accent
        }
    }

    var secondaryAccent: Color {
        switch self {
        case .home, .onboarding: return AppColors.dutchOrange
        case .map, .city: return AppColors.emerald
        case .province, .fines: return AppColors.cyanGlow
        case .search, .saved: return AppColors.softBlue
        case .assistant: return AppColors.cyanGlow
        case .more, .settings, .documents, .support, .general: return AppColors.violet
        }
    }
}

struct GlobalBackgroundView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            DutchFutureBaseLayer(colorScheme: colorScheme)
            AppAmbientMotionLayer(
                reduceMotion: reduceMotion,
                reduceTransparency: reduceTransparency
            )
            DutchFutureAtmosphereLayer(isReduced: reduceTransparency)
            DutchFutureGridLayer(isReduced: reduceTransparency)
            DutchFutureShapeLayer(isReduced: reduceTransparency)
            DutchFutureVignetteLayer()

            if !reduceTransparency {
                DutchFutureGrainLayer()
                    .opacity(0.20)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct AppAmbientMotionLayer: View {
    let reduceMotion: Bool
    let reduceTransparency: Bool

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
                let drift = CGFloat(sin(time / 7.0)) * (reduceMotion ? 0 : 18)
                let pulse = reduceTransparency ? 0.020 : 0.040 + 0.012 * sin(time / 5.5)

                drawAura(
                    &context,
                    size: size,
                    center: CGPoint(x: size.width * 0.18 + drift, y: size.height * 0.20),
                    radius: max(size.width, size.height) * 0.46,
                    color: AppColors.cyanGlow.opacity(pulse)
                )

                drawAura(
                    &context,
                    size: size,
                    center: CGPoint(x: size.width * 0.86 - drift * 0.55, y: size.height * 0.76),
                    radius: max(size.width, size.height) * 0.52,
                    color: AppColors.dutchOrange.opacity(reduceTransparency ? 0.012 : 0.026)
                )
            }
        }
        .opacity(reduceTransparency ? 0.42 : 1.0)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func drawAura(
        _ context: inout GraphicsContext,
        size: CGSize,
        center: CGPoint,
        radius: CGFloat,
        color: Color
    ) {
        let rect = CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
        )

        context.addFilter(.blur(radius: reduceTransparency ? 30 : 72))
        context.fill(Path(ellipseIn: rect), with: .color(color))
    }
}

private struct DutchFutureBaseLayer: View {
    let colorScheme: ColorScheme

    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 3 / 255, green: 7 / 255, blue: 17 / 255),
                AppSurface.base,
                Color(red: 6 / 255, green: 18 / 255, blue: 34 / 255),
                Color(red: 3 / 255, green: 8 / 255, blue: 18 / 255)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            LinearGradient(
                colors: [
                    Color.white.opacity(colorScheme == .dark ? 0.028 : 0.045),
                    Color.clear,
                    Color.black.opacity(colorScheme == .dark ? 0.34 : 0.10)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

private struct DutchFutureAtmosphereLayer: View {
    let isReduced: Bool

    var body: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: AppColors.cyanGlow.opacity(isReduced ? 0.030 : 0.072), location: 0.00),
                    .init(color: Color.clear, location: 0.34),
                    .init(color: AppColors.dutchOrange.opacity(isReduced ? 0.018 : 0.050), location: 0.78),
                    .init(color: Color.clear, location: 1.00)
                ],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )

            LinearGradient(
                stops: [
                    .init(color: AppColors.dutchRed.opacity(isReduced ? 0.012 : 0.026), location: 0.00),
                    .init(color: Color.white.opacity(isReduced ? 0.004 : 0.012), location: 0.46),
                    .init(color: Color(red: 33 / 255, green: 70 / 255, blue: 139 / 255).opacity(isReduced ? 0.020 : 0.045), location: 1.00)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .opacity(0.72)
        }
    }
}

private struct DutchFutureGridLayer: View {
    let isReduced: Bool

    var body: some View {
        Canvas { context, size in
            drawGrid(&context, size: size)
            drawRoutes(&context, size: size)
            drawNodes(&context, size: size)
        }
        .opacity(isReduced ? 0.36 : 0.58)
    }

    private func drawGrid(_ context: inout GraphicsContext, size: CGSize) {
        let spacing: CGFloat = 58
        var grid = Path()

        var x: CGFloat = -spacing * 2
        while x < size.width + spacing * 2 {
            grid.move(to: CGPoint(x: x, y: -30))
            grid.addLine(to: CGPoint(x: x + size.height * 0.13, y: size.height + 30))
            x += spacing
        }

        var y: CGFloat = 30
        while y < size.height + spacing {
            grid.move(to: CGPoint(x: -30, y: y))
            grid.addLine(to: CGPoint(x: size.width + 30, y: y - size.width * 0.055))
            y += spacing
        }

        context.stroke(grid, with: .color(Color.white.opacity(0.030)), lineWidth: 0.7)
    }

    private func drawRoutes(_ context: inout GraphicsContext, size: CGSize) {
        for index in 0..<5 {
            let progress = CGFloat(index) / 4
            let y = size.height * (0.18 + progress * 0.68)
            var route = Path()
            route.move(to: CGPoint(x: -size.width * 0.08, y: y))
            route.addCurve(
                to: CGPoint(x: size.width * 1.08, y: y + (index.isMultiple(of: 2) ? 22 : -18)),
                control1: CGPoint(x: size.width * 0.22, y: y - 38),
                control2: CGPoint(x: size.width * 0.68, y: y + 34)
            )

            let color = index.isMultiple(of: 2) ? AppColors.cyanGlow : AppColors.dutchOrange
            context.stroke(
                route,
                with: .color(color.opacity(index == 2 ? 0.074 : 0.050)),
                style: StrokeStyle(lineWidth: index == 2 ? 1.15 : 0.85, lineCap: .round, dash: [10, 16])
            )
        }
    }

    private func drawNodes(_ context: inout GraphicsContext, size: CGSize) {
        let points = [
            CGPoint(x: size.width * 0.18, y: size.height * 0.22),
            CGPoint(x: size.width * 0.66, y: size.height * 0.31),
            CGPoint(x: size.width * 0.42, y: size.height * 0.62),
            CGPoint(x: size.width * 0.82, y: size.height * 0.76)
        ]

        for (index, point) in points.enumerated() {
            let color = index.isMultiple(of: 2) ? AppColors.cyanGlow : AppColors.dutchOrange
            context.fill(
                Path(ellipseIn: CGRect(x: point.x - 2.2, y: point.y - 2.2, width: 4.4, height: 4.4)),
                with: .color(color.opacity(0.20))
            )
        }
    }
}

private struct DutchFutureShapeLayer: View {
    let isReduced: Bool

    var body: some View {
        Canvas { context, size in
            context.addFilter(.blur(radius: isReduced ? 34 : 58))
            drawDeltaShape(&context, size: size, position: .topTrailing, color: AppColors.cyanGlow.opacity(isReduced ? 0.028 : 0.055))
            drawDeltaShape(&context, size: size, position: .bottomLeading, color: AppColors.dutchOrange.opacity(isReduced ? 0.020 : 0.040))
        }
    }

    private enum Position {
        case topTrailing
        case bottomLeading
    }

    private func drawDeltaShape(_ context: inout GraphicsContext, size: CGSize, position: Position, color: Color) {
        var shape = Path()

        switch position {
        case .topTrailing:
            shape.move(to: CGPoint(x: size.width * 0.42, y: -size.height * 0.10))
            shape.addCurve(
                to: CGPoint(x: size.width * 1.16, y: size.height * 0.40),
                control1: CGPoint(x: size.width * 0.74, y: size.height * 0.02),
                control2: CGPoint(x: size.width * 1.02, y: size.height * 0.05)
            )
            shape.addCurve(
                to: CGPoint(x: size.width * 0.72, y: size.height * 0.54),
                control1: CGPoint(x: size.width * 0.98, y: size.height * 0.54),
                control2: CGPoint(x: size.width * 0.80, y: size.height * 0.45)
            )
            shape.addCurve(
                to: CGPoint(x: size.width * 0.42, y: -size.height * 0.10),
                control1: CGPoint(x: size.width * 0.58, y: size.height * 0.30),
                control2: CGPoint(x: size.width * 0.34, y: size.height * 0.12)
            )
        case .bottomLeading:
            shape.move(to: CGPoint(x: -size.width * 0.18, y: size.height * 0.62))
            shape.addCurve(
                to: CGPoint(x: size.width * 0.55, y: size.height * 1.14),
                control1: CGPoint(x: size.width * 0.08, y: size.height * 0.84),
                control2: CGPoint(x: size.width * 0.26, y: size.height * 1.06)
            )
            shape.addCurve(
                to: CGPoint(x: size.width * 0.66, y: size.height * 0.78),
                control1: CGPoint(x: size.width * 0.62, y: size.height * 1.00),
                control2: CGPoint(x: size.width * 0.58, y: size.height * 0.86)
            )
            shape.addCurve(
                to: CGPoint(x: -size.width * 0.18, y: size.height * 0.62),
                control1: CGPoint(x: size.width * 0.34, y: size.height * 0.72),
                control2: CGPoint(x: size.width * 0.10, y: size.height * 0.56)
            )
        }

        shape.closeSubpath()
        context.fill(shape, with: .color(color))
    }
}

private struct DutchFutureVignetteLayer: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color.black.opacity(0.20),
                Color.clear,
                Color.black.opacity(0.36)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

private struct DutchFutureGrainLayer: View {
    var body: some View {
        Canvas { context, size in
            let count = max(240, Int(size.width * size.height / 190))
            for index in 0..<count {
                let xSeed = (index * 73) % 997
                let ySeed = (index * 151) % 991
                let x = CGFloat(xSeed) / 997 * size.width
                let y = CGFloat(ySeed) / 991 * size.height
                let opacity = 0.012 + Double((index * 37) % 9) * 0.0014
                context.fill(
                    Path(CGRect(x: x, y: y, width: 1, height: 1)),
                    with: .color(Color.white.opacity(opacity))
                )
            }
        }
    }
}

struct AppAtmosphereBackground: View {
    var body: some View {
        GlobalBackgroundView()
    }
}

struct AppBackground: View {
    var style: YouNewScreenBackgroundStyle = .general

    var body: some View {
        GlobalBackgroundView()
    }
}

struct CityMapBackground: View {
    var accent: Color = AppColors.cyanGlow

    var body: some View {
        ZStack {
            GlobalBackgroundView()
            RouteLineBackground(accent: accent)
                .opacity(0.72)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct RouteLineBackground: View {
    var accent: Color = AppColors.cyanGlow

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        Canvas { context, size in
            drawRouteMesh(&context, size: size)
        }
        .opacity(reduceTransparency ? 0.28 : 0.52)
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func drawRouteMesh(_ context: inout GraphicsContext, size: CGSize) {
        let routes: [(CGFloat, CGFloat, CGFloat)] = [
            (0.12, 0.20, -0.08),
            (0.28, 0.58, 0.10),
            (0.48, 0.32, -0.12),
            (0.66, 0.72, 0.08)
        ]

        for (index, route) in routes.enumerated() {
            var path = Path()
            let start = CGPoint(x: -size.width * 0.08, y: size.height * route.0)
            let end = CGPoint(x: size.width * 1.08, y: size.height * route.1)
            path.move(to: start)
            path.addCurve(
                to: end,
                control1: CGPoint(x: size.width * 0.32, y: size.height * (route.0 + route.2)),
                control2: CGPoint(x: size.width * 0.68, y: size.height * (route.1 - route.2))
            )

            let color = index.isMultiple(of: 2) ? accent : AppColors.dutchOrange
            context.stroke(
                path,
                with: .color(color.opacity(index.isMultiple(of: 2) ? 0.12 : 0.075)),
                style: StrokeStyle(lineWidth: index == 1 ? 1.35 : 1.0, lineCap: .round, dash: [12, 18])
            )
        }
    }
}

struct NetherlandsBackground: View {
    var body: some View {
        GlobalBackgroundView()
    }
}

struct YouNewScreenBackground: View {
    let style: YouNewScreenBackgroundStyle

    var body: some View {
        GlobalBackgroundView()
    }
}

struct GlassPanelBackground: View {
    var accent: Color = AppColors.cyanGlow
    var cornerRadius: CGFloat = 34

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color.white.opacity(0.10))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppMaterials.glass)
                    .opacity(0.30)
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        RadialGradient(
                            colors: [accent.opacity(0.18), .clear],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 260
                        )
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            }
    }
}

struct PhotoHeroBackground: View {
    let asset: AppImageAsset?
    let language: AppLanguage
    var accent: Color = AppColors.cyanGlow
    var cornerRadius: CGFloat = AppCornerRadius.hero

    var body: some View {
        ZStack {
            AppContentImageView(
                asset: asset,
                language: language,
                mode: .fill,
                accent: accent,
                aspectRatio: nil,
                cornerRadius: 0,
                showsCaption: false
            )

            LinearGradient(
                colors: [
                    AppColors.navyDeep.opacity(0.32),
                    AppColors.navyDeep.opacity(0.52),
                    AppColors.navyDeep.opacity(0.90)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .accessibilityHidden(true)
    }
}

// MARK: - NoiseTextureOverlay

/// Ultra-subtle grain canvas — adds tactile depth without obscuring content.
/// Drawn once with a fixed seed for zero per-frame CPU cost.
struct NoiseTextureOverlay: View {
    var body: some View {
        Canvas { ctx, size in
            let count = Int(size.width * size.height / 8)
            var rng = SystemRandomNumberGenerator()
            for _ in 0..<count {
                let x = CGFloat(rng.next() % UInt64(max(1, Int(size.width))))
                let y = CGFloat(rng.next() % UInt64(max(1, Int(size.height))))
                let opacity = Double(rng.next() % 100) / 100.0 * 0.016 + 0.008
                ctx.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: 1, height: 1)),
                    with: .color(.white.opacity(opacity))
                )
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
