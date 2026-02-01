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
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Text("+")
                        .font(Theme.Font.rounded(28, .bold))
                        .foregroundStyle(Theme.Colors.nomiGreen.opacity(0.3))
                    Spacer()
                    Text("×")
                        .font(Theme.Font.rounded(24, .bold))
                        .foregroundStyle(Theme.Colors.nomiGreen.opacity(0.2))
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer()

                HStack {
                    Text("÷")
                        .font(Theme.Font.rounded(22, .bold))
                        .foregroundStyle(Theme.Colors.nomiGreen.opacity(0.2))
                    Spacer()
                    Text("−")
                        .font(Theme.Font.rounded(30, .bold))
                        .foregroundStyle(Theme.Colors.nomiGreen.opacity(0.25))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            }

            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Theme.Colors.selectionGreen.opacity(0.8))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Text("ME")
                                .font(Theme.Font.rounded(10, .bold))
                                .foregroundStyle(Theme.Colors.background)
                        )

                    Text("VS")
                        .font(Theme.Font.rounded(14, .black))
                        .foregroundStyle(Theme.Colors.textSecondary.opacity(0.6))

                    Image("nomi_fire")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                }

                Image("nomi_think")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)

                Text("5 + 3 = ?")
                    .font(Theme.Font.rounded(18, .semibold))
                    .foregroundStyle(Theme.Colors.textSecondary.opacity(0.7))
            }
        }
    }
}

struct WordSearchCardContent: View {
    private let letters = ["F", "I", "N", "D", "W", "O", "R", "D", "S"]

    var body: some View {
        ZStack {
            VStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { row in
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { col in
                            let index = row * 3 + col
                            Text(letters[index])
                                .font(Theme.Font.rounded(16, .medium))
                                .foregroundStyle(Theme.Colors.accentGreen.opacity(index == 0 || index == 4 || index == 8 ? 0.5 : 0.15))
                                .frame(width: 28, height: 28)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Theme.Colors.accentGreen.opacity(0.1), lineWidth: 1)
                                )
                        }
                    }
                }
            }
            .offset(x: -30, y: -50)
            .rotationEffect(.degrees(-8))

            VStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { row in
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { col in
                            Text(["Z", "E", "N", "C", "A", "L", "M", "P", "E"][row * 3 + col])
                                .font(Theme.Font.rounded(14, .medium))
                                .foregroundStyle(Theme.Colors.accentGreen.opacity(0.12))
                                .frame(width: 24, height: 24)
                                .background(
                                    RoundedRectangle(cornerRadius: 3)
                                        .stroke(Theme.Colors.accentGreen.opacity(0.08), lineWidth: 1)
                                )
                        }
                    }
                }
            }
            .offset(x: 35, y: 60)
            .rotationEffect(.degrees(5))

            VStack(spacing: 12) {
                Image("nomi_meditate")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)

                HStack(spacing: 2) {
                    ForEach(["P", "E", "A", "C", "E"], id: \.self) { letter in
                        Text(letter)
                            .font(Theme.Font.rounded(14, .bold))
                            .foregroundStyle(Theme.Colors.accentGreen)
                            .frame(width: 22, height: 26)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Theme.Colors.accentGreen.opacity(0.15))
                            )
                    }
                }

                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Theme.Colors.textSecondary.opacity(0.5))
            }
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
