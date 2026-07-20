import SwiftUI

struct FirstStepsView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.openURL) private var openURL

    private var lang: AppLanguage { languageManager.appLanguage }
    private var activePersona: PersonaTag? { appState.selectedUserStatus?.personaTag }
    private var items: [FirstStepItem] {
        [
            FirstStepItem(
                id: "first-steps",
                icon: AppIcons.checklist,
                title: localized(en: "First steps in the Netherlands", nl: "Eerste stappen in Nederland", ru: "Первые шаги в Нидерландах"),
                subtitle: localized(en: "Set up address, documents, phone access, official portals, care, money, and transport.", nl: "Regel adres, documenten, telefoon, officiële portalen, zorg, geld en vervoer.", ru: "Настройте адрес, документы, телефон, официальные порталы, медицину, деньги и транспорт."),
                destination: .practicalGuide(.firstStepsNetherlands),
                sourceURL: AppURL.make("https://www.government.nl/topics/municipalities"),
                tint: AppColors.success
            ),
            FirstStepItem(
                id: "registration",
                icon: "person.badge.plus.fill",
                title: localized(en: "Municipality registration", nl: "Inschrijving bij gemeente", ru: "Регистрация в муниципалитете"),
                subtitle: localized(en: "Register your address and confirm BSN-related steps with your gemeente.", nl: "Schrijf je adres in en controleer BSN-stappen bij je gemeente.", ru: "Зарегистрируйте адрес и проверьте шаги по BSN в муниципалитете."),
                destination: .practicalGuide(.municipalityRegistration),
                sourceURL: nil,
                tint: AppColors.routeLine
            ),
            FirstStepItem(
                id: "digid",
                icon: "lock.shield.fill",
                title: "DigiD",
                subtitle: localized(en: "Use only the official DigiD domain and avoid login links in unexpected messages.", nl: "Gebruik alleen het officiële DigiD-domein en vermijd loginlinks in onverwachte berichten.", ru: "Используйте только официальный домен DigiD и не открывайте ссылки входа из неожиданных сообщений."),
                destination: .practicalGuide(.digidSafety),
                sourceURL: AppURL.make("https://www.digid.nl/en"),
                tint: AppColors.cyanGlow
            ),
            FirstStepItem(
                id: "healthcare-basics",
                icon: "cross.case.fill",
                title: localized(en: "Healthcare basics", nl: "Basiszorg", ru: "Базовая медицина"),
                subtitle: localized(en: "Understand GP, pharmacy, urgent care, hospital referrals, and insurance links.", nl: "Begrijp huisarts, apotheek, spoedzorg, verwijzingen en zorgverzekering.", ru: "Разберитесь с huisarts, аптекой, срочной помощью, направлениями и страховкой."),
                destination: .practicalGuide(.healthcareBasics),
                sourceURL: AppURL.make("https://www.government.nl/topics/health-insurance"),
                tint: AppColors.error
            ),
            FirstStepItem(
                id: "huisarts",
                icon: "stethoscope",
                title: localized(en: "Finding a huisarts", nl: "Een huisarts vinden", ru: "Как найти huisarts"),
                subtitle: localized(en: "Try practices near your registered address and ask your insurer or municipality if lists are full.", nl: "Probeer praktijken bij je inschrijfadres en vraag verzekeraar of gemeente als lijsten vol zijn.", ru: "Пробуйте практики рядом с адресом регистрации; если списки полны, спросите страховщика или gemeente."),
                destination: .practicalGuide(.findingHuisarts),
                sourceURL: AppURL.make("https://www.government.nl/topics/health-insurance"),
                tint: AppColors.error
            ),
            FirstStepItem(
                id: "health-insurance",
                icon: "checkmark.shield.fill",
                title: localized(en: "Health insurance basics", nl: "Basis zorgverzekering", ru: "Основы медицинской страховки"),
                subtitle: localized(en: "Check whether Dutch basic insurance applies, compare policies, and watch eigen risico.", nl: "Controleer of basisverzekering geldt, vergelijk polissen en let op eigen risico.", ru: "Проверьте, нужна ли базовая страховка, сравните полисы и eigen risico."),
                destination: .practicalGuide(.healthInsuranceBasics),
                sourceURL: AppURL.make("https://www.government.nl/topics/health-insurance"),
                tint: AppColors.success
            ),
            FirstStepItem(
                id: "transport",
                icon: "tram.fill",
                title: localized(en: "Transport", nl: "Vervoer", ru: "Транспорт"),
                subtitle: localized(en: "Learn check-in rules, route planning, and local operators before commuting.", nl: "Leer incheckregels, routeplanning en lokale vervoerders voordat je reist.", ru: "Изучите правила check-in, маршруты и местных операторов перед поездками."),
                destination: .practicalGuide(.transportBasics),
                sourceURL: AppURL.make("https://www.government.nl/topics/mobility-public-transport-and-road-safety"),
                tint: AppColors.dutchOrange
            ),
            FirstStepItem(
                id: "housing",
                icon: "house.lodge.fill",
                title: localized(en: "Housing basics", nl: "Wonen basis", ru: "Жильё: основы"),
                subtitle: localized(en: "Check rental terms, address registration permission, deposits, and city rules.", nl: "Controleer huurvoorwaarden, inschrijfmogelijkheid, borg en stadsregels.", ru: "Проверьте договор, возможность регистрации, депозит и городские правила."),
                destination: .practicalGuide(.housingBasics),
                sourceURL: AppURL.make("https://www.government.nl/themes/building-and-housing/housing"),
                tint: AppColors.violet
            ),
            FirstStepItem(
                id: "knm",
                icon: "graduationcap.fill",
                title: "KNM",
                subtitle: localized(en: "Study Dutch society topics with modules, key terms, and app-created practice questions.", nl: "Leer KNM-thema's met modules, woorden en oefenvragen van de app.", ru: "Изучайте темы KNM с модулями, важными словами и тренировочными вопросами."),
                destination: .knm,
                sourceURL: AppURL.make("https://www.inburgeren.nl/en/taking-the-integration-exam/content-knowledge-exams.jsp"),
                tint: AppColors.cyanGlow
            ),
            FirstStepItem(
                id: "dutch-a1-a2",
                icon: "text.book.closed.fill",
                title: localized(en: "Dutch A1-A2", nl: "Nederlands A1-A2", ru: "Нидерландский A1-A2"),
                subtitle: localized(en: "Learn practical Dutch words, phrases, grammar, and mini tests for daily life.", nl: "Leer praktische woorden, zinnen, grammatica en minitoetsen voor dagelijks leven.", ru: "Учите практические слова, фразы, грамматику и мини-тесты для повседневной жизни."),
                destination: .dutchA1A2,
                sourceURL: AppURL.make("https://www.coe.int/en/web/portfolio/self-assessment-grid"),
                tint: AppColors.emerald
            ),
            FirstStepItem(
                id: "banking",
                icon: "creditcard.fill",
                title: localized(en: "Banking basics", nl: "Bankieren basis", ru: "Основы банков"),
                subtitle: localized(en: "Prepare ID, address, BSN context, IBAN needs, and secure authentication.", nl: "Bereid ID, adres, BSN-context, IBAN-behoefte en veilige authenticatie voor.", ru: "Подготовьте ID, адрес, контекст BSN, IBAN и безопасный вход."),
                destination: .practicalGuide(.bankingBasics),
                sourceURL: AppURL.make("https://www.betaalvereniging.nl/en/"),
                tint: AppColors.softBlue
            ),
            FirstStepItem(
                id: "sources",
                icon: AppIcons.officialSource,
                title: localized(en: "Official sources", nl: "Officiële bronnen", ru: "Официальные источники"),
                subtitle: localized(en: "Use YouNew.nl as orientation, then verify important actions at official sources.", nl: "Gebruik YouNew.nl als oriëntatie en controleer belangrijke acties bij officiële bronnen.", ru: "Используйте YouNew.nl для ориентира, а важные действия проверяйте в официальных источниках."),
                destination: .practicalGuide(.officialSourcesChecklist),
                sourceURL: nil,
                tint: AppColors.success
            )
        ]
    }
    private var visibleItems: [FirstStepItem] {
        items.filter { item in
            guard let destination = item.destination else { return true }
            return RelatedContentEngine.isVisible(destination, for: activePersona)
        }
    }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 920) {
                LazyVStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    headerSection
                    stepsSection
                    verifyNote
                    Color.clear.frame(height: AppSpacing.tabBarScrollReserve)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, AppSpacing.medium)
            }
        }
        .appSceneBackground()
        .navigationTitle(titleText)
        .nlNavigationInline()
        .accessibilityIdentifier("firstSteps.screen")
    }

    private var headerSection: some View {
        CategoryHeroVisual(
            assetName: "premium_home_documents",
            title: titleText,
            subtitle: subtitleText,
            symbol: AppIcons.checklist,
            badgeText: badgeText,
            accent: AppColors.success,
            asset: ContentMediaRegistry.profileImage ?? ContentMediaRegistry.officialSourcesHero
        )
    }

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: sectionTitle)

            LazyVStack(spacing: AppSpacing.small) {
                ForEach(visibleItems) { item in
                    firstStepCard(item)
                }
            }
        }
    }

    private func firstStepCard(_ item: FirstStepItem) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            HStack(alignment: .top, spacing: AppSpacing.medium) {
                Image(systemName: item.icon)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(item.tint)
                    .frame(width: 42, height: 42)
                    .background(item.tint.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(2)
                    Text(item.subtitle)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)
            }

            HStack(spacing: AppSpacing.small) {
                if let destination = item.destination {
                    NavigationLink(value: destination) {
                        actionLabel(localized(en: "Open guide", nl: "Open gids", ru: "Открыть гид"), icon: "arrow.right.circle.fill")
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("firstSteps.detailLink.\(item.id)")
                }

                if let sourceURL = AppURL.validatedWebURL(item.sourceURL) {
                    Button {
                        openURL(sourceURL)
                    } label: {
                        actionLabel(localized(en: "Official source", nl: "Officiële bron", ru: "Официальный источник"), icon: AppIcons.external)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .appCardStyle()
    }

    private func actionLabel(_ title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
            Text(title)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.82)
        }
        .foregroundStyle(AppColors.cyanGlow)
        .padding(.horizontal, 11)
        .padding(.vertical, 8)
        .background(AppColors.cyanGlow.opacity(0.10))
        .clipShape(Capsule())
    }

    private var verifyNote: some View {
        DisclaimerBanner(text: localized(
            en: "Information only. Rules can change. Always verify important steps with official sources.",
            nl: "Alleen informatie. Regels kunnen veranderen. Controleer belangrijke stappen altijd bij officiële bronnen.",
            ru: "Только информация. Правила могут меняться. Всегда проверяйте важные шаги в официальных источниках."
        ))
    }

    private func localized(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }

    private var titleText: String { localized(en: "First steps", nl: "Eerste stappen", ru: "Первые шаги") }
    private var subtitleText: String {
        localized(
            en: "A practical starting checklist for the first days and weeks in the Netherlands.",
            nl: "Een praktische startlijst voor de eerste dagen en weken in Nederland.",
            ru: "Практический стартовый список на первые дни и недели в Нидерландах."
        )
    }
    private var badgeText: String { localized(en: "Start", nl: "Start", ru: "Старт") }
    private var sectionTitle: String { localized(en: "What to handle first", nl: "Wat eerst regelen", ru: "Что сделать сначала") }
}

private struct FirstStepItem: Identifiable {
    let id: String
    let icon: String
    let title: String
    let subtitle: String
    let destination: AppDestination?
    let sourceURL: URL?
    let tint: Color
}

struct PracticalGuideView: View {
    let topic: PracticalGuideTopic
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.openURL) private var openURL

    private var lang: AppLanguage { languageManager.appLanguage }
    private var activePersona: PersonaTag? { appState.selectedUserStatus?.personaTag }
    private var content: PracticalGuideContent { topic.content(lang).enriched(for: topic, lang: lang) }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 920) {
                LazyVStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    headerSection
                    meaningSection
                    checklistSection
                    verifySection
                    commonMistakesSection
                    dutchWordsSection
                    relatedActionsSection
                    sourceSection
                    updatedSection
                    Color.clear.frame(height: AppSpacing.tabBarScrollReserve)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, AppSpacing.medium)
            }
        }
        .appSceneBackground()
        .navigationTitle(content.title)
        .nlNavigationInline()
        .accessibilityIdentifier("practicalGuide.\(topic.rawValue)")
    }

    private var headerSection: some View {
        CategoryHeroVisual(
            assetName: topicHeroAssetName,
            title: content.title,
            subtitle: content.subtitle,
            symbol: content.icon,
            badgeText: content.badge,
            accent: content.tint,
            asset: topicHeroAsset
        )
    }

    private var topicHeroAssetName: String? {
        switch topic {
        case .firstStepsNetherlands:
            return "premium_home_documents"
        case .municipalityRegistration:
            return "home_documents_city_hall"
        case .healthcareBasics:
            return "premium_home_healthcare"
        case .findingHuisarts:
            return "home_healthcare_pharmacy"
        case .healthInsuranceBasics:
            return "premium_home_documents"
        case .transportBasics:
            return nil
        case .housingBasics:
            return "premium_home_housing"
        case .digidSafety:
            return "premium_home_language"
        case .officialSourcesChecklist:
            return "home_leiden_canals"
        case .bankingBasics:
            return "premium_home_work"
        }
    }

    private var topicHeroAsset: AppImageAsset? {
        switch topic {
        case .municipalityRegistration:
            return ContentMediaRegistry.municipalityCityHallImage
        case .findingHuisarts:
            return ContentMediaRegistry.healthcarePharmacyImage
        case .transportBasics:
            return ContentMediaRegistry.transportStationHero ?? ContentMediaRegistry.transportHero
        case .officialSourcesChecklist:
            return ContentMediaRegistry.officialSourcesHero
        case .firstStepsNetherlands, .healthcareBasics, .healthInsuranceBasics, .housingBasics, .digidSafety, .bankingBasics:
            return nil
        }
    }

    private var checklistSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: content.stepsTitle)

            ForEach(Array(content.steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: AppSpacing.medium) {
                    Text("\(index + 1)")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(content.tint)
                        .clipShape(Circle())

                    Text(step)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .appCardStyle()
            }
        }
    }

    private var meaningSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: meaningTitle)
            Text(content.meaning)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .appCardStyle()
        }
    }

    private var verifySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: verifyTitle)
            ForEach(content.verifyItems, id: \.self) { item in
                HStack(alignment: .top, spacing: AppSpacing.small) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppColors.success)
                    Text(item)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .appCardStyle()
            }
        }
    }

    private var relatedActionsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: content.actionsTitle)

            HStack(spacing: AppSpacing.small) {
                if let mapFocus = content.mapFocus,
                   isVisible(.mapFocus(mapFocus)) {
                    NavigationLink(value: AppDestination.mapFocus(mapFocus)) {
                        actionChip(content.mapTitle, icon: AppIcons.map)
                    }
                    .buttonStyle(.plain)
                }

                if let dutchModuleID = content.dutchModuleID,
                   isVisible(.dutchA1A2Module(dutchModuleID)) {
                    NavigationLink(value: AppDestination.dutchA1A2Module(dutchModuleID)) {
                        actionChip(dutchWordsActionTitle, icon: "text.book.closed.fill")
                    }
                    .buttonStyle(.plain)
                }

                if isVisible(.officialSources) {
                    NavigationLink(value: AppDestination.officialSources) {
                        actionChip(content.sourcesTitle, icon: AppIcons.officialSource)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func isVisible(_ destination: AppDestination) -> Bool {
        RelatedContentEngine.isVisible(destination, for: activePersona)
    }

    private var commonMistakesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: commonMistakesTitle)
            ForEach(content.commonMistakes, id: \.self) { mistake in
                HStack(alignment: .top, spacing: AppSpacing.small) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppColors.warning)
                    Text(mistake)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .appCardStyle()
            }
        }
    }

    private var dutchWordsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: dutchWordsTitle)
            ForEach(content.dutchWords) { word in
                VStack(alignment: .leading, spacing: 4) {
                    Text(word.nl)
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColors.textPrimary)
                    Text(word.translation)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                    Text(word.example)
                        .font(AppTypography.metadata)
                        .foregroundStyle(content.tint)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .appCardStyle()
            }
        }
    }

    private var sourceSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: content.sourceTitle)

            ForEach(content.sources) { source in
                if let sourceURL = AppURL.validatedWebURL(source.url) {
                    Button {
                        openURL(sourceURL)
                    } label: {
                    HStack(spacing: AppSpacing.medium) {
                        Image(systemName: AppIcons.external)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(content.tint)
                            .frame(width: 42, height: 42)
                            .background(content.tint.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))

                        VStack(alignment: .leading, spacing: 3) {
                            Text(source.title)
                                .font(AppTypography.bodyStrong)
                                .foregroundStyle(AppColors.textPrimary)
                            Text(source.institution)
                                .font(AppTypography.caption)
                                .foregroundStyle(AppColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                            Text(trustLabel(for: source))
                                .font(AppTypography.metadata)
                                .foregroundStyle(content.tint)
                                .lineLimit(1)
                        }

                        Spacer(minLength: 8)
                    }
                    .appCardStyle()
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var updatedSection: some View {
        HStack(spacing: 8) {
            Image(systemName: "calendar.badge.checkmark")
                .foregroundStyle(AppColors.textTertiary)
            Text("\(updatedTitle): \(content.updatedAt)")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .appCardStyle()
    }

    private func trustLabel(for source: InfoSourceMetadata) -> String {
        switch lang {
        case .russian:
            return source.sourceType == "municipality" ? "Источник муниципалитета" : "Официальный источник"
        case .dutch:
            return source.sourceType == "municipality" ? "Gemeentelijke bron" : "Officiële bron"
        case .english:
            return source.sourceType == "municipality" ? "Municipality source" : "Official source"
        }
    }

    private var meaningTitle: String {
        switch lang {
        case .russian: return "Что это значит"
        case .dutch: return "Wat dit betekent"
        case .english: return "What this means"
        }
    }

    private var verifyTitle: String {
        switch lang {
        case .russian: return "Что проверить"
        case .dutch: return "Wat controleren"
        case .english: return "What to verify"
        }
    }

    private var updatedTitle: String {
        switch lang {
        case .russian: return "Последнее обновление"
        case .dutch: return "Laatst bijgewerkt"
        case .english: return "Last updated"
        }
    }

    private var commonMistakesTitle: String {
        switch lang {
        case .russian: return "Частые ошибки"
        case .dutch: return "Veelgemaakte fouten"
        case .english: return "Common mistakes"
        }
    }

    private var dutchWordsTitle: String {
        switch lang {
        case .russian: return "Полезные нидерландские слова"
        case .dutch: return "Handige Nederlandse woorden"
        case .english: return "Useful Dutch words"
        }
    }

    private var dutchWordsActionTitle: String {
        switch lang {
        case .russian: return "Выучить слова"
        case .dutch: return "Leer woorden"
        case .english: return "Learn words"
        }
    }

    private func actionChip(_ title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .bold))
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .foregroundStyle(AppColors.cyanGlow)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(AppColors.cyanGlow.opacity(0.10))
        .clipShape(Capsule())
    }
}

private struct PracticalGuideContent {
    let title: String
    let subtitle: String
    let badge: String
    let icon: String
    let tint: Color
    let stepsTitle: String
    let steps: [String]
    let meaning: String
    let verifyItems: [String]
    let actionsTitle: String
    let mapTitle: String
    let sourcesTitle: String
    let sourceTitle: String
    let sourceName: String
    let sourceDescription: String
    let sourceURL: URL
    let sources: [InfoSourceMetadata]
    let updatedAt: String
    let mapFocus: MapFocus?
    let commonMistakes: [String]
    let dutchWords: [PracticalDutchWord]
    let dutchModuleID: String?

    init(
        title: String,
        subtitle: String,
        badge: String,
        icon: String,
        tint: Color,
        stepsTitle: String,
        steps: [String],
        meaning: String = "",
        verifyItems: [String] = [],
        actionsTitle: String,
        mapTitle: String,
        sourcesTitle: String,
        sourceTitle: String,
        sourceName: String,
        sourceDescription: String,
        sourceURL: URL,
        sources: [InfoSourceMetadata] = [],
        updatedAt: String = "2026-06-01",
        mapFocus: MapFocus?,
        commonMistakes: [String] = [],
        dutchWords: [PracticalDutchWord] = [],
        dutchModuleID: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.badge = badge
        self.icon = icon
        self.tint = tint
        self.stepsTitle = stepsTitle
        self.steps = steps
        self.meaning = meaning.isEmpty ? subtitle : meaning
        self.verifyItems = verifyItems.isEmpty ? [sourceDescription] : verifyItems
        self.actionsTitle = actionsTitle
        self.mapTitle = mapTitle
        self.sourcesTitle = sourcesTitle
        self.sourceTitle = sourceTitle
        self.sourceName = sourceName
        self.sourceDescription = sourceDescription
        self.sourceURL = sourceURL
        self.sources = sources.isEmpty ? [
            InfoSourceMetadata(
                id: sourceName.lowercased().replacingOccurrences(of: " ", with: "-"),
                title: sourceName,
                institution: sourceName,
                url: sourceURL,
                sourceType: "official"
            )
        ] : sources
        self.updatedAt = updatedAt
        self.mapFocus = mapFocus
        self.commonMistakes = commonMistakes
        self.dutchWords = dutchWords
        self.dutchModuleID = dutchModuleID
    }
}

private struct PracticalDutchWord: Identifiable {
    let id: String
    let nl: String
    let translation: String
    let example: String
}

private extension PracticalGuideContent {
    func enriched(for topic: PracticalGuideTopic, lang: AppLanguage) -> PracticalGuideContent {
        PracticalGuideContent(
            title: title,
            subtitle: subtitle,
            badge: badge,
            icon: icon,
            tint: tint,
            stepsTitle: stepsTitle,
            steps: steps,
            meaning: meaning,
            verifyItems: verifyItems,
            actionsTitle: actionsTitle,
            mapTitle: mapTitle,
            sourcesTitle: sourcesTitle,
            sourceTitle: sourceTitle,
            sourceName: sourceName,
            sourceDescription: sourceDescription,
            sourceURL: sourceURL,
            sources: sources,
            updatedAt: updatedAt,
            mapFocus: mapFocus,
            commonMistakes: commonMistakes.isEmpty ? Self.defaultMistakes(for: topic, lang: lang) : commonMistakes,
            dutchWords: dutchWords.isEmpty ? Self.defaultDutchWords(for: topic, lang: lang) : dutchWords,
            dutchModuleID: dutchModuleID ?? Self.defaultDutchModuleID(for: topic)
        )
    }

    private static func defaultDutchModuleID(for topic: PracticalGuideTopic) -> String? {
        switch topic {
        case .municipalityRegistration, .firstStepsNetherlands, .officialSourcesChecklist:
            return "municipality"
        case .healthcareBasics, .findingHuisarts, .healthInsuranceBasics:
            return "healthcare"
        case .digidSafety:
            return "personal-info"
        case .transportBasics:
            return "transport"
        case .housingBasics:
            return "housing"
        case .bankingBasics:
            return "shopping-services"
        }
    }

    private static func defaultMistakes(for topic: PracticalGuideTopic, lang: AppLanguage) -> [String] {
        switch topic {
        case .firstStepsNetherlands:
            return localize(lang,
                en: ["Starting with private advice before checking official sources.", "Forgetting that address, BSN, DigiD, insurance, and letters are connected.", "Keeping confirmations only in email and not saving document copies."],
                nl: ["Beginnen met privéadvies voordat officiële bronnen zijn gecontroleerd.", "Vergeten dat adres, BSN, DigiD, verzekering en brieven samenhangen.", "Bevestigingen alleen in e-mail laten staan en geen kopieën bewaren."],
                ru: ["Начинать с частных советов до проверки официальных источников.", "Не связывать адрес, BSN, DigiD, страховку и официальные письма в одну систему.", "Оставлять подтверждения только в email и не сохранять копии документов."])
        case .municipalityRegistration:
            return localize(lang,
                en: ["Waiting too long to register after moving.", "Not checking document requirements before the appointment.", "Confusing a rental contract with municipality address registration."],
                nl: ["Te lang wachten met inschrijven na verhuizing.", "Documentvereisten niet controleren voor de afspraak.", "Een huurcontract verwarren met adresinschrijving bij de gemeente."],
                ru: ["Слишком долго ждать с регистрацией после переезда.", "Не проверить требования к документам до записи.", "Путать договор аренды с регистрацией адреса в gemeente."])
        case .healthcareBasics, .findingHuisarts:
            return localize(lang,
                en: ["Using emergency care for non-emergency problems.", "Not registering with a huisarts near the registered address.", "Forgetting to check insurance and eigen risico before planned care."],
                nl: ["Spoedzorg gebruiken voor niet-spoedeisende klachten.", "Niet inschrijven bij een huisarts bij het geregistreerde adres.", "Vergeten verzekering en eigen risico te controleren voor geplande zorg."],
                ru: ["Идти в срочную помощь при несрочной проблеме.", "Не зарегистрироваться у huisarts рядом с адресом регистрации.", "Не проверить страховку и eigen risico перед плановой помощью."])
        case .healthInsuranceBasics:
            return localize(lang,
                en: ["Assuming foreign insurance always replaces Dutch basic insurance.", "Comparing only the monthly premium and not contracted care or eigen risico.", "Applying for allowance through unofficial links."],
                nl: ["Aannemen dat buitenlandse verzekering altijd de Nederlandse basisverzekering vervangt.", "Alleen premie vergelijken en niet gecontracteerde zorg of eigen risico.", "Zorgtoeslag aanvragen via onofficiële links."],
                ru: ["Думать, что иностранная страховка всегда заменяет нидерландскую базовую.", "Сравнивать только взнос, а не договорную помощь и eigen risico.", "Оформлять toeslag по неофициальным ссылкам."])
        case .digidSafety:
            return localize(lang,
                en: ["Sharing login codes or app approvals.", "Opening DigiD from unexpected SMS or email links.", "Ignoring recovery settings until access is lost."],
                nl: ["Inlogcodes of app-goedkeuringen delen.", "DigiD openen via onverwachte sms- of e-maillinks.", "Herstelinstellingen pas bekijken nadat toegang kwijt is."],
                ru: ["Передавать коды входа или подтверждения в приложении.", "Открывать DigiD из неожиданных SMS или email-ссылок.", "Вспоминать о восстановлении только после потери доступа."])
        case .transportBasics:
            return localize(lang,
                en: ["Forgetting to check in or check out.", "Not checking live delays, platform changes, or operator rules.", "Paying a suspicious fine message before verifying the official source."],
                nl: ["Vergeten in of uit te checken.", "Actuele vertragingen, perronwijzigingen of vervoerdersregels niet controleren.", "Een verdacht boetebericht betalen zonder officiële controle."],
                ru: ["Забыть сделать check-in или check-out.", "Не проверить задержки, платформу или правила оператора.", "Оплатить подозрительный штраф без проверки официального источника."])
        case .housingBasics:
            return localize(lang,
                en: ["Signing unclear agreements under pressure.", "Not checking whether address registration is allowed.", "Ignoring energy, water, waste, deposit, or noise obligations."],
                nl: ["Onduidelijke afspraken onder druk tekenen.", "Niet controleren of inschrijving op het adres mag.", "Energie, water, afval, borg of geluidsregels negeren."],
                ru: ["Подписывать непонятный договор под давлением.", "Не проверить, разрешена ли регистрация по адресу.", "Игнорировать энергию, воду, мусор, депозит или правила шума."])
        case .officialSourcesChecklist:
            return localize(lang,
                en: ["Trusting screenshots instead of official domains.", "Paying from a link before checking sender, domain, and reference number.", "Using social media comments as the only source."],
                nl: ["Screenshots vertrouwen in plaats van officiële domeinen.", "Via een link betalen zonder afzender, domein en kenmerk te controleren.", "Socialmediacommentaren als enige bron gebruiken."],
                ru: ["Доверять скриншотам вместо официальных доменов.", "Платить по ссылке без проверки отправителя, домена и номера.", "Использовать комментарии в соцсетях как единственный источник."])
        case .bankingBasics:
            return localize(lang,
                en: ["Sharing bank login or confirmation codes.", "Paying rent deposits by untraceable methods under pressure.", "Not saving IBAN, payment, and contract proof."],
                nl: ["Banklogin of bevestigingscodes delen.", "Huur of borg onder druk ontraceerbaar betalen.", "IBAN-, betaal- en contractbewijs niet bewaren."],
                ru: ["Передавать банковский логин или коды подтверждения.", "Платить аренду/депозит неотслеживаемо под давлением.", "Не сохранять IBAN, платежные и договорные подтверждения."])
        }
    }

    private static func defaultDutchWords(for topic: PracticalGuideTopic, lang: AppLanguage) -> [PracticalDutchWord] {
        let words: [(String, String, String, String, String, String)]
        switch topic {
        case .firstStepsNetherlands:
            words = [("gemeente", "municipality", "gemeente", "муниципалитет", "Ik heb een afspraak bij de gemeente.", "У меня запись в gemeente."), ("BSN", "citizen service number", "burgerservicenummer", "гражданский номер", "Ik heb mijn BSN nodig.", "Мне нужен мой BSN."), ("DigiD", "official login", "officiële login", "официальный вход", "Ik log in met DigiD.", "Я вхожу через DigiD."), ("zorgverzekering", "health insurance", "zorgverzekering", "медицинская страховка", "Ik controleer mijn zorgverzekering.", "Я проверяю свою страховку."), ("adres", "address", "adres", "адрес", "Mijn adres is veranderd.", "Мой адрес изменился.")]
        case .municipalityRegistration:
            words = [("gemeente", "municipality", "gemeente", "муниципалитет", "Ik ga naar de gemeente.", "Я иду в gemeente."), ("afspraak", "appointment", "afspraak", "запись / встреча", "Ik heb een afspraak.", "У меня запись."), ("inschrijven", "to register", "inschrijven", "зарегистрироваться", "Ik wil me inschrijven.", "Я хочу зарегистрироваться."), ("documenten", "documents", "documenten", "документы", "Welke documenten heb ik nodig?", "Какие документы мне нужны?"), ("balie", "desk", "balie", "стойка", "Waar is de balie?", "Где стойка?")]
        case .healthcareBasics, .findingHuisarts:
            words = [("huisarts", "GP", "huisarts", "семейный врач", "Ik wil een afspraak maken bij de huisarts.", "Я хочу записаться к huisarts."), ("apotheek", "pharmacy", "apotheek", "аптека", "Waar is de apotheek?", "Где аптека?"), ("pijn", "pain", "pijn", "боль", "Ik heb pijn.", "У меня боль."), ("spoed", "urgent", "spoed", "срочно", "Is dit spoed?", "Это срочно?"), ("medicijnen", "medicines", "medicijnen", "лекарства", "Ik heb medicijnen nodig.", "Мне нужны лекарства.")]
        case .healthInsuranceBasics:
            words = [("zorgverzekering", "health insurance", "zorgverzekering", "медицинская страховка", "Ik heb een zorgverzekering.", "У меня есть медицинская страховка."), ("eigen risico", "deductible", "eigen risico", "франшиза", "Wat is mijn eigen risico?", "Какой у меня eigen risico?"), ("premie", "premium", "premie", "страховой взнос", "De premie is per maand.", "Взнос платится каждый месяц."), ("polis", "policy", "polis", "полис", "Ik zoek mijn polisnummer.", "Я ищу номер полиса.")]
        case .digidSafety:
            words = [("inloggen", "to log in", "inloggen", "войти", "Ik log in met DigiD.", "Я вхожу через DigiD."), ("code", "code", "code", "код", "Deel nooit uw code.", "Никогда не передавайте код."), ("wachtwoord", "password", "wachtwoord", "пароль", "Mijn wachtwoord is geheim.", "Мой пароль секретный."), ("phishing", "phishing", "phishing", "фишинг", "Deze link lijkt phishing.", "Эта ссылка похожа на фишинг.")]
        case .transportBasics:
            words = [("trein", "train", "trein", "поезд", "Is deze trein naar Leiden?", "Этот поезд в Лейден?"), ("inchecken", "check in", "inchecken", "сделать check-in", "Ik moet inchecken.", "Мне нужно сделать check-in."), ("uitchecken", "check out", "uitchecken", "сделать check-out", "Vergeet niet uit te checken.", "Не забудьте сделать check-out."), ("vertraging", "delay", "vertraging", "задержка", "Mijn trein heeft vertraging.", "Мой поезд задерживается."), ("overstappen", "transfer", "overstappen", "пересесть", "Ik moet overstappen.", "Мне нужно пересесть.")]
        case .housingBasics:
            words = [("huur", "rent", "huur", "аренда", "Hoe hoog is de huur?", "Какая аренда?"), ("huurcontract", "rental contract", "huurcontract", "договор аренды", "Ik lees het huurcontract.", "Я читаю договор аренды."), ("borg", "deposit", "borg", "депозит", "Hoeveel borg betaal ik?", "Сколько депозита я плачу?"), ("afval", "waste", "afval", "мусор", "Wanneer wordt het afval opgehaald?", "Когда вывозят мусор?"), ("verhuurder", "landlord", "verhuurder", "арендодатель", "Ik bel de verhuurder.", "Я звоню арендодателю.")]
        case .officialSourcesChecklist:
            words = [("officieel", "official", "officieel", "официальный", "Dit is een officiële website.", "Это официальный сайт."), ("bron", "source", "bron", "источник", "Controleer de bron.", "Проверьте источник."), ("kenmerk", "reference number", "kenmerk", "номер дела", "Bewaar het kenmerk.", "Сохраните номер дела."), ("website", "website", "website", "сайт", "Open de officiële website.", "Откройте официальный сайт.")]
        case .bankingBasics:
            words = [("IBAN", "bank account number", "rekeningnummer", "номер счёта", "Wat is uw IBAN?", "Какой у вас IBAN?"), ("betalen", "to pay", "betalen", "платить", "Ik wil betalen.", "Я хочу оплатить."), ("pinnen", "pay by card", "pinnen", "платить картой", "Kan ik pinnen?", "Можно оплатить картой?"), ("bon", "receipt", "bon", "чек", "Mag ik de bon?", "Можно чек?")]
        }
        return words.map { value in
            PracticalDutchWord(
                id: value.0.lowercased().replacingOccurrences(of: " ", with: "-"),
                nl: value.0,
                translation: translation(lang, en: value.1, nl: value.2, ru: value.3),
                example: lang == .russian ? value.5 : value.4
            )
        }
    }

    private static func localize(_ lang: AppLanguage, en: [String], nl: [String], ru: [String]) -> [String] {
        switch lang {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }

    private static func translation(_ lang: AppLanguage, en: String, nl: String, ru: String) -> String {
        switch lang {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }
}

private extension PracticalGuideTopic {
    func content(_ lang: AppLanguage) -> PracticalGuideContent {
        switch self {
        case .firstStepsNetherlands:
            return PracticalGuideContent(
                title: text(lang, "First steps in the Netherlands", "Eerste stappen in Nederland", "Первые шаги в Нидерландах"),
                subtitle: text(lang, "Build the administrative base before making irreversible decisions.", "Leg de administratieve basis voordat je onomkeerbare keuzes maakt.", "Сначала создайте административную основу, затем принимайте важные решения."),
                badge: text(lang, "Start", "Start", "Старт"),
                icon: AppIcons.checklist,
                tint: AppColors.success,
                stepsTitle: stepsTitle(lang),
                steps: [
                    text(lang, "Secure an address where municipality registration is allowed.", "Zorg voor een adres waar inschrijving bij de gemeente mag.", "Найдите адрес, где разрешена регистрация в gemeente."),
                    text(lang, "Book gemeente registration and prepare identity and address documents.", "Maak een gemeenteafspraak en bereid identiteit- en adresdocumenten voor.", "Запишитесь в gemeente и подготовьте документы личности и адреса."),
                    text(lang, "After BSN/address steps, set up DigiD through the official domain.", "Regel na BSN/adresstappen DigiD via het officiële domein.", "После BSN/адреса оформите DigiD через официальный домен."),
                    text(lang, "Check health insurance, huisarts, banking, transport, and official-letter routines.", "Controleer zorgverzekering, huisarts, bankieren, vervoer en routines voor officiële brieven.", "Проверьте страховку, huisarts, банк, транспорт и работу с официальными письмами.")
                ],
                actionsTitle: actionsTitle(lang),
                mapTitle: mapTitle(lang),
                sourcesTitle: sourcesTitle(lang),
                sourceTitle: sourceTitle(lang),
                sourceName: "Government.nl",
                sourceDescription: text(lang, "Official information about municipalities and public services.", "Officiële informatie over gemeenten en publieke diensten.", "Официальная информация о муниципалитетах и госуслугах."),
                sourceURL: AppURL.make("https://www.government.nl/topics/municipalities"),
                mapFocus: .government
            )
        case .municipalityRegistration:
            return PracticalGuideContent(
                title: text(lang, "Municipality registration", "Inschrijving bij gemeente", "Регистрация в муниципалитете"),
                subtitle: text(lang, "Start with your gemeente: address registration, BSN-related steps, and appointment rules.", "Begin bij je gemeente: adresinschrijving, BSN-stappen en afspraakregels.", "Начните с gemeente: регистрация адреса, шаги по BSN и правила записи."),
                badge: text(lang, "Gemeente", "Gemeente", "Gemeente"),
                icon: "person.badge.plus.fill",
                tint: AppColors.routeLine,
                stepsTitle: stepsTitle(lang),
                steps: [
                    text(lang, "Find your municipality’s official website.", "Zoek de officiële website van je gemeente.", "Найдите официальный сайт вашего муниципалитета."),
                    text(lang, "Check appointment, identity document, and address proof requirements.", "Controleer afspraak, identiteitsbewijs en adresbewijs.", "Проверьте требования к записи, документу личности и подтверждению адреса."),
                    text(lang, "Save confirmations and bring original documents when required.", "Bewaar bevestigingen en neem originele documenten mee als dat nodig is.", "Сохраните подтверждения и возьмите оригиналы документов, если требуется.")
                ],
                actionsTitle: actionsTitle(lang),
                mapTitle: mapTitle(lang),
                sourcesTitle: sourcesTitle(lang),
                sourceTitle: sourceTitle(lang),
                sourceName: "Government.nl",
                sourceDescription: text(lang, "Official central-government information about municipalities.", "Officiële informatie van de centrale overheid over gemeenten.", "Официальная информация правительства о муниципалитетах."),
                sourceURL: AppURL.make("https://www.government.nl/topics/municipalities"),
                mapFocus: .government
            )
        case .healthcareBasics:
            return PracticalGuideContent(
                title: text(lang, "Healthcare basics", "Basiszorg", "Базовая медицина"),
                subtitle: text(lang, "Understand health insurance, huisarts registration, and urgent care routes.", "Begrijp zorgverzekering, huisartsinschrijving en spoedroutes.", "Разберитесь со страховкой, регистрацией у huisarts и срочной помощью."),
                badge: text(lang, "Care", "Zorg", "Здоровье"),
                icon: "cross.case.fill",
                tint: AppColors.error,
                stepsTitle: stepsTitle(lang),
                steps: [
                    text(lang, "Check whether Dutch basic health insurance applies to your situation.", "Controleer of Nederlandse basisverzekering voor jouw situatie geldt.", "Проверьте, нужна ли вам базовая медицинская страховка."),
                    text(lang, "Look for a huisarts near your registered address.", "Zoek een huisarts bij je inschrijfadres.", "Ищите huisarts рядом с адресом регистрации."),
                    text(lang, "Use urgent care only for urgent medical problems and verify local instructions.", "Gebruik spoedzorg alleen bij urgente medische problemen en controleer lokale instructies.", "Используйте срочную помощь только при срочных медицинских проблемах и проверяйте местные инструкции.")
                ],
                actionsTitle: actionsTitle(lang),
                mapTitle: mapTitle(lang),
                sourcesTitle: sourcesTitle(lang),
                sourceTitle: sourceTitle(lang),
                sourceName: "Government.nl",
                sourceDescription: text(lang, "Official information about Dutch health insurance.", "Officiële informatie over Nederlandse zorgverzekering.", "Официальная информация о медицинской страховке в Нидерландах."),
                sourceURL: AppURL.make("https://www.government.nl/topics/health-insurance"),
                mapFocus: .healthcare
            )
        case .findingHuisarts:
            return PracticalGuideContent(
                title: text(lang, "Finding a huisarts", "Een huisarts vinden", "Как найти huisarts"),
                subtitle: text(lang, "The GP is usually the first contact for non-emergency care.", "De huisarts is meestal het eerste contact voor niet-spoedzorg.", "Huisarts обычно первый контакт для несрочной медицины."),
                badge: text(lang, "GP", "Huisarts", "Huisarts"),
                icon: "stethoscope",
                tint: AppColors.error,
                stepsTitle: stepsTitle(lang),
                steps: [
                    text(lang, "Search near your registered address and contact several practices if needed.", "Zoek bij je inschrijfadres en benader zo nodig meerdere praktijken.", "Ищите рядом с адресом регистрации и при необходимости пишите в несколько практик."),
                    text(lang, "Ask whether the practice accepts new patients and what documents are required.", "Vraag of de praktijk nieuwe patienten aanneemt en welke documenten nodig zijn.", "Спросите, принимает ли практика новых пациентов и какие документы нужны."),
                    text(lang, "If lists are full, ask your health insurer or municipality for guidance.", "Als lijsten vol zijn, vraag je zorgverzekeraar of gemeente om richting.", "Если списки закрыты, спросите страховщика или gemeente."),
                    text(lang, "Use 112 only for immediate emergencies; use local urgent-care instructions for urgent but non-life-threatening cases.", "Gebruik 112 alleen bij directe nood; volg lokale spoedinstructies bij urgente maar niet levensbedreigende zorg.", "112 только для экстренной опасности; для срочных, но не критичных случаев используйте местные инструкции.")
                ],
                actionsTitle: actionsTitle(lang),
                mapTitle: mapTitle(lang),
                sourcesTitle: sourcesTitle(lang),
                sourceTitle: sourceTitle(lang),
                sourceName: "Government.nl",
                sourceDescription: text(lang, "Official information about health insurance and healthcare access.", "Officiële informatie over zorgverzekering en toegang tot zorg.", "Официальная информация о страховке и доступе к медицине."),
                sourceURL: AppURL.make("https://www.government.nl/topics/health-insurance"),
                mapFocus: .healthcare
            )
        case .healthInsuranceBasics:
            return PracticalGuideContent(
                title: text(lang, "Health insurance basics", "Basis zorgverzekering", "Основы медицинской страховки"),
                subtitle: text(lang, "Check whether Dutch basic health insurance applies to your situation.", "Controleer of Nederlandse basisverzekering voor jouw situatie geldt.", "Проверьте, нужна ли вам базовая медицинская страховка."),
                badge: text(lang, "Insurance", "Verzekering", "Страховка"),
                icon: "checkmark.shield.fill",
                tint: AppColors.success,
                stepsTitle: stepsTitle(lang),
                steps: [
                    text(lang, "Verify whether your residence, work, or study situation creates an insurance obligation.", "Controleer of wonen, werken of studeren een verzekeringsplicht geeft.", "Проверьте, создает ли проживание, работа или учеба обязанность страхования."),
                    text(lang, "Compare premium, eigen risico, contracted care, reimbursements, and English support.", "Vergelijk premie, eigen risico, gecontracteerde zorg, vergoedingen en Engelstalige hulp.", "Сравните взнос, eigen risico, договорную помощь, компенсации и поддержку на английском."),
                    text(lang, "Check healthcare allowance only through official Toeslagen channels if you may be eligible.", "Controleer zorgtoeslag alleen via officiële Toeslagen-kanalen als je mogelijk recht hebt.", "Проверяйте zorgtoeslag только через официальные каналы Toeslagen."),
                    text(lang, "Keep policy numbers and insurer contact details in your document folder.", "Bewaar polisnummers en contactgegevens van je verzekeraar in je documentenmap.", "Сохраните номер полиса и контакты страховщика.")
                ],
                actionsTitle: actionsTitle(lang),
                mapTitle: mapTitle(lang),
                sourcesTitle: sourcesTitle(lang),
                sourceTitle: sourceTitle(lang),
                sourceName: "Government.nl",
                sourceDescription: text(lang, "Official information about Dutch health insurance.", "Officiële informatie over Nederlandse zorgverzekering.", "Официальная информация о медицинской страховке в Нидерландах."),
                sourceURL: AppURL.make("https://www.government.nl/topics/health-insurance"),
                mapFocus: .healthcare
            )
        case .digidSafety:
            return PracticalGuideContent(
                title: text(lang, "DigiD safety", "DigiD-veiligheid", "Безопасность DigiD"),
                subtitle: text(lang, "Use DigiD carefully: it is the login key for many official services.", "Gebruik DigiD zorgvuldig: het is de login voor veel officiële diensten.", "Используйте DigiD осторожно: это ключ входа во многие официальные сервисы."),
                badge: "DigiD",
                icon: "lock.shield.fill",
                tint: AppColors.cyanGlow,
                stepsTitle: stepsTitle(lang),
                steps: [
                    text(lang, "Open DigiD by typing the official domain yourself.", "Open DigiD door zelf het officiële domein te typen.", "Открывайте DigiD, самостоятельно вводя официальный домен."),
                    text(lang, "Do not share login details, activation codes, or app approval requests.", "Deel geen inloggegevens, activatiecodes of app-goedkeuringen.", "Не передавайте логин, коды активации и подтверждения в приложении."),
                    text(lang, "Treat unexpected SMS, email, or payment links as suspicious until verified.", "Behandel onverwachte sms-, mail- of betaallinks als verdacht totdat ze gecontroleerd zijn.", "Считайте неожиданные SMS, письма и ссылки оплаты подозрительными, пока не проверите их.")
                ],
                actionsTitle: actionsTitle(lang),
                mapTitle: mapTitle(lang),
                sourcesTitle: sourcesTitle(lang),
                sourceTitle: sourceTitle(lang),
                sourceName: "DigiD",
                sourceDescription: text(lang, "Official DigiD website and safety information.", "Officiële DigiD-website en veiligheidsinformatie.", "Официальный сайт DigiD и информация по безопасности."),
                sourceURL: AppURL.make("https://www.digid.nl/en"),
                mapFocus: nil
            )
        case .transportBasics:
            return PracticalGuideContent(
                title: text(lang, "Transport basics", "Vervoer", "Транспорт"),
                subtitle: text(lang, "Learn route planning, check-in rules, and transport-office support.", "Leer routeplanning, incheckregels en hulp bij vervoersloketten.", "Изучите маршруты, правила check-in и поддержку транспортных офисов."),
                badge: text(lang, "Mobility", "Mobiliteit", "Поездки"),
                icon: "tram.fill",
                tint: AppColors.dutchOrange,
                stepsTitle: stepsTitle(lang),
                steps: [
                    text(lang, "Use official route planners or local operators for live schedules.", "Gebruik officiële routeplanners of lokale vervoerders voor actuele tijden.", "Пользуйтесь официальными планировщиками или местными операторами для актуального расписания."),
                    text(lang, "Check in and out correctly where the system requires it.", "Check correct in en uit waar het systeem dat vraagt.", "Правильно делайте check-in и check-out там, где это требуется."),
                    text(lang, "Verify fine/payment messages through official channels before paying.", "Controleer boete- of betaalberichten via officiële kanalen voordat je betaalt.", "Проверяйте штрафы и платежные сообщения через официальные каналы перед оплатой.")
                ],
                actionsTitle: actionsTitle(lang),
                mapTitle: mapTitle(lang),
                sourcesTitle: sourcesTitle(lang),
                sourceTitle: sourceTitle(lang),
                sourceName: "Government.nl",
                sourceDescription: text(lang, "Official information about mobility, public transport, and road safety.", "Officiële informatie over mobiliteit, openbaar vervoer en verkeersveiligheid.", "Официальная информация о мобильности, общественном транспорте и безопасности движения."),
                sourceURL: AppURL.make("https://www.government.nl/topics/mobility-public-transport-and-road-safety"),
                mapFocus: .transport
            )
        case .housingBasics:
            return PracticalGuideContent(
                title: text(lang, "Housing basics", "Wonen basis", "Жильё"),
                subtitle: text(lang, "Check rental terms, registration permission, deposits, and official city rules before committing.", "Controleer huurvoorwaarden, inschrijfmogelijkheid, borg en officiële stadsregels voordat je tekent.", "Проверьте условия аренды, возможность регистрации, депозит и официальные городские правила до решения."),
                badge: text(lang, "Housing", "Wonen", "Жильё"),
                icon: "house.lodge.fill",
                tint: AppColors.violet,
                stepsTitle: stepsTitle(lang),
                steps: [
                    text(lang, "Confirm that the address can be registered with the municipality.", "Controleer of je je op het adres kunt inschrijven bij de gemeente.", "Убедитесь, что по адресу можно зарегистрироваться в муниципалитете."),
                    text(lang, "Review rent, deposit, contract duration, and included costs before signing.", "Controleer huur, borg, contractduur en inbegrepen kosten voordat je tekent.", "Проверьте аренду, депозит, срок договора и включённые расходы до подписания."),
                    text(lang, "Be careful with pressure to pay before viewing, signing, or verifying the landlord.", "Wees voorzichtig met druk om te betalen voor bezichtiging, ondertekening of controle van de verhuurder.", "Осторожно относитесь к требованиям оплатить до просмотра, подписания или проверки арендодателя.")
                ],
                actionsTitle: actionsTitle(lang),
                mapTitle: mapTitle(lang),
                sourcesTitle: sourcesTitle(lang),
                sourceTitle: sourceTitle(lang),
                sourceName: "Government.nl",
                sourceDescription: text(lang, "Official information about housing and renting in the Netherlands.", "Officiële informatie over wonen en huren in Nederland.", "Официальная информация о жилье и аренде в Нидерландах."),
                sourceURL: AppURL.make("https://www.government.nl/themes/building-and-housing/housing"),
                mapFocus: nil
            )
        case .officialSourcesChecklist:
            return PracticalGuideContent(
                title: text(lang, "Official sources checklist", "Checklist officiële bronnen", "Чеклист официальных источников"),
                subtitle: text(lang, "Verify domains before acting on money, identity, housing, healthcare, or immigration information.", "Controleer domeinen voordat je handelt rond geld, identiteit, wonen, zorg of immigratie.", "Проверяйте домены перед действиями с деньгами, личностью, жильём, медициной или иммиграцией."),
                badge: text(lang, "Verify", "Controleer", "Проверка"),
                icon: AppIcons.officialSource,
                tint: AppColors.success,
                stepsTitle: stepsTitle(lang),
                steps: [
                    text(lang, "Type official domains yourself instead of following unexpected links.", "Typ officiële domeinen zelf in plaats van onverwachte links te volgen.", "Вводите официальные домены сами, не переходите по неожиданным ссылкам."),
                    text(lang, "For national rules, start with Government.nl or Rijksoverheid.nl.", "Begin voor nationale regels bij Government.nl of Rijksoverheid.nl.", "Для национальных правил начинайте с Government.nl или Rijksoverheid.nl."),
                    text(lang, "For local rules, use your municipality website and confirm the city domain.", "Gebruik voor lokale regels je gemeentesite en controleer het stadsdomein.", "Для местных правил используйте сайт gemeente и проверяйте домен города."),
                    text(lang, "For payments or fines, compare sender, reference number, domain, and postal letter before paying.", "Vergelijk bij betalingen of boetes afzender, kenmerk, domein en postbrief voordat je betaalt.", "Перед оплатой штрафов сверяйте отправителя, номер, домен и бумажное письмо.")
                ],
                actionsTitle: actionsTitle(lang),
                mapTitle: mapTitle(lang),
                sourcesTitle: sourcesTitle(lang),
                sourceTitle: sourceTitle(lang),
                sourceName: "Government.nl",
                sourceDescription: text(lang, "Official central-government information and links to responsible public institutions.", "Officiële informatie van de centrale overheid en links naar verantwoordelijke organisaties.", "Официальная информация правительства и ссылки на ответственные организации."),
                sourceURL: AppURL.make("https://www.government.nl"),
                mapFocus: .government
            )
        case .bankingBasics:
            return PracticalGuideContent(
                title: text(lang, "Banking basics", "Bankieren basis", "Основы банков"),
                subtitle: text(lang, "Prepare for IBAN, rent, salary, insurer payments, and secure banking access.", "Bereid je voor op IBAN, huur, salaris, verzekeringsbetalingen en veilig bankieren.", "Подготовьтесь к IBAN, аренде, зарплате, страховке и безопасному банкингу."),
                badge: text(lang, "Money", "Geld", "Деньги"),
                icon: "creditcard.fill",
                tint: AppColors.softBlue,
                stepsTitle: stepsTitle(lang),
                steps: [
                    text(lang, "Check what identity, address, BSN, or residence documents the bank requires.", "Controleer welke identiteit-, adres-, BSN- of verblijfsdocumenten de bank vraagt.", "Проверьте, какие ID, адрес, BSN или документы проживания требует банк."),
                    text(lang, "Use traceable payments for rent and deposits; avoid cash or crypto pressure.", "Gebruik traceerbare betalingen voor huur en borg; vermijd druk voor cash of crypto.", "Платите аренду и депозит отслеживаемо; избегайте давления на наличные или крипто."),
                    text(lang, "Set up strong app authentication and never share bank login or confirmation codes.", "Stel sterke app-authenticatie in en deel nooit banklogin of bevestigingscodes.", "Включите надежный вход и не передавайте логин или коды банка."),
                    text(lang, "Keep your IBAN confirmation for employer, insurer, and municipality forms.", "Bewaar je IBAN-bevestiging voor werkgever, verzekeraar en gemeenteformulieren.", "Сохраните подтверждение IBAN для работодателя, страховщика и форм gemeente.")
                ],
                actionsTitle: actionsTitle(lang),
                mapTitle: mapTitle(lang),
                sourcesTitle: sourcesTitle(lang),
                sourceTitle: sourceTitle(lang),
                sourceName: "Dutch Payments Association",
                sourceDescription: text(lang, "Sector information about payments in the Netherlands.", "Sectorinformatie over betalen in Nederland.", "Отраслевая информация о платежах в Нидерландах."),
                sourceURL: AppURL.make("https://www.betaalvereniging.nl/en/"),
                mapFocus: nil
            )
        }
    }

    private func text(_ lang: AppLanguage, _ en: String, _ nl: String, _ ru: String) -> String {
        switch lang {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }

    private func stepsTitle(_ lang: AppLanguage) -> String {
        text(lang, "Practical steps", "Praktische stappen", "Практические шаги")
    }

    private func actionsTitle(_ lang: AppLanguage) -> String {
        text(lang, "Related tools", "Gerelateerde tools", "Полезные разделы")
    }

    private func mapTitle(_ lang: AppLanguage) -> String {
        text(lang, "Open map", "Open kaart", "Открыть карту")
    }

    private func sourcesTitle(_ lang: AppLanguage) -> String {
        text(lang, "Official sources", "Officiële bronnen", "Официальные источники")
    }

    private func sourceTitle(_ lang: AppLanguage) -> String {
        text(lang, "Primary source", "Primaire bron", "Основной источник")
    }
}
