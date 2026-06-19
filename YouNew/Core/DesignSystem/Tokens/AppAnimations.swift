import SwiftUI

enum AppAnimations {

    // MARK: - Core
    static let standard:        Animation = .easeInOut(duration: 0.22)
    static let softSpring:      Animation = .spring(response: 0.34, dampingFraction: 0.85)
    static let tactilePress:    Animation = .spring(response: 0.26, dampingFraction: 0.78, blendDuration: 0.1)
    static let smoothTransition: Animation = .easeInOut(duration: 0.28)

    // MARK: - Premium Card & Reveal
    static let cardReveal:    Animation = .spring(response: 0.44, dampingFraction: 0.82)
    static let onboardingStep: Animation = .spring(response: 0.52, dampingFraction: 0.86)

    // MARK: - Progress & Data
    static let progressFill: Animation = .easeOut(duration: 0.65)

    // MARK: - AI & Messages
    static let messagePop: Animation = .spring(response: 0.38, dampingFraction: 0.72)

    // MARK: - Ambient
    static let gentleBreathe:   Animation = .easeInOut(duration: 3.0).repeatForever(autoreverses: true)
    static let atmosphereFloat: Animation = .easeInOut(duration: 12.0).repeatForever(autoreverses: true)
}
