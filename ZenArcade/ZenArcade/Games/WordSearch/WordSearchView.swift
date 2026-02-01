import SwiftUI

struct WordSearchView: View {
    @Environment(AppRouter.self) private var router
    @State private var viewModel = WordSearchViewModel()

    var body: some View {
        ZStack {
            StarBackground()

            VStack(spacing: 0) {
                Spacer()

                HStack(alignment: .top) {
                    Image("nomi_peek")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                        .opacity(0.8)

                    Spacer()

                    VStack(spacing: 8) {
                        Text("Find the words:")
                            .font(Theme.Font.rounded(15))
                            .foregroundStyle(Theme.Colors.textSecondary)

                        if let word = viewModel.currentWord {
                            Text(word)
                                .font(Theme.Font.rounded(34, .bold))
                                .foregroundStyle(Theme.Colors.textPrimary)
                                .contentTransition(.numericText())
                                .animation(.easeInOut, value: word)
                        }

                        Text(formatTime(viewModel.elapsedTime))
                            .font(Theme.Font.rounded(16, .medium))
                            .foregroundStyle(Theme.Colors.accentGreen)
                            .monospacedDigit()
                    }

                    Spacer()

                    Spacer().frame(width: 44)
                }
                .padding(.horizontal, 20)

                Spacer().frame(height: 28)

                WordProgressView(
                    words: viewModel.targetWords,
                    foundWords: viewModel.foundWords
                )
                .padding(.horizontal, 28)

                Spacer().frame(height: 28)

                CardView {
                    WordGridView(
                        grid: viewModel.grid,
                        foundWords: viewModel.foundWords,
                        currentSelection: viewModel.currentSelection,
                        onSelectionChanged: { positions in
                            viewModel.updateSelection(positions)
                        },
                        onSelectionEnded: { positions in
                            viewModel.endSelection(positions)
                        }
                    )
                    .frame(height: CGFloat(viewModel.grid.rows) * 40 + 24)
                }
                .padding(.horizontal, 20)

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
                router.navigate(to: .gameOver(.wordSearch, viewModel.getGameResult()))
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

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let tenths = Int((time.truncatingRemainder(dividingBy: 1)) * 10)

        if minutes > 0 {
            return String(format: "%d:%02d.%d", minutes, seconds, tenths)
        }
        return String(format: "%d.%ds", seconds, tenths)
    }
}

struct WordProgressView: View {
    let words: [String]
    let foundWords: Set<String>

    var body: some View {
        VStack(spacing: Theme.Spacing.xs) {
            ForEach(words, id: \.self) { word in
                WordProgressBar(
                    word: word,
                    isFound: foundWords.contains(word)
                )
            }
        }
    }
}

struct WordProgressBar: View {
    let word: String
    let isFound: Bool

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Text(word)
                .font(Theme.Font.rounded(14, .medium))
                .foregroundStyle(isFound ? Theme.Colors.accentGreen : Theme.Colors.textSecondary)
                .frame(width: 80, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Theme.Colors.accentGreen)
                        .frame(width: isFound ? geo.size.width : 0, height: 8)
                        .animation(.spring(duration: 0.3), value: isFound)
                }
            }
            .frame(height: 8)

            Image(systemName: isFound ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 16))
                .foregroundStyle(isFound ? Theme.Colors.accentGreen : Theme.Colors.textSecondary.opacity(0.3))
        }
    }
}
