import SwiftUI

struct ResourceCard: View {
    let item: ResourceLinkItem
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }

    private var trustMetadata: TrustMetadata {
        TrustMetadata(
            sourceUpdatedAt: "2026-05",
            sourceLabel: item.isOfficial ? L10n.t("common.official_info", lang) : item.sourceLabel,
            updateIndicator: L10n.t("trust.review_periodically", lang)
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            PremiumImageHeader(
                title: item.localizedTitle(lang),
                asset: resourceImageAsset,
                language: lang,
                symbol: resourceSymbol,
                accent: item.isOfficial ? AppColors.success : AppColors.warning,
                height: 124,
                cornerRadius: 18,
                fallbackCategory: resourceFallbackCategory
            )

            ViewThatFits(in: .horizontal) {
                HStack(alignment: .center, spacing: AppSpacing.xSmall) {
                    categoryLabel

                    Spacer(minLength: AppSpacing.small)

                    saveButton
                    sourceBadge
                }

                VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                    categoryLabel
                    HStack(spacing: AppSpacing.xSmall) {
                        saveButton
                        sourceBadge
                        Spacer(minLength: 0)
                    }
                }
            }

            Text(item.localizedTitle(lang))
                .font(AppTypography.cardTitle)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(4)
                .minimumScaleFactor(0.88)
                .fixedSize(horizontal: false, vertical: true)

            Text(item.localizedDescription(lang))
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary.opacity(0.92))
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)

            Text(String(format: L10n.t("resource.who_helps", lang), item.localizedWhoItHelps(lang)))
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            if let reminder = item.localizedReminder(lang) {
                Text(reminder)
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.warning)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Link(L10n.t("resource.open_source", lang), destination: AppURL.safeWebURL(item.url))
                .buttonStyle(SecondaryPremiumButtonStyle())

            TrustMetadataRow(metadata: trustMetadata)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appGlassCardStyle(accent: item.isOfficial ? AppColors.success : AppColors.warning)
    }

    private var resourceImageAsset: AppImageAsset? {
        switch normalizedCategory {
        case "emergencies":
            return ContentMediaRegistry.emergencyImage ?? ContentMediaRegistry.officialSourcesHero
        case "healthcare":
            return ContentMediaRegistry.healthcareBasicsImage ?? ContentMediaRegistry.healthcarePharmacyImage
        case "transport":
            return ContentMediaRegistry.ovChipkaartImage ?? ContentMediaRegistry.transportStationHero
        case "taxes", "identity", "immigration", "legal help":
            return ContentMediaRegistry.officialSourcesHero ?? ContentMediaRegistry.municipalityCityHallImage
        case "work":
            return ContentMediaRegistry.workImage ?? ContentMediaRegistry.officialSourcesHero
        case "education", "student life":
            return ContentMediaRegistry.museumsCultureImage ?? ContentMediaRegistry.cultureHero
        case "housing":
            return ContentMediaRegistry.premiumHousingImage ?? ContentMediaRegistry.housingTerracedHousesImage
        case "mental support":
            return ContentMediaRegistry.healthcareBasicsImage ?? ContentMediaRegistry.profileImage
        case "scams":
            return ContentMediaRegistry.searchImage ?? ContentMediaRegistry.officialSourcesHero
        default:
            return item.isOfficial ? ContentMediaRegistry.officialSourcesHero : ContentMediaRegistry.searchImage
        }
    }

    private var resourceFallbackCategory: PremiumImageFallbackCategory {
        switch normalizedCategory {
        case "emergencies":
            return .emergency
        case "healthcare", "mental support":
            return .healthcare
        case "transport":
            return .transport
        case "housing":
            return .housing
        case "work":
            return .work
        case "education", "student life":
            return .dutchA1A2
        case "scams":
            return .search
        case "taxes", "identity", "immigration", "legal help":
            return .government
        default:
            return item.isOfficial ? .government : .search
        }
    }

    private var resourceSymbol: String {
        switch normalizedCategory {
        case "emergencies": return "cross.case.circle.fill"
        case "healthcare", "mental support": return "cross.case.fill"
        case "transport": return "tram.fill"
        case "taxes": return "eurosign.circle.fill"
        case "legal help": return "scalemass.fill"
        case "immigration", "identity": return "person.text.rectangle.fill"
        case "work": return "briefcase.fill"
        case "education", "student life": return "graduationcap.fill"
        case "housing": return "house.fill"
        case "scams": return "shield.lefthalf.filled"
        default: return item.isOfficial ? "checkmark.shield.fill" : "link.circle.fill"
        }
    }

    private var normalizedCategory: String {
        item.category.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private var categoryLabel: some View {
        Text(item.localizedCategory(lang))
            .font(AppTypography.caption)
            .foregroundStyle(AppColors.textSecondary)
            .lineLimit(2)
            .minimumScaleFactor(0.82)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var saveButton: some View {
        SaveItemButton(
            itemID: "resource::\(item.title.lowercased())",
            kind: .resource,
            title: item.localizedTitle(lang),
            subtitle: item.localizedCategory(lang),
            destination: .resource(item.id)
        )
    }

    private var sourceBadge: some View {
        Text(item.isOfficial ? L10n.t("common.official_info", lang) : item.sourceLabel)
            .font(AppTypography.caption)
            .foregroundStyle(item.isOfficial ? AppColors.success : AppColors.warning)
            .lineLimit(2)
            .minimumScaleFactor(0.78)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background((item.isOfficial ? AppColors.success : AppColors.warning).opacity(0.12))
            .overlay(
                Capsule()
                    .stroke((item.isOfficial ? AppColors.success : AppColors.warning).opacity(0.35), lineWidth: 1)
            )
            .clipShape(Capsule())
    }
}
