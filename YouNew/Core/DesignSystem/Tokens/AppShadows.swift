import SwiftUI

enum AppShadows {
    static let card        = Shadow(color: Color.black.opacity(0.22), radius: 22, x: 0, y: 12)
    static let elevatedCard = Shadow(color: Color.black.opacity(0.30), radius: 30, x: 0, y: 18)
    static let pressedCard = Shadow(color: Color.black.opacity(0.05), radius: 8,  x: 0, y: 3)
    static let floating    = Shadow(color: Color.black.opacity(0.16), radius: 32, x: 0, y: 16)
    static let heroPanel   = Shadow(color: AppColors.navyDeep.opacity(0.30), radius: 40, x: 0, y: 20)
    static let badge       = Shadow(color: Color.black.opacity(0.10), radius: 6,  x: 0, y: 2)
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

enum AppGradients {
    static let primaryAction = LinearGradient(
        colors: [AppColors.accentBlue, AppColors.cyanGlow],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let netherlandsAccent = LinearGradient(
        colors: [AppColors.accentBlue, AppColors.dutchOrange],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let premiumSurface = LinearGradient(
        colors: [Color.white.opacity(0.16), Color.white.opacity(0.04), Color.clear],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

enum AppMaterials {
    static var glass: Material { .ultraThinMaterial }
    static var elevated: Material { .regularMaterial }
    static var toolbar: Material { .bar }
}

// MARK: - View Modifiers

extension View {

    func appCardStyle() -> some View {
        modifier(AppCardStyleModifier())
    }

    func appGlassCardStyle(
        padding: CGFloat = AppSpacing.cardPadding,
        cornerRadius: CGFloat = AppCornerRadius.large,
        accent: Color = AppColors.cyanGlow
    ) -> some View {
        modifier(AppGlassCardModifier(padding: padding, cornerRadius: cornerRadius, accent: accent))
    }

    func appInputStyle(cornerRadius: CGFloat = AppCornerRadius.medium) -> some View {
        modifier(AppInputModifier(cornerRadius: cornerRadius))
    }

    func appSceneBackground() -> some View {
        appSceneBackground(.general)
    }

    func appSceneBackground(_ style: YouNewScreenBackgroundStyle) -> some View {
        background {
            GlobalBackgroundView()
        }
    }
}

private struct AppCardStyleModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    func body(content: Content) -> some View {
        content
            .padding(AppSpacing.cardPadding)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: AppSurface.cardRadius, style: .continuous)
                        .fill(reduceTransparency ? AppSurface.activeCard : AppSurface.card)
                    RoundedRectangle(cornerRadius: AppSurface.cardRadius, style: .continuous)
                        .fill(AppSurface.cardSurface(accent: AppColors.cyanGlow))
                    RoundedRectangle(cornerRadius: AppSurface.cardRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(colorScheme == .dark ? 0.060 : 0.30), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: AppSurface.cardRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppSurface.cardRadius, style: .continuous)
                    .stroke(AppSurface.cardBorder(accent: AppColors.cyanGlow), lineWidth: colorScheme == .dark ? 0.80 : 1.0)
                    .allowsHitTesting(false)
            )
            .overlay {
                AppCardContourOverlay(cornerRadius: AppSurface.cardRadius, accent: AppColors.cyanGlow)
                    .allowsHitTesting(false)
            }
            .shadow(color: AppShadows.card.color, radius: AppShadows.card.radius, x: AppShadows.card.x, y: AppShadows.card.y)
    }
}

private struct AppGlassCardModifier: ViewModifier {
    let padding: CGFloat
    let cornerRadius: CGFloat
    let accent: Color
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            reduceTransparency
                                ? AppSurface.activeCard
                                : AppSurface.card
                        )
                    if !reduceTransparency {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(AppMaterials.glass)
                            .opacity(colorScheme == .dark ? 0.18 : 0.34)
                    }
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(AppSurface.cardSurface(accent: accent, isActive: false))
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(AppGradients.premiumSurface)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(AppSurface.cardBorder(accent: accent), lineWidth: colorScheme == .dark ? 0.8 : 1.0)
                    .allowsHitTesting(false)
            }
            .overlay {
                AppCardContourOverlay(cornerRadius: cornerRadius, accent: accent)
                    .allowsHitTesting(false)
            }
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.24 : 0.18), radius: colorScheme == .dark ? 22 : 18, x: 0, y: colorScheme == .dark ? 12 : 10)
    }
}

struct AppCardContourOverlay: View {
    var cornerRadius: CGFloat = AppSurface.cardRadius
    var accent: Color = AppColors.cyanGlow

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        TimelineView(.animation) { timeline in
            let phase = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
            let animatedOpacity = reduceTransparency ? 0.10 : 0.13 + 0.035 * sin(phase / 4.2)

            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.16),
                            accent.opacity(animatedOpacity),
                            Color.white.opacity(0.030)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: reduceTransparency ? 0.7 : 0.9
                )
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
    }
}

private struct AppInputModifier: ViewModifier {
    let cornerRadius: CGFloat
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 13)
            .padding(.vertical, 11)
            .frame(minHeight: 46)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(reduceTransparency ? AppColors.cardElevated : AppColors.glassSurface)
                    if !reduceTransparency {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(AppMaterials.glass)
                            .opacity(0.32)
                    }
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(LinearGradient(colors: [Color.white.opacity(0.10), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(AppColors.stroke.opacity(0.86), lineWidth: 0.85)
            }
    }
}

// MARK: - Button Styles

struct AppPressableCardButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(!reduceMotion && configuration.isPressed ? 0.982 : 1.0)
            .opacity(configuration.isPressed ? 0.93 : 1.0)
            .brightness(configuration.isPressed ? -0.015 : 0)
            .shadow(
                color: configuration.isPressed
                    ? .clear
                    : AppShadows.elevatedCard.color.opacity(0.16),
                radius: configuration.isPressed ? 0 : AppShadows.elevatedCard.radius,
                x: configuration.isPressed ? 0 : AppShadows.elevatedCard.x,
                y: configuration.isPressed ? 0 : AppShadows.elevatedCard.y
            )
            .shadow(
                color: configuration.isPressed ? AppShadows.pressedCard.color : .clear,
                radius: configuration.isPressed ? AppShadows.pressedCard.radius : 0,
                x: configuration.isPressed ? AppShadows.pressedCard.x : 0,
                y: configuration.isPressed ? AppShadows.pressedCard.y : 0
            )
            .animation(reduceMotion ? nil : AppAnimations.tactilePress, value: configuration.isPressed)
    }
}

struct AppPressableButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minWidth: AppButtonMetrics.minTouchSize, minHeight: AppButtonMetrics.minTouchSize)
            .scaleEffect(!reduceMotion && configuration.isPressed ? 0.975 : 1.0)
            .opacity(!isEnabled ? 0.56 : (configuration.isPressed ? 0.90 : 1.0))
            .brightness(configuration.isPressed ? -0.02 : 0)
            .animation(reduceMotion ? nil : AppAnimations.tactilePress, value: configuration.isPressed)
    }
}

struct PrimaryPremiumButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTypography.bodyStrong)
            .foregroundStyle(isEnabled ? Color.white : Color.white.opacity(0.58))
            .frame(minHeight: AppButtonMetrics.minTouchSize)
            .padding(.horizontal, AppButtonMetrics.horizontalPadding)
            .padding(.vertical, AppButtonMetrics.verticalPadding)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous)
                        .fill(AppGradients.primaryAction)
                        .opacity(isEnabled ? 1.0 : 0.42)
                    RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.22), Color.clear, Color.black.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous)
                    .stroke(Color.white.opacity(isEnabled ? 0.30 : 0.08), lineWidth: 0.8)
            }
            .shadow(color: isEnabled ? AppColors.cyanGlow.opacity(0.24) : .clear, radius: 18, x: 0, y: 9)
            .shadow(color: isEnabled ? AppColors.dutchOrange.opacity(0.10) : .clear, radius: 8, x: 0, y: 2)
            .scaleEffect(!reduceMotion && configuration.isPressed ? 0.975 : 1.0)
            .opacity(configuration.isPressed ? 0.92 : 1.0)
            .brightness(configuration.isPressed ? -0.025 : 0)
            .animation(reduceMotion ? nil : AppAnimations.tactilePress, value: configuration.isPressed)
    }
}

struct SecondaryPremiumButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTypography.bodyStrong)
            .foregroundStyle(isEnabled ? AppColors.textPrimary : AppColors.textTertiary)
            .frame(minHeight: AppButtonMetrics.minTouchSize)
            .padding(.horizontal, AppButtonMetrics.horizontalPadding)
            .padding(.vertical, AppButtonMetrics.verticalPadding)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous)
                        .fill(isEnabled ? AppColors.glassSurfaceElevated : AppColors.chipBackground.opacity(0.55))
                    RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous)
                        .fill(AppMaterials.glass)
                        .opacity(isEnabled ? 0.25 : 0.08)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.22), AppColors.stroke.opacity(0.82)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            }
            .shadow(color: isEnabled ? Color.black.opacity(0.06) : .clear, radius: 8, x: 0, y: 4)
            .scaleEffect(!reduceMotion && configuration.isPressed ? 0.975 : 1.0)
            .opacity(configuration.isPressed ? 0.86 : 1.0)
            .brightness(configuration.isPressed ? -0.015 : 0)
            .animation(reduceMotion ? nil : AppAnimations.tactilePress, value: configuration.isPressed)
    }
}

struct GhostPremiumButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTypography.footnoteStrong)
            .foregroundStyle(isEnabled ? AppColors.accentLight : AppColors.textTertiary)
            .frame(minHeight: AppButtonMetrics.minTouchSize)
            .padding(.horizontal, AppButtonMetrics.horizontalPadding)
            .padding(.vertical, AppButtonMetrics.compactVerticalPadding)
            .background(AppColors.accent.opacity(configuration.isPressed ? 0.12 : 0.0))
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous))
            .scaleEffect(!reduceMotion && configuration.isPressed ? 0.98 : 1.0)
            .animation(reduceMotion ? nil : AppAnimations.tactilePress, value: configuration.isPressed)
    }
}

struct DestructivePremiumButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTypography.bodyStrong)
            .foregroundStyle(isEnabled ? AppColors.destructive : AppColors.textTertiary)
            .frame(minHeight: AppButtonMetrics.minTouchSize)
            .padding(.horizontal, AppButtonMetrics.horizontalPadding)
            .background(AppColors.destructive.opacity(configuration.isPressed ? 0.16 : 0.10))
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous)
                    .stroke(AppColors.destructive.opacity(isEnabled ? 0.24 : 0.08), lineWidth: 0.75)
            }
            .scaleEffect(!reduceMotion && configuration.isPressed ? 0.975 : 1.0)
            .animation(reduceMotion ? nil : AppAnimations.tactilePress, value: configuration.isPressed)
    }
}

struct IconCircleButton: View {
    let symbol: String
    let accessibilityLabel: String
    var isSelected: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(isSelected ? AppColors.orangeGlow : AppColors.textPrimary)
                .frame(width: 44, height: 44)
                .background {
                    ZStack {
                        Circle()
                            .fill(isSelected ? AppColors.dutchOrange.opacity(0.18) : AppColors.glassSurfaceElevated)
                        Circle()
                            .fill(AppMaterials.glass)
                            .opacity(0.30)
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.18), Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(isSelected ? AppColors.dutchOrange.opacity(0.34) : AppColors.stroke.opacity(0.78), lineWidth: 0.8)
                }
        }
        .buttonStyle(AppPressableButtonStyle())
        .accessibilityLabel(accessibilityLabel)
    }
}
