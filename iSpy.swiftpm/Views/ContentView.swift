import SwiftUI

@available(iOS 17.0, *)
struct ContentView: View {
    var gameState: GameState
    
    var body: some View {
        if #available (iOS 18.0, *){
            TabView{
                Tab("Home", systemImage: "house"){
                    NavigationStack{
                        HomeView(gameState: gameState)
                    }
                }
                
                Tab("Gallery", systemImage: "photo"){
                    GalleryView(gameState: gameState)
                }
                
                Tab("Profile", systemImage: "person"){
                    ProfileView(gameState: gameState)
                }
            }
        } else {
            TabView {
                NavigationStack {
                    HomeView(gameState: gameState)
                }
                .tabItem { Label("Home", systemImage: "house") }
                
                GalleryView(gameState: gameState)
                    .tabItem { Label("Gallery", systemImage: "photo") }
                
                ProfileView(gameState: gameState)
                    .tabItem { Label("Profile", systemImage: "person") }
            }
        }
    }
}
