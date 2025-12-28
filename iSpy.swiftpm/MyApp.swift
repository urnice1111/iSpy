import SwiftUI

@available(iOS 17.0, *)
@main
struct MyApp: App {
    @State private var gameState = GameState()
    
    var body: some Scene {
        WindowGroup {
            ContentView(gameState: gameState)
        }
    }
}
