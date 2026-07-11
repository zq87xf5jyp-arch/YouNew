import Foundation

struct DashboardRenderContext: Equatable {
    let selectedAudience: UserContentCategory?
    let selectedCityID: String?
}

protocol DashboardRenderableCard {
    var dashboardTitle: String { get }
    var dashboardRouteID: String? { get }
    var dashboardActionID: String? { get }
    var dashboardURL: URL? { get }
    var dashboardExternalURL: URL? { get }
    var dashboardAudienceTags: Set<PersonaTag> { get }
    var dashboardCityID: String? { get }
    var dashboardHidden: Bool { get }
    var dashboardDraft: Bool { get }
    var dashboardPriority: Int { get }
}

extension DashboardRenderableCard {
    var dashboardExternalURL: URL? { nil }
}

struct DashboardSection<Item: DashboardRenderableCard> {
    let id: String
    let title: String
    let subtitle: String?
    let layout: DashboardSectionLayout
    let priority: Int
    let audienceTags: Set<PersonaTag>
    let items: [Item]
}

enum DashboardSectionLayout: String, CaseIterable, Equatable {
    case list
    case grid
    case horizontal
}

enum DashboardContentPolicy {
    static func shouldRenderCard<Item: DashboardRenderableCard>(
        _ item: Item?,
        context: DashboardRenderContext
    ) -> Bool {
        guard let item else { return false }
        guard !item.dashboardTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        let hasValidURL = [item.dashboardURL, item.dashboardExternalURL]
            .compactMap { $0 }
            .contains { AppURL.validatedWebURL($0) != nil }
        guard item.dashboardRouteID != nil || item.dashboardActionID != nil || hasValidURL else { return false }
        guard !item.dashboardAudienceTags.isEmpty else { return false }
        guard !item.dashboardHidden, !item.dashboardDraft else { return false }
        guard ContentAccessPolicy.canShowToUser(
            audience: item.dashboardAudienceTags,
            selectedCategory: context.selectedAudience,
            scope: .currentAndUniversal
        ) else { return false }
        if let cityID = item.dashboardCityID, cityID != context.selectedCityID {
            return false
        }
        return true
    }

    static func visibleCards<Item: DashboardRenderableCard>(
        _ items: [Item],
        context: DashboardRenderContext,
        limit: Int? = nil
    ) -> [Item] {
        let visible = items
            .filter { shouldRenderCard($0, context: context) }
            .sorted { lhs, rhs in
                if lhs.dashboardPriority != rhs.dashboardPriority {
                    return lhs.dashboardPriority < rhs.dashboardPriority
                }
                return lhs.dashboardTitle < rhs.dashboardTitle
            }
        guard let limit else { return visible }
        return Array(visible.prefix(limit))
    }

    static func getVisibleSectionItems<Item: DashboardRenderableCard>(
        _ section: DashboardSection<Item>,
        context: DashboardRenderContext
    ) -> [Item] {
        visibleCards(section.items, context: context)
    }

    static func shouldRenderSection<Item: DashboardRenderableCard>(
        _ section: DashboardSection<Item>,
        context: DashboardRenderContext
    ) -> Bool {
        guard !section.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        guard ContentAccessPolicy.canShowToUser(
            audience: section.audienceTags,
            selectedCategory: context.selectedAudience,
            scope: .currentAndUniversal
        ) else { return false }
        return !getVisibleSectionItems(section, context: context).isEmpty
    }
}
