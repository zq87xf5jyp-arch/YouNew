import Foundation

struct NetworkConfig {
    static let imageSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 4
        configuration.timeoutIntervalForResource = 8
        configuration.waitsForConnectivity = false
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.urlCache = URLCache(
            memoryCapacity: 50 * 1024 * 1024,
            diskCapacity: 200 * 1024 * 1024,
            diskPath: "NLImageCacheV2"
        )
        configuration.httpAdditionalHeaders = [
            "User-Agent": "YouNew/1.0 (iOS; Netherlands Guide; contact@younew.nl)",
            "Accept": "image/webp,image/jpeg,image/*,*/*;q=0.8",
            "Accept-Encoding": "gzip, deflate, br"
        ]
        return URLSession(configuration: configuration)
    }()
}
