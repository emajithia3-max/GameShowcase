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

                Spacer().frame(height: Theme.Spacing.sm)

                if let equation = viewModel.currentEquation {
                    AIMirrorView(
                        equation: equation,
                        answers: viewModel.shuffledAnswers,
                        progress: viewModel.aiProgress
                    )
                    .padding(.horizontal, Theme.Spacing.lg)
                }

                Spacer().frame(height: Theme.Spacing.md)

                ProgressDotsView(
                    total: viewModel.totalRounds,
                    current: viewModel.currentRound - 1,
                    results: viewModel.session.roundResults
                )

                Spacer().frame(height: Theme.Spacing.xs)

                VStack(spacing: 4) {
                    Text("You vs AI")
                        .font(Theme.Font.rounded(18, .bold))
                        .foregroundStyle(Theme.Colors.textPrimary)

                    Text("Solve 5 equations faster than AI.")
                        .font(Theme.Font.rounded(14))
                        .foregroundStyle(Theme.Colors.textSecondary)
                }

                Spacer().frame(height: Theme.Spacing.xs)

                ProgressDotsView(
                    total: viewModel.totalRounds,
                    current: viewModel.currentRound - 1,
                    results: viewModel.session.roundResults
                )

                Spacer().frame(height: Theme.Spacing.lg)

                CardView {
                    VStack(spacing: Theme.Spacing.lg) {
                        if let equation = viewModel.currentEquation {
                            HStack(spacing: Theme.Spacing.sm) {
                                Text(equation.displayText)
                                    .font(Theme.Font.rounded(42, .bold))
                                    .foregroundStyle(Theme.Colors.textPrimary)

                                AnswerBox(isAnswered: viewModel.selectedAnswer != nil)
                            }
                            .frame(height: 56)
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

struct AIMirrorView: View {
    let equation: Equation
    let answers: [Int]
    let progress: Double

    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            HStack(spacing: Theme.Spacing.sm) {
                ForEach(answers, id: \.self) { answer in
                    Text("\(answer)")
                        .font(Theme.Font.rounded(16, .semibold))
                        .foregroundStyle(Theme.Colors.textSecondary.opacity(0.5))
                        .frame(width: 50, height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.Radius.small)
                                .fill(Color.white.opacity(0.03))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.Radius.small)
                                .stroke(Color.white.opacity(0.05), lineWidth: 1)
                        )
                }
            }
            .rotationEffect(.degrees(180))

            HStack(spacing: Theme.Spacing.xs) {
                Text(equation.displayText)
                    .font(Theme.Font.rounded(28, .bold))
                    .foregroundStyle(Theme.Colors.textSecondary.opacity(0.4))

                RoundedRectangle(cornerRadius: 6)
                    .stroke(Theme.Colors.accentRed.opacity(0.4), lineWidth: 2)
                    .frame(width: 36, height: 36)
            }
            .rotationEffect(.degrees(180))

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.05))
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(Theme.Colors.accentRed.opacity(0.6))
                        .frame(width: geo.size.width * progress, height: 4)
                        .animation(.linear(duration: 0.05), value: progress)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, Theme.Spacing.lg)
        }
        .padding(Theme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.card)
                .fill(Color.white.opacity(0.02))
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.card)
                .stroke(Color.white.opacity(0.04), lineWidth: 1)
        )
    }
}

struct AnswerBox: View {
    let isAnswered: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(
                isAnswered ? Theme.Colors.accentGreen : Theme.Colors.accentBlue,
                lineWidth: 2
            )
            .frame(width: 48, height: 48)
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
