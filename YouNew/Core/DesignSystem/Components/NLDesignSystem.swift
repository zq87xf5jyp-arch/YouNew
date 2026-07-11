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

// MARK: - Premium Visual System

enum PremiumVisualMetrics {
    enum Layout {
        static let maxContentWidth: CGFloat = 920
        static let readableContentWidth: CGFloat = 760
        static let horizontalPadding: CGFloat = AppSpacing.screenHorizontal
        static let sectionSpacing: CGFloat = AppSpacing.large
        static let compactSectionSpacing: CGFloat = AppSpacing.medium
        static let bottomTerminalGap: CGFloat = 20
    }

    enum Card {
        static let cornerRadius: CGFloat = 20
        static let compactCornerRadius: CGFloat = 16
        static let padding: CGFloat = AppSpacing.cardPadding
        static let compactPadding: CGFloat = AppSpacing.cardPaddingCompact
        static let borderWidth: CGFloat = 0.8
        static let minSearchResultHeight: CGFloat = 314
        static let directResultMinHeight: CGFloat = 148
    }

    enum Image {
        static let searchHeaderHeight: CGFloat = 142
        static let searchDirectSize: CGFloat = 124
        static let carouselThumbnailHeight: CGFloat = 94
        static let cardAspectRatio: CGFloat = 16.0 / 10.0
        static let heroTargetPixelWidth: CGFloat = 1400
        static let cardTargetPixelWidth: CGFloat = 1000
        static let thumbnailTargetPixelWidth: CGFloat = 680
    }

    enum Hero {
        static let minViewportFraction: CGFloat = 0.25
        static let maxViewportFraction: CGFloat = 0.35
        static let compactHeight: CGFloat = 220
        static let regularHeight: CGFloat = 312
        static let maxHeight: CGFloat = 356

        static func height(for viewportHeight: CGFloat) -> CGFloat {
            let target = viewportHeight * 0.30
            return min(max(target, compactHeight), maxHeight)
        }
    }

    enum Grid {
        static let spacing: CGFloat = AppSpacing.gridGap
        static let minimumCardWidth: CGFloat = 156
        static let regularMinimumCardWidth: CGFloat = 220

        static func adaptiveColumns(minimum: CGFloat = minimumCardWidth) -> [GridItem] {
            [GridItem(.adaptive(minimum: minimum), spacing: spacing)]
        }

        static func twoColumnsWhenPossible(contentWidth: CGFloat, minimum: CGFloat = minimumCardWidth) -> [GridItem] {
            DetailPageLayout.twoColumnWhenPossible(for: contentWidth, minimumColumnWidth: minimum)
        }
    }

    enum Carousel {
        static let spacing: CGFloat = AppSpacing.small
        static let maxCardWidth: CGFloat = 320

        static func cardWidth(availableWidth: CGFloat) -> CGFloat {
            min(max(availableWidth * 0.72, 220), maxCardWidth)
        }
    }
}

enum PremiumImageRole {
    case hero
    case card
    case thumbnail
    case symbol
    case fallback

    var defaultAspectRatio: CGFloat? {
        switch self {
        case .hero, .card:
            return PremiumVisualMetrics.Image.cardAspectRatio
        case .thumbnail:
            return 1
        case .symbol, .fallback:
            return nil
        }
    }

    var defaultTargetPixelWidth: CGFloat {
        switch self {
        case .hero:
            return PremiumVisualMetrics.Image.heroTargetPixelWidth
        case .card:
            return PremiumVisualMetrics.Image.cardTargetPixelWidth
        case .thumbnail, .symbol, .fallback:
            return PremiumVisualMetrics.Image.thumbnailTargetPixelWidth
        }
    }
}

enum PremiumImageFocalPoint {
    case center
    case top
    case bottom
    case leading
    case trailing
    case topLeading
    case topTrailing
    case bottomLeading
    case bottomTrailing

    var alignment: Alignment {
        switch self {
        case .center: return .center
        case .top: return .top
        case .bottom: return .bottom
        case .leading: return .leading
        case .trailing: return .trailing
        case .topLeading: return .topLeading
        case .topTrailing: return .topTrailing
        case .bottomLeading: return .bottomLeading
        case .bottomTrailing: return .bottomTrailing
        }
    }
}

enum PremiumImageOverlayPolicy {
    case none
    case adaptive
    case light
    case balanced
    case strong

    func gradient(role: PremiumImageRole, asset: AppImageAsset?) -> LinearGradient? {
        switch self {
        case .none:
            return nil
        case .light:
            return Self.lightGradient
        case .balanced:
            return Self.balancedGradient
        case .strong:
            return Self.strongGradient
        case .adaptive:
            if role == .hero {
                return prefersStrongOverlay(asset: asset) ? Self.readableGradient : Self.lightGradient
            }
            return Self.cardGradient
        }
    }

    private func prefersStrongOverlay(asset: AppImageAsset?) -> Bool {
        let text = [
            asset?.title,
            asset?.description,
            asset?.localAssetName,
            asset?.id
        ]
        .compactMap { $0?.lowercased() }
        .joined(separator: " ")
        return text.contains("map")
            || text.contains("pharmacy")
            || text.contains("city hall")
            || text.contains("station")
            || text.contains("day")
    }

    private static let lightGradient = LinearGradient(
        colors: [
            Color.black.opacity(0.00),
            Color.black.opacity(0.06),
            AppColors.navyDeep.opacity(0.24)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    private static let readableGradient = LinearGradient(
        colors: [
            Color.black.opacity(0.02),
            AppColors.navyDeep.opacity(0.18),
            AppColors.navyDeep.opacity(0.44)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    private static let cardGradient = LinearGradient(
        colors: [
            Color.black.opacity(0.02),
            AppColors.navyDeep.opacity(0.16),
            AppColors.navyDeep.opacity(0.40)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    private static let balancedGradient = LinearGradient(
        colors: [
            Color.black.opacity(0.02),
            AppColors.navyDeep.opacity(0.16),
            AppColors.navyDeep.opacity(0.40)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    private static let strongGradient = LinearGradient(
        colors: [
            Color.black.opacity(0.08),
            AppColors.navyDeep.opacity(0.30),
            AppColors.navyDeep.opacity(0.58)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

struct PremiumPageContainer<Content: View>: View {
    var maxWidth: CGFloat = PremiumVisualMetrics.Layout.maxContentWidth
    var horizontalPadding: CGFloat = PremiumVisualMetrics.Layout.horizontalPadding
    var verticalPadding: CGFloat = AppSpacing.medium
    @ViewBuilder let content: () -> Content

    var body: some View {
        ResponsiveContentContainer(maxWidth: maxWidth) {
            content()
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
        }
    }
}

struct PremiumHeroSurface<Content: View>: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let title: String
    let subtitle: String
    let badge: String?
    let badgeSystemImage: String
    let asset: AppImageAsset?
    let language: AppLanguage
    var role: PremiumImageRole = .hero
    var fallbackCategory: PremiumImageFallbackCategory = .city
    var accent: Color = AppColors.cyanGlow
    var focalPoint: PremiumImageFocalPoint = .center
    var overlayPolicy: PremiumImageOverlayPolicy = .adaptive
    var height: CGFloat = PremiumVisualMetrics.Hero.regularHeight
    var accessibilityIdentifier: String? = nil
    @ViewBuilder let accessory: () -> Content

    var body: some View {
        GeometryReader { proxy in
            let horizontalTextInset = dynamicTypeSize.isAccessibilitySize ? PremiumVisualMetrics.Card.padding : PremiumVisualMetrics.Card.padding + 52
            let verticalTextInset = PremiumVisualMetrics.Card.padding
            let textMaxWidth = max(180, proxy.size.width - horizontalTextInset * 2)
            ZStack(alignment: .bottomLeading) {
                PremiumImageView(
                    asset: asset,
                    language: language,
                    height: proxy.size.height,
                    aspectRatio: nil,
                    mode: .fill,
                    cornerRadius: 0,
                    overlayStyle: .none,
                    fallbackCategory: fallbackCategory,
                    accessibilityLabel: title,
                    targetPixelWidth: role.defaultTargetPixelWidth,
                    role: role,
                    overlayPolicy: .none,
                    focalPoint: focalPoint
                )
                .accessibilityHidden(true)

                if let gradient = overlayPolicy.gradient(role: role, asset: asset) {
                    gradient.allowsHitTesting(false)
                }

                RadialGradient(
                    colors: [accent.opacity(0.24), .clear],
                    center: .topTrailing,
                    startRadius: 0,
                    endRadius: 240
                )
                .allowsHitTesting(false)

                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    if let badge {
                        PremiumBadge(text: badge, systemImage: badgeSystemImage, color: AppColors.success)
                    }

                    Text(title)
                        .font(dynamicTypeSize.isAccessibilitySize ? .system(size: 42, weight: .black, design: .rounded) : AppTypography.title)
                        .foregroundStyle(.white)
                        .lineLimit(dynamicTypeSize.isAccessibilitySize ? 4 : 3)
                        .minimumScaleFactor(dynamicTypeSize.isAccessibilitySize ? 0.78 : 0.68)
                        .allowsTightening(true)
                        .multilineTextAlignment(.leading)
                        .frame(width: textMaxWidth, alignment: .leading)

                    Text(subtitle)
                        .font(dynamicTypeSize.isAccessibilitySize ? .system(size: 25, weight: .bold, design: .rounded) : AppTypography.bodyStrong)
                        .foregroundStyle(Color.white.opacity(0.82))
                        .lineLimit(dynamicTypeSize.isAccessibilitySize ? 5 : 3)
                        .minimumScaleFactor(0.82)
                        .allowsTightening(true)
                        .multilineTextAlignment(.leading)
                        .frame(width: textMaxWidth, alignment: .leading)

                    accessory()
                }
                .padding(.leading, horizontalTextInset)
                .padding(.trailing, horizontalTextInset)
                .padding(.top, verticalTextInset)
                .padding(.bottom, verticalTextInset)
                .frame(width: proxy.size.width, alignment: .leading)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.hero, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.hero, style: .continuous)
                .stroke(Color.white.opacity(0.14), lineWidth: PremiumVisualMetrics.Card.borderWidth)
        )
        .shadow(color: AppShadows.heroPanel.color, radius: 24, x: 0, y: 14)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(accessibilityIdentifier ?? "")
    }
}

extension PremiumHeroSurface where Content == EmptyView {
    init(
        title: String,
        subtitle: String,
        badge: String?,
        badgeSystemImage: String,
        asset: AppImageAsset?,
        language: AppLanguage,
        role: PremiumImageRole = .hero,
        fallbackCategory: PremiumImageFallbackCategory = .city,
        accent: Color = AppColors.cyanGlow,
        focalPoint: PremiumImageFocalPoint = .center,
        overlayPolicy: PremiumImageOverlayPolicy = .adaptive,
        height: CGFloat = PremiumVisualMetrics.Hero.regularHeight,
        accessibilityIdentifier: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.badge = badge
        self.badgeSystemImage = badgeSystemImage
        self.asset = asset
        self.language = language
        self.role = role
        self.fallbackCategory = fallbackCategory
        self.accent = accent
        self.focalPoint = focalPoint
        self.overlayPolicy = overlayPolicy
        self.height = height
        self.accessibilityIdentifier = accessibilityIdentifier
        self.accessory = { EmptyView() }
    }
}

struct PremiumBadge: View {
    let text: String
    var systemImage: String? = nil
    var color: Color = AppColors.cyanGlow

    var body: some View {
        Label {
            Text(text)
                .lineLimit(1)
                .minimumScaleFactor(0.74)
        } icon: {
            if let systemImage {
                Image(systemName: systemImage)
            }
        }
        .font(AppTypography.metadata)
        .foregroundStyle(.white)
        .padding(.horizontal, 11)
        .padding(.vertical, 7)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.42))
                .overlay(color.opacity(0.16), in: Capsule())
        )
        .overlay(Capsule().stroke(Color.white.opacity(0.22), lineWidth: 0.8))
        .shadow(color: Color.black.opacity(0.26), radius: 8, x: 0, y: 4)
    }
}

struct ProductScreenSection<Content: View>: View {
    let title: String
    var subtitle: String? = nil
    var priority: String? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            HStack(alignment: .firstTextBaseline, spacing: AppSpacing.small) {
                VStack(alignment: .leading, spacing: 4) {
                    if let priority {
                        Text(priority)
                            .font(AppTypography.metadata)
                            .foregroundStyle(AppColors.dutchOrange)
                            .textCase(.uppercase)
                            .lineLimit(1)
                    }

                    Text(title)
                        .font(AppTypography.sectionTitle)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                        .fixedSize(horizontal: false, vertical: true)

                    if let subtitle {
                        Text(subtitle)
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Spacer(minLength: 0)
            }

            content()
        }
        .padding(.top, AppSpacing.small)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ProductStatusStrip: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let title: String
    let subtitle: String
    let symbol: String
    let accent: Color
    var actionTitle: String? = nil
    var actionIdentifier: String? = nil
    var prominence: ProductTaskCard.Prominence = .normal

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    HStack(alignment: .top, spacing: AppSpacing.small) {
                        ProductSymbolTile(symbol: symbol, accent: accent, size: prominence == .primary ? 56 : 46)
                        textBlock
                    }

                    actionPill
                }
            } else {
                HStack(alignment: .center, spacing: AppSpacing.small) {
                    ProductSymbolTile(symbol: symbol, accent: accent, size: prominence == .primary ? 56 : 46)
                    textBlock

                    Spacer(minLength: 8)

                    actionPill
                }
            }
        }
        .padding(prominence == .primary ? PremiumVisualMetrics.Card.padding : PremiumVisualMetrics.Card.compactPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumCardChrome(accent: accent, prominence: prominence)
    }

    private var textBlock: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(prominence == .primary ? .system(size: 21, weight: .heavy, design: .default) : AppTypography.cardTitle)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? 3 : 2)
                .minimumScaleFactor(0.82)
                .fixedSize(horizontal: false, vertical: true)

            Text(subtitle)
                .font(prominence == .primary ? AppTypography.bodyStrong : AppTypography.caption)
                .foregroundStyle(prominence == .primary ? AppColors.textPrimary.opacity(0.78) : AppColors.textSecondary)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? 4 : 2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var actionPill: some View {
        if let actionTitle {
            Text(actionTitle)
                .font(AppTypography.captionStrong)
                .foregroundStyle(accent)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                .minimumScaleFactor(0.86)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 14)
                .frame(minWidth: 44, minHeight: 44)
                .background(accent.opacity(0.12), in: Capsule())
                .accessibilityIdentifier(actionIdentifier ?? "")
        }
    }
}

struct ProductTaskCard: View {
    enum Prominence {
        case primary
        case normal
        case quiet
    }

    let title: String
    let subtitle: String
    let symbol: String
    let accent: Color
    var priority: String? = nil
    var cta: String? = nil
    var minHeight: CGFloat = 96
    var prominence: Prominence = .normal

    var body: some View {
        ViewThatFits(in: .horizontal) {
            horizontalContent
            compactContent
        }
        .padding(cardPadding)
        .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .leading)
        .premiumCardChrome(accent: accent, prominence: prominence)
        .contentShape(RoundedRectangle(cornerRadius: PremiumVisualMetrics.Card.cornerRadius, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private var horizontalContent: some View {
        HStack(alignment: .center, spacing: AppSpacing.small) {
            ProductSymbolTile(symbol: symbol, accent: accent, size: symbolSize)

            textContent

            Spacer(minLength: 8)

            accessory
        }
    }

    private var compactContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: AppSpacing.small) {
                ProductSymbolTile(symbol: symbol, accent: accent, size: symbolSize)

                Spacer(minLength: 8)

                accessory
            }

            textContent
        }
    }

    private var textContent: some View {
        VStack(alignment: .leading, spacing: 5) {
            if let priority {
                Text(priority)
                    .font(AppTypography.metadata)
                    .foregroundStyle(accent)
                    .textCase(.uppercase)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text(title)
                .font(titleFont)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(3)
                .minimumScaleFactor(0.82)
                .fixedSize(horizontal: false, vertical: true)

            Text(subtitle)
                .font(subtitleFont)
                .foregroundStyle(subtitleColor)
                .lineLimit(prominence == .quiet ? 2 : 4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .layoutPriority(1)
    }

    @ViewBuilder
    private var accessory: some View {
        if let cta {
            Text(cta)
                .font(prominence == .primary ? AppTypography.bodyStrong : AppTypography.captionStrong)
                .foregroundStyle(AppColors.navyDeep)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
                .padding(.horizontal, prominence == .primary ? 15 : 11)
                .frame(minHeight: prominence == .primary ? 42 : 36)
                .background(accent, in: Capsule())
        } else {
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(prominence == .quiet ? AppColors.textTertiary.opacity(0.62) : AppColors.textTertiary)
        }
    }

    private var cardPadding: CGFloat {
        switch prominence {
        case .primary: return PremiumVisualMetrics.Card.padding + 4
        case .normal: return PremiumVisualMetrics.Card.padding
        case .quiet: return max(PremiumVisualMetrics.Card.compactPadding - 2, 10)
        }
    }

    private var symbolSize: CGFloat {
        switch prominence {
        case .primary: return 58
        case .normal: return 50
        case .quiet: return 38
        }
    }

    private var titleFont: Font {
        switch prominence {
        case .primary: return .system(size: 20, weight: .heavy, design: .default)
        case .normal: return AppTypography.cardTitle
        case .quiet: return AppTypography.bodyStrong
        }
    }

    private var subtitleFont: Font {
        prominence == .quiet ? AppTypography.caption : AppTypography.body
    }

    private var subtitleColor: Color {
        prominence == .quiet ? AppColors.textTertiary : AppColors.textSecondary
    }
}

struct ProductSymbolTile: View {
    let symbol: String
    let accent: Color
    var size: CGFloat = 44

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: size * 0.40, weight: .bold))
            .foregroundStyle(accent)
            .frame(width: size, height: size)
            .background {
                RoundedRectangle(cornerRadius: min(16, size * 0.30), style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                accent.opacity(0.20),
                                accent.opacity(0.085),
                                Color.white.opacity(0.035)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: min(16, size * 0.30), style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: min(16, size * 0.30), style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.16), accent.opacity(0.28), Color.white.opacity(0.045)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            )
            .shadow(color: accent.opacity(0.10), radius: 10, x: 0, y: 5)
            .accessibilityHidden(true)
    }
}

typealias ProductHero<Content: View> = PremiumHeroSurface<Content>

struct ProductCTA: View {
    let title: String
    var subtitle: String? = nil
    let symbol: String
    let accent: Color

    var body: some View {
        HStack(spacing: AppSpacing.small) {
            ProductSymbolTile(symbol: symbol, accent: accent, size: 42)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)

                if let subtitle {
                    Text(subtitle)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                }
            }

            Spacer(minLength: 8)

            Image(systemName: "arrow.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(accent)
        }
        .padding(PremiumVisualMetrics.Card.compactPadding)
        .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
        .premiumCardChrome(accent: accent)
    }
}

struct ProductListItem: View {
    let title: String
    let subtitle: String
    let symbol: String
    let accent: Color
    var metadata: String? = nil

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.small) {
            ProductSymbolTile(symbol: symbol, accent: accent, size: 40)

            VStack(alignment: .leading, spacing: 4) {
                if let metadata {
                    Text(metadata)
                        .font(AppTypography.metadata)
                        .foregroundStyle(accent)
                        .textCase(.uppercase)
                        .lineLimit(1)
                }

                Text(title)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)

                Text(subtitle)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(PremiumVisualMetrics.Card.compactPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumCardChrome(accent: accent)
    }
}

struct ProductInfoBlock: View {
    let title: String
    let bodyText: String
    let symbol: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            HStack(spacing: AppSpacing.small) {
                ProductSymbolTile(symbol: symbol, accent: accent, size: 42)
                Text(title)
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
            }

            Text(bodyText)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(PremiumVisualMetrics.Card.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumCardChrome(accent: accent)
    }
}

struct PremiumImageCard<Content: View>: View {
    let title: String
    let subtitle: String
    let asset: AppImageAsset?
    let language: AppLanguage
    let symbol: String
    let accent: Color
    var imageHeight: CGFloat = PremiumVisualMetrics.Image.searchHeaderHeight
    var minHeight: CGFloat = PremiumVisualMetrics.Card.minSearchResultHeight
    var fallbackCategory: PremiumImageFallbackCategory = .search
    @ViewBuilder let metadata: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            PremiumImageHeader(
                title: title,
                asset: asset,
                language: language,
                symbol: symbol,
                accent: accent,
                height: imageHeight,
                fallbackCategory: fallbackCategory
            )

            VStack(alignment: .leading, spacing: AppSpacing.small) {
                metadata()
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(title)
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(3)
                    .minimumScaleFactor(0.82)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(subtitle)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(PremiumVisualMetrics.Card.padding)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .topLeading)
        .premiumCardChrome(accent: accent)
    }
}

struct PremiumDirectResultCard: View {
    let type: String
    let title: String
    let subtitle: String
    let symbol: String
    let asset: AppImageAsset?
    let accent: Color
    let language: AppLanguage

    var body: some View {
        directBody
        .frame(maxWidth: .infinity, minHeight: PremiumVisualMetrics.Card.directResultMinHeight, alignment: .topLeading)
        .padding(PremiumVisualMetrics.Card.compactPadding)
        .premiumCardChrome(accent: accent)
    }

    private var directBody: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            PremiumImageHeader(
                title: title,
                asset: asset,
                language: language,
                symbol: symbol,
                accent: accent,
                height: PremiumVisualMetrics.Image.carouselThumbnailHeight,
                cornerRadius: 14,
                fallbackCategory: .search
            )
            directText
        }
    }

    private var directText: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(type)
                .font(AppTypography.metadata)
                .foregroundStyle(accent)
                .textCase(.uppercase)
                .lineLimit(1)
            Text(title)
                .font(AppTypography.cardTitle)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
                .fixedSize(horizontal: false, vertical: true)
            Text(subtitle)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(4)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct PremiumImageHeader: View {
    let title: String
    let asset: AppImageAsset?
    let language: AppLanguage
    let symbol: String
    let accent: Color
    var height: CGFloat
    var width: CGFloat? = nil
    var cornerRadius: CGFloat = 0
    var fallbackCategory: PremiumImageFallbackCategory = .city

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            PremiumImageView(
                asset: asset,
                language: language,
                height: height,
                aspectRatio: nil,
                mode: .fill,
                cornerRadius: cornerRadius,
                overlayStyle: .none,
                fallbackCategory: fallbackCategory,
                accessibilityLabel: title,
                targetPixelWidth: PremiumVisualMetrics.Image.cardTargetPixelWidth,
                role: .card,
                overlayPolicy: .none,
                focalPoint: .center
            )
            .frame(width: width)
            .frame(height: height)
            .frame(maxWidth: width == nil ? .infinity : nil)
            .clipped()
            .accessibilityHidden(true)

            if let gradient = PremiumImageOverlayPolicy.balanced.gradient(role: .card, asset: asset) {
                gradient
                    .frame(width: width)
                    .frame(height: height)
                    .frame(maxWidth: width == nil ? .infinity : nil)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    .allowsHitTesting(false)
            }

            Image(systemName: symbol)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 42, height: 42)
                .background(accent.opacity(0.86), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                .padding(14)
        }
        .frame(width: width)
        .frame(maxWidth: width == nil ? .infinity : nil)
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .clipped()
    }
}

private extension View {
    func premiumCardChrome(accent: Color, prominence: ProductTaskCard.Prominence = .normal) -> some View {
        background {
            ZStack {
                AppColors.glassSurfaceElevated.opacity(surfaceOpacity(for: prominence))

                if prominence == .primary {
                    LinearGradient(
                        colors: [
                            accent.opacity(0.16),
                            AppColors.glassSurfaceElevated.opacity(0.30)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            }
        }
            .clipShape(RoundedRectangle(cornerRadius: PremiumVisualMetrics.Card.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: PremiumVisualMetrics.Card.cornerRadius, style: .continuous)
                    .stroke(cardBorder(accent: accent, prominence: prominence), lineWidth: prominence == .primary ? 1.2 : PremiumVisualMetrics.Card.borderWidth)
            )
            .shadow(color: Color.black.opacity(shadowOpacity(for: prominence)), radius: shadowRadius(for: prominence), x: 0, y: shadowY(for: prominence))
    }

    private func surfaceOpacity(for prominence: ProductTaskCard.Prominence) -> Double {
        switch prominence {
        case .primary: return 1
        case .normal: return 0.86
        case .quiet: return 0.58
        }
    }

    private func cardBorder(accent: Color, prominence: ProductTaskCard.Prominence) -> AnyShapeStyle {
        switch prominence {
        case .primary: return AnyShapeStyle(accent.opacity(0.34))
        case .normal: return AnyShapeStyle(AppSurface.cardBorder(accent: accent).opacity(0.82))
        case .quiet: return AnyShapeStyle(Color.white.opacity(0.10))
        }
    }

    private func shadowOpacity(for prominence: ProductTaskCard.Prominence) -> Double {
        switch prominence {
        case .primary: return 0.24
        case .normal: return 0.14
        case .quiet: return 0.06
        }
    }

    private func shadowRadius(for prominence: ProductTaskCard.Prominence) -> CGFloat {
        switch prominence {
        case .primary: return 24
        case .normal: return 14
        case .quiet: return 8
        }
    }

    private func shadowY(for prominence: ProductTaskCard.Prominence) -> CGFloat {
        switch prominence {
        case .primary: return 14
        case .normal: return 8
        case .quiet: return 4
        }
    }
}

// MARK: - TypewriterText

/// Animates text character-by-character on appear, like a typewriter.
struct TypewriterText: View {
    let fullText: String
    var speed: TimeInterval = 0.045

    var body: some View {
        Text(fullText)
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
