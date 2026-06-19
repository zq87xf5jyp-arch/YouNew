import Foundation
import CoreLocation
import Combine

@MainActor
final class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var location: CLLocation?
    @Published var locationFetchFailed: Bool = false

    private let manager = CLLocationManager()
    private var shouldRequestLocationAfterAuthorization = false

    override init() {
        authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestWhenInUsePermission() {
        shouldRequestLocationAfterAuthorization = true
        manager.requestWhenInUseAuthorization()
    }

    func requestLocation() {
        locationFetchFailed = false
        manager.requestLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if shouldRequestLocationAfterAuthorization,
           Self.isAuthorized(manager.authorizationStatus) {
            shouldRequestLocationAfterAuthorization = false
            requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
        locationFetchFailed = false
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let clError = error as? CLError else { return }
        switch clError.code {
        case .locationUnknown:
            break
        default:
            locationFetchFailed = true
        }
    }

    private static func isAuthorized(_ status: CLAuthorizationStatus) -> Bool {
#if os(iOS) || os(tvOS) || os(watchOS)
        status == .authorizedWhenInUse || status == .authorizedAlways
#else
        status == .authorizedAlways
#endif
    }
}
