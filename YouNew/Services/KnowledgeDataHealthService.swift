import Foundation

struct KnowledgeDataHealthSnapshot {
    let checkedAt: Date
    let totalRecords: Int
    let publishableRecords: Int
    let activeEvents: Int
    let expiredEvents: Int
    let outdatedRecords: Int
    let invalidSourceURLs: Int
    let missingPhotoLicenses: Int
    let duplicatePrimaryPhotos: Int

    var isHealthy: Bool {
        expiredEvents == 0 && outdatedRecords == 0 && invalidSourceURLs == 0
    }
}

enum KnowledgeDataHealthService {
    /// Fast, offline health check suitable for launch diagnostics and tests.
    /// Network availability is checked by scripts/check-external-links.py in scheduled QA.
    static func snapshot(
        database: NetherlandsKnowledgeDatabase = .shared,
        now: Date = Date()
    ) -> KnowledgeDataHealthSnapshot {
        let issues = database.dataQualityIssues(now: now)
        return KnowledgeDataHealthSnapshot(
            checkedAt: now,
            totalRecords: database.entities.count,
            publishableRecords: database.publishedEntities.count,
            activeEvents: database.publishedEntities.filter { $0.kind == .event && $0.isActiveEvent(now: now) }.count,
            expiredEvents: issues.filter { $0.kind == .expiredEvent }.count,
            outdatedRecords: issues.filter { $0.kind == .outdatedRecord }.count,
            invalidSourceURLs: issues.filter { $0.kind == .invalidWebsite || $0.kind == .missingOfficialSource }.count,
            missingPhotoLicenses: issues.filter { $0.kind == .missingPhotoLicense }.count,
            duplicatePrimaryPhotos: issues.filter { $0.kind == .duplicatePhoto }.count
        )
    }
}
