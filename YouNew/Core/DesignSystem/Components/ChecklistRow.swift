import SwiftUI

struct ChecklistRow: View {
    let item: ChecklistItem
    let onToggle: () -> Void
    @State private var expanded = false
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }

    private var priorityColor: Color {
        switch item.priority {
        case .high: return AppColors.error
        case .medium: return AppColors.warning
        case .low: return AppColors.success
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            HStack(alignment: .top, spacing: AppSpacing.small) {
                Button(action: onToggle) {
                    Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(item.isCompleted ? AppColors.success : AppColors.textSecondary)
                        .frame(minWidth: 44, minHeight: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(item.isCompleted ? L10n.t("checklist.mark_not_completed", lang) : L10n.t("checklist.mark_completed", lang))

                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    Text(item.title(lang))
                        .font(AppTypography.cardTitle)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(4)
                        .minimumScaleFactor(0.86)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(item.description(lang))
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textSecondary.opacity(0.92))
                        .lineLimit(expanded ? nil : 3)
                        .fixedSize(horizontal: false, vertical: true)

                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: AppSpacing.xSmall) {
                            checklistChip(item.category.localized(lang), color: AppColors.textSecondary)
                            checklistChip(item.priority.localized(lang), color: priorityColor, background: priorityColor.opacity(0.12))
                        }

                        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                            checklistChip(item.category.localized(lang), color: AppColors.textSecondary)
                            checklistChip(item.priority.localized(lang), color: priorityColor, background: priorityColor.opacity(0.12))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: 0)

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        expanded.toggle()
                    }
                } label: {
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(AppColors.textSecondary)
                        .frame(minWidth: 44, minHeight: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(expanded ? L10n.t("common.collapse_details", lang) : L10n.t("common.expand_details", lang))
            }

            if expanded {
                VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                    Text(String(format: L10n.t("checklist.suggested_timing", lang), item.suggestedTiming(lang)))
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)

                    if let dueDate = item.dueDate {
                        ViewThatFits(in: .horizontal) {
                            HStack(spacing: AppSpacing.xSmall) {
                                Text(L10n.t("checklist.possible_due_date", lang))
                                    .font(AppTypography.footnote.weight(.semibold))
                                    .foregroundStyle(AppColors.textTertiary)
                                Text(dueDate, format: Date.FormatStyle().day().month().year())
                                    .font(AppTypography.footnote)
                                    .foregroundStyle(AppColors.textTertiary)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(L10n.t("checklist.possible_due_date", lang))
                                    .font(AppTypography.footnote.weight(.semibold))
                                    .foregroundStyle(AppColors.textTertiary)
                                Text(dueDate, format: Date.FormatStyle().day().month().year())
                                    .font(AppTypography.footnote)
                                    .foregroundStyle(AppColors.textTertiary)
                            }
                        }
                    }

                    Link("\(L10n.t("resource.open_source", lang)): \(item.officialSourceName)", destination: AppURL.safeWebURL(item.officialSourceURL))
                        .font(AppTypography.footnote.weight(.semibold))
                        .lineLimit(3)
                        .minimumScaleFactor(0.82)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardStyle()
        .animation(.easeInOut(duration: 0.2), value: item.isCompleted)
    }

    private func checklistChip(_ text: String, color: Color, background: Color = AppColors.chipBackground) -> some View {
        Text(text)
            .font(AppTypography.caption)
            .foregroundStyle(color)
            .lineLimit(2)
            .minimumScaleFactor(0.80)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(background)
            .clipShape(Capsule())
    }
}
