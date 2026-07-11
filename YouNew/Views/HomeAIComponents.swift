import SwiftUI

// MARK: - AI Navigator

struct HomeAINavigatorCard: View {
    let title: String
    let subtitle: String
    let questionExamples: [String]
    let onOpenAssistant: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Button(action: onOpenAssistant) {
            VStack(alignment: .leading, spacing: 12) {
                header
                questionChips
            }
            .homeReadableBand()
            .padding(.vertical, 30)
            .background(
                LinearGradient(
                    colors: [
                        AppSurface.base,
                        AppColors.violet.opacity(0.16),
                        AppSurface.base
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        .buttonStyle(NLTileButtonStyle())
        .cardGlowingTopEdge(color: AppColors.cyanGlow, cornerRadius: 0)
        .accessibilityIdentifier("home.ai.navigator.card")
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 17, weight: .black))
                .foregroundStyle(AppColors.cyanGlow)
                .frame(width: 38, height: 38)
                .background(AppColors.cyanGlow.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 20 : 17, weight: .semibold, design: .default))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(3)
                    .minimumScaleFactor(0.86)
                    .fixedSize(horizontal: false, vertical: true)

                Text(subtitle)
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(3)
                    .minimumScaleFactor(0.88)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppColors.textTertiary)
        }
    }

    private var questionChips: some View {
        let visibleQuestions = questionExamples.prefix(4).enumerated().map { index, question in
            HomeAIQuestionExample(id: "\(index)-\(question)", question: question)
        }

        return ViewThatFits(in: .vertical) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 126), spacing: 8)], alignment: .leading, spacing: 8) {
                ForEach(visibleQuestions) { example in
                    HomeAIQuestionChip(question: example.question)
                }
            }

            GeometryReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 8) {
                        ForEach(visibleQuestions) { example in
                            HomeAIQuestionChip(question: example.question)
                                .frame(width: min(max(proxy.size.width * 0.72, 160), 320))
                        }
                    }
                    .padding(.trailing, max(AppSpacing.screenHorizontal, 24))
                }
            }
            .frame(height: 72)
        }
    }
}

private struct HomeAIQuestionExample: Identifiable {
    let id: String
    let question: String
}

private struct HomeAIQuestionChip: View {
    let question: String

    var body: some View {
        Text(question)
            .font(.system(size: 11, weight: .semibold, design: .default))
            .foregroundStyle(AppColors.textSecondary)
            .lineLimit(3)
            .minimumScaleFactor(0.84)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity, minHeight: AppIcons.Metrics.minimumTouchTarget, alignment: .leading)
            .background(Color.white.opacity(0.055))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

// MARK: - Audience AI Help

struct HomeAIAudienceHelpSection: View {
    let aiTitle: String
    let heroTitle: String
    let heroSubtitle: String
    let promptPlaceholder: String
    let accessibilityLabel: String
    let heroPrompt: String
    let topics: [HomeAIAudienceTopic]
    let tools: [HomeAIAudienceTool]
    let language: AppLanguage
    let onOpenAssistant: (String?) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            heroButton
            topicChips
            toolButtons
        }
        .homeReadableBand()
        .padding(.bottom, 34)
        .accessibilityIdentifier("home.aiAudienceHelp")
    }

    private var heroButton: some View {
        Button {
            onOpenAssistant(heroPrompt)
        } label: {
            ZStack(alignment: .bottomLeading) {
                PremiumImageView(
                    asset: ContentMediaRegistry.aiImage ?? ContentArtworkRegistry.asset(for: .aiHero),
                    language: language,
                    height: 270,
                    aspectRatio: nil,
                    mode: .fill,
                    cornerRadius: 0,
                    overlayStyle: .none,
                    fallbackCategory: .ai,
                    accessibilityLabel: accessibilityLabel,
                    targetPixelWidth: 1200
                )
                .accessibilityHidden(true)

                LinearGradient(
                    colors: [
                        Color.black.opacity(0.10),
                        AppColors.navyDeep.opacity(0.35),
                        AppColors.navyDeep.opacity(0.65)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 16) {
                    heroTopBar
                    heroCopy
                    promptPill
                }
                .padding(18)
            }
            .frame(height: 270)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(0.16), lineWidth: 1)
            )
            .shadow(color: AppColors.cyanGlow.opacity(0.16), radius: 22, x: 0, y: 14)
        }
        .buttonStyle(NLTileButtonStyle())
    }

    private var heroTopBar: some View {
        HStack {
            HStack(spacing: 10) {
                GlassVisualBadge(size: 34, cornerRadius: 11, accent: AppColors.violet) {
                    GeneratedCategoryArtwork(symbol: "sparkles", accent: AppColors.violet)
                }

                Text(aiTitle)
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 10)
            .frame(height: 46)
            .background(.ultraThinMaterial.opacity(0.58))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.22), lineWidth: 1))

            Spacer()

            Image(systemName: "crown.fill")
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(AppColors.dutchOrange)
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        }
    }

    private var heroCopy: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(heroTitle)
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(heroSubtitle)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.80))
                .lineLimit(2)
        }
    }

    private var promptPill: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.white.opacity(0.68))

            Text(promptPlaceholder)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.60))
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Spacer(minLength: 8)

            Image(systemName: "arrow.right")
                .font(.system(size: 19, weight: .black))
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(
                    LinearGradient(
                        colors: [AppColors.cyanGlow, AppColors.softBlue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
        }
        .padding(.leading, 18)
        .padding(.trailing, 6)
        .frame(height: 62)
        .background(.ultraThinMaterial.opacity(0.70))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.16), lineWidth: 1))
    }

    private var topicChips: some View {
        HStack(spacing: 10) {
            ForEach(topics) { topic in
                HomeAIAudienceTopicChip(topic: topic) {
                    onOpenAssistant(topic.prompt)
                }
            }
        }
        .accessibilityIdentifier("home.aiAudienceHelp.topics")
    }

    private var toolButtons: some View {
        HStack(spacing: 10) {
            ForEach(tools) { tool in
                HomeAIAudienceToolButton(tool: tool) {
                    onOpenAssistant(tool.prompt)
                }
            }
        }
    }
}

struct HomeAIAudienceTopic: Identifiable {
    let id: String
    let title: String
    let symbol: String
    let tint: Color
    let prompt: String
}

struct HomeAIAudienceTool: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let symbol: String
    let tint: Color
    let prompt: String?
}

private struct HomeAIAudienceTopicChip: View {
    let topic: HomeAIAudienceTopic
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: topic.symbol)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(topic.tint.opacity(0.55))
                    .clipShape(Circle())

                Text(topic.title)
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 88)
            .background(AppColors.cardElevated.opacity(0.64))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(topic.tint.opacity(0.20), lineWidth: 0.8)
            )
        }
        .buttonStyle(NLTileButtonStyle())
    }
}

private struct HomeAIAudienceToolButton: View {
    let tool: HomeAIAudienceTool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: tool.symbol)
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(tool.tint)
                    .frame(width: 48, height: 48)
                    .background(tool.tint.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(tool.title)
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(1)
                    Text(tool.subtitle)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 4)

                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(Color.white.opacity(0.62))
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 78)
            .background(AppColors.cardElevated.opacity(0.62))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.11), lineWidth: 0.8)
            )
        }
        .buttonStyle(NLTileButtonStyle())
    }
}
