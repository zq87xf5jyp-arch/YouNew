import SwiftUI
import Foundation
#if canImport(UIKit)
import UIKit
#endif

struct AIAssistantView: View {
    @StateObject private var viewModel = AIViewModel()
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var router: TabRouter
    @FocusState private var isInputFocused: Bool
    @State private var measuredComposerHeight: CGFloat = 86
    let mapToolDestination: AppDestination?
    let onOpenMap: () -> Void

    init(mapToolDestination: AppDestination? = nil, onOpenMap: @escaping () -> Void) {
        self.mapToolDestination = mapToolDestination
        self.onOpenMap = onOpenMap
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

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                GlobalBackgroundView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                ScrollViewReader { scrollProxy in
                    ScrollView {
                        Color.clear
                            .frame(height: 0)
                            .id("assistantTop")

                        if !hasConversation {
                            emptyChatState(safeAreaBottom: proxy.safeAreaInsets.bottom)
                                .id("empty")
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(visibleMessages) { message in
                                    chatBubble(message)
                                        .id(message.id)
                                }

                                if viewModel.isLoading {
                                    AIWritingIndicator(text: L10n.t("ai.thinking", lang))
                                        .transition(.opacity.combined(with: .move(edge: .bottom)))
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
                    .onChange(of: viewModel.conversation.messages.count) { _, _ in
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                            scrollProxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                    .onReceive(router.aiScrollTop) { _ in
                        dismissKeyboard()
                        withAnimation(.easeInOut(duration: 0.24)) {
                            scrollProxy.scrollTo("assistantTop", anchor: .top)
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                assistantComposerInset(safeAreaBottom: proxy.safeAreaInsets.bottom)
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
#if os(iOS)
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(L10n.t("common.done", lang)) {
                    dismissKeyboard()
                }
            }
#endif
        }
    }

    private func assistantScrollBottomPadding(safeAreaBottom: CGFloat) -> CGFloat {
#if os(iOS)
        measuredComposerHeight + bottomComposerClearance(safeAreaBottom: safeAreaBottom) + 24
#else
        measuredComposerHeight + safeAreaBottom + 16
#endif
    }

    private func bottomComposerClearance(safeAreaBottom: CGFloat) -> CGFloat {
#if os(iOS)
        assistantComposerDockClearance(safeAreaBottom: safeAreaBottom)
#else
        0
#endif
    }

    private func assistantComposerDockClearance(safeAreaBottom: CGFloat) -> CGFloat {
#if os(iOS)
        let tabBarClearance = FloatingTabBarMetrics.height + FloatingTabBarMetrics.bottomOffset + 8
        return tabBarClearance + safeAreaBottom + 12
#else
        0
#endif
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
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                assistantInputBar
            }
            .padding(.top, 8)
            .padding(.bottom, 6)
            .background {
                GeometryReader { geometry in
                    Color.clear
                        .preference(
                            key: AssistantComposerHeightPreferenceKey.self,
                            value: geometry.size.height
                        )
                }
            }

            Color.clear
                .frame(height: bottomComposerClearance(safeAreaBottom: safeAreaBottom))
                .allowsHitTesting(false)
        }
        .background(alignment: .top) {
            LinearGradient(
                colors: [
                    AppColors.navyDeep,
                    AppColors.navyDeep.opacity(0.94),
                    AppColors.navyDeep
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(Color.white.opacity(0.055))
                    .frame(height: 0.7)
            }
                .allowsHitTesting(false)
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
        case .russian: return "Спросите о жизни в Нидерландах"
        case .dutch: return "Vraag alles over leven in Nederland"
        case .english: return "Ask anything about life in the Netherlands"
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
            HStack(alignment: .bottom, spacing: 10) {
                ZStack(alignment: .leading) {
                    if viewModel.input.isEmpty {
                        Text(privacyPlaceholder)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(Color.white.opacity(0.35))
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                            .padding(.leading, 2)
                            .allowsHitTesting(false)
                    }

                    TextField("", text: $viewModel.input, axis: .vertical)
                        .textFieldStyle(.plain)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(.white)
                        .tint(AppColors.dutchOrange)
                        .accentColor(AppColors.dutchOrange)
                        .lineLimit(1...5)
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
                        .accessibilityLabel(privacyPlaceholder)
                        .accessibilityIdentifier("assistant.input")
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(Color(red: 28 / 255, green: 42 / 255, blue: 62 / 255))
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
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
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background { sendButtonBackground }
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.isLoading && viewModel.input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityLabel(viewModel.isLoading ? cancelResponseLabel : L10n.t("common.send", lang))
                .accessibilityIdentifier(viewModel.isLoading ? "assistant.cancel" : "assistant.send")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(Color.clear)
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
            Color(red: 28 / 255, green: 42 / 255, blue: 62 / 255)
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

    private func emptyChatState(safeAreaBottom: CGFloat) -> some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 12)

            assistantHero
                .padding(.horizontal, 16)
                .frame(maxWidth: 760)

            VStack(alignment: .leading, spacing: 10) {
                NLSectionHeader(title: suggestionsTitle, subtitle: compactAssistantSubtitle)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 9) {
                    ForEach(displayedQuickPrompts, id: \.self) { prompt in
                        quickPromptButton(prompt)
                    }
                }
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: 760)

            VStack(spacing: 12) {
                activeContextCard
                assistantActionPanel
                assistantEmptyInputHint
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: 760)

            Color.clear.frame(height: assistantScrollBottomPadding(safeAreaBottom: safeAreaBottom))
        }
        .frame(maxWidth: .infinity)
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
                    Text(privacyPlaceholder)
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
            if message.role == .user { Spacer(minLength: 44) }

            if message.role == .assistant {
                assistantAvatar
            }

            chatMessageContent(message)
                .frame(
                    maxWidth: .infinity,
                    alignment: message.role == .user ? .trailing : .leading
                )

            if message.role == .assistant { Spacer(minLength: 0) }
        }
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
        if message.role == .assistant,
           let response = viewModel.structuredResponse(for: message.id) {
            AssistantStructuredResponseCard(
                response: response,
                accent: AppColors.dutchOrange,
                destination: destination(for: response),
                onQueryAction: { query in
                    viewModel.input = query
                    Task { await viewModel.sendCurrentMessage() }
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
        VStack(spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                LinearGradient(
                    colors: [
                        Color(red: 14/255, green: 10/255, blue: 44/255),
                        Color(red: 36/255, green: 18/255, blue: 82/255),
                        Color(red: 8/255, green: 22/255, blue: 66/255)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                RadialGradient(
                    colors: [AppColors.violet.opacity(0.50), .clear],
                    center: .topTrailing,
                    startRadius: 0,
                    endRadius: 220
                )

                RadialGradient(
                    colors: [AppColors.cyanGlow.opacity(0.30), .clear],
                    center: .bottomLeading,
                    startRadius: 0,
                    endRadius: 180
                )

                VStack(alignment: .leading, spacing: 14) {
                    Spacer()

                    ZStack {
                        Circle()
                            .fill(AppColors.violet.opacity(0.22))
                            .frame(width: 60, height: 60)
                        Circle()
                            .stroke(AppColors.violet.opacity(0.45), lineWidth: 1)
                            .frame(width: 60, height: 60)
                        Image(systemName: "sparkles")
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppColors.cyanGlow, AppColors.violet],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        Text(heroCaption)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.cyanGlow)
                            .tracking(1.2)

                        Text(heroTitle)
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(2)

                        Text(heroSubtitle)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.70))
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    HStack(spacing: 6) {
                        aiCapabilityChip("doc.text.fill", heroCap1)
                        aiCapabilityChip("house.fill", heroCap2)
                        aiCapabilityChip("cross.case.fill", heroCap3)
                    }

                    Spacer().frame(height: 4)
                }
                .padding(20)
            }
            .frame(height: 300, alignment: .bottomLeading)
            .clipped()

            HStack(spacing: 10) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppColors.success)
                Text(heroTrustLine)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                Spacer()
                Text("government.nl")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.success.opacity(0.80))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.04))
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .accessibilityIdentifier("assistant.hero")
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
            VStack(alignment: .leading, spacing: 8) {
                GlassVisualBadge(size: 40, cornerRadius: 13, accent: AppColors.softBlue) {
                    if VisualAssetHelper.exists(promptLandmark(for: prompt)) {
                        Image(promptLandmark(for: prompt))
                            .resizable()
                            .scaledToFill()
                    } else {
                        GeneratedCategoryArtwork(symbol: promptIcon(for: prompt), accent: AppColors.softBlue)
                    }
                }
                Text(prompt)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .frame(minHeight: 106, alignment: .topLeading)
            .padding(12)
            .premiumNetherlandsCard(cornerRadius: 18, accent: AppColors.softBlue)
        }
        .buttonStyle(NLTileButtonStyle())
    }

    private var assistantActionPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            NLSectionHeader(title: assistantToolsTitle, subtitle: assistantToolsSubtitle)

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

            LazyVGrid(columns: assistantToolColumns, spacing: 9) {
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
        }
    }

    private var assistantToolColumns: [GridItem] {
        [GridItem(.flexible(), spacing: 9), GridItem(.flexible(), spacing: 9)]
    }

    private func isToolVisible(_ destination: AppDestination) -> Bool {
        RelatedContentEngine.isVisible(destination, for: appState.selectedUserStatus?.personaTag)
    }

    private func assistantToolCard(icon: String, title: String, subtitle: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(color)
                .frame(width: 34, height: 34)
                .background(color.opacity(0.13))
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))

            Text(title)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.76)

            Text(subtitle)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.78)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 118, alignment: .topLeading)
        .background(AppColors.cardElevated.opacity(0.58))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(color.opacity(0.18), lineWidth: 0.8)
        )
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
        let sourceURL = official.flatMap(extractURL(from:)) ?? AppURL.make("https://www.government.nl")
        let content = cleanedParagraphs
            .filter { !isOfficialSourceLine($0) }
            .map(strippingAssistantSectionPrefix)
            .filter { !$0.isEmpty }
        let answer = content.first ?? strippingAssistantSectionPrefix(text.trimmingCharacters(in: .whitespacesAndNewlines))
        let why = content.dropFirst().first ?? defaultWhyText
        let next = content.dropFirst(2).first ?? defaultNextStepText

        return [
            AssistantAnswerSection(title: assistantAnswerTitle, body: answer, symbol: "checkmark.circle.fill", sourceURL: nil, lastChecked: nil),
            AssistantAnswerSection(title: assistantWhyTitle, body: why, symbol: "exclamationmark.circle.fill", sourceURL: nil, lastChecked: nil),
            AssistantAnswerSection(title: assistantNextStepTitle, body: next, symbol: "arrow.right.circle.fill", sourceURL: nil, lastChecked: nil),
            AssistantAnswerSection(
                title: assistantOfficialSourceTitle,
                body: official.map { cleanedVisibleSourceText(strippingAssistantSectionPrefix($0)) } ?? noSourceVerificationText,
                symbol: "building.columns.fill",
                sourceURL: sourceURL,
                lastChecked: official == nil ? nil : aiLastCheckedText
            )
        ]
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
            "Officiele bron:",
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

    private var assistantBadgeText: String {
        switch lang {
        case .russian: return "С проверкой источников"
        case .dutch: return "Met broncontrole"
        case .english: return "Source-checked explanations"
        }
    }

    private var compactAssistantSubtitle: String {
        switch lang {
        case .russian: return "Краткий ответ, следующий шаг и официальный источник."
        case .dutch: return "Kort antwoord, volgende stap en officiële bron."
        case .english: return "Short answer, next step, and official source."
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

    private var defaultWhyText: String {
        switch lang {
        case .russian: return "Это может повлиять на сроки, платежи или доступ к услугам."
        case .dutch: return "Dit kan invloed hebben op termijnen, betalingen of toegang tot diensten."
        case .english: return "This can affect deadlines, payments, or access to services."
        }
    }

    private var defaultNextStepText: String {
        switch lang {
        case .russian: return "Проверьте официальный сайт и подготовьте данные перед действием."
        case .dutch: return "Controleer de officiële site en bereid je gegevens voor."
        case .english: return "Check the official site and prepare details before acting."
        }
    }

    private var sourceFallbackText: String {
        switch lang {
        case .russian: return "Этот ассистент предоставляет только информационные рекомендации. Всегда проверяйте важные решения по официальным источникам."
        case .dutch: return "Deze assistent geeft alleen informatieve begeleiding. Controleer belangrijke beslissingen altijd met officiële bronnen."
        case .english: return "This assistant provides informational guidance only. Always verify important decisions with official sources."
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

    private var retryLabel: String {
        switch lang {
        case .russian: return "Попробовать ещё раз"
        case .dutch: return "Opnieuw proberen"
        case .english: return "Try again"
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

    private var privacyPlaceholder: String {
        switch lang {
        case .russian: return "Спросите без BSN и медданных"
        case .dutch: return "Vraag zonder BSN of medische data"
        case .english: return "Ask without BSN or medical data"
        }
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
        case .russian: return "Объясняю документы, визы, жильё и медицину простым языком"
        case .dutch: return "Legt documenten, visa, wonen en zorg uit in begrijpelijke taal"
        case .english: return "Explaining documents, visas, housing and healthcare in plain language"
        }
    }

    private var heroTrustLine: String {
        switch lang {
        case .russian: return "Ответы со ссылками на официальные источники"
        case .dutch: return "Antwoorden met officiële bronvermeldingen"
        case .english: return "Answers with official source references"
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
    let onQueryAction: (String) -> Void

    private var verifiedSourcesLabel: String {
        switch languageManager.appLanguage {
        case .russian: return "Проверенные источники"
        case .dutch: return "Geverifieerde bronnen"
        case .english: return "Verified sources"
        }
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

            if let nextStep = response.nextStep {
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

            if !response.sources.isEmpty {
                Divider()
                    .overlay(Color.white.opacity(0.08))

                VStack(alignment: .leading, spacing: 8) {
                    Text(verifiedSourcesLabel)
                        .font(.system(size: 11, weight: .semibold, design: .default))
                        .foregroundStyle(Color.white.opacity(0.60))
                        .textCase(.uppercase)
                        .padding(.top, 10)

                    ForEach(response.sources.prefix(3)) { source in
                        AISourceCard(source: source)
                    }
                }
                .padding(.bottom, 10)
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
            NavigationLink(value: destination) {
                actionLabel(action)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(actionIdentifier(action))
        } else if let url = AppURL.validatedWebURL(action.url) {
            Button {
                openURL(url)
            } label: {
                actionLabel(action)
            }
            .buttonStyle(.plain)
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
        Label(action.title, systemImage: symbol(for: action.kind))
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundStyle(accent)
            .lineLimit(2)
            .minimumScaleFactor(0.78)
            .frame(maxWidth: .infinity, minHeight: 34, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(accent.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
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
    @State private var activeDot = 0

    var body: some View {
        HStack(spacing: AppSpacing.small) {
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

            Text(text)
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textSecondary)
        }
        .appCardStyle()
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 500_000_000)
                activeDot = (activeDot + 1) % 3
            }
        }
    }
}

private struct AISourceCard: View {
    let source: OfficialSource
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColors.success)
                .frame(width: 38, height: 38)
                .background(AppColors.success.opacity(0.13))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 7) {
                Text(L10n.t("common.verified_source", lang))
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.success)
                    .textCase(.uppercase)
                    .lineLimit(1)

                Text(source.title)
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: 3) {
                    Text("\(L10n.t("common.source", lang)): \(source.institution ?? source.title)")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("\(L10n.t("common.last_checked", lang)): \(lastCheckedText)")
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.textTertiary)
                        .lineLimit(1)
                }

                if let url = source.url {
                    Link(destination: AppURL.safeWebURL(url)) {
                        Label(L10n.t("resource.open_source", lang), systemImage: "arrow.up.right.square")
                            .font(AppTypography.captionStrong)
                            .foregroundStyle(AppColors.cyanGlow)
                            .lineLimit(1)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(AppColors.cyanGlow.opacity(0.10))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .accessibilityHint(url.host() ?? source.title)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 6)
        }
        .appCardStyle()
        .accessibilityIdentifier("assistant.source.verified")
    }

    private var lastCheckedText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: Date.now)
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
