import SwiftUI

@Observable
final class WordSearchViewModel {
    private(set) var session: WordSearchSession
    private(set) var currentSelection: [GridPosition] = []
    private(set) var currentWordIndex: Int = 0
    private(set) var elapsedTime: TimeInterval = 0
    private(set) var isComplete: Bool = false
    private(set) var showQuitConfirmation: Bool = false

    private var timer: Timer?

    var currentWord: String? {
        let remaining = remainingWords
        return remaining.isEmpty ? nil : remaining[currentWordIndex % remaining.count]
    }

    var remainingWords: [String] {
        session.grid.targetWords.filter { !session.foundWords.contains($0) }
    }

    var foundWords: Set<String> {
        session.foundWords
    }

    var targetWords: [String] {
        session.grid.targetWords
    }

    var grid: WordSearchGrid {
        session.grid
    }

    var difficulty: GridDifficulty {
        session.difficulty
    }

    init(difficulty: GridDifficulty = .easy, seed: UInt64? = nil) {
        self.session = WordSearchSession(difficulty: difficulty, seed: seed)
    }

    func startGame() {
        session.start()
        startTimer()
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.elapsedTime = self?.session.elapsedTime ?? 0
        }
    }

    func updateSelection(_ positions: [GridPosition]) {
        currentSelection = positions
    }

    func endSelection(_ positions: [GridPosition]) {
        if let foundWord = session.grid.validateSelection(positions) {
            if !session.foundWords.contains(foundWord) {
                session.markFound(foundWord)
                triggerHaptic(.success)

                if session.isComplete {
                    completeGame()
                } else {
                    advanceToNextWord()
                }
            }
        } else if !positions.isEmpty {
            triggerHaptic(.warning)
        }

        currentSelection = []
    }

    private func advanceToNextWord() {
        if !remainingWords.isEmpty {
            currentWordIndex = (currentWordIndex + 1) % remainingWords.count
        }
    }

    private func completeGame() {
        timer?.invalidate()
        isComplete = true
        WordSearchPersistence.recordCompletion(time: session.elapsedTime, difficulty: session.difficulty)
    }

    func requestQuit() {
        showQuitConfirmation = true
    }

    func cancelQuit() {
        showQuitConfirmation = false
    }

    func confirmQuit() {
        showQuitConfirmation = false
        timer?.invalidate()
    }

    func getGameResult() -> GameResult {
        var stats: [String: String] = [:]
        stats["Difficulty"] = difficulty.rawValue.capitalized
        stats["Time"] = formatTime(session.elapsedTime)
        stats["Words Found"] = "\(session.foundWords.count)/\(session.grid.targetWords.count)"

        if let best = WordSearchPersistence.bestTime(for: difficulty) {
            stats["Your Best"] = formatTime(best)
        }

        return GameResult(
            won: session.isComplete,
            score: session.foundWords.count,
            totalTime: session.elapsedTime,
            stats: stats
        )
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

    private func triggerHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}
