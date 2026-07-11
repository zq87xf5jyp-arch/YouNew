import Testing
import Foundation
@testable import YouNew

@MainActor
struct KnowledgeIndexTests {
    private func context(
        persona: PersonaTag,
        screen: AIContextScreen = .unknown,
        category: String? = nil,
        topicTitle: String? = nil,
        topicSummary: String? = nil,
        userSituation: String? = nil,
        selectedCity: String? = nil,
        selectedProvince: String? = nil,
        savedItemTitles: [String] = [],
        currentRouteID: String? = nil,
        recentRouteIDs: [String] = [],
        completedChecklistItemIDs: [String] = [],
        completedGuideIDs: [String] = [],
        journeyProgress: String? = nil
    ) -> AIContext {
        AIContext(
            screen: screen,
            category: category,
            topicTitle: topicTitle,
            topicSummary: topicSummary,
            officialSources: [],
            lastReviewed: nil,
            userLanguage: .english,
            userSituation: userSituation,
            selectedCity: selectedCity,
            selectedProvince: selectedProvince,
            savedItemTitles: savedItemTitles,
            currentRouteID: currentRouteID,
            recentRouteIDs: recentRouteIDs,
            completedChecklistItemIDs: completedChecklistItemIDs,
            completedGuideIDs: completedGuideIDs,
            journeyProgress: journeyProgress,
            disclaimer: "",
            activePersonaTag: persona
        )
    }

    @Test func indexContainsCoreAppKnowledgeSources() {
        let index = KnowledgeIndex.shared

        #expect(index.items.contains { $0.type == .topic && $0.title(.english).localizedCaseInsensitiveContains("BSN") })
        #expect(index.items.contains { $0.type == .article && $0.id == "article:documents:bsn" })
        #expect(index.items.contains { $0.type == .guide })
        #expect(index.items.contains { $0.type == .officialService && $0.title(.english) == "DigiD" })
        #expect(index.items.contains { $0.type == .city && $0.title(.english) == "Leiden" })
        #expect(index.items.contains { $0.type == .province })
        #expect(index.items.contains { $0.type == .checklist })
        #expect(index.items.contains { $0.type == .fine })
        #expect(index.items.contains { $0.type == .institution })
        #expect(index.items.contains { $0.type == .dutchTerm })
        #expect(index.items.contains { $0.type == .letter })
        #expect(index.items.contains { $0.type == .resource })
        #expect(index.items.contains { $0.type == .localPartner && $0.city == "Rotterdam" })
        #expect(index.items.contains { $0.type == .knmModule })
        #expect(index.items.contains { $0.type == .dutchCourseModule })
    }

    @Test func netherlandsKnowledgeDatabaseProvidesUnifiedDataPlatform() {
        let database = NetherlandsKnowledgeDatabase.shared
        let report = database.report
        let ids = database.entities.map(\.id)

        #expect(Set(ids).count == ids.count)
        #expect(report.cities >= NLCity.all.count)
        #expect(report.cities >= 12)
        #expect(report.places >= NLCity.all.flatMap(\.attractions).count)
        #expect(report.governmentServices >= MockInstitutionsData.items.count)
        #expect(report.localPartners == MockLocalPartnersData.partners.count)
        #expect(report.officialSources >= 10)
        #expect(report.linkedImages >= database.entities.count)
        #expect(report.relations >= report.cities * 3)

        for entity in database.entities {
            #expect(!entity.id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            #expect(!entity.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            #expect(!entity.summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            #expect(!entity.category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            #expect(!entity.lastChecked.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            #expect(!entity.aiSummary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    @Test func unifiedDatabaseFeedsSearchAndKnowledgeGraph() throws {
        let database = NetherlandsKnowledgeDatabase.shared
        let index = KnowledgeIndex.shared
        let engine = AppSearchEngine(index: index)

        #expect(database.entity(id: "city:leiden") != nil)
        #expect(database.entity(id: "source:government-brp") != nil)
        #expect(index.itemsByID["topic:registration-bsn"] != nil)
        #expect(index.graph.relations.contains {
            $0.fromID == "city:leiden" && $0.toID == "topic:registration-bsn"
        })

        let bsnResults = engine.search("BSN BRP registration", language: .english, scope: .allContentWithOutsidePathWarning, limit: 12)
        #expect(bsnResults.contains { $0.item.id == "topic:registration-bsn" || $0.item.sources.contains { $0.title.localizedCaseInsensitiveContains("BRP") } })

        let placeResults = engine.search("Rijksmuseum Amsterdam", language: .english, scope: .allContentWithOutsidePathWarning, limit: 12)
        #expect(placeResults.contains { $0.item.title(.english).localizedCaseInsensitiveContains("Rijksmuseum") })

        let partnerResults = engine.search("lawyer Eindhoven", language: .english, scope: .allContentWithOutsidePathWarning, limit: 12)
        #expect(partnerResults.contains { $0.item.type == .localPartner || $0.item.category.localizedCaseInsensitiveContains("legal") })
    }

    @Test func assistantBigQuestionAsksClarificationInsteadOfGenericTemplate() throws {
        let response = try #require(AssistantAnswerEngine.getAssistantAnswer(
            userText: "big",
            language: .english,
            context: context(persona: .tourist, selectedCity: "Amsterdam")
        ))

        #expect(response.answer.localizedCaseInsensitiveContains("what do you mean"))
        #expect(response.answer.localizedCaseInsensitiveContains("BIG-register"))
        #expect(!response.answer.localizedCaseInsensitiveContains("deadlines, payments"))
        #expect(response.sources.isEmpty)
        #expect(!response.isVerified)
    }

    @Test func assistantTouristBSNDoesNotStartResidentFlow() throws {
        let response = try #require(AssistantAnswerEngine.getAssistantAnswer(
            userText: "Bsn",
            language: .english,
            context: context(persona: .tourist, selectedCity: "Amsterdam")
        ))

        #expect(response.answer.localizedCaseInsensitiveContains("short-stay tourists"))
        #expect(response.answer.localizedCaseInsensitiveContains("do not need a BSN"))
        #expect(response.sections.map(\.body).joined(separator: " ").localizedCaseInsensitiveContains("do not type your BSN"))
        #expect(!response.answer.localizedCaseInsensitiveContains("deadline"))
    }

    @Test func assistantTouristLostPassportUsesAmsterdamTouristContext() throws {
        let response = try #require(AssistantAnswerEngine.getAssistantAnswer(
            userText: "lost passport",
            language: .english,
            context: context(persona: .tourist, selectedCity: "Amsterdam")
        ))

        let fullText = ([response.answer] + response.sections.map(\.body)).joined(separator: " ")
        #expect(fullText.localizedCaseInsensitiveContains("passport"))
        #expect(fullText.localizedCaseInsensitiveContains("Amsterdam"))
        #expect(fullText.localizedCaseInsensitiveContains("embassy") || fullText.localizedCaseInsensitiveContains("consulate"))
        #expect(!fullText.localizedCaseInsensitiveContains("Municipality Leiden"))
        #expect(response.sources.contains { $0.url != nil })
    }

    @Test func assistantTouristTransportUsesTouristTransportSources() throws {
        let response = try #require(AssistantAnswerEngine.getAssistantAnswer(
            userText: "transport",
            language: .english,
            context: context(persona: .tourist, selectedCity: "Amsterdam")
        ))

        let fullText = ([response.answer] + response.sections.map(\.body)).joined(separator: " ")
        #expect(fullText.localizedCaseInsensitiveContains("tourist"))
        #expect(fullText.localizedCaseInsensitiveContains("Amsterdam"))
        #expect(fullText.localizedCaseInsensitiveContains("check in") || fullText.localizedCaseInsensitiveContains("check-in"))
        #expect(response.sources.contains { $0.title == "9292" || $0.title == "OVpay" })
    }

    @Test func allGuideArticlesCitiesAndProvincesAreIndexedForAI() {
        let index = KnowledgeIndex.shared
        let itemIDs = Set(index.items.map(\.id))

        for section in GuideContent.sections {
            let sectionID = "guide:\(section.id)"
            #expect(itemIDs.contains(sectionID), "Missing guide section in KnowledgeIndex: \(sectionID)")
            #expect(AppNavigationResolver.destination(for: sectionID) == .guideSection(section.id))

            for article in section.articles {
                let articleID = "article:\(section.id):\(article.id)"
                #expect(itemIDs.contains(articleID), "Missing guide article in KnowledgeIndex: \(articleID)")
                #expect(AppNavigationResolver.destination(for: articleID) == .guideArticle(sectionID: section.id, articleID: article.id))
            }
        }

        for topic in PracticalGuideTopic.allCases {
            let destination = AppDestination.practicalGuide(topic)
            let routeID = "practicalGuide:\(topic.rawValue)"
            #expect(AppNavigationResolver.destination(for: routeID) == destination)
        }

        for city in NLCity.all {
            let cityID = "city:\(KnowledgeNormalizer.slug(city.id))"
            #expect(itemIDs.contains(cityID), "Missing city in KnowledgeIndex: \(cityID)")
            #expect(AppNavigationResolver.destination(for: cityID) == .nlCityDetail(city.id))
        }

        for province in NLProvince.all {
            let provinceID = "province:\(KnowledgeNormalizer.slug(province.id))"
            #expect(itemIDs.contains(provinceID), "Missing province in KnowledgeIndex: \(provinceID)")
            #expect(AppNavigationResolver.destination(for: provinceID) == .provinceDetail(province.name))
        }
    }

    @Test func indexedContentHasNavigationSourceSaveAndShareActions() {
        let actionCriticalTypes: Set<KnowledgeItemType> = [
            .guide,
            .article,
            .topic,
            .officialService,
            .document,
            .city,
            .province,
            .checklist,
            .fine,
            .institution,
            .letter,
            .resource,
            .localPartner,
            .knmModule,
            .dutchCourseModule
        ]

        for item in KnowledgeIndex.shared.items where actionCriticalTypes.contains(item.type) {
            let actions = KnowledgeIndexBuilder.quickActions(for: item)

            if item.route != nil {
                #expect(actions.contains { action in
                    switch action {
                    case .openGuide, .openScreen, .openCity, .openProvince:
                        return true
                    default:
                        return false
                    }
                }, "Missing navigation action for \(item.id)")
            }

            if !item.sources.compactMap(\.url).isEmpty {
                #expect(actions.contains { action in
                    if case .openSource = action { return true }
                    return false
                }, "Missing source action for \(item.id)")
            }

            #expect(actions.contains { action in
                if case .save = action { return true }
                return false
            }, "Missing save action for \(item.id)")

            #expect(actions.contains { action in
                if case .share = action { return true }
                return false
            }, "Missing share action for \(item.id)")
        }
    }

    @Test func localPartnersAreIndexedForEverySupportedCityAndCoreCategory() {
        let index = KnowledgeIndex.shared
        let partners = index.items.filter { $0.type == .localPartner }
        let cities = Set(CityDashboardContentData.supportedCityNames)
        let indexedCities = Set(partners.compactMap(\.city))
        let requiredSubcategories: Set<String> = [
            "Hotels",
            "Restaurants",
            "Cafes",
            "Immigration Lawyers",
            "Clinics",
            "Dentists",
            "Banks",
            "Real Estate",
            "Bike Rental",
            "Moving Companies",
            "Dutch Language Schools",
            "Universities",
            "Gyms",
            "Shopping"
        ]
        let indexedSubcategories = Set(partners.map(\.category))

        #expect(cities.isSubset(of: indexedCities))
        #expect(requiredSubcategories.isSubset(of: indexedSubcategories))
        #expect(partners.allSatisfy { !$0.sources.compactMap(\.url).isEmpty })
        #expect(AppSearchEngine().search("dentist Rotterdam", language: .english, activePersona: .worker).contains { $0.item.type == .localPartner && $0.item.city == "Rotterdam" })
        #expect(AppSearchEngine().search("language school Eindhoven", language: .english, activePersona: .student).contains { $0.item.type == .localPartner && $0.item.city == "Eindhoven" })
    }

    @Test func studentEindhovenScenarioConnectsLifeStepsAndRealLocalServices() {
        let index = KnowledgeIndex.shared
        let scenario = index.itemsByID["scenario:student-eindhoven"]
        #expect(scenario != nil)
        #expect(scenario?.city == "Eindhoven")
        #expect(scenario?.personaTags.contains(.student) == true)

        let neighborIDs = Set(index.graph.neighbors(
            of: "scenario:student-eindhoven",
            in: index.itemsByID,
            limit: 20
        ).map(\.id))

        let requiredNeighborIDs: Set<String> = [
            "municipality:eindhoven",
            "topic:registration-bsn",
            "topic:digid",
            "topic:health-insurance",
            "topic:banking",
            "topic:transport-ov",
            "topic:language-schools-and-integration",
            "topic:universities-and-student-administration",
            "topic:student-housing",
            "localPartner:tu-eindhoven",
            "localPartner:municipality-eindhoven-service-center",
            "localPartner:helpling-eindhoven"
        ]

        #expect(requiredNeighborIDs.isSubset(of: neighborIDs))

        let results = index.search("student Eindhoven", language: .english, activePersona: .student, limit: 5)
        #expect(results.contains { $0.item.id == "scenario:student-eindhoven" })
    }

    @Test func indexedContentHasAssignedPersonaTags() {
        for item in KnowledgeIndex.shared.items {
            #expect(!item.personaTags.isEmpty, "Missing persona tags for \(item.id)")
        }
    }

    @Test func selectedPersonaPersistsAcrossAppStateInstances() {
        let suiteName = "YouNewTests.selectedPersonaPersistsAcrossAppStateInstances"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let firstState = AppStateViewModel(defaults: defaults)
        firstState.selectedUserStatus = .student

        let restoredState = AppStateViewModel(defaults: defaults)
        #expect(restoredState.selectedUserStatus == .student)

        restoredState.resetPersonalState()
        let resetState = AppStateViewModel(defaults: defaults)
        #expect(resetState.selectedUserStatus == nil)
    }

    @Test func bsnSearchReturnsRouteSourceAndGraphContext() {
        let results = AppSearchEngine().search("How do I get BSN?", language: .english, activePersona: .worker)
        let titles = results.map { $0.item.title(.english) }

        #expect(titles.contains { $0.localizedCaseInsensitiveContains("BSN") })
        #expect(results.contains { !$0.item.sources.isEmpty })
        #expect(results.contains { $0.item.route != nil })
        #expect(results.flatMap(\.graphNeighbors).contains { $0.title(.english).localizedCaseInsensitiveContains("DigiD") })
        #expect(results.flatMap(\.quickActions).contains { action in
            if case .openSource = action { return true }
            return false
        })
    }

    @Test func healthInsuranceSearchFindsGuideAndOfficialSources() {
        let context = context(persona: .worker, screen: .search, category: "Search")
        let result = AppSearchEngine().answerContext(for: "I need health insurance", language: .english, context: context)

        #expect(result.summary?.localizedCaseInsensitiveContains("health insurance") == true)
        #expect(result.sources.contains { $0.title.localizedCaseInsensitiveContains("Government") || $0.title.localizedCaseInsensitiveContains("Zorg") })
        #expect(result.destination != nil)
    }

    @Test func cityAndProvinceSearchAdaptToContext() {
        let context = AIContext(
            screen: .search,
            category: "Search",
            topicTitle: "Leiden",
            topicSummary: nil,
            officialSources: [],
            lastReviewed: nil,
            userLanguage: .english,
            userSituation: nil,
            selectedCity: "Leiden",
            selectedProvince: "Zuid-Holland",
            savedItemTitles: [],
            disclaimer: "",
            activePersonaTag: .worker
        )

        let results = AppSearchEngine().search("municipality registration", language: .english, context: context, activePersona: .worker, limit: 12)

        #expect(results.contains { $0.item.city == "Leiden" || $0.item.province == "Zuid-Holland" })
        #expect(results.contains { $0.item.route != nil })
    }

    @Test func directCityAndProvinceSearchReturnTypedActions() {
        let context = AIContext(
            screen: .search,
            category: "Search",
            topicTitle: nil,
            topicSummary: nil,
            officialSources: [],
            lastReviewed: nil,
            userLanguage: .english,
            userSituation: nil,
            selectedCity: nil,
            selectedProvince: nil,
            savedItemTitles: [],
            disclaimer: "",
            activePersonaTag: .tourist,
            personaSearchScope: .allContentWithOutsidePathWarning
        )

        let cityResults = AppSearchEngine().search(
            "Tell me about Rotterdam city",
            language: .english,
            context: context,
            activePersona: .tourist,
            scope: .allContentWithOutsidePathWarning,
            limit: 8
        )
        #expect(cityResults.first?.item.type == .city)
        #expect(cityResults.first?.item.city == "Rotterdam")

        let cityResponse = AIResponseComposer.compose(
            query: "Tell me about Rotterdam city",
            language: .english,
            context: context
        )
        #expect(cityResponse?.quickActions.contains {
            $0.kind == .openCity && $0.destinationID == "city:rotterdam"
        } == true)

        let provinceResults = AppSearchEngine().search(
            "North Holland province",
            language: .english,
            context: context,
            activePersona: .tourist,
            scope: .allContentWithOutsidePathWarning,
            limit: 8
        )
        #expect(provinceResults.first?.item.type == .province)
        #expect(provinceResults.first?.item.province == "Noord-Holland")

        let provinceResponse = AIResponseComposer.compose(
            query: "North Holland province",
            language: .english,
            context: context
        )
        #expect(provinceResponse?.quickActions.contains {
            $0.kind == .openProvince && $0.destinationID == "province:noord-holland"
        } == true)
    }

    @Test func assistantEngineLeavesCityAndProvinceSearchQueriesToComposer() {
        let context = context(
            persona: .worker,
            screen: .assistant,
            category: "Assistant",
            selectedCity: "Leiden",
            selectedProvince: "Zuid-Holland"
        )

        #expect(AssistantAnswerEngine.getAssistantAnswer(
            userText: "Tell me about Rotterdam city",
            language: .english,
            context: context
        ) == nil)
        #expect(AssistantAnswerEngine.getAssistantAnswer(
            userText: "North Holland province",
            language: .english,
            context: context
        ) == nil)
    }

    @Test func allIndexedRoutesResolveToLiveDestinations() {
        for item in KnowledgeIndex.shared.items where item.route != nil {
            guard let route = item.route else { continue }

            if let routeID = AppNavigationResolver.routeID(from: route) ?? item.routeID {
                #expect(AppNavigationResolver.destination(for: routeID) != nil, "Route ID \(routeID) for \(item.id) should resolve")
            }

            switch route {
            case .guideArticle(let sectionID, let articleID):
                #expect(GuideContent.article(sectionID: sectionID, articleID: articleID) != nil, "Dead guide article route for \(item.id)")
            case .guideSection(let sectionID):
                #expect(GuideContent.section(id: sectionID) != nil, "Dead guide section route for \(item.id)")
            case .beginnerGuide(let id):
                #expect(MockBeginnerGuidesData.items.contains { $0.id == id }, "Dead beginner guide route for \(item.id)")
            case .searchAnswer(let id):
                #expect(MockSearchAnswersData.items.contains { $0.id == id }, "Dead search answer route for \(item.id)")
            case .provinceDetail(let province):
                #expect(NLProvince.all.contains { $0.name == province || $0.id == province }, "Dead province route for \(item.id)")
            case .nlCityDetail(let cityID):
                #expect(NLCity.all.contains { $0.id == cityID }, "Dead city route for \(item.id)")
            case .checklist(let id):
                #expect(MockChecklistData.items.contains { $0.id == id }, "Dead checklist route for \(item.id)")
            case .fineInfo(let id):
                #expect(MockFineInfoData.items.contains { $0.id == id }, "Dead fine route for \(item.id)")
            case .institution(let name):
                #expect(MockInstitutionsData.items.contains { $0.name.caseInsensitiveCompare(name) == .orderedSame }, "Dead institution route for \(item.id)")
            case .dutchTerm(let id):
                #expect(MockDutchTermsData.items.contains { $0.id == id }, "Dead Dutch term route for \(item.id)")
            case .letter(let title):
                #expect(MockLettersData.examples.contains { $0.title.caseInsensitiveCompare(title) == .orderedSame }, "Dead letter route for \(item.id)")
            case .mistake(let id):
                #expect(MockNewcomerMistakesData.items.contains { $0.id == id }, "Dead mistake route for \(item.id)")
            case .ruleTopic(let id):
                #expect(MockRulesGuideData.topics.contains { $0.id == id }, "Dead rule topic route for \(item.id)")
            case .ruleScenario(let id):
                #expect(MockRulesGuideData.scenarios.contains { $0.id == id }, "Dead rule scenario route for \(item.id)")
            case .resource(let id):
                #expect(MockResourcesData.items.contains { $0.id == id }, "Dead resource route for \(item.id)")
            case .knmModule(let id):
                #expect(KNMGuideData.module(with: id) != nil, "Dead KNM module route for \(item.id)")
            case .dutchA1A2Module(let id):
                #expect(DutchA1A2CourseData.module(with: id) != nil, "Dead Dutch course route for \(item.id)")
            case .scamWarning(let id):
                #expect(MockScamWarningsData.items.contains { $0.id == id }, "Dead scam-warning route for \(item.id)")
            default:
                break
            }
        }
    }

    @Test func localSearchStaysUnderPerformanceBudget() {
        let engine = AppSearchEngine()
        _ = KnowledgeIndex.shared.items.count
        _ = engine.search("registration tax housing healthcare municipality work transport", language: .english, limit: 12)

        let elapsed = (0..<5).map { _ in
            let start = ContinuousClock.now
            _ = engine.search("registration tax housing healthcare municipality work transport", language: .english, limit: 12)
            return start.duration(to: .now)
        }.min() ?? .seconds(1)

        #expect(elapsed < .milliseconds(200))
    }

    @Test func localComposerReturnsDynamicSectionsAndActions() {
        let context = AIContext(
            screen: .search,
            category: "Search",
            topicTitle: nil,
            topicSummary: nil,
            officialSources: [],
            lastReviewed: nil,
            userLanguage: .english,
            userSituation: nil,
            selectedCity: "Leiden",
            selectedProvince: "Zuid-Holland",
            savedItemTitles: [],
            disclaimer: "",
            activePersonaTag: .worker
        )
        let response = AIResponseComposer.compose(
            query: "How do I get BSN?",
            language: .english,
            context: context
        )

        #expect(response?.sections.contains { $0.title == "Answer" } == true)
        #expect(response?.sections.contains { $0.title == "What This Means" } == true)
        #expect(response?.sections.contains { $0.title == "What To Do Next" } == true)
        #expect(response?.sections.contains { $0.title == "Useful Actions" } == true)
        #expect(response?.sections.contains { $0.title == "Official Source" } == true)
        #expect(response?.sections.contains { ["Requirements", "Checklist", "Warnings", "Related Topics"].contains($0.title) } == true)
        #expect(response?.quickActions.contains { $0.kind == .openGuide || $0.kind == .openScreen } == true)
        #expect(response?.quickActions.contains { $0.kind == .openSource } == true)
        #expect(response?.quickActions.contains { $0.kind == .openCity && $0.destinationID?.hasPrefix("city:") == true } == true)
        #expect(response?.quickActions.contains { $0.kind == .openProvince && $0.destinationID?.hasPrefix("province:") == true } == true)
        #expect(response?.quickActions.contains { $0.kind == .save } == true)
        #expect(response?.quickActions.contains { $0.kind == .share } == true)
        #expect(response?.quickActions.contains { $0.kind == .relatedTopic } == true)
    }

    @Test func localComposerDoesNotExposeEnglishActionsInRussianSession() {
        let context = AIContext(
            screen: .assistant,
            category: "Ассистент",
            topicTitle: nil,
            topicSummary: nil,
            officialSources: [],
            lastReviewed: nil,
            userLanguage: .russian,
            userSituation: nil,
            selectedCity: "Leiden",
            selectedProvince: "Zuid-Holland",
            savedItemTitles: [],
            disclaimer: "",
            activePersonaTag: .worker,
            personaSearchScope: .allContentWithOutsidePathWarning
        )
        let response = AIResponseComposer.compose(
            query: "Что важно знать и сделать в первую очередь как Украинец в Нидерландах?",
            language: .russian,
            context: context
        )

        #expect(response != nil)
        #expect(response?.quickActions.allSatisfy { AIResponseLanguageGuard.isVisibleTextAcceptable($0.title, for: .russian) } == true)
        #expect(response?.sections.allSatisfy {
            AIResponseLanguageGuard.isVisibleTextAcceptable($0.title, for: .russian) &&
            AIResponseLanguageGuard.isVisibleTextAcceptable($0.body, for: .russian)
        } == true)
        #expect(response.map { AIResponseLanguageGuard.isResponseAcceptable($0, for: .russian) } == true)
    }

    @Test func missingInformationResponseStillLinksSourceAndContextDestinations() {
        let context = AIContext(
            screen: .search,
            category: "Search",
            topicTitle: nil,
            topicSummary: nil,
            officialSources: [],
            lastReviewed: nil,
            userLanguage: .english,
            userSituation: nil,
            selectedCity: "Leiden",
            selectedProvince: "Zuid-Holland",
            savedItemTitles: [],
            disclaimer: "",
            activePersonaTag: .worker
        )
        let response = AIResponseComposer.compose(
            query: "xqzv plorbnax flibbertigibbet",
            language: .english,
            context: context
        )

        #expect(response?.isVerified == false)
        #expect(response?.sources.isEmpty == false)
        #expect(response?.quickActions.contains { $0.kind == .openSource } == true)
        #expect(response?.quickActions.contains { $0.kind == .openCity } == true)
        #expect(response?.quickActions.contains { $0.kind == .openProvince } == true)
        #expect(response?.quickActions.contains { $0.kind == .relatedTopic } == true)
        #expect(response?.quickActions.contains { $0.kind == .save } == true)
        #expect(response?.quickActions.contains { $0.kind == .share } == true)
    }

    @Test func representativeAssistantQueriesUseKnowledgeNavigationSourcesAndActions() {
        let context = AIContext(
            screen: .assistant,
            category: "Assistant",
            topicTitle: nil,
            topicSummary: nil,
            officialSources: [],
            lastReviewed: nil,
            userLanguage: .english,
            userSituation: "New arrival",
            selectedCity: "Leiden",
            selectedProvince: "Zuid-Holland",
            savedItemTitles: [],
            disclaimer: "",
            activePersonaTag: .worker,
            personaSearchScope: .allContentWithOutsidePathWarning
        )
        let queries = [
            "How do I get BSN?",
            "I need health insurance",
            "How do I activate DigiD?",
            "I got a CJIB letter",
            "How do I avoid beginner transport mistakes?",
            "Find housing help",
            "Where can I learn Dutch?",
            "Tell me about Rotterdam city",
            "North Holland province"
        ]

        for query in queries {
            let response = AIResponseComposer.compose(query: query, language: .english, context: context)
            #expect(response != nil, "Missing response for \(query)")
            #expect(response?.isVerified == true, "Expected verified app knowledge for \(query)")
            #expect(response?.sources.isEmpty == false, "Missing source for \(query)")
            #expect(response?.sections.isEmpty == false, "Missing structured sections for \(query)")
            #expect(response?.quickActions.contains { $0.kind == .openGuide || $0.kind == .openScreen || $0.kind == .openCity || $0.kind == .openProvince } == true, "Missing navigation action for \(query)")
            #expect(response?.quickActions.contains { $0.kind == .openSource } == true, "Missing source action for \(query)")
            #expect(response?.quickActions.contains { $0.kind == .save } == true, "Missing save action for \(query)")
            #expect(response?.quickActions.contains { $0.kind == .share } == true, "Missing share action for \(query)")
            #expect(response?.quickActions.contains { $0.kind == .relatedTopic } == true, "Missing related action for \(query)")

            for action in response?.quickActions ?? [] {
                guard let destinationID = action.destinationID else { continue }
                #expect(AppNavigationResolver.destination(for: destinationID) != nil, "Dead quick-action route \(destinationID) for \(query)")
            }
            if let destinationID = response?.appDestinationID {
                #expect(AppNavigationResolver.destination(for: destinationID) != nil, "Dead primary route \(destinationID) for \(query)")
            }
        }
    }

    @Test func unverifiedFallbackResponsesStillExposeBasicActions() {
        let responses = [
            AIResponse.empty(language: .english),
            AIResponse.unverified(language: .english)
        ]

        for response in responses {
            #expect(response.isVerified == false)
            #expect(response.sources.contains { $0.url?.absoluteString == "https://www.government.nl" })
            #expect(response.quickActions.contains { $0.kind == .openScreen && $0.destinationID == "search" })
            #expect(response.quickActions.contains { $0.kind == .openScreen && $0.destinationID == "officialSources" })
            #expect(response.quickActions.contains { $0.kind == .openSource })
            #expect(response.quickActions.contains { $0.kind == .save })
            #expect(response.quickActions.contains { $0.kind == .share })
            #expect(response.quickActions.contains { $0.kind == .relatedTopic })
        }
    }

    @Test func navigationResolverRoundTripsIndexedDestinations() {
        for item in KnowledgeIndex.shared.items where item.route != nil {
            guard let routeID = AppNavigationResolver.routeID(from: item.route) else { continue }
            #expect(AppNavigationResolver.destination(for: routeID) != nil, "Resolver should round-trip \(routeID)")
        }
    }

    @Test func healthInsuranceWorkflowAsksRequiredFollowups() {
        let context = context(persona: .worker)
        let started = AIWorkflowEngine.startIfNeeded(
            query: "I need health insurance",
            language: .english,
            context: context
        )

        #expect(started?.workflow.step == .asksWorkStatus)
        #expect(started?.response.quickActions.contains { $0.kind == .askFollowUp && $0.title.localizedCaseInsensitiveContains("work") } == true)

        let registeredQuestion = started.flatMap {
            AIWorkflowEngine.advance(workflow: $0.workflow, answer: "yes work", language: .english, context: context)
        }
        #expect(registeredQuestion?.workflow?.step == .asksRegistrationStatus)
        #expect(registeredQuestion?.response.quickActions.contains { $0.kind == .askFollowUp && $0.title.localizedCaseInsensitiveContains("registered") } == true)

        let final = registeredQuestion.flatMap {
            $0.workflow.flatMap { AIWorkflowEngine.advance(workflow: $0, answer: "yes registered", language: .english, context: context) }
        }
        #expect(final?.workflow == nil)
        #expect(final?.response.sections.contains { $0.title == "Workflow result" } == true)
        #expect(final?.response.quickActions.contains { $0.kind == .openGuide || $0.kind == .openScreen } == true)
    }

    @Test func bsnWorkflowRoutesThroughMunicipalityDocumentsAndDigiD() {
        let context = context(persona: .worker)
        let started = AIWorkflowEngine.startIfNeeded(
            query: "How do I get BSN?",
            language: .english,
            context: context
        )

        #expect(started?.workflow.kind == .bsnRegistration)
        #expect(started?.workflow.step == .asksAddressStatus)
        #expect(started?.response.quickActions.contains { $0.kind == .askFollowUp } == true)
        #expect(started?.response.quickActions.contains { $0.kind == .askFollowUp && $0.query == "yes address" } == true)
        #expect(started?.response.quickActions.contains { $0.kind == .askFollowUp && $0.query == "no address" } == true)

        let digidQuestion = started.flatMap {
            AIWorkflowEngine.advance(workflow: $0.workflow, answer: "yes address", language: .english, context: context)
        }
        #expect(digidQuestion?.workflow?.step == .asksDigiDNeed)
        #expect(digidQuestion?.response.quickActions.contains { $0.kind == .askFollowUp && $0.query == "yes digid" } == true)
        #expect(digidQuestion?.response.quickActions.contains { $0.kind == .askFollowUp && $0.query == "no digid" } == true)

        let final = digidQuestion.flatMap {
            $0.workflow.flatMap { AIWorkflowEngine.advance(workflow: $0, answer: "yes digid", language: .english, context: context) }
        }

        #expect(final?.workflow == nil)
        #expect(final?.response.quickActions.contains { $0.destinationID == "government" } == true)
        #expect(final?.response.quickActions.contains { $0.destinationID == "journeyDocuments" } == true)
        #expect(final?.response.quickActions.contains { $0.destinationID == "article:documents:bsn" } == true)
        #expect(final?.response.quickActions.contains { $0.kind == .openSource } == true)
    }

    @Test func digidWorkflowRoutesToBSNWhenMissing() {
        let context = context(persona: .worker)
        let started = AIWorkflowEngine.startIfNeeded(
            query: "I need DigiD",
            language: .english,
            context: context
        )

        #expect(started?.workflow.kind == .digid)
        #expect(started?.workflow.step == .asksBSNStatus)

        let final = started.flatMap {
            AIWorkflowEngine.advance(workflow: $0.workflow, answer: "no bsn", language: .english, context: context)
        }

        #expect(final?.workflow == nil)
        #expect(final?.response.answer.localizedCaseInsensitiveContains("BSN") == true)
        #expect(final?.response.quickActions.contains { $0.destinationID == "journeyDocuments" } == true)
        #expect(final?.response.quickActions.contains { $0.destinationID == "article:documents:digid" } == true)
    }

    @Test func fineLetterWorkflowWarnsAndRoutesToFinesLettersSources() {
        let context = context(persona: .worker)
        let started = AIWorkflowEngine.startIfNeeded(
            query: "I got a CJIB letter",
            language: .english,
            context: context
        )

        #expect(started?.workflow.kind == .fineLetter)
        #expect(started?.response.sections.contains { $0.body.localizedCaseInsensitiveContains("Do not paste") } == true)

        let final = started.flatMap {
            AIWorkflowEngine.advance(workflow: $0.workflow, answer: "fine cjib", language: .english, context: context)
        }

        #expect(final?.workflow == nil)
        #expect(final?.response.quickActions.contains { $0.destinationID == "fines" } == true)
        #expect(final?.response.quickActions.contains { $0.destinationID == "letters" } == true)
        #expect(final?.response.quickActions.contains { $0.destinationID == "officialSources" } == true)
    }

    @Test func housingWorkflowBranchesBySituation() {
        let context = context(persona: .worker)
        let started = AIWorkflowEngine.startIfNeeded(
            query: "I need housing help",
            language: .english,
            context: context
        )

        #expect(started?.workflow.kind == .housing)
        #expect(started?.workflow.step == .asksHousingStatus)

        let final = started.flatMap {
            AIWorkflowEngine.advance(workflow: $0.workflow, answer: "rental problem", language: .english, context: context)
        }

        #expect(final?.workflow == nil)
        #expect(final?.response.quickActions.contains { $0.destinationID == "housing" } == true)
        #expect(final?.response.quickActions.contains { $0.kind == .relatedTopic } == true)
    }

    @Test func whatNextWorkflowUsesContextAndChecklistRoutes() {
        let context = context(
            persona: .worker,
            screen: .home,
            category: "Home",
            topicTitle: nil,
            topicSummary: "2/8 checklist",
            userSituation: "New arrival",
            selectedCity: "Leiden",
            selectedProvince: "Zuid-Holland",
            savedItemTitles: ["BSN"],
            journeyProgress: "2/8 checklist"
        )

        let started = AIWorkflowEngine.startIfNeeded(
            query: "What should I do next?",
            language: .english,
            context: context
        )

        #expect(started?.workflow.kind == .whatNext)
        #expect(started?.response.answer.localizedCaseInsensitiveContains("Leiden") == true)
        #expect(started?.response.appDestinationID?.hasPrefix("checklist:") == true)
        #expect(started?.response.nextStep?.destinationID?.hasPrefix("checklist:") == true)
        #expect(started?.response.sections.contains { $0.title == "Checklist" } == true)
        #expect(started?.response.quickActions.contains { $0.destinationID?.hasPrefix("checklist:") == true } == true)
        #expect(started?.response.quickActions.contains { $0.destinationID == "firstSteps" } == true)
        #expect(started?.response.quickActions.contains { $0.kind == .openSource } == true)
    }

    @Test func whatNextWorkflowAvoidsRepeatingCurrentChecklistRoute() {
        guard let first = MockChecklistData.items.first else { return }
        let currentRouteID = "checklist:\(first.id.uuidString)"
        let context = context(
            persona: .worker,
            screen: .home,
            category: "Home",
            topicTitle: nil,
            topicSummary: "0/\(MockChecklistData.items.count) checklist",
            userSituation: "New arrival",
            selectedCity: "Leiden",
            selectedProvince: "Zuid-Holland",
            savedItemTitles: [],
            currentRouteID: currentRouteID,
            recentRouteIDs: [currentRouteID],
            completedChecklistItemIDs: [],
            completedGuideIDs: [],
            journeyProgress: "0/\(MockChecklistData.items.count) checklist"
        )

        let started = AIWorkflowEngine.startIfNeeded(
            query: "What should I do next?",
            language: .english,
            context: context
        )

        #expect(started?.response.appDestinationID != currentRouteID)
        #expect(started?.response.appDestinationID?.hasPrefix("checklist:") == true)
    }

    @Test func workflowQuickActionDestinationsResolve() {
        let context = context(persona: .worker)
        let healthStart = AIWorkflowEngine.startIfNeeded(query: "I need health insurance", language: .english, context: context)
        let healthRegistration = healthStart.flatMap {
            AIWorkflowEngine.advance(workflow: $0.workflow, answer: "yes work", language: .english, context: context)
        }
        let healthFinal = healthRegistration?.workflow.flatMap {
            AIWorkflowEngine.advance(workflow: $0, answer: "yes registered", language: .english, context: context)
        }
        let responses: [AIResponse?] = [
            healthStart?.response,
            healthRegistration?.response,
            healthFinal?.response,
            AIWorkflowEngine.startIfNeeded(query: "How do I get BSN?", language: .english, context: context)?.response,
            AIWorkflowEngine.startIfNeeded(query: "I need DigiD", language: .english, context: context)?.response,
            AIWorkflowEngine.startIfNeeded(query: "I got a CJIB letter", language: .english, context: context)?.response,
            AIWorkflowEngine.startIfNeeded(query: "I need housing help", language: .english, context: context)?.response,
            AIWorkflowEngine.startIfNeeded(query: "What should I do next?", language: .english, context: context)?.response
        ]

        for response in responses.compactMap({ $0 }) {
            for action in response.quickActions {
                guard let destinationID = action.destinationID else { continue }
                #expect(AppNavigationResolver.destination(for: destinationID) != nil, "Workflow action destination should resolve: \(destinationID)")
            }
        }
    }

    @Test func aiContextCarriesRouteSearchProgressAndCompletionSignals() {
        let defaultsKey = "question_search_recent_v1"
        let previous = UserDefaults.standard.stringArray(forKey: defaultsKey)
        UserDefaults.standard.set(["BSN appointment", "health insurance"], forKey: defaultsKey)
        defer { UserDefaults.standard.set(previous, forKey: defaultsKey) }

        let appState = AppStateViewModel()
        appState.selectedCity = "Leiden"
        appState.selectedUserStatus = .worker
        appState.addRecentRouteID("guide:documents")
        appState.markGuideCompleted(routeID: "guide:documents")
        appState.markGuideCompleted(routeID: "search")
        if let first = appState.checklistItems.first {
            appState.toggleChecklistItem(first)
        }

        let context = AIContextBuilder.automaticContext(
            selectedTab: .search,
            activeDestination: .guideArticle(sectionID: "documents", articleID: "bsn"),
            language: .english,
            appState: appState
        )

        #expect(context.currentRouteID == "article:documents:bsn")
        #expect(context.selectedCity == "Leiden")
        #expect(context.selectedProvince == "Zuid-Holland")
        #expect(context.recentRouteIDs.contains("guide:documents"))
        #expect(context.lastSearches.contains("BSN appointment"))
        #expect(context.completedChecklistItemIDs.isEmpty == false)
        #expect(context.completedGuideIDs.contains("guide:documents"))
        #expect(context.completedGuideIDs.contains("search") == false)
        #expect(context.journeyProgress?.contains("checklist") == true)
    }
}
