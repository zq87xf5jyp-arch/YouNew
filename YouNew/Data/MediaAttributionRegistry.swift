import Foundation

struct MediaAttributionRecord: Decodable, Identifiable, Equatable {
    let id: String
    let title: String
    let creator: String
    let creditLine: String
    let licenseName: String
    let licenseURL: URL
    let sourcePageURL: URL
    let attributionRequired: Bool
    let category: String
    let city: String?
    let province: String?
    let landmarkName: String?

    var locationLabel: String? {
        landmarkName ?? city ?? province
    }
}

enum MediaAttributionRegistry {
    static let expectedRecordCount = 76
    static let expectedNetherlandsPackRecordCount = 72

    static let records: [MediaAttributionRecord] = {
        guard let data = Data(
            base64Encoded: GeneratedMediaAttributions.base64JSON,
            options: .ignoreUnknownCharacters
        ) else {
            assertionFailure("The generated media attribution payload is invalid.")
            return []
        }

        do {
            return try JSONDecoder().decode(
                [MediaAttributionRecord].self,
                from: data
            )
        } catch {
            assertionFailure("The generated media attribution payload could not be decoded: \(error)")
            return []
        }
    }()

    private static let recordsByID: [String: MediaAttributionRecord] =
        Dictionary(uniqueKeysWithValues: records.map { ($0.id, $0) })

    static func record(for assetID: String) -> MediaAttributionRecord? {
        recordsByID[assetID]
    }
}
