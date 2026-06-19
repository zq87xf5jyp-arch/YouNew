import SwiftUI

struct ResourceDetailView: View {
    let item: ResourceLinkItem
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                InfoCard(
                    title: item.localizedTitle(lang),
                    subtitle: item.localizedCategory(lang),
                    detail: item.localizedDescription(lang),
                    icon: "link.circle.fill"
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
                InfoCard(
                    title: document.title,
                    subtitle: document.category.localized(lang),
                    detail: document.notes.isEmpty ? noteFallback : document.notes,
                    icon: "doc.text.fill"
                )
                InfoCard(
                    title: whereManagedTitle,
                    subtitle: nil,
                    detail: whereManagedDetail,
                    icon: "folder.fill"
                )
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .tabBarScrollReserve()
        }
        .appSceneBackground()
        .navigationTitle(document.title)
    }

    private var noteFallback: String {
        switch lang {
        case .russian: return "Заметки отсутствуют."
        case .english: return "No notes available."
        case .dutch: return "Geen notities beschikbaar."
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
}
