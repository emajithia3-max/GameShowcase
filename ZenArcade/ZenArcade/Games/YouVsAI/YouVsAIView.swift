import SwiftUI

struct YouVsAIView: View {
    @Environment(AppRouter.self) private var router
    @State private var viewModel = YouVsAIViewModel()

    var body: some View {
        ZStack {
            StarBackground()

            VStack(spacing: 0) {
                Spacer().frame(height: 60)

                if let nomiEquation = viewModel.currentNomiEquation {
                    NomiMirrorView(
                        equation: nomiEquation,
                        questionProgress: viewModel.nomiQuestionProgress,
                        nomiFinished: viewModel.nomiFinished
                    )
                    .padding(.horizontal, 24)
                }

                Spacer().frame(height: 24)

                DualProgressView(
                    total: viewModel.totalRounds,
                    userCurrent: viewModel.currentRound - 1,
                    nomiCurrent: viewModel.nomiCurrentRound,
                    userResults: viewModel.session.roundResults,
                    nomiFinished: viewModel.nomiFinished
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

struct NomiMirrorView: View {
    let equation: Equation
    let questionProgress: Double
    let nomiFinished: Bool

    private var nomiImage: String {
        nomiFinished ? "nomi_fire" : "nomi_think"
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Image(nomiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Nomi")
                        .font(Theme.Font.rounded(16, .semibold))
                        .foregroundStyle(Theme.Colors.textSecondary.opacity(0.7))

                    if nomiFinished {
                        Text("FINISHED!")
                            .font(Theme.Font.rounded(10, .bold))
                            .foregroundStyle(Theme.Colors.nomiGreen)
                    }
                }
            }
            .rotationEffect(.degrees(180))

            HStack(spacing: Theme.Spacing.sm) {
                Text(nomiFinished ? "Done!" : equation.displayText)
                    .font(Theme.Font.rounded(32, .bold))
                    .foregroundStyle(Theme.Colors.textSecondary.opacity(0.4))

                if !nomiFinished {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Theme.Colors.nomiGreen.opacity(0.3), lineWidth: 2)
                        .frame(width: 40, height: 40)
                }
            }
            .frame(height: 50)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.05))
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(nomiFinished ? Theme.Colors.nomiGreen : Theme.Colors.nomiGreen.opacity(0.6))
                        .frame(width: geo.size.width * (nomiFinished ? 1.0 : questionProgress), height: 4)
                        .animation(.linear(duration: 0.05), value: questionProgress)
                }
            }
            .frame(height: 4)
        }
        .padding(.vertical, 16)
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

struct DualProgressView: View {
    let total: Int
    let userCurrent: Int
    let nomiCurrent: Int
    let userResults: [RoundResult]
    let nomiFinished: Bool

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(nomiFinished ? "nomi_fire" : "nomi_smile")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)

                HStack(spacing: 6) {
                    ForEach(0..<total, id: \.self) { index in
                        Circle()
                            .fill(nomiColorForDot(at: index))
                            .frame(width: 10, height: 10)
                    }
                }

                Spacer().frame(width: 24)
            }

            HStack(spacing: 8) {
                Circle()
                    .fill(Theme.Colors.selectionGreen.opacity(0.8))
                    .frame(width: 24, height: 24)
                    .overlay(
                        Text("ME")
                            .font(Theme.Font.rounded(8, .bold))
                            .foregroundStyle(Theme.Colors.background)
                    )

                HStack(spacing: 6) {
                    ForEach(0..<total, id: \.self) { index in
                        Circle()
                            .fill(userColorForDot(at: index))
                            .frame(width: 10, height: 10)
                    }
                }

                Spacer().frame(width: 24)
            }
        }
    }

    private func nomiColorForDot(at index: Int) -> Color {
        if index < nomiCurrent {
            return Theme.Colors.nomiGreen
        } else if index == nomiCurrent && !nomiFinished {
            return Theme.Colors.nomiGreen.opacity(0.5)
        }
        return Theme.Colors.textSecondary.opacity(0.2)
    }

    private func userColorForDot(at index: Int) -> Color {
        if index < userResults.count {
            return userResults[index].userAnsweredCorrectly ? Theme.Colors.selectionGreen : Theme.Colors.accentRed
        } else if index == userCurrent {
            return Theme.Colors.selectionGreen.opacity(0.5)
        }
        return Theme.Colors.textSecondary.opacity(0.2)
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
