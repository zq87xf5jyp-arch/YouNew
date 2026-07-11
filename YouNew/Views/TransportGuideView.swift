import SwiftUI

struct TransportGuideView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.openURL) private var openURL

    private let guide = TransportGuideData.guide
    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 920) {
                LazyVStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    headerCard
                    quickCardsSection
                    visualReferenceSection
                    sectionsList
                    sourceSection
                    updatedSection
                    Color.clear.frame(height: AppSpacing.tabBarScrollReserve)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, AppSpacing.medium)
            }
        }
        .appSceneBackground(.map)
        .navigationTitle(guide.title.value(lang))
        .nlNavigationInline()
    }

    private var headerCard: some View {
        ZStack(alignment: .bottomLeading) {
            transportHeroPhotoLayer

            LinearGradient(
                colors: [
                    Color.black.opacity(0.10),
                    AppColors.navyDeep.opacity(0.28),
                    AppColors.navyDeep.opacity(0.88)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: "tram.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(AppColors.dutchOrange)
                    .frame(width: 48, height: 48)
                    .background(AppColors.dutchOrange.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))

                Text(guide.title.value(lang))
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)

                Text(guide.summary.value(lang))
                    .font(AppTypography.body)
                    .foregroundStyle(Color.white.opacity(0.82))
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(18)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 238)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .clipped()
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        }
        .overlay(alignment: .bottomTrailing) {
            HStack(spacing: 6) {
                transportMiniBadge("NS")
                transportMiniBadge("OVpay")
                transportMiniBadge("9292")
            }
            .padding(14)
        }
    }

    private var transportHeroPhotoLayer: some View {
        AppContentImageView(
            asset: ContentMediaRegistry.transportStationHero ?? ContentMediaRegistry.transportHero,
            language: lang,
            mode: .fill,
            accent: AppColors.cyanGlow,
            aspectRatio: nil,
            cornerRadius: 24,
            showsCaption: false
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .clipped()
        .accessibilityHidden(true)
    }

    private var quickCardsSection: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 10)], spacing: 10) {
            ForEach(guide.quickCards) { card in
                quickCard(card)
            }
        }
    }

    private var visualReferenceSection: some View {
        let visuals = transportVisualCards

        return VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(
                title: localized("Transport visuals", "Vervoerbeelden", "Визуальный транспорт"),
                subtitle: localized(
                    "Recognize the main systems newcomers actually see: NS, OVpay, 9292, metro, bus, and stations.",
                    "Herken de belangrijkste systemen: NS, OVpay, 9292, metro, bus en stations.",
                    "Узнавайте основные системы: NS, OVpay, 9292, метро, автобус и станции."
                )
            )

            LazyVGrid(columns: transportVisualGridColumns, spacing: AppSpacing.small) {
                ForEach(visuals) { visual in
                    transportVisualCard(visual)
                }
            }
        }
    }

    private var transportVisualGridColumns: [GridItem] {
        [
            GridItem(.flexible(minimum: 0), spacing: AppSpacing.small),
            GridItem(.flexible(minimum: 0), spacing: AppSpacing.small)
        ]
    }

    private var transportVisualCards: [TransportVisualCardModel] {
        [
            TransportVisualCardModel(
                id: "ns",
                badge: "NS",
                symbol: "train.side.front.car",
                title: localized("NS trains", "NS-treinen", "Поезда NS"),
                subtitle: localized("Intercity and Sprinter trains for city-to-city travel.", "Intercity en Sprinter voor reizen tussen steden.", "Intercity и Sprinter для поездок между городами."),
                artwork: .station,
                accent: AppColors.cyanGlow
            ),
            TransportVisualCardModel(
                id: "ovpay",
                badge: "OVpay",
                symbol: "wave.3.right.circle.fill",
                title: localized("OVpay", "OVpay", "OVpay"),
                subtitle: localized("Use the same card or device for check-in and check-out.", "Gebruik dezelfde kaart of apparaat voor in- en uitchecken.", "Используйте одну карту или устройство для входа и выхода."),
                artwork: .ovCard,
                accent: AppColors.dutchOrange
            ),
            TransportVisualCardModel(
                id: "9292",
                badge: "9292",
                symbol: "map.fill",
                title: localized("9292 planner", "9292-planner", "Планировщик 9292"),
                subtitle: localized("Plan routes across train, tram, metro, bus, and walking.", "Plan routes met trein, tram, metro, bus en lopen.", "Планируйте поездки поездом, трамваем, метро, автобусом и пешком."),
                artwork: .network,
                accent: AppColors.success
            ),
            TransportVisualCardModel(
                id: "metro",
                badge: "Metro",
                symbol: "tram.fill",
                title: localized("Metro", "Metro", "Метро"),
                subtitle: localized("Useful in Amsterdam, Rotterdam, The Hague region, and nearby suburbs.", "Handig in Amsterdam, Rotterdam, regio Den Haag en omliggende plaatsen.", "Удобно в Amsterdam, Rotterdam, районе Den Haag и пригородах."),
                artwork: .network,
                accent: AppColors.softBlue
            ),
            TransportVisualCardModel(
                id: "bus",
                badge: "Bus",
                symbol: "bus.fill",
                title: localized("Bus", "Bus", "Автобус"),
                subtitle: localized("Regional buses connect smaller towns, suburbs, hospitals, and stations.", "Streekbussen verbinden dorpen, wijken, ziekenhuizen en stations.", "Региональные автобусы соединяют города, районы, больницы и станции."),
                artwork: .network,
                accent: AppColors.violet
            ),
            TransportVisualCardModel(
                id: "station",
                badge: "Station",
                symbol: "building.columns.fill",
                title: localized("Station", "Station", "Станция"),
                subtitle: localized("Check platform, delay, transfer time, and check-in gates.", "Controleer perron, vertraging, overstaptijd en poortjes.", "Проверяйте платформу, задержку, пересадку и турникеты."),
                artwork: .station,
                accent: AppColors.success
            )
        ]
    }

    private func transportVisualCard(_ visual: TransportVisualCardModel) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            transportIdentityVisual(visual)

            VStack(alignment: .leading, spacing: 4) {
                Text(visual.title)
                    .font(.system(.caption, design: .rounded).weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
                    .fixedSize(horizontal: false, vertical: true)

                Text(visual.subtitle)
                    .font(.system(.caption2, design: .rounded).weight(.medium))
                    .foregroundStyle(AppColors.textTertiary)
                    .lineLimit(3)
                    .minimumScaleFactor(0.82)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .appGlassCardStyle(padding: 10, cornerRadius: 18, accent: visual.accent)
        .frame(maxWidth: .infinity, minHeight: 206, maxHeight: 206, alignment: .topLeading)
        .clipped()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(visual.title). \(visual.subtitle)")
    }

    @ViewBuilder
    private func transportIdentityVisual(_ visual: TransportVisualCardModel) -> some View {
        ZStack(alignment: .bottomLeading) {
            TransportGuideArtwork(kind: visual.artwork, accent: visual.accent, compact: true)

            HStack(spacing: 7) {
                Image(systemName: visual.symbol)
                    .font(.system(size: 13, weight: .black))
                Text(visual.badge)
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(visual.accent.opacity(0.88))
            .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
            .padding(8)
        }
        .frame(height: 82)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.14), lineWidth: 0.8)
        }
    }

    private func transportMiniBadge(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .black, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(AppColors.navyDeep.opacity(0.58))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.16), lineWidth: 0.8))
    }

    private func quickCard(_ card: TransportQuickCard) -> some View {
        Button {
            if let sourceId = card.sourceId, let source = TransportGuideData.source(id: sourceId) {
                openTransportSource(source.url)
            }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: card.symbol)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(quickCardAccent(card))
                    .frame(width: 38, height: 38)
                    .background(quickCardAccent(card).opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                Text(card.title.value(lang))
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)

                Text(card.subtitle.value(lang))
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, minHeight: 128, alignment: .topLeading)
            .padding(14)
            .premiumNetherlandsCard(cornerRadius: 18, accent: quickCardAccent(card))
        }
        .buttonStyle(AppPressableCardButtonStyle())
        .accessibilityLabel(quickCardAccessibility(card))
        .disabled(card.sourceId == nil)
    }

    private var sectionsList: some View {
        return VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: localized("Main transport types", "Vervoerstypen", "Основные виды транспорта"))

            ForEach(guide.sections) { section in
                transportSectionCard(section)
            }
        }
    }

    private func transportSectionCard(_ section: TransportGuideSection) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: section.symbol)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(sectionAccent(section))
                    .frame(width: 42, height: 42)
                    .background(sectionAccent(section).opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))

                VStack(alignment: .leading, spacing: 5) {
                    Text(section.title.value(lang))
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(2)

                    Text(section.summary.value(lang))
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            ForEach(section.points, id: \.self) { point in
                HStack(alignment: .top, spacing: 8) {
                    Circle()
                        .fill(sectionAccent(section))
                        .frame(width: 6, height: 6)
                        .padding(.top, 7)
                    Text(point.value(lang))
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            transportDetailGroup(
                title: localized("Cost and payment", "Kosten en betalen", "Стоимость и оплата"),
                symbol: "banknote.fill",
                accent: AppColors.success,
                items: section.costNotes
            )

            transportDetailGroup(
                title: localized("Practical tips", "Praktische tips", "Практические советы"),
                symbol: "lightbulb.fill",
                accent: AppColors.dutchOrange,
                items: section.practicalTips
            )

            transportDetailGroup(
                title: localized("Hints", "Hints", "Подсказки"),
                symbol: "text.bubble.fill",
                accent: AppColors.cyanGlow,
                items: section.hints
            )
        }
        .premiumNetherlandsCard(cornerRadius: 20, accent: sectionAccent(section))
    }

    private func transportDetailGroup(
        title: String,
        symbol: String,
        accent: Color,
        items: [LocalizedInfoText]
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 7) {
                Image(systemName: symbol)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(accent)
                Text(title)
                    .font(AppTypography.captionStrong)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
            }

            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(accent.opacity(0.72))
                        .frame(width: 5, height: 5)
                        .padding(.top, 7)
                    Text(item.value(lang))
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(accent.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var sourceSection: some View {
        let validSources = guide.sources.compactMap { source -> (TransportGuideSource, URL)? in
            guard let safeURL = AppURL.validatedWebURL(source.url) else { return nil }
            return (source, safeURL)
        }

        return VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: localized("Official sources", "Officiële bronnen", "Официальные источники"))

            if validSources.isEmpty {
                transportSourceFallbackRows
            } else {
                ForEach(validSources, id: \.0.id) { source, safeURL in
                    transportSourceButton(source: source, safeURL: safeURL)
                }
            }
        }
        .accessibilityIdentifier("transport.sources.dashboard")
    }

    private func openTransportSource(_ url: URL) {
        guard let safeURL = AppURL.validatedWebURL(url) else { return }
        openURL(safeURL)
    }

    private func transportSourceButton(source: TransportGuideSource, safeURL: URL) -> some View {
        Button {
            openURL(safeURL)
        } label: {
            HStack(spacing: AppSpacing.medium) {
                Image(systemName: "link.circle.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(AppColors.success)
                    .frame(width: 42, height: 42)
                    .background(AppColors.success.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(source.title)
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(2)
                    Text("\(source.institution) · \(source.language)")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                    Text(sourceTrustText(source))
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.success)
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                Image(systemName: AppIcons.external)
                    .foregroundStyle(AppColors.textTertiary)
            }
            .frame(minHeight: 58)
            .appCardStyle()
        }
        .buttonStyle(.plain)
        .accessibilityLabel(sourceAccessibility(source))
    }

    private var transportSourceFallbackRows: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            transportSourceFallbackRow(
                title: localized("Official sources", "Officiële bronnen", "Официальные источники"),
                subtitle: localized("Verify transport rules before travelling.", "Controleer vervoersregels voordat je reist.", "Проверьте правила транспорта перед поездкой."),
                icon: AppIcons.officialSource,
                destination: .officialSources
            )

            transportSourceFallbackRow(
                title: localized("Nearby transport", "Vervoer in de buurt", "Транспорт рядом"),
                subtitle: localized("Find stations, OV points, and city transport.", "Vind stations, OV-punten en stadsvervoer.", "Найти станции, OV-точки и городской транспорт."),
                icon: "tram.fill",
                destination: .mapFocus(.category(.transport))
            )

            transportSourceFallbackRow(
                title: localized("Search", "Zoeken", "Поиск"),
                subtitle: localized("Search transport answers and documents.", "Zoek vervoersantwoorden en documenten.", "Искать ответы и документы про транспорт."),
                icon: "magnifyingglass",
                destination: .searchList
            )
        }
        .accessibilityIdentifier("transport.sources.empty")
    }

    private func transportSourceFallbackRow(title: String, subtitle: String, icon: String, destination: AppDestination) -> some View {
        NavigationLink(value: destination) {
            HStack(spacing: AppSpacing.medium) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(AppColors.success)
                    .frame(width: 42, height: 42)
                    .background(AppColors.success.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(2)
                    Text(subtitle)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .foregroundStyle(AppColors.textTertiary)
            }
            .frame(minHeight: 58)
            .appCardStyle()
        }
        .buttonStyle(.plain)
    }

    private var updatedSection: some View {
        HStack(spacing: 8) {
            Image(systemName: "calendar.badge.checkmark")
                .foregroundStyle(AppColors.textTertiary)
            Text("\(localized("Last updated", "Laatst bijgewerkt", "Последнее обновление")): \(guide.updatedAt)")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .appCardStyle()
    }

    private func sourceTrustText(_ source: TransportGuideSource) -> String {
        let label = localized("Official source", "Officiële bron", "Официальный источник")
        return "\(label) · \(source.retrievedAt)"
    }

    private func quickCardAccessibility(_ card: TransportQuickCard) -> String {
        switch card.id {
        case "ns": return localized("Open NS official source", "Open officiële NS-bron", "Открыть официальный сайт NS")
        case "ovpay": return localized("Open OVpay official source", "Open officiële OVpay-bron", "Открыть официальный сайт OVpay")
        case "planner": return localized("Open 9292 planner", "Open 9292 planner", "Открыть планировщик 9292")
        default: return localized("Open transport guide", "Open vervoersgids", "Открыть гид по транспорту")
        }
    }

    private func sourceAccessibility(_ source: TransportGuideSource) -> String {
        if source.id == "source.ns" {
            return localized("Open NS official source", "Open officiële NS-bron", "Открыть официальный сайт NS")
        }
        if source.id == "source.9292" {
            return localized("Open 9292 planner", "Open 9292 planner", "Открыть планировщик 9292")
        }
        if source.id == "source.ovpay" {
            return localized("Open OVpay official source", "Open officiële OVpay-bron", "Открыть официальный сайт OVpay")
        }
        return "\(localized("Open official source", "Open officiële bron", "Открыть официальный источник")): \(source.title)"
    }

    private func quickCardAccent(_ card: TransportQuickCard) -> Color {
        switch card.id {
        case "ns": return AppColors.cyanGlow
        case "ovpay": return AppColors.dutchOrange
        case "planner": return AppColors.success
        default: return AppColors.softBlue
        }
    }

    private func sectionAccent(_ section: TransportGuideSection) -> Color {
        switch section.id {
        case "transport.trains": return AppColors.cyanGlow
        case "transport.busTramMetro": return AppColors.dutchOrange
        case "transport.ovChipkaart", "transport.ovpay": return AppColors.success
        case "transport.bikes": return AppColors.emerald
        case "transport.airports": return AppColors.softBlue
        case "transport.accessibility": return AppColors.violet
        default: return AppColors.cyanGlow
        }
    }

    private func localized(_ en: String, _ nl: String, _ ru: String) -> String {
        switch lang {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }
}

private struct TransportVisualCardModel: Identifiable {
    let id: String
    let badge: String
    let symbol: String
    let title: String
    let subtitle: String
    let artwork: TransportGuideArtwork.Kind
    let accent: Color
}

private struct TransportGuideArtwork: View {
    enum Kind {
        case network
        case station
        case ovCard
        case bikeLane
    }

    let kind: Kind
    let accent: Color
    var compact = false

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack {
                baseBackground
                subtleMapLines(in: size)

                switch kind {
                case .network:
                    networkScene(in: size)
                case .station:
                    stationScene(in: size)
                case .ovCard:
                    ovCardScene(in: size)
                case .bikeLane:
                    bikeLaneScene(in: size)
                }

                LinearGradient(
                    colors: [Color.white.opacity(0.08), Color.clear, AppSurface.base.opacity(0.24)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .allowsHitTesting(false)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .accessibilityHidden(true)
    }

    private var baseBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 7 / 255, green: 16 / 255, blue: 32 / 255),
                    accent.opacity(0.22),
                    Color(red: 10 / 255, green: 20 / 255, blue: 38 / 255)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(colors: [accent.opacity(0.34), .clear], center: .topLeading, startRadius: 0, endRadius: 240)
            RadialGradient(colors: [AppColors.dutchOrange.opacity(0.18), .clear], center: .bottomTrailing, startRadius: 0, endRadius: 260)
        }
    }

    private func subtleMapLines(in size: CGSize) -> some View {
        Canvas { context, canvasSize in
            for index in 0..<7 {
                let y = canvasSize.height * (0.14 + CGFloat(index) * 0.12)
                var path = Path()
                path.move(to: CGPoint(x: -canvasSize.width * 0.08, y: y))
                path.addCurve(
                    to: CGPoint(x: canvasSize.width * 1.08, y: y + CGFloat(index % 2 == 0 ? 18 : -14)),
                    control1: CGPoint(x: canvasSize.width * 0.22, y: y - 24),
                    control2: CGPoint(x: canvasSize.width * 0.72, y: y + 26)
                )
                context.stroke(path, with: .color(Color.white.opacity(0.045)), style: StrokeStyle(lineWidth: 0.8, lineCap: .round, dash: [8, 14]))
            }
        }
        .frame(width: size.width, height: size.height)
    }

    private func networkScene(in size: CGSize) -> some View {
        ZStack {
            routePath(in: size)
            vehicleBadge(symbol: "tram.fill", color: AppColors.dutchOrange, scale: compact ? 0.74 : 1.0)
                .position(x: size.width * 0.30, y: size.height * 0.42)
            vehicleBadge(symbol: "train.side.front.car", color: AppColors.cyanGlow, scale: compact ? 0.82 : 1.08)
                .position(x: size.width * 0.60, y: size.height * 0.30)
            vehicleBadge(symbol: "bicycle", color: AppColors.success, scale: compact ? 0.70 : 0.92)
                .position(x: size.width * 0.74, y: size.height * 0.64)
        }
    }

    private func stationScene(in size: CGSize) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: compact ? 12 : 20, style: .continuous)
                .fill(Color.white.opacity(0.10))
                .frame(width: size.width * 0.76, height: size.height * 0.42)
                .position(x: size.width * 0.50, y: size.height * 0.44)

            ForEach(0..<4, id: \.self) { index in
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(Color.white.opacity(0.22))
                    .frame(width: size.width * 0.10, height: size.height * 0.22)
                    .position(x: size.width * (0.34 + CGFloat(index) * 0.105), y: size.height * 0.43)
            }

            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(AppColors.cyanGlow.opacity(0.65))
                .frame(width: size.width * 0.66, height: 4)
                .position(x: size.width * 0.50, y: size.height * 0.67)

            Image(systemName: "train.side.front.car")
                .font(.system(size: compact ? 28 : 42, weight: .black))
                .foregroundStyle(.white)
                .frame(width: compact ? 52 : 78, height: compact ? 52 : 78)
                .background(AppColors.cyanGlow.opacity(0.24))
                .clipShape(RoundedRectangle(cornerRadius: compact ? 16 : 24, style: .continuous))
                .position(x: size.width * 0.26, y: size.height * 0.66)
        }
    }

    private func ovCardScene(in size: CGSize) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: compact ? 10 : 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.22), AppColors.dutchOrange.opacity(0.42)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size.width * 0.58, height: size.height * 0.38)
                .rotationEffect(.degrees(-8))
                .position(x: size.width * 0.50, y: size.height * 0.48)

            Image(systemName: "wave.3.right.circle.fill")
                .font(.system(size: compact ? 20 : 36, weight: .bold))
                .foregroundStyle(.white)
                .position(x: size.width * 0.39, y: size.height * 0.45)

            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(Color.white.opacity(0.34))
                .frame(width: size.width * 0.20, height: compact ? 4 : 7)
                .position(x: size.width * 0.58, y: size.height * 0.43)

            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(Color.white.opacity(0.26))
                .frame(width: size.width * 0.30, height: compact ? 4 : 7)
                .position(x: size.width * 0.62, y: size.height * 0.54)
        }
    }

    private func bikeLaneScene(in size: CGSize) -> some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: size.width * 0.12, y: size.height * 0.76))
                path.addCurve(
                    to: CGPoint(x: size.width * 0.90, y: size.height * 0.32),
                    control1: CGPoint(x: size.width * 0.30, y: size.height * 0.42),
                    control2: CGPoint(x: size.width * 0.62, y: size.height * 0.86)
                )
            }
            .stroke(AppColors.success.opacity(0.72), style: StrokeStyle(lineWidth: compact ? 8 : 13, lineCap: .round))

            Path { path in
                path.move(to: CGPoint(x: size.width * 0.12, y: size.height * 0.76))
                path.addCurve(
                    to: CGPoint(x: size.width * 0.90, y: size.height * 0.32),
                    control1: CGPoint(x: size.width * 0.30, y: size.height * 0.42),
                    control2: CGPoint(x: size.width * 0.62, y: size.height * 0.86)
                )
            }
            .stroke(Color.white.opacity(0.34), style: StrokeStyle(lineWidth: 1.2, lineCap: .round, dash: [8, 11]))

            vehicleBadge(symbol: "bicycle", color: AppColors.success, scale: compact ? 0.78 : 1.1)
                .position(x: size.width * 0.42, y: size.height * 0.56)

            vehicleBadge(symbol: "figure.walk", color: AppColors.cyanGlow, scale: compact ? 0.62 : 0.82)
                .position(x: size.width * 0.72, y: size.height * 0.38)
        }
    }

    private func routePath(in size: CGSize) -> some View {
        Canvas { context, canvasSize in
            var path = Path()
            path.move(to: CGPoint(x: canvasSize.width * 0.14, y: canvasSize.height * 0.64))
            path.addCurve(
                to: CGPoint(x: canvasSize.width * 0.86, y: canvasSize.height * 0.34),
                control1: CGPoint(x: canvasSize.width * 0.30, y: canvasSize.height * 0.22),
                control2: CGPoint(x: canvasSize.width * 0.62, y: canvasSize.height * 0.76)
            )
            context.stroke(path, with: .color(Color.white.opacity(0.30)), style: StrokeStyle(lineWidth: compact ? 3 : 5, lineCap: .round, dash: [12, 12]))
        }
        .frame(width: size.width, height: size.height)
    }

    private func vehicleBadge(symbol: String, color: Color, scale: CGFloat) -> some View {
        Image(systemName: symbol)
            .font(.system(size: 28 * scale, weight: .black))
            .foregroundStyle(.white)
            .frame(width: 58 * scale, height: 58 * scale)
            .background(color.opacity(0.28))
            .clipShape(RoundedRectangle(cornerRadius: 18 * scale, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18 * scale, style: .continuous)
                    .stroke(Color.white.opacity(0.18), lineWidth: 0.8)
            }
            .shadow(color: color.opacity(0.30), radius: 14 * scale, y: 7 * scale)
    }
}

private struct TransportRouteVisual: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(
                    colors: [AppColors.cyanGlow.opacity(0.20), AppColors.dutchOrange.opacity(0.12), Color.clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Canvas { context, size in
                    var train = Path()
                    train.move(to: CGPoint(x: size.width * 0.05, y: size.height * 0.30))
                    train.addCurve(
                        to: CGPoint(x: size.width * 0.92, y: size.height * 0.24),
                        control1: CGPoint(x: size.width * 0.30, y: size.height * 0.08),
                        control2: CGPoint(x: size.width * 0.62, y: size.height * 0.48)
                    )
                    context.stroke(train, with: .color(AppColors.cyanGlow.opacity(0.26)), style: StrokeStyle(lineWidth: 1.4, lineCap: .round))

                    var city = Path()
                    city.move(to: CGPoint(x: size.width * 0.18, y: size.height * 0.70))
                    city.addLine(to: CGPoint(x: size.width * 0.44, y: size.height * 0.48))
                    city.addLine(to: CGPoint(x: size.width * 0.75, y: size.height * 0.62))
                    city.addLine(to: CGPoint(x: size.width * 0.96, y: size.height * 0.42))
                    context.stroke(city, with: .color(AppColors.dutchOrange.opacity(0.24)), style: StrokeStyle(lineWidth: 1.2, lineCap: .round, lineJoin: .round))
                }

                node(proxy, x: 0.24, y: 0.70, color: AppColors.dutchOrange)
                node(proxy, x: 0.52, y: 0.46, color: AppColors.cyanGlow)
                node(proxy, x: 0.78, y: 0.58, color: AppColors.success)
            }
        }
        .accessibilityHidden(true)
    }

    private func node(_ proxy: GeometryProxy, x: CGFloat, y: CGFloat, color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .shadow(color: color.opacity(0.7), radius: 10)
            .position(x: proxy.size.width * x, y: proxy.size.height * y)
    }
}
