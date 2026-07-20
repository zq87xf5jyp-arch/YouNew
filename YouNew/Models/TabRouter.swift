import Combine
import Foundation

enum AppTab: String, CaseIterable, Hashable, Identifiable {
    case home
    case guide
    case map
    case saved
    case more

    var id: String { rawValue }

    // Source-compatible aliases while old deep links and tests migrate.
    static let places = AppTab.guide
    static let search = AppTab.guide
    static let favorites = AppTab.saved
    static let assistant = AppTab.guide
}

enum TabItem: String, CaseIterable, Hashable {
    case home
    case guide
    case map
    case saved
    case more

    static let places = TabItem.guide
    static let ai = TabItem.guide
}

final class TabRouter: ObservableObject {
    var selectedTab: TabItem

    let homeScrollTop = PassthroughSubject<Void, Never>()
    let guideScrollTop = PassthroughSubject<Void, Never>()
    let mapReset = PassthroughSubject<Void, Never>()
    let savedScrollTop = PassthroughSubject<Void, Never>()
    let moreScrollTop = PassthroughSubject<Void, Never>()

    var placesScrollTop: PassthroughSubject<Void, Never> { guideScrollTop }
    var searchScrollTop: PassthroughSubject<Void, Never> { guideScrollTop }
    var aiScrollTop: PassthroughSubject<Void, Never> { guideScrollTop }

    init(initialTab: TabItem = .home) {
        selectedTab = initialTab
    }

    func select(_ tab: TabItem) {
        if selectedTab == tab {
            sendReset(for: tab)
        } else {
            selectedTab = tab
        }
    }

    func select(_ tab: AppTab) {
        select(tab.tabItem)
    }

    private func sendReset(for tab: TabItem) {
        switch tab {
        case .home:
            homeScrollTop.send()
        case .guide:
            guideScrollTop.send()
        case .map:
            mapReset.send()
        case .saved:
            savedScrollTop.send()
        case .more:
            moreScrollTop.send()
        }
    }
}

extension AppTab {
    var tabItem: TabItem {
        switch self {
        case .home: return .home
        case .guide: return .guide
        case .map: return .map
        case .saved: return .saved
        case .more: return .more
        }
    }
}
