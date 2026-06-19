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
                    emptyState(L10n.t("lgbtq.empty.title", lang), L10n.t("lgbtq.empty.subtitle", lang))
                case .loaded:
                    filters
                    if viewModel.filteredItems.isEmpty {
                        emptyState(L10n.t("lgbtq.no_results.title", lang), L10n.t("lgbtq.no_results.subtitle", lang))
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
                accent: AppColors.violet
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
                            LGBTQSupportCard(
                                item: item,
                                isSaved: savedStore.isSaved(item.saveKey),
                                onSave: { toggleSave(item) },
                                onOpenWebsite: { openWebsite(item) },
                                onOpenMaps: { openMaps(item) }
                            )
                        }
                    }
                }
            }
        }
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

    private func emptyState(_ title: String, _ subtitle: String) -> some View {
        NLGlassCard {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                GradientIconBadge(symbol: "tray", color: AppColors.textSecondary, size: 42, cornerRadius: 12)
                Text(title)
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(AppColors.textPrimary)
                Text(subtitle)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                Button(L10n.t("lgbtq.reset_filters", lang)) {
                    withAnimation(reduceMotion ? nil : AppAnimations.softSpring) {
                        viewModel.resetFilters()
                    }
                }
                .font(AppTypography.bodyStrong)
                .foregroundStyle(AppColors.accent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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

private struct LGBTQSupportCard: View {
    let item: LGBTQSupportItem
    let isSaved: Bool
    let onSave: () -> Void
    let onOpenWebsite: () -> Void
    let onOpenMaps: () -> Void

    @EnvironmentObject private var languageManager: LanguageManager
    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        NLGlassCard {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                HStack(alignment: .top, spacing: AppSpacing.small) {
                    LGBTQSupportThumbnail(item: item)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(item.category.title(lang))
                                .font(AppTypography.captionStrong)
                                .foregroundStyle(AppColors.violet)
                            Spacer(minLength: 8)
                            if item.isTrusted {
                                trustedBadge
                            }
                        }

                        Text(item.title)
                            .font(AppTypography.cardTitle)
                            .foregroundStyle(AppColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(item.description(lang))
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                metadataGrid

                if !item.accessibilityTags.isEmpty {
                    tagFlow
                }

                HStack(spacing: AppSpacing.small) {
                    if item.websiteURL != nil {
                        actionButton(title: L10n.t("common.website", lang), symbol: "safari", action: onOpenWebsite)
                    }
                    if item.mapsQuery != nil {
                        actionButton(title: L10n.t("common.maps", lang), symbol: "map", action: onOpenMaps)
                    }
                    Button(action: onSave) {
                        Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(isSaved ? AppColors.accent : AppColors.textSecondary)
                            .frame(width: 44, height: 44)
                            .background(AppColors.cardElevated)
                            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isSaved ? L10n.t("common.remove_saved", lang) : L10n.t("common.save", lang))
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title), \(item.city), \(item.category.title(lang))")
    }

    private var trustedBadge: some View {
        Text(L10n.t("lgbtq.trusted", lang))
            .font(AppTypography.metadata)
            .foregroundStyle(AppColors.success)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(AppColors.success.opacity(0.12))
            .clipShape(Capsule())
    }

    private var metadataGrid: some View {
        VStack(alignment: .leading, spacing: 6) {
            metadataLine(symbol: "mappin.and.ellipse", text: item.city)
            if let transit = item.publicTransportInfo(lang) {
                metadataLine(symbol: "tram.fill", text: transit)
            }
            if let hours = item.openingHours(lang) {
                metadataLine(symbol: "clock", text: hours)
            }
            if let date = item.dateText(lang) {
                metadataLine(symbol: "calendar", text: date)
            }
            if let organizer = item.organizer {
                metadataLine(symbol: "person.2.fill", text: organizer)
            }
        }
    }

    private var tagFlow: some View {
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

    private func metadataLine(symbol: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppColors.textTertiary)
                .frame(width: 16)
            Text(text)
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func actionButton(title: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(AppTypography.footnoteStrong)
                .foregroundStyle(AppColors.accent)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(AppColors.cardElevated)
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct LGBTQSupportThumbnail: View {
    let item: LGBTQSupportItem

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
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView().tint(.white)
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        Image(systemName: item.section.symbol).foregroundStyle(.white)
                    @unknown default:
                        Image(systemName: item.section.symbol).foregroundStyle(.white)
                    }
                }
            } else {
                Image(systemName: item.section.symbol)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: 58, height: 58)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .accessibilityHidden(true)
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
