//
//  ObjectDetailView.swift
//  iSpy
//
//  Created by UwU on 22/02/26.
//
import SwiftUI


struct ObjectDetailView: View {
    
    
    var collectedItem: CollectedItem
    
    var body: some View {
        
        ZStack{
            
            Image("BackgroundOnboarding")
                .resizable()
                .ignoresSafeArea()
            
            HStack(alignment: .center, spacing: 0) {
                // Left half: Image
                Image(collectedItem.object.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity) // takes half due to equal expansion
                    .clipped()
//                    .background(Color.white)
//                    .clipShape(RoundedRectangle(cornerRadius: 40))
                    .padding()
                    

                // Right half: Details
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading){
                            Text(collectedItem.object.name)
                                .font(.custom("FredokaOne-Regular", size: 50))
                                .foregroundStyle(Color("StatsText"))
                                .lineLimit(1)
                            Text("Captured: \(collectedItem.timestamp.formatted(date: .abbreviated, time: .omitted))")
                                .font(.custom("FredokaOne-Regular", size: 20))
                                .foregroundStyle(Color("StatsText"))
                                .lineLimit(1)
                        }
                        Spacer()
                        HStack{
                            Image("Star")
                                .resizable()
                                .scaledToFit()
                                .frame(width:50)
                            
                            Text("\(collectedItem.object.points)")
                                .font(.custom("FredokaOne-Regular", size: 50))
                                .foregroundStyle(.black)
                                .lineLimit(1)
                        }
                    }
                    
                    // Quiz here:

                    
                    Spacer()

                }
                .frame(maxWidth: .infinity, alignment: .leading) // takes the other half
                .padding(50)
            }
        }
        
    }
}


#Preview {
    ObjectDetailView(
        collectedItem: CollectedItem(
            object: GameObject(name: "Traffic Cone", category: "Road", difficulty: .easy),
            challengeId: UUID()
        )
    )

}

