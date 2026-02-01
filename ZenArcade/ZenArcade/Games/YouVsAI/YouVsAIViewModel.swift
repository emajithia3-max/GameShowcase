import SwiftUI

@Observable
final class YouVsAIViewModel {
    private(set) var session: YouVsAISession
    private(set) var currentEquation: Equation?
    private(set) var shuffledAnswers: [Int] = []
    private(set) var gameStartTime: Date?
    private(set) var nomiProgress: Double = 0
    private(set) var selectedAnswer: Int?
    private(set) var showingResult: Bool = false
    private(set) var nomiTimer: Timer?
    private(set) var totalNomiTime: TimeInterval = 0
    private(set) var isComplete: Bool = false
    private(set) var showQuitConfirmation: Bool = false
    private(set) var nomiFinished: Bool = false
    private(set) var userElapsedTime: TimeInterval = 0

    var currentRound: Int {
        session.currentRound + 1
    }

    var totalRounds: Int {
        session.totalRounds
    }

    var userCorrectCount: Int {
        session.correctAnswers
    }

    var isCorrectAnswer: Bool? {
        guard let selected = selectedAnswer, let equation = currentEquation else { return nil }
        return selected == equation.answer
    }

    init(seed: UInt64? = nil) {
        let actualSeed = seed ?? UInt64(Date().timeIntervalSince1970 * 1000)
        self.session = YouVsAISession(seed: actualSeed)
    }

    func startGame() {
        session = YouVsAISession()
        isComplete = false
        nomiFinished = false
        userElapsedTime = 0

        totalNomiTime = calculateTotalNomiTime()

        gameStartTime = Date()
        startNomiTimer()
        startNextRound()
    }

    private func calculateTotalNomiTime() -> TimeInterval {
        var total: TimeInterval = 0
        for i in 1...session.totalRounds {
            total += session.aiTimeForRound(i)
        }
        return total
    }

    func startNextRound() {
        guard session.currentRound < session.totalRounds else {
            completeGame()
            return
        }

        currentEquation = session.equations[session.currentRound]
        if let eq = currentEquation {
            shuffledAnswers = eq.allAnswers
        }
        selectedAnswer = nil
        showingResult = false
    }

    private func startNomiTimer() {
        nomiTimer?.invalidate()
        let updateInterval: TimeInterval = 0.05

        nomiTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            guard let startTime = self.gameStartTime else { return }
            let elapsed = Date().timeIntervalSince(startTime)

            self.userElapsedTime = elapsed
            self.nomiProgress = min(elapsed / self.totalNomiTime, 1.0)

            if elapsed >= self.totalNomiTime && !self.nomiFinished {
                self.nomiFinished = true
                if !self.isComplete {
                    self.triggerHaptic(.warning)
                }
            }
        }
    }

    func selectAnswer(_ answer: Int) {
        guard selectedAnswer == nil, let equation = currentEquation else { return }

        selectedAnswer = answer

        let isCorrect = answer == equation.answer

        let result = RoundResult(
            round: session.currentRound + 1,
            userAnsweredCorrectly: isCorrect,
            userTime: userElapsedTime,
            aiTime: totalNomiTime,
            userWon: isCorrect
        )

        session.roundResults.append(result)
        showingResult = true

        triggerHaptic(isCorrect ? .success : .error)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.advanceRound()
        }
    }

    private func advanceRound() {
        session.currentRound += 1
        if session.currentRound >= session.totalRounds {
            completeGame()
        } else {
            startNextRound()
        }
    }

    private func completeGame() {
        isComplete = true
        nomiTimer?.invalidate()
    }

    func requestQuit() {
        showQuitConfirmation = true
    }

    func cancelQuit() {
        showQuitConfirmation = false
    }

    func confirmQuit() {
        showQuitConfirmation = false
        nomiTimer?.invalidate()
    }

    func getGameResult() -> GameResult {
        let userBeatNomi = userElapsedTime < totalNomiTime
        let allCorrect = session.correctAnswers == session.totalRounds
        let didWin = userBeatNomi && allCorrect

        YouVsAIPersistence.recordRoundsWon(session.correctAnswers, total: session.totalRounds)

        var stats: [String: String] = [:]
        stats["Correct"] = "\(session.correctAnswers)/\(session.totalRounds)"
        stats["Your Time"] = String(format: "%.1fs", userElapsedTime)
        stats["Nomi's Time"] = String(format: "%.1fs", totalNomiTime)

        if let best = YouVsAIPersistence.bestRoundsWon {
            stats["Best"] = "\(best)/\(session.totalRounds)"
        }

        return GameResult(
            won: didWin,
            score: session.correctAnswers,
            totalTime: userElapsedTime,
            stats: stats
        )
    }

    private func triggerHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}
