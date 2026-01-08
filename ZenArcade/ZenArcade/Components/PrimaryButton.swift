import SwiftUI

struct PrimaryButton: View {
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
                .font(Theme.Font.rounded(16, .semibold))
                .foregroundStyle(foregroundColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.sm)
                .padding(.horizontal, Theme.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.button)
                        .fill(backgroundColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.button)
                        .stroke(strokeColor, lineWidth: 1)
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private var backgroundColor: Color {
        switch style {
        case .standard:
            return Color(hex: "1A2B22")
        case .accent:
            return Theme.Colors.accentGreen
        case .destructive:
            return Theme.Colors.accentRed.opacity(0.2)
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .standard, .accent:
            return Theme.Colors.textPrimary
        case .destructive:
            return Theme.Colors.accentRed
        }
    }

    private var strokeColor: Color {
        switch style {
        case .standard:
            return Color.white.opacity(0.08)
        case .accent:
            return Theme.Colors.accentGreen.opacity(0.3)
        case .destructive:
            return Theme.Colors.accentRed.opacity(0.3)
        }
    }
}

struct ScaleButtonStyle: SwiftUI.ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct AnswerButton: View {
    let title: String
    let action: () -> Void
    var isCorrect: Bool? = nil
    var isSelected: Bool = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.Font.rounded(20, .bold))
                .foregroundStyle(Theme.Colors.textPrimary)
                .frame(width: 80, height: 56)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.button)
                        .fill(backgroundColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.button)
                        .stroke(strokeColor, lineWidth: isSelected ? 2 : 1)
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private var backgroundColor: Color {
        if let isCorrect, isSelected {
            return isCorrect ? Theme.Colors.accentGreen.opacity(0.3) : Theme.Colors.accentRed.opacity(0.3)
        }
        return Color(hex: "1A2B22")
    }

    private var strokeColor: Color {
        if let isCorrect, isSelected {
            return isCorrect ? Theme.Colors.accentGreen : Theme.Colors.accentRed
        }
        return Color.white.opacity(0.08)
    }
}

struct CircleButton: View {
    let systemName: String
    let action: () -> Void
    var tint: Color = Theme.Colors.textSecondary

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
        .buttonStyle(ScaleButtonStyle())
    }
}
