import SwiftUI

enum AppCornerRadius {
    static let xSmall: CGFloat = 8
    static let small:  CGFloat = 12
    static let medium: CGFloat = 16
    static let large:  CGFloat = 20
    static let xLarge: CGFloat = 28
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
    static let button: CGFloat = 18
    static let card: CGFloat = 28
    static let pill = AppCornerRadius.pill
}
