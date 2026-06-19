import Foundation

struct DeadlineReminder: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let possibleDueDate: Date?
    let institutionName: String
    let sourceURL: URL
}
