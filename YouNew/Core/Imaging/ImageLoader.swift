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

enum ImageDiskThumbnailCache {
    nonisolated static func cacheKey(urlString: String, targetWidth: CGFloat) -> String {
        let width = max(1, Int(targetWidth.rounded(.up)))
        return "\(stableHash(urlString))-\(width)"
    }

    nonisolated static func readOffMain(urlString: String, targetWidth: CGFloat) async -> UIImage? {
        await Task.detached(priority: .utility) {
            read(urlString: urlString, targetWidth: targetWidth)
        }.value
    }

    nonisolated static func writeOffMain(_ image: UIImage, urlString: String, targetWidth: CGFloat) async {
        await Task.detached(priority: .utility) {
            write(image, urlString: urlString, targetWidth: targetWidth)
        }.value
    }

    nonisolated static func read(urlString: String, targetWidth: CGFloat) -> UIImage? {
        let key = cacheKey(urlString: urlString, targetWidth: targetWidth)
        let url = fileURL(for: key)
        guard let data = try? Data(contentsOf: url),
              let image = UIImage(data: data) else {
            return nil
        }
        try? FileManager.default.setAttributes([.modificationDate: Date()], ofItemAtPath: url.path)
        return image
    }

    nonisolated static func write(_ image: UIImage, urlString: String, targetWidth: CGFloat) {
        guard let data = image.jpegData(compressionQuality: 0.86) else { return }
        let directory = cacheDirectory
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try? data.write(to: fileURL(for: cacheKey(urlString: urlString, targetWidth: targetWidth)), options: [.atomic])
        pruneIfNeeded()
    }

    nonisolated private static var cacheDirectory: URL {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return base.appendingPathComponent("YouNewImageThumbnails", isDirectory: true)
    }

    nonisolated private static func fileURL(for key: String) -> URL {
        cacheDirectory.appendingPathComponent(key).appendingPathExtension("jpg")
    }

    nonisolated private static func pruneIfNeeded(maxBytes: Int64 = 150 * 1024 * 1024, maxFiles: Int = 520) {
        let directory = cacheDirectory
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey],
            options: [.skipsHiddenFiles]
        ) else {
            return
        }

        var records: [(url: URL, modified: Date, size: Int64)] = []
        var totalBytes: Int64 = 0
        for file in files where file.pathExtension == "jpg" {
            let values = try? file.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey])
            let size = Int64(values?.fileSize ?? 0)
            totalBytes += size
            records.append((file, values?.contentModificationDate ?? .distantPast, size))
        }

        guard totalBytes > maxBytes || records.count > maxFiles else { return }
        for record in records.sorted(by: { $0.modified < $1.modified }) {
            try? FileManager.default.removeItem(at: record.url)
            totalBytes -= record.size
            records.removeAll { $0.url == record.url }
            if totalBytes <= maxBytes && records.count <= maxFiles {
                break
            }
        }
    }

    nonisolated private static func stableHash(_ value: String) -> String {
        var hash: UInt64 = 5381
        for scalar in value.unicodeScalars {
            hash = ((hash << 5) &+ hash) &+ UInt64(scalar.value)
        }
        return String(hash, radix: 16)
    }
}

enum CityImageRenderRole {
    case hero
    case card
    case thumbnail
    case mapPreview

    var targetPixelWidth: CGFloat {
        switch self {
        case .hero:
            return 1200
        case .card:
            return 720
        case .thumbnail:
            return 420
        case .mapPreview:
            return 560
        }
    }
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

    func cancel() {
        task?.cancel()
        task = nil
        switch state {
        case .loading:
            currentURLString = nil
            state = .idle
        case .failed:
            currentURLString = nil
        case .idle, .success:
            break
        }
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

        let requestedCacheKey = ImageDiskThumbnailCache.cacheKey(urlString: requestedURL, targetWidth: targetWidth)
        guard requestedCacheKey != currentURLString else { return }
        currentURLString = requestedCacheKey
        task?.cancel()

        if let cached = ImageMemoryCache.shared.object(forKey: requestedCacheKey as NSString) {
            ImageDebugLogger.log(
                context: debugContext,
                resolvedURL: requestedURL,
                fallbackLevel: debugContext?.fallbackLevel,
                cacheKey: requestedCacheKey,
                cacheHit: true
            )
            resolvedURLString = requestedURL
            resolvedCacheKey = requestedCacheKey
            resolvedFallbackLevel = debugContext?.fallbackLevel ?? "cached"
            resolvedFromCache = true
            image = cached
            state = .success
            return
        }

        image = nil
        resolvedURLString = nil
        resolvedCacheKey = requestedCacheKey
        resolvedFallbackLevel = debugContext?.fallbackLevel ?? "loading"
        resolvedFromCache = false
        state = .loading
        task = Task { [weak self] in
            await self?.loadImage(urlString: requestedURL, targetWidth: targetWidth, cacheKey: requestedCacheKey, debugContext: debugContext)
        }
    }

    private func loadImage(urlString: String, targetWidth: CGFloat, cacheKey: String, debugContext: ImageDebugContext?) async {
        guard let prepared = await fetchImage(urlString: urlString, targetWidth: targetWidth, cacheKey: cacheKey) else {
            guard !Task.isCancelled else { return }
            image = nil
            resolvedURLString = nil
            resolvedCacheKey = cacheKey
            resolvedFallbackLevel = "generated-artwork"
            resolvedFromCache = false
            state = .failed
            ImageDebugLogger.log(
                context: debugContext,
                resolvedURL: nil,
                fallbackLevel: "generated-artwork",
                cacheKey: cacheKey,
                cacheHit: false
            )
            return
        }

        guard !Task.isCancelled else { return }
        ImageMemoryCache.shared.setObject(prepared, forKey: cacheKey as NSString, cost: prepared.memoryCost)
        ImageDebugLogger.log(
            context: debugContext,
            resolvedURL: urlString,
            fallbackLevel: debugContext?.fallbackLevel,
            cacheKey: cacheKey,
            cacheHit: false
        )
        resolvedURLString = urlString
        resolvedCacheKey = cacheKey
        resolvedFallbackLevel = debugContext?.fallbackLevel ?? "direct-url"
        resolvedFromCache = false
        withAnimation(.easeIn(duration: 0.25)) {
            image = prepared
            state = .success
        }
    }

    private func fetchImage(urlString: String, targetWidth: CGFloat, cacheKey: String) async -> UIImage? {
        if let cached = ImageMemoryCache.shared.object(forKey: cacheKey as NSString) {
            return cached
        }

        let diskImage = await ImageDiskThumbnailCache.readOffMain(urlString: urlString, targetWidth: targetWidth)

        if let diskImage {
            ImageMemoryCache.shared.setObject(diskImage, forKey: cacheKey as NSString, cost: diskImage.memoryCost)
            return diskImage
        }

        if let existingTask = Self.inFlightTasks[cacheKey] {
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
                let image = downsampledImage(from: data, maxPixelWidth: targetWidth)
                if let image {
                    await ImageDiskThumbnailCache.writeOffMain(image, urlString: urlString, targetWidth: targetWidth)
                }
                return image
            } catch {
                #if DEBUG
                print("Image load failed: \(urlString) - \(error.localizedDescription)")
                #endif
                return nil
            }
        }

        Self.inFlightTasks[cacheKey] = task
        let result = await task.value
        Self.inFlightTasks[cacheKey] = nil
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
    var renderRole: CityImageRenderRole = .hero
    var targetPixelWidth: CGFloat? = nil
    var showsReadableOverlay = true

    @StateObject private var loader = DirectImageLoader()

    private var curatedURL: String? {
        if let placeId,
           let remoteURL = CuratedPlaceHeroMediaRegistry.media(for: placeId)?.remoteURL?.absoluteString {
            return remoteURL
        }
        return nil
    }

    private var bundledAssetName: String? {
        guard let placeId else { return nil }

        let asset: AppImageAsset?
        if placeId.hasPrefix("nl-province-") {
            asset = LocalNetherlandsImagePackRegistry.provinceHero(placeId: placeId)
        } else {
            switch renderRole {
            case .hero:
                asset = LocalNetherlandsImagePackRegistry.cityHero(placeId: placeId)
            case .card:
                asset = LocalNetherlandsImagePackRegistry.cityCard(placeId: placeId)
                    ?? LocalNetherlandsImagePackRegistry.cityHero(placeId: placeId)
            case .thumbnail, .mapPreview:
                asset = LocalNetherlandsImagePackRegistry.cityShortcut(placeId: placeId)
                    ?? LocalNetherlandsImagePackRegistry.cityCard(placeId: placeId)
                    ?? LocalNetherlandsImagePackRegistry.cityHero(placeId: placeId)
            }
        }

        guard let localAssetName = asset?.localAssetName,
              VisualAssetHelper.exists(localAssetName) else { return nil }
        return localAssetName
    }

    private var effectiveURL: String? {
        resolveHeroURL(placeId: placeId, entityURL: urlString)
    }

    private var imageTargetWidth: CGFloat {
        if let targetPixelWidth {
            return targetPixelWidth
        }

        return renderRole.targetPixelWidth
    }

    private var loadIdentity: String {
        "\(bundledAssetName ?? effectiveURL ?? "no-url")-\(Int(imageTargetWidth.rounded(.up)))"
    }

    var body: some View {
        ZStack {
            if let bundledAssetName {
                Image(bundledAssetName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: height)
                    .clipped()
                    .transition(.opacity.animation(.easeIn(duration: 0.25)))
            } else {
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

            if showsReadableOverlay {
                readablePhotoOverlay
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipped()
        .runtimeImageDebugInspector(runtimeDebugInfo)
        .task(id: loadIdentity) {
            guard bundledAssetName == nil else {
                loader.cancel()
                return
            }
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
        .onDisappear {
            loader.cancel()
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
            resolvedURL: bundledAssetName.map { "local:\($0)" } ?? loader.resolvedURLString ?? "generated-fallback",
            registrySource: context.sourceRegistry,
            fallbackLevel: bundledAssetName == nil
                ? (loader.resolvedFallbackLevel.isEmpty ? context.fallbackLevel : loader.resolvedFallbackLevel)
                : "bundled-local-photo",
            cacheKey: bundledAssetName ?? (loader.resolvedCacheKey.isEmpty ? (effectiveURL ?? "") : loader.resolvedCacheKey),
            modelID: context.modelID,
            cacheHit: bundledAssetName != nil || loader.resolvedFromCache
        )
    }

    private var readablePhotoOverlay: some View {
        LinearGradient(
            colors: [
                Color.black.opacity(0.00),
                Color.black.opacity(0.14),
                Color.black.opacity(renderRole == .hero ? 0.54 : 0.46)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .allowsHitTesting(false)
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
    private var shouldAnimate: Bool {
#if DEBUG
        !ProcessInfo.processInfo.arguments.contains("-uiTesting") && !reduceMotion
#else
        !reduceMotion
#endif
    }

    var body: some View {
        Rectangle()
            .fill(Color(hex: "#141C2E"))
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .overlay(
                shimmerOverlay
            )
            .onAppear {
                guard shouldAnimate else { return }
                withAnimation(.linear(duration: 1.6).repeatForever(autoreverses: false)) {
                    phase = 1.4
                }
            }
    }

    @ViewBuilder
    private var shimmerOverlay: some View {
        if !shouldAnimate {
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
