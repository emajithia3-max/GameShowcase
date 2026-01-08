import SwiftUI

enum Theme {
    enum Colors {
        static let background = Color(hex: "0B140F")
        static let cardFill = Color(hex: "0F1C15", alpha: 0.85)
        static let cardStroke = Color.white.opacity(0.06)
        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.65)
        static let accentBlue = Color(hex: "7FB8FF")
        static let accentGreen = Color(hex: "1C9D1F")
        static let accentRed = Color(hex: "FF6B6B")
    }

    enum Radius {
        static let card: CGFloat = 28
        static let button: CGFloat = 18
        static let small: CGFloat = 12
    }

    enum Spacing {
        static let xs: CGFloat = 6
        static let sm: CGFloat = 12
        static let md: CGFloat = 18
        static let lg: CGFloat = 28
    }

    enum Font {
        static func rounded(_ size: CGFloat, _ weight: SwiftUI.Font.Weight = .regular) -> SwiftUI.Font {
            .system(size: size, weight: weight, design: .rounded)
        }
    }
}
