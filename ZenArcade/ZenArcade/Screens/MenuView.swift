import SwiftUI

struct MenuView: View {
    @Environment(AppRouter.self) private var router
    @State private var selectedIndex: Int? = nil

    var body: some View {
        ZStack {
            StarBackground()

            VStack {
                Spacer()

                ZStack {
                    TiltedGameCard(
                        icon: "textformat.abc",
                        title: "Word Search",
                        subtitle: "Find hidden words",
                        accentColor: Theme.Colors.accentGreen,
                        rotation: -8,
                        offset: CGSize(width: -20, height: 40),
                        isSelected: selectedIndex == 1
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedIndex = 1
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            router.navigate(to: .wordSearch)
                        }
                    }

                    TiltedGameCard(
                        icon: "brain.head.profile",
                        title: "You vs AI",
                        subtitle: "Race against the machine",
                        accentColor: Theme.Colors.accentBlue,
                        rotation: 6,
                        offset: CGSize(width: 15, height: -30),
                        isSelected: selectedIndex == 0
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedIndex = 0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            router.navigate(to: .youVsAI)
                        }
                    }
                }
                .frame(height: 380)

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
    let offset: CGSize
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 80, height: 80)

                    Image(systemName: icon)
                        .font(.system(size: 36))
                        .foregroundStyle(accentColor)
                }

                VStack(spacing: 6) {
                    Text(title)
                        .font(Theme.Font.rounded(24, .bold))
                        .foregroundStyle(Theme.Colors.textPrimary)

                    Text(subtitle)
                        .font(Theme.Font.rounded(15))
                        .foregroundStyle(Theme.Colors.textSecondary)
                }
            }
            .frame(width: 200, height: 220)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Theme.Colors.cardFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(accentColor.opacity(isSelected ? 0.6 : 0.15), lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: accentColor.opacity(isSelected ? 0.3 : 0.1), radius: isSelected ? 20 : 12, y: 8)
        }
        .buttonStyle(TiltedCardButtonStyle())
        .rotationEffect(.degrees(rotation))
        .offset(offset)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

struct TiltedCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
