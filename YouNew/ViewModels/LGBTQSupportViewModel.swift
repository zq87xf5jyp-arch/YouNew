import Foundation
import Combine

@MainActor
final class LGBTQSupportViewModel: ObservableObject {
    enum State: Equatable {
        case loading
        case loaded
        case empty
        case failed(String)
    }

    @Published private(set) var state: State = .loading
    @Published private(set) var allItems: [LGBTQSupportItem] = []
    @Published var searchText = ""
    @Published var selectedSection: LGBTQSupportSection? = nil
    @Published var selectedCity = "All"
    @Published var selectedCategory: LGBTQSupportCategory? = nil
    @Published var activePersona: PersonaTag? {
        didSet {
            guard oldValue != activePersona else { return }
            if !filteredItems.contains(where: { selectedCategory == nil || $0.category == selectedCategory }) {
                selectedCategory = nil
            }
            if selectedCity != "All", !cities.contains(selectedCity) {
                selectedCity = "All"
            }
        }
    }

    func load() async {
        state = .loading
        let items = MockLGBTQSupportData.items
        allItems = items
        state = items.isEmpty ? .empty : .loaded
    }

    private var personaVisibleItems: [LGBTQSupportItem] {
        allItems.filter { $0.isVisible(for: activePersona, scope: .currentAndUniversal) }
    }

    var filteredItems: [LGBTQSupportItem] {
        let normalizedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return personaVisibleItems.filter { item in
            let sectionMatches = selectedSection.map { item.section == $0 } ?? true
            let cityMatches = selectedCity == "All" || item.city == selectedCity
            let categoryMatches = selectedCategory.map { item.category == $0 } ?? true
            let searchMatches = normalizedSearch.isEmpty || item.searchableText.contains(normalizedSearch)
            return sectionMatches && cityMatches && categoryMatches && searchMatches
        }
    }

    var visibleCategories: [LGBTQSupportCategory] {
        let scoped = personaVisibleItems.filter { item in
            let sectionMatches = selectedSection.map { item.section == $0 } ?? true
            let cityMatches = selectedCity == "All" || item.city == selectedCity
            return sectionMatches && cityMatches
        }
        return Array(Set(scoped.map(\.category))).sorted { $0.rawValue < $1.rawValue }
    }

    var cities: [String] {
        ["All"] + Array(Set(personaVisibleItems.map(\.city))).sorted()
    }

    func resetFilters() {
        selectedSection = nil
        selectedCity = "All"
        selectedCategory = nil
        searchText = ""
    }
}
