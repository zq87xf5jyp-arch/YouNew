import SwiftUI

struct HomeCityGuideActionButton: View {
    let action: HomeCityGuideActionItem
    let onOpenURL: (URL) -> Void

    var body: some View {
        if let destination = action.destination {
            NavigationLink(value: destination) {
                card
            }
            .buttonStyle(NLTileButtonStyle())
            .accessibilityIdentifier("home.cityGuide.\(action.id)")
        } else if let url = action.url {
            Button {
                if let safeURL = AppURL.validatedWebURL(action.externalLink?.url ?? url) {
                    onOpenURL(safeURL)
                }
            } label: {
                card
            }
            .buttonStyle(NLTileButtonStyle())
            .accessibilityIdentifier("home.cityGuide.external.\(action.id)")
        }
    }

    private var card: some View {
        ProductTaskCard(
            title: action.title,
            subtitle: visibleSubtitle,
            symbol: action.symbol,
            accent: action.tint,
            priority: action.provider,
            cta: action.cta,
            minHeight: 124
        )
    }

    private var visibleSubtitle: String {
        let trimmedSubtitle = action.subtitle.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedSubtitle.isEmpty ? (action.provider ?? "") : action.subtitle
    }
}

struct HomeTravelActionGridSection<Action: Identifiable, Card: View>: View {
    let title: String
    let subtitle: String?
    let actions: [Action]
    let bottomPadding: CGFloat
    let accessibilityIdentifier: String
    let showsExternalDisclaimer: Bool
    @ViewBuilder let card: (Action) -> Card

    var body: some View {
        if !actions.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                HomeTravelSectionTitle(title: title, subtitle: subtitle)

                LazyVGrid(
                    columns: [
                        GridItem(.flexible(minimum: 0), spacing: 12),
                        GridItem(.flexible(minimum: 0), spacing: 12)
                    ],
                    spacing: 12
                ) {
                    ForEach(actions) { action in
                        card(action)
                    }
                }

                if showsExternalDisclaimer {
                    HomeExternalWebsiteDisclaimer()
                }
            }
            .homeReadableBand()
            .padding(.bottom, bottomPadding)
            .accessibilityIdentifier(accessibilityIdentifier)
        }
    }
}

struct HomeTravelLinksSection: View {
    let title: String
    let subtitle: String
    let officialLabel: String
    let links: [TravelLinkItem]
    let onOpenURL: (URL) -> Void

    var body: some View {
        if !links.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                HomeTravelSectionTitle(title: title, subtitle: subtitle)

                LazyVGrid(
                    columns: [
                        GridItem(.flexible(minimum: 0), spacing: 12),
                        GridItem(.flexible(minimum: 0), spacing: 12)
                    ],
                    spacing: 12
                ) {
                    ForEach(links) { link in
                        Button {
                            if let safeURL = AppURL.validatedWebURL(link.externalLink?.url ?? link.url) {
                                onOpenURL(safeURL)
                            }
                        } label: {
                            ProductTaskCard(
                                title: link.title,
                                subtitle: link.subtitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? link.sourceLabel : link.subtitle,
                                symbol: link.kind.symbol,
                                accent: link.kind.accent,
                                priority: link.isOfficial ? officialLabel : nil,
                                cta: link.sourceLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : link.sourceLabel,
                                minHeight: 132
                            )
                        }
                        .buttonStyle(NLTileButtonStyle())
                        .accessibilityIdentifier("home.travelLink.\(link.id)")
                    }
                }

                HomeExternalWebsiteDisclaimer()
            }
            .homeReadableBand()
            .padding(.bottom, 34)
            .accessibilityIdentifier("home.travelLinks")
        }
    }
}

struct HomeExternalWebsiteDisclaimer: View {
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppColors.textTertiary)
                .padding(.top, 1)

            Text("External site. Information, prices and availability are managed by the provider.")
                .font(.system(size: 11.5, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 2)
        .accessibilityIdentifier("home.externalBookingDisclaimer")
    }
}

private struct HomeTravelSectionTitle: View {
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
