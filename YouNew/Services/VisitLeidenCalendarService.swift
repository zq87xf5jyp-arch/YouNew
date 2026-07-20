import Foundation
import Combine

struct VisitLeidenEventRecord: Codable, Sendable, Identifiable {
    let id: String
    let title: String
    let summary: String
    let startDate: Date
    let endDate: Date?
    let venue: String?
    let address: String?
    let imageURL: URL?
    let sourceURL: URL

    func calendarEvent(now: Date = Date(), priority: Int) -> CalendarEvent {
        let calendar = CalendarEventData.calendar
        let today = calendar.startOfDay(for: now)
        let visibleDate = max(calendar.startOfDay(for: startDate), today)
        return CalendarEvent(
            id: "visit-leiden-\(id)",
            title: title,
            localTitle: nil,
            date: visibleDate,
            endDate: endDate,
            type: .cityEvent,
            countryCode: "NL",
            cityId: "Leiden",
            audience: [.universal, .tourist, .student, .worker, .family, .entrepreneur, .eu, .nonEU, .highlySkilledMigrant, .lgbt],
            description: summary,
            impact: [venue, address].compactMap { $0 }.joined(separator: " · "),
            source: OfficialSource(title: "Visit Leiden event calendar", url: sourceURL, institution: "Visit Leiden"),
            lastChecked: ISO8601DateFormatter().string(from: now),
            priority: priority,
            official: true,
            dayOffGuaranteed: false,
            affectsServices: false,
            affectsTransport: false,
            hidden: false,
            draft: false
        )
    }
}

enum VisitLeidenCalendarError: Error {
    case invalidResponse
    case noEvents
}

actor VisitLeidenCalendarService {
    static let shared = VisitLeidenCalendarService()

    private let cacheKey = VisitLeidenCalendarSnapshot.cacheKey
    private let cacheDateKey = VisitLeidenCalendarSnapshot.cacheDateKey
    private let cacheLifetime: TimeInterval = 30 * 60

    func events(forceRefresh: Bool = false, now: Date = Date()) async throws -> [VisitLeidenEventRecord] {
        if !forceRefresh,
           let cached = cachedEvents(),
           let cachedAt = UserDefaults.standard.object(forKey: cacheDateKey) as? Date,
           now.timeIntervalSince(cachedAt) < cacheLifetime {
            return active(cached, now: now)
        }

        do {
            let records = try await fetchAllPages(now: now)
            let encoded = try JSONEncoder().encode(records)
            UserDefaults.standard.set(encoded, forKey: cacheKey)
            UserDefaults.standard.set(now, forKey: cacheDateKey)
            return records
        } catch {
            if let cached = cachedEvents(), !cached.isEmpty {
                return active(cached, now: now)
            }
            throw error
        }
    }

    func cachedEvents(now: Date = Date()) -> [VisitLeidenEventRecord] {
        active(cachedEvents() ?? [], now: now)
    }

    private func fetchAllPages(now: Date) async throws -> [VisitLeidenEventRecord] {
        let firstPageURL = URL(string: "https://www.visitleiden.nl/en/event-calendar")!
        let (firstPageData, firstPageRecords) = try await Self.fetchPage(firstPageURL, now: now)
        let pageCount = min(max(VisitLeidenHTMLParser.pageCount(data: firstPageData), 1), 10)
        let urls = pageCount > 1 ? (2 ... pageCount).compactMap(Self.pageURL) : []

        var records = firstPageRecords
        try await withThrowingTaskGroup(of: [VisitLeidenEventRecord].self) { group in
            for url in urls {
                group.addTask {
                    let page = try await Self.fetchPage(url, now: now)
                    return page.records
                }
            }
            for try await pageRecords in group {
                records.append(contentsOf: pageRecords)
            }
        }

        var seen = Set<String>()
        var unique: [VisitLeidenEventRecord] = []
        for record in records where seen.insert(record.id).inserted {
            unique.append(record)
        }
        unique.sort {
            if $0.startDate == $1.startDate { return $0.title < $1.title }
            return $0.startDate < $1.startDate
        }
        guard !unique.isEmpty else { throw VisitLeidenCalendarError.noEvents }
        return unique
    }

    nonisolated private static func pageURL(_ page: Int) -> URL? {
        var components = URLComponents(string: "https://www.visitleiden.nl/en/event-calendar")
        components?.queryItems = [
            URLQueryItem(name: "order", value: "desc"),
            URLQueryItem(name: "sort", value: "calendar"),
            URLQueryItem(name: "page", value: String(page))
        ]
        return components?.url
    }

    nonisolated private static func fetchPage(_ url: URL, now: Date) async throws -> (data: Data, records: [VisitLeidenEventRecord]) {
        var request = URLRequest(url: url)
        request.timeoutInterval = 18
        request.setValue("YouNew/1.0 (+https://younew.nl)", forHTTPHeaderField: "User-Agent")
        request.setValue("en-NL,en;q=0.9", forHTTPHeaderField: "Accept-Language")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, 200 ..< 300 ~= http.statusCode else {
            throw VisitLeidenCalendarError.invalidResponse
        }
        return (data, VisitLeidenHTMLParser.parse(data: data, now: now))
    }

    private func cachedEvents() -> [VisitLeidenEventRecord]? {
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else { return nil }
        return try? JSONDecoder().decode([VisitLeidenEventRecord].self, from: data)
    }

    private func active(_ records: [VisitLeidenEventRecord], now: Date) -> [VisitLeidenEventRecord] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Amsterdam") ?? .current
        let today = calendar.startOfDay(for: now)
        return records.filter { calendar.startOfDay(for: $0.endDate ?? $0.startDate) >= today }
    }
}

enum VisitLeidenCalendarSnapshot {
    nonisolated static let cacheKey = "visit-leiden-calendar-v1"
    nonisolated static let cacheDateKey = "visit-leiden-calendar-v1-date"

    static func calendarEvents(now: Date = Date()) -> [CalendarEvent] {
        guard let data = UserDefaults.standard.data(forKey: cacheKey),
              let records = try? JSONDecoder().decode([VisitLeidenEventRecord].self, from: data) else { return [] }
        let today = CalendarEventData.calendar.startOfDay(for: now)
        return records
            .filter { CalendarEventData.calendar.startOfDay(for: $0.endDate ?? $0.startDate) >= today }
            .enumerated()
            .map { index, record in record.calendarEvent(now: now, priority: 1_000 + index) }
    }
}

enum VisitLeidenHTMLParser {
    nonisolated static func pageCount(data: Data) -> Int {
        guard let html = String(data: data, encoding: .utf8) else { return 1 }
        let pageValues = captures(#"(?:\?|&amp;|&)page=(\d+)"#, in: html)
            .compactMap(Int.init)
        return max(pageValues.max() ?? 1, 1)
    }

    nonisolated static func parse(data: Data, now: Date = Date()) -> [VisitLeidenEventRecord] {
        guard let html = String(data: data, encoding: .utf8) else { return [] }
        return eventBlocks(in: html).compactMap { block in
            guard let href = capture(#"href="([^"]*/event-calendar/[^"]+)""#, in: block),
                  let sourceURL = URL(string: href, relativeTo: URL(string: "https://www.visitleiden.nl"))?.absoluteURL,
                  let rawTitle = capture(#"<meta itemprop="name" content="([^"]+)""#, in: block),
                  let startValue = capture(#"<meta itemprop="startDate" content="([^"]+)""#, in: block),
                  let startDate = date(startValue) else { return nil }

            let endDate = capture(#"<meta itemprop="endDate" content="([^"]+)""#, in: block).flatMap(date)
            let effectiveEnd = endDate ?? startDate
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(identifier: "Europe/Amsterdam") ?? .current
            guard calendar.startOfDay(for: effectiveEnd) >= calendar.startOfDay(for: now) else { return nil }

            let location = capture(#"<meta itemprop="name" content="([^"]+)""#, in: locationBlock(in: block) ?? "")
            let street = capture(#"<meta itemprop="streetAddress" content="([^"]+)""#, in: block)
            let locality = capture(#"<meta itemprop="addressLocality" content="([^"]+)""#, in: block)
            let address = [street, locality].compactMap { $0 }.map(decode).joined(separator: ", ")
            let image = capture(#"<img src="([^"]+)""#, in: block)
                .flatMap { URL(string: decode($0), relativeTo: URL(string: "https://www.visitleiden.nl"))?.absoluteURL }
            let summary = capture(#"<p class="description__text[^"]*">\s*([\s\S]*?)\s*</p>"#, in: block)
                .map { stripTags(decode($0)) } ?? "Current event listed by Visit Leiden."
            let identifier = sourceURL.pathComponents.dropLast().last ?? sourceURL.lastPathComponent

            return VisitLeidenEventRecord(
                id: identifier,
                title: decode(rawTitle),
                summary: summary,
                startDate: startDate,
                endDate: endDate,
                venue: location.map(decode),
                address: address.isEmpty ? nil : address,
                imageURL: image,
                sourceURL: sourceURL
            )
        }
    }

    nonisolated private static func eventBlocks(in html: String) -> [String] {
        matches(#"<li class="tiles__tile[\s\S]*?itemtype="https?://schema.org/Event"[\s\S]*?</li>"#, in: html)
    }

    nonisolated private static func locationBlock(in block: String) -> String? {
        capture(#"<div itemprop="location"[\s\S]*?</div>\s*</div>"#, in: block, group: 0)
    }

    nonisolated private static func date(_ value: String) -> Date? {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: String(value.prefix(10)))
    }

    nonisolated private static func capture(_ pattern: String, in value: String, group: Int = 1) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: value, range: NSRange(value.startIndex..., in: value)),
              let range = Range(match.range(at: group), in: value) else { return nil }
        return String(value[range])
    }

    nonisolated private static func matches(_ pattern: String, in value: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        return regex.matches(in: value, range: NSRange(value.startIndex..., in: value)).compactMap { match in
            Range(match.range, in: value).map { String(value[$0]) }
        }
    }

    nonisolated private static func captures(_ pattern: String, in value: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        return regex.matches(in: value, range: NSRange(value.startIndex..., in: value)).compactMap { match in
            guard match.numberOfRanges > 1,
                  let range = Range(match.range(at: 1), in: value) else { return nil }
            return String(value[range])
        }
    }

    nonisolated private static func decode(_ value: String) -> String {
        value
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#039;", with: "'")
            .replacingOccurrences(of: "&apos;", with: "'")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&nbsp;", with: " ")
    }

    nonisolated private static func stripTags(_ value: String) -> String {
        value.replacingOccurrences(of: #"<[^>]+>"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

@MainActor
final class VisitLeidenCalendarModel: ObservableObject {
    enum Phase: Equatable { case idle, loading, live, cached, unavailable }

    @Published private(set) var events: [CalendarEvent] = []
    @Published private(set) var phase: Phase = .idle

    func load(cityID: String, forceRefresh: Bool = false) async {
        guard cityID.caseInsensitiveCompare("Leiden") == .orderedSame else {
            events = []
            phase = .idle
            return
        }

        phase = .loading
        let cached = await VisitLeidenCalendarService.shared.cachedEvents()
        if !cached.isEmpty {
            events = Self.calendarEvents(cached)
            phase = .cached
        }
        do {
            let records = try await VisitLeidenCalendarService.shared.events(forceRefresh: forceRefresh)
            guard !Task.isCancelled else { return }
            events = Self.calendarEvents(records)
            phase = .live
        } catch is CancellationError {
            return
        } catch {
            if events.isEmpty { phase = .unavailable }
        }
    }

    private static func calendarEvents(_ records: [VisitLeidenEventRecord]) -> [CalendarEvent] {
        records.enumerated().map { index, record in record.calendarEvent(priority: 1_000 + index) }
    }
}
