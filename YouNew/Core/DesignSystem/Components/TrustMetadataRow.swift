import SwiftUI

struct TrustMetadataRow: View {
    let metadata: TrustMetadata
    @EnvironmentObject private var languageManager: LanguageManager
    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .center, spacing: AppSpacing.small) {
                OfficialSourceBadge(label: metadata.sourceLabel)
                updateIndicatorText
                Spacer(minLength: AppSpacing.small)
                updatedText
            }

            VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                OfficialSourceBadge(label: metadata.sourceLabel)
                updateIndicatorText
                updatedText
            }
        }
        .padding(.top, AppSpacing.xSmall)
    }

    @ViewBuilder
    private var updateIndicatorText: some View {
        if !metadata.updateIndicator.isEmpty {
            Text(metadata.updateIndicator)
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.textTertiary)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var updatedText: some View {
        Text(String(format: L10n.t("trust.updated", lang), metadata.sourceUpdatedAt))
            .font(AppTypography.metadata)
            .foregroundStyle(AppColors.textTertiary)
            .lineLimit(2)
            .minimumScaleFactor(0.82)
            .fixedSize(horizontal: false, vertical: true)
    }
}
