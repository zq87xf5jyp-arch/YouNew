#!/usr/bin/env python3
from pathlib import Path
import json
import re
import sys


ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    file_path = ROOT / path
    if not file_path.exists():
        fail(f"missing required file: {path}")
    return file_path.read_text(encoding="utf-8")


def fail(message: str) -> None:
    print(f"AI subsystem static QA failed: {message}")
    sys.exit(1)


def expect(condition: bool, message: str) -> None:
    if not condition:
        fail(message)


def expect_all(data: str, needles: list[str], label: str) -> None:
    for needle in needles:
        expect(needle in data, f"{label} missing {needle}")


def expect_no_duplicate_static_sources(data: str, label: str) -> int:
    source_pattern = re.compile(
        r'OfficialSource\(title:\s*"([^"]+)",\s*url:\s*URL\(string:\s*"([^"]+)"\),\s*institution:\s*"([^"]+)"\)'
    )
    checked = 0
    source_list_pattern = re.compile(r"officialSources:\s*\[(.*?)\]\s*(?:,|\))", re.DOTALL)
    for list_index, list_match in enumerate(source_list_pattern.finditer(data), start=1):
        seen: set[tuple[str, str, str]] = set()
        for match in source_pattern.finditer(list_match.group(1)):
            checked += 1
            source = match.groups()
            expect(
                source not in seen,
                f"{label} officialSources list {list_index} duplicates static OfficialSource {source[0]} {source[1]}",
            )
            seen.add(source)
    return checked


def main() -> None:
    required_docs = [
        "AI_SYSTEM_ARCHITECTURE.md",
        "AI_KNOWLEDGE_GRAPH.md",
        "AI_NAVIGATION_MAP.md",
        "AI_WORKFLOWS.md",
        "AI_RELEASE_REPORT.md",
    ]
    for doc in required_docs:
        text = read(doc)
        expect(len(text.strip()) > 500, f"{doc} is too small to be a real release artifact")

    ai_context = read("YouNew/Models/AIContext.swift")
    ai_workflow = read("YouNew/Models/AIWorkflow.swift")
    ai_client = read("YouNew/Services/AIClient.swift")
    ai_context_builder = read("YouNew/Services/AIContextBuilder.swift")
    ai_composer = read("YouNew/Services/AIResponseComposer.swift")
    ai_parser = read("YouNew/Services/AIResponseParser.swift")
    ai_language_guard = read("YouNew/Services/AIResponseLanguageGuard.swift")
    mock_ai_service = read("YouNew/Services/MockAIService.swift")
    ai_view_model = read("YouNew/ViewModels/AIViewModel.swift")
    ai_workflow_engine = read("YouNew/Services/AIWorkflowEngine.swift")
    assistant_view = read("YouNew/Views/AIAssistantView.swift")
    app_destination = read("YouNew/App/Navigation/AppDestination.swift")
    app_destination_view = read("YouNew/App/Navigation/AppDestinationView.swift")
    app_state = read("YouNew/ViewModels/AppStateViewModel.swift")
    knowledge_index = read("YouNew/Services/KnowledgeIndex.swift")
    knowledge_graph = read("YouNew/Services/KnowledgeGraph.swift")
    search_engine = read("YouNew/Services/AppSearchEngine.swift")
    nav_resolver = read("YouNew/App/Navigation/AppRouter.swift")
    root = read("YouNew/App/AppTabView.swift")
    tests = read("YouNewTests/KnowledgeIndexTests.swift")
    foundation_tests = read("YouNewTests/AIFoundationTests.swift")
    newcomer_demo = read("YouNew/Services/BuildWeekNewcomerDemo.swift")
    newcomer_tests = read("YouNewTests/BuildWeekNewcomerDemoTests.swift")
    backend = read("BackendExamples/cloudflare-worker-ai-proxy.js")
    backend_tests = read("BackendExamples/cloudflare-worker-ai-proxy.test.mjs")
    governed_records: dict[str, dict] = {}
    for batch_path in [
        "DataProject/batches/WP-01/M1-government-core-001.json",
        "DataProject/batches/WP-01/M1-government-core-003.json",
        "DataProject/batches/WP-01/M1-government-core-008.json",
    ]:
        batch = json.loads(read(batch_path))
        expect(batch.get("publication_status") == "qa", f"{batch_path} must remain QA")
        for record in batch.get("records", []):
            governed_records[record["id"]] = record

    expect_all(
        ai_context,
        [
            "struct AIContext",
            "struct AIResponse",
            "struct AIResponseGovernance",
            "contentReleaseID",
            "verifiedDate",
            "locationAssumption",
            "uncertainty",
            "escalation",
            "let governance",
            "governance.isMachineValid",
            "BuildWeekNewcomerDemo.isApprovedContentRelease(",
            "struct AIResponseAction",
            "case openGuide",
            "case openScreen",
            "case openCity",
            "case openProvince",
            "case openSource",
            "case save",
            "case share",
            "case relatedTopic",
            "currentRouteID",
            "recentRouteIDs",
            "lastSearches",
            "completedChecklistItemIDs",
            "completedGuideIDs",
            "savedItemIDs",
            "savedItemKinds",
            "journeyProgress",
        ],
        "AIContext contract",
    )

    expect_all(
        ai_client,
        [
            "struct NewcomerRequestBody",
            "let question: String",
            "let locale: String",
            "let scenario: String",
            "let contextVersion: String",
            "let knowledgeRecordIDs: [String]",
            "BuildWeekNewcomerDemo.matches(userMessage)",
            "YOUNEW_AI_BACKEND_URL",
            'endpointPath = "/v1/newcomer-demo"',
            "components.path == endpointPath",
            "validatedEndpoint(",
            'components.scheme == "https"',
            "maximumQuestionBytes",
            "maximumResponseBytes",
            "parsed.isLiveOpenAI",
        ],
        "AIClient bounded backend contract",
    )
    request_block = ai_client.split("struct NewcomerRequestBody", 1)[-1].split("let endpoint:", 1)[0]
    for forbidden_field in [
        "systemPrompt",
        "conversation",
        "savedItemIDs",
        "completedGuideIDs",
        "lastSearches",
        "currentRouteID",
        "OPENAI_API_KEY",
    ]:
        expect(
            forbidden_field not in request_block,
            f"AIClient bounded request contains forbidden field {forbidden_field}",
        )
    expect(
        "return URL(string: raw)" not in ai_client,
        "AIClient accepts unvalidated backend endpoint URLs",
    )
    expect(
        'components.scheme == "http"' in ai_client
        and "allowInsecureLoopback" in ai_client
        and 'loopbackHosts.contains(host.lowercased())' in ai_client,
        "AIClient must restrict insecure HTTP to explicit loopback use",
    )

    expect_all(
        newcomer_demo,
        [
            'scenarioID = "BuildWeekNewcomerDemo"',
            'contextVersion = "newcomer-after-address.v1"',
            '"topic:registration-bsn"',
            '"topic:digid"',
            '"government-service:health-insurance"',
            '"government-service:gp"',
            '"practicalGuide:municipalityRegistration"',
            '"practicalGuide:digidSafety"',
            '"practicalGuide:healthInsuranceBasics"',
            '"practicalGuide:findingHuisarts"',
            "static func localResponse",
            "origin: .localGuide",
            "static func isAllowedModel",
            "sourceVerifiedDate",
            "approvedLiveContentReleases: [String: String] = [:]",
            "static func isApprovedContentRelease",
        ],
        "BuildWeekNewcomerDemo",
    )
    expect_all(
        backend,
        [
            'const ENDPOINT_PATH = "/v1/newcomer-demo"',
            'const OPENAI_RESPONSES_URL = "https://api.openai.com/v1/responses"',
            '"gpt-5.6"',
            "OPENAI_API_KEY",
            "OPENAI_MODEL",
            "store: false",
            "max_output_tokens: MAX_OUTPUT_TOKENS",
            'type: "json_schema"',
            "strict: true",
            "AbortController",
            "safeUpstreamRequestId",
            "isReleaseEligible(knowledgeRelease)",
            'status: "qa"',
            '"knowledge_not_release_eligible"',
            "contentReleaseId",
            "sourceVerifiedDate",
            "locationAssumption",
            "uncertainty",
            "escalation",
            '"Cache-Control": "no-store"',
        ],
        "bounded backend",
    )
    for contract_literal in [
        "Government.nl — Citizen service number (BSN)",
        "DigiD — Apply and activate",
        "Government.nl — Taking out compulsory health insurance",
        "Government.nl — Moving to the Netherlands checklist",
        "https://www.government.nl/themes/government-and-democracy/personal-data/citizen-service-number-bsn",
        "https://www.digid.nl/en/apply-and-activate/apply-digid",
        "https://www.government.nl/themes/family-health-and-care/health-insurance/standard-health-insurance/taking-out-compulsory-health-insurance",
        "https://www.government.nl/faq/what-do-i-need-to-arrange-if-im-moving-to-the-netherlands",
        "practicalGuide:municipalityRegistration",
        "practicalGuide:digidSafety",
        "practicalGuide:healthInsuranceBasics",
        "practicalGuide:findingHuisarts",
    ]:
        expect(
            contract_literal in newcomer_demo and contract_literal in backend,
            f"iOS/backend newcomer contract drift for {contract_literal}",
        )
    for repository_record_id in [
        "government.brp-registration",
        "government.bsn",
        "government.digid",
        "government.health-insurance",
        "government.register-family-doctor",
    ]:
        expect(
            repository_record_id in backend,
            f"bounded backend missing governed repository record {repository_record_id}",
        )
    expected_release_sources = {
        "government.bsn": "https://www.government.nl/themes/government-and-democracy/personal-data/citizen-service-number-bsn",
        "government.brp-registration": "https://www.rijksoverheid.nl/themas/overheid-en-democratie/privacy-en-persoonsgegevens/basisregistratie-personen-brp",
        "government.digid": "https://www.digid.nl/en/apply-and-activate/apply-digid",
        "government.health-insurance": "https://www.government.nl/themes/family-health-and-care/health-insurance/standard-health-insurance/taking-out-compulsory-health-insurance",
        "government.register-family-doctor": "https://www.government.nl/faq/what-do-i-need-to-arrange-if-im-moving-to-the-netherlands",
    }
    # Dates advance only with the separate, source-bound review receipt.
    confirmations = json.loads(read("DataProject/research/freshness-wave-1-confirmations.json"))
    reviewed_sources = {item["entity_id"]: item for item in confirmations["records"]}
    for record_id, source_url in expected_release_sources.items():
        receipt = reviewed_sources.get(record_id)
        expected_checked_at = "2026-07-14"
        if receipt is not None:
            expect(receipt.get("status") == "confirmed_current", f"{record_id} review not confirmed")
            expect(receipt.get("source_url") == source_url, f"{record_id} review source mismatch")
            expect(bool(receipt.get("reviewer")) and bool(receipt.get("confirmed_fields")), f"{record_id} incomplete review receipt")
            expected_checked_at = receipt["reviewed_at"]
        record = governed_records.get(record_id)
        expect(record is not None, f"missing bounded DataProject record {record_id}")
        expect(record.get("lifecycle_status") == "qa", f"{record_id} must remain QA")
        expect(record.get("last_checked") == expected_checked_at, f"{record_id} checked-date drift")
        official_source = record.get("official_source", {})
        expect(official_source.get("url") == source_url, f"{record_id} source URL drift")
        expect(official_source.get("checked_at") == expected_checked_at, f"{record_id} source-date drift")
    expect(
        "console.log" not in backend
        and "console.error" not in backend
        and "gpt-4.1" not in backend
        and "Access-Control-Allow-Origin" not in backend,
        "bounded backend logs sensitive data, contains a non-GPT-5.6 fallback, or grants browser CORS access",
    )
    expect_all(
        backend_tests,
        [
            "default QA knowledge release fails closed before an OpenAI request",
            "release gate requires published status, a real date, and a reviewer",
            "configuration requires both secret and an explicit GPT-5.6 model",
            "request input is exact, bounded, and rejects unknown client prompt fields",
            "request rejects incomplete or substituted knowledge context",
            "successful request uses the Responses API and returns the exact public contract",
            "native endpoint does not grant browser CORS access",
            "upstream HTTP failures are safe and never return provider text",
            "AbortController timeout maps to a safe timeout response",
        ],
        "bounded backend tests",
    )

    expect_all(
        knowledge_index,
        [
            "struct KnowledgeIndex",
            "KnowledgeIndexBuilder.buildItems()",
            "appScreens()",
            "guideContent()",
            "checklist()",
            "fines()",
            "institutions()",
            "letters()",
            "resources()",
            "knmModules()",
            "dutchCourseModules()",
            "searchAnswers()",
            "provinces()",
            "cities()",
            "quickActions(for item:",
            "prewarmShared()",
        ],
        "KnowledgeIndex",
    )
    expect(
        knowledge_index.count("actions.append(.openCity(item.city ?? item.title(.english)))") == 1,
        "KnowledgeIndex city quick action is duplicated",
    )

    expect_all(
        knowledge_graph,
        [
            "struct KnowledgeGraph",
            "topic:registration-bsn",
            "article:documents:bsn",
            "topic:health-insurance",
            "article:healthcare:insurance",
            "topic:digid",
        ],
        "KnowledgeGraph canonical links",
    )

    expect_all(
        search_engine,
        ["struct AppSearchEngine", "answerContext", "graphNeighbors", "sources", "destination"],
        "AppSearchEngine",
    )

    expect_all(
        nav_resolver,
        [
            "enum AppNavigationResolver",
            "routeID(from destination:",
            "destination(for rawID:",
            'case "checklist"',
            'case "article"',
            'case "guide"',
            'case "city"',
            'case "province"',
            'case "mapFocus"',
        ],
        "AppNavigationResolver",
    )

    expect_all(
        app_destination,
        [
            "case checklistList",
            "case lettersList",
            'case "checklist", "checklistlist"',
            'case "letters", "letter"',
        ],
        "AppDestination aliases",
    )

    expect_all(
        ai_composer,
        [
            "AppSearchEngine().search",
            "missingInformationResponse",
            "cityAction(from:",
            "provinceAction(from:",
            ".openSource",
            ".save",
            ".share",
            ".relatedTopic",
            "missingInformationResponse",
            "I don't have verified information in the app for this yet.",
        ],
        "AIResponseComposer",
    )

    expect_all(
        ai_parser,
        [
            "struct NewcomerBackendResponse",
            "struct NewcomerBackendStep",
            "BuildWeekNewcomerDemo.isAllowedModel(model)",
            "BuildWeekNewcomerDemo.isApprovedContentRelease(",
            "decoded.steps.count == BuildWeekNewcomerDemo.steps.count",
            "step.sourceURL == contract.sourceURL.absoluteString",
            "step.sourceVerifiedDate == contract.sourceVerifiedDate",
            "newcomerTraceIsComplete",
            "governance.isMachineValid",
            "step.appDestination == contract.appDestination",
            "origin: .liveOpenAI",
            "struct BackendAction",
            "quickActions: [BackendAction]?",
            "normalizedQuickActions",
            "normalizedActionKind",
            "repairMissingSeparators(in:",
            "localizedParserText",
            "localizedGenericSectionTitle",
            'case (.openOfficialSources, .russian): return "Открыть официальные источники"',
            'case (.verifySourceCard, .dutch): return "Controleer de officiële bronkaart voordat u handelt."',
            "normalizedSectionBody(answer)",
            'guard !(titleKey == "warnings" && bodyKey == answerBodyKey) else { return nil }',
            "guard seenBodies.insert(bodyKey).inserted else { return nil }",
            "canonicalDestinationID(action.destination?.id, action.destinationID)",
            ".openSource(title:",
            ".relatedTopic(action, query: action)",
            "validatedURL",
        ],
        "AIResponseParser typed quick actions",
    )
    expect_all(
        ai_language_guard,
        [
            "response.governance?.locationAssumption",
            "response.governance?.uncertainty",
            "response.governance?.escalation",
        ],
        "AIResponseLanguageGuard governance fields",
    )

    expect_all(
        mock_ai_service,
        [
            "quickActions(",
            "suggestedActions: Array(quickActions.map",
            ".openGuide(",
            ".openSource(title:",
            ".save(",
            ".share(",
            "routeID(forCityNamed:",
            "routeID(forProvinceNamed:",
        ],
        "MockAIService typed quick actions",
    )

    expect_all(
        ai_workflow,
        [
            "case healthInsurance",
            "case bsnRegistration",
            "case digid",
            "case fineLetter",
            "case housing",
            "case whatNext",
        ],
        "AIWorkflow kinds",
    )

    expect_all(
        ai_workflow_engine,
        [
            "startHealthInsurance",
            "startBSN",
            "startDigiD",
            "startFineLetter",
            "startHousing",
            "startWhatNext",
            "nextChecklistResponse",
            "checklistScore",
            "recentRouteIDs",
            "savedItemIDs",
            "savedItemKinds",
        ],
        "AIWorkflowEngine",
    )

    expect_all(
        ai_view_model,
        [
            "activeWorkflow",
            "workflowStorageKey",
            "persistActiveWorkflow",
            "AIWorkflowEngine.advance",
            "AIWorkflowEngine.startIfNeeded",
            "AIResponseComposer.compose",
            "context.recentRouteIDs",
            "context.savedItemIDs",
            "context.savedItemKinds",
            "@Published private(set) var canRetryLastMessage = false",
            "canRetryLastMessage = false",
            "canRetryLastMessage = true",
            "canRetryLastMessage,",
            "let baseResources = await service.suggestResources(for: message, language: language)\n            guard activeRequestID == requestID, !Task.isCancelled else { return }",
            "if BuildWeekNewcomerDemo.matches(message)",
            "The named demo intentionally bypasses local intent interception",
            "candidate.isLiveOpenAI",
            "BuildWeekNewcomerDemo.localResponse",
            "answerCache.removeAll()",
            "removeObject(forKey: answerCacheStorageKey)",
        ],
        "AIViewModel integration",
    )

    expect_all(
        assistant_view,
        [
            "AssistantStructuredResponseCard",
            "response.quickActions",
            "AppNavigationResolver.destination",
            "ShareLink",
            "savedItemsStore.toggle",
            "if viewModel.canRetryLastMessage",
            "private func retryStatusLine(_ error: String) -> some View",
            "Task { await viewModel.retryLastMessage() }",
            '.accessibilityIdentifier("assistant.retry")',
            'let openSourceTitle = L10n.t("resource.open_source", lang)',
            'Label(openSourceTitle, systemImage: "link")',
            'L10n.t("resource.open_source", lang)',
            'L10n.t("common.verified_source", lang)',
            'L10n.t("common.source", lang)',
            'L10n.t("common.last_checked", lang)',
            "assistantEmptyInputHint",
            '.accessibilityIdentifier("assistant.empty.inputHint")',
            "assistantScrollBottomPadding(safeAreaBottom:",
            "PremiumVisualMetrics.Layout.bottomTerminalGap",
            "assistant.response.origin.live",
            "assistant.response.origin.localGuide",
            "assistant.response.model",
            "assistant.response.requestId",
            'accessibilityIdentifier("assistant.response.governance")',
            "governance.locationAssumption",
            "governance.uncertainty",
            "governance.escalation",
        ],
        "AIAssistantView quick actions",
    )
    expect(
        "Color.clear.frame(height: PremiumVisualMetrics.Layout.bottomTerminalGap)" not in assistant_view,
        "AIAssistantView empty state still has an artificial bottom spacer",
    )
    expect(
        "measuredComposerHeight + PremiumVisualMetrics.Layout.bottomTerminalGap" in assistant_view
        and "bottomComposerClearance" not in assistant_view,
        "AIAssistantView terminal scroll gap must include the compact composer height without duplicating tab-bar clearance",
    )
    for forbidden_source_label in ['Label("Open Source"', 'Text("Verified Source")', 'Text("Source:', 'Text("Last checked:']:
        expect(
            forbidden_source_label not in assistant_view,
            f"AIAssistantView contains hardcoded English source-card label {forbidden_source_label}",
        )

    expect_all(
        root,
        [
            "GlobalAIModeLauncher",
            "GlobalAIMode.allCases",
            "case askQuestion",
            "case explainScreen",
            "case nextStep",
            "case findInApp",
            "case translate",
            "case guideMe",
            "openGlobalAssistant",
            "global.aiLauncher",
            "context.topicSummary?.trimmingCharacters(in: .whitespacesAndNewlines)",
            "Do not translate only the screen title.",
        ],
        "global AI launcher",
    )
    translate_block = root.split("case .translate:", 1)[-1].split("case .guideMe:", 1)[0]
    expect(
        "context.topicTitle ?? context.category" not in translate_block,
        "global Translate mode still sends a screen title/category to the AI prompt",
    )
    expect(
        "requirementsText(primary: primary, language: language)" in ai_composer
        and "checklistText(results: [primary], language: language)" in ai_composer
        and "warningText(results: [primary], language: language)" in ai_composer,
        "AIResponseComposer must keep requirements/checklist/warnings scoped to the primary result",
    )

    expect_all(
        app_state,
        [
            "recentRouteIDs",
            "completedGuideIDs",
            "addRecentRouteID",
            "markGuideCompleted",
            "privacyExportPayload",
        ],
        "AppState AI context signals",
    )

    expect_all(
        app_destination_view,
        [
            "appState.addRecentRouteID",
            "appState.markGuideCompleted",
            "AppNavigationResolver.routeID(from: destination)",
        ],
        "AppDestinationView route tracking",
    )

    expect_all(
        ai_context_builder,
        [
            "static func automaticContext",
            "lastSearches: [],",
            "SavedItemsStore.shared.savedItems",
            "appState.visibleRecentRouteIDs()",
            "appState.visibleCompletedGuideIDs()",
            "AppSearchEngine().answerContext",
        ],
        "AIContextBuilder context assembly",
    )
    expect("recentSearches()" not in ai_context_builder, "AI context must not recover persisted raw search history")
    static_source_checks = expect_no_duplicate_static_sources(ai_context_builder, "AIContextBuilder")
    static_source_checks += expect_no_duplicate_static_sources(ai_composer, "AIResponseComposer")

    expect_all(
        tests,
        [
            "bsnSearchReturnsRouteSourceAndGraphContext",
            "healthInsuranceWorkflowAsksRequiredFollowups",
            "bsnWorkflowRoutesThroughMunicipalityDocumentsAndDigiD",
            "digidWorkflowRoutesToBSNWhenMissing",
            "fineLetterWorkflowWarnsAndRoutesToFinesLettersSources",
            "housingWorkflowBranchesBySituation",
            "whatNextWorkflowUsesContextAndChecklistRoutes",
            "whatNextWorkflowAvoidsRepeatingCurrentChecklistRoute",
            "workflowQuickActionDestinationsResolve",
            "aiContextCarriesProgressWithoutReadingLegacySearchText",
            "missingInformationResponseStillLinksSourceAndContextDestinations",
            "representativeAssistantQueriesUseKnowledgeNavigationSourcesAndActions",
            "unverifiedFallbackResponsesStillExposeBasicActions",
        ],
        "KnowledgeIndexTests AI audit coverage",
    )

    expect_all(
        foundation_tests,
        [
            "aiClientRequestContainsOnlyBoundedNewcomerFields",
            "aiClientRequestUsesAppLocaleAsAssistantLocale",
            "responseParserAcceptsTypedQuickActions",
            "responseParserBackfillsQuickActionsWhenBackendOmitsThem",
            "responseParserRepairsGluedDynamicFields",
            "responseParserDropsDuplicatedWarningsAndSectionBodies",
            "responseParserLocalizesGenericFallbackLabels",
            "localFallbackReturnsVerifiedCachedBSNResponse",
            "response.quickActions.contains",
        ],
        "AIFoundationTests quick action contract",
    )

    expect_all(
        newcomer_tests,
        [
            "boundedScenarioUsesExistingKnowledgeIndexRecordsAndRoutes",
            "parserRejectsUnapprovedReleaseEvenWhenLiveShapeIsComplete",
            "governanceContractRequiresReleaseDateLocationUncertaintyAndEscalation",
            "parserRejectsLiveResponseWithoutCompleteGovernanceContract",
            "parserRejectsMismatchedSourceVerificationDate",
            "parserRejectsDuplicateDecisionTraceRecordsWithoutTrapping",
            "languageGuardChecksVisibleGovernanceBoundaryText",
            "liveClassificationRequiresVerifiedApprovedBundledRelease",
            "parserRejectsModelsOutsideYouNewSolPolicy",
            "parserRejectsSourceOrRouteOutsideServerContract",
            "unavailableBackendUsesExplicitDeterministicFallback",
            "legacyPersistedResponseCannotBecomeLiveByDecoding",
            "endpointValidationRequiresHTTPSOutsideExplicitLoopbackTests",
        ],
        "BuildWeekNewcomerDemoTests",
    )

    print("AI subsystem static QA passed")
    print(f"- Static AI OfficialSource tuples checked: {static_source_checks}")
    print(f"- Bounded governed release records checked: {len(expected_release_sources)} (all QA)")


if __name__ == "__main__":
    main()
