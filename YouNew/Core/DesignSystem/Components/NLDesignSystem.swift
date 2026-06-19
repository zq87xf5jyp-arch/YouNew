import SwiftUI

// MARK: - Glass Card

struct NLGlassCard<Content: View>: View {
    var padding: CGFloat = AppSpacing.cardPadding
    var cornerRadius: CGFloat = AppCornerRadius.large
    var fillColor: Color = AppColors.card
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(reduceTransparency ? fillColor : AppColors.glassSurface)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(fillColor.opacity(reduceTransparency ? 1.0 : 0.68))
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            RadialGradient(
                                colors: [AppColors.cyanGlow.opacity(0.10), .clear],
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: cornerRadius * 8
                            )
                        )
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(reduceTransparency ? 0.07 : 0.16),
                                    Color.white.opacity(0.035),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(reduceTransparency ? 0.22 : 0.34),
                                AppColors.cyanGlow.opacity(0.12),
                                AppColors.stroke.opacity(0.48)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            }
            .shadow(color: AppColors.cyanGlow.opacity(reduceTransparency ? 0.00 : 0.05), radius: 14, x: 0, y: 0)
            .shadow(color: Color.black.opacity(0.26), radius: 16, x: 0, y: 8)
    }
}

// MARK: - Gradient Card

struct NLGradientCard<Content: View>: View {
    let gradient: LinearGradient
    var cornerRadius: CGFloat = AppCornerRadius.large
    var padding: CGFloat = AppSpacing.cardPadding
    var glowColor: Color? = nil
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background {
                ZStack {
                    gradient
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.20),
                                    Color.clear,
                                    Color.black.opacity(0.14)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.30), Color.white.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.85
                    )
            }
            .shadow(
                color: glowColor?.opacity(reduceTransparency ? 0.16 : 0.26) ?? Color.black.opacity(0.22),
                radius: glowColor != nil ? 16 : 12,
                x: 0, y: glowColor != nil ? 9 : 6
            )
    }
}

// MARK: - Home Category Tile

struct NLCategoryTile: View {
    let title: String
    let icon: String
    let gradient: LinearGradient
    let destination: AppDestination
    var accessibilityIdentifier: String? = nil
    var tileHeight: CGFloat = 108
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        NavigationLink(value: destination) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    AppSymbolBadge(symbol: icon, color: AppColors.accentLight)
                        .shadow(color: AppColors.orangeGlow.opacity(0.12), radius: 12, x: 0, y: 0)
                        .shadow(color: Color.black.opacity(0.24), radius: 9, x: 0, y: 6)

                    Spacer(minLength: 8)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(AppColors.textTertiary)
                        .frame(width: 18, height: 18)
                }

                Text(title)
                    .font(.system(.footnote, design: .rounded).weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 4 : 3)
                    .minimumScaleFactor(0.90)
                    .allowsTightening(true)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(13)
            .frame(minHeight: adjustedTileHeight, alignment: .topLeading)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                        .fill(AppColors.glassSurfaceElevated)
                    GeneratedCategoryArtwork(symbol: icon, accent: AppColors.accentLight)
                        .opacity(0.24)
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
                    RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                        .fill(gradient.opacity(0.13))
                    RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                        .fill(
                            RadialGradient(
                                colors: [AppColors.cyanGlow.opacity(0.09), .clear],
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: 160
                            )
                        )
                    RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.17),
                                    Color.white.opacity(0.035),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
            .overlay {
                ZStack {
                    RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.30),
                                    AppColors.cyanGlow.opacity(0.12),
                                    AppColors.stroke.opacity(0.74)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.8
                        )
                }
            }
            .shadow(color: AppColors.cyanGlow.opacity(0.06), radius: 16, x: 0, y: 0)
            .shadow(color: Color.black.opacity(0.22), radius: 16, x: 0, y: 10)
        }
        .buttonStyle(NLTileButtonStyle())
        .accessibilityIdentifier(accessibilityIdentifier ?? "")
    }

    private var adjustedTileHeight: CGFloat {
        dynamicTypeSize.isAccessibilitySize ? max(tileHeight + 34, 146) : tileHeight
    }
}

// MARK: - Premium CTA Button

struct NLPremiumButton: View {
    let title: String
    var icon: String? = nil
    var gradient: LinearGradient = LinearGradient(
        colors: [AppColors.accent, AppColors.accentLight],
        startPoint: .leading, endPoint: .trailing
    )
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background {
                ZStack {
                    gradient
                        .opacity(isDisabled ? 0.38 : 1.0)
                    LinearGradient(
                        colors: [
                            Color.white.opacity(isDisabled ? 0.05 : 0.24),
                            Color.clear,
                            Color.black.opacity(isDisabled ? 0.04 : 0.10)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous))
            }
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous)
                    .stroke(Color.white.opacity(isDisabled ? 0.08 : 0.24), lineWidth: 0.75)
            }
            .shadow(
                color: isDisabled ? .clear : AppColors.cyanGlow.opacity(0.32),
                radius: 16, x: 0, y: 7
            )
            .shadow(
                color: isDisabled ? .clear : AppColors.dutchOrange.opacity(0.16),
                radius: 24, x: 0, y: 12
            )
        }
        .buttonStyle(AppPressableButtonStyle())
        .disabled(isDisabled)
        .animation(AppAnimations.standard, value: isDisabled)
    }
}

// MARK: - Badge / Chip

struct NLBadge: View {
    let text: String
    var icon: String? = nil
    var color: Color = AppColors.accent

    var body: some View {
        HStack(spacing: 4) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .semibold))
            }
            Text(text)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(0.14))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(color.opacity(0.25), lineWidth: 0.75))
    }
}

// MARK: - Section Header

struct NLSectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var actionTitle: String? = nil
    var destination: AppDestination? = nil

    var body: some View {
        if let actionTitle, let destination {
            HStack(alignment: .lastTextBaseline, spacing: AppSpacing.medium) {
                textStack
                Spacer(minLength: 12)
                NavigationLink(value: destination) {
                    actionLabel(actionTitle)
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .sectionPadding()
        } else {
            textStack
                .frame(maxWidth: .infinity, alignment: .leading)
                .sectionPadding()
        }
    }

    private var textStack: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(.title3, design: .rounded).weight(.bold))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(3)
                .minimumScaleFactor(0.86)
                .fixedSize(horizontal: false, vertical: true)

            if let subtitle {
                Text(subtitle)
                    .font(.system(.footnote, design: .rounded).weight(.medium))
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .layoutPriority(1)
    }

    private func actionLabel(_ title: String) -> some View {
        HStack(spacing: 3) {
            Text(title)
                .font(.system(.footnote, design: .rounded).weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.80)
            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .bold))
        }
        .foregroundStyle(AppColors.textPrimary)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(AppColors.cardElevated)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(AppColors.stroke.opacity(0.85), lineWidth: 0.75))
    }
}

// MARK: - Stat Tile

struct NLStatTile: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.78)
                .fixedSize(horizontal: false, vertical: true)
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.60))
                .lineLimit(2)
                .minimumScaleFactor(0.82)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.09))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.13), lineWidth: 0.75)
        )
    }
}

// MARK: - Alert Card

struct NLAlertCard: View {
    let icon: String
    let title: String
    let subtitle: String
    var color: Color = AppColors.dutchOrange
    var destination: AppDestination? = nil

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(color.opacity(0.16))
                    .frame(width: 46, height: 46)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Text(subtitle)
                    .font(.system(.footnote, design: .rounded).weight(.regular))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(AppColors.textTertiary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 78, alignment: .leading)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                    .fill(AppColors.cardElevated)
                RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                    .fill(color.opacity(0.045))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [color.opacity(0.30), AppColors.stroke.opacity(0.75)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.8
                )
        )
        .shadow(color: Color.black.opacity(0.12), radius: 14, x: 0, y: 8)
    }
}

// MARK: - Nearby Pill

struct NLNearbyPill: View {
    let icon: String
    let title: String
    let destination: AppDestination
    var color: Color = AppColors.accent

    var body: some View {
        NavigationLink(value: destination) {
            VStack(spacing: 7) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.14))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(color)
                }
                Text(title)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 6)
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(AppColors.stroke, lineWidth: 0.75)
            )
            .shadow(color: color.opacity(0.10), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(NLTileButtonStyle())
    }
}

// MARK: - Ambient Background Wash

struct NLAmbientOrbs: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    AppColors.accent.opacity(reduceTransparency ? 0.06 : 0.12),
                    Color.clear,
                    AppColors.dutchOrange.opacity(reduceTransparency ? 0.035 : 0.07)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.045), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Tile Button Style

struct NLTileButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(!reduceMotion && configuration.isPressed ? 0.975 : 1.0)
            .opacity(!isEnabled ? 0.58 : (configuration.isPressed ? 0.92 : 1.0))
            .brightness(configuration.isPressed ? -0.02 : 0)
            .animation(reduceMotion ? nil : AppAnimations.tactilePress, value: configuration.isPressed)
    }
}

// MARK: - Glow View Modifier

struct NLGlowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.55), radius: radius * 0.5, x: 0, y: 0)
            .shadow(color: color.opacity(0.25), radius: radius, x: 0, y: 0)
    }
}

extension View {
    @ViewBuilder
    func nlNavigationInline() -> some View {
#if os(iOS)
        self.navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppSurface.base.opacity(0.94), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
#else
        self
#endif
    }

    @ViewBuilder
    func nlNavigationBarHidden() -> some View {
#if os(iOS)
        self.toolbar(.hidden, for: .navigationBar)
#else
        self
#endif
    }

    @ViewBuilder
    func nlFullScreenCover<CoverContent: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> CoverContent
    ) -> some View {
#if os(iOS)
        self.fullScreenCover(isPresented: isPresented, content: content)
#else
        self.sheet(isPresented: isPresented, content: content)
#endif
    }

    @ViewBuilder
    func nlTextInputAutocapitalizationWords() -> some View {
#if os(iOS)
        self.textInputAutocapitalization(.words)
#else
        self
#endif
    }

    @ViewBuilder
    func nlTextInputAutocapitalizationNever() -> some View {
#if os(iOS)
        self.textInputAutocapitalization(.never)
#else
        self
#endif
    }

    @ViewBuilder
    func nlScrollDismissesKeyboardInteractively() -> some View {
#if os(iOS)
        self.scrollDismissesKeyboard(.interactively)
#else
        self
#endif
    }

    @ViewBuilder
    func nlScrollDismissesKeyboardImmediately() -> some View {
#if os(iOS)
        self.scrollDismissesKeyboard(.immediately)
#else
        self
#endif
    }

    func nlGlow(color: Color, radius: CGFloat = 14) -> some View {
        modifier(NLGlowModifier(color: color, radius: radius))
    }

    func nlCard(cornerRadius: CGFloat = AppCornerRadius.large) -> some View {
        self
            .padding(AppSpacing.cardPadding)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(AppColors.glassSurface)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(AppColors.card.opacity(0.58))
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            RadialGradient(
                                colors: [AppColors.orangeGlow.opacity(0.055), .clear],
                                center: .topTrailing,
                                startRadius: 0,
                                endRadius: cornerRadius * 9
                            )
                        )
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.14), Color.white.opacity(0.025), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.30), AppColors.stroke.opacity(0.55)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.75
                    )
            }
            .shadow(color: AppColors.cyanGlow.opacity(0.06), radius: 18, x: 0, y: 0)
            .shadow(color: Color.black.opacity(0.32), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Responsive Content Container

/// Centers and width-constrains content on wide screens (iPad, macOS, landscape).
/// On compact width the content fills available width normally.
struct ResponsiveContentContainer<Content: View>: View {
    var maxWidth: CGFloat
    let content: Content
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    init(maxWidth: CGFloat = 920, @ViewBuilder content: () -> Content) {
        self.maxWidth = maxWidth
        self.content = content()
    }

    var body: some View {
        if horizontalSizeClass == .compact {
            content
                .frame(maxWidth: .infinity, alignment: .center)
        } else {
            content
                .frame(maxWidth: maxWidth)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

enum PlaceResponsiveLayout {
    static let compactTwoColumnThreshold: CGFloat = 340

    static func availableWidth(viewportWidth: CGFloat, horizontalPadding: CGFloat = AppSpacing.screenHorizontal) -> CGFloat {
        max(0, viewportWidth - horizontalPadding * 2)
    }

    static func twoColumnCardWidth(availableWidth: CGFloat, gap: CGFloat = AppSpacing.small) -> CGFloat {
        guard availableWidth >= compactTwoColumnThreshold else {
            return availableWidth
        }
        return max(0, (availableWidth - gap) / 2)
    }

    static func shouldUseTwoColumns(availableWidth: CGFloat) -> Bool {
        availableWidth >= compactTwoColumnThreshold
    }
}

// MARK: - TypewriterText

/// Animates text character-by-character on appear, like a typewriter.
struct TypewriterText: View {
    let fullText: String
    var speed: TimeInterval = 0.045
    @State private var displayed = ""

    var body: some View {
        Text(displayed)
            .task(id: fullText) {
                displayed = ""
                for char in fullText {
                    try? await Task.sleep(for: .seconds(speed))
                    displayed += String(char)
                }
            }
    }
}

// MARK: - CountingNumber

/// Animates a numeric value counting up from 0 on appear.
struct CountingNumber: View {
    let target: Double
    var suffix: String = ""
    var duration: Double = 1.2
    @State private var current: Double = 0

    var body: some View {
        Text("\(Int(current))\(suffix)")
            .contentTransition(.numericText())
            .onAppear {
                withAnimation(.easeOut(duration: duration)) {
                    current = target
                }
            }
    }
}

// MARK: - TiltCard

/// Lightweight compatibility wrapper for old tilt calls.
struct TiltCard: ViewModifier {
    func body(content: Content) -> some View {
        content
    }
}

extension View {
    func tiltCard() -> some View {
        modifier(TiltCard())
    }
}

// MARK: - GradientFadeDivider

/// A horizontal fade-in / fade-out divider — more premium than Divider().
struct GradientFadeDivider: View {
    var color: Color = AppSurface.b1
    var horizontalPadding: CGFloat = 40
    var verticalPadding: CGFloat = 20

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.clear, color, .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 0.5)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
    }
}

// MARK: - MagneticEffect

/// Lightweight compatibility wrapper for old magnetic CTA calls.
struct MagneticEffect: ViewModifier {
    func body(content: Content) -> some View {
        content
    }
}

extension View {
    func magneticEffect() -> some View {
        modifier(MagneticEffect())
    }
}

// MARK: - ParallaxHero

/// Wraps a view so it scrolls at ~0.58× speed, creating depth behind the foreground.
/// Requires the enclosing ScrollView to carry `.coordinateSpace(name: "masterScroll")`.
struct ParallaxHero<Content: View>: View {
    @ViewBuilder let content: () -> Content
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { geo in
            let scrollY = geo.frame(in: .named("masterScroll")).minY
            // When scrolled down (scrollY < 0), counteract motion so image lags behind.
            // When overscrolling (scrollY > 0), subtly scale up from bottom for depth.
            let parallaxOffset: CGFloat = reduceMotion ? 0 : -scrollY * 0.42
            let scaleValue: CGFloat = (reduceMotion || scrollY <= 0) ? 1 : 1 + scrollY / 900

            content()
                .frame(width: geo.size.width, height: geo.size.height)
                .offset(y: parallaxOffset)
                .scaleEffect(scaleValue, anchor: .bottom)
        }
    }
}

// MARK: - CardGlowingTopEdge

/// Adds a glowing horizontal gradient line along the top edge of a card.
struct CardGlowingTopEdge: ViewModifier {
    var color: Color = AppSurface.accentWarm
    var cornerRadius: CGFloat = AppCornerRadius.large

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                LinearGradient(
                    colors: [.clear, color.opacity(0.80), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 1.5)
                .clipShape(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .inset(by: 0.75)
                )
            }
    }
}

extension View {
    func cardGlowingTopEdge(color: Color = AppSurface.accentWarm, cornerRadius: CGFloat = AppCornerRadius.large) -> some View {
        modifier(CardGlowingTopEdge(color: color, cornerRadius: cornerRadius))
    }
}
