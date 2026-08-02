import Foundation
import Testing

struct ProductionSafetyPatternTests {
    @Test(.enabled(if: SourceTreeTestSupport.isAvailable))
    func productionSourcesAvoidFixedHighRiskPatterns() throws {
        let productionRoot = SourceTreeTestSupport.repoRoot.appendingPathComponent("YouNew", isDirectory: true)
        let swiftFiles = try FileManager.default.subpathsOfDirectory(atPath: productionRoot.path)
            .filter { $0.hasSuffix(".swift") }

        let bannedPatterns = [
            "try!",
            "as!",
            "transport!",
            "best!",
            "DispatchQueue.main"
        ]

        var violations: [String] = []
        for relativePath in swiftFiles {
            let fileURL = productionRoot.appendingPathComponent(relativePath)
            let contents = try String(contentsOf: fileURL, encoding: .utf8)
            for pattern in bannedPatterns where contents.contains(pattern) {
                violations.append("YouNew/\(relativePath): \(pattern)")
            }
        }

        #expect(violations.isEmpty, "High-risk source patterns found: \(violations.joined(separator: ", "))")
    }
}
