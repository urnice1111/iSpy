import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.95, blue: 0.92)
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 56) {
                    
                    // MARK: - Hero
                    VStack(spacing: 16) {
                        Image("magnifier_icon")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                        
                        Text("Look Outside!")
                            .font(.custom("FredokaOne-Regular", size: 44))
                            .foregroundStyle(Color("Title"))
                        
                        Text("Next time you're in the car, peek out the window. The world is full of amazing things hiding in plain sight — you just have to look.")
                            .font(.system(.title3, design: .rounded, weight: .medium))
                            .foregroundStyle(.black.opacity(0.6))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 32)
                    
                    // MARK: - Did You Know
                    aboutSection(
                        icon: "binoculars.fill",
                        iconColor: .orange,
                        title: "Did You Know?",
                        body: "A single road trip can take you past hundreds of cool things. Traffic cones, funny signs, fire trucks, wind turbines...\n\nMost people zoom right past them. But not you."
                    )
                    
                    // MARK: - You're an Explorer
                    aboutSection(
                        icon: "camera.fill",
                        iconColor: .blue,
                        title: "You're an Explorer",
                        body: "With iSpy, every car ride becomes a treasure hunt. We'll give you a secret mission with things to find.\n\nWhen you spot one — point your iPad and snap! Our smart camera knows what you found."
                    )
                    
                    // MARK: - Make It Yours
                    aboutSection(
                        icon: "pencil.tip.crop.circle.fill",
                        iconColor: .purple,
                        title: "Make It Yours",
                        body: "Finding things is just the start. See a traffic cone? Maybe it reminds you of that scene in Toy Story where the toys sneak across the road!\n\nGrab your pencil and draw right on your photo. Add stickers. Tell a story. Turn an ordinary photo into something only you could make."
                    )
                    
                    // MARK: - Show Your Friends
                    aboutSection(
                        icon: "person.2.fill",
                        iconColor: .green,
                        title: "Show Your Friends",
                        body: "Save your creations and show the people you love. Maybe they'll start noticing cool things too.\n\nThe world looks different when you really pay attention."
                    )
                    
                    // MARK: - Closing
                    VStack(spacing: 12) {
                        Image("Star")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 70)
                        
                        Text("Every road trip is\na new adventure.")
                            .font(.custom("FredokaOne-Regular", size: 34))
                            .foregroundStyle(Color("Title"))
                            .multilineTextAlignment(.center)
                        
                        Text("Ready to explore?")
                            .font(.system(.title3, design: .rounded, weight: .medium))
                            .foregroundStyle(.black.opacity(0.6))
                    }
                    .padding(.bottom, 48)
                }
                .padding(.horizontal, 40)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
        }
        .overlay(alignment: .topTrailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.secondary)
            }
            .padding(20)
        }
    }
    
    @ViewBuilder
    private func aboutSection(
        icon: String,
        iconColor: Color,
        title: String,
        body: String
    ) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 44))
                .foregroundStyle(iconColor)
                .padding(18)
                .background(
                    Circle()
                        .fill(iconColor.opacity(0.12))
                )
            
            Text(title)
                .font(.custom("FredokaOne-Regular", size: 32))
                .foregroundStyle(.black)
            
            Text(body)
                .font(.system(.title3, design: .rounded, weight: .medium))
                .foregroundStyle(.black.opacity(0.6))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
