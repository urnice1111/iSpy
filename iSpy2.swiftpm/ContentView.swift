import SwiftUI

@available(iOS 26.0, *)
struct ContentView: View {
    
    @State private var gameState = GameState()
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            NavigationStack {
                GalleryView()
            }
                .tabItem {
                    Label("Gallery", systemImage: "photo.on.rectangle")
                }
        }
        .environment(gameState)
    }
}
