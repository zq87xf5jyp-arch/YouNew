import Foundation
import Testing
@testable import YouNew

struct PublicReleaseLinksTests {
    @Test func publicReleaseURLsUseTheCanonicalSecureDomain() {
        let urls = [
            AppPublicLinks.website,
            AppPublicLinks.privacyPolicy,
            AppPublicLinks.termsOfUse,
            AppPublicLinks.support
        ]

        #expect(urls.allSatisfy { $0.scheme == "https" })
        #expect(urls.allSatisfy { $0.host == "younew.nl" })
        #expect(AppPublicLinks.privacyPolicy.path == "/privacy")
        #expect(AppPublicLinks.termsOfUse.path == "/terms")
        #expect(AppPublicLinks.support.path == "/support")
    }

    @Test func supportEmailMatchesThePublicDomain() {
        #expect(AppPublicLinks.supportEmail == "support@younew.nl")
    }
}
