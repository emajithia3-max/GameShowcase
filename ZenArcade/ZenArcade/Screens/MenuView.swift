import SwiftUI

struct MenuView: View {
    @Environment(AppRouter.self) private var router
    @State private var selectedIndex: Int? = nil

    var body: some View {
        ZStack {
            StarBackground()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 8) {
                    Text("Pick a game to continue")
                        .font(Theme.Font.rounded(24, .bold))
                        .foregroundStyle(Theme.Colors.textPrimary)

                    Text("Random difficulty")
                        .font(Theme.Font.rounded(16))
                        .foregroundStyle(Theme.Colors.textSecondary)
                }

                Spacer().frame(height: 40)

                HStack(spacing: 16) {
                    GameCard(
                        title: "ME VS. NOMI",
                        accentColor: Theme.Colors.nomiGreen,
                        rotation: -5,
                        isSelected: selectedIndex == 0,
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedIndex = 0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                router.navigate(to: .youVsAI)
                            }
                        }
                    ) {
                        MeVsNomiCardContent()
                    }

                    GameCard(
                        title: "WORD SEARCH",
                        accentColor: Theme.Colors.accentGreen,
                        rotation: 5,
                        isSelected: selectedIndex == 1,
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedIndex = 1
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                router.navigate(to: .wordSearch)
                            }
                        }
                    ) {
                        WordSearchCardContent()
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                CircleButton(systemName: "xmark", action: {}, tint: Theme.Colors.textSecondary)
                    .padding(.bottom, 32)
            }
        }
        .onAppear {
            selectedIndex = nil
        }
    }
}

struct MeVsNomiCardContent: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            HStack(spacing: 12) {
                Circle()
                    .fill(Theme.Colors.selectionGreen)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text("ME")
                            .font(Theme.Font.rounded(12, .bold))
                            .foregroundStyle(Theme.Colors.background)
                    )

                Text("VS")
                    .font(Theme.Font.rounded(16, .black))
                    .foregroundStyle(Theme.Colors.textSecondary.opacity(0.5))

                Image("nomi_fire")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
            }

            Image("nomi_fire")
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 90)

            VStack(spacing: 6) {
                Text("7 × 8 = ?")
                    .font(Theme.Font.rounded(22, .bold))
                    .foregroundStyle(Theme.Colors.textPrimary.opacity(0.9))

                Text("Race to solve!")
                    .font(Theme.Font.rounded(13))
                    .foregroundStyle(Theme.Colors.textSecondary.opacity(0.6))
            }

            Spacer()
        }
    }
}

struct WordSearchCardContent: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image("nomi_meditate")
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 90)

            VStack(spacing: 8) {
                HStack(spacing: 3) {
                    ForEach(["C", "A", "L", "M"], id: \.self) { letter in
                        Text(letter)
                            .font(Theme.Font.rounded(16, .bold))
                            .foregroundStyle(Theme.Colors.foundGreen)
                            .frame(width: 28, height: 32)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Theme.Colors.foundGreen.opacity(0.2))
                            )
                    }
                }

                Text("Find hidden words")
                    .font(Theme.Font.rounded(13))
                    .foregroundStyle(Theme.Colors.textSecondary.opacity(0.6))
            }

            Spacer()
        }
    }
}

struct GameCard<Content: View>: View {
    let title: String
    let accentColor: Color
    let rotation: Double
    let isSelected: Bool
    let action: () -> Void
    @ViewBuilder let content: Content

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Text(title)
                    .font(Theme.Font.rounded(13, .semibold))
                    .foregroundStyle(Theme.Colors.textPrimary)
                    .tracking(1)
                    .padding(.top, 20)
                    .padding(.horizontal, 12)

                Spacer()

                content

                Spacer()
                Spacer().frame(height: 20)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 360)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Theme.Colors.cardFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(accentColor.opacity(isSelected ? 0.5 : 0.1), lineWidth: 1)
            )
            .shadow(color: accentColor.opacity(isSelected ? 0.2 : 0.05), radius: isSelected ? 24 : 16, y: 10)
        }
        .buttonStyle(TiltedCardButtonStyle())
        .rotationEffect(.degrees(rotation))
        .scaleEffect(isSelected ? 1.02 : 1.0)
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
