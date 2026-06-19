import SwiftUI

/// Unified surface token system. Every screen uses these values — zero hardcoded colors.
enum AppSurface {

    // MARK: - Base

    /// The one true background — every screen uses this exact floor color.
    static let base = Color(red: 0.027, green: 0.039, blue: 0.075)

    // MARK: - Elevation layers (each ~7% lighter than previous)

    /// E1 — cards floating on base
    static let e1 = Color(red: 0.047, green: 0.064, blue: 0.118)
    /// E2 — elevated cards, highlighted rows
    static let e2 = Color(red: 0.064, green: 0.086, blue: 0.152)
    /// E3 — modals, sheets, popovers
    static let e3 = Color(red: 0.086, green: 0.112, blue: 0.188)

    // MARK: - Border system (same hue, varying opacity)

    /// Barely visible — separators, dividers
    static let b1 = Color.white.opacity(0.055)
    /// Normal — card borders, input outlines
    static let b2 = Color.white.opacity(0.090)
    /// Emphasized — focused, selected, highlighted
    static let b3 = Color.white.opacity(0.150)

    // MARK: - Product depth system

    static let card = e1.opacity(0.88)
    static let activeCard = e2.opacity(0.94)
    static let modal = e3.opacity(0.96)
    static let cardRadius: CGFloat = 22
    static let modalRadius: CGFloat = 28

    static let hairline = Color.white.opacity(0.105)
    static let premiumHighlight = Color.white.opacity(0.085)
    static let quietShadow = Color.black.opacity(0.28)

    static func cardSurface(accent: Color = AppColors.cyanGlow, isActive: Bool = false) -> LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(isActive ? 0.110 : 0.070),
                accent.opacity(isActive ? 0.060 : 0.030),
                (isActive ? activeCard : card)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func cardBorder(accent: Color = AppColors.cyanGlow, isActive: Bool = false) -> LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(isActive ? 0.260 : 0.170),
                accent.opacity(isActive ? 0.160 : 0.075),
                Color.white.opacity(0.050)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Accent glow

    /// Warm orange accent — Dutch flag, CTAs
    static let accentWarm = AppColors.dutchOrange
    /// Cool teal accent — highlights, secondary CTAs
    static let accentCool = AppColors.cyanGlow

    // MARK: - Hero gradient stops
    // The gradient MUST end exactly at AppSurface.base for a seamless seam.

    static func heroGradient() -> LinearGradient {
        LinearGradient(
            stops: [
                .init(color: .clear,                            location: 0.00),
                .init(color: .clear,                            location: 0.28),
                .init(color: base.opacity(0.35),                location: 0.48),
                .init(color: base.opacity(0.78),                location: 0.68),
                .init(color: base.opacity(0.96),                location: 0.82),
                .init(color: base,                              location: 0.92)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
