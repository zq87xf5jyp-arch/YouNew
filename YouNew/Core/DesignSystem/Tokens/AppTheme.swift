import SwiftUI

enum AppTheme {

    // MARK: - Backgrounds
    static let background    = AppColors.background
    static let cardBackground = AppColors.card
    static let elevatedCard  = AppColors.cardElevated

    // MARK: - Text
    static let primaryText   = AppColors.textPrimary
    static let secondaryText = AppColors.textSecondary
    static let tertiaryText  = AppColors.textTertiary

    // MARK: - Brand
    static let accent      = AppColors.accent
    static let accentLight = AppColors.accentLight
    static let highlight   = AppColors.dutchOrange
    static let supportBlue = AppColors.softBlue
    static let navy        = AppColors.navyDeep

    // MARK: - Semantic Status
    static let trusted  = AppColors.success
    static let caution  = AppColors.warning
    static let risk     = AppColors.error

    // MARK: - Hero
    static let heroGradientStart = AppColors.heroStart
    static let heroGradientMid   = AppColors.heroMid
    static let heroGradientEnd   = AppColors.heroEnd

    // MARK: - Surfaces
    static let separator     = AppColors.stroke
    static let iconContainer = AppColors.iconSurface
    static let trackSurface  = AppColors.progressTrack
}
