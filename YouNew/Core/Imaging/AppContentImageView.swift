import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

enum AppContentImageMode {
    case fill
    case fit
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
    var fallbackLocalAssetName: String = CuratedPlaceHeroMediaRegistry.bundledEmergencyFallbackAssetName
    var debugContext: ImageDebugContext? = nil
    var targetPixelWidth: CGFloat? = nil
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
    }

    @ViewBuilder
    private func content(for asset: AppImageAsset) -> some View {
        if let localAssetName = asset.localAssetName, VisualAssetHelper.exists(localAssetName) {
            Image(localAssetName)
                .resizable()
                .contentShape(Rectangle())
                .modifier(AppContentImageSizing(mode: mode))
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
                .modifier(AppContentImageSizing(mode: mode))
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
                fallbackBackground.opacity(0.46)
            } else {
                fallbackBackground
                GeneratedCategoryArtwork(symbol: "photo.on.rectangle.angled", accent: accent)
                    .opacity(0.24)
                    .padding(18)
            }

            VStack(spacing: 7) {
                Image(systemName: fallbackSymbol)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(accent.opacity(0.82))
                    .frame(width: 54, height: 54)
                    .background(Color.white.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
            }
            .accessibilityLabel(imageUnavailableText)
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

    private var fallbackSymbol: String {
        "sparkles.rectangle.stack.fill"
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
            Text(imageUnavailableText)
                .font(.system(.caption2, design: .rounded).weight(.semibold))
                .foregroundStyle(AppColors.textTertiary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
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

    private var cacheKey: String {
        ([url] + fallbackURLs).map(\.absoluteString).joined(separator: "|")
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
            let key = candidate.absoluteString as NSString
            if let cached = Self.imageCache.object(forKey: key) {
                ImageDebugLogger.log(
                    context: debugContext,
                    resolvedURL: candidate.absoluteString,
                    fallbackLevel: debugContext?.fallbackLevel ?? "app-content-cache",
                    cacheKey: candidate.absoluteString,
                    cacheHit: true
                )
                image = cached
                loadedCacheKey = cacheKey
                return
            }

            do {
                let prepared = try await Task.detached(priority: .utility) {
                    let (data, _) = try await URLSession.shared.data(from: candidate)
                    guard let decoded = UIImage(data: data) else { return nil as UIImage? }
                    return await decoded.byPreparingThumbnail(ofSize: targetPixelSize) ?? decoded
                }.value
                guard let prepared else { continue }
                Self.imageCache.setObject(prepared, forKey: key)
                ImageDebugLogger.log(
                    context: debugContext,
                    resolvedURL: candidate.absoluteString,
                    fallbackLevel: debugContext?.fallbackLevel ?? "app-content-remote",
                    cacheKey: candidate.absoluteString,
                    cacheHit: false
                )
                image = prepared
                loadedCacheKey = cacheKey
                return
            } catch {
                continue
            }
        }

        didFail = true
        loadedCacheKey = cacheKey
    }
    #else
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                loading
            case .success(let image):
                content(image.resizable())
            case .failure:
                fallback
            @unknown default:
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
#endif

private extension View {
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

    var body: some View {
        Rectangle()
            .fill(Color(red: 0.039, green: 0.055, blue: 0.098))
            .overlay(
                shimmerOverlay
            )
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                    phase = 1.35
                }
            }
    }

    @ViewBuilder
    private var shimmerOverlay: some View {
        if reduceMotion {
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

    func body(content: Content) -> some View {
        switch mode {
        case .fill:
            content
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
        case .fit:
            content
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
