import SwiftUI

struct HomeCityEmotionStrip: View {
    let cityTitle: String
    let citySubtitle: String
    let mapDestination: AppDestination
    let statusTitle: String
    let statusSubtitle: String
    let statusIcon: String
    let statusTint: Color
    let progressTitle: String
    let progressSubtitle: String

    var body: some View {
        LazyVGrid(columns: PremiumVisualMetrics.Grid.adaptiveColumns(minimum: 148), spacing: AppSpacing.xSmall) {
            NavigationLink(value: mapDestination) {
                HomeCitySignalPill(
                    title: cityTitle,
                    subtitle: citySubtitle,
                    symbol: "map.fill",
                    accent: AppColors.dutchOrange
                )
            }
            .buttonStyle(NLTileButtonStyle())

            HomeCitySignalPill(
                title: statusTitle,
                subtitle: statusSubtitle,
                symbol: statusIcon,
                accent: statusTint
            )

            HomeCitySignalPill(
                title: progressTitle,
                subtitle: progressSubtitle,
                symbol: "checklist",
                accent: AppColors.cyanGlow
            )
        }
        .padding(.top, -4)
        .accessibilityIdentifier("home.cityEmotionStrip")
    }
}

private struct HomeCitySignalPill: View {
    let title: String
    let subtitle: String
    let symbol: String
    let accent: Color

    var body: some View {
        HStack(spacing: 10) {
            ProductSymbolTile(symbol: symbol, accent: accent, size: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Text(subtitle)
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.textTertiary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, minHeight: 68, alignment: .leading)
        .background(AppColors.glassSurface.opacity(0.64), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(accent.opacity(0.14), lineWidth: 0.8)
        )
    }
}

struct HomeScenarioProgressCard: View {
    let title: String
    let summary: String
    let value: String
    let progress: Double
    let symbol: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                ProductSymbolTile(symbol: symbol, accent: accent, size: 42)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(.title3, design: .rounded).weight(.bold))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.78)

                    Text(summary)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                Text(value)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.cyanGlow)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            ProgressView(value: progress)
                .tint(AppColors.cyanGlow)
        }
        .padding(14)
        .background(AppColors.cardElevated.opacity(0.82), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(accent.opacity(0.18), lineWidth: 0.8)
        )
    }
}

struct HomeActionCommandCenterSection: View {
    let title: String
    let subtitle: String
    let priority: String
    let continueDestination: AppDestination
    let continueTitle: String
    let continueSubtitle: String
    let continueIcon: String
    let nextStepLabel: String
    let continueCTA: String
    let askTitle: String
    let askSubtitle: String
    let askCTA: String
    let onAskAI: () -> Void

    var body: some View {
        ProductScreenSection(title: title, subtitle: subtitle, priority: priority) {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                NavigationLink(value: continueDestination) {
                    ProductTaskCard(
                        title: continueTitle,
                        subtitle: continueSubtitle,
                        symbol: continueIcon,
                        accent: AppColors.cyanGlow,
                        priority: nextStepLabel,
                        cta: continueCTA,
                        minHeight: 138,
                        prominence: .primary
                    )
                }
                .buttonStyle(NLTileButtonStyle())
                .accessibilityIdentifier("home.continue")

                Button(action: onAskAI) {
                    ProductTaskCard(
                        title: askTitle,
                        subtitle: askSubtitle,
                        symbol: "sparkles",
                        accent: AppColors.violet,
                        cta: askCTA,
                        minHeight: 82,
                        prominence: .quiet
                    )
                }
                .buttonStyle(NLTileButtonStyle())
                .accessibilityIdentifier("home.product.askAI")
            }
        }
    }
}

struct HomePrimaryScenarioSection: View {
    let title: String
    let subtitle: String
    let selectedStatus: UserStatus?
    let selectedScenarioTitle: String
    let selectedScenarioSubtitle: String
    let selectedScenarioTint: Color
    let changeScenarioTitle: String
    let startAsTouristTitle: String
    let touristScenarioSubtitle: String
    let bottomPadding: CGFloat
    let onStartTourist: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HomePrimaryScenarioTitle(title: title, subtitle: subtitle)

            if let selectedStatus {
                NavigationLink(value: AppDestination.profileSelection) {
                    card(
                        title: selectedScenarioTitle,
                        subtitle: selectedScenarioSubtitle,
                        symbol: selectedStatus.icon,
                        accent: selectedScenarioTint,
                        cta: changeScenarioTitle
                    )
                }
                .buttonStyle(NLTileButtonStyle())
                .accessibilityIdentifier("home.primaryScenario.\(selectedStatus.rawValue)")
            } else {
                Button(action: onStartTourist) {
                    card(
                        title: startAsTouristTitle,
                        subtitle: touristScenarioSubtitle,
                        symbol: "suitcase.rolling.fill",
                        accent: AppColors.cyanGlow,
                        cta: startAsTouristTitle
                    )
                }
                .buttonStyle(NLTileButtonStyle())
                .accessibilityIdentifier("home.primaryScenario.tourist")
            }
        }
        .homeReadableBand()
        .padding(.top, 18)
        .padding(.bottom, bottomPadding)
    }

    private func card(title: String, subtitle: String, symbol: String, accent: Color, cta: String) -> some View {
        ProductTaskCard(
            title: title,
            subtitle: subtitle,
            symbol: symbol,
            accent: accent,
            cta: cta,
            minHeight: 112
        )
    }
}

private struct HomePrimaryScenarioTitle: View {
    let title: String
    let subtitle: String

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 28 : AppTypography.Scale.section, weight: .semibold, design: .default))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
                .fixedSize(horizontal: false, vertical: true)

            if !visibleSubtitle.isEmpty {
                Text(visibleSubtitle)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(3)
                    .minimumScaleFactor(0.78)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var visibleSubtitle: String {
        subtitle.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct HomePersonalDashboardSection<ProgressCard: View>: View {
    let title: String
    let subtitle: String
    let priority: String
    let aiTitle: String
    let aiSubtitle: String
    let aiCTA: String
    let searchTitle: String
    let searchSubtitle: String
    let searchCTA: String
    let mapDestination: AppDestination
    let mapTitle: String
    let mapSubtitle: String
    let mapCTA: String
    let onAskAI: () -> Void
    let onSearch: () -> Void
    let progressCard: () -> ProgressCard

    init(
        title: String,
        subtitle: String,
        priority: String,
        aiTitle: String,
        aiSubtitle: String,
        aiCTA: String,
        searchTitle: String,
        searchSubtitle: String,
        searchCTA: String,
        mapDestination: AppDestination,
        mapTitle: String,
        mapSubtitle: String,
        mapCTA: String,
        onAskAI: @escaping () -> Void,
        onSearch: @escaping () -> Void,
        @ViewBuilder progressCard: @escaping () -> ProgressCard
    ) {
        self.title = title
        self.subtitle = subtitle
        self.priority = priority
        self.aiTitle = aiTitle
        self.aiSubtitle = aiSubtitle
        self.aiCTA = aiCTA
        self.searchTitle = searchTitle
        self.searchSubtitle = searchSubtitle
        self.searchCTA = searchCTA
        self.mapDestination = mapDestination
        self.mapTitle = mapTitle
        self.mapSubtitle = mapSubtitle
        self.mapCTA = mapCTA
        self.onAskAI = onAskAI
        self.onSearch = onSearch
        self.progressCard = progressCard
    }

    var body: some View {
        ProductScreenSection(title: title, subtitle: subtitle, priority: priority) {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                progressCard()

                LazyVGrid(columns: PremiumVisualMetrics.Grid.adaptiveColumns(minimum: 220), spacing: AppSpacing.small) {
                    Button(action: onAskAI) {
                        HomeEcosystemActionCard(
                            title: aiTitle,
                            subtitle: aiSubtitle,
                            symbol: "sparkles",
                            accent: AppColors.violet,
                            cta: aiCTA
                        )
                    }
                    .buttonStyle(NLTileButtonStyle())
                    .accessibilityIdentifier("home.ecosystem.ai")

                    Button(action: onSearch) {
                        HomeEcosystemActionCard(
                            title: searchTitle,
                            subtitle: searchSubtitle,
                            symbol: "magnifyingglass",
                            accent: AppColors.softBlue,
                            cta: searchCTA
                        )
                    }
                    .buttonStyle(NLTileButtonStyle())
                    .accessibilityIdentifier("home.ecosystem.search")

                    NavigationLink(value: mapDestination) {
                        HomeEcosystemActionCard(
                            title: mapTitle,
                            subtitle: mapSubtitle,
                            symbol: "map.fill",
                            accent: AppColors.dutchOrange,
                            cta: mapCTA
                        )
                    }
                    .buttonStyle(NLTileButtonStyle())
                    .accessibilityIdentifier("home.ecosystem.map")
                }
            }
        }
        .accessibilityIdentifier("home.personalDashboard")
    }
}

struct HomeContextualRecommendationsSection<ActionContent: View>: View {
    let title: String
    let subtitle: String
    let accessibilityLabel: String
    let recommendations: [HomeCityGuideActionItem]
    let actionContent: (HomeCityGuideActionItem) -> ActionContent

    init(
        title: String,
        subtitle: String,
        accessibilityLabel: String,
        recommendations: [HomeCityGuideActionItem],
        @ViewBuilder actionContent: @escaping (HomeCityGuideActionItem) -> ActionContent
    ) {
        self.title = title
        self.subtitle = subtitle
        self.accessibilityLabel = accessibilityLabel
        self.recommendations = recommendations
        self.actionContent = actionContent
    }

    var body: some View {
        if !recommendations.isEmpty {
            ProductScreenSection(title: title, subtitle: subtitle) {
                LazyVGrid(columns: PremiumVisualMetrics.Grid.adaptiveColumns(minimum: 260), spacing: AppSpacing.small) {
                    ForEach(recommendations) { action in
                        actionContent(action)
                    }
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel(accessibilityLabel)
            .accessibilityIdentifier("home.quickActions")
        }
    }
}

struct HomeEcosystemActionCard: View {
    let title: String
    let subtitle: String
    let symbol: String
    let accent: Color
    let cta: String

    var body: some View {
        ProductTaskCard(
            title: title,
            subtitle: subtitle,
            symbol: symbol,
            accent: accent,
            cta: cta,
            minHeight: 94,
            prominence: .quiet
        )
    }
}
