import Foundation
import Testing

struct ProductionSafetyPatternTests {
    @Test func productionSourcesAvoidFixedHighRiskPatterns() throws {
        let sourceRoot = try Self.sourceRoot()
        let swiftFiles = try FileManager.default.subpathsOfDirectory(atPath: sourceRoot.path)
            .filter { $0.hasSuffix(".swift") }
            .filter { !$0.contains("Tests/") && !$0.contains("UITests/") }

        let bannedPatterns = [
            "try!",
            "as!",
            "transport!",
            "best!",
            "DispatchQueue.main"
        ]

        var violations: [String] = []
        for relativePath in swiftFiles {
            let fileURL = sourceRoot.appendingPathComponent(relativePath)
            let contents = try String(contentsOf: fileURL, encoding: .utf8)
            for pattern in bannedPatterns where contents.contains(pattern) {
                violations.append("\(relativePath): \(pattern)")
            }
        }

        #expect(violations.isEmpty, "High-risk source patterns found: \(violations.joined(separator: ", "))")
    }

    private static func sourceRoot() throws -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while true {
            let appSource = url.appendingPathComponent("YouNew")
            let testSource = url.appendingPathComponent("YouNewTests")
            if FileManager.default.fileExists(atPath: appSource.path),
               FileManager.default.fileExists(atPath: testSource.path) {
                return url
            }

            let parent = url.deletingLastPathComponent()
            if parent.path == url.path {
                throw SourceRootError.notFound
            }
            url = parent
        }
    }

    private enum SourceRootError: Error {
        case notFound
    }
}
