import SwiftUI

struct PrivacyDataControlView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var documentStore: DocumentStore
    @EnvironmentObject private var savedItemsStore: SavedItemsStore
    @State private var exportURL: URL?
    @State private var exportError: String?
    @State private var showDeleteConfirmation = false

    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                header
                rightsSection
                storageSection
                neverSharedSection
                retentionSection
                dataControlsSection
                legalSection
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .tabBarScrollReserve()
        }
        .appSceneBackground()
        .navigationTitle(title)
        .nlNavigationInline()
        .confirmationDialog(deleteTitle, isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button(deleteConfirmTitle, role: .destructive) {
                deletePersonalData()
            }
            Button(cancelTitle, role: .cancel) {}
        } message: {
            Text(deleteMessage)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            CategoryHeroVisual(
                assetName: nil,
                title: title,
                subtitle: headerSubtitle,
                symbol: "lock.shield.fill",
                badgeText: privacyBadgeText,
                accent: AppColors.accent,
                asset: ContentMediaRegistry.savedImage ?? ContentMediaRegistry.officialSourcesHero,
                height: 240,
                language: lang
            )

            Text(headerDetail)
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 4)
        }
    }

    private var storageSection: some View {
        section(title: storedDataTitle) {
            privacyRow(icon: "person.crop.circle", title: profileDataTitle, detail: profileDataDetail)
            privacyRow(icon: "checklist", title: checklistDataTitle, detail: checklistDataDetail)
            privacyRow(icon: "doc.on.doc", title: documentDataTitle, detail: documentDataDetail)
            privacyRow(icon: "bookmark.fill", title: savedDataTitle, detail: savedDataDetail)
        }
    }

    private var rightsSection: some View {
        section(title: rightsTitle) {
            privacyRow(icon: "person.fill.checkmark", title: ownershipTitle, detail: ownershipDetail)
            privacyRow(icon: "square.and.arrow.up", title: portabilityTitle, detail: portabilityDetail)
            privacyRow(icon: "trash", title: erasureTitle, detail: erasureDetail)
        }
    }

    private var neverSharedSection: some View {
        section(title: neverSharedTitle) {
            privacyRow(icon: "wifi.slash", title: noServerTitle, detail: noServerDetail)
            privacyRow(icon: "chart.bar.xaxis", title: noTrackingTitle, detail: noTrackingDetail)
            privacyRow(icon: "eye.slash.fill", title: noHiddenSharingTitle, detail: noHiddenSharingDetail)
            privacyRow(icon: "doc.on.clipboard", title: clipboardTitle, detail: clipboardDetail)
        }
    }

    private var retentionSection: some View {
        section(title: retentionTitle) {
            privacyRow(icon: "internaldrive", title: localRetentionTitle, detail: localRetentionDetail)
            privacyRow(icon: "icloud.slash", title: backupTitle, detail: backupDetail)
            privacyRow(icon: "clock.badge.exclamationmark", title: temporaryExportTitle, detail: temporaryExportDetail)
        }
    }

    private var dataControlsSection: some View {
        section(title: controlsTitle) {
            Button {
                createExportFile()
            } label: {
                controlRow(icon: "square.and.arrow.up", title: exportTitle, detail: exportDetail, color: AppColors.accent)
            }
            .buttonStyle(.plain)

            if let exportURL {
                ShareLink(item: exportURL) {
                    controlRow(icon: "doc.zipper", title: shareExportTitle, detail: exportURL.lastPathComponent, color: AppColors.success)
                }
                .buttonStyle(.plain)
            }

            if let exportError {
                Text(exportError)
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.error)
                    .fixedSize(horizontal: false, vertical: true)
                    .appCardStyle()
            }

            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                controlRow(icon: "trash.fill", title: deleteTitle, detail: deleteDetail, color: AppColors.error)
            }
            .buttonStyle(.plain)
        }
    }

    private var legalSection: some View {
        section(title: legalTitle) {
            privacyRow(icon: "graduationcap.fill", title: educationalTitle, detail: educationalDetail)
            privacyRow(icon: "building.columns.fill", title: officialTitle, detail: officialDetail)
            privacyRow(icon: "scalemass.fill", title: notLegalAdviceTitle, detail: notLegalAdviceDetail)
        }
    }

    @ViewBuilder
    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text(title.uppercased())
                .font(AppTypography.metadata)
                .tracking(0.5)
                .foregroundStyle(AppColors.textTertiary)
                .padding(.horizontal, 4)
            VStack(spacing: AppSpacing.xSmall) {
                content()
            }
        }
    }

    private func privacyRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.medium) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColors.accent)
                .frame(width: 40, height: 40)
                .background(AppColors.accent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.textPrimary)
                Text(detail)
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .appCardStyle()
    }

    private func controlRow(icon: String, title: String, detail: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.medium) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.textPrimary)
                Text(detail)
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(AppColors.textTertiary)
                .padding(.top, 12)
        }
        .appCardStyle()
        .contentShape(Rectangle())
    }

    private func createExportFile() {
        do {
            removePreviousExportIfNeeded()
            let payload = appState.privacyExportPayload(
                savedItemsCount: savedItemsStore.savedItems.count,
                documentMetadata: documentStore.documents
            )
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(payload)
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("younew-privacy-export-\(Int(Date().timeIntervalSince1970)).json")
            try data.write(to: url, options: [.atomic, .completeFileProtection])
            exportURL = url
            exportError = nil
        } catch {
            exportURL = nil
            exportError = exportFailedMessage
        }
    }

    private func removePreviousExportIfNeeded() {
        guard let exportURL else { return }
        try? FileManager.default.removeItem(at: exportURL)
    }

    private func deletePersonalData() {
        appState.resetPersonalState()
        savedItemsStore.removeAll()
        documentStore.clearAllDocuments()
        AppDataMigration.resetLocalCachedData()
        removePreviousExportIfNeeded()
        exportURL = nil
        exportError = nil
        appState.showToast(deletedToast)
    }
}

private extension PrivacyDataControlView {
    var title: String {
        switch lang {
        case .russian: return "Приватность и данные"
        case .english: return "Privacy and data"
        case .dutch: return "Privacy en gegevensbeheer"
        }
    }

    var headerSubtitle: String {
        switch lang {
        case .russian: return "Локальное хранение, экспорт и удаление ваших данных."
        case .english: return "Local storage, export and deletion for your data."
        case .dutch: return "Lokale opslag, export en verwijdering van uw gegevens."
        }
    }

    var privacyBadgeText: String {
        switch lang {
        case .russian: return "Локально на устройстве"
        case .english: return "On-device control"
        case .dutch: return "Op apparaat"
        }
    }

    var headerDetail: String {
        switch lang {
        case .russian: return "YouNew.nl не содержит аналитики или скрытой синхронизации. При использовании AI вопрос и ограниченный контекст могут отправляться в настроенный AI proxy; не вводите BSN, паспортные номера, медицинские записи или другие чувствительные данные. Экспорт включает metadata документов, но не копирует сами файлы."
        case .english: return "YouNew.nl does not include analytics or hidden sync. If you use AI, your question and limited context may be sent to the configured AI proxy; do not enter BSN, passport numbers, medical records or other sensitive data. Export includes document metadata, not the document files themselves."
        case .dutch: return "YouNew.nl bevat geen analytics of verborgen synchronisatie. Als u AI gebruikt, kunnen uw vraag en beperkte context naar de ingestelde AI-proxy worden verzonden; voer geen BSN, paspoortnummers, medische gegevens of andere gevoelige data in. Export bevat documentmetadata, niet de bestanden zelf."
        }
    }

    var storedDataTitle: String { lang == .russian ? "Что хранится" : (lang == .dutch ? "Wat wordt opgeslagen" : "What is stored") }
    var rightsTitle: String { lang == .russian ? "Ваши права" : (lang == .dutch ? "Uw rechten" : "Your rights") }
    var ownershipTitle: String { lang == .russian ? "Вы владеете данными" : (lang == .dutch ? "U beheert uw gegevens" : "You own your data") }
    var ownershipDetail: String { lang == .russian ? "Профиль, документы, сохранённые элементы и история контролируются пользователем на устройстве." : (lang == .dutch ? "Profiel, documenten, opgeslagen items en geschiedenis worden door de gebruiker op het apparaat beheerd." : "Profile, documents, saved items and history are controlled by the user on device.") }
    var portabilityTitle: String { lang == .russian ? "Право на экспорт" : (lang == .dutch ? "Recht op export" : "Right to export") }
    var portabilityDetail: String { lang == .russian ? "Экспорт создаётся по запросу пользователя в переносимом JSON-формате." : (lang == .dutch ? "Export wordt op verzoek van de gebruiker gemaakt in draagbaar JSON-formaat." : "Export is created on user request in portable JSON format.") }
    var erasureTitle: String { lang == .russian ? "Право на удаление" : (lang == .dutch ? "Recht op verwijdering" : "Right to delete") }
    var erasureDetail: String { lang == .russian ? "Удаление очищает локальный профиль, историю, документы и сохранённые элементы приложения." : (lang == .dutch ? "Verwijderen wist lokaal profiel, geschiedenis, documenten en opgeslagen app-items." : "Deletion clears local profile, history, documents and saved app items.") }
    var profileDataTitle: String { lang == .russian ? "Профиль и статус" : (lang == .dutch ? "Profiel en status" : "Profile and status") }
    var profileDataDetail: String { lang == .russian ? "Тип профиля, город, статус, локальные флаги BSN/DigiD/страховки." : (lang == .dutch ? "Profieltype, stad, status en lokale BSN/DigiD/verzekeringsvlaggen." : "Profile type, city, status and local BSN/DigiD/insurance flags.") }
    var checklistDataTitle: String { lang == .russian ? "Чеклист" : (lang == .dutch ? "Checklist" : "Checklist") }
    var checklistDataDetail: String { lang == .russian ? "Только отметки выполнения и выбранные шаги внутри приложения." : (lang == .dutch ? "Alleen voltooiingsstatus en gekozen stappen in de app." : "Only completion state and selected steps inside the app.") }
    var documentDataTitle: String { lang == .russian ? "Документы" : (lang == .dutch ? "Documenten" : "Documents") }
    var documentDataDetail: String { lang == .russian ? "\(documentStore.documents.count) файлов в локальном хранилище приложения." : (lang == .dutch ? "\(documentStore.documents.count) bestanden in lokale appopslag." : "\(documentStore.documents.count) files in local app storage.") }
    var savedDataTitle: String { lang == .russian ? "Сохранённые материалы" : (lang == .dutch ? "Opgeslagen items" : "Saved items") }
    var savedDataDetail: String { lang == .russian ? "\(savedItemsStore.savedItems.count) сохранённых тем, правил или ресурсов." : (lang == .dutch ? "\(savedItemsStore.savedItems.count) opgeslagen onderwerpen, regels of bronnen." : "\(savedItemsStore.savedItems.count) saved topics, rules or resources.") }
    var neverSharedTitle: String { lang == .russian ? "Что не передаётся" : (lang == .dutch ? "Wat niet wordt gedeeld" : "What is never shared") }
    var noServerTitle: String { lang == .russian ? "Нет скрытой серверной синхронизации" : (lang == .dutch ? "Geen verborgen serversynchronisatie" : "No hidden server sync") }
    var noServerDetail: String { lang == .russian ? "Профиль и документы остаются на устройстве. AI-запросы могут отправляться только при явном использовании ассистента и только если настроен AI proxy." : (lang == .dutch ? "Profiel en documenten blijven op het apparaat. AI-vragen kunnen alleen worden verzonden wanneer u de assistent gebruikt en alleen als een AI-proxy is ingesteld." : "Profile and documents stay on device. AI questions may be sent only when you use the assistant and only if an AI proxy is configured.") }
    var noTrackingTitle: String { lang == .russian ? "Нет скрытой аналитики" : (lang == .dutch ? "Geen verborgen analytics" : "No hidden analytics") }
    var noTrackingDetail: String { lang == .russian ? "В проект не добавлены рекламные или tracking SDK." : (lang == .dutch ? "Er zijn geen advertentie- of tracking-SDK's toegevoegd." : "No advertising or tracking SDKs are included.") }
    var noHiddenSharingTitle: String { lang == .russian ? "Нет скрытой отправки документов" : (lang == .dutch ? "Geen verborgen documentupload" : "No hidden document upload") }
    var noHiddenSharingDetail: String { lang == .russian ? "Импортированные документы используются только локально для организации." : (lang == .dutch ? "Geïmporteerde documenten worden alleen lokaal georganiseerd." : "Imported documents are used only for local organization.") }
    var clipboardTitle: String { lang == .russian ? "Буфер обмена только по действию" : (lang == .dutch ? "Klembord alleen op actie" : "Clipboard only by action") }
    var clipboardDetail: String { lang == .russian ? "Копирование ссылок или переводов выполняется только после нажатия пользователем." : (lang == .dutch ? "Links of vertalingen worden alleen gekopieerd na een gebruikersactie." : "Links or translations are copied only after a user action.") }
    var retentionTitle: String { lang == .russian ? "Хранение и backup" : (lang == .dutch ? "Bewaren en backup" : "Retention and backup") }
    var localRetentionTitle: String { lang == .russian ? "Хранится до удаления" : (lang == .dutch ? "Bewaard tot verwijdering" : "Kept until deleted") }
    var localRetentionDetail: String { lang == .russian ? "Локальные данные остаются, пока пользователь не удалит их или приложение." : (lang == .dutch ? "Lokale gegevens blijven staan tot de gebruiker ze of de app verwijdert." : "Local data remains until the user deletes it or removes the app.") }
    var backupTitle: String { lang == .russian ? "Документы исключены из backup" : (lang == .dutch ? "Documenten uitgesloten van backup" : "Documents excluded from backup") }
    var backupDetail: String { lang == .russian ? "Хранилище документов приложения помечается как excluded from backup и защищается file protection, где доступно." : (lang == .dutch ? "Appdocumentopslag wordt gemarkeerd als excluded from backup en gebruikt file protection waar beschikbaar." : "App document storage is marked excluded from backup and uses file protection where available.") }
    var temporaryExportTitle: String { lang == .russian ? "Экспорт временный" : (lang == .dutch ? "Export is tijdelijk" : "Export is temporary") }
    var temporaryExportDetail: String { lang == .russian ? "JSON export создаётся во временной папке и защищается file protection. Пользователь сам выбирает, куда его передать." : (lang == .dutch ? "JSON-export wordt tijdelijk aangemaakt met file protection. De gebruiker kiest zelf waar die wordt gedeeld." : "JSON export is created in temporary storage with file protection. The user chooses where to share it.") }
    var controlsTitle: String { lang == .russian ? "Управление" : (lang == .dutch ? "Beheer" : "Controls") }
    var exportTitle: String { lang == .russian ? "Экспортировать мои данные" : (lang == .dutch ? "Mijn gegevens exporteren" : "Export my data") }
    var exportDetail: String { lang == .russian ? "Создать JSON dossier с профилем, чеклистом, сохранёнными items и metadata документов." : (lang == .dutch ? "Maak een JSON-dossier met profiel, checklist, opgeslagen items en documentmetadata." : "Create a JSON dossier with profile, checklist, saved items and document metadata.") }
    var shareExportTitle: String { lang == .russian ? "Поделиться экспортом" : (lang == .dutch ? "Export delen" : "Share export") }
    var deleteTitle: String { lang == .russian ? "Удалить все личные данные" : (lang == .dutch ? "Alle persoonlijke gegevens verwijderen" : "Delete all personal data") }
    var deleteDetail: String { lang == .russian ? "Сбросить профиль, чеклист, сохранённое, историю и локальные документы." : (lang == .dutch ? "Reset profiel, checklist, opgeslagen items, geschiedenis en lokale documenten." : "Reset profile, checklist, saved items, history and local documents.") }
    var legalTitle: String { lang == .russian ? "Юридическая безопасность" : (lang == .dutch ? "Juridische veiligheid" : "Legal safety") }
    var educationalTitle: String { lang == .russian ? "Только образовательная информация" : (lang == .dutch ? "Alleen educatieve informatie" : "Educational information only") }
    var educationalDetail: String { lang == .russian ? "Приложение помогает ориентироваться, но не принимает решения за пользователя." : (lang == .dutch ? "De app helpt oriënteren, maar neemt geen beslissingen voor de gebruiker." : "The app helps orientation, but does not make decisions for the user.") }
    var officialTitle: String { lang == .russian ? "Проверяйте официальные источники" : (lang == .dutch ? "Controleer officiële bronnen" : "Verify official sources") }
    var officialDetail: String { lang == .russian ? "Суммы штрафов, сроки и процедуры могут меняться." : (lang == .dutch ? "Boetes, termijnen en procedures kunnen wijzigen." : "Fine amounts, deadlines and procedures may change.") }
    var notLegalAdviceTitle: String { lang == .russian ? "Не юридическая консультация" : (lang == .dutch ? "Geen juridisch advies" : "Not legal advice") }
    var notLegalAdviceDetail: String { lang == .russian ? "Приложение не заменяет юриста, gemeente, IND, CJIB или другое учреждение." : (lang == .dutch ? "De app vervangt geen advocaat, gemeente, IND, CJIB of andere instantie." : "The app does not replace a lawyer, gemeente, IND, CJIB or another institution.") }
    var deleteConfirmTitle: String { lang == .russian ? "Удалить данные" : (lang == .dutch ? "Gegevens verwijderen" : "Delete data") }
    var deleteMessage: String { lang == .russian ? "Это действие удалит локальные личные данные и документы приложения. Его нельзя отменить." : (lang == .dutch ? "Dit verwijdert lokale persoonlijke gegevens en appdocumenten. Dit kan niet ongedaan worden gemaakt." : "This removes local personal data and app documents. It cannot be undone.") }
    var cancelTitle: String { lang == .russian ? "Отмена" : (lang == .dutch ? "Annuleren" : "Cancel") }
    var deletedToast: String { lang == .russian ? "Личные данные удалены" : (lang == .dutch ? "Persoonlijke gegevens verwijderd" : "Personal data deleted") }
    var exportFailedMessage: String { lang == .russian ? "Не удалось создать экспорт. Проверьте доступное место и повторите." : (lang == .dutch ? "Export maken mislukt. Controleer opslagruimte en probeer opnieuw." : "Could not create export. Check available storage and try again.") }
}
