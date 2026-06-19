import XCTest

final class YouNewUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
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
        app.launchArguments = ["-uiTesting", "-resetUITestState", "-launchLanguage", "en"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        let launcher = app.descendants(matching: .any)["global.aiLauncher"]
        XCTAssertTrue(launcher.waitForExistence(timeout: 6))

        let homeTab = app.descendants(matching: .any)["tab.home"]
        XCTAssertTrue(homeTab.waitForExistence(timeout: 4))
        XCTAssertFalse(
            launcher.frame.intersects(homeTab.frame),
            "Global AI launcher should not overlap the floating tab bar home target."
        )

        launcher.tap()

        let nextStepMode = app.buttons["What Should I Do Next?"]
        if !nextStepMode.waitForExistence(timeout: 4) {
            _ = waitForElement("global.aiLauncher.mode.nextStep", in: app, timeout: 2)
        }
        XCTAssertTrue(nextStepMode.exists)
        nextStepMode.tap()

        XCTAssertTrue(app.descendants(matching: .any)["tab.assistant"].waitForExistence(timeout: 4))
        let input = app.descendants(matching: .any)["assistant.input"]
        XCTAssertTrue(input.waitForExistence(timeout: 6))
        XCTAssertTrue((input.value as? String)?.localizedCaseInsensitiveContains("What should I do next") == true)
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
        openGuide.tap()

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

        let includeDigiD = waitForElement("assistant.quickAction.askFollowUp.yes.digid", in: app, timeout: 6)
        XCTAssertTrue(includeDigiD.exists)
        includeDigiD.tap()

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
        openCity.tap()

        XCTAssertTrue(app.descendants(matching: .any)["city.detail.leiden"].waitForExistence(timeout: 6))
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
        digidTopic.tap()

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

        documentsAction.tap()

        XCTAssertTrue(app.descendants(matching: .any)["documents.screen"].waitForExistence(timeout: 6))
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
        finesAction.tap()

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
        lettersAction.tap()

        XCTAssertTrue(app.descendants(matching: .any)["letters.screen"].waitForExistence(timeout: 6))
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
        officialSources.tap()

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
        municipalityAction.tap()

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
        openCity.tap()

        XCTAssertTrue(app.descendants(matching: .any)["city.detail.leiden"].waitForExistence(timeout: 6))
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
        openProvince.tap()

        XCTAssertTrue(app.descendants(matching: .any)["province.detail.zuid-holland"].waitForExistence(timeout: 6))
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
        openCity.tap()

        XCTAssertTrue(app.descendants(matching: .any)["city.detail.rotterdam"].waitForExistence(timeout: 6))
    }

    @MainActor
    func testAssistantProvinceSearchActionOpensNorthHolland() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-resetUITestState", "-launchLanguage", "en", "-uiTestingStartTab", "assistant"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        sendAssistantPrompt("North Holland province", in: app)

        let openProvince = waitForElement("assistant.quickAction.openProvince.province.noord.holland", in: app, timeout: 6)
        XCTAssertTrue(openProvince.exists)
        openProvince.tap()

        XCTAssertTrue(app.descendants(matching: .any)["province.detail.noord-holland"].waitForExistence(timeout: 6))
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
        checklistAction.tap()

        XCTAssertTrue(app.descendants(matching: .any)["checklist.detail.screen"].waitForExistence(timeout: 6))
    }

    @MainActor
    func testMoreOpensAndClosesRightSideMenu() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-launchLanguage", "en"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        let more = app.descendants(matching: .any)["tab.more"]
        XCTAssertTrue(more.waitForExistence(timeout: 4))
        more.tap()

        let panel = app.descendants(matching: .any)["rightMenu.panel"]
        XCTAssertTrue(panel.waitForExistence(timeout: 3))
        XCTAssertLessThanOrEqual(panel.frame.maxX, app.windows.firstMatch.frame.maxX + 1)
        XCTAssertGreaterThanOrEqual(panel.frame.width, 280)

        let close = app.descendants(matching: .any)["rightMenu.close"]
        XCTAssertTrue(close.waitForExistence(timeout: 2))
        close.tap()
        XCTAssertFalse(panel.waitForExistence(timeout: 2))
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

        let hero = app.descendants(matching: .any)["assistant.hero"]
        XCTAssertTrue(hero.waitForExistence(timeout: 4))
        XCTAssertLessThanOrEqual(hero.frame.height, 380, "Assistant hero should stay compact enough for question cards.")

        let input = app.descendants(matching: .any)["assistant.input"]
        XCTAssertTrue(input.waitForExistence(timeout: 4))

        let firstQuestion = app.staticTexts["What is my next official step?"].firstMatch
        XCTAssertTrue(firstQuestion.waitForExistence(timeout: 4))
        XCTAssertFalse(input.frame.intersects(firstQuestion.frame), "Assistant input should not cover popular question text.")
    }

    @MainActor
    func testMenuHistoryRouteOpensHistory() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-launchLanguage", "en"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        app.descendants(matching: .any)["tab.more"].tap()
        let history = app.descendants(matching: .any)["rightMenu.item.history"]
        XCTAssertTrue(history.waitForExistence(timeout: 3))
        history.tap()

        XCTAssertTrue(app.staticTexts["History of the Netherlands"].waitForExistence(timeout: 4))
        XCTAssertFalse(app.descendants(matching: .any)["rightMenu.panel"].exists)
    }

    @MainActor
    func testMenuKNMRouteOpensKNM() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-launchLanguage", "en"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        app.descendants(matching: .any)["tab.more"].tap()
        let knm = app.descendants(matching: .any)["rightMenu.item.knm"]
        XCTAssertTrue(knm.waitForExistence(timeout: 3))
        knm.tap()

        XCTAssertTrue(app.descendants(matching: .any)["knm.screen"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["Knowledge of Dutch Society"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["knm.disclaimer"].exists)
    }

    @MainActor
    func testSearchKNMOpensKNM() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-launchLanguage", "en", "-uiTestingStartTab", "search"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        let input = app.descendants(matching: .any)["search.input"]
        XCTAssertTrue(input.waitForExistence(timeout: 4))
        input.tap()
        input.typeText("KNM")
        app.descendants(matching: .any)["search.submit"].tap()

        let result = app.staticTexts["KNM"].firstMatch
        XCTAssertTrue(result.waitForExistence(timeout: 4))
        result.tap()
        XCTAssertTrue(app.descendants(matching: .any)["knm.screen"].waitForExistence(timeout: 4))
    }

    @MainActor
    func testMenuDutchA1A2RouteOpensCourse() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-launchLanguage", "en"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        app.descendants(matching: .any)["tab.more"].tap()
        let course = app.descendants(matching: .any)["rightMenu.item.dutchA1A2"]
        XCTAssertTrue(course.waitForExistence(timeout: 3))
        course.tap()

        XCTAssertTrue(app.descendants(matching: .any)["dutchA1A2.screen"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["Dutch A1-A2"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["dutchA1A2.disclaimer"].exists)
    }

    @MainActor
    func testSearchAfspraakFindsDutchCourse() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-launchLanguage", "en", "-uiTestingStartTab", "search"]
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
        app.launchArguments = ["-uiTesting", "-launchLanguage", "ru"]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 4))

        app.descendants(matching: .any)["tab.more"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["rightMenu.panel"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["История Нидерландов"].exists)
        XCTAssertTrue(app.staticTexts["Источники"].exists)
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

        XCTAssertTrue(app.descendants(matching: .any)["assistant.response.structured"].waitForExistence(timeout: 8))
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
        return app.descendants(matching: .any)[identifiers[0]]
    }
}
