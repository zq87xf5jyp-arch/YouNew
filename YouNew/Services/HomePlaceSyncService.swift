import Foundation
import Combine

nonisolated enum YouNewAPIConfiguration {
    nonisolated static var baseURL: URL? {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: "YOUNEW_API_BASE_URL") as? String else { return nil }
        return validatedBaseURL(raw)
    }

    nonisolated static func validatedBaseURL(_ raw: String) -> URL? {
        let value = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty,
              let url = URL(string: value),
              url.scheme?.lowercased() == "https",
              url.host != nil else { return nil }
        return url
    }

    nonisolated static func citySlug(_ cityID: String) -> String {
        cityID.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: "-")
    }
}

nonisolated struct ProductionPlaceSummary: Codable, Equatable, Sendable {
    let cityID: String
    let placeCount: Int
    let restaurantCount: Int?
    let eventCount: Int?
    let updatedAt: Date
}

nonisolated private struct CachedProductionPlaceSummary: Codable, Sendable {
    let summary: ProductionPlaceSummary
    let cachedAt: Date
}

actor HomePlaceSyncService {
    static let shared = HomePlaceSyncService()

    private let defaults: UserDefaults
    private let session: URLSession
    private let cacheTTL: TimeInterval = 24 * 60 * 60

    init(defaults: UserDefaults = .standard, session: URLSession = .shared) {
        self.defaults = defaults
        self.session = session
    }

    func cachedSummary(cityID: String) -> ProductionPlaceSummary? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let data = defaults.data(forKey: cacheKey(cityID)) else { return nil }
        if let cached = try? decoder.decode(CachedProductionPlaceSummary.self, from: data),
           Date().timeIntervalSince(cached.cachedAt) < cacheTTL {
            return cached.summary
        }
        // Preserve caches written by earlier app versions until they expire.
        if let legacy = try? decoder.decode(ProductionPlaceSummary.self, from: data),
           Date().timeIntervalSince(legacy.updatedAt) < cacheTTL {
            return legacy
        }
        return nil
    }

    func summary(cityID: String, localCount: Int) async throws -> ProductionPlaceSummary? {
        guard let baseURL = YouNewAPIConfiguration.baseURL else { return nil }
        let slug = YouNewAPIConfiguration.citySlug(cityID)
        let url = baseURL.appending(path: "v1/cities/\(slug)/places/summary")
        var request = URLRequest(url: url)
        request.timeoutInterval = 12
        request.cachePolicy = .reloadRevalidatingCacheData
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, 200 ..< 300 ~= http.statusCode else {
            throw URLError(.badServerResponse)
        }

        let decoded = try Self.decode(data: data, cityID: cityID, localCount: localCount)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let cached = CachedProductionPlaceSummary(summary: decoded, cachedAt: Date())
        if let encoded = try? encoder.encode(cached) {
            defaults.set(encoded, forKey: cacheKey(cityID))
        }
        return decoded
    }

    nonisolated static func decode(
        data: Data,
        cityID: String,
        localCount: Int,
        receivedAt: Date = Date()
    ) throws -> ProductionPlaceSummary {
        struct Payload: Decodable {
            let placeCount: Int?
            let placesCount: Int?
            let count: Int?
            let restaurantCount: Int?
            let eventCount: Int?
            let updatedAt: Date?
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let payload = try decoder.decode(Payload.self, from: data)
        let count = payload.placeCount ?? payload.placesCount ?? payload.count ?? localCount
        guard count >= 0,
              payload.restaurantCount.map({ $0 >= 0 }) ?? true,
              payload.eventCount.map({ $0 >= 0 }) ?? true else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Summary counts must be non-negative."))
        }
        return ProductionPlaceSummary(
            cityID: cityID,
            placeCount: count,
            restaurantCount: payload.restaurantCount,
            eventCount: payload.eventCount,
            updatedAt: payload.updatedAt ?? receivedAt
        )
    }

    private func cacheKey(_ cityID: String) -> String {
        "younew.live.places.\(YouNewAPIConfiguration.citySlug(cityID)).v1"
    }
}

@MainActor
final class HomePlaceCountModel: ObservableObject {
    enum Source: Equatable { case local, cached, production }
    @Published private(set) var summary: ProductionPlaceSummary?
    @Published private(set) var count = 0
    @Published private(set) var source: Source = .local

    func load(cityID: String, localCount: Int) async {
        count = localCount
        summary = nil
        source = .local

        let cached = await HomePlaceSyncService.shared.cachedSummary(cityID: cityID)
        guard !Task.isCancelled else { return }
        if let cached {
            summary = cached
            count = cached.placeCount
            source = .cached
            return
        }

        do {
            guard let live = try await HomePlaceSyncService.shared.summary(cityID: cityID, localCount: localCount),
                  !Task.isCancelled else { return }
            summary = live
            count = live.placeCount
            source = .production
        } catch is CancellationError {
            return
        } catch {
            if source == .local { count = localCount }
        }
    }
}
