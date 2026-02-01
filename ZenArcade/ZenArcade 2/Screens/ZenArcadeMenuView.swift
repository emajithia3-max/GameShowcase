import SwiftUI

struct ZenArcadeMenuView: View {
    @Environment(ZenArcadeRouter.self) private var router
    @State private var selectedIndex: Int? = nil
    var onDismiss: () -> Void = {}

    var body: some View {
        ZStack {
            StarBackground()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 8) {
                    Text("Pick a game to continue")
                        .font(ZenArcadeTheme.Font.rounded(24, .bold))
                        .foregroundStyle(ZenArcadeTheme.Colors.textPrimary)

                    Text("Random difficulty")
                        .font(ZenArcadeTheme.Font.rounded(16))
                        .foregroundStyle(ZenArcadeTheme.Colors.textSecondary)
                }

                Spacer().frame(height: 40)

                HStack(spacing: 16) {
                    ZenArcadeTiltedGameCard(
                        icon: "brain.head.profile",
                        title: "YOU VS AI",
                        accentColor: ZenArcadeTheme.Colors.accentBlue,
                        rotation: -5,
                        isSelected: selectedIndex == 0
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedIndex = 0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            router.navigate(to: .youVsAI)
                        }
                    }

                    ZenArcadeTiltedGameCard(
                        icon: "textformat.abc",
                        title: "WORD SEARCH",
                        accentColor: ZenArcadeTheme.Colors.accentGreen,
                        rotation: 5,
                        isSelected: selectedIndex == 1
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedIndex = 1
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            router.navigate(to: .wordSearch)
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                ZenArcadeCircleButton(systemName: "xmark", action: onDismiss, tint: ZenArcadeTheme.Colors.textSecondary)
                    .padding(.bottom, 32)
            }
        }
        .onAppear {
            selectedIndex = nil
        }
    }
}

struct ZenArcadeTiltedGameCard: View {
    let icon: String
    let title: String
    let accentColor: Color
    let rotation: Double
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Text(title)
                    .font(ZenArcadeTheme.Font.rounded(13, .semibold))
                    .foregroundStyle(ZenArcadeTheme.Colors.textPrimary)
                    .tracking(1)
                    .padding(.top, 20)
                    .padding(.horizontal, 12)

                Spacer()

                Image(systemName: icon)
                    .font(.system(size: 64, weight: .light))
                    .foregroundStyle(accentColor.opacity(0.7))

                Spacer()
                Spacer().frame(height: 30)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 360)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(ZenArcadeTheme.Colors.cardFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(accentColor.opacity(isSelected ? 0.5 : 0.1), lineWidth: 1)
            )
            .shadow(color: accentColor.opacity(isSelected ? 0.2 : 0.05), radius: isSelected ? 24 : 16, y: 10)
        }
        .buttonStyle(ZenArcadeTiltedCardButtonStyle())
        .rotationEffect(.degrees(rotation))
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

struct ZenArcadeTiltedCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
