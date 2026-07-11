import SwiftUI

struct InstitutionCard: View {
    let institution: Institution
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }

    private var iconName: String {
        switch institution.name {
        case "IND": return "person.text.rectangle"
        case "DUO": return "graduationcap"
        case "UWV": return "briefcase"
        case "Belastingdienst": return "receipt"
        case "DigiD": return "lock.shield"
        case "CJIB": return "exclamationmark.bubble"
        case "RDW": return "car"
        case "Municipality": return "building.2"
        default: return "building.columns"
        }
    }

    private var institutionAccent: Color {
        switch institution.name {
        case "IND": return AppColors.cyanGlow
        case "DUO": return AppColors.emerald
        case "UWV": return AppColors.dutchOrange
        case "Belastingdienst": return AppColors.warning
        case "DigiD": return AppColors.softBlue
        case "CJIB": return AppColors.emergencyRed
        case "RDW": return AppColors.violet
        case "Municipality": return AppColors.softBlue
        default: return AppColors.success
        }
    }

    private var trustMetadata: TrustMetadata {
        TrustMetadata(sourceUpdatedAt: "2026-05", sourceLabel: L10n.t("beginner.official_source", lang), updateIndicator: L10n.t("trust.manual_review", lang))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            HStack(alignment: .top, spacing: AppSpacing.small) {
                Image(systemName: iconName)
                    .font(.title3)
                    .foregroundStyle(institutionAccent)
                    .frame(width: 32, height: 32)
                    .background(institutionAccent.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small, style: .continuous))

                VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                    Text(institution.name)
                        .font(AppTypography.cardTitle)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(3)
                        .minimumScaleFactor(0.86)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(institution.shortExplanation(lang))
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Text(L10n.t("institution.what_for", lang))
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text(institution.usage(lang))
                .font(AppTypography.bodyStrong)
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(L10n.t("institution.when_use", lang))
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Text(institution.whenToUse(lang))
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text(L10n.t("institution.common_confusion", lang))
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Text(institution.commonConfusion(lang))
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Link(L10n.t("resource.open_source", lang), destination: AppURL.safeWebURL(institution.officialWebsiteURL))
                .font(AppTypography.bodyStrong)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
                .padding(.vertical, AppSpacing.xSmall)
                .padding(.horizontal, AppSpacing.small)
                .background(institutionAccent.opacity(0.12))
                .overlay(
                    Capsule()
                        .stroke(institutionAccent.opacity(0.32), lineWidth: 1)
                )
                .clipShape(Capsule())

            Text(institution.warning(lang))
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.warning)
                .fixedSize(horizontal: false, vertical: true)

            TrustMetadataRow(metadata: trustMetadata)
        }
        .padding(PremiumVisualMetrics.Card.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumNetherlandsCard(cornerRadius: AppCornerRadius.large, accent: institutionAccent)
    }
}
