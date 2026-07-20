import SwiftUI

struct SurvivalNavigatorView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var completedEssentialIDs: Set<String> = []

    private var lang: AppLanguage { languageManager.appLanguage }
    private var activePersona: PersonaTag? { appState.selectedUserStatus?.personaTag }
    private var visibleScenarios: [RuleScenario] {
        MockRulesGuideData.scenarios.filter { $0.isVisible(for: activePersona, scope: .currentAndUniversal) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                guideHeader
                calmStartSection
                essentialsSection
                sectionsGrid
                scenariosSection
                DisclaimerBanner(text: L10n.t("disclaimer.short", lang))
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .tabBarScrollReserve()
        }
        .appSceneBackground()
        .navigationTitle(L10n.t("survival_guide.nav_title", lang))
    }

    private var guideHeader: some View {
        CategoryHeroVisual(
            assetName: nil,
            title: L10n.t("survival_guide.title", lang),
            subtitle: profileHint,
            symbol: "heart.text.square.fill",
            badgeText: L10n.t("survival_guide.header_tagline", lang),
            accent: AppColors.warning,
            asset: ContentMediaRegistry.emergencyImage ?? ContentMediaRegistry.healthcareBasicsImage ?? ContentMediaRegistry.officialSourcesHero,
            height: 240,
            language: lang
        )
        .accessibilityIdentifier("survivalNavigator.hero")
    }

    private var calmStartSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            SectionHeader(title: calmStartTitle, subtitle: calmStartSubtitle)

            LazyVGrid(columns: [GridItem(.flexible())], spacing: AppSpacing.small) {
                ForEach(SurvivalStarterItem.localizedItems(lang)) { item in
                    if let sourceURL = AppURL.validatedWebURL(item.sourceURL) {
                        Link(destination: sourceURL) {
                            ProductTaskCard(
                                title: item.title,
                                subtitle: item.body,
                                symbol: item.icon,
                                accent: item.accent,
                                priority: item.sourceName,
                                cta: item.firstAction,
                                minHeight: 112
                            )
                        }
                        .buttonStyle(.plain)
                    } else {
                        ProductTaskCard(
                            title: item.title,
                            subtitle: item.body,
                            symbol: item.icon,
                            accent: item.accent,
                            priority: item.sourceName,
                            cta: item.firstAction,
                            minHeight: 112
                        )
                    }
                }
            }
        }
    }

    private var sectionsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.small) {
            ForEach(appState.prioritizedGuideSections) { section in
                NavigationLink(value: appState.destination(for: section)) {
                    VStack(alignment: .leading, spacing: 8) {
                        Image(systemName: section.icon)
                            .font(.title3)
                            .foregroundStyle(AppColors.accent)
                        Text(section.title(lang))
                            .font(AppTypography.bodyStrong)
                            .foregroundStyle(AppColors.textPrimary)
                        Text(appState.sectionSummary(section, language: lang))
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
                    .appCardStyle()
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var essentialsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            SectionHeader(title: essentialsTitle, subtitle: essentialsSubtitle)
            ForEach(SurvivalEssentialStep.items(lang)) { item in
                HStack(alignment: .top, spacing: AppSpacing.small) {
                    Button {
                        toggleEssentialStep(item)
                    } label: {
                        Image(systemName: completedEssentialIDs.contains(item.id) ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(completedEssentialIDs.contains(item.id) ? AppColors.success : AppColors.textTertiary)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(completedEssentialIDs.contains(item.id) ? "Completed" : "Not completed")

                    if let sourceURL = AppURL.validatedWebURL(item.sourceURL) {
                        Link(destination: sourceURL) {
                            ProductTaskCard(
                                title: item.title,
                                subtitle: item.detail,
                                symbol: item.icon,
                                accent: completedEssentialIDs.contains(item.id) ? AppColors.success : AppColors.accent,
                                priority: item.sourceName,
                                minHeight: 96
                            )
                        }
                        .buttonStyle(.plain)
                    } else {
                        ProductTaskCard(
                            title: item.title,
                            subtitle: item.detail,
                            symbol: item.icon,
                            accent: completedEssentialIDs.contains(item.id) ? AppColors.success : AppColors.accent,
                            priority: item.sourceName,
                            minHeight: 96
                        )
                    }
                }
            }
        }
    }

    private func toggleEssentialStep(_ item: SurvivalEssentialStep) {
        if completedEssentialIDs.contains(item.id) {
            completedEssentialIDs.remove(item.id)
        } else {
            completedEssentialIDs.insert(item.id)
        }
    }

    private var scenariosSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            SectionHeader(title: L10n.t("fines.scenarios_title", lang), subtitle: L10n.t("survival_guide.scenarios_subtitle", lang))
            ForEach(visibleScenarios) { scenario in
                NavigationLink(value: AppDestination.ruleScenario(scenario.id)) {
                    HStack(spacing: AppSpacing.small) {
                        Image(systemName: "bolt.horizontal.circle")
                            .foregroundStyle(AppColors.warning)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(scenario.title)
                                .font(AppTypography.bodyStrong)
                                .foregroundStyle(AppColors.textPrimary)
                            Text(scenario.institution)
                                .font(AppTypography.caption)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(AppColors.textTertiary)
                    }
                    .appCardStyle()
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var calmStartTitle: String {
        switch lang {
        case .russian: return "Сначала спокойно"
        case .dutch: return "Eerst rustig"
        case .english: return "Start calm"
        }
    }

    private var calmStartSubtitle: String {
        switch lang {
        case .russian: return "Короткий путь от «где безопасно быть сегодня» до документов и поддержки."
        case .dutch: return "Een korte route van veilig slapen vandaag naar documenten en steun."
        case .english: return "A short route from safe shelter today to documents and support."
        }
    }

    private var essentialsTitle: String {
        switch lang {
        case .russian: return "3 основы без перегруза"
        case .dutch: return "3 basisstappen zonder druk"
        case .english: return "3 basics without overload"
        }
    }

    private var essentialsSubtitle: String {
        switch lang {
        case .russian: return "Отметьте, что уже понятно. Открывайте официальный источник только когда готовы."
        case .dutch: return "Vink af wat duidelijk is. Open de officiële bron pas als je er klaar voor bent."
        case .english: return "Tick what is clear. Open the official source only when you are ready."
        }
    }

    private var profileHint: String {
        guard let status = appState.selectedUserStatus else {
            return L10n.t("survival_guide.pick_situation", lang)
        }
        return String(format: L10n.t("survival_guide.focused_for", lang), status.localized(lang))
    }
}

struct RuleScenarioDetailView: View {
    let scenario: RuleScenario
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                PremiumImageHeader(
                    title: scenario.title,
                    asset: scenarioImageAsset,
                    language: lang,
                    symbol: scenarioSymbol,
                    accent: scenarioAccent,
                    height: 210,
                    cornerRadius: 22,
                    fallbackCategory: scenarioFallbackCategory
                )
                .appCardStyle()

                InfoCard(title: L10n.t("rule.scenario.what_means", lang), subtitle: scenario.title, detail: scenario.meaning, icon: "info.circle")
                InfoCard(title: L10n.t("rule.scenario.dont_panic", lang), subtitle: L10n.t("rule.scenario.what_to_know", lang), detail: scenario.doNotPanic, icon: "heart.text.square")

                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    SectionHeader(title: L10n.t("rule.scenario.next_steps", lang))
                    ForEach(scenario.nextSteps, id: \.self) { step in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(AppColors.success)
                            Text(step).font(AppTypography.body).foregroundStyle(AppColors.textPrimary)
                        }
                    }
                }
                .appCardStyle()

                if let sourceURL = AppURL.validatedWebURL(scenario.officialSourceURL) {
                    Link(destination: sourceURL) {
                        Label(L10n.t("beginner.open_official_source", lang), systemImage: "arrow.up.right.square")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppColors.accent)
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .tabBarScrollReserve()
        }
        .appSceneBackground()
        .navigationTitle(scenario.title)
    }

    private var scenarioImageAsset: AppImageAsset? {
        let source = normalizedScenarioSource
        if source.contains("transport") || source.contains("bicycle") {
            return ContentMediaRegistry.transportHero ?? ContentMediaRegistry.ovChipkaartImage ?? ContentMediaRegistry.officialSourcesHero
        }
        if source.contains("landlord") || source.contains("housing") || source.contains("rent") {
            return ContentMediaRegistry.premiumHousingImage ?? ContentMediaRegistry.housingTerracedHousesImage ?? ContentMediaRegistry.officialSourcesHero
        }
        if source.contains("tax") || source.contains("belasting") || source.contains("employer") || source.contains("labour") {
            return ContentMediaRegistry.workImage ?? ContentMediaRegistry.officialSourcesHero
        }
        if source.contains("crashed") || source.contains("police") || source.contains("fake") || source.contains("fraud") || source.contains("cjib") {
            return ContentMediaRegistry.emergencyImage ?? ContentMediaRegistry.officialSourcesHero
        }
        if source.contains("bsn") || source.contains("municipality") {
            return ContentMediaRegistry.municipalityCityHallImage ?? ContentMediaRegistry.officialSourcesHero
        }
        return ContentMediaRegistry.officialSourcesHero
    }

    private var scenarioFallbackCategory: PremiumImageFallbackCategory {
        let source = normalizedScenarioSource
        if source.contains("transport") || source.contains("bicycle") { return .transport }
        if source.contains("landlord") || source.contains("housing") || source.contains("rent") { return .housing }
        if source.contains("tax") || source.contains("belasting") || source.contains("employer") || source.contains("labour") { return .work }
        if source.contains("crashed") || source.contains("police") || source.contains("fake") || source.contains("fraud") || source.contains("cjib") { return .emergency }
        if source.contains("bsn") || source.contains("municipality") { return .government }
        return .documents
    }

    private var scenarioSymbol: String {
        switch scenarioFallbackCategory {
        case .transport: return "tram.fill"
        case .housing: return "house.fill"
        case .work: return "briefcase.fill"
        case .emergency: return "exclamationmark.triangle.fill"
        case .government: return "building.columns.fill"
        default: return "checklist.checked"
        }
    }

    private var scenarioAccent: Color {
        switch scenarioFallbackCategory {
        case .transport: return AppColors.dutchOrange
        case .housing: return AppColors.emerald
        case .work: return AppColors.violet
        case .emergency: return AppColors.warning
        case .government: return AppColors.routeLine
        default: return AppColors.accent
        }
    }

    private var normalizedScenarioSource: String {
        "\(scenario.title) \(scenario.institution)"
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .lowercased()
    }
}

private struct SurvivalStarterItem: Identifiable {
    let id: String
    let icon: String
    let accent: Color
    let title: String
    let body: String
    let firstAction: String
    let sourceName: String
    let sourceURL: URL?

    static func localizedItems(_ lang: AppLanguage) -> [SurvivalStarterItem] {
        switch lang {
        case .russian:
            return [
                item("tonight", "bed.double.fill", AppColors.gradEmergency, "Сегодня: где быть безопасно", "Если нет безопасного места, не ищите идеальный ответ в одиночку. Начните с gemeente, 112 при прямой опасности, или местной экстренной помощи.", "Сохранить адрес, имя службы и время следующего контакта.", "Government.nl", "https://www.government.nl/faq/assistance-at-home-from-my-municipality"),
                item("identity", "person.text.rectangle.fill", AppColors.gradDocs, "Паспорт / ID", "Оригинальный действующий документ важен для проверок, банка, медицины и официальных действий. Копия обычно не заменяет оригинал.", "Держать оригинал доступным и отдельно сохранить защищённую копию.", "Government.nl", "https://www.government.nl/themes/justice-security-and-defence/identification-documents/compulsory-identification"),
                item("registration", "number.circle.fill", AppColors.gradGovernment, "Регистрация и BSN", "BRP-регистрация и BSN открывают путь к госуслугам, медицине, налогам и многим бытовым шагам.", "Проверить страницу своей gemeente и ближайшую запись.", "Government.nl", "https://www.government.nl/faq/what-do-i-need-to-arrange-if-im-moving-to-the-netherlands"),
                item("health", "cross.case.fill", AppColors.gradHealth, "Здоровье без паники", "Сначала различайте: 112 для прямой угрозы жизни, huisarts для обычной медицины, аптека для лекарств.", "Записать местный huisarts/huisartsenpost и аптеку рядом.", "Government.nl", "https://www.government.nl/themes/family-health-and-care"),
                item("teen", "figure.2.and.child.holdinghands", AppColors.gradEducation, "Подросткам и молодым", "Переезд, язык и документы могут перегружать. Нужны ритм дня, школа/учёба, взрослый контакт и место, где можно задать вопрос без стыда.", "Выбрать одного взрослого/службу, кому можно написать при стрессе.", "Nederlands Jeugdinstituut", "https://www.nji.nl/vluchtelingen/ondersteuning-gevluchte-kinderen-jongeren"),
                item("scams", "shield.lefthalf.filled", AppColors.gradTransport, "Не платить из страха", "Фальшивые сообщения часто давят срочностью: штраф, банк, жильё, CJIB. Проверяйте домен и открывайте сайт вручную.", "Не нажимать ссылку из SMS; сверить через официальный сайт.", "Fraudehelpdesk", "https://www.fraudehelpdesk.nl")
            ]
        case .dutch:
            return [
                item("tonight", "bed.double.fill", AppColors.gradEmergency, "Vandaag: veilig blijven", "Geen veilige plek? Zoek niet alleen naar het perfecte antwoord. Begin bij de gemeente, 112 bij direct gevaar, of lokale noodhulp.", "Bewaar adres, naam van de dienst en volgende contacttijd.", "Government.nl", "https://www.government.nl/faq/assistance-at-home-from-my-municipality"),
                item("identity", "person.text.rectangle.fill", AppColors.gradDocs, "Paspoort / ID", "Een origineel geldig document is belangrijk voor controles, bank, zorg en officiële stappen. Een kopie vervangt meestal niet het origineel.", "Houd het origineel bereikbaar en bewaar een beveiligde kopie apart.", "Government.nl", "https://www.government.nl/themes/justice-security-and-defence/identification-documents/compulsory-identification"),
                item("registration", "number.circle.fill", AppColors.gradGovernment, "Registratie en BSN", "BRP-registratie en BSN geven toegang tot overheid, zorg, belasting en veel praktische stappen.", "Controleer je gemeentepagina en eerstvolgende afspraak.", "Government.nl", "https://www.government.nl/faq/what-do-i-need-to-arrange-if-im-moving-to-the-netherlands"),
                item("health", "cross.case.fill", AppColors.gradHealth, "Zorg zonder paniek", "Maak onderscheid: 112 bij levensgevaar, huisarts voor gewone zorg, apotheek voor medicijnen.", "Noteer huisarts/huisartsenpost en apotheek dichtbij.", "Government.nl", "https://www.government.nl/themes/family-health-and-care"),
                item("teen", "figure.2.and.child.holdinghands", AppColors.gradEducation, "Tieners en jongeren", "Verhuizen, taal en papieren kunnen veel zijn. Ritme, school/studie, een vertrouwde volwassene en vraagruimte helpen.", "Kies een volwassene of dienst die je bij stress kunt berichten.", "Nederlands Jeugdinstituut", "https://www.nji.nl/vluchtelingen/ondersteuning-gevluchte-kinderen-jongeren"),
                item("scams", "shield.lefthalf.filled", AppColors.gradTransport, "Betaal niet uit angst", "Nepberichten gebruiken haast: boete, bank, kamer, CJIB. Controleer domein en open de website zelf.", "Klik niet op sms-links; controleer via de officiële site.", "Fraudehelpdesk", "https://www.fraudehelpdesk.nl")
            ]
        case .english:
            return [
                item("tonight", "bed.double.fill", AppColors.gradEmergency, "Today: stay safe", "If you do not have a safe place, do not solve it alone. Start with the municipality, 112 for immediate danger, or local emergency support.", "Save the address, service name, and next contact time.", "Government.nl", "https://www.government.nl/faq/assistance-at-home-from-my-municipality"),
                item("identity", "person.text.rectangle.fill", AppColors.gradDocs, "Passport / ID", "An original valid document matters for checks, banking, healthcare, and official steps. A copy usually does not replace the original.", "Keep the original reachable and store a protected copy separately.", "Government.nl", "https://www.government.nl/themes/justice-security-and-defence/identification-documents/compulsory-identification"),
                item("registration", "number.circle.fill", AppColors.gradGovernment, "Registration and BSN", "BRP registration and BSN unlock government services, healthcare, tax, and many practical steps.", "Check your municipality page and the earliest appointment.", "Government.nl", "https://www.government.nl/faq/what-do-i-need-to-arrange-if-im-moving-to-the-netherlands"),
                item("health", "cross.case.fill", AppColors.gradHealth, "Healthcare without panic", "Separate the routes: 112 for immediate danger, huisarts for regular care, pharmacy for medicine.", "Write down a nearby huisarts/huisartsenpost and pharmacy.", "Government.nl", "https://www.government.nl/themes/family-health-and-care"),
                item("teen", "figure.2.and.child.holdinghands", AppColors.gradEducation, "Teens and young people", "Moving, language, and paperwork can overload anyone. Daily rhythm, school/study, a trusted adult, and a place to ask help.", "Choose one adult or service you can message when stress rises.", "Nederlands Jeugdinstituut", "https://www.nji.nl/vluchtelingen/ondersteuning-gevluchte-kinderen-jongeren"),
                item("scams", "shield.lefthalf.filled", AppColors.gradTransport, "Do not pay from fear", "Fake messages use urgency: fine, bank, housing, CJIB. Check the domain and open the official site yourself.", "Do not tap SMS links; verify through the official website.", "Fraudehelpdesk", "https://www.fraudehelpdesk.nl")
            ]
        }
    }

    private static func item(_ id: String, _ icon: String, _ colors: [Color], _ title: String, _ body: String, _ firstAction: String, _ sourceName: String, _ source: String) -> SurvivalStarterItem {
        SurvivalStarterItem(id: id, icon: icon, accent: colors.first ?? AppColors.accent, title: title, body: body, firstAction: firstAction, sourceName: sourceName, sourceURL: AppURL.validatedWebURL(URL(string: source)))
    }
}

private struct SurvivalEssentialStep: Identifiable {
    let id: String
    let icon: String
    let title: String
    let detail: String
    let sourceName: String
    let sourceURL: URL?

    static func items(_ lang: AppLanguage) -> [SurvivalEssentialStep] {
        [
            item("bsn", "number.circle.fill", text(lang, "BSN и регистрация", "BSN en registratie", "BSN and registration"), text(lang, "Нужны для госуслуг, медицины, налогов и многих бытовых шагов.", "Nodig voor overheid, zorg, belasting en veel praktische stappen.", "Needed for government services, healthcare, tax, and many practical steps."), "Government.nl", "https://www.government.nl/faq/what-do-i-need-to-arrange-if-im-moving-to-the-netherlands"),
            item("digid", "key.fill", text(lang, "DigiD", "DigiD", "DigiD"), text(lang, "Ваш цифровой вход в государственные сервисы. Никому не передавайте логин.", "Je digitale toegang tot overheidsdiensten. Deel je login nooit.", "Your digital access to government services. Never share your login."), "DigiD", "https://www.digid.nl/en"),
            item("insurance", "cross.case.fill", text(lang, "Страховка и huisarts", "Verzekering en huisarts", "Insurance and huisarts"), text(lang, "Проверьте, нужна ли базовая страховка, и где рядом обычная медицинская помощь.", "Controleer of basisverzekering nodig is en waar gewone zorg dichtbij is.", "Check whether basic insurance is needed and where regular care is nearby."), "Government.nl", "https://www.government.nl/topics/health-insurance")
        ]
    }

    private static func item(_ id: String, _ icon: String, _ title: String, _ detail: String, _ sourceName: String, _ source: String) -> SurvivalEssentialStep {
        SurvivalEssentialStep(id: id, icon: icon, title: title, detail: detail, sourceName: sourceName, sourceURL: AppURL.validatedWebURL(URL(string: source)))
    }

    private static func text(_ lang: AppLanguage, _ ru: String, _ nl: String, _ en: String) -> String {
        switch lang {
        case .russian: return ru
        case .dutch: return nl
        case .english: return en
        }
    }
}
