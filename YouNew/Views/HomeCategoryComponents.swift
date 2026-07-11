import SwiftUI

// MARK: - Quick Actions

struct HomeQuickActionsSection: View {
    let title: String
    let actions: [HomeQuickAction]
    let language: AppLanguage

    var body: some View {
        if !actions.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                NLSectionHeader(title: title)

                LazyVGrid(
                    columns: [
                        GridItem(.flexible(minimum: 0), spacing: 10),
                        GridItem(.flexible(minimum: 0), spacing: 10)
                    ],
                    spacing: 10
                ) {
                    ForEach(actions, id: \.id) { action in
                        NavigationLink(value: action.destination) {
                            QuickActionChip(action: action, language: language)
                        }
                        .buttonStyle(NLTileButtonStyle())
                    }
                }
                .sectionPadding()
            }
        }
    }
}

// MARK: - Categories Grid

struct HomeCategoriesGridSection: View {
    let title: String
    let viewAllLabel: String
    let showAllCategoriesLink: Bool
    let categories: [HomeCategoryItem]
    let scenarios: [HomeLifeScenario]
    let language: AppLanguage

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        if !categories.isEmpty || !scenarios.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                header
                categoriesGrid
                scenarioCards
            }
        }
    }

    private var header: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .lastTextBaseline, spacing: 12) {
                titleText

                Spacer(minLength: 12)

                if showAllCategoriesLink {
                    viewAllLink
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                titleText

                if showAllCategoriesLink {
                    viewAllLink
                }
            }
        }
    }

    private var titleText: some View {
        Text(title)
            .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 31 : 28, weight: .heavy, design: .rounded))
            .foregroundStyle(.white)
            .lineLimit(2)
            .minimumScaleFactor(0.86)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var viewAllLink: some View {
        NavigationLink(value: AppDestination.categoriesHub) {
            Label(viewAllLabel, systemImage: "chevron.right")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(AppColors.softBlue.opacity(0.28))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.white.opacity(0.14), lineWidth: 0.8))
        }
        .buttonStyle(NLTileButtonStyle())
    }

    @ViewBuilder
    private var categoriesGrid: some View {
        if !categories.isEmpty {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(minimum: 0), spacing: 12),
                    GridItem(.flexible(minimum: 0), spacing: 12)
                ],
                spacing: 12
            ) {
                ForEach(categories, id: \.id) { category in
                    NavigationLink(value: category.destination) {
                        ProductTaskCard(
                            title: category.title(language),
                            subtitle: categorySubtitle(category),
                            symbol: category.icon,
                            accent: category.gradient.first ?? AppColors.dutchOrange,
                            minHeight: 132
                        )
                    }
                    .buttonStyle(NLTileButtonStyle())
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(category.title(language))
                    .accessibilityIdentifier("home.category.\(category.id)")
                }
            }
        }
    }

    private var scenarioCards: some View {
        VStack(spacing: 12) {
            ForEach(scenarios.prefix(3)) { scenario in
                NavigationLink(value: scenario.destination) {
                    PremiumImageCard(
                        title: scenario.title(language),
                        subtitle: scenario.subtitle(language),
                        asset: scenario.asset,
                        language: language,
                        symbol: "sparkles",
                        accent: scenario.accent,
                        imageHeight: dynamicTypeSize.isAccessibilitySize ? 220 : 174,
                        minHeight: dynamicTypeSize.isAccessibilitySize ? 300 : 252,
                        fallbackCategory: .city
                    ) {
                        EmptyView()
                    }
                }
                .buttonStyle(NLTileButtonStyle())
                .accessibilityLabel("\(scenario.title(language)). \(scenario.subtitle(language))")
            }
        }
    }

    private func categorySubtitle(_ category: HomeCategoryItem) -> String {
        HomeCategorySubtitle.text(for: category.id, language: language)
    }
}

// MARK: - Audience Categories

struct HomeAudienceCategorySection: View {
    let shouldShow: Bool
    let title: String
    let subtitle: String?
    let categories: [HomeCategoryItem]
    let language: AppLanguage
    let accessibilityIdentifier: String

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        if shouldShow, !categories.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                sectionTitle
                categoryGrid
            }
            .homeReadableBand()
            .padding(.bottom, 34)
            .accessibilityIdentifier(accessibilityIdentifier)
        }
    }

    private var sectionTitle: some View {
        let visibleSubtitle = subtitle?.trimmingCharacters(in: .whitespacesAndNewlines)
        return VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 28 : AppTypography.Scale.section, weight: .semibold))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
                .fixedSize(horizontal: false, vertical: true)

            if let visibleSubtitle, !visibleSubtitle.isEmpty {
                Text(visibleSubtitle)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(3)
                    .minimumScaleFactor(0.78)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var categoryGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(minimum: 0), spacing: 12),
                GridItem(.flexible(minimum: 0), spacing: 12)
            ],
            spacing: 12
        ) {
            ForEach(categories) { category in
                NavigationLink(value: category.destination) {
                    ProductTaskCard(
                        title: category.title(language),
                        subtitle: categorySubtitle(category),
                        symbol: category.icon,
                        accent: category.gradient.first ?? AppColors.dutchOrange,
                        minHeight: 132
                    )
                }
                .buttonStyle(NLTileButtonStyle())
            }
        }
    }

    private func categorySubtitle(_ category: HomeCategoryItem) -> String {
        HomeCategorySubtitle.text(for: category.id, language: language)
    }
}

private enum HomeCategorySubtitle {
    static func text(for id: String, language: AppLanguage) -> String {
        switch id {
        case "rules_fines":
            return localized(language, en: "Traffic, fines, letters", nl: "Verkeer, boetes, brieven", ru: "Правила, штрафы, письма")
        case "documents":
            return localized(language, en: "BSN, DigiD, official steps", nl: "BSN, DigiD, officiële stappen", ru: "BSN, DigiD, официальные шаги")
        case "lost_documents":
            return localized(language, en: "Report and replace safely", nl: "Melden en veilig vervangen", ru: "Сообщить и восстановить")
        case "transport":
            return localized(language, en: "OV, bikes, routes", nl: "OV, fiets, routes", ru: "OV, велосипед, маршруты")
        case "work_taxes":
            return localized(language, en: "Contracts, salary, taxes", nl: "Contracten, salaris, belasting", ru: "Договоры, зарплата, налоги")
        case "housing":
            return localized(language, en: "Rent, address, contracts", nl: "Huur, adres, contracten", ru: "Аренда, адрес, договоры")
        case "healthcare":
            return localized(language, en: "GP, insurance, urgent care", nl: "Huisarts, verzekering, spoed", ru: "Huisarts, страховка, срочно")
        case "government":
            return localized(language, en: "Municipality and services", nl: "Gemeente en diensten", ru: "Gemeente и службы")
        case "education":
            return localized(language, en: "Schools, DUO, study", nl: "Scholen, DUO, studie", ru: "Школы, DUO, учёба")
        case "help_nearby":
            return localized(language, en: "Map and nearby support", nl: "Kaart en hulp dichtbij", ru: "Карта и помощь рядом")
        case "emergency_112":
            return localized(language, en: "112 and urgent help", nl: "112 en spoedhulp", ru: "112 и срочная помощь")
        case "places":
            return localized(language, en: "Museums and landmarks", nl: "Musea en bezienswaardigheden", ru: "Музеи и места")
        case "museums":
            return localized(language, en: "Culture and attractions", nl: "Cultuur en attracties", ru: "Культура и достопримечательности")
        case "cycling":
            return localized(language, en: "Bike rules and safety", nl: "Fietsregels en veiligheid", ru: "Правила и безопасность")
        case "food_events":
            return localized(language, en: "Cafés, restaurants, events", nl: "Cafés, restaurants, events", ru: "Кафе, рестораны, события")
        default:
            return localized(language, en: "Guide and sources", nl: "Gids en bronnen", ru: "Гид и источники")
        }
    }

    private static func localized(_ language: AppLanguage, en: String, nl: String, ru: String) -> String {
        switch language {
        case .russian: return ru
        case .dutch: return nl
        case .english: return en
        }
    }
}
