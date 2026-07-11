import SwiftUI

struct MoreHubView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager

    var onSwitchTab: ((AppTab) -> Void)? = nil

    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 920) {
                LazyVStack(alignment: .leading, spacing: AppSpacing.sectionGap) {

                    moreIntroSection
                    categoryNavigatorSection
                    quickActionsSection
                    referenceLibrarySection
                    supportLibrarySection
                    profileSection

                    DisclaimerBanner(text: AppDisclaimers.medium(lang))
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.large)
                .padding(.bottom, AppSpacing.medium)
                .bottomTabSafeAreaPadding()
            }
        }
        .topChromeSafeAreaPadding(AppSpacing.small)
        .appSceneBackground(.more)
        .navigationTitle(L10n.t("tab.more", lang))
        .accessibilityIdentifier("more.screen")
    }

    // MARK: - Quick Actions Strip

    private var moreIntroSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 12) {
                ProductSymbolTile(symbol: "square.grid.2x2.fill", accent: AppColors.accentLight, size: 50)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(moreHeroTitle)
                        .font(.system(size: 23, weight: .black, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.84)

                    Text(moreIntroSubtitle)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appGlassCardStyle(padding: AppSpacing.cardPadding, cornerRadius: 22, accent: AppColors.accentLight)
        .accessibilityIdentifier("more.intro")
    }

    private var moreHeroSection: some View {
        ZStack {
            AppContentImageView(
                asset: ContentMediaRegistry.officialSourcesHero,
                language: .english,
                mode: .fill,
                accent: AppColors.accentLight,
                aspectRatio: nil,
                cornerRadius: 0,
                showsCaption: false,
                showsSourceButton: false,
                accessibilityLabel: moreHeroTitle,
                fallbackURLs: [],
                fallbackLocalAssetName: CuratedPlaceHeroMediaRegistry.bundledNeutralFallbackAssetName,
                debugContext: nil,
                targetPixelWidth: 1200
            )
            .frame(maxWidth: .infinity, minHeight: 220, maxHeight: 220)
            .clipped()

            LinearGradient(
                colors: [
                    Color.black.opacity(0.10),
                    Color.black.opacity(0.35),
                    Color.black.opacity(0.65)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: AppSpacing.small) {
                HStack(spacing: AppSpacing.small) {
                    LandmarkSymbolBadge(symbol: "square.grid.2x2.fill", accent: AppColors.accentLight, size: 48)
                        .accessibilityHidden(true)

                    Text(moreHeroBadge)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.accentLight)
                        .textCase(.uppercase)
                        .lineLimit(1)
                }

                Text(moreHeroTitle)
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)

                Text(moreHeroSubtitle)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.78))
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(AppSpacing.cardPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)

            Rectangle()
                .fill(Color.white.opacity(0.01))
                .frame(maxWidth: .infinity, minHeight: 220, maxHeight: 220)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(moreHeroTitle)
                .accessibilityIdentifier("more.hero.bounds")
        }
        .frame(height: 220, alignment: .bottomLeading)
        .frame(maxWidth: .infinity, alignment: .bottomLeading)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.hero, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.hero, style: .continuous)
                .stroke(Color.white.opacity(0.16), lineWidth: 0.85)
        )
        .clipped()
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            SectionHeader(title: L10n.t("more.quick.title", lang))
                .padding(.horizontal, 2)

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: AppSpacing.small
            ) {
                quickChip(
                    title: L10n.t("more.quick.parse_letter", lang),
                    icon: "envelope.open.fill",
                    color: AppColors.dutchOrange
                ) { onSwitchTab?(.assistant) }

                NavigationLink(value: AppDestination.finesList) {
                    QuickActionChipLabel(
                        title: L10n.t("more.quick.check_fine", lang),
                        icon: "exclamationmark.octagon.fill",
                        color: AppColors.error
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var profileSection: some View {
        moreSection(title: accountSectionTitle) {
            moreRow(icon: "gearshape.fill", color: AppColors.textSecondary,
                    title: L10n.t("more.row.settings.title", lang),
                    subtitle: L10n.t("more.row.settings.subtitle", lang),
                    destination: .settings)

            moreRow(icon: "info.circle.fill", color: AppColors.softBlue,
                    title: aboutTitle,
                    subtitle: aboutSubtitle,
                    destination: .aboutYouNew)
        }
    }

    private var referenceLibrarySection: some View {
        moreSection(title: referenceLibraryTitle) {
            moreRow(icon: "books.vertical.fill", color: AppColors.accent,
                    title: L10n.t("more.row.resources.title", lang),
                    subtitle: L10n.t("more.row.resources.subtitle", lang),
                    destination: .resourcesHub)

            moreRow(icon: "checkmark.seal.fill", color: AppColors.success,
                    title: localPartnersTitle,
                    subtitle: localPartnersSubtitle,
                    destination: .localPartners)

            moreRow(icon: "figure.child", color: AppColors.accent,
                    title: L10n.t("more.row.guides.title", lang),
                    subtitle: L10n.t("more.row.guides.subtitle", lang),
                    destination: .beginnerGuidesList)

            moreRow(icon: "text.book.closed.fill", color: AppColors.accent,
                    title: L10n.t("more.row.terms.title", lang),
                    subtitle: L10n.t("more.row.terms.subtitle", lang),
                    destination: .dutchTermsList)

            moreRow(icon: "envelope.open.fill", color: AppColors.dutchOrange,
                    title: L10n.t("more.row.fines_letters.title", lang),
                    subtitle: L10n.t("more.row.fines_letters.subtitle", lang),
                    destination: .finesAndLettersHub)

            moreRow(icon: "building.columns.fill", color: AppColors.success,
                    title: L10n.t("more.row.official_sites.title", lang),
                    subtitle: L10n.t("more.row.official_sites.subtitle", lang),
                    destination: .officialSources)

            moreRow(icon: "exclamationmark.triangle.fill", color: AppColors.warning,
                    title: L10n.t("more.row.mistakes.title", lang),
                    subtitle: L10n.t("more.row.mistakes.subtitle", lang),
                    destination: .mistakesList)
        }
    }

    private var localPartnersTitle: String {
        switch lang {
        case .russian: return "Local Partners"
        case .dutch: return "Local Partners"
        case .english: return "Local Partners"
        }
    }

    private var localPartnersSubtitle: String {
        switch lang {
        case .russian: return "Подборка локальных сервисов без навязчивой рекламы."
        case .dutch: return "Uitgelichte lokale diensten zonder opdringerige reclame."
        case .english: return "Featured local services without intrusive advertising."
        }
    }

    private var supportLibrarySection: some View {
        moreSection(title: supportLibraryTitle) {
            supportRow(icon: "scale.3d", color: AppColors.textSecondary,
                    title: L10n.t("more.row.legal.title", lang),
                    subtitle: L10n.t("more.row.legal.subtitle", lang),
                    destination: .legalHelp)

            if RelatedContentEngine.isVisible(.lgbtqSupport, for: appState.selectedUserStatus?.personaTag) {
                supportRow(icon: "heart.text.square.fill", color: AppColors.violet,
                        title: L10n.t("more.row.lgbtq.title", lang),
                        subtitle: L10n.t("more.row.lgbtq.subtitle", lang),
                        destination: .lgbtqSupport)
            }

            if RelatedContentEngine.isVisible(.emotionalSupport, for: appState.selectedUserStatus?.personaTag) {
                supportRow(icon: "figure.mind.and.body", color: AppColors.emerald,
                        title: emotionalSupportTitle,
                        subtitle: emotionalSupportSubtitle,
                        destination: .emotionalSupport)
            }
        }
    }

    private func quickChip(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            QuickActionChipLabel(title: title, icon: icon, color: color)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Personal Guide Dashboard

    private var personalGuideDashboardSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            SectionHeader(title: dashboardTitle, subtitle: dashboardSubtitle)
                .padding(.horizontal, 2)

            VStack(alignment: .leading, spacing: AppSpacing.small) {
                LazyVGrid(columns: dashboardInfoColumns, spacing: AppSpacing.small) {
                    dashboardInfoTile(
                        icon: "location.fill",
                        color: AppColors.dutchOrange,
                        title: currentCityTitle,
                        value: ProvinceCatalog.localizedCityName(appState.selectedCity, lang),
                        detail: currentCityDetail
                    )

                    dashboardInfoTile(
                        icon: "cloud.sun.fill",
                        color: AppColors.warning,
                        title: weatherTitle,
                        value: weatherValue,
                        detail: weatherDetail
                    )
                }

                LazyVGrid(columns: dashboardActionColumns, spacing: AppSpacing.small) {
                    dashboardDestinationCard(
                        icon: "arrow.triangle.2.circlepath",
                        color: AppColors.cyanGlow,
                        title: changeSituationTitle,
                        subtitle: changeSituationSubtitle,
                        destination: .profileSelection
                    )

                    dashboardDestinationCard(
                        icon: "phone.circle.fill",
                        color: AppColors.error,
                        title: emergencyTitle,
                        subtitle: "112",
                        destination: .emergencyHub
                    )

                    dashboardTabCard(
                        icon: AppIcons.save,
                        color: AppColors.softBlue,
                        title: savedTitle,
                        subtitle: savedSubtitle,
                        tab: .favorites
                    )

                    dashboardDestinationCard(
                        icon: "doc.text.fill",
                        color: AppColors.cyanGlow,
                        title: documentsTitle,
                        subtitle: documentsSubtitle,
                        destination: .journeyDocuments
                    )

                    dashboardDestinationCard(
                        icon: "text.book.closed.fill",
                        color: AppColors.emerald,
                        title: languageLearningTitle,
                        subtitle: languageLearningSubtitle,
                        destination: .dutchA1A2
                    )

                    dashboardDestinationCard(
                        icon: "tram.fill",
                        color: AppColors.dutchOrange,
                        title: transportTitle,
                        subtitle: transportSubtitle,
                        destination: .practicalGuide(.transportBasics)
                    )

                    dashboardTabCard(
                        icon: AppIcons.assistant,
                        color: AppColors.violet,
                        title: aiAssistantTitle,
                        subtitle: aiAssistantSubtitle,
                        tab: .assistant
                    )
                }

                HStack(alignment: .top, spacing: AppSpacing.small) {
                    dashboardMiniPanel(
                        icon: "clock.arrow.circlepath",
                        color: AppColors.emerald,
                        title: recentActivityTitle,
                        lines: [recentHistoryLine, recentTransportLine, recentDocumentsLine]
                    )

                    dashboardMiniPanel(
                        icon: "calendar.badge.exclamationmark",
                        color: AppColors.warning,
                        title: deadlinesTitle,
                        lines: [deadlineBRPLine, deadlineInsuranceLine, deadlineLettersLine]
                    )
                }

                dashboardDestinationCard(
                    icon: "checklist.checked",
                    color: AppColors.cyanGlow,
                    title: upcomingTasksTitle,
                    subtitle: upcomingTasksSubtitle,
                    destination: .firstSteps
                )
            }
            .appGlassCardStyle(padding: AppSpacing.small, cornerRadius: 24, accent: AppColors.cyanGlow)
        }
        .accessibilityIdentifier("more.dashboard")
    }

    private var dashboardInfoColumns: [GridItem] {
        [GridItem(.flexible(), spacing: AppSpacing.small), GridItem(.flexible(), spacing: AppSpacing.small)]
    }

    private var dashboardActionColumns: [GridItem] {
        [GridItem(.flexible(), spacing: AppSpacing.small), GridItem(.flexible(), spacing: AppSpacing.small)]
    }

    private func dashboardInfoTile(icon: String, color: Color, title: String, value: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(color)
                    .frame(width: 28, height: 28)
                    .background(color.opacity(0.13))
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                Text(title)
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(AppColors.textTertiary)
                    .textCase(.uppercase)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text(value)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.70)

            Text(detail)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(3)
                .minimumScaleFactor(0.86)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 126, alignment: .topLeading)
        .background(color.opacity(0.075))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(color.opacity(0.16), lineWidth: 0.8))
    }

    private func dashboardDestinationCard(
        icon: String,
        color: Color,
        title: String,
        subtitle: String,
        destination: AppDestination
    ) -> some View {
        NavigationLink(value: destination) {
            dashboardCardLabel(icon: icon, color: color, title: title, subtitle: subtitle)
        }
        .buttonStyle(.plain)
    }

    private func dashboardTabCard(icon: String, color: Color, title: String, subtitle: String, tab: AppTab) -> some View {
        Button {
            onSwitchTab?(tab)
        } label: {
            dashboardCardLabel(icon: icon, color: color, title: title, subtitle: subtitle)
        }
        .buttonStyle(.plain)
    }

    private func dashboardCardLabel(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(color)
                .frame(width: 34, height: 34)
                .background(color.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)
                    .fixedSize(horizontal: false, vertical: true)
                Text(subtitle)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 82, alignment: .topLeading)
        .background(Color.white.opacity(0.045))
        .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 17, style: .continuous).stroke(color.opacity(0.14), lineWidth: 0.8))
        .contentShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
    }

    private func dashboardMiniPanel(icon: String, color: Color, title: String, lines: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(color)
                Text(title)
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.74)
            }

            ForEach(lines, id: \.self) { line in
                HStack(alignment: .top, spacing: 6) {
                    Circle()
                        .fill(color.opacity(0.78))
                        .frame(width: 5, height: 5)
                        .padding(.top, 6)
                    Text(line)
                        .font(.system(size: 10.5, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 128, alignment: .topLeading)
        .background(color.opacity(0.065))
        .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 17, style: .continuous).stroke(color.opacity(0.13), lineWidth: 0.8))
    }

    private var dashboardTitle: String {
        localizedText(en: "Personal guide dashboard", nl: "Persoonlijk gidsdashboard", ru: "Персональная панель")
    }

    private var dashboardSubtitle: String {
        localizedText(en: "Your city, urgent help, saved items, documents, learning, and next actions.", nl: "Je stad, spoedhulp, opgeslagen items, documenten, leren en volgende acties.", ru: "Ваш город, срочная помощь, сохранённое, документы, обучение и следующие шаги.")
    }

    private var moreIntroSubtitle: String {
        localizedText(
            en: "Settings, official resources, support topics, and useful tools in one calm place.",
            nl: "Instellingen, officiële bronnen, steunonderwerpen en handige tools op één rustige plek.",
            ru: "Настройки, официальные источники, поддержка и полезные инструменты в одном спокойном месте."
        )
    }

    private var currentCityTitle: String { localizedText(en: "Current city", nl: "Huidige stad", ru: "Текущий город") }
    private var currentCityDetail: String { localizedText(en: "Open municipality and local basics from city pages.", nl: "Open gemeente en lokale basisinfo via stadspagina's.", ru: "Откройте муниципалитет и местную информацию на странице города.") }
    private var weatherTitle: String { localizedText(en: "Weather", nl: "Weer", ru: "Погода") }
    private var weatherValue: String { localizedText(en: "Check forecast", nl: "Bekijk verwachting", ru: "Проверить прогноз") }
    private var weatherDetail: String { localizedText(en: "Use official local forecast before travel.", nl: "Gebruik lokale officiële verwachting voor vertrek.", ru: "Проверьте официальный прогноз перед поездкой.") }
    private var emergencyTitle: String { localizedText(en: "Emergency", nl: "Noodhulp", ru: "Экстренно") }
    private var savedTitle: String { localizedText(en: "Saved items", nl: "Opgeslagen", ru: "Сохранённое") }
    private var savedSubtitle: String { localizedText(en: "Bookmarks and later reading", nl: "Bladwijzers en later lezen", ru: "Закладки и чтение позже") }
    private var documentsTitle: String { localizedText(en: "Documents", nl: "Documenten", ru: "Документы") }
    private var documentsSubtitle: String { localizedText(en: "Letters, forms, and actions", nl: "Brieven, formulieren en acties", ru: "Письма, формы и действия") }
    private var languageLearningTitle: String { localizedText(en: "Language learning", nl: "Taal leren", ru: "Изучение языка") }
    private var languageLearningSubtitle: String { localizedText(en: "A1/A2 Dutch practice", nl: "A1/A2 Nederlands oefenen", ru: "Практика A1/A2") }
    private var transportTitle: String { localizedText(en: "Transport", nl: "Vervoer", ru: "Транспорт") }
    private var transportSubtitle: String { localizedText(en: "OV, check-in, route planning", nl: "OV, inchecken, reisplanning", ru: "OV, check-in и маршруты") }
    private var aiAssistantTitle: String { localizedText(en: "AI Assistant", nl: "AI-assistent", ru: "AI ассистент") }
    private var aiAssistantSubtitle: String { localizedText(en: "Ask, translate, explain", nl: "Vraag, vertaal, leg uit", ru: "Спросить, перевести, объяснить") }
    private var changeSituationTitle: String { localizedText(en: "Personalize guide", nl: "Gids personaliseren", ru: "Настроить гид") }
    private var changeSituationSubtitle: String { localizedText(en: "Update your profile and priorities", nl: "Werk profiel en prioriteiten bij", ru: "Обновить профиль и приоритеты") }
    private var recentActivityTitle: String { localizedText(en: "Recent activity", nl: "Recente activiteit", ru: "Недавнее") }
    private var recentHistoryLine: String { localizedText(en: "History and culture", nl: "Geschiedenis en cultuur", ru: "История и культура") }
    private var recentTransportLine: String { localizedText(en: "Transport guide", nl: "Vervoergids", ru: "Транспортный гид") }
    private var recentDocumentsLine: String { localizedText(en: "Documents organizer", nl: "Documentenplanner", ru: "Органайзер документов") }
    private var deadlinesTitle: String { localizedText(en: "Important deadlines", nl: "Belangrijke deadlines", ru: "Важные сроки") }
    private var deadlineBRPLine: String { localizedText(en: "BRP address changes", nl: "BRP-adreswijzigingen", ru: "Изменения BRP-адреса") }
    private var deadlineInsuranceLine: String { localizedText(en: "Health insurance timing", nl: "Timing zorgverzekering", ru: "Сроки страховки") }
    private var deadlineLettersLine: String { localizedText(en: "Official letter dates", nl: "Datums op officiële brieven", ru: "Даты в официальных письмах") }
    private var upcomingTasksTitle: String { localizedText(en: "Upcoming tasks", nl: "Komende taken", ru: "Следующие задачи") }
    private var upcomingTasksSubtitle: String { localizedText(en: "Review first steps and finish setup safely.", nl: "Bekijk eerste stappen en rond veilig af.", ru: "Проверьте первые шаги и завершите настройку.") }

    private func localizedText(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }

    private var moreHeroTitle: String {
        switch lang {
        case .russian: return "Справочник и поддержка"
        case .dutch: return "Gids en ondersteuning"
        case .english: return "Guide and support"
        }
    }

    private var moreHeroSubtitle: String {
        switch lang {
        case .russian: return "Документы, официальные сайты, карта помощи и полезные разделы в одном месте."
        case .dutch: return "Documenten, officiële websites, hulpkaart en nuttige onderdelen op één plek."
        case .english: return "Documents, official websites, nearby help, and useful sections in one place."
        }
    }

    private var moreHeroBadge: String {
        switch lang {
        case .russian: return "Разделы"
        case .dutch: return "Onderdelen"
        case .english: return "Sections"
        }
    }

    private var emotionalSupportTitle: String {
        switch lang {
        case .russian: return "Эмоциональная поддержка"
        case .dutch: return "Emotionele steun"
        case .english: return "Emotional support"
        }
    }

    private var emotionalSupportSubtitle: String {
        switch lang {
        case .russian: return "Короткие контакты для подростков, молодых взрослых и срочных ситуаций."
        case .dutch: return "Korte hulpcontacten voor tieners, jongvolwassenen en urgente situaties."
        case .english: return "Short help contacts for teens, young adults, and urgent moments."
        }
    }

    private var categoryNavigatorSection: some View {
        PremiumMenuSection(title: categorySectionTitle) {
            categoryAction(icon: AppIcons.home, color: AppColors.dutchOrange, title: categoryHomeTitle, subtitle: categoryHomeSubtitle) {
                onSwitchTab?(.home)
            }
            categoryAction(icon: AppIcons.mapActive, color: AppColors.cyanGlow, title: categoryPlacesTitle, subtitle: categoryPlacesSubtitle) {
                onSwitchTab?(.map)
            }
            categoryAction(icon: AppIcons.assistant, color: AppColors.violet, title: categoryAssistantTitle, subtitle: categoryAssistantSubtitle) {
                onSwitchTab?(.assistant)
            }
        }
    }

    @ViewBuilder
    private var personaCategoryLinks: some View {
        switch appState.selectedUserStatus?.personaTag {
        case .student:
            categoryLink(icon: "graduationcap.fill", color: AppColors.emerald, title: moreStudentStudyTitle, subtitle: moreStudentStudySubtitle, destination: .beginnerGuidesList)
            categoryLink(icon: "house.fill", color: AppColors.warning, title: moreStudentHousingTitle, subtitle: moreStudentHousingSubtitle, destination: .guideSection("housing"))
            categoryLink(icon: "text.book.closed.fill", color: AppColors.accent, title: languageLearningTitle, subtitle: languageLearningSubtitle, destination: .dutchA1A2)
            categoryLink(icon: "tram.fill", color: AppColors.dutchOrange, title: categoryTransportTitle, subtitle: moreStudentTransportSubtitle, destination: .practicalGuide(.transportBasics))
        case .worker, .highlySkilledMigrant:
            categoryLink(icon: "briefcase.fill", color: AppColors.softBlue, title: categoryWorkTitle, subtitle: categoryWorkSubtitle, destination: .guideSection("work"))
            categoryLink(icon: "building.columns.fill", color: AppColors.softBlue, title: categoryGovTitle, subtitle: categoryGovSubtitle, destination: .governmentHub)
            categoryLink(icon: "cross.case.fill", color: AppColors.success, title: categoryHealthTitle, subtitle: categoryHealthSubtitle, destination: .guideSection("healthcare"))
            categoryLink(icon: "house.fill", color: AppColors.warning, title: categoryHousingTitle, subtitle: categoryHousingSubtitle, destination: .guideSection("housing"))
            categoryLink(icon: "tram.fill", color: AppColors.accent, title: categoryTransportTitle, subtitle: categoryTransportSubtitle, destination: .practicalGuide(.transportBasics))
        case .refugee:
            categoryLink(icon: "building.columns.fill", color: AppColors.softBlue, title: moreRefugeeIndMunicipalityTitle, subtitle: moreRefugeeIndMunicipalitySubtitle, destination: .governmentHub)
            categoryLink(icon: "house.fill", color: AppColors.warning, title: categoryHousingTitle, subtitle: moreRefugeeHousingSubtitle, destination: .guideSection("housing"))
            categoryLink(icon: "person.2.fill", color: AppColors.emerald, title: moreRefugeeIntegrationTitle, subtitle: moreRefugeeIntegrationSubtitle, destination: .guideSection("integration"))
            categoryLink(icon: "text.book.closed.fill", color: AppColors.accent, title: languageLearningTitle, subtitle: languageLearningSubtitle, destination: .dutchA1A2)
            categoryLink(icon: "doc.text.fill", color: AppColors.softBlue, title: categoryDocsTitle, subtitle: categoryDocsSubtitle, destination: .guideSection("documents"))
            categoryLink(icon: "map.fill", color: AppColors.accent, title: categoryNearbyTitle, subtitle: categoryNearbySubtitle, destination: .mapHub)
        case .family:
            categoryLink(icon: "graduationcap.fill", color: AppColors.emerald, title: moreFamilySchoolsTitle, subtitle: moreFamilySchoolsSubtitle, destination: .beginnerGuidesList)
            categoryLink(icon: "figure.and.child.holdinghands", color: AppColors.softBlue, title: moreFamilyChildcareTitle, subtitle: moreFamilyChildcareSubtitle, destination: .officialSources)
            categoryLink(icon: "building.columns.fill", color: AppColors.dutchOrange, title: moreFamilyBenefitsTitle, subtitle: moreFamilyBenefitsSubtitle, destination: .officialSources)
            categoryLink(icon: "cross.case.fill", color: AppColors.success, title: categoryHealthTitle, subtitle: categoryHealthSubtitle, destination: .guideSection("healthcare"))
            categoryLink(icon: "house.fill", color: AppColors.warning, title: categoryHousingTitle, subtitle: categoryHousingSubtitle, destination: .guideSection("housing"))
        case .tourist:
            categoryLink(icon: "tram.fill", color: AppColors.accent, title: categoryTransportTitle, subtitle: categoryTransportSubtitle, destination: .practicalGuide(.transportBasics))
            categoryLink(icon: "phone.circle.fill", color: AppColors.error, title: categoryEmergencyTitle, subtitle: categoryEmergencySubtitle, destination: .emergencyHub)
            categoryLink(icon: "map.circle.fill", color: AppColors.softBlue, title: categoryProvinceTitle, subtitle: categoryProvinceSubtitle, destination: .provinceList)
            categoryLink(icon: "cross.case.fill", color: AppColors.success, title: categoryHealthTitle, subtitle: moreTouristHealthSubtitle, destination: .guideSection("healthcare"))
        case .entrepreneur:
            categoryLink(icon: "building.columns.fill", color: AppColors.softBlue, title: moreEntrepreneurKvkTitle, subtitle: moreEntrepreneurKvkSubtitle, destination: .officialSources)
            categoryLink(icon: "percent", color: AppColors.dutchOrange, title: moreEntrepreneurTaxTitle, subtitle: moreEntrepreneurTaxSubtitle, destination: .officialSources)
            categoryLink(icon: "creditcard.fill", color: AppColors.success, title: moreEntrepreneurBankingTitle, subtitle: moreEntrepreneurBankingSubtitle, destination: .guideSection("documents"))
            categoryLink(icon: "doc.text.fill", color: AppColors.warning, title: moreEntrepreneurPermitsTitle, subtitle: moreEntrepreneurPermitsSubtitle, destination: .governmentHub)
        case .lgbt:
            categoryLink(icon: "heart.text.square.fill", color: AppColors.violet, title: moreLGBTSupportTitle, subtitle: moreLGBTSupportSubtitle, destination: .lgbtqSupport)
            categoryLink(icon: "cross.case.fill", color: AppColors.success, title: categoryHealthTitle, subtitle: moreLGBTHealthSubtitle, destination: .guideSection("healthcare"))
            categoryLink(icon: "figure.mind.and.body", color: AppColors.emerald, title: emotionalSupportTitle, subtitle: emotionalSupportSubtitle, destination: .emotionalSupport)
            categoryLink(icon: "house.fill", color: AppColors.warning, title: moreLGBTHousingTitle, subtitle: moreLGBTHousingSubtitle, destination: .guideSection("housing"))
        case .eu, .nonEU, .universal, nil:
            categoryLink(icon: "doc.text.fill", color: AppColors.softBlue, title: categoryDocsTitle, subtitle: categoryDocsSubtitle, destination: .guideSection("documents"))
            categoryLink(icon: "cross.case.fill", color: AppColors.success, title: categoryHealthTitle, subtitle: categoryHealthSubtitle, destination: .guideSection("healthcare"))
            categoryLink(icon: "house.fill", color: AppColors.warning, title: categoryHousingTitle, subtitle: categoryHousingSubtitle, destination: .guideSection("housing"))
            categoryLink(icon: "tram.fill", color: AppColors.accent, title: categoryTransportTitle, subtitle: categoryTransportSubtitle, destination: .practicalGuide(.transportBasics))
            categoryLink(icon: "building.columns.fill", color: AppColors.softBlue, title: categoryGovTitle, subtitle: categoryGovSubtitle, destination: .governmentHub)
        }
    }

    private func categoryAction(
        icon: String,
        color: Color,
        title: String,
        subtitle: String,
        action: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 0) {
            Button(action: action) {
                PremiumMenuRow(icon: icon, color: color, title: title, subtitle: subtitle)
            }
            .buttonStyle(.plain)

            Rectangle()
                .fill(AppColors.stroke.opacity(0.7))
                .frame(height: 0.5)
                .padding(.leading, 66)
        }
    }

    private func categoryLink(
        icon: String,
        color: Color,
        title: String,
        subtitle: String,
        destination: AppDestination
    ) -> some View {
        VStack(spacing: 0) {
            NavigationLink(value: destination) {
                PremiumMenuRow(icon: icon, color: color, title: title, subtitle: subtitle)
            }
            .buttonStyle(.plain)

            Rectangle()
                .fill(AppColors.stroke.opacity(0.7))
                .frame(height: 0.5)
                .padding(.leading, 66)
        }
    }

    private var categorySectionTitle: String {
        switch lang {
        case .russian: return "Меню"
        case .english: return "Categories"
        case .dutch: return "Categorieën"
        }
    }

    private var categoryHomeTitle: String { lang == .russian ? "Главная" : (lang == .dutch ? "Start" : "Home") }
    private var categoryHomeSubtitle: String { lang == .russian ? "Важное сегодня и быстрые действия" : (lang == .dutch ? "Belangrijk vandaag en snelle acties" : "Important today and quick actions") }
    private var categoryPlacesTitle: String { lang == .russian ? "Places" : (lang == .dutch ? "Places" : "Places") }
    private var categoryPlacesSubtitle: String { lang == .russian ? "Карта, места и сервисы рядом" : (lang == .dutch ? "Kaart, plekken en diensten dichtbij" : "Map, places, and services nearby") }
    private var categoryRulesTitle: String { lang == .russian ? "Правила и штрафы" : (lang == .dutch ? "Regels en boetes" : "Rules and fines") }
    private var categoryRulesSubtitle: String { lang == .russian ? "Транспорт, парковка, штрафы, предупреждения" : (lang == .dutch ? "Vervoer, parkeren, boetes en waarschuwingen" : "Transport, parking, fines, warnings") }
    private var categoryDocsTitle: String { lang == .russian ? "Документы и услуги" : (lang == .dutch ? "Documenten en diensten" : "Documents and services") }
    private var categoryDocsSubtitle: String { lang == .russian ? "BSN, DigiD, письма и госуслуги" : (lang == .dutch ? "BSN, DigiD, brieven en overheidsdiensten" : "BSN, DigiD, letters, government services") }
    private var categoryTransportTitle: String { lang == .russian ? "Транспорт" : (lang == .dutch ? "Vervoer" : "Transport") }
    private var categoryTransportSubtitle: String { lang == .russian ? "OV, велосипед, парковка, маршруты" : (lang == .dutch ? "OV, fiets, parkeren, routes" : "OV, bike, parking, routes") }
    private var categoryWorkTitle: String { lang == .russian ? "Работа и налоги" : (lang == .dutch ? "Werk en belastingen" : "Work and taxes") }
    private var categoryWorkSubtitle: String { lang == .russian ? "Контракт, налоги, UWV, Belastingdienst" : (lang == .dutch ? "Contract, belastingen, UWV, Belastingdienst" : "Contract, taxes, UWV, Belastingdienst") }
    private var categoryHousingTitle: String { lang == .russian ? "Жильё" : (lang == .dutch ? "Wonen" : "Housing") }
    private var categoryHousingSubtitle: String { lang == .russian ? "Аренда, правила и типичные ошибки" : (lang == .dutch ? "Huur, regels en veelgemaakte fouten" : "Rent, rules, common mistakes") }
    private var categoryHealthTitle: String { lang == .russian ? "Здоровье" : (lang == .dutch ? "Gezondheid" : "Health") }
    private var categoryHealthSubtitle: String { lang == .russian ? "Страховка, семейный врач, аптеки, больницы" : (lang == .dutch ? "Verzekering, huisarts, apotheken, ziekenhuizen" : "Insurance, GP, pharmacies, hospitals") }
    private var categoryGovTitle: String { lang == .russian ? "Правительство" : (lang == .dutch ? "Overheid" : "Government") }
    private var categoryGovSubtitle: String { lang == .russian ? "Муниципалитет, IND и официальные сайты" : (lang == .dutch ? "Gemeente, IND en officiële websites" : "Municipality, IND, official websites") }
    private var categoryEmergencyTitle: String { lang == .russian ? "Экстренная помощь" : (lang == .dutch ? "Noodhulp" : "Emergency help") }
    private var categoryEmergencySubtitle: String { lang == .russian ? "112, полиция, срочные контакты" : (lang == .dutch ? "112, politie, spoedcontacten" : "112, police, urgent contacts") }
    private var categoryNearbyTitle: String { lang == .russian ? "Помощь рядом" : (lang == .dutch ? "Hulp in de buurt" : "Nearby help") }
    private var categoryNearbySubtitle: String { lang == .russian ? "Карта служб и фильтры категорий" : (lang == .dutch ? "Kaart met diensten en filters" : "Service map and category filters") }
    private var categoryProvinceTitle: String { lang == .russian ? "Провинции и города" : (lang == .dutch ? "Provincies en steden" : "Provinces and cities") }
    private var categoryProvinceSubtitle: String { lang == .russian ? "Справочник по регионам Нидерландов" : (lang == .dutch ? "Gids voor regio's in Nederland" : "Regional Netherlands directory") }
    private var categoryAssistantTitle: String { lang == .russian ? "Ассистент" : (lang == .dutch ? "Assistent" : "Assistant") }
    private var categoryAssistantSubtitle: String { lang == .russian ? "AI-помощник по вопросам и ситуациям" : (lang == .dutch ? "AI-hulp voor vragen en situaties" : "AI help for questions and situations") }
    private var moreStudentStudyTitle: String { localizedText(en: "Universities", nl: "Universiteiten", ru: "Университеты") }
    private var moreStudentStudySubtitle: String { localizedText(en: "MBO, HBO, research universities, DUO", nl: "MBO, HBO, onderzoeksuniversiteiten, DUO", ru: "MBO, HBO, research universities, DUO") }
    private var moreStudentHousingTitle: String { localizedText(en: "Student housing", nl: "Studentenhuisvesting", ru: "Студенческое жилье") }
    private var moreStudentHousingSubtitle: String { localizedText(en: "Rooms, registration, study spaces", nl: "Kamers, inschrijving, studieplekken", ru: "Комнаты, регистрация, места для учебы") }
    private var moreStudentTransportSubtitle: String { localizedText(en: "Public transport discounts and city travel", nl: "OV-korting en reizen in de stad", ru: "Скидки на транспорт и поездки по городу") }
    private var moreRefugeeIndMunicipalityTitle: String { localizedText(en: "IND and municipality", nl: "IND en gemeente", ru: "IND и муниципалитет") }
    private var moreRefugeeIndMunicipalitySubtitle: String { localizedText(en: "Status, benefits, documents", nl: "Status, uitkeringen, documenten", ru: "Статус, пособия, документы") }
    private var moreRefugeeHousingSubtitle: String { localizedText(en: "Housing path and local support", nl: "Woonroute en lokale steun", ru: "Жилье и местная поддержка") }
    private var moreRefugeeIntegrationTitle: String { localizedText(en: "Integration", nl: "Integratie", ru: "Интеграция") }
    private var moreRefugeeIntegrationSubtitle: String { localizedText(en: "Language, healthcare, education access", nl: "Taal, zorg, toegang tot onderwijs", ru: "Язык, медицина, доступ к образованию") }
    private var moreFamilySchoolsTitle: String { localizedText(en: "Schools", nl: "Scholen", ru: "Школы") }
    private var moreFamilySchoolsSubtitle: String { localizedText(en: "Education and activities for children", nl: "Onderwijs en activiteiten voor kinderen", ru: "Образование и активности для детей") }
    private var moreFamilyChildcareTitle: String { localizedText(en: "Childcare", nl: "Kinderopvang", ru: "Детский сад") }
    private var moreFamilyChildcareSubtitle: String { localizedText(en: "Kinderopvang and municipal services", nl: "Kinderopvang en gemeentelijke diensten", ru: "Kinderopvang и муниципальные услуги") }
    private var moreFamilyBenefitsTitle: String { localizedText(en: "SVB and child benefits", nl: "SVB en kinderbijslag", ru: "SVB и детские пособия") }
    private var moreFamilyBenefitsSubtitle: String { localizedText(en: "Family support and benefits", nl: "Gezinssteun en toeslagen", ru: "Поддержка семьи и пособия") }
    private var moreTouristHealthSubtitle: String { localizedText(en: "Urgent care and travel health", nl: "Spoedzorg en reisgezondheid", ru: "Срочная помощь и здоровье в поездке") }
    private var moreEntrepreneurKvkTitle: String { localizedText(en: "KVK", nl: "KVK", ru: "KVK") }
    private var moreEntrepreneurKvkSubtitle: String { localizedText(en: "Business registration", nl: "Bedrijfsregistratie", ru: "Регистрация бизнеса") }
    private var moreEntrepreneurTaxTitle: String { localizedText(en: "VAT / BTW", nl: "BTW", ru: "BTW") }
    private var moreEntrepreneurTaxSubtitle: String { localizedText(en: "Business tax basics", nl: "Belastingbasis voor ondernemers", ru: "Налоги для бизнеса") }
    private var moreEntrepreneurBankingTitle: String { localizedText(en: "Business banking", nl: "Zakelijk bankieren", ru: "Бизнес-банк") }
    private var moreEntrepreneurBankingSubtitle: String { localizedText(en: "Banking, insurance, contracts", nl: "Bankieren, verzekering, contracten", ru: "Банк, страхование, договоры") }
    private var moreEntrepreneurPermitsTitle: String { localizedText(en: "Permits", nl: "Vergunningen", ru: "Разрешения") }
    private var moreEntrepreneurPermitsSubtitle: String { localizedText(en: "Municipal rules and business setup", nl: "Gemeentelijke regels en bedrijfsstart", ru: "Муниципальные правила и старт бизнеса") }
    private var moreLGBTSupportTitle: String { localizedText(en: "LGBT support", nl: "LGBT steun", ru: "ЛГБТ поддержка") }
    private var moreLGBTSupportSubtitle: String { localizedText(en: "Safety, rights, community", nl: "Veiligheid, rechten, gemeenschap", ru: "Безопасность, права, сообщество") }
    private var moreLGBTHealthSubtitle: String { localizedText(en: "Inclusive healthcare", nl: "Inclusieve zorg", ru: "Инклюзивная медицина") }
    private var moreLGBTHousingTitle: String { localizedText(en: "Housing safety", nl: "Woonveiligheid", ru: "Безопасность жилья") }
    private var moreLGBTHousingSubtitle: String { localizedText(en: "Safe housing and legal support", nl: "Veilig wonen en juridische steun", ru: "Безопасное жилье и юридическая помощь") }
    private var accountSectionTitle: String { localizedText(en: "Account", nl: "Account", ru: "Аккаунт") }
    private var aboutTitle: String { lang == .russian ? "О приложении" : (lang == .dutch ? "Over de app" : "About the app") }
    private var aboutSubtitle: String { lang == .russian ? "Информация о YouNew.nl" : (lang == .dutch ? "Informatie over YouNew.nl" : "Information about YouNew.nl") }
    private var referenceLibraryTitle: String { lang == .russian ? "Справочник" : (lang == .dutch ? "Naslagwerk" : "Reference library") }
    private var supportLibraryTitle: String { lang == .russian ? "Поддержка" : (lang == .dutch ? "Ondersteuning" : "Support") }

    // MARK: - Helpers

    @ViewBuilder
    private func moreSection<Content: View>(title: String, @ViewBuilder content: @escaping () -> Content) -> some View {
        PremiumMenuSection(title: title) {
            content()
        }
    }

    private func moreRow(
        icon: String,
        color: Color,
        title: String,
        subtitle: String,
        destination: AppDestination
    ) -> some View {
        VStack(spacing: 0) {
            NavigationLink(value: destination) {
                PremiumMenuRow(icon: icon, color: color, title: title, subtitle: subtitle)
            }
            .buttonStyle(.plain)

            Rectangle()
                .fill(AppColors.stroke.opacity(0.7))
                .frame(height: 0.5)
                .padding(.leading, 66)
        }
    }

    private func supportRow(
        icon: String,
        color: Color,
        title: String,
        subtitle: String,
        destination: AppDestination
    ) -> some View {
        VStack(spacing: 0) {
            NavigationLink(value: destination) {
                PremiumMenuRow(
                    icon: icon,
                    color: color,
                    title: title,
                    subtitle: subtitle,
                    minHeight: 76,
                    iconSize: 42
                )
            }
            .buttonStyle(.plain)

            Rectangle()
                .fill(AppColors.stroke.opacity(0.70))
                .frame(height: 0.5)
                .padding(.leading, 68)
        }
    }
}

// MARK: - Quick Action Chip Label

private struct QuickActionChipLabel: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            GradientIconBadge(symbol: icon, color: color, size: 34, cornerRadius: 10)

            Text(title)
                .font(.system(size: 12.5, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous)
                    .fill(AppColors.card)
                RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous)
                    .fill(color.opacity(0.04))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous)
                .stroke(AppColors.stroke.opacity(0.88), lineWidth: 0.75)
        }
        .shadow(color: color.opacity(0.08), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Fines & Letters Hub

struct FinesAndLettersHubView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                finesAndLettersHero

                NavigationLink(value: AppDestination.finesList) {
                    PremiumMenuCard {
                        PremiumMenuRow(
                            icon: "exclamationmark.octagon.fill",
                            color: AppColors.dutchOrange,
                            title: L10n.t("more.fines_hub.fines.title", lang),
                            subtitle: L10n.t("more.fines_hub.fines.detail", lang)
                        )
                    }
                }
                .buttonStyle(.plain)

                NavigationLink(value: AppDestination.lettersList) {
                    PremiumMenuCard {
                        PremiumMenuRow(
                            icon: "envelope.open.fill",
                            color: AppColors.softBlue,
                            title: L10n.t("more.fines_hub.letters.title", lang),
                            subtitle: L10n.t("more.fines_hub.letters.detail", lang)
                        )
                    }
                }
                .buttonStyle(.plain)

            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .bottomTabSafeAreaPadding()
        }
        .topChromeSafeAreaPadding()
        .appSceneBackground(.fines)
        .navigationTitle(L10n.t("more.row.fines_letters.title", lang))
    }

    private var finesAndLettersHero: some View {
        CategoryHeroVisual(
            assetName: nil,
            title: L10n.t("more.row.fines_letters.title", lang),
            subtitle: finesAndLettersSubtitle,
            symbol: "envelope.badge.shield.half.filled.fill",
            badgeText: finesAndLettersBadge,
            accent: AppColors.dutchOrange,
            asset: ContentMediaRegistry.savedImage ?? ContentMediaRegistry.officialSourcesHero,
            height: 220,
            language: lang
        )
        .accessibilityIdentifier("finesLetters.hero")
    }

    private var finesAndLettersSubtitle: String {
        switch lang {
        case .russian: return "Понимайте официальные письма, штрафы и безопасные следующие шаги."
        case .dutch: return "Begrijp officiële brieven, boetes en veilige vervolgstappen."
        case .english: return "Understand official letters, fines, and safe next steps."
        }
    }

    private var finesAndLettersBadge: String {
        switch lang {
        case .russian: return "Документы и правила"
        case .dutch: return "Brieven en regels"
        case .english: return "Letters and rules"
        }
    }
}

// MARK: - Emergency Contacts

private struct EmergencyContactsView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.openURL) private var openURL
    private var lang: AppLanguage { languageManager.appLanguage }

    private struct Contact: Identifiable {
        let id = UUID()
        let name: String
        let number: String
        let description: String
        let color: Color
        let icon: String
        let dialURL: URL?
    }

    private var contacts: [Contact] {
        [
            Contact(name: L10n.t("emergency.112.name", lang),     number: "112",
                    description: L10n.t("emergency.112.desc", lang),
                    color: AppColors.error, icon: "phone.fill",
                    dialURL: URL(string: "tel://112")),
            Contact(name: L10n.t("emergency.politie.name", lang), number: "0900-8844",
                    description: L10n.t("emergency.politie.desc", lang),
                    color: AppColors.warning, icon: "building.fill",
                    dialURL: URL(string: "tel://09008844")),
            Contact(name: L10n.t("emergency.huisarts.name", lang), number: "",
                    description: L10n.t("emergency.huisarts.desc", lang),
                    color: AppColors.success, icon: "cross.case.fill",
                    dialURL: nil),
            Contact(name: L10n.t("emergency.loket.name", lang),   number: "0900-8020",
                    description: L10n.t("emergency.loket.desc", lang),
                    color: AppColors.accent, icon: "scale.3d",
                    dialURL: URL(string: "tel://09008020"))
        ]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                emergencyContactsHero
                DisclaimerBanner(text: L10n.t("disclaimer.short", lang))

                ForEach(contacts) { contact in
                    PremiumMenuCard {
                        HStack(spacing: AppSpacing.medium) {
                            GradientIconBadge(symbol: contact.icon, color: contact.color, size: 44)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(contact.name)
                                    .font(AppTypography.bodyStrong)
                                    .foregroundStyle(AppColors.textPrimary)
                                if !contact.number.isEmpty {
                                    Text(contact.number)
                                        .font(.system(size: 17, weight: .bold, design: .rounded))
                                        .foregroundStyle(contact.color)
                                }
                                Text(contact.description)
                                    .font(AppTypography.caption)
                                    .foregroundStyle(AppColors.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            Spacer()

                            if let url = contact.dialURL {
                                Button {
                                    openURL(url)
                                } label: {
                                    Image(systemName: "phone.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(contact.color)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(callAccessibilityLabel(for: contact.name))
                            }
                        }
                        .padding(AppSpacing.cardPaddingCompact)
                    }
                }

            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .bottomTabSafeAreaPadding()
        }
        .topChromeSafeAreaPadding()
        .appSceneBackground(.support)
        .navigationTitle(L10n.t("more.row.emergency.title", lang))
    }

    private var emergencyContactsHero: some View {
        CategoryHeroVisual(
            assetName: nil,
            title: L10n.t("more.row.emergency.title", lang),
            subtitle: emergencyContactsHeroSubtitle,
            symbol: "phone.badge.waveform.fill",
            badgeText: emergencyContactsHeroBadge,
            accent: AppColors.error,
            asset: ContentMediaRegistry.emergencyImage ?? ContentMediaRegistry.healthcareBasicsImage ?? ContentMediaRegistry.officialSourcesHero,
            height: 220,
            language: lang
        )
        .accessibilityIdentifier("emergencyContacts.hero")
    }

    private var emergencyContactsHeroSubtitle: String {
        switch lang {
        case .russian: return "112, полиция и базовые контакты для срочных ситуаций в Нидерландах."
        case .dutch: return "112, politie en basiscontacten voor spoedsituaties in Nederland."
        case .english: return "112, police, and essential contacts for urgent situations in the Netherlands."
        }
    }

    private var emergencyContactsHeroBadge: String {
        switch lang {
        case .russian: return "Срочная помощь"
        case .dutch: return "Spoedhulp"
        case .english: return "Urgent help"
        }
    }

    private func callAccessibilityLabel(for contactName: String) -> String {
        switch lang {
        case .russian: return "Позвонить: \(contactName)"
        case .dutch: return "Bel \(contactName)"
        case .english: return "Call \(contactName)"
        }
    }
}

// MARK: - Legal Help

struct LegalHelpView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.openURL) private var openURL
    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                PremiumImageHeader(
                    title: L10n.t("more.row.legal.title", lang),
                    asset: ContentMediaRegistry.municipalityCityHallImage ?? ContentMediaRegistry.officialSourcesHero,
                    language: lang,
                    symbol: "building.columns.fill",
                    accent: AppColors.violet,
                    height: 190,
                    cornerRadius: 22,
                    fallbackCategory: .government
                )
                .appCardStyle()

                DisclaimerBanner(text: L10n.t("disclaimer.medium", lang))

                PremiumMenuCard {
                    VStack(spacing: 0) {
                        PremiumMenuRow(
                            icon: "scale.3d",
                            color: AppColors.textSecondary,
                            title: "Juridisch Loket",
                            subtitle: L10n.t("more.legal.loket_detail", lang),
                            trailingSymbol: "info.circle"
                        )
                        Divider().padding(.leading, 70)
                        PremiumMenuRow(
                            icon: "building.columns",
                            color: AppColors.softBlue,
                            title: "Rechtspraak.nl",
                            subtitle: L10n.t("more.legal.courts_detail", lang),
                            trailingSymbol: "info.circle"
                        )
                    }
                }

                Button(L10n.t("more.legal.open_loket", lang)) {
                    guard let url = AppURL.validatedWebURL(URL(string: "https://www.juridischloket.nl")) else { return }
                    openURL(url)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppColors.accent)
                .frame(maxWidth: .infinity)

            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .bottomTabSafeAreaPadding()
        }
        .topChromeSafeAreaPadding()
        .appSceneBackground(.support)
        .navigationTitle(L10n.t("more.row.legal.title", lang))
    }
}

// MARK: - About YouNew

struct AboutYouNewView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    private var lang: AppLanguage { languageManager.appLanguage }
    private var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                aboutHero

                PremiumMenuCard {
                    VStack(spacing: 0) {
                        PremiumMenuRow(
                            icon: "sparkles",
                            color: AppColors.accent,
                            title: "YouNew.nl",
                            subtitle: L10n.t("more.about.detail", lang),
                            trailingSymbol: "info.circle"
                        )
                        Divider().padding(.leading, 70)
                        PremiumMenuRow(
                            icon: "checkmark.shield",
                            color: AppColors.success,
                            title: L10n.t("more.about.important_title", lang),
                            subtitle: L10n.t("more.about.important_detail", lang),
                            trailingSymbol: "checkmark.circle"
                        )
                        Divider().padding(.leading, 70)
                        PremiumMenuRow(
                            icon: "number",
                            color: AppColors.softBlue,
                            title: aboutVersionTitle,
                            subtitle: version,
                            trailingSymbol: "number.circle"
                        )
                        Divider().padding(.leading, 70)
                        PremiumMenuRow(
                            icon: "doc.text.magnifyingglass",
                            color: AppColors.textSecondary,
                            title: aboutSourcesTitle,
                            subtitle: aboutSourcesDetail,
                            trailingSymbol: "doc.text"
                        )
                    }
                }

            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .bottomTabSafeAreaPadding()
        }
        .topChromeSafeAreaPadding()
        .appSceneBackground(.more)
        .navigationTitle(L10n.t("more.row.about.title", lang))
    }

    private var aboutHero: some View {
        CategoryHeroVisual(
            assetName: nil,
            title: "YouNew.nl",
            subtitle: aboutHeroSubtitle,
            symbol: "sparkles.rectangle.stack.fill",
            badgeText: aboutHeroBadge,
            accent: AppColors.cyanGlow,
            asset: ContentMediaRegistry.mapImage ?? ContentMediaRegistry.officialSourcesHero,
            height: 250,
            language: lang
        )
    }

    private var aboutHeroSubtitle: String {
        switch lang {
        case .russian: return "Информационный гид по жизни в Нидерландах."
        case .dutch: return "Informatieve gids voor leven in Nederland."
        case .english: return "An informational guide for life in the Netherlands."
        }
    }

    private var aboutHeroBadge: String {
        switch lang {
        case .russian: return "Нидерланды"
        case .dutch: return "Nederland"
        case .english: return "Netherlands"
        }
    }

    private var aboutVersionTitle: String {
        switch lang {
        case .russian: return "Версия приложения"
        case .dutch: return "Appversie"
        case .english: return "App version"
        }
    }

    private var aboutSourcesTitle: String {
        switch lang {
        case .russian: return "Источники и лицензии"
        case .dutch: return "Bronnen en licenties"
        case .english: return "Sources and licenses"
        }
    }

    private var aboutSourcesDetail: String {
        switch lang {
        case .russian:
            return "YouNew.nl показывает информационные материалы и ссылки на официальные источники. Медиа и сторонние материалы сохраняют свои исходные лицензии."
        case .dutch:
            return "YouNew.nl toont informatieve inhoud en verwijzingen naar officiële bronnen. Media en materiaal van derden behouden hun oorspronkelijke licenties."
        case .english:
            return "YouNew.nl provides informational content and references official sources. Media and third-party materials keep their original licenses."
        }
    }
}

// MARK: - Emotional Support

struct EmotionalSupportView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                emotionalSupportHero

                let items = EmotionalSupportItem.items(lang)
                if items.isEmpty {
                    emptySupportDashboard
                } else {
                    VStack(spacing: AppSpacing.small) {
                        ForEach(items) { item in
                            Link(destination: AppURL.safeWebURL(item.url)) {
                                HStack(alignment: .top, spacing: AppSpacing.medium) {
                                    Image(systemName: item.icon)
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundStyle(.white)
                                        .frame(width: 42, height: 42)
                                        .background(item.color)
                                        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))

                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(item.title)
                                            .font(AppTypography.bodyStrong)
                                            .foregroundStyle(AppColors.textPrimary)
                                        Text(item.detail)
                                            .font(AppTypography.caption)
                                            .foregroundStyle(AppColors.textSecondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                        Text(item.source)
                                            .font(AppTypography.footnote)
                                            .foregroundStyle(AppColors.textTertiary)
                                    }

                                    Spacer(minLength: 8)

                                    Image(systemName: "arrow.up.right.square")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(AppColors.textTertiary)
                                }
                                .appCardStyle()
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                NavigationLink(value: AppDestination.mapFocus(.education)) {
                    InfoCard(title: localSupportTitle, subtitle: localSupportSubtitle, detail: localSupportDetail, icon: "map.fill")
                }
                .buttonStyle(.plain)

                DisclaimerBanner(text: footerNote)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .bottomTabSafeAreaPadding()
        }
        .topChromeSafeAreaPadding()
        .appSceneBackground(.support)
        .navigationTitle(title)
    }

    private var emotionalSupportHero: some View {
        CategoryHeroVisual(
            assetName: nil,
            title: title,
            subtitle: subtitle,
            symbol: "heart.fill",
            badgeText: emotionalSupportHeroBadge,
            accent: AppColors.violet,
            asset: ContentMediaRegistry.healthcareBasicsImage ?? ContentMediaRegistry.profileImage ?? ContentMediaRegistry.emergencyImage ?? ContentMediaRegistry.officialSourcesHero,
            height: 240,
            language: lang
        )
        .accessibilityIdentifier("emotionalSupport.hero")
    }

    private var emptySupportDashboard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            HStack(alignment: .top, spacing: AppSpacing.medium) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(AppColors.warning)
                    .frame(width: 52, height: 52)
                    .background(AppColors.warning.opacity(0.13))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 6) {
                    Text(emptyStateTitle)
                        .font(AppTypography.cardTitle)
                        .foregroundStyle(AppColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(emptyStateDetail)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 170), spacing: 10)], spacing: 10) {
                ForEach(emptySupportActions) { action in
                    NavigationLink(value: action.destination) {
                        EmotionalSupportRecoveryActionCard(action: action)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("emotionalSupport.empty.action.\(action.id)")
                }
            }
        }
        .appCardStyle()
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("emotionalSupport.empty.dashboard")
    }

    private var emptySupportActions: [EmotionalSupportRecoveryAction] {
        [
            EmotionalSupportRecoveryAction(
                id: "map",
                icon: "map.fill",
                title: localSupportTitle,
                subtitle: localSupportSubtitle,
                color: AppColors.emerald,
                destination: .mapFocus(.category(.communitySupport))
            ),
            EmotionalSupportRecoveryAction(
                id: "search",
                icon: "magnifyingglass.circle.fill",
                title: localized(en: "Search help", nl: "Hulp zoeken", ru: "Поиск помощи"),
                subtitle: localized(en: "Find support by topic", nl: "Zoek steun per onderwerp", ru: "Найти поддержку по теме"),
                color: AppColors.dutchOrange,
                destination: .searchList
            ),
            EmotionalSupportRecoveryAction(
                id: "sources",
                icon: "checkmark.shield.fill",
                title: localized(en: "Official sources", nl: "Officiële bronnen", ru: "Официальные источники"),
                subtitle: localized(en: "Use verified public channels", nl: "Gebruik geverifieerde publieke kanalen", ru: "Использовать проверенные публичные каналы"),
                color: AppColors.success,
                destination: .officialSources
            ),
            EmotionalSupportRecoveryAction(
                id: "legal",
                icon: "scalemass.fill",
                title: localized(en: "Legal help", nl: "Juridische hulp", ru: "Юридическая помощь"),
                subtitle: localized(en: "Rights and safety routes", nl: "Rechten en veiligheidsroutes", ru: "Права и маршруты безопасности"),
                color: AppColors.violet,
                destination: .legalHelp
            )
        ]
    }

    private var title: String {
        switch lang {
        case .russian: return "Эмоциональная поддержка"
        case .dutch: return "Emotionele steun"
        case .english: return "Emotional support"
        }
    }

    private var subtitle: String {
        switch lang {
        case .russian: return "Если страшно, непонятно или одиноко: начните с одного безопасного контакта."
        case .dutch: return "Als je bang, verward of alleen bent: begin met één veilig contact."
        case .english: return "If you feel scared, confused, or alone: start with one safe contact."
        }
    }

    private var emotionalSupportHeroBadge: String {
        switch lang {
        case .russian: return "Безопасная поддержка"
        case .dutch: return "Veilige steun"
        case .english: return "Safe support"
        }
    }

    private var localSupportTitle: String {
        switch lang {
        case .russian: return "Найти поддержку рядом"
        case .dutch: return "Steun in de buurt vinden"
        case .english: return "Find support nearby"
        }
    }

    private var localSupportSubtitle: String {
        switch lang {
        case .russian: return "Библиотеки, учебные места и community support"
        case .dutch: return "Bibliotheken, leerplekken en buurtsteun"
        case .english: return "Libraries, learning places, and community support"
        }
    }

    private var localSupportDetail: String {
        switch lang {
        case .russian: return "Откройте карту с мягкими местами помощи: язык, учёба, взрослый контакт, вопросы без стыда."
        case .dutch: return "Open de kaart met laagdrempelige hulp: taal, studie, volwassen contact en vragen zonder schaamte."
        case .english: return "Open the map for low-pressure help: language, study, adult contact, and questions without shame."
        }
    }

    private var emptyStateTitle: String {
        switch lang {
        case .russian: return "Надёжные варианты помощи"
        case .dutch: return "Betrouwbare hulpopties"
        case .english: return "Reliable support options"
        }
    }

    private var emptyStateDetail: String {
        switch lang {
        case .russian: return "Для этой темы используйте проверенные источники, карту помощи рядом и экстренные контакты, если ситуация срочная."
        case .dutch: return "Gebruik voor dit onderwerp betrouwbare bronnen, hulp dichtbij op de kaart en noodcontacten als de situatie dringend is."
        case .english: return "For this topic, use trusted sources, nearby help on the map, and emergency contacts if the situation is urgent."
        }
    }

    private var footerNote: String {
        switch lang {
        case .russian: return "При прямой опасности звоните 112. При мыслях о самоповреждении используйте 113 или местную экстренную помощь."
        case .dutch: return "Bel 112 bij direct gevaar. Bij gedachten aan zelfbeschadiging: gebruik 113 of lokale spoedhulp."
        case .english: return "Call 112 for immediate danger. If self-harm thoughts appear, use 113 or local urgent help."
        }
    }

    private func localized(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .russian: return ru
        case .dutch: return nl
        case .english: return en
        }
    }
}

private struct EmotionalSupportRecoveryAction: Identifiable {
    let id: String
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let destination: AppDestination
}

private struct EmotionalSupportRecoveryActionCard: View {
    let action: EmotionalSupportRecoveryAction

    var body: some View {
        ProductTaskCard(
            title: action.title,
            subtitle: action.subtitle,
            symbol: action.icon,
            accent: action.color,
            minHeight: 104
        )
    }
}

private struct EmotionalSupportItem: Identifiable {
    let id: String
    let title: String
    let detail: String
    let source: String
    let icon: String
    let color: Color
    let url: URL

    static func items(_ lang: AppLanguage) -> [EmotionalSupportItem] {
        [
            item("112", title(lang, "112: прямая опасность", "112: direct gevaar", "112: immediate danger"), detail(lang, "Если сейчас небезопасно или нужна срочная полиция/скорая/пожарные.", "Als het nu onveilig is of politie/ambulance/brandweer spoed nodig is.", "If it is unsafe now or you need urgent police, ambulance, or fire help."), "Government.nl", "phone.fill", AppColors.error, "https://www.government.nl/topics/emergency-number-112"),
            item("kindertelefoon", title(lang, "Kindertelefoon 8–18", "Kindertelefoon 8-18", "Kindertelefoon 8-18"), detail(lang, "Бесплатно и анонимно: можно поговорить или написать в чат, когда трудно.", "Gratis en anoniem bellen of chatten als iets moeilijk voelt.", "Free and anonymous call or chat when something feels hard."), "Kindertelefoon", "message.fill", AppColors.softBlue, "https://www.kindertelefoon.nl"),
            item("nidos-amv", title(lang, "До 18 и без семьи", "Onder 18 zonder familie", "Under 18 without family"), detail(lang, "NIDOS и партнёры помогают с жильём, наставником, школой и социальным развитием для AMV.", "NIDOS en partners helpen AMV met wonen, begeleiding, school en sociale ontwikkeling.", "NIDOS and partners support AMV with housing, mentors, school, and social development."), "RefugeeHelp / NIDOS", "house.and.flag.fill", AppColors.dutchOrange, "https://www.refugeehelp.nl/en/asylum-seeker/article/100515-living-in-the-netherlands-if-you-are-under-18-and-living-without-your-family"),
            item("mindus", title(lang, "MIND Us: молодые люди", "MIND Us: jongeren", "MIND Us: young people"), detail(lang, "Ресурсы и инициативы для психического здоровья молодых людей.", "Initiatieven en bronnen voor mentale gezondheid van jongeren.", "Resources and initiatives for young people's mental health."), "MIND Us", "figure.mind.and.body", AppColors.emerald, "https://mindus.nl"),
            item("113", title(lang, "113: кризисные мысли", "113: crisisgedachten", "113: crisis thoughts"), detail(lang, "Бесплатная помощь 24/7 через 0800-0113 или чат, если появляются мысли о самоповреждении.", "Gratis 24/7 hulp via 0800-0113 of chat bij gedachten aan zelfbeschadiging.", "Free 24/7 help via 0800-0113 or chat if self-harm thoughts appear."), "113 Zelfmoordpreventie", "heart.text.square.fill", AppColors.violet, "https://www.113.nl"),
            item("fraudehelpdesk", title(lang, "Страх из-за сообщения?", "Bang door een bericht?", "Scared by a message?"), detail(lang, "Если письмо/SMS требует срочно платить или дать данные, сначала проверьте мошенничество.", "Als een bericht haast maakt met betalen of gegevens delen, controleer eerst op fraude.", "If a message pressures you to pay or share data, check fraud risk first."), "Fraudehelpdesk", "shield.lefthalf.filled", AppColors.warning, "https://www.fraudehelpdesk.nl")
        ]
    }

    private static func item(_ id: String, _ title: String, _ detail: String, _ source: String, _ icon: String, _ color: Color, _ url: String) -> EmotionalSupportItem {
        EmotionalSupportItem(id: id, title: title, detail: detail, source: source, icon: icon, color: color, url: AppURL.make(url))
    }

    private static func title(_ lang: AppLanguage, _ ru: String, _ nl: String, _ en: String) -> String {
        switch lang {
        case .russian: return ru
        case .dutch: return nl
        case .english: return en
        }
    }

    private static func detail(_ lang: AppLanguage, _ ru: String, _ nl: String, _ en: String) -> String {
        title(lang, ru, nl, en)
    }
}

#if DEBUG && os(iOS)
private struct MoreHubPreviewContainer: View {
    @StateObject private var appState = AppStateViewModel()
    @StateObject private var languageManager: LanguageManager

    init(language: AppLanguage) {
        let manager = LanguageManager()
        manager.appLanguage = language
        _languageManager = StateObject(wrappedValue: manager)
    }

    var body: some View {
        NavigationStack {
            MoreHubView()
        }
        .environmentObject(appState)
        .environmentObject(languageManager)
    }
}

#Preview("More Hub - Premium") {
    MoreHubPreviewContainer(language: .english)
}
#endif
