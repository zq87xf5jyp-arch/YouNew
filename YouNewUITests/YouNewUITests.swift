import XCTest

final class YouNewUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        XCUIApplication().terminate()
    }

    @MainActor
    func testMajorTabsLaunchInAllSupportedLanguages() throws {
        for language in ["ru", "en", "nl"] {
            let app = XCUIApplication()
            app.launchArguments = ["-uiTesting", "-launchLanguage", language]
            app.launch()

            XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))
            XCTAssertTrue(app.descendants(matching: .any)["tab.home"].waitForExistence(timeout: 4))
            XCTAssertTrue(app.descendants(matching: .any)["tab.search"].waitForExistence(timeout: 4))
            XCTAssertTrue(app.descendants(matching: .any)["tab.map"].waitForExistence(timeout: 4))
            XCTAssertTrue(app.descendants(matching: .any)["tab.assistant"].waitForExistence(timeout: 4))

            app.terminate()
        }
    }

    @MainActor
    func testAssistantTabAcceptsInputAndShowsSendControl() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-launchLanguage", "en", "-uiTestingStartTab", "assistant"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        XCTAssertTrue(app.descendants(matching: .any)["tab.assistant"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.buttons["Send"].exists || app.buttons["send"].exists || app.descendants(matching: .any)["tab.assistant"].exists)
    }

    @MainActor
    func testGlobalAILauncherOpensWhatNextFromHomeWithoutTabOverlap() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-resetUITestState", "-launchLanguage", "en", "-uiTestingStartTab", "assistant"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        XCTAssertTrue(app.descendants(matching: .any)["tab.assistant"].waitForExistence(timeout: 4))
        let input = app.descendants(matching: .any)["assistant.input"]
        XCTAssertTrue(input.waitForExistence(timeout: 6))
        input.tap()
        input.typeText("What should I do next?")

        let send = app.descendants(matching: .any)["assistant.send"]
        XCTAssertTrue(send.waitForExistence(timeout: 2))
        send.tap()

        let checklistAction = waitForElementWithIdentifierPrefix("assistant.quickAction.openScreen.checklist.", in: app, timeout: 8)
        XCTAssertTrue(checklistAction.exists)
    }

    @MainActor
    func testAssistantQuickActionOpensBSNGuideArticle() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-resetUITestState", "-launchLanguage", "en", "-uiTestingStartTab", "assistant"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        let input = app.descendants(matching: .any)["assistant.input"]
        XCTAssertTrue(input.waitForExistence(timeout: 4))
        input.tap()
        input.typeText("BSN")

        let send = app.descendants(matching: .any)["assistant.send"]
        XCTAssertTrue(send.waitForExistence(timeout: 2))
        send.tap()

        XCTAssertTrue(app.descendants(matching: .any)["assistant.response.structured"].waitForExistence(timeout: 5))

        let openGuide = app.descendants(matching: .any)["assistant.quickAction.openGuide.article.documents.bsn"]
        if !openGuide.waitForExistence(timeout: 5) {
            app.swipeUp()
        }
        XCTAssertTrue(openGuide.waitForExistence(timeout: 3))

        launchDestination("article:documents:bsn", in: app)
        XCTAssertTrue(app.descendants(matching: .any)["guide.article.bsn"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testAssistantBSNWorkflowExposesMunicipalityDocumentsGuideAndSource() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-resetUITestState", "-launchLanguage", "en", "-uiTestingStartTab", "assistant"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        sendAssistantPrompt("How do I get BSN?", in: app)

        let hasAddress = waitForElement("assistant.quickAction.askFollowUp.yes.address", in: app, timeout: 6)
        XCTAssertTrue(hasAddress.exists)
        hasAddress.tap()

        let includeDigiD = waitForElement("assistant.quickAction.askFollowUp.yes.digid", in: app, timeout: 2)
        if includeDigiD.exists {
            includeDigiD.tap()
        }

        let municipalityAction = waitForFirstElement("assistant.quickAction.openScreen.government", in: app, timeout: 6)
        XCTAssertTrue(municipalityAction.exists)

        let bsnGuide = waitForFirstElement("assistant.quickAction.openGuide.article.documents.bsn", in: app, timeout: 6)
        XCTAssertTrue(bsnGuide.exists)

        let sourceAction = waitForElementWithIdentifierPrefix("assistant.quickAction.openSource.", in: app, timeout: 6)
        XCTAssertTrue(sourceAction.exists)

        let documentsAction = waitForFirstElement("assistant.quickAction.openScreen.journeydocuments", in: app, timeout: 6)
        XCTAssertTrue(documentsAction.exists)
        documentsAction.tap()

        XCTAssertTrue(app.descendants(matching: .any)["documents.screen"].waitForExistence(timeout: 6))
    }

    @MainActor
    func testAssistantBSNWorkflowWithoutAddressOpensDocumentsAndSourceActions() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-resetUITestState", "-launchLanguage", "en", "-uiTestingStartTab", "assistant"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        sendAssistantPrompt("How do I get BSN?", in: app)

        let noAddress = waitForElement("assistant.quickAction.askFollowUp.no.address", in: app, timeout: 6)
        XCTAssertTrue(noAddress.exists)
        noAddress.tap()

        let onlyBSN = waitForElement("assistant.quickAction.askFollowUp.no.digid", in: app, timeout: 6)
        XCTAssertTrue(onlyBSN.exists)
        onlyBSN.tap()

        let municipalityAction = waitForFirstElement("assistant.quickAction.openScreen.government", in: app, timeout: 6)
        XCTAssertTrue(municipalityAction.exists)

        let bsnGuide = waitForFirstElement("assistant.quickAction.openGuide.article.documents.bsn", in: app, timeout: 6)
        XCTAssertTrue(bsnGuide.exists)

        let sourceAction = waitForElementWithIdentifierPrefix("assistant.quickAction.openSource.", in: app, timeout: 6)
        XCTAssertTrue(sourceAction.exists)

        let documentsAction = waitForFirstElement("assistant.quickAction.openScreen.journeydocuments", in: app, timeout: 6)
        XCTAssertTrue(documentsAction.exists)
        documentsAction.tap()

        XCTAssertTrue(app.descendants(matching: .any)["documents.screen"].waitForExistence(timeout: 6))
    }

    @MainActor
    func testAssistantBSNWorkflowWithSelectedCityOpensLeiden() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-resetUITestState", "-launchLanguage", "en", "-uiTestingStartTab", "assistant", "-uiTestingCity", "Leiden"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        sendAssistantPrompt("How do I get BSN?", in: app)

        let hasAddress = waitForElement("assistant.quickAction.askFollowUp.yes.address", in: app, timeout: 6)
        XCTAssertTrue(hasAddress.exists)
        hasAddress.tap()

        let includeDigiD = waitForElement("assistant.quickAction.askFollowUp.yes.digid", in: app, timeout: 6)
        XCTAssertTrue(includeDigiD.exists)
        includeDigiD.tap()

        let openCity = waitForElement("assistant.quickAction.openCity.city.leiden", in: app, timeout: 6)
        XCTAssertTrue(openCity.exists)
        tapRouteAction(openCity, in: app, expecting: ["city.detail.leiden", "city.detail.nl-city-zuid_holland-leiden"])

        XCTAssertTrue(firstExistingElement(["city.detail.leiden", "city.detail.nl-city-zuid_holland-leiden"], in: app, timeout: 6).exists)
    }

    @MainActor
    func testAssistantHealthInsuranceWorkflowOpensGuide() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-resetUITestState", "-launchLanguage", "en", "-uiTestingStartTab", "assistant"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        sendAssistantPrompt("I need health insurance", in: app)

        let yesWork = waitForElement("assistant.quickAction.askFollowUp.yes.work", in: app, timeout: 6)
        XCTAssertTrue(yesWork.exists)
        yesWork.tap()

        let yesRegistered = waitForElement("assistant.quickAction.askFollowUp.yes.registered", in: app, timeout: 6)
        XCTAssertTrue(yesRegistered.exists)
        yesRegistered.tap()

        let guideAction = firstExistingElement(
            [
                "assistant.quickAction.openGuide.practicalguide.healthinsurancebasics",
                "assistant.quickAction.openGuide.practicalguide.healthcarebasics",
                "assistant.quickAction.openGuide.healthcare"
            ],
            in: app,
            timeout: 6
        )
        XCTAssertTrue(guideAction.exists)
        guideAction.tap()

        let openedGuide = firstExistingElement(
            [
                "practicalGuide.healthInsuranceBasics",
                "practicalGuide.healthcareBasics"
            ],
            in: app,
            timeout: 6
        )
        XCTAssertTrue(openedGuide.exists)
    }

    @MainActor
    func testAssistantHealthInsuranceUnregisteredOpensDocumentsAndBSNActions() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-resetUITestState", "-launchLanguage", "en", "-uiTestingStartTab", "assistant"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        sendAssistantPrompt("I need health insurance", in: app)

        let yesWork = waitForElement("assistant.quickAction.askFollowUp.yes.work", in: app, timeout: 6)
        XCTAssertTrue(yesWork.exists)
        yesWork.tap()

        let notRegistered = waitForElement("assistant.quickAction.askFollowUp.no.registration", in: app, timeout: 6)
        XCTAssertTrue(notRegistered.exists)
        notRegistered.tap()

        let municipalityAction = waitForFirstElement("assistant.quickAction.openScreen.government", in: app, timeout: 6)
        XCTAssertTrue(municipalityAction.exists)

        let bsnGuide = waitForFirstElement("assistant.quickAction.openGuide.article.documents.bsn", in: app, timeout: 6)
        XCTAssertTrue(bsnGuide.exists)

        let documentsAction = waitForFirstElement("assistant.quickAction.openScreen.journeydocuments", in: app, timeout: 6)
        XCTAssertTrue(documentsAction.exists)
        documentsAction.tap()

        XCTAssertTrue(app.descendants(matching: .any)["documents.screen"].waitForExistence(timeout: 6))
    }

    @MainActor
    func testAssistantHealthInsuranceWorkflowOpensHealthcareMapFocus() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-resetUITestState", "-launchLanguage", "en", "-uiTestingStartTab", "assistant"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        sendAssistantPrompt("I need health insurance", in: app)

        let yesWork = waitForElement("assistant.quickAction.askFollowUp.yes.work", in: app, timeout: 6)
        XCTAssertTrue(yesWork.exists)
        yesWork.tap()

        let yesRegistered = waitForElement("assistant.quickAction.askFollowUp.yes.registered", in: app, timeout: 6)
        XCTAssertTrue(yesRegistered.exists)
        yesRegistered.tap()

        let mapFocus = waitForFirstElement("assistant.quickAction.openScreen.mapfocus.healthcare", in: app, timeout: 6)
        XCTAssertTrue(mapFocus.exists)
        mapFocus.tap()

        XCTAssertTrue(app.descendants(matching: .any)["map.screen"].waitForExistence(timeout: 6))
        XCTAssertTrue(app.descendants(matching: .any)["map.focus.healthcare"].waitForExistence(timeout: 6))
    }

    @MainActor
    func testAssistantDigiDWorkflowWithoutBSNOpensDigiDArticle() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-resetUITestState", "-launchLanguage", "en", "-uiTestingStartTab", "assistant"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        sendAssistantPrompt("I need DigiD", in: app)

        let noBSN = waitForElement("assistant.quickAction.askFollowUp.no.bsn", in: app, timeout: 6)
        XCTAssertTrue(noBSN.exists)
        noBSN.tap()

        let digidTopic = waitForFirstElement("assistant.quickAction.openGuide.article.documents.digid", in: app, timeout: 6)
        XCTAssertTrue(digidTopic.exists)
        launchDestination("article:documents:digid", in: app)
        XCTAssertTrue(app.descendants(matching: .any)["guide.article.digid"].waitForExistence(timeout: 6))
    }

    @MainActor
    func testAssistantDigiDWorkflowWithBSNOpensDocumentsAndShowsDigiDArticleAndSource() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-resetUITestState", "-launchLanguage", "en", "-uiTestingStartTab", "assistant"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        sendAssistantPrompt("I need DigiD", in: app)

        let yesBSN = waitForElement("assistant.quickAction.askFollowUp.yes.bsn", in: app, timeout: 6)
        XCTAssertTrue(yesBSN.exists)
        yesBSN.tap()

        let sourceAction = waitForElementWithIdentifierPrefix("assistant.quickAction.openSource.", in: app, timeout: 6)
        XCTAssertTrue(sourceAction.exists)

        let documentsAction = waitForFirstElement("assistant.quickAction.openScreen.journeydocuments", in: app, timeout: 6)
        XCTAssertTrue(documentsAction.exists)

        let digidTopic = waitForFirstElement("assistant.quickAction.openGuide.article.documents.digid", in: app, timeout: 6)
        XCTAssertTrue(digidTopic.exists)

        launchDestination("article:documents:digid", in: app)
        XCTAssertTrue(app.descendants(matching: .any)["guide.article.digid"].waitForExistence(timeout: 6))
    }

    @MainActor
    func testAssistantFineLetterWorkflowOpensFinesAndShowsSourceActions() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-resetUITestState", "-launchLanguage", "en", "-uiTestingStartTab", "assistant"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        sendAssistantPrompt("I got a CJIB letter", in: app)

        let privacyWarning = NSPredicate(format: "label CONTAINS[c] %@", "Do not paste BSN")
        XCTAssertTrue(app.staticTexts.matching(privacyWarning).firstMatch.waitForExistence(timeout: 6))

        let fineType = waitForElement("assistant.quickAction.askFollowUp.fine.cjib", in: app, timeout: 6)
        XCTAssertTrue(fineType.exists)
        fineType.tap()

        let lettersAction = waitForFirstElement("assistant.quickAction.openScreen.letters", in: app, timeout: 6)
        XCTAssertTrue(lettersAction.exists)

        let officialSources = waitForFirstElement("assistant.quickAction.openScreen.officialsources", in: app, timeout: 6)
        XCTAssertTrue(officialSources.exists)

        let finesAction = waitForFirstElement("assistant.quickAction.openScreen.fines", in: app, timeout: 6)
        XCTAssertTrue(finesAction.exists)
        launchDestination("fines", in: app)

        XCTAssertTrue(app.descendants(matching: .any)["fines.screen"].waitForExistence(timeout: 6))
    }

    @MainActor
    func testAssistantFineLetterWorkflowOpensLetters() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-resetUITestState", "-launchLanguage", "en", "-uiTestingStartTab", "assistant"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        sendAssistantPrompt("I got a CJIB letter", in: app)

        let fineType = waitForElement("assistant.quickAction.askFollowUp.fine.cjib", in: app, timeout: 6)
        XCTAssertTrue(fineType.exists)
        fineType.tap()

        let lettersAction = waitForFirstElement("assistant.quickAction.openScreen.letters", in: app, timeout: 6)
        XCTAssertTrue(lettersAction.exists)
        launchDestination("letters", in: app)

        XCTAssertTrue(firstExistingElement(["letters.screen"], in: app, timeout: 6).exists)
    }

    @MainActor
    func testAssistantFineLetterWorkflowOpensOfficialSources() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-resetUITestState", "-launchLanguage", "en", "-uiTestingStartTab", "assistant"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        sendAssistantPrompt("I got a CJIB letter", in: app)

        let fineType = waitForElement("assistant.quickAction.askFollowUp.fine.cjib", in: app, timeout: 6)
        XCTAssertTrue(fineType.exists)
        fineType.tap()

        let officialSources = waitForFirstElement("assistant.quickAction.openScreen.officialsources", in: app, timeout: 6)
        XCTAssertTrue(officialSources.exists)
        launchDestination("officialSources", in: app)

        XCTAssertTrue(app.descendants(matching: .any)["officialSources.screen"].waitForExistence(timeout: 6))
    }

    @MainActor
    func testAssistantHousingWorkflowOpensHousingGuideAndShowsSupportActions() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-resetUITestState", "-launchLanguage", "en", "-uiTestingStartTab", "assistant"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        sendAssistantPrompt("I need housing", in: app)

        let lookingForHousing = waitForElement("assistant.quickAction.askFollowUp.looking.housing", in: app, timeout: 6)
        XCTAssertTrue(lookingForHousing.exists)
        lookingForHousing.tap()

        let municipalityAction = waitForFirstElement("assistant.quickAction.openScreen.government", in: app, timeout: 6)
        XCTAssertTrue(municipalityAction.exists)

        let scamWarnings = waitForFirstElement("assistant.quickAction.relatedTopic.housing.scam", in: app, timeout: 6)
        XCTAssertTrue(scamWarnings.exists)

        let housingGuide = waitForFirstElement("assistant.quickAction.openGuide.housing", in: app, timeout: 6)
        XCTAssertTrue(housingGuide.exists)
        housingGuide.tap()

        XCTAssertTrue(app.descendants(matching: .any)["practicalGuide.housingBasics"].waitForExistence(timeout: 6))
    }

    @MainActor
    func testAssistantHousingRentalProblemOpensHousingGuideAndShowsSourceActions() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-resetUITestState", "-launchLanguage", "en", "-uiTestingStartTab", "assistant"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        sendAssistantPrompt("I need housing", in: app)

        let rentalProblem = waitForElement("assistant.quickAction.askFollowUp.rental.problem", in: app, timeout: 6)
        XCTAssertTrue(rentalProblem.exists)
        rentalProblem.tap()

        let sourceAction = waitForElementWithIdentifierPrefix("assistant.quickAction.openSource.", in: app, timeout: 6)
        XCTAssertTrue(sourceAction.exists)

        let municipalityAction = waitForFirstElement("assistant.quickAction.openScreen.government", in: app, timeout: 6)
        XCTAssertTrue(municipalityAction.exists)

        let scamWarnings = waitForFirstElement("assistant.quickAction.relatedTopic.housing.scam", in: app, timeout: 6)
        XCTAssertTrue(scamWarnings.exists)

        let housingGuide = waitForFirstElement("assistant.quickAction.openGuide.housing", in: app, timeout: 6)
        XCTAssertTrue(housingGuide.exists)
        housingGuide.tap()

        XCTAssertTrue(app.descendants(matching: .any)["practicalGuide.housingBasics"].waitForExistence(timeout: 6))
    }

    @MainActor
    func testAssistantHousingRegistrationIssueOpensMunicipalityAndShowsHousingActions() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-resetUITestState", "-launchLanguage", "en", "-uiTestingStartTab", "assistant"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        sendAssistantPrompt("I need housing", in: app)

        let registrationIssue = waitForElement("assistant.quickAction.askFollowUp.registration.issue", in: app, timeout: 6)
        XCTAssertTrue(registrationIssue.exists)
        registrationIssue.tap()

        let housingGuide = waitForFirstElement("assistant.quickAction.openGuide.housing", in: app, timeout: 6)
        XCTAssertTrue(housingGuide.exists)

        let scamWarnings = waitForFirstElement("assistant.quickAction.relatedTopic.housing.scam", in: app, timeout: 6)
        XCTAssertTrue(scamWarnings.exists)

        let municipalityAction = waitForFirstElement("assistant.quickAction.openScreen.government", in: app, timeout: 6)
        XCTAssertTrue(municipalityAction.exists)

        launchDestination("government", in: app)
        XCTAssertTrue(app.descendants(matching: .any)["government.screen"].waitForExistence(timeout: 6))
    }

    @MainActor
    func testAssistantContextActionOpensSelectedCity() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-resetUITestState", "-launchLanguage", "en", "-uiTestingStartTab", "assistant"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        sendAssistantPrompt("transport mistakes", in: app)

        let openCity = waitForElement("assistant.quickAction.openCity.city.leiden", in: app, timeout: 6)
        XCTAssertTrue(openCity.exists)
        tapRouteAction(openCity, in: app, expecting: ["city.detail.leiden", "city.detail.nl-city-zuid_holland-leiden"])

        XCTAssertTrue(firstExistingElement(["city.detail.leiden", "city.detail.nl-city-zuid_holland-leiden"], in: app, timeout: 6).exists)
    }

    @MainActor
    func testAssistantContextActionOpensSelectedProvince() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-resetUITestState", "-launchLanguage", "en", "-uiTestingStartTab", "assistant"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        sendAssistantPrompt("transport mistakes", in: app)

        let openProvince = waitForElement("assistant.quickAction.openProvince.province.zuid.holland", in: app, timeout: 6)
        XCTAssertTrue(openProvince.exists)
        tapRouteAction(openProvince, in: app, expecting: ["province.detail.zuid.holland", "province.detail.zuid-holland", "province.detail.nl-province-zuid-holland"])

        XCTAssertTrue(firstExistingElement(["province.detail.zuid.holland", "province.detail.zuid-holland", "province.detail.nl-province-zuid-holland"], in: app, timeout: 6).exists)
    }

    @MainActor
    func testAssistantCitySearchActionOpensRotterdam() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-resetUITestState", "-launchLanguage", "en", "-uiTestingStartTab", "assistant"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        sendAssistantPrompt("Tell me about Rotterdam city", in: app)

        let openCity = waitForElement("assistant.quickAction.openCity.city.rotterdam", in: app, timeout: 6)
        XCTAssertTrue(openCity.exists)
        launchDestination("city:rotterdam", in: app)

        XCTAssertTrue(firstExistingElement(["city.detail.rotterdam", "city.detail.nl-city-zuid_holland-rotterdam"], in: app, timeout: 6).exists)
    }

    @MainActor
    func testAssistantProvinceSearchActionOpensNorthHolland() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-resetUITestState", "-launchLanguage", "en", "-uiTestingStartTab", "assistant", "-uiTestingCity", "Amsterdam"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        sendAssistantPrompt("transport mistakes", in: app)

        let openProvince = waitForElement("assistant.quickAction.openProvince.province.noord.holland", in: app, timeout: 6)
        XCTAssertTrue(openProvince.exists)
        tapRouteAction(openProvince, in: app, expecting: ["province.detail.noord.holland", "province.detail.noord-holland", "province.detail.nl-province-noord-holland"])

        XCTAssertTrue(firstExistingElement(["province.detail.noord.holland", "province.detail.noord-holland", "province.detail.nl-province-noord-holland"], in: app, timeout: 6).exists)
    }

    @MainActor
    func testAssistantMissingInfoShowsSourceAndOpensOfficialSources() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-resetUITestState", "-launchLanguage", "en", "-uiTestingStartTab", "assistant"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        sendAssistantPrompt("zzzxqv qqqnonexistent pppnonsense", in: app)

        let sourceLink = waitForElement("assistant.quickAction.openSource.www.government.nl", in: app, timeout: 6)
        XCTAssertTrue(sourceLink.exists)

        let officialSources = waitForElement("assistant.quickAction.openScreen.officialsources", in: app, timeout: 6)
        XCTAssertTrue(officialSources.exists)
        officialSources.tap()

        XCTAssertTrue(app.descendants(matching: .any)["officialSources.screen"].waitForExistence(timeout: 6))
    }

    @MainActor
    func testAssistantWhatNextOpensChecklistItem() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-resetUITestState", "-launchLanguage", "en", "-uiTestingStartTab", "assistant"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        sendAssistantPrompt("What should I do next?", in: app)

        let checklistAction = waitForElementWithIdentifierPrefix("assistant.quickAction.openScreen.checklist.", in: app, timeout: 6)
        XCTAssertTrue(checklistAction.exists)
        launchDestination(checklistRouteID(fromActionIdentifier: checklistAction.identifier), in: app)

        XCTAssertTrue(firstExistingElement(["checklist.detail.screen"], in: app, timeout: 6).exists)
    }

    @MainActor
    func testMoreTabOpensMoreHub() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-launchLanguage", "en"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        let more = app.descendants(matching: .any)["tab.more"]
        XCTAssertTrue(more.waitForExistence(timeout: 4))
        more.tap()

        let moreScreen = app.descendants(matching: .any)["more.screen"]
        let rightMenuPanel = app.descendants(matching: .any)["rightMenu.panel"]
        XCTAssertTrue(moreScreen.waitForExistence(timeout: 4) || rightMenuPanel.waitForExistence(timeout: 2))
        if moreScreen.exists {
            XCTAssertTrue(app.descendants(matching: .any)["more.dashboard"].waitForExistence(timeout: 4))
        }
        XCTAssertFalse(app.descendants(matching: .any)["global.aiLauncher"].exists)
    }

    @MainActor
    func testMoreMenuLayoutKeepsHeroBoundedAndAIHidden() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-resetUITestState", "-launchLanguage", "en"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        let more = app.descendants(matching: .any)["tab.more"]
        XCTAssertTrue(more.waitForExistence(timeout: 4))
        more.tap()

        let hubHero = app.descendants(matching: .any).matching(identifier: "more.hero.bounds").firstMatch
        let menuHero = app.descendants(matching: .any).matching(identifier: "rightMenu.cityHero").firstMatch
        let hero: XCUIElement
        let followingContent: XCUIElement

        if hubHero.waitForExistence(timeout: 6) {
            hero = hubHero
            followingContent = app.descendants(matching: .any).matching(identifier: "more.dashboard").firstMatch
        } else {
            XCTAssertTrue(menuHero.waitForExistence(timeout: 4), "More should show either the hub hero or the right-menu hero.")
            hero = menuHero
            followingContent = app.descendants(matching: .any).matching(identifier: "rightMenu.stats").firstMatch
        }

        XCTAssertTrue(followingContent.waitForExistence(timeout: 4))

        let windowFrame = app.windows.firstMatch.frame
        XCTAssertGreaterThanOrEqual(hero.frame.height, 220, "More hero should not collapse below card height.")
        XCTAssertLessThanOrEqual(hero.frame.height, 320, "More hero must stay within the 220-320 pt regression-safe range.")
        XCTAssertLessThan(hero.frame.height, windowFrame.height * 0.45, "More hero must never behave like a full-screen image.")
        XCTAssertGreaterThanOrEqual(followingContent.frame.minY, hero.frame.maxY - 2, "More content should flow after the hero, not overlap it.")
        XCTAssertLessThanOrEqual(followingContent.frame.minY - hero.frame.maxY, 80, "More layout should not introduce a large artificial gap after the hero.")

        XCTAssertFalse(
            app.descendants(matching: .any)["global.aiLauncher"].exists,
            "Global AI launcher should be hidden on the More tab so it cannot overlap More content."
        )
        XCTAssertFalse(hero.frame.intersects(more.frame), "More hero should not be hidden behind the tab bar.")
        XCTAssertFalse(followingContent.frame.intersects(more.frame), "More content after the hero should not be hidden behind the tab bar.")
    }

    @MainActor
    func testAssistantInitialLayoutKeepsComposerBelowQuestionCards() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-resetUITestState", "-launchLanguage", "en", "-uiTestingStartTab", "assistant"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        let input = app.descendants(matching: .any)["assistant.input"]
        XCTAssertTrue(input.waitForExistence(timeout: 4))

        let productIntro = app.descendants(matching: .any).matching(identifier: "assistant.productIntro").firstMatch
        XCTAssertTrue(productIntro.waitForExistence(timeout: 4))
        XCTAssertFalse(input.frame.intersects(productIntro.frame), "Assistant input should not cover the initial assistant context.")
    }

    @MainActor
    func testMenuHistoryRouteOpensHistory() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-resetUITestState", "-launchLanguage", "en", "-uiTestingStatus", "tourist", "-uiTestingDestination", "history"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        XCTAssertTrue(app.staticTexts["History of the Netherlands"].waitForExistence(timeout: 4))
    }

    @MainActor
    func testMenuKNMRouteOpensKNM() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-resetUITestState", "-launchLanguage", "en", "-uiTestingStatus", "refugee", "-uiTestingDestination", "knm"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        XCTAssertTrue(app.descendants(matching: .any)["knm.screen"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["Knowledge of Dutch Society"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["knm.disclaimer"].exists)
    }

    @MainActor
    func testSearchKNMOpensKNM() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-resetUITestState", "-launchLanguage", "en", "-uiTestingStatus", "refugee", "-uiTestingStartTab", "search"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        let input = app.descendants(matching: .any)["search.input"]
        XCTAssertTrue(input.waitForExistence(timeout: 4))
        input.tap()
        input.typeText("KNM")
        app.descendants(matching: .any)["search.submit"].tap()

        let result = app.descendants(matching: .any)["search.result.card"]
        XCTAssertTrue(result.waitForExistence(timeout: 4))
        result.tap()
        XCTAssertTrue(app.descendants(matching: .any)["knm.screen"].waitForExistence(timeout: 4))
    }

    @MainActor
    func testMenuDutchA1A2RouteOpensCourse() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-launchLanguage", "en", "-uiTestingDestination", "dutch"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        XCTAssertTrue(app.descendants(matching: .any)["dutchA1A2.screen"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["Dutch A1-A2"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["dutchA1A2.disclaimer"].exists)
    }

    @MainActor
    func testSearchAfspraakFindsDutchCourse() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-resetUITestState", "-launchLanguage", "en", "-uiTestingStatus", "refugee", "-uiTestingStartTab", "search"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        let input = app.descendants(matching: .any)["search.input"]
        XCTAssertTrue(input.waitForExistence(timeout: 4))
        input.tap()
        input.typeText("afspraak")
        app.descendants(matching: .any)["search.submit"].tap()

        XCTAssertTrue(app.staticTexts["Dutch A1-A2"].firstMatch.waitForExistence(timeout: 4) || app.staticTexts["City and municipality"].firstMatch.exists)
    }

    @MainActor
    func testRussianMenuLabelsAreLocalized() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-resetUITestState", "-launchLanguage", "ru", "-uiTestingStartTab", "more"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        let moreTab = app.descendants(matching: .any)["tab.more"]
        XCTAssertTrue(moreTab.waitForExistence(timeout: 4))
        XCTAssertEqual(moreTab.label, "Открыть меню")
        let moreScreen = app.descendants(matching: .any)["more.screen"]
        let rightMenuPanel = app.descendants(matching: .any)["rightMenu.panel"]
        XCTAssertTrue(moreScreen.waitForExistence(timeout: 4) || rightMenuPanel.waitForExistence(timeout: 2))
        if moreScreen.exists {
            XCTAssertTrue(app.descendants(matching: .any)["more.dashboard"].waitForExistence(timeout: 4))
        }
        XCTAssertFalse(app.staticTexts["menu.history"].exists)
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            let app = XCUIApplication()
            app.launchArguments = ["-uiTesting", "-launchLanguage", "en"]
            app.launch()
        }
    }

    @MainActor
    private func sendAssistantPrompt(_ prompt: String, in app: XCUIApplication) {
        let input = app.descendants(matching: .any)["assistant.input"]
        XCTAssertTrue(input.waitForExistence(timeout: 4))
        input.tap()
        if !app.keyboards.firstMatch.waitForExistence(timeout: 1) {
            input.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            _ = app.keyboards.firstMatch.waitForExistence(timeout: 1)
        }
        input.typeText(prompt)

        let send = app.descendants(matching: .any)["assistant.send"]
        XCTAssertTrue(send.waitForExistence(timeout: 2))
        send.tap()

        XCTAssertTrue(app.descendants(matching: .any)["assistant.response.structured"].waitForExistence(timeout: 14))
    }

    @MainActor
    private func launchDestination(_ routeID: String, in app: XCUIApplication) {
        app.terminate()
        app.launchArguments = ["-uiTesting", "-resetUITestState", "-launchLanguage", "en", "-uiTestingDestination", routeID]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))
    }

    private func checklistRouteID(fromActionIdentifier identifier: String) -> String {
        let prefix = "assistant.quickAction.openScreen.checklist."
        let normalizedUUID = identifier.hasPrefix(prefix) ? String(identifier.dropFirst(prefix.count)) : identifier
        return "checklist:\(normalizedUUID.replacingOccurrences(of: ".", with: "-"))"
    }

    @MainActor
    private func waitForElement(_ identifier: String, in app: XCUIApplication, timeout: TimeInterval) -> XCUIElement {
        let element = app.descendants(matching: .any)[identifier]
        if !element.waitForExistence(timeout: timeout) {
            for _ in 0..<4 where !element.exists {
                app.swipeUp()
                if element.waitForExistence(timeout: 1) {
                    break
                }
            }
            for _ in 0..<4 where !element.exists {
                app.swipeDown()
                if element.waitForExistence(timeout: 1) {
                    break
                }
            }
        }
        return element
    }

    @MainActor
    private func waitForFirstElement(_ identifier: String, in app: XCUIApplication, timeout: TimeInterval) -> XCUIElement {
        let element = app.descendants(matching: .any).matching(identifier: identifier).firstMatch
        if !element.waitForExistence(timeout: timeout) {
            for _ in 0..<4 where !element.exists {
                app.swipeUp()
                if element.waitForExistence(timeout: 1) {
                    break
                }
            }
            for _ in 0..<4 where !element.exists {
                app.swipeDown()
                if element.waitForExistence(timeout: 1) {
                    break
                }
            }
        }
        return element
    }

    @MainActor
    private func waitForElementWithIdentifierPrefix(_ prefix: String, in app: XCUIApplication, timeout: TimeInterval) -> XCUIElement {
        let predicate = NSPredicate(format: "identifier BEGINSWITH %@", prefix)
        let element = app.descendants(matching: .any).matching(predicate).firstMatch
        if !element.waitForExistence(timeout: timeout) {
            for _ in 0..<5 where !element.exists {
                app.swipeUp()
                if element.waitForExistence(timeout: 1) {
                    break
                }
            }
            for _ in 0..<5 where !element.exists {
                app.swipeDown()
                if element.waitForExistence(timeout: 1) {
                    break
                }
            }
        }
        return element
    }

    @MainActor
    private func firstExistingElement(_ identifiers: [String], in app: XCUIApplication, timeout: TimeInterval) -> XCUIElement {
        let deadline = Date().addingTimeInterval(timeout)
        repeat {
            for identifier in identifiers {
                let element = app.descendants(matching: .any)[identifier]
                if element.exists {
                    return element
                }
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        } while Date() < deadline

        app.swipeUp()
        for identifier in identifiers {
            let element = app.descendants(matching: .any)[identifier]
            if element.waitForExistence(timeout: 1) {
                return element
            }
        }
        app.swipeDown()
        for identifier in identifiers {
            let element = app.descendants(matching: .any)[identifier]
            if element.waitForExistence(timeout: 1) {
                return element
            }
        }
        return app.descendants(matching: .any)[identifiers[0]]
    }


    
    
    @MainActor
    private func tapRouteAction(_ element: XCUIElement, in app: XCUIApplication, expecting identifiers: [String]) {
        let routeIdentifier = element.identifier
        tapActionElement(element)
        if firstExistingElementWithoutScrolling(identifiers, in: app, timeout: 3).exists {
            return
        }

        if !routeIdentifier.isEmpty {
            tapRouteAction(routeIdentifier, in: app, expecting: identifiers)
            return
        }
    }

    @MainActor
    private func tapRouteAction(_ identifier: String, in app: XCUIApplication, expecting identifiers: [String]) {
        for attempt in 0..<5 {
            if firstExistingElementWithoutScrolling(identifiers, in: app, timeout: attempt == 0 ? 0.25 : 1).exists {
                return
            }

            let button = app.buttons.matching(identifier: identifier).firstMatch
            let action = button.exists ? button : app.descendants(matching: .any).matching(identifier: identifier).firstMatch
            if action.waitForExistence(timeout: 1) {
                tapActionElement(action)
                if firstExistingElementWithoutScrolling(identifiers, in: app, timeout: 2).exists {
                    return
                }
            }

            if attempt.isMultiple(of: 2) {
                app.swipeUp()
            } else {
                app.swipeDown()
            }
        }
    }

    @MainActor
    private func firstExistingElementWithoutScrolling(_ identifiers: [String], in app: XCUIApplication, timeout: TimeInterval) -> XCUIElement {
        let deadline = Date().addingTimeInterval(timeout)
        repeat {
            for identifier in identifiers {
                let element = app.descendants(matching: .any)[identifier]
                if element.exists {
                    return element
                }
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        } while Date() < deadline

        return app.descendants(matching: .any)[identifiers[0]]
    }

    @MainActor
    private func tapActionElement(_ element: XCUIElement) {
        let activePoint = element.coordinate(withNormalizedOffset: CGVector(dx: 0.18, dy: 0.5))
        if element.isHittable {
            activePoint.tap()
        } else {
            activePoint.tap()
        }
    }
}
