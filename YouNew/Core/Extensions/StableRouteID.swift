import Foundation

enum StableRouteID {
    static func uuid(_ key: String) -> UUID {
        let normalized = key
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .init(identifier: "en_US_POSIX"))
            .lowercased()

        func fnv1a64(seed: UInt64) -> UInt64 {
            var hash = seed
            for byte in normalized.utf8 {
                hash ^= UInt64(byte)
                hash &*= 1_099_511_628_211
            }
            return hash
        }

        let high = fnv1a64(seed: 14_695_981_039_346_656_037)
        let low = fnv1a64(seed: 7_809_841_780_034_217_819)
        var bytes = [UInt8](repeating: 0, count: 16)
        for index in 0..<8 {
            bytes[index] = UInt8((high >> ((7 - index) * 8)) & 0xff)
            bytes[index + 8] = UInt8((low >> ((7 - index) * 8)) & 0xff)
        }
        bytes[6] = (bytes[6] & 0x0f) | 0x50
        bytes[8] = (bytes[8] & 0x3f) | 0x80

        return UUID(uuid: (
            bytes[0], bytes[1], bytes[2], bytes[3],
            bytes[4], bytes[5], bytes[6], bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11],
            bytes[12], bytes[13], bytes[14], bytes[15]
        ))
    }
}
