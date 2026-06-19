import Foundation

struct AIUsageLimiter {
    private let key = "ai.usageLimiter.timestamps.v1"
    var limit: Int = 20
    var window: TimeInterval = 60 * 60
    var defaults: UserDefaults = .standard

    func canSend(now: Date = Date()) -> Bool {
        recentTimestamps(now: now).count < limit
    }

    func recordSend(now: Date = Date()) {
        let timestamps = (recentTimestamps(now: now) + [now.timeIntervalSince1970])
        defaults.set(timestamps, forKey: key)
    }

    private func recentTimestamps(now: Date) -> [TimeInterval] {
        let cutoff = now.timeIntervalSince1970 - window
        return (defaults.array(forKey: key) as? [TimeInterval] ?? [])
            .filter { $0 >= cutoff }
    }
}

