import SwiftUI

// MARK: - Fines & Rules Hub

struct FinesInfoView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var selectedCategory: String? = nil
    @State private var appeared = false

    private var lang: AppLanguage { languageManager.appLanguage }
    private var activePersona: PersonaTag? { appState.selectedUserStatus?.personaTag }
    private var visibleTopics: [RuleGuideTopic] {
        MockRulesGuideData.topics.filter { $0.isVisible(for: activePersona, scope: .currentAndUniversal) }
    }
    private var visibleScenarios: [RuleScenario] {
        MockRulesGuideData.scenarios.filter { $0.isVisible(for: activePersona, scope: .currentAndUniversal) }
    }

    private var categories: [String] {
        Array(Set(visibleTopics.map(\.category))).sorted()
    }

    private var filtered: [RuleGuideTopic] {
        guard let selectedCategory else { return visibleTopics }
        return visibleTopics.filter { $0.category == selectedCategory }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                heroHeader

                DisclaimerBanner(text: L10n.t("fines.disclaimer", lang))

                filterChips

                quickFinesSection

                topicsSection

                scenariosSection
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.small)
            .tabBarScrollReserve()
            .accessibilityIdentifier("fines.screen")
        }
        .scrollIndicators(.hidden)
        .appSceneBackground(.fines)
        .navigationTitle("")
        .nlNavigationInline()
        .accessibilityIdentifier("fines.screen")
        .onAppear {
            withAnimation(AppAnimations.cardReveal.delay(0.1)) {
                appeared = true
            }
        }
    }

    // MARK: - Hero Header

    private var heroHeader: some View {
        CategoryHeroVisual(
            assetName: "premium_home_documents",
            title: L10n.t("fines.nav_title", lang),
            subtitle: L10n.t("fines.hub_subtitle", lang),
            symbol: "exclamationmark.triangle.fill",
            badgeText: rulesBadgeText,
            accent: AppColors.dutchOrange
        )
    }

    // MARK: - Quick Fines

    private var quickFinesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: quickFinesTitle, subtitle: quickFinesSubtitle)

            ForEach(QuickFineExample.localized(lang)) { example in
                quickFineCard(example)
            }

            Button {
                withAnimation(AppAnimations.standard) {
                    selectedCategory = nil
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "list.bullet.rectangle.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text(allRulesButtonTitle)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
                .background(
                    LinearGradient(
                        colors: [AppColors.dutchOrange, AppColors.finesGradDark],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: AppColors.dutchOrange.opacity(0.28), radius: 12, x: 0, y: 6)
            }
            .buttonStyle(AppPressableButtonStyle())
        }
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(
                    title: L10n.t("common.all", lang),
                    icon: "square.grid.2x2.fill",
                    isActive: selectedCategory == nil
                ) { selectedCategory = nil }

                ForEach(categories, id: \.self) { category in
                    filterChip(
                        title: RuleGuideCategoryLocalization.localized(category, lang: lang),
                        icon: iconForCategory(category),
                        isActive: selectedCategory == category
                    ) {
                        withAnimation(AppAnimations.standard) {
                            selectedCategory = selectedCategory == category ? nil : category
                        }
                    }
                }
            }
            .padding(5)
            .background(AppColors.card.opacity(0.88))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppColors.stroke.opacity(0.92), lineWidth: 0.75)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
            .padding(.vertical, 2)
        }
    }

    private func filterChip(title: String, icon: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                Text(title)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(isActive ? .white : AppColors.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(
                isActive
                    ? LinearGradient(colors: [AppColors.finesChipStart, AppColors.finesChipEnd], startPoint: .leading, endPoint: .trailing)
                    : LinearGradient(colors: [Color.clear, Color.clear], startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(
                    isActive ? Color.white.opacity(0.16) : AppColors.stroke.opacity(0.85),
                    lineWidth: 0.75
                )
            )
            .shadow(
                color: isActive ? Color.black.opacity(0.16) : .clear,
                radius: 8, x: 0, y: 4
            )
        }
        .buttonStyle(.plain)
        .animation(AppAnimations.standard, value: isActive)
    }

    // MARK: - Topics

    private var topicsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            ForEach(filtered) { topic in
                NavigationLink(value: AppDestination.ruleTopic(topic.id)) {
                    ruleTopicCard(topic)
                }
                .buttonStyle(NLTileButtonStyle())
            }
        }
        .animation(AppAnimations.softSpring, value: selectedCategory)
    }

    private func quickFineCard(_ example: QuickFineExample) -> some View {
        let accent = severityColor(example.severity)
        return HStack(alignment: .top, spacing: 12) {
            PremiumImageHeader(
                title: example.title,
                asset: fineImageAsset(icon: example.icon, category: nil),
                language: lang,
                symbol: example.icon,
                accent: accent,
                height: 88,
                width: 96,
                cornerRadius: 18,
                fallbackCategory: .transport
            )
            .layoutPriority(0)

            VStack(alignment: .leading, spacing: 7) {
                HStack(spacing: 8) {
                    Text(fineLabel)
                        .font(AppTypography.captionStrong)
                        .foregroundStyle(accent)
                    Text(example.fine)
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.textTertiary)
                }

                Text(example.title)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)

                Text("\(example.explanation) \(example.context)")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)
        }
        .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
        .appCardStyle()
    }

    private func ruleTopicCard(_ topic: RuleGuideTopic) -> some View {
        let accent = severityColor(topic.severity)
        return HStack(alignment: .top, spacing: 12) {
            PremiumImageHeader(
                title: topic.title,
                asset: fineImageAsset(icon: iconForCategory(topic.category), category: topic.category),
                language: lang,
                symbol: iconForCategory(topic.category),
                accent: accent,
                height: 88,
                width: 96,
                cornerRadius: 18,
                fallbackCategory: fineFallbackCategory(for: topic.category)
            )
            .layoutPriority(0)

            VStack(alignment: .leading, spacing: 7) {
                HStack(spacing: 8) {
                    Text(RuleGuideCategoryLocalization.localized(topic.category, lang: lang))
                        .font(AppTypography.captionStrong)
                        .foregroundStyle(accent)
                        .lineLimit(1)
                    Text(topic.estimatedFineRange)
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.textTertiary)
                        .lineLimit(1)
                }

                Text(topic.title)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)

                Text(topic.commonMistake)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)
        }
        .frame(maxWidth: .infinity, minHeight: 136, alignment: .topLeading)
        .appCardStyle()
    }

    // MARK: - Scenarios

    private var scenariosSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: L10n.t("fines.scenarios_title", lang))

            ForEach(visibleScenarios) { scenario in
                NavigationLink(value: AppDestination.ruleScenario(scenario.id)) {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(AppColors.accent.opacity(0.12))
                                .frame(width: 40, height: 40)
                            Image(systemName: "questionmark.circle.fill")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(AppColors.accent)
                        }
                        Text(scenario.title)
                            .font(.system(.subheadline, design: .rounded).weight(.semibold))
                            .foregroundStyle(AppColors.textPrimary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(AppColors.textTertiary)
                    }
                    .padding(15)
                    .background(AppColors.cardElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(AppColors.stroke.opacity(0.85), lineWidth: 0.75)
                    )
                }
                .buttonStyle(NLTileButtonStyle())
            }
        }
    }

    // MARK: - Helpers

    private func iconForCategory(_ category: String) -> String {
        switch category {
        case "Bicycle rules":               return "bicycle"
        case "Scooter / moped rules":       return "scooter"
        case "Car rules":                   return "car.fill"
        case "Parking fines":               return "parkingsign"
        case "Public transport fines":      return "tram.fill"
        case "Trash / garbage rules":       return "trash.fill"
        case "Smoking rules":               return "nosign"
        case "Noise complaints":            return "speaker.wave.3.fill"
        case "ID/passport obligations":     return "person.text.rectangle.fill"
        case "Alcohol/drug rules":          return "exclamationmark.octagon.fill"
        case "Municipality rules":          return "building.columns.fill"
        case "Housing violations":          return "house.fill"
        case "Work violations":             return "briefcase.fill"
        case "Scam warnings":              return "shield.lefthalf.filled"
        case "Tourist mistakes":            return "globe.europe.africa.fill"
        default:                            return "circle.fill"
        }
    }

    private func severityColor(_ severity: RuleSeverity) -> Color {
        switch severity {
        case .low: return AppColors.success
        case .medium: return AppColors.warning
        case .high: return AppColors.dutchOrange
        case .critical: return AppColors.error
        }
    }

    private func fineImageAsset(icon: String, category: String?) -> AppImageAsset? {
        let normalizedCategory = category?.lowercased() ?? ""
        if icon == "tram.fill" || normalizedCategory.contains("public transport") {
            return ContentMediaRegistry.ovChipkaartImage ?? ContentMediaRegistry.transportStationHero
        }
        if icon == "bicycle" || icon == "lightbulb.fill" || icon == "iphone" || icon == "figure.walk" || icon == "person.2.fill" || normalizedCategory.contains("bicycle") {
            return ContentMediaRegistry.transportHero ?? ContentMediaRegistry.transportStationHero
        }
        if icon == "parkingsign" || normalizedCategory.contains("parking") || normalizedCategory.contains("car") {
            return ContentMediaRegistry.transportStationHero ?? ContentMediaRegistry.transportHero
        }
        if normalizedCategory.contains("municipality") || normalizedCategory.contains("id/passport") {
            return ContentMediaRegistry.municipalityCityHallImage ?? ContentMediaRegistry.officialSourcesHero
        }
        if normalizedCategory.contains("housing") {
            return ContentMediaRegistry.premiumHousingImage ?? ContentMediaRegistry.housingTerracedHousesImage
        }
        if normalizedCategory.contains("work") {
            return ContentMediaRegistry.workImage ?? ContentMediaRegistry.officialSourcesHero
        }
        if normalizedCategory.contains("scam") {
            return ContentMediaRegistry.officialSourcesHero
        }
        return ContentMediaRegistry.transportHero ?? ContentMediaRegistry.officialSourcesHero
    }

    private func fineFallbackCategory(for category: String) -> PremiumImageFallbackCategory {
        let normalized = category.lowercased()
        if normalized.contains("housing") { return .housing }
        if normalized.contains("work") { return .work }
        if normalized.contains("municipality") || normalized.contains("id/passport") { return .government }
        if normalized.contains("scam") { return .search }
        return .transport
    }

    private var rulesBadgeText: String {
        switch lang {
        case .russian: return "Неофициальный гид"
        case .dutch: return "Onofficiële gids"
        case .english: return "Unofficial guide"
        }
    }

    private var quickFinesTitle: String {
        switch lang {
        case .russian: return "Частые штрафы"
        case .dutch: return "Veelvoorkomende boetes"
        case .english: return "Common fines"
        }
    }

    private var quickFinesSubtitle: String {
        switch lang {
        case .russian: return "Короткие примеры для быстрой ориентации"
        case .dutch: return "Korte voorbeelden voor snelle oriëntatie"
        case .english: return "Short examples for quick orientation"
        }
    }

    private var allRulesButtonTitle: String {
        switch lang {
        case .russian: return "Все правила и штрафы"
        case .dutch: return "Alle regels en boetes"
        case .english: return "All rules and fines"
        }
    }

    private var fineLabel: String {
        switch lang {
        case .russian: return "Штраф"
        case .dutch: return "Boete"
        case .english: return "Fine"
        }
    }
}

// MARK: - Fine Topic Card

private struct QuickFineExample: Identifiable {
    let id = UUID()
    let title: String
    let fine: String
    let explanation: String
    let context: String
    let icon: String
    let severity: RuleSeverity

    static func localized(_ lang: AppLanguage) -> [QuickFineExample] {
        switch lang {
        case .russian:
            return [
                QuickFineExample(title: "Езда без света", fine: "CJIB", explanation: "В темное время велосипед должен быть хорошо виден.", context: "Правило видимости для велосипедистов", icon: "lightbulb.fill", severity: .medium),
                QuickFineExample(title: "Телефон на велосипеде", fine: "CJIB", explanation: "Нельзя держать телефон в руке во время езды.", context: "Отвлечение внимания в дорожном движении", icon: "iphone", severity: .high),
                QuickFineExample(title: "Езда по тротуару", fine: "CJIB", explanation: "Велосипеды обычно должны ехать по велодорожке.", context: "Безопасность пешеходов и велосипедистов", icon: "figure.walk", severity: .medium),
                QuickFineExample(title: "Двойной багажник", fine: "CJIB", explanation: "Перевозка пассажира на багажнике часто небезопасна.", context: "Риск падения и травм", icon: "person.2.fill", severity: .low)
            ]
        case .dutch:
            return [
                QuickFineExample(title: "Fietsen zonder licht", fine: "CJIB", explanation: "In het donker moet je fiets goed zichtbaar zijn.", context: "Zichtbaarheid en verkeersveiligheid", icon: "lightbulb.fill", severity: .medium),
                QuickFineExample(title: "Telefoon op de fiets", fine: "CJIB", explanation: "Je mag geen telefoon vasthouden tijdens het fietsen.", context: "Afleiding in het verkeer", icon: "iphone", severity: .high),
                QuickFineExample(title: "Fietsen op de stoep", fine: "CJIB", explanation: "Fietsers horen meestal op het fietspad te rijden.", context: "Veiligheid voor voetgangers", icon: "figure.walk", severity: .medium),
                QuickFineExample(title: "Passagier op bagagedrager", fine: "CJIB", explanation: "Iemand achterop meenemen kan onveilig zijn.", context: "Valgevaar en letselrisico", icon: "person.2.fill", severity: .low)
            ]
        case .english:
            return [
                QuickFineExample(title: "Cycling without lights", fine: "CJIB", explanation: "Your bike must be visible in the dark.", context: "Visibility rule for cyclists", icon: "lightbulb.fill", severity: .medium),
                QuickFineExample(title: "Phone while cycling", fine: "CJIB", explanation: "You may not hold a phone while riding.", context: "Distraction in traffic", icon: "iphone", severity: .high),
                QuickFineExample(title: "Cycling on the sidewalk", fine: "CJIB", explanation: "Cyclists usually belong on the bike lane.", context: "Pedestrian and cyclist safety", icon: "figure.walk", severity: .medium),
                QuickFineExample(title: "Passenger on rear rack", fine: "CJIB", explanation: "Carrying someone on the rack is often unsafe.", context: "Fall and injury risk", icon: "person.2.fill", severity: .low)
            ]
        }
    }
}

// MARK: - Rule Topic Detail View

struct RuleTopicDetailView: View {
    let topic: RuleGuideTopic
    @EnvironmentObject private var languageManager: LanguageManager
    @ObservedObject private var savedStore = SavedItemsStore.shared
    @State private var expandedSections: Set<String> = ["what"]

    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                topMetaCard
                expandableDetailCard("what", L10n.t("rule.section.what_is", lang), topic.rule, icon: "book.fill", color: AppColors.softBlue)
                expandableDetailCard("why", L10n.t("rule.section.why", lang), topic.reason, icon: "lightbulb.fill", color: AppColors.warning)
                expandableDetailCard("mistake", L10n.t("rule.section.mistake", lang), topic.commonMistake, icon: "person.crop.circle.badge.exclamationmark", color: AppColors.dutchOrange)
                expandableDetailCard("fine", L10n.t("rule.section.fine_amount", lang), topic.estimatedFineRange, icon: "eurosign.circle.fill", color: AppColors.fineGold)
                expandableDetailCard("consequence", L10n.t("rule.section.consequence", lang), topic.consequence, icon: "exclamationmark.triangle.fill", color: AppColors.error)
                expandableDetailCard("authority", L10n.t("rule.section.authority", lang), topic.authority, icon: "building.columns.fill", color: AppColors.accent)
                expandableDetailCard("action", L10n.t("rule.section.already_fined", lang), topic.alreadyFinedAction, icon: "list.bullet.clipboard.fill", color: AppColors.accentLight)
                expandableDetailCard("example", L10n.t("rule.section.example", lang), topic.realLifeExample, icon: "bubble.left.and.bubble.right.fill", color: AppColors.softBlue)
                expandableDetailCard("avoid", L10n.t("rule.section.avoid", lang), topic.avoidWarning, icon: "shield.lefthalf.filled", color: AppColors.success)

                relatedTopicsCard
                safeWordingCard

                AIAskButton(
                    title: askAIRuleTitle,
                    context: AIContextBuilder.fineTopicContext(topic: topic, language: lang, appState: nil),
                    prompt: askAIRulePrompt
                )

                if let safeURL = AppURL.validatedWebURL(topic.officialSourceURL) {
                    Link(destination: safeURL) {
                        Label(
                            "\(L10n.t("beginner.open_official_source", lang)) (\(topic.officialSourceName))",
                            systemImage: "arrow.up.right.square"
                        )
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
        .appSceneBackground(.fines)
        .navigationTitle(topic.title)
        .nlNavigationInline()
    }

    private func detailCard(_ title: String, _ body: String, icon: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(color.opacity(0.14))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(color.opacity(0.90))
                    .textCase(.uppercase)
                    .tracking(0.6)
                Text(body)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.84))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)
            }
        }
        .nlCard()
    }

    private func expandableDetailCard(_ id: String, _ title: String, _ body: String, icon: String, color: Color) -> some View {
        DisclosureGroup(
            isExpanded: Binding(
                get: { expandedSections.contains(id) },
                set: { isExpanded in
                    if isExpanded { expandedSections.insert(id) } else { expandedSections.remove(id) }
                }
            )
        ) {
            Text(body)
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.84))
                .padding(.top, 10)
                .fixedSize(horizontal: false, vertical: true)
        } label: {
            Label(title, systemImage: icon)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(color)
        }
        .tint(color)
        .nlCard()
    }

    private var topMetaCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text(topic.title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            HStack(spacing: 8) {
                metaChip(RuleGuideCategoryLocalization.localized(topic.category, lang: lang), color: AppColors.softBlue)
                metaChip(topic.severity.localized(lang), color: severityColor(topic.severity))
                metaChip(topic.estimatedFineRange, color: Color(red: 1, green: 0.78, blue: 0.28))
            }

            Text(topic.authority)
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.55))

            Button(savedStore.isSaved("rule::\(topic.id.uuidString.lowercased())") ? saveOffText : saveOnText) {
                savedStore.toggle(
                    id: "rule::\(topic.id.uuidString.lowercased())",
                    kind: .rule,
                    title: topic.title,
                    subtitle: RuleGuideCategoryLocalization.localized(topic.category, lang: lang),
                    destination: .ruleTopic(topic.id)
                )
            }
            .buttonStyle(.bordered)
            .tint(AppColors.accent)
        }
        .nlCard()
    }

    private func metaChip(_ value: String, color: Color) -> some View {
        Text(value)
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .foregroundStyle(color)
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(color.opacity(0.14))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(color.opacity(0.25), lineWidth: 0.75))
    }

    private var relatedTopicsCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text(relatedTitle)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            if topic.relatedTopics.isEmpty {
                ruleNavigationRow(
                    title: relatedFallbackTitle,
                    subtitle: relatedFallbackSubtitle,
                    symbol: "list.bullet.rectangle.fill",
                    destination: .finesList
                )
                ruleNavigationRow(
                    title: officialSourcesTitle,
                    subtitle: officialSourcesSubtitle,
                    symbol: "building.columns.fill",
                    destination: .officialSources
                )
            } else {
                ForEach(topic.relatedTopics, id: \.self) { topicName in
                    ruleNavigationRow(
                        title: RuleGuideCategoryLocalization.localized(topicName, lang: lang),
                        subtitle: relatedTopicActionSubtitle,
                        symbol: "magnifyingglass",
                        destination: .searchList
                    )
                }
            }
        }
        .nlCard()
        .accessibilityIdentifier("fines.rule.relatedTopics.dashboard")
    }

    private func ruleNavigationRow(title: String, subtitle: String, symbol: String, destination: AppDestination) -> some View {
        NavigationLink(value: destination) {
            HStack(spacing: AppSpacing.small) {
                Image(systemName: symbol)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.softBlue)
                    .frame(width: 30, height: 30)
                    .background(AppColors.softBlue.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                    Text(subtitle)
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.62))
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.38))
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var safeWordingCard: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppColors.warning.opacity(0.14))
                    .frame(width: 36, height: 36)
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.warning)
            }
            VStack(alignment: .leading, spacing: 5) {
                Text(safeTitle)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.warning.opacity(0.90))
                    .textCase(.uppercase)
                    .tracking(0.6)
                Text(safeDetail)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.80))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)
            }
        }
        .nlCard()
    }

    private func severityColor(_ severity: RuleSeverity) -> Color {
        switch severity {
        case .low:      return AppColors.success
        case .medium:   return AppColors.warning
        case .high:     return AppColors.dutchOrange
        case .critical: return AppColors.error
        }
    }

    private var saveOnText: String {
        switch lang {
        case .russian: return "Сохранить правило"
        case .english: return "Save rule"
        case .dutch: return "Regel opslaan"
        }
    }

    private var saveOffText: String {
        switch lang {
        case .russian: return "Убрать из избранного"
        case .english: return "Remove from saved"
        case .dutch: return "Verwijder uit opgeslagen"
        }
    }

    private var relatedTitle: String {
        switch lang {
        case .russian: return "Связанные темы"
        case .english: return "Related topics"
        case .dutch: return "Gerelateerde onderwerpen"
        }
    }

    private var relatedTopicActionSubtitle: String {
        switch lang {
        case .russian: return "Открыть поиск по связанным правилам и источникам"
        case .english: return "Search related rules and sources"
        case .dutch: return "Zoek verwante regels en bronnen"
        }
    }

    private var relatedFallbackTitle: String {
        switch lang {
        case .russian: return "Смотреть все правила и штрафы"
        case .english: return "View all rules and fines"
        case .dutch: return "Bekijk alle regels en boetes"
        }
    }

    private var relatedFallbackSubtitle: String {
        switch lang {
        case .russian: return "Сравните похожие ситуации перед оплатой или обжалованием"
        case .english: return "Compare similar situations before payment or objection"
        case .dutch: return "Vergelijk soortgelijke situaties voor betaling of bezwaar"
        }
    }

    private var officialSourcesTitle: String {
        switch lang {
        case .russian: return "Проверить официальный источник"
        case .english: return "Check official sources"
        case .dutch: return "Controleer officiële bronnen"
        }
    }

    private var officialSourcesSubtitle: String {
        switch lang {
        case .russian: return "Суммы и процедуры могут меняться"
        case .english: return "Amounts and procedures can change"
        case .dutch: return "Bedragen en procedures kunnen veranderen"
        }
    }

    private var safeTitle: String {
        switch lang {
        case .russian: return "Важное уточнение"
        case .english: return "Important note"
        case .dutch: return "Belangrijke opmerking"
        }
    }

    private var safeDetail: String {
        switch lang {
        case .russian: return "Суммы штрафов указаны примерно, могут отличаться и меняться. Всегда проверяйте официальный источник перед оплатой или обжалованием."
        case .english: return "Fine ranges are approximate and may differ or change. Always verify official sources before payment or objection."
        case .dutch: return "Boetebedragen zijn indicatief en kunnen verschillen of wijzigen. Controleer altijd officiële bronnen voor betaling of bezwaar."
        }
    }

    private var askAIRuleTitle: String {
        switch lang {
        case .russian: return "Спросить AI об этом правиле"
        case .dutch: return "Vraag AI over deze regel"
        case .english: return "Ask AI about this rule"
        }
    }

    private var askAIRulePrompt: String {
        switch lang {
        case .russian: return "Объясните это правило просто и скажите что делать дальше."
        case .dutch: return "Leg deze regel eenvoudig uit en zeg wat ik nu moet doen."
        case .english: return "Explain this rule simply and tell me what to do next."
        }
    }
}

#if DEBUG && os(iOS)
private struct FinesInfoPreviewContainer: View {
    @StateObject private var languageManager: LanguageManager
    @StateObject private var appState = AppStateViewModel()
    @StateObject private var savedItemsStore = SavedItemsStore()
    @StateObject private var documentStore = DocumentStore()

    init(language: AppLanguage) {
        let manager = LanguageManager()
        manager.appLanguage = language
        _languageManager = StateObject(wrappedValue: manager)
    }

    var body: some View {
        NavigationStack {
            FinesInfoView()
                .navigationDestination(for: AppDestination.self) { destination in
                    AppDestinationView(destination: destination)
                }
        }
        .environmentObject(languageManager)
        .environmentObject(appState)
        .environmentObject(savedItemsStore)
        .environmentObject(documentStore)
    }
}

#Preview("Rules QA - RU iPhone SE", traits: .fixedLayout(width: 375, height: 667)) {
    FinesInfoPreviewContainer(language: .russian)
        .environment(\.dynamicTypeSize, .large)
        .transaction { $0.animation = nil }
}
#endif

// MARK: - Fine Info Detail View

struct FineInfoDetailView: View {
    let item: FineInfoItem
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                InfoCard(
                    title: item.title(lang),
                    subtitle: item.category.localized(lang),
                    detail: item.simpleExplanation(lang),
                    icon: item.category.systemImageName
                )
                InfoCard(
                    title: L10n.t("fines.possible_consequence", lang),
                    subtitle: nil,
                    detail: item.possibleConsequence(lang),
                    icon: "exclamationmark.triangle"
                )
                InfoCard(
                    title: L10n.t("fines.what_to_do", lang),
                    subtitle: nil,
                    detail: item.userAction(lang),
                    icon: "checkmark.circle"
                )
                DisclaimerBanner(text: L10n.t("fines.check_amounts_warning", lang))
                AIAskButton(
                    title: askAIFineTitle,
                    context: AIContextBuilder.fineInfoDetailContext(item: item, language: lang, appState: nil),
                    prompt: askAIFinePrompt
                )
                if let safeURL = AppURL.validatedWebURL(item.officialSourceURL) {
                    Link(destination: safeURL) {
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
        .appSceneBackground(.fines)
        .navigationTitle(item.title(lang))
        .nlNavigationInline()
    }

    private var askAIFineTitle: String {
        switch lang {
        case .russian: return "Спросить AI об этом штрафе"
        case .dutch: return "Vraag AI over deze boete"
        case .english: return "Ask AI about this fine"
        }
    }

    private var askAIFinePrompt: String {
        switch lang {
        case .russian: return "Объясните этот штраф просто и скажите что делать дальше."
        case .dutch: return "Leg deze boete eenvoudig uit en zeg wat ik nu moet doen."
        case .english: return "Explain this fine simply and tell me what to do next."
        }
    }
}
