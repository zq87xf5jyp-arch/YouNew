import Foundation
import Combine
import Network

@MainActor
final class ConnectivityStatus: ObservableObject {
    static let shared = ConnectivityStatus()

    @Published private(set) var isOnline = true
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "YouNew.ConnectivityStatus")

    private init() {
        monitor.pathUpdateHandler = { path in
            let isOnline = path.status == .satisfied
            Task { @MainActor [weak self] in
                self?.isOnline = isOnline
            }
        }
        monitor.start(queue: queue)
    }

    deinit { monitor.cancel() }
}
