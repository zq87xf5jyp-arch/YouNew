import Foundation

enum DiscoveryEventFilter {
    static func events(
        from events: [CalendarEvent],
        matching type: DiscoveryListType,
        now: Date = Date(),
        calendar: Calendar = CalendarEventData.calendar
    ) -> [CalendarEvent] {
        switch type {
        case .eventsWeekend:
            guard let interval = weekendInterval(containingOrFollowing: now, calendar: calendar) else { return [] }
            return events.filter { overlaps($0, interval: interval, calendar: calendar) }
        case .eventsWeek:
            guard let interval = calendar.dateInterval(of: .weekOfYear, for: now) else { return [] }
            return events.filter { overlaps($0, interval: interval, calendar: calendar) }
        case .eventsFree:
            return events.filter { containsAnyKeyword($0, keywords: freeKeywords) }
        case .eventsFamily:
            return events.filter {
                $0.type == .schoolHoliday || containsAnyKeyword($0, keywords: familyKeywords)
            }
        case .eventsMusic:
            return events.filter { containsAnyKeyword($0, keywords: musicKeywords) }
        case .eventsMuseums:
            return events.filter { containsAnyKeyword($0, keywords: museumKeywords) }
        case .eventsMarkets:
            return events.filter { containsAnyKeyword($0, keywords: marketKeywords) }
        case .eventsFestivals, .festivals:
            return events.filter { containsAnyKeyword($0, keywords: festivalKeywords) }
        case .sports, .freeActivities, .freePlaces, .localFood, .vegetarian, .breakfast, .hotels, .shopping, .gallery:
            return []
        }
    }

    private static let freeKeywords = [
        "free", "free admission", "no admission", "gratis", "gratis toegang", "kosteloos"
    ]

    private static let familyKeywords = [
        "family", "families", "children", "child", "kids", "gezinsactiviteit", "gezinsactiviteiten", "familie", "kinderen"
    ]

    private static let musicKeywords = [
        "music", "musical", "concert", "orchestra", "choir", "jazz", "opera", "muziek"
    ]

    private static let museumKeywords = [
        "museum", "museums", "exhibition", "exhibitions", "gallery", "galleries", "tentoonstelling", "tentoonstellingen"
    ]

    private static let marketKeywords = [
        "market", "markets", "markt"
    ]

    private static let festivalKeywords = [
        "festival", "festivals"
    ]

    private static func weekendInterval(containingOrFollowing now: Date, calendar: Calendar) -> DateInterval? {
        let today = calendar.startOfDay(for: now)
        let weekday = calendar.component(.weekday, from: today)
        let daysUntilSaturday: Int

        switch weekday {
        case 1:
            daysUntilSaturday = -1
        case 7:
            daysUntilSaturday = 0
        default:
            daysUntilSaturday = 7 - weekday
        }

        guard let saturday = calendar.date(byAdding: .day, value: daysUntilSaturday, to: today),
              let monday = calendar.date(byAdding: .day, value: 2, to: saturday) else { return nil }
        return DateInterval(start: saturday, end: monday)
    }

    private static func overlaps(_ event: CalendarEvent, interval: DateInterval, calendar: Calendar) -> Bool {
        let eventStart = calendar.startOfDay(for: event.date)
        let eventEnd = calendar.startOfDay(for: event.endDate ?? event.date)
        return eventStart < interval.end && eventEnd >= interval.start
    }

    private static func containsAnyKeyword(_ event: CalendarEvent, keywords: [String]) -> Bool {
        let searchableText = [event.title, event.localTitle, event.description, event.impact]
            .compactMap { $0 }
            .joined(separator: " ")
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .lowercased()
        return keywords.contains { keyword in
            let escapedKeyword = NSRegularExpression.escapedPattern(for: keyword)
            let pattern = "(?<![\\p{L}\\p{N}])\(escapedKeyword)(?![\\p{L}\\p{N}])"
            return searchableText.range(of: pattern, options: .regularExpression) != nil
        }
    }
}
