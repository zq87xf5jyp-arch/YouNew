import Testing
import Foundation
@testable import YouNew

@MainActor
struct ContentAccessPolicyTests {
    @Test func centralPolicyMatchesSelectedCategoryAndGeneralOnly() {
        #expect(canShowToUser(audience: [.tourist], selectedCategory: .tourist))
        #expect(canShowToUser(audience: [.universal], selectedCategory: .tourist))
        #expect(!canShowToUser(audience: [.entrepreneur], selectedCategory: .tourist))
        #expect(!canShowToUser(audience: [.tourist], selectedCategory: .business))
        #expect(!canShowToUser(audience: [], selectedCategory: .tourist))
        #expect(!canShowToUser(audience: [.tourist], selectedCategory: nil))
    }

    @Test func touristDoesNotSeeBusinessResources() {
        let businessResource = MockResourcesData.items.first {
            $0.personaTags.contains(.entrepreneur) && !$0.personaTags.contains(.tourist)
        }

        #expect(businessResource != nil)
        #expect(businessResource?.isVisible(for: .tourist, scope: .currentAndUniversal) == false)
        #expect(businessResource?.isVisible(for: .entrepreneur, scope: .currentAndUniversal) == true)
    }

    @Test func touristSearchStaysInsideTouristAndGeneralAudience() {
        let touristSearch = SearchViewModel(initialQuery: "business KVK", language: .english, activePersona: .tourist)
        #expect(touristSearch.displayedResults.allSatisfy { answer in
            answer.personaTags.contains(.tourist) || answer.personaTags.contains(.universal)
        })
        #expect(!touristSearch.displayedResults.contains { $0.personaTags.contains(.entrepreneur) })

        let businessSearch = SearchViewModel(initialQuery: "business KVK", language: .english, activePersona: .entrepreneur)
        #expect(businessSearch.displayedResults.contains { $0.personaTags.contains(.entrepreneur) })
        #expect(!businessSearch.displayedResults.contains { $0.personaTags.contains(.tourist) && !$0.personaTags.contains(.universal) })
    }

    @Test func navigationVisibilityUsesSelectedCategory() {
        #expect(RelatedContentEngine.isVisible(.finesList, for: .tourist))
        #expect(RelatedContentEngine.isVisible(.finesList, for: .entrepreneur))
        #expect(!RelatedContentEngine.isVisible(.dutchA1A2, for: .tourist))
        #expect(!RelatedContentEngine.isVisible(.governmentHub, for: .tourist))
        #expect(RelatedContentEngine.isVisible(.governmentHub, for: .entrepreneur))
    }

    @Test func mapGeographyRoutesStayAvailableForEveryProfile() {
        for persona in PersonaTag.allCases where persona != .universal {
            #expect(RelatedContentEngine.isVisible(.cityDetail(province: "Zuid-Holland", city: "Leiden"), for: persona))
            #expect(RelatedContentEngine.isVisible(.provinceDetail("Zuid-Holland"), for: persona))
            #expect(RelatedContentEngine.isVisible(.provinceCities("Zuid-Holland"), for: persona))
            #expect(RelatedContentEngine.isVisible(.mapFocus(.city("leiden")), for: persona))
            #expect(RelatedContentEngine.isVisible(.mapFocus(.province("Zuid-Holland")), for: persona))
        }
    }

    @Test func homeScreenPrioritizesPrimaryActionsBeforeSecondaryTools() throws {
        let source = try homeViewSource()
        let bodyStart = try requireRange("var body: some View", in: source)
        let bodyEnd = try requireRange("disclaimerFooter", in: source, after: bodyStart.lowerBound)
        let bodyFlow = String(source[bodyStart.lowerBound...bodyEnd.upperBound])
        let topChrome = try requireRange("homeTopChrome", in: bodyFlow)
        let hero = try requireRange("productHomeHero", in: bodyFlow)
        let status = try requireRange("productHomeStatus", in: bodyFlow)
        let nextStep = try requireRange("What to do now", in: bodyFlow)
        let askAI = try requireRange("home.product.askAI", in: bodyFlow)
        let essentials = try requireRange("Essentials", in: bodyFlow)
        let city = try requireRange("Your city", in: bodyFlow)
        let footer = try requireRange("disclaimerFooter", in: bodyFlow)

        #expect(topChrome.lowerBound < hero.lowerBound)
        #expect(hero.lowerBound < status.lowerBound)
        #expect(status.lowerBound < nextStep.lowerBound)
        #expect(nextStep.lowerBound < askAI.lowerBound)
        #expect(askAI.lowerBound < essentials.lowerBound)
        #expect(essentials.lowerBound < city.lowerBound)
        #expect(city.lowerBound < footer.lowerBound)
        #expect(!bodyFlow.contains("stayInThisCitySection"))
        #expect(!bodyFlow.contains("travelLinksSection"))
        #expect(!bodyFlow.contains("primaryScenarioSection"))
        #expect(!bodyFlow.contains("audienceEssentialsSection"))
        #expect(!bodyFlow.contains("audienceExploreSection"))
        #expect(!bodyFlow.contains("categoriesGridSection"))
        #expect(!bodyFlow.contains("secondaryToolsSection"))
    }

    @Test func homeHeroKeepsBureaucracyOutOfTouristShortcuts() throws {
        let source = try homeViewSource()
        let documents = try requireRange("id: \"documents\"", in: source)
        let lostDocuments = try requireRange("id: \"lost_documents\"", in: source)
        let documentsDefinition = String(source[documents.lowerBound..<lostDocuments.lowerBound])
        let heroQuickStart = try requireRange("private var heroQuickIntelligence", in: source)
        let heroQuickEnd = try requireRange("private func heroIntelligenceTile", in: source)
        let heroQuick = String(source[heroQuickStart.lowerBound..<heroQuickEnd.lowerBound])

        #expect(!documentsDefinition.contains(".tourist"))
        #expect(!heroQuick.contains("Municipality"))
        #expect(heroQuick.contains("112"))
        #expect(heroQuick.contains("Weather"))
        #expect(heroQuick.contains("askAITitle"))
        #expect(heroQuick.contains("home.hero.shortcut.ai"))
    }

    @Test func homeDashboardNewBlocksRespectSelectedAudience() throws {
        let source = try homeViewSource()
        let touristStart = try requireRange("private var stayPlanningActions", in: source)
        let refugeeStart = try requireRange("private var refugeeEssentialsActions", in: source)
        let studentStart = try requireRange("private var studentEssentialsActions", in: source)
        let businessStart = try requireRange("private var businessEssentialsActions", in: source)
        let generalStart = try requireRange("private var generalEssentialsActions", in: source)
        let residentStart = try requireRange("private var residentEssentialsActions", in: source)
        let foodVisibilityStart = try requireRange("private var shouldShowFoodDrinksSection", in: source)
        let foodVisibilityEnd = try requireRange("private func foodGuideItemIsVisible", in: source)
        let travelVisibilityStart = try requireRange("private func canShowTravelLink", in: source)
        let travelVisibilityEnd = try requireRange("private var stayPlanningActions", in: source)

        let touristActions = String(source[touristStart.lowerBound..<refugeeStart.lowerBound])
        let refugeeActions = String(source[refugeeStart.lowerBound..<studentStart.lowerBound])
        let studentActions = String(source[studentStart.lowerBound..<businessStart.lowerBound])
        let businessActions = String(source[businessStart.lowerBound..<generalStart.lowerBound])
        let generalActions = String(source[generalStart.lowerBound..<residentStart.lowerBound])
        let foodVisibility = String(source[foodVisibilityStart.lowerBound..<foodVisibilityEnd.lowerBound])
        let travelVisibility = String(source[travelVisibilityStart.lowerBound..<travelVisibilityEnd.lowerBound])

        #expect(touristActions.contains("Hotels in"))
        #expect(touristActions.contains("Restaurants"))
        #expect(touristActions.contains("Cafes"))
        #expect(touristActions.contains("Places"))
        #expect(touristActions.contains("Transport"))
        #expect(touristActions.contains("Emergency"))
        #expect(!touristActions.contains("BSN"))
        #expect(!touristActions.contains("DigiD"))
        #expect(!touristActions.contains("Taxes"))
        #expect(!touristActions.contains("IND"))

        #expect(refugeeActions.contains("IND"))
        #expect(refugeeActions.contains("Municipality"))
        #expect(refugeeActions.contains("Housing"))
        #expect(refugeeActions.contains("Benefits"))
        #expect(refugeeActions.contains("Healthcare"))
        #expect(refugeeActions.contains("Documents"))

        #expect(studentActions.contains("Transport"))
        #expect(studentActions.contains("Housing"))
        #expect(studentActions.contains("Education"))
        #expect(studentActions.contains("City places"))
        #expect(studentActions.contains("Cafes"))

        #expect(businessActions.contains("Business setup"))
        #expect(businessActions.contains("Taxes"))
        #expect(businessActions.contains("Transport"))
        #expect(generalActions.contains("City guide"))
        #expect(generalActions.contains("Places"))
        #expect(generalActions.contains("Transport"))
        #expect(generalActions.contains("Emergency"))

        #expect(foodVisibility.contains("case .tourist, .student, .business"))
        #expect(foodVisibility.contains("case .general, .local, .refugee"))
        #expect(travelVisibility.contains("case .refugee"))
        #expect(travelVisibility.contains("return false"))
    }

    @Test func homeAudiencePlansCoverNonTouristCategories() throws {
        let source = try homeViewSource()
        let essentials = try requireRange("private var audienceEssentialCategoryIDs", in: source)
        let explore = try requireRange("private var audienceExploreCategoryIDs", in: source)
        let audiencePlans = String(source[essentials.lowerBound..<explore.lowerBound])
        let explorePlans = String(source[explore.lowerBound...])

        #expect(audiencePlans.contains("case .tourist"))
        #expect(audiencePlans.contains("case .student"))
        #expect(audiencePlans.contains("case .business"))
        #expect(audiencePlans.contains("case .local"))
        #expect(explorePlans.contains("case .student"))
        #expect(explorePlans.contains("case .business"))
        #expect(explorePlans.contains("case .local"))
    }

    @Test func searchIncludesCityDashboardSourcesAndFilters() throws {
        let source = try searchViewSource()
        let directStart = try requireRange("private func buildDirectResults", in: source)
        let directEnd = try requireRange("private func selectedCategoryAllows", in: source)
        let directSearch = String(source[directStart.lowerBound..<directEnd.lowerBound])

        #expect(directSearch.contains("CityDashboardContentData.travelLinks"))
        #expect(directSearch.contains("CityDashboardContentData.foodGuideItems"))
        #expect(directSearch.contains("DashboardPlacesData.visiblePlaces(cityId: selectedCity.name"))
        #expect(directSearch.contains("DashboardCalendarData.upcomingEvents(cityId: selectedCity.name"))
        #expect(directSearch.contains("selectedAudience"))
        #expect(directSearch.contains("selectedCategory"))
        #expect(directSearch.contains("travelLinkIsVisible"))
        #expect(directSearch.contains("foodGuideSearchCategoryAllows"))
        #expect(directSearch.contains("shouldSearchPlaces"))
        #expect(directSearch.contains("shouldSearchCalendar"))
        #expect(directSearch.contains("hotel"))
        #expect(directSearch.contains("restaurant"))
        #expect(directSearch.contains("coffee"))
        #expect(directSearch.contains("museum"))
        #expect(directSearch.contains("holiday"))
        #expect(source.contains("externalURL"))
        #expect(source.contains("openOfficialSource(externalURL)"))
    }

    private func homeViewSource() throws -> String {
        let testFile = URL(fileURLWithPath: #filePath)
        let projectRoot = testFile.deletingLastPathComponent().deletingLastPathComponent()
        let homeView = projectRoot.appendingPathComponent("YouNew/Views/HomeView.swift")
        return try String(contentsOf: homeView, encoding: .utf8)
    }

    private func searchViewSource() throws -> String {
        let testFile = URL(fileURLWithPath: #filePath)
        let projectRoot = testFile.deletingLastPathComponent().deletingLastPathComponent()
        let searchView = projectRoot.appendingPathComponent("YouNew/Views/SearchView.swift")
        return try String(contentsOf: searchView, encoding: .utf8)
    }

    private func requireRange(_ needle: String, in source: String, after lowerBound: String.Index? = nil) throws -> Range<String.Index> {
        let searchRange = (lowerBound ?? source.startIndex)..<source.endIndex
        guard let range = source.range(of: needle, range: searchRange) else {
            throw TestSourceError.missing(needle)
        }
        return range
    }
}

private enum TestSourceError: Error {
    case missing(String)
}
