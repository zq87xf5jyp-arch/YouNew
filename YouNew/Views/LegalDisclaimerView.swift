import SwiftUI

struct LegalDisclaimerView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                header
                section(title: educationalTitle) {
                    disclaimerRow(icon: "graduationcap.fill", title: educationalOnlyTitle, detail: educationalOnlyDetail)
                    disclaimerRow(icon: "scalemass.fill", title: notLegalAdviceTitle, detail: notLegalAdviceDetail)
                }
                section(title: sourceTitle) {
                    disclaimerRow(icon: "building.columns.fill", title: officialSourceTitle, detail: officialSourceDetail)
                    disclaimerRow(icon: "calendar.badge.exclamationmark", title: changingRulesTitle, detail: changingRulesDetail)
                }
                section(title: responsibilityTitle) {
                    disclaimerRow(icon: "person.fill.checkmark", title: userDecisionTitle, detail: userDecisionDetail)
                    disclaimerRow(icon: "exclamationmark.triangle.fill", title: noGuaranteeTitle, detail: noGuaranteeDetail)
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .tabBarScrollReserve()
        }
        .appSceneBackground()
        .navigationTitle(title)
        .nlNavigationInline()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            CategoryHeroVisual(
                assetName: nil,
                title: title,
                subtitle: headerSummary,
                symbol: "shield.checkered",
                badgeText: disclaimerBadgeText,
                accent: AppColors.warning,
                asset: ContentMediaRegistry.municipalityCityHallImage ?? ContentMediaRegistry.officialSourcesHero,
                height: 240,
                language: lang
            )

            Text(headerDetail)
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text(title.uppercased())
                .font(AppTypography.metadata)
                .tracking(0.5)
                .foregroundStyle(AppColors.textTertiary)
                .padding(.horizontal, 4)
            VStack(spacing: AppSpacing.xSmall) {
                content()
            }
        }
    }

    private func disclaimerRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.medium) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColors.warning)
                .frame(width: 40, height: 40)
                .background(AppColors.warning.opacity(0.12))
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
            Spacer(minLength: 0)
        }
        .appCardStyle()
    }
}

private extension LegalDisclaimerView {
    var title: String {
        switch lang {
        case .russian: return "Юридический дисклеймер"
        case .english: return "Legal Disclaimer"
        case .dutch: return "Juridische disclaimer"
        }
    }

    var headerDetail: String {
        switch lang {
        case .russian: return "YouNew.nl помогает ориентироваться в правилах, документах и официальных источниках, но не заменяет профессиональную или государственную консультацию."
        case .english: return "YouNew.nl helps with orientation around rules, documents and official sources, but does not replace professional or government advice."
        case .dutch: return "YouNew.nl helpt bij oriëntatie rond regels, documenten en officiële bronnen, maar vervangt geen professioneel of overheidsadvies."
        }
    }

    var headerSummary: String {
        switch lang {
        case .russian: return "Проверяйте важные решения в официальных источниках."
        case .english: return "Verify important decisions with official sources."
        case .dutch: return "Controleer belangrijke beslissingen bij officiële bronnen."
        }
    }

    var disclaimerBadgeText: String {
        switch lang {
        case .russian: return "Информация"
        case .english: return "Information only"
        case .dutch: return "Alleen informatie"
        }
    }

    var educationalTitle: String { lang == .russian ? "Назначение" : (lang == .dutch ? "Doel" : "Purpose") }
    var educationalOnlyTitle: String { lang == .russian ? "Только образовательная информация" : (lang == .dutch ? "Alleen educatieve informatie" : "Educational information only") }
    var educationalOnlyDetail: String { lang == .russian ? "Контент предназначен для ориентации и подготовки вопросов к официальным источникам." : (lang == .dutch ? "Content is bedoeld voor oriëntatie en voorbereiding van vragen aan officiële bronnen." : "Content is intended for orientation and preparing questions for official sources.") }
    var notLegalAdviceTitle: String { lang == .russian ? "Не юридическая консультация" : (lang == .dutch ? "Geen juridisch advies" : "Not legal advice") }
    var notLegalAdviceDetail: String { lang == .russian ? "Приложение не заменяет юриста, gemeente, IND, CJIB, Belastingdienst, RDW или медицинского специалиста." : (lang == .dutch ? "De app vervangt geen advocaat, gemeente, IND, CJIB, Belastingdienst, RDW of medische professional." : "The app does not replace a lawyer, gemeente, IND, CJIB, Belastingdienst, RDW or medical professional.") }
    var sourceTitle: String { lang == .russian ? "Источники" : (lang == .dutch ? "Bronnen" : "Sources") }
    var officialSourceTitle: String { lang == .russian ? "Проверяйте официальные учреждения" : (lang == .dutch ? "Controleer officiële instanties" : "Verify official institutions") }
    var officialSourceDetail: String { lang == .russian ? "Перед оплатой, обжалованием, подачей заявления или юридическим действием сверяйтесь с официальным сайтом или учреждением." : (lang == .dutch ? "Controleer officiële websites of instanties voordat u betaalt, bezwaar maakt, aanvraagt of juridisch handelt." : "Before paying, objecting, applying or taking legal action, verify with an official website or institution.") }
    var changingRulesTitle: String { lang == .russian ? "Правила и суммы меняются" : (lang == .dutch ? "Regels en bedragen wijzigen" : "Rules and amounts change") }
    var changingRulesDetail: String { lang == .russian ? "Штрафы, сроки, процедуры и требования могут измениться после публикации материала." : (lang == .dutch ? "Boetes, termijnen, procedures en vereisten kunnen wijzigen na publicatie." : "Fines, deadlines, procedures and requirements may change after content publication.") }
    var responsibilityTitle: String { lang == .russian ? "Ответственность" : (lang == .dutch ? "Verantwoordelijkheid" : "Responsibility") }
    var userDecisionTitle: String { lang == .russian ? "Решение принимает пользователь" : (lang == .dutch ? "Gebruiker beslist" : "User decides") }
    var userDecisionDetail: String { lang == .russian ? "YouNew.nl может подсказать следующий шаг, но пользователь отвечает за проверку и выполнение действий." : (lang == .dutch ? "YouNew.nl kan een volgende stap suggereren, maar de gebruiker is verantwoordelijk voor controle en uitvoering." : "YouNew.nl may suggest a next step, but the user is responsible for verification and action.") }
    var noGuaranteeTitle: String { lang == .russian ? "Нет гарантии точности" : (lang == .dutch ? "Geen nauwkeurigheidsgarantie" : "No accuracy guarantee") }
    var noGuaranteeDetail: String { lang == .russian ? "Мы не обещаем полноту, юридическую применимость или актуальность каждой суммы, правила или процедуры." : (lang == .dutch ? "Wij garanderen niet de volledigheid, juridische toepasbaarheid of actualiteit van elk bedrag, regel of procedure." : "We do not guarantee completeness, legal applicability or current accuracy of every amount, rule or procedure.") }
}
