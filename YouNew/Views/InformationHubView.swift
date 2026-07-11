import SwiftUI

struct InformationHubView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var appState: AppStateViewModel
    private var lang: AppLanguage { languageManager.appLanguage }
    private var activePersona: PersonaTag? { appState.selectedUserStatus?.personaTag }

    private var recentlyUpdated: [InformationHubItem] {
        visibleItems([
            item(title: text("First steps in the Netherlands", "Eerste stappen in Nederland", "Первые шаги в Нидерландах"), subtitle: text("Registration, DigiD, care, transport, housing, and sources.", "Inschrijving, DigiD, zorg, vervoer, wonen en bronnen.", "Регистрация, DigiD, медицина, транспорт, жильё и источники."), icon: AppIcons.checklist, tint: AppColors.success, destination: .firstSteps),
            item(title: text("KNM", "KNM", "KNM"), subtitle: text("Knowledge of Dutch Society modules and practice questions.", "Kennis van de Nederlandse Maatschappij met oefenvragen.", "Знание нидерландского общества: модули и тренировка."), icon: "graduationcap.fill", tint: AppColors.cyanGlow, destination: .knm),
            item(title: text("Dutch A1-A2", "Nederlands A1-A2", "Нидерландский A1-A2"), subtitle: text("Words, phrases, and grammar for daily life.", "Woorden, zinnen en grammatica voor dagelijks leven.", "Слова, фразы и грамматика для повседневной жизни."), icon: "text.book.closed.fill", tint: AppColors.emerald, destination: .dutchA1A2),
            item(title: text("City profiles", "Stadsprofielen", "Профили городов"), subtitle: text("\(MockNetherlandsUnderstandingData.cityInfoProfiles.count) supported newcomer cities with source links.", "\(MockNetherlandsUnderstandingData.cityInfoProfiles.count) steden voor nieuwkomers met bronlinks.", "\(MockNetherlandsUnderstandingData.cityInfoProfiles.count) городов для новичков с источниками."), icon: "building.2.fill", tint: AppColors.softBlue, destination: .cityList),
            item(title: text("Culture & Attractions", "Cultuur & attracties", "Культура и достопримечательности"), subtitle: text("Sourced culture notes and attraction guides.", "Cultuurnotities en attractiegidsen met bronnen.", "Культура и достопримечательности с источниками."), icon: "sparkles.rectangle.stack.fill", tint: AppColors.dutchOrange, destination: .cultureAttractions)
        ])
    }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 920) {
                LazyVStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    header
                    verifiedVisualsSection
                    sectionIfNeeded(title: text("Start here", "Begin hier", "Начните здесь"), items: startItems)
                    sectionIfNeeded(title: text("What to do first", "Wat eerst doen", "Что сделать сначала"), items: flowItems)
                    sectionIfNeeded(title: text("Practical life", "Praktisch leven", "Практическая жизнь"), items: practicalItems)
                    sectionIfNeeded(title: text("Cities & provinces", "Steden & provincies", "Города и провинции"), items: placeItems)
                    sectionIfNeeded(title: text("Culture & attractions", "Cultuur & attracties", "Культура и достопримечательности"), items: cultureItems)
                    sectionIfNeeded(title: text("Official sources", "Officiële bronnen", "Официальные источники"), items: sourceItems)
                    sectionIfNeeded(title: text("Recently updated", "Recent bijgewerkt", "Недавно обновлено"), items: recentlyUpdated)
                    Color.clear.frame(height: AppSpacing.tabBarScrollReserve)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, AppSpacing.medium)
            }
        }
        .appSceneBackground(.more)
        .navigationTitle(text("Information Hub", "Informatiecentrum", "Информационный центр"))
        .nlNavigationInline()
    }

    private var header: some View {
        CategoryHeroVisual(
            assetName: "premium_home_documents",
            title: text("Information Hub", "Informatiecentrum", "Информационный центр"),
            subtitle: text(
                "A connected guide to practical life, cities, culture, and official sources.",
                "Een verbonden gids voor praktisch leven, steden, cultuur en officiële bronnen.",
                "Единый центр для практической жизни, городов, культуры и официальных источников."
            ),
            symbol: "rectangle.grid.2x2.fill",
            badgeText: text("Source-aware paths", "Bronbewuste routes", "Маршруты с учетом источников"),
            accent: AppColors.success,
            asset: ContentMediaRegistry.municipalityCityHallImage ?? ContentMediaRegistry.officialSourcesHero ?? ContentMediaRegistry.mapImage,
            language: lang
        )
    }

    private var verifiedVisualsSection: some View {
        return VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(
                title: text("Media sources", "Mediabronnen", "Источники медиа"),
                subtitle: text(
                    "Attributed media records for practical topics.",
                    "Mediagegevens met bronvermelding voor praktische onderwerpen.",
                    "Медиа с атрибуцией для практических тем."
                )
            )

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: AppSpacing.small)], spacing: AppSpacing.small) {
                ForEach(verifiedVisualAssets) { image in
                    AppContentImageView(
                        asset: image,
                        language: lang,
                        mode: .fill,
                        accent: AppColors.success,
                        aspectRatio: 4.0 / 3.0,
                        cornerRadius: 16,
                        showsCaption: true,
                        showsSourceButton: true,
                        accessibilityLabel: image.displayTitle(lang)
                    )
                    .appGlassCardStyle(padding: 10, cornerRadius: 18, accent: AppColors.success)
                }
            }
        }
    }

    private var verifiedVisualAssets: [AppImageAsset] {
        let assets: [AppImageAsset?]
        switch activePersona {
        case .student:
            assets = [
                ContentMediaRegistry.housingTerracedHousesImage,
                ContentMediaRegistry.ovChipkaartImage,
                ContentMediaRegistry.healthcarePharmacyImage
            ]
        case .refugee, .family, .lgbt, .nonEU:
            assets = [
                ContentMediaRegistry.municipalityCityHallImage,
                ContentMediaRegistry.housingTerracedHousesImage,
                ContentMediaRegistry.healthcarePharmacyImage
            ]
        case .tourist:
            assets = [
                ContentMediaRegistry.ovChipkaartImage,
                ContentMediaRegistry.healthcarePharmacyImage,
                ContentMediaRegistry.cultureHero
            ]
        case .worker, .entrepreneur, .eu, .highlySkilledMigrant, .universal, .none:
            assets = [
                ContentMediaRegistry.municipalityCityHallImage,
                ContentMediaRegistry.healthcarePharmacyImage,
                ContentMediaRegistry.housingTerracedHousesImage,
                ContentMediaRegistry.ovChipkaartImage
            ]
        }
        return assets.compactMap { $0 }
    }

    private var startItems: [InformationHubItem] {
        visibleItems([
            item(title: text("First steps in the Netherlands", "Eerste stappen in Nederland", "Первые шаги в Нидерландах"), subtitle: text("A safe newcomer flow with official source links.", "Een veilige startflow met officiële bronlinks.", "Безопасный стартовый маршрут с официальными ссылками."), icon: AppIcons.checklist, tint: AppColors.success, destination: .firstSteps),
            item(title: text("KNM", "KNM", "KNM"), subtitle: text("Knowledge of Dutch Society: everyday, civic, and practical life.", "Kennis van de Nederlandse Maatschappij: dagelijks, maatschappelijk en praktisch leven.", "Знание нидерландского общества: быт, общество и практика."), icon: "graduationcap.fill", tint: AppColors.cyanGlow, destination: .knm),
            item(title: text("Dutch A1-A2", "Nederlands A1-A2", "Нидерландский A1-A2"), subtitle: text("Learn practical Dutch for daily life.", "Praktisch Nederlands voor het dagelijks leven.", "Практический нидерландский для повседневной жизни."), icon: "text.book.closed.fill", tint: AppColors.emerald, destination: .dutchA1A2),
            item(title: text("Search knowledge", "Zoek kennis", "Поиск знаний"), subtitle: text("Find cities, guides, sources, and practical answers.", "Vind steden, gidsen, bronnen en praktische antwoorden.", "Ищите города, гайды, источники и практические ответы."), icon: AppIcons.search, tint: AppColors.dutchOrange, destination: .searchList)
        ])
    }

    private var practicalItems: [InformationHubItem] {
        visibleItems([
            guide(.municipalityRegistration),
            guide(.digidSafety),
            guide(.healthInsuranceBasics),
            guide(.findingHuisarts),
            guide(.transportBasics),
            guide(.housingBasics),
            item(title: text("KNM", "KNM", "KNM"), subtitle: text("Practice themes for Dutch society knowledge.", "Oefenthema's voor kennis van de Nederlandse maatschappij.", "Темы для подготовки к знанию нидерландского общества."), icon: "graduationcap.fill", tint: AppColors.cyanGlow, destination: .knm),
            item(title: text("Dutch A1-A2", "Nederlands A1-A2", "Нидерландский A1-A2"), subtitle: text("Words, phrases, and grammar for daily life.", "Woorden, zinnen en grammatica voor dagelijks leven.", "Слова, фразы и грамматика для повседневной жизни."), icon: "text.book.closed.fill", tint: AppColors.emerald, destination: .dutchA1A2),
            guide(.officialSourcesChecklist)
        ])
    }

    private var flowItems: [InformationHubItem] {
        visibleItems([
            item(title: text("New in the Netherlands", "Nieuw in Nederland", "Новый в Нидерландах"), subtitle: text("Register, arrange DigiD, insurance, huisarts, transport, and sources.", "Inschrijven, DigiD, verzekering, huisarts, vervoer en bronnen regelen.", "Регистрация, DigiD, страховка, huisarts, транспорт и источники."), icon: "list.number", tint: AppColors.success, destination: .firstSteps),
            item(title: text("Moving to a new city", "Verhuizen naar een nieuwe stad", "Переезд в новый город"), subtitle: text("Check municipality, address update, waste rules, transport, and city sources.", "Controleer gemeente, adreswijziging, afvalregels, vervoer en stadsbronnen.", "Проверьте gemeente, адрес, мусор, транспорт и источники города."), icon: "building.2.crop.circle", tint: AppColors.routeLine, destination: .practicalGuide(.municipalityRegistration)),
            item(title: text("Need healthcare", "Zorg nodig", "Нужна медицина"), subtitle: text("Huisarts first, huisartsenpost for urgent care, 112 for immediate danger.", "Eerst huisarts, huisartsenpost bij spoed, 112 bij direct gevaar.", "Сначала huisarts, huisartsenpost при срочности, 112 при опасности."), icon: "cross.case.fill", tint: AppColors.error, destination: .practicalGuide(.healthcareBasics)),
            item(title: text("Need transport", "Vervoer nodig", "Нужен транспорт"), subtitle: text("Plan route, check NS/9292, pay with OVpay or OV-chipkaart, check in and out.", "Plan route, controleer NS/9292, betaal met OVpay of OV-chipkaart, check in en uit.", "Постройте маршрут, проверьте NS/9292, оплатите OVpay/OV-chipkaart, check-in/out."), icon: "tram.fill", tint: AppColors.dutchOrange, destination: .practicalGuide(.transportBasics))
        ])
    }

    private var placeItems: [InformationHubItem] {
        visibleItems([
            item(title: text("Cities", "Steden", "Города"), subtitle: text("Supported city profiles and official links.", "Stadsprofielen en officiële links.", "Профили городов и официальные ссылки."), icon: "building.2.fill", tint: AppColors.softBlue, destination: .cityList),
            item(title: text("Provinces", "Provincies", "Провинции"), subtitle: text("Province overview and real city links.", "Provincieoverzicht en echte stadslinks.", "Обзор провинций и реальные ссылки на города."), icon: "map.fill", tint: AppColors.routeLine, destination: .provinceList)
        ])
    }

    private var cultureItems: [InformationHubItem] {
        visibleItems([
            item(title: text("Culture & Attractions", "Cultuur & attracties", "Культура и достопримечательности"), subtitle: text("Articles, museums, canals, markets, and heritage.", "Artikelen, musea, grachten, markten en erfgoed.", "Статьи, музеи, каналы, рынки и наследие."), icon: "sparkles.rectangle.stack.fill", tint: AppColors.dutchOrange, destination: .cultureAttractions),
            item(title: text("History of the Netherlands", "Geschiedenis van Nederland", "История Нидерландов"), subtitle: text("Historical timeline and civic context.", "Historische tijdlijn en maatschappelijke context.", "Историческая шкала и гражданский контекст."), icon: "clock.arrow.circlepath", tint: AppColors.cyanGlow, destination: .netherlandsHistory)
        ])
    }

    private var sourceItems: [InformationHubItem] {
        visibleItems([
            item(title: text("Official sources", "Officiële bronnen", "Официальные источники"), subtitle: text("Government, municipality, healthcare, transport, and identity sources.", "Overheid, gemeente, zorg, vervoer en identiteit.", "Государство, gemeente, медицина, транспорт и DigiD."), icon: AppIcons.officialSource, tint: AppColors.success, destination: .officialSources)
        ])
    }

    @ViewBuilder
    private func sectionIfNeeded(title: String, items: [InformationHubItem]) -> some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                NLSectionHeader(title: title)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 240), spacing: AppSpacing.small)], spacing: AppSpacing.small) {
                    ForEach(items) { item in
                        NavigationLink(value: item.destination) {
                            hubCard(item)
                        }
                        .buttonStyle(NLTileButtonStyle())
                    }
                }
            }
        }
    }

    private func hubCard(_ item: InformationHubItem) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Image(systemName: item.icon)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(item.tint)
                .frame(width: 40, height: 40)
                .background(item.tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            Text(item.title)
                .font(AppTypography.bodyStrong)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2)
            Text(item.subtitle)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 144, alignment: .topLeading)
        .appCardStyle()
    }

    private func guide(_ topic: PracticalGuideTopic) -> InformationHubItem {
        item(title: guideTitle(topic), subtitle: guideSummary(topic), icon: guideIcon(topic), tint: guideTint(topic), destination: .practicalGuide(topic))
    }

    private func item(title: String, subtitle: String, icon: String, tint: Color, destination: AppDestination) -> InformationHubItem {
        InformationHubItem(title: title, subtitle: subtitle, icon: icon, tint: tint, destination: destination)
    }

    private func visibleItems(_ items: [InformationHubItem]) -> [InformationHubItem] {
        items.filter { RelatedContentEngine.isVisible($0.destination, for: activePersona) }
    }

    private func text(_ en: String, _ nl: String, _ ru: String) -> String {
        switch lang {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }

    private func guideTitle(_ topic: PracticalGuideTopic) -> String {
        switch topic {
        case .firstStepsNetherlands: return text("First steps in the Netherlands", "Eerste stappen in Nederland", "Первые шаги в Нидерландах")
        case .municipalityRegistration: return text("Municipality registration", "Inschrijving bij gemeente", "Регистрация в муниципалитете")
        case .healthcareBasics: return text("Healthcare basics", "Basiszorg", "Базовая медицина")
        case .findingHuisarts: return text("Find a huisarts", "Huisarts vinden", "Поиск huisarts")
        case .healthInsuranceBasics: return text("Health insurance", "Zorgverzekering", "Медицинская страховка")
        case .digidSafety: return text("DigiD safety", "DigiD-veiligheid", "DigiD и безопасность")
        case .transportBasics: return text("Transport in the Netherlands", "Vervoer in Nederland", "Транспорт в Нидерландах")
        case .housingBasics: return text("Housing basics", "Wonen basis", "Жильё")
        case .officialSourcesChecklist: return text("Official sources", "Officiële bronnen", "Официальные источники")
        case .bankingBasics: return text("Banking basics", "Bankieren", "Банкинг")
        }
    }

    private func guideSummary(_ topic: PracticalGuideTopic) -> String {
        switch topic {
        case .firstStepsNetherlands: return text("What to handle first after arrival.", "Wat je eerst regelt na aankomst.", "Что сделать первым после приезда.")
        case .municipalityRegistration: return text("Address registration and BSN-related steps.", "Adresinschrijving en BSN-stappen.", "Регистрация адреса и шаги по BSN.")
        case .healthcareBasics, .findingHuisarts, .healthInsuranceBasics: return text("General care orientation with official checks.", "Algemene zorgoriëntatie met broncontrole.", "Общая медицинская ориентация с проверкой источников.")
        case .digidSafety: return text("Use the official login safely.", "Gebruik de officiële login veilig.", "Безопасно используйте официальный вход.")
        case .transportBasics: return text("NS, OVpay, OV-chipkaart, local operators, bikes, and planners.", "NS, OVpay, OV-chipkaart, lokale vervoerders, fiets en planners.", "NS, OVpay, OV-chipkaart, операторы, велосипеды и планировщики.")
        case .housingBasics: return text("Rental checks and registration permission.", "Huurcontrole en inschrijfmogelijkheid.", "Проверка аренды и регистрации.")
        case .officialSourcesChecklist: return text("Verify domains before acting.", "Controleer domeinen voordat je handelt.", "Проверяйте домены перед действиями.")
        case .bankingBasics: return text("IBAN, payments, and secure banking.", "IBAN, betalingen en veilig bankieren.", "IBAN, платежи и безопасный банк.")
        }
    }

    private func guideIcon(_ topic: PracticalGuideTopic) -> String {
        switch topic {
        case .firstStepsNetherlands: return AppIcons.checklist
        case .municipalityRegistration: return "person.badge.plus.fill"
        case .healthcareBasics, .findingHuisarts, .healthInsuranceBasics: return "cross.case.fill"
        case .digidSafety: return "lock.shield.fill"
        case .transportBasics: return "tram.fill"
        case .housingBasics: return "house.lodge.fill"
        case .officialSourcesChecklist: return AppIcons.officialSource
        case .bankingBasics: return "creditcard.fill"
        }
    }

    private func guideTint(_ topic: PracticalGuideTopic) -> Color {
        switch topic {
        case .municipalityRegistration: return AppColors.routeLine
        case .healthcareBasics, .findingHuisarts: return AppColors.error
        case .healthInsuranceBasics, .firstStepsNetherlands, .officialSourcesChecklist: return AppColors.success
        case .digidSafety: return AppColors.cyanGlow
        case .transportBasics: return AppColors.dutchOrange
        case .housingBasics: return AppColors.violet
        case .bankingBasics: return AppColors.softBlue
        }
    }
}

private struct InformationHubItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color
    let destination: AppDestination
}
