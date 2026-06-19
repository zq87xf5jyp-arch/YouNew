import SwiftUI

// MARK: - Empty State View

struct AppEmptyStateView: View {
    let icon: String
    let title: String
    let detail: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: AppSpacing.large) {
            Image(systemName: icon)
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(AppColors.accent.opacity(0.55))
                .frame(width: 88, height: 88)
                .background(AppColors.iconSurface)
                .clipShape(Circle())

            VStack(spacing: AppSpacing.small) {
                Text(title)
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(detail)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .frame(maxWidth: 260)
                }
                .buttonStyle(PrimaryPremiumButtonStyle())
            }
        }
        .padding(AppSpacing.xLarge)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Official Source Badge

struct OfficialSourceBadge: View {
    @EnvironmentObject private var languageManager: LanguageManager
    var label: String? = nil
    var color: Color = AppColors.success

    private var lang: AppLanguage { languageManager.appLanguage }
    private var resolvedLabel: String { label ?? L10n.t("common.official_info", lang) }

    var body: some View {
        Label(resolvedLabel, systemImage: "checkmark.shield.fill")
            .font(AppTypography.metadata)
            .foregroundStyle(color)
            .padding(.horizontal, AppSpacing.small)
            .padding(.vertical, 4)
            .background(color.opacity(0.10))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(color.opacity(0.26), lineWidth: 0.75))
    }
}

// MARK: - Trust Badge

enum TrustBadgeKind {
    case verified
    case educational
    case caution
    case officialSource

    var icon: String {
        switch self {
        case .verified:       "checkmark.shield"
        case .educational:    "graduationcap"
        case .caution:        "exclamationmark.triangle"
        case .officialSource: "building.columns"
        }
    }

    var color: Color {
        switch self {
        case .verified:       AppColors.success
        case .educational:    AppColors.accent
        case .caution:        AppColors.warning
        case .officialSource: AppColors.success
        }
    }
}

struct TrustBadge: View {
    let kind: TrustBadgeKind
    var customLabel: String? = nil
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }

    private var defaultLabel: String {
        switch kind {
        case .verified:
            return L10n.t("common.verified_source", lang)
        case .educational:
            return L10n.t("trust.educational_source", lang)
        case .caution:
            return L10n.t("trust.verify_current_rules", lang)
        case .officialSource:
            return L10n.t("common.official_info", lang)
        }
    }

    var body: some View {
        Label(customLabel ?? defaultLabel, systemImage: kind.icon)
            .font(AppTypography.metadata)
            .foregroundStyle(kind.color)
            .padding(.horizontal, AppSpacing.small)
            .padding(.vertical, 4)
            .background(kind.color.opacity(0.10))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(kind.color.opacity(0.26), lineWidth: 0.75))
    }
}

// MARK: - Privacy Chip

struct PrivacyChip: View {
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        Label(L10n.t("trust.privacy_first", lang), systemImage: "lock.shield")
            .font(AppTypography.metadata)
            .foregroundStyle(AppColors.accent)
            .padding(.horizontal, AppSpacing.small)
            .padding(.vertical, 4)
            .background(AppColors.accent.opacity(0.08))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(AppColors.accent.opacity(0.20), lineWidth: 0.75))
    }
}

// MARK: - Guide Only Banner (inline variant)

struct GuideOnlyBadge: View {
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        Label(L10n.t("disclaimer.guide_only", lang), systemImage: "info.circle")
            .font(AppTypography.metadata)
            .foregroundStyle(AppColors.textTertiary)
            .padding(.horizontal, AppSpacing.small)
            .padding(.vertical, 4)
            .background(AppColors.chipBackground)
            .clipShape(Capsule())
    }
}

// MARK: - Image Placeholder

enum ImagePlaceholderKind: Equatable {
    case hero
    case flag
    case coatOfArms

    var symbolName: String {
        switch self {
        case .hero: return "photo.fill"
        case .flag: return "flag.fill"
        case .coatOfArms: return "shield.fill"
        }
    }

    func localizedTitle(_ lang: AppLanguage) -> String {
        return ""
    }
}

struct ImagePlaceholderView: View {
    let kind: ImagePlaceholderKind
    let lang: AppLanguage
    var accent: Color = AppColors.accent
    var showsText = true

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    AppColors.navyDeep.opacity(0.96),
                    accent.opacity(0.32),
                    AppColors.graphite.opacity(0.88)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            GeneratedCategoryArtwork(symbol: kind.symbolName, accent: accent)
                .opacity(0.24)
                .padding(18)

            VStack(spacing: 8) {
                Image(systemName: kind.symbolName)
                    .font(.system(size: showsText ? 24 : 18, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.92))
                    .frame(width: showsText ? 54 : 38, height: showsText ? 54 : 38)
                    .background(Color.white.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: showsText ? 18 : 12, style: .continuous))

                if showsText {
                    Text(kind.localizedTitle(lang))
                        .font(AppTypography.caption)
                        .foregroundStyle(Color.white.opacity(0.86))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                        .padding(.horizontal, 12)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(kind.localizedTitle(lang))
    }
}

// MARK: - Primary Button

struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppButtonMetrics.labelIconSpacing) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: AppButtonMetrics.smallIconSize, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .lineLimit(2)
                    .minimumScaleFactor(0.84)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 8)
                Image(systemName: "arrow.right")
                    .font(.system(size: 13, weight: .bold))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PrimaryPremiumButtonStyle())
        .accessibilityLabel(title)
    }
}

// MARK: - Province Card

struct ProvinceCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: LinearGradient

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(gradient)
                    .frame(width: 72, height: 72)
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
                    .fixedSize(horizontal: false, vertical: true)
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.62))
                    .lineLimit(3)
                    .minimumScaleFactor(0.84)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.white.opacity(0.34))
        }
        .padding(14)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.11), lineWidth: 0.8)
        )
        .shadow(color: Color.black.opacity(0.24), radius: 16, x: 0, y: 8)
    }
}

// MARK: - City Info Card

struct CityInfoCard: View {
    let icon: String
    let title: String
    let value: String
    var color: Color = AppColors.softBlue

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(color.opacity(0.14))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.56))
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
                    .fixedSize(horizontal: false, vertical: true)
                Text(value)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.88)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 4)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appGlassCardStyle(padding: 0, cornerRadius: 15, accent: color)
    }
}
