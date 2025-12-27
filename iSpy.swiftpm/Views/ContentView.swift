import SwiftUI

struct ContentView: View {
    var body: some View {
        if #available (iOS 18.0, *){
            TabView{
                Tab("Home", systemImage: "house"){
                    NavigationStack{
                        HomeView()
                    }
                }
                
                Tab("Gallery", systemImage: "photo"){
                    
                }
                
                Tab("Profile", systemImage: "person"){
                    
                }
            }
        } else {}
    }
}
