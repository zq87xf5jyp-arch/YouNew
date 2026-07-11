import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

enum AppColors {

    // MARK: - Surfaces (Deep Premium Navy)
    static let background = Color.dynamic(
        light: Color(red: 245/255, green: 248/255, blue: 252/255),
        dark:  Color(red: 6/255,  green: 10/255,  blue: 20/255)
    )
    static let backgroundTop = Color.dynamic(
        light: Color(red: 248/255, green: 251/255, blue: 255/255),
        dark:  Color(red: 9/255,  green: 15/255,  blue: 28/255)
    )
    static let backgroundBottom = Color.dynamic(
        light: Color(red: 234/255, green: 241/255, blue: 250/255),
        dark:  Color(red: 4/255,  green: 8/255,  blue: 17/255)
    )
    static let card = Color.dynamic(
        light: .white,
        dark:  Color(red: 18/255, green: 27/255, blue: 45/255)
    )
    static let cardElevated = Color.dynamic(
        light: Color(red: 248/255, green: 252/255, blue: 255/255),
        dark:  Color(red: 24/255, green: 35/255, blue: 58/255)
    )
    static let glassSurface = Color.dynamic(
        light: Color(red: 255/255, green: 255/255, blue: 255/255).opacity(0.82),
        dark:  Color(red: 18/255, green: 28/255, blue: 48/255).opacity(0.72)
    )
    static let glassSurfaceElevated = Color.dynamic(
        light: Color(red: 255/255, green: 255/255, blue: 255/255).opacity(0.92),
        dark:  Color(red: 28/255, green: 42/255, blue: 68/255).opacity(0.80)
    )
    static let graphite = Color.dynamic(
        light: Color(red: 32/255, green: 44/255, blue: 62/255),
        dark:  Color(red: 13/255, green: 18/255, blue: 30/255)
    )
    static let systemGroupedBackground = Color.dynamic(
        light: Color(red: 242/255, green: 242/255, blue: 247/255),
        dark:  Color(red: 28/255, green: 28/255,  blue: 30/255)
    )

    // MARK: - Text
    static let textPrimary = Color.dynamic(
        light: Color(red: 8/255,   green: 22/255,  blue: 48/255),
        dark:  Color(red: 242/255, green: 247/255, blue: 255/255)
    )
    static let textSecondary = Color.dynamic(
        light: Color(red: 72/255,  green: 96/255,  blue: 126/255),
        dark:  Color(red: 184/255, green: 202/255, blue: 226/255)
    )
    static let textTertiary = Color.dynamic(
        light: Color(red: 104/255, green: 128/255, blue: 154/255),
        dark:  Color(red: 142/255, green: 163/255, blue: 190/255)
    )

    // MARK: - Brand
    static let accent      = Color(red: 18/255,  green: 122/255, blue: 136/255) // Muted Teal
    static let accentLight = Color(red: 38/255,  green: 162/255, blue: 178/255) // Lighter Teal
    static let dutchOrange = Color(red: 230/255, green: 104/255, blue: 26/255)  // Dutch Orange
    static let dutchRed    = Color(red: 174/255, green: 28/255,  blue: 40/255)  // Dutch Red
    static let softBlue    = Color(red: 100/255, green: 164/255, blue: 216/255) // Sky Blue
    static let navyDeep    = Color(red: 10/255,  green: 18/255,  blue: 38/255)  // Deep Navy
    static let routeLine   = Color(red: 72/255,  green: 140/255, blue: 168/255) // Canal Blue
    static let emerald     = Color(red: 52/255,  green: 200/255, blue: 144/255) // Emerald
    static let violet      = Color(red: 120/255, green: 80/255,  blue: 220/255) // Violet
    static let cyanGlow    = Color(red: 58/255,  green: 196/255, blue: 214/255)
    static let orangeGlow  = Color(red: 255/255, green: 136/255, blue: 54/255)

    // MARK: - Reference-driven semantic palette
    // Use these aliases in shared components instead of introducing local colours.
    static let backgroundPrimary = Color(red: 5/255, green: 12/255, blue: 27/255)
    static let backgroundSecondary = Color(red: 10/255, green: 27/255, blue: 50/255)
    static let cardBackground = Color(red: 14/255, green: 29/255, blue: 53/255)
    static let accentPrimary = dutchOrange
    static let accentSecondary = Color(red: 45/255, green: 155/255, blue: 214/255)
    static let accentAI = violet
    static let divider = Color(red: 72/255, green: 92/255, blue: 121/255).opacity(0.30)

    // MARK: - Fines & Emergency UI
    static let fineAmountOrange = Color(red: 189/255, green: 77/255,  blue: 20/255)  // Burnt orange for fine amount text
    static let fineGold         = Color(red: 255/255, green: 199/255, blue: 71/255)  // Gold accent for fine-amount icon
    static let finesGradDark    = Color(red: 209/255, green: 51/255,  blue: 31/255)  // Fines CTA button gradient end
    static let finesChipStart   = Color(red: 204/255, green: 56/255,  blue: 41/255)  // Active filter-chip gradient start
    static let finesChipEnd     = Color(red: 148/255, green: 48/255,  blue: 56/255)  // Active filter-chip gradient end
    static let emergencyRed     = Color(red: 198/255, green: 72/255,  blue: 36/255)  // Emergency services accent (112, Politie)
    static let emergencyRedDark = Color(red: 140/255, green: 32/255,  blue: 22/255)  // Emergency card gradient shadow end

    // MARK: - Hero Gradient
    static let heroStart = Color(red: 10/255, green: 18/255, blue: 44/255)
    static let heroMid   = Color(red: 14/255, green: 30/255, blue: 70/255)
    static let heroEnd   = Color(red: 18/255, green: 50/255, blue: 100/255)

    // MARK: - Semantic
    static let warning = Color(red: 204/255, green: 150/255, blue: 60/255)
    static let error   = Color(red: 200/255, green: 72/255,  blue: 72/255)
    static let success = Color(red: 56/255,  green: 166/255, blue: 110/255)

    // MARK: - Decorative Surfaces
    static let stroke = Color.dynamic(
        light: Color(red: 212/255, green: 224/255, blue: 240/255),
        dark:  Color(red: 36/255, green: 52/255,  blue: 76/255)
    )
    static let chipBackground = Color.dynamic(
        light: Color(red: 230/255, green: 242/255, blue: 252/255),
        dark:  Color(red: 26/255, green: 40/255,  blue: 62/255)
    )
    static let iconSurface = Color.dynamic(
        light: Color(red: 222/255, green: 236/255, blue: 252/255),
        dark:  Color(red: 24/255, green: 38/255,  blue: 62/255)
    )
    static let progressTrack = Color.dynamic(
        light: Color(red: 218/255, green: 230/255, blue: 246/255),
        dark:  Color(red: 28/255, green: 44/255,  blue: 68/255)
    )

    // MARK: - Premium Semantic Aliases
    static let primaryBackground = backgroundPrimary
    static let secondaryBackground = backgroundSecondary
    static let elevatedSurface = cardElevated
    static let primaryText = textPrimary
    static let secondaryText = textSecondary
    static let tertiaryText = textTertiary
    static let accentBlue = softBlue
    static let accentOrange = dutchOrange
    static let destructive = error

    // MARK: - Gradient Presets (premium category colours)
    static let gradFines    = [Color(red: 230/255, green: 78/255,  blue: 48/255),  Color(red: 200/255, green: 52/255,  blue: 28/255)]
    static let gradDocs     = [Color(red: 40/255,  green: 116/255, blue: 230/255), Color(red: 26/255,  green: 82/255,  blue: 196/255)]
    static let gradTransport = [Color(red: 14/255, green: 152/255, blue: 136/255), Color(red: 8/255,   green: 112/255, blue: 100/255)]
    static let gradWork     = [Color(red: 100/255, green: 72/255,  blue: 210/255), Color(red: 74/255,  green: 52/255,  blue: 172/255)]
    static let gradHousing  = [Color(red: 28/255,  green: 140/255, blue: 188/255), Color(red: 18/255,  green: 100/255, blue: 148/255)]
    static let gradHealth   = [Color(red: 210/255, green: 62/255,  blue: 90/255),  Color(red: 176/255, green: 40/255,  blue: 68/255)]
    static let gradProvince = [Color(red: 30/255,  green: 90/255,  blue: 210/255), Color(red: 18/255,  green: 60/255,  blue: 160/255)]
    static let gradEmergency   = [Color(red: 224/255, green: 124/255, blue: 10/255),  Color(red: 190/255, green: 90/255,  blue: 4/255)]
    static let gradGovernment  = [Color(red: 22/255,  green: 62/255,  blue: 148/255), Color(red: 14/255,  green: 148/255, blue: 166/255)]
    static let gradEducation   = [Color(red: 54/255,  green: 116/255, blue: 222/255), Color(red: 106/255, green: 92/255,  blue: 210/255)]

    // MARK: - Province Colors
    static let province00 = [Color(red: 30/255,  green: 80/255,  blue: 180/255), Color(red: 16/255,  green: 52/255,  blue: 140/255)]
    static let province01 = [Color(red: 20/255,  green: 120/255, blue: 160/255), Color(red: 10/255,  green: 80/255,  blue: 120/255)]
    static let province02 = [Color(red: 40/255,  green: 100/255, blue: 180/255), Color(red: 24/255,  green: 66/255,  blue: 140/255)]
    static let province03 = [Color(red: 90/255,  green: 60/255,  blue: 190/255), Color(red: 62/255,  green: 40/255,  blue: 150/255)]
    static let province04 = [Color(red: 18/255,  green: 130/255, blue: 110/255), Color(red: 10/255,  green: 90/255,  blue: 76/255)]
    static let province05 = [Color(red: 190/255, green: 90/255,  blue: 30/255),  Color(red: 150/255, green: 62/255,  blue: 14/255)]
    static let province06 = [Color(red: 52/255,  green: 110/255, blue: 200/255), Color(red: 32/255,  green: 74/255,  blue: 158/255)]
    static let province07 = [Color(red: 26/255,  green: 148/255, blue: 130/255), Color(red: 14/255,  green: 104/255, blue: 90/255)]
    static let province08 = [Color(red: 160/255, green: 60/255,  blue: 180/255), Color(red: 118/255, green: 38/255,  blue: 140/255)]
    static let province09 = [Color(red: 180/255, green: 46/255,  blue: 60/255),  Color(red: 140/255, green: 26/255,  blue: 40/255)]
    static let province10 = [Color(red: 60/255,  green: 130/255, blue: 60/255),  Color(red: 36/255,  green: 90/255,  blue: 36/255)]
    static let province11 = [Color(red: 180/255, green: 120/255, blue: 20/255),  Color(red: 140/255, green: 86/255,  blue: 10/255)]
}

private extension Color {
    static func dynamic(light: Color, dark: Color) -> Color {
        #if canImport(UIKit)
        Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light) })
        #else
        light
        #endif
    }
}
