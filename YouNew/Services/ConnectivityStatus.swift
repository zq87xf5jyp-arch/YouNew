import Combine
import Foundation
import Network

final class ConnectivityStatus: ObservableObject {
    static let shared = ConnectivityStatus()

    @Published private(set) var isOnline = true

    private let monitor: NWPathMonitor
    private let monitorQueue = DispatchQueue(label: "app.younew.connectivity-status")

    private init(monitor: NWPathMonitor = NWPathMonitor()) {
        self.monitor = monitor

        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                self?.isOnline = path.status == .satisfied
            }
        }
        monitor.start(queue: monitorQueue)
    }

    deinit {
        monitor.cancel()
    }
}
