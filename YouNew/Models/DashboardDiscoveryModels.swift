import Foundation
import CoreLocation
import SwiftUI

enum DashboardExternalProvider: String, CaseIterable, Codable, Hashable, Identifiable {
    case booking
    case googleMaps = "google_maps"
    case appleMaps = "apple_maps"
    case tripadvisor
    case thefork
    case official

    var id: String { rawValue }

    var label: String {
        switch self {
        case .booking: return "Booking"
        case .googleMaps: return "Google Maps"
        case .appleMaps: return "Apple Maps"
        case .tripadvisor: return "Tripadvisor"
        case .thefork: return "TheFork"
        case .official: return "Official"
        }
    }
}

enum DashboardExternalLinkCategory: String, CaseIterable, Codable, Hashable, Identifiable {
    case hotels
    case restaurants
    case cafes
    case places
    case transport

    var id: String { rawValue }
}

enum FoodGuideCategory: String, CaseIterable, Codable, Hashable, Identifiable {
    case restaurant
    case cafe
    case breakfast
    case localFood = "local_food"
    case market
    case vegetarian
    case budget
    case fineDining = "fine_dining"

    var id: String { rawValue }
}

struct DashboardExternalLink: Identifiable, Codable, Hashable {
    let id: String
    let provider: DashboardExternalProvider
    let title: String
    let url: URL
    let cityId: CityId?
    let audience: [UserContentCategory]
    let category: DashboardExternalLinkCategory
    let source: String?
    let lastChecked: String?
}

struct FoodGuideItem: Identifiable, Codable, Equatable {
    let id: String
    let cityId: CityId
    let title: String
    let shortTitle: String?
    let description: String
    let category: FoodGuideCategory
    let audience: [UserContentCategory]
    let route: String?
    let externalUrl: URL?
    let query: String?
    let icon: String
    let priority: Int
    let source: OfficialSource?
    let lastChecked: String?
    let hidden: Bool
    let draft: Bool
}

enum TravelLinkKind: String, CaseIterable, Codable, Hashable, Identifiable {
    case booking
    case restaurants
    case cafes
    case places
    case officialGuide
    case maps

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .booking: return "bed.double.fill"
        case .restaurants: return "fork.knife"
        case .cafes: return "cup.and.saucer.fill"
        case .places: return "camera.fill"
        case .officialGuide: return "checkmark.seal.fill"
        case .maps: return "tram.fill"
        }
    }

    var accent: Color {
        switch self {
        case .booking: return AppColors.softBlue
        case .restaurants: return AppColors.dutchOrange
        case .cafes: return AppColors.warning
        case .places: return AppColors.cyanGlow
        case .officialGuide: return AppColors.success
        case .maps: return AppColors.emerald
        }
    }
}

struct TravelLinkItem: Identifiable, Codable, Equatable {
    let id: String
    let cityId: String
    let kind: TravelLinkKind
    let title: String
    let subtitle: String
    let url: URL
    let sourceLabel: String
    let isOfficial: Bool
    let audience: [UserContentCategory]
    let lastChecked: String
    let priority: Int
    let externalLink: DashboardExternalLink?
}

struct CityDashboardStat: Identifiable, Codable, Hashable {
    let id: String
    let value: String
    let label: String
}

enum CityId: String, CaseIterable, Codable, Hashable, Identifiable {
    case amsterdam
    case rotterdam
    case denHaag = "den_haag"
    case leiden
    case utrecht
    case eindhoven
    case maastricht
    case groningen

    var id: String { rawValue }

    nonisolated var displayName: String {
        switch self {
        case .amsterdam: return "Amsterdam"
        case .rotterdam: return "Rotterdam"
        case .denHaag: return "Den Haag"
        case .leiden: return "Leiden"
        case .utrecht: return "Utrecht"
        case .eindhoven: return "Eindhoven"
        case .maastricht: return "Maastricht"
        case .groningen: return "Groningen"
        }
    }

    nonisolated static func resolve(_ value: String?) -> CityId? {
        guard let normalized = value?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: " ", with: "_"),
              !normalized.isEmpty
        else { return nil }

        if let id = CityId(rawValue: normalized) {
            return id
        }
        return allCases.first { city in
            city.displayName
                .lowercased()
                .replacingOccurrences(of: " ", with: "_") == normalized
        }
    }
}

struct DashboardCityCoordinate: Codable, Hashable {
    let lat: Double
    let lng: Double
}

struct DashboardCity: Identifiable, Codable, Equatable {
    let id: CityId
    let name: String
    let province: String
    let country: String
    let heroImage: String?
    let heroImageDark: String?
    let tags: [String]
    let stats: [CityDashboardStat]
    let coordinates: DashboardCityCoordinate
    let municipalityName: String?
    let bookingQuery: String
    let restaurantQuery: String
    let cafeQuery: String
    let placesQuery: String
    let placeSeed: [String]
    let routeCityId: String
}

struct CityDashboardContent {
    let city: DashboardCity
    let heroCity: NLCity?
    let places: [PlaceItem]
    let travelLinks: [TravelLinkItem]
    let aiSummary: String
    let mapFocus: AppDestination

    var cityId: CityId { city.id }
    var routeCityId: String { city.routeCityId }
    var cityName: String { city.name }
    var province: String { city.province }
    var tags: [String] { city.tags }
    var stats: [CityDashboardStat] { city.stats }
    var coordinates: DashboardCityCoordinate { city.coordinates }
    var municipalityName: String { city.municipalityName ?? city.name }
}

enum VisitPlaceCategory: String, CaseIterable, Codable, Hashable, Identifiable {
    case landmark
    case museum
    case park
    case market
    case viewpoint
    case food
    case historic
    case family
    case free
    case hiddenGem
    case rainyDay

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .landmark: return "building.columns.fill"
        case .museum: return "paintpalette.fill"
        case .park: return "leaf.fill"
        case .market: return "basket.fill"
        case .viewpoint: return "binoculars.fill"
        case .food: return "fork.knife"
        case .historic: return "clock.fill"
        case .family: return "figure.2.and.child.holdinghands"
        case .free: return "ticket.fill"
        case .hiddenGem: return "sparkle.magnifyingglass"
        case .rainyDay: return "cloud.rain.fill"
        }
    }

    var accent: Color {
        switch self {
        case .landmark, .historic: return AppColors.dutchOrange
        case .museum, .rainyDay: return AppColors.violet
        case .park, .free: return AppColors.emerald
        case .market, .food: return AppColors.warning
        case .viewpoint: return AppColors.cyanGlow
        case .family: return AppColors.softBlue
        case .hiddenGem: return AppColors.success
        }
    }

    func title(_ language: AppLanguage) -> String {
        switch (self, language) {
        case (.landmark, .russian): return "Ориентир"
        case (.landmark, .dutch): return "Bezienswaardigheid"
        case (.landmark, .english): return "Landmark"
        case (.museum, .russian): return "Музей"
        case (.museum, .dutch): return "Museum"
        case (.museum, .english): return "Museum"
        case (.park, .russian): return "Парк"
        case (.park, .dutch): return "Park"
        case (.park, .english): return "Park"
        case (.market, .russian): return "Рынок"
        case (.market, .dutch): return "Markt"
        case (.market, .english): return "Market"
        case (.viewpoint, .russian): return "Видовая точка"
        case (.viewpoint, .dutch): return "Uitzichtpunt"
        case (.viewpoint, .english): return "Viewpoint"
        case (.food, .russian): return "Еда"
        case (.food, .dutch): return "Eten"
        case (.food, .english): return "Food"
        case (.historic, .russian): return "История"
        case (.historic, .dutch): return "Historisch"
        case (.historic, .english): return "Historic"
        case (.family, .russian): return "Для семьи"
        case (.family, .dutch): return "Gezin"
        case (.family, .english): return "Family"
        case (.free, .russian): return "Бесплатно"
        case (.free, .dutch): return "Gratis"
        case (.free, .english): return "Free"
        case (.hiddenGem, .russian): return "Неочевидное"
        case (.hiddenGem, .dutch): return "Verborgen plek"
        case (.hiddenGem, .english): return "Hidden gem"
        case (.rainyDay, .russian): return "В дождь"
        case (.rainyDay, .dutch): return "Regenachtig"
        case (.rainyDay, .english): return "Rainy day"
        }
    }
}

enum PlacePriceHint: String, Codable, Hashable {
    case free
    case paid
    case mixed
    case unknown
}

struct PlaceCoordinate: Codable, Hashable {
    let lat: Double
    let lng: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
}

struct PlaceItem: Identifiable, Codable, Equatable {
    let id: String
    let cityId: String
    let section: IASection
    let title: String
    let shortTitle: String?
    let description: String
    let category: [VisitPlaceCategory]
    let audience: Set<PersonaTag>
    let address: String?
    let coordinates: PlaceCoordinate?
    let image: String?
    let estimatedVisitTime: String?
    let priceHint: PlacePriceHint?
    let indoor: Bool?
    let goodForRain: Bool?
    let familyFriendly: Bool?
    let priority: Int
    let source: OfficialSource?
    let lastChecked: String?
    let route: String?
    let externalUrl: URL?
    let action: String?
    let hidden: Bool
    let draft: Bool

    var destination: AppDestination { .placeDetail(id) }
    var primaryCategory: VisitPlaceCategory { category.first ?? .landmark }

    func isVisible(cityId selectedCityId: String, audience selectedAudience: UserContentCategory?) -> Bool {
        !hidden
            && !draft
            && !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !cityId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && IAUserMode.from(contentCategory: selectedAudience).canSee(section)
            && cityId.caseInsensitiveCompare(selectedCityId) == .orderedSame
            && !audience.isEmpty
            && source != nil
            && lastChecked?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && ContentAccessPolicy.canShowToUser(audience: audience, selectedCategory: selectedAudience)
    }
}

enum CalendarEventType: String, CaseIterable, Codable, Hashable, Identifiable {
    case publicHoliday
    case observance
    case schoolHoliday
    case cityEvent
    case serviceClosure
    case touristEvent

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .publicHoliday: return "flag.fill"
        case .observance: return "sparkles"
        case .schoolHoliday: return "graduationcap.fill"
        case .cityEvent: return "building.2.fill"
        case .serviceClosure: return "exclamationmark.triangle.fill"
        case .touristEvent: return "camera.fill"
        }
    }

    var accent: Color {
        switch self {
        case .publicHoliday: return AppColors.dutchOrange
        case .observance: return AppColors.softBlue
        case .schoolHoliday: return AppColors.emerald
        case .cityEvent, .touristEvent: return AppColors.cyanGlow
        case .serviceClosure: return AppColors.warning
        }
    }

    func title(_ language: AppLanguage) -> String {
        switch (self, language) {
        case (.publicHoliday, .russian): return "Праздник"
        case (.publicHoliday, .dutch): return "Feestdag"
        case (.publicHoliday, .english): return "Public holiday"
        case (.observance, .russian): return "Дата"
        case (.observance, .dutch): return "Herdenking"
        case (.observance, .english): return "Observance"
        case (.schoolHoliday, .russian): return "Каникулы"
        case (.schoolHoliday, .dutch): return "Schoolvakantie"
        case (.schoolHoliday, .english): return "School holiday"
        case (.cityEvent, .russian): return "Город"
        case (.cityEvent, .dutch): return "Stadsevenement"
        case (.cityEvent, .english): return "City event"
        case (.serviceClosure, .russian): return "Сервисы"
        case (.serviceClosure, .dutch): return "Dienstwijziging"
        case (.serviceClosure, .english): return "Service change"
        case (.touristEvent, .russian): return "Для туристов"
        case (.touristEvent, .dutch): return "Toeristisch"
        case (.touristEvent, .english): return "Tourist event"
        }
    }
}

struct CalendarEvent: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let localTitle: String?
    let date: Date
    let endDate: Date?
    let type: CalendarEventType
    let countryCode: String
    let cityId: String?
    let audience: Set<PersonaTag>
    let description: String?
    let impact: String?
    let source: OfficialSource?
    let lastChecked: String?
    let priority: Int
    let official: Bool
    let dayOffGuaranteed: Bool?
    let affectsServices: Bool?
    let affectsTransport: Bool?
    let hidden: Bool
    let draft: Bool

    func isVisible(cityId selectedCityId: String, audience selectedAudience: UserContentCategory?, now: Date = Date()) -> Bool {
        !hidden
            && !draft
            && date >= CalendarEventData.calendar.startOfDay(for: now)
            && (cityId == nil || cityId?.caseInsensitiveCompare(selectedCityId) == .orderedSame)
            && !audience.isEmpty
            && source != nil
            && lastChecked?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && ContentAccessPolicy.canShowToUser(audience: audience, selectedCategory: selectedAudience)
    }
}

enum CalendarEventData {
    static var calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Amsterdam") ?? .current
        return calendar
    }()
}
