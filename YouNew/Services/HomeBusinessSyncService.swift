import Foundation
import Combine

nonisolated struct ProductionBusinessSummary: Codable, Equatable, Sendable {
    let cityID: String
    let businessCount: Int
    let verifiedCount: Int
    let featuredCount: Int
    let updatedAt: Date
}

nonisolated private struct CachedProductionBusinessSummary: Codable, Sendable {
    let summary: ProductionBusinessSummary
    let cachedAt: Date
}

actor HomeBusinessSyncService {
    static let shared = HomeBusinessSyncService()

    private let defaults: UserDefaults
    private let session: URLSession
    private let cacheTTL: TimeInterval = 24 * 60 * 60

    init(defaults: UserDefaults = .standard, session: URLSession = .shared) {
        self.defaults = defaults
        self.session = session
    }

    func cachedSummary(cityID: String) -> ProductionBusinessSummary? {
        guard let data = defaults.data(forKey: cacheKey(cityID)) else { return nil }
        if let cached = try? decoder.decode(CachedProductionBusinessSummary.self, from: data),
           Date().timeIntervalSince(cached.cachedAt) < cacheTTL {
            return cached.summary
        }
        // Preserve caches written by earlier app versions until they expire.
        if let legacy = try? decoder.decode(ProductionBusinessSummary.self, from: data),
           Date().timeIntervalSince(legacy.updatedAt) < cacheTTL {
            return legacy
        }
        return nil
    }

    func summary(cityID: String, localCount: Int) async throws -> ProductionBusinessSummary? {
        guard let baseURL = YouNewAPIConfiguration.baseURL else { return nil }
        let slug = YouNewAPIConfiguration.citySlug(cityID)
        let url = baseURL.appending(path: "v1/cities/\(slug)/businesses/summary")
        var request = URLRequest(url: url)
        request.timeoutInterval = 12
        request.cachePolicy = .reloadRevalidatingCacheData
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, 200 ..< 300 ~= http.statusCode else {
            throw URLError(.badServerResponse)
        }

        let decoded = try Self.decode(data: data, cityID: cityID, localCount: localCount)
        let cached = CachedProductionBusinessSummary(summary: decoded, cachedAt: Date())
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
    ) throws -> ProductionBusinessSummary {
        struct Payload: Decodable {
            let businessCount: Int?
            let businessesCount: Int?
            let count: Int?
            let verifiedCount: Int?
            let featuredCount: Int?
            let updatedAt: Date?
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let payload = try decoder.decode(Payload.self, from: data)
        let total = payload.businessCount ?? payload.businessesCount ?? payload.count ?? localCount
        let verified = payload.verifiedCount ?? total
        let featured = payload.featuredCount ?? 0
        guard total >= 0, verified >= 0, featured >= 0,
              verified <= total, featured <= total else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Business summary counts are inconsistent."))
        }
        return ProductionBusinessSummary(
            cityID: cityID,
            businessCount: total,
            verifiedCount: verified,
            featuredCount: featured,
            updatedAt: payload.updatedAt ?? receivedAt
        )
    }

    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    private var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }

    private func cacheKey(_ cityID: String) -> String {
        "younew.live.businesses.\(YouNewAPIConfiguration.citySlug(cityID)).v1"
    }
}

@MainActor
final class HomeBusinessCountModel: ObservableObject {
    enum Source: Equatable { case local, cached, production }
    @Published private(set) var summary: ProductionBusinessSummary?
    @Published private(set) var verifiedCount = 0
    @Published private(set) var source: Source = .local

    func load(cityID: String, localCount: Int) async {
        verifiedCount = localCount
        summary = nil
        source = .local

        let cached = await HomeBusinessSyncService.shared.cachedSummary(cityID: cityID)
        guard !Task.isCancelled else { return }
        if let cached {
            summary = cached
            verifiedCount = cached.verifiedCount
            source = .cached
            return
        }

        do {
            guard let live = try await HomeBusinessSyncService.shared.summary(cityID: cityID, localCount: localCount),
                  !Task.isCancelled else { return }
            summary = live
            verifiedCount = live.verifiedCount
            source = .production
        } catch is CancellationError {
            return
        } catch {
            if source == .local { verifiedCount = localCount }
        }
    }
}
