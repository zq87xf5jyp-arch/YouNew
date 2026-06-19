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
            symbol: "person.3.sequence.fill",
            badgeText: badgeText,
            accent: AppColors.dutchOrange
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
                FigureCard(
                    figure: figure,
                    lang: lang,
                    isExpanded: expandedID == figure.id,
                    onToggle: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            expandedID = expandedID == figure.id ? nil : figure.id
                        }
                    }
                )
            }
        }
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

// MARK: - FigureCard

private struct FigureCard: View {
    let figure: HistoricalFigure
    let lang: AppLanguage
    let isExpanded: Bool
    let onToggle: () -> Void

    private var accent: Color { Color(hex: figure.accentColor) }

    var body: some View {
        Button(action: {
            onToggle()
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
        }) {
            VStack(alignment: .leading, spacing: 0) {
                header
                if isExpanded {
                    expandedContent
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .appGlassCardStyle(padding: 14, cornerRadius: 18, accent: accent)
    }

    private var header: some View {
        HStack(spacing: 12) {
            portrait
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(figure.name)
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                    Text(figure.emoji)
                        .font(.system(size: 14))
                }
                HStack(spacing: 4) {
                    Text(figure.years)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                    Text("·")
                        .foregroundStyle(AppColors.textTertiary)
                    Text(figure.fieldName(lang))
                        .font(AppTypography.captionStrong)
                        .foregroundStyle(accent)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                }
            }
            Spacer(minLength: 4)
            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppColors.textTertiary)
        }
    }

    private var portrait: some View {
        ZStack {
            LinearGradient(
                colors: [accent.opacity(0.45), AppColors.graphite.opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Text(figure.emoji)
                .font(.system(size: 24))
        }
        .frame(width: 52, height: 52)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider().background(accent.opacity(0.2)).padding(.top, 10)

            Text(figure.shortBio(lang))
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            routeRow
            knownForBadge
        }
        .padding(.top, 2)
    }

    private var routeRow: some View {
        HStack(spacing: 8) {
            Label(figure.birthCity, systemImage: "mappin.circle.fill")
            Text("→")
                .foregroundStyle(AppColors.textTertiary)
            Label(figure.deathCity, systemImage: "cross.circle.fill")
        }
        .font(.system(size: 11, weight: .medium))
        .foregroundStyle(AppColors.textSecondary)
    }

    private var knownForBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "star.fill")
                .font(.system(size: 10, weight: .bold))
            Text(figure.knownForText(lang))
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundStyle(accent)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(accent.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
