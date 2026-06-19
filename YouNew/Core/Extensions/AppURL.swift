import Foundation

nonisolated enum AppURL {
    private static var fallback: URL {
        URL(string: "https://www.government.nl") ?? URL(fileURLWithPath: "/")
    }

    static func make(_ raw: String) -> URL {
        validatedWebURL(URL(string: raw)) ?? fallback
    }

    static func validatedWebURL(_ url: URL?) -> URL? {
        guard let url else { return nil }
        guard let scheme = url.scheme?.lowercased(), scheme == "http" || scheme == "https" else {
            return nil
        }
        guard url.host?.isEmpty == false else {
            return nil
        }
        return url
    }

    static func safeWebURL(_ url: URL?) -> URL {
        validatedWebURL(url) ?? fallback
    }
}
