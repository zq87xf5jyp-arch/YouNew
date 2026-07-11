import SwiftUI

struct HomeTopChromeBar: View {
    enum Style {
        case standard
        case hero
    }

    let title: String
    let tagline: String
    let menuAccessibilityLabel: String
    let style: Style
    let onOpenMenu: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            YouNewLogoMark()
                .frame(width: 38, height: 38)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 20, weight: .heavy, design: .default))
                    .foregroundStyle(titleColor)
                    .lineLimit(1)

                Text(tagline)
                    .font(.system(size: 12, weight: .semibold, design: taglineFontDesign))
                    .foregroundStyle(taglineColor)
                    .lineLimit(taglineLineLimit)
                    .minimumScaleFactor(0.74)
            }

            Spacer()

            Button(action: onOpenMenu) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(menuIconColor)
                    .frame(width: 44, height: 44)
                    .background(menuBackground)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(menuStrokeColor, lineWidth: 0.7))
            }
            .buttonStyle(NLTileButtonStyle())
            .accessibilityLabel(menuAccessibilityLabel)
        }
    }

    private var titleColor: Color {
        switch style {
        case .standard: return AppColors.textPrimary
        case .hero: return .white
        }
    }

    private var taglineColor: Color {
        switch style {
        case .standard: return AppColors.textSecondary
        case .hero: return Color.white.opacity(0.72)
        }
    }

    private var taglineFontDesign: Font.Design {
        switch style {
        case .standard: return .rounded
        case .hero: return .default
        }
    }

    private var taglineLineLimit: Int {
        switch style {
        case .standard: return 1
        case .hero: return 2
        }
    }

    private var menuIconColor: Color {
        switch style {
        case .standard: return AppColors.textPrimary
        case .hero: return .white
        }
    }

    private var menuBackground: Color {
        switch style {
        case .standard: return AppColors.cardElevated.opacity(0.92)
        case .hero: return Color.black.opacity(0.20)
        }
    }

    private var menuStrokeColor: Color {
        switch style {
        case .standard: return Color.white.opacity(0.10)
        case .hero: return Color.white.opacity(0.12)
        }
    }
}

struct HomeCityCompactOverviewCard: View {
    let destination: AppDestination
    let asset: AppImageAsset
    let language: AppLanguage
    let cityName: String
    let provinceName: String
    let cta: String

    var body: some View {
        NavigationLink(value: destination) {
            HStack(spacing: 14) {
                AppContentImageView(
                    asset: asset,
                    language: language,
                    aspectRatio: 1,
                    cornerRadius: 8,
                    showsCaption: false,
                    targetPixelWidth: 280
                )
                .frame(width: 82, height: 82)

                VStack(alignment: .leading, spacing: 5) {
                    Text(cityName)
                        .font(.system(size: 18, weight: .bold, design: .default))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)

                    Text(provinceName)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(1)

                    Text(cta)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.dutchOrange)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(AppColors.textTertiary)
            }
            .padding(12)
            .background(AppColors.card.opacity(0.88))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(Color.white.opacity(0.10), lineWidth: 0.8))
        }
        .buttonStyle(NLTileButtonStyle())
        .homeReadableBand()
        .padding(.bottom, 12)
        .accessibilityIdentifier("home.cityCompactOverview")
    }
}

struct HomeHeroCityStats: View {
    let stats: [CityDashboardStat]

    var body: some View {
        let visibleStats = Array(stats.prefix(3))

        if !visibleStats.isEmpty {
            HStack(spacing: 0) {
                ForEach(Array(visibleStats.enumerated()), id: \.element.id) { index, stat in
                    HomeHeroCityStat(value: stat.value, title: stat.label)
                    if index < visibleStats.count - 1 {
                        statDivider
                    }
                }
            }
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.26))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(Color.white.opacity(0.10), lineWidth: 0.8))
            .frame(maxWidth: 440)
        }
    }

    private var statDivider: some View {
        LinearGradient(
            colors: [.clear, AppSurface.b2, .clear],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(width: 0.5, height: 34)
    }
}

struct HomeHeroCityPagerDots: View {
    let count: Int
    let selectedIndex: Int?

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == selectedIndex ? AppColors.dutchOrange : Color.white.opacity(0.32))
                    .frame(width: index == selectedIndex ? 34 : 18, height: 4)
                    .animation(.easeInOut(duration: 0.22), value: selectedIndex)
            }
        }
        .padding(.bottom, 2)
    }
}

struct HomeCityPillsSection: View {
    let cities: [String]
    let selectedIndex: Int?
    let language: AppLanguage
    let onSelectCity: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                ForEach(Array(cities.enumerated()), id: \.element) { index, city in
                    HomeCityPill(
                        city: city,
                        isSelected: index == selectedIndex,
                        language: language,
                        onSelect: { onSelectCity(city) }
                    )
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, 18)
        }
        .background(.clear)
    }
}

private struct HomeCityPill: View {
    let city: String
    let isSelected: Bool
    let language: AppLanguage
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 6) {
                if let nlCity = CityDashboardContentData.resolveCity(city) {
                    CityOfficialFlagView(city: nlCity, width: 18, height: 12, showLabel: false)
                } else {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 12, weight: .bold))
                }

                Text(ProvinceCatalog.localizedCityName(city, language))
                    .font(.system(size: 13, weight: isSelected ? .bold : .medium, design: .rounded))
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? .white : .white.opacity(0.50))
            .lineLimit(1)
            .minimumScaleFactor(0.78)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color(hex: "#F97316") : Color.white.opacity(0.08))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.white.opacity(0.08), lineWidth: 0.8)
            )
        }
        .buttonStyle(.plain)
        .pressable()
    }
}

private struct HomeHeroCityStat: View {
    let value: String
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .semibold, design: .default))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.55)
                .contentTransition(.numericText())

            Text(title)
                .font(.system(size: 9.5, weight: .semibold, design: .default))
                .foregroundStyle(Color.white.opacity(0.52))
                .textCase(.uppercase)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
    }
}

struct HomeHeroCityActions: View {
    let destination: AppDestination
    let exploreTitle: String
    let savedTitle: String
    let onOpenSaved: () -> Void

    var body: some View {
        ViewThatFits(in: .horizontal) {
            horizontal
            wrapped
        }
        .padding(.top, 4)
    }

    private var horizontal: some View {
        HStack(spacing: 10) {
            exploreLink

            Button(action: onOpenSaved) {
                Image(systemName: "bookmark")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 48, height: 48)
            }
            .buttonStyle(HomeSecondaryIconButtonStyle())
            .accessibilityLabel(savedTitle)
            .accessibilityIdentifier("home.hero.saveCity.icon")
        }
        .frame(maxWidth: 440)
    }

    private var wrapped: some View {
        VStack(spacing: 10) {
            exploreLink

            Button(action: onOpenSaved) {
                Label(savedTitle, systemImage: "bookmark")
                    .font(.system(size: 13, weight: .semibold, design: .default))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(HomeSecondaryIconButtonStyle())
            .accessibilityIdentifier("home.hero.saveCity.label")
        }
        .frame(maxWidth: 440)
    }

    private var exploreLink: some View {
        NavigationLink(value: destination) {
            Label(exploreTitle, systemImage: "arrow.right")
                .font(.system(size: 14, weight: .semibold, design: .default))
                .frame(maxWidth: .infinity, minHeight: 48)
        }
        .buttonStyle(HomePrimaryHeroButtonStyle())
        .contentShape(Rectangle())
        .accessibilityIdentifier("home.hero.exploreCity")
        .zIndex(2)
    }
}

struct HomeHeroQuickIntelligenceGrid: View {
    let emergencyTitle: String
    let emergencySubtitle: String
    let emergencyDestination: AppDestination
    let weatherTitle: String
    let weatherSubtitle: String
    let aiTitle: String
    let aiSubtitle: String
    let onOpenWeather: () -> Void
    let onOpenAI: () -> Void

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: 8)], spacing: 8) {
            NavigationLink(value: emergencyDestination) {
                HomeHeroIntelligenceTile(
                    icon: "phone.fill",
                    title: emergencyTitle,
                    subtitle: emergencySubtitle,
                    tint: AppColors.error
                )
            }
            .buttonStyle(NLTileButtonStyle())
            .accessibilityIdentifier("home.hero.shortcut.emergency")

            Button(action: onOpenWeather) {
                HomeHeroIntelligenceTile(
                    icon: "cloud.sun.fill",
                    title: weatherTitle,
                    subtitle: weatherSubtitle,
                    tint: AppColors.warning
                )
            }
            .buttonStyle(NLTileButtonStyle())
            .accessibilityIdentifier("home.hero.shortcut.weather")

            Button(action: onOpenAI) {
                HomeHeroIntelligenceTile(
                    icon: "sparkles",
                    title: aiTitle,
                    subtitle: aiSubtitle,
                    tint: AppColors.violet
                )
            }
            .buttonStyle(NLTileButtonStyle())
            .accessibilityIdentifier("home.hero.shortcut.ai")
        }
        .frame(maxWidth: 520)
    }
}

private struct HomeHeroIntelligenceTile: View {
    let icon: String
    let title: String
    let subtitle: String
    let tint: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(tint)
                .frame(width: 30, height: 30)
                .background(tint.opacity(0.16))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)

                Text(subtitle)
                    .font(.system(size: 9.5, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.62))
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
            }

            Spacer(minLength: 0)
        }
        .padding(9)
        .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
        .background(Color.black.opacity(0.28))
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous).stroke(tint.opacity(0.24), lineWidth: 0.8))
    }
}

struct HomeWelcomeHeroActions: View {
    let provinceTitle: String
    let cityTitle: String
    let journeyTitle: String
    let cityDestination: AppDestination

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 8) {
                actionButtons
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                actionButtons
            }
        }
    }

    @ViewBuilder
    private var actionButtons: some View {
        NavigationLink(value: AppDestination.provinceList) {
            Label(provinceTitle, systemImage: "map.fill")
        }
        .buttonStyle(HomeHeroButtonStyle(tint: AppColors.cyanGlow))

        NavigationLink(value: cityDestination) {
            Label(cityTitle, systemImage: "building.2.fill")
        }
        .buttonStyle(HomeHeroButtonStyle(tint: AppColors.softBlue))

        NavigationLink(value: AppDestination.checklistList) {
            Label(journeyTitle, systemImage: "figure.walk")
        }
        .buttonStyle(HomeHeroButtonStyle(tint: AppColors.dutchOrange))
    }
}

struct HomeWelcomeHeroTopBar: View {
    let title: String
    let tagline: String
    let currentTime: String
    let fullDate: String
    let dynamicTypeSize: DynamicTypeSize

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 14 : 11, weight: .black, design: .rounded))
                    .foregroundStyle(AppColors.cyanGlow)
                    .textCase(.uppercase)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
                    .fixedSize(horizontal: false, vertical: true)

                Text(tagline)
                    .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 16 : 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.72))
                    .lineLimit(2)
                    .minimumScaleFactor(0.84)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 2) {
                Text(currentTime)
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                Text(fullDate)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.60))
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
}

struct HomeWelcomeHeroCityCopy: View {
    let cityName: String
    let provinceName: String
    let cityDescription: String
    let dynamicTypeSize: DynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(cityName)
                .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 36 : 40, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.66)

            HStack(spacing: 6) {
                Circle()
                    .fill(AppColors.cyanGlow)
                    .frame(width: 6, height: 6)

                Text(provinceName)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.cyanGlow)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }

            Text(cityDescription)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.72))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
