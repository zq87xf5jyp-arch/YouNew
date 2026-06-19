import Foundation

enum AIWorkflowKind: String, Codable, Equatable {
    case healthInsurance
    case bsnRegistration
    case digid
    case fineLetter
    case housing
    case whatNext
}

struct AIWorkflow: Codable, Equatable {
    enum Step: String, Codable, Equatable {
        case asksWorkStatus
        case asksRegistrationStatus
        case asksAddressStatus
        case asksBSNStatus
        case asksDigiDNeed
        case asksLetterType
        case asksHousingStatus
        case finalGuidance
    }

    let kind: AIWorkflowKind
    var step: Step
    var userWorks: Bool?
    var isRegistered: Bool?
    var hasAddress: Bool?
    var hasBSN: Bool?
    var needsDigiD: Bool?
    var selectedOption: String?

    init(
        kind: AIWorkflowKind,
        step: Step,
        userWorks: Bool? = nil,
        isRegistered: Bool? = nil,
        hasAddress: Bool? = nil,
        hasBSN: Bool? = nil,
        needsDigiD: Bool? = nil,
        selectedOption: String? = nil
    ) {
        self.kind = kind
        self.step = step
        self.userWorks = userWorks
        self.isRegistered = isRegistered
        self.hasAddress = hasAddress
        self.hasBSN = hasBSN
        self.needsDigiD = needsDigiD
        self.selectedOption = selectedOption
    }
}
