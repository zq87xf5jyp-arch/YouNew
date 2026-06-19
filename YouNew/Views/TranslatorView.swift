import SwiftUI

struct TranslatorView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @StateObject private var viewModel = TranslatorViewModel()

    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                DisclaimerBanner(text: L10n.t("translator.disclaimer", lang), tone: AppColors.error)

                SectionHeader(title: L10n.t("translator.title", lang), subtitle: L10n.t("translator.subtitle", lang))

                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    Text(L10n.t("translator.text_to_translate", lang))
                        .font(AppTypography.cardTitle)
                        .foregroundStyle(AppColors.textPrimary)

                    TextEditor(text: $viewModel.inputText)
                        .font(AppTypography.body)
                        .frame(minHeight: 140)
                        .padding(8)
                        .background(AppColors.card)
                        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadius, style: .continuous))

                    HStack(spacing: AppSpacing.small) {
                        Picker(L10n.t("translator.from", lang), selection: $viewModel.fromLanguage) {
                            ForEach(TranslationLanguage.allCases) { language in
                                Text(language.rawValue).tag(language)
                            }
                        }
                        .pickerStyle(.menu)

                        Button { viewModel.swapLanguages() } label: {
                            Image(systemName: "arrow.left.arrow.right")
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                                .background(AppColors.chipBackground)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(L10n.t("translator.swap_languages", lang))

                        Picker(L10n.t("translator.to", lang), selection: $viewModel.toLanguage) {
                            ForEach(TranslationLanguage.allCases) { language in
                                Text(language.rawValue).tag(language)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    HStack(spacing: AppSpacing.small) {
                        Button(L10n.t("translator.detect_language", lang)) { viewModel.detectLanguage() }
                            .buttonStyle(.bordered)
                        Button(L10n.t("translator.translate", lang)) {
                            Task { await viewModel.translate() }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppColors.accent)
                    }
                }
                .appCardStyle()

                if let errorMessage = viewModel.errorMessage {
                    HStack(alignment: .top, spacing: AppSpacing.xSmall) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AppColors.error)
                        Text(errorMessage)
                            .font(AppTypography.footnote)
                            .foregroundStyle(AppColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .appCardStyle()
                    .transition(.opacity)
                }

                if let result = viewModel.result {
                    VStack(alignment: .leading, spacing: AppSpacing.medium) {
                        InfoCard(title: L10n.t("translator.translated_text", lang), subtitle: "\(result.fromLanguage) → \(result.toLanguage)", detail: result.translatedText, icon: "text.bubble")
                        InfoCard(title: L10n.t("translator.simple_explanation", lang), subtitle: L10n.t("translator.possible_meaning", lang), detail: result.simpleExplanation, icon: "lightbulb")
                        InfoCard(title: L10n.t("translator.institution_detection", lang), subtitle: result.detectedInstitution, detail: L10n.t("translator.possible_match_only", lang), icon: "building.columns")
                        InfoCard(title: L10n.t("translator.possible_dates", lang), subtitle: result.possibleDates.isEmpty ? L10n.t("translator.no_clear_date", lang) : result.possibleDates.joined(separator: ", "), detail: L10n.t("translator.dates_may_be_incomplete", lang), icon: "calendar")

                        Button(L10n.t("translator.copy_translated", lang)) { viewModel.copyResult() }
                            .buttonStyle(.bordered)
                    }
                }

                VStack(alignment: .leading, spacing: AppSpacing.medium) {
                    SectionHeader(title: L10n.t("translator.recent", lang))
                    if viewModel.recent.isEmpty {
                        Text(L10n.t("translator.no_recent", lang))
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.textSecondary)
                            .appCardStyle()
                    } else {
                        ForEach(viewModel.recent.prefix(5)) { item in
                            VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                                Text(item.sourceText)
                                    .font(AppTypography.bodyStrong)
                                    .foregroundStyle(AppColors.textPrimary)
                                    .lineLimit(2)
                                Text(item.translatedText)
                                    .font(AppTypography.body)
                                    .foregroundStyle(AppColors.textSecondary)
                                    .lineLimit(2)
                            }
                            .appCardStyle()
                        }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .tabBarScrollReserve()
        }
        .appSceneBackground()
        .navigationTitle(L10n.t("translator.title", lang))
    }
}
