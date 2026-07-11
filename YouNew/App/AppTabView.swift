import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

enum NavigationMenuPosition: String, CaseIterable, Identifiable {
    case automatic
    case bottom
    case top
    case left
    case right

    var id: String { rawValue }

    func localized(_ lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.automatic, .russian): return "Автоматически"
        case (.bottom, .russian): return "Снизу"
        case (.top, .russian): return "Сверху"
        case (.left, .russian): return "Слева"
        case (.right, .russian): return "Справа"
        case (.automatic, .dutch): return "Automatisch"
        case (.bottom, .dutch): return "Onder"
        case (.top, .dutch): return "Boven"
        case (.left, .dutch): return "Links"
        case (.right, .dutch): return "Rechts"
        case (.automatic, .english): return "Automatic"
        case (.bottom, .english): return "Bottom"
        case (.top, .english): return "Top"
        case (.left, .english): return "Left"
        case (.right, .english): return "Right"
        }
    }
}

private enum GlobalAIMode: String, CaseIterable, Identifiable {
    case askQuestion
    case explainScreen
    case nextStep
    case findInApp
    case translate
    case guideMe

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .askQuestion: return "text.bubble.fill"
        case .explainScreen: return "rectangle.and.text.magnifyingglass"
        case .nextStep: return "arrow.triangle.branch"
        case .findInApp: return "magnifyingglass"
        case .translate: return "character.book.closed.fill"
        case .guideMe: return "point.topleft.down.curvedto.point.bottomright.up.fill"
        }
    }

    func title(_ lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.askQuestion, .russian): return "Задать вопрос"
        case (.explainScreen, .russian): return "Объяснить экран"
        case (.nextStep, .russian): return "Что дальше?"
        case (.findInApp, .russian): return "Найти в приложении"
        case (.translate, .russian): return "Перевести"
        case (.guideMe, .russian): return "Провести меня"
        case (.askQuestion, .dutch): return "Vraag stellen"
        case (.explainScreen, .dutch): return "Scherm uitleggen"
        case (.nextStep, .dutch): return "Wat nu?"
        case (.findInApp, .dutch): return "Zoek in app"
        case (.translate, .dutch): return "Vertalen"
        case (.guideMe, .dutch): return "Begeleid mij"
        case (.askQuestion, .english): return "Ask Question"
        case (.explainScreen, .english): return "Explain Screen"
        case (.nextStep, .english): return "What Should I Do Next?"
        case (.findInApp, .english): return "Find in App"
        case (.translate, .english): return "Translate"
        case (.guideMe, .english): return "Guide Me"
        }
    }
}

struct RootTabView: View {
    @State private var selectedTab: AppTab
    @State private var previousContentTab: AppTab
    @State private var isMenuPresented = false
    @State private var activeMenuDestination: AppDestination? = nil
    @State private var lastTappedTab: AppTab? = nil
    @State private var lastTabTapDate: Date? = nil
    @State private var isGlobalAIModeLauncherExpanded = false
    @State private var didApplyInitialTestingDestination = false
    @StateObject private var tabRouter: TabRouter
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var appState: AppStateViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @AppStorage("settings.navigationMenuPosition") private var menuPositionRawValue = NavigationMenuPosition.automatic.rawValue

    @State private var regularNavPath = NavigationPath()
    @State private var homeNavPath = NavigationPath()
    @State private var guideNavPath = NavigationPath()
    @State private var searchNavPath = NavigationPath()
    @State private var mapNavPath = NavigationPath()
    @State private var savedNavPath = NavigationPath()
    @State private var moreNavPath = NavigationPath()

    private var lang: AppLanguage { languageManager.appLanguage }
    private var menuPosition: NavigationMenuPosition {
        NavigationMenuPosition(rawValue: menuPositionRawValue) ?? .automatic
    }

#if os(iOS)
    private var effectiveMenuPosition: NavigationMenuPosition {
        Self.resolvedMenuPosition(menuPosition: menuPosition, horizontalSizeClass: horizontalSizeClass)
    }
#endif

    static func resolvedMenuPosition(
        menuPosition: NavigationMenuPosition,
        horizontalSizeClass: UserInterfaceSizeClass?
    ) -> NavigationMenuPosition {
        if menuPosition == .automatic {
            return horizontalSizeClass == .regular ? .left : .bottom
        }
        if horizontalSizeClass == .compact, menuPosition == .left || menuPosition == .right {
            return .bottom
        }
        return menuPosition
    }

    init(initialTab overrideInitialTab: AppTab? = nil) {
        let initialTab = overrideInitialTab ?? Self.initialSelectedTab()
        _selectedTab = State(initialValue: initialTab)
        _previousContentTab = State(initialValue: initialTab)
        _isMenuPresented = State(initialValue: false)
        _activeMenuDestination = State(initialValue: Self.initialTestingDestination())
        _tabRouter = StateObject(wrappedValue: TabRouter(initialTab: initialTab.tabItem))

#if os(iOS)
        // Suppress the native tab bar — we use FloatingTabBar on compact and sidebar on regular.
        let hidden = UITabBarAppearance()
        hidden.configureWithTransparentBackground()
        hidden.shadowColor = .clear
        UITabBar.appearance().standardAppearance = hidden
        UITabBar.appearance().scrollEdgeAppearance = hidden
        UITabBar.appearance().isHidden = true
#endif
    }

    private static func initialSelectedTab() -> AppTab {
#if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        if initialTestingDestination() != nil {
            return .home
        }
        if arguments.contains("-uiTesting"),
           let tabIndex = arguments.firstIndex(of: "-uiTestingStartTab"),
           arguments.indices.contains(tabIndex + 1) {
            switch arguments[tabIndex + 1] {
            case "places", "search", "guide": return .guide
            case "map":       return .map
            case "favorites", "saved": return .saved
            case "assistant": return .guide
            case "more":      return .more
            default:          return .home
            }
        }
#endif
        return .home
    }

    private static func initialTestingDestination() -> AppDestination? {
#if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        guard arguments.contains("-uiTesting"),
              let destinationIndex = arguments.firstIndex(of: "-uiTestingDestination"),
              arguments.indices.contains(destinationIndex + 1)
        else { return nil }

        return AppNavigationResolver.destination(for: arguments[destinationIndex + 1])
#else
        return nil
#endif
    }

    // MARK: - Body

    var body: some View {
#if os(iOS)
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                unifiedRootBackground
                    .ignoresSafeArea()

                Group {
                    if horizontalSizeClass == .regular && menuPosition == .automatic {
                        regularWidthLayout
                    } else {
                        adaptiveMenuLayout
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.clear)
        .overlay {
            if isMenuPresented {
                RightSideMenuOverlay(
                    selectedTab: selectedTab,
                    activeDestination: activeMenuDestination,
                    sections: menuSections,
                    onClose: closeMenu,
                    onSelect: handleMenuSelection
                )
                .transition(.opacity)
                .zIndex(50)
            }
        }
        .overlay(alignment: .bottomTrailing) { contextualAIButton }
        .overlay(alignment: .bottom) { toastOverlay }
        .animation(AppAnimations.standard, value: appState.toastMessage)
        .animation(AppAnimations.standard, value: isMenuPresented)
        .onAppear(perform: applyInitialTestingDestinationIfNeeded)
        .environmentObject(tabRouter)
#else
        ZStack {
            tabContent
        }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.clear)
            .overlay(alignment: .bottomTrailing) { contextualAIButton }
            .overlay(alignment: .bottom) { toastOverlay }
            .animation(AppAnimations.standard, value: appState.toastMessage)
            .onAppear(perform: applyInitialTestingDestinationIfNeeded)
            .environmentObject(tabRouter)
#endif
    }

    private func applyInitialTestingDestinationIfNeeded() {
#if DEBUG
        guard !didApplyInitialTestingDestination,
              let destination = Self.initialTestingDestination()
        else { return }

        didApplyInitialTestingDestination = true
        selectedTab = .home
        previousContentTab = .home
        activeMenuDestination = nil
        homeNavPath.append(destination)
#endif
    }

    private var rootBackgroundStyle: YouNewScreenBackgroundStyle {
        switch selectedTab {
        case .home, .more: return .home
        case .guide: return .search
        case .map: return .map
        case .saved: return .saved
        }
    }

    private var unifiedRootBackground: some View {
        GlobalBackgroundView()
            .allowsHitTesting(false)
    }

    @ViewBuilder
    private var contextualAIButton: some View {
        if shouldShowContextualAIButton {
            FloatingAssistantButton(
                title: contextualAIButtonTitle,
                subtitle: contextualAIButtonSubtitle,
                modes: GlobalAIMode.allCases,
                language: lang,
                onSelect: openGlobalAssistant,
                isExpanded: $isGlobalAIModeLauncherExpanded
            )
            .padding(.trailing, contextualAIButtonTrailingPadding)
            .padding(.bottom, contextualAIButtonBottomPadding)
            .transition(.scale(scale: 0.94).combined(with: .opacity))
            .zIndex(20)
        }
    }

    private var shouldShowContextualAIButton: Bool {
        Self.shouldShowContextualAIButton(selectedTab: selectedTab, isMenuPresented: isMenuPresented)
    }

    static func shouldShowContextualAIButton(selectedTab: AppTab, isMenuPresented: Bool) -> Bool {
        !isMenuPresented
            && selectedTab != .more
            && selectedTab != .saved
            && selectedTab == .map
    }

    private var contextualAIButtonBottomPadding: CGFloat {
#if os(iOS)
        if horizontalSizeClass == .regular && menuPosition == .automatic {
            return 24
        }
        return effectiveMenuPosition == .bottom ? FloatingTabBarMetrics.rootContentInset : 24
#else
        return 24
#endif
    }

    private var contextualAIButtonTrailingPadding: CGFloat {
#if os(iOS)
        effectiveMenuPosition == .right ? 104 : 18
#else
        18
#endif
    }

    private var contextualAIButtonTitle: String {
        switch lang {
        case .russian: return "AI"
        case .dutch: return "AI"
        case .english: return "AI"
        }
    }

    private var contextualAIButtonSubtitle: String {
        switch lang {
        case .russian: return "помощник"
        case .dutch: return "assistent"
        case .english: return "assistant"
        }
    }

    // MARK: - Toast

    @ViewBuilder
    private var toastOverlay: some View {
        if let toast = appState.toastMessage {
            Text(toast)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 11)
                .background(
                    Capsule()
                        .fill(AppColors.navyDeep)
                        .shadow(color: Color.black.opacity(0.30), radius: 16, x: 0, y: 8)
                )
                .overlay(
                    Capsule().stroke(Color.white.opacity(0.14), lineWidth: 0.75)
                )
                .padding(.bottom, 90)
                .allowsHitTesting(false)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    // MARK: - Compact layout (iPhone / iPad multitasking compact)

#if os(iOS)
    @ViewBuilder
    private var adaptiveMenuLayout: some View {
        switch effectiveMenuPosition {
        case .top:
            tabContent
                .padding(.top, FloatingTabBarMetrics.rootContentInset)
                .overlay(alignment: .top) { horizontalMenu(edge: .top) }
        case .left:
            tabContent
                .padding(.leading, FloatingTabBarMetrics.sideContentInset)
                .overlay(alignment: .leading) { verticalMenu(edge: .leading) }
        case .right:
            tabContent
                .padding(.trailing, FloatingTabBarMetrics.sideContentInset)
                .overlay(alignment: .trailing) { verticalMenu(edge: .trailing) }
        case .automatic, .bottom:
            tabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    horizontalMenu(edge: .bottom)
                        .zIndex(3)
                }
        }
    }

    private func horizontalMenu(edge: Edge) -> some View {
        FloatingTabBar(
            selectedTab: menuSelectionBinding,
            items: compactTabBarItems,
            axis: .horizontal,
            onSelect: handleTabSelection
        )
        .accessibilityIdentifier("root.tabBar")
        .padding(.horizontal, FloatingTabBarMetrics.horizontalPadding)
        .padding(.top, edge == .top ? 8 : 0)
        .padding(.bottom, edge == .bottom ? FloatingTabBarMetrics.bottomOffset : 8)
        .safeAreaPadding(.bottom, edge == .bottom ? 4 : 0)
        .background(Color.clear)
        .zIndex(100)
    }

    private func verticalMenu(edge: Edge) -> some View {
        FloatingTabBar(
            selectedTab: menuSelectionBinding,
            items: compactTabBarItems,
            axis: .vertical,
            onSelect: handleTabSelection
        )
        .frame(width: 88)
        .padding(.vertical, 12)
        .padding(edge == .leading ? .leading : .trailing, 8)
        .background(Color.clear)
        .zIndex(100)
    }

    private var menuSelectionBinding: Binding<AppTab> {
        Binding(
            get: { isMenuPresented ? .more : selectedTab },
            set: { handleTabSelection($0) }
        )
    }

    // MARK: - Regular layout (iPad / macOS Catalyst)
    // Uses NavigationSplitView sidebar instead of FloatingTabBar to avoid
    // iOS 18's automatic floating top tab bar on wide screens.

    private var regularWidthLayout: some View {
        NavigationSplitView {
            sidebarList
        } detail: {
            NavigationStack(path: $regularNavPath) {
                regularTabContent
                    .navigationDestination(for: AppDestination.self) {
                        AppDestinationView(destination: $0)
                    }
            }
        }
        .tint(AppColors.dutchOrange)
        .onChange(of: selectedTab) {
            regularNavPath = NavigationPath()
        }
    }

    private var sidebarList: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                regularSidebarHeader
                regularSidebarWidgets
                regularSidebarGroup(
                    title: localizedRootText(en: "Navigation", nl: "Navigatie", ru: "Навигация"),
                    items: AppTab.allCases
                )
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 18)
        }
        .scrollContentBackground(.hidden)
        .background {
            GlobalBackgroundView()
                .overlay(.ultraThinMaterial.opacity(0.30))
        }
        .navigationTitle("")
        .tint(AppColors.cyanGlow)
    }

    private var regularSidebarHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 10) {
                YouNewLogoMark()
                    .frame(width: 42, height: 42)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: AppColors.cyanGlow.opacity(0.20), radius: 16, x: 0, y: 8)

                VStack(alignment: .leading, spacing: 2) {
                    Text(localizedRootText(en: "Good afternoon", nl: "Goedemiddag", ru: "Добрый день"))
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColors.textSecondary)
                    Text("YouNew.nl")
                        .font(.system(size: 23, weight: .black, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                }
            }

            HStack(spacing: 8) {
                regularHeaderChip(icon: "location.fill", text: ProvinceCatalog.localizedCityName(appState.selectedCity, lang), tint: AppColors.dutchOrange)
                regularHeaderChip(icon: "globe", text: languageIndicator, tint: AppColors.cyanGlow)
            }
        }
        .padding(16)
        .appGlassCardStyle(padding: 0, cornerRadius: 24, accent: AppColors.cyanGlow)
    }

    private var regularSidebarWidgets: some View {
        HStack(spacing: 10) {
            regularWidget(icon: "cloud.sun.fill", value: localizedRootText(en: "Weather", nl: "Weer", ru: "Погода"), label: localizedRootText(en: "Check official forecast", nl: "Controleer officiële verwachting", ru: "Проверьте официальный прогноз"), tint: AppColors.warning)
            regularWidget(icon: "clock.fill", value: regularSidebarTime, label: regularSidebarDate, tint: AppColors.softBlue)
        }
    }

    private func regularHeaderChip(icon: String, text: String, tint: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
            Text(text)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.70)
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .frame(maxWidth: .infinity)
        .background(tint.opacity(0.12))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(tint.opacity(0.22), lineWidth: 0.8))
    }

    private func regularWidget(icon: String, value: String, label: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(tint)
            Text(value)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.70)
            Text(label)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.70)
        }
        .padding(13)
        .frame(maxWidth: .infinity, minHeight: 116, alignment: .topLeading)
        .appGlassCardStyle(padding: 0, cornerRadius: 20, accent: tint)
    }

    private func regularSidebarGroup(title: String, items: [AppTab]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            regularGroupTitle(title)
            VStack(spacing: 6) {
                ForEach(items, id: \.self) { tab in
                    if let item = sidebarItems.first(where: { $0.tab == tab }) {
                        regularTabButton(item)
                    }
                }
            }
            .padding(8)
            .appGlassCardStyle(padding: 0, cornerRadius: 22, accent: items.contains(selectedTab) ? AppColors.cyanGlow : AppColors.softBlue)
        }
    }

    @ViewBuilder
    private func regularMenuGroup(title: String, items: [SideMenuItemModel]) -> some View {
        let visibleItems = items.filter(isMenuItemVisibleForPersona)
        VStack(alignment: .leading, spacing: 8) {
            regularGroupTitle(title)
            VStack(spacing: 6) {
                ForEach(visibleItems) { item in
                    regularMenuButton(item)
                }
            }
            .padding(8)
            .appGlassCardStyle(padding: 0, cornerRadius: 22, accent: visibleItems.first?.tint ?? AppColors.cyanGlow)
        }
    }

    private func regularGroupTitle(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(size: 10, weight: .black, design: .rounded))
            .foregroundStyle(AppColors.textTertiary)
            .tracking(1.0)
            .padding(.horizontal, 8)
    }

    private func regularTabButton(_ item: TabSidebarItem) -> some View {
        Button {
            handleTabSelection(item.tab)
        } label: {
            regularRowContent(
                title: item.title,
                subtitle: regularTabSubtitle(item.tab),
                icon: selectedTab == item.tab ? item.selectedSymbol : item.symbol,
                tint: selectedTab == item.tab ? AppColors.dutchOrange : regularTabTint(item.tab),
                isActive: selectedTab == item.tab
            )
        }
        .buttonStyle(AppPressableButtonStyle())
    }

    private func regularMenuButton(_ item: SideMenuItemModel) -> some View {
        Button {
            handleMenuSelection(item)
        } label: {
            regularRowContent(
                title: item.title(lang),
                subtitle: item.subtitle(lang),
                icon: item.systemIcon,
                tint: item.tint,
                isActive: activeMenuDestination == item.destination.appDestination
            )
        }
        .buttonStyle(AppPressableButtonStyle())
    }

    private func regularRowContent(title: String, subtitle: String?, icon: String, tint: Color, isActive: Bool) -> some View {
        HStack(spacing: 11) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(isActive ? .white : tint)
                .frame(width: 34, height: 34)
                .background(isActive ? tint : tint.opacity(0.13))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.76)
                    .fixedSize(horizontal: false, vertical: true)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: 4)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .background(isActive ? tint.opacity(0.16) : Color.white.opacity(0.001))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            if isActive {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(tint.opacity(0.34), lineWidth: 0.8)
            }
        }
    }

    @ViewBuilder
    private var regularTabContent: some View {
        switch selectedTab {
        case .home: RootHomeView(selectedTab: $selectedTab)
        case .guide: RootGuideView()
        case .map:
            PlacesDiscoveryView(
                onNavigate: { regularNavPath.append($0) },
                onAskAI: { openPlacesAI($0) }
            )
        case .saved: FavoritesView()
        case .more: RootMoreView()
        }
    }
#endif

    // MARK: - Tab content

    @ViewBuilder
    private var tabContent: some View {
        ZStack {
            switch selectedTab {
            case .home:
                homeTabStack
            case .guide:
                guideTabStack
            case .map:
                mapTabStack
            case .saved:
                savedTabStack
            case .more:
                moreTabStack
            }
        }
        .background(Color.clear)
    }

#if os(iOS)
    private var homeTabStack: some View {
        NavigationStack(path: $homeNavPath) {
            RootHomeView(selectedTab: $selectedTab) {
                homeNavPath.append(AppDestination.assistantHub)
            }
                .navigationDestination(for: AppDestination.self) { AppDestinationView(destination: $0) }
        }
    }

    private var searchTabStack: some View {
        NavigationStack(path: $searchNavPath) {
            SearchTabRoot()
                .navigationDestination(for: AppDestination.self) { AppDestinationView(destination: $0) }
        }
    }

    private struct SearchTabRoot: View {
        @EnvironmentObject private var appState: AppStateViewModel
        @StateObject private var viewModel = SearchViewModel()

        var body: some View {
            SearchView(viewModel: viewModel)
                .onAppear {
                    viewModel.activePersona = appState.selectedUserStatus?.personaTag
                    viewModel.personaSearchScope = .currentAndUniversal
                }
                .onChange(of: appState.selectedUserStatus) { _, status in
                    viewModel.activePersona = status?.personaTag
                }
        }
    }

    private var mapTabStack: some View {
        NavigationStack(path: $mapNavPath) {
            PlacesDiscoveryView(
                onNavigate: { mapNavPath.append($0) },
                onAskAI: { openPlacesAI($0) }
            )
                .navigationDestination(for: AppDestination.self) { AppDestinationView(destination: $0) }
        }
    }

    private var guideTabStack: some View {
        NavigationStack(path: $guideNavPath) {
            RootGuideView {
                guideNavPath.append(AppDestination.assistantHub)
            }
            .navigationDestination(for: AppDestination.self) { AppDestinationView(destination: $0) }
        }
    }

    private var savedTabStack: some View {
        NavigationStack(path: $savedNavPath) {
            FavoritesView()
                .navigationDestination(for: AppDestination.self) { AppDestinationView(destination: $0) }
        }
    }

    private var moreTabStack: some View {
        NavigationStack(path: $moreNavPath) {
            RootMoreView()
                .navigationDestination(for: AppDestination.self) { AppDestinationView(destination: $0) }
        }
    }
#else
    private var homeTabStack: some View {
        NavigationStack {
            RootHomeView(selectedTab: $selectedTab)
                .navigationDestination(for: AppDestination.self) { AppDestinationView(destination: $0) }
        }
    }

    private var searchTabStack: some View {
        NavigationStack {
            SearchTabRoot()
                .navigationDestination(for: AppDestination.self) { AppDestinationView(destination: $0) }
        }
    }

    private struct SearchTabRoot: View {
        @EnvironmentObject private var appState: AppStateViewModel
        @StateObject private var viewModel = SearchViewModel()

        var body: some View {
            SearchView(viewModel: viewModel)
                .onAppear {
                    viewModel.activePersona = appState.selectedUserStatus?.personaTag
                    viewModel.personaSearchScope = .currentAndUniversal
                }
                .onChange(of: appState.selectedUserStatus) { _, status in
                    viewModel.activePersona = status?.personaTag
                }
        }
    }

    private var mapTabStack: some View {
        NavigationStack {
            PlacesDiscoveryView(
                onNavigate: { _ in },
                onAskAI: { openPlacesAI($0) }
            )
                .navigationDestination(for: AppDestination.self) { AppDestinationView(destination: $0) }
        }
    }

    private var guideTabStack: some View {
        NavigationStack {
            RootGuideView()
            .navigationDestination(for: AppDestination.self) { AppDestinationView(destination: $0) }
        }
    }

    private var savedTabStack: some View {
        NavigationStack {
            FavoritesView()
                .navigationDestination(for: AppDestination.self) { AppDestinationView(destination: $0) }
        }
    }

    private var moreTabStack: some View {
        NavigationStack {
            RootMoreView()
                .navigationDestination(for: AppDestination.self) { AppDestinationView(destination: $0) }
        }
    }
#endif

    // MARK: - Tab items

    private struct TabSidebarItem: Identifiable {
        let tab: AppTab
        let title: String
        let symbol: String
        let selectedSymbol: String
        var id: AppTab { tab }
    }

    private var sidebarItems: [TabSidebarItem] {
        [
            TabSidebarItem(tab: .home,  title: tabHomeTitle,  symbol: AppIcons.home, selectedSymbol: AppIcons.homeActive),
            TabSidebarItem(tab: .guide, title: tabGuideTitle, symbol: "books.vertical", selectedSymbol: "books.vertical.fill"),
            TabSidebarItem(tab: .map,   title: tabMapTitle,   symbol: AppIcons.map, selectedSymbol: AppIcons.mapActive),
            TabSidebarItem(tab: .saved, title: tabSavedTitle, symbol: AppIcons.save, selectedSymbol: AppIcons.saved),
            TabSidebarItem(tab: .more,  title: tabMoreTitle,  symbol: AppIcons.more, selectedSymbol: AppIcons.moreActive)
        ]
    }

    private var regularGovernmentItems: [SideMenuItemModel] {
        switch appState.selectedUserStatus?.personaTag {
        case .student:
            return [
                rootDashboardItem(id: "duo", en: "DUO", nl: "DUO", ru: "DUO", subtitleEN: "Student finance", subtitleNL: "Studiefinanciering", subtitleRU: "Финансы студента", icon: "building.columns.fill", destination: .officialSources, tint: AppColors.softBlue),
                rootDashboardItem(id: "universities", en: "Universities", nl: "Universiteiten", ru: "Университеты", subtitleEN: "MBO, HBO, research", subtitleNL: "MBO, HBO, onderzoek", subtitleRU: "MBO, HBO, research", icon: "graduationcap.fill", destination: .blogGuides, tint: AppColors.emerald)
            ]
        case .refugee:
            return [
                rootDashboardItem(id: "ind", en: "IND", nl: "IND", ru: "IND", subtitleEN: "Documents and status", subtitleNL: "Documenten en status", subtitleRU: "Документы и статус", icon: "building.columns.fill", destination: .governmentHub, tint: AppColors.softBlue),
                rootDashboardItem(id: "municipality", en: "Municipality", nl: "Gemeente", ru: "Муниципалитет", subtitleEN: ProvinceCatalog.localizedCityName(appState.selectedCity, lang), subtitleNL: ProvinceCatalog.localizedCityName(appState.selectedCity, lang), subtitleRU: ProvinceCatalog.localizedCityName(appState.selectedCity, lang), icon: "building.2.fill", destination: .governmentHub, tint: AppColors.routeLine),
                rootDashboardItem(id: "benefits", en: "Benefits", nl: "Uitkeringen", ru: "Пособия", subtitleEN: "Official support", subtitleNL: "Officiele steun", subtitleRU: "Официальная поддержка", icon: "creditcard.fill", destination: .officialSources, tint: AppColors.emerald)
            ]
        case .family:
            return [
                rootDashboardItem(id: "schools", en: "Schools", nl: "Scholen", ru: "Школы", subtitleEN: "Education for children", subtitleNL: "Onderwijs voor kinderen", subtitleRU: "Образование детей", icon: "graduationcap.fill", destination: .blogGuides, tint: AppColors.emerald),
                rootDashboardItem(id: "childcare", en: "Childcare", nl: "Kinderopvang", ru: "Детский сад", subtitleEN: "Kinderopvang", subtitleNL: "Kinderopvang", subtitleRU: "Kinderopvang", icon: "figure.and.child.holdinghands", destination: .officialSources, tint: AppColors.softBlue),
                rootDashboardItem(id: "svb", en: "SVB", nl: "SVB", ru: "SVB", subtitleEN: "Child benefits", subtitleNL: "Kinderbijslag", subtitleRU: "Детские пособия", icon: "building.columns.fill", destination: .officialSources, tint: AppColors.dutchOrange)
            ]
        case .tourist:
            return [
                rootDashboardItem(id: "stay-rules", en: "Stay Rules", nl: "Verblijfsregels", ru: "Правила пребывания", subtitleEN: "Short stay basics", subtitleNL: "Kort verblijf", subtitleRU: "Краткое пребывание", icon: "calendar.badge.clock", destination: .officialSources, tint: AppColors.softBlue),
                rootDashboardItem(id: "emergency", en: "Emergency", nl: "Noodhulp", ru: "Экстренно", subtitleEN: "112 and urgent help", subtitleNL: "112 en noodhulp", subtitleRU: "112 и срочная помощь", icon: "phone.fill", destination: .emergency, tint: AppColors.error)
            ]
        case .entrepreneur:
            return [
                rootDashboardItem(id: "kvk", en: "KVK", nl: "KVK", ru: "KVK", subtitleEN: "Business registration", subtitleNL: "Bedrijfsregistratie", subtitleRU: "Регистрация бизнеса", icon: "building.columns.fill", destination: .officialSources, tint: AppColors.softBlue),
                rootDashboardItem(id: "vat", en: "VAT / BTW", nl: "BTW", ru: "BTW", subtitleEN: "Tax basics", subtitleNL: "Belastingbasis", subtitleRU: "Налоговые основы", icon: "percent", destination: .officialSources, tint: AppColors.dutchOrange),
                rootDashboardItem(id: "permits", en: "Permits", nl: "Vergunningen", ru: "Разрешения", subtitleEN: "Municipal rules", subtitleNL: "Gemeentelijke regels", subtitleRU: "Муниципальные правила", icon: "doc.text.fill", destination: .governmentHub, tint: AppColors.violet)
            ]
        case .lgbt:
            return [
                rootDashboardItem(id: "rights", en: "Rights", nl: "Rechten", ru: "Права", subtitleEN: "Safety and equality", subtitleNL: "Veiligheid en gelijkheid", subtitleRU: "Безопасность и равенство", icon: "shield.lefthalf.filled", destination: .lgbtq, tint: AppColors.softBlue),
                rootDashboardItem(id: "legal-support", en: "Legal Support", nl: "Juridische steun", ru: "Юридическая помощь", subtitleEN: "Official support", subtitleNL: "Officiele steun", subtitleRU: "Официальная поддержка", icon: "doc.text.fill", destination: .officialSources, tint: AppColors.violet)
            ]
        case .worker, .highlySkilledMigrant, .eu, .nonEU, .universal, nil:
            return [
            rootDashboardItem(id: "bsn", en: "BSN", nl: "BSN", ru: "BSN", subtitleEN: "Registration number", subtitleNL: "Registratienummer", subtitleRU: "Регистрационный номер", icon: "number.circle.fill", destination: .firstSteps(section: .municipalityRegistration), tint: AppColors.softBlue),
            rootDashboardItem(id: "digid", en: "DigiD", nl: "DigiD", ru: "DigiD", subtitleEN: "Digital identity", subtitleNL: "Digitale identiteit", subtitleRU: "Цифровая идентификация", icon: "lock.shield.fill", destination: .firstSteps(section: .digidSafety), tint: AppColors.cyanGlow),
            rootDashboardItem(id: "municipality", en: "Municipality", nl: "Gemeente", ru: "Муниципалитет", subtitleEN: ProvinceCatalog.localizedCityName(appState.selectedCity, lang), subtitleNL: ProvinceCatalog.localizedCityName(appState.selectedCity, lang), subtitleRU: ProvinceCatalog.localizedCityName(appState.selectedCity, lang), icon: "building.columns.fill", destination: .firstSteps(section: .municipalityRegistration), tint: AppColors.routeLine),
            rootDashboardItem(id: "taxes", en: "Taxes", nl: "Belasting", ru: "Налоги", subtitleEN: "Official basics", subtitleNL: "Officiele basis", subtitleRU: "Официальные основы", icon: "banknote.fill", destination: .governmentHub, tint: AppColors.emerald)
            ]
        }
    }

    private var regularLifeItems: [SideMenuItemModel] {
        switch appState.selectedUserStatus?.personaTag {
        case .student:
            return [
                rootDashboardItem(id: "student-housing", en: "Student Housing", nl: "Studentenhuisvesting", ru: "Жилье студента", subtitleEN: "Rooms and contracts", subtitleNL: "Kamers en contracten", subtitleRU: "Комнаты и договоры", icon: "house.fill", destination: .firstSteps(section: .housingBasics), tint: AppColors.violet),
                rootDashboardItem(id: "student-insurance", en: "Student Insurance", nl: "Studentenverzekering", ru: "Страховка студента", subtitleEN: "Healthcare basics", subtitleNL: "Zorgbasis", subtitleRU: "Медицинские основы", icon: "cross.case.fill", destination: .firstSteps(section: .healthInsuranceBasics), tint: AppColors.error),
                rootDashboardItem(id: "transport-discounts", en: "Transport Discounts", nl: "OV-korting", ru: "Скидки на транспорт", subtitleEN: "Student travel", subtitleNL: "Studentenreisproduct", subtitleRU: "Студенческий проезд", icon: "tram.fill", destination: .firstSteps(section: .transportBasics), tint: AppColors.dutchOrange)
            ]
        case .refugee:
            return [
                rootDashboardItem(id: "housing", en: "Housing", nl: "Wonen", ru: "Жилье", subtitleEN: "Municipality path", subtitleNL: "Gemeentepad", subtitleRU: "Путь через gemeente", icon: "house.fill", destination: .firstSteps(section: .housingBasics), tint: AppColors.violet),
                rootDashboardItem(id: "healthcare", en: "Healthcare", nl: "Zorg", ru: "Медицина", subtitleEN: "GP and insurance", subtitleNL: "Huisarts en verzekering", subtitleRU: "Врач и страховка", icon: "cross.case.fill", destination: .firstSteps(section: .healthcareBasics), tint: AppColors.error),
                rootDashboardItem(id: "documents", en: "Documents", nl: "Documenten", ru: "Документы", subtitleEN: "Proof and permissions", subtitleNL: "Bewijs en toestemmingen", subtitleRU: "Доказательства и разрешения", icon: "doc.text.fill", destination: .journeyDocuments, tint: AppColors.softBlue)
            ]
        case .family:
            return [
                rootDashboardItem(id: "family-housing", en: "Family Housing", nl: "Gezinswoning", ru: "Жилье семьи", subtitleEN: "Home and registration", subtitleNL: "Wonen en inschrijving", subtitleRU: "Дом и регистрация", icon: "house.fill", destination: .firstSteps(section: .housingBasics), tint: AppColors.violet),
                rootDashboardItem(id: "healthcare", en: "Healthcare", nl: "Zorg", ru: "Медицина", subtitleEN: "Family care", subtitleNL: "Gezinszorg", subtitleRU: "Медицина семьи", icon: "cross.case.fill", destination: .firstSteps(section: .healthcareBasics), tint: AppColors.error),
                rootDashboardItem(id: "activities", en: "Activities", nl: "Activiteiten", ru: "Активности", subtitleEN: "City life for families", subtitleNL: "Stadsleven voor gezinnen", subtitleRU: "Городская жизнь семьи", icon: "calendar", destination: .cultureAttractions, tint: AppColors.dutchOrange)
            ]
        case .tourist:
            return [
                rootDashboardItem(id: "transport", en: "Transport", nl: "Vervoer", ru: "Транспорт", subtitleEN: "OV and city travel", subtitleNL: "OV en stadsreizen", subtitleRU: "OV и город", icon: "tram.fill", destination: .firstSteps(section: .transportBasics), tint: AppColors.dutchOrange),
                rootDashboardItem(id: "healthcare", en: "Healthcare", nl: "Zorg", ru: "Медицина", subtitleEN: "Urgent care", subtitleNL: "Spoedzorg", subtitleRU: "Срочная помощь", icon: "cross.case.fill", destination: .firstSteps(section: .healthcareBasics), tint: AppColors.error),
                rootDashboardItem(id: "places", en: "Places", nl: "Plaatsen", ru: "Места", subtitleEN: "City essentials", subtitleNL: "Stadsinformatie", subtitleRU: "Городские места", icon: "mappin.circle.fill", destination: .placesToVisit, tint: AppColors.routeLine)
            ]
        case .entrepreneur:
            return [
                rootDashboardItem(id: "business-banking", en: "Business Banking", nl: "Zakelijk bankieren", ru: "Бизнес-банк", subtitleEN: "Money basics", subtitleNL: "Geldzaken", subtitleRU: "Финансы", icon: "creditcard.fill", destination: .firstSteps(section: .bankingBasics), tint: AppColors.softBlue),
                rootDashboardItem(id: "insurance", en: "Insurance", nl: "Verzekering", ru: "Страхование", subtitleEN: "Health and business", subtitleNL: "Zorg en bedrijf", subtitleRU: "Медицина и бизнес", icon: "cross.case.fill", destination: .firstSteps(section: .healthInsuranceBasics), tint: AppColors.error),
                rootDashboardItem(id: "housing", en: "Housing", nl: "Wonen", ru: "Жилье", subtitleEN: "Personal setup", subtitleNL: "Persoonlijke basis", subtitleRU: "Личная база", icon: "house.fill", destination: .firstSteps(section: .housingBasics), tint: AppColors.violet)
            ]
        case .lgbt:
            return [
                rootDashboardItem(id: "healthcare", en: "Healthcare", nl: "Zorg", ru: "Медицина", subtitleEN: "Inclusive care", subtitleNL: "Inclusieve zorg", subtitleRU: "Инклюзивная медицина", icon: "cross.case.fill", destination: .firstSteps(section: .healthcareBasics), tint: AppColors.error),
                rootDashboardItem(id: "mental-health", en: "Mental Health", nl: "Mentale gezondheid", ru: "Психическое здоровье", subtitleEN: "Support and safety", subtitleNL: "Steun en veiligheid", subtitleRU: "Поддержка и безопасность", icon: "heart.fill", destination: .emotionalSupport, tint: AppColors.violet),
                rootDashboardItem(id: "housing-safety", en: "Housing Safety", nl: "Woonveiligheid", ru: "Безопасность жилья", subtitleEN: "Safe housing", subtitleNL: "Veilig wonen", subtitleRU: "Безопасное жилье", icon: "house.fill", destination: .firstSteps(section: .housingBasics), tint: AppColors.softBlue)
            ]
        case .worker, .highlySkilledMigrant, .eu, .nonEU, .universal, nil:
            return [
            rootDashboardItem(id: "healthcare", en: "Healthcare", nl: "Zorg", ru: "Медицина", subtitleEN: "GP and insurance", subtitleNL: "Huisarts en verzekering", subtitleRU: "Врач и страховка", icon: "cross.case.fill", destination: .firstSteps(section: .healthcareBasics), tint: AppColors.error),
            rootDashboardItem(id: "housing", en: "Housing", nl: "Wonen", ru: "Жилье", subtitleEN: "Renting safely", subtitleNL: "Veilig huren", subtitleRU: "Безопасная аренда", icon: "house.fill", destination: .firstSteps(section: .housingBasics), tint: AppColors.violet),
            rootDashboardItem(id: "transport", en: "Transport", nl: "Vervoer", ru: "Транспорт", subtitleEN: "OV and cycling", subtitleNL: "OV en fietsen", subtitleRU: "OV и велосипед", icon: "tram.fill", destination: .firstSteps(section: .transportBasics), tint: AppColors.dutchOrange),
            rootDashboardItem(id: "banking", en: "Banking", nl: "Bankieren", ru: "Банки", subtitleEN: "Money basics", subtitleNL: "Geldzaken", subtitleRU: "Финансы", icon: "creditcard.fill", destination: .firstSteps(section: .bankingBasics), tint: AppColors.softBlue)
            ]
        }
    }

    private var regularLearnItems: [SideMenuItemModel] {
        switch appState.selectedUserStatus?.personaTag {
        case .student:
            return [
                rootDashboardItem(id: "dutch-language", en: "Dutch Language Courses", nl: "Nederlandse taalcursussen", ru: "Курсы нидерландского", subtitleEN: "A1/A2 Dutch", subtitleNL: "A1/A2 Nederlands", subtitleRU: "A1/A2 нидерландский", icon: "text.book.closed.fill", destination: .dutchA1A2, tint: AppColors.emerald),
                rootDashboardItem(id: "libraries", en: "Libraries", nl: "Bibliotheken", ru: "Библиотеки", subtitleEN: "Study spaces", subtitleNL: "Studieplekken", subtitleRU: "Места для учебы", icon: "books.vertical.fill", destination: .map, tint: AppColors.softBlue),
                rootDashboardItem(id: "student-life", en: "Student Communities", nl: "Studentengemeenschappen", ru: "Студенческие сообщества", subtitleEN: "Events and free time", subtitleNL: "Events en vrije tijd", subtitleRU: "События и досуг", icon: "person.3.fill", destination: .cultureAttractions, tint: AppColors.dutchOrange)
            ]
        case .worker, .highlySkilledMigrant, .eu:
            return [
                rootDashboardItem(id: "worker-training", en: "Worker Training", nl: "Werknemerstraining", ru: "Обучение работника", subtitleEN: "Skills and rights", subtitleNL: "Vaardigheden en rechten", subtitleRU: "Навыки и права", icon: "wrench.and.screwdriver.fill", destination: .blogGuides, tint: AppColors.emerald),
                rootDashboardItem(id: "language", en: "Language", nl: "Taal", ru: "Язык", subtitleEN: "A1/A2 Dutch", subtitleNL: "A1/A2 Nederlands", subtitleRU: "A1/A2 нидерландский", icon: "text.book.closed.fill", destination: .dutchA1A2, tint: AppColors.softBlue)
            ]
        case .refugee:
            return [
                rootDashboardItem(id: "integration", en: "Integration", nl: "Integratie", ru: "Интеграция", subtitleEN: "Inburgering and next steps", subtitleNL: "Inburgering en stappen", subtitleRU: "Inburgering и шаги", icon: "figure.2.arms.open", destination: .integration, tint: AppColors.emerald),
                rootDashboardItem(id: "language", en: "Language", nl: "Taal", ru: "Язык", subtitleEN: "Dutch learning", subtitleNL: "Nederlands leren", subtitleRU: "Учить нидерландский", icon: "text.book.closed.fill", destination: .languageHub, tint: AppColors.softBlue),
                rootDashboardItem(id: "education-access", en: "Education Access", nl: "Toegang onderwijs", ru: "Доступ к образованию", subtitleEN: "Study options", subtitleNL: "Studieopties", subtitleRU: "Варианты учебы", icon: "graduationcap.fill", destination: .blogGuides, tint: AppColors.cyanGlow)
            ]
        case .family:
            return [
                rootDashboardItem(id: "family-activities", en: "Family Activities", nl: "Gezinsactiviteiten", ru: "Семейные активности", subtitleEN: "City life", subtitleNL: "Stadsleven", subtitleRU: "Городская жизнь", icon: "calendar", destination: .cultureAttractions, tint: AppColors.dutchOrange)
            ]
        case .tourist:
            return [
                rootDashboardItem(id: "culture", en: "City Life", nl: "Stadsleven", ru: "Городская жизнь", subtitleEN: "Places and culture", subtitleNL: "Plaatsen en cultuur", subtitleRU: "Места и культура", icon: "mappin.and.ellipse", destination: .cultureAttractions, tint: AppColors.dutchOrange)
            ]
        case .entrepreneur:
            return [
                rootDashboardItem(id: "networking", en: "Networking", nl: "Netwerken", ru: "Нетворкинг", subtitleEN: "Business community", subtitleNL: "Ondernemersnetwerk", subtitleRU: "Бизнес-сообщество", icon: "person.3.fill", destination: .blogGuides, tint: AppColors.emerald),
                rootDashboardItem(id: "language", en: "Language", nl: "Taal", ru: "Язык", subtitleEN: "Dutch for business", subtitleNL: "Nederlands voor zaken", subtitleRU: "Нидерландский для бизнеса", icon: "text.book.closed.fill", destination: .dutchA1A2, tint: AppColors.softBlue)
            ]
        case .lgbt:
            return [
                rootDashboardItem(id: "community", en: "Community", nl: "Gemeenschap", ru: "Сообщество", subtitleEN: "Support and belonging", subtitleNL: "Steun en gemeenschap", subtitleRU: "Поддержка и сообщество", icon: "person.3.fill", destination: .lgbtq, tint: AppColors.dutchOrange)
            ]
        case .nonEU, .universal, nil:
            return [
            rootDashboardItem(id: "culture", en: "Dutch Culture", nl: "Nederlandse cultuur", ru: "Культура", subtitleEN: "Norms and daily life", subtitleNL: "Normen en dagelijks leven", subtitleRU: "Нормы и быт", icon: "person.2.fill", destination: .cultureAttractions, tint: AppColors.dutchOrange),
            rootDashboardItem(id: "history", en: "History", nl: "Geschiedenis", ru: "История", subtitleEN: "Context for KNM", subtitleNL: "Context voor KNM", subtitleRU: "Контекст для KNM", icon: "clock.arrow.circlepath", destination: .historyNetherlands, tint: AppColors.cyanGlow),
            rootDashboardItem(id: "language", en: "Language", nl: "Taal", ru: "Язык", subtitleEN: "A1/A2 Dutch", subtitleNL: "A1/A2 Nederlands", subtitleRU: "A1/A2 нидерландский", icon: "text.book.closed.fill", destination: .dutchA1A2, tint: AppColors.emerald)
            ]
        }
    }

    private var regularSettingsItems: [SideMenuItemModel] {
        [
            rootDashboardItem(id: "settings", en: "Settings", nl: "Instellingen", ru: "Настройки", subtitleEN: "Language and preferences", subtitleNL: "Taal en voorkeuren", subtitleRU: "Язык и параметры", icon: "gearshape.fill", destination: .settings, tint: AppColors.textSecondary)
        ]
    }

    private func rootDashboardItem(
        id: String,
        en: String,
        nl: String,
        ru: String,
        subtitleEN: String? = nil,
        subtitleNL: String? = nil,
        subtitleRU: String? = nil,
        icon: String,
        destination: MenuDestination,
        tint: Color
    ) -> SideMenuItemModel {
        SideMenuItemModel(
            id: "regular-\(id)",
            titleKey: "sideMenu.title",
            titleOverride: [.english: en, .dutch: nl, .russian: ru],
            subtitleOverride: subtitleEN == nil ? nil : [.english: subtitleEN ?? "", .dutch: subtitleNL ?? subtitleEN ?? "", .russian: subtitleRU ?? subtitleEN ?? ""],
            systemIcon: icon,
            destination: destination,
            tint: tint
        )
    }

    private func localizedRootText(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .russian: return ru
        case .dutch: return nl
        case .english: return en
        }
    }

    private var languageIndicator: String {
        switch lang {
        case .russian: return "RU"
        case .dutch: return "NL"
        case .english: return "EN"
        }
    }

    private var regularSidebarTime: String {
        Date.now.formatted(.dateTime.locale(Locale(identifier: "nl_NL")).hour().minute())
    }

    private var regularSidebarDate: String {
        Date.now.formatted(.dateTime.locale(Locale(identifier: "nl_NL")).weekday(.abbreviated).day().month(.abbreviated))
    }

    private func regularTabSubtitle(_ tab: AppTab) -> String? {
        switch tab {
        case .home: return localizedRootText(en: "City intelligence", nl: "Stadsinformatie", ru: "Городской гид")
        case .guide: return localizedRootText(en: "All topics", nl: "Alle onderwerpen", ru: "Все темы")
        case .map: return localizedRootText(en: "Netherlands map", nl: "Kaart van Nederland", ru: "Карта Нидерландов")
        case .saved: return localizedRootText(en: "Saved guides", nl: "Bewaarde gidsen", ru: "Сохраненное")
        case .more: return nil
        }
    }

    private func regularTabTint(_ tab: AppTab) -> Color {
        switch tab {
        case .home: return AppColors.cyanGlow
        case .guide: return AppColors.emerald
        case .map: return AppColors.routeLine
        case .saved: return AppColors.softBlue
        case .more: return AppColors.textSecondary
        }
    }

#if os(iOS)
    private var compactTabBarItems: [FloatingTabBarItem] {
        [
            FloatingTabBarItem(tab: .home,  title: tabHomeTitle,  symbol: AppIcons.home, selectedSymbol: AppIcons.homeActive),
            FloatingTabBarItem(tab: .guide, title: tabGuideTitle, symbol: "books.vertical", selectedSymbol: "books.vertical.fill"),
            FloatingTabBarItem(tab: .map,   title: tabMapTitle,   symbol: AppIcons.map, selectedSymbol: AppIcons.mapActive),
            FloatingTabBarItem(tab: .saved, title: tabSavedTitle, symbol: AppIcons.save, selectedSymbol: AppIcons.saved),
            FloatingTabBarItem(tab: .more,  title: tabMoreTitle,  symbol: AppIcons.more, selectedSymbol: AppIcons.moreActive)
        ]
    }
#endif

    private var tabHomeTitle: String      { L10n.t("tab.home",    lang) }
    private var tabGuideTitle: String     { localizedRootText(en: "Guide", nl: "Gids", ru: "Гид") }
    private var tabPlacesTitle: String    { localizedRootText(en: "Map", nl: "Kaart", ru: "Карта") }
    private var tabSearchTitle: String    { L10n.t("tab.search",  lang) }
    private var tabMapTitle: String       { L10n.t("tab.map",     lang) }
    private var tabFavoritesTitle: String { L10n.t("tab.saved",   lang) }
    private var tabAssistantTitle: String { L10n.t("tab.ai", lang) }
    private var tabSavedTitle: String     { L10n.t("tab.saved", lang) }
    private var tabMoreTitle: String      { L10n.t("tab.more", lang) }

    private var menuSections: [SideMenuSection] {
        [
            SideMenuSection(
                id: "main",
                titleKey: "sideMenu.main",
                items: [
                    SideMenuItemModel(id: "home", titleKey: "sideMenu.home", systemIcon: AppIcons.home, destination: .home, tint: AppColors.cyanGlow),
                    SideMenuItemModel(
                        id: "places",
                        titleKey: "sideMenu.title",
                        titleOverride: [.russian: "Карта", .dutch: "Kaart", .english: "Map"],
                        subtitleOverride: [.russian: "Карта, список и партнеры", .dutch: "Kaart, lijst en partners", .english: "Map, list, and partners"],
                        systemIcon: AppIcons.map,
                        destination: .map,
                        tint: AppColors.routeLine
                    ),
                    SideMenuItemModel(
                        id: "netherlandsOverview",
                        titleKey: "sideMenu.title",
                        titleOverride: [.russian: "О Нидерландах", .dutch: "Over Nederland", .english: "About the Netherlands"],
                        subtitleOverride: [.russian: "Страна, факты, устройство", .dutch: "Land, feiten, bestuur", .english: "Country, facts, state"],
                        systemIcon: "map.fill",
                        destination: .netherlandsOverview,
                        tint: AppColors.dutchOrange
                    ),
                    SideMenuItemModel(id: "saved", titleKey: "sideMenu.saved", systemIcon: AppIcons.save, destination: .saved, tint: AppColors.softBlue),
                    SideMenuItemModel(id: "history",      titleKey: "sideMenu.historyNetherlands",  subtitleKey: "sideMenu.subtitle.history",   systemIcon: "clock.arrow.circlepath",  destination: .historyNetherlands, tint: AppColors.cyanGlow),
                    SideMenuItemModel(id: "language",     titleKey: "sideMenu.language",     systemIcon: "globe",                    destination: .language,    tint: AppColors.softBlue),
                    SideMenuItemModel(id: "dutchA1A2", titleKey: "sideMenu.dutchA1A2", subtitleKey: "sideMenu.subtitle.dutchA1A2", systemIcon: "text.book.closed.fill", destination: .dutchA1A2, tint: AppColors.emerald),
                    SideMenuItemModel(id: "knm",          titleKey: "sideMenu.knm",         subtitleKey: "sideMenu.subtitle.knm",       systemIcon: "graduationcap.fill",       destination: .knm,         tint: AppColors.cyanGlow),
                    SideMenuItemModel(id: "law",          titleKey: "guide.law",                                                        systemIcon: "building.columns.fill",   destination: .governmentHub, tint: AppColors.softBlue),
                    SideMenuItemModel(id: "documents",     titleKey: "sideMenu.documents",  systemIcon: "doc.text.fill",                destination: .guideSection("documents"), tint: AppColors.cyanGlow),
                    SideMenuItemModel(id: "digid", titleKey: "sideMenu.digidSafety", systemIcon: "lock.shield.fill", destination: .firstSteps(section: .digidSafety), tint: AppColors.cyanGlow),
                    SideMenuItemModel(id: "housing", titleKey: "sideMenu.housing", systemIcon: "house.fill", destination: .guideSection("housing"), tint: AppColors.violet),
                    SideMenuItemModel(id: "transport",      titleKey: "sideMenu.transport",        subtitleKey: "sideMenu.subtitle.transport",        systemIcon: "tram.fill",             destination: .guideSection("transport"),                      tint: AppColors.dutchOrange),
                    SideMenuItemModel(id: "healthcare",     titleKey: "sideMenu.healthcare",       subtitleKey: "sideMenu.subtitle.healthcare",       systemIcon: "cross.case",            destination: .guideSection("healthcare"),                      tint: AppColors.error),
                    SideMenuItemModel(id: "official", titleKey: "sideMenu.officialSources", systemIcon: "checkmark.shield.fill", destination: .officialSources, tint: AppColors.success),
                    SideMenuItemModel(id: "police",          titleKey: "guide.police",          systemIcon: "shield.lefthalf.filled",              destination: .police,          tint: AppColors.softBlue),
                    SideMenuItemModel(id: "municipality",   titleKey: "sideMenu.registration",    subtitleKey: "sideMenu.subtitle.registration",    systemIcon: "building.columns",      destination: .firstSteps(section: .municipalityRegistration), tint: AppColors.routeLine),
                    SideMenuItemModel(id: "socialService",   titleKey: "guide.socialService",   systemIcon: "person.crop.circle.badge.checkmark",  destination: .socialService,   tint: AppColors.emerald),
                    SideMenuItemModel(id: "socialSupport",   titleKey: "guide.socialSupport",   systemIcon: "heart.fill",                          destination: .emotionalSupport, tint: AppColors.error),
                    SideMenuItemModel(id: "lgbtq",           titleKey: "guide.lgbtq",           systemIcon: "rainbow",                             destination: .lgbtq,           tint: AppColors.violet),
                    SideMenuItemModel(id: "ukraineSupport",  titleKey: "guide.ukraine",         systemIcon: "heart.text.square.fill",              destination: .survivalHub,     tint: AppColors.warning),
                    SideMenuItemModel(id: "refugees",        titleKey: "guide.refugees",        systemIcon: "figure.walk",                         destination: .survivalHub,     tint: AppColors.dutchOrange),
                    SideMenuItemModel(id: "finance",        titleKey: "sideMenu.banking",          subtitleKey: "sideMenu.subtitle.banking",          systemIcon: "creditcard.fill",       destination: .firstSteps(section: .bankingBasics),            tint: AppColors.softBlue),
                    SideMenuItemModel(id: "fines",          titleKey: "guide.fines",                                                                  systemIcon: "exclamationmark.triangle.fill", destination: .guideSection("fines"),                  tint: AppColors.warning),
                    SideMenuItemModel(id: "culture",      titleKey: "sideMenu.cultureAttractions",  subtitleKey: "sideMenu.subtitle.culture",   systemIcon: "building.columns",        destination: .cultureAttractions, tint: AppColors.dutchOrange),
                    SideMenuItemModel(id: "placesToVisit",titleKey: "guide.placesToVisit",                                                      systemIcon: "mappin.and.ellipse",      destination: .placesToVisit,      tint: AppColors.softBlue),
                    SideMenuItemModel(id: "guides",       titleKey: "sideMenu.blogGuides",          subtitleKey: "sideMenu.subtitle.guides",    systemIcon: "doc.text",                destination: .blogGuides,         tint: AppColors.emerald),
                    SideMenuItemModel(id: "feedback", titleKey: "sideMenu.feedback", systemIcon: "star.bubble.fill", destination: .feedback, isVisible: false, tint: AppColors.dutchOrange),
                    SideMenuItemModel(id: "settings", titleKey: "sideMenu.settings", systemIcon: "gearshape",    destination: .settings, tint: AppColors.textSecondary)
                ]
            ),
            SideMenuSection(
                id: "workGuide",
                titleKey: "sideMenu.title",
                titleOverride: [.russian: "💼 РАБОТА", .dutch: "💼 WERK", .english: "💼 WORK"],
                items: [workGuideMenuItem]
            ),
            SideMenuSection(
                id: "integrationGuide",
                titleKey: "sideMenu.title",
                titleOverride: [.russian: "🌍 ИНТЕГРАЦИЯ", .dutch: "🌍 INTEGRATIE", .english: "🌍 INTEGRATION"],
                items: [integrationGuideMenuItem]
            ),
            SideMenuSection(
                id: "emergencyGuide",
                titleKey: "sideMenu.title",
                titleOverride: [.russian: "🚨 ЭКСТРЕННЫЕ СИТУАЦИИ", .dutch: "🚨 NOODGEVALLEN", .english: "🚨 EMERGENCY"],
                items: [emergencyGuideMenuItem]
            )
        ]
    }

    private var workGuideMenuItem: SideMenuItemModel {
        SideMenuItemModel(
            id: "work",
            titleKey: "sideMenu.title",
            titleOverride: [.russian: "Работа", .dutch: "Werk", .english: "Work"],
            subtitleOverride: [.russian: "Разрешения, зарплата, поиск", .dutch: "Vergunningen, loon, zoeken", .english: "Permits, salary, search"],
            systemIcon: "briefcase.fill",
            destination: .guideSection("work"),
            tint: AppColors.softBlue
        )
    }

    private var integrationGuideMenuItem: SideMenuItemModel {
        SideMenuItemModel(
            id: "integration",
            titleKey: "guide.integration",
            titleOverride: [.russian: "Интеграция", .dutch: "Integratie", .english: "Integration"],
            subtitleOverride: [.russian: "Язык, культура, адаптация", .dutch: "Taal, cultuur, aanpassen", .english: "Language, culture, settling in"],
            systemIcon: "globe.europe.africa.fill",
            destination: .guideSection("integration"),
            tint: AppColors.emerald
        )
    }

    private var emergencyGuideMenuItem: SideMenuItemModel {
        SideMenuItemModel(
            id: "emergencyGuide",
            titleKey: "sideMenu.title",
            titleOverride: [.russian: "Экстренные ситуации", .dutch: "Noodgevallen", .english: "Emergency"],
            subtitleOverride: [.russian: "112, полиция, врач", .dutch: "112, politie, huisarts", .english: "112, police, GP"],
            systemIcon: "exclamationmark.triangle.fill",
            destination: .guideSection("emergency"),
            tint: AppColors.error
        )
    }

    private func handleTabSelection(_ tab: AppTab) {
        isGlobalAIModeLauncherExpanded = false
        if tab == .more {
            if isMenuPresented {
                closeMenu()
                return
            }
            if selectedTab == .more {
                resetTabToRoot(.more)
                return
            }
            registerTabTap(.more)
            activeMenuDestination = nil
            previousContentTab = .more
            selectedTab = .more
            tabRouter.select(TabItem.more)
            return
        }

        if isMenuPresented {
            closeMenu()
        }

        if selectedTab == tab {
            resetTabToRoot(tab)
            return
        }

        registerTabTap(tab)
        activeMenuDestination = nil
        previousContentTab = tab
        selectedTab = tab
        tabRouter.select(tab)
    }

    private func registerTabTap(_ tab: AppTab) {
        let now = Date()
        lastTappedTab = tab
        lastTabTapDate = now
    }

    private func resetTabToRoot(_ tab: AppTab) {
        activeMenuDestination = nil
        isMenuPresented = false
        isGlobalAIModeLauncherExpanded = false
#if os(iOS)
        if horizontalSizeClass == .regular && menuPosition == .automatic {
            regularNavPath = NavigationPath()
        } else {
            clearPath(for: tab)
        }
#else
        clearPath(for: tab)
#endif
        previousContentTab = tab
        selectedTab = tab
        tabRouter.select(tab)
        registerTabTap(tab)
    }

    private func openMenu() {
        isGlobalAIModeLauncherExpanded = false
        if selectedTab != .more {
            previousContentTab = selectedTab
        }
        tabRouter.selectedTab = TabItem.more
        selectedTab = previousContentTab
        isMenuPresented = true
    }

    private func closeMenu() {
        isGlobalAIModeLauncherExpanded = false
        isMenuPresented = false
        selectedTab = previousContentTab
        tabRouter.selectedTab = previousContentTab.tabItem
    }

    private func isMenuItemVisibleForPersona(_ item: SideMenuItemModel) -> Bool {
        guard item.isVisible else { return false }
        guard let destination = item.destination.appDestination else { return true }
        return RelatedContentEngine.isVisible(destination, for: appState.selectedUserStatus?.personaTag)
    }

    private func handleMenuSelection(_ item: SideMenuItemModel) {
        guard isMenuItemVisibleForPersona(item) else { return }
        if item.destination == .feedback {
            openFeedbackAssistant()
            return
        }
        isMenuPresented = false
        navigateAfterClose(item.destination)
    }

    private func openFeedbackAssistant() {
        isMenuPresented = false
        activeMenuDestination = .supportFeedback
        previousContentTab = .home
        selectedTab = .home
        navigateFromMenu(to: .supportFeedback)
    }

    private func navigateAfterClose(_ destination: MenuDestination) {
        switch destination.tab {
        case .some(let tab):
            if selectedTab == tab, activeMenuDestination == nil {
                previousContentTab = tab
                selectedTab = tab
                tabRouter.selectedTab = tab.tabItem
                return
            }
            activeMenuDestination = nil
            clearPath(for: tab)
            previousContentTab = tab
            selectedTab = tab
            tabRouter.selectedTab = tab.tabItem
        case .none:
            guard let appDestination = destination.appDestination else { return }
            if activeMenuDestination == appDestination {
                return
            }
            navigateFromMenu(to: appDestination)
        }
    }

    private func navigateFromMenu(to destination: AppDestination) {
        activeMenuDestination = destination
        previousContentTab = .home
        selectedTab = .home
        tabRouter.selectedTab = TabItem.home
        if horizontalSizeClass == .regular && menuPosition == .automatic {
            regularNavPath = NavigationPath()
            regularNavPath.append(destination)
        } else {
            homeNavPath = NavigationPath()
            homeNavPath.append(destination)
        }
    }

    private func openGlobalAssistant(_ mode: GlobalAIMode) {
        let context = AIContextBuilder.automaticContext(
            selectedTab: selectedTab,
            activeDestination: activeMenuDestination,
            language: lang,
            appState: appState
        )
        appState.pendingAIContext = context
        appState.pendingAIPrompt = globalAssistantPrompt(for: mode, context: context)
        isMenuPresented = false
        isGlobalAIModeLauncherExpanded = false
        activeMenuDestination = nil
        previousContentTab = .guide
        selectedTab = .guide
        tabRouter.selectedTab = .guide
        if horizontalSizeClass == .regular && menuPosition == .automatic {
            regularNavPath.append(AppDestination.assistantHub)
        } else {
            guideNavPath.append(AppDestination.assistantHub)
        }
    }

    private func globalAssistantPrompt(for mode: GlobalAIMode, context: AIContext) -> String? {
        switch mode {
        case .askQuestion:
            return nil
        case .explainScreen:
            return AIContextBuilder.automaticPrompt(
                language: lang,
                selectedTab: selectedTab,
                activeDestination: activeMenuDestination
            )
        case .nextStep:
            switch lang {
            case .russian:
                return "Что мне делать дальше? Используйте мой город, статус, сохранённые элементы, прогресс и текущий экран."
            case .dutch:
                return "Wat moet ik nu doen? Gebruik mijn stad, status, opgeslagen items, voortgang en huidig scherm."
            case .english:
                return "What should I do next? Use my city, profile, saved items, progress, and current screen."
            }
        case .findInApp:
            switch lang {
            case .russian:
                return "Найди в приложении: "
            case .dutch:
                return "Zoek in de app: "
            case .english:
                return "Find in the app: "
            }
        case .translate:
            if let text = context.topicSummary?.trimmingCharacters(in: .whitespacesAndNewlines),
               text.count >= 24 {
                switch lang {
                case .russian:
                    return "Переведи и объясни простыми словами этот текст: \(text)"
                case .dutch:
                    return "Vertaal en leg deze tekst eenvoudig uit: \(text)"
                case .english:
                    return "Translate and explain this text in simple language: \(text)"
                }
            }
            switch lang {
            case .russian:
                return "Вставьте текст письма, сообщения или документа, который нужно перевести. Не переводите только название экрана."
            case .dutch:
                return "Plak de tekst van de brief, het bericht of document dat u wilt vertalen. Vertaal niet alleen de schermtitel."
            case .english:
                return "Paste the letter, message, or document text you want translated. Do not translate only the screen title."
            }
        case .guideMe:
            let target = context.topicTitle ?? context.category ?? localizedRootText(en: "this task", nl: "deze taak", ru: "эту задачу")
            switch lang {
            case .russian:
                return "Проведи меня шаг за шагом: \(target). Задавай вопросы, если нужно выбрать правильный путь."
            case .dutch:
                return "Begeleid mij stap voor stap: \(target). Stel vragen als je de juiste route moet kiezen."
            case .english:
                return "Guide me step by step: \(target). Ask questions if you need to choose the right path."
            }
        }
    }

    private var feedbackAssistantPrompt: String {
        switch lang {
        case .russian: return "Я хочу оставить отзыв о приложении YouNew. Помоги сформулировать краткий отзыв: что работает хорошо, что неудобно и что улучшить."
        case .dutch: return "Ik wil feedback geven over de YouNew-app. Help mij een korte feedback te formuleren: wat werkt goed, wat is onhandig en wat kan beter."
        case .english: return "I want to give feedback about the YouNew app. Help me write concise feedback: what works well, what feels difficult, and what should improve."
        }
    }

    private func openPlacesAI(_ query: String) {
        let prompt = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty else { return }

        appState.pendingAIContext = AIContext(
            screen: .map,
            category: tabPlacesTitle,
            topicTitle: "Places discovery",
            topicSummary: "User asked from Places: \(prompt)",
            officialSources: [],
            lastReviewed: nil,
            userLanguage: lang,
            userSituation: appState.selectedUserStatus?.localized(lang),
            selectedCity: appState.selectedCity,
            selectedProvince: nil,
            savedItemTitles: [],
            lastSearches: [prompt],
            disclaimer: AISafetyRules.mandatoryDisclaimer(for: lang),
            activePersonaTag: appState.selectedUserStatus?.personaTag
        )
        appState.pendingAIPrompt = prompt
        isMenuPresented = false
        isGlobalAIModeLauncherExpanded = false
        activeMenuDestination = nil
        previousContentTab = .guide
        selectedTab = .guide
        tabRouter.selectedTab = .guide
        if horizontalSizeClass == .regular && menuPosition == .automatic {
            regularNavPath.append(AppDestination.assistantHub)
        } else {
            guideNavPath.append(AppDestination.assistantHub)
        }
    }

    private func clearPath(for tab: AppTab) {
        switch tab {
        case .home: homeNavPath = NavigationPath()
        case .guide: guideNavPath = NavigationPath()
        case .more: moreNavPath = NavigationPath()
        case .map: mapNavPath = NavigationPath()
        case .saved: savedNavPath = NavigationPath()
        }
    }
}

private enum FirstStepsSection: Hashable {
    case municipalityRegistration
    case healthcareBasics
    case findingHuisarts
    case healthInsuranceBasics
    case digidSafety
    case transportBasics
    case housingBasics
    case bankingBasics
    case officialSourcesChecklist
}

private enum MenuDestination: Equatable {
    case home
    case search
    case map
    case saved
    case help
    case cities
    case provinces
    case informationHub
    case netherlandsOverview
    case historyNetherlands
    case cultureAttractions
    case blogGuides
    case journeyDocuments
    case emergency
    case firstSteps(section: FirstStepsSection?)
    case knm
    case dutchA1A2
    case officialSources
    case language
    case settings
    case sources
    case about
    case feedback
    case currentCity(province: String, city: String)
    // Extended guide destinations
    case emotionalSupport
    case fines
    case survivalHub
    case languageHub
    case governmentHub
    case lgbtq
    case integration
    case police
    case socialService
    case scamWarnings
    case placesToVisit
    case guideSection(String)

    var tab: AppTab? {
        switch self {
        case .home: return .home
        case .search: return .guide
        case .map: return .map
        case .saved: return .saved
        case .help: return .guide
        default: return nil
        }
    }

    var appDestination: AppDestination? {
        switch self {
        case .informationHub: return .informationHub
        case .netherlandsOverview: return .netherlandsOverview
        case .cities: return .cityList
        case .provinces: return .provinceList
        case .historyNetherlands: return .netherlandsHistory
        case .cultureAttractions: return .cultureAttractions
        case .blogGuides: return .beginnerGuidesList
        case .journeyDocuments: return .journeyDocuments
        case .emergency, .police: return .emergencyHub
        case .firstSteps(nil): return .firstSteps
        case .firstSteps(.some(.municipalityRegistration)): return .practicalGuide(.municipalityRegistration)
        case .firstSteps(.some(.healthcareBasics)): return .practicalGuide(.healthcareBasics)
        case .firstSteps(.some(.findingHuisarts)): return .practicalGuide(.findingHuisarts)
        case .firstSteps(.some(.healthInsuranceBasics)): return .practicalGuide(.healthInsuranceBasics)
        case .firstSteps(.some(.digidSafety)): return .practicalGuide(.digidSafety)
        case .firstSteps(.some(.transportBasics)): return .practicalGuide(.transportBasics)
        case .firstSteps(.some(.housingBasics)): return .practicalGuide(.housingBasics)
        case .firstSteps(.some(.bankingBasics)): return .practicalGuide(.bankingBasics)
        case .firstSteps(.some(.officialSourcesChecklist)): return .practicalGuide(.officialSourcesChecklist)
        case .knm: return .knm
        case .dutchA1A2: return .dutchA1A2
        case .officialSources, .sources: return .officialSources
        case .language, .languageHub: return .languageHub
        case .settings: return .settings
        case .about: return .aboutYouNew
        case .currentCity(let province, let city): return .cityDetail(province: province, city: city)
        case .emotionalSupport: return .emotionalSupport
        case .lgbtq: return .lgbtqSupport
        case .socialService: return .helpHub
        case .fines: return .finesList
        case .survivalHub: return .survivalHub
        case .integration: return .guideSection("integration")
        case .governmentHub: return .governmentHub
        case .scamWarnings: return .scamWarningsList
        case .placesToVisit: return .cultureAttractions
        case .guideSection(let id): return .guideSection(id)
        case .feedback: return .supportFeedback
        case .home, .search, .map, .saved, .help: return nil
        }
    }
}

private struct SideMenuSection: Identifiable {
    let id: String
    let titleKey: String
    var titleOverride: [AppLanguage: String]? = nil
    let items: [SideMenuItemModel]

    func title(_ lang: AppLanguage) -> String {
        if let titleOverride, let title = titleOverride[lang] {
            return title
        }
        return L10n.t(titleKey, lang)
    }
}

private struct SideMenuItemModel: Identifiable {
    let id: String
    let titleKey: String
    var titleOverride: [AppLanguage: String]? = nil
    var subtitleKey: String? = nil
    var subtitleOverride: [AppLanguage: String]? = nil
    let systemIcon: String
    let destination: MenuDestination
    var requiresExistingRoute = true
    var isVisible = true
    let tint: Color

    func title(_ lang: AppLanguage) -> String {
        if let titleOverride, let title = titleOverride[lang] {
            return title
        }
        return L10n.t(titleKey, lang)
    }

    func subtitle(_ lang: AppLanguage) -> String? {
        if let subtitleOverride, let subtitle = subtitleOverride[lang] {
            return subtitle
        }
        return subtitleKey.map { L10n.t($0, lang) }
    }
}

private struct CitySidebarGalleryItem: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let symbol: String
    let asset: AppImageAsset
}

struct HistoricalFigure: Identifiable {
    let id: String
    let name: String
    let years: String
    let field: String
    let fieldEN: String
    let fieldRU: String
    let shortBioEN: String
    let shortBioRU: String
    let emoji: String
    let accentColor: String
    let imageURL: String
    let birthCity: String
    let deathCity: String
    let knownFor: String
    let knownForRU: String

    func fieldName(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return fieldRU
        case .dutch: return fieldNL
        case .english: return fieldEN
        }
    }

    func shortBio(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return shortBioRU
        case .dutch: return shortBioNL
        case .english: return shortBioEN
        }
    }

    func knownForText(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return knownForRU
        case .dutch: return knownForNL
        case .english: return knownFor
        }
    }

    private var fieldNL: String {
        switch id {
        case "rembrandt", "vermeer": return "Schilder"
        case "spinoza": return "Filosoof"
        case "erasmus": return "Humanistisch geleerde"
        case "van-gogh": return "Postimpressionistische schilder"
        case "william-orange": return "Vader des vaderlands"
        case "huygens": return "Natuurkundige en astronoom"
        case "anne-frank": return "Dagboekschrijfster"
        case "grotius": return "Vader van het internationaal recht"
        case "leeuwenhoek": return "Vader van de microbiologie"
        default: return fieldEN
        }
    }

    private var shortBioNL: String {
        switch id {
        case "rembrandt":
            return "De grootste Nederlandse meester. Zijn Nachtwacht (1642) in het Rijksmuseum is het beroemdste Nederlandse schilderij. Geboren in Leiden, vernieuwde hij portretkunst en clair-obscur."
        case "vermeer":
            return "Meester van licht en huiselijke interieurs. Meisje met de parel hangt in het Mauritshuis in Den Haag. Hij maakte slechts 34-36 bekende schilderijen, allemaal van grote waarde."
        case "spinoza":
            return "Een van de grootste rationalistische filosofen. Zijn Ethica (1677) stelde dat God en de natuur dezelfde substantie zijn. Geboren in Amsterdam in een Portugees-Joodse familie, werd hij op 23-jarige leeftijd verbannen om zijn radicale ideeën."
        case "erasmus":
            return "De prins der humanisten. Zijn Lof der Zotheid (1509) bespotte kerkelijke corruptie en bereidde de Reformatie voor. De Erasmusbrug in Rotterdam is naar hem vernoemd."
        case "van-gogh":
            return "De wereldwijd bekendste Nederlandse kunstenaar. Hij maakte 2100 werken in 10 jaar ondanks zware psychische problemen. De Sterrennacht en Zonnebloemen behoren tot de beroemdste schilderijen ter wereld."
        case "william-orange":
            return "Vader van Nederland. Hij leidde de opstand tegen Spaans gezag en legde de basis voor de Nederlandse Republiek. In 1584 werd hij in Delft vermoord."
        case "huygens":
            return "Hij vond het slingeruurwerk uit (1656), ontdekte de ringen van Saturnus en de maan Titan, en ontwikkelde de golftheorie van licht. Een van de belangrijkste wetenschappers van de Wetenschappelijke Revolutie."
        case "anne-frank":
            return "Joods meisje dat een dagboek bijhield terwijl ze in Amsterdam ondergedoken zat tijdens de nazi-bezetting. Haar dagboek werd na de oorlog door haar vader Otto uitgegeven en is in 70 talen verspreid."
        case "grotius":
            return "Legde de basis voor het moderne internationaal recht met Mare Liberum (1609) en Over het recht van oorlog en vrede (1625). Het Internationaal Gerechtshof in Den Haag weerspiegelt zijn nalatenschap."
        case "leeuwenhoek":
            return "Delftse lakenhandelaar die eigen microscopen bouwde en als eerste bacteriën (1676), protozoa en bloedcellen waarnam. Hij was autodidact en had geen formele wetenschappelijke opleiding."
        default:
            return shortBioEN
        }
    }

    private var knownForNL: String {
        switch id {
        case "rembrandt": return "Nachtwacht · 600+ schilderijen"
        case "vermeer": return "Meisje met de parel"
        case "spinoza": return "Ethica · Theologisch-politiek traktaat"
        case "erasmus": return "Lof der Zotheid · Vertaling van het Nieuwe Testament"
        case "van-gogh": return "Sterrennacht · Zonnebloemen · 2100 werken"
        case "william-orange": return "Grondlegger van de Nederlandse Republiek (1581)"
        case "huygens": return "Slingeruurwerk · Ringen van Saturnus · Titan"
        case "anne-frank": return "Het Achterhuis · 35 miljoen exemplaren"
        case "grotius": return "Grondlegger van het internationaal recht (1609)"
        case "leeuwenhoek": return "Eerste waarneming van bacteriën (1676)"
        default: return knownFor
        }
    }

    static let all: [HistoricalFigure] = [
        HistoricalFigure(
            id: "rembrandt",
            name: "Rembrandt van Rijn",
            years: "1606–1669",
            field: "Painting",
            fieldEN: "Painter",
            fieldRU: "Художник",
            shortBioEN: "The greatest Dutch master. His Night Watch (1642) in the Rijksmuseum is the most famous Dutch painting. Born in Leiden, he revolutionized portraiture and chiaroscuro technique.",
            shortBioRU: "Величайший нидерландский мастер. Его «Ночной дозор» (1642) в Рейксмюзеуме — самая известная нидерландская картина. Родился в Лейдене, революционизировал портрет и технику светотени.",
            emoji: "🎨",
            accentColor: "#F59E0B",
            imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Rembrandt_van_Rijn_-_Self-Portrait_-_Google_Art_Project.jpg?width=900",
            birthCity: "Leiden",
            deathCity: "Amsterdam",
            knownFor: "Night Watch · 600+ paintings",
            knownForRU: "Ночной дозор · 600+ картин"
        ),
        HistoricalFigure(
            id: "vermeer",
            name: "Johannes Vermeer",
            years: "1632–1675",
            field: "Painting",
            fieldEN: "Painter",
            fieldRU: "Художник",
            shortBioEN: "Master of light and domestic interiors. Girl with a Pearl Earring hangs in the Mauritshuis in Den Haag. Created only 34–36 known paintings, all priceless.",
            shortBioRU: "Мастер света и домашних интерьеров. «Девушка с жемчужной серёжкой» находится в Маурицхёйсе в Гааге. Создал всего 34–36 известных картин, каждая бесценна.",
            emoji: "💎",
            accentColor: "#60A5FA",
            imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Johannes_Vermeer_-_Girl_with_a_Pearl_Earring.jpg?width=900",
            birthCity: "Delft",
            deathCity: "Delft",
            knownFor: "Girl with a Pearl Earring",
            knownForRU: "Девушка с жемчужной серёжкой"
        ),
        HistoricalFigure(
            id: "spinoza",
            name: "Baruch Spinoza",
            years: "1632–1677",
            field: "Philosophy",
            fieldEN: "Philosopher",
            fieldRU: "Философ",
            shortBioEN: "One of the greatest rationalist philosophers. His Ethics (1677) argued that God and Nature are the same substance. Born in Amsterdam to a Portuguese-Jewish family, he was excommunicated at 23 for his radical ideas.",
            shortBioRU: "Один из величайших философов-рационалистов. Его «Этика» (1677) утверждала, что Бог и Природа — одна субстанция. Родился в Амстердаме в португальско-еврейской семье, отлучён от общины в 23 года.",
            emoji: "🧠",
            accentColor: "#8B5CF6",
            imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Spinoza.jpg?width=900",
            birthCity: "Amsterdam",
            deathCity: "Den Haag",
            knownFor: "Ethics · Theological-Political Treatise",
            knownForRU: "Этика · Богословско-политический трактат"
        ),
        HistoricalFigure(
            id: "erasmus",
            name: "Erasmus of Rotterdam",
            years: "1466–1536",
            field: "Humanism",
            fieldEN: "Humanist Scholar",
            fieldRU: "Учёный-гуманист",
            shortBioEN: "The prince of humanists. His Praise of Folly (1509) mocked church corruption and prepared the ground for the Reformation. The Erasmus Bridge in Rotterdam is named after him.",
            shortBioRU: "Принц гуманистов. Его «Похвала глупости» (1509) высмеивала церковную коррупцию и подготовила почву для Реформации. Мост Эразма в Роттердаме назван в его честь.",
            emoji: "📚",
            accentColor: "#F97316",
            imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Holbein-erasmus.jpg?width=900",
            birthCity: "Rotterdam",
            deathCity: "Basel",
            knownFor: "Praise of Folly · New Testament translation",
            knownForRU: "Похвала глупости · Перевод Нового Завета"
        ),
        HistoricalFigure(
            id: "van-gogh",
            name: "Vincent van Gogh",
            years: "1853–1890",
            field: "Painting",
            fieldEN: "Post-Impressionist Painter",
            fieldRU: "Постимпрессионист",
            shortBioEN: "The most recognized Dutch artist worldwide. Created 2,100 artworks in 10 years despite severe mental illness. The Starry Night and Sunflowers are among the world's most valuable paintings.",
            shortBioRU: "Самый узнаваемый нидерландский художник в мире. Создал 2100 работ за 10 лет, несмотря на тяжёлую болезнь. «Звёздная ночь» и «Подсолнухи» — одни из самых дорогих картин в истории.",
            emoji: "🌻",
            accentColor: "#EAB308",
            imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Vincent_van_Gogh_-_Self-Portrait_-_Google_Art_Project.jpg?width=900",
            birthCity: "Zundert",
            deathCity: "Auvers-sur-Oise",
            knownFor: "Starry Night · Sunflowers · 2100 works",
            knownForRU: "Звёздная ночь · Подсолнухи · 2100 работ"
        ),
        HistoricalFigure(
            id: "william-orange",
            name: "William of Orange",
            years: "1533–1584",
            field: "Statecraft",
            fieldEN: "Father of the Nation",
            fieldRU: "Отец нации",
            shortBioEN: "Father of the Netherlands. Led the revolt against Spanish rule and founded the Dutch Republic. Assassinated in Delft in 1584, he became the first head of state murdered by pistol in modern history.",
            shortBioRU: "Отец Нидерландов. Возглавил восстание против испанского владычества и основал Нидерландскую республику. Убит в Делфте в 1584 году — первый глава государства, застреленный из пистолета в истории.",
            emoji: "👑",
            accentColor: "#F97316",
            imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/William_I%2C_Prince_of_Orange_%28Michiel_Jansz._van_Mierevelt%29.jpg?width=900",
            birthCity: "Dillenburg",
            deathCity: "Delft",
            knownFor: "Founded the Dutch Republic (1581)",
            knownForRU: "Основал Нидерландскую республику (1581)"
        ),
        HistoricalFigure(
            id: "huygens",
            name: "Christiaan Huygens",
            years: "1629–1695",
            field: "Science",
            fieldEN: "Physicist & Astronomer",
            fieldRU: "Физик и астроном",
            shortBioEN: "Invented the pendulum clock (1656), discovered Saturn's rings and its moon Titan, and developed the wave theory of light. He was one of the most important scientists of the Scientific Revolution.",
            shortBioRU: "Изобрёл маятниковые часы (1656), открыл кольца Сатурна и его спутник Титан, разработал волновую теорию света. Один из важнейших учёных Научной революции.",
            emoji: "🔭",
            accentColor: "#22C55E",
            imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Christiaan_Huygens-painting.jpeg?width=900",
            birthCity: "Den Haag",
            deathCity: "Den Haag",
            knownFor: "Pendulum clock · Saturn's rings · Titan",
            knownForRU: "Маятниковые часы · Кольца Сатурна · Титан"
        ),
        HistoricalFigure(
            id: "anne-frank",
            name: "Anne Frank",
            years: "1929–1945",
            field: "Literature",
            fieldEN: "Diarist",
            fieldRU: "Дневник",
            shortBioEN: "Jewish girl who kept a diary while hiding in Amsterdam during Nazi occupation. Published by her father Otto after the war, her diary has sold 35 million copies in 70 languages.",
            shortBioRU: "Еврейская девочка, вёдшая дневник во время укрытия в Амстердаме при нацистской оккупации. Её дневник, опубликованный отцом Отто после войны, продан тиражом 35 миллионов в 70 языках.",
            emoji: "📔",
            accentColor: "#EF4444",
            imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Anne_Frank_passport_photo%2C_May_1942.jpg?width=900",
            birthCity: "Frankfurt",
            deathCity: "Bergen-Belsen",
            knownFor: "Diary of a Young Girl · 35M copies",
            knownForRU: "Дневник Анны Франк · 35 млн экземпляров"
        ),
        HistoricalFigure(
            id: "grotius",
            name: "Hugo Grotius",
            years: "1583–1645",
            field: "Law",
            fieldEN: "Father of International Law",
            fieldRU: "Отец международного права",
            shortBioEN: "Founded modern international law with Mare Liberum (1609), establishing freedom of the seas, and On the Law of War and Peace (1625). The International Court of Justice in Den Haag reflects his legacy.",
            shortBioRU: "Заложил основы международного права трактатом «Свободное море» (1609) и «О праве войны и мира» (1625). Международный суд ООН в Гааге — его наследие.",
            emoji: "⚖️",
            accentColor: "#60A5FA",
            imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Michiel_Jansz_van_Mierevelt_-_Hugo_Grotius.jpg?width=900",
            birthCity: "Delft",
            deathCity: "Rostock",
            knownFor: "Founded International Law (1609)",
            knownForRU: "Основал международное право (1609)"
        ),
        HistoricalFigure(
            id: "leeuwenhoek",
            name: "Antonie van Leeuwenhoek",
            years: "1632–1723",
            field: "Science",
            fieldEN: "Father of Microbiology",
            fieldRU: "Отец микробиологии",
            shortBioEN: "Delft draper who built his own microscopes and became the first person to observe bacteria (1676), protozoa, and blood cells. Self-taught, he had no formal scientific training.",
            shortBioRU: "Делфтский торговец тканями, самостоятельно изготовивший микроскопы и первым наблюдавший бактерии (1676), простейших и клетки крови. Самоучка без формального научного образования.",
            emoji: "🔬",
            accentColor: "#14B8A6",
            imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Anthonie_van_Leeuwenhoek_%281632-1723%29._Natuurkundige_te_Delft_Rijksmuseum_SK-A-957.jpeg?width=900",
            birthCity: "Delft",
            deathCity: "Delft",
            knownFor: "First to observe bacteria (1676)",
            knownForRU: "Первым наблюдал бактерии (1676)"
        )
    ]
}

private struct HistoricalFiguresSidebarSection: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var expandedFigureID: String?
    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(sectionTitle)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.28))
                .tracking(1.2)
                .padding(.horizontal, 4)

            LazyVStack(spacing: 6) {
                ForEach(HistoricalFigure.all) { figure in
                    HistoricalFigureCard(
                        figure: figure,
                        isExpanded: expandedFigureID == figure.id,
                        onToggle: {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                                expandedFigureID = expandedFigureID == figure.id ? nil : figure.id
                            }
                        }
                    )
                }
            }
        }
        .padding(.bottom, 4)
    }

    private var sectionTitle: String {
        switch lang {
        case .russian: return "🏛 ВЕЛИКИЕ НИДЕРЛАНДЦЫ"
        case .dutch: return "🏛 GROTE NEDERLANDERS"
        case .english: return "🏛 GREAT DUTCH FIGURES"
        }
    }
}

private struct HistoricalFigureCard: View {
    let figure: HistoricalFigure
    let isExpanded: Bool
    let onToggle: () -> Void
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }
    private var accent: Color { Color(hex: figure.accentColor) }

    var body: some View {
        Button {
            onToggle()
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 10) {
                    portrait

                    VStack(alignment: .leading, spacing: 3) {
                        Text(figure.name)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)

                        HStack(spacing: 4) {
                            Text(figure.years)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.white.opacity(0.35))
                            Text("·")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.white.opacity(0.20))
                            Text(figure.fieldName(lang))
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(accent.opacity(0.85))
                                .lineLimit(1)
                                .minimumScaleFactor(0.72)
                        }

                        Text(figure.knownForText(lang))
                            .font(.system(size: 10))
                            .foregroundStyle(.white.opacity(0.45))
                            .lineLimit(1)
                            .minimumScaleFactor(0.70)
                    }

                    Spacer(minLength: 6)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.25))
                }
                .padding(10)

                if isExpanded {
                    VStack(alignment: .leading, spacing: 7) {
                        Divider()
                            .background(Color.white.opacity(0.06))
                            .padding(.horizontal, 10)

                        Text(figure.shortBio(lang))
                            .font(.system(size: 11.5))
                            .foregroundStyle(.white.opacity(0.68))
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 10)

                        ViewThatFits(in: .horizontal) {
                            figureRouteRow
                            VStack(alignment: .leading, spacing: 5) {
                                Label(figure.birthCity, systemImage: "mappin.circle")
                                Label(figure.deathCity, systemImage: "cross.circle")
                            }
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.40))
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom, 10)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .background(isExpanded ? accent.opacity(0.07) : Color.white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(isExpanded ? accent.opacity(0.25) : Color.white.opacity(0.06), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
        .pressable()
    }

    private var portrait: some View {
        let resolvedImage = CanonicalPlaceImageResolver.resolveFigureThumbnail(figure: figure)
        return ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(accent.opacity(0.15))
                .frame(width: 42, height: 42)

            HistoricalFigurePortraitImage(
                figure: figure,
                resolvedImage: resolvedImage,
                accent: accent
            )
            .frame(width: 42, height: 42)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Text(figure.emoji)
                .font(.system(size: 14))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(3)
                .background(alignment: .bottomTrailing) {
                    Circle()
                        .fill(Color.black.opacity(0.45))
                        .frame(width: 20, height: 20)
                        .padding(1)
                }
        }
        .frame(width: 42, height: 42)
    }

    private var figureRouteRow: some View {
        HStack(spacing: 8) {
            Label(figure.birthCity, systemImage: "mappin.circle")
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text("→")
                .foregroundStyle(.white.opacity(0.20))
            Label(figure.deathCity, systemImage: "cross.circle")
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .font(.system(size: 10, weight: .medium))
        .foregroundStyle(.white.opacity(0.40))
    }
}

#if canImport(UIKit)
private struct HistoricalFigurePortraitImage: View {
    let figure: HistoricalFigure
    let resolvedImage: ResolvedPlaceImage
    let accent: Color

    @StateObject private var loader = DirectImageLoader()

    var body: some View {
        ZStack {
            switch loader.state {
            case .success:
                if let image = loader.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    symbolicFallback
                }
            case .idle, .loading:
                if resolvedImage.url != nil {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(accent.opacity(0.18))
                        .overlay(ProgressView().tint(.white.opacity(0.72)))
                } else {
                    symbolicFallback
                }
            case .failed:
                symbolicFallback
            }
        }
        .frame(width: 48, height: 48)
        .clipped()
        .runtimeImageDebugInspector(runtimeDebugInfo)
        .task(id: resolvedImage.urlString) {
            guard let urlString = resolvedImage.urlString else { return }
            loader.load(
                urlString,
                targetWidth: 160,
                debugContext: resolvedImage.debugContext(
                    screen: "Right menu historical figures",
                    entityType: "figure",
                    entityName: figure.name
                )
            )
        }
    }

    private var runtimeDebugInfo: RuntimeImageDebugInfo {
        RuntimeImageDebugInfo(
            screen: "Right menu historical figures",
            entityName: figure.name,
            entityType: "figure",
            requestedURL: resolvedImage.urlString ?? "",
            resolvedURL: loader.resolvedURLString ?? (resolvedImage.urlString == nil ? "symbolic-fallback" : "generated-fallback"),
            registrySource: resolvedImage.sourceRegistry,
            fallbackLevel: loader.resolvedFallbackLevel.isEmpty ? resolvedImage.fallbackLevel.rawValue : loader.resolvedFallbackLevel,
            cacheKey: loader.resolvedCacheKey.isEmpty ? resolvedImage.cacheKey : loader.resolvedCacheKey,
            modelID: resolvedImage.modelID,
            cacheHit: loader.resolvedFromCache
        )
    }

    private var symbolicFallback: some View {
        ZStack {
            LinearGradient(
                colors: [
                    accent.opacity(0.46),
                    AppColors.graphite.opacity(0.92)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image(systemName: resolvedImage.fallbackSymbolName ?? "person.crop.square.fill")
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(.white.opacity(0.82))
        }
    }
}
#else
private struct HistoricalFigurePortraitImage: View {
    let figure: HistoricalFigure
    let resolvedImage: ResolvedPlaceImage
    let accent: Color

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    accent.opacity(0.46),
                    AppColors.graphite.opacity(0.92)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image(systemName: resolvedImage.fallbackSymbolName ?? "person.crop.square.fill")
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(.white.opacity(0.82))
        }
        .frame(width: 48, height: 48)
        .clipped()
    }
}
#endif

private struct RightSideMenuOverlay: View {
    let selectedTab: AppTab
    let activeDestination: AppDestination?
    let sections: [SideMenuSection]
    let onClose: () -> Void
    let onSelect: (SideMenuItemModel) -> Void
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var tabRouter: TabRouter
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @State private var searchText = ""
    @State private var heroSeed = Int.random(in: 0...10_000)

    private var lang: AppLanguage { languageManager.appLanguage }
    private var currentCitySpotlight: CitySpotlightData? {
        ProvinceCatalog.citySpotlight(matching: appState.selectedCity)
    }
    private var heroLandmark: AppImageAsset {
        SideMenuLandmarkRegistry.hero(for: appState.selectedCity, rotationSeed: heroSeed)
    }
    private var visibleSections: [SideMenuSection] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return sections.compactMap { section in
            let visibleItems = section.items.filter { item in
                guard isMenuItemVisibleForPersona(item) else { return false }
                guard !query.isEmpty else { return true }
                return item.title(lang).lowercased().contains(query)
                    || (item.subtitleKey.map { L10n.t($0, lang).lowercased().contains(query) } ?? false)
                    || section.title(lang).lowercased().contains(query)
            }
            guard !visibleItems.isEmpty else { return nil }
            return SideMenuSection(id: section.id, titleKey: section.titleKey, items: visibleItems)
        }
    }
    private var visibleMenuItems: [SideMenuItemModel] {
        visibleSections.flatMap(\.items)
    }

    private func isDestinationVisible(_ destination: MenuDestination) -> Bool {
        guard let appDestination = destination.appDestination else { return true }
        return RelatedContentEngine.isVisible(appDestination, for: appState.selectedUserStatus?.personaTag)
    }

    private func isMenuItemVisibleForPersona(_ item: SideMenuItemModel) -> Bool {
        guard item.isVisible else { return false }
        return isDestinationVisible(item.destination)
    }
    private var guideMenuIDs: [String] {
        [
            "history", "language", "knm", "law", "documents", "work", "transport",
            "healthcare", "emergencyGuide", "police", "municipality", "socialService",
            "socialSupport", "lgbtq", "ukraineSupport", "refugees",
            "integration", "finance", "fines", "culture", "placesToVisit",
            "guides"
        ]
    }
    private var systemMenuIDs: [String] {
        ["feedback", "settings"]
    }
    private var closeLabel: String {
        L10n.t("accessibility.closeMenu", lang)
    }
    private var openCityLabel: String {
        L10n.t("sideMenu.openCityPage", lang)
    }
    private var changeCityLabel: String {
        L10n.t("sideMenu.changeCity", lang)
    }
    private var guideGroupTitle: String {
        switch lang {
        case .russian: return "Гид"
        case .dutch: return "Gids"
        case .english: return "Guide"
        }
    }
    private var systemGroupTitle: String {
        switch lang {
        case .russian: return "Система"
        case .dutch: return "Systeem"
        case .english: return "System"
        }
    }
    private var currentLocationTitle: String {
        switch lang {
        case .russian: return "Текущая локация"
        case .dutch: return "Huidige locatie"
        case .english: return "Current Location"
        }
    }
    private var quickAccessTitle: String {
        switch lang {
        case .russian: return "Быстрый доступ"
        case .dutch: return "Snel toegang"
        case .english: return "Quick Access"
        }
    }
    private var netherlandsGuideTitle: String {
        switch lang {
        case .russian: return "Гид по Нидерландам"
        case .dutch: return "Nederland gids"
        case .english: return "Netherlands Guide"
        }
    }
    private var lifeInNetherlandsTitle: String {
        switch lang {
        case .russian: return "Жизнь в Нидерландах"
        case .dutch: return "Leven in Nederland"
        case .english: return "Life in the Netherlands"
        }
    }
    private var supportTitle: String {
        switch lang {
        case .russian: return "Поддержка"
        case .dutch: return "Ondersteuning"
        case .english: return "Support"
        }
    }
    private var languageSectionTitle: String {
        switch lang {
        case .russian: return "Язык"
        case .dutch: return "Taal"
        case .english: return "Language"
        }
    }

    var body: some View {
        GeometryReader { proxy in
            let width = min(proxy.size.width * 0.92, 460)
            ZStack(alignment: .trailing) {
                Button(action: onClose) {
                    Color.black.opacity(0.55)
                        .ignoresSafeArea()
                }
                .buttonStyle(.plain)
                .accessibilityLabel(closeLabel)
                .accessibilityIdentifier("rightMenu.overlay")

                panel(
                    width: width,
                    safeAreaTop: proxy.safeAreaInsets.top,
                    safeAreaBottom: proxy.safeAreaInsets.bottom
                )
                    .frame(width: width)
                    .frame(maxHeight: .infinity)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .accessibilityIdentifier("rightMenu.panel")
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }

    private func panel(width: CGFloat, safeAreaTop: CGFloat, safeAreaBottom: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        Color.clear
                            .frame(height: 0)
                            .id("rightMenuTop")
                        dashboardContent
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, max(18, safeAreaTop + 14))
                    .padding(.bottom, sideMenuBottomContentReserve(safeAreaBottom: safeAreaBottom))
                }
                .nlScrollDismissesKeyboardImmediately()
                .transaction { transaction in
                    transaction.animation = nil
                }
                .onReceive(tabRouter.moreScrollTop) { _ in
                    withAnimation(.easeOut(duration: 0.22)) {
                        proxy.scrollTo("rightMenuTop", anchor: .top)
                    }
                }
            }
        }
        .background {
            ZStack {
                Color(red: 8 / 255, green: 14 / 255, blue: 28 / 255)
                RadialGradient(
                    colors: [AppColors.dutchOrange.opacity(0.06), .clear],
                    center: UnitPoint(x: 1.1, y: 0.05),
                    startRadius: 0,
                    endRadius: 280
                )
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.03),
                        Color.clear,
                        Color.black.opacity(0.18)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 8,
                    bottomLeadingRadius: 8,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 0,
                    style: .continuous
                )
            )
        }
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.34), cityPrimaryAccent.opacity(0.30), citySecondaryAccent.opacity(0.20), Color.white.opacity(0.08)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 1)
        }
        .shadow(color: Color.black.opacity(0.50), radius: 40, x: -10, y: 0)
        .onAppear {
            heroSeed = Int.random(in: 0...10_000)
        }
    }

    private func sideMenuBottomContentReserve(safeAreaBottom: CGFloat) -> CGFloat {
        FloatingTabBarMetrics.rootContentInset
            + safeAreaBottom
            + AppLayout.bottomNavReserveExtra
    }

    private var dashboardContent: some View {
        VStack(alignment: .leading, spacing: 18) {
            premiumSidebarHeader
            NLStatsBar()
                .accessibilityIdentifier("rightMenu.stats")
            SidebarCitiesSection()
            HistoricalFiguresSidebarSection()
            premiumSidebarSection(title: localizedText(en: "Main Sections", nl: "Hoofdsecties", ru: "Основные разделы"), items: premiumLifeEssentialItems)
            premiumSidebarSection(title: localizedText(en: "Official", nl: "Officieel", ru: "Официальное"), items: premiumOfficialItems)
            premiumSidebarSection(title: localizedText(en: "Community", nl: "Gemeenschap", ru: "Сообщество"), items: premiumCommunityItems)
            premiumSidebarSection(title: localizedText(en: "Netherlands", nl: "Nederland", ru: "Нидерланды"), items: netherlandsGuideItems)
            premiumSidebarFooter
        }
    }

    private var premiumSidebarHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    VStack(spacing: 0) {
                        Color(hex: "#AE1C28")
                        Color.white
                        Color(hex: "#21468B")
                    }
                    .frame(width: 28, height: 18)
                    .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .strokeBorder(.white.opacity(0.2), lineWidth: 0.5)
                    )

                    Text(localizedText(en: "Kingdom of the Netherlands", nl: "Koninkrijk der Nederlanden", ru: "Королевство Нидерланды"))
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#2DD4BF"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }

                Text(localizedText(en: "YouNew Guide", nl: "YouNew gids", ru: "Гид YouNew"))
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                Text("📍 \(cityDisplayName) · \(provinceDisplayName)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#F97316"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            Spacer(minLength: 12)

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white.opacity(0.62))
                    .frame(width: 32, height: 32)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Circle())
            }
            .buttonStyle(AppPressableButtonStyle())
            .accessibilityLabel(closeLabel)
            .accessibilityIdentifier("rightMenu.close")
        }
        .padding(.top, 10)
        .padding(.horizontal, 6)
    }

    private var premiumLiveWidgets: some View {
        HStack(spacing: 10) {
            premiumMiniWidget(icon: "cloud.sun.fill", iconColor: AppColors.warning, value: localizedText(en: "Forecast", nl: "Weer", ru: "Прогноз"), caption: localizedText(en: "Verify before travel", nl: "Controleer voor vertrek", ru: "Проверьте перед выходом"))
            premiumMiniWidget(icon: "clock.fill", iconColor: AppColors.dutchOrange, value: sideMenuTime, caption: localizedText(en: "Netherlands time", nl: "Nederlandse tijd", ru: "Время Нидерландов"))
        }
    }

    private func premiumMiniWidget(icon: String, iconColor: Color, value: String, caption: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(iconColor)
            Text(value)
                .font(.system(size: value.count > 8 ? 13 : 20, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text(caption)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.45))
                .lineLimit(1)
                .minimumScaleFactor(0.70)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 17 / 255, green: 28 / 255, blue: 46 / 255))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Color.white.opacity(0.07), lineWidth: 0.5))
    }

    private var premiumEmergencyBanner: some View {
        Button {
            onSelect(SideMenuItemModel(id: "dashboard-emergency", titleKey: "sideMenu.emergency", systemIcon: "phone.fill", destination: .emergency, tint: AppColors.error))
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(AppColors.error)
                    .clipShape(Circle())
                    .shadow(color: AppColors.error.opacity(0.40), radius: 8)

                VStack(alignment: .leading, spacing: 1) {
                    Text("112")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(AppColors.error)
                    Text(localizedText(en: "Emergency", nl: "Noodgeval", ru: "Экстренно"))
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(AppColors.error.opacity(0.72))
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppColors.error.opacity(0.60))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(AppColors.error.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(AppColors.error.opacity(0.20), lineWidth: 0.5))
        }
        .buttonStyle(AppPressableButtonStyle())
    }

    private func premiumSidebarSection(title: String, items: [SideMenuItemModel]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Capsule()
                    .fill(AppColors.dutchOrange.opacity(0.70))
                    .frame(width: 2, height: 10)
                Text(title.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.48))
                    .tracking(1.2)
            }
            .padding(.horizontal, 6)
            .padding(.bottom, 2)

            menuRows(items: items)
        }
    }

    private var premiumSidebarFooter: some View {
        HStack(spacing: 10) {
            premiumFooterButton(itemFromMenu(id: "feedback", fallback: dashboardItem(id: "feedback", title: languageMap(ru: "Отзыв", nl: "Feedback", en: "Feedback"), icon: "star.fill", destination: .feedback, tint: AppColors.dutchOrange), tint: AppColors.dutchOrange))
            premiumFooterButton(itemFromMenu(id: "settings", fallback: dashboardItem(id: "settings", title: languageMap(ru: "Настройки", nl: "Instellingen", en: "Settings"), icon: "gearshape.fill", destination: .settings, tint: AppColors.textSecondary), tint: AppColors.textSecondary))
            premiumFooterButton(dashboardItem(id: "about", title: languageMap(ru: "О нас", nl: "Over", en: "About"), icon: "info.circle.fill", destination: .about, tint: AppColors.softBlue))
        }
        .padding(.top, 2)
        .padding(.bottom, 18)
    }

    private func premiumFooterButton(_ item: SideMenuItemModel) -> some View {
        Button {
            onSelect(item)
        } label: {
            VStack(spacing: 4) {
                Image(systemName: item.systemIcon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(item.tint)
                Text(item.title(lang))
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.42))
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(AppPressableButtonStyle())
    }

    private var cityDisplayName: String {
        currentCitySpotlight?.city.localizedName(lang) ?? appState.selectedCity
    }

    private var provinceDisplayName: String {
        currentCitySpotlight?.province.localizedName(lang) ?? localizedText(en: "South Holland", nl: "Zuid-Holland", ru: "Южная Голландия")
    }

    private var cityTagline: String {
        switch normalizedCityName {
        case let city where city.contains("amsterdam"):
            return localizedText(en: "Canal capital and neighbourhood hub", nl: "Grachtenhoofdstad en buurtcentrum", ru: "Столица каналов и районов")
        case let city where city.contains("rotterdam"):
            return localizedText(en: "Modern port city on the Maas", nl: "Moderne havenstad aan de Maas", ru: "Современный портовый город на Маасе")
        case let city where city.contains("hague") || city.contains("den haag"):
            return localizedText(en: "Royal city of government and coast", nl: "Koninklijke stad van bestuur en kust", ru: "Королевский город власти и побережья")
        default:
            return localizedText(en: "Historic university city", nl: "Historische universiteitsstad", ru: "Исторический университетский город")
        }
    }

    private var normalizedCityName: String {
        appState.selectedCity.lowercased()
    }

    private var cityPrimaryAccent: Color {
        switch normalizedCityName {
        case let city where city.contains("amsterdam"):
            return AppColors.dutchOrange
        case let city where city.contains("rotterdam"):
            return AppColors.routeLine
        case let city where city.contains("hague") || city.contains("den haag"):
            return Color(red: 61 / 255, green: 133 / 255, blue: 255 / 255)
        default:
            return Color(red: 67 / 255, green: 166 / 255, blue: 230 / 255)
        }
    }

    private var citySecondaryAccent: Color {
        switch normalizedCityName {
        case let city where city.contains("amsterdam"):
            return AppColors.navyDeep
        case let city where city.contains("rotterdam"):
            return Color(red: 128 / 255, green: 151 / 255, blue: 174 / 255)
        case let city where city.contains("hague") || city.contains("den haag"):
            return AppColors.cyanGlow
        default:
            return Color(red: 224 / 255, green: 176 / 255, blue: 72 / 255)
        }
    }

    private var cityHeroBlock: some View {
        ZStack(alignment: .bottomLeading) {
            SideMenuHeroImageView(landmark: heroLandmark)
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            LinearGradient(
                colors: [
                    Color.black.opacity(0.08),
                    AppColors.navyDeep.opacity(0.36),
                    Color.black.opacity(0.86)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(cityDisplayName)
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.60)
                        Text(provinceDisplayName)
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundStyle(citySecondaryAccent)
                            .lineLimit(1)
                    }

                    Spacer(minLength: 8)

                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .black))
                            .foregroundStyle(.white)
                            .frame(width: AppIcons.Metrics.minimumTouchTarget, height: AppIcons.Metrics.minimumTouchTarget)
                            .background(Color.black.opacity(0.34))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.18), lineWidth: 0.8))
                    }
                    .buttonStyle(AppPressableButtonStyle())
                    .accessibilityLabel(closeLabel)
                    .accessibilityIdentifier("rightMenu.close")
                }

                Text(cityTagline)
                    .font(.system(size: 19, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.76)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    cityHeroMetric(title: weatherLabel, value: localizedText(en: "Check forecast", nl: "Check weer", ru: "Проверьте прогноз"), symbol: "cloud.sun.fill")
                    cityHeroMetric(title: localizedText(en: "Current time", nl: "Huidige tijd", ru: "Текущее время"), value: sideMenuTime, symbol: "clock.fill")
                    cityHeroMetric(title: localizedText(en: "Population", nl: "Inwoners", ru: "Население"), value: cityPopulationValue, symbol: "person.3.fill")
                    cityHeroMetric(title: quickAccessTitle, value: "4", symbol: "bolt.fill")
                }
            }
            .padding(18)
        }
        .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300, alignment: .bottomLeading)
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(LinearGradient(colors: [Color.white.opacity(0.28), cityPrimaryAccent.opacity(0.22), citySecondaryAccent.opacity(0.18)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 0.9)
        }
        .accessibilityIdentifier("rightMenu.cityHero")
    }

    private func cityHeroMetric(title: String, value: String, symbol: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(citySecondaryAccent)
                .frame(width: 24, height: 24)
                .background(Color.white.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.58))
                    .textCase(.uppercase)
                    .lineLimit(1)
                    .minimumScaleFactor(0.64)
                Text(value)
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)
            }
        }
        .padding(9)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.28))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var cityPhotoCarousel: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(localizedText(en: "Leiden Gallery", nl: "Leiden Galerij", ru: "Галерея Лейдена"))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(cityGalleryItems) { item in
                        cityGalleryCard(item)
                    }
                }
                .padding(.horizontal, 2)
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
        }
    }

    private var dailyCityBriefSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(localizedText(en: "Today in \(cityDisplayName)", nl: "Vandaag in \(cityDisplayName)", ru: "Сегодня в \(cityDisplayName)"))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                infoTile(
                    title: weatherLabel,
                    value: localizedText(en: "Check official forecast", nl: "Controleer officiële verwachting", ru: "Проверьте официальный прогноз"),
                    symbol: "cloud.sun.fill",
                    tint: AppColors.warning
                )
                infoTile(
                    title: localizedText(en: "Phrase of the day", nl: "Zin van de dag", ru: "Фраза дня"),
                    value: dailyDutchPhrase.0,
                    symbol: "text.bubble.fill",
                    tint: AppColors.dutchOrange
                )
                infoTile(
                    title: localizedText(en: "Next holiday", nl: "Volgende feestdag", ru: "Следующий праздник"),
                    value: nextDutchHolidayInfo().0,
                    symbol: "calendar",
                    tint: AppColors.cyanGlow
                )
                infoTile(
                    title: localizedText(en: "Next step", nl: "Volgende stap", ru: "Следующий шаг"),
                    value: nextMenuStep,
                    symbol: "checklist.checked",
                    tint: AppColors.emerald
                )
            }
        }
    }

    private var cityGalleryItems: [CitySidebarGalleryItem] {
        let leiden = SideMenuLandmarkRegistry.image(for: "Leiden") ?? heroLandmark
        let windmill = SideMenuLandmarkRegistry.images.first { $0.id == "side-menu-kinderdijk-windmills" } ?? leiden
        let museum = SideMenuLandmarkRegistry.images.first { $0.id == "side-menu-amsterdam-rijksmuseum" } ?? leiden

        return [
            CitySidebarGalleryItem(id: "canals", title: localizedText(en: "Canals", nl: "Grachten", ru: "Каналы"), subtitle: localizedText(en: "Old centre", nl: "Binnenstad", ru: "Старый центр"), symbol: "water.waves", asset: leiden),
            CitySidebarGalleryItem(id: "university", title: localizedText(en: "University", nl: "Universiteit", ru: "Университет"), subtitle: "1575", symbol: "graduationcap.fill", asset: leiden),
            CitySidebarGalleryItem(id: "museums", title: localizedText(en: "Museums", nl: "Musea", ru: "Музеи"), subtitle: localizedText(en: "Culture", nl: "Cultuur", ru: "Культура"), symbol: "building.columns.fill", asset: museum),
            CitySidebarGalleryItem(id: "windmill", title: localizedText(en: "Windmill", nl: "Molen", ru: "Мельница"), subtitle: localizedText(en: "Dutch landscape", nl: "Nederlands landschap", ru: "Пейзаж"), symbol: "wind", asset: windmill),
            CitySidebarGalleryItem(id: "streets", title: localizedText(en: "Historic streets", nl: "Historische straten", ru: "Исторические улицы"), subtitle: localizedText(en: "Walkable", nl: "Te voet", ru: "Пешком"), symbol: "figure.walk", asset: leiden)
        ]
    }

    private func cityGalleryCard(_ item: CitySidebarGalleryItem) -> some View {
        ZStack(alignment: .bottomLeading) {
            SideMenuHeroImageView(landmark: item.asset)
                .frame(width: 168, height: 112)
                .clipped()

            LinearGradient(colors: [.clear, Color.black.opacity(0.74)], startPoint: .top, endPoint: .bottom)

            VStack(alignment: .leading, spacing: 4) {
                Image(systemName: item.symbol)
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(citySecondaryAccent)
                Text(item.title)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(item.subtitle)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.74))
                    .lineLimit(1)
            }
            .padding(12)
        }
        .frame(width: 168, height: 112)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(Color.white.opacity(0.16), lineWidth: 0.8))
    }

    private var citySnapshotSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(localizedText(en: "City Snapshot", nl: "Stadsoverzicht", ru: "Сводка города"))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                snapshotWidget(title: localizedText(en: "Population", nl: "Inwoners", ru: "Население"), value: cityPopulationValue, symbol: "person.3.fill", tint: cityPrimaryAccent)
                snapshotWidget(title: localizedText(en: "Province", nl: "Provincie", ru: "Провинция"), value: provinceDisplayName, symbol: "map.fill", tint: citySecondaryAccent)
                snapshotWidget(title: localizedText(en: "Emergency", nl: "Noodnummer", ru: "Экстренно"), value: "112", symbol: "phone.fill", tint: AppColors.error)
                snapshotWidget(title: localizedText(en: "Municipality", nl: "Gemeente", ru: "Муниципалитет"), value: cityDisplayName, symbol: "building.columns.fill", tint: AppColors.softBlue)
                snapshotWidget(title: localizedText(en: "Train station", nl: "Station", ru: "Вокзал"), value: "\(cityDisplayName) Centraal", symbol: "tram.fill", tint: AppColors.routeLine)
                snapshotWidget(title: localizedText(en: "Hospital", nl: "Ziekenhuis", ru: "Больница"), value: cityHospitalName, symbol: "cross.case.fill", tint: AppColors.emerald)
            }
        }
    }

    private func snapshotWidget(title: String, value: String, symbol: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(tint)
                .frame(width: 30, height: 30)
                .background(tint.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
            Text(title)
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(AppColors.textTertiary)
                .textCase(.uppercase)
                .lineLimit(1)
                .minimumScaleFactor(0.62)
            Text(value)
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.70)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 108, alignment: .topLeading)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 0.7))
    }

    private var importantActionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(localizedText(en: "Most Important Actions", nl: "Belangrijkste acties", ru: "Главные действия"))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                primaryCityAction(title: localizedText(en: "Registration", nl: "Registratie", ru: "Регистрация"), symbol: "person.text.rectangle.fill", destination: .firstSteps(section: .municipalityRegistration), tint: cityPrimaryAccent)
                primaryCityAction(title: localizedText(en: "Healthcare", nl: "Zorg", ru: "Медицина"), symbol: "cross.case.fill", destination: .firstSteps(section: .healthcareBasics), tint: AppColors.emerald)
                primaryCityAction(title: localizedText(en: "Transport", nl: "Vervoer", ru: "Транспорт"), symbol: "tram.fill", destination: .firstSteps(section: .transportBasics), tint: AppColors.routeLine)
                primaryCityAction(title: localizedText(en: "Emergency", nl: "Noodgeval", ru: "Экстренно"), symbol: "phone.fill", destination: .emergency, tint: AppColors.error)
            }
        }
    }

    private func primaryCityAction(title: String, symbol: String, destination: MenuDestination, tint: Color) -> some View {
        Button {
            onSelect(SideMenuItemModel(id: "primary-\(title)", titleKey: "sideMenu.title", titleOverride: languageMap(ru: title, nl: title, en: title), systemIcon: symbol, destination: destination, tint: tint))
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: symbol)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(tint)
                    .frame(width: 42, height: 42)
                    .background(tint.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                Text(title)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 116, alignment: .topLeading)
            .background(
                LinearGradient(colors: [tint.opacity(0.14), Color.white.opacity(0.045)], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(tint.opacity(0.18), lineWidth: 0.8))
        }
        .buttonStyle(AppPressableButtonStyle())
    }

    private var interactiveCityStrip: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(localizedText(en: "Today in \(cityDisplayName)", nl: "Vandaag in \(cityDisplayName)", ru: "Сегодня в \(cityDisplayName)"))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                infoTile(title: weatherLabel, value: localizedText(en: "Check official forecast", nl: "Controleer officiële verwachting", ru: "Проверьте официальный прогноз"), symbol: "cloud.sun.fill", tint: AppColors.warning)
                infoTile(title: localizedText(en: "Current city", nl: "Huidige stad", ru: "Текущий город"), value: cityDisplayName, symbol: "location.fill", tint: cityPrimaryAccent)
                infoTile(title: localizedText(en: "Phrase of the day", nl: "Zin van de dag", ru: "Фраза дня"), value: dailyDutchPhrase.0, symbol: "text.bubble.fill", tint: AppColors.dutchOrange)
                infoTile(title: localizedText(en: "Dutch word", nl: "Nederlands woord", ru: "Слово дня"), value: dailyDutchWord, symbol: "textformat.abc", tint: citySecondaryAccent)
                infoTile(title: localizedText(en: "Holiday", nl: "Feestdag", ru: "Праздник"), value: nextDutchHolidayInfo().0, symbol: "calendar", tint: AppColors.cyanGlow)
                infoTile(title: localizedText(en: "Next task", nl: "Volgende taak", ru: "Следующая задача"), value: nextMenuStep, symbol: "checklist.checked", tint: AppColors.emerald)
            }

            Button {
                onSelect(SideMenuItemModel(id: "dashboard-journey", titleKey: "sideMenu.firstSteps", systemIcon: "checklist", destination: .firstSteps(section: nil), tint: cityPrimaryAccent))
            } label: {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(journeyLabel)
                            .font(.system(size: 15, weight: .black, design: .rounded))
                            .foregroundStyle(AppColors.textPrimary)
                        Spacer()
                        Text("\(completedMenuSteps)/\(totalMenuSteps)")
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundStyle(citySecondaryAccent)
                    }
                    ProgressView(value: menuProgress)
                        .tint(citySecondaryAccent)
                }
                .padding(13)
                .background(cityPrimaryAccent.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(citySecondaryAccent.opacity(0.18), lineWidth: 0.8))
            }
            .buttonStyle(AppPressableButtonStyle())
        }
    }

    private func infoTile(title: String, value: String, symbol: String, tint: Color) -> some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: symbol)
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
                .background(tint.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(AppColors.textTertiary)
                    .textCase(.uppercase)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
                Text(value)
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.70)
            }
        }
        .padding(11)
        .frame(maxWidth: .infinity, minHeight: 76, alignment: .topLeading)
        .background(Color.white.opacity(0.050))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(Color.white.opacity(0.075), lineWidth: 0.7))
    }

    private var groupedCitySections: some View {
        VStack(alignment: .leading, spacing: 14) {
            cityMenuGroup(title: localizedText(en: "Learn", nl: "Leren", ru: "Учиться"), items: learnItems, tint: citySecondaryAccent)
            cityMenuGroup(title: localizedText(en: "Live", nl: "Leven", ru: "Жить"), items: liveItems, tint: cityPrimaryAccent)
            cityMenuGroup(title: supportTitle, items: supportItems, tint: AppColors.emerald)
            cityMenuGroup(title: localizedText(en: "Personal", nl: "Persoonlijk", ru: "Личное"), items: personalItems, tint: AppColors.softBlue)
        }
    }

    private var learnItems: [SideMenuItemModel] {
        [
            itemFromMenu(id: "history", fallback: dashboardItem(id: "history", title: languageMap(ru: "История", nl: "Geschiedenis", en: "History"), icon: "clock.arrow.circlepath", destination: .historyNetherlands, tint: citySecondaryAccent), tint: citySecondaryAccent),
            itemFromMenu(id: "culture", fallback: dashboardItem(id: "culture", title: languageMap(ru: "Культура", nl: "Cultuur", en: "Culture"), icon: "theatermasks.fill", destination: .cultureAttractions, tint: citySecondaryAccent), tint: citySecondaryAccent),
            itemFromMenu(id: "language", fallback: dashboardItem(id: "language", title: languageMap(ru: "Язык", nl: "Taal", en: "Language"), icon: "text.book.closed.fill", destination: .languageHub, tint: citySecondaryAccent), tint: citySecondaryAccent),
            itemFromMenu(id: "knm", fallback: dashboardItem(id: "knm", title: languageMap(ru: "KNM", nl: "KNM", en: "KNM"), icon: "graduationcap.fill", destination: .knm, tint: citySecondaryAccent), tint: citySecondaryAccent),
            itemFromMenu(id: "placesToVisit", fallback: dashboardItem(id: "placesToVisit", title: languageMap(ru: "Места", nl: "Plaatsen", en: "Places"), icon: "mappin.and.ellipse", destination: .placesToVisit, tint: citySecondaryAccent), tint: citySecondaryAccent)
        ]
    }

    private var liveItems: [SideMenuItemModel] {
        [
            dashboardItem(id: "life-registration", title: languageMap(ru: "Регистрация", nl: "Registratie", en: "Registration"), icon: "person.text.rectangle.fill", destination: .firstSteps(section: .municipalityRegistration), tint: cityPrimaryAccent),
            itemFromMenu(id: "municipality", fallback: dashboardItem(id: "municipality", title: languageMap(ru: "Муниципалитет", nl: "Gemeente", en: "Municipality"), icon: "building.columns.fill", destination: .governmentHub, tint: cityPrimaryAccent), tint: cityPrimaryAccent),
            itemFromMenu(id: "documents", fallback: dashboardItem(id: "documents", title: languageMap(ru: "Документы и DigiD", nl: "Documenten & DigiD", en: "Documents & DigiD"), icon: "doc.text.fill", destination: .journeyDocuments, tint: cityPrimaryAccent), tint: cityPrimaryAccent),
            itemFromMenu(id: "healthcare", fallback: dashboardItem(id: "healthcare", title: languageMap(ru: "Медицина", nl: "Zorg", en: "Healthcare"), icon: "cross.case.fill", destination: .firstSteps(section: .healthcareBasics), tint: cityPrimaryAccent), tint: cityPrimaryAccent),
            itemFromMenu(id: "transport", fallback: dashboardItem(id: "transport", title: languageMap(ru: "Транспорт", nl: "Vervoer", en: "Transport"), icon: "tram.fill", destination: .firstSteps(section: .transportBasics), tint: cityPrimaryAccent), tint: cityPrimaryAccent),
            itemFromMenu(id: "police", fallback: dashboardItem(id: "police", title: languageMap(ru: "Полиция", nl: "Politie", en: "Police"), icon: "shield.fill", destination: .police, tint: cityPrimaryAccent), tint: cityPrimaryAccent),
            itemFromMenu(id: "law", fallback: dashboardItem(id: "law", title: languageMap(ru: "Право", nl: "Recht", en: "Law"), icon: "building.columns.fill", destination: .governmentHub, tint: cityPrimaryAccent), tint: cityPrimaryAccent),
            itemFromMenu(id: "finance", fallback: dashboardItem(id: "finance", title: languageMap(ru: "Финансы", nl: "Financiën", en: "Finance"), icon: "creditcard.fill", destination: .firstSteps(section: .bankingBasics), tint: cityPrimaryAccent), tint: cityPrimaryAccent),
            itemFromMenu(id: "fines", fallback: dashboardItem(id: "fines", title: languageMap(ru: "Штрафы", nl: "Boetes", en: "Fines"), icon: "exclamationmark.triangle.fill", destination: .fines, tint: cityPrimaryAccent), tint: cityPrimaryAccent)
        ]
    }

    private var personalItems: [SideMenuItemModel] {
        [
            dashboardItem(id: "personal-bookmarks", title: languageMap(ru: "Закладки", nl: "Bladwijzers", en: "Bookmarks"), icon: "bookmark.fill", destination: .saved, tint: AppColors.softBlue),
            dashboardItem(id: "personal-journey", title: languageMap(ru: "Прогресс", nl: "Voortgang", en: "Journey progress"), icon: "checklist.checked", destination: .firstSteps(section: nil), tint: AppColors.softBlue),
            itemFromMenu(id: "feedback", fallback: dashboardItem(id: "feedback", title: languageMap(ru: "Отзывы", nl: "Feedback", en: "Feedback"), icon: "star.bubble.fill", destination: .feedback, tint: AppColors.softBlue), tint: AppColors.softBlue),
            itemFromMenu(id: "settings", fallback: dashboardItem(id: "settings", title: languageMap(ru: "Настройки", nl: "Instellingen", en: "Settings"), icon: "gearshape", destination: .settings, tint: AppColors.softBlue), tint: AppColors.softBlue)
        ]
    }

    @ViewBuilder
    private func cityMenuGroup(title: String, items: [SideMenuItemModel], tint: Color) -> some View {
        let visibleItems = items.filter(isMenuItemVisibleForPersona)
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(title)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(visibleItems) { item in
                    compactCityMenuButton(item, tint: tint)
                }
            }
        }
    }

    private func compactCityMenuButton(_ item: SideMenuItemModel, tint: Color) -> some View {
        Button {
            onSelect(item)
        } label: {
            HStack(spacing: 9) {
                Image(systemName: item.systemIcon)
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(item.tint)
                    .frame(width: 30, height: 30)
                    .background(item.tint.opacity(0.13))
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                Text(item.title(lang))
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.68)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
            }
            .padding(10)
            .frame(maxWidth: .infinity, minHeight: 58, alignment: .leading)
            .background(Color.white.opacity(0.045))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(tint.opacity(0.10), lineWidth: 0.7))
        }
        .buttonStyle(AppPressableButtonStyle())
    }

    private func sectionTitle(_ title: String) -> some View {
            Text(title)
                .font(AppTypography.captionScale.weight(.semibold))
                .foregroundStyle(AppColors.textTertiary)
                .textCase(.uppercase)
                .padding(.horizontal, 2)
    }

    private var cityPopulationValue: String {
        switch normalizedCityName {
        case let city where city.contains("amsterdam"): return "934k"
        case let city where city.contains("rotterdam"): return "671k"
        case let city where city.contains("hague") || city.contains("den haag"): return "566k"
        case let city where city.contains("utrecht"): return "374k"
        default: return "127k"
        }
    }

    private var cityHospitalName: String {
        switch normalizedCityName {
        case let city where city.contains("amsterdam"): return "Amsterdam UMC"
        case let city where city.contains("rotterdam"): return "Erasmus MC"
        case let city where city.contains("hague") || city.contains("den haag"): return "HMC"
        case let city where city.contains("utrecht"): return "UMC Utrecht"
        default: return "LUMC"
        }
    }

    private var dailyDutchPhrase: (String, String) {
        let phrases: [(String, String)] = [
            ("Goedemorgen!", localizedText(en: "Good morning!", nl: "Goedemorgen!", ru: "Доброе утро!")),
            ("Dank je wel!", localizedText(en: "Thank you!", nl: "Dank je wel!", ru: "Спасибо!")),
            ("Hoe gaat het?", localizedText(en: "How are you?", nl: "Hoe gaat het?", ru: "Как дела?")),
            ("Fijne dag!", localizedText(en: "Have a nice day!", nl: "Fijne dag!", ru: "Хорошего дня!"))
        ]
        let dayIndex = (Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1) - 1
        return phrases[dayIndex % phrases.count]
    }

    private var dailyDutchWord: String {
        let words = ["gracht", "gemeente", "fiets", "huisarts", "afspraak", "station"]
        let dayIndex = (Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1) - 1
        return words[dayIndex % words.count]
    }

    private var guideTopRows: some View {
        VStack(alignment: .leading, spacing: 12) {
            sideCompactWeatherRow
            sideCompactCityRow
            sidePanelDutchPhraseRow
            sidePanelHolidaysRow
            sideCompactBookmarks
            sideEmergencyShortcut
        }
    }

    private var fullGuideMenu: some View {
        menuGroup(title: fullGuideMenuTitle) {
            menuRows(for: visibleMenuItems.map(\.id))
        }
    }

    private var currentLocationDashboard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                if let currentCitySpotlight {
                    onSelect(SideMenuItemModel(
                        id: "dashboard-current-city",
                        titleKey: "sideMenu.cities",
                        systemIcon: "building.2.fill",
                        destination: .currentCity(province: currentCitySpotlight.province.id, city: currentCitySpotlight.city.name),
                        tint: AppColors.cyanGlow
                    ))
                } else {
                    onSelect(SideMenuItemModel(
                        id: "dashboard-current-city-map",
                        titleKey: "sideMenu.map",
                        systemIcon: AppIcons.map,
                        destination: .map,
                        tint: AppColors.cyanGlow
                    ))
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 16, weight: .black))
                        .foregroundStyle(AppColors.cyanGlow)
                        .frame(width: 38, height: 38)
                        .background(AppColors.cyanGlow.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(currentLocationTitle)
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundStyle(AppColors.textTertiary)
                            .textCase(.uppercase)
                            .tracking(0.7)
                        Text(currentCitySpotlight?.city.localizedName(lang) ?? appState.selectedCity)
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundStyle(AppColors.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                        Text(currentCitySpotlight?.province.localizedName(lang) ?? "South Holland")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.cyanGlow)
                            .lineLimit(1)
                    }

                    Spacer(minLength: 8)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(AppColors.textTertiary)
                }
                .padding(12)
                .background(Color.white.opacity(0.060))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 0.7))
            }
            .buttonStyle(AppPressableButtonStyle())

            sideCompactWeatherRow
            sidePanelDutchPhraseRow
            sidePanelHolidaysRow
        }
    }

    private var quickAccessRows: some View {
        VStack(spacing: 2) {
            menuButton(dashboardItem(
                id: "quick-bookmarks",
                title: languageMap(ru: "Закладки", nl: "Bladwijzers", en: "Bookmarks"),
                subtitle: languageMap(ru: "8 сохранённых материалов", nl: "8 opgeslagen items", en: "8 saved items"),
                icon: "bookmark.fill",
                destination: .saved,
                tint: AppColors.textSecondary
            ))
            menuButton(dashboardItem(
                id: "quick-recent",
                title: languageMap(ru: "Недавняя активность", nl: "Recente activiteit", en: "Recent Activity"),
                subtitle: languageMap(ru: recentPagePreview.joined(separator: " · "), nl: recentPagePreview.joined(separator: " · "), en: recentPagePreview.joined(separator: " · ")),
                icon: "clock.arrow.circlepath",
                destination: .informationHub,
                tint: AppColors.textSecondary
            ))
            menuButton(dashboardItem(
                id: "quick-journey",
                title: languageMap(ru: "Мой путь", nl: "Mijn route", en: "My Journey"),
                subtitle: languageMap(ru: "\(completedMenuSteps)/\(totalMenuSteps) шагов", nl: "\(completedMenuSteps)/\(totalMenuSteps) stappen", en: "\(completedMenuSteps)/\(totalMenuSteps) steps"),
                icon: "checklist.checked",
                destination: .firstSteps(section: nil),
                tint: AppColors.textSecondary
            ))
            menuButton(dashboardItem(
                id: "quick-emergency",
                title: languageMap(ru: "Экстренно 112", nl: "Noodgeval 112", en: "Emergency 112"),
                subtitle: languageMap(ru: "Полиция, скорая, пожарные", nl: "Politie, ambulance, brandweer", en: "Police, medical, fire"),
                icon: "phone.fill",
                destination: .emergency,
                tint: AppColors.error
            ))
        }
    }

    private var languageSwitcherCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(languageSectionTitle)
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(AppColors.textTertiary)
                .textCase(.uppercase)
                .tracking(0.8)
                .padding(.horizontal, 2)

            HStack(spacing: 8) {
                ForEach(AppLanguage.releasePriority) { language in
                    languageButton(language, title: languageButtonTitle(language))
                }
            }
            .padding(12)
            .background(Color.white.opacity(0.055))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 0.7))

            Text(languageReleaseSubtitle)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 2)
        }
    }

    private func languageButtonTitle(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "English"
        case .dutch: return "Nederlands"
        case .russian: return "Русский"
        }
    }

    private func languageButton(_ language: AppLanguage, title: String) -> some View {
        Button {
            withAnimation(AppAnimations.standard) {
                languageManager.appLanguage = language
            }
        } label: {
            Text(title)
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundStyle(languageManager.appLanguage == language ? AppColors.navyDeep : AppColors.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
                .frame(maxWidth: .infinity, minHeight: 34)
                .background(languageManager.appLanguage == language ? AppColors.cyanGlow : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var netherlandsGuideItems: [SideMenuItemModel] {
        [
            itemFromMenu(id: "netherlandsOverview", fallback: dashboardItem(id: "netherlandsOverview", title: languageMap(ru: "О Нидерландах", nl: "Over Nederland", en: "About the Netherlands"), subtitle: languageMap(ru: "Страна, факты, устройство", nl: "Land, feiten, bestuur", en: "Country, facts, state"), icon: "map.fill", destination: .netherlandsOverview, tint: AppColors.dutchOrange), tint: AppColors.dutchOrange),
            itemFromMenu(id: "history", fallback: dashboardItem(id: "history", title: languageMap(ru: "История Нидерландов", nl: "Geschiedenis van Nederland", en: "History of the Netherlands"), icon: "clock.arrow.circlepath", destination: .historyNetherlands, tint: AppColors.dutchOrange), tint: AppColors.dutchOrange),
            itemFromMenu(id: "culture", fallback: dashboardItem(id: "culture", title: languageMap(ru: "Культура и традиции", nl: "Cultuur & tradities", en: "Culture & Traditions"), icon: "theatermasks.fill", destination: .cultureAttractions, tint: AppColors.dutchOrange), tint: AppColors.dutchOrange),
            itemFromMenu(id: "placesToVisit", fallback: dashboardItem(id: "placesToVisit", title: languageMap(ru: "Места для посещения", nl: "Bezienswaardigheden", en: "Places to Visit"), icon: "mappin.and.ellipse", destination: .placesToVisit, tint: AppColors.dutchOrange), tint: AppColors.dutchOrange),
            itemFromMenu(id: "language", fallback: dashboardItem(id: "language", title: languageMap(ru: "Нидерландский язык", nl: "Nederlands", en: "Dutch Language"), icon: "text.book.closed.fill", destination: .languageHub, tint: AppColors.dutchOrange), tint: AppColors.dutchOrange),
            itemFromMenu(id: "knm", fallback: dashboardItem(id: "knm", title: languageMap(ru: "KNM", nl: "KNM", en: "KNM"), icon: "graduationcap.fill", destination: .knm, tint: AppColors.dutchOrange), tint: AppColors.dutchOrange)
        ]
    }

    private var premiumLifeEssentialItems: [SideMenuItemModel] {
        [
            premiumMenuItem(id: "documents", title: languageMap(ru: "Документы", nl: "Documenten", en: "Documents"), subtitle: languageMap(ru: "BSN, DigiD, ВНЖ", nl: "BSN, DigiD, vergunningen", en: "BSN, DigiD, permits"), icon: "doc.text.fill", destination: .journeyDocuments, tint: AppColors.softBlue),
            premiumMenuItem(id: "housing", title: languageMap(ru: "Жильё", nl: "Wonen", en: "Housing"), subtitle: languageMap(ru: "Аренда, покупка, коммунальные", nl: "Huur, koop, nutsvoorzieningen", en: "Rent, buy, utilities"), icon: "house.fill", destination: .firstSteps(section: .housingBasics), tint: AppColors.violet),
            premiumMenuItem(id: "work", title: languageMap(ru: "Работа", nl: "Werk", en: "Work"), subtitle: languageMap(ru: "Разрешения, зарплата, поиск", nl: "Vergunningen, loon, zoeken", en: "Permits, salary, search"), icon: "briefcase.fill", destination: .guideSection("work"), tint: AppColors.softBlue),
            premiumMenuItem(id: "transport", title: languageMap(ru: "Транспорт", nl: "Vervoer", en: "Transport"), subtitle: languageMap(ru: "OV, велосипед, парковка", nl: "OV, fiets, parkeren", en: "OV, bike, parking"), icon: "tram.fill", destination: .firstSteps(section: .transportBasics), tint: AppColors.emerald),
            premiumMenuItem(id: "healthcare", title: languageMap(ru: "Медицина", nl: "Zorg", en: "Healthcare"), subtitle: languageMap(ru: "Huisarts, страховка, аптека", nl: "Huisarts, verzekering, apotheek", en: "GP, insurance, pharmacy"), icon: "cross.case.fill", destination: .firstSteps(section: .healthcareBasics), tint: AppColors.error),
            premiumMenuItem(id: "emergencyGuide", title: languageMap(ru: "Экстренно", nl: "Noodhulp", en: "Emergency"), subtitle: languageMap(ru: "112, полиция, врач", nl: "112, politie, huisarts", en: "112, police, GP"), icon: "phone.fill", destination: .guideSection("emergency"), tint: AppColors.error)
        ]
    }

    private var premiumOfficialItems: [SideMenuItemModel] {
        [
            premiumMenuItem(id: "fines", title: languageMap(ru: "Правила и штрафы", nl: "Regels & boetes", en: "Rules & Fines"), subtitle: languageMap(ru: "Дороги, велосипед, общество", nl: "Verkeer, fiets, openbaar", en: "Traffic, cycling, public"), icon: "exclamationmark.triangle.fill", destination: .fines, tint: AppColors.warning),
            premiumMenuItem(id: "municipality", title: languageMap(ru: "Муниципалитет", nl: "Gemeente", en: "Municipality"), subtitle: languageMap(ru: "Сервисы рядом с вами", nl: "Diensten bij jou in de buurt", en: "Services near you"), icon: "building.columns.fill", destination: .firstSteps(section: .municipalityRegistration), tint: Color(red: 99 / 255, green: 102 / 255, blue: 241 / 255)),
            premiumMenuItem(id: "police", title: languageMap(ru: "Полиция", nl: "Politie", en: "Police"), subtitle: languageMap(ru: "Заявления и контакты", nl: "Melden & contacten", en: "Report & contacts"), icon: "shield.fill", destination: .police, tint: AppColors.cyanGlow),
            premiumMenuItem(id: "finance", title: languageMap(ru: "Налоги", nl: "Belasting", en: "Taxes"), subtitle: languageMap(ru: "Гид Belastingdienst", nl: "Belastingdienst-gids", en: "Belastingdienst guide"), icon: "chart.bar.fill", destination: .firstSteps(section: .bankingBasics), tint: AppColors.dutchOrange)
        ]
    }

    private var premiumCommunityItems: [SideMenuItemModel] {
        [
            premiumMenuItem(id: "integration", title: languageMap(ru: "Интеграция", nl: "Integratie", en: "Integration"), subtitle: languageMap(ru: "Язык, культура, NT2", nl: "Taal, cultuur, NT2", en: "Language, culture, NT2"), icon: "globe.europe.africa.fill", destination: .guideSection("integration"), tint: AppColors.emerald),
            premiumMenuItem(id: "lgbtq", title: languageMap(ru: "ЛГБТК+ поддержка", nl: "LGBTQ+ steun", en: "LGBTQ+ Support"), subtitle: languageMap(ru: "Права и ресурсы", nl: "Rechten & bronnen", en: "Rights & resources"), icon: "heart.fill", destination: .lgbtq, tint: Color(red: 236 / 255, green: 72 / 255, blue: 153 / 255)),
            premiumMenuItem(id: "ukraineSupport", title: languageMap(ru: "Поддержка Украины", nl: "Steun Oekraïne", en: "Ukraine Support"), subtitle: languageMap(ru: "Специальный гид", nl: "Speciale gids", en: "Dedicated guide"), icon: "heart.text.square.fill", destination: .survivalHub, tint: AppColors.softBlue),
            premiumMenuItem(id: "refugees", title: languageMap(ru: "Беженцы", nl: "Vluchtelingen", en: "Refugees"), subtitle: languageMap(ru: "COA, IND, убежище", nl: "COA, IND, asiel", en: "COA, IND, asylum"), icon: "person.2.fill", destination: .survivalHub, tint: AppColors.violet)
        ]
    }

    private func premiumMenuItem(
        id: String,
        title: [AppLanguage: String],
        subtitle: [AppLanguage: String],
        icon: String,
        destination: MenuDestination,
        tint: Color
    ) -> SideMenuItemModel {
        itemFromMenu(
            id: id,
            fallback: dashboardItem(id: id, title: title, subtitle: subtitle, icon: icon, destination: destination, tint: tint),
            tint: tint
        )
    }

    private var lifeInNetherlandsItems: [SideMenuItemModel] {
        [
            dashboardItem(id: "life-registration", title: languageMap(ru: "Регистрация", nl: "Registratie", en: "Registration"), icon: "person.text.rectangle.fill", destination: .firstSteps(section: .municipalityRegistration), tint: AppColors.softBlue),
            itemFromMenu(id: "municipality", fallback: dashboardItem(id: "municipality", title: languageMap(ru: "Муниципалитет", nl: "Gemeente", en: "Municipality"), icon: "building.columns.fill", destination: .governmentHub, tint: AppColors.softBlue), tint: AppColors.softBlue),
            itemFromMenu(id: "documents", fallback: dashboardItem(id: "documents", title: languageMap(ru: "Документы и DigiD", nl: "Documenten & DigiD", en: "Documents & DigiD"), icon: "doc.text.fill", destination: .journeyDocuments, tint: AppColors.softBlue), tint: AppColors.softBlue),
            itemFromMenu(id: "healthcare", fallback: dashboardItem(id: "healthcare", title: languageMap(ru: "Медицина", nl: "Zorg", en: "Healthcare"), icon: "cross.case.fill", destination: .firstSteps(section: .healthcareBasics), tint: AppColors.softBlue), tint: AppColors.softBlue),
            itemFromMenu(id: "work", fallback: dashboardItem(id: "work", title: languageMap(ru: "Работа", nl: "Werk", en: "Work"), icon: "briefcase.fill", destination: .guideSection("work"), tint: AppColors.softBlue), tint: AppColors.softBlue),
            itemFromMenu(id: "transport", fallback: dashboardItem(id: "transport", title: languageMap(ru: "Транспорт", nl: "Vervoer", en: "Transport"), icon: "tram.fill", destination: .firstSteps(section: .transportBasics), tint: AppColors.softBlue), tint: AppColors.softBlue),
            itemFromMenu(id: "emergencyGuide", fallback: dashboardItem(id: "emergencyGuide", title: languageMap(ru: "Экстренно", nl: "Noodhulp", en: "Emergency"), icon: "phone.fill", destination: .guideSection("emergency"), tint: AppColors.error), tint: AppColors.error),
            itemFromMenu(id: "police", fallback: dashboardItem(id: "police", title: languageMap(ru: "Полиция", nl: "Politie", en: "Police"), icon: "shield.fill", destination: .police, tint: AppColors.softBlue), tint: AppColors.softBlue),
            itemFromMenu(id: "law", fallback: dashboardItem(id: "law", title: languageMap(ru: "Право и государство", nl: "Recht & overheid", en: "Law & Government"), icon: "building.columns.fill", destination: .governmentHub, tint: AppColors.softBlue), tint: AppColors.softBlue),
            itemFromMenu(id: "finance", fallback: dashboardItem(id: "finance", title: languageMap(ru: "Финансовый ассистент", nl: "Financiële assistent", en: "Financial Assistant"), icon: "creditcard.fill", destination: .firstSteps(section: .bankingBasics), tint: AppColors.softBlue), tint: AppColors.softBlue),
            itemFromMenu(id: "fines", fallback: dashboardItem(id: "fines", title: languageMap(ru: "Штрафы", nl: "Boetes", en: "Fines"), icon: "exclamationmark.triangle.fill", destination: .fines, tint: AppColors.softBlue), tint: AppColors.softBlue)
        ]
    }

    private var supportItems: [SideMenuItemModel] {
        [
            itemFromMenu(id: "socialService", fallback: dashboardItem(id: "socialService", title: languageMap(ru: "Социальные службы", nl: "Sociale diensten", en: "Social Services"), icon: "person.crop.circle.badge.checkmark", destination: .socialService, tint: AppColors.emerald), tint: AppColors.emerald),
            itemFromMenu(id: "socialSupport", fallback: dashboardItem(id: "socialSupport", title: languageMap(ru: "Социальная поддержка", nl: "Sociale steun", en: "Social Support"), icon: "heart.fill", destination: .emotionalSupport, tint: AppColors.emerald), tint: AppColors.emerald),
            itemFromMenu(id: "lgbtq", fallback: dashboardItem(id: "lgbtq", title: languageMap(ru: "ЛГБТК+ поддержка", nl: "LGBTQ+ steun", en: "LGBTQ+ Support"), icon: "rainbow", destination: .lgbtq, tint: AppColors.emerald), tint: AppColors.emerald),
            itemFromMenu(id: "ukraineSupport", fallback: dashboardItem(id: "ukraineSupport", title: languageMap(ru: "Поддержка Украины", nl: "Steun Oekraïne", en: "Ukraine Support"), icon: "heart.text.square.fill", destination: .survivalHub, tint: AppColors.emerald), tint: AppColors.emerald),
            itemFromMenu(id: "refugees", fallback: dashboardItem(id: "refugees", title: languageMap(ru: "Беженцы", nl: "Vluchtelingen", en: "Refugees"), icon: "figure.walk", destination: .survivalHub, tint: AppColors.emerald), tint: AppColors.emerald),
            itemFromMenu(id: "integration", fallback: dashboardItem(id: "integration", title: languageMap(ru: "Интеграция", nl: "Integratie", en: "Integration"), icon: "person.2.fill", destination: .guideSection("integration"), tint: AppColors.emerald), tint: AppColors.emerald)
        ]
    }

    private var systemItems: [SideMenuItemModel] {
        [
            itemFromMenu(id: "settings", fallback: dashboardItem(id: "settings", title: languageMap(ru: "Настройки", nl: "Instellingen", en: "Settings"), icon: "gearshape", destination: .settings, tint: AppColors.textSecondary), tint: AppColors.textSecondary),
            dashboardItem(id: "about", title: languageMap(ru: "О YouNew", nl: "Over YouNew", en: "About YouNew"), icon: "info.circle.fill", destination: .about, tint: AppColors.textSecondary)
        ]
    }

    private func itemFromMenu(id: String, fallback: SideMenuItemModel, tint: Color) -> SideMenuItemModel {
        guard let existing = visibleMenuItems.first(where: { $0.id == id }) else { return fallback }
        return SideMenuItemModel(
            id: existing.id,
            titleKey: existing.titleKey,
            titleOverride: existing.titleOverride,
            subtitleKey: existing.subtitleKey,
            subtitleOverride: existing.subtitleOverride ?? fallback.subtitleOverride,
            systemIcon: existing.systemIcon,
            destination: existing.destination,
            requiresExistingRoute: existing.requiresExistingRoute,
            isVisible: existing.isVisible,
            tint: tint
        )
    }

    private func dashboardItem(
        id: String,
        title: [AppLanguage: String],
        subtitle: [AppLanguage: String]? = nil,
        icon: String,
        destination: MenuDestination,
        tint: Color
    ) -> SideMenuItemModel {
        SideMenuItemModel(
            id: id,
            titleKey: "sideMenu.title",
            titleOverride: title,
            subtitleOverride: subtitle,
            systemIcon: icon,
            destination: destination,
            tint: tint
        )
    }

    private func languageMap(ru: String, nl: String, en: String) -> [AppLanguage: String] {
        [.russian: ru, .dutch: nl, .english: en]
    }

    private func menuGroup<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(AppColors.textTertiary)
                .textCase(.uppercase)
                .tracking(0.8)
                .padding(.horizontal, 2)

            content()
        }
    }

    private func menuRows(for ids: [String]) -> some View {
        LazyVStack(spacing: 2) {
            ForEach(visibleMenuItems.filter { ids.contains($0.id) }) { item in
                menuButton(item)
            }
        }
    }

    @ViewBuilder
    private func menuRows(items: [SideMenuItemModel]) -> some View {
        let visibleItems = items.filter(isMenuItemVisibleForPersona)
        LazyVStack(spacing: 2) {
            ForEach(visibleItems) { item in
                menuButton(item)
            }
        }
    }

    private var sideCompactCityRow: some View {
        Button {
            if let currentCitySpotlight,
               isDestinationVisible(.currentCity(province: currentCitySpotlight.province.id, city: currentCitySpotlight.city.name)) {
                onSelect(SideMenuItemModel(
                    id: "dashboard-current-city",
                    titleKey: "sideMenu.cities",
                    systemIcon: "building.2.fill",
                    destination: .currentCity(province: currentCitySpotlight.province.id, city: currentCitySpotlight.city.name),
                    tint: AppColors.cyanGlow
                ))
            } else {
                onSelect(SideMenuItemModel(id: "dashboard-map", titleKey: "sideMenu.map", systemIcon: AppIcons.map, destination: .map, tint: AppColors.routeLine))
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "location.fill")
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(AppColors.cyanGlow)
                    .frame(width: 38, height: 38)
                    .background(AppColors.cyanGlow.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(L10n.t("sideMenu.currentCity", lang))
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.textSecondary)
                    Text(currentCitySpotlight?.city.localizedName(lang) ?? appState.selectedCity)
                        .font(.system(size: 21, weight: .black, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                    Text(currentCitySpotlight?.province.localizedName(lang) ?? "Zuid-Holland")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.textTertiary)
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                Image(systemName: "map.fill")
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .buttonStyle(AppPressableButtonStyle())
    }

    private var sideCompactWeatherRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "cloud.sun.fill")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(AppColors.warning)
                .frame(width: 42, height: 42)
            Text(localizedText(en: "Forecast", nl: "Weer", ru: "Прогноз"))
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
            Spacer(minLength: 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(localizedText(en: "No live weather data", nl: "Geen live weerdata", ru: "Нет live-погоды"))
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                Text(localizedText(en: "Check official forecast", nl: "Controleer officiële verwachting", ru: "Проверьте официальный прогноз"))
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.060))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 0.7))
    }

    private func localizedText(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .russian: return ru
        case .dutch: return nl
        case .english: return en
        }
    }

    private var sideCompactBookmarks: some View {
        Button {
            onSelect(SideMenuItemModel(id: "dashboard-saved", titleKey: "sideMenu.saved", systemIcon: AppIcons.save, destination: .saved, tint: AppColors.softBlue))
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "bookmark.fill")
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(AppColors.dutchOrange)
                    .frame(width: 34, height: 34)
                    .background(AppColors.dutchOrange.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                Text(bookmarksLabel)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Text("8")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppColors.textTertiary)
            }
            .padding(12)
            .background(Color.white.opacity(0.052))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 0.7))
        }
        .buttonStyle(AppPressableButtonStyle())
    }

    private var sideEmergencyShortcut: some View {
        Button {
            onSelect(SideMenuItemModel(id: "dashboard-emergency", titleKey: "sideMenu.emergency", systemIcon: "phone.fill", destination: .emergency, tint: AppColors.error))
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(AppColors.error)
                    .frame(width: 34, height: 34)
                    .background(AppColors.error.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                Text(emergencyLabel)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Text("112")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(AppColors.error)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppColors.textTertiary)
            }
            .padding(12)
            .background(Color.white.opacity(0.052))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 0.7))
        }
        .buttonStyle(AppPressableButtonStyle())
    }

    private var oldSideCompactWeatherRowUnused: some View {
        HStack(spacing: 10) {
            SideWidgetTitle(title: weatherLabel, symbol: "cloud.sun.fill", accent: AppColors.softBlue)
            Spacer(minLength: 8)
            Text(weatherHintLabel)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.trailing)
                .minimumScaleFactor(0.78)
        }
        .padding(12)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var sideCompactProgressRow: some View {
        Button {
            onSelect(SideMenuItemModel(id: "dashboard-journey", titleKey: "sideMenu.firstSteps", systemIcon: "checklist", destination: .firstSteps(section: nil), tint: AppColors.cyanGlow))
        } label: {
            VStack(alignment: .leading, spacing: 9) {
                HStack {
                    SideWidgetTitle(title: journeyLabel, symbol: "checklist.checked", accent: AppColors.cyanGlow)
                    Spacer(minLength: 8)
                    Text("\(completedMenuSteps)/\(totalMenuSteps)")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(AppColors.cyanGlow)
                }

                ProgressView(value: menuProgress)
                    .tint(AppColors.cyanGlow)
            }
        }
        .buttonStyle(AppPressableButtonStyle())
    }

    private var sideCompactRecommendationRow: some View {
        Button {
            onSelect(SideMenuItemModel(id: "dashboard-ai", titleKey: "ai.title", systemIcon: AppIcons.assistant, destination: .help, tint: AppColors.violet))
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(AppColors.violet)
                    .frame(width: 32, height: 32)
                    .background(AppColors.violet.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(recommendedNextStepLabel)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(1)
                    Text(nextMenuStep)
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(12)
            .background(AppColors.violet.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(AppPressableButtonStyle())
    }

    private var sideCompactQuickActions: some View {
        VStack(alignment: .leading, spacing: 10) {
            SideWidgetTitle(title: L10n.t("sideMenu.quickActions", lang), symbol: "bolt.fill", accent: AppColors.dutchOrange)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                sidePillAction("BSN", destination: .firstSteps(section: .municipalityRegistration), tint: AppColors.cyanGlow)
                sidePillAction("DigiD", destination: .firstSteps(section: .digidSafety), tint: AppColors.softBlue)
                sidePillAction(doctorLabel, destination: .firstSteps(section: .findingHuisarts), tint: AppColors.emerald)
                sidePillAction(housingLabel, destination: .firstSteps(section: .housingBasics), tint: AppColors.violet)
                sidePillAction(transportLabel, destination: .map, tint: AppColors.routeLine)
                sidePillAction(localizedText(en: "Municipality", nl: "Gemeente", ru: "Муниципалитет"), destination: .currentCity(province: currentCitySpotlight?.province.id ?? "Zuid-Holland", city: currentCitySpotlight?.city.name ?? appState.selectedCity), tint: AppColors.dutchOrange)
            }
        }
    }

    private var sideCompactRecentPages: some View {
        VStack(alignment: .leading, spacing: 10) {
            SideWidgetTitle(title: recentPagesLabel, symbol: "clock.arrow.circlepath", accent: AppColors.emerald)
            ForEach(recentPagePreview, id: \.self) { item in
                HStack(spacing: 8) {
                    Circle()
                        .fill(AppColors.emerald.opacity(0.70))
                        .frame(width: 6, height: 6)
                    Text(item)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                }
            }
        }
    }

    private var sideOfficialServicesWidget: some View {
        Button {
            onSelect(SideMenuItemModel(id: "dashboard-official", titleKey: "sideMenu.officialSources", systemIcon: "checkmark.shield.fill", destination: .officialSources, tint: AppColors.success))
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(AppColors.success)
                    .frame(width: 36, height: 36)
                    .background(AppColors.success.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(officialServicesLabel)
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.78)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(officialServicesHintLabel)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(AppColors.textTertiary)
            }
            .padding(12)
            .background(AppColors.success.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(AppColors.success.opacity(0.16), lineWidth: 0.8))
        }
        .buttonStyle(AppPressableButtonStyle())
    }

    private var sidePanelDutchPhraseRow: some View {
        let phrases: [(String, String)] = [
            ("Goedemorgen!", lang == .russian ? "Доброе утро!" : lang == .dutch ? "Goedemorgen!" : "Good morning!"),
            ("Dank je wel!", lang == .russian ? "Спасибо!" : lang == .dutch ? "Dank je wel!" : "Thank you!"),
            ("Hoe gaat het?", lang == .russian ? "Как дела?" : lang == .dutch ? "Hoe gaat het?" : "How are you?"),
            ("Gezellig!", lang == .russian ? "Уютно и хорошо!" : lang == .dutch ? "Gezellig!" : "Cozy & convivial!"),
            ("Alsjeblieft!", lang == .russian ? "Пожалуйста!" : lang == .dutch ? "Alsjeblieft!" : "Here you go!"),
            ("Tot ziens!", lang == .russian ? "До свидания!" : lang == .dutch ? "Tot ziens!" : "Goodbye!"),
            ("Fijne dag!", lang == .russian ? "Хорошего дня!" : lang == .dutch ? "Fijne dag!" : "Have a nice day!"),
        ]
        let dayIndex = (Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1) - 1
        let phrase = phrases[dayIndex % phrases.count]
        let label = lang == .russian ? "Фраза дня" : lang == .dutch ? "Zin van de dag" : "Phrase of the Day"
        return HStack(spacing: 12) {
            Text("🇳🇱")
                .font(.system(size: 20))
                .frame(width: 36, height: 36)
                .background(AppColors.dutchOrange.opacity(0.16))
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(AppColors.dutchOrange)
                    .textCase(.uppercase)
                    .tracking(0.8)
                Text(phrase.0)
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                Text(phrase.1)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 4)
        }
        .padding(12)
        .background(AppColors.dutchOrange.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(AppColors.dutchOrange.opacity(0.18), lineWidth: 0.75))
    }

    private var sidePanelHolidaysRow: some View {
        let (name, icon, dateStr) = nextDutchHolidayInfo()
        let titleStr = lang == .russian ? "Праздник" : lang == .dutch ? "Feestdag" : "Holiday"
        return HStack(spacing: 12) {
            Text(icon)
                .font(.system(size: 20))
                .frame(width: 36, height: 36)
                .background(AppColors.cyanGlow.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text(titleStr)
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(AppColors.cyanGlow)
                    .textCase(.uppercase)
                    .tracking(0.8)
                Text(name)
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                Text(dateStr)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer(minLength: 4)
        }
        .padding(12)
        .background(AppColors.cyanGlow.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(AppColors.cyanGlow.opacity(0.18), lineWidth: 0.75))
    }

    private func nextDutchHolidayInfo() -> (String, String, String) {
        let entries: [(nlName: String, enName: String, month: Int, day: Int, icon: String)] = [
            ("Nieuwjaarsdag", "New Year's Day", 1, 1, "🎆"),
            ("Koningsdag", "King's Day", 4, 27, "🧡"),
            ("Bevrijdingsdag", "Liberation Day", 5, 5, "🕊️"),
            ("Eerste Kerstdag", "Christmas Day", 12, 25, "🎄"),
            ("Oud & Nieuw", "New Year's Eve", 12, 31, "🎇"),
        ]
        let cal = Calendar.current
        let now = Date()
        let currentYear = cal.component(.year, from: now)
        var best: (name: String, icon: String, date: Date)?
        for year in [currentYear, currentYear + 1] {
            for e in entries {
                var comps = DateComponents()
                comps.year = year
                comps.month = e.month
                comps.day = e.day
                guard let hDate = cal.date(from: comps), hDate >= now else { continue }
                if best.map({ hDate < $0.date }) ?? true {
                    best = (lang == .dutch ? e.nlName : e.enName, e.icon, hDate)
                }
            }
        }
        guard let h = best else { return ("Koningsdag", "🧡", "27 april") }
        let df = DateFormatter()
        df.locale = Locale(identifier: lang == .dutch ? "nl_NL" : lang == .russian ? "ru_RU" : "en_GB")
        df.dateFormat = "d MMMM"
        return (h.name, h.icon, df.string(from: h.date))
    }

    private var sideDashboardHero: some View {
        SideMenuDashboardWidget(accent: AppColors.cyanGlow, minHeight: 170) {
            ZStack(alignment: .bottomLeading) {
                SideMenuHeroImageView(landmark: heroLandmark)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                VStack(alignment: .leading, spacing: 8) {
                    Text(currentCitySpotlight?.city.localizedName(lang) ?? appState.selectedCity)
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    HStack(spacing: 8) {
                        Label(currentCitySpotlight?.province.localizedName(lang) ?? "Zuid-Holland", systemImage: "mappin.circle.fill")
                        Label(sideMenuTime, systemImage: "clock.fill")
                    }
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.82))
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                }
                .padding(14)
            }
            .frame(height: 160)
        }
    }

    private var sideQuickActionsWidget: some View {
        SideMenuDashboardWidget(accent: AppColors.dutchOrange, minHeight: 128) {
            VStack(alignment: .leading, spacing: 10) {
                SideWidgetTitle(title: L10n.t("sideMenu.quickActions", lang), symbol: "bolt.fill", accent: AppColors.dutchOrange)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    sidePillAction("BSN", destination: .firstSteps(section: .municipalityRegistration), tint: AppColors.cyanGlow)
                    sidePillAction("DigiD", destination: .firstSteps(section: .digidSafety), tint: AppColors.softBlue)
                    sidePillAction(doctorLabel, destination: .firstSteps(section: .findingHuisarts), tint: AppColors.emerald)
                    sidePillAction("Gemeente", destination: .currentCity(province: currentCitySpotlight?.province.id ?? "Zuid-Holland", city: currentCitySpotlight?.city.name ?? appState.selectedCity), tint: AppColors.dutchOrange)
                    sidePillAction(housingLabel, destination: .firstSteps(section: .housingBasics), tint: AppColors.violet)
                    sidePillAction(transportLabel, destination: .map, tint: AppColors.routeLine)
                }
            }
        }
    }

    private var sideRecommendationWidget: some View {
        Button {
            onSelect(SideMenuItemModel(id: "dashboard-ai", titleKey: "ai.title", systemIcon: AppIcons.assistant, destination: .help, tint: AppColors.violet))
        } label: {
            SideMenuDashboardWidget(accent: AppColors.violet, minHeight: 118) {
                VStack(alignment: .leading, spacing: 10) {
                    SideWidgetTitle(title: aiRecommendationsLabel, symbol: "sparkles", accent: AppColors.violet)
                    Text(recommendedNextStepLabel)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                    Text(nextMenuStep)
                        .font(.system(size: 19, weight: .black, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(4)
                        .minimumScaleFactor(0.76)
                }
            }
        }
        .buttonStyle(AppPressableButtonStyle())
    }

    private var sideJourneyWidget: some View {
        Button {
            onSelect(SideMenuItemModel(id: "dashboard-journey", titleKey: "sideMenu.firstSteps", systemIcon: "checklist", destination: .firstSteps(section: nil), tint: AppColors.cyanGlow))
        } label: {
            SideMenuDashboardWidget(accent: AppColors.cyanGlow, minHeight: 118) {
                VStack(alignment: .leading, spacing: 14) {
                    SideWidgetTitle(title: journeyLabel, symbol: "checklist.checked", accent: AppColors.cyanGlow)
                    Text("\(completedMenuSteps)/\(totalMenuSteps)")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(1)
                    ProgressView(value: menuProgress)
                        .tint(AppColors.cyanGlow)
                }
            }
        }
        .buttonStyle(AppPressableButtonStyle())
    }

    private var sideBookmarksWidget: some View {
        Button {
            onSelect(SideMenuItemModel(id: "dashboard-saved", titleKey: "sideMenu.saved", systemIcon: AppIcons.save, destination: .saved, tint: AppColors.softBlue))
        } label: {
            SideMenuDashboardWidget(accent: AppColors.softBlue, minHeight: 140) {
                VStack(alignment: .leading, spacing: 10) {
                    SideWidgetTitle(title: bookmarksLabel, symbol: "bookmark.fill", accent: AppColors.softBlue)
                    ForEach(bookmarkPreview, id: \.self) { item in
                        Text(item)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)
                    }
                }
            }
        }
        .buttonStyle(AppPressableButtonStyle())
    }

    @ViewBuilder
    private func sidePillAction(_ title: String, destination: MenuDestination, tint: Color) -> some View {
        if isDestinationVisible(destination) {
            Button {
                onSelect(SideMenuItemModel(id: "dashboard-\(title)", titleKey: "sideMenu.title", systemIcon: "circle.fill", destination: destination, tint: tint))
            } label: {
                Text(title)
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.76)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, minHeight: 46)
                    .padding(.horizontal, 6)
                    .background(tint.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(tint.opacity(0.16), lineWidth: 0.7)
                    }
                }
            .buttonStyle(AppPressableButtonStyle())
            .accessibilityLabel(title)
        }
    }

    private var completedMenuSteps: Int {
        appState.visibleChecklistItems.filter(\.isCompleted).count
    }

    private var totalMenuSteps: Int {
        appState.visibleChecklistItems.count
    }

    private var menuProgress: Double {
        guard totalMenuSteps > 0 else { return 0 }
        return min(1, max(0, Double(completedMenuSteps) / Double(totalMenuSteps)))
    }

    private var nextMenuStep: String {
        appState.prioritizedChecklist.recommended.first(where: { !$0.isCompleted })?.title(lang)
            ?? appState.visibleChecklistItems.first(where: { !$0.isCompleted })?.title(lang)
            ?? defaultNextStepLabel
    }

    private var bookmarkPreview: [String] {
        switch lang {
        case .russian: return ["BSN", "DigiD", "Huisarts"]
        case .dutch: return ["BSN", "DigiD", "Huisarts"]
        case .english: return ["BSN", "DigiD", "GP"]
        }
    }

    private var recentPagePreview: [String] {
        let recent = appState.visibleRecentlyViewedTopics().prefix(3).map { appState.displayTitle(forRecentlyViewedTopic: $0, language: lang) }
        if !recent.isEmpty { return Array(recent) }

        switch lang {
        case .russian: return ["Регистрация", "Huisarts", "Транспорт"]
        case .dutch: return ["Registratie", "Huisarts", "Vervoer"]
        case .english: return ["Registration", "GP", "Transport"]
        }
    }

    private var sideMenuTime: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "nl_NL")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }

    private var dashboardTitle: String {
        switch lang {
        case .russian: return "Гид"
        case .dutch: return "Gids"
        case .english: return "The Guide"
        }
    }

    private var fullGuideMenuTitle: String {
        switch lang {
        case .russian: return "Полное меню гида"
        case .dutch: return "Volledig gidsmenu"
        case .english: return "Full Guide Menu"
        }
    }

    private var weatherLabel: String {
        switch lang {
        case .russian: return "Погода"
        case .dutch: return "Weer"
        case .english: return "Weather"
        }
    }

    private var weatherHintLabel: String {
        switch lang {
        case .russian: return "Проверьте перед выходом"
        case .dutch: return "Check voor vertrek"
        case .english: return "Check before leaving"
        }
    }

    private var recentPagesLabel: String {
        switch lang {
        case .russian: return "Недавние"
        case .dutch: return "Recent"
        case .english: return "Recent pages"
        }
    }

    private var doctorLabel: String {
        switch lang {
        case .russian: return "Врач"
        case .dutch: return "Arts"
        case .english: return "Doctor"
        }
    }

    private var housingLabel: String {
        switch lang {
        case .russian: return "Жильё"
        case .dutch: return "Wonen"
        case .english: return "Housing"
        }
    }

    private var transportLabel: String {
        switch lang {
        case .russian: return "Транспорт"
        case .dutch: return "Vervoer"
        case .english: return "Transport"
        }
    }

    private var aiRecommendationsLabel: String {
        switch lang {
        case .russian: return "AI-рекомендации"
        case .dutch: return "AI-aanbevelingen"
        case .english: return "AI Recommendations"
        }
    }

    private var recommendedNextStepLabel: String {
        switch lang {
        case .russian: return "Рекомендуемый следующий шаг"
        case .dutch: return "Aanbevolen volgende stap"
        case .english: return "Recommended next step"
        }
    }

    private var journeyLabel: String {
        switch lang {
        case .russian: return "Мой путь"
        case .dutch: return "Mijn route"
        case .english: return "My Journey"
        }
    }

    private var bookmarksLabel: String {
        switch lang {
        case .russian: return "Закладки"
        case .dutch: return "Bladwijzers"
        case .english: return "Bookmarks"
        }
    }

    private var emergencyLabel: String {
        switch lang {
        case .russian: return "Экстренно"
        case .dutch: return "Noodgeval"
        case .english: return "Emergency"
        }
    }

    private var emergencySupportLabel: String {
        switch lang {
        case .russian: return "Полиция, скорая, пожарные, кризисная помощь"
        case .dutch: return "Politie, ambulance, brandweer, crisis"
        case .english: return "Police, medical, fire, crisis support"
        }
    }

    private var officialServicesLabel: String {
        switch lang {
        case .russian: return "Официальные сервисы"
        case .dutch: return "Officiële diensten"
        case .english: return "Official Services"
        }
    }

    private var officialServicesHintLabel: String {
        switch lang {
        case .russian: return "Проверенные источники для следующего шага"
        case .dutch: return "Gecontroleerde bronnen voor je volgende stap"
        case .english: return "Verified sources before your next step"
        }
    }

    private var defaultNextStepLabel: String {
        switch lang {
        case .russian: return "Зарегистрировать адрес"
        case .dutch: return "Adres registreren"
        case .english: return "Register your address"
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "location.north.fill")
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(AppColors.cyanGlow)
                .frame(width: 44, height: 44)
                .background(AppColors.cyanGlow.opacity(0.14))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(currentCitySpotlight?.city.localizedName(lang) ?? appState.selectedCity)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                Text(currentCitySpotlight?.province.localizedName(lang) ?? "South Holland")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(width: AppIcons.Metrics.minimumTouchTarget, height: AppIcons.Metrics.minimumTouchTarget)
                    .background(Circle().fill(Color.white.opacity(0.10)))
                    .overlay {
                        Circle().stroke(Color.white.opacity(0.14), lineWidth: 0.8)
                    }
                    .contentShape(Circle())
            }
            .buttonStyle(AppPressableButtonStyle())
            .accessibilityLabel(closeLabel)
            .accessibilityIdentifier("rightMenu.close")
        }
        .padding(.horizontal, 18)
        .padding(.top, 16)
        .padding(.bottom, 14)
        .onAppear {
            heroSeed = Int.random(in: 0...10_000)
        }
    }

    @ViewBuilder
    private var currentCityCard: some View {
        if let currentCitySpotlight {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    cityThumbnail()
                    VStack(alignment: .leading, spacing: 2) {
                        Text(L10n.t("sideMenu.currentCity", lang))
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.textTertiary)
                            .textCase(.uppercase)
                        Text(currentCitySpotlight.city.localizedName(lang))
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.textPrimary)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 8)
                }

                HStack(spacing: 8) {
                    compactActionButton(title: openCityLabel, icon: "arrow.right.circle.fill") {
                        onSelect(SideMenuItemModel(
                            id: "currentCity",
                            titleKey: "sideMenu.cities",
                            systemIcon: "building.2.fill",
                            destination: .currentCity(province: currentCitySpotlight.province.id, city: currentCitySpotlight.city.name),
                            tint: AppColors.softBlue
                        ))
                    }
                    compactActionButton(title: changeCityLabel, icon: "slider.horizontal.3") {
                        onSelect(SideMenuItemModel(
                            id: "changeCity",
                            titleKey: "sideMenu.changeCity",
                            systemIcon: AppIcons.settings,
                            destination: .settings,
                            tint: AppColors.softBlue
                        ))
                    }
                }
            }
            .padding(14)
            .background(
                LinearGradient(
                    colors: [Color.white.opacity(0.11), AppColors.cyanGlow.opacity(0.065), Color.white.opacity(0.035)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.20), AppColors.cyanGlow.opacity(0.16), Color.white.opacity(0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            }
        }
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.t("sideMenu.quickActions", lang))
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.textTertiary)
                .textCase(.uppercase)
                .padding(.horizontal, 8)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                quickAction(title: L10n.t("sideMenu.quick.openMap", lang), icon: "map", destination: .map, tint: AppColors.routeLine)
                quickAction(title: L10n.t("sideMenu.quick.cities", lang), icon: "building.2", destination: .cities, tint: AppColors.softBlue)
                quickAction(title: L10n.t("sideMenu.quick.firstSteps", lang), icon: "list.bullet.rectangle", destination: .firstSteps(section: nil), tint: AppColors.success)
                quickAction(title: L10n.t("sideMenu.quick.sources", lang), icon: "doc.text.magnifyingglass", destination: .officialSources, tint: AppColors.dutchOrange)
                quickAction(title: L10n.t("sideMenu.knm", lang), icon: "graduationcap.fill", destination: .knm, tint: AppColors.cyanGlow)
                quickAction(title: L10n.t("sideMenu.dutchA1A2", lang), icon: "text.book.closed.fill", destination: .dutchA1A2, tint: AppColors.emerald)
            }
        }
    }

    @ViewBuilder
    private func quickAction(title: String, icon: String, destination: MenuDestination, tint: Color) -> some View {
        if isDestinationVisible(destination) {
            Button {
                onSelect(SideMenuItemModel(id: "quick-\(title)", titleKey: "sideMenu.title", systemIcon: icon, destination: destination, tint: tint))
            } label: {
                HStack(spacing: 9) {
                    GradientIconBadge(symbol: icon, color: tint, size: 34, cornerRadius: 10)

                    Text(title)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.76)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, minHeight: 54, alignment: .leading)
                .frame(minHeight: AppIcons.Metrics.minimumTouchTarget)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    LinearGradient(
                        colors: [Color.white.opacity(0.09), Color.white.opacity(0.035)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.11), lineWidth: 0.7)
                }
            }
            .buttonStyle(AppPressableButtonStyle())
            .accessibilityLabel(title)
        }
    }

    private func compactActionButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(AppColors.cyanGlow)
                Text(title)
                    .font(.system(size: 12.5, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                    .foregroundStyle(AppColors.textPrimary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(minHeight: 36)
            .background(
                LinearGradient(
                    colors: [AppColors.cyanGlow.opacity(0.18), AppColors.cyanGlow.opacity(0.08)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: [AppColors.cyanGlow.opacity(0.35), AppColors.cyanGlow.opacity(0.12)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            }
        }
        .buttonStyle(AppPressableButtonStyle())
    }

    private func menuButton(_ item: SideMenuItemModel) -> some View {
        let active = isActive(item)
        return SideMenuItem(
            icon: item.systemIcon,
            title: item.title(lang),
            subtitle: item.subtitle(lang),
            tint: item.tint,
            isActive: active
        ) {
            onSelect(item)
        }
        .buttonStyle(AppPressableButtonStyle())
        .accessibilityLabel(item.title(lang))
        .accessibilityAddTraits(active ? .isSelected : [])
        .accessibilityIdentifier("rightMenu.item.\(item.id)")
    }

    private func cityThumbnail() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            AppColors.cyanGlow.opacity(0.22),
                            AppColors.dutchOrange.opacity(0.12),
                            Color.white.opacity(0.06)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Path { path in
                path.move(to: CGPoint(x: 7, y: 34))
                path.addCurve(to: CGPoint(x: 43, y: 17), control1: CGPoint(x: 16, y: 21), control2: CGPoint(x: 31, y: 25))
                path.move(to: CGPoint(x: 12, y: 12))
                path.addLine(to: CGPoint(x: 41, y: 39))
            }
            .stroke(Color.white.opacity(0.42), style: StrokeStyle(lineWidth: 1.2, lineCap: .round, lineJoin: .round))

            Circle()
                .fill(AppColors.cyanGlow)
                .frame(width: 8, height: 8)
                .shadow(color: AppColors.cyanGlow.opacity(0.60), radius: 8)
                .offset(x: -12, y: 8)

            Circle()
                .fill(AppColors.dutchOrange)
                .frame(width: 6, height: 6)
                .shadow(color: AppColors.dutchOrange.opacity(0.50), radius: 7)
                .offset(x: 12, y: -8)
        }
        .frame(width: 50, height: 50)
        .overlay {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(Color.white.opacity(0.11), lineWidth: 0.8)
        }
        .accessibilityHidden(true)
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(languageSectionTitle)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textTertiary)

            HStack(spacing: 8) {
                ForEach(AppLanguage.releasePriority) { language in
                    languageButton(language, title: languageButtonTitle(language))
                }
            }

            Text("\(L10n.t("menu.version", lang)) \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(AppColors.textTertiary)
                .padding(.top, 2)
        }
    }

    private var languageReleaseTitle: String {
        switch lang {
        case .russian: return "Язык интерфейса"
        case .dutch: return "Interfacetaal"
        case .english: return "Interface language"
        }
    }

    private var languageReleaseSubtitle: String {
        switch lang {
        case .russian: return "Приоритет: English, Nederlands, Русский."
        case .dutch: return "Prioriteit: English, Nederlands, Русский."
        case .english: return "Priority: English, Dutch, Russian."
        }
    }

    private func isActive(_ item: SideMenuItemModel) -> Bool {
        if let tab = item.destination.tab {
            return activeDestination == nil && selectedTab == tab
        }
        if let destination = item.destination.appDestination {
            if case .cityDetail = activeDestination, item.destination == .cities {
                return true
            }
            return activeDestination == destination
        }
        return false
    }
}

private struct SideMenuHeroImageView: View {
    let landmark: AppImageAsset

    var body: some View {
        ZStack {
            PremiumImageView(
                asset: landmark,
                language: .english,
                height: 184,
                aspectRatio: nil,
                mode: .fill,
                cornerRadius: 0,
                overlayStyle: .none,
                fallbackCategory: .city,
                accessibilityLabel: landmark.title,
                targetPixelWidth: 900
            )
            .accessibilityHidden(true)

            LinearGradient(
                colors: [
                    Color.black.opacity(0.10),
                    AppColors.navyDeep.opacity(0.35),
                    Color.black.opacity(0.65)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            LinearGradient(
                colors: [AppColors.cyanGlow.opacity(0.24), Color.clear, AppColors.dutchOrange.opacity(0.14)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .frame(maxWidth: .infinity, minHeight: 164, maxHeight: 184)
        .clipped()
        .accessibilityLabel(landmark.title)
    }

    private var fallback: some View {
        ZStack {
            CityMenuMapHeaderBackground()
            LinearGradient(
                colors: [AppColors.navyDeep, AppColors.graphite.opacity(0.82)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(0.72)
        }
    }
}

private struct SideMenuDashboardWidget<Content: View>: View {
    let accent: Color
    var minHeight: CGFloat = 190
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .topLeading)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .fill(Color.white.opacity(0.10))
                    RadialGradient(colors: [accent.opacity(0.20), .clear], center: .topLeading, startRadius: 0, endRadius: 220)
                    LinearGradient(colors: [Color.white.opacity(0.16), Color.white.opacity(0.04), .clear], startPoint: .topLeading, endPoint: .bottomTrailing)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.24), accent.opacity(0.18), Color.white.opacity(0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: accent.opacity(0.10), radius: 14, x: 0, y: 8)
    }
}

private struct SideWidgetTitle: View {
    let title: String
    let symbol: String
    let accent: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(accent)
                .frame(width: 28, height: 28)
                .background(accent.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))

            Text(title)
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(3)
                .minimumScaleFactor(0.72)
        }
    }
}

private struct SideMenuItem: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    let tint: Color
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(tint.opacity(isActive ? 0.24 : 0.15))
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(tint)
                }
                .frame(width: 38, height: 38)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 11, weight: .regular))
                            .foregroundStyle(.white.opacity(0.40))
                            .lineLimit(2)
                            .minimumScaleFactor(0.76)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(isActive ? tint : Color.white.opacity(0.20))
            }
            .frame(maxWidth: .infinity, minHeight: 58, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 5)
            .background {
                Color.white.opacity(isActive ? 0.05 : 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct FloatingAssistantButton: View {
    let title: String
    let subtitle: String
    let modes: [GlobalAIMode]
    let language: AppLanguage
    let onSelect: (GlobalAIMode) -> Void
    @Binding var isExpanded: Bool

    var body: some View {
        GlobalAIModeLauncher(
            title: title,
            subtitle: subtitle,
            modes: modes,
            language: language,
            onSelect: onSelect,
            isExpanded: $isExpanded
        )
        .accessibilityIdentifier("floating.assistant.button")
    }
}

private struct GlobalAIModeLauncher: View {
    let title: String
    let subtitle: String
    let modes: [GlobalAIMode]
    let language: AppLanguage
    let onSelect: (GlobalAIMode) -> Void
    @Binding var isExpanded: Bool

    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            if isExpanded {
                VStack(alignment: .trailing, spacing: 7) {
                    ForEach(modes) { mode in
                        Button {
#if canImport(UIKit)
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
#endif
                            withAnimation(AppAnimations.tactilePress) {
                                isExpanded = false
                            }
                            onSelect(mode)
                        } label: {
                            Label(mode.title(language), systemImage: mode.symbol)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(AppColors.textPrimary)
                                .lineLimit(2)
                                .minimumScaleFactor(0.82)
                                .multilineTextAlignment(.trailing)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 9)
                                .frame(minHeight: 46, alignment: .trailing)
                                .background(AppSurface.base.opacity(0.94))
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(AppColors.cyanGlow.opacity(0.22), lineWidth: 0.7)
                                )
                        }
                        .buttonStyle(AppPressableButtonStyle())
                        .accessibilityIdentifier("global.aiLauncher.mode.\(mode.rawValue)")
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .accessibilityIdentifier("global.aiLauncher.menu")
            }

            Button {
#if canImport(UIKit)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
#endif
                withAnimation(AppAnimations.tactilePress) {
                    isExpanded.toggle()
                }
            } label: {
                Image(systemName: "sparkles")
                    .font(.system(size: 17, weight: .black))
                    .foregroundStyle(AppColors.navyDeep)
                    .frame(width: 48, height: 48)
                    .background(
                        LinearGradient(
                            colors: [AppColors.orangeGlow, AppColors.cyanGlow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
            }
            .shadow(color: AppColors.cyanGlow.opacity(0.18), radius: 18, x: 0, y: 8)
            .contentShape(Circle())
            .buttonStyle(AppPressableButtonStyle())
            .accessibilityLabel("\(title) \(subtitle)")
            .accessibilityIdentifier("global.aiLauncher")
        }
    }
}

private struct RouteNodeGlyph: View {
    let tint: Color
    let isActive: Bool

    var body: some View {
        ZStack {
            Capsule()
                .fill(tint.opacity(isActive ? 0.26 : 0.12))
                .frame(width: 24, height: 2)
                .offset(x: -8, y: -12)
            Circle()
                .fill(tint.opacity(isActive ? 0.20 : 0.10))
                .frame(width: 30, height: 30)
                .overlay(Circle().stroke(tint.opacity(isActive ? 0.48 : 0.22), lineWidth: 1))
            Circle()
                .fill(tint)
                .frame(width: isActive ? 9 : 6, height: isActive ? 9 : 6)
        }
        .frame(width: 38, height: 38)
    }
}
private struct CityMenuMapHeaderBackground: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                AppColors.navyDeep

                LinearGradient(
                    colors: [
                        AppColors.cyanGlow.opacity(0.22),
                        AppColors.dutchOrange.opacity(0.10),
                        AppColors.navyDeep.opacity(0.86)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Canvas { context, size in
                    let routeStroke = StrokeStyle(lineWidth: 1.1, lineCap: .round, lineJoin: .round)
                    var canal = Path()
                    canal.move(to: CGPoint(x: size.width * 0.05, y: size.height * 0.78))
                    canal.addCurve(
                        to: CGPoint(x: size.width * 0.96, y: size.height * 0.25),
                        control1: CGPoint(x: size.width * 0.28, y: size.height * 0.45),
                        control2: CGPoint(x: size.width * 0.62, y: size.height * 0.72)
                    )
                    context.stroke(canal, with: .color(AppColors.cyanGlow.opacity(0.32)), style: routeStroke)

                    var tram = Path()
                    tram.move(to: CGPoint(x: size.width * 0.14, y: size.height * 0.20))
                    tram.addLine(to: CGPoint(x: size.width * 0.38, y: size.height * 0.46))
                    tram.addLine(to: CGPoint(x: size.width * 0.72, y: size.height * 0.40))
                    tram.addLine(to: CGPoint(x: size.width * 0.92, y: size.height * 0.64))
                    context.stroke(tram, with: .color(AppColors.dutchOrange.opacity(0.28)), style: routeStroke)

                    for x in stride(from: CGFloat(20), to: size.width, by: 42) {
                        var street = Path()
                        street.move(to: CGPoint(x: x, y: 0))
                        street.addLine(to: CGPoint(x: x - 34, y: size.height))
                        context.stroke(street, with: .color(Color.white.opacity(0.035)), lineWidth: 0.7)
                    }
                    for y in stride(from: CGFloat(18), to: size.height, by: 32) {
                        var street = Path()
                        street.move(to: CGPoint(x: 0, y: y))
                        street.addLine(to: CGPoint(x: size.width, y: y + 16))
                        context.stroke(street, with: .color(Color.white.opacity(0.028)), lineWidth: 0.7)
                    }
                }

                cityNode(x: 0.18, y: 0.66, color: AppColors.cyanGlow, in: proxy.size)
                cityNode(x: 0.42, y: 0.46, color: AppColors.dutchOrange, in: proxy.size)
                cityNode(x: 0.64, y: 0.54, color: AppColors.cyanGlow, in: proxy.size)
                cityNode(x: 0.82, y: 0.32, color: AppColors.dutchOrange, in: proxy.size)
            }
        }
        .frame(minHeight: 112)
        .accessibilityHidden(true)
    }

    private func cityNode(x: CGFloat, y: CGFloat, color: Color, in size: CGSize) -> some View {
        Circle()
            .fill(color)
            .frame(width: 7, height: 7)
            .shadow(color: color.opacity(0.75), radius: 9, x: 0, y: 0)
            .position(x: size.width * x, y: size.height * y)
    }
}

// MARK: - Floating tab bar (compact / iPhone only)

#if os(iOS)
private struct FloatingTabBarItem: Identifiable {
    let tab: AppTab
    let title: String
    let symbol: String
    let selectedSymbol: String

    var id: AppTab { tab }
}

private struct FloatingTabBar: View {
    @Binding var selectedTab: AppTab
    let items: [FloatingTabBarItem]
    var axis: Axis = .horizontal
    var onSelect: (AppTab) -> Void = { _ in }
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Namespace private var selectionNS
    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        menuStack
        .padding(.horizontal, axis == .horizontal ? 4 : 5)
        .padding(.vertical, axis == .horizontal ? 5 : 5)
        .frame(maxWidth: axis == .horizontal ? 430 : 68)
        .frame(height: axis == .horizontal ? FloatingTabBarMetrics.height : nil)
        .background {
            backgroundView
        }
        .clipShape(RoundedRectangle(cornerRadius: axis == .horizontal ? 22 : 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: axis == .horizontal ? 22 : 14, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 0.8)
        )
        .overlay(alignment: .top) {
            LinearGradient(
                colors: [.clear, AppSurface.b2, .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 0.5)
        }
        .compositingGroup()
        .shadow(color: Color.black.opacity(0.24), radius: 16, x: 0, y: 8)
        .animation(.spring(response: 0.28, dampingFraction: 0.7), value: selectedTab)
    }

    @ViewBuilder
    private var menuStack: some View {
        if axis == .horizontal {
            HStack(spacing: 0) {
                buttons
            }
        } else {
            VStack(spacing: 6) {
                buttons
            }
        }
    }

    private var buttons: some View {
        ForEach(items) { item in
            Button {
#if canImport(UIKit)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
#endif
                withAnimation(AppAnimations.tactilePress) {
                    onSelect(item.tab)
                }
            } label: {
                FloatingTabBarButton(
                    item: item,
                    isSelected: selectedTab == item.tab,
                    axis: axis,
                    namespace: selectionNS
                )
            }
            .buttonStyle(.plain)
            .frame(minWidth: AppIcons.Metrics.minimumTouchTarget, minHeight: AppIcons.Metrics.minimumTouchTarget)
            .contentShape(Rectangle())
            .accessibilityLabel(item.tab == .more ? L10n.t("accessibility.openMenu", lang) : item.title)
            .accessibilityAddTraits(selectedTab == item.tab ? .isSelected : [])
            .accessibilityIdentifier("tab.\(item.tab)")
        }
    }

    private var backgroundView: some View {
        ZStack {
            if reduceTransparency {
                Rectangle().fill(AppSurface.e1)
            } else {
                Rectangle().fill(.regularMaterial)
                Rectangle().fill(AppColors.navyDeep.opacity(0.30))
            }
            // Dutch tricolor tint: red left edge, white center, blue right edge.
            LinearGradient(
                stops: [
                    .init(color: AppColors.dutchRed.opacity(0.045), location: 0.0),
                    .init(color: AppColors.dutchRed.opacity(0.022), location: 0.18),
                    .init(color: Color.white.opacity(0.014),          location: 0.50),
                    .init(color: Color(red: 33 / 255, green: 70 / 255, blue: 139 / 255).opacity(0.028), location: 0.82),
                    .init(color: Color(red: 33 / 255, green: 70 / 255, blue: 139 / 255).opacity(0.045), location: 1.0)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            // Subtle top shine
            LinearGradient(
                colors: [Color.white.opacity(0.05), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

private struct FloatingTabBarButton: View {
    let item: FloatingTabBarItem
    let isSelected: Bool
    var axis: Axis = .horizontal
    var namespace: Namespace.ID
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                if isSelected {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.dutchOrange.opacity(0.30), AppColors.dutchRed.opacity(0.20)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 25)
                        .matchedGeometryEffect(id: "tabSelectionPill", in: namespace)
                        .shadow(color: AppColors.dutchOrange.opacity(0.22), radius: 12, x: 0, y: 4)
                }

                Image(systemName: isSelected ? item.selectedSymbol : item.symbol)
                    .font(.system(size: 19, weight: isSelected ? .bold : .regular))
                    .symbolRenderingMode(isSelected ? .monochrome : .hierarchical)
                    .foregroundStyle(
                        isSelected
                            ? LinearGradient(
                                colors: [AppColors.dutchOrange, AppColors.dutchRed],
                                startPoint: .top, endPoint: .bottom)
                            : LinearGradient(
                                colors: [Color.white.opacity(0.35), Color.white.opacity(0.35)],
                                startPoint: .top, endPoint: .bottom)
                    )
                    .scaleEffect(isSelected ? 1.08 : 1.0)
                    .symbolEffect(.bounce, value: isSelected)
                    .accessibilityHidden(true)
            }
            .frame(height: 25)

            Text(item.title)
                .font(.system(size: 9.5, weight: isSelected ? .semibold : .medium, design: .rounded))
                .foregroundStyle(isSelected ? AppColors.dutchOrange : Color.white.opacity(0.42))
                .lineLimit(1)
                .minimumScaleFactor(0.52)
                .allowsTightening(true)
                .frame(maxWidth: .infinity)

            Circle()
                .fill(
                    isSelected
                        ? LinearGradient(
                            colors: [AppColors.dutchOrange, AppColors.dutchRed],
                            startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [.clear, .clear], startPoint: .top, endPoint: .bottom)
                )
                .frame(width: 4, height: 4)
                .shadow(color: isSelected ? AppColors.dutchOrange.opacity(0.8) : .clear, radius: 4)
                .opacity(isSelected ? 1 : 0)
                .scaleEffect(isSelected ? 1 : 0)
        }
        .frame(maxWidth: .infinity, minHeight: axis == .horizontal ? 42 : 54)
        .frame(minWidth: AppIcons.Metrics.minimumTouchTarget, minHeight: AppIcons.Metrics.minimumTouchTarget)
        .contentShape(Rectangle())
        .animation(
            reduceMotion ? nil : .spring(response: 0.28, dampingFraction: 0.7),
            value: isSelected
        )
    }
}
#endif

#if DEBUG && os(iOS)
private struct RootTabPreviewContainer: View {
    let initialTab: AppTab
    @StateObject private var languageManager = LanguageManager()
    @StateObject private var appState = AppStateViewModel()
    @StateObject private var savedItemsStore = SavedItemsStore()
    @StateObject private var documentStore = DocumentStore()

    var body: some View {
        RootTabView(initialTab: initialTab)
            .environmentObject(languageManager)
            .environmentObject(appState)
            .environmentObject(savedItemsStore)
            .environmentObject(documentStore)
            .environment(\.dynamicTypeSize, .large)
            .transaction { $0.animation = nil }
    }
}

#Preview("Root Tabs - iPhone 15", traits: .fixedLayout(width: 390, height: 844)) {
    RootTabPreviewContainer(initialTab: .home)
}

#Preview("Root Map - iPhone 15", traits: .fixedLayout(width: 390, height: 844)) {
    RootTabPreviewContainer(initialTab: .map)
}

#Preview("Root AI - iPhone 15", traits: .fixedLayout(width: 390, height: 844)) {
    RootTabPreviewContainer(initialTab: .assistant)
}
#endif
