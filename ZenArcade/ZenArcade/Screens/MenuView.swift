import SwiftUI

struct MenuView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        ZStack {
            StarBackground()

            VStack(spacing: 0) {
                NavigationHeader("Zen Session", rightAction: {})

                Spacer()

                CardView {
                    VStack(spacing: Theme.Spacing.lg) {
                        Text("Choose Your Challenge")
                            .font(Theme.Font.rounded(22, .bold))
                            .foregroundStyle(Theme.Colors.textPrimary)

                        GameTile(
                            icon: "brain.head.profile",
                            title: "You vs AI",
                            subtitle: "Race against the machine",
                            accentColor: Theme.Colors.accentBlue
                        ) {
                            router.navigate(to: .youVsAI)
                        }

                        GameTile(
                            icon: "textformat.abc",
                            title: "Word Search",
                            subtitle: "Find hidden words",
                            accentColor: Theme.Colors.accentGreen
                        ) {
                            router.navigate(to: .wordSearch)
                        }
                    }
                    .padding(.vertical, Theme.Spacing.sm)
                }
                .padding(.horizontal, Theme.Spacing.lg)

                Spacer()

                VStack(spacing: Theme.Spacing.xs) {
                    Text("Zen Arcade")
                        .font(Theme.Font.rounded(14, .medium))
                        .foregroundStyle(Theme.Colors.textSecondary)

                    Text("Focus. Breathe. Play.")
                        .font(Theme.Font.rounded(12))
                        .foregroundStyle(Theme.Colors.textSecondary.opacity(0.6))
                }
                .padding(.bottom, Theme.Spacing.lg)
            }
        }
    }
}

struct GameTile: View {
    let icon: String
    let title: String
    let subtitle: String
    let accentColor: Color
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.Radius.small)
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 56, height: 56)

                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundStyle(accentColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(Theme.Font.rounded(18, .semibold))
                        .foregroundStyle(Theme.Colors.textPrimary)

                    Text(subtitle)
                        .font(Theme.Font.rounded(14))
                        .foregroundStyle(Theme.Colors.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
            .padding(Theme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.button)
                    .fill(Color(hex: "1A2B22"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.button)
                    .stroke(accentColor.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
