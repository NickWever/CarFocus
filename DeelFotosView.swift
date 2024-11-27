//
//  DeelFotosView.swift
//  CarFocus
//
//  Created by Nick Wever on 08/10/2024.
//

import SwiftUICore
import SwiftUI

struct DeelFotosView: View {
    @State private var toonDeelSheet = false
    var fotoPaths: [String]
    var voertuigID: String
    
    var body: some View {
        Button(action: {
            toonDeelSheet = true
        }) {
            Text("Deel foto's")
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .sheet(isPresented: $toonDeelSheet) {
            deelFotos(fotoPaths: fotoPaths, voertuigID: voertuigID)
        }
    }
}
