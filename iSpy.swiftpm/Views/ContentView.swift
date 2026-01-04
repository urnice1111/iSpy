import SwiftUI

@available(iOS 17.0, *)
struct ContentView: View {
    var gameState: GameState
    
    var body: some View {
        Group {
            if #available(iOS 18.0, *) {
                TabView {
                    Tab("Home", systemImage: "house.fill") {
                        NavigationStack {
                            HomeView(gameState: gameState)
                        }
                    }
                    
                    Tab("Gallery", systemImage: "photo.stack.fill") {
                        GalleryView(gameState: gameState)
                    }
                    
                    Tab("Profile", systemImage: "person.fill") {
                        ProfileView(gameState: gameState)
                    }
                }
//                .toolbarBackground(.visible, for: .tabBar)
//                .toolbarBackground(Color("BackgroundColor").opacity(0.9), for: .tabBar)
                .toolbarColorScheme(.light, for: .tabBar)
                .tint(.purple)
            } else {
                TabView {
                    NavigationStack {
                        HomeView(gameState: gameState)
                    }
                    .tabItem { 
                        Label("Home", systemImage: "house.fill")
                    }
                    
                    GalleryView(gameState: gameState)
                        .tabItem { 
                            Label("Gallery", systemImage: "photo.stack.fill")
                        }
                    
                    ProfileView(gameState: gameState)
                        .tabItem { 
                            Label("Profile", systemImage: "person.fill")
                        }
                }
                .tint(.purple)
            }
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    if #available(iOS 17.0, *) {
        ContentView(gameState: GameState())
    }
}
