import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            HStack {
                Text("1250")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundStyle(.white)
                
                Text("Points")
                    .font(.system(size: 35))
                    .foregroundStyle(.white)
                
                Spacer()
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
 
            GameWidget(
                title: "Road Trip",
                status: "Ready to start",
                imageName: "roadTrip"
            )
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image("backgroundPhoto")
                .resizable()
                .scaledToFill()
                .overlay(Color.black.opacity(0.25))
                .ignoresSafeArea()
                .blur(radius: 13)
        )
        .navigationTitle("Hey, Explorer!")
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
struct GameWidget: View {
    var title: String
    var status: String
    var imageName: String
    
    @State private var isGameActive = false
    
    var body: some View {
        VStack(spacing: 20) {
            
            HStack(spacing: 15) {
                
                Spacer()
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .shadow(radius: 5)
                
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text("Challenge:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    
                    Text(title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.leading)
                    
                    Text("Find 10 objects in your route!")
                        .font(.body)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
            }
            
            Button {
            } label: {
                Text("Start Challenge!")
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(Color.blue)
                    .clipShape(Capsule()) // Capsule es mejor que RoundedRectangle(100
                    .shadow(radius: 5)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    HomeView()
}
