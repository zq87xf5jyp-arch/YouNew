import SwiftUI

struct OutdatedInfoReportCard: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var didReport = false
    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text(L10n.t("outdated.notice_title", lang))
                .font(AppTypography.cardTitle)
                .foregroundStyle(AppColors.textPrimary)

            Text(L10n.t("outdated.notice_subtitle", lang))
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)

            Button(didReport ? L10n.t("outdated.report_submitted", lang) : L10n.t("outdated.report_action", lang)) {
                didReport = true
            }
            .buttonStyle(.bordered)
            .disabled(didReport)
        }
        .appCardStyle()
    }
}
