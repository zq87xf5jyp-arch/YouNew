import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct LandmarkImageBadge: View {
    let assetName: String?
    let fallbackSymbol: String
    var size: CGFloat = 58
    var cornerRadius: CGFloat = 17
    var isSelected: Bool = false

    @Environment(\.colorScheme) private var colorScheme

    private var hasAsset: Bool {
        guard let assetName else { return false }
        return Self.assetExists(named: assetName)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.white.opacity(colorScheme == .dark ? 0.10 : 0.64))

            if let assetName, hasAsset {
                Image(assetName)
                    .resizable()
                    .scaledToFill()
                    .overlay {
                        LinearGradient(
                            colors: [.clear, Color.black.opacity(0.34)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
            } else {
                LinearGradient(
                    colors: [
                        Color(red: 33/255, green: 70/255, blue: 139/255).opacity(colorScheme == .dark ? 0.72 : 0.62),
                        Color(red: 174/255, green: 28/255, blue: 40/255).opacity(colorScheme == .dark ? 0.46 : 0.40),
                        Color(red: 238/255, green: 247/255, blue: 250/255).opacity(colorScheme == .dark ? 0.12 : 0.36)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Image(systemName: fallbackSymbol)
                    .font(.system(size: size * 0.36, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.92))
            }

            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(colorScheme == .dark ? 0.16 : 0.34), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Color.white.opacity(colorScheme == .dark ? 0.22 : 0.52), lineWidth: 0.8)
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.28 : 0.13), radius: 12, x: 0, y: 7)
        .accessibilityHidden(true)
    }

    private static func assetExists(named name: String) -> Bool {
        #if canImport(UIKit)
        return UIImage(named: name) != nil
        #elseif canImport(AppKit)
        return NSImage(named: name) != nil
        #else
        return false
        #endif
    }
}

struct PremiumNetherlandsCard<Content: View>: View {
    var cornerRadius: CGFloat = 26
    var accent: Color = Color(red: 34/255, green: 199/255, blue: 217/255)
    var isSelected: Bool = false
    @ViewBuilder let content: Content

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        content
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            colorScheme == .dark
                                ? Color(red: 18/255, green: 31/255, blue: 54/255).opacity(isSelected ? 0.94 : 0.84)
                                : Color(red: 250/255, green: 253/255, blue: 255/255).opacity(isSelected ? 1.0 : 0.985)
                        )
                    if !reduceTransparency {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(.regularMaterial)
                            .opacity(colorScheme == .dark ? 0.18 : 0.42)
                    }
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(colorScheme == .dark ? 0.10 : 0.34),
                                    accent.opacity(isSelected ? 0.15 : (colorScheme == .dark ? 0.055 : 0.085)),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(colorScheme == .dark ? 0.24 : 0.50),
                                accent.opacity(isSelected ? 0.62 : (colorScheme == .dark ? 0.24 : 0.34)),
                                AppColors.stroke.opacity(colorScheme == .dark ? 0.44 : 0.92)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isSelected ? 1.2 : (colorScheme == .dark ? 0.85 : 1.0)
                    )
            }
            .shadow(color: isSelected ? accent.opacity(0.20) : Color.black.opacity(colorScheme == .dark ? 0.24 : 0.20), radius: isSelected ? 22 : 18, x: 0, y: isSelected ? 12 : 10)
            .shadow(color: colorScheme == .dark ? .clear : Color.black.opacity(0.07), radius: 5, x: 0, y: 2)
    }
}

extension View {
    func premiumNetherlandsCard(
        cornerRadius: CGFloat = 26,
        accent: Color = Color(red: 34/255, green: 199/255, blue: 217/255),
        isSelected: Bool = false
    ) -> some View {
        PremiumNetherlandsCard(cornerRadius: cornerRadius, accent: accent, isSelected: isSelected) {
            self
        }
    }
}

// MARK: - Visual Asset System

enum CityVisualAsset {
    case hero(String)
    case flag(String)
    case coatOfArms(String)
    case landmark(String)

    var name: String {
        switch self {
        case .hero(let name), .flag(let name), .coatOfArms(let name), .landmark(let name):
            return name
        }
    }
}

enum ProvinceVisualAsset {
    case hero(String)
    case flag(String)
    case map(String)

    var name: String {
        switch self {
        case .hero(let name), .flag(let name), .map(let name):
            return name
        }
    }
}

enum CategoryVisualAsset {
    case hero(String)
    case illustration(String)

    var name: String {
        switch self {
        case .hero(let name), .illustration(let name):
            return name
        }
    }
}

enum GeneratedFallbackArtwork {
    case city(name: String, symbol: String, accent: Color)
    case province(id: String, accent: Color)
    case category(symbol: String, accent: Color)
}

enum VisualAssetHelper {
    private static var cache: [String: Bool] = [:]
    private static let lock = NSLock()

    static func exists(_ name: String?) -> Bool {
        guard let name, !name.isEmpty else { return false }

        lock.lock()
        if let cached = cache[name] {
            lock.unlock()
            return cached
        }
        lock.unlock()

        #if canImport(UIKit)
        let result = UIImage(named: name) != nil
        #elseif canImport(AppKit)
        let result = NSImage(named: name) != nil
        #else
        let result = false
        #endif

        lock.lock()
        cache[name] = result
        lock.unlock()
        return result
    }
}

struct DutchFlagRibbon: View {
    var opacity: Double = 0.78

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                AppColors.dutchRed
                Color.white
                Color(red: 33/255, green: 70/255, blue: 139/255)
            }
            .opacity(opacity)
            .frame(width: proxy.size.width * 1.18, height: proxy.size.height * 0.34)
            .clipShape(RoundedRectangle(cornerRadius: proxy.size.height * 0.08, style: .continuous))
            .rotationEffect(.degrees(-12))
            .offset(x: -proxy.size.width * 0.12, y: proxy.size.height * 0.04)
        }
        .allowsHitTesting(false)
    }
}

struct AbstractCanalLines: View {
    var color: Color = AppColors.routeLine
    var lineCount: Int = 4

    var body: some View {
        Canvas { context, size in
            for index in 0..<lineCount {
                let y = size.height * (0.56 + CGFloat(index) * 0.085)
                var path = Path()
                path.move(to: CGPoint(x: -12, y: y))
                path.addCurve(
                    to: CGPoint(x: size.width + 12, y: y + CGFloat(index.isMultiple(of: 2) ? 8 : -6)),
                    control1: CGPoint(x: size.width * 0.28, y: y - 18),
                    control2: CGPoint(x: size.width * 0.68, y: y + 22)
                )
                context.stroke(path, with: .color(color.opacity(0.22 - Double(index) * 0.025)), lineWidth: 2.2)
            }
        }
        .allowsHitTesting(false)
    }
}

struct MiniSkylineGraphic: View {
    var accent: Color = AppColors.softBlue

    var body: some View {
        Canvas { context, size in
            let heights: [CGFloat] = [0.35, 0.52, 0.42, 0.64, 0.46, 0.58, 0.38, 0.50]
            let slot = size.width / CGFloat(heights.count)
            for (index, heightRatio) in heights.enumerated() {
                let width = slot * 0.68
                let height = size.height * heightRatio
                let x = CGFloat(index) * slot + slot * 0.16
                let y = size.height - height
                let rect = CGRect(x: x, y: y, width: width, height: height)
                context.fill(Path(roundedRect: rect, cornerRadius: 3), with: .color(Color.white.opacity(0.14)))
                context.stroke(Path(roundedRect: rect, cornerRadius: 3), with: .color(accent.opacity(0.20)), lineWidth: 0.8)
            }
        }
        .allowsHitTesting(false)
    }
}

struct ProvinceMapSilhouette: View {
    var provinceID: String?
    var accent: Color

    var body: some View {
        ProvinceHighlightMapView(
            provinceID: provinceID,
            highlightColor: accent,
            showLabels: false
        )
        .padding(8)
        .background(AppColors.navyDeep.opacity(0.30))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct LandmarkSymbolBadge: View {
    let symbol: String
    var accent: Color = AppColors.accentLight
    var size: CGFloat = 44

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: size * 0.42, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                        .fill(accent.opacity(0.26))
                    RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                        .fill(AppSurface.base.opacity(0.22))
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                    .stroke(Color.white.opacity(0.22), lineWidth: 0.75)
            )
    }
}

struct GlassImageBadge<Content: View>: View {
    var size: CGFloat = 58
    var cornerRadius: CGFloat = 16
    var accent: Color = AppColors.accentLight
    @ViewBuilder let content: Content

    var body: some View {
        content
            .frame(width: size, height: size)
            .background(AppColors.glassSurfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.26), accent.opacity(0.22), Color.white.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            )
            .shadow(color: Color.black.opacity(0.18), radius: 12, x: 0, y: 7)
    }
}

struct GlassVisualBadge<Content: View>: View {
    var size: CGFloat = 58
    var cornerRadius: CGFloat = 16
    var accent: Color = AppColors.accentLight
    @ViewBuilder let content: Content

    var body: some View {
        GlassImageBadge(size: size, cornerRadius: cornerRadius, accent: accent) {
            content
        }
    }
}

struct ProvinceMapMiniGraphic: View {
    var provinceID: String?
    var accent: Color = AppColors.softBlue

    var body: some View {
        ProvinceMapSilhouette(provinceID: provinceID, accent: accent)
    }
}

struct CityHeroVisual: View {
    let assetName: String?
    let cityName: String
    var symbol: String = "building.2.fill"
    var accent: Color = AppColors.accentLight

    var body: some View {
        ZStack {
            if VisualAssetHelper.exists(assetName), let assetName {
                Image(assetName)
                    .resizable()
                    .scaledToFill()
            } else {
                GeneratedCityArtwork(cityName: cityName, symbol: symbol, accent: accent)
            }
        }
        .clipped()
    }
}

struct LandmarkCard: View {
    let title: String
    let description: String
    let symbol: String
    var assetName: String? = nil
    var accent: Color = AppColors.accentLight

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .bottomLeading) {
                if VisualAssetHelper.exists(assetName), let assetName {
                    Image(assetName)
                        .resizable()
                        .scaledToFill()
                } else {
                    GeneratedCategoryArtwork(symbol: symbol, accent: accent)
                }

                LandmarkSymbolBadge(symbol: symbol, accent: accent, size: 38)
                    .padding(10)
            }
            .frame(height: 96)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                Text(description)
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 196, alignment: .topLeading)
        .background(AppColors.glassSurface.opacity(0.76))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 0.75)
        )
    }
}

struct CategoryHeroVisual: View {
    let assetName: String?
    let title: String
    let subtitle: String
    let symbol: String
    var badgeText: String? = nil
    var accent: Color = AppColors.accentLight
    var imageURL: URL? = nil
    var asset: AppImageAsset? = nil
    var height: CGFloat = 220
    var language: AppLanguage = .english

    var body: some View {
        let resolvedHeight = min(max(height, 220), 320)

        ZStack(alignment: .bottomLeading) {
            AppContentImageView(
                asset: resolvedHeroAsset,
                language: language,
                mode: .fill,
                accent: accent,
                aspectRatio: nil,
                cornerRadius: 0,
                showsCaption: false,
                showsSourceButton: false,
                accessibilityLabel: accessibilityLabel,
                fallbackURLs: fallbackRemoteURLs,
                fallbackLocalAssetName: fallbackLocalAssetName,
                fallbackSymbol: symbol,
                debugContext: nil,
                targetPixelWidth: 1200
            )
            .frame(maxWidth: .infinity, minHeight: resolvedHeight, maxHeight: resolvedHeight)
            .clipped()
            .accessibilityHidden(true)

            LinearGradient(
                colors: [
                    Color.black.opacity(0.10),
                    Color.black.opacity(0.35),
                    Color.black.opacity(0.65)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            RadialGradient(
                colors: [
                    AppColors.navyDeep.opacity(0.42),
                    AppColors.navyDeep.opacity(0.22),
                    Color.clear
                ],
                center: .bottomLeading,
                startRadius: 0,
                endRadius: 260
            )
            .allowsHitTesting(false)

            LinearGradient(
                colors: [
                    Color.white.opacity(0.06),
                    Color.clear,
                    accent.opacity(0.10)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            GeometryReader { proxy in
                let availableTextWidth = max(0, proxy.size.width - AppSpacing.cardPadding * 2 - 18)
                let textWidth = proxy.size.width < 1_000
                    ? min(availableTextWidth, 430)
                    : max(320, min(availableTextWidth, 640))

                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    LandmarkSymbolBadge(symbol: symbol, accent: accent, size: 48)
                        .accessibilityHidden(true)
                    textStack
                        .frame(width: textWidth, alignment: .leading)
                }
                .padding(AppSpacing.cardPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
        }
        .frame(height: resolvedHeight, alignment: .bottomLeading)
        .frame(maxWidth: .infinity, alignment: .bottomLeading)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.hero, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.hero, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.26), accent.opacity(0.22), Color.white.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.85
                )
        )
        .shadow(color: accent.opacity(0.16), radius: 22, x: 0, y: 0)
        .shadow(color: Color.black.opacity(0.24), radius: 20, x: 0, y: 12)
    }

    private var accessibilityLabel: String {
        if let asset = resolvedHeroAsset {
            return asset.displayTitle(language)
        }
        return title
    }

    private var resolvedHeroAsset: AppImageAsset? {
        if let asset {
            return asset
        }
        if let assetName, VisualAssetHelper.exists(assetName) {
            return AppImageAsset(
                id: "category-local-\(assetName)",
                url: nil,
                localAssetName: assetName,
                title: title,
                sourceName: "YouNew",
                sourceURL: nil,
                license: nil,
                attribution: nil,
                width: nil,
                height: nil,
                type: .homeHero,
                verified: true
            )
        }
        if let imageURL {
            return AppImageAsset(
                id: "category-remote-\(abs(imageURL.absoluteString.hashValue))",
                url: imageURL,
                title: title,
                sourceName: "Verified remote image",
                sourceURL: imageURL,
                license: nil,
                attribution: nil,
                width: nil,
                height: nil,
                type: .homeHero,
                verified: true
            )
        }
        return fallbackHeroAsset
    }

    private var fallbackLocalAssetName: String {
        if let localAssetName = fallbackHeroAsset?.localAssetName,
           VisualAssetHelper.exists(localAssetName) {
            return localAssetName
        }
        return CuratedPlaceHeroMediaRegistry.bundledNeutralFallbackAssetName
    }

    private var fallbackRemoteURLs: [URL] {
        guard let fallbackHeroAsset else { return [] }
        var seen = Set<String>()
        return [
            fallbackHeroAsset.thumbnailURL,
            fallbackHeroAsset.imageURL,
            fallbackHeroAsset.url,
            fallbackHeroAsset.originalFileURL
        ]
        .compactMap { $0 }
        .filter { seen.insert($0.absoluteString).inserted }
    }

    private var fallbackHeroAsset: AppImageAsset? {
        let lowerSymbol = symbol.lowercased()
        let lowerBadge = badgeText?.lowercased() ?? ""

        let candidate: AppImageAsset?
        if lowerSymbol.contains("phone") || lowerSymbol.contains("exclamationmark") || lowerSymbol.contains("siren") || lowerBadge.contains("112") || lowerBadge.contains("emergency") {
            candidate = ContentMediaRegistry.emergencyImage
        } else if lowerSymbol.contains("cross") || lowerSymbol.contains("stethoscope") || lowerSymbol.contains("heart") {
            candidate = ContentMediaRegistry.healthcarePharmacyImage
        } else if lowerSymbol.contains("tram") || lowerSymbol.contains("bus") || lowerSymbol.contains("car") || lowerSymbol.contains("bicycle") {
            candidate = ContentMediaRegistry.transportStationHero ?? ContentMediaRegistry.transportHero
        } else if lowerSymbol.contains("house") {
            candidate = ContentMediaRegistry.premiumHousingImage ?? ContentMediaRegistry.housingTerracedHousesImage
        } else if lowerSymbol.contains("briefcase") || lowerSymbol.contains("wrench") || lowerSymbol.contains("hammer") || lowerBadge.contains("work") {
            candidate = ContentMediaRegistry.workImage
        } else if lowerSymbol.contains("fork") || lowerSymbol.contains("cup") || lowerBadge.contains("food") {
            candidate = ContentMediaRegistry.foodImage
        } else if lowerSymbol.contains("leaf") || lowerSymbol.contains("tree") || lowerSymbol.contains("sun") || lowerBadge.contains("nature") {
            candidate = ContentMediaRegistry.natureImage
        } else if lowerSymbol.contains("calendar") || lowerBadge.contains("event") {
            candidate = ContentMediaRegistry.calendarImage
        } else if lowerSymbol.contains("rectangle.grid") {
            candidate = ContentMediaRegistry.searchImage ?? ContentMediaRegistry.mapImage
        } else if lowerSymbol.contains("gearshape") || lowerBadge.contains("settings") {
            candidate = ContentMediaRegistry.profileImage ?? ContentMediaRegistry.savedImage
        } else if lowerSymbol.contains("building.columns") || lowerSymbol.contains("person.badge") || lowerSymbol.contains("doc") {
            candidate = ContentMediaRegistry.municipalityCityHallImage
        } else if lowerSymbol.contains("book") || lowerSymbol.contains("graduationcap") || lowerBadge.contains("knm") || lowerBadge.contains("a1") {
            candidate = ContentMediaRegistry.leidenCanalsHero ?? ContentMediaRegistry.officialSourcesHero
        } else if lowerSymbol.contains("paintpalette") || lowerSymbol.contains("theatermasks") || lowerSymbol.contains("crown") || lowerSymbol.contains("star") {
            candidate = ContentMediaRegistry.cultureHero
        } else if lowerSymbol.contains("map") || lowerSymbol.contains("globe") {
            candidate = ContentMediaRegistry.mapImage ?? ContentMediaRegistry.officialSourcesHero
        } else if lowerSymbol.contains("sparkles") || lowerSymbol.contains("wand") || lowerBadge.contains("ai") {
            candidate = ContentMediaRegistry.aiImage
        } else if lowerSymbol.contains("magnifyingglass") {
            candidate = ContentMediaRegistry.searchImage
        } else if lowerSymbol.contains("bookmark") || lowerSymbol.contains("heart") {
            candidate = ContentMediaRegistry.savedImage
        } else if lowerSymbol.contains("person.crop.circle") {
            candidate = ContentMediaRegistry.profileImage
        } else if lowerSymbol.contains("building.2") || lowerSymbol.contains("mappin") {
            candidate = ContentMediaRegistry.officialSourcesHero
        } else {
            candidate = nil
        }

        guard candidate?.id != asset?.id else { return nil }
        return candidate
    }

    private var textStack: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let badgeText {
                Text(badgeText.uppercased())
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(AppColors.orangeGlow)
                    .lineLimit(2)
                    .minimumScaleFactor(0.74)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text(title)
                .font(.system(size: 27, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(3)
                .minimumScaleFactor(0.82)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(subtitle)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.84))
                .lineLimit(4)
                .minimumScaleFactor(0.84)
                .allowsTightening(true)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .layoutPriority(1)
    }
}

struct PremiumSectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var symbol: String? = nil
    var accent: Color = AppColors.accentLight

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if let symbol {
                LandmarkSymbolBadge(symbol: symbol, accent: accent, size: 34)
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.84)
                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(.subheadline, design: .rounded).weight(.medium))
                        .foregroundStyle(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: 6)
        }
        .accessibilityElement(children: .combine)
    }
}

struct GlassMetricCard: View {
    let value: String
    let label: String
    let symbol: String
    var accent: Color = AppColors.accentLight

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            LandmarkSymbolBadge(symbol: symbol, accent: accent, size: 34)
                .accessibilityHidden(true)
            Text(value)
                .font(.system(.title3, design: .rounded).weight(.bold))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.76)
            Text(label)
                .font(.system(.caption, design: .rounded).weight(.semibold))
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 124, alignment: .topLeading)
        .background(AppColors.glassSurface.opacity(0.76))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 0.75)
        )
    }
}

struct OfficialSourceVisualCard: View {
    let title: String
    let subtitle: String
    let detail: String
    var symbol: String = "building.columns.fill"
    var accent: Color = AppColors.success
    var asset: AppImageAsset? = nil
    var language: AppLanguage = .english
    var fallbackCategory: PremiumImageFallbackCategory = .government

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            PremiumImageHeader(
                title: title,
                asset: asset,
                language: language,
                symbol: symbol,
                accent: accent,
                height: 92,
                width: 104,
                cornerRadius: 18,
                fallbackCategory: fallbackCategory
            )

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                Text(subtitle)
                    .font(.system(.caption, design: .rounded).weight(.bold))
                    .foregroundStyle(accent)
                    .lineLimit(2)
                Text(detail)
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 128, alignment: .topLeading)
        .background(AppColors.glassSurface.opacity(0.76))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 0.75)
        )
    }
}

struct VisualEmptyState: View {
    let title: String
    let detail: String
    let symbol: String
    var accent: Color = AppColors.accentLight
    var suggestedActions: [String] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 13) {
                GlassVisualBadge(size: 58, cornerRadius: 18, accent: accent) {
                    GeneratedCategoryArtwork(symbol: symbol, accent: accent)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(.headline, design: .rounded).weight(.bold))
                        .foregroundStyle(AppColors.textPrimary)
                    Text(detail)
                        .font(.system(.subheadline, design: .rounded).weight(.medium))
                        .foregroundStyle(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            if !suggestedActions.isEmpty {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 112), spacing: 8)], alignment: .leading, spacing: 8) {
                    ForEach(suggestedActions, id: \.self) { action in
                        Text(action)
                            .font(.system(.caption, design: .rounded).weight(.bold))
                            .foregroundStyle(AppColors.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.82)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .frame(maxWidth: .infinity)
                            .background(accent.opacity(0.14))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(accent.opacity(0.20), lineWidth: 0.7))
                    }
                }
            }
        }
        .padding(16)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(AppColors.glassSurfaceElevated.opacity(0.82))
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                accent.opacity(0.11),
                                Color.white.opacity(0.035),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RadialGradient(
                    colors: [accent.opacity(0.10), .clear],
                    center: .topTrailing,
                    startRadius: 0,
                    endRadius: 190
                )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.17), accent.opacity(0.18), Color.white.opacity(0.06)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.8
                )
        )
        .shadow(color: accent.opacity(0.08), radius: 18, x: 0, y: 10)
        .accessibilityElement(children: .combine)
    }
}

struct GeneratedCityArtwork: View {
    let cityName: String
    var symbol: String = "building.2.fill"
    var accent: Color = AppColors.accentLight

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.navyDeep, accent.opacity(0.72), AppColors.graphite],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            DutchFlagRibbon(opacity: 0.42)
                .blur(radius: 0.5)
            RadialGradient(colors: [AppColors.cyanGlow.opacity(0.20), .clear], center: .topTrailing, startRadius: 0, endRadius: 220)
            RadialGradient(colors: [AppColors.orangeGlow.opacity(0.12), .clear], center: .bottomLeading, startRadius: 0, endRadius: 180)
            MiniSkylineGraphic(accent: accent)
                .frame(height: 128)
                .padding(.horizontal, 22)
                .frame(maxHeight: .infinity, alignment: .center)
            AbstractCanalLines(color: AppColors.routeLine, lineCount: 4)
            LandmarkSymbolBadge(symbol: symbol, accent: accent, size: 62)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(22)
            Text(String(cityName.prefix(2)).uppercased())
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.18))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(24)
        }
    }
}

struct GeneratedProvinceArtwork: View {
    let provinceID: String
    var accent: Color = AppColors.softBlue

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.heroMid, accent.opacity(0.54), AppColors.navyDeep],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            DutchFlagRibbon(opacity: 0.34)
            RadialGradient(colors: [accent.opacity(0.24), .clear], center: .topTrailing, startRadius: 0, endRadius: 240)
            ProvinceMapSilhouette(provinceID: provinceID, accent: accent)
                .padding(24)
            AbstractCanalLines(color: AppColors.routeLine, lineCount: 3)
                .opacity(0.70)
        }
    }
}

struct GeneratedCategoryArtwork: View {
    let symbol: String
    var accent: Color = AppColors.accentLight

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.graphite, accent.opacity(0.42), AppColors.navyDeep],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            DutchFlagRibbon(opacity: 0.26)
            Circle()
                .fill(AppColors.cyanGlow.opacity(0.12))
                .frame(width: 92, height: 92)
                .offset(x: 42, y: -34)
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppColors.orangeGlow.opacity(0.12))
                .frame(width: 72, height: 42)
                .rotationEffect(.degrees(-18))
                .offset(x: -42, y: 36)
            LandmarkSymbolBadge(symbol: symbol, accent: accent, size: 58)
        }
    }
}
