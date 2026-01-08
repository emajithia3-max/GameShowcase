import Foundation

struct SeededRandomGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}

enum Difficulty: Int, CaseIterable {
    case easy = 1
    case medium = 2
    case hard = 3

    var operators: [MathOperator] {
        switch self {
        case .easy:
            return [.add, .subtract]
        case .medium:
            return [.add, .subtract, .multiply]
        case .hard:
            return [.add, .subtract, .multiply, .divide]
        }
    }

    var numberRange: ClosedRange<Int> {
        switch self {
        case .easy:
            return 1...12
        case .medium:
            return 2...20
        case .hard:
            return 5...50
        }
    }

    var aiBaseTime: TimeInterval {
        switch self {
        case .easy:
            return 2.5
        case .medium:
            return 2.0
        case .hard:
            return 1.5
        }
    }
}

enum MathOperator: String, CaseIterable {
    case add = "+"
    case subtract = "-"
    case multiply = "×"
    case divide = "÷"

    func apply(_ a: Int, _ b: Int) -> Int {
        switch self {
        case .add: return a + b
        case .subtract: return a - b
        case .multiply: return a * b
        case .divide: return a / b
        }
    }
}

struct Equation: Identifiable {
    let id = UUID()
    let leftOperand: Int
    let rightOperand: Int
    let op: MathOperator
    let answer: Int
    let wrongAnswers: [Int]

    var displayText: String {
        "\(leftOperand) \(op.rawValue) \(rightOperand)"
    }

    var allAnswers: [Int] {
        ([answer] + wrongAnswers).shuffled()
    }

    static func generate(difficulty: Difficulty, rng: inout SeededRandomGenerator) -> Equation {
        let ops = difficulty.operators
        let op = ops[Int.random(in: 0..<ops.count, using: &rng)]
        let range = difficulty.numberRange

        var a: Int
        var b: Int
        var answer: Int

        switch op {
        case .add:
            a = Int.random(in: range, using: &rng)
            b = Int.random(in: range, using: &rng)
            answer = a + b
        case .subtract:
            a = Int.random(in: range, using: &rng)
            b = Int.random(in: 1...a, using: &rng)
            answer = a - b
        case .multiply:
            a = Int.random(in: 2...12, using: &rng)
            b = Int.random(in: 2...12, using: &rng)
            answer = a * b
        case .divide:
            b = Int.random(in: 2...12, using: &rng)
            answer = Int.random(in: 2...12, using: &rng)
            a = b * answer
        }

        var wrongAnswers: [Int] = []
        while wrongAnswers.count < 2 {
            let offset = Int.random(in: 1...5, using: &rng) * (Bool.random(using: &rng) ? 1 : -1)
            let wrong = answer + offset
            if wrong != answer && wrong > 0 && !wrongAnswers.contains(wrong) {
                wrongAnswers.append(wrong)
            }
        }

        return Equation(leftOperand: a, rightOperand: b, op: op, answer: answer, wrongAnswers: wrongAnswers)
    }
}

struct RoundResult: Identifiable {
    let id = UUID()
    let round: Int
    let userAnsweredCorrectly: Bool
    let userTime: TimeInterval
    let aiTime: TimeInterval
    let userWon: Bool
}

struct YouVsAISession {
    let seed: UInt64
    let totalRounds: Int
    var currentRound: Int = 0
    var equations: [Equation] = []
    var roundResults: [RoundResult] = []
    var rng: SeededRandomGenerator

    var userWins: Int {
        roundResults.filter { $0.userWon }.count
    }

    var aiWins: Int {
        roundResults.filter { !$0.userWon }.count
    }

    var isComplete: Bool {
        currentRound >= totalRounds
    }

    var userTotalTime: TimeInterval {
        roundResults.reduce(0) { $0 + $1.userTime }
    }

    var userAverageTime: TimeInterval {
        guard !roundResults.isEmpty else { return 0 }
        return userTotalTime / Double(roundResults.count)
    }

    var correctAnswers: Int {
        roundResults.filter { $0.userAnsweredCorrectly }.count
    }

    init(seed: UInt64 = UInt64(Date().timeIntervalSince1970 * 1000), totalRounds: Int = 5) {
        self.seed = seed
        self.totalRounds = totalRounds
        self.rng = SeededRandomGenerator(seed: seed)
        generateEquations()
    }

    private mutating func generateEquations() {
        for i in 0..<totalRounds {
            let difficulty = difficultyForRound(i + 1)
            equations.append(Equation.generate(difficulty: difficulty, rng: &rng))
        }
    }

    private func difficultyForRound(_ round: Int) -> Difficulty {
        switch round {
        case 1...2:
            return .easy
        case 3...4:
            return .medium
        default:
            return .hard
        }
    }

    func aiTimeForRound(_ round: Int) -> TimeInterval {
        let difficulty = difficultyForRound(round)
        let baseTime = difficulty.aiBaseTime
        let variance = Double.random(in: -0.3...0.5)
        return baseTime + variance
    }
}

struct YouVsAIPersistence {
    private static let bestTimeKey = "youVsAI_bestTime"
    private static let winStreakKey = "youVsAI_winStreak"
    private static let currentStreakKey = "youVsAI_currentStreak"

    static var bestTime: TimeInterval? {
        get {
            let time = UserDefaults.standard.double(forKey: bestTimeKey)
            return time > 0 ? time : nil
        }
        set {
            if let time = newValue {
                UserDefaults.standard.set(time, forKey: bestTimeKey)
            }
        }
    }

    static var longestWinStreak: Int {
        get { UserDefaults.standard.integer(forKey: winStreakKey) }
        set { UserDefaults.standard.set(newValue, forKey: winStreakKey) }
    }

    static var currentStreak: Int {
        get { UserDefaults.standard.integer(forKey: currentStreakKey) }
        set { UserDefaults.standard.set(newValue, forKey: currentStreakKey) }
    }

    static func recordWin(totalTime: TimeInterval) {
        currentStreak += 1
        if currentStreak > longestWinStreak {
            longestWinStreak = currentStreak
        }
        if let best = bestTime {
            if totalTime < best {
                bestTime = totalTime
            }
        } else {
            bestTime = totalTime
        }
    }

    static func recordLoss() {
        currentStreak = 0
    }
}
