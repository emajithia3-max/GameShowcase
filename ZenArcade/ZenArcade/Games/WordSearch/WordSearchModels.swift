import Foundation

enum GridDifficulty: String, CaseIterable {
    case easy
    case medium
    case hard

    var gridSize: (rows: Int, cols: Int) {
        switch self {
        case .easy: return (8, 7)
        case .medium: return (9, 8)
        case .hard: return (10, 9)
        }
    }

    var wordCount: Int {
        switch self {
        case .easy: return 3
        case .medium: return 4
        case .hard: return 5
        }
    }

    var wordDifficulty: WordDifficulty {
        switch self {
        case .easy: return .easy
        case .medium: return .medium
        case .hard: return .hard
        }
    }
}

struct GridPosition: Hashable, Equatable {
    let row: Int
    let col: Int

    static func + (lhs: GridPosition, rhs: Direction) -> GridPosition {
        GridPosition(row: lhs.row + rhs.dRow, col: lhs.col + rhs.dCol)
    }
}

enum Direction: CaseIterable {
    case right, down, left, up
    case downRight, downLeft, upRight, upLeft

    var dRow: Int {
        switch self {
        case .up, .upRight, .upLeft: return -1
        case .down, .downRight, .downLeft: return 1
        case .left, .right: return 0
        }
    }

    var dCol: Int {
        switch self {
        case .left, .upLeft, .downLeft: return -1
        case .right, .upRight, .downRight: return 1
        case .up, .down: return 0
        }
    }

    var opposite: Direction {
        switch self {
        case .right: return .left
        case .left: return .right
        case .up: return .down
        case .down: return .up
        case .downRight: return .upLeft
        case .upLeft: return .downRight
        case .downLeft: return .upRight
        case .upRight: return .downLeft
        }
    }
}

struct PlacedWord {
    let word: String
    let start: GridPosition
    let direction: Direction
    var positions: [GridPosition] {
        var result: [GridPosition] = []
        var current = start
        for _ in word {
            result.append(current)
            current = current + direction
        }
        return result
    }
}

struct WordSearchGrid {
    let rows: Int
    let cols: Int
    private(set) var cells: [[Character]]
    private(set) var placedWords: [PlacedWord]
    let targetWords: [String]

    init(difficulty: GridDifficulty, seed: UInt64) {
        var rng = SeededRandomGenerator(seed: seed)
        let size = difficulty.gridSize
        self.rows = size.rows
        self.cols = size.cols
        self.cells = Array(repeating: Array(repeating: Character(" "), count: size.cols), count: size.rows)
        self.placedWords = []

        let words = WordLibrary.randomWords(
            count: difficulty.wordCount,
            difficulty: difficulty.wordDifficulty,
            rng: &rng
        )
        self.targetWords = words

        for word in words.sorted(by: { $0.count > $1.count }) {
            placeWord(word, rng: &rng)
        }

        fillEmpty(rng: &rng)
    }

    private mutating func placeWord(_ word: String, rng: inout SeededRandomGenerator) {
        var attempts = 0
        let maxAttempts = 100

        var directions = Direction.allCases
        directions.shuffle(using: &rng)

        while attempts < maxAttempts {
            attempts += 1

            let direction = directions[attempts % directions.count]
            let startRow = Int.random(in: 0..<rows, using: &rng)
            let startCol = Int.random(in: 0..<cols, using: &rng)
            let start = GridPosition(row: startRow, col: startCol)

            if canPlace(word: word, at: start, direction: direction) {
                place(word: word, at: start, direction: direction)
                return
            }
        }
    }

    private func canPlace(word: String, at start: GridPosition, direction: Direction) -> Bool {
        var pos = start
        for char in word {
            if pos.row < 0 || pos.row >= rows || pos.col < 0 || pos.col >= cols {
                return false
            }
            let existing = cells[pos.row][pos.col]
            if existing != " " && existing != char {
                return false
            }
            pos = pos + direction
        }
        return true
    }

    private mutating func place(word: String, at start: GridPosition, direction: Direction) {
        var pos = start
        for char in word {
            cells[pos.row][pos.col] = char
            pos = pos + direction
        }
        placedWords.append(PlacedWord(word: word, start: start, direction: direction))
    }

    private mutating func fillEmpty(rng: inout SeededRandomGenerator) {
        for row in 0..<rows {
            for col in 0..<cols {
                if cells[row][col] == " " {
                    cells[row][col] = WordLibrary.randomLetter(rng: &rng)
                }
            }
        }
    }

    func getPositions(for word: String) -> [GridPosition]? {
        for placed in placedWords {
            if placed.word == word {
                return placed.positions
            }
        }
        return nil
    }

    func validateSelection(_ positions: [GridPosition]) -> String? {
        guard positions.count >= 2 else { return nil }

        var selectedWord = ""
        for pos in positions {
            if pos.row >= 0 && pos.row < rows && pos.col >= 0 && pos.col < cols {
                selectedWord.append(cells[pos.row][pos.col])
            }
        }

        for placed in placedWords {
            if placed.word == selectedWord || String(placed.word.reversed()) == selectedWord {
                return placed.word
            }
        }

        return nil
    }
}

struct WordSearchSession {
    let seed: UInt64
    let difficulty: GridDifficulty
    let grid: WordSearchGrid
    var foundWords: Set<String> = []
    var startTime: Date?
    var endTime: Date?

    var isComplete: Bool {
        foundWords.count == grid.targetWords.count
    }

    var elapsedTime: TimeInterval {
        guard let start = startTime else { return 0 }
        let end = endTime ?? Date()
        return end.timeIntervalSince(start)
    }

    init(difficulty: GridDifficulty = .easy, seed: UInt64? = nil) {
        let actualSeed = seed ?? UInt64(Date().timeIntervalSince1970 * 1000)
        self.seed = actualSeed
        self.difficulty = difficulty
        self.grid = WordSearchGrid(difficulty: difficulty, seed: actualSeed)
    }

    mutating func start() {
        startTime = Date()
    }

    mutating func markFound(_ word: String) {
        foundWords.insert(word)
        if isComplete {
            endTime = Date()
        }
    }
}

struct WordSearchPersistence {
    private static func bestTimeKey(for difficulty: GridDifficulty) -> String {
        "wordSearch_bestTime_\(difficulty.rawValue)"
    }

    static func bestTime(for difficulty: GridDifficulty) -> TimeInterval? {
        let time = UserDefaults.standard.double(forKey: bestTimeKey(for: difficulty))
        return time > 0 ? time : nil
    }

    static func setBestTime(_ time: TimeInterval, for difficulty: GridDifficulty) {
        UserDefaults.standard.set(time, forKey: bestTimeKey(for: difficulty))
    }

    static func recordCompletion(time: TimeInterval, difficulty: GridDifficulty) {
        if let current = bestTime(for: difficulty) {
            if time < current {
                setBestTime(time, for: difficulty)
            }
        } else {
            setBestTime(time, for: difficulty)
        }
    }
}
