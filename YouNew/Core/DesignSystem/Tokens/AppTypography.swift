import SwiftUI

enum AppTypography {
    enum Scale {
        static let hero: CGFloat = 48
        static let section: CGFloat = 32
        static let card: CGFloat = 22
        static let body: CGFloat = 16
        static let caption: CGFloat = 13
    }

    // MARK: - Display
    static let display   = Font.system(size: Scale.hero, weight: .semibold, design: .default)
    static let heroTitle = Font.system(size: Scale.hero, weight: .semibold, design: .default)
    static let largeTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)

    // MARK: - Headings
    static let title        = Font.system(.title2, design: .rounded).weight(.bold)
    static let sectionTitle = Font.system(size: Scale.section, weight: .semibold, design: .default)
    static let cardTitle    = Font.system(size: Scale.card, weight: .semibold, design: .default)

    // MARK: - Body
    static let bodyScale = Font.system(size: Scale.body, weight: .regular, design: .default)
    static let bodyLeading = Font.system(.body, design: .rounded).weight(.medium)
    static let body        = Font.system(.body, design: .rounded)
    static let bodyStrong  = Font.system(.body, design: .rounded).weight(.semibold)

    // MARK: - Small
    static let captionScale = Font.system(size: Scale.caption, weight: .regular, design: .default)
    static let caption      = Font.system(.caption,  design: .rounded)
    static let captionStrong = Font.system(.caption, design: .rounded).weight(.semibold)
    static let metadata     = Font.system(.caption2, design: .rounded).weight(.medium)
    static let footnote     = Font.system(.footnote, design: .rounded)
    static let footnoteStrong = Font.system(.footnote, design: .rounded).weight(.semibold)

    // MARK: - Navigation
    static let tabLabel = Font.system(.caption2, design: .rounded).weight(.semibold)

    // MARK: - Tracking Values (use with .tracking() modifier)
    static let labelTracking: CGFloat   = 0.6
    static let overlineTracking: CGFloat = 1.4
    static let chipTracking: CGFloat    = 0.3
}
