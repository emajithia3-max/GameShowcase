import SwiftUI

enum GameType: String, Codable {
    case youVsAI = "You vs AI"
    case wordSearch = "Word Search"
}

struct GameResult: Codable {
    let won: Bool
    let score: Int
    let totalTime: TimeInterval
    let stats: [String: String]
}

enum Route: Equatable {
    case menu
    case youVsAI
    case wordSearch
    case gameOver(GameType, GameResult)

    static func == (lhs: Route, rhs: Route) -> Bool {
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
final class AppRouter {
    var currentRoute: Route = .menu
    private var routeHistory: [Route] = []

    func navigate(to route: Route) {
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
