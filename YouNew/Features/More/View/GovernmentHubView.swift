import SwiftUI

struct GovernmentHubView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }
    private var activePersona: PersonaTag? { appState.selectedUserStatus?.personaTag }

    private struct GovService: Identifiable {
        let id: String
        let nameEN: String
        let nameNL: String
        let nameRU: String
        let descEN: String
        let descNL: String
        let descRU: String
        let icon: String
        let color: Color
        let website: String
        let institutionName: String
        let personaTags: Set<PersonaTag>

        func name(_ lang: AppLanguage) -> String {
            switch lang {
            case .english: return nameEN
            case .dutch: return nameNL
            case .russian: return nameRU
            }
        }
        func desc(_ lang: AppLanguage) -> String {
            switch lang {
            case .english: return descEN
            case .dutch: return descNL
            case .russian: return descRU
            }
        }
    }

    private let services: [GovService] = [
        GovService(id: "gemeente", nameEN: "Gemeente", nameNL: "Gemeente", nameRU: "Gemeente", descEN: "Local municipality — registration, permits, certificates", descNL: "Lokale gemeente — inschrijving, vergunningen, documenten", descRU: "Местный муниципалитет — регистрация, разрешения, документы", icon: "building.2.fill", color: AppColors.softBlue, website: "gemeenten.nl", institutionName: "Gemeente", personaTags: [.worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]),
        GovService(id: "ind", nameEN: "IND", nameNL: "IND", nameRU: "IND", descEN: "Immigration and Naturalisation Service — residence permits", descNL: "Immigratie- en Naturalisatiedienst — verblijfsvergunningen", descRU: "Служба иммиграции и натурализации — виды на жительство", icon: "person.badge.shield.checkmark.fill", color: AppColors.cyanGlow, website: "ind.nl", institutionName: "IND", personaTags: [.refugee, .nonEU, .highlySkilledMigrant]),
        GovService(id: "duo", nameEN: "DUO", nameNL: "DUO", nameRU: "DUO", descEN: "Education executive agency — student finance, NT2 exams", descNL: "Dienst Uitvoering Onderwijs — studiefinanciering, NT2", descRU: "Агентство по образованию — студенческие субсидии, NT2", icon: "graduationcap.fill", color: AppColors.emerald, website: "duo.nl", institutionName: "DUO", personaTags: [.student, .refugee]),
        GovService(id: "uwv", nameEN: "UWV", nameNL: "UWV", nameRU: "UWV", descEN: "Employee Insurance Agency — unemployment, work permits", descNL: "Uitvoeringsinstituut Werknemersverzekeringen — WW, tewerkstellingsvergunning", descRU: "Страхование занятости — пособия по безработице, разрешения на работу", icon: "briefcase.fill", color: AppColors.dutchOrange, website: "uwv.nl", institutionName: "UWV", personaTags: [.worker, .refugee]),
        GovService(id: "belasting", nameEN: "Belastingdienst", nameNL: "Belastingdienst", nameRU: "Belastingdienst", descEN: "Tax and Customs — filing taxes, toeslagen allowances", descNL: "Belastingen en toeslagen — belastingaangifte, zorgtoeslag", descRU: "Налоговая служба — декларации, льготы toeslagen", icon: "banknote.fill", color: AppColors.warning, website: "belastingdienst.nl", institutionName: "Belastingdienst", personaTags: [.worker, .family, .eu, .highlySkilledMigrant, .entrepreneur]),
        GovService(id: "svb", nameEN: "SVB", nameNL: "SVB", nameRU: "SVB", descEN: "Social Insurance Bank — AOW pension, child benefit", descNL: "Sociale Verzekeringsbank — AOW, kinderbijslag", descRU: "Социальный страховой банк — пенсия AOW, детские пособия", icon: "person.2.fill", color: AppColors.violet, website: "svb.nl", institutionName: "SVB", personaTags: [.family]),
        GovService(id: "politie", nameEN: "Politie", nameNL: "Politie", nameRU: "Politie", descEN: "National Police — report crime, non-emergency 0900-8844", descNL: "Nationale Politie — aangifte doen, niet-spoed 0900-8844", descRU: "Национальная полиция — сообщить о преступлении, не срочно 0900-8844", icon: "shield.fill", color: AppColors.emergencyRed, website: "politie.nl", institutionName: "Politie", personaTags: [.refugee, .family, .tourist, .lgbt]),
        GovService(id: "juridisch", nameEN: "Juridisch Loket", nameNL: "Juridisch Loket", nameRU: "Juridisch Loket", descEN: "Free first legal advice — housing, work, family law", descNL: "Gratis eerste juridisch advies — wonen, werk, familierecht", descRU: "Бесплатная юридическая помощь — жильё, работа, семья", icon: "scale.3d", color: AppColors.textSecondary, website: "juridischloket.nl", institutionName: "Juridisch Loket", personaTags: [.worker, .refugee, .family, .entrepreneur, .lgbt])
    ]

    private var visibleServices: [GovService] {
        guard let activePersona else { return services }
        return services.filter { $0.personaTags.contains(activePersona) || $0.personaTags.contains(.universal) }
    }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 920) {
                VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    heroSection
                    aiNavigatorBanner
                    NLSectionHeader(title: servicesTitle, subtitle: servicesSubtitle)
                    servicesGrid
                    officialDisclaimerSection
                    Color.clear.frame(height: AppSpacing.tabBarScrollReserve)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, AppSpacing.medium)
            }
        }
        .appSceneBackground(.more)
        .navigationTitle(navTitle)
        .nlNavigationInline()
        .accessibilityIdentifier("government.screen")
    }

    // MARK: - Sections

    private var heroSection: some View {
        CategoryHeroVisual(
            assetName: "home_documents_city_hall",
            title: navTitle,
            subtitle: heroSubtitle,
            symbol: "building.columns.fill",
            badgeText: badgeText,
            accent: AppColors.softBlue,
            asset: ContentMediaRegistry.municipalityCityHallImage
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

    private var servicesGrid: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 240), spacing: AppSpacing.small)],
            spacing: AppSpacing.small
        ) {
            ForEach(visibleServices) { service in
                NavigationLink(value: AppDestination.institution(service.institutionName)) {
                    serviceCard(service)
                }
                .buttonStyle(NLTileButtonStyle())
            }
        }
    }

    private func serviceCard(_ service: GovService) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(service.color.opacity(0.14))
                    .frame(width: 50, height: 50)
                Image(systemName: service.icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(service.color)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(service.name(lang))
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                Text(service.desc(lang))
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Text(service.website)
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(service.color.opacity(0.8))
                    .lineLimit(1)
            }
        Spacer(minLength: 4)
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(AppColors.textTertiary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 96, alignment: .leading)
        .background {
            ZStack {
                LinearGradient(
                    colors: [
                        service.color.opacity(0.18),
                        AppColors.glassSurfaceElevated.opacity(0.82),
                        AppColors.navyDeep.opacity(0.68)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                GeneratedCategoryArtwork(symbol: service.icon, accent: service.color)
                    .opacity(0.10)
                    .scaleEffect(1.12)
                    .offset(x: 70, y: 8)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.16), service.color.opacity(0.36)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.8
                )
        )
        .shadow(color: service.color.opacity(0.12), radius: 14, x: 0, y: 8)
    }

    private var officialDisclaimerSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColors.success)
            Text(disclaimerText)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .appGlassCardStyle(padding: 14, cornerRadius: 16, accent: AppColors.success)
    }

    // MARK: - Strings

    private var navTitle: String {
        switch lang {
        case .russian: return "Государственные службы"
        case .dutch:   return "Overheidsdiensten"
        case .english: return "Government services"
        }
    }

    private var heroSubtitle: String {
        switch lang {
        case .russian: return "Официальные нидерландские учреждения: регистрация, налоги, образование, работа и правовая помощь."
        case .dutch:   return "Officiële Nederlandse instellingen: inschrijving, belastingen, onderwijs, werk en rechtshulp."
        case .english: return "Official Dutch institutions for registration, taxes, education, work, and legal help."
        }
    }

    private var badgeText: String {
        switch lang {
        case .russian: return "Официальные источники"
        case .dutch:   return "Officiële bronnen"
        case .english: return "Official sources"
        }
    }

    private var servicesTitle: String {
        switch lang {
        case .russian: return "Учреждения"
        case .dutch:   return "Instellingen"
        case .english: return "Institutions"
        }
    }

    private var servicesSubtitle: String {
        switch lang {
        case .russian: return "Нажмите для подробностей и официальных ссылок"
        case .dutch:   return "Tik voor details en officiële links"
        case .english: return "Tap for details and official links"
        }
    }

    private var aiBannerTitle: String {
        switch lang {
        case .russian: return "Не знаете, куда обратиться?"
        case .dutch:   return "Weet u niet waar u heen moet?"
        case .english: return "Not sure which service to use?"
        }
    }

    private var aiBannerSubtitle: String {
        switch lang {
        case .russian: return "AI-навигатор подскажет нужный маршрут и следующий шаг"
        case .dutch:   return "De AI-navigator wijst u de juiste weg en de volgende stap"
        case .english: return "AI Navigator will guide you to the right route and next step"
        }
    }

    private var disclaimerText: String {
        switch lang {
        case .russian: return "Все организации — официальные нидерландские учреждения. Информация носит ознакомительный характер. Всегда проверяйте актуальность на официальных сайтах."
        case .dutch:   return "Alle organisaties zijn officiële Nederlandse instellingen. Informatie is alleen ter oriëntatie. Controleer altijd via de officiële websites."
        case .english: return "All organisations are official Dutch institutions. Information is for orientation only. Always verify at official websites."
        }
    }
}
