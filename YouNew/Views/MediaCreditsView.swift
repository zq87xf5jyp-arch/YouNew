import SwiftUI

struct MediaCreditsView: View {
    @EnvironmentObject private var languageManager: LanguageManager

    private var language: AppLanguage { languageManager.appLanguage }
    private let categoryOrder = ["app_context", "city_hero", "city_card", "landmark", "province"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                InfoCard(
                    title: introTitle,
                    subtitle: recordCountText,
                    detail: introDetail,
                    icon: "photo.on.rectangle.angled",
                    accentColor: AppColors.accent
                )

                if MediaAttributionRegistry.records.isEmpty {
                    InfoCard(
                        title: unavailableTitle,
                        subtitle: nil,
                        detail: unavailableDetail,
                        icon: "exclamationmark.triangle",
                        accentColor: AppColors.warning
                    )
                } else {
                    ForEach(categoryOrder, id: \.self) { category in
                        let records = records(in: category)
                        if !records.isEmpty {
                            VStack(alignment: .leading, spacing: AppSpacing.small) {
                                SectionHeader(
                                    title: categoryTitle(category),
                                    subtitle: "\(records.count)"
                                )

                                LazyVStack(spacing: AppSpacing.small) {
                                    ForEach(records) { record in
                                        creditCard(record)
                                    }
                                }
                            }
                        }
                    }
                }

                InfoCard(
                    title: changesTitle,
                    subtitle: nil,
                    detail: changesDetail,
                    icon: "crop.rotate",
                    accentColor: AppColors.softBlue
                )
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .bottomTabSafeAreaPadding()
        }
        .topChromeSafeAreaPadding()
        .appSceneBackground(.more)
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("mediaCredits.screen")
    }

    private func records(in category: String) -> [MediaAttributionRecord] {
        MediaAttributionRegistry.records
            .filter { $0.category == category }
            .sorted {
                let lhs = $0.locationLabel ?? $0.title
                let rhs = $1.locationLabel ?? $1.title
                return lhs.localizedCaseInsensitiveCompare(rhs) == .orderedAscending
            }
    }

    private func creditCard(_ record: MediaAttributionRecord) -> some View {
        PremiumMenuCard(padding: AppSpacing.medium) {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                if let location = record.locationLabel {
                    Text(location.uppercased())
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(0.8)
                        .foregroundStyle(AppColors.accent)
                }

                Text(record.creditLine)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(changesDetail)
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: AppSpacing.small) {
                    Link(destination: record.sourcePageURL) {
                        Label(sourceButtonTitle, systemImage: "arrow.up.right.square")
                    }

                    Link(destination: record.licenseURL) {
                        Label(record.licenseName, systemImage: "doc.text")
                    }
                }
                .font(AppTypography.footnote)
                .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("mediaCredits.record.\(record.id)")
    }

    private var navigationTitle: String {
        switch language {
        case .russian: return "Медиа и лицензии"
        case .dutch: return "Media en licenties"
        case .english: return "Media and licenses"
        }
    }

    private var introTitle: String {
        switch language {
        case .russian: return "Медиа и источники"
        case .dutch: return "Media en bronnen"
        case .english: return "Media and sources"
        }
    }

    private var recordCountText: String {
        switch language {
        case .russian: return "\(MediaAttributionRegistry.records.count) записей об авторстве"
        case .dutch: return "\(MediaAttributionRegistry.records.count) bronvermeldingen"
        case .english: return "\(MediaAttributionRegistry.records.count) attribution records"
        }
    }

    private var introDetail: String {
        switch language {
        case .russian:
            return "Здесь указаны авторы, исходные страницы и лицензии встроенного набора фотографий. Условия на исходной странице имеют приоритет."
        case .dutch:
            return "Hier staan de makers, bronpagina’s en licenties van het ingebouwde fotopakket. De voorwaarden op de bronpagina zijn leidend."
        case .english:
            return "Creators, source pages and licenses for the bundled photography pack are listed here. Terms on each source page control."
        }
    }

    private var changesTitle: String {
        switch language {
        case .russian: return "Изменения изображений"
        case .dutch: return "Wijzigingen aan afbeeldingen"
        case .english: return "Image modifications"
        }
    }

    private var changesDetail: String {
        switch language {
        case .russian:
            return "Для показа в приложении изображения уменьшены и, где требовалось, кадрированы; копии распространяются как оптимизированные встроенные файлы."
        case .dutch:
            return "Voor weergave in de app zijn afbeeldingen verkleind en waar nodig bijgesneden; de kopieën worden als geoptimaliseerde ingebouwde afbeeldingsbestanden gedistribueerd."
        case .english:
            return "For in-app display, images were resized and, where needed, cropped; the copies are distributed as optimized bundled image files."
        }
    }

    private var sourceButtonTitle: String {
        switch language {
        case .russian: return "Источник"
        case .dutch: return "Bron"
        case .english: return "Source"
        }
    }

    private var unavailableTitle: String {
        switch language {
        case .russian: return "Данные недоступны"
        case .dutch: return "Gegevens niet beschikbaar"
        case .english: return "Attribution unavailable"
        }
    }

    private var unavailableDetail: String {
        switch language {
        case .russian: return "Файл атрибуции не загружен."
        case .dutch: return "Het attributiebestand kon niet worden geladen."
        case .english: return "The attribution file could not be loaded."
        }
    }

    private func categoryTitle(_ category: String) -> String {
        switch (category, language) {
        case ("app_context", .russian): return "Материалы интерфейса"
        case ("app_context", .dutch): return "Media in de app"
        case ("app_context", .english): return "In-app context"
        case ("city_hero", .russian): return "Города — обложки"
        case ("city_hero", .dutch): return "Steden — hoofdbeelden"
        case ("city_hero", .english): return "Cities — hero images"
        case ("city_card", .russian): return "Города — карточки"
        case ("city_card", .dutch): return "Steden — kaarten"
        case ("city_card", .english): return "Cities — cards"
        case ("landmark", .russian): return "Достопримечательности"
        case ("landmark", .dutch): return "Bezienswaardigheden"
        case ("landmark", .english): return "Landmarks"
        case ("province", .russian): return "Провинции"
        case ("province", .dutch): return "Provincies"
        case ("province", .english): return "Provinces"
        default: return category
        }
    }
}
