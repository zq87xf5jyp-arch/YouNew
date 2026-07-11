import Foundation
import Combine

@MainActor
final class DocumentStore: ObservableObject {
    private nonisolated static let metadataFileName = "documents.json"
    private nonisolated static let storageDirectoryName = "YouNewDocuments"
    private nonisolated static let corruptedMetadataPrefix = "documents-corrupted"

    @Published var documents: [DocumentItem] = [] {
        didSet { persistDocuments() }
    }
    @Published private(set) var lastStorageError: String?
    @Published private(set) var recoveredFromCorruption = false
    private var isLoadingFromDisk = false
    private var persistTask: Task<Void, Never>?

    init() {
        isLoadingFromDisk = true
        Task { [weak self] in
            let loaded = await Self.loadDocumentsOffMain()
            guard let self else { return }
            documents = loaded.documents
            recoveredFromCorruption = loaded.recoveredFromCorruption
            isLoadingFromDisk = false
        }
    }

    var items: [DocumentItem] { documents }

    func visibleCategories(for status: UserStatus?) -> [DocumentCategory] {
        DocumentCategory.allCases.filter { $0.isVisible(for: status) }
    }

    func add(_ document: DocumentItem) {
        documents.insert(document, at: 0)
    }

    func update(_ item: DocumentItem) {
        guard let idx = documents.firstIndex(where: { $0.id == item.id }) else { return }
        documents[idx] = item
    }

    func delete(_ document: DocumentItem) {
        documents.removeAll { $0.id == document.id }
        removeStoredFileIfNeeded(document.fileURL)
    }

    func clearAllDocuments() {
        documents.removeAll()
        do {
            let storageURL = try Self.storageDirectoryURL()
            if FileManager.default.fileExists(atPath: storageURL.path) {
                try FileManager.default.removeItem(at: storageURL)
            }
            _ = try Self.storageDirectoryURL()
            lastStorageError = nil
            recoveredFromCorruption = false
        } catch {
            lastStorageError = error.localizedDescription
        }
    }

    func suggestedCategories(for status: UserStatus?) -> [DocumentCategory] {
        let fallback = visibleCategories(for: status)
        let suggestions: [DocumentCategory]

        switch status?.personaTag {
        case .student:
            suggestions = [.duoLetters, .schoolUniversity, .healthInsurance, .rentalContract]
        case .worker:
            suggestions = [.bsn, .digid, .workContract, .payslip, .healthInsurance]
        case .refugee:
            suggestions = [.indResidence, .gemeenteLetters, .healthInsurance, .schoolUniversity]
        case .family:
            suggestions = [.gemeenteLetters, .schoolUniversity, .healthInsurance, .rentalContract]
        case .tourist:
            suggestions = [.passportID, .cjibFines]
        case .entrepreneur:
            suggestions = [.bsn, .digid, .belastingdienstLetters, .bankDocuments]
        case .lgbt:
            suggestions = [.indResidence, .gemeenteLetters, .healthInsurance, .rentalContract]
        case .eu:
            suggestions = [.brpRegistration, .bsn, .digid, .healthInsurance]
        case .nonEU, .highlySkilledMigrant:
            suggestions = [.indResidence, .bsn, .digid, .workContract, .healthInsurance]
        case .universal, .none:
            suggestions = [.passportID, .healthInsurance, .rentalContract]
        }

        let visibleSuggestions = suggestions.filter { $0.isVisible(for: status) }
        return visibleSuggestions.isEmpty ? fallback : visibleSuggestions
    }

    func addImportedDocument(from sourceURL: URL, title: String, category: DocumentCategory, notes: String, isSensitive: Bool, language: AppLanguage) throws {
        _ = language
        let id = UUID()
        let storedURL = try copyIntoManagedStorage(sourceURL, id: id)
        add(DocumentItem(id: id, title: title, category: category, fileURL: storedURL, isSensitive: isSensitive, notes: notes))
    }

    func addScannedDocument(fileURL: URL, title: String, category: DocumentCategory, notes: String, isSensitive: Bool, language: AppLanguage) throws {
        _ = language
        let id = UUID()
        defer {
            try? FileManager.default.removeItem(at: fileURL)
        }
        let storedURL = try copyIntoManagedStorage(fileURL, id: id)
        add(DocumentItem(id: id, title: title, category: category, fileURL: storedURL, isSensitive: isSensitive, notes: notes))
    }

    private func persistDocuments() {
        guard !isLoadingFromDisk else { return }
        let snapshot = documents
        persistTask?.cancel()
        persistTask = Task { [weak self] in
            let result = await Self.persistDocumentsOffMain(snapshot)
            guard let self, !Task.isCancelled else { return }
            switch result {
            case .success:
                lastStorageError = nil
            case .failure(let error):
                lastStorageError = error.localizedDescription
            }
        }
    }

    private nonisolated static func persistDocumentsOffMain(_ documents: [DocumentItem]) async -> Result<Void, Error> {
        await Task.detached(priority: .utility) {
            do {
                let metadataURL = try Self.metadataURL()
                let data = try JSONEncoder().encode(documents)
                try data.write(to: metadataURL, options: [.atomic, .completeFileProtection])
                try Self.applyFileProtection(to: metadataURL, excludeFromBackup: true)
                return .success(())
            } catch {
                return .failure(error)
            }
        }.value
    }

    private nonisolated static func loadDocumentsOffMain() async -> (documents: [DocumentItem], recoveredFromCorruption: Bool) {
        await Task.detached(priority: .utility) {
            loadDocuments()
        }.value
    }

    private nonisolated static func loadDocuments() -> (documents: [DocumentItem], recoveredFromCorruption: Bool) {
        do {
            let metadataURL = try Self.metadataURL()
            guard FileManager.default.fileExists(atPath: metadataURL.path) else { return ([], false) }
            let data = try Data(contentsOf: metadataURL)
            let decoded = try JSONDecoder().decode([DocumentItem].self, from: data)
            return (decoded.sorted { $0.createdAt > $1.createdAt }, false)
        } catch {
            quarantineCorruptedMetadata()
            return ([], true)
        }
    }

    private func copyIntoManagedStorage(_ sourceURL: URL, id: UUID) throws -> URL {
        let directoryURL = try Self.storageDirectoryURL()
        let didStartAccess = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if didStartAccess {
                sourceURL.stopAccessingSecurityScopedResource()
            }
        }

        let fileExtension = Self.safeFileExtension(from: sourceURL)
        let destinationURL = directoryURL.appendingPathComponent("\(id.uuidString).\(fileExtension)")

        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }
        try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
        try Self.applyFileProtection(to: destinationURL, excludeFromBackup: true)
        return destinationURL
    }

    private static func safeFileExtension(from url: URL) -> String {
        let allowedCharacters = CharacterSet.alphanumerics
        let sanitized = url.pathExtension
            .lowercased()
            .unicodeScalars
            .filter { allowedCharacters.contains($0) }
            .map(String.init)
            .joined()

        return sanitized.isEmpty ? "dat" : String(sanitized.prefix(12))
    }

    private func removeStoredFileIfNeeded(_ fileURL: URL) {
        guard let storageURL = try? Self.storageDirectoryURL(),
              fileURL.path.hasPrefix(storageURL.path),
              FileManager.default.fileExists(atPath: fileURL.path) else {
            return
        }
        try? FileManager.default.removeItem(at: fileURL)
    }

    private nonisolated static func metadataURL() throws -> URL {
        try storageDirectoryURL().appendingPathComponent(metadataFileName)
    }

    private nonisolated static func storageDirectoryURL() throws -> URL {
        let baseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        let directoryURL = baseURL.appendingPathComponent(storageDirectoryName, isDirectory: true)
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        try applyFileProtection(to: directoryURL, excludeFromBackup: true)
        return directoryURL
    }

    private nonisolated static func applyFileProtection(to url: URL, excludeFromBackup: Bool) throws {
        #if os(iOS)
        try FileManager.default.setAttributes([.protectionKey: FileProtectionType.complete], ofItemAtPath: url.path)
        #endif

        if excludeFromBackup {
            var mutableURL = url
            var values = URLResourceValues()
            values.isExcludedFromBackup = true
            try mutableURL.setResourceValues(values)
        }
    }

    private nonisolated static func quarantineCorruptedMetadata() {
        guard let metadataURL = try? metadataURL(),
              FileManager.default.fileExists(atPath: metadataURL.path) else {
            return
        }

        let backupName = "\(corruptedMetadataPrefix)-\(Int(Date().timeIntervalSince1970)).json"
        let backupURL = metadataURL.deletingLastPathComponent().appendingPathComponent(backupName)
        try? FileManager.default.moveItem(at: metadataURL, to: backupURL)
        try? applyFileProtection(to: backupURL, excludeFromBackup: true)
    }
}
