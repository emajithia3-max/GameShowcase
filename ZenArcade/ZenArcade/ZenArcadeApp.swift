import SwiftUI

@main
struct ZenArcadeApp: App {
    @State private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(router)
                .preferredColorScheme(.dark)
        }
    }
}

struct ContentView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        ZStack {
            Theme.Colors.background
                .ignoresSafeArea()

            Group {
                switch router.currentRoute {
                case .menu:
                    MenuView()
                        .transition(.opacity)
                case .youVsAI:
                    YouVsAIView()
                        .transition(.opacity)
                case .wordSearch:
                    WordSearchView()
                        .transition(.opacity)
                case let .gameOver(gameType, result):
                    GameOverView(gameType: gameType, result: result)
                        .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: router.currentRoute)
    }
}
