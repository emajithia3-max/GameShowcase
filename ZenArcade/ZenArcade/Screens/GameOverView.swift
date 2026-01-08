import SwiftUI

struct GameOverView: View {
    @Environment(AppRouter.self) private var router
    let gameType: GameType
    let result: GameResult

    var body: some View {
        ZStack {
            StarBackground()

            VStack(spacing: 0) {
                NavigationHeader(gameType.rawValue)

                Spacer()

                CardView {
                    VStack(spacing: Theme.Spacing.lg) {
                        VStack(spacing: Theme.Spacing.sm) {
                            Image(systemName: result.won ? "trophy.fill" : "xmark.circle")
                                .font(.system(size: 48))
                                .foregroundStyle(result.won ? Theme.Colors.accentGreen : Theme.Colors.accentRed)

                            Text(result.won ? "Victory!" : "Game Over")
                                .font(Theme.Font.rounded(28, .bold))
                                .foregroundStyle(Theme.Colors.textPrimary)

                            Text(resultSubtitle)
                                .font(Theme.Font.rounded(16))
                                .foregroundStyle(Theme.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                        }

                        Divider()
                            .background(Theme.Colors.cardStroke)

                        VStack(spacing: Theme.Spacing.sm) {
                            ForEach(Array(result.stats.sorted(by: { $0.key < $1.key })), id: \.key) { key, value in
                                StatRow(label: key, value: value)
                            }
                        }

                        VStack(spacing: Theme.Spacing.sm) {
                            PrimaryButton(title: "Play Again", action: {
                                switch gameType {
                                case .youVsAI:
                                    router.navigate(to: .youVsAI)
                                case .wordSearch:
                                    router.navigate(to: .wordSearch)
                                }
                            }, style: .accent)

                            PrimaryButton(title: "Back to Menu", action: {
                                router.goToMenu()
                            })
                        }
                    }
                    .padding(.vertical, Theme.Spacing.sm)
                }
                .padding(.horizontal, Theme.Spacing.lg)

                Spacer()
            }
        }
    }

    private var resultSubtitle: String {
        switch gameType {
        case .youVsAI:
            return result.won ? "You outsmarted the AI!" : "The AI was faster this time."
        case .wordSearch:
            return result.won ? "All words found!" : "Better luck next time!"
        }
    }
}

struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(Theme.Font.rounded(14))
                .foregroundStyle(Theme.Colors.textSecondary)

            Spacer()

            Text(value)
                .font(Theme.Font.rounded(16, .semibold))
                .foregroundStyle(Theme.Colors.textPrimary)
        }
    }
}
