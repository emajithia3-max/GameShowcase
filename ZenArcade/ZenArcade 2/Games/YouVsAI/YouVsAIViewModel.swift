import SwiftUI

@Observable
final class YouVsAIViewModel {
    private(set) var session: YouVsAISession
    private(set) var currentEquation: Equation?
    private(set) var shuffledAnswers: [Int] = []
    private(set) var gameStartTime: Date?
    private(set) var selectedAnswer: Int?
    private(set) var showingResult: Bool = false
    private(set) var nomiTimer: Timer?
    private(set) var isComplete: Bool = false
    private(set) var showQuitConfirmation: Bool = false
    private(set) var userElapsedTime: TimeInterval = 0

    private(set) var nomiCurrentRound: Int = 0
    private(set) var nomiQuestionProgress: Double = 0
    private(set) var nomiFinished: Bool = false
    private var nomiQuestionStartTime: Date?
    private var currentNomiQuestionTime: TimeInterval = 0

    var currentRound: Int {
        session.currentRound + 1
    }

    var totalRounds: Int {
        session.totalRounds
    }

    var userCorrectCount: Int {
        session.correctAnswers
    }

    var currentNomiEquation: Equation? {
        guard nomiCurrentRound < session.totalRounds else { return nil }
        return session.nomiEquations[nomiCurrentRound]
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
        nomiCurrentRound = 0
        nomiQuestionProgress = 0

        gameStartTime = Date()
        startNomiTimer()
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
    }

    private func startNomiTimer() {
        nomiTimer?.invalidate()
        nomiQuestionStartTime = Date()
        currentNomiQuestionTime = session.nomiTimes[nomiCurrentRound]

        let updateInterval: TimeInterval = 0.05

        nomiTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            guard let startTime = self.gameStartTime else { return }
            self.userElapsedTime = Date().timeIntervalSince(startTime)

            if self.nomiFinished { return }

            guard let questionStart = self.nomiQuestionStartTime else { return }
            let questionElapsed = Date().timeIntervalSince(questionStart)

            self.nomiQuestionProgress = min(questionElapsed / self.currentNomiQuestionTime, 1.0)

            if questionElapsed >= self.currentNomiQuestionTime {
                self.advanceNomi()
            }
        }
    }

    private func advanceNomi() {
        nomiCurrentRound += 1
        nomiQuestionProgress = 0

        if nomiCurrentRound >= session.totalRounds {
            nomiFinished = true
            triggerHaptic(.warning)

            if session.currentRound >= session.totalRounds {
                completeGame()
            }
        } else {
            nomiQuestionStartTime = Date()
            currentNomiQuestionTime = session.nomiTimes[nomiCurrentRound]
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
            aiTime: 0,
            userWon: isCorrect
        )

        session.roundResults.append(result)
        showingResult = true

        triggerHaptic(isCorrect ? .success : .error)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
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
        guard !isComplete else { return }
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

    func getGameResult() -> ZenArcadeGameResult {
        let userFinishedFirst = session.currentRound >= session.totalRounds && !nomiFinished
        let allCorrect = session.correctAnswers == session.totalRounds
        let didWin = userFinishedFirst && allCorrect

        YouVsAIPersistence.recordRoundsWon(session.correctAnswers, total: session.totalRounds)

        var stats: [String: String] = [:]
        stats["Correct"] = "\(session.correctAnswers)/\(session.totalRounds)"
        stats["Your Time"] = String(format: "%.1fs", userElapsedTime)

        if didWin {
            stats["Result"] = "You beat Nomi!"
        } else if !allCorrect {
            stats["Result"] = "Wrong answers"
        } else {
            stats["Result"] = "Nomi was faster"
        }

        if let best = YouVsAIPersistence.bestRoundsWon {
            stats["Best"] = "\(best)/\(session.totalRounds)"
        }

        return ZenArcadeGameResult(
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
