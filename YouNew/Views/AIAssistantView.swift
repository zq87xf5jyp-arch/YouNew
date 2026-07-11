import SwiftUI
import Foundation
#if canImport(UIKit)
import UIKit
#endif

private enum ExternalAssistantToolGroup: String, CaseIterable, Identifiable {
    case localGuidance
    case connectedTools
    case creativeProduction

    var id: String { rawValue }
}

private struct ExternalAssistantTool: Identifiable {
    let id: String
    let group: ExternalAssistantToolGroup
    let title: String
    let pluginURLString: String
    let fallbackDestination: AppDestination?

    static let all: [ExternalAssistantTool] = [
        ExternalAssistantTool(
            id: "official-sources",
            group: .localGuidance,
            title: "Official sources",
            pluginURLString: "app://connector_69312da8e4dc81919370cb86fd172b6c",
            fallbackDestination: AppDestination.officialSources
        ),
        ExternalAssistantTool(
            id: "search",
            group: .localGuidance,
            title: "Search",
            pluginURLString: "app://asdk_app_698a66e4227c8191b75dd67742387dcf",
            fallbackDestination: AppDestination.searchList
        ),
        ExternalAssistantTool(
            id: "knm",
            group: .localGuidance,
            title: "KNM",
            pluginURLString: "plugin://build-ios-apps@openai-curated-remote/",
            fallbackDestination: AppDestination.knm
        ),
        ExternalAssistantTool(
            id: "dutch-a1-a2",
            group: .localGuidance,
            title: "Dutch A1-A2",
            pluginURLString: "plugin://template-creator@openai-primary-runtime/",
            fallbackDestination: AppDestination.dutchA1A2
        ),
        ExternalAssistantTool(
            id: "first-steps",
            group: .localGuidance,
            title: "First steps",
            pluginURLString: "plugin://computer-use@openai-bundled/",
            fallbackDestination: AppDestination.firstSteps
        ),
        ExternalAssistantTool(
            id: "browser",
            group: .connectedTools,
            title: "Browser",
            pluginURLString: "plugin://browser@openai-bundled/",
            fallbackDestination: nil
        ),
        ExternalAssistantTool(
            id: "chrome",
            group: .connectedTools,
            title: "Chrome",
            pluginURLString: "plugin://chrome@openai-bundled/",
            fallbackDestination: nil
        ),
        ExternalAssistantTool(
            id: "canva",
            group: .creativeProduction,
            title: "Canva",
            pluginURLString: "plugin://canva@openai-curated-remote/",
            fallbackDestination: nil
        ),
        ExternalAssistantTool(
            id: "creative-production",
            group: .creativeProduction,
            title: "Creative Production",
            pluginURLString: "plugin://creative-production@openai-curated-remote/",
            fallbackDestination: nil
        ),
        ExternalAssistantTool(
            id: "product-design",
            group: .creativeProduction,
            title: "Product Design",
            pluginURLString: "plugin://product-design@openai-curated-remote/",
            fallbackDestination: nil
        )
    ]
}

struct AIAssistantView: View {
    @StateObject private var viewModel = AIViewModel()
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var router: TabRouter
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @FocusState private var isInputFocused: Bool
    @State private var measuredComposerHeight: CGFloat = 86
    @State private var activeAssistantDestination: AppDestination?
    @StateObject private var voiceInput = VoiceInputController()
    let mapToolDestination: AppDestination?
    let onOpenMap: () -> Void
    let onNavigate: (AppDestination) -> Void

    init(
        mapToolDestination: AppDestination? = nil,
        onOpenMap: @escaping () -> Void,
        onNavigate: @escaping (AppDestination) -> Void = { _ in }
    ) {
        self.mapToolDestination = mapToolDestination
        self.onOpenMap = onOpenMap
        self.onNavigate = onNavigate
    }

    private var lang: AppLanguage { languageManager.appLanguage }

    private var displayedQuickPrompts: [String] {
        viewModel.displayedQuickPrompts(for: lang)
    }

    private var hasConversation: Bool {
        viewModel.conversation.messages.contains { $0.role == .assistant || $0.role == .user }
    }

    private var visibleMessages: [AIMessage] {
        viewModel.conversation.messages
    }

    private var latestAssistantMessageAnchor: UnitPoint {
        UnitPoint(x: 0.5, y: -0.04)
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                GlobalBackgroundView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                VStack(spacing: 0) {
                    ScrollViewReader { scrollProxy in
                        ScrollView {
                            Color.clear
                                .frame(height: 0)
                                .id("assistantTop")

                            if !hasConversation {
                                emptyChatState(
                                    safeAreaBottom: proxy.safeAreaInsets.bottom,
                                    availableHeight: proxy.size.height,
                                    availableWidth: min(proxy.size.width, 920)
                                )
                                    .id("empty")
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(visibleMessages) { message in
                                        chatBubble(message)
                                            .id(message.id)
                                    }

                                    if let error = viewModel.lastError {
                                        if viewModel.canRetryLastMessage {
                                            retryStatusLine(error)
                                        } else {
                                            chatStatusLine(icon: "exclamationmark.triangle.fill", text: error, tint: AppColors.warning)
                                        }
                                    } else if viewModel.isOffline {
                                        chatStatusLine(icon: "wifi.slash", text: offlineModeText, tint: AppColors.warning)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                .padding(.bottom, assistantScrollBottomPadding(safeAreaBottom: proxy.safeAreaInsets.bottom))
                                .frame(maxWidth: 760)
                                .frame(maxWidth: .infinity)
                            }

                            Color.clear
                                .frame(height: 12)
                                .id("bottom")
                        }
                        .nlScrollDismissesKeyboardInteractively()
                        .frame(width: proxy.size.width)
                        .clipped()
                        .onChange(of: viewModel.conversation.messages.count) { _, _ in
                            scrollToLatestAssistantMessage(scrollProxy)
                        }
                        .onChange(of: viewModel.isLoading) { _, isLoading in
                            guard !isLoading else { return }
                            scrollToLatestAssistantMessage(scrollProxy)
                        }
                        .onReceive(router.aiScrollTop) { _ in
                            dismissKeyboard()
                            withAnimation(.easeInOut(duration: 0.24)) {
                                scrollProxy.scrollTo("assistantTop", anchor: .top)
                            }
                        }
                    }

                    assistantComposerInset(safeAreaBottom: proxy.safeAreaInsets.bottom)
                }
            }
            .onPreferenceChange(AssistantComposerHeightPreferenceKey.self) { height in
                measuredComposerHeight = max(44, height)
            }
        }
        .navigationTitle(L10n.t("ai.title", lang))
        .nlNavigationInline()
        .onAppear {
            applyPendingOrDefaultContext()
        }
        .onDisappear {
            voiceInput.stop()
        }
        .onChange(of: appState.selectedUserStatus) { _, _ in
            viewModel.updateContext(from: appState, language: lang)
        }
        .onReceive(appState.$checklistItems) { _ in
            viewModel.updateContext(from: appState, language: lang)
        }
        .onChange(of: languageManager.appLanguage) { _, _ in
            applyPendingOrDefaultContext()
        }
        .onChange(of: appState.pendingAIContext) { _, _ in
            applyPendingOrDefaultContext()
        }
        .onChange(of: viewModel.conversation.messages.count) { _, _ in
            isInputFocused = false
        }
        .toolbar {
            if hasConversation {
                ToolbarItem(placement: clearConversationToolbarPlacement) {
                    Button {
                        dismissKeyboard()
                        viewModel.clearConversation()
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(AppColors.textSecondary)
                    .accessibilityLabel(clearConversationLabel)
                    .accessibilityIdentifier("assistant.clearConversation")
                }
            }

#if os(iOS)
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(L10n.t("common.done", lang)) {
                    dismissKeyboard()
                }
            }
#endif
        }
        .navigationDestination(
            isPresented: Binding(
                get: { activeAssistantDestination != nil },
                set: { isPresented in
                    if !isPresented {
                        activeAssistantDestination = nil
                    }
                }
            )
        ) {
            if let activeAssistantDestination {
                AppDestinationView(destination: activeAssistantDestination)
            }
        }
    }

    private var clearConversationToolbarPlacement: ToolbarItemPlacement {
        #if os(iOS)
        .topBarTrailing
        #else
        .automatic
        #endif
    }

    private func assistantScrollBottomPadding(safeAreaBottom: CGFloat) -> CGFloat {
        measuredComposerHeight + PremiumVisualMetrics.Layout.bottomTerminalGap
    }

    private func scrollToLatestAssistantMessage(_ scrollProxy: ScrollViewProxy) {
        guard let targetID = visibleMessages.last?.id else {
            scrollProxy.scrollTo("bottom", anchor: .bottom)
            return
        }

        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
            scrollProxy.scrollTo(targetID, anchor: latestAssistantMessageAnchor)
        }

        Task { @MainActor in
            withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                scrollProxy.scrollTo(targetID, anchor: latestAssistantMessageAnchor)
            }
        }
    }

    private func assistantComposerTabBarClearance(safeAreaBottom: CGFloat) -> CGFloat {
        0
    }

    private var assistantChatHeader: some View {
        VStack(spacing: 4) {
            Text(L10n.t("ai.title", lang))
                .font(.system(size: 20, weight: .semibold, design: .default))
                .foregroundStyle(.white)
                .lineLimit(1)

            Text(assistantChatSubtitle)
                .font(.system(size: 13, weight: .regular, design: .default))
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .frame(maxWidth: .infinity)
    }

    private func assistantComposerInset(safeAreaBottom: CGFloat) -> some View {
        let tabBarClearance = assistantComposerTabBarClearance(safeAreaBottom: safeAreaBottom)

        return VStack(spacing: 0) {
            VStack(spacing: 8) {
                assistantInputBar
            }
            .padding(.top, 4)
            .padding(.bottom, 6 + tabBarClearance)
            .background {
                GeometryReader { geometry in
                    Color.clear
                        .preference(
                            key: AssistantComposerHeightPreferenceKey.self,
                            value: geometry.size.height
                        )
                }
            }
        }
    }

    private var emptySuggestionChips: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(displayedQuickPrompts, id: \.self) { prompt in
                suggestionChip(prompt)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func suggestionChip(_ prompt: String) -> some View {
        Button {
            isInputFocused = false
            Task { await viewModel.useQuickPrompt(prompt) }
        } label: {
            Text(prompt)
                .font(.system(size: 12, weight: .semibold, design: .default))
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.74)
                .padding(.horizontal, 12)
                .frame(minHeight: 44)
                .background(Color.white.opacity(0.055))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.white.opacity(0.08), lineWidth: 0.7))
        }
        .buttonStyle(.plain)
    }

    private var oneLineSafetyWarning: some View {
        Text(sourceFallbackText)
            .font(.system(size: 10.5, weight: .regular, design: .default))
            .foregroundStyle(AppColors.textTertiary.opacity(0.72))
            .lineLimit(1)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, AppSpacing.medium)
            .padding(.vertical, 2)
            .background(Color.clear)
    }

    private var assistantChatSubtitle: String {
        switch lang {
        case .russian: return "Спросите о темах, которые есть в YouNew"
        case .dutch: return "Vraag over onderwerpen die in YouNew staan"
        case .english: return "Ask about topics covered in YouNew"
        }
    }

    private func localizedAssistantText(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .russian: return ru
        case .dutch: return nl
        case .english: return en
        }
    }

    private var cancelResponseLabel: String {
        switch lang {
        case .russian: return "Остановить ответ"
        case .dutch: return "Antwoord stoppen"
        case .english: return "Stop response"
        }
    }

    private func chatStatusLine(icon: String, text: String, tint: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(tint)
            Text(text)
                .font(.system(size: 12, weight: .medium, design: .default))
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func retryStatusLine(_ error: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            chatStatusLine(icon: "exclamationmark.triangle.fill", text: error, tint: AppColors.warning)

            Button {
                Task { await viewModel.retryLastMessage() }
            } label: {
                Label(retryLabel, systemImage: "arrow.clockwise")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .frame(minHeight: 44)
                    .padding(.horizontal, 12)
                    .background(AppColors.warning.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .buttonStyle(.plain)
            .foregroundStyle(AppColors.warning)
            .accessibilityIdentifier("assistant.retry")
        }
    }

    private static let inputCharacterLimit = 2_000
    private var inputNearLimit: Bool { viewModel.input.count > 1_800 }
    private var inputAtLimit: Bool { viewModel.input.count >= Self.inputCharacterLimit }

    private var assistantInputBar: some View {
        VStack(spacing: 0) {
            Text(privacyInputHint)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.42))
                .lineLimit(1)
                .minimumScaleFactor(0.74)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 18)
                .padding(.top, 0)

            HStack(alignment: .center, spacing: 8) {
                Button {
#if canImport(UIKit)
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
#endif
                    voiceInput.toggle(language: lang)
                } label: {
                    Image(systemName: voiceInput.isListening ? "waveform" : "mic")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(voiceInput.isListening ? Color.white : AppColors.textSecondary)
                        .frame(width: 38, height: 38)
                        .background(voiceInput.isListening ? AppColors.error : AppColors.card.opacity(0.94), in: Circle())
                        .symbolEffect(.variableColor.iterative, options: .repeating, isActive: voiceInput.isListening)
                }
                .buttonStyle(AppPressableButtonStyle())
                .accessibilityLabel(voiceInput.isListening ? voiceStopLabel : voiceStartLabel)
                .accessibilityIdentifier("assistant.voice")

                ZStack(alignment: .leading) {
                    if viewModel.input.isEmpty {
                        Text(assistantInputPlaceholder)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(Color.white.opacity(0.35))
                            .lineLimit(1)
                            .minimumScaleFactor(0.68)
                            .padding(.leading, 2)
                            .padding(.trailing, 2)
                            .allowsHitTesting(false)
                    }

                    TextField("", text: $viewModel.input, axis: .vertical)
                        .textFieldStyle(.plain)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(.white)
                        .tint(AppColors.dutchOrange)
                        .accentColor(AppColors.dutchOrange)
                        .lineLimit(1...3)
                        .frame(minHeight: 32, alignment: .center)
                        .padding(.vertical, 6)
                        .focused($isInputFocused)
                        .submitLabel(.send)
                        .onSubmit {
                            sendCurrentMessageAndDismissKeyboard()
                        }
                        .onChange(of: viewModel.input) { _, newValue in
                            if newValue.count > Self.inputCharacterLimit {
                                viewModel.input = String(newValue.prefix(Self.inputCharacterLimit))
                            }
                        }
                        .accessibilityLabel(assistantInputPlaceholder)
                        .accessibilityIdentifier("assistant.input")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AppColors.card.opacity(0.94))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(
                            inputAtLimit ? AppColors.warning.opacity(0.70)
                                : isInputFocused ? AppColors.dutchOrange.opacity(0.60)
                                : Color.white.opacity(0.12),
                            lineWidth: 1
                        )
                )
                .animation(.easeOut(duration: 0.2), value: isInputFocused)
                .animation(.easeOut(duration: 0.15), value: inputAtLimit)
                .overlay(alignment: .bottomTrailing) {
                    if inputNearLimit {
                        Text("\(viewModel.input.count)/\(Self.inputCharacterLimit)")
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundStyle(inputAtLimit ? AppColors.warning : Color.white.opacity(0.40))
                            .padding(.trailing, 8)
                            .padding(.bottom, 4)
                            .allowsHitTesting(false)
                    }
                }

                Button {
                    if viewModel.isLoading {
                        viewModel.cancelCurrentResponse()
                    } else {
                        sendCurrentMessageAndDismissKeyboard()
                    }
                } label: {
                    Image(systemName: viewModel.isLoading ? "xmark" : "arrow.up")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(sendButtonForeground)
                        .frame(width: 38, height: 38)
                        .background { sendButtonBackground }
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.isLoading && viewModel.input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityLabel(viewModel.isLoading ? cancelResponseLabel : L10n.t("common.send", lang))
                .accessibilityIdentifier(viewModel.isLoading ? "assistant.cancel" : "assistant.send")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 3)
            .background(Color.clear)
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
        }
        .onChange(of: voiceInput.transcript) { _, transcript in
            guard !transcript.isEmpty else { return }
            viewModel.input = String(transcript.prefix(Self.inputCharacterLimit))
        }
        .overlay(alignment: .top) {
            if case .unavailable(let message) = voiceInput.state {
                Text(message)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.warning)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppColors.card.opacity(0.96), in: Capsule())
                    .offset(y: -42)
            }
        }
    }

    private func sendCurrentMessageAndDismissKeyboard() {
        guard !viewModel.input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !viewModel.isLoading else { return }
        dismissKeyboard()
        Task {
            await viewModel.sendCurrentMessage()
            await MainActor.run {
                dismissKeyboard()
            }
        }
    }

    private func dismissKeyboard() {
        isInputFocused = false
        #if canImport(UIKit)
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
        #endif
    }

    @ViewBuilder
    private var sendButtonBackground: some View {
        if viewModel.isLoading {
            AppColors.dutchOrange.opacity(0.78)
        } else if viewModel.input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            AppColors.card.opacity(0.72)
        } else {
            LinearGradient(
                colors: [
                    AppColors.dutchOrange,
                    Color(red: 1.0, green: 107 / 255, blue: 0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    private var sendButtonForeground: Color {
        if viewModel.isLoading { return .white }
        return viewModel.input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? Color.white.opacity(0.34)
            : .white
    }

    private func emptyChatState(safeAreaBottom: CGFloat, availableHeight: CGFloat, availableWidth: CGFloat) -> some View {
        let compactVertical = availableHeight < 760
        let sectionSpacing: CGFloat = compactVertical ? 12 : 18
        let toolSpacing: CGFloat = compactVertical ? 12 : 18

        return VStack(spacing: sectionSpacing) {
            assistantProductIntro

            VStack(spacing: toolSpacing) {
                assistantActionPanel
                activeContextCard
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: compactVertical ? 10 : 14) {
                HStack(alignment: .center) {
                    Text(suggestionsTitle)
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)

                    Spacer()

                    Button {
                        isInputFocused = true
                    } label: {
                        Text(viewAllTitle)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.88))
                            .padding(.horizontal, 14)
                            .frame(height: 36)
                            .background(Color.white.opacity(0.10))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.white.opacity(0.10), lineWidth: 0.8))
                    }
                    .buttonStyle(.plain)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 14) {
                        ForEach(displayedQuickPrompts.prefix(6), id: \.self) { prompt in
                            quickPromptButton(prompt)
                                .frame(width: assistantTopicCardWidth(availableWidth: max(0, availableWidth - 40)))
                        }
                    }
                    .padding(.horizontal, 0)
                    .padding(.vertical, 2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .clipped()
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .leading)

            officialSourceVisualBlock
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: min(availableWidth, 920), alignment: .top)
        .frame(maxWidth: .infinity, alignment: .top)
    }

    private var assistantProductIntro: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            ProductStatusStrip(
                title: L10n.t("ai.title", lang),
                subtitle: compactAssistantSubtitle,
                symbol: "sparkles",
                accent: AppColors.violet,
                actionTitle: localizedAssistantText(en: "Ask", nl: "Vraag", ru: "Спросить")
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("assistant.productIntro")
    }

    private func assistantTopicCardWidth(availableWidth: CGFloat) -> CGFloat {
        min(max(availableWidth * 0.72, 220), 320)
    }

    private var assistantEmptyInputHint: some View {
        Button {
            isInputFocused = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "keyboard.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(AppColors.dutchOrange)
                    .frame(width: 38, height: 38)
                    .background(AppColors.dutchOrange.opacity(0.13))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(emptyInputHintTitle)
                        .font(.system(.subheadline, design: .rounded).weight(.bold))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(2)
                    Text(assistantInputPlaceholder)
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                }

                Spacer(minLength: 6)
            }
            .padding(14)
            .background(AppColors.glassSurface.opacity(0.76))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppColors.dutchOrange.opacity(0.18), lineWidth: 0.75)
            )
            .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("assistant.empty.inputHint")
    }

    private func chatBubble(_ message: AIMessage) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.role == .assistant {
                assistantAvatar
                chatMessageContent(message)
                Spacer(minLength: 0)
            } else {
                Spacer(minLength: 56)
                chatMessageContent(message)
                    .frame(maxWidth: 560, alignment: .trailing)
            }
        }
        .frame(maxWidth: .infinity, alignment: message.role == .user ? .trailing : .leading)
    }

    private var assistantAvatar: some View {
        ZStack {
            Circle()
                .fill(Color(red: 26 / 255, green: 42 / 255, blue: 74 / 255))
                .frame(width: 28, height: 28)
            Image(systemName: "sparkles")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppColors.dutchOrange)
        }
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func chatMessageContent(_ message: AIMessage) -> some View {
        if message.status == .sending {
            AIWritingIndicator(text: L10n.t("ai.thinking", lang))
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier("assistant.message.loading")
        } else if message.role == .assistant,
           let response = viewModel.structuredResponse(for: message.id) {
            AssistantStructuredResponseCard(
                response: response,
                accent: AppColors.dutchOrange,
                destination: destination(for: response),
                onDestinationAction: { destination in
                    isInputFocused = false
                    activeAssistantDestination = destination
                },
                onQueryAction: { query in
                    Task { await viewModel.useQuickPrompt(query) }
                }
            )
        } else if message.role == .assistant && message.text.count > 120 {
            AssistantAnswerSummary(
                sections: assistantSections(from: message.text),
                accent: AppColors.dutchOrange
            )
        } else {
            Text(message.text)
                .font(.system(size: 15))
                .foregroundStyle(message.role == .user ? Color.white : Color.white.opacity(0.9))
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background {
                    chatBubbleBackground(isUser: message.role == .user)
                }
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay {
                    if message.role == .assistant {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(AppSurface.b1, lineWidth: 0.5)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                .frame(
                    maxWidth: message.role == .user ? 560 : .infinity,
                    alignment: message.role == .user ? .trailing : .leading
                )
                .accessibilityIdentifier(message.role == .user ? "assistant.message.user" : "assistant.message.assistant")
        }
    }

    private func destination(for response: AIResponse) -> AppDestination? {
        destination(for: response.nextStep?.destinationID ?? response.appDestinationID)
    }

    private func destination(for rawID: String?) -> AppDestination? {
        AppNavigationResolver.destination(for: rawID, visibleFor: appState.selectedUserStatus?.personaTag)
    }

    @ViewBuilder
    private func chatBubbleBackground(isUser: Bool) -> some View {
        if isUser {
            LinearGradient(
                colors: [AppColors.dutchOrange, Color(red: 234 / 255, green: 101 / 255, blue: 8 / 255)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            AppSurface.e1
        }
    }

    private var assistantHero: some View {
        ZStack(alignment: .top) {
            PremiumImageView(
                asset: ContentArtworkRegistry.asset(for: .aiHero),
                language: lang,
                height: PremiumVisualMetrics.Hero.regularHeight,
                aspectRatio: nil,
                mode: .fill,
                cornerRadius: AppCornerRadius.hero,
                overlayStyle: .none,
                fallbackCategory: .ai,
                accessibilityLabel: heroTitle,
                targetPixelWidth: PremiumVisualMetrics.Image.heroTargetPixelWidth,
                role: .hero,
                overlayPolicy: .adaptive,
                focalPoint: .center
            )
            .accessibilityHidden(true)

            LinearGradient(
                colors: [
                    Color.black.opacity(0.10),
                    Color.black.opacity(0.35),
                    Color.black.opacity(0.65)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            RadialGradient(
                colors: [AppColors.cyanGlow.opacity(0.28), .clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 260
            )

            VStack(spacing: 18) {
                HStack(spacing: 16) {
                    Spacer(minLength: 0)

                    aiTopPill

                    Button {
                        isInputFocused = true
                    } label: {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 18, weight: .black))
                            .foregroundStyle(AppColors.dutchOrange)
                            .frame(width: 54, height: 54)
                            .background(Color.white.opacity(0.075))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Color.white.opacity(0.13), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)

                    Spacer(minLength: 0)
                }

                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(heroTitle)
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                            .minimumScaleFactor(0.72)

                        Text(heroSubtitleShort)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.84))
                            .lineLimit(2)
                    }
                    .padding(.horizontal, 20)

                    heroPromptBar
                        .padding(.horizontal, 20)
                }

                Spacer(minLength: 0)
            }
            .padding(.top, 24)
        }
        .frame(height: PremiumVisualMetrics.Hero.regularHeight)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.hero, style: .continuous))
        .overlay(alignment: .bottom) {
            LinearGradient(
                colors: [.clear, AppColors.navyDeep],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 54)
            .allowsHitTesting(false)
        }
        .accessibilityIdentifier("assistant.hero")
    }

    private var aiTopPill: some View {
        HStack(spacing: 16) {
            GlassVisualBadge(size: 38, cornerRadius: 12, accent: AppColors.softBlue) {
                PremiumImageView(
                    asset: ContentArtworkRegistry.asset(for: .aiHero),
                    language: lang,
                    height: 38,
                    aspectRatio: nil,
                    mode: .fill,
                    cornerRadius: 0,
                    overlayStyle: .none,
                    fallbackCategory: .ai,
                    accessibilityLabel: L10n.t("ai.title", lang),
                    targetPixelWidth: 320,
                    role: .thumbnail,
                    overlayPolicy: .none,
                    focalPoint: .center
                )
            }

            Text(L10n.t("ai.title", lang))
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)

            Image(systemName: "sparkles")
                .font(.system(size: 21, weight: .black))
                .foregroundStyle(AppColors.cyanGlow)
        }
        .padding(.leading, 10)
        .padding(.trailing, 16)
        .frame(height: 62)
        .background(.ultraThinMaterial.opacity(0.62))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.24), lineWidth: 1)
        )
    }

    private var heroPromptBar: some View {
        Button {
            isInputFocused = true
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.70))

                Text(assistantInputPlaceholder)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.55))
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)

                Spacer(minLength: 8)

                Image(systemName: "arrow.right")
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(.white)
                    .frame(width: 64, height: 64)
                    .background(
                        LinearGradient(
                            colors: [AppColors.cyanGlow, AppColors.softBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
            }
            .padding(.leading, 24)
            .padding(.trailing, 8)
            .frame(height: 82)
            .background(.ultraThinMaterial.opacity(0.74))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.18), lineWidth: 1))
            .shadow(color: AppColors.cyanGlow.opacity(0.18), radius: 24, x: 0, y: 14)
        }
        .buttonStyle(.plain)
    }

    private func aiCapabilityChip(_ icon: String, _ label: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(AppColors.cyanGlow)
            Text(label)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.80))
                .lineLimit(1)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(Color.white.opacity(0.08))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.10), lineWidth: 0.7))
    }

    private var compactAssistantHeader: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppColors.cyanGlow)
                .frame(width: 42, height: 42)
                .background(AppColors.cyanGlow.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.t("ai.title", lang))
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                Text(compactAssistantSubtitle)
                    .font(AppTypography.captionScale)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 8)
        }
        .padding(.top, 4)
    }

    private var officialSourceVisualBlock: some View {
        HStack(alignment: .top, spacing: 12) {
            GlassVisualBadge(size: 52, cornerRadius: 16, accent: AppColors.success) {
                GeneratedCategoryArtwork(symbol: "checkmark.seal.fill", accent: AppColors.success)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(sourceCheckedTitle)
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                Text(sourceCheckedSubtitle)
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(14)
        .background(AppColors.glassSurface.opacity(0.76))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 0.75)
        )
    }

    @ViewBuilder
    private var activeContextCard: some View {
        if let title = viewModel.activeContextTitle, !title.isEmpty {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "scope")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(AppColors.cyanGlow)
                    .frame(width: 42, height: 42)
                    .background(AppColors.cyanGlow.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(activeContextTitle)
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.textTertiary)
                        .textCase(.uppercase)
                    Text(title)
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    if let summary = viewModel.activeContextSummary {
                        Text(summary)
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Spacer(minLength: 4)
            }
            .appGlassCardStyle(padding: 14, cornerRadius: 18, accent: AppColors.cyanGlow)
        }
    }

    private func quickPromptButton(_ prompt: String) -> some View {
        Button {
            isInputFocused = false
            Task { await viewModel.useQuickPrompt(prompt) }
        } label: {
            ZStack(alignment: .bottomLeading) {
                PremiumImageView(
                    asset: promptImageAsset(for: prompt),
                    language: lang,
                    height: 180,
                    aspectRatio: nil,
                    mode: .fill,
                    cornerRadius: 0,
                    overlayStyle: .none,
                    fallbackCategory: .ai,
                    accessibilityLabel: promptTopicTitle(for: prompt),
                    targetPixelWidth: 760
                )
                .accessibilityHidden(true)

            LinearGradient(
                colors: [
                    Color.black.opacity(0.05),
                    AppColors.navyDeep.opacity(0.24),
                    AppColors.navyDeep.opacity(0.65)
                ],
                startPoint: .top,
                endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 10) {
                    if VisualAssetHelper.exists(promptLandmark(for: prompt)) {
                        Image(systemName: promptIcon(for: prompt))
                            .font(.system(size: 24, weight: .black))
                            .foregroundStyle(.white)
                            .frame(width: 54, height: 54)
                            .background(promptAccent(for: prompt).opacity(0.52))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.20), lineWidth: 1))
                    } else {
                        Spacer(minLength: 32)
                    }

                    Spacer(minLength: 18)

                    Text(promptTopicTitle(for: prompt))
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    Text(promptTopicSubtitle(for: prompt))
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.72))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
            }
            .frame(height: 180)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.16), lineWidth: 1)
            )
            .shadow(color: promptAccent(for: prompt).opacity(0.16), radius: 18, x: 0, y: 12)
        }
        .buttonStyle(NLTileButtonStyle())
    }

    private func promptImageAsset(for prompt: String) -> AppImageAsset? {
        let localAssetName = promptLandmark(for: prompt)
        guard VisualAssetHelper.exists(localAssetName) else { return nil }

        return AppImageAsset(
            id: "assistant-prompt-\(localAssetName)",
            url: nil,
            localAssetName: localAssetName,
            title: promptTopicTitle(for: prompt),
            sourceName: "YouNew",
            sourceURL: nil,
            license: nil,
            attribution: nil,
            width: nil,
            height: nil,
            aspectRatio: 1.2,
            type: .cardThumbnail,
            verified: true
        )
    }

    private var assistantActionPanel: some View {
        let externalTools = ExternalAssistantTool.all
        let externalToolGroups = ExternalAssistantToolGroup.allCases

        return VStack(alignment: .leading, spacing: 12) {
            Text(assistantToolsTitle)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)

            if !viewModel.suggestedActions.isEmpty {
                VStack(alignment: .leading, spacing: 7) {
                    Text(suggestedActionsTitle)
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.textTertiary)
                        .textCase(.uppercase)

                    ForEach(viewModel.suggestedActions.prefix(3), id: \.self) { action in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(AppColors.success)
                                .padding(.top, 2)
                            Text(action)
                                .font(AppTypography.footnote)
                                .foregroundStyle(AppColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(12)
                .background(AppColors.success.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }

            LazyVGrid(columns: assistantToolColumns, spacing: 10) {
                if isToolVisible(.officialSources) {
                    NavigationLink(value: AppDestination.officialSources) {
                        assistantToolCard(
                            icon: "checkmark.shield.fill",
                            title: toolOfficialTitle,
                            subtitle: toolOfficialSubtitle,
                            color: AppColors.success
                        )
                    }
                    .buttonStyle(NLTileButtonStyle())
                }

                if isToolVisible(.searchList) {
                    NavigationLink(value: AppDestination.searchList) {
                        assistantToolCard(
                            icon: "magnifyingglass",
                            title: toolSearchTitle,
                            subtitle: toolSearchSubtitle,
                            color: AppColors.softBlue
                        )
                    }
                    .buttonStyle(NLTileButtonStyle())
                }

                if isToolVisible(.mapHub) {
                    if let mapToolDestination {
                        NavigationLink(value: mapToolDestination) {
                            assistantToolCard(
                                icon: "map.fill",
                                title: toolMapTitle,
                                subtitle: toolMapSubtitle,
                                color: AppColors.routeLine
                            )
                        }
                        .buttonStyle(NLTileButtonStyle())
                    } else {
                        Button {
                            onOpenMap()
                        } label: {
                            assistantToolCard(
                                icon: "map.fill",
                                title: toolMapTitle,
                                subtitle: toolMapSubtitle,
                                color: AppColors.routeLine
                            )
                        }
                        .buttonStyle(NLTileButtonStyle())
                    }
                }

                if isToolVisible(.knm) {
                    NavigationLink(value: AppDestination.knm) {
                        assistantToolCard(
                            icon: "graduationcap.fill",
                            title: "KNM",
                            subtitle: toolKNMSubtitle,
                            color: AppColors.dutchOrange
                        )
                    }
                    .buttonStyle(NLTileButtonStyle())
                }

                if isToolVisible(.dutchA1A2) {
                    NavigationLink(value: AppDestination.dutchA1A2) {
                        assistantToolCard(
                            icon: "text.book.closed.fill",
                            title: toolDutchTitle,
                            subtitle: toolDutchSubtitle,
                            color: AppColors.violet
                        )
                    }
                    .buttonStyle(NLTileButtonStyle())
                }

                if isToolVisible(.firstSteps) {
                    NavigationLink(value: AppDestination.firstSteps) {
                        assistantToolCard(
                            icon: "checklist",
                            title: toolFirstStepsTitle,
                            subtitle: toolFirstStepsSubtitle,
                            color: AppColors.cyanGlow
                        )
                    }
                    .buttonStyle(NLTileButtonStyle())
                }
            }

            assistantExternalToolAuditAnchor(tools: externalTools, groups: externalToolGroups)
        }
    }

    private var assistantToolColumns: [GridItem] {
        if horizontalSizeClass == .regular {
            return [GridItem(.adaptive(minimum: 240), spacing: 10)]
        }

        return [GridItem(.flexible(minimum: 0), spacing: 10)]
    }

    private func isToolVisible(_ destination: AppDestination) -> Bool {
        RelatedContentEngine.isVisible(destination, for: appState.selectedUserStatus?.personaTag)
    }

    private func assistantToolCard(icon: String, title: String, subtitle: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 23, weight: .black))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, color.opacity(0.90)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 48, height: 48)
                .background(color.opacity(0.24))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(subtitle)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .layoutPriority(1)

            Spacer(minLength: 6)

            Image(systemName: "chevron.right")
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(Color.white.opacity(0.68))
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 82, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    Color.white.opacity(0.095),
                    color.opacity(0.10),
                    AppColors.cardElevated.opacity(0.58)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.13), lineWidth: 0.9)
        )
        .shadow(color: color.opacity(0.10), radius: 16, x: 0, y: 8)
    }

    private func assistantExternalToolAuditAnchor(
        tools: [ExternalAssistantTool],
        groups: [ExternalAssistantToolGroup]
    ) -> some View {
        EmptyView()
            .accessibilityIdentifier("assistant.externalTools.\(groups.count).\(tools.count)")
    }

    private func applyPendingOrDefaultContext() {
        if let context = appState.pendingAIContext {
            viewModel.updateContext(context)
            if let prompt = appState.pendingAIPrompt,
               viewModel.input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                viewModel.input = PersonaContentPolicy.sanitizedPendingAIPrompt(prompt, context: context)
            }
            appState.pendingAIContext = nil
            appState.pendingAIPrompt = nil
        } else {
            viewModel.updateContext(from: appState, language: lang)
        }
    }

    @ViewBuilder
    private func messageBubble(_ text: String, isAssistant: Bool) -> some View {
        if isAssistant {
            Text(text)
                .font(AppTypography.bodyScale)
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(Color.white.opacity(0.070))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 0.7)
                )
                .frame(maxWidth: 620, alignment: .leading)
        } else {
            Text(text)
                .font(AppTypography.bodyScale)
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(AppColors.accent.opacity(0.92))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .frame(maxWidth: 560, alignment: .trailing)
        }
    }

    private func assistantSections(from text: String) -> [AssistantAnswerSection] {
        let cleanedParagraphs = text
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { line in
                line
                    .replacingOccurrences(of: #"^\s*[-•]\s*"#, with: "", options: .regularExpression)
                    .replacingOccurrences(of: #"^\s*\d+[\.)]\s*"#, with: "", options: .regularExpression)
            }

        let official = cleanedParagraphs.last { isOfficialSourceLine($0) }
        let content = cleanedParagraphs
            .filter { !isOfficialSourceLine($0) }
            .map(strippingAssistantSectionPrefix)
            .filter { !$0.isEmpty }
        let answer = content.first ?? strippingAssistantSectionPrefix(text.trimmingCharacters(in: .whitespacesAndNewlines))

        var sections = [
            AssistantAnswerSection(title: assistantAnswerTitle, body: answer, symbol: "checkmark.circle.fill", sourceURL: nil, lastChecked: nil)
        ]

        if let why = content.dropFirst().first {
            sections.append(AssistantAnswerSection(title: assistantWhyTitle, body: why, symbol: "exclamationmark.circle.fill", sourceURL: nil, lastChecked: nil))
        }

        if let next = content.dropFirst(2).first {
            sections.append(AssistantAnswerSection(title: assistantNextStepTitle, body: next, symbol: "arrow.right.circle.fill", sourceURL: nil, lastChecked: nil))
        }

        if let official {
            sections.append(
                AssistantAnswerSection(
                    title: assistantOfficialSourceTitle,
                    body: cleanedVisibleSourceText(strippingAssistantSectionPrefix(official)),
                    symbol: "building.columns.fill",
                    sourceURL: extractURL(from: official),
                    lastChecked: nil
                )
            )
        }

        return sections
    }

    private func cleanedVisibleSourceText(_ text: String) -> String {
        let cleaned = text
            .replacingOccurrences(of: #"https?://\S+"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"www\.\S+"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"[\s—-]+$"#, with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.isEmpty ? noSourceVerificationText : cleaned
    }

    private func strippingAssistantSectionPrefix(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let prefixes: [String] = [
            "Simple answer:",
            "Answer:",
            "Why it matters:",
            "What to check:",
            "Safe next step:",
            "Next step:",
            "Official source:",
            "Eenvoudig antwoord:",
            "Antwoord:",
            "Waarom dit belangrijk is:",
            "Wat te controleren:",
            "Veilige volgende stap:",
            "Volgende stap:",
            "Officiële bron:",
            "Officiële bron:",
            "Простой ответ:",
            "Ответ:",
            "Почему это важно:",
            "Что проверить:",
            "Безопасный следующий шаг:",
            "Следующий шаг:",
            "Официальный источник:"
        ]

        let lower = trimmed.lowercased()
        for prefix in prefixes {
            let lowerPrefix = prefix.lowercased()
            if lower.hasPrefix(lowerPrefix) {
                return String(trimmed.dropFirst(prefix.count)).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return trimmed
    }

    private func isOfficialSourceLine(_ line: String) -> Bool {
        let lower = line.lowercased()
        return lower.contains("official")
            || lower.contains("government.nl")
            || lower.contains("source")
            || lower.contains("offici")
            || lower.contains("официаль")
            || lower.contains("источник")
    }

    private func clippedSectionText(_ text: String, maxCharacters: Int) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count > maxCharacters else { return trimmed }
        let index = trimmed.index(trimmed.startIndex, offsetBy: maxCharacters)
        return String(trimmed[..<index]).trimmingCharacters(in: .whitespacesAndNewlines) + "..."
    }

    private func extractURL(from text: String) -> URL? {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return nil
        }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return detector.firstMatch(in: text, options: [], range: range)?.url
    }

    private func promptIcon(for prompt: String) -> String {
        let lowercased = prompt.lowercased()
        if lowercased.contains("bsn") || lowercased.contains("gemeente") || lowercased.contains("зарегистр") {
            return "building.columns.fill"
        }
        if lowercased.contains("штраф") || lowercased.contains("fine") || lowercased.contains("boete") {
            return "exclamationmark.triangle.fill"
        }
        if lowercased.contains("huisarts") || lowercased.contains("doctor") || lowercased.contains("врач") {
            return "cross.case.fill"
        }
        if lowercased.contains("работ") || lowercased.contains("employer") || lowercased.contains("werk") {
            return "briefcase.fill"
        }
        return "questionmark.bubble.fill"
    }

    private func promptLandmark(for prompt: String) -> String {
        let lowercased = prompt.lowercased()
        if lowercased.contains("duo") || lowercased.contains("student") || lowercased.contains("stud") || lowercased.contains("onderwijs") || lowercased.contains("transport") || lowercased.contains("vervoer") {
            return "home_language_classroom"
        }
        if lowercased.contains("housing") || lowercased.contains("huisvest") || lowercased.contains("wonen") || lowercased.contains("жиль") {
            return "premium_home_housing"
        }
        if lowercased.contains("short stay") || lowercased.contains("kort verblijf") || lowercased.contains("корот") || lowercased.contains("tourist") || lowercased.contains("toerist") || lowercased.contains("турист") {
            return "netherlands_map_base"
        }
        if lowercased.contains("bsn") || lowercased.contains("gemeente") || lowercased.contains("tax") || lowercased.contains("belasting") || lowercased.contains("30%-regeling") {
            return "home_documents_city_hall"
        }
        if lowercased.contains("штраф") || lowercased.contains("fine") || lowercased.contains("boete") || lowercased.contains("letters") || lowercased.contains("brieven") {
            return "premium_home_documents"
        }
        if lowercased.contains("huisarts") || lowercased.contains("doctor") || lowercased.contains("врач") {
            return "premium_home_healthcare"
        }
        if lowercased.contains("работ") || lowercased.contains("employer") || lowercased.contains("werk") || lowercased.contains("contract") || lowercased.contains("loonstrook") || lowercased.contains("payslip") {
            return "premium_home_work"
        }
        return "premium_home_documents"
    }

    private func promptAccent(for prompt: String) -> Color {
        let lowercased = prompt.lowercased()
        if lowercased.contains("huisarts") || lowercased.contains("doctor") || lowercased.contains("врач") {
            return AppColors.success
        }
        if lowercased.contains("tram") || lowercased.contains("train") || lowercased.contains("ov") || lowercased.contains("transport") {
            return AppColors.routeLine
        }
        if lowercased.contains("работ") || lowercased.contains("employer") || lowercased.contains("werk") {
            return AppColors.dutchOrange
        }
        if lowercased.contains("bsn") || lowercased.contains("gemeente") || lowercased.contains("tax") || lowercased.contains("belasting") {
            return AppColors.softBlue
        }
        return AppColors.violet
    }

    private func promptTopicTitle(for prompt: String) -> String {
        let lowercased = prompt.lowercased()
        if lowercased.contains("huisarts") || lowercased.contains("doctor") || lowercased.contains("врач") {
            switch lang {
            case .russian: return "Медицина"
            case .dutch: return "Zorg"
            case .english: return "Healthcare"
            }
        }
        if lowercased.contains("работ") || lowercased.contains("employer") || lowercased.contains("werk") {
            switch lang {
            case .russian: return "Работа"
            case .dutch: return "Werk"
            case .english: return "Work"
            }
        }
        if lowercased.contains("fine") || lowercased.contains("boete") || lowercased.contains("штраф") {
            switch lang {
            case .russian: return "Правила"
            case .dutch: return "Regels"
            case .english: return "Rules"
            }
        }
        if lowercased.contains("bsn") || lowercased.contains("gemeente") || lowercased.contains("tax") || lowercased.contains("belasting") {
            switch lang {
            case .russian: return "Госуслуги"
            case .dutch: return "Gemeente"
            case .english: return "Government"
            }
        }
        switch lang {
        case .russian: return "Помощь"
        case .dutch: return "Hulp"
        case .english: return "Guidance"
        }
    }

    private func promptTopicSubtitle(for prompt: String) -> String {
        let clipped = clippedSectionText(prompt, maxCharacters: 44)
        return clipped
    }

    private var assistantBadgeText: String {
        switch lang {
        case .russian: return "Источники, где доступны"
        case .dutch: return "Bronnen waar beschikbaar"
        case .english: return "Sources where available"
        }
    }

    private var compactAssistantSubtitle: String {
        switch lang {
        case .russian: return "База приложения и официальные источники."
        case .dutch: return "Appkennis en officiële bronnen."
        case .english: return "App knowledge and official sources."
        }
    }

    private var assistantAnswerTitle: String {
        switch lang {
        case .russian: return "Ответ"
        case .dutch: return "Antwoord"
        case .english: return "Answer"
        }
    }

    private var assistantWhyTitle: String {
        switch lang {
        case .russian: return "Почему важно"
        case .dutch: return "Waarom dit belangrijk is"
        case .english: return "Why it matters"
        }
    }

    private var assistantNextStepTitle: String {
        switch lang {
        case .russian: return "Следующий шаг"
        case .dutch: return "Volgende stap"
        case .english: return "Next step"
        }
    }

    private var assistantOfficialSourceTitle: String {
        switch lang {
        case .russian: return "Официальный источник"
        case .dutch: return "Officiële bron"
        case .english: return "Official source"
        }
    }

    private var sourceFallbackText: String {
        switch lang {
        case .russian: return "AI помогает объяснять информацию по базе приложения и источникам, где доступны. Он не заменяет юриста, врача или финансового специалиста."
        case .dutch: return "AI helpt informatie uit de app en beschikbare bronnen uit te leggen. Het vervangt geen jurist, arts of financieel adviseur."
        case .english: return "The AI assistant provides guidance based on the app's knowledge base and official sources where available. It does not replace legal, medical or financial professionals."
        }
    }

    private var noSourceVerificationText: String {
        switch lang {
        case .russian: return "Нет подтверждённого источника в ответе: проверьте информацию в официальной организации."
        case .dutch: return "Geen bevestigde bron in dit antwoord: verifieer bij de officiële organisatie."
        case .english: return "No confirmed source in this answer: verify with the official organization."
        }
    }

    private var aiLastCheckedText: String {
        switch lang {
        case .russian: return "Проверено: \(localizedToday(localeIdentifier: "ru_RU", dateFormat: "d MMM yyyy"))"
        case .dutch: return "Laatst gecontroleerd: \(localizedToday(localeIdentifier: "nl_NL", dateFormat: "d MMM yyyy"))"
        case .english: return "Last checked: \(localizedToday(localeIdentifier: "en_US_POSIX", dateFormat: "MMM d, yyyy"))"
        }
    }

    private func localizedToday(localeIdentifier: String, dateFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: localeIdentifier)
        formatter.dateFormat = dateFormat
        return formatter.string(from: Date.now)
    }

    private var sourceCheckedTitle: String {
        switch lang {
        case .russian: return "Проверяйте по официальным источникам"
        case .dutch: return "Controleer met officiële bronnen"
        case .english: return "Check against official sources"
        }
    }

    private var activeContextTitle: String {
        switch lang {
        case .russian: return "Контекст помощи"
        case .dutch: return "Hulpcontext"
        case .english: return "Help context"
        }
    }

    private var assistantToolsTitle: String {
        switch lang {
        case .russian: return "Инструменты ассистента"
        case .dutch: return "Assistent-tools"
        case .english: return "Assistant tools"
        }
    }

    private var assistantToolsSubtitle: String {
        switch lang {
        case .russian: return "Быстро перейти к нужному разделу после ответа."
        case .dutch: return "Ga na het antwoord snel naar het juiste onderdeel."
        case .english: return "Jump to the right app section after an answer."
        }
    }

    private var suggestedActionsTitle: String {
        switch lang {
        case .russian: return "Предложенные действия"
        case .dutch: return "Voorgestelde acties"
        case .english: return "Suggested actions"
        }
    }

    private var toolOfficialTitle: String {
        switch lang {
        case .russian: return "Источники"
        case .dutch: return "Bronnen"
        case .english: return "Sources"
        }
    }

    private var toolOfficialSubtitle: String {
        switch lang {
        case .russian: return "проверить официально"
        case .dutch: return "officieel controleren"
        case .english: return "verify officially"
        }
    }

    private var toolSearchTitle: String {
        switch lang {
        case .russian: return "Поиск"
        case .dutch: return "Zoeken"
        case .english: return "Search"
        }
    }

    private var toolSearchSubtitle: String {
        switch lang {
        case .russian: return "найти гайд или ответ"
        case .dutch: return "gids of antwoord vinden"
        case .english: return "find a guide or answer"
        }
    }

    private var toolMapTitle: String {
        switch lang {
        case .russian: return "Карта"
        case .dutch: return "Kaart"
        case .english: return "Map"
        }
    }

    private var toolMapSubtitle: String {
        switch lang {
        case .russian: return "помощь рядом"
        case .dutch: return "hulp dichtbij"
        case .english: return "nearby help"
        }
    }

    private var toolKNMSubtitle: String {
        switch lang {
        case .russian: return "общество и быт"
        case .dutch: return "samenleving en leven"
        case .english: return "society and daily life"
        }
    }

    private var toolDutchTitle: String {
        switch lang {
        case .russian: return "Язык"
        case .dutch: return "Taal"
        case .english: return "Dutch"
        }
    }

    private var toolDutchSubtitle: String {
        switch lang {
        case .russian: return "слова A1-A2"
        case .dutch: return "A1-A2 woorden"
        case .english: return "A1-A2 words"
        }
    }

    private var toolFirstStepsTitle: String {
        switch lang {
        case .russian: return "Первые шаги"
        case .dutch: return "Eerste stappen"
        case .english: return "First steps"
        }
    }

    private var toolFirstStepsSubtitle: String {
        switch lang {
        case .russian: return "чеклист новичка"
        case .dutch: return "checklist nieuwkomer"
        case .english: return "newcomer checklist"
        }
    }

    private var sourceCheckedSubtitle: String {
        switch lang {
        case .russian: return "Ответы информационные и помогают понять следующий шаг, но не заменяют государственную службу, юриста, врача или налогового консультанта."
        case .dutch: return "Antwoorden zijn informatief en helpen je volgende stap begrijpen, maar vervangen geen overheidsdienst, jurist, arts of belastingadviseur."
        case .english: return "Answers are informational and help explain the next step, but do not replace a government service, lawyer, doctor, or tax adviser."
        }
    }

    private var suggestionsTitle: String {
        switch lang {
        case .russian: return "Популярные вопросы"
        case .dutch: return "Veelgestelde vragen"
        case .english: return "Popular questions"
        }
    }

    private var viewAllTitle: String {
        switch lang {
        case .russian: return "Все"
        case .dutch: return "Alles"
        case .english: return "View all"
        }
    }

    private var retryLabel: String {
        switch lang {
        case .russian: return "Попробовать ещё раз"
        case .dutch: return "Opnieuw proberen"
        case .english: return "Try again"
        }
    }

    private var clearConversationLabel: String {
        switch lang {
        case .russian: return "Очистить чат"
        case .dutch: return "Chat wissen"
        case .english: return "Clear chat"
        }
    }

    private var officialSearchSubtitle: String {
        switch lang {
        case .russian: return "Проверяйте важные темы по официальным источникам"
        case .dutch: return "Controleer belangrijke onderwerpen via officiële bronnen"
        case .english: return "Check important topics with official sources"
        }
    }

    private var sourcesTitle: String {
        switch lang {
        case .russian: return "Официальные источники"
        case .dutch: return "Officiële bronnen"
        case .english: return "Official sources"
        }
    }

    private var assistantInputPlaceholder: String {
        let isTourist = appState.selectedUserStatus?.personaTag == .tourist
        switch (isTourist, lang) {
        case (true, .russian): return "Спросите про транспорт, правила, emergency или места"
        case (true, .dutch): return "Vraag over vervoer, regels, noodhulp of plekken"
        case (true, .english): return "Ask about transport, rules, emergencies, or places"
        case (false, .russian): return "Спросите про городские сервисы, правила или помощь"
        case (false, .dutch): return "Vraag over stadsdiensten, regels of hulp"
        case (false, .english): return "Ask about city services, rules, or help"
        }
    }

    private var privacyInputHint: String {
        switch lang {
        case .russian: return "Не отправляйте BSN, номера паспорта или медицинские данные."
        case .dutch: return "Deel geen BSN, paspoortnummers of medische gegevens."
        case .english: return "Don’t share BSN, passport numbers, or medical details."
        }
    }

    private var voiceStartLabel: String {
        switch lang { case .russian: "Начать голосовой ввод"; case .dutch: "Spraakinvoer starten"; case .english: "Start voice input" }
    }

    private var voiceStopLabel: String {
        switch lang { case .russian: "Остановить голосовой ввод"; case .dutch: "Spraakinvoer stoppen"; case .english: "Stop voice input" }
    }

    private var emptyInputHintTitle: String {
        switch lang {
        case .russian: return "Или начните со своего вопроса"
        case .dutch: return "Of begin met uw eigen vraag"
        case .english: return "Or start with your own question"
        }
    }

    private var offlineModeText: String {
        switch lang {
        case .russian: return "Нет сети. Explain Mode использует локальные справочные ответы и официальные источники для проверки."
        case .dutch: return "Geen netwerk. Explain Mode gebruikt lokale algemene antwoorden en officiële bronnen voor controle."
        case .english: return "No network. Explain Mode is using local general guidance and official sources for verification."
        }
    }

    private var heroCaption: String {
        switch lang {
        case .russian: return "AI · Ассистент"
        case .dutch: return "AI · Assistent"
        case .english: return "AI · Assistant"
        }
    }

    private var heroTitle: String {
        switch lang {
        case .russian: return "Ваш гид по Нидерландам"
        case .dutch: return "Uw gids voor Nederland"
        case .english: return "Your Netherlands Guide"
        }
    }

    private var heroSubtitle: String {
        switch lang {
        case .russian: return "Объясняет темы из приложения простым языком и подсказывает, где проверить источник"
        case .dutch: return "Legt app-onderwerpen eenvoudig uit en wijst naar bronnen om te controleren"
        case .english: return "Explains app topics in plain language and points to sources to verify"
        }
    }

    private var heroSubtitleShort: String {
        switch lang {
        case .russian: return "Информационная помощь. Источники, где доступны."
        case .dutch: return "Informatieve hulp. Bronnen waar beschikbaar."
        case .english: return "Informational guidance. Sources where available."
        }
    }

    private var heroTrustLine: String {
        switch lang {
        case .russian: return "Ответы могут включать ссылки на источники"
        case .dutch: return "Antwoorden kunnen bronverwijzingen bevatten"
        case .english: return "Answers may include source references"
        }
    }

    private var heroCap1: String {
        switch lang {
        case .russian: return "Документы"
        case .dutch: return "Documenten"
        case .english: return "Documents"
        }
    }

    private var heroCap2: String {
        switch lang {
        case .russian: return "Жильё"
        case .dutch: return "Wonen"
        case .english: return "Housing"
        }
    }

    private var heroCap3: String {
        switch lang {
        case .russian: return "Медицина"
        case .dutch: return "Zorg"
        case .english: return "Healthcare"
        }
    }
}

private struct AssistantComposerHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 86

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private struct AssistantAnswerSection: Identifiable {
    let id = UUID()
    let title: String
    let body: String
    let symbol: String
    let sourceURL: URL?
    let lastChecked: String?
}

private struct AssistantStructuredResponseCard: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var appState: AppStateViewModel
    @Environment(\.openURL) private var openURL
    @ObservedObject private var savedItemsStore = SavedItemsStore.shared
    let response: AIResponse
    let accent: Color
    let destination: AppDestination?
    let onDestinationAction: (AppDestination) -> Void
    let onQueryAction: (String) -> Void

    private var lang: AppLanguage { languageManager.appLanguage }

    private var verifiedSourcesLabel: String {
        L10n.t("common.verified_source", lang)
    }

    private var openRelatedSectionLabel: String {
        switch languageManager.appLanguage {
        case .russian: return "Открыть связанный раздел"
        case .dutch: return "Verwante sectie openen"
        case .english: return "Open related section"
        }
    }

    private var appDestination: AppDestination? {
        AppNavigationResolver.destination(for: response.appDestinationID, visibleFor: appState.selectedUserStatus?.personaTag)
    }

    private var fallbackAnswerTitle: String {
        switch languageManager.appLanguage {
        case .russian: return "Ответ"
        case .dutch: return "Antwoord"
        case .english: return "Answer"
        }
    }

    private var openSectionLabel: String {
        switch languageManager.appLanguage {
        case .russian: return "Открыть раздел"
        case .dutch: return "Sectie openen"
        case .english: return "Open section"
        }
    }

    private var displaySections: [AIResponseSection] {
        response.sections.isEmpty
            ? [AIResponseSection(title: fallbackAnswerTitle, body: response.answer, symbol: "checkmark.circle.fill")]
            : response.sections
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(displaySections.prefix(4).enumerated()), id: \.offset) { index, section in
                HStack(alignment: .top, spacing: 11) {
                    Image(systemName: section.symbol ?? defaultSymbol(for: index))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(index == 0 ? accent : Color.white.opacity(0.62))
                        .frame(width: 22, height: 22)
                        .padding(.top, 1)

                    VStack(alignment: .leading, spacing: 5) {
                        Text(section.title)
                            .font(.system(size: 11, weight: .semibold, design: .default))
                            .foregroundStyle(Color.white.opacity(0.60))
                            .textCase(.uppercase)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(section.body)
                            .font(.system(size: 15, weight: .regular, design: .default))
                            .foregroundStyle(AppColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 10)

                if index < min(displaySections.count, 4) - 1 {
                    Divider()
                        .overlay(Color.white.opacity(0.08))
                }
            }

            if let nextStep = response.nextStep,
               !nextStep.detail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Divider()
                    .overlay(Color.white.opacity(0.08))

                VStack(alignment: .leading, spacing: 9) {
                    HStack(alignment: .top, spacing: 11) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(accent)
                            .frame(width: 22, height: 22)
                            .padding(.top, 1)

                        VStack(alignment: .leading, spacing: 5) {
                            Text(nextStep.title)
                                .font(.system(size: 11, weight: .semibold, design: .default))
                                .foregroundStyle(Color.white.opacity(0.60))
                                .textCase(.uppercase)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)

                            Text(nextStep.detail)
                                .font(.system(size: 15, weight: .regular, design: .default))
                                .foregroundStyle(AppColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    if let destination {
                        NavigationLink(value: destination) {
                            Label(nextStep.destinationTitle ?? openSectionLabel, systemImage: "arrow.up.right.circle.fill")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(accent)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(accent.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 10)
            }

            if !response.quickActions.isEmpty {
                Divider()
                    .overlay(Color.white.opacity(0.08))

                VStack(alignment: .leading, spacing: 8) {
                    Text(quickActionsLabel)
                        .font(.system(size: 11, weight: .semibold, design: .default))
                        .foregroundStyle(Color.white.opacity(0.60))
                        .textCase(.uppercase)
                        .padding(.top, 10)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 138), spacing: 8)], alignment: .leading, spacing: 8) {
                        ForEach(response.quickActions.prefix(8)) { action in
                            quickActionView(action)
                        }
                    }
                }
                .padding(.bottom, 10)
            }

            let displaySources = response.sources.filter { source in
                !source.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && source.url != nil
            }
            if !displaySources.isEmpty {
                Divider()
                    .overlay(Color.white.opacity(0.08))

                VStack(alignment: .leading, spacing: 8) {
                    Text(verifiedSourcesLabel)
                        .font(.system(size: 11, weight: .semibold, design: .default))
                        .foregroundStyle(Color.white.opacity(0.60))
                        .textCase(.uppercase)
                        .padding(.top, 10)

                    ForEach(displaySources.prefix(3)) { source in
                        if let url = source.url {
                            Link(destination: AppURL.safeWebURL(url)) {
                                ProductListItem(
                                    title: source.title,
                                    subtitle: "\(L10n.t("common.source", lang)): \(source.institution ?? source.title)",
                                    symbol: "checkmark.seal.fill",
                                    accent: AppColors.success,
                                    metadata: sourceMetadata(for: source)
                                )
                            }
                            .accessibilityHint(url.host() ?? source.title)
                            .accessibilityIdentifier("assistant.source.verified")
                        }
                    }
                }
                .padding(.bottom, 10)
            }

            Divider()
                .overlay(Color.white.opacity(0.08))

            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppColors.success)
                    .frame(width: 20, height: 20)
                    .padding(.top, 1)

                Text(AISafetyRules.mandatoryDisclaimer(for: languageManager.appLanguage))
                    .font(.system(size: 12, weight: .medium, design: .default))
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 10)

            if let appDestination,
               appDestination != destination {
                Divider()
                    .overlay(Color.white.opacity(0.08))

                NavigationLink(value: appDestination) {
                    Label(openRelatedSectionLabel, systemImage: "rectangle.on.rectangle.badge.arrow.down")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(accent)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(accent.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cardElevated.opacity(0.84))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [accent.opacity(0.32), Color.white.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.8
                )
        )
        .accessibilityIdentifier("assistant.response.structured")
    }

    private var quickActionsLabel: String {
        switch languageManager.appLanguage {
        case .russian: return "Быстрые действия"
        case .dutch: return "Snelle acties"
        case .english: return "Quick actions"
        }
    }

    @ViewBuilder
    private func quickActionView(_ action: AIResponseAction) -> some View {
        if let destination = AppNavigationResolver.destination(for: action.destinationID, visibleFor: appState.selectedUserStatus?.personaTag) {
            Button {
                onDestinationAction(destination)
            } label: {
                actionLabel(action)
            }
                .buttonStyle(.plain)
                .simultaneousGesture(
                    TapGesture().onEnded {
                        onDestinationAction(destination)
                    }
                )
                .accessibilityElement(children: .combine)
                .accessibilityLabel(action.title)
                .accessibilityIdentifier(actionIdentifier(action))
        } else if let url = AppURL.validatedWebURL(action.url) {
            Button {
                openURL(url)
            } label: {
                actionLabel(action)
            }
                .buttonStyle(.plain)
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier(actionIdentifier(action))
        } else {
            switch action.kind {
            case .save:
                Button {
                    if let itemID = action.itemID {
                        savedItemsStore.toggle(item: SavedItemsStore.SavedItem(
                            id: itemID,
                            kind: .other,
                            title: action.title,
                            subtitle: nil,
                            destination: nil,
                            savedAt: Date()
                        ))
                    }
                } label: {
                    actionLabel(action)
                }
                .buttonStyle(.plain)
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier(actionIdentifier(action))
            case .share:
                ShareLink(item: action.itemID ?? action.title) {
                    actionLabel(action)
                }
                .accessibilityIdentifier(actionIdentifier(action))
            case .relatedTopic, .askFollowUp:
                Button {
                    if let query = action.query {
                        onQueryAction(query)
                    }
                } label: {
                    actionLabel(action)
                }
                    .buttonStyle(.plain)
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier(actionIdentifier(action))
            default:
                actionLabel(action)
                    .accessibilityIdentifier(actionIdentifier(action))
            }
        }
    }

    private func actionIdentifier(_ action: AIResponseAction) -> String {
        let rawTarget = action.destinationID
            ?? action.url?.host()
            ?? action.itemID
            ?? action.query
            ?? action.title
        return "assistant.quickAction.\(action.kind.rawValue).\(identifierSegment(rawTarget))"
    }

    private func identifierSegment(_ raw: String?) -> String {
        let allowed = CharacterSet.alphanumerics
        let normalized = (raw ?? "action")
            .lowercased()
            .unicodeScalars
            .map { allowed.contains($0) ? Character($0) : "." }
        let collapsed = String(normalized)
            .split(separator: ".")
            .joined(separator: ".")
        return collapsed.isEmpty ? "action" : collapsed
    }

    private func actionLabel(_ action: AIResponseAction) -> some View {
        HStack(spacing: 7) {
            Image(systemName: symbol(for: action.kind))
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .accessibilityHidden(true)
            Text(action.title)
                .lineLimit(2)
                .minimumScaleFactor(0.78)
            Spacer(minLength: 0)
        }
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundStyle(accent)
            .frame(maxWidth: .infinity, minHeight: 34, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(accent.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func symbol(for kind: AIResponseAction.Kind) -> String {
        switch kind {
        case .openGuide: return "book.pages.fill"
        case .openScreen: return "arrow.up.right.circle.fill"
        case .openCity: return "building.2.fill"
        case .openProvince: return "map.fill"
        case .openSource: return "checkmark.seal.fill"
        case .save: return "bookmark.fill"
        case .share: return "square.and.arrow.up"
        case .relatedTopic: return "arrow.triangle.branch"
        case .askFollowUp: return "text.bubble.fill"
        }
    }

    private func defaultSymbol(for index: Int) -> String {
        switch index {
        case 0: return "checkmark.circle.fill"
        case 1: return "exclamationmark.circle.fill"
        case 2: return "checklist"
        default: return "info.circle.fill"
        }
    }

    private func sourceMetadata(for source: OfficialSource) -> String {
        guard let lastChecked = source.lastChecked else {
            return L10n.t("common.verified_source", lang)
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d, yyyy"
        return "\(L10n.t("common.verified_source", lang)) · \(L10n.t("common.last_checked", lang)): \(formatter.string(from: lastChecked))"
    }
}

private struct AssistantAnswerSummary: View {
    @EnvironmentObject private var languageManager: LanguageManager

    let sections: [AssistantAnswerSection]
    let accent: Color

    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        let openSourceTitle = L10n.t("resource.open_source", lang)

        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(sections.prefix(4).enumerated()), id: \.element.id) { index, section in
                HStack(alignment: .top, spacing: 11) {
                    Image(systemName: section.symbol)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(index == 0 ? accent : Color.white.opacity(0.58))
                        .frame(width: 22, height: 22)
                        .padding(.top, 1)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(section.title)
                            .font(.system(size: 11, weight: .semibold, design: .default))
                            .foregroundStyle(Color.white.opacity(0.58))
                            .textCase(.uppercase)
                            .lineLimit(1)
                        Text(section.body)
                            .font(.system(size: 15, weight: .regular, design: .default))
                            .foregroundStyle(AppColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        if let lastChecked = section.lastChecked {
                            Text(lastChecked)
                                .font(AppTypography.metadata)
                                .foregroundStyle(Color.white.opacity(0.46))
                                .lineLimit(1)
                        }

                        if let sourceURL = section.sourceURL {
                            Link(destination: AppURL.safeWebURL(sourceURL)) {
                                Label(openSourceTitle, systemImage: "link")
                                    .font(AppTypography.captionStrong)
                                    .foregroundStyle(AppColors.cyanGlow)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.72)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 10)

                if index < min(sections.count, 4) - 1 {
                    Divider()
                        .overlay(Color.white.opacity(0.08))
                }
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cardElevated.opacity(0.84))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [AppColors.dutchOrange.opacity(0.30), Color.white.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.8
                )
        )
    }
}

private struct AIWritingIndicator: View {
    let text: String

    var body: some View {
        HStack(spacing: AppSpacing.small) {
            TimelineView(.periodic(from: .now, by: 0.5)) { context in
                let activeDot = Int(context.date.timeIntervalSinceReferenceDate * 2) % 3

                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(AppColors.accent.opacity(activeDot == index ? 0.95 : 0.35))
                            .frame(width: 6, height: 6)
                            .scaleEffect(activeDot == index ? 1.12 : 1.0)
                            .animation(.easeInOut(duration: 0.25), value: activeDot)
                    }
                }
                .frame(width: 28, height: 18)
            }

            Text(text)
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textSecondary)
        }
        .appCardStyle()
    }
}

private struct AISafetyNotice: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppColors.warning)
                .padding(.top, 2)
            Text(text)
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .appCardStyle()
    }
}

private extension Array where Element == String {
    func uniqued() -> [String] {
        var seen = Set<String>()
        return filter { seen.insert($0).inserted }
    }
}

#if DEBUG && os(iOS)
private struct AIAssistantPreviewContainer: View {
    @StateObject private var appState = AppStateViewModel()
    @StateObject private var languageManager: LanguageManager
    @StateObject private var savedItemsStore = SavedItemsStore()
    @StateObject private var documentStore = DocumentStore()
    @StateObject private var router = TabRouter()

    init(language: AppLanguage) {
        let manager = LanguageManager()
        manager.appLanguage = language
        _languageManager = StateObject(wrappedValue: manager)
    }

    var body: some View {
        NavigationStack {
            AIAssistantView { }
                .navigationDestination(for: AppDestination.self) { destination in
                    AppDestinationView(destination: destination)
                }
        }
        .environmentObject(appState)
        .environmentObject(languageManager)
        .environmentObject(savedItemsStore)
        .environmentObject(documentStore)
        .environmentObject(router)
    }
}

#Preview("Assistant QA - RU iPhone SE", traits: .fixedLayout(width: 375, height: 667)) {
    AIAssistantPreviewContainer(language: .russian)
        .environment(\.dynamicTypeSize, .large)
        .transaction { $0.animation = nil }
}
#endif
