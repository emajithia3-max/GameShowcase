import SwiftUI

@Observable
final class YouVsAIViewModel {
    private(set) var session: YouVsAISession
    private(set) var currentEquation: Equation?
    private(set) var shuffledAnswers: [Int] = []
    private(set) var roundStartTime: Date?
    private(set) var aiProgress: Double = 0
    private(set) var selectedAnswer: Int?
    private(set) var showingResult: Bool = false
    private(set) var aiTimer: Timer?
    private(set) var targetAiTime: TimeInterval = 0
    private(set) var isComplete: Bool = false
    private(set) var showQuitConfirmation: Bool = false

    var currentRound: Int {
        session.currentRound + 1
    }

    var totalRounds: Int {
        session.totalRounds
    }

    var userWins: Int {
        session.userWins
    }

    var aiWins: Int {
        session.aiWins
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
        startNextRound()
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
        aiProgress = 0
        roundStartTime = Date()
        targetAiTime = session.aiTimeForRound(session.currentRound + 1)

        startAITimer()
    }

    private func startAITimer() {
        aiTimer?.invalidate()
        let updateInterval: TimeInterval = 0.05
        var elapsed: TimeInterval = 0

        aiTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            elapsed += updateInterval

            if self.showingResult {
                timer.invalidate()
                return
            }

            self.aiProgress = min(elapsed / self.targetAiTime, 1.0)

            if elapsed >= self.targetAiTime && self.selectedAnswer == nil {
                self.handleAIWin()
                timer.invalidate()
            }
        }
    }

    private func handleAIWin() {
        guard let equation = currentEquation else { return }

        let userTime: TimeInterval
        if let start = roundStartTime {
            userTime = Date().timeIntervalSince(start)
        } else {
            userTime = targetAiTime + 1
        }

        let result = RoundResult(
            round: session.currentRound + 1,
            userAnsweredCorrectly: false,
            userTime: userTime,
            aiTime: targetAiTime,
            userWon: false
        )

        session.roundResults.append(result)
        selectedAnswer = equation.answer
        showingResult = true

        triggerHaptic(.error)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.advanceRound()
        }
    }

    func selectAnswer(_ answer: Int) {
        guard selectedAnswer == nil, let equation = currentEquation else { return }

        aiTimer?.invalidate()
        selectedAnswer = answer

        let userTime: TimeInterval
        if let start = roundStartTime {
            userTime = Date().timeIntervalSince(start)
        } else {
            userTime = 0
        }

        let isCorrect = answer == equation.answer
        let userWon = isCorrect && userTime < targetAiTime

        let result = RoundResult(
            round: session.currentRound + 1,
            userAnsweredCorrectly: isCorrect,
            userTime: userTime,
            aiTime: targetAiTime,
            userWon: userWon
        )

        session.roundResults.append(result)
        showingResult = true

        triggerHaptic(isCorrect ? .success : .error)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
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
        aiTimer?.invalidate()
    }

    func requestQuit() {
        showQuitConfirmation = true
    }

    func cancelQuit() {
        showQuitConfirmation = false
    }

    func confirmQuit() {
        showQuitConfirmation = false
        aiTimer?.invalidate()
    }

    func getGameResult() -> GameResult {
        let didWin = session.userWins >= 3

        YouVsAIPersistence.recordRoundsWon(session.userWins, total: session.totalRounds)

        var stats: [String: String] = [:]
        stats["Rounds Won"] = "\(session.userWins)/\(session.totalRounds)"

        if let best = YouVsAIPersistence.bestRoundsWon {
            stats["Best"] = "\(best)/\(session.totalRounds)"
        }

        return GameResult(
            won: didWin,
            score: session.userWins,
            totalTime: session.userTotalTime,
            stats: stats
        )
    }

    private func triggerHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}
