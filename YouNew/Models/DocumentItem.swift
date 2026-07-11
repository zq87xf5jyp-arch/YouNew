import Foundation

enum DocumentCategory: String, CaseIterable, Identifiable, Hashable, Codable {
    case passportID
    case brpRegistration
    case bsn
    case digid
    case indResidence
    case gemeenteLetters
    case belastingdienstLetters
    case cjibFines
    case duoLetters
    case uwvLetters
    case healthInsurance
    case rentalContract
    case workContract
    case payslip
    case bankDocuments
    case schoolUniversity
    case other

    var id: String { rawValue }

    var personaTags: Set<PersonaTag> {
        switch self {
        case .passportID, .other:
            return [.universal]
        case .brpRegistration, .bsn, .digid:
            return [.worker, .refugee, .family, .entrepreneur, .eu, .nonEU, .highlySkilledMigrant, .lgbt]
        case .indResidence:
            return [.refugee, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        case .gemeenteLetters:
            return [.worker, .refugee, .family, .entrepreneur, .eu, .nonEU, .highlySkilledMigrant, .lgbt]
        case .belastingdienstLetters:
            return [.worker, .entrepreneur, .eu, .nonEU, .highlySkilledMigrant]
        case .cjibFines:
            return [.worker, .tourist, .entrepreneur, .eu, .highlySkilledMigrant]
        case .duoLetters:
            return [.student]
        case .uwvLetters:
            return [.worker]
        case .healthInsurance:
            return [.student, .worker, .refugee, .family, .entrepreneur, .eu, .nonEU, .highlySkilledMigrant, .lgbt]
        case .rentalContract:
            return [.student, .worker, .refugee, .family, .entrepreneur, .eu, .nonEU, .highlySkilledMigrant, .lgbt]
        case .workContract, .payslip:
            return [.worker, .eu, .nonEU, .highlySkilledMigrant]
        case .bankDocuments:
            return [.student, .worker, .family, .entrepreneur, .eu, .nonEU, .highlySkilledMigrant]
        case .schoolUniversity:
            return [.student, .refugee, .family]
        }
    }

    func isVisible(for status: UserStatus?) -> Bool {
        PersonaContentPolicy.isVisible(
            tags: personaTags,
            activePersona: status?.personaTag,
            scope: .currentAndUniversal
        )
    }

    func localized(_ language: AppLanguage) -> String {
        switch language {
        case .english:
            switch self {
            case .passportID:             return "Passport / ID"
            case .brpRegistration:        return "BRP Registration"
            case .bsn:                    return "BSN (Citizen Number)"
            case .digid:                  return "DigiD"
            case .indResidence:           return "IND Residence Permit"
            case .gemeenteLetters:        return "Gemeente Letters"
            case .belastingdienstLetters: return "Belastingdienst Letters"
            case .cjibFines:              return "CJIB Fines"
            case .duoLetters:             return "DUO Letters"
            case .uwvLetters:             return "UWV Letters"
            case .healthInsurance:        return "Health Insurance"
            case .rentalContract:         return "Rental Contract"
            case .workContract:           return "Work Contract"
            case .payslip:                return "Payslip"
            case .bankDocuments:          return "Bank Documents"
            case .schoolUniversity:       return "School / University"
            case .other:                  return "Other"
            }
        case .dutch:
            switch self {
            case .passportID:             return "Paspoort / ID"
            case .brpRegistration:        return "BRP-registratie"
            case .bsn:                    return "BSN (Burgerservicenummer)"
            case .digid:                  return "DigiD"
            case .indResidence:           return "IND Verblijfsvergunning"
            case .gemeenteLetters:        return "Gemeentebrieven"
            case .belastingdienstLetters: return "Belastingdienstbrieven"
            case .cjibFines:              return "CJIB-boetes"
            case .duoLetters:             return "DUO-brieven"
            case .uwvLetters:             return "UWV-brieven"
            case .healthInsurance:        return "Zorgverzekering"
            case .rentalContract:         return "Huurcontract"
            case .workContract:           return "Arbeidscontract"
            case .payslip:                return "Loonstrook"
            case .bankDocuments:          return "Bankdocumenten"
            case .schoolUniversity:       return "School / Universiteit"
            case .other:                  return "Overig"
            }
        case .russian:
            switch self {
            case .passportID:             return "Паспорт / Удостоверение"
            case .brpRegistration:        return "Регистрация BRP"
            case .bsn:                    return "BSN (Гражданский номер)"
            case .digid:                  return "DigiD"
            case .indResidence:           return "Разрешение на проживание IND"
            case .gemeenteLetters:        return "Письма от gemeente"
            case .belastingdienstLetters: return "Письма от Belastingdienst"
            case .cjibFines:             return "Штрафы CJIB"
            case .duoLetters:             return "Письма от DUO"
            case .uwvLetters:             return "Письма от UWV"
            case .healthInsurance:        return "Медицинская страховка"
            case .rentalContract:         return "Договор аренды"
            case .workContract:           return "Трудовой договор"
            case .payslip:                return "Расчётный листок"
            case .bankDocuments:          return "Банковские документы"
            case .schoolUniversity:       return "Школа / Университет"
            case .other:                  return "Прочее"
            }
        }
    }
}

struct DocumentItem: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var category: DocumentCategory
    var fileURL: URL
    var createdAt: Date
    var expirationDate: Date?
    var reminderDate: Date?
    var relatedChecklistItemID: UUID?
    var isSensitive: Bool
    var notes: String
    var printReady: Bool

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case category
        case fileURL
        case createdAt
        case expirationDate
        case reminderDate
        case relatedChecklistItemID
        case isSensitive
        case notes
        case printReady
    }

    init(
        id: UUID = UUID(),
        title: String,
        category: DocumentCategory = .other,
        fileURL: URL? = nil,
        createdAt: Date = Date(),
        expirationDate: Date? = nil,
        reminderDate: Date? = nil,
        relatedChecklistItemID: UUID? = nil,
        isSensitive: Bool = false,
        notes: String = "",
        printReady: Bool = true
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.fileURL = fileURL ?? FileManager.default.temporaryDirectory.appendingPathComponent("doc_\(id.uuidString).txt")
        self.createdAt = createdAt
        self.expirationDate = expirationDate
        self.reminderDate = reminderDate
        self.relatedChecklistItemID = relatedChecklistItemID
        self.isSensitive = isSensitive
        self.notes = notes
        self.printReady = printReady
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        category = try container.decode(DocumentCategory.self, forKey: .category)
        fileURL = try container.decode(URL.self, forKey: .fileURL)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        expirationDate = try container.decodeIfPresent(Date.self, forKey: .expirationDate)
        reminderDate = try container.decodeIfPresent(Date.self, forKey: .reminderDate)
        relatedChecklistItemID = try container.decodeIfPresent(UUID.self, forKey: .relatedChecklistItemID)
        isSensitive = try container.decodeIfPresent(Bool.self, forKey: .isSensitive) ?? false
        notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
        printReady = try container.decodeIfPresent(Bool.self, forKey: .printReady) ?? true
    }
}
