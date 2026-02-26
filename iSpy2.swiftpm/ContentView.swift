import SwiftUI
import TipKit

@available(iOS 26.0, *)
struct ContentView: View {
    
    @State private var gameState = GameState()
    @State private var selectedTab: Int = 0
    @AppStorage("hasSeenAbout") private var hasSeenAbout = false
    
    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                HomeView()
                    .opacity(selectedTab == 0 ? 1 : 0)
                    .allowsHitTesting(selectedTab == 0)
                
                NavigationStack {
                    GalleryView()
                }
                .opacity(selectedTab == 1 ? 1 : 0)
                .allowsHitTesting(selectedTab == 1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if !gameState.isCameraActive && !gameState.isFullScreenActive {
                CustomSidebar(selectedTab: $selectedTab)
                    .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: gameState.isCameraActive)
        .animation(.easeInOut(duration: 0.25), value: gameState.isFullScreenActive)
        .environment(gameState)
        .sheet(isPresented: Binding(
            get: { !hasSeenAbout },
            set: { if !$0 { hasSeenAbout = true } }
        )) {
            AboutView()
        }
        .onChange(of: hasSeenAbout) { _, seen in
            if seen {
                Task { await StartAdventureTip.aboutDismissed.donate() }
            }
        }
    }
}

// MARK: - Custom Sidebar

@available(iOS 26.0, *)
struct CustomSidebar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            SidebarButton(icon: "home_icon", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            
            SidebarButton(icon: "camera_icon", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            
            Spacer()
        }
        .frame(width: 150)
        .background(Color(red: 0.42, green: 0.78, blue: 0.22))
        .overlay(
            Rectangle()
                .fill(Color.black)
                .frame(width: 3),
            alignment: .leading
        )
        .ignoresSafeArea(edges: .vertical)
    }
}

@available(iOS 26.0, *)
struct SidebarButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 100)
                .padding(8)
                .contentShape(Rectangle())
                .opacity(isSelected ? 1.0 : 0.6)
        }
        .buttonStyle(.plain)
    }
}
