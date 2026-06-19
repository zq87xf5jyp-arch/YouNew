import SwiftUI

struct TermsOfUseView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 760) {
                VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    header
                    section(title: useTitle) {
                        termsRow(icon: "info.circle.fill", title: informationalTitle, detail: informationalDetail)
                        termsRow(icon: "exclamationmark.triangle.fill", title: emergencyTitle, detail: emergencyDetail)
                    }
                    section(title: aiTitle) {
                        termsRow(icon: "sparkles", title: aiGuidanceTitle, detail: aiGuidanceDetail)
                        termsRow(icon: "lock.shield.fill", title: sensitiveDataTitle, detail: sensitiveDataDetail)
                    }
                    section(title: responsibilityTitle) {
                        termsRow(icon: "link", title: externalLinksTitle, detail: externalLinksDetail)
                        termsRow(icon: "person.fill.checkmark", title: userActionTitle, detail: userActionDetail)
                    }
                    Color.clear.frame(height: AppSpacing.tabBarScrollReserve)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, AppSpacing.medium)
            }
        }
        .appSceneBackground(.settings)
        .navigationTitle(title)
        .nlNavigationInline()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(AppColors.softBlue)
                .frame(width: 54, height: 54)
                .background(AppColors.softBlue.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            Text(title)
                .font(AppTypography.title)
                .foregroundStyle(AppColors.textPrimary)
            Text(headerDetail)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardStyle()
    }

    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text(title.uppercased())
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.textTertiary)
                .padding(.horizontal, 4)
            VStack(spacing: AppSpacing.xSmall) {
                content()
            }
        }
    }

    private func termsRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.medium) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColors.softBlue)
                .frame(width: 40, height: 40)
                .background(AppColors.softBlue.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.textPrimary)
                Text(detail)
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .appCardStyle()
    }
}

private extension TermsOfUseView {
    var title: String { lang == .russian ? "Условия использования" : (lang == .dutch ? "Gebruiksvoorwaarden" : "Terms of Use") }
    var headerDetail: String { lang == .russian ? "Используя YouNew, вы соглашаетесь использовать приложение как информационный гид и проверять важные решения в официальных источниках." : (lang == .dutch ? "Door YouNew te gebruiken, gebruikt u de app als informatieve gids en controleert u belangrijke beslissingen bij officiële bronnen." : "By using YouNew, you agree to use the app as an informational guide and verify important decisions with official sources.") }
    var useTitle: String { lang == .russian ? "Использование" : (lang == .dutch ? "Gebruik" : "Use") }
    var informationalTitle: String { lang == .russian ? "Информационный гид" : (lang == .dutch ? "Informatieve gids" : "Informational guide") }
    var informationalDetail: String { lang == .russian ? "Контент помогает ориентироваться в жизни в Нидерландах, но не является юридической, медицинской, финансовой или государственной консультацией." : (lang == .dutch ? "Content helpt bij oriëntatie in Nederland, maar is geen juridisch, medisch, financieel of overheidsadvies." : "Content helps orientation in the Netherlands, but is not legal, medical, financial or government advice.") }
    var emergencyTitle: String { lang == .russian ? "Экстренные ситуации" : (lang == .dutch ? "Noodsituaties" : "Emergencies") }
    var emergencyDetail: String { lang == .russian ? "Приложение не является службой экстренного реагирования. При непосредственной опасности звоните 112." : (lang == .dutch ? "De app is geen noodhulpdienst. Bel 112 bij direct gevaar." : "The app is not an emergency response service. Call 112 for immediate danger.") }
    var aiTitle: String { lang == .russian ? "AI" : (lang == .dutch ? "AI" : "AI") }
    var aiGuidanceTitle: String { lang == .russian ? "Только информационные рекомендации" : (lang == .dutch ? "Alleen informatieve begeleiding" : "Informational guidance only") }
    var aiGuidanceDetail: String { lang == .russian ? "AI может ошибаться или быть неполным. Всегда проверяйте важные решения в официальной организации." : (lang == .dutch ? "AI kan fouten maken of onvolledig zijn. Controleer belangrijke beslissingen altijd bij de officiële organisatie." : "AI can be wrong or incomplete. Always verify important decisions with the official organization.") }
    var sensitiveDataTitle: String { lang == .russian ? "Не вводите чувствительные данные" : (lang == .dutch ? "Geen gevoelige data invoeren" : "Do not enter sensitive data") }
    var sensitiveDataDetail: String { lang == .russian ? "Не вводите BSN, паспортные номера, медицинские записи, банковские данные или пароли в AI или feedback." : (lang == .dutch ? "Voer geen BSN, paspoortnummers, medische gegevens, bankgegevens of wachtwoorden in AI of feedback in." : "Do not enter BSN, passport numbers, medical records, bank details or passwords in AI or feedback.") }
    var responsibilityTitle: String { lang == .russian ? "Ответственность" : (lang == .dutch ? "Verantwoordelijkheid" : "Responsibility") }
    var externalLinksTitle: String { lang == .russian ? "Внешние ссылки" : (lang == .dutch ? "Externe links" : "External links") }
    var externalLinksDetail: String { lang == .russian ? "Внешние сайты принадлежат их владельцам. Проверяйте URL и условия перед вводом личных данных." : (lang == .dutch ? "Externe sites zijn van hun eigenaars. Controleer URL en voorwaarden voordat u persoonlijke gegevens invoert." : "External sites belong to their owners. Check URL and terms before entering personal data.") }
    var userActionTitle: String { lang == .russian ? "Пользователь отвечает за действия" : (lang == .dutch ? "Gebruiker is verantwoordelijk" : "User is responsible") }
    var userActionDetail: String { lang == .russian ? "Вы отвечаете за проверку информации, соблюдение сроков и выполнение действий в официальных сервисах." : (lang == .dutch ? "U bent verantwoordelijk voor controle, termijnen en acties in officiële diensten." : "You are responsible for verification, deadlines and actions in official services.") }
}
