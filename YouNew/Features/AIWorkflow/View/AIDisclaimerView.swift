import SwiftUI

struct AIDisclaimerView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        DisclaimerBanner(
            text: L10n.t("ai.disclaimer", lang),
            tone: AppColors.error
        )
    }
}
