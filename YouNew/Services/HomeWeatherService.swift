import Foundation
import Combine

nonisolated struct HomeWeatherSnapshot: Codable, Equatable, Sendable {
    let temperature: Double
    let apparentTemperature: Double
    let precipitation: Double
    let windSpeed: Double
    let weatherCode: Int
    let isDay: Bool
    let observedAt: Date
}

nonisolated private struct CachedHomeWeatherSnapshot: Codable {
    let snapshot: HomeWeatherSnapshot
    let cachedAt: Date
}

@MainActor
final class HomeWeatherModel: ObservableObject {
    enum Phase: Equatable {
        case idle
        case loading
        case loaded(HomeWeatherSnapshot, cached: Bool)
        case unavailable
    }

    @Published private(set) var phase: Phase = .idle

    private let liveRefreshInterval: TimeInterval = 15 * 60

    nonisolated private struct ForecastResponse: Decodable {
        let current: Current

        struct Current: Decodable {
            let time: String
            let temperature_2m: Double
            let apparent_temperature: Double
            let is_day: Int
            let precipitation: Double
            let weather_code: Int
            let wind_speed_10m: Double
        }
    }

    func load(cityID: String, latitude: Double, longitude: Double) async {
        let cacheKey = "home.weather.\(cityID.lowercased())"
        let cachedRecord = cachedSnapshot(for: cacheKey)
        let cached = cachedRecord?.snapshot
        if let cached {
            phase = .loaded(cached, cached: true)
            if let cachedRecord,
               Date().timeIntervalSince(cachedRecord.cachedAt) < liveRefreshInterval {
                return
            }
        } else {
            phase = .loading
        }

        do {
            let snapshot = try await fetch(latitude: latitude, longitude: longitude)
            try Task.checkCancellation()
            cache(snapshot, for: cacheKey)
            phase = .loaded(snapshot, cached: false)
        } catch is CancellationError {
            return
        } catch {
            phase = cached.map { .loaded($0, cached: true) } ?? .unavailable
        }
    }

    private func fetch(latitude: Double, longitude: Double) async throws -> HomeWeatherSnapshot {
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "current", value: "temperature_2m,apparent_temperature,is_day,precipitation,weather_code,wind_speed_10m"),
            URLQueryItem(name: "timezone", value: "Europe/Amsterdam"),
            URLQueryItem(name: "models", value: "knmi_seamless")
        ]
        guard let url = components?.url else { throw URLError(.badURL) }

        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        request.cachePolicy = .reloadRevalidatingCacheData
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200 ... 299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try Self.decode(data: data)
    }

    nonisolated static func decode(data: Data, receivedAt: Date = Date()) throws -> HomeWeatherSnapshot {
        let decoded = try JSONDecoder().decode(ForecastResponse.self, from: data)
        guard (-90 ... 90).contains(decoded.current.temperature_2m),
              (-100 ... 100).contains(decoded.current.apparent_temperature),
              decoded.current.precipitation >= 0,
              decoded.current.wind_speed_10m >= 0 else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Weather measurements are outside supported bounds."))
        }
        let timestampFormatter = ISO8601DateFormatter()
        timestampFormatter.formatOptions = [.withInternetDateTime, .withColonSeparatorInTime]
        let observedAt = timestampFormatter.date(from: decoded.current.time) ?? receivedAt

        return HomeWeatherSnapshot(
            temperature: decoded.current.temperature_2m,
            apparentTemperature: decoded.current.apparent_temperature,
            precipitation: decoded.current.precipitation,
            windSpeed: decoded.current.wind_speed_10m,
            weatherCode: decoded.current.weather_code,
            isDay: decoded.current.is_day == 1,
            observedAt: observedAt
        )
    }

    private func cachedSnapshot(for key: String) -> CachedHomeWeatherSnapshot? {
        guard let data = UserDefaults.standard.data(forKey: key),
              let cached = try? JSONDecoder().decode(CachedHomeWeatherSnapshot.self, from: data),
              Date().timeIntervalSince(cached.cachedAt) < 6 * 60 * 60 else {
            return nil
        }
        return cached
    }

    private func cache(_ snapshot: HomeWeatherSnapshot, for key: String) {
        let cached = CachedHomeWeatherSnapshot(snapshot: snapshot, cachedAt: Date())
        guard let data = try? JSONEncoder().encode(cached) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
