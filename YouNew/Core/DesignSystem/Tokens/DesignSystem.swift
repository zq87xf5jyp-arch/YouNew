import SwiftUI

struct ShadowToken {
    let color: Color
    let radius: CGFloat
    let y: CGFloat
}

enum DS {
    enum Color {
        static let bg0 = SwiftUI.Color(red: 6 / 255, green: 8 / 255, blue: 15 / 255)
        static let bg1 = AppSurface.base
        static let bg2 = AppSurface.e1
        static let bg3 = AppSurface.e2
        static let bg4 = AppSurface.e3
        static let bg5 = SwiftUI.Color(red: 31 / 255, green: 42 / 255, blue: 66 / 255)

        static let b0 = SwiftUI.Color.white.opacity(0.04)
        static let b1 = SwiftUI.Color.white.opacity(0.07)
        static let b2 = AppSurface.b2
        static let b3 = AppSurface.b3

        static let orange = AppColors.dutchOrange
        static let orange2 = SwiftUI.Color(red: 234 / 255, green: 101 / 255, blue: 8 / 255)
        static let orangeGlow = AppColors.dutchOrange.opacity(0.35)

        static let teal = AppColors.cyanGlow
        static let teal2 = SwiftUI.Color(red: 20 / 255, green: 184 / 255, blue: 166 / 255)
        static let blue = SwiftUI.Color(red: 59 / 255, green: 130 / 255, blue: 246 / 255)

        static let red = AppColors.error
        static let green = AppColors.success
        static let amber = AppColors.warning

        static let t1 = AppColors.textPrimary
        static let t2 = AppColors.textSecondary
        static let t3 = AppColors.textTertiary
        static let t4 = SwiftUI.Color(red: 45 / 255, green: 55 / 255, blue: 72 / 255)

        static let mapLand = SwiftUI.Color(red: 22 / 255, green: 40 / 255, blue: 64 / 255)
        static let mapLandAlt = SwiftUI.Color(red: 26 / 255, green: 48 / 255, blue: 72 / 255)
        static let mapWater = SwiftUI.Color(red: 10 / 255, green: 24 / 255, blue: 40 / 255)
        static let mapBorder = AppColors.cyanGlow.opacity(0.30)
        static let mapSelected = AppColors.dutchOrange
    }

    enum Font {
        static func display(_ size: CGFloat = 52) -> SwiftUI.Font {
            .system(size: size, weight: .semibold, design: .default)
        }

        static func heading(_ size: CGFloat = 20) -> SwiftUI.Font {
            .system(size: size, weight: .bold, design: .rounded)
        }

        static func ui(_ size: CGFloat = 14, weight: SwiftUI.Font.Weight = .semibold) -> SwiftUI.Font {
            .system(size: size, weight: weight, design: .rounded)
        }

        static func body(_ size: CGFloat = 14) -> SwiftUI.Font {
            .system(size: size, weight: .regular, design: .default)
        }

        static func caption(_ size: CGFloat = 11) -> SwiftUI.Font {
            .system(size: size, weight: .medium, design: .rounded)
        }

        static func mono(_ size: CGFloat = 14) -> SwiftUI.Font {
            .system(size: size, weight: .bold, design: .monospaced)
        }
    }

    enum Space {
        static let x2: CGFloat = 2
        static let x4: CGFloat = 4
        static let x8: CGFloat = 8
        static let x10: CGFloat = 10
        static let x12: CGFloat = 12
        static let x16: CGFloat = 16
        static let x20: CGFloat = 20
        static let x24: CGFloat = 24
        static let x32: CGFloat = 32
        static let x40: CGFloat = 40
        static let x48: CGFloat = 48
        static let x64: CGFloat = 64
    }

    enum Radius {
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 28
        static let xxl: CGFloat = 36
        static let full: CGFloat = 999
    }

    enum Shadow {
        static let card = [
            ShadowToken(color: .black.opacity(0.40), radius: 24, y: 10),
            ShadowToken(color: .black.opacity(0.16), radius: 6, y: 2)
        ]
        static let accentOrange = [
            ShadowToken(color: DS.Color.orange.opacity(0.45), radius: 20, y: 6)
        ]
        static let accentTeal = [
            ShadowToken(color: DS.Color.teal.opacity(0.35), radius: 16, y: 4)
        ]
    }
}

struct PressableModifier: ViewModifier {
    let targetScale: CGFloat

    func body(content: Content) -> some View {
        content
    }
}

struct StaggeredAppear: ViewModifier {
    let index: Int
    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : (reduceMotion ? 0 : 18))
            .onAppear {
                withAnimation(reduceMotion ? nil : .spring(response: 0.48, dampingFraction: 0.78).delay(Double(index) * 0.055 + 0.1)) {
                    appeared = true
                }
            }
    }
}

extension View {
    func cardStyle(elevation: Int = 1, cornerRadius: CGFloat = DS.Radius.lg) -> some View {
        let bg: SwiftUI.Color = elevation == 1 ? DS.Color.bg3 : elevation == 2 ? DS.Color.bg4 : DS.Color.bg5
        return self
            .background(bg)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(DS.Color.b2, lineWidth: 0.5)
            )
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.06), .clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                    .frame(height: cornerRadius * 2)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            }
    }

    func pressable(scale: CGFloat = 0.96) -> some View {
        modifier(PressableModifier(targetScale: scale))
    }

    func shadows(_ tokens: [ShadowToken]) -> some View {
        tokens.reduce(AnyView(self)) { view, token in
            AnyView(view.shadow(color: token.color, radius: token.radius, x: 0, y: token.y))
        }
    }

    func sectionPadding() -> some View {
        padding(.horizontal, DS.Space.x16)
    }

    func staggeredAppear(index: Int, total: Int = 8) -> some View {
        modifier(StaggeredAppear(index: index))
    }
}
