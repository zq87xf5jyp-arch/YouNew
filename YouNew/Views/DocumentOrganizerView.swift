import SwiftUI
import UniformTypeIdentifiers
import QuickLook
#if os(iOS)
import UIKit
import VisionKit
#endif

struct DocumentOrganizerView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var documentStore: DocumentStore

    @State private var showImporter = false
    @State private var showScanner = false
    @State private var selectedDocument: DocumentItem?
    @State private var showPrintUnavailableAlert = false
    @State private var alertMessage: String?

    private var lang: AppLanguage { languageManager.appLanguage }
    private enum ScrollTarget: Hashable { case documents, needed }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    DisclaimerBanner(text: privacyIntro)
                    documentHero
                    actionsSection(scrollTo: { target in
                        withAnimation(AppAnimations.standard) {
                            proxy.scrollTo(target, anchor: .top)
                        }
                    })
                    documentsList
                        .id(ScrollTarget.documents)
                    suggestionSection
                        .id(ScrollTarget.needed)
                    lettersSection
                    officialSourcesSection
                    safeExplainSection
                    privacyCard
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, AppSpacing.medium)
                .tabBarScrollReserve()
            }
        }
        .appSceneBackground(.documents)
        .navigationTitle(title)
        .accessibilityIdentifier("documents.screen")
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [.pdf, .image, .plainText, .rtf],
            allowsMultipleSelection: false
        ) { result in
            handleImport(result)
        }
        .sheet(isPresented: $showScanner) {
            scannerSheet
        }
        .sheet(item: $selectedDocument) { item in
            NavigationStack {
                DocumentDetailSheet(
                    item: item,
                    lang: lang,
                    status: appState.selectedUserStatus,
                    onUpdate: { updated in documentStore.update(updated) },
                    onDelete: { deleting in
                        documentStore.delete(deleting)
                        selectedDocument = nil
                    },
                    onPrintUnavailable: { showPrintUnavailableAlert = true }
                )
                .navigationTitle(item.title)
                .nlNavigationInline()
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        AppNavigationBackButton(style: .close)
                    }
                }
            }
        }
        .alert(printUnavailableTitle, isPresented: $showPrintUnavailableAlert) {
            Button(okButtonTitle, role: .cancel) { }
        } message: {
            Text(printUnavailableMessage)
        }
        .alert(infoAlertTitle, isPresented: Binding(get: { alertMessage != nil }, set: { if !$0 { alertMessage = nil } })) {
            Button(okButtonTitle, role: .cancel) { alertMessage = nil }
        } message: {
            Text(alertMessage ?? "")
        }
    }

    private var sectionHeader: some View {
        SectionHeader(title: title, subtitle: subtitle)
    }

    private var documentHero: some View {
        CategoryHeroVisual(
            assetName: "premium_home_documents",
            title: title,
            subtitle: subtitle,
            symbol: "doc.viewfinder.fill",
            badgeText: visualPreviewLabel,
            accent: AppColors.softBlue
        )
    }

    private func actionsSection(scrollTo: @escaping (ScrollTarget) -> Void) -> some View {
        VStack(spacing: AppSpacing.small) {
            actionButton(icon: "doc.viewfinder", title: scanTitle, subtitle: scanSubtitle) {
#if os(iOS)
                if UIImagePickerController.isSourceTypeAvailable(.camera), Bundle.main.object(forInfoDictionaryKey: "NSCameraUsageDescription") != nil {
                    showScanner = true
                } else {
                    alertMessage = scanningLater
                }
#else
                alertMessage = scanningLater
#endif
            }
            actionButton(icon: "square.and.arrow.down", title: importTitle, subtitle: importSubtitle) { showImporter = true }
            actionButton(icon: "folder", title: myDocsTitle, subtitle: myDocsSubtitle) {
                scrollTo(.documents)
            }
            actionButton(icon: "printer", title: preparePrintTitle, subtitle: preparePrintSubtitle) {
                if documentStore.items.isEmpty {
                    alertMessage = emptyDocs
                } else {
                    scrollTo(.documents)
                }
            }
            actionButton(icon: "list.bullet.clipboard", title: neededDocsTitle, subtitle: neededDocsSubtitle) {
                scrollTo(.needed)
            }
            routeActionLink(icon: "envelope", title: lettersTitle, subtitle: lettersSubtitle, destination: .lettersList)
            routeActionLink(icon: "building.columns", title: officialTitle, subtitle: officialSubtitle, destination: .officialSources)
        }
    }

    private func routeActionLink(icon: String, title: String, subtitle: String, destination: AppDestination) -> some View {
        NavigationLink(value: destination) {
            actionLabel(icon: icon, title: title, subtitle: subtitle)
        }
        .buttonStyle(.plain)
    }

    private func actionButton(icon: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            actionLabel(icon: icon, title: title, subtitle: subtitle)
        }
        .buttonStyle(.plain)
    }

    private func actionLabel(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: AppSpacing.medium) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColors.accent)
                .frame(width: 40, height: 40)
                .background(AppColors.accent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(AppTypography.bodyStrong).foregroundStyle(AppColors.textPrimary)
                Text(subtitle).font(AppTypography.caption).foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(AppColors.textTertiary)
        }
        .appCardStyle()
    }

    private var documentsList: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text(myDocsTitle).font(AppTypography.sectionTitle).foregroundStyle(AppColors.textPrimary)
            if documentStore.items.isEmpty {
                Text(emptyDocs).appCardStyle()
            } else {
                ForEach(documentStore.items) { item in
                    HStack(spacing: AppSpacing.small) {
                        Button { selectedDocument = item } label: {
                            HStack(spacing: AppSpacing.small) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title).font(AppTypography.bodyStrong).foregroundStyle(AppColors.textPrimary)
                                    Text(item.category.localized(lang)).font(AppTypography.caption).foregroundStyle(AppColors.textSecondary)
                                    if item.isSensitive {
                                        Text(sensitiveTag).font(AppTypography.footnote).foregroundStyle(AppColors.warning)
                                    }
                                }
                                Spacer()
                                Image(systemName: "chevron.right").foregroundStyle(AppColors.textTertiary)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(item.title)

                        Button {
                            SavedItemsStore.shared.toggle(
                                id: "document::\(item.id.uuidString.lowercased())",
                                kind: .document,
                                title: item.title,
                                subtitle: item.category.localized(lang),
                                destination: .document(item.id)
                            )
                        } label: {
                            Image(systemName: SavedItemsStore.shared.isSaved("document::\(item.id.uuidString.lowercased())") ? "bookmark.fill" : "bookmark")
                                .foregroundStyle(AppColors.dutchOrange)
                                .frame(minWidth: 44, minHeight: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(
                            SavedItemsStore.shared.isSaved("document::\(item.id.uuidString.lowercased())")
                                ? L10n.t("common.remove_bookmark", lang)
                                : L10n.t("common.bookmark_item", lang)
                        )
                    }
                    .appCardStyle()
                }
            }
        }
    }

    private var suggestionSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text(neededDocsTitle).font(AppTypography.sectionTitle).foregroundStyle(AppColors.textPrimary)
            ForEach(documentStore.suggestedCategories(for: appState.selectedUserStatus)) { category in
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.localized(lang)).font(AppTypography.bodyStrong).foregroundStyle(AppColors.textPrimary)
                    Text(suggestionReason(for: category)).font(AppTypography.caption).foregroundStyle(AppColors.textSecondary)
                }
                .appCardStyle()
            }
            Text(suggestionDisclaimer).font(AppTypography.caption).foregroundStyle(AppColors.textTertiary)
        }
    }

    private var lettersSection: some View {
        NavigationLink(value: AppDestination.lettersList) {
            InfoCard(title: lettersTitle, subtitle: lettersSubtitle, detail: safeExplainShort, icon: "envelope.open")
        }
        .buttonStyle(.plain)
    }

    private var officialSourcesSection: some View {
        NavigationLink(value: AppDestination.officialSources) {
            InfoCard(title: officialTitle, subtitle: officialSubtitle, detail: sourceCheckText, icon: "checkmark.shield")
        }
        .buttonStyle(.plain)
    }

    private var safeExplainSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text(safeExplainTitle).font(AppTypography.sectionTitle).foregroundStyle(AppColors.textPrimary)
            Text(safeExplainLong).font(AppTypography.body).foregroundStyle(AppColors.textSecondary)
            Text(ocrFutureText).font(AppTypography.caption).foregroundStyle(AppColors.textTertiary)
        }
        .appCardStyle()
    }

    private var privacyCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(privacyTitle).font(AppTypography.bodyStrong).foregroundStyle(AppColors.textPrimary)
            Text(privacyPoints).font(AppTypography.caption).foregroundStyle(AppColors.textSecondary)
        }
        .appCardStyle()
    }

    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            do {
                try documentStore.addImportedDocument(
                    from: url,
                    title: url.deletingPathExtension().lastPathComponent,
                    category: .other,
                    notes: "",
                    isSensitive: false,
                    language: lang
                )
                appState.showToast(importSuccess)
            } catch {
                alertMessage = importError
            }
        case .failure:
            alertMessage = importError
        }
    }

    private func suggestionReason(for category: DocumentCategory) -> String {
        switch lang {
        case .russian:
            return "Может понадобиться для подтверждения данных. Обычно просят организации. Проверьте требования организации."
        case .dutch:
            return "Kan nodig zijn om gegevens te bevestigen. Wordt vaak gevraagd door organisaties. Controleer altijd de eisen."
        case .english:
            return "May be needed to confirm your details. Organizations often request it. Always verify requirements."
        }
    }

    private var scannerSheet: some View {
#if os(iOS)
        DocumentScannerView(
            onCancel: { showScanner = false },
            onFail: {
                showScanner = false
                alertMessage = scanningLater
            },
            onSave: { url in
                documentStore.addScannedDocument(fileURL: url, title: "Scan \(Date().formattedForAppLanguage(lang))", category: .other, notes: "", isSensitive: false, language: lang)
                showScanner = false
            }
        )
#else
        Text(scanningLater)
#endif
    }

    private var title: String { lang == .russian ? "Документы" : (lang == .dutch ? "Documenten" : "Documents") }
    private var subtitle: String { lang == .russian ? "Сканируйте, импортируйте, храните и готовьте документы локально." : (lang == .dutch ? "Scan, importeer, bewaar en bereid documenten lokaal voor." : "Scan, import, store, and prepare documents locally.") }
    private var privacyIntro: String { lang == .russian ? "Не загружайте чувствительные документы в сторонние сервисы. Приложение хранит документы локально на устройстве." : (lang == .dutch ? "Upload gevoelige documenten niet naar externe diensten. Deze app bewaart documenten lokaal op je apparaat." : "Do not upload sensitive documents to external services. This app stores documents locally on-device.") }
    private var visualPreviewLabel: String { lang == .russian ? "Визуальный предпросмотр" : (lang == .dutch ? "Visuele preview" : "Visual preview") }
    private var scanTitle: String { lang == .russian ? "Отсканировать документ" : (lang == .dutch ? "Document scannen" : "Scan document") }
    private var scanSubtitle: String { lang == .russian ? "Камера и безопасное локальное сохранение" : (lang == .dutch ? "Camera en veilig lokaal opslaan" : "Camera and safe local save") }
    private var importTitle: String { lang == .russian ? "Импортировать файл" : (lang == .dutch ? "Bestand importeren" : "Import file") }
    private var importSubtitle: String { lang == .russian ? "PDF, изображения и документы" : (lang == .dutch ? "PDF, afbeeldingen en documenten" : "PDF, images, and documents") }
    private var myDocsTitle: String { lang == .russian ? "Мои документы" : (lang == .dutch ? "Mijn documenten" : "My documents") }
    private var myDocsSubtitle: String { lang == .russian ? "Локальный список сохранённых файлов" : (lang == .dutch ? "Lokale lijst met opgeslagen bestanden" : "Local list of saved files") }
    private var preparePrintTitle: String { lang == .russian ? "Подготовить к печати" : (lang == .dutch ? "Voorbereiden voor afdrukken" : "Prepare for print") }
    private var preparePrintSubtitle: String { lang == .russian ? "Выберите локальный документ для просмотра, экспорта или печати" : (lang == .dutch ? "Selecteer een lokaal document om te bekijken, exporteren of afdrukken" : "Select a local document to preview, export, or print") }
    private var neededDocsTitle: String { lang == .russian ? "Какие документы могут понадобиться" : (lang == .dutch ? "Welke documenten kunnen nodig zijn" : "Which documents may be needed") }
    private var neededDocsSubtitle: String { lang == .russian ? "По вашему статусу и этапу" : (lang == .dutch ? "Op basis van je status en fase" : "Based on your status and stage") }
    private var lettersTitle: String { lang == .russian ? "Письма и уведомления" : (lang == .dutch ? "Brieven en meldingen" : "Letters and notices") }
    private var lettersSubtitle: String { lang == .russian ? "Разобрать отправителя, дату, дедлайн" : (lang == .dutch ? "Afzender, datum en deadline begrijpen" : "Understand sender, date, and deadline") }
    private var officialTitle: String { lang == .russian ? "Официальные источники" : (lang == .dutch ? "Officiële bronnen" : "Official sources") }
    private var officialSubtitle: String { lang == .russian ? "Проверяйте требования организации" : (lang == .dutch ? "Controleer vereisten bij de organisatie" : "Verify requirements with the organization") }
    private var safeExplainTitle: String { lang == .russian ? "Безопасное объяснение документа" : (lang == .dutch ? "Document veilig uitleggen" : "Explain document safely") }
    private var safeExplainShort: String { lang == .russian ? "Помогаем понять структуру без юридических выводов." : (lang == .dutch ? "Helpt structuur begrijpen zonder juridisch oordeel." : "Helps understand structure without legal interpretation.") }
    private var safeExplainLong: String { lang == .russian ? "Приложение может помочь понять структуру документа, но не заменяет официальную организацию или юриста." : (lang == .dutch ? "De app kan helpen de documentstructuur te begrijpen, maar vervangt geen officiële organisatie of jurist." : "The app can help understand a document's structure, but does not replace an official organization or a lawyer.") }
    private var ocrFutureText: String { lang == .russian ? "Используйте импорт, предпросмотр и заметки для локальной подготовки документа; перед отправкой проверяйте требования организации." : (lang == .dutch ? "Gebruik import, preview en notities om documenten lokaal voor te bereiden; controleer vereisten bij de organisatie." : "Use import, preview, and notes to prepare documents locally; verify requirements with the organization before sending.") }
    private var privacyTitle: String { lang == .russian ? "Документы хранятся на устройстве." : (lang == .dutch ? "Documenten worden op het apparaat opgeslagen." : "Documents are stored on-device.") }
    private var privacyPoints: String { lang == .russian ? "• Без серверной загрузки\n• Вы контролируете удаление\n• Чувствительные файлы храните осторожно\n• Проверяйте официальные источники" : (lang == .dutch ? "• Geen server-upload\n• Jij beheert verwijdering\n• Ga voorzichtig om met gevoelige bestanden\n• Controleer officiële bronnen" : "• No server upload\n• You control deletion\n• Handle sensitive files carefully\n• Verify official sources") }
    private var sourceCheckText: String { lang == .russian ? "Может понадобиться сверка с официальным сайтом организации." : (lang == .dutch ? "Controle met officiële website van de organisatie kan nodig zijn." : "You may need to verify with the organization’s official website.") }
    private var suggestionDisclaimer: String { lang == .russian ? "Это не гарантия. Требования могут отличаться: проверьте требования организации." : (lang == .dutch ? "Dit is geen garantie. Vereisten kunnen verschillen: controleer de organisatie-eisen." : "This is not a guarantee. Requirements may vary: verify with the organization.") }
    private var scanningLater: String { lang == .russian ? "Сканирование будет доступно позже." : (lang == .dutch ? "Scannen is later beschikbaar." : "Scanning will be available later.") }
    private var importSuccess: String { lang == .russian ? "Файл импортирован локально" : (lang == .dutch ? "Bestand lokaal geïmporteerd" : "File imported locally") }
    private var importError: String { lang == .russian ? "Не удалось импортировать файл" : (lang == .dutch ? "Bestand importeren mislukt" : "Failed to import file") }
    private var infoAlertTitle: String { lang == .russian ? "Информация" : (lang == .dutch ? "Info" : "Info") }
    private var okButtonTitle: String { lang == .russian ? "Понятно" : "OK" }
    private var printUnavailableTitle: String { lang == .russian ? "Печать" : (lang == .dutch ? "Afdrukken" : "Print") }
    private var printUnavailableMessage: String { lang == .russian ? "Печать недоступна на этом устройстве." : (lang == .dutch ? "Afdrukken is niet beschikbaar op dit apparaat." : "Printing is unavailable on this device.") }
    private var sensitiveTag: String { lang == .russian ? "Чувствительный документ" : (lang == .dutch ? "Gevoelig document" : "Sensitive document") }
    private var emptyDocs: String { lang == .russian ? "Пока нет документов. Добавьте скан или импортируйте файл." : (lang == .dutch ? "Nog geen documenten. Voeg een scan toe of importeer een bestand." : "No documents yet. Add a scan or import a file.") }
}

private struct DocumentDetailSheet: View {
    @State var item: DocumentItem
    let lang: AppLanguage
    let status: UserStatus?
    let onUpdate: (DocumentItem) -> Void
    let onDelete: (DocumentItem) -> Void
    let onPrintUnavailable: () -> Void

    @State private var showPreview = false
    @State private var showExporter = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                Button { showPreview = true } label: { Text(previewTitle).appCardStyle() }
                Picker(categoryTitle, selection: $item.category) {
                    ForEach(visibleCategories) { category in
                        Text(category.localized(lang)).tag(category)
                    }
                }
                .pickerStyle(.menu)
                .appCardStyle()

                Toggle(sensitiveTitle, isOn: $item.isSensitive)
                    .appCardStyle()

                Toggle(printReadyTitle, isOn: $item.printReady)
                    .appCardStyle()

                TextField(notesTitle, text: $item.notes, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .appCardStyle()

                HStack {
                    Button(shareTitle) { showExporter = true }
                    Spacer()
                    Button(printTitle) { printDocument() }
                    Spacer()
                    Button(deleteTitle, role: .destructive) { onDelete(item) }
                }
                .appCardStyle()
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
        }
        .onDisappear { onUpdate(item) }
        .sheet(isPresented: $showPreview) { QuickLookPreviewController(url: item.fileURL) }
        .sheet(isPresented: $showExporter) { ActivityViewController(activityItems: [item.fileURL]) }
    }

    private func printDocument() {
#if os(iOS)
        guard UIPrintInteractionController.isPrintingAvailable else {
            onPrintUnavailable()
            return
        }
        let controller = UIPrintInteractionController.shared
        controller.printingItem = item.fileURL
        controller.present(animated: true, completionHandler: nil)
#else
        onPrintUnavailable()
#endif
    }

    private var visibleCategories: [DocumentCategory] {
        let categories = DocumentCategory.allCases.filter { $0.isVisible(for: status) }
        if categories.contains(item.category) {
            return categories
        }
        return [item.category] + categories
    }

    private var previewTitle: String { lang == .russian ? "Предпросмотр" : (lang == .dutch ? "Voorvertoning" : "Preview") }
    private var categoryTitle: String { lang == .russian ? "Категория" : (lang == .dutch ? "Categorie" : "Category") }
    private var sensitiveTitle: String { lang == .russian ? "Чувствительный" : (lang == .dutch ? "Gevoelig" : "Sensitive") }
    private var printReadyTitle: String { lang == .russian ? "Готов к печати" : (lang == .dutch ? "Klaar om te printen" : "Print ready") }
    private var notesTitle: String { lang == .russian ? "Заметки" : (lang == .dutch ? "Notities" : "Notes") }
    private var shareTitle: String { lang == .russian ? "Экспорт" : (lang == .dutch ? "Exporteren" : "Export") }
    private var printTitle: String { lang == .russian ? "Печать" : (lang == .dutch ? "Afdrukken" : "Print") }
    private var deleteTitle: String { lang == .russian ? "Удалить" : (lang == .dutch ? "Verwijderen" : "Delete") }
}

// iOS-only wrappers for preview/share; macOS uses simple fallback views.
#if os(iOS)
private struct QuickLookPreviewController: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        context.coordinator.url = url
        controller.dataSource = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {
        context.coordinator.url = url
        uiViewController.reloadData()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(url: url)
    }

    final class Coordinator: NSObject, QLPreviewControllerDataSource {
        var url: URL

        init(url: URL) {
            self.url = url
        }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            url as NSURL
        }
    }
}

private struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#else
private struct QuickLookPreviewController: View {
    let url: URL
    @EnvironmentObject private var languageManager: LanguageManager

    var body: some View {
        VStack(spacing: 12) {
            Text(message)
            Text(url.lastPathComponent).font(.caption).foregroundStyle(.secondary)
        }
        .padding()
    }

    private var message: String {
        switch languageManager.appLanguage {
        case .english: return "Preview is not available on this platform."
        case .dutch: return "Voorvertoning is niet beschikbaar op dit platform."
        case .russian: return "Предпросмотр недоступен на этой платформе."
        }
    }
}

private struct ActivityViewController: View {
    let activityItems: [Any]
    @EnvironmentObject private var languageManager: LanguageManager

    var body: some View {
        Text(message)
            .padding()
            .onAppear { _ = activityItems }
    }

    private var message: String {
        switch languageManager.appLanguage {
        case .english: return "Sharing is not available on this platform."
        case .dutch: return "Delen is niet beschikbaar op dit platform."
        case .russian: return "Отправка недоступна на этой платформе."
        }
    }
}
#endif

#if os(iOS)
private struct DocumentScannerView: UIViewControllerRepresentable {
    let onCancel: () -> Void
    let onFail: () -> Void
    let onSave: (URL) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let controller = VNDocumentCameraViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        private let parent: DocumentScannerView

        init(_ parent: DocumentScannerView) {
            self.parent = parent
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.onCancel()
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            parent.onFail()
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            let pdf = NSMutableData()
            UIGraphicsBeginPDFContextToData(pdf, .zero, nil)
            for page in 0..<scan.pageCount {
                let image = scan.imageOfPage(at: page)
                let bounds = CGRect(origin: .zero, size: image.size)
                UIGraphicsBeginPDFPageWithInfo(bounds, nil)
                image.draw(in: bounds)
            }
            UIGraphicsEndPDFContext()

            let dir = FileManager.default.temporaryDirectory
            let url = dir.appendingPathComponent("scan_\(UUID().uuidString).pdf")
            do {
                try pdf.write(to: url, options: [.atomic, .completeFileProtection])
                var protectedURL = url
                var values = URLResourceValues()
                values.isExcludedFromBackup = true
                try? protectedURL.setResourceValues(values)
                parent.onSave(url)
            } catch {
                parent.onFail()
            }
        }
    }
}
#endif
