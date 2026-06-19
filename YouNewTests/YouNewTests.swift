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
