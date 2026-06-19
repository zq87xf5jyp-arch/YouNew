import SwiftUI

#if DEBUG
struct KnowledgeDebugView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    @StateObject private var searchViewModel = SearchViewModel(language: .english)
    @State private var query = "BSN"

    private let requiredQueries = [
        "BSN", "DigiD", "huisarts", "gemeente", "taxes", "toeslagen",
        "штраф", "налог", "врач", "жильё", "работа",
        "fiets", "boete", "zorgverzekering", "huur", "werk", "uitkering"
    ]

    private var contextPreview: AIContext {
        AIContextBuilder.searchContext(query: query, language: languageManager.appLanguage, appState: appState)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                releaseInfoSection
                appIconDiagnosticsSection
                countsSection
                searchPanel
                contextSection
                missingSourcesSection
                localizationSection
                releaseFlagsSection
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .tabBarScrollReserve()
        }
        .appSceneBackground()
        .navigationTitle(knowledgeDiagnosticsTitle)
        .onAppear {
            runSearch(query)
        }
    }

    private var knowledgeDiagnosticsTitle: String {
        switch languageManager.appLanguage {
        case .russian: return "Проверка источников"
        case .dutch: return "Broncontrole"
        case .english: return "Source coverage"
        }
    }

    private var countsSection: some View {
        section("Data counts") {
            metric("Knowledge topics", MockExpansionData.knowledgeTopics.count)
            metric("Life scenarios", MockExpansionData.lifeScenarios.count)
            metric("Official services", MockExpansionData.officialServices.count)
            metric("Provinces", MockExpansionData.provinceProfiles.count)
            metric("Cities", MockExpansionData.cityProfiles.count)
            metric("Roadmap weeks", MockExpansionData.newcomerRoadmap.count)
            metric("Suggested searches", MockExpansionData.suggestedSearches.count)
        }
    }

    private var releaseInfoSection: some View {
        section("Release diagnostics") {
            statusRow("Build", "\(bundleVersion) (\(buildNumber))", color: AppColors.textSecondary)
            statusRow("Environment", isDebugBuild ? "DEBUG" : "RELEASE", color: isDebugBuild ? AppColors.warning : AppColors.success)
            statusRow("Bundle ID", bundleIdentifier, color: bundleIdentifier.hasPrefix("com.") ? AppColors.success : AppColors.error)
            statusRow("AI status", aiStatus, color: aiStatus == "Local fallback" ? AppColors.warning : AppColors.success)
            statusRow("Source validation", sourceIssues.isEmpty ? "OK" : "\(sourceIssues.count) issue(s)", color: sourceIssues.isEmpty ? AppColors.success : AppColors.error)
            statusRow("Search coverage", "\(coveredRequiredQueries)/\(requiredQueries.count)", color: coveredRequiredQueries == requiredQueries.count ? AppColors.success : AppColors.warning)
        }
    }

    private var appIconDiagnosticsSection: some View {
        section("App icon assets") {
            let missing = missingAppIconDiagnostics
            if missing.isEmpty {
                statusRow("Generated icon PNGs", "OK", color: AppColors.success)
            } else {
                ForEach(missing, id: \.self) { path in
                    statusRow("Missing", path, color: AppColors.error)
                }
            }
        }
    }

    private var searchPanel: some View {
        section("Search test panel") {
            TextField("Search query", text: $query)
                .textFieldStyle(.roundedBorder)
                .onChange(of: query) { _, newValue in runSearch(newValue) }

            let results = searchViewModel.displayedResults
            Text("\(results.count) result(s)")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)

            ForEach(results.prefix(5)) { answer in
                VStack(alignment: .leading, spacing: AppSpacing.xxSmall) {
                    Text(answer.title(languageManager.appLanguage))
                        .font(AppTypography.body.weight(.semibold))
                        .foregroundStyle(AppColors.textPrimary)
                    Text(answer.officialSourceName)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Divider()

            ForEach(requiredQueries, id: \.self) { value in
                HStack {
                    Text(value)
                    Spacer()
                    Text(resultCount(for: value) > 0 ? "OK" : "Missing")
                        .font(AppTypography.caption.weight(.semibold))
                        .foregroundStyle(resultCount(for: value) > 0 ? AppColors.success : AppColors.error)
                }
                .font(AppTypography.caption)
            }
        }
    }

    private var contextSection: some View {
        section("AI context preview") {
            metric("Sources", contextPreview.officialSources.count)
            metric("Summary chars", contextPreview.topicSummary?.count ?? 0)
            Text(contextPreview.topicSummary ?? "No summary")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .textSelection(.enabled)
        }
    }

    private var missingSourcesSection: some View {
        section("Missing sources checker") {
            let issues = sourceIssues
            if issues.isEmpty {
                statusRow("Source metadata", "OK", color: AppColors.success)
            } else {
                ForEach(issues, id: \.self) { issue in
                    statusRow(issue, "Fix", color: AppColors.error)
                }
            }
        }
    }

    private var localizationSection: some View {
        section("Localization coverage") {
            metric("Search answers with EN/RU/NL titles", localizedTitleCount)
            metric("Total search answers", MockSearchAnswersData.items.count)
            metric("Suggested searches", MockExpansionData.suggestedSearches.count)
        }
    }

    private var releaseFlagsSection: some View {
        section("Runtime checks") {
            statusRow("DEBUG diagnostics gated", "OK", color: AppColors.success)
            statusRow("Privacy manifest present", privacyManifestPresent ? "OK" : "Missing", color: privacyManifestPresent ? AppColors.success : AppColors.error)
            statusRow("Manual device QA", "Required", color: AppColors.warning)
            statusRow("Archive validation", "Required", color: AppColors.warning)
        }
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text(title)
                .font(AppTypography.cardTitle)
                .foregroundStyle(AppColors.textPrimary)
            content()
        }
        .appCardStyle()
    }

    private func metric(_ label: String, _ value: Int) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text("\(value)")
                .fontWeight(.semibold)
        }
        .font(AppTypography.body)
        .foregroundStyle(AppColors.textPrimary)
    }

    private func statusRow(_ label: String, _ status: String, color: Color) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
            Spacer()
            Text(status)
                .fontWeight(.semibold)
                .foregroundStyle(color)
        }
        .font(AppTypography.caption)
        .foregroundStyle(AppColors.textPrimary)
    }

    private func runSearch(_ value: String) {
        searchViewModel.query = value
    }

    private func resultCount(for value: String) -> Int {
        let viewModel = SearchViewModel(initialQuery: value, language: .english)
        return viewModel.displayedResults.count
    }

    private var sourceIssues: [String] {
        var issues: [String] = []

        for topic in MockExpansionData.knowledgeTopics {
            if topic.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                issues.append("Empty title in knowledge topic")
            }
            if topic.summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                issues.append("Empty summary: \(topic.title)")
            }
            if topic.officialSourceName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                issues.append("Missing source name: \(topic.title)")
            }
            if topic.officialSourceURL.host == nil {
                issues.append("Broken source URL: \(topic.title)")
            }
        }

        for service in MockExpansionData.officialServices where service.officialURL.host == nil {
            issues.append("Broken service URL: \(service.name)")
        }

        return issues
    }

    private var localizedTitleCount: Int {
        MockSearchAnswersData.items.filter { answer in
            AppLanguage.allCases.allSatisfy { language in
                answer.titleByLanguage[language]?.isEmpty == false
            }
        }.count
    }

    private var coveredRequiredQueries: Int {
        requiredQueries.filter { resultCount(for: $0) > 0 }.count
    }

    private var bundleVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown"
    }

    private var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "unknown"
    }

    private var bundleIdentifier: String {
        Bundle.main.bundleIdentifier ?? "unknown"
    }

    private var aiStatus: String {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: "YOUNEW_AI_PROXY_URL") as? String,
              !raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              AppURL.validatedWebURL(URL(string: raw.trimmingCharacters(in: .whitespacesAndNewlines))) != nil else {
            return "Local fallback"
        }
        return "Proxy configured"
    }

    private var privacyManifestPresent: Bool {
        Bundle.main.url(forResource: "PrivacyInfo", withExtension: "xcprivacy") != nil
    }

    private var missingAppIconDiagnostics: [String] {
        let repoRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let iconSet = repoRoot.appendingPathComponent("YouNew/Assets.xcassets/AppIcon.appiconset")

        return [16, 32, 64, 128, 256, 512, 1024].compactMap { size in
            let expected = iconSet.appendingPathComponent("icon-\(size).png")
            return FileManager.default.fileExists(atPath: expected.path) ? nil : expected.path
        }
    }

    private var isDebugBuild: Bool {
        #if DEBUG
        true
        #else
        false
        #endif
    }
}
#endif
