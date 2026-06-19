import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

#if os(macOS)
private let cityDetailBackButtonPlacement: ToolbarItemPlacement = .navigation
#else
private let cityDetailBackButtonPlacement: ToolbarItemPlacement = .navigationBarLeading
#endif

#if !canImport(UIKit)
struct CityImageView: View {
    let urlString: String?
    let height: CGFloat
    var placeId: String? = nil
    var cityName: String = ""
    var fallbackColor: Color = Color(hex: "#142A3E")
    var fallbackURLStrings: [String] = []
    var debugContext: ImageDebugContext? = nil
    var targetPixelWidth: CGFloat? = nil

    private var imageURL: URL? {
        let candidates = ([urlString] + fallbackURLStrings)
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }

        return candidates.lazy
            .filter { !$0.isEmpty }
            .compactMap(URL.init(string:))
            .first
    }

    var body: some View {
        ZStack {
            if let imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .empty:
                        fallback
                            .overlay(Color.white.opacity(0.035))
                    case .failure:
                        fallback
                    @unknown default:
                        fallback
                    }
                }
            } else {
                fallback
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipped()
    }

    private var fallback: some View {
        ZStack {
            LinearGradient(
                colors: [
                    fallbackColor.opacity(0.95),
                    Color(hex: "#050914").opacity(0.96)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 8) {
                Circle()
                    .fill(.white.opacity(0.10))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Text(String(cityName.prefix(1)))
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(.white.opacity(0.62))
                    )

                if !cityName.isEmpty {
                    Text(cityName)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.54))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
            }
        }
    }
}
#endif

struct CityFlagView: View {
    let flag: CityFlag
    let width: CGFloat
    let height: CGFloat
    let showLabel: Bool

    var body: some View {
        VStack(spacing: 4) {
            VStack(spacing: 0) {
                ForEach(Array(flag.svgStripes.enumerated()), id: \.offset) { _, stripe in
                    Color(hex: stripe.color)
                        .frame(height: height * stripe.heightFraction)
                }
            }
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
            .saturation(1.08)
            .contrast(1.04)
            .opacity(1)
            .overlay(
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .strokeBorder(.white.opacity(0.58), lineWidth: 0.75)
            )
            .shadow(color: .black.opacity(0.56), radius: 5, y: 2)

            if showLabel {
                Text(flag.description)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.white.opacity(0.45))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: width + 20)
            }
        }
    }
}

struct CityOfficialFlagView: View {
    let city: NLCity
    let width: CGFloat
    let height: CGFloat
    var showLabel: Bool = false

    var body: some View {
        VStack(spacing: 4) {
            if VisualAssetHelper.exists(assetName) {
                Image(assetName)
                    .resizable()
                    .scaledToFit()
                    .padding(1)
                    .frame(width: width, height: height)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .strokeBorder(.white.opacity(0.58), lineWidth: 0.75)
                    )
                    .shadow(color: .black.opacity(0.56), radius: 5, y: 2)
            } else {
                CityFlagView(flag: city.flag, width: width, height: height, showLabel: false)
            }

            if showLabel {
                Text(city.flag.description)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.white.opacity(0.45))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: width + 20)
            }
        }
    }

    private var assetName: String {
        let normalized = city.id
            .lowercased()
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: " ", with: "_")
        return "city_\(normalized)_flag"
    }
}

struct NetherlandsCityDetailView: View {
    let city: NLCity
    @State private var selectedTab = 0
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.dismiss) private var dismiss
    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                hero

                CityTabSelector(
                    selected: $selectedTab,
                    tabs: [
                        cityDetailText(.overview, lang),
                        cityDetailText(.history, lang),
                        cityDetailText(.places, lang),
                        cityDetailText(.life, lang)
                    ]
                )
                .padding(.vertical, 16)

                Group {
                    switch selectedTab {
                    case 0:
                        CityOverviewTab(city: city, lang: lang)
                    case 1:
                        CityHistoryTab(city: city, lang: lang)
                    case 2:
                        CityAttractionsTab(city: city, lang: lang)
                    case 3:
                        CityLivingTab(city: city, lang: lang)
                    default:
                        EmptyView()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)

                Color.clear
                    .frame(height: AppSpacing.tabBarScrollReserveCity)
            }
        }
        .background(Color(hex: "#06080F"))
        .ignoresSafeArea(edges: .top)
        .accessibilityIdentifier("city.detail.\(city.id)")
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: cityDetailBackButtonPlacement) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text(cityDetailText(.back, lang))
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                }
            }
        }
    }

    private var hero: some View {
        let resolvedImage = CanonicalPlaceImageResolver.resolveCityHero(city: city)
        return ZStack(alignment: .bottom) {
            CityImageView(
                urlString: resolvedImage.urlString,
                height: 320,
                placeId: city.placeId,
                cityName: city.name,
                fallbackColor: Color(hex: city.heroColor),
                fallbackURLStrings: resolvedImage.fallbackURLStrings,
                debugContext: resolvedImage.debugContext(
                    screen: "City detail hero",
                    entityType: "city",
                    entityName: city.name
                )
            )

            LinearGradient(
                stops: [
                    .init(color: Color(hex: "#06080F").opacity(0.54), location: 0.00),
                    .init(color: Color(hex: "#06080F").opacity(0.12), location: 0.28),
                    .init(color: .clear, location: 0.42),
                    .init(color: Color(hex: "#06080F").opacity(0.60), location: 0.62),
                    .init(color: Color(hex: "#06080F").opacity(0.90), location: 0.80),
                    .init(color: Color(hex: "#06080F"), location: 0.92)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 8) {
                Text(city.province.uppercased())
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "#2DD4BF"))
                    .tracking(1.5)

                HStack(alignment: .top, spacing: 12) {
                    Text(city.name)
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)

                    Spacer()

                    CityOfficialFlagView(city: city, width: 44, height: 30, showLabel: false)
                }

                if let kw = city.keywords(lang: lang) {
                    Text(kw)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color(hex: "#2DD4BF").opacity(0.90))
                        .lineLimit(2)
                } else {
                    Text(city.desc(short: true, lang: lang))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.70))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CityOverviewTab: View {
    let city: NLCity
    let lang: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(city.desc(lang: lang))
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.72))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                spacing: 10
            ) {
                StatCard(icon: "👥", value: city.population, label: cityDetailText(.population, lang))
                StatCard(icon: "📐", value: city.area, label: cityDetailText(.area, lang))
                StatCard(icon: "📅", value: city.founded, label: cityDetailText(.founded, lang))
                ForEach(city.facts) { fact in
                    StatCard(icon: fact.icon, value: fact.localizedValue(lang), label: fact.label(lang))
                }
            }

            SectionHeading(cityDetailText(.highlights, lang))
            ForEach(city.highlights(lang: lang), id: \.self) { highlight in
                HStack(alignment: .top, spacing: 10) {
                    Text("•")
                        .font(.system(size: 18))
                        .frame(width: 28)
                    Text(highlight)
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.75))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            SectionHeading(cityDetailText(.cityFlag, lang))
            HStack(spacing: 16) {
                CityOfficialFlagView(city: city, width: 80, height: 54, showLabel: false)
                Text(cityDetailText(.cityFlagDescription, lang))
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.75))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

struct CityHistoryTab: View {
    let city: NLCity
    let lang: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(cityDetailText(.history, lang)) \(city.name)")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
            Text(city.hist(lang: lang))
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.75))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct CityAttractionsTab: View {
    let city: NLCity
    let lang: AppLanguage

    var body: some View {
        LazyVStack(spacing: 14) {
            ForEach(city.attractions) { attraction in
                AttractionCard(attraction: attraction, lang: lang)
            }
        }
    }
}

struct AttractionCard: View {
    let attraction: Attraction
    let lang: AppLanguage

    var body: some View {
        let resolvedImage = CanonicalPlaceImageResolver.resolvePlaceImage(place: attraction)
        VStack(alignment: .leading, spacing: 0) {
            CityImageView(
                urlString: attraction.imageURL,
                height: 160,
                cityName: attraction.name,
                fallbackColor: Color(hex: "#142A3E"),
                fallbackURLStrings: resolvedImage.fallbackURLStrings,
                debugContext: resolvedImage.debugContext(
                    screen: "City places card",
                    entityType: "place",
                    entityName: attraction.name
                )
            )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(attraction.category.title.uppercased())
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color(hex: "#2DD4BF"))
                        .tracking(1.2)
                    Spacer()
                    Text(attraction.localizedAdmission(lang))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color(hex: "#F97316"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                Text(attraction.name)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                Text(attraction.localizedDescription(lang))
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.65))
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                VStack(alignment: .leading, spacing: 5) {
                    tourismMetadataRow(icon: "mappin.and.ellipse", label: "Location", value: attraction.location)
                    tourismMetadataRow(icon: "sparkles", label: "Why visit", value: attraction.whyVisit)
                    tourismMetadataRow(icon: "calendar", label: "Best season", value: attraction.bestSeason)
                }
                .padding(.top, 3)
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.40))
                    Text(attraction.localizedOpenHours(lang))
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.50))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(14)
        }
        .background(Color(hex: "#111C2E"))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.white.opacity(0.07), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.28), radius: 12, x: 0, y: 4)
        .pressable(scale: 0.98)
    }

    private func tourismMetadataRow(icon: String, label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color(hex: "#2DD4BF").opacity(0.75))
                .frame(width: 13, alignment: .center)
            VStack(alignment: .leading, spacing: 1) {
                Text(label.uppercased())
                    .font(.system(size: 8, weight: .bold, design: .rounded))
                    .tracking(0.8)
                    .foregroundStyle(.white.opacity(0.38))
                Text(value)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.62))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct CityLivingTab: View {
    let city: NLCity
    let lang: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            InfoBlock(title: "🌍 \(cityDetailText(.forInternationals, lang))", content: city.expat(lang: lang))
            InfoBlock(title: "🚌 \(cityDetailText(.transport, lang))", content: city.transport(lang: lang))
            InfoBlock(title: "🏛️ \(cityDetailText(.services, lang))", content: city.services.joined(separator: " · "))
            InfoBlock(title: "📮 \(cityDetailText(.postalCode, lang))", content: city.postalCode)
            InfoBlock(title: "📍 \(cityDetailText(.coordinates, lang))", content: city.coordinates)
            InfoBlock(title: "📞 \(cityDetailText(.phone, lang))", content: city.phoneHint)
        }
    }
}

private struct CityTabSelector: View {
    @Binding var selected: Int
    let tabs: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                    Button {
                        #if canImport(UIKit)
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        #endif
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
                            selected = index
                        }
                    } label: {
                        Text(tab)
                            .font(.system(size: 13, weight: selected == index ? .bold : .medium, design: .rounded))
                            .foregroundStyle(selected == index ? .white : .white.opacity(0.55))
                            .lineLimit(1)
                            .minimumScaleFactor(0.80)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(
                                Group {
                                    if selected == index {
                                        LinearGradient(
                                            colors: [Color(hex: "#F97316"), Color(hex: "#AE1C28")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    } else {
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.07), Color.white.opacity(0.07)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    }
                                }
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .pressable(scale: 0.94)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
        }
    }
}

private struct StatCard: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(icon)
                .font(.system(size: 18))
            Text(value)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.62)
                .fixedSize(horizontal: false, vertical: true)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.45))
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 94, alignment: .topLeading)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.white.opacity(0.07), lineWidth: 0.5)
        )
    }
}

private struct SectionHeading: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        HStack(spacing: 10) {
            Capsule()
                .fill(Color(hex: "#2DD4BF"))
                .frame(width: 3, height: 20)
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct InfoBlock: View {
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
            Text(content)
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.72))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.white.opacity(0.07), lineWidth: 0.5)
        )
    }
}

enum CityDetailTextKey {
    case overview
    case history
    case places
    case life
    case back
    case population
    case area
    case founded
    case highlights
    case cityFlag
    case cityFlagDescription
    case forInternationals
    case transport
    case services
    case postalCode
    case coordinates
    case phone
}

func cityDetailText(_ key: CityDetailTextKey, _ lang: AppLanguage) -> String {
    switch (key, lang) {
    case (.overview, .english): return "Overview"
    case (.overview, .dutch): return "Overzicht"
    case (.overview, .russian): return "Обзор"
    case (.history, .english): return "History"
    case (.history, .dutch): return "Geschiedenis"
    case (.history, .russian): return "История"
    case (.places, .english): return "Places"
    case (.places, .dutch): return "Plekken"
    case (.places, .russian): return "Места"
    case (.life, .english): return "Life"
    case (.life, .dutch): return "Leven"
    case (.life, .russian): return "Жизнь"
    case (.back, .english): return "Back"
    case (.back, .dutch): return "Terug"
    case (.back, .russian): return "Назад"
    case (.population, .english): return "Population"
    case (.population, .dutch): return "Inwoners"
    case (.population, .russian): return "Население"
    case (.area, .english): return "Area"
    case (.area, .dutch): return "Oppervlakte"
    case (.area, .russian): return "Площадь"
    case (.founded, .english): return "Founded"
    case (.founded, .dutch): return "Gesticht"
    case (.founded, .russian): return "Основан"
    case (.highlights, .english): return "Highlights"
    case (.highlights, .dutch): return "Hoogtepunten"
    case (.highlights, .russian): return "Главное"
    case (.cityFlag, .english): return "City flag"
    case (.cityFlag, .dutch): return "Stadsvlag"
    case (.cityFlag, .russian): return "Флаг города"
    case (.cityFlagDescription, .english): return "Official municipal flag colors."
    case (.cityFlagDescription, .dutch): return "Officiele kleuren van de gemeentevlag."
    case (.cityFlagDescription, .russian): return "Официальные цвета муниципального флага."
    case (.forInternationals, .english): return "For internationals"
    case (.forInternationals, .dutch): return "Voor internationals"
    case (.forInternationals, .russian): return "Для иностранцев"
    case (.transport, .english): return "Transport"
    case (.transport, .dutch): return "Vervoer"
    case (.transport, .russian): return "Транспорт"
    case (.services, .english): return "Services"
    case (.services, .dutch): return "Diensten"
    case (.services, .russian): return "Сервисы"
    case (.postalCode, .english): return "Postal code"
    case (.postalCode, .dutch): return "Postcode"
    case (.postalCode, .russian): return "Почтовый индекс"
    case (.coordinates, .english): return "Coordinates"
    case (.coordinates, .dutch): return "Coordinaten"
    case (.coordinates, .russian): return "Координаты"
    case (.phone, .english): return "Phone"
    case (.phone, .dutch): return "Telefoon"
    case (.phone, .russian): return "Телефон"
    }
}

private extension Attraction {
    func localizedType(_ lang: AppLanguage) -> String {
        switch (type.lowercased(), lang) {
        case (_, .english): return type
        case ("museum", .dutch): return "Museum"
        case ("museum", .russian): return "Музей"
        case ("historic site", .dutch): return "Historische plek"
        case ("historic site", .russian): return "Историческое место"
        case ("market", .dutch): return "Markt"
        case ("market", .russian): return "Рынок"
        case ("architecture", .dutch): return "Architectuur"
        case ("architecture", .russian): return "Архитектура"
        case ("landmark", .dutch): return "Bezienswaardigheid"
        case ("landmark", .russian): return "Достопримечательность"
        case ("garden", .dutch): return "Tuin"
        case ("garden", .russian): return "Сад"
        case ("windmill", .dutch): return "Molen"
        case ("windmill", .russian): return "Мельница"
        case ("monument", .dutch): return "Monument"
        case ("monument", .russian): return "Памятник"
        case ("canal", .dutch): return "Gracht"
        case ("canal", .russian): return "Канал"
        case ("public square", .dutch): return "Plein"
        case ("public square", .russian): return "Площадь"
        case ("church", .dutch): return "Kerk"
        case ("church", .russian): return "Церковь"
        case ("cultural", .dutch): return "Cultuur"
        case ("cultural", .russian): return "Культура"
        case (_, .dutch): return "Plek"
        case (_, .russian): return "Место"
        }
    }

    func localizedDescription(_ lang: AppLanguage) -> String {
        description
    }

    func localizedOpenHours(_ lang: AppLanguage) -> String {
        switch lang {
        case .english:
            return openHours
        case .dutch:
            return "Controleer actuele openingstijden"
        case .russian:
            return "Проверьте актуальные часы работы"
        }
    }

    func localizedAdmission(_ lang: AppLanguage) -> String {
        let lowercasedAdmission = admission.lowercased()
        switch lang {
        case .english:
            return admission
        case .dutch where lowercasedAdmission == "free":
            return "Gratis"
        case .russian where lowercasedAdmission == "free":
            return "Бесплатно"
        case .dutch where lowercasedAdmission == "varies":
            return "Verschilt"
        case .russian where lowercasedAdmission == "varies":
            return "Зависит"
        case .dutch:
            return admission
        case .russian:
            return admission
        }
    }
}

struct NLStatsBar: View {
    @EnvironmentObject private var languageManager: LanguageManager
    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        HStack(spacing: 0) {
            NLStatCell(value: "17.9M", label: localizedText(en: "Population", nl: "Inwoners", ru: "Население"))
            Divider().frame(height: 28).background(Color.white.opacity(0.1))
            NLStatCell(value: "12", label: localizedText(en: "Provinces", nl: "Provincies", ru: "Провинций"))
            Divider().frame(height: 28).background(Color.white.opacity(0.1))
            NLStatCell(value: "€1.1T", label: localizedText(en: "GDP", nl: "BBP", ru: "ВВП"))
            Divider().frame(height: 28).background(Color.white.opacity(0.1))
            NLStatCell(value: "2M+", label: localizedText(en: "Expats", nl: "Expats", ru: "Экспатов"))
        }
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.white.opacity(0.07), lineWidth: 0.5)
        )
    }

    private func localizedText(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .russian: return ru
        case .dutch: return nl
        case .english: return en
        }
    }
}

private struct NLStatCell: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.white.opacity(0.40))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }
}

struct SidebarCitiesSection: View {
    @EnvironmentObject private var languageManager: LanguageManager
    private let cities = Array(NLCity.all.prefix(8))
    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("🏙 \(localizedTitle.uppercased())")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.28))
                .tracking(1.5)
                .padding(.horizontal, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 10) {
                    ForEach(cities) { city in
                        NavigationLink(value: AppDestination.nlCityDetail(city.id)) {
                            SidebarCityCard(city: city)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 2)
            }
            .frame(height: 150)
        }
    }

    private var localizedTitle: String {
        switch lang {
        case .russian: return "Города"
        case .dutch: return "Steden"
        case .english: return "Cities"
        }
    }
}

struct SidebarCityCard: View {
    let city: NLCity
    @EnvironmentObject private var languageManager: LanguageManager
    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        let resolvedImage = CanonicalPlaceImageResolver.resolveCityThumbnail(city: city)
        ZStack(alignment: .bottomLeading) {
            CityImageView(
                urlString: resolvedImage.urlString,
                height: 150,
                placeId: city.placeId,
                cityName: city.name,
                fallbackColor: Color(hex: city.heroColor),
                fallbackURLStrings: resolvedImage.fallbackURLStrings,
                debugContext: resolvedImage.debugContext(
                    screen: "Sidebar city card",
                    entityType: "city",
                    entityName: city.name
                )
            )
                .frame(width: 130, height: 150)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            LinearGradient(
                colors: [.clear, .black.opacity(0.82)],
                startPoint: .top,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                CityOfficialFlagView(city: city, width: 34, height: 22, showLabel: false)

                Text(city.name)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Text(localizedProvince)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(Color(hex: "#2DD4BF"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .padding(10)
        }
        .frame(width: 130, height: 150)
    }

    private var localizedProvince: String {
        switch (city.province, lang) {
        case ("Noord-Holland", .russian): return "Северная Голландия"
        case ("Zuid-Holland", .russian): return "Южная Голландия"
        case ("Gelderland", .russian): return "Гелдерланд"
        case ("Noord-Brabant", .russian): return "Северный Брабант"
        default: return city.province
        }
    }
}

private extension NLCity {
    var phoneHint: String {
        switch id {
        case "amsterdam": return "+31 (0)20"
        case "rotterdam": return "+31 (0)10"
        case "den-haag": return "+31 (0)70"
        case "leiden": return "+31 (0)71"
        case "utrecht": return "+31 (0)30"
        case "groningen": return "+31 (0)50"
        case "nijmegen": return "+31 (0)24"
        case "arnhem": return "+31 (0)26"
        case "maastricht": return "+31 (0)43"
        case "eindhoven": return "+31 (0)40"
        default: return NetherlandsCountry.callingCode
        }
    }
}
