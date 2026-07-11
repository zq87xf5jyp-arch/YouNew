import SwiftUI

struct EmergencyHubView: View {
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }

    private var contacts: [EmergencyContact] {
        [
            EmergencyContact(
                id: "112",
                number: "112",
                titleEN: "Emergency: fire, police, ambulance",
                titleNL: "Nood: brandweer, politie, ambulance",
                titleRU: "Экстренно: пожарные, полиция, скорая",
                whenEN: "Use for life-threatening situations, urgent medical help, fire, or a serious crime in progress.",
                whenNL: "Gebruik bij levensgevaar, spoedeisende medische hulp, brand of een ernstig misdrijf op heterdaad.",
                whenRU: "Используйте при угрозе жизни, срочной медицинской помощи, пожаре или тяжком преступлении сейчас.",
                nextEN: "The control-room operator asks what happened, where help is needed, and connects the right service.",
                nextNL: "De meldkamer vraagt wat er is gebeurd, waar hulp nodig is en verbindt de juiste hulpdienst.",
                nextRU: "Оператор спросит, что случилось, где нужна помощь, и подключит нужную службу.",
                disclaimerEN: "Do not use 112 for routine questions or non-urgent reports.",
                disclaimerNL: "Gebruik 112 niet voor gewone vragen of meldingen zonder spoed.",
                disclaimerRU: "Не используйте 112 для обычных вопросов или несрочных сообщений.",
                sourceTitle: "Government.nl — Emergency number 112",
                sourceURL: AppURL.make("https://www.government.nl/topics/emergency-number-112"),
                callURL: URL(string: "tel://112"),
                icon: "phone.fill",
                color: AppColors.emergencyRed,
                isPrimary: true
            ),
            EmergencyContact(
                id: "police",
                number: "0900-8844",
                titleEN: "Police: non-emergency",
                titleNL: "Politie: geen spoed",
                titleRU: "Полиция: не срочно",
                whenEN: "Use for police questions, appointments, or reports when there is no immediate danger.",
                whenNL: "Gebruik voor politievraag, afspraak of melding zonder direct gevaar.",
                whenRU: "Используйте для вопросов полиции, записи или сообщений без непосредственной опасности.",
                nextEN: "Police contact staff route your question or report; call costs may apply.",
                nextNL: "De politie verwerkt uw vraag of melding; belkosten kunnen gelden.",
                nextRU: "Полиция направит вопрос или сообщение; возможна стоимость звонка.",
                disclaimerEN: "If danger becomes urgent, call 112 instead.",
                disclaimerNL: "Wordt de situatie spoed, bel dan 112.",
                disclaimerRU: "Если ситуация стала срочной, звоните 112.",
                sourceTitle: "Politie.nl — Contact",
                sourceURL: AppURL.make("https://www.politie.nl/en/contact/"),
                callURL: URL(string: "tel://09008844"),
                icon: "shield.fill",
                color: AppColors.softBlue,
                isPrimary: false
            ),
            EmergencyContact(
                id: "huisarts",
                number: "Huisarts / huisartsenpost",
                titleEN: "Urgent medical care, not life-threatening",
                titleNL: "Dringende zorg, niet levensbedreigend",
                titleRU: "Срочная медицина без угрозы жизни",
                whenEN: "Use your GP during office hours; use the out-of-hours GP service in evenings, nights, weekends, and public holidays.",
                whenNL: "Bel uw huisarts tijdens kantooruren; bel de huisartsenpost in avond, nacht, weekend en feestdagen.",
                whenRU: "Днём звоните своему huisarts; вечером, ночью, в выходные и праздники — в huisartsenpost.",
                nextEN: "A triage assistant decides whether you need advice, an appointment, home visit, emergency department, or 112.",
                nextNL: "Triage bepaalt advies, afspraak, huisbezoek, spoedeisende hulp of 112.",
                nextRU: "Триаж решит: совет, приём, визит на дом, SEH или 112.",
                disclaimerEN: "For life-threatening symptoms, do not wait for GP triage: call 112.",
                disclaimerNL: "Bij levensgevaar niet wachten op triage: bel 112.",
                disclaimerRU: "При угрозе жизни не ждите триаж: звоните 112.",
                sourceTitle: "Thuisarts — In case of emergency",
                sourceURL: AppURL.make("https://www.thuisarts.nl/dutch-healthcare/in-case-of-emergency"),
                callURL: nil,
                icon: "stethoscope",
                color: AppColors.emerald,
                isPrimary: false
            ),
            EmergencyContact(
                id: "ggd",
                number: "GGD",
                titleEN: "GGD: public health questions",
                titleNL: "GGD: publieke gezondheidsvragen",
                titleRU: "GGD: вопросы общественного здоровья",
                whenEN: "Use for local public-health services and regional GGD contact, not for acute medical emergencies.",
                whenNL: "Gebruik voor lokale publieke gezondheidszorg en regionaal GGD-contact, niet voor acute medische nood.",
                whenRU: "Используйте для местных услуг общественного здоровья и контакта GGD, не для экстренной медицины.",
                nextEN: "Find your regional GGD contact through official GGD/GHOR or municipality channels.",
                nextNL: "Vind uw regionale GGD via officiële GGD/GHOR- of gemeentekanalen.",
                nextRU: "Найдите региональную GGD через официальные каналы GGD/GHOR или gemeente.",
                disclaimerEN: "For immediate danger or severe symptoms, use 112 or urgent medical care.",
                disclaimerNL: "Bij direct gevaar of ernstige klachten: 112 of spoedzorg.",
                disclaimerRU: "При непосредственной опасности или тяжёлых симптомах — 112 или срочная медицина.",
                sourceTitle: "Rijksoverheid — GGD GHOR Nederland",
                sourceURL: AppURL.make("https://www.rijksoverheid.nl/contact/contactgids/ggd-ghor-nederland"),
                callURL: nil,
                icon: "cross.case.fill",
                color: AppColors.warning,
                isPrimary: false
            )
        ]
    }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 920) {
                VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    heroSection

                    NLSectionHeader(title: primaryTitle, subtitle: primarySubtitle)
                    primaryCard

                    NLSectionHeader(title: otherTitle)
                    ForEach(contacts.filter { !$0.isPrimary }) { contact in
                        emergencyContactCard(contact)
                    }

                    disclaimerCard

                    Color.clear.frame(height: AppSpacing.tabBarScrollReserve)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, AppSpacing.medium)
            }
        }
        .appSceneBackground(.more)
        .navigationTitle(navTitle)
        .nlNavigationInline()
    }

    // MARK: - Sections

    private var heroSection: some View {
        CategoryHeroVisual(
            assetName: "premium_home_emergency",
            title: navTitle,
            subtitle: heroSubtitle,
            symbol: "phone.fill",
            badgeText: "112",
            accent: AppColors.emergencyRed,
            asset: ContentMediaRegistry.emergencyImage ?? ContentMediaRegistry.healthcareBasicsImage ?? ContentMediaRegistry.officialSourcesHero
        )
    }

    @ViewBuilder
    private var primaryCard: some View {
        if let contact = contacts.first {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white.opacity(0.22))
                            .frame(width: 64, height: 64)
                        Image(systemName: contact.icon)
                            .font(.system(size: 28, weight: .black))
                            .foregroundStyle(.white)
                    }
                    VStack(alignment: .leading, spacing: 5) {
                        Text("112")
                            .font(.system(size: 48, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        Text(contact.title(lang))
                            .font(.system(.subheadline, design: .rounded).weight(.bold))
                            .foregroundStyle(.white.opacity(0.9))
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                }
                .padding(18)

                Divider().overlay(Color.white.opacity(0.2))

                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 13, weight: .bold))
                    Text(contact.whenToUse(lang))
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(.white.opacity(0.9))
                .padding(.horizontal, 18)
                .padding(.vertical, 12)

                VStack(alignment: .leading, spacing: 10) {
                    Text(contact.sourceTitle)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.78))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 8) {
                        if let callURL = contact.callURL {
                            Link(destination: callURL) {
                                Label(callButtonTitle, systemImage: "phone.fill")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.white.opacity(0.2))
                            }
                            .accessibilityIdentifier("emergency.primary.call")
                        }

                        Link(destination: AppURL.safeWebURL(contact.sourceURL)) {
                            Label(sourceButtonTitle, systemImage: "checkmark.shield.fill")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.14))
                        }
                        .accessibilityIdentifier("emergency.primary.source")
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
            }
            .background(
                LinearGradient(
                    colors: [AppColors.emergencyRed, AppColors.emergencyRedDark],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.hero, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.hero, style: .continuous)
                    .stroke(Color.white.opacity(0.22), lineWidth: 0.8)
            )
            .shadow(color: AppColors.emergencyRed.opacity(0.36), radius: 20, x: 0, y: 10)
        }
    }

    private func emergencyContactCard(_ contact: EmergencyContact) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(contact.color.opacity(0.14))
                        .frame(width: 50, height: 50)
                    Image(systemName: contact.icon)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(contact.color)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(contact.title(lang))
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(contact.number)
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(contact.color)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }

                Spacer(minLength: 4)
            }

            emergencyDetailRow(title: whenTitle, text: contact.whenToUse(lang), color: contact.color)
            emergencyDetailRow(title: nextTitle, text: contact.whatHappensNext(lang), color: contact.color)
            emergencyDetailRow(title: disclaimerTitle, text: contact.disclaimer(lang), color: AppColors.warning)

            HStack(spacing: 8) {
                if let callURL = contact.callURL {
                    Link(destination: callURL) {
                        Label(callButtonTitle, systemImage: "phone.fill")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryPremiumButtonStyle())
                    .accessibilityIdentifier("emergency.contact.call.\(contact.id)")
                }

                Link(destination: AppURL.safeWebURL(contact.sourceURL)) {
                    Label(sourceButtonTitle, systemImage: "checkmark.shield.fill")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryPremiumButtonStyle())
                .accessibilityIdentifier("emergency.contact.source.\(contact.id)")
            }
        }
        .appGlassCardStyle(padding: 14, cornerRadius: 20, accent: contact.color)
    }

    private func emergencyDetailRow(title: String, text: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(AppTypography.metadata)
                .foregroundStyle(color)
                .textCase(.uppercase)
            Text(text)
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var disclaimerCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColors.warning)
            Text(disclaimerText)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .appGlassCardStyle(padding: 14, cornerRadius: 16, accent: AppColors.warning)
    }

    // MARK: - Strings

    private var navTitle: String {
        switch lang {
        case .russian: return "Экстренные службы"
        case .dutch:   return "Noodcontacten"
        case .english: return "Emergency contacts"
        }
    }

    private var heroSubtitle: String {
        switch lang {
        case .russian: return "Реальные контакты экстренных служб Нидерландов. 112 — всегда первый шаг при угрозе жизни."
        case .dutch:   return "Echte noodcontacten in Nederland. 112 is altijd de eerste stap bij levensgevaar."
        case .english: return "Real Dutch emergency contacts. 112 is always the first call when life is at risk."
        }
    }

    private var primaryTitle: String {
        switch lang {
        case .russian: return "Главный номер"
        case .dutch:   return "Hoofdnummer"
        case .english: return "Primary number"
        }
    }

    private var primarySubtitle: String {
        switch lang {
        case .russian: return "Вызов экстренных служб при угрозе жизни"
        case .dutch:   return "Nooddiensten bij levensgevaar"
        case .english: return "Emergency services when life is at risk"
        }
    }

    private var otherTitle: String {
        switch lang {
        case .russian: return "Другие контакты"
        case .dutch:   return "Andere contacten"
        case .english: return "Other contacts"
        }
    }

    private var disclaimerText: String {
        switch lang {
        case .russian: return "Информация только справочная. При непосредственной опасности звоните 112. Для важных решений проверяйте официальный источник на карточке."
        case .dutch:   return "Alleen informatieve gids. Bel 112 bij direct gevaar. Controleer voor belangrijke beslissingen de officiële bron op de kaart."
        case .english: return "Informational guidance only. Call 112 for immediate danger. For important decisions, verify the official source shown on each card."
        }
    }

    private var whenTitle: String {
        switch lang {
        case .russian: return "Когда использовать"
        case .dutch: return "Wanneer gebruiken"
        case .english: return "When to use"
        }
    }

    private var nextTitle: String {
        switch lang {
        case .russian: return "Что будет дальше"
        case .dutch: return "Wat gebeurt daarna"
        case .english: return "What happens next"
        }
    }

    private var disclaimerTitle: String {
        switch lang {
        case .russian: return "Важно"
        case .dutch: return "Belangrijk"
        case .english: return "Important"
        }
    }

    private var callButtonTitle: String {
        switch lang {
        case .russian: return "Позвонить"
        case .dutch: return "Bel"
        case .english: return "Call"
        }
    }

    private var sourceButtonTitle: String {
        switch lang {
        case .russian: return "Официальный источник"
        case .dutch: return "Officiële bron"
        case .english: return "Official source"
        }
    }
}

// MARK: - Emergency Contact Model

private struct EmergencyContact: Identifiable {
    let id: String
    let number: String
    let titleEN: String
    let titleNL: String
    let titleRU: String
    let whenEN: String
    let whenNL: String
    let whenRU: String
    let nextEN: String
    let nextNL: String
    let nextRU: String
    let disclaimerEN: String
    let disclaimerNL: String
    let disclaimerRU: String
    let sourceTitle: String
    let sourceURL: URL
    let callURL: URL?
    let icon: String
    let color: Color
    let isPrimary: Bool

    func title(_ lang: AppLanguage) -> String {
        switch lang {
        case .english: return titleEN
        case .dutch:   return titleNL
        case .russian: return titleRU
        }
    }

    func whenToUse(_ lang: AppLanguage) -> String {
        switch lang {
        case .english: return whenEN
        case .dutch:   return whenNL
        case .russian: return whenRU
        }
    }

    func whatHappensNext(_ lang: AppLanguage) -> String {
        switch lang {
        case .english: return nextEN
        case .dutch:   return nextNL
        case .russian: return nextRU
        }
    }

    func disclaimer(_ lang: AppLanguage) -> String {
        switch lang {
        case .english: return disclaimerEN
        case .dutch:   return disclaimerNL
        case .russian: return disclaimerRU
        }
    }
}
