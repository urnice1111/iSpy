import SwiftUI

@available(iOS 17.0, *)
struct ProfileView: View {
    var gameState: GameState
    @State var showingResetGameAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 30) {
                    // Profile header
                    VStack(spacing: 15) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 100))
                            .foregroundStyle(.black)
                        
                        Text("Explorer")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.black)
                    }
                    .padding(.top, 40)
                    
                    
                    statisticsWidget(gameState: gameState)
                        .padding(.horizontal, 20)
                    
                    
                    
                    // Reset button (optional)
                    Button {
                        showingResetGameAlert = true
                    } label: {
                        Text("Reset Game")
                            .font(.body)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.1))
                            )
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    Spacer()
                }
            }
            .background(
                Rectangle()
                    .fill(Color("BackgroundColor"))
                    .scaledToFill()
                    .ignoresSafeArea()
            )
            .navigationTitle("Profile")
            .toolbarColorScheme(.light, for: .navigationBar)
            
        }
        .alert("Reset progress?",
               isPresented: $showingResetGameAlert
        ){
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive){
                gameState.resetGame()
            }
        } message: {
            Text("All progress so far will be deleted.")
        }
    }
    
}

@available(iOS 17.0, *)
struct statisticsWidget: View {
    let gameState: GameState
    
    var body: some View {
        HStack{
            Spacer()
            VStack{
                Text("Total points")
                    .foregroundStyle(Color.black)
                
                Text("\(gameState.totalScore)")
                    .foregroundStyle(Color.black)
                    .font(.title)
                    .bold()
                //                    .padding(.top,5)
                
            }.multilineTextAlignment(.center)
            
            Spacer()
            
            
            VStack{
                Text("Found objects")
                    .foregroundStyle(Color.black)
                Text("\(gameState.collectedItems.count)")
                    .foregroundStyle(Color.black)
                    .font(.title)
                    .bold()
                //                    .padding(.top,5)
                
            }.multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 35)
        .background(Color("WidgetColor"))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        
    }
}


#Preview {
    if #available(iOS 17.0, *) {
        ProfileView(gameState: GameState())
    } else {
        // Fallback on earlier versions
    }
}

