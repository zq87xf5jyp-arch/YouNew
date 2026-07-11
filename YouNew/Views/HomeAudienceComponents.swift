import SwiftUI

struct HomeAudienceActionsSection: View {
    let shouldShow: Bool
    let title: String
    let actions: [HomeQuickAction]
    let language: AppLanguage

    var body: some View {
        if shouldShow, !actions.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                HomeAudienceSectionTitle(title: title)

                VStack(spacing: 12) {
                    ForEach(actions, id: \.id) { action in
                        NavigationLink(value: action.destination) {
                            ProductTaskCard(
                                title: action.shortTitle(language),
                                subtitle: action.subtitle(language),
                                symbol: action.icon,
                                accent: action.accent,
                                minHeight: 104
                            )
                        }
                        .buttonStyle(NLTileButtonStyle())
                    }
                }
            }
            .homeReadableBand()
            .padding(.bottom, 34)
            .accessibilityIdentifier("home.audienceActions")
        }
    }
}

struct HomeAudienceHelpSection: View {
    let shouldShow: Bool
    let title: String
    let topics: [HomeHelpTopic]
    let language: AppLanguage

    var body: some View {
        if shouldShow, !topics.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                HomeAudienceSectionTitle(title: title)

                LazyVGrid(
                    columns: [
                        GridItem(.flexible(minimum: 0), spacing: 12),
                        GridItem(.flexible(minimum: 0), spacing: 12)
                    ],
                    spacing: 12
                ) {
                    ForEach(topics, id: \.id) { topic in
                        NavigationLink(value: topic.destination) {
                            ProductTaskCard(
                                title: topic.shortTitle(language),
                                subtitle: topic.subtitle(language),
                                symbol: topic.icon,
                                accent: topic.tint,
                                minHeight: 132
                            )
                        }
                        .buttonStyle(NLTileButtonStyle())
                    }
                }
            }
            .homeReadableBand()
            .padding(.bottom, 34)
            .accessibilityIdentifier("home.audienceHelp")
        }
    }
}

struct HomeSecondaryToolsSection: View {
    let shouldShow: Bool
    let title: String
    let subtitle: String
    let tools: [HomeSecondaryTool]
    let onSelectTab: (AppTab) -> Void

    var body: some View {
        if shouldShow, !tools.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                HomeAudienceSectionTitle(title: title, subtitle: subtitle)

                LazyVGrid(
                    columns: [
                        GridItem(.flexible(minimum: 0), spacing: 12),
                        GridItem(.flexible(minimum: 0), spacing: 12)
                    ],
                    spacing: 12
                ) {
                    ForEach(tools) { tool in
                        Button {
                            onSelectTab(tool.tab)
                        } label: {
                            ProductTaskCard(
                                title: tool.title,
                                subtitle: tool.subtitle,
                                symbol: tool.icon,
                                accent: tool.tint,
                                minHeight: 104
                            )
                        }
                        .buttonStyle(NLTileButtonStyle())
                    }
                }
            }
            .homeReadableBand()
            .padding(.bottom, 34)
            .accessibilityIdentifier("home.secondaryTools")
        }
    }
}

struct HomePersonaJourneySection: View {
    let title: String
    let subtitle: String
    let journeys: [HomePersonaJourney]
    let language: AppLanguage
    let hasSelectedAudience: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header
            journeyCarousel
        }
        .homeReadableBand()
        .padding(.top, hasSelectedAudience ? 4 : 0)
        .padding(.bottom, hasSelectedAudience ? 30 : 18)
    }

    private var header: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .lastTextBaseline, spacing: 12) {
                Text(title)
                    .font(.system(size: 20, weight: .semibold, design: .default))
                    .foregroundStyle(AppColors.textPrimary)
                Spacer(minLength: 12)
                Text(subtitle)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textTertiary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 20, weight: .semibold, design: .default))
                    .foregroundStyle(AppColors.textPrimary)
                Text(subtitle)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textTertiary)
                    .lineLimit(2)
            }
        }
    }

    private var journeyCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(journeys) { journey in
                    NavigationLink(value: journey.destination) {
                        ProductTaskCard(
                            title: journey.title(language),
                            subtitle: journey.subtitle(language),
                            symbol: journey.icon,
                            accent: journey.tint,
                            minHeight: 128
                        )
                    }
                    .buttonStyle(NLTileButtonStyle())
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, 2)
        }
        .padding(.horizontal, -AppSpacing.screenHorizontal)
        .clipped()
    }
}

private struct HomeAudienceSectionTitle: View {
    let title: String
    var subtitle: String?

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
