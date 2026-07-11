import Foundation

struct AIMessage: Identifiable, Codable, Equatable {
    enum Role: String, Codable {
        case user
        case assistant
    }

    enum Status: String, Codable {
        case sending
        case done
        case error
    }

    struct Metadata: Codable, Equatable {
        let cityId: String?
        let audience: PersonaTag?
        let categoryId: String?
        let confidence: AIResponseConfidence?

        init(cityId: String? = nil, audience: PersonaTag? = nil, categoryId: String? = nil, confidence: AIResponseConfidence? = nil) {
            self.cityId = cityId
            self.audience = audience
            self.categoryId = categoryId
            self.confidence = confidence
        }
    }

    let id: UUID
    let role: Role
    let text: String
    let createdAt: Date
    let replyToMessageID: UUID?
    let status: Status?
    let source: OfficialSource?
    let metadata: Metadata?

    init(
        id: UUID = UUID(),
        role: Role,
        text: String,
        createdAt: Date,
        replyToMessageID: UUID? = nil,
        status: Status? = .done,
        source: OfficialSource? = nil,
        metadata: Metadata? = nil
    ) {
        self.id = id
        self.role = role
        self.text = text
        self.createdAt = createdAt
        self.replyToMessageID = replyToMessageID
        self.status = status
        self.source = source
        self.metadata = metadata
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case role
        case text
        case createdAt
        case replyToMessageID
        case status
        case source
        case metadata
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        role = try container.decode(Role.self, forKey: .role)
        text = try container.decode(String.self, forKey: .text)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        replyToMessageID = try container.decodeIfPresent(UUID.self, forKey: .replyToMessageID)
        status = try container.decodeIfPresent(Status.self, forKey: .status) ?? .done
        source = try container.decodeIfPresent(OfficialSource.self, forKey: .source)
        metadata = try container.decodeIfPresent(Metadata.self, forKey: .metadata)
    }
}
