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
                    PremiumImageHeader(
                        title: place.localizedName(lang),
                        asset: imageAsset(for: place),
                        language: lang,
                        symbol: place.category.systemImageName,
                        accent: accent(for: place.category),
                        height: 190,
                        cornerRadius: 24,
                        fallbackCategory: fallbackCategory(for: place.category)
                    )
                    .accessibilityIdentifier("place.detail.hero")

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

                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        SectionHeader(
                            title: L10n.t("map.related_guides", lang),
                            subtitle: relatedLinks.isEmpty ? relatedGuidesFallbackSubtitle : nil
                        )

                        if relatedLinks.isEmpty {
                            relatedGuidesFallback
                        } else {
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
                    .accessibilityIdentifier("place.relatedGuides.dashboard")

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

    private var relatedGuidesFallback: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            SmartNavigationRow(
                title: localized(en: "Search this topic", nl: "Zoek dit onderwerp", ru: "Искать по теме"),
                subtitle: localized(en: "Find answers, documents, and official links.", nl: "Vind antwoorden, documenten en officiële links.", ru: "Найти ответы, документы и официальные ссылки."),
                symbol: "magnifyingglass",
                destination: .searchList
            )

            SmartNavigationRow(
                title: localized(en: "Official sources", nl: "Officiële bronnen", ru: "Официальные источники"),
                subtitle: localized(en: "Verify opening hours, rules, and requirements.", nl: "Controleer openingstijden, regels en vereisten.", ru: "Проверьте часы работы, правила и требования."),
                symbol: "building.columns",
                destination: .officialSources
            )

            SmartNavigationRow(
                title: localized(en: "Documents", nl: "Documenten", ru: "Документы"),
                subtitle: localized(en: "Prepare files before visiting or applying.", nl: "Bereid bestanden voor voordat je langsgaat of aanvraagt.", ru: "Подготовьте файлы перед визитом или заявлением."),
                symbol: "folder",
                destination: .journeyDocuments
            )
        }
        .accessibilityIdentifier("place.relatedGuides.empty")
    }

    private var relatedGuidesFallbackSubtitle: String {
        localized(
            en: "Use search, official sources, or documents for the next step.",
            nl: "Gebruik zoeken, officiële bronnen of documenten voor de volgende stap.",
            ru: "Используйте поиск, официальные источники или документы для следующего шага."
        )
    }

    private func localized(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .russian: return ru
        case .dutch: return nl
        case .english: return en
        }
    }

    private func imageAsset(for place: NearbyPlace) -> AppImageAsset? {
        if let directAsset = directPlaceImageAsset(for: place) {
            return directAsset
        }
        if let tourismAsset = tourismImageAsset(for: place) {
            return tourismAsset
        }
        switch place.category {
        case .healthcare, .hospital, .huisarts, .pharmacy, .nightPharmacy:
            return ContentMediaRegistry.healthcareBasicsImage ?? ContentMediaRegistry.healthcarePharmacyImage
        case .municipality, .ind, .duo, .immigrationSupport, .expatCenter, .police:
            return ContentMediaRegistry.governmentBasicsImage ?? ContentMediaRegistry.municipalityCityHallImage
        case .uwv, .legalHelp:
            return ContentMediaRegistry.workImage ?? ContentMediaRegistry.governmentBasicsImage
        case .transport, .transportOffice, .bikeRepair:
            return ContentMediaRegistry.transportStationHero ?? ContentMediaRegistry.transportHero
        case .education, .library, .studentHelp:
            return ContentMediaRegistry.dailyCultureImage ?? ContentMediaRegistry.officialSourcesHero
        case .foodBank:
            return ContentMediaRegistry.foodImage ?? ContentMediaRegistry.marketsLocalLifeImage
        case .shelter:
            return ContentMediaRegistry.premiumHousingImage ?? ContentMediaRegistry.housingWonenImage
        case .communitySupport, .lgbtqSupport:
            return ContentMediaRegistry.dailyCultureImage ?? ContentMediaRegistry.marketsLocalLifeImage ?? ContentMediaRegistry.officialSourcesHero
        case .animalEmergency:
            return ContentMediaRegistry.emergencyImage
        }
    }

    private func directPlaceImageAsset(for place: NearbyPlace) -> AppImageAsset? {
        guard let imageURL = place.imageURL else { return nil }
        return AppImageAsset(
            id: "place-detail-\(place.saveKey)-image",
            url: imageURL,
            sourcePageURL: place.websiteURL,
            imageURL: imageURL,
            thumbnailURL: imageURL,
            title: place.localizedName(lang),
            description: place.localizedDescription(lang),
            sourceName: place.sourceLabel,
            sourceURL: place.websiteURL,
            license: nil,
            attribution: place.sourceLabel,
            width: nil,
            height: nil,
            type: .cardThumbnail,
            verified: place.isOfficialSource
        )
    }

    private func tourismImageAsset(for place: NearbyPlace) -> AppImageAsset? {
        let normalizedName = place.name.lowercased()
        if normalizedName.contains("canal") || normalizedName.contains("gracht") {
            return ContentMediaRegistry.leidenCanalsHero ?? ContentMediaRegistry.canalHousesHero
        }
        if normalizedName.contains("molen") || normalizedName.contains("windmill") || normalizedName.contains("valk") {
            return ContentMediaRegistry.cultureWindmillHero ?? ContentMediaRegistry.cultureWideHero
        }
        if normalizedName.contains("museum") || normalizedName.contains("rijksmuseum") || normalizedName.contains("lakenhal") || normalizedName.contains("oudheden") {
            return ContentMediaRegistry.cultureWideHero ?? ContentMediaRegistry.dailyCultureImage
        }
        if normalizedName.contains("hortus") || normalizedName.contains("botanic") || normalizedName.contains("park") {
            return ContentMediaRegistry.natureImage ?? ContentMediaRegistry.dailyCultureImage
        }
        if normalizedName.contains("burcht") || normalizedName.contains("castle") || normalizedName.contains("historic") {
            return ContentMediaRegistry.cultureWideHero ?? ContentMediaRegistry.mapImage
        }
        return nil
    }

    private func fallbackCategory(for category: PlaceCategory) -> PremiumImageFallbackCategory {
        switch category {
        case .healthcare, .hospital, .huisarts, .pharmacy, .nightPharmacy:
            return .healthcare
        case .municipality, .ind, .uwv, .duo, .immigrationSupport, .expatCenter, .police:
            return .government
        case .transport, .transportOffice, .bikeRepair:
            return .transport
        case .education, .library, .studentHelp:
            return .dutchA1A2
        case .legalHelp:
            return .documents
        case .foodBank, .communitySupport, .lgbtqSupport:
            return .integration
        case .shelter:
            return .housing
        case .animalEmergency:
            return .emergency
        }
    }

    private func accent(for category: PlaceCategory) -> Color {
        switch category {
        case .healthcare, .hospital, .huisarts, .pharmacy, .nightPharmacy:
            return AppColors.error
        case .municipality, .ind, .uwv, .duo, .immigrationSupport, .expatCenter:
            return AppColors.softBlue
        case .transport, .transportOffice, .bikeRepair:
            return AppColors.dutchOrange
        case .education, .library, .studentHelp:
            return AppColors.emerald
        case .legalHelp, .police:
            return AppColors.violet
        default:
            return AppColors.routeLine
        }
    }
}
