import SwiftUI


@available(iOS 18.0, *)
struct ContentView: View {
    var body: some View {
        TabView{
            
            Tab("Home", systemImage: "plus"){
                HomeView()
            }
            
        }
    }
}
