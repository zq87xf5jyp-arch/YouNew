import SwiftUI

struct OpenDiscoveryMenuAction {
    private let handler: () -> Void

    init(_ handler: @escaping () -> Void = {}) {
        self.handler = handler
    }

    func callAsFunction() {
        handler()
    }
}

private struct OpenDiscoveryMenuKey: EnvironmentKey {
    static let defaultValue = OpenDiscoveryMenuAction()
}

extension EnvironmentValues {
    var openDiscoveryMenu: OpenDiscoveryMenuAction {
        get { self[OpenDiscoveryMenuKey.self] }
        set { self[OpenDiscoveryMenuKey.self] = newValue }
    }
}

enum DiscoveryMenuRoute: String, CaseIterable, Identifiable, Sendable {
    case museums
    case attractions
    case historicPlaces = "historic-places"
    case parks
    case nature
    case familyActivities = "family-activities"
    case architecture
    case freePlaces = "free-places"
    case restaurants
    case cafes
    case bars
    case bakeries
    case localFood = "local-food"
    case vegetarian
    case breakfast
    case hotels
    case shopping
    case eventsToday = "events-today"
    case eventsWeekend = "events-weekend"
    case eventsWeek = "events-week"
    case eventsFree = "events-free"
    case eventsFamily = "events-family"
    case eventsMusic = "events-music"
    case eventsMuseums = "events-museums"
    case eventsMarkets = "events-markets"
    case eventsFestivals = "events-festivals"
    case servicesNearby = "services-nearby"
    case localPartners = "local-partners"
    case gallery
    case businessRegister = "business-register"
    case businessLogin = "business-login"
    case businessManage = "business-manage"

    var id: String { rawValue }

    func destination(city: CityId) -> AppDestination {
        switch self {
        case .museums:
            return .museumList(city: city)
        case .parks, .nature:
            return .natureList(city: city)
        case .attractions, .historicPlaces:
            return .landmarkList(city: city)
        case .architecture:
            return .leisureSection(city: city, type: .architecture)
        case .familyActivities:
            return .leisureSection(city: city, type: .family)
        case .freePlaces:
            return .discoveryList(city: city, type: .freePlaces)
        case .restaurants:
            return .restaurantList(city: city)
        case .cafes, .bakeries:
            return .cafeList(city: city)
        case .bars:
            return .leisureSection(city: city, type: .nightlife)
        case .localFood:
            return .discoveryList(city: city, type: .localFood)
        case .vegetarian:
            return .discoveryList(city: city, type: .vegetarian)
        case .breakfast:
            return .discoveryList(city: city, type: .breakfast)
        case .hotels:
            return .discoveryList(city: city, type: .hotels)
        case .shopping:
            return .discoveryList(city: city, type: .shopping)
        case .eventsToday:
            return .eventList(city: city)
        case .eventsWeekend:
            return .discoveryList(city: city, type: .eventsWeekend)
        case .eventsWeek:
            return .discoveryList(city: city, type: .eventsWeek)
        case .eventsFree:
            return .discoveryList(city: city, type: .eventsFree)
        case .eventsFamily:
            return .discoveryList(city: city, type: .eventsFamily)
        case .eventsMusic:
            return .discoveryList(city: city, type: .eventsMusic)
        case .eventsMuseums:
            return .discoveryList(city: city, type: .eventsMuseums)
        case .eventsMarkets:
            return .discoveryList(city: city, type: .eventsMarkets)
        case .eventsFestivals:
            return .discoveryList(city: city, type: .eventsFestivals)
        case .gallery:
            return .discoveryList(city: city, type: .gallery)
        case .servicesNearby: return .mapHub
        case .localPartners: return .localPartners
        case .businessRegister: return .businessGrowth
        case .businessLogin: return .businessLogin
        case .businessManage: return .businessDashboard
        }
    }
}
