import Foundation
import CoreLocation

enum MockNearbyPlacesData {
    static let supportedCities = CityDashboardContentData.supportedCityNames

    static let places: [NearbyPlace] = supportedCities.flatMap { city in
        CityNewcomerPlacesData.places(for: city).map { place in
            NearbyPlace(newcomerPlace: place, cityCenter: CityNewcomerPlacesData.cityCenter(for: city))
        }
    }

    static func saveKey(matching routeID: String) -> String? {
        places.first { place in
            place.saveKey == routeID || place.id.uuidString == routeID
        }?.saveKey
    }
}
