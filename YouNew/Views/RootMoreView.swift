import SwiftUI

struct RootMoreView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager

    private var language: AppLanguage { languageManager.appLanguage }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 14) {
                Text(localized(en: "More", nl: "Meer", ru: "Ещё"))
                    .font(.largeTitle.bold())
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("screen.more")

                settingsGroup(localized(en: "PROFILE", nl: "PROFIEL", ru: "ПРОФИЛЬ")) {
                    row("person.crop.circle", localized(en: "Profile", nl: "Profiel", ru: "Профиль"), .profileSelection)
                    row("location.fill", localized(en: "Current city", nl: "Huidige stad", ru: "Текущий город"), .cityList, detail: ProvinceCatalog.localizedCityName(appState.selectedCity, language))
                    row("slider.horizontal.3", localized(en: "Personalization", nl: "Personalisatie", ru: "Персонализация"), .profileSelection)
                }

                settingsGroup(localized(en: "APP", nl: "APP", ru: "ПРИЛОЖЕНИЕ")) {
                    row("globe", localized(en: "Language", nl: "Taal", ru: "Язык"), .settings)
                    row("bell.fill", localized(en: "Notifications", nl: "Meldingen", ru: "Уведомления"), .settings)
                    row("circle.lefthalf.filled", localized(en: "Appearance", nl: "Weergave", ru: "Оформление"), .settings)
                    row("arrow.down.circle.fill", localized(en: "Offline materials", nl: "Offline materiaal", ru: "Офлайн-материалы"), .resourcesHub)
                }

                settingsGroup(localized(en: "INFORMATION", nl: "INFORMATIE", ru: "ИНФОРМАЦИЯ")) {
                    row("checkmark.seal.fill", localized(en: "Sources and updates", nl: "Bronnen en updates", ru: "Источники и обновления"), .officialSources)
                    row("bubble.left.and.bubble.right.fill", localized(en: "Feedback", nl: "Feedback", ru: "Обратная связь"), .supportFeedback)
                    row("hand.raised.fill", localized(en: "Privacy", nl: "Privacy", ru: "Конфиденциальность"), .privacyDataControl)
                    row("info.circle.fill", localized(en: "About", nl: "Over", ru: "О приложении"), .aboutYouNew)
                        .accessibilityIdentifier("more.lastElement")
                }

                Color.clear.frame(height: AppSpacing.tabBarScrollReserve)
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
        }
        .safeAreaPadding(.top, 4)
    }

    private func settingsGroup<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(AppTypography.captionStrong)
                .foregroundStyle(AppColors.textSecondary)
                .tracking(0.8)
                .padding(.horizontal, 4)
                .padding(.bottom, 8)
            VStack(spacing: 0) { content() }
                .appGlassCardStyle(padding: 0, cornerRadius: 19, accent: AppColors.softBlue)
        }
    }

    private func row(_ icon: String, _ title: String, _ destination: AppDestination, detail: String? = nil) -> some View {
        NavigationLink(value: destination) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.headline.bold())
                    .foregroundStyle(AppColors.cyanGlow)
                    .frame(width: 38, height: 38)
                    .background(AppColors.cyanGlow.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(AppTypography.body.weight(.semibold))
                        .foregroundStyle(AppColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    if let detail {
                        Text(detail)
                            .font(AppTypography.footnote)
                            .foregroundStyle(AppColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer(minLength: 4)
                Image(systemName: "chevron.right")
                    .foregroundStyle(AppColors.textTertiary)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 13)
            .frame(minHeight: 64)
            .overlay(alignment: .bottom) {
                Rectangle().fill(AppColors.stroke.opacity(0.45)).frame(height: 0.5).padding(.leading, 62)
            }
        }
        .buttonStyle(.plain)
    }

    private func localized(en: String, nl: String, ru: String) -> String {
        switch language {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }
}
