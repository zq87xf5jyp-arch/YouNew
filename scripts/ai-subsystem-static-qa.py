#!/usr/bin/env python3
from pathlib import Path
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

    expect_all(
        ai_context,
        [
            "struct AIContext",
            "struct AIResponse",
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
            "struct RetrievalContext",
            "currentRouteID",
            "recentRouteIDs",
            "lastSearches",
            "completedChecklistItemIDs",
            "completedGuideIDs",
            "savedItemIDs",
            "savedItemKinds",
            "journeyProgress",
            "backendMustRetrieveVerifiedContext",
            "strictJSONOnly",
            "AppURL.validatedWebURL(URL(string: trimmed))",
        ],
        "AIClient retrieval contract",
    )
    expect(
        "return URL(string: raw)" not in ai_client,
        "AIClient accepts unvalidated AI proxy endpoint URLs",
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
            "Color.clear.frame(height: assistantScrollBottomPadding(safeAreaBottom: safeAreaBottom))",
        ],
        "AIAssistantView quick actions",
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
            "recentSearches()",
            "SavedItemsStore.shared.savedItems",
            "appState.visibleRecentRouteIDs()",
            "appState.visibleCompletedGuideIDs()",
            "AppSearchEngine().answerContext",
        ],
        "AIContextBuilder context assembly",
    )
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
            "aiContextCarriesRouteSearchProgressAndCompletionSignals",
            "missingInformationResponseStillLinksSourceAndContextDestinations",
            "representativeAssistantQueriesUseKnowledgeNavigationSourcesAndActions",
            "unverifiedFallbackResponsesStillExposeBasicActions",
        ],
        "KnowledgeIndexTests AI audit coverage",
    )

    expect_all(
        foundation_tests,
        [
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

    print("AI subsystem static QA passed")
    print(f"- Static AI OfficialSource tuples checked: {static_source_checks}")


if __name__ == "__main__":
    main()
