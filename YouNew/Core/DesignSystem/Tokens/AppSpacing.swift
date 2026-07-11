import SwiftUI

enum AppSpacing {

    // MARK: - Base Scale
    static let xxSmall: CGFloat = 8
    static let xSmall:  CGFloat = 8
    static let small:   CGFloat = 12
    static let medium:  CGFloat = 16
    static let large:   CGFloat = 24
    static let xLarge:  CGFloat = 32
    static let xxLarge: CGFloat = 48

    // MARK: - Semantic
    static let cardPadding:        CGFloat = 16
    static let cardPaddingCompact: CGFloat = 12
    static let screenHorizontal:   CGFloat = 18
    static let sectionGap:         CGFloat = 32
    static let sectionTop:         CGFloat = 8
    static let listGap:            CGFloat = 12
    static let gridGap:            CGFloat = 12
    static let iconPadding:        CGFloat = 12
    static let buttonX:            CGFloat = 16
    static let buttonY:            CGFloat = 12
    static let iconButtonSize:     CGFloat = 48
    static let heroVertical:       CGFloat = 32
    static let tabBarScrollReserve: CGFloat = 260
    static let tabBarScrollReserveLarge: CGFloat = 292
    static let tabBarScrollReserveMap: CGFloat = 274
    static let tabBarScrollReserveCity: CGFloat = 288
    static let floatingTabClearance: CGFloat = tabBarScrollReserve
    static let screenTopSafeArea: CGFloat = 14

    // Legacy alias — kept for compatibility
    static let cornerRadius: CGFloat = 16
}

// Centralised metrics for the root-hosted floating tab bar.
enum FloatingTabBarMetrics {
    static let height: CGFloat = 66
    static let bottomOffset: CGFloat = 6
    static let totalClearance: CGFloat = height + bottomOffset
    static let rootContentInset: CGFloat = 142
    static let sideContentInset: CGFloat = 80
    static let terminalContentClearance: CGFloat = 116
    static let horizontalPadding: CGFloat = 12
    static let contentBottomPadding: CGFloat = rootContentInset + 24
    static let modalContentBottomPadding: CGFloat = rootContentInset + 32
}

enum GlobalAILauncherMetrics {
    static let collapsedHeight: CGFloat = 58
    static let expandedMenuHeight: CGFloat = 430
    static let contentGap: CGFloat = 18

    static func contentReserve(bottomPadding: CGFloat, isExpanded: Bool) -> CGFloat {
        bottomPadding + collapsedHeight + contentGap + (isExpanded ? expandedMenuHeight : 0)
    }
}

enum AppLayout {
    static let pagePadding: CGFloat = AppSpacing.screenHorizontal
    static let sectionSpacing: CGFloat = AppSpacing.sectionGap
    static let cardSpacing: CGFloat = AppSpacing.medium
    static let smallSpacing: CGFloat = AppSpacing.small
    static let bottomNavReserveExtra: CGFloat = FloatingTabBarMetrics.terminalContentClearance
}

enum AppButtonMetrics {
    static let minTouchSize: CGFloat = AppIcons.Metrics.minimumTouchTarget
    static let horizontalPadding: CGFloat = AppSpacing.buttonX
    static let verticalPadding: CGFloat = AppSpacing.buttonY
    static let compactVerticalPadding: CGFloat = AppSpacing.xSmall
    static let iconSize: CGFloat = AppIcons.Metrics.large
    static let smallIconSize: CGFloat = AppIcons.Metrics.medium
    static let labelIconSpacing: CGFloat = 8
}

enum DetailPageLayout {
    static let pageHorizontalPadding: CGFloat = 18
    static let sectionGap: CGFloat = 24
    static let cardGap: CGFloat = 16
    static let maximumPageWidth: CGFloat = 920

    static func availableContentWidth(viewportWidth: CGFloat) -> CGFloat {
        max(0, min(viewportWidth, maximumPageWidth) - pageHorizontalPadding * 2)
    }

    static func pageWidth(viewportWidth: CGFloat) -> CGFloat {
        min(viewportWidth, maximumPageWidth)
    }

    static func singleColumnGrid() -> [GridItem] {
        [GridItem(.flexible(minimum: 0), spacing: cardGap)]
    }

    static func columns(for contentWidth: CGFloat, compactBreakpoint: CGFloat = 430, regularMinimum: CGFloat = 220) -> [GridItem] {
        if contentWidth < compactBreakpoint {
            return singleColumnGrid()
        }

        return [GridItem(.adaptive(minimum: regularMinimum), spacing: cardGap)]
    }

    static func twoColumnWhenPossible(for contentWidth: CGFloat, minimumColumnWidth: CGFloat = 160) -> [GridItem] {
        if contentWidth >= minimumColumnWidth * 2 + cardGap {
            return Array(repeating: GridItem(.flexible(minimum: 0), spacing: cardGap), count: 2)
        }

        return singleColumnGrid()
    }
}

extension View {
    func tabBarScrollReserve(_ height: CGFloat = AppSpacing.tabBarScrollReserve) -> some View {
        padding(.bottom, height)
    }

    func bottomTabSafeAreaPadding(_ extra: CGFloat = 0) -> some View {
        padding(.bottom, FloatingTabBarMetrics.contentBottomPadding + extra)
    }

    func topChromeSafeAreaPadding(_ extra: CGFloat = 0) -> some View {
        safeAreaPadding(.top, AppSpacing.screenTopSafeArea + extra)
    }
}
