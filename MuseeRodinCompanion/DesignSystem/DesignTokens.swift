import SwiftUI
import UIKit

enum Spacing {
    static let xxSmall: CGFloat = 4
    static let xSmall: CGFloat = 8
    static let small: CGFloat = 12
    static let medium: CGFloat = 16
    static let large: CGFloat = 20
    static let xLarge: CGFloat = 24
    static let xxLarge: CGFloat = 32
}

enum CornerRadiusToken {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
}

enum BorderWidth {
    static let hairline: CGFloat = 0.5
    static let standard: CGFloat = 1
}

enum IconSize {
    static let small: CGFloat = 16
    static let medium: CGFloat = 20
    static let large: CGFloat = 28
}

enum AppColor {
    static let background = Color("AppBackground")
    static let card = Color("CardBackground")
    static let bronze = Color("AccentBronze")
    static let patina = Color("AccentPatina")
    static let border = Color.primary.opacity(0.12)
}

enum AppHaptics {
    @MainActor
    static func primary() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    @MainActor
    static func secondary() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

struct PressableButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.78), value: configuration.isPressed)
    }
}

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(Spacing.medium)
            .background(AppColor.card, in: RoundedRectangle(cornerRadius: CornerRadiusToken.medium, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: CornerRadiusToken.medium, style: .continuous)
                    .stroke(AppColor.border, lineWidth: BorderWidth.hairline)
            }
    }
}

extension View {
    func appCard() -> some View {
        modifier(CardModifier())
    }
}

enum AdaptiveContrast {
    static func foreground(for uiColor: UIColor) -> Color {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let luminance = (0.299 * red) + (0.587 * green) + (0.114 * blue)
        return luminance > 0.54 ? .black : .white
    }
}
