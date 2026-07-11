import Testing
import Foundation
@testable import YouNew

struct OfficialServicesDirectoryTests {
    @Test func officialServicesDirectoryContainsCoreServices() {
        let serviceNames = Set(MockExpansionData.officialServices.map(\.name))

        for required in [
            "Rijksoverheid", "Government.nl", "Overheid.nl", "IND", "Belastingdienst", "Toeslagen",
            "UWV", "DigiD", "MijnOverheid", "Autoriteit Persoonsgegevens", "DUO", "Studielink",
            "RDW", "NS", "9292", "Politie", "Juridisch Loket", "Huurcommissie", "BIG-register",
            "Netherlands Labour Authority", "Business.gov.nl"
        ] {
            #expect(serviceNames.contains(required), "Missing official service \(required)")
        }
    }

    @Test func officialServicesHaveValidPublicURLs() {
        for service in MockExpansionData.officialServices {
            #expect(service.officialURL.scheme == "https", "Expected https for \(service.name)")
            #expect(service.officialURL.host?.isEmpty == false, "Missing host for \(service.name)")
            #expect(!service.purpose.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            #expect(!service.whenToUse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    @Test func serviceClaimsAreLimitedToKnownInstitutions() {
        let allowedHosts = [
            "rijksoverheid.nl", "government.nl", "overheid.nl", "ind.nl", "belastingdienst.nl",
            "toeslagen.nl", "uwv.nl", "digid.nl", "mijn.overheid.nl", "autoriteitpersoonsgegevens.nl",
            "duo.nl", "studielink.nl", "rdw.nl", "ns.nl", "9292.nl", "politie.nl",
            "juridischloket.nl", "huurcommissie.nl", "english.bigregister.nl", "nllabourauthority.nl",
            "business.gov.nl", "kvk.nl", "ovpay.nl", "ov-chipkaart.nl", "consuwijzer.nl",
            "discriminatie.nl", "113.nl", "studyinnl.org", "nuffic.nl", "refugeehelp.nl",
            "netherlandsworldwide.nl"
        ]

        for service in MockExpansionData.officialServices {
            let host = service.officialURL.host?.replacingOccurrences(of: "www.", with: "") ?? ""
            #expect(allowedHosts.contains(host), "Unexpected official service host: \(host)")
        }
    }
}
