import SwiftUI

struct HistoryKNMHubView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }
    private var activePersona: PersonaTag? { appState.selectedUserStatus?.personaTag }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 920) {
                VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    heroSection

                    NLSectionHeader(title: historyTitle, subtitle: historySubtitle)
                    historySection

                    NLSectionHeader(title: heritageTitle, subtitle: heritageSubtitle)
                    heritageSection

                    NLSectionHeader(title: knmTitle, subtitle: knmSubtitle)
                    knmSection

                    NLSectionHeader(title: cultureTitle)
                    cultureSection

                    factsCard

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
            assetName: nil,
            title: navTitle,
            subtitle: heroSubtitle,
            symbol: "clock.arrow.circlepath",
            badgeText: badgeText,
            accent: AppColors.cyanGlow,
            asset: ContentMediaRegistry.cultureWindmillHero ?? ContentMediaRegistry.cultureHero
        )
    }

    private var historySection: some View {
        VStack(spacing: AppSpacing.small) {
            if isVisible(.netherlandsHistory) {
                NavigationLink(value: AppDestination.netherlandsHistory) {
                    hubRow(icon: "clock.arrow.circlepath", title: historyRowTitle, subtitle: historyRowSubtitle, badge: nil, color: AppColors.cyanGlow)
                }
                .buttonStyle(NLTileButtonStyle())
            }

            if isVisible(.cultureAttractions) {
                NavigationLink(value: AppDestination.cultureAttractions) {
                    hubRow(icon: "sparkles.rectangle.stack.fill", title: cultureRowTitle, subtitle: cultureRowSubtitle, badge: nil, color: AppColors.dutchOrange)
                }
                .buttonStyle(NLTileButtonStyle())
            }
        }
    }

    private var heritageSection: some View {
        VStack(spacing: AppSpacing.small) {
            if isVisible(.dutchFigures) {
                NavigationLink(value: AppDestination.dutchFigures) {
                    hubRow(icon: "person.3.sequence.fill", title: figuresRowTitle, subtitle: figuresRowSubtitle, badge: nil, color: AppColors.dutchOrange)
                }
                .buttonStyle(NLTileButtonStyle())
            }

            if isVisible(.dutchMonarchy) {
                NavigationLink(value: AppDestination.dutchMonarchy) {
                    hubRow(icon: "crown.fill", title: monarchyRowTitle, subtitle: monarchyRowSubtitle, badge: nil, color: AppColors.violet)
                }
                .buttonStyle(NLTileButtonStyle())
            }

            if isVisible(.dutchHolidays) {
                NavigationLink(value: AppDestination.dutchHolidays) {
                    hubRow(icon: "calendar.badge.clock", title: holidaysRowTitle, subtitle: holidaysRowSubtitle, badge: "2026", color: AppColors.cyanGlow)
                }
                .buttonStyle(NLTileButtonStyle())
            }
        }
    }

    private var knmSection: some View {
        VStack(spacing: AppSpacing.small) {
            if isVisible(.knm) {
                NavigationLink(value: AppDestination.knm) {
                    hubRow(icon: "graduationcap.fill", title: knmRowTitle, subtitle: knmRowSubtitle, badge: "KNM", color: AppColors.violet)
                }
                .buttonStyle(NLTileButtonStyle())
            }
        }
    }

    private var cultureSection: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(minimum: 140), spacing: AppSpacing.small),
                GridItem(.flexible(minimum: 140), spacing: AppSpacing.small)
            ],
            spacing: AppSpacing.small
        ) {
            ForEach(visibleCultureTopics) { topic in
                NavigationLink(value: topic.destination) {
                    miniTopicCard(topic)
                }
                .buttonStyle(NLTileButtonStyle())
            }
        }
    }

    private struct CultureTopic: Identifiable {
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

    private var cultureTopics: [CultureTopic] {
        [
            CultureTopic(id: "history", icon: "clock.arrow.circlepath", titleEN: "NL History", titleNL: "NL Geschiedenis", titleRU: "История НЛ", color: AppColors.cyanGlow, destination: .netherlandsHistory),
            CultureTopic(id: "culture", icon: "building.columns.fill", titleEN: "Culture", titleNL: "Cultuur", titleRU: "Культура", color: AppColors.dutchOrange, destination: .cultureAttractions),
            CultureTopic(id: "knm", icon: "graduationcap.fill", titleEN: "KNM Exam", titleNL: "KNM Examen", titleRU: "Экзамен KNM", color: AppColors.violet, destination: .knm),
            CultureTopic(id: "provinces", icon: "map.fill", titleEN: "Provinces", titleNL: "Provincies", titleRU: "Провинции", color: AppColors.softBlue, destination: .provinceList)
        ]
    }

    private var visibleCultureTopics: [CultureTopic] {
        cultureTopics.filter { isVisible($0.destination) }
    }

    private func isVisible(_ destination: AppDestination) -> Bool {
        RelatedContentEngine.isVisible(destination, for: activePersona)
    }

    private func miniTopicCard(_ topic: CultureTopic) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: topic.icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(topic.color)
                .frame(width: 38, height: 38)
                .background(topic.color.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            Text(topic.title(lang))
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

    private func hubRow(icon: String, title: String, subtitle: String, badge: String?, color: Color) -> some View {
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

    private var factsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(quickFactsTitle, systemImage: "lightbulb.fill")
                .font(AppTypography.bodyStrong)
                .foregroundStyle(AppColors.dutchOrange)

            ForEach(quickFacts, id: \.self) { fact in
                HStack(alignment: .top, spacing: 8) {
                    Text("·")
                        .foregroundStyle(AppColors.dutchOrange)
                    Text(fact)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .appGlassCardStyle(padding: 14, cornerRadius: 18, accent: AppColors.dutchOrange)
    }

    // MARK: - Strings

    private var navTitle: String {
        switch lang {
        case .russian: return "История и КНМ"
        case .dutch:   return "Geschiedenis & KNM"
        case .english: return "History & KNM"
        }
    }

    private var heroSubtitle: String {
        switch lang {
        case .russian: return "История Нидерландов, монархия, парламент, провинции и подготовка к интеграционному экзамену KNM."
        case .dutch:   return "Geschiedenis van Nederland, monarchie, parlement, provincies en voorbereiding op het KNM-inburgeringsexamen."
        case .english: return "History of the Netherlands, monarchy, parliament, provinces, and KNM integration exam preparation."
        }
    }

    private var badgeText: String {
        switch lang {
        case .russian: return "История · KNM · Культура"
        case .dutch:   return "Geschiedenis · KNM · Cultuur"
        case .english: return "History · KNM · Culture"
        }
    }

    private var historyTitle: String {
        switch lang {
        case .russian: return "История Нидерландов"
        case .dutch:   return "Geschiedenis van Nederland"
        case .english: return "History of the Netherlands"
        }
    }

    private var historySubtitle: String {
        switch lang {
        case .russian: return "От воды и торговли до современного общества"
        case .dutch:   return "Van water en handel tot de moderne samenleving"
        case .english: return "From water and trade to modern Dutch society"
        }
    }

    private var knmTitle: String {
        switch lang {
        case .russian: return "KNM — Знание нидерландского общества"
        case .dutch:   return "KNM — Kennis van de Nederlandse Maatschappij"
        case .english: return "KNM — Knowledge of Dutch Society"
        }
    }

    private var knmSubtitle: String {
        switch lang {
        case .russian: return "Подготовка к интеграционному экзамену"
        case .dutch:   return "Voorbereiding op het inburgeringsexamen"
        case .english: return "Preparation for the integration exam"
        }
    }

    private var cultureTitle: String {
        switch lang {
        case .russian: return "Темы"
        case .dutch:   return "Onderwerpen"
        case .english: return "Topics"
        }
    }

    private var historyRowTitle: String {
        switch lang {
        case .russian: return "История Нидерландов"
        case .dutch:   return "Geschiedenis van Nederland"
        case .english: return "History of the Netherlands"
        }
    }

    private var historyRowSubtitle: String {
        switch lang {
        case .russian: return "Вода, торговля, республика, монархия и современность"
        case .dutch:   return "Water, handel, republiek, monarchie en moderniteit"
        case .english: return "Water, trade, republic, monarchy, and modern times"
        }
    }

    private var cultureRowTitle: String {
        switch lang {
        case .russian: return "Культура и достопримечательности"
        case .dutch:   return "Cultuur & attracties"
        case .english: return "Culture & attractions"
        }
    }

    private var cultureRowSubtitle: String {
        switch lang {
        case .russian: return "Музеи, каналы, рынки и культурное наследие"
        case .dutch:   return "Musea, grachten, markten en cultureel erfgoed"
        case .english: return "Museums, canals, markets, and cultural heritage"
        }
    }

    private var knmRowTitle: String {
        switch lang {
        case .russian: return "Тренировка KNM"
        case .dutch:   return "KNM oefenen"
        case .english: return "KNM practice"
        }
    }

    private var knmRowSubtitle: String {
        switch lang {
        case .russian: return "Модули и тренировочные вопросы для интеграционного экзамена"
        case .dutch:   return "Modules en oefenvragen voor het inburgeringsexamen"
        case .english: return "Modules and practice questions for the integration exam"
        }
    }

    private var heritageTitle: String {
        switch lang {
        case .russian: return "Культурное наследие"
        case .dutch:   return "Cultureel erfgoed"
        case .english: return "Cultural Heritage"
        }
    }

    private var heritageSubtitle: String {
        switch lang {
        case .russian: return "Великие нидерландцы, монархия и государственные праздники"
        case .dutch:   return "Grote Nederlanders, monarchie en officiële feestdagen"
        case .english: return "Great Dutch figures, monarchy, and official holidays"
        }
    }

    private var figuresRowTitle: String {
        switch lang {
        case .russian: return "Великие нидерландцы"
        case .dutch:   return "Grote Nederlanders"
        case .english: return "Great Dutch Figures"
        }
    }

    private var figuresRowSubtitle: String {
        switch lang {
        case .russian: return "Рембрандт, Вермеер, Ван Гог, Спиноза, Эразм и другие"
        case .dutch:   return "Rembrandt, Vermeer, Van Gogh, Spinoza, Erasmus en anderen"
        case .english: return "Rembrandt, Vermeer, Van Gogh, Spinoza, Erasmus and more"
        }
    }

    private var monarchyRowTitle: String {
        switch lang {
        case .russian: return "Монархия Нидерландов"
        case .dutch:   return "Nederlandse Monarchie"
        case .english: return "Dutch Monarchy"
        }
    }

    private var monarchyRowSubtitle: String {
        switch lang {
        case .russian: return "Короли и королевы с 1815 года до наших дней, роль монарха"
        case .dutch:   return "Koningen en koninginnen van 1815 tot heden, rol van de monarch"
        case .english: return "Kings and queens from 1815 to the present, role of the monarch"
        }
    }

    private var holidaysRowTitle: String {
        switch lang {
        case .russian: return "Праздники Нидерландов"
        case .dutch:   return "Nederlandse feestdagen"
        case .english: return "Dutch Holidays"
        }
    }

    private var holidaysRowSubtitle: String {
        switch lang {
        case .russian: return "Официальный календарь 2026: история праздников, что закрыто"
        case .dutch:   return "Officiële kalender 2026: geschiedenis van feestdagen, wat gesloten is"
        case .english: return "Official 2026 calendar: holiday history, what's closed"
        }
    }

    private var quickFactsTitle: String {
        switch lang {
        case .russian: return "Быстрые факты"
        case .dutch:   return "Snelle feiten"
        case .english: return "Quick facts"
        }
    }

    private var quickFacts: [String] {
        switch lang {
        case .russian: return [
            "Нидерланды — конституционная монархия с 1815 года",
            "Парламент: Eerste Kamer (сенат) и Tweede Kamer (нижняя палата)",
            "12 провинций, столица — Амстердам, правительство — в Гааге",
            "KNM — обязательная часть интеграционного экзамена (inburgering)"
        ]
        case .dutch: return [
            "Nederland is een constitutionele monarchie sinds 1815",
            "Parlement: Eerste Kamer (senaat) en Tweede Kamer (lagerhuis)",
            "12 provincies, hoofdstad Amsterdam, regeringszetel Den Haag",
            "KNM is verplicht onderdeel van het inburgeringsexamen"
        ]
        case .english: return [
            "Netherlands is a constitutional monarchy since 1815",
            "Parliament: Eerste Kamer (senate) and Tweede Kamer (lower house)",
            "12 provinces, capital Amsterdam, government seat The Hague",
            "KNM is a required part of the integration (inburgering) exam"
        ]
        }
    }
}
