import Foundation

struct AIConversation: Codable, Equatable {
    var messages: [AIMessage] = []

    @discardableResult
    mutating func appendUser(_ text: String, metadata: AIMessage.Metadata? = nil) -> AIMessage {
        let message = AIMessage(role: .user, text: text, createdAt: Date(), status: .done, metadata: metadata)
        messages.append(message)
        return message
    }

    @discardableResult
    mutating func appendAssistant(
        _ text: String,
        replyToMessageID: UUID? = nil,
        status: AIMessage.Status? = .done,
        source: OfficialSource? = nil,
        metadata: AIMessage.Metadata? = nil
    ) -> AIMessage {
        let message = AIMessage(
            role: .assistant,
            text: text,
            createdAt: Date(),
            replyToMessageID: replyToMessageID,
            status: status,
            source: source,
            metadata: metadata
        )
        messages.append(message)
        return message
    }

    @discardableResult
    mutating func replaceMessage(
        id: UUID,
        text: String,
        status: AIMessage.Status?,
        source: OfficialSource?,
        metadata: AIMessage.Metadata?
    ) -> AIMessage? {
        guard let index = messages.firstIndex(where: { $0.id == id }) else { return nil }
        let existing = messages[index]
        let replacement = AIMessage(
            id: existing.id,
            role: existing.role,
            text: text,
            createdAt: existing.createdAt,
            replyToMessageID: existing.replyToMessageID,
            status: status,
            source: source,
            metadata: metadata
        )
        messages[index] = replacement
        return replacement
    }

    mutating func clear() {
        messages.removeAll()
    }

    mutating func removeLastUserMessage() {
        if let idx = messages.indices.last(where: { messages[$0].role == .user }) {
            messages.remove(at: idx)
        }
    }

    mutating func removeAssistantReplies(to userMessageID: UUID) -> [AIMessage] {
        let removed = messages.filter { $0.role == .assistant && $0.replyToMessageID == userMessageID }
        messages.removeAll { $0.role == .assistant && $0.replyToMessageID == userMessageID }
        return removed
    }
}
