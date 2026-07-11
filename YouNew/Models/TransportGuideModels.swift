import Foundation

struct TransportGuide: Identifiable, Sendable {
    let id: String
    let title: LocalizedInfoText
    let summary: LocalizedInfoText
    let sections: [TransportGuideSection]
    let quickCards: [TransportQuickCard]
    let sources: [TransportGuideSource]
    let updatedAt: String
    let verified: Bool
    let searchAliases: [String]
}

struct TransportGuideSection: Identifiable, Hashable, Sendable {
    let id: String
    let title: LocalizedInfoText
    let summary: LocalizedInfoText
    let points: [LocalizedInfoText]
    let costNotes: [LocalizedInfoText]
    let practicalTips: [LocalizedInfoText]
    let hints: [LocalizedInfoText]
    let sourceIds: [String]
    let symbol: String
}

struct TransportQuickCard: Identifiable, Hashable, Sendable {
    let id: String
    let title: LocalizedInfoText
    let subtitle: LocalizedInfoText
    let symbol: String
    let sourceId: String?
    let sectionId: String?
}

struct TransportGuideSource: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let institution: String
    let url: URL
    let sourceType: String
    let language: String
    let retrievedAt: String
    let verified: Bool
}
