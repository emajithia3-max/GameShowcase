import SwiftUI

struct MenuView: View {
    @Environment(AppRouter.self) private var router
    @State private var selectedIndex: Int? = nil

    var body: some View {
        ZStack {
            StarBackground()

            VStack {
                Spacer()

                HStack(spacing: 16) {
                    TiltedGameCard(
                        icon: "brain.head.profile",
                        title: "You vs AI",
                        subtitle: "Race against\nthe machine",
                        accentColor: Theme.Colors.accentBlue,
                        rotation: -4,
                        isSelected: selectedIndex == 0
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedIndex = 0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            router.navigate(to: .youVsAI)
                        }
                    }

                    TiltedGameCard(
                        icon: "textformat.abc",
                        title: "Word Search",
                        subtitle: "Find hidden\nwords",
                        accentColor: Theme.Colors.accentGreen,
                        rotation: 4,
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
                .padding(.horizontal, 20)

                Spacer()
            }
        }
        .onAppear {
            selectedIndex = nil
        }
    }
}

struct TiltedGameCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let accentColor: Color
    let rotation: Double
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 24) {
                Spacer().frame(height: 20)

                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 90, height: 90)

                    Image(systemName: icon)
                        .font(.system(size: 40))
                        .foregroundStyle(accentColor)
                }

                VStack(spacing: 8) {
                    Text(title)
                        .font(Theme.Font.rounded(20, .bold))
                        .foregroundStyle(Theme.Colors.textPrimary)

                    Text(subtitle)
                        .font(Theme.Font.rounded(14))
                        .foregroundStyle(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 280)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Theme.Colors.cardFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(accentColor.opacity(isSelected ? 0.6 : 0.12), lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: accentColor.opacity(isSelected ? 0.25 : 0.08), radius: isSelected ? 20 : 12, y: 8)
        }
        .buttonStyle(TiltedCardButtonStyle())
        .rotationEffect(.degrees(rotation))
        .scaleEffect(isSelected ? 1.03 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

struct TiltedCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
