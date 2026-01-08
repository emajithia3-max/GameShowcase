import SwiftUI

struct YouVsAIView: View {
    @Environment(AppRouter.self) private var router
    @State private var viewModel = YouVsAIViewModel()

    var body: some View {
        ZStack {
            StarBackground()

            VStack(spacing: 0) {
                NavigationHeader("You vs AI", onDismiss: {
                    viewModel.requestQuit()
                })

                Spacer().frame(height: Theme.Spacing.md)

                ScoreBar(userWins: viewModel.userWins, aiWins: viewModel.aiWins)
                    .padding(.horizontal, Theme.Spacing.lg)

                Spacer().frame(height: Theme.Spacing.lg)

                VStack(spacing: Theme.Spacing.xs) {
                    Text("Solve faster than AI")
                        .font(Theme.Font.rounded(14))
                        .foregroundStyle(Theme.Colors.textSecondary)

                    Text("Round \(viewModel.currentRound) of \(viewModel.totalRounds)")
                        .font(Theme.Font.rounded(16, .medium))
                        .foregroundStyle(Theme.Colors.textPrimary)
                }

                Spacer().frame(height: Theme.Spacing.sm)

                ProgressDotsView(
                    total: viewModel.totalRounds,
                    current: viewModel.currentRound - 1,
                    results: viewModel.session.roundResults
                )

                Spacer().frame(height: Theme.Spacing.lg)

                CardView {
                    VStack(spacing: Theme.Spacing.lg) {
                        AIProgressBar(progress: viewModel.aiProgress)

                        if let equation = viewModel.currentEquation {
                            Text(equation.displayText)
                                .font(Theme.Font.rounded(48, .bold))
                                .foregroundStyle(Theme.Colors.textPrimary)
                                .frame(height: 60)
                        }

                        HStack(spacing: Theme.Spacing.sm) {
                            ForEach(viewModel.shuffledAnswers, id: \.self) { answer in
                                AnswerButton(
                                    title: "\(answer)",
                                    action: {
                                        viewModel.selectAnswer(answer)
                                    },
                                    isCorrect: viewModel.showingResult ? (answer == viewModel.currentEquation?.answer) : nil,
                                    isSelected: viewModel.selectedAnswer == answer
                                )
                            }
                        }
                    }
                    .padding(.vertical, Theme.Spacing.sm)
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .modifier(ShakeEffect(shakes: viewModel.isCorrectAnswer == false ? 2 : 0))

                Spacer()

                CircleButton(systemName: "xmark", action: {
                    viewModel.requestQuit()
                }, tint: Theme.Colors.accentRed)
                .padding(.bottom, Theme.Spacing.lg)
            }
        }
        .onAppear {
            viewModel.startGame()
        }
        .onChange(of: viewModel.isComplete) { _, isComplete in
            if isComplete {
                router.navigate(to: .gameOver(.youVsAI, viewModel.getGameResult()))
            }
        }
        .alert("Quit Game?", isPresented: Binding(
            get: { viewModel.showQuitConfirmation },
            set: { if !$0 { viewModel.cancelQuit() } }
        )) {
            Button("Cancel", role: .cancel) {
                viewModel.cancelQuit()
            }
            Button("Quit", role: .destructive) {
                viewModel.confirmQuit()
                router.goToMenu()
            }
        } message: {
            Text("Your progress will be lost.")
        }
    }
}

struct ScoreBar: View {
    let userWins: Int
    let aiWins: Int

    var body: some View {
        HStack {
            ScorePill(label: "YOU", score: userWins, color: Theme.Colors.accentGreen)
            Spacer()
            ScorePill(label: "AI", score: aiWins, color: Theme.Colors.accentRed)
        }
    }
}

struct ScorePill: View {
    let label: String
    let score: Int
    let color: Color

    var body: some View {
        HStack(spacing: Theme.Spacing.xs) {
            Text(label)
                .font(Theme.Font.rounded(12, .medium))
                .foregroundStyle(Theme.Colors.textSecondary)

            Text("\(score)")
                .font(Theme.Font.rounded(18, .bold))
                .foregroundStyle(color)
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.vertical, Theme.Spacing.xs)
        .background(
            Capsule()
                .fill(color.opacity(0.1))
        )
        .overlay(
            Capsule()
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct ProgressDotsView: View {
    let total: Int
    let current: Int
    let results: [RoundResult]

    var body: some View {
        HStack(spacing: Theme.Spacing.xs) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .fill(colorForDot(at: index))
                    .frame(width: 10, height: 10)
            }
        }
    }

    private func colorForDot(at index: Int) -> Color {
        if index < results.count {
            return results[index].userWon ? Theme.Colors.accentGreen : Theme.Colors.accentRed
        } else if index == current {
            return Theme.Colors.accentBlue
        }
        return Theme.Colors.textSecondary.opacity(0.3)
    }
}

struct AIProgressBar: View {
    let progress: Double

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text("AI solving...")
                    .font(Theme.Font.rounded(12))
                    .foregroundStyle(Theme.Colors.textSecondary)
                Spacer()
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [Theme.Colors.accentRed.opacity(0.6), Theme.Colors.accentRed],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress, height: 6)
                        .animation(.linear(duration: 0.05), value: progress)
                }
            }
            .frame(height: 6)
        }
    }
}

struct ShakeEffect: GeometryEffect {
    var shakes: Int
    var animatableData: CGFloat

    init(shakes: Int) {
        self.shakes = shakes
        self.animatableData = CGFloat(shakes)
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = sin(animatableData * .pi * 2) * 10
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}
