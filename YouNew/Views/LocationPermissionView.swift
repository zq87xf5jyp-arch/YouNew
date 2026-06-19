import SwiftUI

struct LocationPermissionView: View {
    let onUseLocation: () -> Void
    @EnvironmentObject private var languageManager: LanguageManager
    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text(L10n.t("map.use_location", lang))
                .font(AppTypography.cardTitle)
                .foregroundStyle(AppColors.textPrimary)
            Text(L10n.t("location.privacy_note", lang))
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
            Button(L10n.t("location.allow", lang)) {
                onUseLocation()
            }
            .buttonStyle(.borderedProminent)
            .tint(AppColors.accent)
        }
        .appCardStyle()
    }
}
