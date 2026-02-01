import SwiftUI

/// Wrapper view that initializes ZenArcade with its router and dismiss handling
struct ZenArcadeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var router = ZenArcadeRouter()
    
    var body: some View {
        ZenArcadeContentView(onDismiss: { dismiss() })
            .environment(router)
    }
}

/// Main content view for ZenArcade game suite
struct ZenArcadeContentView: View {
    @Environment(ZenArcadeRouter.self) private var router
        var onDismiss: () -> Void = {}


    var body: some View {
        ZStack {
            ZenArcadeTheme.Colors.background
                .ignoresSafeArea()
            
            Group {
                switch router.currentRoute {
                case .menu:
                    ZenArcadeMenuView()
                        .transition(.opacity)
                case .youVsAI:
                    YouVsAIView()
                        .transition(.opacity)
                case .wordSearch:
                    WordSearchView()
                        .transition(.opacity)
                case let .gameOver(gameType, result):
                    ZenArcadeGameOverView(gameType: gameType, result: result)
                        .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: router.currentRoute)
    }
}
