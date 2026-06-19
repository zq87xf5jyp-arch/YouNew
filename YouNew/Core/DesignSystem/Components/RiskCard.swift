import SwiftUI

struct RiskCard: View {
    let item: RiskItem
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }

    private var severityColor: Color {
        switch item.section {
        case .topMistakes: return AppColors.warning
        case .fines: return AppColors.error
        case .scams: return AppColors.accent
        case .reminders: return AppColors.success
        }
    }

    private var trustMetadata: TrustMetadata {
        TrustMetadata(
            sourceUpdatedAt: "2026-05",
            sourceLabel: L10n.t("trust.educational_source", lang),
            updateIndicator: L10n.t("trust.verify_current_rules", lang)
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            HStack(alignment: .top, spacing: AppSpacing.xSmall) {
                Circle()
                    .fill(severityColor)
                    .frame(width: 10, height: 10)
                    .padding(.top, 7)
                Text(item.title(lang))
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(4)
                    .minimumScaleFactor(0.86)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text(item.detail(lang))
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            TrustMetadataRow(metadata: trustMetadata)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardStyle()
    }
}
