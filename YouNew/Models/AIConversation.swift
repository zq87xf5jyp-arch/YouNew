import Foundation

struct AIConversation: Codable, Equatable {
    var messages: [AIMessage] = []

    @discardableResult
    mutating func appendUser(_ text: String) -> AIMessage {
        let message = AIMessage(role: .user, text: text, createdAt: Date())
        messages.append(message)
        return message
    }

    @discardableResult
    mutating func appendAssistant(_ text: String, replyToMessageID: UUID? = nil) -> AIMessage {
        let message = AIMessage(role: .assistant, text: text, createdAt: Date(), replyToMessageID: replyToMessageID)
        messages.append(message)
        return message
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
