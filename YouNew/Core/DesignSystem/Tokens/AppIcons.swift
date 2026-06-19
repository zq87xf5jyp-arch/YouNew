import Foundation

enum AppIcons {
    enum Metrics {
        static let small: CGFloat = 14
        static let medium: CGFloat = 17
        static let large: CGFloat = 22
        static let actionContainer: CGFloat = 42
        static let tabContainerWidth: CGFloat = 42
        static let tabContainerHeight: CGFloat = 30
        static let minimumTouchTarget: CGFloat = 44
    }

    // MARK: - Navigation & Guidance
    static let home      = "house"
    static let homeActive = "house.fill"
    static let search    = "magnifyingglass"
    static let searchActive = "magnifyingglass"
    static let map       = "map"
    static let mapActive = "map.fill"
    static let nearby    = "location.circle"
    static let route     = "tram.fill.tunnel"
    static let timeline  = "point.topleft.down.curvedto.point.bottomright.up"
    static let compass   = "safari"
    static let back      = "chevron.left"
    static let forward   = "chevron.right"
    static let settings  = "gearshape"
    static let more = "ellipsis.circle"
    static let moreActive = "ellipsis.circle.fill"
    static let assistant = "sparkles"
    static let assistantActive = "sparkles"

    // MARK: - Trust & Verification
    static let officialSource = "checkmark.shield"
    static let verified       = "checkmark.shield.fill"
    static let source         = "building.columns"
    static let updated        = "arrow.clockwise"
    static let privacy        = "lock.shield"
    static let educational    = "graduationcap"
    static let guideOnly      = "info.circle"

    // MARK: - Onboarding
    static let checklist  = "checklist.checked"
    static let progress   = "chart.line.uptrend.xyaxis"
    static let nextStep   = "arrow.right.circle"
    static let complete   = "checkmark.circle.fill"
    static let milestone  = "flag.checkered"
    static let resources  = "books.vertical"

    // MARK: - Content Types
    static let letter      = "envelope.open"
    static let fine        = "doc.text"
    static let institution = "building.2"
    static let scam        = "exclamationmark.octagon"
    static let dutchTerm   = "character.book.closed"
    static let legal       = "scale.3d"
    static let tip         = "lightbulb"
    static let reminder    = "calendar.badge.clock"
    static let ai          = "sparkles"

    // MARK: - Semantic
    static let warning = "exclamationmark.triangle"
    static let info    = "info.circle"
    static let success = "checkmark.circle"
    static let error   = "xmark.circle"
    static let pending = "clock"

    // MARK: - Actions
    static let save     = "bookmark"
    static let saved    = "bookmark.fill"
    static let share    = "square.and.arrow.up"
    static let expand   = "chevron.down"
    static let collapse = "chevron.up"
    static let external = "arrow.up.right.square"
    static let copy     = "doc.on.doc"
}
