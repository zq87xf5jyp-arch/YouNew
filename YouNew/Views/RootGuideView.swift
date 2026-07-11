import SwiftUI

struct RootGuideView: View {
    var onAskAI: () -> Void = {}
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var router: TabRouter

    private var language: AppLanguage { languageManager.appLanguage }
    private let columns = [GridItem(.adaptive(minimum: 150, maximum: 280), spacing: 14)]

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 22) {
                    Color.clear.frame(height: 1).id("guide.top")
                    header
                    searchAction
                    categoryGrid
                    popularContent
                    recentlyUpdated
                    sourceNote
                    Color.clear.frame(height: AppSpacing.tabBarScrollReserve)
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
            }
            .accessibilityIdentifier("guide.scrollContent")
            .safeAreaPadding(.top, 4)
            .onReceive(router.guideScrollTop) {
                withAnimation(.easeInOut(duration: 0.22)) {
                    proxy.scrollTo("guide.top", anchor: .top)
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(localized(en: "Guide", nl: "Gids", ru: "Гид"))
                .font(.largeTitle.bold())
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("screen.guide")
            Text(localized(
                en: "Everything in YouNew, organized by topic. Your profile changes recommendations, never access.",
                nl: "Alles in YouNew, geordend op onderwerp. Je profiel verandert aanbevelingen, nooit toegang.",
                ru: "Все материалы YouNew по темам. Профиль меняет рекомендации, но не доступ."
            ))
            .font(AppTypography.body)
            .foregroundStyle(AppColors.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var searchAction: some View {
        HStack(spacing: 10) {
            NavigationLink(value: AppDestination.searchList) {
                HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.headline.bold())
                Text(localized(en: "Search all guides and services", nl: "Zoek in alle gidsen en diensten", ru: "Поиск по всем материалам и сервисам"))
                    .font(AppTypography.body.weight(.semibold))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 4)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button(action: onAskAI) {
                Image(systemName: "sparkles")
                    .font(.headline.bold())
                    .foregroundStyle(AppColors.violet)
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(localized(en: "Open AI assistant", nl: "Open AI-assistent", ru: "Открыть AI-помощника"))
            .accessibilityIdentifier("guide.aiButton")
        }
        .foregroundStyle(AppColors.textPrimary)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .frame(minHeight: 64)
        .appGlassCardStyle(padding: 0, cornerRadius: 20, accent: AppColors.cyanGlow)
        .accessibilityIdentifier("guide.search")
    }

    private var categoryGrid: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 14) {
            ForEach(Category.canonical.sorted { $0.displayOrder < $1.displayOrder }) { category in
                NavigationLink(value: destination(for: category.id)) {
                    VStack(alignment: .leading, spacing: 12) {
                        Image(systemName: symbol(for: category.id))
                            .font(.title2.bold())
                            .foregroundStyle(tint(for: category.id))
                            .frame(width: 42, height: 42)
                            .background(tint(for: category.id).opacity(0.13), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                        Text(title(for: category))
                            .font(.headline)
                            .foregroundStyle(AppColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(categoryDescription(category.id))
                            .font(AppTypography.footnote)
                            .foregroundStyle(AppColors.textSecondary)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, minHeight: 154, alignment: .topLeading)
                    .padding(15)
                    .appGlassCardStyle(padding: 0, cornerRadius: 22, accent: tint(for: category.id))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("guide.category.\(category.id)")
            }
        }
    }

    private var popularContent: some View {
        contentSection(
            title: localized(en: "Popular guides", nl: "Populaire gidsen", ru: "Популярные материалы"),
            items: Array(ContentRepository.shared.guideItems().prefix(4))
        )
    }

    private var recentlyUpdated: some View {
        let items = ContentRepository.shared.guideItems()
            .filter { $0.lastVerifiedAt != nil }
            .sorted { ($0.lastVerifiedAt ?? .distantPast) > ($1.lastVerifiedAt ?? .distantPast) }
        return contentSection(
            title: localized(en: "Recently updated", nl: "Recent bijgewerkt", ru: "Недавно обновлено"),
            items: Array(items.prefix(3))
        )
    }

    private func contentSection(title: String, items: [ContentItem]) -> some View {
        VStack(alignment: .leading, spacing: 11) {
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(AppColors.textPrimary)
            if items.isEmpty {
                Text(localized(en: "Verified materials will appear here.", nl: "Geverifieerde informatie verschijnt hier.", ru: "Здесь появятся проверенные материалы."))
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .appGlassCardStyle(padding: 0, cornerRadius: 17, accent: AppColors.softBlue)
            } else {
                ForEach(items) { item in
                    if let destination = ContentRepository.shared.legacyDestination(id: item.id) {
                        NavigationLink(value: destination) { guideContentRow(item) }
                            .buttonStyle(.plain)
                    } else {
                        guideContentRow(item)
                    }
                }
            }
        }
    }

    private func guideContentRow(_ item: ContentItem) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol(for: item.primaryCategoryID))
                .foregroundStyle(tint(for: item.primaryCategoryID))
                .frame(width: 38, height: 38)
                .background(tint(for: item.primaryCategoryID).opacity(0.12), in: RoundedRectangle(cornerRadius: 11))
            VStack(alignment: .leading, spacing: 3) {
                Text(localizedTitle(item))
                    .font(AppTypography.body.weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(item.shortDescription)
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 4)
            Image(systemName: "chevron.right").accessibilityHidden(true)
        }
        .padding(13)
        .appGlassCardStyle(padding: 0, cornerRadius: 17, accent: tint(for: item.primaryCategoryID))
    }

    private func localizedTitle(_ item: ContentItem) -> String {
        switch language {
        case .english: return item.title
        case .dutch: return item.localTitle["nl"] ?? item.title
        case .russian: return item.localTitle["ru"] ?? item.title
        }
    }

    private func categoryDescription(_ id: String) -> String {
        switch id {
        case "getting-started": return localized(en: "Arrival, registration and your first week", nl: "Aankomst, registratie en je eerste week", ru: "Приезд, регистрация и первая неделя")
        case "housing": return localized(en: "Finding a home, contracts and tenant rights", nl: "Woning zoeken, contracten en huurdersrechten", ru: "Поиск жилья, договоры и права арендатора")
        case "official-services": return localized(en: "Municipality, BSN, DigiD, IND and documents", nl: "Gemeente, BSN, DigiD, IND en documenten", ru: "Муниципалитет, BSN, DigiD, IND и документы")
        case "work-money": return localized(en: "Employment, salary, taxes and banking", nl: "Werk, salaris, belastingen en bankzaken", ru: "Работа, зарплата, налоги и банки")
        case "study": return localized(en: "Education, Dutch language and integration", nl: "Onderwijs, Nederlands en integratie", ru: "Учёба, нидерландский язык и интеграция")
        case "health-safety": return localized(en: "Insurance, care, emergencies and protection", nl: "Verzekering, zorg, noodgevallen en veiligheid", ru: "Страхование, медицина и безопасность")
        case "transport": return localized(en: "Public transport, cycling and driving", nl: "Openbaar vervoer, fietsen en autorijden", ru: "Общественный транспорт, велосипеды и вождение")
        default: return localized(en: "Cities, culture, history and leisure", nl: "Steden, cultuur, geschiedenis en vrije tijd", ru: "Города, культура, история и досуг")
        }
    }

    private var sourceNote: some View {
        NavigationLink(value: AppDestination.officialSources) {
            Label(
                localized(en: "Sources and last verified dates", nl: "Bronnen en laatst gecontroleerde datums", ru: "Источники и даты последней проверки"),
                systemImage: "checkmark.seal.fill"
            )
            .font(AppTypography.footnote.weight(.semibold))
            .foregroundStyle(AppColors.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityIdentifier("guide.lastElement")
    }

    private func destination(for categoryID: String) -> AppDestination {
        switch categoryID {
        case "getting-started": return .firstSteps
        case "housing": return .practicalGuide(.housingBasics)
        case "official-services": return .officialSources
        case "work-money": return .guideSection("work")
        case "study": return .languageHub
        case "health-safety": return .practicalGuide(.healthcareBasics)
        case "transport": return .practicalGuide(.transportBasics)
        default: return .cultureAttractions
        }
    }

    private func symbol(for id: String) -> String {
        switch id {
        case "getting-started": return "figure.walk"
        case "housing": return "house.fill"
        case "official-services": return "building.columns.fill"
        case "work-money": return "briefcase.fill"
        case "study": return "graduationcap.fill"
        case "health-safety": return "cross.case.fill"
        case "transport": return "tram.fill"
        default: return "safari.fill"
        }
    }

    private func tint(for id: String) -> Color {
        switch id {
        case "getting-started": return AppColors.cyanGlow
        case "housing": return AppColors.violet
        case "official-services": return AppColors.dutchOrange
        case "work-money": return AppColors.warning
        case "study": return AppColors.softBlue
        case "health-safety": return AppColors.success
        case "transport": return AppColors.emerald
        default: return AppColors.routeLine
        }
    }

    private func title(for category: Category) -> String {
        switch language {
        case .english: return category.title
        case .dutch: return category.localTitle["nl"] ?? category.title
        case .russian: return category.localTitle["ru"] ?? category.title
        }
    }

    private func displaySubcategory(_ value: String) -> String {
        value.replacingOccurrences(of: "-", with: " ").capitalized
    }

    private func localized(en: String, nl: String, ru: String) -> String {
        switch language {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }
}
