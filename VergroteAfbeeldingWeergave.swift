//
//  VergroteAfbeeldingWeergave.swift
//  CarFocus
//
//  Created by Nick Wever on 13/11/2024.
//

import SwiftUI
import UIKit

struct VergroteAfbeeldingWeergave: View {
    var image: UIImage
    @State private var toonDeelSheet = false
    @Environment(\.presentationMode) var presentationMode
    var onEdit: (() -> Void)?
    var onRetake: (() -> Void)?

    var body: some View {
        VStack {
            Spacer()
            
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
                .padding()

            Spacer()

            HStack {
                Button(action: {
                    onEdit?()
                }) {
                    Text("Bewerk Foto")
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Spacer()

                Button(action: {
                    onRetake?()
                }) {
                    Text("Opnieuw Neem")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Spacer()

                Button(action: {
                    toonDeelSheet = true
                }) {
                    Text("Deel Foto")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .sheet(isPresented: $toonDeelSheet) {
                    DeelAfbeeldingViewController(image: image)
                }

                Spacer()

                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Sluiten")
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

// MARK: - DeelAfbeeldingViewController
struct DeelAfbeeldingViewController: UIViewControllerRepresentable {
    var image: UIImage

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [image], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
