import SwiftUI

struct AIAskButton: View {
    let title: String
    let context: AIContext
    let prompt: String?

    @EnvironmentObject private var appState: AppStateViewModel

    init(title: String, context: AIContext, prompt: String? = nil) {
        self.title = title
        self.context = context
        self.prompt = prompt
    }

    var body: some View {
        NavigationLink(value: AppDestination.assistantHub) {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(AppColors.orangeGlow)
                    .frame(width: 34, height: 34)
                    .background(AppColors.orangeGlow.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))

                Text(title)
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.86)

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(AppColors.textTertiary)
            }
            .padding(14)
            .background(AppColors.graphite.opacity(0.90))
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                    .stroke(Color.white.opacity(0.14), lineWidth: 0.75)
            )
        }
        .simultaneousGesture(TapGesture().onEnded {
            appState.pendingAIContext = context
            appState.pendingAIPrompt = prompt
        })
        .buttonStyle(NLTileButtonStyle())
    }
}

