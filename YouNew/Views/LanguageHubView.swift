import SwiftUI

struct LanguageHubView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }
    private var activePersona: PersonaTag? { appState.selectedUserStatus?.personaTag }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 920) {
                VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    heroSection

                    NLSectionHeader(title: startTitle, subtitle: startSubtitle)
                    startSection

                    NLSectionHeader(title: resourcesTitle)
                    resourcesSection

                    examBanner

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
            assetName: "home_language_classroom",
            title: navTitle,
            subtitle: heroSubtitle,
            symbol: "text.book.closed.fill",
            badgeText: badgeText,
            accent: AppColors.violet,
            asset: ContentMediaRegistry.dailyCultureImage ?? ContentMediaRegistry.profileImage ?? ContentMediaRegistry.officialSourcesHero
        )
    }

    private var startSection: some View {
        VStack(spacing: AppSpacing.small) {
            if isVisible(.dutchA1A2) {
                NavigationLink(value: AppDestination.dutchA1A2) {
                    languageRow(
                        icon: "1.circle.fill",
                        title: a1Title,
                        subtitle: a1Subtitle,
                        badge: "A1 · A2",
                        color: AppColors.emerald
                    )
                }
                .buttonStyle(NLTileButtonStyle())
            }

            if isVisible(.dutchTermsList) {
                NavigationLink(value: AppDestination.dutchTermsList) {
                    languageRow(
                        icon: "text.magnifyingglass",
                        title: termsTitle,
                        subtitle: termsSubtitle,
                        badge: nil,
                        color: AppColors.softBlue
                    )
                }
                .buttonStyle(NLTileButtonStyle())
            }

            if isVisible(.knm) {
                NavigationLink(value: AppDestination.knm) {
                    languageRow(
                        icon: "graduationcap.fill",
                        title: knmTitle,
                        subtitle: knmSubtitle,
                        badge: "KNM",
                        color: AppColors.cyanGlow
                    )
                }
                .buttonStyle(NLTileButtonStyle())
            }
        }
    }

    private var resourcesSection: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(minimum: 140), spacing: AppSpacing.small),
                GridItem(.flexible(minimum: 140), spacing: AppSpacing.small)
            ],
            spacing: AppSpacing.small
        ) {
            ForEach(visibleResourceCards) { card in
                NavigationLink(value: card.destination) {
                    miniResourceCard(card)
                }
                .buttonStyle(NLTileButtonStyle())
            }
        }
    }

    private struct ResourceCard: Identifiable {
        let id: String
        let icon: String
        let titleEN: String
        let titleNL: String
        let titleRU: String
        let color: Color
        let destination: AppDestination

        func title(_ lang: AppLanguage) -> String {
            switch lang {
            case .english: return titleEN
            case .dutch:   return titleNL
            case .russian: return titleRU
            }
        }
    }

    private var resourceCards: [ResourceCard] {
        [
            ResourceCard(id: "a1", icon: "book.fill", titleEN: "A1–A2 Course", titleNL: "A1–A2 cursus", titleRU: "Курс A1–A2", color: AppColors.emerald, destination: .dutchA1A2),
            ResourceCard(id: "terms", icon: "text.magnifyingglass", titleEN: "Dutch terms", titleNL: "Nederlandse termen", titleRU: "Нидерландские термины", color: AppColors.softBlue, destination: .dutchTermsList),
            ResourceCard(id: "knm", icon: "graduationcap.fill", titleEN: "KNM practice", titleNL: "KNM oefenen", titleRU: "Практика KNM", color: AppColors.cyanGlow, destination: .knm),
            ResourceCard(id: "history", icon: "clock.arrow.circlepath", titleEN: "NL history", titleNL: "NL geschiedenis", titleRU: "История НЛ", color: AppColors.dutchOrange, destination: .netherlandsHistory)
        ]
    }

    private var visibleResourceCards: [ResourceCard] {
        resourceCards.filter { isVisible($0.destination) }
    }

    private func isVisible(_ destination: AppDestination) -> Bool {
        RelatedContentEngine.isVisible(destination, for: activePersona)
    }

    private func miniResourceCard(_ card: ResourceCard) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: card.icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(card.color)
                .frame(width: 38, height: 38)
                .background(card.color.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            Text(card.title(lang))
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .minimumScaleFactor(0.82)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 88, alignment: .topLeading)
        .appCardStyle()
    }

    private func languageRow(icon: String, title: String, subtitle: String, badge: String?, color: Color) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(color)
                .frame(width: 48, height: 48)
                .background(color.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 7) {
                    Text(title)
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColors.textPrimary)
                    if let badge {
                        Text(badge)
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundStyle(color)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(color.opacity(0.14))
                            .clipShape(Capsule())
                    }
                }
                Text(subtitle)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppColors.textTertiary)
        }
        .appGlassCardStyle(padding: 14, cornerRadius: 18, accent: color)
    }

    private var examBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColors.success)
            VStack(alignment: .leading, spacing: 2) {
                Text(examTitle)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.textPrimary)
                Text(examSubtitle)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .appGlassCardStyle(padding: 14, cornerRadius: 18, accent: AppColors.success)
    }

    // MARK: - Strings

    private var navTitle: String {
        switch lang {
        case .russian: return "Нидерландский язык"
        case .dutch:   return "Nederlandse taal"
        case .english: return "Dutch language"
        }
    }

    private var heroSubtitle: String {
        switch lang {
        case .russian: return "Основы A1–A2, фразы, словарь, KNM и подготовка к экзамену NT2."
        case .dutch:   return "A1–A2 basis, zinnen, woordenschat, KNM en voorbereiding op het NT2-examen."
        case .english: return "A1–A2 basics, phrases, vocabulary, KNM, and NT2 exam preparation."
        }
    }

    private var badgeText: String {
        switch lang {
        case .russian: return "A1 · A2 · B1 · KNM"
        case .dutch:   return "A1 · A2 · B1 · KNM"
        case .english: return "A1 · A2 · B1 · KNM"
        }
    }

    private var startTitle: String {
        switch lang {
        case .russian: return "Начните учиться"
        case .dutch:   return "Begin met leren"
        case .english: return "Start learning"
        }
    }

    private var startSubtitle: String {
        switch lang {
        case .russian: return "Практический нидерландский для повседневной жизни"
        case .dutch:   return "Praktisch Nederlands voor dagelijks leven"
        case .english: return "Practical Dutch for daily life"
        }
    }

    private var resourcesTitle: String {
        switch lang {
        case .russian: return "Ресурсы"
        case .dutch:   return "Bronnen"
        case .english: return "Resources"
        }
    }

    private var a1Title: String {
        switch lang {
        case .russian: return "Нидерландский A1–A2"
        case .dutch:   return "Nederlands A1–A2"
        case .english: return "Dutch A1–A2"
        }
    }

    private var a1Subtitle: String {
        switch lang {
        case .russian: return "Слова, фразы и грамматика для повседневной жизни"
        case .dutch:   return "Woorden, zinnen en grammatica voor dagelijks leven"
        case .english: return "Words, phrases, and grammar for daily life"
        }
    }

    private var termsTitle: String {
        switch lang {
        case .russian: return "Словарь нидерландских терминов"
        case .dutch:   return "Nederlandse woordenlijst"
        case .english: return "Dutch terms dictionary"
        }
    }

    private var termsSubtitle: String {
        switch lang {
        case .russian: return "Официальные и бытовые термины с переводом"
        case .dutch:   return "Officiële en dagelijkse termen met uitleg"
        case .english: return "Official and everyday terms with explanations"
        }
    }

    private var knmTitle: String {
        switch lang {
        case .russian: return "KNM — знание общества"
        case .dutch:   return "KNM — kennis van de maatschappij"
        case .english: return "KNM — Knowledge of Dutch Society"
        }
    }

    private var knmSubtitle: String {
        switch lang {
        case .russian: return "Темы и вопросы для подготовки к интеграционному экзамену"
        case .dutch:   return "Thema's en vragen voor voorbereiding op het inburgeringsexamen"
        case .english: return "Topics and practice questions for the integration exam"
        }
    }

    private var examTitle: String {
        switch lang {
        case .russian: return "Экзамен NT2 — через DUO"
        case .dutch:   return "NT2-examen — via DUO"
        case .english: return "NT2 exam — via DUO"
        }
    }

    private var examSubtitle: String {
        switch lang {
        case .russian: return "Официальная регистрация на экзамен на сайте duo.nl. Инбюргерование через inburgeren.nl."
        case .dutch:   return "Officiële exameninschrijving via duo.nl. Inburgering via inburgeren.nl."
        case .english: return "Official exam registration at duo.nl. Integration process at inburgeren.nl."
        }
    }
}
