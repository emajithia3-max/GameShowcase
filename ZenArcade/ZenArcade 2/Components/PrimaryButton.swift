import SwiftUI

struct ZenArcadePrimaryButton: View {
    let title: String
    let action: () -> Void
    var style: ButtonStyle = .standard

    enum ButtonStyle {
        case standard
        case accent
        case destructive
    }

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(ZenArcadeTheme.Font.rounded(16, .semibold))
                .foregroundStyle(foregroundColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, ZenArcadeTheme.Spacing.sm)
                .padding(.horizontal, ZenArcadeTheme.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: ZenArcadeTheme.Radius.button)
                        .fill(backgroundColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: ZenArcadeTheme.Radius.button)
                        .stroke(strokeColor, lineWidth: 1)
                )
        }
        .buttonStyle(ZenArcadeScaleButtonStyle())
    }

    private var backgroundColor: Color {
        switch style {
        case .standard:
            return Color(hex: "1A2B22")
        case .accent:
            return ZenArcadeTheme.Colors.accentGreen
        case .destructive:
            return ZenArcadeTheme.Colors.accentRed.opacity(0.2)
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .standard, .accent:
            return ZenArcadeTheme.Colors.textPrimary
        case .destructive:
            return ZenArcadeTheme.Colors.accentRed
        }
    }

    private var strokeColor: Color {
        switch style {
        case .standard:
            return Color.white.opacity(0.08)
        case .accent:
            return ZenArcadeTheme.Colors.accentGreen.opacity(0.3)
        case .destructive:
            return ZenArcadeTheme.Colors.accentRed.opacity(0.3)
        }
    }
}

struct ZenArcadeScaleButtonStyle: SwiftUI.ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct ZenArcadeAnswerButton: View {
    let title: String
    let action: () -> Void
    var isCorrect: Bool? = nil
    var isSelected: Bool = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(ZenArcadeTheme.Font.rounded(20, .bold))
                .foregroundStyle(ZenArcadeTheme.Colors.textPrimary)
                .frame(width: 80, height: 56)
                .background(
                    RoundedRectangle(cornerRadius: ZenArcadeTheme.Radius.button)
                        .fill(backgroundColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: ZenArcadeTheme.Radius.button)
                        .stroke(strokeColor, lineWidth: isSelected ? 2 : 1)
                )
        }
        .buttonStyle(ZenArcadeScaleButtonStyle())
    }

    private var backgroundColor: Color {
        if let isCorrect, isSelected {
            return isCorrect ? ZenArcadeTheme.Colors.accentGreen.opacity(0.3) : ZenArcadeTheme.Colors.accentRed.opacity(0.3)
        }
        return Color(hex: "1A2B22")
    }

    private var strokeColor: Color {
        if let isCorrect, isSelected {
            return isCorrect ? ZenArcadeTheme.Colors.accentGreen : ZenArcadeTheme.Colors.accentRed
        }
        return Color.white.opacity(0.08)
    }
}

struct ZenArcadeCircleButton: View {
    let systemName: String
    let action: () -> Void
    var tint: Color = ZenArcadeTheme.Colors.textSecondary

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(Color(hex: "1A2B22"))
                )
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        }
        .buttonStyle(ZenArcadeScaleButtonStyle())
    }
}
