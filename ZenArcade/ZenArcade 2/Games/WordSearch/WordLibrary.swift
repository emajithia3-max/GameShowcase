import Foundation

enum WordCategory: String, CaseIterable {
    case wellness = "Wellness"
    case focus = "Focus"
    case nature = "Nature"
    case growth = "Growth"
    case calm = "Calm"
    case confidence = "Confidence"
    case energy = "Energy"
}

enum WordDifficulty: Int, CaseIterable {
    case easy = 1
    case medium = 2
    case hard = 3

    var lengthRange: ClosedRange<Int> {
        switch self {
        case .easy: return 3...5
        case .medium: return 5...7
        case .hard: return 7...10
        }
    }
}

struct WordLibrary {
    private static let wordsByCategory: [WordCategory: [String]] = [
        .wellness: [
            "HEAL", "REST", "YOGA", "SPA", "ZEN", "FIT", "CARE", "WELL", "PURE", "LIFE",
            "HEALTH", "PEACE", "RELAX", "DREAM", "BLISS", "HAPPY", "SMILE", "FRESH", "WHOLE", "VITAL",
            "BALANCE", "HARMONY", "SERENITY", "REFRESH", "RESTORE", "RENEW", "NURTURE", "BREATHE", "MINDFUL", "HOLISTIC",
            "WELLNESS", "THERAPY", "HEALING", "PEACEFUL", "TRANQUIL", "SOOTHE", "COMFORT", "GENTLE", "TENDER", "NOURISH",
            "REJUVENATE", "INVIGORATE", "REVITALIZE", "MEDITATION", "SANCTUARY"
        ],
        .focus: [
            "AIM", "SEE", "TRY", "ACT", "WIN", "NOW", "KEY", "WAY", "SET", "FIX",
            "FOCUS", "THINK", "LEARN", "STUDY", "CLEAR", "SHARP", "ALERT", "AWARE", "QUICK", "SMART",
            "CLARITY", "PRESENT", "MINDSET", "INSIGHT", "ACHIEVE", "PURSUE", "COMMIT", "DECIDE", "DIRECT", "PRECISE",
            "ATTENTION", "PRIORITY", "DETERMINE", "CONCENTRATE", "INTENTION", "STRATEGY", "DEDICATION", "PERSISTENT", "DILIGENT", "RESOLUTE",
            "DISCIPLINE", "UNWAVERING", "PERSEVERE", "STEADFAST", "METICULOUS"
        ],
        .nature: [
            "SKY", "SUN", "SEA", "AIR", "DEW", "OAK", "ELM", "IVY", "BAY", "BOG",
            "TREE", "LEAF", "WAVE", "WIND", "RAIN", "SNOW", "MOON", "STAR", "LAKE", "HILL",
            "FOREST", "FLOWER", "GARDEN", "STREAM", "MEADOW", "VALLEY", "SUNSET", "BREEZE", "CLOUDS", "RIVER",
            "MOUNTAIN", "SUNRISE", "BLOSSOM", "WATERFALL", "HORIZON", "GLACIER", "CANYON", "PRAIRIE", "LAGOON", "ISLAND",
            "WILDERNESS", "EVERGREEN", "RAINFOREST", "ECOSYSTEM", "LANDSCAPE"
        ],
        .growth: [
            "GO", "UP", "NEW", "TRY", "ADD", "GET", "AIM", "RUN", "CAN", "YES",
            "GROW", "RISE", "GAIN", "MOVE", "LEAP", "SOAR", "CLIMB", "BUILD", "REACH", "EXCEL",
            "EVOLVE", "EXPAND", "THRIVE", "DEVELOP", "ADVANCE", "IMPROVE", "PROSPER", "FLOURISH", "SUCCEED", "ASCEND",
            "PROGRESS", "TRANSFORM", "OVERCOME", "MOMENTUM", "POTENTIAL", "EMPOWER", "CULTIVATE", "OPTIMIZE", "ACCELERATE", "ELEVATE",
            "BREAKTHROUGH", "ACCOMPLISH", "ACHIEVEMENT", "EXCELLENCE", "MASTERY"
        ],
        .calm: [
            "HUM", "LOW", "NAP", "OHM", "SIT", "LIE", "DIM", "COO", "SAT", "MUM",
            "CALM", "SLOW", "SOFT", "EASE", "HUSH", "MILD", "WARM", "GLOW", "FLOW", "DRIFT",
            "SERENE", "GENTLE", "PLACID", "MELLOW", "SMOOTH", "TENDER", "STEADY", "SILENT", "PACIFIC", "RELAXED",
            "TRANQUIL", "PEACEFUL", "STILLNESS", "COMPOSED", "UNTROUBLED", "CENTERED", "GROUNDED", "BALANCED", "SOOTHING", "QUIETUDE",
            "UNDISTURBED", "CONTENTED", "EFFORTLESS", "EQUANIMITY", "SERENITY"
        ],
        .confidence: [
            "CAN", "WIN", "OWN", "ACE", "TOP", "YES", "PRO", "FLY", "BOW", "VOW",
            "BOLD", "SURE", "TRUE", "FIRM", "SELF", "PROUD", "BRAVE", "DARING", "POWER", "TRUST",
            "BELIEVE", "CAPABLE", "CERTAIN", "ASSURED", "POISED", "SECURE", "STRONG", "WORTHY", "FEARLESS", "VALIANT",
            "CONFIDENT", "EMPOWERED", "COURAGEOUS", "RESILIENT", "AUTHENTIC", "UNSTOPPABLE", "DETERMINED", "ASSERTIVE", "TRIUMPHANT", "VICTORIOUS",
            "UNSHAKABLE", "INVINCIBLE", "INDOMITABLE", "UNWAVERING", "FORMIDABLE"
        ],
        .energy: [
            "GO", "RUN", "ZIP", "POP", "ZAP", "HOP", "JOG", "REV", "PEP", "VIM",
            "FIRE", "GLOW", "RUSH", "BUZZ", "PUMP", "PUSH", "BOLT", "ZEST", "SPARK", "SURGE",
            "ACTIVE", "LIVELY", "VIBRANT", "DYNAMIC", "RADIANT", "INTENSE", "SPIRITED", "VIGOROUS", "PULSING", "KINETIC",
            "ENERGIZE", "ELECTRIC", "POWERHOUSE", "EXPLOSIVE", "MAGNETIC", "VIVACIOUS", "EXUBERANT", "ELECTRIFY", "STIMULATE", "MOTIVATE",
            "UNSTOPPABLE", "EFFERVESCENT", "INVIGORATED", "ENTHUSIASTIC", "EXHILARATING"
        ]
    ]

    private static let letterFrequency: [Character: Int] = [
        "E": 12, "T": 9, "A": 8, "O": 7, "I": 7, "N": 7, "S": 6, "H": 6, "R": 6,
        "D": 4, "L": 4, "C": 3, "U": 3, "M": 3, "W": 2, "F": 2, "G": 2, "Y": 2,
        "P": 2, "B": 1, "V": 1, "K": 1, "J": 1, "X": 1, "Q": 1, "Z": 1
    ]

    static func randomWords(
        count: Int,
        difficulty: WordDifficulty,
        category: WordCategory? = nil,
        rng: inout SeededRandomGenerator
    ) -> [String] {
        var pool: [String] = []
        let lengthRange = difficulty.lengthRange

        if let cat = category {
            pool = wordsByCategory[cat]?.filter { lengthRange.contains($0.count) } ?? []
        } else {
            for (_, words) in wordsByCategory {
                pool.append(contentsOf: words.filter { lengthRange.contains($0.count) })
            }
        }

        pool = Array(Set(pool))
        pool.shuffle(using: &rng)

        return Array(pool.prefix(count))
    }

    static func randomLetter(rng: inout SeededRandomGenerator) -> Character {
        var weightedLetters: [Character] = []
        for (letter, weight) in letterFrequency {
            for _ in 0..<weight {
                weightedLetters.append(letter)
            }
        }
        let index = Int.random(in: 0..<weightedLetters.count, using: &rng)
        return weightedLetters[index]
    }

    static func allWords() -> [String] {
        var all: [String] = []
        for (_, words) in wordsByCategory {
            all.append(contentsOf: words)
        }
        return Array(Set(all))
    }
}
