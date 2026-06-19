import SwiftUI

struct ProgressCard: View {
    let title: String
    let progress: Double
    let completedCount: Int
    let totalCount: Int
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        HStack(spacing: AppSpacing.large) {
            progressRing

            VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                Text(title)
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(AppColors.textPrimary)

                Text(String(format: L10n.t("progress.steps_completed", lang), completedCount, totalCount))
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textSecondary)

                gradientProgressBar
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardStyle()
    }

    // MARK: - Sub-views

    private var progressRing: some View {
        ZStack {
            Circle()
                .stroke(AppColors.progressTrack, lineWidth: 7)
                .frame(width: 72, height: 72)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [AppColors.accent, AppColors.dutchOrange, AppColors.accentLight]),
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: 7, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 72, height: 72)
                .animation(AppAnimations.progressFill, value: progress)

            VStack(spacing: 0) {
                Text("\(Int(progress * 100))")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                Text("%")
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.textTertiary)
            }
        }
    }

    private var gradientProgressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppColors.progressTrack)
                    .frame(height: 5)

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.accent, AppColors.dutchOrange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(8, geo.size.width * progress), height: 5)
                    .animation(AppAnimations.progressFill, value: progress)
            }
        }
        .frame(height: 5)
    }
}
