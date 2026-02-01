import SwiftUI
import UIKit

@Observable
final class WordSearchViewModel {
    private(set) var session: WordSearchSession
    private(set) var currentSelection: [GridPosition] = []
    private(set) var currentWordIndex: Int = 0
    private(set) var elapsedTime: TimeInterval = 0
    private(set) var isComplete: Bool = false
    private(set) var showQuitConfirmation: Bool = false

    private var timer: Timer?
    private let successFeedback = UINotificationFeedbackGenerator()
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)

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

    init(difficulty: GridDifficulty? = nil, seed: UInt64? = nil) {
        let selectedDifficulty = difficulty ?? GridDifficulty.allCases.randomElement()!
        self.session = WordSearchSession(difficulty: selectedDifficulty, seed: seed)
    }

    func startGame() {
        session.start()
        startTimer()
        prepareHaptics()
    }

    private func prepareHaptics() {
        successFeedback.prepare()
        heavyImpact.prepare()
        mediumImpact.prepare()
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
                successFeedback.notificationOccurred(.success)
                heavyImpact.impactOccurred()

                if session.isComplete {
                    completeGame()
                } else {
                    advanceToNextWord()
                }
            }
        } else if !positions.isEmpty {
            mediumImpact.impactOccurred()
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

    func getGameResult() -> ZenArcadeGameResult {
        var stats: [String: String] = [:]
        stats["Difficulty"] = difficulty.rawValue.capitalized
        stats["Time"] = formatTime(session.elapsedTime)
        stats["Words Found"] = "\(session.foundWords.count)/\(session.grid.targetWords.count)"

        if let best = WordSearchPersistence.bestTime(for: difficulty) {
            stats["Your Best"] = formatTime(best)
        }

        return ZenArcadeGameResult(
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

}
