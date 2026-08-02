import Foundation
import Combine
import CoreLocation
import WeatherKit

nonisolated struct HomeWeatherAttributionSnapshot: Codable, Equatable, Sendable {
    let serviceName: String
    let legalPageURL: URL
    let combinedMarkDarkURL: URL
    let combinedMarkLightURL: URL
}

nonisolated struct HomeWeatherSnapshot: Codable, Equatable, Sendable {
    let temperature: Double
    let apparentTemperature: Double
    let windSpeed: Double
    let weatherCode: Int
    let symbolName: String
    let isDay: Bool
    let observedAt: Date
    let attribution: HomeWeatherAttributionSnapshot
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

    private let liveRefreshInterval: TimeInterval = 30 * 60

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
        let location = CLLocation(latitude: latitude, longitude: longitude)
        async let currentWeather = WeatherKit.WeatherService.shared.weather(for: location, including: .current)
        async let attribution = WeatherKit.WeatherService.shared.attribution
        return try await Self.snapshot(currentWeather: currentWeather, attribution: attribution)
    }

    nonisolated static func snapshot(
        currentWeather: CurrentWeather,
        attribution: WeatherAttribution
    ) throws -> HomeWeatherSnapshot {
        let temperature = currentWeather.temperature.converted(to: .celsius).value
        let apparentTemperature = currentWeather.apparentTemperature.converted(to: .celsius).value
        let windSpeed = currentWeather.wind.speed.converted(to: .kilometersPerHour).value

        guard (-90 ... 90).contains(temperature),
              (-100 ... 100).contains(apparentTemperature),
              windSpeed >= 0,
              !currentWeather.symbolName.isEmpty,
              attribution.legalPageURL.scheme == "https" else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Weather measurements are outside supported bounds."))
        }

        return HomeWeatherSnapshot(
            temperature: temperature,
            apparentTemperature: apparentTemperature,
            windSpeed: windSpeed,
            weatherCode: weatherCode(for: currentWeather.condition),
            symbolName: currentWeather.symbolName,
            isDay: currentWeather.isDaylight,
            observedAt: currentWeather.date,
            attribution: HomeWeatherAttributionSnapshot(
                serviceName: attribution.serviceName,
                legalPageURL: attribution.legalPageURL,
                combinedMarkDarkURL: attribution.combinedMarkDarkURL,
                combinedMarkLightURL: attribution.combinedMarkLightURL
            )
        )
    }

    nonisolated static func weatherCode(for condition: WeatherCondition) -> Int {
        switch condition {
        case .clear, .mostlyClear, .hot:
            0
        case .partlyCloudy, .mostlyCloudy, .cloudy, .breezy, .windy:
            2
        case .foggy, .haze, .smoky, .blowingDust:
            45
        case .drizzle, .freezingDrizzle, .freezingRain, .rain, .heavyRain, .sunShowers:
            63
        case .flurries, .snow, .heavySnow, .sleet, .blowingSnow, .blizzard, .wintryMix, .frigid, .sunFlurries:
            73
        case .hail, .isolatedThunderstorms, .scatteredThunderstorms, .thunderstorms, .strongStorms, .hurricane, .tropicalStorm:
            95
        @unknown default:
            2
        }
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
