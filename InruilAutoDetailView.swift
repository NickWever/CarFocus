//
//  InruilAutoDetailView.swift
//  CarFocus
//
//  Created by Nick Wever on 22/10/2024.
//

import SwiftUI
import UIKit

struct InruilAutoDetailView: View {
    var voertuig: InruilAutoEntity

    @State private var toonFotoGalerij = false
    @State private var geselecteerdeFoto: UIImage? = nil
    @State private var notities: String = ""

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text(voertuig.merk ?? "Onbekend Merk")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.top)

                Text(voertuig.kenteken ?? "Onbekend Kenteken")
                    .font(.title2)
                    .foregroundColor(.gray)

                if let fotoPaths = voertuig.fotoPaths, !fotoPaths.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(fotoPaths, id: \.self) { path in
                                if let image = laadAfbeelding(fotoPad: path) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 150, height: 150)
                                        .padding()
                                        .onTapGesture {
                                            geselecteerdeFoto = image
                                            toonFotoGalerij = true
                                        }
                                } else {
                                    Text("Foto niet beschikbaar")
                                        .foregroundColor(.red)
                                        .frame(width: 150, height: 150)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                } else {
                    Text("Geen foto's beschikbaar")
                        .foregroundColor(.gray)
                }

                Text("Inruilauto Notities")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top)

                TextEditor(text: $notities)
                    .frame(height: 100)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal)

                Button(action: {
                    slaNotitiesOp()
                }) {
                    Text("Opslaan Notities")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                Spacer()
            }
        }
        .sheet(isPresented: $toonFotoGalerij) {
            if let geselecteerdeFoto = geselecteerdeFoto {
                VergroteAfbeeldingWeergave(image: geselecteerdeFoto, onEdit: {
                    // Logica om de foto te bewerken
                }, onRetake: {
                    // Logica om de foto opnieuw te nemen
                })
            }
        }
        .navigationTitle("Inruilauto Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    func laadAfbeelding(fotoPad: String) -> UIImage? {
        let fotoURL = URL(fileURLWithPath: fotoPad)
        if let imageData = try? Data(contentsOf: fotoURL) {
            return UIImage(data: imageData)
        }
        return nil
    }

    func slaNotitiesOp() {
        print("Notities opgeslagen: \(notities)")
    }
}
