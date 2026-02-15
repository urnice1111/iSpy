//
//  Test.swift
//  iSpy
//
//  Created by UwU on 29/01/26.
//

import SwiftUI
import FoundationModels

@available(iOS 26.0, *)
struct AIView: View {
    @State private var output = "Esperando..."
    
    var body: some View {
        ScrollView {
            Text(output)
                .padding()
        }
        .task {
            await generateItinerary()
        }
    }
    
    
    
    func generateItinerary() async {
        let model = SystemLanguageModel.default
        
        guard model.availability == .available else {
            output = "Modelo no disponible: \(model.availability)"
            return
        }
        
        let session = LanguageModelSession(
            instructions: "You are a helpful travel assistant."
        )
        
        do {
            let response = try await session.respond(
                to: "Generate a 3-day travel itinerary to Tokyo, Japan."
            )
            output = response.content
        } catch {
            output = "Error: \(error)"
        }
    }
}


#Preview{
    if #available(iOS 26.0, *) {
        AIView()
    } else {
        // Fallback on earlier versions
    }
}
