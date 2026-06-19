import Foundation

struct OnboardingFlowStep: Identifiable {
    let id = UUID()
    let title: String
    let beginnerExplanation: String
    let estimatedImportance: String
    let commonMistake: String
}

struct OnboardingFlowPeriod: Identifiable {
    let id = UUID()
    let periodTitle: String
    let steps: [OnboardingFlowStep]
}

struct OnboardingFlow: Identifiable {
    let id = UUID()
    let profileType: ProfileType
    let periods: [OnboardingFlowPeriod]
}
