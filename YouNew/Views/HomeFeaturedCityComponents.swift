import SwiftUI

// MARK: - Featured City

struct HomeFeaturedCitySection: View {
    let city: NLCity
    let language: AppLanguage
    let eyebrow: String
    let exploreCityTitle: String

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let resolvedImage = CanonicalPlaceImageResolver.resolveCityHero(city: city)

        return NavigationLink(value: AppDestination.nlCityDetail(city.id)) {
            GeometryReader { proxy in
                ZStack(alignment: .bottomLeading) {
                    CityImageView(
                        urlString: resolvedImage.urlString,
                        height: dynamicTypeSize.isAccessibilitySize ? 620 : 540,
                        placeId: city.placeId,
                        cityName: city.name,
                        fallbackColor: Color(hex: city.heroColor),
                        fallbackURLStrings: resolvedImage.fallbackURLStrings,
                        debugContext: resolvedImage.debugContext(
                            screen: "Home featured city",
                            entityType: "city",
                            entityName: city.name
                        ),
                        renderRole: .card
                    )

                    cityImageOverlays

                    CityOfficialFlagView(city: city, width: 36, height: 24, showLabel: false)
                        .position(x: max(54, proxy.size.width - 42), y: 42)
                        .zIndex(2)

                    content(width: proxy.size.width)
                }
            }
            .frame(maxWidth: .infinity, minHeight: dynamicTypeSize.isAccessibilitySize ? 620 : 540)
            .tiltCard()
        }
        .buttonStyle(NLTileButtonStyle())
        .pressable()
        .cardGlowingTopEdge(color: AppColors.softBlue, cornerRadius: 0)
    }

    private var cityImageOverlays: some View {
        ZStack {
            LinearGradient(
                colors: [
                    AppColors.navyDeep.opacity(0.96),
                    AppColors.navyDeep.opacity(0.58),
                    Color.black.opacity(0.26),
                    AppColors.navyDeep.opacity(0.98)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            LinearGradient(
                colors: [
                    AppColors.navyDeep.opacity(0.86),
                    Color.clear,
                    Color.clear
                ],
                startPoint: .leading,
                endPoint: .trailing
            )

            LinearGradient(
                colors: [
                    AppColors.cyanGlow.opacity(0.18),
                    Color.clear,
                    AppColors.dutchOrange.opacity(0.16)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private func content(width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(eyebrow)
                .font(.system(size: 13, weight: .semibold, design: .default))
                .foregroundStyle(AppColors.cyanGlow)
                .textCase(.uppercase)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
                .fixedSize(horizontal: false, vertical: true)

            cityCopy
            featuredCityStats
            exploreButton
        }
        .padding(dynamicTypeSize.isAccessibilitySize ? 20 : 18)
        .frame(width: min(max(0, width - AppSpacing.screenHorizontal * 2), 560), alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    Color.black.opacity(0.58),
                    AppColors.navyDeep.opacity(0.42)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.bottom, dynamicTypeSize.isAccessibilitySize ? 34 : 28)
    }

    private var cityCopy: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(ProvinceCatalog.localizedCityName(city.name, language))
                .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 42 : 36, weight: .semibold, design: .default))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.64)
                .allowsTightening(true)

            Text(localizedProvinceName(city.province))
                .font(.system(size: 16, weight: .medium, design: .default))
                .foregroundStyle(Color.white.opacity(0.78))
                .lineLimit(2)
                .minimumScaleFactor(0.82)
                .fixedSize(horizontal: false, vertical: true)

            Text(city.desc(short: true, lang: language))
                .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 18 : 15.5, weight: .regular, design: .default))
                .foregroundStyle(Color.white.opacity(0.92))
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? 6 : 3)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var featuredCityStats: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(minimum: 0), spacing: 8),
                GridItem(.flexible(minimum: 0), spacing: 8),
                GridItem(.flexible(minimum: 0), spacing: 0)
            ],
            alignment: .leading,
            spacing: 8
        ) {
            ForEach(Array(city.facts.prefix(3)), id: \.id) { fact in
                FeaturedCityStatChip(title: fact.label(language), value: fact.localizedValue(language))
            }
        }
        .padding(8)
        .background(Color.black.opacity(0.24))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var exploreButton: some View {
        HStack(spacing: 8) {
            Image(systemName: "arrow.right")
                .font(.system(size: 14, weight: .bold))

            Text(exploreCityTitle)
                .font(.system(size: 15, weight: .bold, design: .rounded))
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(
            LinearGradient(
                colors: [Color(hex: "#F97316"), Color(hex: "#AE1C28")],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color(hex: "#F97316").opacity(0.45), radius: 14, y: 5)
    }

    private func localizedProvinceName(_ province: String) -> String {
        switch (province, language) {
        case ("Noord-Holland", .russian): return "Северная Голландия"
        case ("Zuid-Holland", .russian): return "Южная Голландия"
        case ("Noord-Brabant", .russian): return "Северный Брабант"
        default: return province
        }
    }
}
