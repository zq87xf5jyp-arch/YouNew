import Testing
import Foundation
@testable import YouNew

// MARK: - AIContextBuilder Tests

@MainActor
struct AIContextBuilderTests {

    // MARK: Province Context

    @Test func provinceContextSetsCorrectScreen() {
        let province = ProvinceCatalog.item(id: "Noord-Holland")
        let ctx = AIContextBuilder.provinceContext(province: province, language: .english, appState: nil)
        #expect(ctx.screen == .province)
        #expect(ctx.selectedProvince == "Noord-Holland")
    }

    @Test func provinceContextHasOfficialSource() {
        let province = ProvinceCatalog.item(id: "Utrecht")
        let ctx = AIContextBuilder.provinceContext(province: province, language: .english, appState: nil)
        #expect(!ctx.officialSources.isEmpty)
        #expect(ctx.officialSources.first?.url != nil)
    }

    @Test func provinceContextHasDisclaimer() {
        let province = ProvinceCatalog.item(id: "Friesland")
        let ctx = AIContextBuilder.provinceContext(province: province, language: .english, appState: nil)
        #expect(ctx.disclaimer.contains("informational guidance"))
    }

    @Test func provinceContextDutchDisclaimerCorrect() {
        let province = ProvinceCatalog.item(id: "Groningen")
        let ctx = AIContextBuilder.provinceContext(province: province, language: .dutch, appState: nil)
        #expect(ctx.disclaimer.contains("informatieve hulp"))
    }

    @Test func provinceContextRussianDisclaimerCorrect() {
        let province = ProvinceCatalog.item(id: "Zeeland")
        let ctx = AIContextBuilder.provinceContext(province: province, language: .russian, appState: nil)
        #expect(ctx.disclaimer.contains("информационную помощь"))
    }

    // MARK: City Context

    @Test func cityContextSetsCorrectScreen() {
        let ctx = AIContextBuilder.cityContext(cityName: "Amsterdam", provinceName: "Noord-Holland", language: .english, appState: nil)
        #expect(ctx.screen == .city)
        #expect(ctx.topicTitle == "Amsterdam")
        #expect(ctx.selectedProvince == "Noord-Holland")
    }

    @Test func cityContextTopicSummaryContainsCityName() {
        let ctx = AIContextBuilder.cityContext(cityName: "Rotterdam", provinceName: "Zuid-Holland", language: .english, appState: nil)
        #expect(ctx.topicSummary?.contains("Rotterdam") == true)
    }

    // MARK: Transport Context

    @Test func transportContextSetsCorrectScreen() {
        let ctx = AIContextBuilder.transportContext(language: .english, appState: nil)
        #expect(ctx.screen == .transport)
        #expect(ctx.category == "Transport")
    }

    @Test func transportContextHasNSAndOVSources() {
        let ctx = AIContextBuilder.transportContext(language: .english, appState: nil)
        let titles = ctx.officialSources.map(\.title)
        #expect(titles.contains("NS"))
        #expect(titles.contains("OV-chipkaart"))
    }

    // MARK: Emergency Context

    @Test func emergencyContextSetsCorrectScreen() {
        let ctx = AIContextBuilder.emergencyContext(language: .english, appState: nil)
        #expect(ctx.screen == .emergency)
    }

    @Test func emergencyContextTopicSummaryContains112() {
        let ctx = AIContextBuilder.emergencyContext(language: .english, appState: nil)
        #expect(ctx.topicSummary?.contains("112") == true)
    }

    @Test func emergencyContextHasPolitieSource() {
        let ctx = AIContextBuilder.emergencyContext(language: .english, appState: nil)
        #expect(ctx.officialSources.first?.institution == "Politie")
    }

    // MARK: Housing Context

    @Test func housingContextSetsCorrectScreen() {
        let ctx = AIContextBuilder.housingContext(language: .english, appState: nil)
        #expect(ctx.screen == .housing)
        #expect(ctx.category == "Housing")
    }

    @Test func housingContextHasHuurcommissieSource() {
        let ctx = AIContextBuilder.housingContext(language: .dutch, appState: nil)
        let titles = ctx.officialSources.map(\.title)
        #expect(titles.contains("Huurcommissie"))
    }

    // MARK: Healthcare Context

    @Test func healthcareContextSetsCorrectScreen() {
        let ctx = AIContextBuilder.healthcareContext(language: .english, appState: nil)
        #expect(ctx.screen == .healthcare)
        #expect(ctx.category == "Healthcare")
    }

    @Test func healthcareContextTopicSummaryMentionsMandatoryInsurance() {
        let ctx = AIContextBuilder.healthcareContext(language: .english, appState: nil)
        #expect(ctx.topicSummary?.contains("mandatory") == true)
    }

    // MARK: Work & Taxes Context

    @Test func workAndTaxesContextSetsCorrectScreen() {
        let ctx = AIContextBuilder.workAndTaxesContext(language: .english, appState: nil)
        #expect(ctx.screen == .workAndTaxes)
    }

    @Test func workAndTaxesContextHasBelastingdienstSource() {
        let ctx = AIContextBuilder.workAndTaxesContext(language: .english, appState: nil)
        let institutions = ctx.officialSources.compactMap(\.institution)
        #expect(institutions.contains("Tax Authority"))
    }

    @Test func workAndTaxesContextHasUWVSource() {
        let ctx = AIContextBuilder.workAndTaxesContext(language: .english, appState: nil)
        let institutions = ctx.officialSources.compactMap(\.institution)
        #expect(institutions.contains("UWV"))
    }

    // MARK: Documents Context

    @Test func documentsContextSetsCorrectScreen() {
        let ctx = AIContextBuilder.documentsContext(language: .english, appState: nil)
        #expect(ctx.screen == .documents)
        #expect(ctx.category == "Documents & DigiD")
    }

    @Test func documentsContextHasDigiDSource() {
        let ctx = AIContextBuilder.documentsContext(language: .english, appState: nil)
        let titles = ctx.officialSources.map(\.title)
        #expect(titles.contains("DigiD"))
    }

    // MARK: Search Context

    @Test func searchContextWithQuerySetsTitle() {
        let ctx = AIContextBuilder.searchContext(query: "BSN registration", language: .english, appState: nil)
        #expect(ctx.screen == .search)
        #expect(ctx.topicTitle?.contains("BSN registration") == true)
    }

    @Test func searchContextWithNilQueryHasDefaultTitle() {
        let ctx = AIContextBuilder.searchContext(query: nil, language: .english, appState: nil)
        #expect(ctx.screen == .search)
        #expect(ctx.topicTitle == "Search")
    }

    // MARK: Rules & Fines Context

    @Test func rulesAndFinesContextSetsCorrectScreen() {
        let ctx = AIContextBuilder.rulesAndFinesContext(language: .english, appState: nil)
        #expect(ctx.screen == .rulesAndFines)
    }

    @Test func rulesAndFinesContextHasCJIBSource() {
        let ctx = AIContextBuilder.rulesAndFinesContext(language: .english, appState: nil)
        let titles = ctx.officialSources.map(\.title)
        #expect(titles.contains("CJIB (fines)"))
    }

    // MARK: Fine Topic Context

    @Test func fineTopicContextSetsCorrectScreen() {
        guard let topic = MockRulesGuideData.topics.first else { return }
        let ctx = AIContextBuilder.fineTopicContext(topic: topic, language: .english, appState: nil)
        #expect(ctx.screen == .fineDetail)
        #expect(ctx.topicTitle == topic.title)
    }

    @Test func fineTopicContextOfficialSourceMatchesToopic() {
        guard let topic = MockRulesGuideData.topics.first else { return }
        let ctx = AIContextBuilder.fineTopicContext(topic: topic, language: .english, appState: nil)
        #expect(ctx.officialSources.first?.title == topic.officialSourceName)
    }

    // MARK: Settings Context

    @Test func settingsContextSetsCorrectScreen() {
        let ctx = AIContextBuilder.settingsContext(language: .english, appState: nil)
        #expect(ctx.screen == .settings)
    }

    // MARK: Official Links Context

    @Test func officialLinksContextSetsCorrectScreen() {
        let ctx = AIContextBuilder.officialLinksContext(language: .english, appState: nil)
        #expect(ctx.screen == .officialLinks)
        #expect(ctx.officialSources.count >= 3)
    }

    // MARK: Sanitization

    @Test func buildSanitizesTopicTitleOver1200Chars() {
        let longTitle = String(repeating: "X", count: 2000)
        let ctx = AIContextBuilder.build(
            screen: .home,
            language: .english,
            appState: nil,
            topicTitle: longTitle
        )
        #expect((ctx.topicTitle?.count ?? 0) <= 1200)
    }

    @Test func buildReturnsNilForEmptyTopicTitle() {
        let ctx = AIContextBuilder.build(
            screen: .home,
            language: .english,
            appState: nil,
            topicTitle: "   "
        )
        #expect(ctx.topicTitle == nil)
    }

    // MARK: Disclaimer presence across all screens

    @Test func allContextsHaveNonEmptyDisclaimer() {
        let contexts: [AIContext] = [
            AIContextBuilder.transportContext(language: .english, appState: nil),
            AIContextBuilder.emergencyContext(language: .english, appState: nil),
            AIContextBuilder.housingContext(language: .english, appState: nil),
            AIContextBuilder.healthcareContext(language: .english, appState: nil),
            AIContextBuilder.workAndTaxesContext(language: .english, appState: nil),
            AIContextBuilder.documentsContext(language: .english, appState: nil),
            AIContextBuilder.searchContext(query: nil, language: .english, appState: nil),
            AIContextBuilder.settingsContext(language: .english, appState: nil),
        ]
        for ctx in contexts {
            #expect(!ctx.disclaimer.isEmpty, "Disclaimer must not be empty for screen \(ctx.screen.rawValue)")
        }
    }
}
