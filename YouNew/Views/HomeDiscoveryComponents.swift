import SwiftUI

// MARK: - History & Culture

struct HomeHistoryCultureSection: View {
    let title: String
    let language: AppLanguage

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(title)
                .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 31 : 26, weight: .semibold, design: .default))
                .foregroundStyle(.white)
                .lineLimit(3)
                .minimumScaleFactor(0.86)
                .fixedSize(horizontal: false, vertical: true)
                .sectionPadding()

            GeometryReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 10) {
                        historyCard(width: cultureCardWidth(for: proxy.size.width))
                        cultureCard(width: cultureCardWidth(for: proxy.size.width))
                        placesCard(width: cultureCardWidth(for: proxy.size.width))
                    }
                    .padding(.leading, AppSpacing.screenHorizontal)
                    .padding(.trailing, max(AppSpacing.screenHorizontal, 24))
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
            }
            .frame(height: dynamicTypeSize.isAccessibilitySize ? 360 : 300)
            .clipped()
        }
        .padding(.top, 42)
        .padding(.bottom, 40)
        .background(.clear)
    }

    private func historyCard(width: CGFloat) -> some View {
        NavigationLink(value: AppDestination.netherlandsHistory) {
            CultureImageBlock(
                title: localizedText(en: "History", nl: "Geschiedenis", ru: "История"),
                subtitle: localizedText(en: "Water, trade, cities, and the Dutch state.", nl: "Water, handel, steden en de Nederlandse staat.", ru: "Вода, торговля, города и государство."),
                asset: ContentMediaRegistry.canalHousesHero,
                tint: AppColors.dutchOrange,
                width: width
            )
        }
        .buttonStyle(NLTileButtonStyle())
    }

    private func cultureCard(width: CGFloat) -> some View {
        NavigationLink(value: AppDestination.cultureAttractions) {
            CultureImageBlock(
                title: localizedText(en: "Culture", nl: "Cultuur", ru: "Культура"),
                subtitle: localizedText(en: "Traditions, daily habits, museums, and local life.", nl: "Tradities, dagelijkse gewoontes, musea en lokaal leven.", ru: "Традиции, привычки, музеи и местная жизнь."),
                asset: ContentMediaRegistry.cultureHero,
                tint: AppColors.softBlue,
                width: width
            )
        }
        .buttonStyle(NLTileButtonStyle())
    }

    private func placesCard(width: CGFloat) -> some View {
        NavigationLink(value: AppDestination.cityList) {
            CultureImageBlock(
                title: localizedText(en: "Places to Visit", nl: "Plaatsen om te bezoeken", ru: "Места для посещения"),
                subtitle: localizedText(en: "Canals, windmills, tulip fields, and historic cities.", nl: "Grachten, molens, tulpenvelden en historische steden.", ru: "Каналы, мельницы, тюльпаны и исторические города."),
                asset: ContentMediaRegistry.cultureWindmillHero,
                tint: AppColors.emerald,
                width: width
            )
        }
        .buttonStyle(NLTileButtonStyle())
    }

    private func cultureCardWidth(for availableWidth: CGFloat) -> CGFloat {
        min(420, max(310, availableWidth * 0.92))
    }

    private func localizedText(en: String, nl: String, ru: String) -> String {
        switch language {
        case .russian: return ru
        case .dutch: return nl
        case .english: return en
        }
    }
}

// MARK: - Nearby Attractions

struct HomeNearbyAttractionsSection: View {
    let title: String
    let moments: [HomeCityMoment]
    let language: AppLanguage

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            NLSectionHeader(title: title)

            GeometryReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(moments) { moment in
                            momentCard(moment, width: max(0, proxy.size.width - 4))
                        }
                    }
                    .padding(.horizontal, 2)
                    .padding(.vertical, 2)
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
            }
            .frame(height: dynamicTypeSize.isAccessibilitySize ? 292 : 226)
            .clipped()
        }
    }

    @ViewBuilder
    private func momentCard(_ moment: HomeCityMoment, width: CGFloat) -> some View {
        if let destination = moment.destination {
            NavigationLink(value: destination) {
                imageCard(moment)
                    .frame(width: width)
            }
            .buttonStyle(NLTileButtonStyle())
        } else {
            imageCard(moment)
                .frame(width: width)
        }
    }

    private func imageCard(_ moment: HomeCityMoment) -> some View {
        PremiumImageCard(
            title: moment.title(language),
            subtitle: moment.subtitle(language),
            asset: moment.asset,
            language: language,
            symbol: "mappin.and.ellipse",
            accent: moment.accent,
            imageHeight: dynamicTypeSize.isAccessibilitySize ? 192 : 148,
            minHeight: dynamicTypeSize.isAccessibilitySize ? 292 : 226,
            fallbackCategory: .city
        ) {
            EmptyView()
        }
    }
}

// MARK: - News

struct HomeNewsUpdatesSection: View {
    let title: String
    let items: [HomeNewsItem]
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            NLSectionHeader(title: title)

            VStack(spacing: 10) {
                ForEach(items, id: \.id) { item in
                    ProductListItem(
                        title: item.title(language),
                        subtitle: item.subtitle(language),
                        symbol: item.icon,
                        accent: item.accent
                    )
                }
            }
        }
    }
}

// MARK: - Feedback

struct HomeReviewsFeedbackCard: View {
    let title: String
    let subtitle: String
    let storageNotice: String

    var body: some View {
        NavigationLink(value: AppDestination.supportFeedback) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 14) {
                    ZStack {
                        LinearGradient(
                            colors: [AppColors.dutchOrange, AppColors.dutchOrange.opacity(0.72)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )

                        Image(systemName: "star.bubble.fill")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 52, height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: 17, weight: .black, design: .rounded))
                            .foregroundStyle(AppColors.textPrimary)

                        Text(subtitle)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppColors.textSecondary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(AppColors.textTertiary)
                }

                Text(storageNotice)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(20)
            .background(GlassPanelBackground(accent: AppColors.dutchOrange, cornerRadius: 28))
        }
        .buttonStyle(NLTileButtonStyle())
    }
}
