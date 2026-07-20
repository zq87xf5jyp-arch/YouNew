import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var documentStore: DocumentStore
    @EnvironmentObject private var savedItemsStore: SavedItemsStore
    @State private var showCacheResetAlert = false
    @AppStorage("settings.navigationMenuPosition") private var menuPositionRawValue = NavigationMenuPosition.automatic.rawValue
    @AppStorage("settings.atomicGuideSimplifiedMode") private var atomicGuideSimplifiedMode = false

    private var lang: AppLanguage { languageManager.appLanguage }
    private var activePersona: PersonaTag? { appState.selectedUserStatus?.personaTag }
    private var visibleMapCategories: [PlaceCategory] {
        PlaceCategory.allCases.filter { category in
            MockNearbyPlacesData.places.contains {
                $0.category == category && $0.isVisible(for: activePersona)
            }
        }
    }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 920) {
                VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    settingsHeroSection
                    profileSection
                    languageSection
                    menuSection
                    navigationSection
                    remindersSection
                    mapSection
                    documentSection
                    appSection
                    safetySection
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.xLarge)
                .padding(.bottom, AppSpacing.medium)
                .bottomTabSafeAreaPadding()
            }
        }
        .topChromeSafeAreaPadding()
        .appSceneBackground(.settings)
        .navigationTitle(L10n.t("settings.title", lang))
        .nlNavigationInline()
        .accessibilityIdentifier("settings.screen")
        .onAppear(perform: syncProfileMunicipality)
        .onChange(of: appState.selectedCity) { _, _ in syncProfileMunicipality() }
        .onChange(of: appState.selectedUserStatus) { _, newStatus in
            if let profileType = newStatus?.correspondingProfileType {
                appState.userProfile.profileType = profileType
            }
            if let category = appState.defaultMapCategory,
               !visibleMapCategories.contains(category) {
                appState.defaultMapCategory = nil
            }
        }
        .alert(resetLocalDataTitle, isPresented: $showCacheResetAlert) {
            Button(resetLocalDataTitle, role: .destructive) {
                resetLocalCachedData()
            }
            Button(okButtonTitle, role: .cancel) {}
        } message: {
            Text(resetLocalDataMessage)
        }
    }

    // MARK: - Profile

    private var settingsHeroSection: some View {
        CategoryHeroVisual(
            assetName: nil,
            title: L10n.t("settings.title", lang),
            subtitle: settingsHeroSubtitle,
            symbol: "gearshape.2.fill",
            badgeText: settingsHeroBadge,
            accent: AppColors.softBlue,
            asset: ContentMediaRegistry.profileImage ?? ContentMediaRegistry.savedImage ?? ContentMediaRegistry.officialSourcesHero,
            height: 238,
            language: lang
        )
    }

    private var profileSection: some View {
        settingsGroup(title: L10n.t("settings.section.profile", lang)) {
            HStack(spacing: AppSpacing.medium) {
                GlassVisualBadge(size: 48, cornerRadius: 15, accent: AppColors.accent) {
                    GeneratedCategoryArtwork(symbol: displayedProfileIcon, accent: AppColors.accent)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(displayedProfileName)
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColors.textPrimary)
                    Text("\(L10n.t("profile.municipality", lang)): \(localizedSelectedCity)")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()
            }
            .appCardStyle()

            NavigationLink(value: AppDestination.profileSelection) {
                settingsRow(icon: "pencil", title: L10n.t("settings.edit_profile", lang))
            }
            .buttonStyle(.plain)

            Picker(L10n.t("settings.profile_status", lang), selection: $appState.selectedUserStatus) {
                ForEach(UserStatus.allCases) { status in
                    Text(status.localized(lang)).tag(UserStatus?.some(status))
                }
            }
            .pickerStyle(.menu)
            .appCardStyle()

            Picker(L10n.t("profile.municipality", lang), selection: $appState.selectedCity) {
                ForEach(MockNearbyPlacesData.supportedCities, id: \.self) { city in
                    Text(ProvinceCatalog.localizedCityName(city, lang)).tag(city)
                }
            }
            .pickerStyle(.menu)
            .appCardStyle()
        }
    }

    private var settingsHeroSubtitle: String {
        switch lang {
        case .russian: return "Проверьте язык, профиль, город и локальные настройки приложения."
        case .dutch: return "Controleer taal, profiel, stad en lokale app-instellingen."
        case .english: return "Review language, profile, city, and local app settings."
        }
    }

    private var settingsHeroBadge: String {
        switch lang {
        case .russian: return "Локально"
        case .dutch: return "Lokaal"
        case .english: return "Local"
        }
    }

    private var okButtonTitle: String {
        switch lang {
        case .russian: return "Понятно"
        case .dutch: return "OK"
        case .english: return "OK"
        }
    }

    private var releaseLanguageTitle: String {
        switch lang {
        case .russian: return "Язык интерфейса"
        case .dutch: return "Interfacetaal"
        case .english: return "Interface language"
        }
    }

    private var releaseLanguageDetail: String {
        switch lang {
        case .russian: return "Приоритет релиза: английский, затем нидерландский, затем русский."
        case .dutch: return "Releaseprioriteit: Engels, daarna Nederlands, daarna Russisch."
        case .english: return "Release priority: English first, Dutch second, Russian third."
        }
    }

    // MARK: - Language

    private var languageSection: some View {
        settingsGroup(title: L10n.t("settings.language", lang)) {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                HStack(spacing: AppSpacing.medium) {
                    Image(systemName: "globe")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppColors.accent)
                        .frame(width: 40, height: 40)
                        .background(AppColors.accent.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small, style: .continuous))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(releaseLanguageTitle)
                            .font(AppTypography.bodyStrong)
                            .foregroundStyle(AppColors.textPrimary)
                        Text(releaseLanguageDetail)
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()
                }

                Picker(releaseLanguageTitle, selection: languageBinding) {
                    ForEach(AppLanguage.releasePriority) { language in
                        Text(languageDisplayTitle(language, in: lang)).tag(language)
                    }
                }
                .pickerStyle(.segmented)
            }
            .appCardStyle()
        }
    }

    private var languageBinding: Binding<AppLanguage> {
        Binding(
            get: { languageManager.appLanguage },
            set: { languageManager.appLanguage = $0 }
        )
    }

    private var menuSection: some View {
        settingsGroup(title: menuSectionTitle) {
            Picker(menuPositionTitle, selection: $menuPositionRawValue) {
                ForEach(NavigationMenuPosition.allCases) { position in
                    Text(position.localized(lang)).tag(position.rawValue)
                }
            }
            .pickerStyle(.menu)
            .appCardStyle()

            InfoCard(
                title: menuHintTitle,
                subtitle: menuHintSubtitle,
                detail: menuHintDetail,
                icon: "rectangle.3.group.bubble.left.fill"
            )

            Toggle(isOn: $atomicGuideSimplifiedMode) {
                HStack(spacing: AppSpacing.medium) {
                    Image(systemName: "list.bullet.rectangle.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.accent)
                        .frame(width: 40, height: 40)
                        .background(AppColors.accent.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small, style: .continuous))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(simplifiedAtomTitle)
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.textPrimary)
                        Text(simplifiedAtomSubtitle)
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }
            .tint(AppColors.accent)
            .appCardStyle()
        }
    }

    private func languageDisplayTitle(_ language: AppLanguage, in displayLanguage: AppLanguage) -> String {
        switch displayLanguage {
        case .english:
            switch language {
            case .english: return "English"
            case .dutch: return "Dutch"
            case .russian: return "Russian"
            }
        case .dutch:
            switch language {
            case .english: return "Engels"
            case .dutch: return "Nederlands"
            case .russian: return "Russisch"
            }
        case .russian:
            switch language {
            case .english: return "Английский"
            case .dutch: return "Нидерландский"
            case .russian: return "Русский"
            }
        }
    }

    private var navigationSection: some View {
        settingsGroup(title: L10n.t("settings.section.navigation", lang)) {
            NavigationLink(value: AppDestination.checklistList) {
                settingsRow(icon: "list.bullet.rectangle", title: L10n.t("settings.nav.recommended_steps", lang))
            }
            .buttonStyle(.plain)

            NavigationLink(value: AppDestination.savedTopics) {
                settingsRow(icon: "bookmark.fill", title: L10n.t("settings.nav.saved_topics", lang))
            }
            .buttonStyle(.plain)

            NavigationLink(value: AppDestination.recentlyViewedTopics) {
                settingsRow(icon: "clock.arrow.circlepath", title: L10n.t("settings.nav.recently_viewed", lang))
            }
            .buttonStyle(.plain)
        }
    }

    private var menuSectionTitle: String {
        switch lang {
        case .russian: return "Меню"
        case .dutch: return "Menu"
        case .english: return "Menu"
        }
    }

    private var menuPositionTitle: String {
        switch lang {
        case .russian: return "Положение меню"
        case .dutch: return "Menupositie"
        case .english: return "Menu position"
        }
    }

    private var menuHintTitle: String {
        switch lang {
        case .russian: return "Подстройте навигацию под себя"
        case .dutch: return "Pas navigatie aan jezelf aan"
        case .english: return "Adjust navigation to you"
        }
    }

    private var menuHintSubtitle: String {
        switch lang {
        case .russian: return "Снизу, сверху, слева или справа"
        case .dutch: return "Onder, boven, links of rechts"
        case .english: return "Bottom, top, left, or right"
        }
    }

    private var menuHintDetail: String {
        switch lang {
        case .russian: return "Автоматический режим оставляет меню снизу на iPhone и слева на широком экране."
        case .dutch: return "Automatisch zet het menu onder op iPhone en links op een breed scherm."
        case .english: return "Automatic keeps the menu at the bottom on iPhone and on the left on wide screens."
        }
    }

    private var simplifiedAtomTitle: String {
        switch lang {
        case .russian: return "Упростить атомный путь"
        case .dutch: return "Atoomroute vereenvoudigen"
        case .english: return "Simplify atomic path"
        }
    }

    private var simplifiedAtomSubtitle: String {
        switch lang {
        case .russian: return "Показывать шаги списком вместо орбит."
        case .dutch: return "Toon stappen als lijst in plaats van banen."
        case .english: return "Show steps as a list instead of orbits."
        }
    }

    // MARK: - Reminders

    private var remindersSection: some View {
        settingsGroup(title: L10n.t("settings.section.reminders", lang)) {
            Toggle(isOn: $appState.userProfile.remindersEnabled) {
                HStack(spacing: AppSpacing.medium) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.accent)
                        .frame(width: 40, height: 40)
                        .background(AppColors.accent.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small, style: .continuous))

                    Text(L10n.t("settings.local_reminders", lang))
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textPrimary)
                }
            }
            .tint(AppColors.accent)
            .appCardStyle()

            InfoCard(
                title: L10n.t("settings.reminders.important_steps", lang),
                subtitle: L10n.t("settings.reminders.active", lang),
                detail: L10n.t("settings.reminders.local_detail", lang),
                icon: "bell.badge"
            )
        }
    }

    private var mapSection: some View {
        settingsGroup(title: L10n.t("tab.map", lang)) {
            Picker(L10n.t("settings.map.default_city", lang), selection: $appState.selectedCity) {
                ForEach(MockNearbyPlacesData.supportedCities, id: \.self) { city in
                    Text(ProvinceCatalog.localizedCityName(city, lang)).tag(city)
                }
            }
            .pickerStyle(.menu)
            .appCardStyle()

            Picker(L10n.t("settings.map.default_category", lang), selection: $appState.defaultMapCategory) {
                Text(L10n.t("common.all", lang)).tag(PlaceCategory?.none)
                ForEach(visibleMapCategories) { category in
                    Text(category.localized(lang)).tag(PlaceCategory?.some(category))
                }
            }
            .pickerStyle(.menu)
            .appCardStyle()

            Toggle(isOn: $appState.useCurrentLocationForMap) {
                Text(L10n.t("settings.map.use_location", lang))
            }
            .tint(AppColors.accent)
            .appCardStyle()

            NavigationLink(value: AppDestination.mapHub) {
                settingsRow(icon: "map.fill", title: L10n.t("settings.map.open_map", lang))
            }
            .buttonStyle(.plain)
        }
    }

    

    private var documentSection: some View {
        settingsGroup(title: L10n.t("settings.section.documents", lang)) {
            NavigationLink(value: AppDestination.journeyDocuments) {
                settingsRow(icon: "doc.on.doc", title: L10n.t("settings.documents.center", lang))
            }
            .buttonStyle(.plain)

            Text(L10n.t("settings.documents.stored_on_device", lang))
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .appCardStyle()

            Button(role: .destructive) {
                documentStore.clearAllDocuments()
            } label: {
                settingsRow(icon: "trash", title: L10n.t("settings.documents.clear_cache", lang))
            }
            .buttonStyle(.plain)

            Text(L10n.t("settings.documents.export_coming", lang))
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .appCardStyle()
        }
    }
// MARK: - App

    private var appSection: some View {
        settingsGroup(title: L10n.t("settings.section.app", lang)) {
            NavigationLink(value: AppDestination.aboutYouNew) {
                settingsRow(icon: "info.circle.fill", title: L10n.t("settings.about", lang))
            }
            .buttonStyle(.plain)

            NavigationLink(value: AppDestination.officialSources) {
                settingsRow(icon: "checkmark.shield.fill", title: L10n.t("settings.sources", lang))
            }
            .buttonStyle(.plain)

            Link(destination: AppPublicLinks.website) {
                settingsRow(icon: "globe", title: publicWebsiteTitle)
            }
            .buttonStyle(.plain)

            NavigationLink(value: AppDestination.privacyDataControl) {
                settingsRow(icon: "lock.shield.fill", title: privacyDataControlTitle)
            }
            .buttonStyle(.plain)

            Link(destination: AppPublicLinks.privacyPolicy) {
                settingsRow(icon: "hand.raised.fill", title: publicPrivacyTitle)
            }
            .buttonStyle(.plain)

            NavigationLink(value: AppDestination.termsOfUse) {
                settingsRow(icon: "doc.text.fill", title: termsTitle)
            }
            .buttonStyle(.plain)

            Link(destination: AppPublicLinks.termsOfUse) {
                settingsRow(icon: "safari.fill", title: publicTermsTitle)
            }
            .buttonStyle(.plain)

            NavigationLink(value: AppDestination.legalDisclaimer) {
                settingsRow(icon: "scalemass.fill", title: legalDisclaimerTitle)
            }
            .buttonStyle(.plain)

            NavigationLink(value: AppDestination.supportFeedback) {
                settingsRow(icon: "lifepreserver.fill", title: supportFeedbackTitle)
            }
            .buttonStyle(.plain)

            Link(destination: AppPublicLinks.support) {
                settingsRow(icon: "questionmark.circle.fill", title: publicSupportTitle)
            }
            .buttonStyle(.plain)

            Button(role: .destructive) {
                showCacheResetAlert = true
            } label: {
                settingsRow(icon: "arrow.clockwise.circle.fill", title: resetLocalDataTitle)
            }
            .buttonStyle(.plain)

            NavigationLink(value: AppDestination.supportFeedback) {
                settingsRow(icon: "exclamationmark.bubble.fill", title: L10n.t("settings.report_issue", lang))
            }
            .buttonStyle(.plain)

            HStack(spacing: AppSpacing.medium) {
                Image(systemName: "number")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(width: 40, height: 40)
                    .background(AppColors.textSecondary.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small, style: .continuous))

                Text(L10n.t("settings.version", lang))
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                Text("0.2.1")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .appCardStyle()
        }
    }

    // MARK: - Safety

    private var safetySection: some View {
        settingsGroup(title: L10n.t("settings.section.safety", lang)) {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                safetyRow(icon: "building.columns", text: L10n.t("settings.safety.not_affiliated", lang))
                Divider().background(AppColors.stroke)
                safetyRow(icon: "scalemass", text: L10n.t("settings.safety.not_legal", lang))
                Divider().background(AppColors.stroke)
                safetyRow(icon: "checkmark.shield", text: L10n.t("settings.safety.verify_official", lang))
            }
            .appCardStyle()
        }
    }

    private func resetLocalCachedData() {
        AppDataMigration.resetLocalCachedData()
        savedItemsStore.clearCachedSavedItemsForSchemaMigration()
        appState.recentlyViewedTopics = []
        appState.showToast(resetLocalDataToast)
    }

    private var localizedSelectedCity: String {
        ProvinceCatalog.localizedCityName(appState.selectedCity, lang)
    }

    private var displayedProfileName: String {
        appState.selectedUserStatus?.localized(lang) ?? appState.userProfile.profileType.localized(lang)
    }

    private var displayedProfileIcon: String {
        appState.selectedUserStatus?.icon ?? appState.userProfile.profileType.icon
    }

    private func syncProfileMunicipality() {
        if appState.userProfile.municipality != appState.selectedCity {
            appState.userProfile.municipality = appState.selectedCity
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func settingsGroup<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text(title.uppercased())
                .font(AppTypography.metadata)
                .tracking(0.5)
                .foregroundStyle(AppColors.textTertiary)
                .padding(.horizontal, 4)

            VStack(spacing: AppSpacing.xSmall) {
                content()
            }
        }
    }

    private func settingsRow(icon: String, title: String) -> some View {
        HStack(spacing: AppSpacing.medium) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColors.accent)
                .frame(width: 40, height: 40)
                .background(AppColors.accent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small, style: .continuous))

            Text(title)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textPrimary)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(AppColors.textTertiary)
        }
        .appCardStyle()
        .contentShape(Rectangle())
    }

    private func safetyRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.small) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppColors.textTertiary)
                .frame(width: 20, alignment: .center)
                .padding(.top, 1)

            Text(text)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var privacyDataControlTitle: String {
        switch lang {
        case .russian: return "Приватность и данные"
        case .english: return "Privacy and data"
        case .dutch: return "Privacy en gegevensbeheer"
        }
    }

    private var publicWebsiteTitle: String {
        switch lang {
        case .russian: return "Сайт YouNew.nl"
        case .english: return "YouNew.nl website"
        case .dutch: return "YouNew.nl website"
        }
    }

    private var publicPrivacyTitle: String {
        switch lang {
        case .russian: return "Публичная Privacy Policy"
        case .english: return "Public Privacy Policy"
        case .dutch: return "Openbaar privacybeleid"
        }
    }

    private var publicTermsTitle: String {
        switch lang {
        case .russian: return "Публичные условия"
        case .english: return "Public Terms of Use"
        case .dutch: return "Openbare gebruiksvoorwaarden"
        }
    }

    private var publicSupportTitle: String {
        switch lang {
        case .russian: return "Сайт поддержки"
        case .english: return "Support website"
        case .dutch: return "Supportwebsite"
        }
    }

    private var legalDisclaimerTitle: String {
        switch lang {
        case .russian: return "Юридический дисклеймер"
        case .english: return "Legal Disclaimer"
        case .dutch: return "Juridische disclaimer"
        }
    }

    private var termsTitle: String {
        switch lang {
        case .russian: return "Условия использования"
        case .english: return "Terms of Use"
        case .dutch: return "Gebruiksvoorwaarden"
        }
    }

    private var supportFeedbackTitle: String {
        switch lang {
        case .russian: return "Поддержка и отзыв"
        case .english: return "Support & Feedback"
        case .dutch: return "Support en feedback"
        }
    }

    private var resetLocalDataTitle: String {
        switch lang {
        case .russian: return "Сбросить локальные данные"
        case .english: return "Reset local data"
        case .dutch: return "Lokale gegevens resetten"
        }
    }

    private var resetLocalDataMessage: String {
        switch lang {
        case .russian: return "Будут очищены локальные кэши, история поиска, недавние переводы, разговор ассистента и устаревшие сохранённые подписи. Язык и профиль сохранятся."
        case .english: return "This clears local caches, search history, recent translations, assistant conversation, and outdated saved labels. Language and profile stay unchanged."
        case .dutch: return "Dit wist lokale caches, zoekgeschiedenis, recente vertalingen, assistentgesprek en verouderde opgeslagen labels. Taal en profiel blijven behouden."
        }
    }

    private var resetLocalDataToast: String {
        switch lang {
        case .russian: return "Локальные данные сброшены"
        case .english: return "Local data reset"
        case .dutch: return "Lokale gegevens gereset"
        }
    }
}

struct SavedTopicsView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var savedItemsStore: SavedItemsStore
    private var lang: AppLanguage { languageManager.appLanguage }
    private var visibleSavedItems: [SavedItemsStore.SavedItem] {
        let persona = appState.selectedUserStatus?.personaTag
        return savedItemsStore.savedItems.filter { item in
            guard let destination = item.destination else { return false }
            return RelatedContentEngine.isVisible(destination, for: persona)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                savedTopicsHero

                if visibleSavedItems.isEmpty {
                    settingsEmptyState(
                        title: L10n.t("empty.no_saved_items", lang),
                        detail: savedTopicsEmptyDetail,
                        icon: "bookmark",
                        actions: [
                            SettingsEmptyAction(id: "resources", title: L10n.t("resources.title", lang), icon: "books.vertical.fill", destination: .resourcesHub),
                            SettingsEmptyAction(id: "search", title: L10n.t("tab.search", lang), icon: "magnifyingglass", destination: .searchList),
                            SettingsEmptyAction(id: "sources", title: L10n.t("settings.sources", lang), icon: "checkmark.shield.fill", destination: .officialSources)
                        ]
                    )
                } else {
                    ForEach(visibleSavedItems) { item in
                        if let destination = item.destination {
                            NavigationLink(value: destination) {
                                savedTopicRow(item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
        }
        .navigationTitle(L10n.t("settings.nav.saved_topics", lang))
    }

    private var savedTopicsHero: some View {
        CategoryHeroVisual(
            assetName: nil,
            title: L10n.t("settings.nav.saved_topics", lang),
            subtitle: savedTopicsHeroSubtitle,
            symbol: "bookmark.fill",
            badgeText: savedTopicsHeroBadge,
            accent: AppColors.dutchOrange,
            asset: ContentMediaRegistry.savedImage ?? ContentMediaRegistry.officialSourcesHero,
            height: 220,
            language: lang
        )
        .accessibilityIdentifier("settings.savedTopics.hero")
    }

    private func savedTopicRow(_ item: SavedItemsStore.SavedItem) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.displayTitle(lang))
                .font(AppTypography.bodyStrong)
                .foregroundStyle(AppColors.textPrimary)
            if let subtitle = item.displaySubtitle(lang),
               !subtitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(subtitle)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardStyle()
    }

    private var savedTopicsEmptyDetail: String {
        switch lang {
        case .russian: return "Откройте ресурсы, поиск или официальные источники и сохраните важные карточки для быстрого доступа."
        case .english: return "Open Resources, Search, or Official Sources and bookmark useful cards for quick access."
        case .dutch: return "Open Bronnen, Zoeken of Officiële bronnen en bewaar nuttige kaarten voor snelle toegang."
        }
    }

    private var savedTopicsHeroSubtitle: String {
        switch lang {
        case .russian: return "Соберите важные карточки, документы, места и источники в одном спокойном месте."
        case .english: return "Keep important cards, documents, places, and sources in one calm place."
        case .dutch: return "Bewaar belangrijke kaarten, documenten, plekken en bronnen op een rustige plek."
        }
    }

    private var savedTopicsHeroBadge: String {
        switch lang {
        case .russian: return "Быстрый доступ"
        case .english: return "Quick access"
        case .dutch: return "Snelle toegang"
        }
    }
}

struct RecentlyViewedTopicsView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    private var lang: AppLanguage { languageManager.appLanguage }
    private var visibleRouteIDs: [String] {
        appState.visibleRecentRouteIDs().filter { $0 != "recentlyViewedTopics" }
    }
    private var visibleLegacyTopics: [String] { appState.visibleRecentlyViewedTopics() }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                recentlyViewedHero

                if visibleRouteIDs.isEmpty && visibleLegacyTopics.isEmpty {
                    settingsEmptyState(
                        title: L10n.t("settings.recent.empty", lang),
                        detail: recentlyViewedEmptyDetail,
                        icon: "clock",
                        actions: [
                            SettingsEmptyAction(id: "checklist", title: L10n.t("settings.nav.recommended_steps", lang), icon: "checklist", destination: .checklistList),
                            SettingsEmptyAction(id: "search", title: L10n.t("tab.search", lang), icon: "magnifyingglass", destination: .searchList),
                            SettingsEmptyAction(id: "map", title: L10n.t("tab.map", lang), icon: "map.fill", destination: .mapHub)
                        ]
                    )
                } else {
                    ForEach(visibleRouteIDs, id: \.self) { routeID in
                        if let destination = AppNavigationResolver.destination(for: routeID, visibleFor: appState.selectedUserStatus?.personaTag) {
                            NavigationLink(value: destination) {
                                recentTopicRow(title: recentRouteTitle(destination, fallback: routeID), subtitle: recentRouteSubtitle(for: routeID))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    ForEach(visibleLegacyTopics, id: \.self) { topic in
                        let title = appState.displayTitle(forRecentlyViewedTopic: topic, language: lang)
                        if let destination = legacyDestination(for: topic) {
                            NavigationLink(value: destination) {
                                recentTopicRow(title: title, subtitle: nil)
                            }
                            .buttonStyle(.plain)
                        } else {
                            recentTopicRow(title: title, subtitle: nil)
                        }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
        }
        .navigationTitle(L10n.t("settings.nav.recently_viewed", lang))
    }

    private var recentlyViewedHero: some View {
        CategoryHeroVisual(
            assetName: nil,
            title: L10n.t("settings.nav.recently_viewed", lang),
            subtitle: recentlyViewedHeroSubtitle,
            symbol: "clock.arrow.circlepath",
            badgeText: recentlyViewedHeroBadge,
            accent: AppColors.accent,
            asset: ContentMediaRegistry.searchImage ?? ContentMediaRegistry.mapImage ?? ContentMediaRegistry.officialSourcesHero,
            height: 220,
            language: lang
        )
        .accessibilityIdentifier("settings.recentlyViewed.hero")
    }

    private func legacyDestination(for topic: String) -> AppDestination? {
        if let idText = topic.removingSettingsPrefix("searchAnswer::"),
           let id = UUID(uuidString: idText),
           MockSearchAnswersData.items.contains(where: { $0.id == id }) {
            return .searchAnswer(id)
        }
        if let idText = topic.removingSettingsPrefix("checklist::"),
           let id = UUID(uuidString: idText),
           appState.checklistItems.contains(where: { $0.id == id }) {
            return .checklist(id)
        }
        if let place = MockNearbyPlacesData.places.first(where: {
            $0.name == topic && $0.isVisible(for: appState.selectedUserStatus?.personaTag)
        }) {
            return .mapFocus(.place(place.saveKey))
        }
        return nil
    }

    private func recentRouteTitle(_ destination: AppDestination, fallback: String) -> String {
        switch destination {
        case .checklistList:
            return L10n.t("settings.nav.recommended_steps", lang)
        case .searchList:
            return L10n.t("tab.search", lang)
        case .mapHub:
            return L10n.t("tab.map", lang)
        case .assistantHub:
            return L10n.t("tab.ai", lang)
        case .settings:
            return L10n.t("settings.title", lang)
        case .officialSources:
            return L10n.t("settings.sources", lang)
        case .aboutYouNew:
            return L10n.t("settings.about", lang)
        case .supportFeedback:
            return supportFeedbackTitle
        default:
            return fallback
                .replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression)
                .capitalized
        }
    }

    private func recentRouteSubtitle(for routeID: String) -> String? {
        routeID.contains(":") ? routeID : nil
    }

    private var supportFeedbackTitle: String {
        switch lang {
        case .russian: return "Поддержка и обратная связь"
        case .english: return "Support & Feedback"
        case .dutch: return "Support en feedback"
        }
    }

    private var recentlyViewedEmptyDetail: String {
        switch lang {
        case .russian: return "Откройте чек-лист, поиск или карту, чтобы быстро вернуться к полезным разделам позже."
        case .english: return "Open the checklist, search, or map to make useful sections easy to revisit."
        case .dutch: return "Open de checklist, zoekfunctie of kaart om nuttige onderdelen makkelijk terug te vinden."
        }
    }

    private var recentlyViewedHeroSubtitle: String {
        switch lang {
        case .russian: return "Быстро возвращайтесь к темам, которые вы уже открывали."
        case .english: return "Return quickly to topics you have already opened."
        case .dutch: return "Ga snel terug naar onderwerpen die u al hebt geopend."
        }
    }

    private var recentlyViewedHeroBadge: String {
        switch lang {
        case .russian: return "История"
        case .english: return "History"
        case .dutch: return "Geschiedenis"
        }
    }

    private func recentTopicRow(title: String, subtitle: String?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(AppTypography.bodyStrong)
                .foregroundStyle(AppColors.textPrimary)
            if let subtitle,
               !subtitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(subtitle)
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.textTertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardStyle()
    }
}

private struct SettingsEmptyAction: Identifiable {
    let id: String
    let title: String
    let icon: String
    let destination: AppDestination
}

private func settingsEmptyState(
    title: String,
    detail: String,
    icon: String,
    actions: [SettingsEmptyAction]
) -> some View {
    VStack(alignment: .leading, spacing: AppSpacing.medium) {
        InfoCard(title: title, subtitle: nil, detail: detail, icon: icon)

        LazyVGrid(columns: DetailPageLayout.twoColumnWhenPossible(for: 420, minimumColumnWidth: 220), spacing: AppSpacing.small) {
            ForEach(actions) { action in
                NavigationLink(value: action.destination) {
                    HStack(spacing: AppSpacing.small) {
                        Image(systemName: action.icon)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(AppColors.accentLight)
                            .frame(width: 34, height: 34)
                            .background(AppColors.accentLight.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))

                        Text(action.title)
                            .font(AppTypography.bodyStrong)
                            .foregroundStyle(AppColors.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.82)

                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity, minHeight: 62, alignment: .leading)
                    .appGlassCardStyle(accent: AppColors.accentLight)
                }
                .buttonStyle(AppPressableCardButtonStyle())
                .accessibilityIdentifier("settings.empty.action.\(action.id)")
            }
        }
    }
    .accessibilityIdentifier("settings.empty.state")
}

private extension String {
    func removingSettingsPrefix(_ prefix: String) -> String? {
        guard hasPrefix(prefix) else { return nil }
        return String(dropFirst(prefix.count))
    }
}
