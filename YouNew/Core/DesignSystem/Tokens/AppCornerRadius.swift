import SwiftUI

enum AppCornerRadius {
    static let xSmall: CGFloat = 16
    static let small:  CGFloat = 16
    static let medium: CGFloat = 16
    static let large:  CGFloat = 24
    static let xLarge: CGFloat = 32
    static let hero:   CGFloat = 24
    static let pill:   CGFloat = 999
}

enum AppRadius {
    static let xSmall = AppCornerRadius.xSmall
    static let small = AppCornerRadius.small
    static let medium = AppCornerRadius.medium
    static let large = AppCornerRadius.large
    static let xLarge = AppCornerRadius.xLarge
    static let hero = AppCornerRadius.hero
    static let button: CGFloat = 16
    static let card: CGFloat = 24
    static let pill = AppCornerRadius.pill
}
