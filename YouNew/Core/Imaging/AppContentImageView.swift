import SwiftUI
#if canImport(UIKit)
import ImageIO
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

enum AppContentImageMode {
    case fill
    case fit
}

enum PremiumImageOverlayStyle {
    case none
    case balanced
    case subtle

    var gradient: LinearGradient? {
        switch self {
        case .none:
            return nil
        case .balanced:
            return LinearGradient(
                colors: [
                    Color.black.opacity(0.10),
                    Color.black.opacity(0.35),
                    Color.black.opacity(0.65)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .subtle:
            return LinearGradient(
                colors: [
                    Color.black.opacity(0.04),
                    Color.black.opacity(0.18),
                    Color.black.opacity(0.42)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

enum PremiumImageFallbackCategory {
    case documents
    case housing
    case healthcare
    case transport
    case government
    case dutchA1A2
    case emergency
    case work
    case integration
    case map
    case search
    case ai
    case city
    case province
    case nearbyHelp

    var symbol: String {
        switch self {
        case .documents: return "doc.text.fill"
        case .housing: return "house.fill"
        case .healthcare: return "cross.case.fill"
        case .transport: return "tram.fill"
        case .government: return "building.columns.fill"
        case .dutchA1A2: return "text.book.closed.fill"
        case .emergency: return "cross.case.circle.fill"
        case .work: return "briefcase.fill"
        case .integration: return "person.2.wave.2.fill"
        case .map: return "map.fill"
        case .search: return "magnifyingglass.circle.fill"
        case .ai: return "sparkles.rectangle.stack.fill"
        case .city: return "building.2.fill"
        case .province: return "leaf.fill"
        case .nearbyHelp: return "mappin.and.ellipse"
        }
    }

    var accent: Color {
        switch self {
        case .documents, .government: return AppColors.softBlue
        case .housing, .city: return AppColors.cyanGlow
        case .healthcare, .nearbyHelp: return AppColors.success
        case .transport, .map: return AppColors.routeLine
        case .dutchA1A2, .ai: return AppColors.violet
        case .emergency: return AppColors.warning
        case .work: return AppColors.dutchOrange
        case .integration, .province: return AppColors.emerald
        case .search: return AppColors.accentBlue
        }
    }

    var fallbackLocalAssetName: String {
        switch self {
        case .documents, .government:
            return "home_documents_city_hall"
        case .housing:
            return "premium_home_housing"
        case .healthcare:
            return "home_healthcare_pharmacy"
        case .transport, .map:
            return "netherlands_map_base"
        case .work:
            return "home_work_zuidas"
        case .emergency:
            return "home_emergency_ambulance"
        case .dutchA1A2:
            return "home_language_classroom"
        case .integration, .ai:
            return "premium_home_language"
        case .search:
            return "netherlands_map_base"
        case .city:
            return "netherlands_map_base"
        case .province:
            return "netherlands_map_provinces"
        case .nearbyHelp:
            return "home_emergency_ambulance"
        }
    }
}

struct PremiumImageView: View {
    let asset: AppImageAsset?
    let language: AppLanguage
    var height: CGFloat? = nil
    var aspectRatio: CGFloat? = 16.0 / 9.0
    var mode: AppContentImageMode = .fill
    var cornerRadius: CGFloat = AppCornerRadius.large
    var overlayStyle: PremiumImageOverlayStyle = .none
    var fallbackCategory: PremiumImageFallbackCategory = .city
    var accessibilityLabel: String? = nil
    var targetPixelWidth: CGFloat? = nil
    var role: PremiumImageRole = .card
    var overlayPolicy: PremiumImageOverlayPolicy = .none
    var focalPoint: PremiumImageFocalPoint = .center

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                AppContentImageView(
                    asset: asset,
                    language: language,
                    mode: mode,
                    accent: fallbackCategory.accent,
                    aspectRatio: nil,
                    cornerRadius: 0,
                    showsCaption: false,
                    showsSourceButton: false,
                    accessibilityLabel: accessibilityLabel,
                    fallbackLocalAssetName: fallbackCategory.fallbackLocalAssetName,
                    fallbackSymbol: fallbackCategory.symbol,
                    targetPixelWidth: targetPixelWidth ?? role.defaultTargetPixelWidth,
                    focalPoint: focalPoint
                )
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()

                if let gradient = overlayStyle.gradient {
                    gradient
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .allowsHitTesting(false)
                }

                if let gradient = overlayPolicy.gradient(role: role, asset: asset) {
                    gradient
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .allowsHitTesting(false)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
        .premiumImageStableFrame(height: height, aspectRatio: aspectRatio ?? role.defaultAspectRatio)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .contentShape(Rectangle())
        .clipped()
        .accessibilityLabel(accessibilityLabel ?? asset?.displayTitle(language) ?? fallbackCategory.symbol)
    }
}

struct AppContentImageView: View {
    let asset: AppImageAsset?
    let language: AppLanguage
    var mode: AppContentImageMode = .fill
    var accent: Color = AppColors.cyanGlow
    var aspectRatio: CGFloat? = 16.0 / 9.0
    var cornerRadius: CGFloat = AppCornerRadius.large
    var showsCaption = true
    var showsSourceButton = false
    var accessibilityLabel: String? = nil
    var fallbackURLs: [URL] = []
    var fallbackLocalAssetName: String = CuratedPlaceHeroMediaRegistry.bundledNeutralFallbackAssetName
    var fallbackSymbol: String = "sparkles.rectangle.stack.fill"
    var debugContext: ImageDebugContext? = nil
    var targetPixelWidth: CGFloat? = nil
    var focalPoint: PremiumImageFocalPoint = .center
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(alignment: .leading, spacing: showsCaption ? 8 : 0) {
            ZStack {
                if let asset, asset.verified {
                    content(for: asset)
                } else {
                    fallback
                }
            }
            .contentImageFrame(aspectRatio)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.14), lineWidth: 0.8)
            )
            .accessibilityLabel(accessibilityLabel ?? asset?.displayTitle(language) ?? fallbackTitle)

            if showsCaption {
                captionView(asset)
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .clipped()
    }

    @ViewBuilder
    private func content(for asset: AppImageAsset) -> some View {
        if let localAssetName = asset.localAssetName, VisualAssetHelper.exists(localAssetName) {
            Image(localAssetName)
                .resizable()
                .contentShape(Rectangle())
                .modifier(AppContentImageSizing(mode: mode, focalPoint: focalPoint))
        } else if let url = asset.thumbnailURL ?? asset.imageURL ?? asset.url {
            remoteImage(url: url, fallbackURLs: ([asset.originalFileURL] + fallbackURLs).compactMap { $0 })
        } else {
            fallback
        }
    }

    @ViewBuilder
    private func remoteImage(url: URL, fallbackURLs: [URL]) -> some View {
        CachedRemoteContentImage(url: url, fallbackURLs: fallbackURLs, targetPixelSize: remoteTargetPixelSize, loading: loading, fallback: fallback, debugContext: debugContext) { image in
            image
                .modifier(AppContentImageSizing(mode: mode, focalPoint: focalPoint))
        }
    }

    private var remoteTargetPixelSize: CGSize {
        let width = targetPixelWidth ?? 1200
        let ratio = aspectRatio ?? (16.0 / 9.0)
        return CGSize(width: width, height: max(360, width / max(0.75, ratio)))
    }

    private var loading: some View {
        ContentSkeletonView()
    }

    private var fallback: some View {
        ZStack {
            if VisualAssetHelper.exists(fallbackLocalAssetName) {
                Image(fallbackLocalAssetName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                fallbackBackground.opacity(0.20)
            } else {
                fallbackBackground
                GeneratedCategoryArtwork(symbol: "photo.on.rectangle.angled", accent: accent)
                    .opacity(0.24)
                    .padding(18)

                Image(systemName: fallbackSymbol)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(accent.opacity(0.82))
                    .frame(width: 54, height: 54)
                    .background(Color.white.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
                    .accessibilityLabel(imageUnavailableText)
            }
        }
    }

    private var fallbackBackground: some View {
        LinearGradient(
            colors: [
                AppColors.graphite.opacity(0.94),
                accent.opacity(0.20),
                AppSurface.base.opacity(0.84)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var fallbackTitle: String {
        switch language {
        case .english: return "Verified image"
        case .dutch: return "Geverifieerde afbeelding"
        case .russian: return "Проверенное изображение"
        }
    }

    private var imageUnavailableText: String {
        switch language {
        case .english: return L10n.t("image.unavailable", language)
        case .dutch: return L10n.t("image.unavailable", language)
        case .russian: return L10n.t("image.unavailable", language)
        }
    }

    @ViewBuilder
    private func captionView(_ asset: AppImageAsset?) -> some View {
        if let asset {
            VStack(alignment: .leading, spacing: 5) {
                Text(asset.displayTitle(language))
                    .font(.system(.caption, design: .rounded).weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(creditLine(asset))
                        .font(.system(.caption2, design: .rounded).weight(.medium))
                        .foregroundStyle(AppColors.textTertiary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 4)

                    if showsSourceButton, let sourceURL = AppURL.validatedWebURL(asset.sourcePageURL ?? asset.sourceURL) {
                        Button {
                            openURL(sourceURL)
                        } label: {
                            Label(L10n.t("image.openSource", language), systemImage: "arrow.up.right.square")
                                .labelStyle(.iconOnly)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(AppColors.accentLight)
                                .frame(width: AppButtonMetrics.minTouchSize, height: AppButtonMetrics.minTouchSize)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(AppPressableButtonStyle())
                        .accessibilityLabel(L10n.t("image.openSource", language))
                    }
                }
            }
        } else {
            Text(fallbackCaptionText)
                .font(.system(.caption2, design: .rounded).weight(.semibold))
                .foregroundStyle(AppColors.textTertiary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var fallbackCaptionText: String {
        switch language {
        case .english: return "Using a verified fallback visual. Check sources in the page before acting."
        case .dutch: return "Gebruikt een geverifieerde fallback-visual. Controleer bronnen op de pagina voordat je handelt."
        case .russian: return "Показан проверенный запасной визуальный контекст. Перед действием проверьте источники на странице."
        }
    }

    private func creditLine(_ asset: AppImageAsset) -> String {
        [asset.sourceName, asset.licenseName ?? asset.license].compactMap { value in
            guard let value, !value.isEmpty else { return nil }
            return value
        }.joined(separator: " · ")
    }
}

private struct CachedRemoteContentImage<Loading: View, Fallback: View, Content: View>: View {
    let url: URL
    let fallbackURLs: [URL]
    let targetPixelSize: CGSize
    let loading: Loading
    let fallback: Fallback
    let debugContext: ImageDebugContext?
    let content: (Image) -> Content

    private var cacheKey: String {
        ([url] + fallbackURLs).map(\.absoluteString).joined(separator: "|")
    }

    #if canImport(UIKit)
    @State private var image: UIImage?
    @State private var didFail = false
    @State private var loadedCacheKey = ""
    private static var imageCache: NSCache<NSString, UIImage> { RemoteImageCache.shared }

    var body: some View {
        Group {
            if let image {
                content(Image(uiImage: image))
                    .transition(.opacity.animation(.easeIn(duration: 0.24)))
            } else if didFail {
                fallback
            } else {
                loading
            }
        }
        .task(id: cacheKey) {
            await loadImage()
        }
    }

    @MainActor
    private func loadImage() async {
        if loadedCacheKey == cacheKey, image != nil, !didFail {
            return
        }

        didFail = false
        if loadedCacheKey != cacheKey {
            image = nil
        }

        for candidate in ([url] + fallbackURLs).uniquedByAbsoluteString() {
            let targetDimension = max(targetPixelSize.width, targetPixelSize.height)
            let diskCacheKey = ImageDiskThumbnailCache.cacheKey(urlString: candidate.absoluteString, targetWidth: targetDimension)
            if let cached = Self.imageCache.object(forKey: diskCacheKey as NSString) {
                ImageDebugLogger.log(
                    context: debugContext,
                    resolvedURL: candidate.absoluteString,
                    fallbackLevel: debugContext?.fallbackLevel ?? "app-content-cache",
                    cacheKey: diskCacheKey,
                    cacheHit: true
                )
                image = cached
                loadedCacheKey = cacheKey
                return
            }

            let diskImage = await ImageDiskThumbnailCache.readOffMain(
                urlString: candidate.absoluteString,
                targetWidth: targetDimension
            )

            if let diskImage {
                Self.imageCache.setObject(diskImage, forKey: diskCacheKey as NSString, cost: diskImage.memoryCost)
                ImageDebugLogger.log(
                    context: debugContext,
                    resolvedURL: candidate.absoluteString,
                    fallbackLevel: debugContext?.fallbackLevel ?? "app-content-disk-cache",
                    cacheKey: diskCacheKey,
                    cacheHit: true
                )
                image = diskImage
                loadedCacheKey = cacheKey
                return
            }

            let prepared = await RemoteContentImageFetchCoordinator.shared.image(for: diskCacheKey) {
                do {
                    var request = URLRequest(url: candidate, timeoutInterval: 12)
                    request.setValue("YouNew/1.0 (iOS; NetherlandsGuide)", forHTTPHeaderField: "User-Agent")
                    request.setValue("image/webp,image/jpeg,image/png,image/*,*/*;q=0.8", forHTTPHeaderField: "Accept")
                    request.cachePolicy = .useProtocolCachePolicy

                    let (data, response) = try await NetworkConfig.imageSession.data(for: request)
                    guard let httpResponse = response as? HTTPURLResponse,
                          httpResponse.statusCode == 200,
                          httpResponse.value(forHTTPHeaderField: "Content-Type")?.lowercased().hasPrefix("image/") == true
                    else {
                        return nil as UIImage?
                    }

                    guard let image = downsampledContentImage(from: data, maxPixelSize: targetDimension) else {
                        return nil
                    }

                    await ImageDiskThumbnailCache.writeOffMain(
                        image,
                        urlString: candidate.absoluteString,
                        targetWidth: targetDimension
                    )
                    return image
                } catch {
                    return nil
                }
            }
            guard let prepared else { continue }
            guard !Task.isCancelled else { return }
            Self.imageCache.setObject(prepared, forKey: diskCacheKey as NSString, cost: prepared.memoryCost)
            ImageDebugLogger.log(
                context: debugContext,
                resolvedURL: candidate.absoluteString,
                fallbackLevel: debugContext?.fallbackLevel ?? "app-content-remote",
                cacheKey: diskCacheKey,
                cacheHit: false
            )
            image = prepared
            loadedCacheKey = cacheKey
            return
        }

        didFail = true
        loadedCacheKey = cacheKey
    }
    #elseif canImport(AppKit)
    @State private var appKitImage: NSImage?
    @State private var appKitDidFail = false
    @State private var appKitLoadedCacheKey = ""

    var body: some View {
        Group {
            if let appKitImage {
                content(Image(nsImage: appKitImage).resizable())
                    .transition(.opacity.animation(.easeIn(duration: 0.24)))
            } else if appKitDidFail {
                fallback
            } else {
                loading
            }
        }
        .task(id: cacheKey) {
            await loadAppKitImage()
        }
    }

    @MainActor
    private func loadAppKitImage() async {
        if appKitLoadedCacheKey == cacheKey, appKitImage != nil, !appKitDidFail {
            return
        }

        appKitDidFail = false
        if appKitLoadedCacheKey != cacheKey {
            appKitImage = nil
        }

        for candidate in ([url] + fallbackURLs).uniquedByAbsoluteString() {
            let image = await Task.detached(priority: .utility) {
                do {
                    var request = URLRequest(url: candidate, timeoutInterval: 12)
                    request.setValue("YouNew/1.0 (macOS; NetherlandsGuide)", forHTTPHeaderField: "User-Agent")
                    request.setValue("image/webp,image/jpeg,image/png,image/*,*/*;q=0.8", forHTTPHeaderField: "Accept")
                    request.cachePolicy = .useProtocolCachePolicy

                    let (data, response) = try await NetworkConfig.imageSession.data(for: request)
                    guard let httpResponse = response as? HTTPURLResponse,
                          httpResponse.statusCode == 200,
                          httpResponse.value(forHTTPHeaderField: "Content-Type")?.lowercased().hasPrefix("image/") == true
                    else {
                        return nil as NSImage?
                    }
                    return NSImage(data: data)
                } catch {
                    return nil
                }
            }.value

            guard !Task.isCancelled else { return }
            if let image {
                appKitImage = image
                appKitLoadedCacheKey = cacheKey
                return
            }
        }

        appKitDidFail = true
        appKitLoadedCacheKey = cacheKey
    }
    #else
    var body: some View {
        Group {
            if fallbackURLs.isEmpty {
                loading
            } else {
                fallback
            }
        }
    }
    #endif
}

private extension Array where Element == URL {
    func uniquedByAbsoluteString() -> [URL] {
        var seen = Set<String>()
        return filter { url in
            seen.insert(url.absoluteString).inserted
        }
    }
}

#if canImport(UIKit)
private final class RemoteImageCache {
    static let shared: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 160
        cache.totalCostLimit = 80 * 1024 * 1024
        return cache
    }()
}

private actor RemoteContentImageFetchCoordinator {
    static let shared = RemoteContentImageFetchCoordinator()

    private var tasks: [String: Task<UIImage?, Never>] = [:]

    func image(for key: String, operation: @escaping @Sendable () async -> UIImage?) async -> UIImage? {
        if let existingTask = tasks[key] {
            return await existingTask.value
        }

        let task = Task<UIImage?, Never>.detached(priority: .utility) {
            await operation()
        }
        tasks[key] = task
        let result = await task.value
        tasks[key] = nil
        return result
    }
}

private extension UIImage {
    var memoryCost: Int {
        guard let cgImage else {
            return Int(size.width * size.height * scale * scale * 4)
        }
        return cgImage.bytesPerRow * cgImage.height
    }
}

nonisolated private func downsampledContentImage(from data: Data, maxPixelSize: CGFloat) -> UIImage? {
    guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
        return nil
    }

    let maxPixelSize = max(1, Int(maxPixelSize.rounded(.up)))
    let options: [CFString: Any] = [
        kCGImageSourceCreateThumbnailFromImageAlways: true,
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
    ]

    guard let thumbnail = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
        return nil
    }

    return UIImage(cgImage: thumbnail)
}
#endif

private extension View {
    @ViewBuilder
    func premiumImageStableFrame(height: CGFloat?, aspectRatio: CGFloat?) -> some View {
        if let height {
            self
                .frame(maxWidth: .infinity)
                .frame(height: height)
        } else if let aspectRatio {
            self
                .aspectRatio(aspectRatio, contentMode: .fit)
                .frame(maxWidth: .infinity)
        } else {
            self
                .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    func contentImageFrame(_ aspectRatio: CGFloat?) -> some View {
        if let aspectRatio {
            self
                .aspectRatio(aspectRatio, contentMode: .fit)
                .frame(maxWidth: .infinity)
        } else {
            self
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// Smooth left-to-right shimmer that fills the loading placeholder.
// Uses a moving gradient — zero network activity, zero GPU overhead at rest.
private struct ContentSkeletonView: View {
    @State private var phase: CGFloat = -1.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var shouldAnimate: Bool {
#if DEBUG
        !ProcessInfo.processInfo.arguments.contains("-uiTesting") && !reduceMotion
#else
        !reduceMotion
#endif
    }

    var body: some View {
        Rectangle()
            .fill(Color(red: 0.039, green: 0.055, blue: 0.098))
            .overlay(
                shimmerOverlay
            )
            .onAppear {
                guard shouldAnimate else { return }
                withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                    phase = 1.35
                }
            }
    }

    @ViewBuilder
    private var shimmerOverlay: some View {
        if !shouldAnimate {
            Color.white.opacity(0.035)
        } else {
            LinearGradient(
                colors: [.clear, Color.white.opacity(0.07), .clear],
                startPoint: UnitPoint(x: phase, y: 0.5),
                endPoint: UnitPoint(x: phase + 0.65, y: 0.5)
            )
        }
    }
}

private struct AppContentImageSizing: ViewModifier {
    let mode: AppContentImageMode
    let focalPoint: PremiumImageFocalPoint

    func body(content: Content) -> some View {
        switch mode {
        case .fill:
            content
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: focalPoint.alignment)
                .clipped()
        case .fit:
            content
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
