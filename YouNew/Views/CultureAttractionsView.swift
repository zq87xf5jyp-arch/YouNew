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
    private var cultureTopics: [InfoArticle] {
        orderedTopics.filter { $0.type == .culture }
    }
    private var attractionTopics: [InfoArticle] {
        orderedTopics.filter { $0.type != .culture }
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
        .accessibilityIdentifier("culture.screen")
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
                ?? ContentMediaRegistry.museumsCultureImage
                ?? ContentMediaRegistry.mapImage
        )
    }

    private var introSection: some View {
        return VStack(alignment: .leading, spacing: 8) {
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

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 116), spacing: 8)],
                alignment: .leading,
                spacing: 8
            ) {
                ForEach(TourismCategory.allCases, id: \.self) { category in
                    tourismCategoryChip(category)
                }
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 250), spacing: AppSpacing.small)], spacing: AppSpacing.small) {
                ForEach(selectedTourismRecords) { record in
                    tourismAttractionCard(record)
                }
            }
            .id(selectedTourismCategory)
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
            .frame(maxWidth: .infinity, minHeight: 40)
            .background(isSelected ? AppColors.dutchOrange : AppColors.chipBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.white.opacity(isSelected ? 0.20 : 0.08), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("culture.category.\(category.rawValue)")
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
                renderRole: .card
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
            if !cultureTopics.isEmpty {
                topicGroupHeader(title: cultureTopicsTitle, subtitle: cultureTopicsSubtitle, accent: AppColors.emerald)
                ForEach(Array(cultureTopics.enumerated()), id: \.element.id) { index, article in
                    topicCard(article, index: index, next: nextTopicTitle(in: cultureTopics, after: index))
                }
            }

            if !attractionTopics.isEmpty {
                topicGroupHeader(title: attractionTopicsTitle, subtitle: attractionTopicsSubtitle, accent: AppColors.dutchOrange)
                    .padding(.top, AppSpacing.medium)
                ForEach(Array(attractionTopics.enumerated()), id: \.element.id) { index, article in
                    topicCard(article, index: index, next: nextTopicTitle(in: attractionTopics, after: index))
                }
            }
        }
    }

    private func topicGroupHeader(title: String, subtitle: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(accent)
                .frame(width: 42, height: 3)
                .padding(.bottom, 4)

            Text(title)
                .font(.system(.title3, design: .rounded).weight(.bold))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.82)

            Text(subtitle)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, AppSpacing.small)
    }

    private func topicCard(_ article: InfoArticle, index: Int, next: String?) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            topicHeader(article, index: index)

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

    private func topicHeader(_ article: InfoArticle, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            topicWideImage(article, accent: accent(for: article))
            topicHeaderText(article, index: index)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func topicHeaderText(_ article: InfoArticle, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("\(topicLabel) \(index + 1)")
                .font(AppTypography.metadata)
                .foregroundStyle(accent(for: article))
                .textCase(.uppercase)

            Text(article.title.value(lang))
                .font(AppTypography.bodyStrong)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(3)
                .minimumScaleFactor(0.86)
                .fixedSize(horizontal: false, vertical: true)

            Text(article.subtitle.value(lang))
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
            .clipped()
        } else {
            Image(systemName: article.symbol)
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(accent)
                .frame(width: 82, height: 62)
                .background(accent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    @ViewBuilder
    private func topicWideImage(_ article: InfoArticle, accent: Color) -> some View {
        if let image = article.image {
            AppContentImageView(
                asset: image,
                language: lang,
                mode: .fill,
                accent: accent,
                aspectRatio: 16.0 / 9.0,
                cornerRadius: 12,
                showsCaption: false,
                showsSourceButton: false,
                accessibilityLabel: image.displayTitle(lang),
                targetPixelWidth: 720
            )
            .frame(maxWidth: .infinity)
            .frame(height: 138)
            .clipped()
        } else {
            Image(systemName: article.symbol)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(accent)
                .frame(maxWidth: .infinity)
                .frame(height: 84)
                .background(accent.opacity(0.10))
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
        let validSources = article.sources.prefix(2).compactMap { source -> (InfoSourceMetadata, URL)? in
            guard let sourceURL = AppURL.validatedWebURL(source.url) else { return nil }
            return (source, sourceURL)
        }

        return VStack(alignment: .leading, spacing: 8) {
            Label(sourceLabel, systemImage: "checkmark.seal.fill")
                .font(AppTypography.captionStrong)
                .foregroundStyle(AppColors.textPrimary)

            if validSources.isEmpty {
                sourceFallbackRows(accent: accent)
            } else {
                ForEach(validSources, id: \.0.id) { source, sourceURL in
                    cultureSourceButton(source: source, sourceURL: sourceURL, accent: accent)
                }
            }
        }
        .accessibilityIdentifier("culture.article.sources.dashboard")
    }

    private func cultureSourceButton(source: InfoSourceMetadata, sourceURL: URL, accent: Color) -> some View {
        Button {
            openURL(sourceURL)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: AppIcons.external)
                    .font(.system(size: 11, weight: .bold))
                VStack(alignment: .leading, spacing: 2) {
                    Text(source.title)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
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

    private func sourceFallbackRows(accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sourceFallbackRow(
                title: officialSourcesFallbackTitle,
                subtitle: officialSourcesFallbackSubtitle,
                symbol: AppIcons.officialSource,
                destination: .officialSources,
                accent: accent
            )

            sourceFallbackRow(
                title: cultureFallbackTitle,
                subtitle: cultureFallbackSubtitle,
                symbol: "sparkles.rectangle.stack.fill",
                destination: .cultureAttractions,
                accent: accent
            )
        }
        .accessibilityIdentifier("culture.article.sources.empty")
    }

    private func sourceFallbackRow(title: String, subtitle: String, symbol: String, destination: AppDestination, accent: Color) -> some View {
        NavigationLink(value: destination) {
            HStack(spacing: 8) {
                Image(systemName: symbol)
                    .font(.system(size: 11, weight: .bold))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(AppColors.textTertiary)
            }
            .foregroundStyle(accent)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(accent.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func accent(for article: InfoArticle) -> Color {
        article.type == .culture ? AppColors.emerald : AppColors.dutchOrange
    }

    private func nextTopicTitle(in topics: [InfoArticle], after index: Int) -> String? {
        guard topics.indices.contains(index + 1) else { return nil }
        return topics[index + 1].title.value(lang)
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
        "Dutch culture, canals, museums, and city landmarks."
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
    private var officialSourcesFallbackTitle: String {
        switch lang {
        case .russian: return "Официальные источники"
        case .dutch: return "Officiële bronnen"
        case .english: return "Official sources"
        }
    }
    private var officialSourcesFallbackSubtitle: String {
        switch lang {
        case .russian: return "Проверьте актуальную информацию перед поездкой."
        case .dutch: return "Controleer actuele informatie voordat je gaat."
        case .english: return "Check current information before you go."
        }
    }
    private var cultureFallbackTitle: String {
        switch lang {
        case .russian: return "Культура и достопримечательности"
        case .dutch: return "Cultuur & attracties"
        case .english: return "Culture & attractions"
        }
    }
    private var cultureFallbackSubtitle: String {
        switch lang {
        case .russian: return "Вернуться к проверенным темам и местам."
        case .dutch: return "Ga terug naar gecontroleerde thema's en plekken."
        case .english: return "Return to verified topics and places."
        }
    }
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
    private var cultureTopicsTitle: String {
        switch lang {
        case .english: return "Culture basics"
        case .dutch: return "Cultuurbasis"
        case .russian: return "Основы культуры"
        }
    }
    private var cultureTopicsSubtitle: String {
        switch lang {
        case .english: return "Daily life, communication, cycling, water, museums, and local routines."
        case .dutch: return "Dagelijks leven, communicatie, fietsen, water, musea en lokale routines."
        case .russian: return "Повседневная жизнь, общение, велосипеды, вода, музеи и местные привычки."
        }
    }
    private var attractionTopicsTitle: String {
        switch lang {
        case .english: return "City places"
        case .dutch: return "Stadsplekken"
        case .russian: return "Городские места"
        }
    }
    private var attractionTopicsSubtitle: String {
        switch lang {
        case .english: return "Canals, historic centres, landmarks, UNESCO sites, and visitor source checks."
        case .dutch: return "Grachten, historische centra, landmarks, UNESCO-sites en broncontrole."
        case .russian: return "Каналы, исторические центры, достопримечательности, UNESCO и проверка источников."
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
