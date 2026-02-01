import SwiftUI

struct ZenArcadeGameOverView: View {
    @Environment(ZenArcadeRouter.self) private var router
    let gameType: ZenArcadeGameType
    let result: ZenArcadeGameResult

    private var nomiImage: String {
        switch gameType {
        case .youVsAI:
            return result.won ? "nomi_love" : "nomi_fire"
        case .wordSearch:
            return result.won ? "nomi_love" : "nomi_smile"
        }
    }

    var body: some View {
        ZStack {
            StarBackground()

            VStack(spacing: 0) {
                Spacer()

                CardView {
                    VStack(spacing: ZenArcadeTheme.Spacing.lg) {
                        VStack(spacing: ZenArcadeTheme.Spacing.sm) {
                            Image(nomiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)

                            Text(result.won ? "Victory!" : "Game Over")
                                .font(ZenArcadeTheme.Font.rounded(28, .bold))
                                .foregroundStyle(ZenArcadeTheme.Colors.textPrimary)

                            Text(resultSubtitle)
                                .font(ZenArcadeTheme.Font.rounded(16))
                                .foregroundStyle(ZenArcadeTheme.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                        }

                        Divider()
                            .background(ZenArcadeTheme.Colors.cardStroke)

                        VStack(spacing: ZenArcadeTheme.Spacing.sm) {
                            ForEach(Array(result.stats.sorted(by: { $0.key < $1.key })), id: \.key) { key, value in
                                ZenArcadeStatRow(label: key, value: value)
                            }
                        }

                        VStack(spacing: ZenArcadeTheme.Spacing.sm) {
                            ZenArcadePrimaryButton(title: "Play Again", action: {
                                switch gameType {
                                case .youVsAI:
                                    router.navigate(to: .youVsAI)
                                case .wordSearch:
                                    router.navigate(to: .wordSearch)
                                }
                            }, style: .accent)

                            ZenArcadePrimaryButton(title: "Back to Menu", action: {
                                router.goToMenu()
                            })
                        }
                    }
                    .padding(.vertical, ZenArcadeTheme.Spacing.sm)
                }
                .padding(.horizontal, ZenArcadeTheme.Spacing.lg)

                Spacer()
            }
        }
    }

    private var resultSubtitle: String {
        switch gameType {
        case .youVsAI:
            return result.won ? "You outsmarted Nomi!" : "Nomi was faster this time."
        case .wordSearch:
            return result.won ? "All words found!" : "Better luck next time!"
        }
    }
}

struct ZenArcadeStatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(ZenArcadeTheme.Font.rounded(14))
                .foregroundStyle(ZenArcadeTheme.Colors.textSecondary)

            Spacer()

            Text(value)
                .font(ZenArcadeTheme.Font.rounded(16, .semibold))
                .foregroundStyle(ZenArcadeTheme.Colors.textPrimary)
        }
    }
}
