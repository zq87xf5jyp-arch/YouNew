import CoreGraphics
import Foundation

enum PremiumMapDisplayMode: String, CaseIterable, Equatable, Identifiable {
    case cities
    case provinces
    case services

    var id: String { rawValue }
}

enum PremiumMapMarkerRole: Equatable {
    case activeCity
    case majorCity
    case serviceHub
}

struct PremiumMapCityMarker: Identifiable, Equatable {
    let id: String
    let name: String
    let provinceID: String
    let normalizedPosition: CGPoint
    let normalizedLabelPosition: CGPoint
    let role: PremiumMapMarkerRole
    let priority: Int

    var labelSafetyFrame: CGRect {
        CGRect(
            x: normalizedLabelPosition.x - 0.115,
            y: normalizedLabelPosition.y - 0.026,
            width: 0.23,
            height: 0.052
        )
    }
}

enum PremiumNetherlandsMapModel {
    static let ctaSafeFrame = CGRect(x: 0.60, y: 0.855, width: 0.32, height: 0.095)
    static let minimumHomeCardHeight: CGFloat = 420
    static let minimumCompactWidth: CGFloat = 320

    static let baseCityMarkers: [PremiumMapCityMarker] = [
        marker("amsterdam", "Amsterdam", "Noord-Holland", 0.355, 0.405, 0.505, 0.355, .majorCity, 1),
        marker("rotterdam", "Rotterdam", "Zuid-Holland", 0.285, 0.645, 0.435, 0.650, .majorCity, 2),
        marker("the-hague", "The Hague", "Zuid-Holland", 0.225, 0.590, 0.120, 0.600, .majorCity, 3),
        marker("utrecht", "Utrecht", "Utrecht", 0.485, 0.545, 0.640, 0.520, .majorCity, 4),
        marker("leiden", "Leiden", "Zuid-Holland", 0.275, 0.550, 0.150, 0.485, .majorCity, 5),
        marker("eindhoven", "Eindhoven", "Noord-Brabant", 0.570, 0.805, 0.710, 0.772, .majorCity, 6),
        marker("maastricht", "Maastricht", "Limburg", 0.760, 0.925, 0.460, 0.925, .majorCity, 7),
        marker("groningen", "Groningen", "Groningen", 0.730, 0.150, 0.585, 0.112, .majorCity, 8)
    ]

    static let serviceMarkers: [PremiumMapCityMarker] = [
        marker("service-amsterdam", "Amsterdam", "Noord-Holland", 0.355, 0.405, 0.505, 0.355, .serviceHub, 1),
        marker("service-rotterdam", "Rotterdam", "Zuid-Holland", 0.285, 0.645, 0.435, 0.650, .serviceHub, 2),
        marker("service-utrecht", "Utrecht", "Utrecht", 0.485, 0.545, 0.640, 0.520, .serviceHub, 3),
        marker("service-eindhoven", "Eindhoven", "Noord-Brabant", 0.570, 0.805, 0.710, 0.772, .serviceHub, 4)
    ]

    static func markers(selectedCity: String, mode: PremiumMapDisplayMode) -> [PremiumMapCityMarker] {
        let source = mode == .services ? serviceMarkers + baseCityMarkers : baseCityMarkers
        var seenCities = Set<String>()
        return source.compactMap { marker in
            guard cityNameMatches(marker.name, selectedCity) else { return nil }
            let normalizedName = normalizeCity(marker.name)
            guard seenCities.insert(normalizedName).inserted else { return nil }
            return PremiumMapCityMarker(
                id: marker.id,
                name: marker.name,
                provinceID: marker.provinceID,
                normalizedPosition: marker.normalizedPosition,
                normalizedLabelPosition: marker.normalizedLabelPosition,
                role: .activeCity,
                priority: 0
            )
        }
        .sorted { lhs, rhs in
            if lhs.priority != rhs.priority { return lhs.priority < rhs.priority }
            return lhs.name < rhs.name
        }
    }

    static func marker(named cityName: String, selectedCity: String, mode: PremiumMapDisplayMode) -> PremiumMapCityMarker? {
        markers(selectedCity: selectedCity, mode: mode).first { cityNameMatches($0.name, cityName) }
    }

    static func labelFrames(selectedCity: String, mode: PremiumMapDisplayMode) -> [CGRect] {
        markers(selectedCity: selectedCity, mode: mode).map(\.labelSafetyFrame)
    }

    static func labelsAvoidCTA(selectedCity: String, mode: PremiumMapDisplayMode) -> Bool {
        labelFrames(selectedCity: selectedCity, mode: mode).allSatisfy { !$0.intersects(ctaSafeFrame) }
    }

    static func supportsCompactWidth(_ width: CGFloat) -> Bool {
        width >= minimumCompactWidth
    }

    static func cityNameMatches(_ lhs: String, _ rhs: String) -> Bool {
        normalizeCity(lhs) == normalizeCity(rhs)
            || (normalizeCity(lhs) == "thehague" && normalizeCity(rhs) == "denhaag")
            || (normalizeCity(lhs) == "denhaag" && normalizeCity(rhs) == "thehague")
    }

    private static func marker(
        _ id: String,
        _ name: String,
        _ provinceID: String,
        _ x: CGFloat,
        _ y: CGFloat,
        _ labelX: CGFloat,
        _ labelY: CGFloat,
        _ role: PremiumMapMarkerRole,
        _ priority: Int
    ) -> PremiumMapCityMarker {
        PremiumMapCityMarker(
            id: id,
            name: name,
            provinceID: provinceID,
            normalizedPosition: CGPoint(x: x, y: y),
            normalizedLabelPosition: CGPoint(x: labelX, y: labelY),
            role: role,
            priority: priority
        )
    }

    private static func normalizeCity(_ value: String) -> String {
        value
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .filter(\.isLetter)
            .lowercased()
    }
}
