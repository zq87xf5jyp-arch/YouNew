import SwiftUI

struct HomeInformationFeature: Identifiable {
    let id: String
    let title: String
    let symbol: String
    let destination: AppDestination

    init(id: String, _ title: String, symbol: String, destination: AppDestination) {
        self.id = id
        self.title = title
        self.symbol = symbol
        self.destination = destination
    }

    var accessibilityIdentifier: String { "home.categoryChip.\(id)" }
}

struct HomeInformationPreview: Identifiable {
    let id: String
    let localAssetName: String?
    let remoteURL: URL?
    let accessibilityLabel: String

    init(id: String, localAssetName: String? = nil, remoteURL: URL? = nil, accessibilityLabel: String) {
        self.id = id
        self.localAssetName = localAssetName
        self.remoteURL = remoteURL
        self.accessibilityLabel = accessibilityLabel
    }
}

enum HomeInformationPersonality {
    case profile
    case official
    case places
    case housing
    case transport
    case leisure
    case education
    case ai
    case discover

    var accent: Color {
        switch self {
        case .profile: return AppColors.violet
        case .official: return AppColors.softBlue
        case .places: return AppColors.cyanGlow
        case .housing: return AppColors.gradHousing[0]
        case .transport: return AppColors.emerald
        case .leisure: return AppColors.dutchOrange
        case .education: return AppColors.routeLine
        case .ai: return AppColors.violet
        case .discover: return AppColors.warning
        }
    }

    var secondary: Color {
        switch self {
        case .profile: return AppColors.routeLine
        case .official: return AppColors.navyDeep
        case .places: return AppColors.softBlue
        case .housing: return AppColors.violet
        case .transport: return AppColors.routeLine
        case .leisure: return AppColors.error
        case .education: return AppColors.softBlue
        case .ai: return AppColors.cyanGlow
        case .discover: return AppColors.dutchOrange
        }
    }
}

struct HomePremiumInformationCard: View {
    let symbol: String
    let subtitle: String?
    let features: [HomeInformationFeature]
    let metric: String?
    let callToAction: String
    let personality: HomeInformationPersonality
    var previews: [HomeInformationPreview] = []
    var progress: Double? = nil
    var primaryDestination: AppDestination? = nil
    var primaryAction: (() -> Void)? = nil
    var primaryAccessibilityIdentifier: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            primaryHeader

            if !features.isEmpty {
                featureGrid
            }

            if let progress {
                ProgressView(value: min(max(progress, 0), 1))
                    .tint(personality.accent)
                    .accessibilityValue(Text("\(Int(progress * 100))%"))
            }

            primaryFooter
        }
        .padding(15)
        .background(cardBackground)
        .overlay(alignment: .topTrailing) {
            Image(systemName: symbol)
                .font(.system(size: 70, weight: .black))
                .foregroundStyle(personality.accent.opacity(0.07))
                .offset(x: 12, y: -13)
                .accessibilityHidden(true)
                .allowsHitTesting(false)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(personality.accent.opacity(0.25), lineWidth: 0.8)
                .allowsHitTesting(false)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    @ViewBuilder
    private var primaryHeader: some View {
        if let primaryDestination {
            NavigationLink(value: primaryDestination) {
                primaryHeaderContent
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(primaryAccessibilityIdentifier ?? "home.card.primary")
        } else if let primaryAction {
            Button(action: primaryAction) {
                primaryHeaderContent
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(primaryAccessibilityIdentifier ?? "home.card.primary")
        } else {
            primaryHeaderContent
        }
    }

    private var primaryHeaderContent: some View {
        VStack(alignment: .leading, spacing: 13) {
            header

            if !previews.isEmpty {
                previewStrip
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .frame(
                    width: AppIcons.Metrics.minimumTouchTarget,
                    height: AppIcons.Metrics.minimumTouchTarget
                )
                .background(
                    LinearGradient(
                        colors: [personality.accent, personality.secondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                )

            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
    }

    private var previewStrip: some View {
        HStack(spacing: 8) {
            ForEach(previews.prefix(3)) { preview in
                previewImage(preview)
                    .frame(maxWidth: .infinity)
                    .frame(height: 62)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(.white.opacity(0.13)))
                    .accessibilityLabel(preview.accessibilityLabel)
            }
        }
    }

    @ViewBuilder
    private func previewImage(_ preview: HomeInformationPreview) -> some View {
        if let localAssetName = preview.localAssetName {
            Image(localAssetName)
                .resizable()
                .scaledToFill()
        } else if let remoteURL = preview.remoteURL {
            CityImageView(
                urlString: remoteURL.absoluteString,
                height: 62,
                fallbackColor: personality.accent.opacity(0.42),
                renderRole: .thumbnail,
                targetPixelWidth: 360,
                showsReadableOverlay: false
            )
        } else {
            previewFallback
        }
    }

    private var previewFallback: some View {
        LinearGradient(
            colors: [personality.accent.opacity(0.42), personality.secondary.opacity(0.24)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            Image(systemName: symbol)
                .foregroundStyle(.white.opacity(0.82))
        }
    }

    private var featureGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 92), spacing: 7)], alignment: .leading, spacing: 7) {
            ForEach(features) { feature in
                NavigationLink(value: feature.destination) {
                    Label(feature.title, systemImage: feature.symbol)
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.78)
                        .frame(maxWidth: .infinity, minHeight: 31, alignment: .leading)
                        .padding(.horizontal, 9)
                        .background(personality.accent.opacity(0.10), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(feature.accessibilityIdentifier)
            }
        }
    }

    @ViewBuilder
    private var primaryFooter: some View {
        if let primaryDestination {
            NavigationLink(value: primaryDestination) {
                footerContent
            }
            .buttonStyle(.plain)
        } else if let primaryAction {
            Button(action: primaryAction) {
                footerContent
            }
            .buttonStyle(.plain)
        } else {
            footerContent
        }
    }

    private var footerContent: some View {
        HStack(alignment: .center, spacing: 10) {
            if let metric, !metric.isEmpty {
                Text(metric)
                    .font(AppTypography.captionStrong)
                    .foregroundStyle(personality.accent)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 8)
            HStack(spacing: 5) {
                Text(callToAction)
                Image(systemName: "arrow.right")
            }
            .font(AppTypography.captionStrong)
            .foregroundStyle(AppColors.textPrimary)
        }
    }

    private var cardBackground: some ShapeStyle {
        LinearGradient(
            colors: [
                AppColors.cardElevated.opacity(0.96),
                personality.secondary.opacity(0.14),
                AppColors.navyDeep.opacity(0.90)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
