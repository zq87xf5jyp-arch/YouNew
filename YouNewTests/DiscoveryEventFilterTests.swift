import Foundation
import XCTest
@testable import YouNew

final class DiscoveryEventFilterTests: XCTestCase {
    func testOngoingEventOverlapsCurrentWeekAndWeekend() throws {
        let calendar = testCalendar
        let now = try XCTUnwrap(date(2026, 7, 17, calendar: calendar))
        let ongoing = makeEvent(
            id: "ongoing",
            title: "Museum exhibition",
            start: try XCTUnwrap(date(2026, 7, 13, calendar: calendar)),
            end: try XCTUnwrap(date(2026, 7, 31, calendar: calendar))
        )
        let later = makeEvent(
            id: "later",
            title: "Later event",
            start: try XCTUnwrap(date(2026, 8, 1, calendar: calendar))
        )

        XCTAssertEqual(
            DiscoveryEventFilter.events(from: [ongoing, later], matching: .eventsWeek, now: now, calendar: calendar).map(\.id),
            ["ongoing"]
        )
        XCTAssertEqual(
            DiscoveryEventFilter.events(from: [ongoing, later], matching: .eventsWeekend, now: now, calendar: calendar).map(\.id),
            ["ongoing"]
        )
    }

    func testExactEventSubsetsOnlyReturnMatchingDetails() throws {
        let calendar = testCalendar
        let eventDate = try XCTUnwrap(date(2026, 7, 18, calendar: calendar))
        let events = [
            makeEvent(id: "free", title: "Free admission", start: eventDate),
            makeEvent(id: "family", title: "Family workshop", start: eventDate),
            makeEvent(id: "music", title: "Jazz concert", start: eventDate),
            makeEvent(id: "museum", title: "Museum exhibition", start: eventDate),
            makeEvent(id: "market", title: "Saturday market", start: eventDate),
            makeEvent(id: "festival", title: "Summer festival", start: eventDate),
            makeEvent(id: "freedom", title: "Freedom celebration", start: eventDate),
            makeEvent(id: "other", title: "Unrelated city update", start: eventDate)
        ]

        let expectations: [(DiscoveryListType, String)] = [
            (.eventsFree, "free"),
            (.eventsFamily, "family"),
            (.eventsMusic, "music"),
            (.eventsMuseums, "museum"),
            (.eventsMarkets, "market"),
            (.eventsFestivals, "festival")
        ]

        for (type, expectedID) in expectations {
            XCTAssertEqual(
                DiscoveryEventFilter.events(from: events, matching: type, now: eventDate, calendar: calendar).map(\.id),
                [expectedID],
                "Unexpected details for \(type.rawValue)"
            )
        }
    }

    func testNonEventDiscoveryTypesNeverBorrowUnfilteredEvents() throws {
        let calendar = testCalendar
        let eventDate = try XCTUnwrap(date(2026, 7, 18, calendar: calendar))
        let event = makeEvent(id: "festival", title: "Summer festival", start: eventDate)
        let nonEventTypes: [DiscoveryListType] = [
            .sports, .freeActivities, .freePlaces, .localFood, .vegetarian,
            .breakfast, .hotels, .shopping, .gallery
        ]

        for type in nonEventTypes {
            XCTAssertTrue(
                DiscoveryEventFilter.events(from: [event], matching: type, now: eventDate, calendar: calendar).isEmpty,
                "\(type.rawValue) borrowed an event detail"
            )
        }
    }

    private var testCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Amsterdam")!
        calendar.firstWeekday = 2
        return calendar
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, calendar: Calendar) -> Date? {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))
    }

    private func makeEvent(id: String, title: String, start: Date, end: Date? = nil) -> CalendarEvent {
        CalendarEvent(
            id: id,
            title: title,
            localTitle: nil,
            date: start,
            endDate: end,
            type: .cityEvent,
            countryCode: "NL",
            cityId: "Leiden",
            audience: [.universal],
            description: nil,
            impact: nil,
            source: OfficialSource(title: "Test source", url: URL(string: "https://example.com")!, institution: "Tests"),
            lastChecked: "2026-07-17",
            priority: 1,
            official: true,
            dayOffGuaranteed: false,
            affectsServices: false,
            affectsTransport: false,
            hidden: false,
            draft: false
        )
    }
}
