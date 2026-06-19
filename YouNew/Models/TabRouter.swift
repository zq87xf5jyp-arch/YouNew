import Combine
import Foundation

enum AppTab: Hashable {
    case home
    case search
    case map
    case favorites
    case assistant
    case more
}

enum TabItem: Hashable {
    case home
    case search
    case map
    case saved
    case ai
    case more
}

final class TabRouter: ObservableObject {
    @Published var selectedTab: TabItem

    let homeScrollTop = PassthroughSubject<Void, Never>()
    let searchScrollTop = PassthroughSubject<Void, Never>()
    let mapReset = PassthroughSubject<Void, Never>()
    let savedScrollTop = PassthroughSubject<Void, Never>()
    let aiScrollTop = PassthroughSubject<Void, Never>()
    let moreScrollTop = PassthroughSubject<Void, Never>()

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
        case .search:
            searchScrollTop.send()
        case .map:
            mapReset.send()
        case .saved:
            savedScrollTop.send()
        case .ai:
            aiScrollTop.send()
        case .more:
            moreScrollTop.send()
        }
    }
}

extension AppTab {
    var tabItem: TabItem {
        switch self {
        case .home: return .home
        case .search: return .search
        case .map: return .map
        case .favorites: return .saved
        case .assistant: return .ai
        case .more: return .more
        }
    }
}

