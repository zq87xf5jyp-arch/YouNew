import SwiftUI

// MARK: - Quick Action Chip

struct QuickActionChip: View {
    let action: HomeQuickAction
    let language: AppLanguage

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                LinearGradient(
                    colors: [action.accent, action.accent.opacity(0.68)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Image(systemName: action.icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
            }
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .shadow(color: action.accent.opacity(0.32), radius: 9, x: 0, y: 4)

            Text(action.title(language))
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.78)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 132)
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .background(GlassPanelBackground(accent: action.accent, cornerRadius: 20))
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// MARK: - Home Button Styles

struct HomeHeroButtonStyle: ButtonStyle {
    let tint: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 13)
            .background(
                LinearGradient(
                    colors: [
                        Color.white.opacity(configuration.isPressed ? 0.18 : 0.12),
                        tint.opacity(configuration.isPressed ? 0.22 : 0.14)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.white.opacity(configuration.isPressed ? 0.20 : 0.11), lineWidth: 0.8)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.24, dampingFraction: 0.78), value: configuration.isPressed)
    }
}

struct HomePrimaryHeroButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .background(AppColors.dutchOrange.opacity(configuration.isPressed ? 0.82 : 0.96))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: AppColors.dutchOrange.opacity(configuration.isPressed ? 0.20 : 0.34), radius: 18, x: 0, y: 8)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.68), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed {
                    AppHaptics.lightImpact()
                }
            }
    }
}

struct HomeSecondaryIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .background(Color.white.opacity(configuration.isPressed ? 0.18 : 0.11))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.16), lineWidth: 0.8)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}
