import SwiftUI

struct HelpHubView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }
    private var activePersona: PersonaTag? { appState.selectedUserStatus?.personaTag }

    private struct HelpCategory: Identifiable {
        let id: String
        let titleEN: String
        let titleNL: String
        let titleRU: String
        let icon: String
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

    private var categories: [HelpCategory] {
        switch activePersona {
        case .student:
            return [
                help("student-housing", "Student housing", "Studentenhuisvesting", "Студенческое жилье", "house.fill", AppColors.violet, .housingSection(.studentHousing)),
                help("student-health", "Student insurance", "Studentenverzekering", "Студенческая страховка", "cross.case.fill", AppColors.success, .practicalGuide(.healthcareBasics)),
                help("student-transport", "Public transport discounts", "OV-korting", "Скидки на транспорт", "tram.fill", AppColors.cyanGlow, .practicalGuide(.transportBasics)),
                help("student-language", "Dutch language courses", "Nederlandse taalcursussen", "Курсы нидерландского", "text.book.closed.fill", AppColors.violet, .dutchA1A2),
                help("student-community", "Libraries and student communities", "Bibliotheken en studentengroepen", "Библиотеки и студенческие сообщества", "books.vertical.fill", AppColors.emerald, .mapFocus(.education)),
                help("student-city", "City life and free time", "Stadsleven en vrije tijd", "Городская жизнь и свободное время", "building.2.fill", AppColors.softBlue, .cityList)
            ]
        case .worker, .highlySkilledMigrant:
            return [
                help("worker-documents", "BSN and DigiD", "BSN en DigiD", "BSN и DigiD", "doc.text.fill", AppColors.softBlue, .guideSection("documents")),
                help("worker-work", "Work contracts", "Arbeidscontracten", "Рабочие контракты", "briefcase.fill", AppColors.dutchOrange, .workSection(.permitsAndRights)),
                help("worker-taxes", "Taxes and salary", "Belasting en salaris", "Налоги и зарплата", "banknote.fill", AppColors.warning, .officialSources),
                help("worker-health", "Health insurance", "Zorgverzekering", "Медицинская страховка", "cross.case.fill", AppColors.success, .practicalGuide(.healthcareBasics)),
                help("worker-housing", "Housing", "Wonen", "Жилье", "house.fill", AppColors.violet, .practicalGuide(.housingBasics)),
                help("worker-transport", "Transport", "Vervoer", "Транспорт", "tram.fill", AppColors.cyanGlow, .practicalGuide(.transportBasics))
            ]
        case .refugee:
            return [
                help("refugee-ind", "IND and municipality", "IND en gemeente", "IND и муниципалитет", "building.columns.fill", AppColors.softBlue, .governmentHub),
                help("refugee-housing", "Housing", "Wonen", "Жилье", "house.fill", AppColors.violet, .practicalGuide(.housingBasics)),
                help("refugee-benefits", "Benefits", "Uitkeringen", "Пособия", "banknote.fill", AppColors.warning, .officialSources),
                help("refugee-integration", "Integration and language", "Integratie en taal", "Интеграция и язык", "text.book.closed.fill", AppColors.emerald, .guideSection("integration")),
                help("refugee-health", "Healthcare", "Zorg", "Медицина", "cross.case.fill", AppColors.success, .practicalGuide(.healthcareBasics)),
                help("refugee-support", "Support organizations", "Steunorganisaties", "Организации поддержки", "person.3.fill", AppColors.cyanGlow, .mapFocus(.government))
            ]
        case .family:
            return [
                help("family-schools", "Schools", "Scholen", "Школы", "graduationcap.fill", AppColors.emerald, .mapFocus(.education)),
                help("family-childcare", "Childcare / Kinderopvang", "Kinderopvang", "Детский сад / Kinderopvang", "figure.and.child.holdinghands", AppColors.softBlue, .officialSources),
                help("family-benefits", "SVB and child benefits", "SVB en kinderbijslag", "SVB и детские пособия", "banknote.fill", AppColors.warning, .officialSources),
                help("family-housing", "Family housing", "Gezinswoning", "Семейное жилье", "house.fill", AppColors.violet, .practicalGuide(.housingBasics)),
                help("family-health", "Healthcare", "Zorg", "Медицина", "cross.case.fill", AppColors.success, .practicalGuide(.healthcareBasics)),
                help("family-activities", "Activities", "Activiteiten", "Активности", "sparkles", AppColors.cyanGlow, .cityList)
            ]
        case .tourist:
            return [
                help("tourist-transport", "Transport", "Vervoer", "Транспорт", "tram.fill", AppColors.cyanGlow, .practicalGuide(.transportBasics)),
                help("tourist-emergency", "Emergency", "Noodhulp", "Экстренная помощь", "phone.fill", AppColors.error, .emergencyHub),
                help("tourist-health", "Travel health", "Reisgezondheid", "Здоровье в поездке", "cross.case.fill", AppColors.success, .practicalGuide(.healthcareBasics)),
                help("tourist-city", "City life and free time", "Stadsleven en vrije tijd", "Город и свободное время", "building.2.fill", AppColors.softBlue, .cityList)
            ]
        case .entrepreneur:
            return [
                help("entrepreneur-kvk", "KVK and business registration", "KVK en bedrijfsregistratie", "KVK и регистрация бизнеса", "building.columns.fill", AppColors.softBlue, .officialSources),
                help("entrepreneur-tax", "VAT / BTW and taxes", "BTW en belasting", "BTW и налоги", "banknote.fill", AppColors.warning, .officialSources),
                help("entrepreneur-banking", "Business banking", "Zakelijk bankieren", "Бизнес-банк", "creditcard.fill", AppColors.success, .guideSection("documents")),
                help("entrepreneur-permits", "Permits", "Vergunningen", "Разрешения", "doc.badge.gearshape.fill", AppColors.violet, .governmentHub)
            ]
        case .lgbt:
            return [
                help("lgbt-support", "LGBTQ+ support", "LGBTQ+ steun", "ЛГБТК+ поддержка", "heart.text.square.fill", AppColors.violet, .lgbtqSupport),
                help("lgbt-health", "Inclusive healthcare", "Inclusieve zorg", "Инклюзивная медицина", "cross.case.fill", AppColors.success, .practicalGuide(.healthcareBasics)),
                help("lgbt-housing", "Housing safety", "Woonveiligheid", "Безопасность жилья", "house.fill", AppColors.warning, .practicalGuide(.housingBasics)),
                help("lgbt-emotional", "Emotional support", "Emotionele steun", "Эмоциональная поддержка", "figure.mind.and.body", AppColors.emerald, .emotionalSupport)
            ]
        case .eu, .nonEU, .universal, nil:
            return [
                help("housing", "Housing", "Wonen", "Жильё", "house.fill", AppColors.violet, .practicalGuide(.housingBasics)),
                help("health", "Health", "Zorg", "Здоровье", "cross.case.fill", AppColors.error, .practicalGuide(.healthcareBasics)),
                help("transport", "Transport", "Vervoer", "Транспорт", "tram.fill", AppColors.cyanGlow, .practicalGuide(.transportBasics)),
                help("documents", "Documents", "Documenten", "Документы", "doc.text.fill", AppColors.softBlue, .journeyDocuments),
                help("safety", "Safety", "Veiligheid", "Безопасность", "shield.fill", Color(red: 198/255, green: 72/255, blue: 36/255), .emergencyHub)
            ]
        }
    }

    private func help(_ id: String, _ en: String, _ nl: String, _ ru: String, _ icon: String, _ color: Color, _ destination: AppDestination) -> HelpCategory {
        HelpCategory(id: id, titleEN: en, titleNL: nl, titleRU: ru, icon: icon, color: color, destination: destination)
    }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 920) {
                VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    heroSection

                    aiNavigatorBanner

                    NLSectionHeader(title: categoriesTitle, subtitle: categoriesSubtitle)
                    categoryGrid

                    checklistBanner

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
            assetName: "premium_home_housing",
            title: navTitle,
            subtitle: heroSubtitle,
            symbol: "hands.and.sparkles.fill",
            badgeText: badgeText,
            accent: AppColors.emerald,
            asset: ContentMediaRegistry.housingTerracedHousesImage
        )
    }

    private var aiNavigatorBanner: some View {
        NavigationLink(value: AppDestination.assistantHub) {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(AppColors.cyanGlow)
                    .frame(width: 42, height: 42)
                    .background(AppColors.cyanGlow.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text(aiBannerTitle)
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColors.textPrimary)
                    Text(aiBannerSubtitle)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppColors.textTertiary)
            }
            .appGlassCardStyle(padding: 14, cornerRadius: 18, accent: AppColors.cyanGlow)
        }
        .buttonStyle(NLTileButtonStyle())
    }

    private var categoryGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(minimum: 140), spacing: AppSpacing.small),
                GridItem(.flexible(minimum: 140), spacing: AppSpacing.small)
            ],
            spacing: AppSpacing.small
        ) {
            ForEach(categories) { category in
                NavigationLink(value: category.destination) {
                    categoryTile(category)
                }
                .buttonStyle(NLTileButtonStyle())
            }
        }
    }

    private func categoryTile(_ category: HelpCategory) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(category.color.opacity(0.16))
                    .frame(width: 44, height: 44)
                Image(systemName: category.icon)
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(category.color)
            }
            Text(category.title(lang))
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .minimumScaleFactor(0.82)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 96, alignment: .topLeading)
        .background {
            ZStack {
                LinearGradient(
                    colors: [
                        category.color.opacity(0.24),
                        AppColors.glassSurfaceElevated.opacity(0.78),
                        AppColors.navyDeep.opacity(0.62)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                GeneratedCategoryArtwork(symbol: category.icon, accent: category.color)
                    .opacity(0.11)
                    .scaleEffect(1.18)
                    .offset(x: 56, y: 10)
                RadialGradient(
                    colors: [category.color.opacity(0.20), Color.clear],
                    center: .topLeading,
                    startRadius: 8,
                    endRadius: 120
                )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                .stroke(category.color.opacity(0.28), lineWidth: 0.8)
        )
        .shadow(color: category.color.opacity(0.12), radius: 14, x: 0, y: 7)
    }

    private var checklistBanner: some View {
        NavigationLink(value: AppDestination.checklistList) {
            HStack(spacing: 12) {
                Image(systemName: "checklist.checked")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(AppColors.success)
                    .frame(width: 42, height: 42)
                    .background(AppColors.success.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text(checklistTitle)
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColors.textPrimary)
                    Text(checklistSubtitle)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppColors.textTertiary)
            }
            .appGlassCardStyle(padding: 14, cornerRadius: 18, accent: AppColors.success)
        }
        .buttonStyle(NLTileButtonStyle())
    }

    // MARK: - Strings

    private var navTitle: String {
        switch lang {
        case .russian: return "Помощь и жизнь"
        case .dutch:   return "Hulp & Leven"
        case .english: return "Help & Life"
        }
    }

    private var heroSubtitle: String {
        switch lang {
        case .russian: return "Практическая помощь по жизни в Нидерландах: жильё, работа, здоровье, транспорт, деньги и права."
        case .dutch:   return "Praktische hulp bij het leven in Nederland: wonen, werk, zorg, vervoer, geld en rechten."
        case .english: return "Practical help for life in the Netherlands: housing, work, health, transport, money, and rights."
        }
    }

    private var badgeText: String {
        switch lang {
        case .russian: return "Маршруты с учетом источников"
        case .dutch:   return "Gecontroleerde routes"
        case .english: return "Source-aware routes"
        }
    }

    private var categoriesTitle: String {
        switch lang {
        case .russian: return "Категории"
        case .dutch:   return "Categorieën"
        case .english: return "Categories"
        }
    }

    private var categoriesSubtitle: String {
        switch lang {
        case .russian: return "Выберите тему, чтобы найти нужную помощь"
        case .dutch:   return "Kies een onderwerp om de juiste hulp te vinden"
        case .english: return "Choose a topic to find the right help"
        }
    }

    private var aiBannerTitle: String {
        switch lang {
        case .russian: return "Не знаете с чего начать?"
        case .dutch:   return "Weet u niet waar te beginnen?"
        case .english: return "Not sure where to start?"
        }
    }

    private var aiBannerSubtitle: String {
        switch lang {
        case .russian: return "Спросите AI-навигатор — он подскажет маршрут"
        case .dutch:   return "Vraag de AI-navigator — hij wijst u de weg"
        case .english: return "Ask AI Navigator — it will find the right route"
        }
    }

    private var checklistTitle: String {
        switch lang {
        case .russian: return "Чеклист первых шагов"
        case .dutch:   return "Checklist eerste stappen"
        case .english: return "First steps checklist"
        }
    }

    private var checklistSubtitle: String {
        switch lang {
        case .russian: return "Полный список дел после приезда в Нидерланды"
        case .dutch:   return "Volledige takenlijst na aankomst in Nederland"
        case .english: return "Full task list after arriving in the Netherlands"
        }
    }
}
