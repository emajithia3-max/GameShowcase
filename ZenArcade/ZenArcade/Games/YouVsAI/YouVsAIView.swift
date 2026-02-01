import SwiftUI

struct YouVsAIView: View {
    @Environment(AppRouter.self) private var router
    @State private var viewModel = YouVsAIViewModel()

    var body: some View {
        ZStack {
            StarBackground()

            VStack(spacing: 0) {
                Spacer().frame(height: 60)

                if let equation = viewModel.currentEquation {
                    AIMirrorView(
                        equation: equation,
                        answers: viewModel.shuffledAnswers,
                        progress: viewModel.nomiProgress,
                        nomiFinished: viewModel.nomiFinished
                    )
                    .padding(.horizontal, 24)
                }

                Spacer().frame(height: 32)

                ProgressDotsView(
                    total: viewModel.totalRounds,
                    current: viewModel.currentRound - 1,
                    results: viewModel.session.roundResults
                )

                Spacer().frame(height: 16)

                VStack(spacing: 6) {
                    Text("Me vs. Nomi")
                        .font(Theme.Font.rounded(20, .bold))
                        .foregroundStyle(Theme.Colors.textPrimary)

                    Text("Solve 5 equations faster than Nomi!")
                        .font(Theme.Font.rounded(15))
                        .foregroundStyle(Theme.Colors.textSecondary)
                }

                Spacer().frame(height: 40)

                CardView {
                    VStack(spacing: 28) {
                        if let equation = viewModel.currentEquation {
                            HStack(spacing: Theme.Spacing.sm) {
                                Text(equation.displayText)
                                    .font(Theme.Font.rounded(44, .bold))
                                    .foregroundStyle(Theme.Colors.textPrimary)

                                AnswerBox(isAnswered: viewModel.selectedAnswer != nil)
                            }
                            .frame(height: 60)
                        }

                        HStack(spacing: Theme.Spacing.md) {
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
                    .padding(.vertical, 20)
                }
                .padding(.horizontal, 24)
                .modifier(ShakeEffect(shakes: viewModel.isCorrectAnswer == false ? 2 : 0))

                Spacer()

                CircleButton(systemName: "xmark", action: {
                    viewModel.requestQuit()
                }, tint: Theme.Colors.accentRed)
                .padding(.bottom, 32)
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
    let nomiFinished: Bool

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 12) {
                Image("nomi")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text("Nomi")
                        .font(Theme.Font.rounded(18, .semibold))
                        .foregroundStyle(Theme.Colors.textSecondary.opacity(0.6))

                    if nomiFinished {
                        Text("FINISHED!")
                            .font(Theme.Font.rounded(10, .bold))
                            .foregroundStyle(Theme.Colors.nomiGreen)
                    }
                }
            }
            .rotationEffect(.degrees(180))

            HStack(spacing: Theme.Spacing.md) {
                ForEach(answers, id: \.self) { answer in
                    Text("\(answer)")
                        .font(Theme.Font.rounded(20, .bold))
                        .foregroundStyle(Theme.Colors.textSecondary.opacity(0.4))
                        .frame(width: 80, height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.Radius.button)
                                .fill(Color.white.opacity(0.02))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.Radius.button)
                                .stroke(Color.white.opacity(0.04), lineWidth: 1)
                        )
                }
            }

            HStack(spacing: Theme.Spacing.sm) {
                Text(equation.displayText)
                    .font(Theme.Font.rounded(44, .bold))
                    .foregroundStyle(Theme.Colors.textSecondary.opacity(0.35))

                RoundedRectangle(cornerRadius: 8)
                    .stroke(Theme.Colors.nomiGreen.opacity(0.35), lineWidth: 2)
                    .frame(width: 48, height: 48)
            }
            .frame(height: 60)

            GeometryReader { geo in
                ZStack(alignment: .trailing) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.05))
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(nomiFinished ? Theme.Colors.nomiGreen : Theme.Colors.nomiGreen.opacity(0.6))
                        .frame(width: geo.size.width * progress, height: 4)
                        .animation(.linear(duration: 0.05), value: progress)
                }
            }
            .frame(height: 4)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, Theme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.card)
                .fill(Theme.Colors.cardFill.opacity(0.5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.card)
                .stroke(nomiFinished ? Theme.Colors.nomiGreen.opacity(0.3) : Theme.Colors.cardStroke, lineWidth: 1)
        )
        .rotationEffect(.degrees(180))
    }
}

struct AnswerBox: View {
    let isAnswered: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(
                isAnswered ? Theme.Colors.nomiGreen : Theme.Colors.selectionGreen,
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
            return results[index].userAnsweredCorrectly ? Theme.Colors.nomiGreen : Theme.Colors.accentRed
        } else if index == current {
            return Theme.Colors.nomiGreen.opacity(0.5)
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
