import SwiftUI

struct MarketingPreviewView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    private var lang: AppLanguage { languageManager.appLanguage }

    private let benefits = [
        "marketing.benefit.systems",
        "marketing.benefit.letters",
        "marketing.benefit.sources",
        "marketing.benefit.mistakes",
        "marketing.benefit.one_guide"
    ]

    private let screenshotLines = [
        "marketing.screenshot.1",
        "marketing.screenshot.2",
        "marketing.screenshot.3",
        "marketing.screenshot.4",
        "marketing.screenshot.5"
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                SectionHeader(title: L10n.t("marketing.title", lang), subtitle: L10n.t("marketing.subtitle", lang))

                InfoCard(
                    title: L10n.t("marketing.positioning_title", lang),
                    subtitle: L10n.t("marketing.positioning_subtitle", lang),
                    detail: L10n.t("marketing.positioning_detail", lang),
                    icon: "megaphone"
                )

                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    SectionHeader(title: L10n.t("marketing.key_benefits", lang))
                    ForEach(benefits, id: \.self) { key in
                        Text("• \(L10n.t(key, lang))")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.textPrimary)
                            .appCardStyle()
                    }
                }

                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    SectionHeader(title: L10n.t("marketing.screenshot_copy", lang))
                    ForEach(screenshotLines, id: \.self) { key in
                        Text(L10n.t(key, lang))
                            .font(AppTypography.bodyStrong)
                            .foregroundStyle(AppColors.textPrimary)
                            .appCardStyle()
                    }
                }

                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    SectionHeader(title: L10n.t("marketing.brand_palette", lang))
                    HStack(spacing: AppSpacing.small) {
                        colorSwatch(AppColors.navyDeep, label: "Navy")
                        colorSwatch(AppColors.accent, label: "Teal")
                        colorSwatch(AppColors.dutchOrange, label: "Orange")
                    }
                }

                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    SectionHeader(title: L10n.t("marketing.icon_preview", lang))
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(AppColors.navyDeep)
                        .frame(width: 112, height: 112)
                        .overlay {
                            ZStack {
                                Path { path in
                                    path.move(to: CGPoint(x: 16, y: 88))
                                    path.addCurve(to: CGPoint(x: 88, y: 26), control1: CGPoint(x: 32, y: 72), control2: CGPoint(x: 66, y: 42))
                                }
                                .stroke(AppColors.accent, style: StrokeStyle(lineWidth: 7, lineCap: .round))

                                Circle()
                                    .fill(AppColors.dutchOrange)
                                    .frame(width: 16, height: 16)
                                    .offset(x: -34, y: 25)
                            }
                        }

                    Text(L10n.t("marketing.icon_note", lang))
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .appCardStyle()

                InfoCard(
                    title: L10n.t("marketing.icon_checklist_title", lang),
                    subtitle: "App Store",
                    detail: L10n.t("marketing.icon_checklist_detail", lang),
                    icon: "checkmark.seal"
                )
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
        }
        .appSceneBackground()
        .navigationTitle(L10n.t("marketing.nav_title", lang))
    }

    private func colorSwatch(_ color: Color, label: String) -> some View {
        VStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(color)
                .frame(width: 64, height: 52)
            Text(label)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .appCardStyle()
    }
}
