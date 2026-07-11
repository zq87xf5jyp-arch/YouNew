import SwiftUI

struct HomePlacesWorthVisitingSection: View {
    let shouldShow: Bool
    let title: String
    let subtitle: String
    let viewAllLabel: String
    let allFilterLabel: String
    let mapDestination: AppDestination
    let places: [PlaceItem]
    let language: AppLanguage
    @Binding var selectedFilter: VisitPlaceCategory?

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        if shouldShow, !places.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                sectionHeader
                filterChips
                placesCarousel
            }
            .homeReadableBand()
            .padding(.bottom, 34)
            .accessibilityIdentifier("home.placesWorthVisiting")
        }
    }

    private var sectionHeader: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .lastTextBaseline, spacing: 12) {
                HomeSectionTitle(title: title, subtitle: subtitle)
                Spacer(minLength: 12)
                mapLink
            }

            VStack(alignment: .leading, spacing: 8) {
                HomeSectionTitle(title: title, subtitle: subtitle)
                mapLink
            }
        }
    }

    private var mapLink: some View {
        NavigationLink(value: mapDestination) {
            Label(viewAllLabel, systemImage: "chevron.right")
                .font(AppTypography.captionStrong)
                .foregroundStyle(AppColors.dutchOrange)
        }
    }

    private var filterChips: some View {
        HomePlaceFilterChips(
            allFilterLabel: allFilterLabel,
            selectedFilter: $selectedFilter,
            language: language
        )
    }

    private var placesCarousel: some View {
        GeometryReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(Array(places.enumerated()), id: \.element.id) { index, place in
                        placeLink(place, index: index, viewportWidth: proxy.size.width)
                    }
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, 2)
            }
            .padding(.horizontal, -AppSpacing.screenHorizontal)
            .scrollTargetBehavior(.viewAligned)
        }
        .frame(height: dynamicTypeSize.isAccessibilitySize ? 304 : 226)
        .clipped()
    }

    private func placeLink(_ place: PlaceItem, index: Int, viewportWidth: CGFloat) -> some View {
        let category = place.primaryCategory
        let width = index == 0 ? min(318, max(258, viewportWidth * 0.78)) : min(238, max(206, viewportWidth * 0.58))

        return NavigationLink(value: place.destination) {
            PremiumImageCard(
                title: place.shortTitle ?? place.title,
                subtitle: place.description,
                asset: dashboardPlaceImageAsset(place),
                language: language,
                symbol: category.symbol,
                accent: category.accent,
                imageHeight: index == 0 ? 122 : 104,
                minHeight: index == 0 ? 218 : 188,
                fallbackCategory: .city
            ) {
                Text(category.title(language))
                    .font(AppTypography.metadata)
                    .foregroundStyle(category.accent)
                    .textCase(.uppercase)
            }
            .frame(width: width)
        }
        .buttonStyle(NLTileButtonStyle())
    }

    private func dashboardPlaceImageAsset(_ place: PlaceItem) -> AppImageAsset? {
        guard let imageURL = AppURL.validatedWebURL(URL(string: place.image ?? "")) else { return nil }
        return AppImageAsset(
            id: "dashboard-place-\(place.id)",
            url: imageURL,
            title: place.shortTitle ?? place.title,
            description: place.description,
            sourceName: "YouNew",
            sourceURL: imageURL,
            license: nil,
            attribution: nil,
            width: nil,
            height: nil,
            type: .cardThumbnail,
            verified: true
        )
    }
}

struct HomeNetherlandsCalendarSection: View {
    let title: String
    let subtitle: String
    let nextHolidayLabel: String
    let viewCalendarLabel: String
    let allFilterLabel: String
    let events: [CalendarEvent]
    let language: AppLanguage
    @Binding var selectedFilter: CalendarEventType?

    var body: some View {
        if let nextEvent = events.first {
            VStack(alignment: .leading, spacing: 14) {
                HomeSectionTitle(title: title, subtitle: subtitle)
                nextEventLink(nextEvent)
                filterChips
                eventsCarousel
            }
            .homeReadableBand()
            .padding(.bottom, 34)
            .accessibilityIdentifier("home.netherlandsCalendar")
        }
    }

    private func nextEventLink(_ event: CalendarEvent) -> some View {
        NavigationLink(value: AppDestination.calendarEvent(event.id)) {
            ProductTaskCard(
                title: nextHolidayLabel,
                subtitle: "\(event.title) · \(event.type.title(language))",
                symbol: event.type.symbol,
                accent: event.type.accent,
                cta: event.date.formattedForAppLanguage(language),
                minHeight: 112
            )
        }
        .buttonStyle(NLTileButtonStyle())
    }

    private var filterChips: some View {
        HomeCalendarFilterChips(
            allFilterLabel: allFilterLabel,
            selectedFilter: $selectedFilter,
            language: language
        )
    }

    private var eventsCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                ForEach(events.dropFirst().prefix(5), id: \.id) { event in
                    eventLink(event)
                }

                NavigationLink(value: AppDestination.netherlandsCalendar) {
                    VStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .font(.system(size: 18, weight: .bold))
                        Text(viewCalendarLabel)
                            .font(AppTypography.captionStrong)
                            .multilineTextAlignment(.center)
                    }
                    .foregroundStyle(.white)
                    .frame(width: 112, height: 112)
                    .background(AppColors.dutchOrange.opacity(0.20))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(AppColors.dutchOrange.opacity(0.28), lineWidth: 1))
                }
                .buttonStyle(NLTileButtonStyle())
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, 2)
        }
        .padding(.horizontal, -AppSpacing.screenHorizontal)
    }

    private func eventLink(_ event: CalendarEvent) -> some View {
        NavigationLink(value: AppDestination.calendarEvent(event.id)) {
            ProductTaskCard(
                title: event.title,
                subtitle: event.type.title(language),
                symbol: event.type.symbol,
                accent: event.type.accent,
                cta: event.date.formattedForAppLanguage(language),
                minHeight: 112
            )
        }
        .buttonStyle(NLTileButtonStyle())
    }
}

private struct HomePlaceFilterChips: View {
    let allFilterLabel: String
    @Binding var selectedFilter: VisitPlaceCategory?
    let language: AppLanguage

    private let options: [VisitPlaceCategory] = [.museum, .landmark, .park, .historic]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                HomeDashboardFilterChip(label: allFilterLabel, selected: selectedFilter == nil, tint: AppColors.dutchOrange) {
                    selectedFilter = nil
                }

                ForEach(options, id: \.id) { option in
                    HomeDashboardFilterChip(label: option.title(language), selected: selectedFilter == option, tint: option.accent) {
                        selectedFilter = selectedFilter == option ? nil : option
                    }
                }
            }
        }
    }
}

private struct HomeCalendarFilterChips: View {
    let allFilterLabel: String
    @Binding var selectedFilter: CalendarEventType?
    let language: AppLanguage

    private let options: [CalendarEventType] = [.publicHoliday, .cityEvent, .serviceClosure, .touristEvent]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                HomeDashboardFilterChip(label: allFilterLabel, selected: selectedFilter == nil, tint: AppColors.dutchOrange) {
                    selectedFilter = nil
                }

                ForEach(options, id: \.id) { option in
                    HomeDashboardFilterChip(label: option.title(language), selected: selectedFilter == option, tint: option.accent) {
                        selectedFilter = selectedFilter == option ? nil : option
                    }
                }
            }
        }
    }
}

private struct HomeDashboardFilterChip: View {
    let label: String
    let selected: Bool
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(AppTypography.captionStrong)
                .foregroundStyle(selected ? .black : AppColors.textPrimary)
                .lineLimit(1)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(selected ? tint : AppColors.graphite.opacity(0.54))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct HomeSectionTitle: View {
    let title: String
    let subtitle: String?

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let visibleSubtitle = subtitle?.trimmingCharacters(in: .whitespacesAndNewlines)

        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 28 : AppTypography.Scale.section, weight: .semibold, design: .default))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
                .fixedSize(horizontal: false, vertical: true)

            if let visibleSubtitle, !visibleSubtitle.isEmpty {
                Text(visibleSubtitle)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(3)
                    .minimumScaleFactor(0.78)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
