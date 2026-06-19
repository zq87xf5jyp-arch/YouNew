import Foundation
import CoreLocation

enum MockNearbyPlacesData {
    static let supportedCities = CityNewcomerPlacesData.priorityCities

    static let places: [NearbyPlace] = supportedCities.flatMap { city in
        CityNewcomerPlacesData.places(for: city).map { place in
            NearbyPlace(newcomerPlace: place, cityCenter: CityNewcomerPlacesData.cityCenter(for: city))
        }
    }
}
