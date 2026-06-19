import SwiftUI

struct CultureAttractionsView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.openURL) private var openURL
    @State private var selectedTourismCategory: TourismCategory = .topAttractions

    private var lang: AppLanguage { languageManager.appLanguage }
    private var allArticles: [InfoArticle] {
        MockNetherlandsUnderstandingData.cultureArticles + MockNetherlandsUnderstandingData.attractionArticles
    }
    private var selectedTourismRecords: [TourismAttractionRecord] {
        TourismAttractionCatalog.records.filter { $0.category == selectedTourismCategory }
    }
    private var orderedTopics: [InfoArticle] {
        let articleByID = Dictionary(uniqueKeysWithValues: allArticles.map { ($0.id, $0) })
        return topicOrder.compactMap { articleByID[$0] }
    }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 920) {
                LazyVStack(alignment: .leading, spacing: AppSpacing.medium) {
                    headerSection
                    introSection
                    tourismCategorySection
                    topicFlow
                    Color.clear.frame(height: AppSpacing.tabBarScrollReserve)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, AppSpacing.medium)
            }
        }
        .appSceneBackground(.city)
        .navigationTitle(titleText)
        .nlNavigationInline()
    }

    private var headerSection: some View {
        CategoryHeroVisual(
            assetName: nil,
            title: titleText,
            subtitle: subtitleText,
            symbol: "sparkles.rectangle.stack.fill",
            badgeText: badgeText,
            accent: AppColors.dutchOrange,
            asset: ContentMediaRegistry.cultureHero
        )
    }

    private var introSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(introTitle)
                .font(AppTypography.bodyStrong)
                .foregroundStyle(AppColors.textPrimary)

            Text(introBody)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .appCardStyle()
    }

    private var tourismCategorySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(
                title: tourismSectionTitle,
                subtitle: tourismSectionSubtitle
            )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(TourismCategory.allCases, id: \.self) { category in
                        tourismCategoryChip(category)
                    }
                }
                .padding(.vertical, 2)
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 250), spacing: AppSpacing.small)], spacing: AppSpacing.small) {
                ForEach(selectedTourismRecords) { record in
                    tourismAttractionCard(record)
                }
            }
        }
    }

    private func tourismCategoryChip(_ category: TourismCategory) -> some View {
        let isSelected = selectedTourismCategory == category
        return Button {
            withAnimation(AppAnimations.standard) {
                selectedTourismCategory = category
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: tourismCategoryIcon(category))
                    .font(.system(size: 11, weight: .bold))
                Text(category.localizedTitle(lang))
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? Color.white : AppColors.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? AppColors.dutchOrange : AppColors.chipBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.white.opacity(isSelected ? 0.20 : 0.08), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }

    private func tourismAttractionCard(_ record: TourismAttractionRecord) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            CityImageView(
                urlString: record.photoURL,
                height: 148,
                cityName: record.name,
                fallbackColor: Color(hex: "#20324A"),
                debugContext: ImageDebugContext(
                    screen: "Culture attractions tourism catalog",
                    entityType: "tourism-attraction",
                    entityName: record.name,
                    requestedURL: record.photoURL,
                    fallbackLevel: PlaceImageFallbackLevel.explicitModelURL.rawValue,
                    sourceRegistry: "TourismAttractionCatalog",
                    modelID: record.id
                ),
                targetPixelWidth: 1200
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: tourismCategoryIcon(record.category))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AppColors.dutchOrange)
                        .frame(width: 18)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(record.category.localizedTitle(lang).uppercased())
                            .font(AppTypography.metadata)
                            .foregroundStyle(AppColors.dutchOrange)
                        Text(record.name)
                            .font(AppTypography.bodyStrong)
                            .foregroundStyle(AppColors.textPrimary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                tourismMetadataLine(icon: "mappin.and.ellipse", text: record.location)
                Text(record.description)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: 5) {
                    tourismFact(label: whyVisitLabel, value: record.whyVisit)
                    tourismFact(label: bestSeasonLabel, value: record.bestSeason)
                }
            }
            .padding(12)
        }
        .appGlassCardStyle(padding: 0, cornerRadius: 18, accent: AppColors.dutchOrange)
    }

    private func tourismMetadataLine(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(AppColors.textTertiary)
                .frame(width: 14)
            Text(text)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func tourismFact(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased())
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.textTertiary)
            Text(value)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var topicFlow: some View {
        LazyVStack(alignment: .leading, spacing: AppSpacing.small) {
            ForEach(Array(orderedTopics.enumerated()), id: \.element.id) { index, article in
                topicCard(article, index: index, next: nextTopicTitle(after: index))
            }
        }
    }

    private func topicCard(_ article: InfoArticle, index: Int, next: String?) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                topicThumbnail(article, accent: accent(for: article))

                VStack(alignment: .leading, spacing: 5) {
                    Text("\(topicLabel) \(index + 1)")
                        .font(AppTypography.metadata)
                        .foregroundStyle(accent(for: article))
                        .textCase(.uppercase)

                    Text(article.title.value(lang))
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(article.subtitle.value(lang))
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            explanationBlock(article, accent: accent(for: article))
            sourceBlock(article, accent: accent(for: article))

            if let next {
                Divider().overlay(Color.white.opacity(0.10))
                HStack(spacing: 7) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(AppColors.textTertiary)
                    Text("\(nextTopicLabel): \(next)")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .appGlassCardStyle(padding: 12, cornerRadius: 16, accent: accent(for: article))
    }

    @ViewBuilder
    private func topicThumbnail(_ article: InfoArticle, accent: Color) -> some View {
        if let image = article.image {
            AppContentImageView(
                asset: image,
                language: lang,
                mode: .fill,
                accent: accent,
                aspectRatio: 4.0 / 3.0,
                cornerRadius: 12,
                showsCaption: false,
                showsSourceButton: false,
                accessibilityLabel: image.displayTitle(lang),
                targetPixelWidth: 360
            )
            .frame(width: 82, height: 62)
        } else {
            Image(systemName: article.symbol)
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(accent)
                .frame(width: 82, height: 62)
                .background(accent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private func explanationBlock(_ article: InfoArticle, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(explanationLabel, systemImage: "text.alignleft")
                .font(AppTypography.captionStrong)
                .foregroundStyle(AppColors.textPrimary)

            Text(article.summary.value(lang))
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text(article.practicalNote.value(lang))
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(accent.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func sourceBlock(_ article: InfoArticle, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(sourceLabel, systemImage: "checkmark.seal.fill")
                .font(AppTypography.captionStrong)
                .foregroundStyle(AppColors.textPrimary)

            ForEach(article.sources.prefix(2)) { source in
                if let sourceURL = AppURL.validatedWebURL(source.url) {
                    Button {
                        openURL(sourceURL)
                    } label: {
                    HStack(spacing: 8) {
                        Image(systemName: AppIcons.external)
                            .font(.system(size: 11, weight: .bold))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(source.title)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .lineLimit(1)
                            Text(source.institution)
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundStyle(AppColors.textSecondary)
                                .lineLimit(1)
                        }
                        Spacer(minLength: 0)
                    }
                    .foregroundStyle(accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(accent.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func accent(for article: InfoArticle) -> Color {
        article.type == .culture ? AppColors.emerald : AppColors.dutchOrange
    }

    private func nextTopicTitle(after index: Int) -> String? {
        guard orderedTopics.indices.contains(index + 1) else { return nil }
        return orderedTopics[index + 1].title.value(lang)
    }

    private var topicOrder: [String] {
        [
            "dutch-daily-culture",
            "direct-communication-style",
            "cycling-culture",
            "water-and-netherlands",
            "canals-city-centres",
            "museums-public-culture",
            "markets-local-life",
            "amsterdam-canals",
            "rijksmuseum-museumplein",
            "leiden-old-centre-canals",
            "delft-historic-centre",
            "the-hague-binnenhof",
            "utrecht-canals",
            "rotterdam-architecture",
            "maastricht-historic-centre",
            "kinderdijk-windmills",
            "delta-works"
        ]
    }

    private var titleText: String { "Culture & Attractions" }
    private var subtitleText: String {
        "A practical, source-backed path through Dutch daily culture, canals, museums, and city landmarks."
    }
    private var badgeText: String { "Guide" }
    private var introTitle: String { "Start with context, then choose a place" }
    private var introBody: String {
        "Begin with Dutch daily culture, then move into canals, museums, landmarks, and city-specific places with verified sources for each topic."
    }
    private var topicLabel: String { "Topic" }
    private var explanationLabel: String { "Explanation" }
    private var sourceLabel: String { "Source" }
    private var nextTopicLabel: String { "Next topic" }
    private var tourismSectionTitle: String {
        switch lang {
        case .english: return "Tourism by category"
        case .dutch: return "Toerisme per categorie"
        case .russian: return "Туризм по категориям"
        }
    }
    private var tourismSectionSubtitle: String {
        switch lang {
        case .english: return "Attractions with specific photos, locations, reasons to visit, and seasons."
        case .dutch: return "Attracties met specifieke foto's, locaties, bezoekredenen en seizoenen."
        case .russian: return "Достопримечательности с конкретными фото, местом, причиной и сезоном."
        }
    }
    private var whyVisitLabel: String {
        switch lang {
        case .english: return "Why visit"
        case .dutch: return "Waarom gaan"
        case .russian: return "Зачем идти"
        }
    }
    private var bestSeasonLabel: String {
        switch lang {
        case .english: return "Best season"
        case .dutch: return "Beste seizoen"
        case .russian: return "Лучший сезон"
        }
    }

    private func tourismCategoryIcon(_ category: TourismCategory) -> String {
        switch category {
        case .topAttractions: return "star.fill"
        case .museums: return "building.columns.fill"
        case .castles: return "building.columns"
        case .nature: return "leaf.fill"
        case .beaches: return "water.waves"
        case .parks: return "tree.fill"
        case .historicCentres: return "clock.fill"
        case .unescoSites: return "seal.fill"
        case .hiddenGems: return "sparkles"
        case .dayTrips: return "tram.fill"
        }
    }
}

private extension TourismCategory {
    func localizedTitle(_ lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.topAttractions, .dutch): return "Topattracties"
        case (.topAttractions, .russian): return "Главное"
        case (.museums, .dutch): return "Musea"
        case (.museums, .russian): return "Музеи"
        case (.castles, .dutch): return "Kastelen"
        case (.castles, .russian): return "Замки"
        case (.nature, .dutch): return "Natuur"
        case (.nature, .russian): return "Природа"
        case (.beaches, .dutch): return "Stranden"
        case (.beaches, .russian): return "Пляжи"
        case (.parks, .dutch): return "Parken"
        case (.parks, .russian): return "Парки"
        case (.historicCentres, .dutch): return "Historische centra"
        case (.historicCentres, .russian): return "Исторические центры"
        case (.unescoSites, .dutch): return "UNESCO-sites"
        case (.unescoSites, .russian): return "UNESCO"
        case (.hiddenGems, .dutch): return "Verborgen parels"
        case (.hiddenGems, .russian): return "Скрытые места"
        case (.dayTrips, .dutch): return "Dagtrips"
        case (.dayTrips, .russian): return "Поездки на день"
        default: return title
        }
    }
}
