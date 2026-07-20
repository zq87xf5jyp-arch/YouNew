import SwiftUI

// MARK: - Business Partner Promo

struct HomeBusinessPartnerPromoCard: View {
    let language: AppLanguage
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        Group {
            if horizontalSizeClass == .regular && !dynamicTypeSize.isAccessibilitySize {
                wideLayout
            } else {
                compactLayout
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: minimumHeight, alignment: .leading)
        .background {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 15/255, green: 21/255, blue: 38/255),
                        Color(red: 11/255, green: 22/255, blue: 42/255),
                        Color(red: 18/255, green: 40/255, blue: 78/255)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                RadialGradient(
                    colors: [AppColors.cyanGlow.opacity(0.24), .clear],
                    center: .bottomTrailing,
                    startRadius: 8,
                    endRadius: 240
                )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            AppColors.cyanGlow.opacity(0.46),
                            AppColors.softBlue.opacity(0.20),
                            Color.white.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: AppColors.cyanGlow.opacity(0.10), radius: 18, x: 0, y: 8)
    }

    private var minimumHeight: CGFloat {
        if horizontalSizeClass == .regular && !dynamicTypeSize.isAccessibilitySize {
            return 216
        }
        return dynamicTypeSize.isAccessibilitySize ? 336 : 292
    }

    private var wideLayout: some View {
        HStack(alignment: .bottom, spacing: 18) {
            copy
                .frame(maxWidth: .infinity, alignment: .leading)

            artwork
                .frame(width: 190, height: 134)
        }
    }

    private var compactLayout: some View {
        VStack(alignment: .leading, spacing: 18) {
            copy

            HStack(alignment: .bottom) {
                Spacer(minLength: 24)
                artwork
                    .frame(
                        width: dynamicTypeSize.isAccessibilitySize ? 156 : 178,
                        height: dynamicTypeSize.isAccessibilitySize ? 112 : 128
                    )
            }
        }
    }

    private var copy: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(localizedText(en: "FOR BUSINESSES", nl: "VOOR BEDRIJVEN", ru: "ДЛЯ БИЗНЕСА"))
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.cyanGlow)
                .lineLimit(1)

            Text(localizedText(en: "Grow your business with YouNew", nl: "Groei uw bedrijf met YouNew", ru: "Развивайте свой бизнес вместе с YouNew"))
                .font(AppTypography.cardTitle)
                .foregroundStyle(Color.white)
                .lineLimit(2)
                .minimumScaleFactor(0.78)
                .fixedSize(horizontal: false, vertical: true)

            Text(localizedText(en: "Reach tourists, expats, students, and residents through city pages, map placement, and contextual discovery.", nl: "Bereik toeristen, expats, studenten en bewoners via stadspagina's, kaartplaatsing en contextuele ontdekking.", ru: "Привлекайте туристов, экспатов, студентов и жителей через страницы городов, карту и контекстное открытие сервисов."))
                .font(AppTypography.footnote)
                .foregroundStyle(Color.white.opacity(0.78))
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? 5 : 3)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                Text(localizedText(en: "Become a Partner", nl: "Partner worden", ru: "Стать партнером"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Image(systemName: "arrow.right")
                    .font(.system(size: 12, weight: .bold))
            }
            .font(AppTypography.captionStrong)
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(AppColors.softBlue, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .padding(.top, 2)
        }
    }

    private var artwork: some View {
        ZStack(alignment: .topTrailing) {
            Image("premium_home_work")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.08),
                            AppColors.navyDeep.opacity(0.38)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                )
                .accessibilityHidden(true)

            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppColors.softBlue, Color(red: 92/255, green: 197/255, blue: 255/255)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: AppColors.softBlue.opacity(0.35), radius: 8, x: 0, y: 4)
                .offset(x: 8, y: -10)
                .accessibilityHidden(true)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 0.8)
        )
        .overlay(alignment: .bottomLeading) {
            Image(systemName: "building.2.crop.circle.fill")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(AppColors.cyanGlow)
                .padding(6)
                .background(AppColors.navyDeep.opacity(0.72), in: Circle())
                .padding(8)
                .accessibilityHidden(true)
        }
    }

    private func localizedText(en: String, nl: String, ru: String) -> String {
        switch language {
        case .russian: return ru
        case .dutch: return nl
        case .english: return en
        }
    }
}

// MARK: - Local Partners

struct HomeLocalPartnersSection: View {
    let partners: ArraySlice<LocalPartner>
    let language: AppLanguage
    var totalCount: Int? = nil
    var accessibilityIdentifier: String = "home.localPartners"

    @ViewBuilder
    var body: some View {
        if !partners.isEmpty {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                header

                NavigationLink(value: AppDestination.localPartners) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(localizedText(en: "Top verified partners", nl: "Top geverifieerde partners", ru: "Лучшие проверенные партнёры"))
                            .font(AppTypography.footnote)
                            .foregroundStyle(AppColors.textSecondary)

                        HStack(spacing: 8) {
                            ForEach(partners.prefix(3)) { partner in
                                partnerPreview(partner)
                            }
                        }

                        HStack {
                            Text(localizedText(
                                en: "\(totalCount ?? partners.count) verified in this city",
                                nl: "\(totalCount ?? partners.count) geverifieerd in deze stad",
                                ru: "Проверено в городе: \(totalCount ?? partners.count)"
                            ))
                            .font(AppTypography.captionStrong)
                            .foregroundStyle(AppColors.warning)
                            Spacer()
                            Label(localizedText(en: "View partners", nl: "Bekijk partners", ru: "Открыть партнёров"), systemImage: "arrow.right")
                                .font(AppTypography.captionStrong)
                                .foregroundStyle(AppColors.textPrimary)
                        }
                    }
                    .padding(15)
                    .background(
                        LinearGradient(
                            colors: [AppColors.cardElevated.opacity(0.96), AppColors.warning.opacity(0.10), AppColors.navyDeep.opacity(0.92)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                    )
                    .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(AppColors.warning.opacity(0.24), lineWidth: 0.8))
                }
                .buttonStyle(AppPressableCardButtonStyle())
                .accessibilityIdentifier(accessibilityIdentifier)
            }
        }
    }

    private var header: some View {
        HStack {
            Text(localizedText(en: "Local Partners", nl: "Lokale partners", ru: "Local Partners"))
                .font(AppTypography.cardTitle)
                .foregroundStyle(AppColors.textPrimary)

            Spacer()

            NavigationLink(value: AppDestination.localPartners) {
                Text(localizedText(en: "See all", nl: "Alles", ru: "Показать все"))
                    .font(AppTypography.captionStrong)
                    .foregroundStyle(AppColors.accent)
            }
            .accessibilityIdentifier("\(accessibilityIdentifier).seeAll")
        }
    }

    private func partnerPreview(_ partner: LocalPartner) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            partnerThumbnail(partner)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            Text(partner.name)
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2)
            Text(partner.category.title(language))
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, minHeight: 130, alignment: .topLeading)
        .padding(9)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    @ViewBuilder
    private func partnerThumbnail(_ partner: LocalPartner) -> some View {
        let asset = partner.media.thumbnail
        CityImageView(
            urlString: asset.url.absoluteString,
            height: 52,
            fallbackColor: partnerAccent(partner).opacity(0.72),
            renderRole: .thumbnail,
            targetPixelWidth: 320,
            showsReadableOverlay: false
        )
        .accessibilityLabel(asset.altText)
    }

    private func partnerThumbnailFallback(_ partner: LocalPartner) -> some View {
        LinearGradient(
            colors: [partnerAccent(partner).opacity(0.72), AppColors.navyDeep],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            Image(systemName: partner.category.symbol)
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
        }
    }

    private func partnerAccent(_ partner: LocalPartner) -> Color {
        switch partner.category {
        case .stay: return AppColors.softBlue
        case .foodDrinks: return AppColors.dutchOrange
        case .legal: return AppColors.violet
        case .finance: return AppColors.success
        case .healthcare: return AppColors.emerald
        case .education: return AppColors.cyanGlow
        case .jobs: return AppColors.gradWork[0]
        case .home: return AppColors.gradHousing[0]
        case .transport: return AppColors.routeLine
        case .shopping: return AppColors.gradDocs[0]
        case .leisure: return AppColors.orangeGlow
        }
    }

    private func localizedText(en: String, nl: String, ru: String) -> String {
        switch language {
        case .russian: return ru
        case .dutch: return nl
        case .english: return en
        }
    }
}

private struct HomeLocalPartnerCard: View {
    let partner: LocalPartner
    let language: AppLanguage
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var isHighlighted: Bool {
        partner.plan == .premium || partner.plan == .aiFeatured || partner.plan == .featured
    }

    private var cardWidth: CGFloat {
        dynamicTypeSize.isAccessibilitySize ? 196 : 166
    }

    private var visualHeight: CGFloat {
        dynamicTypeSize.isAccessibilitySize ? 112 : 96
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            partnerVisual

            VStack(alignment: .leading, spacing: 4) {
                Text(partner.name)
                    .font(AppTypography.footnoteStrong)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
                    .fixedSize(horizontal: false, vertical: true)

                Text(partner.subcategory)
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .frame(width: cardWidth, alignment: .topLeading)
        .frame(minHeight: dynamicTypeSize.isAccessibilitySize ? 206 : 178, alignment: .topLeading)
        .background(AppColors.cardElevated.opacity(0.86), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(isHighlighted ? AppColors.warning.opacity(0.30) : Color.white.opacity(0.08), lineWidth: 0.8)
        )
        .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private var partnerVisual: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [
                    AppColors.chipBackground.opacity(0.96),
                    partnerAccent.opacity(0.20)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image(systemName: partner.category.symbol)
                .font(.system(size: 25, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(
                    LinearGradient(
                        colors: [partnerAccent, partnerAccent.opacity(0.72)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                )
                .shadow(color: partnerAccent.opacity(0.24), radius: 10, x: 0, y: 5)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding(10)

            if isHighlighted {
                Text(partner.plan.label(language))
                    .font(AppTypography.metadata)
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(AppColors.warning, in: Capsule())
                    .padding(8)
                    .accessibilityHidden(true)
            }
        }
        .frame(width: cardWidth - 20, height: visualHeight)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var partnerAccent: Color {
        switch partner.category {
        case .healthcare: return AppColors.emerald
        case .legal: return AppColors.violet
        case .stay: return AppColors.softBlue
        case .foodDrinks: return AppColors.dutchOrange
        case .transport: return AppColors.routeLine
        case .education: return AppColors.cyanGlow
        case .finance: return AppColors.success
        case .jobs: return AppColors.gradWork[0]
        case .home: return AppColors.gradHousing[0]
        case .shopping: return AppColors.gradDocs[0]
        case .leisure: return AppColors.orangeGlow
        }
    }
}
