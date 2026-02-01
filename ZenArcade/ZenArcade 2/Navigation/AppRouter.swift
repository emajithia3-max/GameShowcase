import SwiftUI

enum ZenArcadeGameType: String, Codable {
    case youVsAI = "You vs AI"
    case wordSearch = "Word Search"
}

struct ZenArcadeGameResult: Codable {
    let won: Bool
    let score: Int
    let totalTime: TimeInterval
    let stats: [String: String]
}

enum ZenArcadeRoute: Equatable {
    case menu
    case youVsAI
    case wordSearch
    case gameOver(ZenArcadeGameType, ZenArcadeGameResult)

    static func == (lhs: ZenArcadeRoute, rhs: ZenArcadeRoute) -> Bool {
        switch (lhs, rhs) {
        case (.menu, .menu), (.youVsAI, .youVsAI), (.wordSearch, .wordSearch):
            return true
        case let (.gameOver(type1, _), .gameOver(type2, _)):
            return type1 == type2
        default:
            return false
        }
    }
}

@Observable
final class ZenArcadeRouter {
    var currentRoute: ZenArcadeRoute = .menu
    private var routeHistory: [ZenArcadeRoute] = []

    func navigate(to route: ZenArcadeRoute) {
        routeHistory.append(currentRoute)
        withAnimation(.easeInOut(duration: 0.3)) {
            currentRoute = route
        }
    }

    func goBack() {
        if let previousRoute = routeHistory.popLast() {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentRoute = previousRoute
            }
        }
    }

    func goToMenu() {
        routeHistory.removeAll()
        withAnimation(.easeInOut(duration: 0.3)) {
            currentRoute = .menu
        }
    }
}

