import SwiftUI

enum YouNewLogoVariant {
    case fullColor       // navy background + city skyline + orange route node
    case monochromeLight // no background - navy skyline (for light surfaces)
    case monochromeDark  // no background - white skyline (for dark surfaces)
}

// MARK: - YouNewLogoMark

/// YouNew.nl brand mark: a compact Dutch city silhouette with a route line.
///
/// Concept: stylized canal-house skyline + route node.
/// The simple stepped buildings make the mark read as a city at small size,
/// while the orange route line carries navigation and newcomer discovery.
struct YouNewLogoMark: View {
    var variant: YouNewLogoVariant = .fullColor

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let s = min(w, h)

            // Maps 1024-space coordinates used in the SVG source to canvas space.
            func p(_ svgX: CGFloat, _ svgY: CGFloat) -> CGPoint {
                CGPoint(x: svgX / 1024 * w, y: svgY / 1024 * h)
            }
            func r(_ svgR: CGFloat) -> CGFloat { svgR / 1024 * s }

            let fullRect = CGRect(origin: .zero, size: size)

            if variant == .fullColor {
                let corner = s * 0.221
                let bgPath = Path(roundedRect: fullRect, cornerRadius: corner)

                context.fill(bgPath, with: .linearGradient(
                    Gradient(colors: [
                        Color(red: 0.031, green: 0.227, blue: 0.451),
                        Color(red: 0.012, green: 0.055, blue: 0.165),
                    ]),
                    startPoint: CGPoint(x: w / 2, y: 0),
                    endPoint:   CGPoint(x: w / 2, y: h)
                ))

                let glowCtr = p(512, 360)
                let glowR   = r(390)
                var glowCtx = context
                glowCtx.clip(to: bgPath)
                glowCtx.fill(
                    Path(ellipseIn: CGRect(
                        x: glowCtr.x - glowR, y: glowCtr.y - glowR,
                        width: glowR * 2, height: glowR * 2
                    )),
                    with: .radialGradient(
                        Gradient(colors: [
                            Color(red: 0.055, green: 0.424, blue: 0.725).opacity(0.68),
                            Color(red: 0.055, green: 0.424, blue: 0.725).opacity(0.00),
                        ]),
                        center: glowCtr, startRadius: 0, endRadius: glowR
                    )
                )
            }

            let markColor: GraphicsContext.Shading
            switch variant {
            case .fullColor:       markColor = .color(.white)
            case .monochromeLight: markColor = .color(Color(red: 0.031, green: 0.227, blue: 0.451))
            case .monochromeDark:  markColor = .color(.white)
            }

            // Building 1 — narrow canal house, left
            var skyline = Path()
            skyline.move(to: p(208, 772))
            skyline.addLine(to: p(208, 540))
            skyline.addLine(to: p(276, 498))
            skyline.addLine(to: p(344, 540))
            skyline.addLine(to: p(344, 772))
            // Building 2 — the tallest, narrowest canal house (grachtenpand).
            // Width:height ≈ 1:4 echoes authentic Dutch canal-house proportions.
            // The high peak (y=278) dominates the skyline, giving the mark a clear
            // focal point that reads as a city landmark even at small sizes.
            skyline.move(to: p(382, 772))
            skyline.addLine(to: p(382, 416))
            skyline.addLine(to: p(444, 278))
            skyline.addLine(to: p(506, 416))
            skyline.addLine(to: p(506, 772))
            // Building 3 — medium canal house, shifted to preserve uniform gaps
            skyline.move(to: p(524, 772))
            skyline.addLine(to: p(524, 486))
            skyline.addLine(to: p(592, 444))
            skyline.addLine(to: p(660, 486))
            skyline.addLine(to: p(660, 772))
            // Building 4 — flat-topped modern building (Rotterdam contrast)
            skyline.move(to: p(678, 772))
            skyline.addLine(to: p(678, 566))
            skyline.addLine(to: p(766, 566))
            skyline.addLine(to: p(766, 772))
            context.stroke(
                skyline,
                with: markColor,
                style: StrokeStyle(lineWidth: r(52), lineCap: .round, lineJoin: .round)
            )

            // Windows — mid-height circle at the centre of each building
            var windows = Path()
            for x in [276, 444, 592, 722] {
                windows.addEllipse(in: CGRect(x: p(CGFloat(x), 626).x - r(14), y: p(CGFloat(x), 626).y - r(14), width: r(28), height: r(28)))
            }
            // Oculus window at B2 gable — characteristic circular topgevellicht
            // of Dutch canal-house upper facades. Adds depth at icon sizes.
            windows.addEllipse(in: CGRect(x: p(444, 366).x - r(22), y: p(444, 366).y - r(22), width: r(44), height: r(44)))
            context.fill(windows, with: variant == .fullColor ? .color(AppColors.cyanGlow.opacity(0.88)) : markColor)

            guard variant == .fullColor else { return }

            let orangeColor = Color(red: 1.0, green: 0.490, blue: 0.039)

            var pathLine = Path()
            pathLine.move(to: p(246, 842))
            pathLine.addCurve(to: p(500, 754), control1: p(332, 774), control2: p(420, 812))
            pathLine.addCurve(to: p(778, 842), control1: p(604, 678), control2: p(676, 820))
            context.stroke(
                pathLine,
                with: .color(orangeColor),
                style: StrokeStyle(lineWidth: r(44), lineCap: .round, lineJoin: .round)
            )

            let nodeR   = r(68)
            let nodeCtr = p(246, 842)
            let orangeGrad = Gradient(stops: [
                .init(color: Color(red: 1.0,   green: 0.863, blue: 0.224), location: 0.00),
                .init(color: Color(red: 1.0,   green: 0.490, blue: 0.039), location: 0.55),
                .init(color: Color(red: 0.749, green: 0.290, blue: 0.000), location: 1.00),
            ])
            let nodeBox = CGRect(x: nodeCtr.x - nodeR, y: nodeCtr.y - nodeR,
                                 width: nodeR * 2, height: nodeR * 2)
            context.fill(Path(ellipseIn: nodeBox),
                         with: .radialGradient(orangeGrad, center: nodeCtr,
                                               startRadius: 0, endRadius: nodeR))

            let hiR   = nodeR * 0.38
            let hiBox = CGRect(x: nodeCtr.x - hiR, y: nodeCtr.y - hiR,
                               width: hiR * 2, height: hiR * 2)
            context.fill(Path(ellipseIn: hiBox),
                         with: .color(Color(red: 1.0, green: 0.875, blue: 0.502).opacity(0.90)))

            let ringR = nodeR + r(20)
            let ringW = max(0.8, s * 0.004)
            context.stroke(
                Path(ellipseIn: CGRect(x: nodeCtr.x - ringR, y: nodeCtr.y - ringR,
                                       width: ringR * 2, height: ringR * 2)),
                with: .color(Color.white.opacity(0.52)),
                lineWidth: ringW
            )
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }
}

// MARK: - YouNewLogoWordmark

struct YouNewLogoWordmark: View {
    var variant: YouNewLogoVariant = .fullColor
    var markSize: CGFloat = 28

    var body: some View {
        HStack(spacing: 8) {
            YouNewLogoMark(variant: variant)
                .frame(width: markSize, height: markSize)

            HStack(spacing: 0) {
                Text("YouNew")
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(variant == .monochromeLight ? AppColors.navyDeep : AppColors.textPrimary)
                Text(".nl")
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(variant == .monochromeLight ? AppColors.navyDeep : AppColors.cyanGlow)
            }
            .lineLimit(1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("YouNew.nl")
    }
}

// MARK: - AppSymbolBadge

struct AppSymbolBadge: View {
    let symbol: String
    var color: Color = AppColors.cyanGlow
    var size: CGFloat = AppIcons.Metrics.actionContainer

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: min(size * 0.32, AppCornerRadius.medium), style: .continuous)
                .fill(color.opacity(0.13))
            RoundedRectangle(cornerRadius: min(size * 0.32, AppCornerRadius.medium), style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.30), color.opacity(0.28), AppColors.stroke.opacity(0.55)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.8
                )
            Image(systemName: symbol)
                .font(.system(size: min(size * 0.42, AppIcons.Metrics.large), weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(color)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}
