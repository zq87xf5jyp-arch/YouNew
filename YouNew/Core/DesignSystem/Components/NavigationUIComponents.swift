import SwiftUI

struct InteractiveCard<Content: View>: View {
    let destination: AppDestination
    @ViewBuilder var content: () -> Content

    var body: some View {
        NavigationLink(value: destination) {
            content()
                .frame(maxWidth: .infinity, alignment: .leading)
                .appCardStyle()
        }
        .buttonStyle(AppPressableCardButtonStyle())
    }
}

struct SmartNavigationRow: View {
    let title: String
    let subtitle: String
    let symbol: String
    let destination: AppDestination

    var body: some View {
        NavigationLink(value: destination) {
            HStack(alignment: .top, spacing: AppSpacing.small) {
                Image(systemName: symbol)
                    .foregroundStyle(AppColors.accent)
                    .frame(width: 24)
                    .padding(.top, 2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(3)
                        .minimumScaleFactor(0.86)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(subtitle)
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(4)
                        .minimumScaleFactor(0.86)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: AppIcons.forward)
                    .font(.footnote)
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(.top, 4)
            }
            .appCardStyle()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Premium Menu Components

struct GradientIconBadge: View {
    let symbol: String
    let color: Color
    var size: CGFloat = 40
    var cornerRadius: CGFloat = AppCornerRadius.small

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.24), color.opacity(0.10)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(color.opacity(0.24), lineWidth: 0.75)
            Image(systemName: symbol)
                .font(.system(size: size * 0.42, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(color)
        }
        .frame(width: size, height: size)
        .shadow(color: color.opacity(0.12), radius: 8, x: 0, y: 4)
    }
}

/// Drop-in back button for pushed screens and modal close buttons.
/// Place in `.toolbar { ToolbarItem(placement: .topBarLeading) { AppNavigationBackButton() } }`
/// or as a close button with `style: .close`.
struct AppNavigationBackButton: View {
    enum Style {
        case back   // chevron.left — for pushed NavigationStack screens
        case close  // xmark       — for sheet / modal screens
    }

    var style: Style = .back
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var languageManager: LanguageManager

    private var label: String {
        switch style {
        case .back:  return L10n.t("common.back",  languageManager.appLanguage)
        case .close: return L10n.t("common.close", languageManager.appLanguage)
        }
    }

    private var icon: String {
        switch style {
        case .back:  return AppIcons.back   // "chevron.left"
        case .close: return "xmark"
        }
    }

    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(AppColors.textPrimary)
                .frame(width: 30, height: 30)
                .background {
                    Circle()
                        .fill(AppColors.glassSurfaceElevated.opacity(0.72))
                        .overlay {
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.28), AppColors.stroke.opacity(0.72)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 0.75
                                )
                        }
                }
                // 44×44 pt guaranteed touch target
                .frame(width: AppIcons.Metrics.minimumTouchTarget,
                       height: AppIcons.Metrics.minimumTouchTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(AppPressableButtonStyle())
        .accessibilityLabel(label)
    }
}

struct PremiumMenuCard<Content: View>: View {
    var padding: CGFloat = 0
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                        .fill(AppColors.card)
                    RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.08), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.22), AppColors.stroke.opacity(0.72)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.75
                    )
            }
            .shadow(color: Color.black.opacity(0.10), radius: 18, x: 0, y: 10)
    }
}

struct PremiumMenuRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    var trailingSymbol: String = "chevron.right"

    var body: some View {
        HStack(spacing: 14) {
            GradientIconBadge(symbol: icon, color: color, size: 40)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(subtitle)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: AppSpacing.small)

            Image(systemName: trailingSymbol)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppColors.textTertiary)
                .frame(width: 18)
        }
        .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
        .padding(.horizontal, AppSpacing.medium)
        .padding(.vertical, 11)
        .contentShape(Rectangle())
    }
}

struct PremiumMenuSection<Content: View>: View {
    let title: String
    var subtitle: String? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: title, subtitle: subtitle)
                .padding(.horizontal, 2)

            PremiumMenuCard {
                VStack(spacing: 0) {
                    content()
                }
            }
        }
    }
}

struct PremiumStatTile: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(label)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
        .padding(AppSpacing.cardPaddingCompact)
        .background(color.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous)
                .stroke(color.opacity(0.20), lineWidth: 0.75)
        )
    }
}

struct OfficialSourceButton: View {
    let title: String
    let url: URL
    @Environment(\.openURL) private var openURL

    var body: some View {
        Button(title) {
            if let safeURL = AppURL.validatedWebURL(url) {
                openURL(safeURL)
            }
        }
        .buttonStyle(PrimaryPremiumButtonStyle())
    }
}

struct InstitutionChip: View {
    let title: String
    let destination: AppDestination

    var body: some View {
        NavigationLink(value: destination) {
            HStack(spacing: 6) {
                Image(systemName: "building.columns")
                Text(title)
            }
            .font(AppTypography.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .frame(minHeight: AppButtonMetrics.minTouchSize)
            .background(AppColors.softBlue.opacity(0.12))
            .clipShape(Capsule())
        }
        .buttonStyle(AppPressableButtonStyle())
    }
}

struct QuickActionButton: View {
    let title: String
    let symbol: String
    let destination: AppDestination

    var body: some View {
        NavigationLink(value: destination) {
            Label(title, systemImage: symbol)
                .font(AppTypography.footnote)
        }
        .buttonStyle(SecondaryPremiumButtonStyle())
    }
}

struct SafetyBanner: View {
    let text: String

    var body: some View {
        DisclaimerBanner(text: text, tone: AppColors.warning)
    }
}

struct RelatedContentSection: View {
    let title: String
    let items: [RelatedNavigationItem]

    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                SectionHeader(title: title)
                ForEach(items) { item in
                    SmartNavigationRow(
                        title: item.title,
                        subtitle: item.subtitle,
                        symbol: item.symbol,
                        destination: item.destination
                    )
                }
            }
        }
    }
}

// MARK: - Save / Bookmark

struct SaveItemButton: View {
    let itemID: String
    let kind: SavedItemsStore.SavedItemKind
    let title: String
    let subtitle: String?
    let destination: AppDestination?
    @ObservedObject private var store = SavedItemsStore.shared
    @EnvironmentObject private var languageManager: LanguageManager

    init(
        itemID: String,
        kind: SavedItemsStore.SavedItemKind = .other,
        title: String? = nil,
        subtitle: String? = nil,
        destination: AppDestination? = nil
    ) {
        self.itemID = itemID
        self.kind = kind
        self.title = title ?? itemID
        self.subtitle = subtitle
        self.destination = destination
    }

    var body: some View {
        Button {
            store.toggle(
                id: itemID,
                kind: kind,
                title: title,
                subtitle: subtitle,
                destination: destination
            )
        } label: {
            Image(systemName: store.isSaved(itemID) ? "bookmark.fill" : "bookmark")
                .font(.system(size: 16, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(store.isSaved(itemID) ? AppColors.dutchOrange : AppColors.accentLight)
                .frame(width: 44, height: 44)
                .background {
                    Circle()
                        .fill(store.isSaved(itemID) ? AppColors.dutchOrange.opacity(0.16) : AppColors.glassSurfaceElevated)
                        .overlay {
                            Circle()
                                .stroke(store.isSaved(itemID) ? AppColors.dutchOrange.opacity(0.34) : AppColors.stroke.opacity(0.76), lineWidth: 0.8)
                        }
                }
                .contentShape(Rectangle())
                .symbolEffect(.bounce, value: store.isSaved(itemID))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            store.isSaved(itemID)
                ? L10n.t("common.remove_bookmark", languageManager.appLanguage)
                : L10n.t("common.bookmark_item", languageManager.appLanguage)
        )
    }
}

// MARK: - Common Mistakes

struct CommonMistakesSection: View {
    let mistakes: [NewcomerMistake]
    @EnvironmentObject private var languageManager: LanguageManager

    var body: some View {
        if !mistakes.isEmpty {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                SectionHeader(title: L10n.t("common.mistakes_section_title", languageManager.appLanguage), icon: "exclamationmark.triangle")
                ForEach(mistakes) { mistake in
                    NavigationLink(value: AppDestination.mistake(mistake.id)) {
                        HStack(spacing: AppSpacing.small) {
                            ZStack {
                                RoundedRectangle(cornerRadius: AppCornerRadius.xSmall)
                                    .fill(riskColor(mistake.riskLevel).opacity(0.12))
                                    .frame(width: 36, height: 36)
                                Image(systemName: mistake.category.systemImageName)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(riskColor(mistake.riskLevel))
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(mistake.title(languageManager.appLanguage))
                                    .font(AppTypography.bodyStrong)
                                    .foregroundStyle(AppColors.textPrimary)
                                    .lineLimit(2)
                                Text(mistake.category.localized(languageManager.appLanguage))
                                    .font(AppTypography.caption)
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.footnote)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        .appCardStyle()
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func riskColor(_ level: RiskLevel) -> Color {
        switch level {
        case .low: return AppColors.success
        case .medium: return AppColors.warning
        case .high: return AppColors.dutchOrange
        case .urgent: return AppColors.error
        }
    }
}

// MARK: - Next Step Card

struct NextStepCard: View {
    let title: String
    let subtitle: String
    let destination: AppDestination
    @EnvironmentObject private var languageManager: LanguageManager

    var body: some View {
        NavigationLink(value: destination) {
            HStack(spacing: AppSpacing.medium) {
                VStack(alignment: .leading, spacing: AppSpacing.xxSmall) {
                    Text(L10n.t("search.next_recommended_step", languageManager.appLanguage).uppercased())
                        .font(AppTypography.caption)
                        .tracking(AppTypography.overlineTracking)
                        .foregroundStyle(AppColors.accent)
                    Text(title)
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColors.textPrimary)
                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(AppTypography.footnote)
                            .foregroundStyle(AppColors.textSecondary)
                            .lineLimit(2)
                    }
                }
                Spacer()
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title3)
                    .foregroundStyle(AppColors.accent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .appCardStyle()
        }
        .buttonStyle(AppPressableCardButtonStyle())
    }
}

#if DEBUG && os(iOS)
#Preview("Premium Menu Components") {
    ScrollView {
        VStack(spacing: AppSpacing.sectionGap) {
            PremiumMenuSection(title: "Main") {
                PremiumMenuRow(
                    icon: "books.vertical.fill",
                    color: AppColors.accent,
                    title: "Resources",
                    subtitle: "Trusted guides and official links"
                )
                Divider().padding(.leading, 70)
                PremiumMenuRow(
                    icon: "building.columns.fill",
                    color: AppColors.success,
                    title: "Official sources",
                    subtitle: "Government websites and verified information"
                )
            }

            HStack(spacing: AppSpacing.small) {
                PremiumStatTile(value: "12", label: "Saved", color: AppColors.accent)
                PremiumStatTile(value: "4", label: "Urgent", color: AppColors.dutchOrange)
            }
        }
        .padding()
    }
    .background { GlobalBackgroundView() }
}
#endif
