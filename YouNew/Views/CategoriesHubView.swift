import SwiftUI

struct CategoriesHubView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }
    private var activePersona: PersonaTag? { appState.selectedUserStatus?.personaTag }
    private var visibleCategories: [AppCategory] { AppCategoryRegistry.forPersona(activePersona) }
    private var visibleQuickLinks: [CategoryQuickLink] { CategoryQuickLink.links(for: activePersona, lang: lang) }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 920) {
                VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    heroSection

                    NLSectionHeader(title: mainCategoriesTitle, subtitle: mainCategoriesSubtitle)
                    mainCategoriesGrid

                    NLSectionHeader(title: quickLinksTitle)
                    quickLinksSection

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
            symbol: "rectangle.grid.2x2.fill",
            badgeText: badgeText,
            accent: AppColors.success,
            asset: nil
        )
    }

    private var mainCategoriesGrid: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 150), spacing: AppSpacing.small)],
            spacing: AppSpacing.small
        ) {
            ForEach(visibleCategories) { category in
                NavigationLink(value: category.destination) {
                    categoryCard(category)
                }
                .buttonStyle(NLTileButtonStyle())
            }
        }
    }

    private func categoryCard(_ category: AppCategory) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [category.color.opacity(0.36), category.color.opacity(0.16)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 52, height: 52)
                    Image(systemName: category.icon)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(category.color)
                        .shadow(color: category.color.opacity(0.44), radius: 7, x: 0, y: 0)
                }
                Spacer(minLength: 4)
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(category.color.opacity(0.56))
                    .padding(.top, 4)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(category.title(lang))
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .minimumScaleFactor(0.82)

                Text(category.subtitle(lang))
                    .font(.system(size: 10.5, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 130, alignment: .topLeading)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                    .fill(AppColors.glassSurfaceElevated)
                RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [category.color.opacity(0.16), category.color.opacity(0.04), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                    .fill(
                        RadialGradient(
                            colors: [category.color.opacity(0.14), .clear],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 88
                        )
                    )
                RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.16), Color.white.opacity(0.03), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.22), category.color.opacity(0.36), Color.white.opacity(0.06)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.85
                )
        )
        .shadow(color: category.color.opacity(0.16), radius: 14, x: 0, y: 7)
        .shadow(color: Color.black.opacity(0.14), radius: 10, x: 0, y: 5)
    }

    private var quickLinksSection: some View {
        VStack(spacing: AppSpacing.small) {
            ForEach(visibleQuickLinks) { link in
                quickLink(icon: link.icon, title: link.title, color: link.color, destination: link.destination)
            }
        }
    }

    private func quickLink(icon: String, title: String, color: Color, destination: AppDestination) -> some View {
        NavigationLink(value: destination) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                Text(title)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppColors.textTertiary)
            }
            .appGlassCardStyle(padding: 12, cornerRadius: 16, accent: color)
        }
        .buttonStyle(NLTileButtonStyle())
    }

    // MARK: - Strings

    private var navTitle: String {
        if let status = appState.selectedUserStatus {
            return status.localized(lang)
        }
        switch lang {
        case .russian: return "Категории"
        case .dutch:   return "Categorieën"
        case .english: return "Categories"
        }
    }

    private var heroSubtitle: String {
        if appState.selectedUserStatus != nil {
            switch lang {
            case .russian: return "Только разделы, действия и источники для выбранного жизненного пути."
            case .dutch:   return "Alleen onderdelen, acties en bronnen voor het gekozen levenspad."
            case .english: return "Only sections, actions, and sources for the selected life path."
            }
        }
        switch lang {
        case .russian: return "Вся информация о жизни в Нидерландах — разбита по понятным разделам."
        case .dutch:   return "Alle informatie over het leven in Nederland — overzichtelijk per categorie."
        case .english: return "All information about life in the Netherlands — organized in clear sections."
        }
    }

    private var badgeText: String {
        switch lang {
        case .russian: return "Проверенные пути"
        case .dutch:   return "Gecontroleerde routes"
        case .english: return "Verified routes"
        }
    }

    private var mainCategoriesTitle: String {
        if appState.selectedUserStatus != nil {
            switch lang {
            case .russian: return "Ваш путь"
            case .dutch:   return "Uw route"
            case .english: return "Your path"
            }
        }
        switch lang {
        case .russian: return "Основные разделы"
        case .dutch:   return "Hoofdcategorieën"
        case .english: return "Main categories"
        }
    }

    private var mainCategoriesSubtitle: String {
        if appState.selectedUserStatus != nil {
            switch lang {
            case .russian: return "Разделы отфильтрованы по вашему профилю"
            case .dutch:   return "Onderdelen zijn gefilterd op uw profiel"
            case .english: return "Sections are filtered by your profile"
            }
        }
        switch lang {
        case .russian: return "Нажмите для перехода в раздел"
        case .dutch:   return "Tik om naar de categorie te gaan"
        case .english: return "Tap to enter a category"
        }
    }

    private var quickLinksTitle: String {
        switch lang {
        case .russian: return "Быстрые ссылки"
        case .dutch:   return "Snelle links"
        case .english: return "Quick links"
        }
    }

    private var checklistTitle: String {
        switch lang {
        case .russian: return "Чеклист первых шагов"
        case .dutch:   return "Checklist eerste stappen"
        case .english: return "First steps checklist"
        }
    }

    private var citiesTitle: String {
        switch lang {
        case .russian: return "Города"
        case .dutch:   return "Steden"
        case .english: return "Cities"
        }
    }

    private var provincesTitle: String {
        switch lang {
        case .russian: return "Провинции"
        case .dutch:   return "Provincies"
        case .english: return "Provinces"
        }
    }

    private var searchTitle: String {
        switch lang {
        case .russian: return "Поиск знаний"
        case .dutch:   return "Kennis zoeken"
        case .english: return "Search knowledge"
        }
    }

    private var officialTitle: String {
        switch lang {
        case .russian: return "Официальные источники"
        case .dutch:   return "Officiële bronnen"
        case .english: return "Official sources"
        }
    }
}

private struct CategoryQuickLink: Identifiable {
    let id: String
    let icon: String
    let title: String
    let color: Color
    let destination: AppDestination

    static func links(for persona: PersonaTag?, lang: AppLanguage) -> [CategoryQuickLink] {
        switch persona {
        case .student:
            return [
                link("student-checklist", "checklist.checked", localized(lang, en: "Student checklist", nl: "Studentenchecklist", ru: "Студенческий чеклист"), AppColors.success, .checklistList),
                link("student-map", "map.fill", localized(lang, en: "Libraries and study spaces", nl: "Bibliotheken en studieplekken", ru: "Библиотеки и места для учебы"), AppColors.softBlue, .mapFocus(.education)),
                link("student-search", "magnifyingglass.circle", localized(lang, en: "Search student help", nl: "Studentenhulp zoeken", ru: "Поиск помощи студентам"), AppColors.dutchOrange, .searchList),
                link("student-sources", "checkmark.shield.fill", localized(lang, en: "DUO and official sources", nl: "DUO en officiële bronnen", ru: "DUO и официальные источники"), AppColors.success, .officialSources)
            ]
        case .worker, .highlySkilledMigrant:
            return [
                link("worker-checklist", "checklist.checked", localized(lang, en: "Work setup checklist", nl: "Checklist werkstart", ru: "Чеклист для работы"), AppColors.success, .checklistList),
                link("worker-map", "map.fill", localized(lang, en: "Government and UWV nearby", nl: "Overheid en UWV dichtbij", ru: "Госслужбы и UWV рядом"), AppColors.softBlue, .mapFocus(.government)),
                link("worker-search", "magnifyingglass.circle", localized(lang, en: "Search worker topics", nl: "Werkonderwerpen zoeken", ru: "Поиск рабочих тем"), AppColors.dutchOrange, .searchList),
                link("worker-sources", "checkmark.shield.fill", localized(lang, en: "Official work sources", nl: "Officiële werkbronnen", ru: "Официальные источники о работе"), AppColors.success, .officialSources)
            ]
        case .refugee:
            return [
                link("refugee-checklist", "checklist.checked", localized(lang, en: "Refugee checklist", nl: "Vluchtelingenchecklist", ru: "Чеклист беженца"), AppColors.success, .checklistList),
                link("refugee-map", "map.fill", localized(lang, en: "Municipality and support nearby", nl: "Gemeente en steun dichtbij", ru: "Муниципалитет и поддержка рядом"), AppColors.softBlue, .mapFocus(.government)),
                link("refugee-documents", "doc.text.fill", localized(lang, en: "Documents", nl: "Documenten", ru: "Документы"), AppColors.violet, .journeyDocuments),
                link("refugee-search", "magnifyingglass.circle", localized(lang, en: "Search refugee help", nl: "Vluchtelingenhulp zoeken", ru: "Поиск помощи беженцам"), AppColors.dutchOrange, .searchList)
            ]
        case .family:
            return [
                link("family-checklist", "checklist.checked", localized(lang, en: "Family checklist", nl: "Gezinschecklist", ru: "Семейный чеклист"), AppColors.success, .checklistList),
                link("family-map", "map.fill", localized(lang, en: "Schools and childcare nearby", nl: "Scholen en kinderopvang dichtbij", ru: "Школы и детсады рядом"), AppColors.softBlue, .mapFocus(.education)),
                link("family-search", "magnifyingglass.circle", localized(lang, en: "Search family services", nl: "Gezinsdiensten zoeken", ru: "Поиск семейных услуг"), AppColors.dutchOrange, .searchList),
                link("family-sources", "checkmark.shield.fill", localized(lang, en: "SVB and official sources", nl: "SVB en officiële bronnen", ru: "SVB и официальные источники"), AppColors.success, .officialSources)
            ]
        case .tourist:
            return [
                link("tourist-map", "map.fill", localized(lang, en: "City map", nl: "Stadskaart", ru: "Карта города"), AppColors.softBlue, .mapHub),
                link("tourist-emergency", "phone.fill", localized(lang, en: "Emergency help", nl: "Noodhulp", ru: "Экстренная помощь"), AppColors.error, .emergencyHub),
                link("tourist-cities", "building.2.fill", localized(lang, en: "Cities", nl: "Steden", ru: "Города"), AppColors.softBlue, .cityList),
                link("tourist-search", "magnifyingglass.circle", localized(lang, en: "Search travel help", nl: "Reishulp zoeken", ru: "Поиск помощи в поездке"), AppColors.dutchOrange, .searchList)
            ]
        case .entrepreneur:
            return [
                link("entrepreneur-checklist", "checklist.checked", localized(lang, en: "Business checklist", nl: "Ondernemerschecklist", ru: "Бизнес-чеклист"), AppColors.success, .checklistList),
                link("entrepreneur-sources", "checkmark.shield.fill", localized(lang, en: "KVK and official sources", nl: "KVK en officiële bronnen", ru: "KVK и официальные источники"), AppColors.success, .officialSources),
                link("entrepreneur-government", "building.columns.fill", localized(lang, en: "Municipality permits", nl: "Gemeentelijke vergunningen", ru: "Муниципальные разрешения"), AppColors.softBlue, .governmentHub),
                link("entrepreneur-search", "magnifyingglass.circle", localized(lang, en: "Search business help", nl: "Ondernemershulp zoeken", ru: "Поиск помощи бизнесу"), AppColors.dutchOrange, .searchList)
            ]
        case .lgbt:
            return [
                link("lgbt-support", "heart.text.square.fill", localized(lang, en: "LGBT support", nl: "LGBT steun", ru: "ЛГБТ поддержка"), AppColors.violet, .lgbtqSupport),
                link("lgbt-emotional", "figure.mind.and.body", localized(lang, en: "Emotional support", nl: "Emotionele steun", ru: "Эмоциональная поддержка"), AppColors.emerald, .emotionalSupport),
                link("lgbt-map", "map.fill", localized(lang, en: "Safe support nearby", nl: "Veilige steun dichtbij", ru: "Безопасная поддержка рядом"), AppColors.softBlue, .mapFocus(.government)),
                link("lgbt-search", "magnifyingglass.circle", localized(lang, en: "Search LGBT help", nl: "LGBT hulp zoeken", ru: "Поиск ЛГБТ помощи"), AppColors.dutchOrange, .searchList)
            ]
        case .eu, .nonEU, .universal, nil:
            return [
                link("checklist", "checklist.checked", localized(lang, en: "First steps checklist", nl: "Checklist eerste stappen", ru: "Чеклист первых шагов"), AppColors.success, .checklistList),
                link("cities", "building.2.fill", localized(lang, en: "Cities", nl: "Steden", ru: "Города"), AppColors.softBlue, .cityList),
                link("provinces", "map.fill", localized(lang, en: "Provinces", nl: "Provincies", ru: "Провинции"), AppColors.routeLine, .provinceList),
                link("search", "magnifyingglass.circle", localized(lang, en: "Search knowledge", nl: "Kennis zoeken", ru: "Поиск знаний"), AppColors.dutchOrange, .searchList),
                link("official", "checkmark.shield.fill", localized(lang, en: "Official sources", nl: "Officiële bronnen", ru: "Официальные источники"), AppColors.success, .officialSources)
            ]
        }
    }

    private static func link(_ id: String, _ icon: String, _ title: String, _ color: Color, _ destination: AppDestination) -> CategoryQuickLink {
        CategoryQuickLink(id: id, icon: icon, title: title, color: color, destination: destination)
    }

    private static func localized(_ lang: AppLanguage, en: String, nl: String, ru: String) -> String {
        switch lang {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }
}
