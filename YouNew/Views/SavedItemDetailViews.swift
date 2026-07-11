import SwiftUI

struct ResourceDetailView: View {
    let item: ResourceLinkItem
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                PremiumImageHeader(
                    title: item.localizedTitle(lang),
                    asset: resourceImageAsset,
                    language: lang,
                    symbol: resourceSymbol,
                    accent: item.isOfficial ? AppColors.success : AppColors.warning,
                    height: 190,
                    cornerRadius: 22,
                    fallbackCategory: resourceFallbackCategory
                )
                .appCardStyle()

                InfoCard(
                    title: item.localizedTitle(lang),
                    subtitle: item.localizedCategory(lang),
                    detail: item.localizedDescription(lang),
                    icon: resourceSymbol
                )
                InfoCard(
                    title: whoNeedsTitle,
                    subtitle: nil,
                    detail: item.localizedWhoItHelps(lang),
                    icon: "person.2.fill"
                )
                if let reminder = item.localizedReminder(lang) {
                    DisclaimerBanner(text: reminder)
                }
                Link(L10n.t("resource.open_source", lang), destination: AppURL.safeWebURL(item.url))
                    .buttonStyle(.borderedProminent)
                    .tint(AppColors.accent)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .tabBarScrollReserve()
        }
        .appSceneBackground()
        .navigationTitle(item.localizedTitle(lang))
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
            return ContentMediaRegistry.dailyCultureImage ?? ContentMediaRegistry.officialSourcesHero
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

    private var whoNeedsTitle: String {
        switch lang {
        case .russian: return "Кому полезно"
        case .english: return "Who needs this"
        case .dutch: return "Voor wie dit nuttig is"
        }
    }
}

struct SavedDocumentDetailView: View {
    let document: DocumentItem
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                PremiumImageHeader(
                    title: document.title,
                    asset: documentImageAsset,
                    language: lang,
                    symbol: documentSymbol,
                    accent: documentAccent,
                    height: 190,
                    cornerRadius: 22,
                    fallbackCategory: documentFallbackCategory
                )
                .appCardStyle()

                InfoCard(
                    title: document.title,
                    subtitle: document.category.localized(lang),
                    detail: document.notes.isEmpty ? noteFallback : document.notes,
                    icon: documentSymbol
                )
                InfoCard(
                    title: whereManagedTitle,
                    subtitle: nil,
                    detail: whereManagedDetail,
                    icon: "folder.fill"
                )
                NavigationLink(value: AppDestination.journeyDocuments) {
                    Label(openDocumentsTitle, systemImage: "folder.fill.badge.plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryPremiumButtonStyle())
                .accessibilityIdentifier("saved.document.openDocuments")
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .tabBarScrollReserve()
        }
        .appSceneBackground()
        .navigationTitle(document.title)
    }

    private var documentImageAsset: AppImageAsset? {
        switch document.category {
        case .passportID, .brpRegistration, .bsn, .digid, .indResidence, .gemeenteLetters:
            return ContentMediaRegistry.officialSourcesHero ?? ContentMediaRegistry.municipalityCityHallImage
        case .belastingdienstLetters, .bankDocuments:
            return ContentMediaRegistry.officialSourcesHero ?? ContentMediaRegistry.governmentBasicsImage
        case .cjibFines:
            return ContentMediaRegistry.transportHero ?? ContentMediaRegistry.officialSourcesHero
        case .duoLetters, .schoolUniversity:
            return ContentMediaRegistry.dailyCultureImage ?? ContentMediaRegistry.officialSourcesHero
        case .uwvLetters, .workContract, .payslip:
            return ContentMediaRegistry.workImage ?? ContentMediaRegistry.officialSourcesHero
        case .healthInsurance:
            return ContentMediaRegistry.healthInsuranceImage ?? ContentMediaRegistry.healthcareBasicsImage
        case .rentalContract:
            return ContentMediaRegistry.premiumHousingImage ?? ContentMediaRegistry.housingTerracedHousesImage
        case .other:
            return ContentMediaRegistry.officialSourcesHero
        }
    }

    private var documentFallbackCategory: PremiumImageFallbackCategory {
        switch document.category {
        case .passportID, .brpRegistration, .bsn, .digid, .indResidence, .gemeenteLetters, .belastingdienstLetters, .bankDocuments:
            return .documents
        case .cjibFines:
            return .transport
        case .duoLetters, .schoolUniversity:
            return .dutchA1A2
        case .uwvLetters, .workContract, .payslip:
            return .work
        case .healthInsurance:
            return .healthcare
        case .rentalContract:
            return .housing
        case .other:
            return .documents
        }
    }

    private var documentSymbol: String {
        switch document.category {
        case .passportID: return "person.text.rectangle.fill"
        case .brpRegistration, .gemeenteLetters: return "building.columns.fill"
        case .bsn: return "number.square.fill"
        case .digid: return "lock.shield.fill"
        case .indResidence: return "person.crop.rectangle.stack.fill"
        case .belastingdienstLetters: return "eurosign.circle.fill"
        case .cjibFines: return "exclamationmark.triangle.fill"
        case .duoLetters, .schoolUniversity: return "graduationcap.fill"
        case .uwvLetters, .workContract: return "briefcase.fill"
        case .payslip: return "doc.text.magnifyingglass"
        case .healthInsurance: return "cross.case.fill"
        case .rentalContract: return "house.fill"
        case .bankDocuments: return "creditcard.fill"
        case .other: return "doc.text.fill"
        }
    }

    private var documentAccent: Color {
        switch document.category {
        case .cjibFines: return AppColors.warning
        case .healthInsurance: return AppColors.success
        case .rentalContract: return AppColors.cyanGlow
        case .uwvLetters, .workContract, .payslip: return AppColors.dutchOrange
        case .duoLetters, .schoolUniversity: return AppColors.violet
        default: return AppColors.softBlue
        }
    }

    private var noteFallback: String {
        switch lang {
        case .russian: return "Добавьте заметки в разделе Документы, чтобы сохранить срок, отправителя или следующий шаг."
        case .english: return "Add notes in Documents to keep the deadline, sender, or next step with this file."
        case .dutch: return "Voeg notities toe in Documenten om de deadline, afzender of volgende stap bij dit bestand te bewaren."
        }
    }

    private var whereManagedTitle: String {
        switch lang {
        case .russian: return "Где управлять документом"
        case .english: return "Where to manage this document"
        case .dutch: return "Waar dit document beheren"
        }
    }

    private var whereManagedDetail: String {
        switch lang {
        case .russian: return "Для сканирования, печати и редактирования откройте раздел Документы и услуги."
        case .english: return "Open Documents and services to scan, print, and edit this file."
        case .dutch: return "Open Documenten en diensten om dit bestand te scannen, printen en bewerken."
        }
    }

    private var openDocumentsTitle: String {
        switch lang {
        case .russian: return "Открыть документы"
        case .english: return "Open Documents"
        case .dutch: return "Documenten openen"
        }
    }
}
