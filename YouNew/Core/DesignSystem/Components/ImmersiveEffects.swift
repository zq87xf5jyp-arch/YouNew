import SwiftUI
import CoreMotion
import Combine

enum TimeAwareAtmosphere {
    static func colors(at date: Date = .now) -> [Color] {
        switch Calendar.current.component(.hour, from: date) {
        case 5..<8:
            return [AppColors.dutchOrange.opacity(0.72), AppColors.warning.opacity(0.46), AppColors.routeLine.opacity(0.60)]
        case 8..<12:
            return [AppColors.routeLine.opacity(0.72), AppColors.emerald.opacity(0.36), AppColors.dutchOrange.opacity(0.38)]
        case 12..<17:
            return [AppColors.navyDeep, AppColors.routeLine.opacity(0.60), AppColors.emerald.opacity(0.24)]
        case 17..<20:
            return [AppColors.warning.opacity(0.62), AppColors.dutchOrange.opacity(0.62), AppColors.dutchRed.opacity(0.30)]
        default:
            return [AppColors.navyDeep, AppSurface.base, AppColors.routeLine.opacity(0.38)]
        }
    }
}

@MainActor
private final class DeviceTiltModel: ObservableObject {
    @Published var x: Double = 0
    @Published var y: Double = 0
    private let manager = CMMotionManager()

    func start() {
        guard manager.isDeviceMotionAvailable, !manager.isDeviceMotionActive else { return }
        manager.deviceMotionUpdateInterval = 1.0 / 20.0
        manager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let motion else { return }
            Task { @MainActor in
                self?.x = min(1, max(-1, motion.attitude.roll / 0.55))
                self?.y = min(1, max(-1, motion.attitude.pitch / 0.55))
            }
        }
    }

    func stop() {
        manager.stopDeviceMotionUpdates()
        x = 0
        y = 0
    }
}

private struct DeviceTiltModifier: ViewModifier {
    let intensity: Double
    @StateObject private var model = DeviceTiltModel()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .rotation3DEffect(.degrees(reduceMotion ? 0 : model.y * intensity), axis: (x: 1, y: 0, z: 0), perspective: 0.58)
            .rotation3DEffect(.degrees(reduceMotion ? 0 : -model.x * intensity), axis: (x: 0, y: 1, z: 0), perspective: 0.58)
            .offset(x: reduceMotion ? 0 : model.x * intensity * 0.45, y: reduceMotion ? 0 : model.y * intensity * 0.28)
            .animation(reduceMotion ? nil : .interactiveSpring(response: 0.24, dampingFraction: 0.82), value: model.x)
            .animation(reduceMotion ? nil : .interactiveSpring(response: 0.24, dampingFraction: 0.82), value: model.y)
            .onAppear { if !reduceMotion { model.start() } }
            .onDisappear { model.stop() }
            .onChange(of: reduceMotion) { _, isReduced in
                isReduced ? model.stop() : model.start()
            }
    }
}

extension View {
    func immersiveTilt(intensity: Double = 4.0) -> some View {
        modifier(DeviceTiltModifier(intensity: intensity))
    }
}

struct AchievementConfetti: View {
    let visible: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            ForEach(0..<24, id: \.self) { index in
                Capsule()
                    .fill(particleColor(index))
                    .frame(width: 6, height: 13)
                    .rotationEffect(.degrees(visible && !reduceMotion ? Double(index * 47) : 0))
                    .offset(
                        x: visible && !reduceMotion ? cos(Double(index) * 1.73) * Double(55 + (index % 5) * 18) : 0,
                        y: visible && !reduceMotion ? sin(Double(index) * 1.31) * Double(70 + (index % 4) * 22) : 0
                    )
                    .opacity(visible && !reduceMotion ? 0 : (visible ? 0.72 : 0))
                    .animation(
                        reduceMotion ? nil : .easeOut(duration: 1.05).delay(Double(index % 6) * 0.035),
                        value: visible
                    )
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func particleColor(_ index: Int) -> Color {
        [AppColors.dutchOrange, AppColors.warning, AppColors.routeLine, AppColors.emerald, AppColors.dutchRed][index % 5]
    }
}
