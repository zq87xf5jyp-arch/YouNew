import SwiftUI

struct SupportFeedbackView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var appState: AppStateViewModel
    @AppStorage("support.lastFeedbackText") private var lastFeedbackText = ""
    @AppStorage("support.lastFeedbackDate") private var lastFeedbackDate = ""
    @State private var feedbackText = ""

    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 760) {
                VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    header
                    feedbackForm
                    supportSection
                    legalSection
                    Color.clear.frame(height: AppSpacing.tabBarScrollReserve)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, AppSpacing.medium)
            }
        }
        .appSceneBackground(.settings)
        .navigationTitle(title)
        .nlNavigationInline()
        .onAppear {
            if feedbackText.isEmpty {
                feedbackText = lastFeedbackText
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: AppSpacing.medium) {
            Image(systemName: "lifepreserver.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(AppColors.cyanGlow)
                .frame(width: 52, height: 52)
                .background(AppColors.cyanGlow.opacity(0.13))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(AppTypography.title)
                    .foregroundStyle(AppColors.textPrimary)
                Text(headerDetail)
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .appCardStyle()
    }

    private var feedbackForm: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text(feedbackTitle.uppercased())
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.textTertiary)
                .padding(.horizontal, 4)

            VStack(alignment: .leading, spacing: AppSpacing.small) {
                TextEditor(text: $feedbackText)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(minHeight: 150)
                    .padding(8)
                    .background(AppColors.cardElevated.opacity(0.64))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(AppColors.stroke.opacity(0.8), lineWidth: 0.8)
                    )
                    .accessibilityLabel(feedbackPlaceholder)

                Button {
                    saveFeedback()
                } label: {
                    Label(saveTitle, systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryPremiumButtonStyle())
                .disabled(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                if !lastFeedbackDate.isEmpty {
                    Label(savedStatus, systemImage: "checkmark.seal.fill")
                        .font(AppTypography.footnoteStrong)
                        .foregroundStyle(AppColors.success)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .appGlassCardStyle(padding: 14, cornerRadius: 22, accent: AppColors.cyanGlow)
        }
    }

    private var supportSection: some View {
        section(title: supportTitle) {
            supportRow(icon: "exclamationmark.triangle.fill", title: urgentTitle, detail: urgentDetail, tint: AppColors.error)
            supportRow(icon: "checkmark.shield.fill", title: sourcesTitle, detail: sourcesDetail, tint: AppColors.success)
            supportRow(icon: "lock.shield.fill", title: privacyTitle, detail: privacyDetail, tint: AppColors.cyanGlow)
        }
    }

    private var legalSection: some View {
        section(title: legalTitle) {
            supportRow(icon: "info.circle.fill", title: infoOnlyTitle, detail: infoOnlyDetail, tint: AppColors.warning)
            supportRow(icon: "link", title: externalLinksTitle, detail: externalLinksDetail, tint: AppColors.softBlue)
        }
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

    private func supportRow(icon: String, title: String, detail: String, tint: Color) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.medium) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 42, height: 42)
                .background(tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))

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

    private func saveFeedback() {
        let trimmed = feedbackText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        lastFeedbackText = trimmed
        lastFeedbackDate = Date.now.formatted(.dateTime.year().month().day().hour().minute())
        appState.showToast(savedToast)
    }
}

private extension SupportFeedbackView {
    var title: String {
        switch lang {
        case .russian: return "Поддержка и отзыв"
        case .dutch: return "Support en feedback"
        case .english: return "Support & Feedback"
        }
    }

    var headerDetail: String {
        switch lang {
        case .russian: return "Сохраните отзыв локально для передачи команде поддержки. Для срочных ситуаций используйте официальные службы, а не форму отзыва."
        case .dutch: return "Bewaar feedback lokaal om met support te delen. Gebruik officiële diensten voor urgente situaties, niet dit formulier."
        case .english: return "Save feedback locally so it can be shared with support. For urgent situations, use official services, not this form."
        }
    }

    var feedbackTitle: String { lang == .russian ? "Отзыв" : (lang == .dutch ? "Feedback" : "Feedback") }
    var feedbackPlaceholder: String { lang == .russian ? "Опишите проблему или идею" : (lang == .dutch ? "Beschrijf het probleem of idee" : "Describe the issue or idea") }
    var saveTitle: String { lang == .russian ? "Сохранить отзыв" : (lang == .dutch ? "Feedback bewaren" : "Save feedback") }
    var savedToast: String { lang == .russian ? "Отзыв сохранён локально" : (lang == .dutch ? "Feedback lokaal bewaard" : "Feedback saved locally") }
    var savedStatus: String { lang == .russian ? "Последний отзыв сохранён: \(lastFeedbackDate)" : (lang == .dutch ? "Laatste feedback bewaard: \(lastFeedbackDate)" : "Last feedback saved: \(lastFeedbackDate)") }
    var supportTitle: String { lang == .russian ? "Куда обращаться" : (lang == .dutch ? "Waarheen" : "Where to go") }
    var urgentTitle: String { lang == .russian ? "Срочная помощь" : (lang == .dutch ? "Urgente hulp" : "Urgent help") }
    var urgentDetail: String { lang == .russian ? "Если есть непосредственная опасность, звоните 112. Отзыв в приложении не отслеживается в реальном времени." : (lang == .dutch ? "Bel 112 bij direct gevaar. Appfeedback wordt niet realtime bewaakt." : "Call 112 for immediate danger. App feedback is not monitored in real time.") }
    var sourcesTitle: String { lang == .russian ? "Официальные источники" : (lang == .dutch ? "Officiële bronnen" : "Official sources") }
    var sourcesDetail: String { lang == .russian ? "Для решений по документам, штрафам, здравоохранению или муниципалитету проверяйте официальную организацию." : (lang == .dutch ? "Controleer de officiële organisatie voor documenten, boetes, zorg of gemeentezaken." : "For documents, fines, healthcare or municipality decisions, verify with the official organization.") }
    var privacyTitle: String { lang == .russian ? "Приватность" : (lang == .dutch ? "Privacy" : "Privacy") }
    var privacyDetail: String { lang == .russian ? "Не вводите BSN, паспортные номера, медицинские записи или другие чувствительные данные в отзыв." : (lang == .dutch ? "Voer geen BSN, paspoortnummers, medische gegevens of andere gevoelige data in feedback in." : "Do not enter BSN, passport numbers, medical records or other sensitive data in feedback.") }
    var legalTitle: String { lang == .russian ? "Правовая информация" : (lang == .dutch ? "Juridische informatie" : "Legal information") }
    var infoOnlyTitle: String { lang == .russian ? "Только информация" : (lang == .dutch ? "Alleen informatie" : "Information only") }
    var infoOnlyDetail: String { lang == .russian ? "YouNew не заменяет юриста, врача, gemeente, IND, CJIB, полицию или другую официальную организацию." : (lang == .dutch ? "YouNew vervangt geen advocaat, arts, gemeente, IND, CJIB, politie of andere officiële organisatie." : "YouNew does not replace a lawyer, doctor, municipality, IND, CJIB, police or another official organization.") }
    var externalLinksTitle: String { lang == .russian ? "Внешние ссылки" : (lang == .dutch ? "Externe links" : "External links") }
    var externalLinksDetail: String { lang == .russian ? "Внешние сайты управляются их владельцами. Проверяйте URL перед вводом личных данных." : (lang == .dutch ? "Externe sites worden beheerd door hun eigenaars. Controleer de URL voordat u persoonlijke gegevens invoert." : "External sites are operated by their owners. Check the URL before entering personal data.") }
}
