import SwiftUI

struct HelpTopicIcon: View {
    let topic: HomeHelpTopic
    let language: AppLanguage

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [topic.tint.opacity(0.96), AppColors.dutchOrange.opacity(0.72)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 66, height: 66)

                Circle()
                    .fill(AppColors.card.opacity(0.98))
                    .frame(width: 60, height: 60)

                Image(systemName: topic.icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(topic.tint)
            }

            Text(topic.title(language))
                .font(.system(size: 13, weight: .semibold, design: .default))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.76)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: 82, height: 106, alignment: .top)
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

struct CultureImageBlock: View {
    let title: String
    let subtitle: String
    let asset: AppImageAsset?
    let tint: Color
    let width: CGFloat
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            HomeImageFill(asset: asset, accent: tint)
                .frame(width: width, height: dynamicTypeSize.isAccessibilitySize ? 310 : 258)
                .clipped()
            LinearGradient(
                colors: [
                    AppColors.navyDeep.opacity(0.24),
                    Color.clear,
                    AppColors.navyDeep.opacity(0.94)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            LinearGradient(
                colors: [
                    Color.black.opacity(0.34),
                    Color.clear
                ],
                startPoint: .leading,
                endPoint: .trailing
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 25 : 22, weight: .semibold, design: .default))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                    .fixedSize(horizontal: false, vertical: true)
                Text(subtitle)
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundStyle(Color.white.opacity(0.80))
                    .lineLimit(3)
                    .minimumScaleFactor(0.82)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: width)
        .frame(height: dynamicTypeSize.isAccessibilitySize ? 310 : 258)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(Color.white.opacity(0.14), lineWidth: 0.8))
        .clipped()
    }
}

struct FeaturedCityStatChip: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 18, weight: .semibold, design: .default))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text(title)
                .font(.system(size: 11.5, weight: .regular, design: .default))
                .foregroundStyle(Color.white.opacity(0.70))
                .lineLimit(3)
                .minimumScaleFactor(0.76)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 13)
        .padding(.vertical, 11)
        .background(Color.black.opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct HomeUnifiedVisualBackdrop: View {
    let asset: AppImageAsset?
    let accent: Color

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 4 / 255, green: 8 / 255, blue: 18 / 255),
                    Color(red: 8 / 255, green: 20 / 255, blue: 38 / 255),
                    AppSurface.base
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [accent.opacity(0.16), .clear],
                center: UnitPoint(x: 0.02, y: 0.05),
                startRadius: 0,
                endRadius: 430
            )

            RadialGradient(
                colors: [AppColors.dutchOrange.opacity(0.10), .clear],
                center: UnitPoint(x: 1.03, y: 0.16),
                startRadius: 0,
                endRadius: 390
            )

            RadialGradient(
                colors: [AppColors.violet.opacity(0.08), .clear],
                center: UnitPoint(x: 0.82, y: 0.92),
                startRadius: 0,
                endRadius: 520
            )

            LinearGradient(
                colors: [
                    Color.white.opacity(0.045),
                    Color.clear,
                    Color.black.opacity(0.22)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            DutchFlagRibbon(opacity: 0.035)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct HomeImageFill: View {
    let asset: AppImageAsset?
    let accent: Color
    var contentMode: ContentMode = .fill

    var body: some View {
        ZStack {
            fallback

            if let asset {
                AppContentImageView(
                    asset: asset,
                    language: .english,
                    mode: contentMode == .fit ? .fit : .fill,
                    accent: accent,
                    aspectRatio: nil,
                    cornerRadius: 0,
                    showsCaption: false,
                    fallbackLocalAssetName: CuratedPlaceHeroMediaRegistry.bundledNeutralFallbackAssetName,
                    targetPixelWidth: 1200
                )
            }

            LinearGradient(
                colors: [
                    Color.white.opacity(0.03),
                    Color.clear,
                    AppColors.navyDeep.opacity(0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .allowsHitTesting(false)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .accessibilityHidden(true)
    }

    private var fallback: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.navyDeep.opacity(0.96), accent.opacity(0.28), AppColors.graphite.opacity(0.86)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            DutchFlagRibbon(opacity: 0.18)
            AbstractCanalLines(color: accent, lineCount: 3)
                .opacity(0.28)
        }
    }
}
