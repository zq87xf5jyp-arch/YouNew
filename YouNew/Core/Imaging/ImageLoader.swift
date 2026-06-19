#if canImport(UIKit)
import Combine
import Foundation
import ImageIO
import SwiftUI
import UIKit

enum ImageMemoryCache {
    static let shared: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100
        cache.totalCostLimit = 200 * 1024 * 1024
        return cache
    }()
}

@MainActor
final class DirectImageLoader: ObservableObject {
    @Published private(set) var image: UIImage?
    @Published private(set) var state: LoadState = .idle
    @Published private(set) var resolvedURLString: String?
    @Published private(set) var resolvedCacheKey: String = ""
    @Published private(set) var resolvedFallbackLevel: String = ""
    @Published private(set) var resolvedFromCache = false

    enum LoadState {
        case idle
        case loading
        case success
        case failed
    }

    private var currentURLString: String?
    private var task: Task<Void, Never>?
    private static var inFlightTasks: [String: Task<UIImage?, Never>] = [:]

    deinit {
        task?.cancel()
    }

    func load(_ urlString: String?, targetWidth: CGFloat = 900, debugContext: ImageDebugContext? = nil) {
        let requestedURL = urlString?.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let requestedURL, !requestedURL.isEmpty else {
            image = nil
            resolvedURLString = nil
            resolvedCacheKey = ""
            resolvedFallbackLevel = debugContext?.fallbackLevel ?? "no-url"
            resolvedFromCache = false
            state = .failed
            return
        }

        guard requestedURL != currentURLString else { return }
        currentURLString = requestedURL
        task?.cancel()

        if let cached = ImageMemoryCache.shared.object(forKey: requestedURL as NSString) {
            ImageDebugLogger.log(
                context: debugContext,
                resolvedURL: requestedURL,
                fallbackLevel: debugContext?.fallbackLevel,
                cacheKey: requestedURL,
                cacheHit: true
            )
            resolvedURLString = requestedURL
            resolvedCacheKey = requestedURL
            resolvedFallbackLevel = debugContext?.fallbackLevel ?? "cached"
            resolvedFromCache = true
            image = cached
            state = .success
            return
        }

        image = nil
        resolvedURLString = nil
        resolvedCacheKey = requestedURL
        resolvedFallbackLevel = debugContext?.fallbackLevel ?? "loading"
        resolvedFromCache = false
        state = .loading
        task = Task { [weak self] in
            await self?.loadImage(urlString: requestedURL, targetWidth: targetWidth, debugContext: debugContext)
        }
    }

    private func loadImage(urlString: String, targetWidth: CGFloat, debugContext: ImageDebugContext?) async {
        guard let prepared = await fetchImage(urlString: urlString, targetWidth: targetWidth) else {
            guard !Task.isCancelled else { return }
            image = nil
            resolvedURLString = nil
            resolvedCacheKey = urlString
            resolvedFallbackLevel = "generated-artwork"
            resolvedFromCache = false
            state = .failed
            ImageDebugLogger.log(
                context: debugContext,
                resolvedURL: nil,
                fallbackLevel: "generated-artwork",
                cacheKey: urlString,
                cacheHit: false
            )
            return
        }

        guard !Task.isCancelled else { return }
        ImageMemoryCache.shared.setObject(prepared, forKey: urlString as NSString, cost: prepared.memoryCost)
        ImageDebugLogger.log(
            context: debugContext,
            resolvedURL: urlString,
            fallbackLevel: debugContext?.fallbackLevel,
            cacheKey: urlString,
            cacheHit: false
        )
        resolvedURLString = urlString
        resolvedCacheKey = urlString
        resolvedFallbackLevel = debugContext?.fallbackLevel ?? "direct-url"
        resolvedFromCache = false
        withAnimation(.easeIn(duration: 0.25)) {
            image = prepared
            state = .success
        }
    }

    private func fetchImage(urlString: String, targetWidth: CGFloat) async -> UIImage? {
        if let cached = ImageMemoryCache.shared.object(forKey: urlString as NSString) {
            return cached
        }

        if let existingTask = Self.inFlightTasks[urlString] {
            return await existingTask.value
        }

        let task = Task<UIImage?, Never>.detached(priority: .utility) {
            guard let url = URL(string: urlString) else { return nil }

            do {
                var request = URLRequest(url: url, timeoutInterval: 12)
                request.setValue("YouNew/1.0 (iOS; NetherlandsGuide)", forHTTPHeaderField: "User-Agent")
                request.setValue("image/webp,image/jpeg,image/png,image/*,*/*;q=0.8", forHTTPHeaderField: "Accept")
                request.cachePolicy = .useProtocolCachePolicy

                let (data, response) = try await NetworkConfig.imageSession.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse else { return nil }
                guard httpResponse.statusCode == 200 else {
                    #if DEBUG
                    print("Image load HTTP \(httpResponse.statusCode): \(urlString)")
                    #endif
                    return nil
                }
                guard let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type")?.lowercased(),
                      contentType.hasPrefix("image/") else {
                    #if DEBUG
                    print("Image load invalid content type: \(urlString)")
                    #endif
                    return nil
                }
                return downsampledImage(from: data, maxPixelWidth: targetWidth)
            } catch {
                #if DEBUG
                print("Image load failed: \(urlString) - \(error.localizedDescription)")
                #endif
                return nil
            }
        }

        Self.inFlightTasks[urlString] = task
        let result = await task.value
        Self.inFlightTasks[urlString] = nil
        return result
    }
}

struct CityImageView: View {
    let urlString: String?
    let height: CGFloat
    var placeId: String? = nil
    var cityName: String = ""
    var fallbackColor: Color = Color(hex: "#142A3E")
    var fallbackURLStrings: [String] = []
    var debugContext: ImageDebugContext? = nil
    var targetPixelWidth: CGFloat? = nil

    @StateObject private var loader = DirectImageLoader()

    private var curatedURL: String? {
        if let placeId,
           let remoteURL = CuratedPlaceHeroMediaRegistry.media(for: placeId)?.remoteURL?.absoluteString {
            return remoteURL
        }
        return nil
    }

    private var effectiveURL: String? {
        resolveHeroURL(placeId: placeId, entityURL: urlString)
    }

    private var imageTargetWidth: CGFloat {
        if let targetPixelWidth {
            return targetPixelWidth
        }

        let displayAwareWidth = height * 3.2
        return min(1200, max(320, displayAwareWidth))
    }

    var body: some View {
        ZStack {
            switch loader.state {
            case .success:
                if let image = loader.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: height)
                        .clipped()
                        .transition(.opacity.animation(.easeIn(duration: 0.25)))
                } else {
                    FallbackCityView(cityName: cityName, color: fallbackColor, height: height)
                }
            case .idle, .loading:
                if let effectiveURL, !effectiveURL.isEmpty {
                    ShimmerView(height: height)
                        .transition(.opacity.animation(.easeIn(duration: 0.25)))
                } else {
                    FallbackCityView(cityName: cityName, color: fallbackColor, height: height)
                }
            case .failed:
                FallbackCityView(cityName: cityName, color: fallbackColor, height: height)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipped()
        .runtimeImageDebugInspector(runtimeDebugInfo)
        .task(id: effectiveURL) {
            guard let effectiveURL else { return }
            loader.load(
                effectiveURL,
                targetWidth: imageTargetWidth,
                debugContext: debugContext ?? ImageDebugContext(
                    screen: "CityImageView",
                    entityType: placeId?.hasPrefix("nl-province-") == true ? "province" : "city",
                    entityName: cityName,
                    requestedURL: effectiveURL,
                    fallbackLevel: curatedURL == nil ? "explicit-model-url" : "curated-registry",
                    sourceRegistry: curatedURL == nil ? "Legacy urlString" : "CuratedPlaceHeroMediaRegistry",
                    modelID: placeId ?? "unknown"
                )
            )
        }
    }

    private var runtimeDebugInfo: RuntimeImageDebugInfo {
        let context = debugContext ?? ImageDebugContext(
            screen: "CityImageView",
            entityType: placeId?.hasPrefix("nl-province-") == true ? "province" : "city",
            entityName: cityName,
            requestedURL: effectiveURL ?? "",
            fallbackLevel: curatedURL == nil ? "explicit-model-url" : "curated-registry",
            sourceRegistry: curatedURL == nil ? "Legacy urlString" : "CuratedPlaceHeroMediaRegistry",
            modelID: placeId ?? "unknown"
        )

        return RuntimeImageDebugInfo(
            screen: context.screen,
            entityName: context.entityName,
            entityType: context.entityType,
            requestedURL: context.requestedURL,
            resolvedURL: loader.resolvedURLString ?? "generated-fallback",
            registrySource: context.sourceRegistry,
            fallbackLevel: loader.resolvedFallbackLevel.isEmpty ? context.fallbackLevel : loader.resolvedFallbackLevel,
            cacheKey: loader.resolvedCacheKey.isEmpty ? (effectiveURL ?? "") : loader.resolvedCacheKey,
            modelID: context.modelID,
            cacheHit: loader.resolvedFromCache
        )
    }

    private func resolveHeroURL(placeId: String?, entityURL: String?) -> String? {
        if let placeId,
           let registryURL = CuratedPlaceHeroMediaRegistry.media(for: placeId)?.remoteURL?.absoluteString,
           !registryURL.isEmpty {
            return registryURL
        }

        let trimmed = entityURL?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed?.isEmpty == false ? trimmed : nil
    }
}

struct FallbackCityView: View {
    let cityName: String
    let color: Color
    let height: CGFloat

    var body: some View {
        ZStack {
            GeneratedCityArtwork(cityName: cityName, symbol: fallbackSymbol, accent: color)

            LinearGradient(
                colors: [
                    Color.black.opacity(0.06),
                    color.opacity(0.18),
                    Color(hex: "#050914").opacity(0.74)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.09))
                        .frame(width: 56, height: 56)
                    Text(String(cityName.prefix(1)))
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.white.opacity(0.62))
                }

                if !cityName.isEmpty {
                    Text(cityName)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.48))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
    }

    private var fallbackSymbol: String {
        let key = cityName.lowercased()
        if key.contains("province") || key.contains("holland") || key.contains("drenthe") || key.contains("overijssel") {
            return "map.fill"
        }
        if key.contains("rotterdam") { return "ferry.fill" }
        if key.contains("den haag") || key.contains("hague") { return "building.columns.fill" }
        if key.contains("leiden") || key.contains("utrecht") || key.contains("maastricht") { return "water.waves" }
        if key.contains("groningen") { return "building.2.crop.circle" }
        if key.contains("arnhem") || key.contains("nijmegen") { return "water.waves" }
        if key.contains("haarlem") { return "building.columns.fill" }
        return "building.2.fill"
    }
}

struct RuntimeImageDebugInfo: Equatable {
    let screen: String
    let entityName: String
    let entityType: String
    let requestedURL: String
    let resolvedURL: String
    let registrySource: String
    let fallbackLevel: String
    let cacheKey: String
    let modelID: String
    let cacheHit: Bool
}

private struct RuntimeImageDebugInspector: ViewModifier {
    let info: RuntimeImageDebugInfo?
    @State private var isPresented = false

    private var isEnabled: Bool {
        let processInfo = ProcessInfo.processInfo
        return processInfo.arguments.contains("-YouNewImageDebugOverlay")
            || processInfo.environment["YOUNEW_IMAGE_DEBUG_OVERLAY"] == "1"
    }

    @ViewBuilder
    func body(content: Content) -> some View {
        #if DEBUG
        if isEnabled {
            content
                .overlay(alignment: .topTrailing) {
                    if info != nil {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white.opacity(0.84))
                            .frame(width: 30, height: 30)
                            .background(Color.black.opacity(0.42), in: Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.22), lineWidth: 0.7))
                            .contentShape(Circle())
                            .onTapGesture {
                                isPresented = true
                            }
                            .padding(8)
                            .accessibilityHidden(true)
                    }
                }
                .sheet(isPresented: $isPresented) {
                    if let info {
                        RuntimeImageDebugSheet(info: info)
                            .presentationDetents([.medium, .large])
                            .presentationDragIndicator(.visible)
                        }
                    }
        } else {
            content
        }
        #else
        content
        #endif
    }
}

private struct RuntimeImageDebugSheet: View {
    let info: RuntimeImageDebugInfo

    var body: some View {
        NavigationStack {
            List {
                debugRow("Screen", info.screen)
                debugRow("Entity Name", info.entityName)
                debugRow("Entity Type", info.entityType)
                debugRow("Resolved URL", info.resolvedURL)
                debugRow("Requested URL", info.requestedURL)
                debugRow("Registry Source", info.registrySource)
                debugRow("Fallback Level", info.fallbackLevel)
                debugRow("Cache Key", info.cacheKey)
                debugRow("Cache Hit", info.cacheHit ? "YES" : "NO")
                debugRow("Model ID", info.modelID)
            }
            .navigationTitle("Image Runtime")
            .nlNavigationInline()
        }
    }

    private func debugRow(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
            Text(value.isEmpty ? "empty" : value)
                .font(.system(.footnote, design: .monospaced))
                .textSelection(.enabled)
        }
        .padding(.vertical, 3)
    }
}

extension View {
    func runtimeImageDebugInspector(_ info: RuntimeImageDebugInfo?) -> some View {
        modifier(RuntimeImageDebugInspector(info: info))
    }
}

struct ShimmerView: View {
    let height: CGFloat
    @State private var phase: CGFloat = -1
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Rectangle()
            .fill(Color(hex: "#141C2E"))
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .overlay(
                shimmerOverlay
            )
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.linear(duration: 1.6).repeatForever(autoreverses: false)) {
                    phase = 1.4
                }
            }
    }

    @ViewBuilder
    private var shimmerOverlay: some View {
        if reduceMotion {
            Color.white.opacity(0.035)
        } else {
            LinearGradient(
                colors: [.clear, .white.opacity(0.06), .clear],
                startPoint: UnitPoint(x: phase, y: 0.5),
                endPoint: UnitPoint(x: phase + 0.7, y: 0.5)
            )
        }
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

nonisolated private func downsampledImage(from data: Data, maxPixelWidth: CGFloat) -> UIImage? {
    guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
        return nil
    }

    let pixelWidth = max(1, Int(maxPixelWidth.rounded(.up)))
    let options: [CFString: Any] = [
        kCGImageSourceCreateThumbnailFromImageAlways: true,
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceThumbnailMaxPixelSize: pixelWidth
    ]

    guard let thumbnail = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
        return nil
    }

    return UIImage(cgImage: thumbnail)
}
#endif
