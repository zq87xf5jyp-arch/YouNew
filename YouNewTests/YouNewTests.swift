import Testing
import Foundation
@testable import YouNew

@MainActor
struct YouNewTests {

    @Test func aiSafetyBlocksLegalGuaranteesInEveryLanguage() {
        let english = AISafetyRules.blockedResponseIfNeeded(
            for: "Can you guarantee my immigration outcome?",
            languageCode: "en"
        )
        let dutch = AISafetyRules.blockedResponseIfNeeded(
            for: "Kun je juridisch advies geven?",
            languageCode: "nl"
        )
        let russian = AISafetyRules.blockedResponseIfNeeded(
            for: "Можно предсказать решение IND?",
            languageCode: "ru"
        )

        #expect(english?.contains("cannot provide legal advice") == true)
        #expect(dutch?.contains("geen juridisch advies") == true)
        #expect(russian?.contains("не могу давать юридическую консультацию") == true)
    }

    @MainActor
    @Test func aiConversationPersistsMessagesWithStableRoles() throws {
        var conversation = AIConversation()
        conversation.appendUser("What is BSN?")
        conversation.appendAssistant("BSN is a citizen service number.")

        let data = try JSONEncoder().encode(conversation)
        let decoded = try JSONDecoder().decode(AIConversation.self, from: data)

        #expect(decoded.messages.count == 2)
        #expect(decoded.messages[0].role == .user)
        #expect(decoded.messages[1].role == .assistant)
        #expect(decoded.messages[0].text == "What is BSN?")
    }

    @Test func privacyResetClearsAllPersistentAssistantState() {
        let defaults = UserDefaults.standard
        let keysToRestore = AssistantStorage.allPersistentKeys + [AppDataMigration.schemaVersionKey]
        let previousValues = keysToRestore.reduce(into: [String: Any]()) { result, key in
            if let value = defaults.object(forKey: key) {
                result[key] = value
            }
        }
        defer {
            keysToRestore.forEach { defaults.removeObject(forKey: $0) }
            previousValues.forEach { defaults.set($0.value, forKey: $0.key) }
        }

        AssistantStorage.allPersistentKeys.forEach { key in
            defaults.set("seed-\(key)", forKey: key)
        }

        AppDataMigration.resetLocalCachedData()

        AssistantStorage.allPersistentKeys.forEach { key in
            #expect(defaults.object(forKey: key) == nil, "\(key) should be cleared by privacy reset")
        }
        #expect(defaults.integer(forKey: AppDataMigration.schemaVersionKey) == AppDataMigration.currentSchemaVersion)
    }

    @Test func scannedDocumentImportMovesTempFileIntoManagedStorage() throws {
        let store = DocumentStore()
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("younew-scan-\(UUID().uuidString).pdf")
        try Data("scan".utf8).write(to: tempURL, options: [.atomic])

        try store.addScannedDocument(
            fileURL: tempURL,
            title: "Scan",
            category: .other,
            notes: "",
            isSensitive: false,
            language: .english
        )

        guard let saved = store.items.first(where: { $0.title == "Scan" }) else {
            Issue.record("Scanned document should be saved")
            return
        }
        defer { store.delete(saved) }

        #expect(!FileManager.default.fileExists(atPath: tempURL.path))
        #expect(FileManager.default.fileExists(atPath: saved.fileURL.path))
        #expect(saved.fileURL != tempURL)
    }

    @Test func scannedDocumentImportFailureDoesNotAddTempFallbackDocument() {
        let store = DocumentStore()
        let missingTempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("missing-younew-scan-\(UUID().uuidString).pdf")
        let previousIDs = Set(store.items.map(\.id))

        do {
            try store.addScannedDocument(
                fileURL: missingTempURL,
                title: "Missing scan",
                category: .other,
                notes: "",
                isSensitive: false,
                language: .english
            )
            Issue.record("Missing scan file should fail instead of falling back to temp URL")
        } catch {
            let addedItems = store.items.filter { !previousIDs.contains($0.id) }
            #expect(addedItems.isEmpty)
            #expect(!store.items.contains { $0.fileURL == missingTempURL })
        }
    }

    @Test func lifeTimelineIncludesRequiredDocumentsSourcesAndAIPrompt() {
        let steps = LifeTimelineBuilder.steps(
            for: .student,
            checklistItems: MockChecklistData.items,
            documents: [],
            now: Date(timeIntervalSince1970: 1_800_000_000)
        )

        #expect(!steps.isEmpty)
        #expect(steps.allSatisfy { !$0.title.english.isEmpty })
        #expect(steps.allSatisfy { !$0.requiredDocuments.isEmpty })
        #expect(steps.allSatisfy { ($0.officialSourceURL.scheme?.hasPrefix("http") ?? false) })
        #expect(steps.allSatisfy { $0.aiPrompt.english.contains("Do not give legal guarantees") })
    }

    @Test func documentMetadataCodableKeepsVaultFields() throws {
        let checklistID = UUID()
        let expiration = Date(timeIntervalSince1970: 1_850_000_000)
        let reminder = Date(timeIntervalSince1970: 1_849_900_000)
        let document = DocumentItem(
            title: "Residence permit",
            category: .indResidence,
            expirationDate: expiration,
            reminderDate: reminder,
            relatedChecklistItemID: checklistID,
            isSensitive: true
        )

        let data = try JSONEncoder().encode(document)
        let decoded = try JSONDecoder().decode(DocumentItem.self, from: data)

        #expect(decoded.expirationDate == expiration)
        #expect(decoded.reminderDate == reminder)
        #expect(decoded.relatedChecklistItemID == checklistID)
        #expect(decoded.isSensitive)
    }

    @MainActor
    @Test func privacyExportIncludesDocumentMetadataOnly() {
        let suiteName = "younew.tests.privacy.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            Issue.record("Could not create test defaults")
            return
        }
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let state = AppStateViewModel(defaults: defaults)
        let checklistID = UUID()
        let expiration = Date(timeIntervalSince1970: 1_850_000_000)
        let payload = state.privacyExportPayload(
            savedItemsCount: 0,
            documentMetadata: [
                DocumentItem(
                    title: "BSN letter",
                    category: .bsn,
                    expirationDate: expiration,
                    relatedChecklistItemID: checklistID,
                    notes: "contains private number"
                )
            ]
        )

        #expect(payload.documents.first?.expirationDate == expiration)
        #expect(payload.documents.first?.relatedChecklistItemID == checklistID.uuidString)
        #expect(payload.documents.first?.hasNotes == true)
        #expect(payload.documents.first?.fileName.contains("BSN") == false)
    }

    @Test func utilityRoutesResolveForAIAndNavigationAliases() {
        #expect(AppDestination.aiRoute(for: "lifeTimeline") == .lifeTimeline)
        #expect(AppDestination.aiRoute(for: "deadlineCenter") == .deadlineCenter)
        #expect(AppDestination.aiRoute(for: "documentVault") == .documentVault)
        #expect(AppDestination.aiRoute(for: "verifiedExperts") == .verifiedExperts)
        #expect(AppDestination.aiRoute(for: "aiLetterGenerator") == .aiLetterGenerator)
    }

    @Test func verifiedExpertsAreExplicitCommercialOrVerified() {
        let experts = MockLocalPartnersData.partners(in: "Amsterdam")
            .filter { $0.plan != .freeListing && [.legal, .finance, .education, .home].contains($0.category) }

        #expect(experts.allSatisfy { $0.plan != .freeListing })
        #expect(experts.allSatisfy { !$0.plan.label(.english).isEmpty })
        #expect(experts.allSatisfy { !$0.sourceReliabilityNote.isEmpty })
    }

    @MainActor
    @Test func checklistProgressPersistsLocallyByCompletedID() {
        let suiteName = "younew.tests.checklist.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            Issue.record("Could not create test defaults")
            return
        }
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let state = AppStateViewModel(defaults: defaults)
        state.selectedUserStatus = .student

        guard let item = state.visibleChecklistItems.first(where: { !$0.isCompleted }) else {
            Issue.record("Expected a visible checklist item")
            return
        }

        state.toggleChecklistItem(item)

        let restored = AppStateViewModel(defaults: defaults)
        restored.selectedUserStatus = .student

        #expect(restored.checklistItems.first(where: { $0.id == item.id })?.isCompleted == true)
        #expect(defaults.stringArray(forKey: AppStateViewModel.completedChecklistIDsKey)?.contains(item.id.uuidString.lowercased()) == true)
    }

    @Test func publicOnboardingProfilesMatchProductTaxonomy() {
        #expect(OnboardingProfile.allCases.map(\.rawValue) == [
            "tourist",
            "student",
            "worker",
            "newResident",
            "businessOwner",
            "refugeeStatusHolder",
            "family"
        ])
        #expect(OnboardingProfile.businessOwner.userStatus == .entrepreneur)
        #expect(OnboardingProfile.refugeeStatusHolder.userStatus == .refugee)
    }

    @Test func onboardingSituationOptionsAreProfileSpecificAndActionable() {
        #expect(OnboardingSituation.options(for: .tourist) == [.shortStay])
        #expect(OnboardingSituation.options(for: .student).contains(.enrolledStudent))
        #expect(OnboardingSituation.options(for: .businessOwner).contains(.startingBusiness))
        #expect(OnboardingSituation.statusHolder.priorityHints.contains(.housing))
        #expect(OnboardingSituation.movingWithChildren.priorityHints.contains(.schools))
        #expect(OnboardingSituation.options(for: .family).allSatisfy { !$0.priorityHints.isEmpty })
    }

    @MainActor
    @Test func onboardingProfileSituationAndInterestsPersistWithUserProfile() {
        let suiteName = "younew.tests.onboarding.profile.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            Issue.record("Could not create test defaults")
            return
        }
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let state = AppStateViewModel(defaults: defaults)
        state.selectedUserStatus = .entrepreneur
        state.userProfile.onboardingProfile = .businessOwner
        state.userProfile.onboardingSituation = .startingBusiness
        state.userProfile.selectedRegionOrProvince = "province:Noord-Holland"
        state.userProfile.optionalInterests = [.events, .restaurants]
        state.userProfile.hasBSN = true
        state.userProfile.hasDigiD = true

        let restored = AppStateViewModel(defaults: defaults)
        #expect(restored.selectedUserStatus == .entrepreneur)
        #expect(restored.userProfile.onboardingProfile == .businessOwner)
        #expect(restored.userProfile.onboardingSituation == .startingBusiness)
        #expect(restored.userProfile.selectedRegionOrProvince == "province:Noord-Holland")
        #expect(Set(restored.userProfile.optionalInterests) == Set([.events, .restaurants]))
        #expect(restored.userProfile.hasBSN)
        #expect(restored.userProfile.hasDigiD)
    }

    @Test func localizedPermissionStringsArePresent() {
        for language in AppLanguage.allCases {
            let bundlePath = Bundle.main.path(
                forResource: "InfoPlist",
                ofType: "strings",
                inDirectory: "\(language.rawValue).lproj"
            )

            #expect(bundlePath != nil)

            guard let bundlePath,
                  let strings = NSDictionary(contentsOfFile: bundlePath) as? [String: String] else {
                Issue.record("Missing InfoPlist.strings for \(language.rawValue)")
                continue
            }

            #expect(strings["CFBundleDisplayName"] == "YouNew")
            #expect(strings["NSCameraUsageDescription"]?.isEmpty == false)
            #expect(strings["NSLocationWhenInUseUsageDescription"]?.isEmpty == false)
        }
    }

    @Test func localizableFilesHaveMatchingKeys() throws {
        let english = try loadLocalizableStrings(for: .english)
        let dutch = try loadLocalizableStrings(for: .dutch)
        let russian = try loadLocalizableStrings(for: .russian)

        #expect(Set(english.keys) == Set(dutch.keys))
        #expect(Set(english.keys) == Set(russian.keys))
    }

    @Test func englishAndDutchLocalizationsDoNotContainCyrillicExceptLanguageName() throws {
        let allowedCyrillicKeys: Set<String> = ["language.russian"]

        for language in [AppLanguage.english, .dutch] {
            let strings = try loadLocalizableStrings(for: language)
            let leakingKeys = strings
                .filter { key, value in
                    !allowedCyrillicKeys.contains(key) && containsCyrillic(value)
                }
                .map(\.key)
                .sorted()

            #expect(leakingKeys.isEmpty, "\(language.rawValue) contains Cyrillic values for keys: \(leakingKeys)")
        }
    }

    @Test func localizableValuesDoNotExposeRawKeys() throws {
        for language in AppLanguage.allCases {
            let strings = try loadLocalizableStrings(for: language)
            let rawValueKeys = strings
                .filter { key, value in key == value }
                .map(\.key)
                .sorted()

            #expect(rawValueKeys.isEmpty, "\(language.rawValue) exposes raw localization keys: \(rawValueKeys)")
        }
    }

    @Test func unsupportedPreferredLanguageFallsBackToEnglish() {
        #expect(AppLanguage(rawValue: "de") == nil)
        #expect(L10n.t("tab.home", .english) == "Home")
    }

    @Test func navigationMenuPositionsCoverEveryPersistedSetting() {
        let expectedRawValues = ["automatic", "bottom", "top", "left", "right"]
        #expect(NavigationMenuPosition.allCases.map(\.rawValue) == expectedRawValues)

        for position in NavigationMenuPosition.allCases {
            #expect(NavigationMenuPosition(rawValue: position.rawValue) == position)
            for language in AppLanguage.allCases {
                #expect(!position.localized(language).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    @Test func releasePublicNavigationAreasAreCovered() {
        let requiredAreaIDs: Set<String> = [
            "home",
            "dashboard",
            "search",
            "map",
            "aiAssistant",
            "saved",
            "more",
            "places",
            "calendar",
            "transport",
            "emergency",
            "documents",
            "settings"
        ]
        let actualAreaIDs = Set(ReleaseNavigationContract.publicAreas.map(\.id))

        #expect(actualAreaIDs == requiredAreaIDs)
    }

    @Test func releasePublicNavigationAreasStayWithinThreeTapsAndHaveExitPath() {
        for area in ReleaseNavigationContract.publicAreas {
            #expect(
                area.tapCountFromHome <= ReleaseNavigationContract.maximumTapCountFromHome,
                "\(area.title) should be reachable within \(ReleaseNavigationContract.maximumTapCountFromHome) taps"
            )
            #expect(area.supportsBackNavigation, "\(area.title) should have a back, close, or tab exit path")

            guard let destination = area.destination else { continue }
            guard let routeID = area.routeID else {
                Issue.record("\(area.title) should expose a stable route ID for \(destination)")
                continue
            }
            #expect(AppNavigationResolver.destination(for: routeID) == destination, "\(area.title) route should round-trip")
        }
    }

    @Test func studentAtomicPathOpensExpectedCoreSubtasks() {
        let profile = UserPathProfiles.profile(for: .student)
        let destinations = Set(profile.recommendedSteps.map(\.destination))

        #expect(destinations.contains(.institutionsList))
        #expect(destinations.contains(.officialSources))
        #expect(destinations.contains(.beginnerGuidesList))
        #expect(destinations.contains(.practicalGuide(.healthInsuranceBasics)))
        #expect(destinations.contains(.practicalGuide(.transportBasics)))
        #expect(destinations.contains(.mapFocus(.education)))
        #expect(destinations.contains(.searchList))
        #expect(destinations.contains(.mapHub))
        #expect(!destinations.contains(.checklistList))
        #expect(!destinations.contains(.mapFocus(.government)))
        #expect(!destinations.contains(.mapFocus(.healthcare)))
    }

    @Test func mapFocusRawRoutesCanonicalizeCatalogIdentifiers() {
        #expect(MapFocus(rawValue: "province:zuid-holland") == .province("Zuid-Holland"))
        #expect(MapFocus(rawValue: "city:zuid-holland-leiden") == .city("Zuid-Holland-Leiden"))

        let place = MockNearbyPlacesData.places[0]
        #expect(MapFocus(rawValue: "place:\(place.id.uuidString)") == .place(place.saveKey))
    }

    @Test func moduleRoutesAreVisibleOnlyWhenBackingContentExists() {
        #expect(RelatedContentEngine.isVisible(.knmModule("registration"), for: .refugee))
        #expect(!RelatedContentEngine.isVisible(.knmModule("missing-module"), for: .refugee))
        #expect(RelatedContentEngine.isVisible(.dutchA1A2Module("basics"), for: .student))
        #expect(!RelatedContentEngine.isVisible(.dutchA1A2Module("missing-module"), for: .student))
    }

    @Test func screenBackgroundStylesAreStableForSettingsAndSnapshots() {
        let expected: Set<YouNewScreenBackgroundStyle> = [
            .home, .map, .province, .city, .search, .saved,
            .assistant, .more, .settings, .documents, .fines,
            .onboarding, .support, .general
        ]

        #expect(Set(YouNewScreenBackgroundStyle.allCases) == expected)
        #expect(YouNewScreenBackgroundStyle.home.id == "home")
        #expect(YouNewScreenBackgroundStyle.onboarding.id == "onboarding")
    }

    @Test func onboardingCompletionPersistsAcrossRelaunchAndReset() {
        let suiteName = "test.onboarding.persistence.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let firstLaunch = AppStateViewModel(defaults: defaults)
        #expect(firstLaunch.hasCompletedQuestionnaire == false)

        firstLaunch.completeQuestionnaire()
        #expect(defaults.bool(forKey: AppStateViewModel.onboardingCompletionKey) == true)

        let relaunched = AppStateViewModel(defaults: defaults)
        #expect(relaunched.hasCompletedQuestionnaire == true)

        relaunched.resetPersonalState()
        #expect(defaults.bool(forKey: AppStateViewModel.onboardingCompletionKey) == false)

        let afterReset = AppStateViewModel(defaults: defaults)
        #expect(afterReset.hasCompletedQuestionnaire == false)

        defaults.removePersistentDomain(forName: suiteName)
    }

    private func loadLocalizableStrings(for language: AppLanguage) throws -> [String: String] {
        let path = try #require(Bundle.main.path(
            forResource: "Localizable",
            ofType: "strings",
            inDirectory: "\(language.rawValue).lproj"
        ))
        return try #require(NSDictionary(contentsOfFile: path) as? [String: String])
    }

    private func containsCyrillic(_ text: String) -> Bool {
        text.unicodeScalars.contains { scalar in
            (0x0400...0x04FF).contains(Int(scalar.value))
        }
    }
}
