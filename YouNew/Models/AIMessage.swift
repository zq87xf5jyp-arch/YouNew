import Foundation

struct AIMessage: Identifiable, Codable, Equatable {
    enum Role: String, Codable {
        case user
        case assistant
    }

    let id: UUID
    let role: Role
    let text: String
    let createdAt: Date
    let replyToMessageID: UUID?

    init(id: UUID = UUID(), role: Role, text: String, createdAt: Date, replyToMessageID: UUID? = nil) {
        self.id = id
        self.role = role
        self.text = text
        self.createdAt = createdAt
        self.replyToMessageID = replyToMessageID
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case role
        case text
        case createdAt
        case replyToMessageID
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        role = try container.decode(Role.self, forKey: .role)
        text = try container.decode(String.self, forKey: .text)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        replyToMessageID = try container.decodeIfPresent(UUID.self, forKey: .replyToMessageID)
    }
}
