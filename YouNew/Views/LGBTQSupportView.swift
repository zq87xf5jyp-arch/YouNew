import SwiftUI

struct LGBTQSupportView: View {
    @StateObject private var viewModel = LGBTQSupportViewModel()
    @ObservedObject private var savedStore = SavedItemsStore.shared
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.openURL) private var openURL
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                hero
                disclaimer

                switch viewModel.state {
                case .loading:
                    skeletonSection
                case .failed(let message):
                    errorState(message)
                case .empty:
                    supportEmptyDashboard(
                        title: L10n.t("lgbtq.empty.title", lang),
                        subtitle: L10n.t("lgbtq.empty.subtitle", lang),
                        showsRetry: true,
                        showsReset: false
                    )
                case .loaded:
                    filters
                    if viewModel.filteredItems.isEmpty {
                        supportEmptyDashboard(
                            title: L10n.t("lgbtq.no_results.title", lang),
                            subtitle: L10n.t("lgbtq.no_results.subtitle", lang),
                            showsRetry: false,
                            showsReset: true
                        )
                    } else {
                        sections
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .tabBarScrollReserve()
        }
        .appSceneBackground()
        .navigationTitle(L10n.t("lgbtq.title", lang))
        .task {
            viewModel.activePersona = appState.selectedUserStatus?.personaTag
            await viewModel.load()
        }
        .onChange(of: appState.selectedUserStatus) { _, status in
            viewModel.activePersona = status?.personaTag
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            CategoryHeroVisual(
                assetName: nil,
                title: L10n.t("lgbtq.title", lang),
                subtitle: L10n.t("lgbtq.subtitle", lang),
                symbol: "heart.text.square.fill",
                badgeText: supportBadgeText,
                accent: AppColors.violet,
                asset: ContentMediaRegistry.healthcareBasicsImage ?? ContentMediaRegistry.profileImage ?? ContentMediaRegistry.officialSourcesHero,
                height: 238,
                language: lang
            )

            HStack(spacing: 8) {
                tag(L10n.t("lgbtq.tag.no_tracking", lang), color: AppColors.success)
                tag(L10n.t("lgbtq.tag.info_only", lang), color: AppColors.softBlue)
            }
            .padding(.horizontal, 2)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(L10n.t("lgbtq.title", lang)). \(L10n.t("lgbtq.subtitle", lang))")
    }

    private var supportBadgeText: String {
        switch lang {
        case .russian: return "Поддержка"
        case .dutch: return "Ondersteuning"
        case .english: return "Support"
        }
    }

    private var disclaimer: some View {
        InfoCard(
            title: L10n.t("lgbtq.disclaimer.title", lang),
            subtitle: nil,
            detail: L10n.t("lgbtq.disclaimer.body", lang),
            icon: "shield.checkered",
            accentColor: AppColors.warning
        )
    }

    private var filters: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(AppColors.textSecondary)
                TextField(L10n.t("lgbtq.search.placeholder", lang), text: $viewModel.searchText)
                    .youNewTextInputAutocapitalizationNever()
                    .disableAutocorrection(true)
                    .accessibilityLabel(L10n.t("lgbtq.search.accessibility", lang))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous)
                    .stroke(AppColors.stroke.opacity(0.8), lineWidth: 0.8)
            }

            horizontalFilter(title: L10n.t("lgbtq.filter.section", lang)) {
                filterChip(title: L10n.t("common.all", lang), isSelected: viewModel.selectedSection == nil) {
                    viewModel.selectedSection = nil
                    viewModel.selectedCategory = nil
                }
                ForEach(LGBTQSupportSection.allCases) { section in
                    filterChip(title: section.title(lang), isSelected: viewModel.selectedSection == section) {
                        viewModel.selectedSection = section
                        viewModel.selectedCategory = nil
                    }
                }
            }

            horizontalFilter(title: L10n.t("lgbtq.filter.city", lang)) {
                ForEach(viewModel.cities, id: \.self) { city in
                    filterChip(title: city == "All" ? L10n.t("common.all", lang) : city, isSelected: viewModel.selectedCity == city) {
                        viewModel.selectedCity = city
                        viewModel.selectedCategory = nil
                    }
                }
            }

            if !viewModel.visibleCategories.isEmpty {
                horizontalFilter(title: L10n.t("lgbtq.filter.category", lang)) {
                    filterChip(title: L10n.t("common.all", lang), isSelected: viewModel.selectedCategory == nil) {
                        viewModel.selectedCategory = nil
                    }
                    ForEach(viewModel.visibleCategories) { category in
                        filterChip(title: category.title(lang), isSelected: viewModel.selectedCategory == category) {
                            viewModel.selectedCategory = category
                        }
                    }
                }
            }
        }
    }

    private var sections: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
            ForEach(LGBTQSupportSection.allCases) { section in
                let items = viewModel.filteredItems.filter { $0.section == section }
                if !items.isEmpty {
                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        SectionHeader(title: section.title(lang))
                        ForEach(items) { item in
                            supportItemCard(item)
                        }
                    }
                }
            }
        }
    }

    private func supportItemCard(_ item: LGBTQSupportItem) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            ProductTaskCard(
                title: item.title,
                subtitle: item.description(lang),
                symbol: item.section.symbol,
                accent: AppColors.violet,
                priority: item.isTrusted ? L10n.t("lgbtq.trusted", lang) : item.category.title(lang),
                minHeight: 112
            )

            ProductInfoBlock(
                title: item.category.title(lang),
                bodyText: supportMetadataText(for: item),
                symbol: "mappin.and.ellipse",
                accent: AppColors.softBlue
            )

            if !item.accessibilityTags.isEmpty {
                FlexibleTagLayout(items: item.accessibilityTags) { tag in
                    Text(tag)
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.textSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(AppColors.chipBackground)
                        .clipShape(Capsule())
                }
            }

            HStack(spacing: AppSpacing.small) {
                if item.websiteURL != nil {
                    Button(action: { openWebsite(item) }) {
                        ProductCTA(title: L10n.t("common.website", lang), symbol: "safari", accent: AppColors.accent)
                    }
                    .buttonStyle(.plain)
                }

                if item.mapsQuery != nil {
                    Button(action: { openMaps(item) }) {
                        ProductCTA(title: L10n.t("common.maps", lang), symbol: "map", accent: AppColors.accent)
                    }
                    .buttonStyle(.plain)
                }

                Button(action: { toggleSave(item) }) {
                    ProductCTA(
                        title: savedStore.isSaved(item.saveKey) ? L10n.t("common.remove_saved", lang) : L10n.t("common.save", lang),
                        symbol: savedStore.isSaved(item.saveKey) ? "bookmark.fill" : "bookmark",
                        accent: savedStore.isSaved(item.saveKey) ? AppColors.accent : AppColors.textSecondary
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title), \(item.city), \(item.category.title(lang))")
    }

    private func supportMetadataText(for item: LGBTQSupportItem) -> String {
        var lines = [item.city]
        if let transit = item.publicTransportInfo(lang) {
            lines.append(transit)
        }
        if let hours = item.openingHours(lang) {
            lines.append(hours)
        }
        if let date = item.dateText(lang) {
            lines.append(date)
        }
        if let organizer = item.organizer {
            lines.append(organizer)
        }
        return lines.joined(separator: "\n")
    }

    private var skeletonSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            ForEach(0..<4, id: \.self) { _ in
                NLGlassCard {
                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        RoundedRectangle(cornerRadius: 6).fill(AppColors.stroke).frame(height: 16)
                        RoundedRectangle(cornerRadius: 6).fill(AppColors.stroke).frame(height: 48)
                        RoundedRectangle(cornerRadius: 6).fill(AppColors.stroke).frame(width: 180, height: 14)
                    }
                }
                .redacted(reason: .placeholder)
            }
        }
        .accessibilityLabel(L10n.t("lgbtq.loading", lang))
    }

    private func supportEmptyDashboard(title: String, subtitle: String, showsRetry: Bool, showsReset: Bool) -> some View {
        NLGlassCard {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                HStack(alignment: .top, spacing: AppSpacing.medium) {
                    GradientIconBadge(symbol: "heart.text.square.fill", color: AppColors.violet, size: 48, cornerRadius: 14)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(title)
                            .font(AppTypography.cardTitle)
                            .foregroundStyle(AppColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(subtitle)
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                if showsRetry || showsReset {
                    HStack(spacing: AppSpacing.small) {
                        if showsRetry {
                            Button {
                                Task { await viewModel.load() }
                            } label: {
                                Label(retryTitle, systemImage: "arrow.clockwise")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(AppColors.accent)
                            .accessibilityIdentifier("lgbtq.empty.retry")
                        }

                        if showsReset {
                            Button {
                                withAnimation(reduceMotion ? nil : AppAnimations.softSpring) {
                                    viewModel.resetFilters()
                                }
                            } label: {
                                Label(L10n.t("lgbtq.reset_filters", lang), systemImage: "line.3.horizontal.decrease.circle")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(AppColors.accent)
                            .accessibilityIdentifier("lgbtq.empty.reset")
                        }
                    }
                    .font(AppTypography.bodyStrong)
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 168), spacing: 10)], spacing: 10) {
                    ForEach(supportRecoveryActions) { action in
                        NavigationLink(value: action.destination) {
                            LGBTQRecoveryActionCard(action: action)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("lgbtq.empty.action.\(action.id)")
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("lgbtq.empty.dashboard")
    }

    private var supportRecoveryActions: [LGBTQRecoveryAction] {
        [
            LGBTQRecoveryAction(
                id: "map",
                icon: "map.fill",
                title: localized(en: "Nearby support", nl: "Steun in de buurt", ru: "Поддержка рядом"),
                subtitle: localized(en: "Open LGBTQ places on the map", nl: "Open LGBTQ-plekken op de kaart", ru: "Открыть LGBTQ-места на карте"),
                color: AppColors.violet,
                destination: .mapFocus(.category(.lgbtqSupport))
            ),
            LGBTQRecoveryAction(
                id: "legal",
                icon: "scalemass.fill",
                title: localized(en: "Legal help", nl: "Juridische hulp", ru: "Юридическая помощь"),
                subtitle: localized(en: "Rights, safety, discrimination", nl: "Rechten, veiligheid, discriminatie", ru: "Права, безопасность, дискриминация"),
                color: AppColors.softBlue,
                destination: .legalHelp
            ),
            LGBTQRecoveryAction(
                id: "sources",
                icon: "checkmark.shield.fill",
                title: localized(en: "Official sources", nl: "Officiële bronnen", ru: "Официальные источники"),
                subtitle: localized(en: "Verify trusted channels", nl: "Controleer betrouwbare kanalen", ru: "Проверить надёжные каналы"),
                color: AppColors.success,
                destination: .officialSources
            ),
            LGBTQRecoveryAction(
                id: "search",
                icon: "magnifyingglass.circle.fill",
                title: localized(en: "Search help", nl: "Hulp zoeken", ru: "Поиск помощи"),
                subtitle: localized(en: "Try broader words", nl: "Probeer bredere woorden", ru: "Попробовать более общие слова"),
                color: AppColors.dutchOrange,
                destination: .searchList
            )
        ]
    }

    private var retryTitle: String {
        switch lang {
        case .russian: return "Повторить"
        case .dutch: return "Opnieuw"
        case .english: return "Retry"
        }
    }

    private func errorState(_ message: String) -> some View {
        InfoCard(
            title: L10n.t("common.error", lang),
            subtitle: nil,
            detail: message,
            icon: "exclamationmark.triangle.fill",
            accentColor: AppColors.error
        )
    }

    private func horizontalFilter<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppTypography.captionStrong)
                .foregroundStyle(AppColors.textSecondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    content()
                }
                .padding(.vertical, 2)
            }
        }
    }

    private func filterChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.footnoteStrong)
                .foregroundStyle(isSelected ? Color.white : AppColors.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(isSelected ? AppColors.accent : AppColors.card)
                .clipShape(Capsule())
                .overlay {
                    Capsule().stroke(AppColors.stroke.opacity(isSelected ? 0 : 0.8), lineWidth: 0.8)
                }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func tag(_ title: String, color: Color) -> some View {
        Text(title)
            .font(AppTypography.captionStrong)
            .foregroundStyle(color)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }

    private func toggleSave(_ item: LGBTQSupportItem) {
        savedStore.toggle(
            id: item.saveKey,
            kind: .place,
            title: item.title,
            subtitle: "\(item.city) - \(item.category.title(lang))",
            destination: nil
        )
    }

    private func openWebsite(_ item: LGBTQSupportItem) {
        guard let url = item.websiteURL else { return }
        openURL(AppURL.safeWebURL(url))
    }

    private func openMaps(_ item: LGBTQSupportItem) {
        guard let query = item.mapsQuery?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://maps.apple.com/?q=\(query)") else { return }
        openURL(AppURL.safeWebURL(url))
    }

    private func localized(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .russian: return ru
        case .dutch: return nl
        case .english: return en
        }
    }
}

private extension View {
    @ViewBuilder
    func youNewTextInputAutocapitalizationNever() -> some View {
        #if os(iOS)
        self.textInputAutocapitalization(.never)
        #else
        self
        #endif
    }
}

private struct LGBTQRecoveryAction: Identifiable {
    let id: String
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let destination: AppDestination
}

private struct LGBTQRecoveryActionCard: View {
    let action: LGBTQRecoveryAction

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

private struct LGBTQSupportThumbnail: View {
    let item: LGBTQSupportItem
    let language: AppLanguage

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            AppColors.navyDeep,
                            AppColors.violet.opacity(0.75),
                            AppColors.cyanGlow.opacity(0.72)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            if let imageURL = item.imageURL {
                AppContentImageView(
                    asset: thumbnailAsset(imageURL),
                    language: language,
                    mode: .fill,
                    accent: AppColors.violet,
                    aspectRatio: nil,
                    cornerRadius: 0,
                    showsCaption: false,
                    accessibilityLabel: "\(item.title), \(item.city)",
                    fallbackLocalAssetName: CuratedPlaceHeroMediaRegistry.bundledNeutralFallbackAssetName,
                    fallbackSymbol: item.section.symbol,
                    targetPixelWidth: 180
                )
            } else {
                GeneratedCategoryArtwork(symbol: item.section.symbol, accent: AppColors.violet)
            }
        }
        .frame(width: 58, height: 58)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .accessibilityHidden(true)
    }

    private func thumbnailAsset(_ url: URL) -> AppImageAsset {
        AppImageAsset(
            id: "lgbtq-support-\(item.id)",
            url: url,
            imageURL: url,
            thumbnailURL: url,
            title: "\(item.title), \(item.city)",
            description: item.description(language),
            sourceName: "Verified support resource",
            sourceURL: item.websiteURL,
            license: nil,
            attribution: nil,
            width: nil,
            height: nil,
            aspectRatio: 1,
            type: .cardThumbnail,
            verified: true,
            retrievedAt: "2026-06-27"
        )
    }
}

private struct FlexibleTagLayout<Content: View>: View {
    let items: [String]
    let content: (String) -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(row, id: \.self) { item in
                        content(item)
                    }
                }
            }
        }
    }

    private var rows: [[String]] {
        var result: [[String]] = [[]]
        var currentLength = 0
        for item in items {
            let length = item.count
            if currentLength + length > 34, !(result.last?.isEmpty ?? true) {
                result.append([item])
                currentLength = length
            } else {
                result[result.count - 1].append(item)
                currentLength += length
            }
        }
        return result
    }
}
