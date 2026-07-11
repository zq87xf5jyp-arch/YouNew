import SwiftUI

struct GreatDutchFiguresView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    private var lang: AppLanguage { languageManager.appLanguage }

    @State private var expandedID: String?
    @State private var selectedField: String? = nil

    private var allFields: [String] {
        Array(Set(HistoricalFigure.all.map { $0.fieldName(lang) })).sorted()
    }

    private var filtered: [HistoricalFigure] {
        guard let field = selectedField else { return HistoricalFigure.all }
        return HistoricalFigure.all.filter { $0.fieldName(lang) == field }
    }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 920) {
                VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    heroSection
                    filterChips
                    figuresList
                    sourceNote
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.large)
                .padding(.bottom, AppSpacing.medium)
                .bottomTabSafeAreaPadding()
            }
        }
        .topChromeSafeAreaPadding()
        .appSceneBackground(.more)
        .navigationTitle(navTitle)
        .nlNavigationInline()
    }

    // MARK: - Sections

    private var heroSection: some View {
        PremiumHeroSurface(
            title: navTitle,
            subtitle: heroSubtitle,
            badge: badgeText,
            badgeSystemImage: "person.3.sequence.fill",
            asset: ContentMediaRegistry.cultureHero ?? ContentMediaRegistry.dailyCultureImage,
            language: lang,
            fallbackCategory: .city,
            accent: AppColors.dutchOrange,
            focalPoint: .center,
            height: 260,
            accessibilityIdentifier: "greatDutchFigures.hero"
        )
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(label: allLabel, isSelected: selectedField == nil) {
                    withAnimation(.spring(response: 0.26, dampingFraction: 0.8)) {
                        selectedField = nil
                    }
                }
                ForEach(allFields, id: \.self) { field in
                    filterChip(label: field, isSelected: selectedField == field) {
                        withAnimation(.spring(response: 0.26, dampingFraction: 0.8)) {
                            selectedField = selectedField == field ? nil : field
                        }
                    }
                }
            }
        }
    }

    private func filterChip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(isSelected ? .black : AppColors.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(isSelected ? AppColors.dutchOrange : AppColors.graphite.opacity(0.55))
                .clipShape(Capsule())
        }
    }

    private var figuresList: some View {
        LazyVStack(spacing: 10) {
            ForEach(filtered) { figure in
                let isExpanded = expandedID == figure.id
                Button {
                    #if canImport(UIKit)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    #endif
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        expandedID = expandedID == figure.id ? nil : figure.id
                    }
                } label: {
                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        figureCard(figure)

                        if isExpanded {
                            ProductInfoBlock(
                                title: figure.knownForText(lang),
                                bodyText: "\(figure.shortBio(lang))\n\n\(figure.birthCity) → \(figure.deathCity)",
                                symbol: "star.fill",
                                accent: Color(hex: figure.accentColor)
                            )
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func figureCard(_ figure: HistoricalFigure) -> some View {
        let accent = Color(hex: figure.accentColor)
        return HStack(alignment: .top, spacing: 12) {
            PremiumImageHeader(
                title: figure.name,
                asset: figureImageAsset(figure),
                language: lang,
                symbol: figureIcon(for: figure),
                accent: accent,
                height: 88,
                width: 96,
                cornerRadius: 18,
                fallbackCategory: .city
            )
            .layoutPriority(0)

            VStack(alignment: .leading, spacing: 7) {
                Text(figure.birthCity)
                    .font(AppTypography.captionStrong)
                    .foregroundStyle(accent)
                    .lineLimit(1)

                Text(figure.name)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)

                Text("\(figure.years) · \(figure.fieldName(lang))")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)
        }
        .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
        .appCardStyle()
    }

    private func figureIcon(for figure: HistoricalFigure) -> String {
        let field = figure.fieldName(.english).lowercased()
        if field.contains("paint") || field.contains("artist") { return "paintbrush.pointed.fill" }
        if field.contains("science") || field.contains("physic") { return "atom" }
        if field.contains("philos") { return "text.book.closed.fill" }
        if field.contains("law") || field.contains("politic") || field.contains("states") { return "building.columns.fill" }
        if field.contains("writer") || field.contains("diary") { return "book.pages.fill" }
        return "person.fill"
    }

    private func figureImageAsset(_ figure: HistoricalFigure) -> AppImageAsset? {
        guard let imageURL = URL(string: figure.imageURL) else { return nil }
        let sourceURL = URL(string: figure.imageURL.components(separatedBy: "?").first ?? figure.imageURL)
        return AppImageAsset(
            id: "historical-figure-\(figure.id)",
            url: imageURL,
            sourcePageURL: sourceURL,
            imageURL: imageURL,
            thumbnailURL: imageURL,
            originalFileURL: nil,
            title: figure.name,
            description: figure.knownFor,
            sourceName: "Wikimedia Commons",
            sourceURL: sourceURL,
            creator: nil,
            author: nil,
            license: nil,
            attribution: "Wikimedia Commons",
            width: nil,
            height: nil,
            type: .cardThumbnail,
            verified: true,
            retrievedAt: "2026-06-01"
        )
    }

    private var sourceNote: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(sourceTitle, systemImage: "checkmark.seal.fill")
                .font(AppTypography.footnoteStrong)
                .foregroundStyle(AppColors.cyanGlow)
            Text(sourceBody)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cyanGlow.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(AppColors.cyanGlow.opacity(0.18), lineWidth: 1)
        )
    }

    // MARK: - Strings

    private var navTitle: String {
        switch lang {
        case .russian: return "Великие нидерландцы"
        case .dutch:   return "Grote Nederlanders"
        case .english: return "Great Dutch Figures"
        }
    }

    private var heroSubtitle: String {
        switch lang {
        case .russian: return "Живописцы, учёные, философы, политики — люди, которые изменили нидерландскую и мировую историю."
        case .dutch:   return "Schilders, wetenschappers, filosofen, staatslieden — mensen die de Nederlandse en wereldgeschiedenis hebben veranderd."
        case .english: return "Painters, scientists, philosophers, statesmen — people who shaped Dutch and world history."
        }
    }

    private var badgeText: String {
        switch lang {
        case .russian: return "\(HistoricalFigure.all.count) фигур · Canon of the Netherlands"
        case .dutch:   return "\(HistoricalFigure.all.count) figuren · Canon van Nederland"
        case .english: return "\(HistoricalFigure.all.count) figures · Canon of the Netherlands"
        }
    }

    private var allLabel: String {
        switch lang {
        case .russian: return "Все"
        case .dutch:   return "Alle"
        case .english: return "All"
        }
    }

    private var sourceTitle: String {
        switch lang {
        case .russian: return "Источники: Rijksmuseum · Van Gogh Museum · Anne Frank House · International Court of Justice"
        case .dutch:   return "Bronnen: Rijksmuseum · Van Gogh Museum · Anne Frank Huis · Internationaal Gerechtshof"
        case .english: return "Sources: Rijksmuseum · Van Gogh Museum · Anne Frank House · International Court of Justice"
        }
    }

    private var sourceBody: String {
        switch lang {
        case .russian: return "Биографические данные основаны на официальных музейных и академических источниках. Количественные данные (картины, произведения) могут варьироваться в разных источниках."
        case .dutch:   return "Biografische gegevens zijn gebaseerd op officiële museum- en academische bronnen. Kwantitatieve gegevens (schilderijen, werken) kunnen per bron variëren."
        case .english: return "Biographical data is based on official museum and academic sources. Quantitative figures (paintings, works) may vary across sources."
        }
    }
}
