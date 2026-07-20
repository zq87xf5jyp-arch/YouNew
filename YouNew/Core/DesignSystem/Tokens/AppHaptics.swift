import Foundation

#if canImport(UIKit)
import UIKit
#endif

/// Centralized, short system haptics for discrete UI interactions.
/// `UIFeedbackGenerator` automatically becomes a no-op on unsupported hardware
/// and follows the device's system haptics setting.
@MainActor
enum AppHaptics {
#if canImport(UIKit)
    private static let selectionGenerator = UISelectionFeedbackGenerator()
    private static let lightImpactGenerator = UIImpactFeedbackGenerator(style: .light)
    private static let mediumImpactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private static let notificationGenerator = UINotificationFeedbackGenerator()
#endif

    static func prepare() {
#if canImport(UIKit)
        selectionGenerator.prepare()
        lightImpactGenerator.prepare()
        mediumImpactGenerator.prepare()
        notificationGenerator.prepare()
#endif
    }

    static func selection() {
#if canImport(UIKit)
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare()
#endif
    }

    static func lightImpact() {
#if canImport(UIKit)
        lightImpactGenerator.impactOccurred(intensity: 1.0)
        lightImpactGenerator.prepare()
#endif
    }

    static func mediumImpact() {
#if canImport(UIKit)
        mediumImpactGenerator.impactOccurred(intensity: 1.0)
        mediumImpactGenerator.prepare()
#endif
    }

    static func notificationSuccess() {
#if canImport(UIKit)
        notificationGenerator.notificationOccurred(.success)
        notificationGenerator.prepare()
#endif
    }

    static func notificationWarning() {
#if canImport(UIKit)
        notificationGenerator.notificationOccurred(.warning)
        notificationGenerator.prepare()
#endif
    }

    static func notificationError() {
#if canImport(UIKit)
        notificationGenerator.notificationOccurred(.error)
        notificationGenerator.prepare()
#endif
    }
}
