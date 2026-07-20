import Foundation
import Testing
@testable import YouNew

struct VisitLeidenCalendarParserTests {
    @Test func discoversEveryCalendarPageWithoutRepeatingTheFirstPage() {
        let html = """
        <a href="/en/event-calendar?order=desc&amp;sort=calendar&amp;page=2">2</a>
        <a href="/en/event-calendar?order=desc&amp;sort=calendar&amp;page=3">3</a>
        """

        #expect(VisitLeidenHTMLParser.pageCount(data: Data(html.utf8)) == 3)
    }

    @Test func parsesPublicSchemaEventMarkupAndDropsExpiredItems() throws {
        let html = """
        <ul>
          <li class="tiles__tile" itemscope itemtype="http://schema.org/Event">
            <a href="/en/event-calendar/123456789/walk-in-concerts">Details</a>
            <meta itemprop="name" content="Walk-in concerts">
            <meta itemprop="startDate" content="2026-07-13">
            <meta itemprop="endDate" content="2026-07-20">
            <div itemprop="location">
              <meta itemprop="name" content="Leiden city centre">
              <meta itemprop="streetAddress" content="Pieterskerkplein 1">
              <meta itemprop="addressLocality" content="Leiden">
            </div></div>
            <img src="https://example.com/leiden.jpg">
            <p class="description__text">Music &amp; culture in Leiden.</p>
          </li>
          <li class="tiles__tile" itemscope itemtype="http://schema.org/Event">
            <a href="/en/event-calendar/987654321/expired">Details</a>
            <meta itemprop="name" content="Expired event">
            <meta itemprop="startDate" content="2026-01-01">
            <meta itemprop="endDate" content="2026-01-02">
          </li>
        </ul>
        """
        let now = try #require(ISO8601DateFormatter().date(from: "2026-07-13T10:00:00Z"))

        let events = VisitLeidenHTMLParser.parse(data: Data(html.utf8), now: now)
        let event = try #require(events.first)

        #expect(events.count == 1)
        #expect(event.id == "123456789")
        #expect(event.title == "Walk-in concerts")
        #expect(event.venue == "Leiden city centre")
        #expect(event.address == "Pieterskerkplein 1, Leiden")
        #expect(event.summary == "Music & culture in Leiden.")
        #expect(event.sourceURL.absoluteString == "https://www.visitleiden.nl/en/event-calendar/123456789/walk-in-concerts")
    }

    @Test func acceptsSecureSchemaMarkupTimestampDatesAndRelativeImages() throws {
        let html = """
        <li class="tiles__tile" itemscope itemtype="https://schema.org/Event">
          <a href="/en/event-calendar/555/current-event">Details</a>
          <meta itemprop="name" content="Current event">
          <meta itemprop="startDate" content="2026-07-13T10:00:00+02:00">
          <meta itemprop="endDate" content="2026-07-14T18:00:00+02:00">
          <img src="/media/current-event.jpg">
        </li>
        """
        let now = try #require(ISO8601DateFormatter().date(from: "2026-07-13T10:00:00Z"))

        let event = try #require(VisitLeidenHTMLParser.parse(data: Data(html.utf8), now: now).first)

        #expect(event.id == "555")
        #expect(event.imageURL?.absoluteString == "https://www.visitleiden.nl/media/current-event.jpg")
    }
}
