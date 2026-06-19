import SwiftUI

struct PlaceDetailView: View {
    let place: NearbyPlace
    let distanceText: String
    let travelTimeText: String
    let onOpenMaps: () -> Void
    let onOpenWalkRoute: () -> Void
    let onOpenTransitRoute: () -> Void
    let onOpenCyclingRoute: () -> Void
    let onToggleSaved: () -> Void
    let isSaved: Bool
    let relatedLinks: [PlaceRelatedLink]
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.dismiss) private var dismiss

    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        GeometryReader { proxy in
            let pageWidth = DetailPageLayout.pageWidth(viewportWidth: proxy.size.width)
            let contentWidth = DetailPageLayout.availableContentWidth(viewportWidth: proxy.size.width)

            ScrollView {
                VStack(alignment: .leading, spacing: DetailPageLayout.sectionGap) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                            Text(place.localizedName(lang))
                                .font(AppTypography.sectionTitle)
                                .foregroundStyle(AppColors.textPrimary)
                            Text(place.category.localized(lang))
                                .font(AppTypography.metadata)
                                .foregroundStyle(AppColors.accent)
                        }
                        Spacer()
                        Text(place.isOfficialSource ? L10n.t("common.official_info", lang) : place.localizedSourceLabel(lang))
                            .font(AppTypography.caption)
                            .foregroundStyle(place.isOfficialSource ? AppColors.success : AppColors.warning)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background((place.isOfficialSource ? AppColors.success : AppColors.warning).opacity(0.12))
                            .clipShape(Capsule())
                    }

                    Button(isSaved ? L10n.t("map.remove_saved_place", lang) : L10n.t("map.save_place", lang)) {
                        onToggleSaved()
                    }
                    .buttonStyle(.bordered)
                    .appCardStyle()

                    InfoCard(title: L10n.t("map.place_for", lang), subtitle: L10n.t("map.beginner_friendly", lang), detail: place.localizedDescription(lang), icon: "mappin.and.ellipse")
                    InfoCard(title: L10n.t("map.why_newcomers_use", lang), subtitle: place.city, detail: place.localizedUseCase(lang), icon: "person.text.rectangle")

                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        SectionHeader(title: L10n.t("map.visit_details", lang))
                        Text(place.address)
                            .font(AppTypography.footnote)
                            .foregroundStyle(AppColors.textSecondary)
                        if !place.isReferenceLocation {
                            Text(distanceText + " • " + travelTimeText)
                                .font(AppTypography.footnote)
                                .foregroundStyle(AppColors.textSecondary)
                        } else {
                            Text(distanceText)
                                .font(AppTypography.footnote)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        Text(place.localizedOpeningHours(lang))
                            .font(AppTypography.footnote)
                            .foregroundStyle(AppColors.warning)
                        Text(String(format: L10n.t("legal.last_updated", lang), place.lastUpdated))
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                        Text(L10n.t("map.verify_hours", lang))
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .appCardStyle()

                    if let emergencyNote = place.localizedEmergencyNote(lang) {
                        SafetyBanner(text: emergencyNote)
                    }

                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        SectionHeader(title: L10n.t("map.route_actions", lang))
                        Button(L10n.t("map.open_apple_maps", lang)) { onOpenMaps() }
                            .buttonStyle(.borderedProminent)
                            .tint(AppColors.accent)
                        if !place.isReferenceLocation {
                            ViewThatFits(in: .horizontal) {
                                HStack(spacing: AppSpacing.small) {
                                    routeButton(title: L10n.t("map.walking", lang), action: onOpenWalkRoute)
                                    routeButton(title: L10n.t("map.transit", lang), action: onOpenTransitRoute)
                                    routeButton(title: L10n.t("map.cycling", lang), action: onOpenCyclingRoute)
                                }

                                VStack(alignment: .leading, spacing: AppSpacing.small) {
                                    routeButton(title: L10n.t("map.walking", lang), action: onOpenWalkRoute)
                                    routeButton(title: L10n.t("map.transit", lang), action: onOpenTransitRoute)
                                    routeButton(title: L10n.t("map.cycling", lang), action: onOpenCyclingRoute)
                                }
                            }
                        }
                    }
                    .appCardStyle()

                    if let websiteURL = AppURL.validatedWebURL(place.websiteURL) {
                        VStack(alignment: .leading, spacing: AppSpacing.small) {
                            SectionHeader(title: L10n.t("beginner.official_source", lang))
                            Link(L10n.t("map.open_official_website", lang), destination: websiteURL)
                                .font(AppTypography.bodyStrong)
                        }
                        .appCardStyle()
                    }

                    if !relatedLinks.isEmpty {
                        VStack(alignment: .leading, spacing: AppSpacing.small) {
                            SectionHeader(title: L10n.t("map.related_guides", lang))
                            ForEach(relatedLinks) { link in
                                SmartNavigationRow(
                                    title: link.title,
                                    subtitle: link.subtitle,
                                    symbol: link.symbol,
                                    destination: link.destination
                                )
                            }
                        }
                    }

                    InfoCard(
                        title: L10n.t("map.trust_safety", lang),
                        subtitle: place.isOfficialSource ? L10n.t("map.official_source_label", lang) : place.localizedSourceLabel(lang),
                        detail: place.localizedTrustNote(lang),
                        icon: "checkmark.shield"
                    )
                }
                .frame(width: contentWidth, alignment: .leading)
                .padding(.top, AppSpacing.medium)
                .padding(.bottom, AppSpacing.medium)
                .padding(.horizontal, DetailPageLayout.pageHorizontalPadding)
                .frame(width: pageWidth, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .center)
                .tabBarScrollReserve(AppSpacing.tabBarScrollReserveMap)
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                AppNavigationBackButton(style: .close)
            }
        }
    }

    private func routeButton(title: String, action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .buttonStyle(.bordered)
    }
}
