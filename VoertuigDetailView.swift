import SwiftUI
import UIKit

// MARK: - VoertuigDetailView
enum VoertuigType {
    case verkoop(VoertuigEntity)
    case inruil(InruilAutoEntity)
}

struct VoertuigDetailView: View {
    var voertuig: VoertuigType

    @State private var toonFotoVergroten = false
    @State private var geselecteerdeFoto: UIImage?
    @State private var geselecteerdeFotoPad: String?
    @State private var toonEditor = false
    @State private var notities: String = ""

    private let kolommen = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        ZStack {
            Theme.background.edgesIgnoringSafeArea(.all)

            ScrollView {  // Maakt de hele inhoud scrollbaar
                VStack(spacing: 20) {
                    Text(merkTekst)
                        .font(.largeTitle)
                        .foregroundColor(Theme.textColor)
                        .padding(.top)

                    Text(kentekenTekst)
                        .font(.title2)
                        .foregroundColor(Theme.textColor)

                    if let fotoPaths = fotoPaths, !fotoPaths.isEmpty {
                        LazyVGrid(columns: kolommen, spacing: 10) {
                            ForEach(fotoPaths, id: \.self) { path in
                                if let image = laadAfbeelding(fotoPad: path) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: UIScreen.main.bounds.width * 0.45, height: 150)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .shadow(radius: 3)
                                        .onTapGesture {
                                            geselecteerdeFoto = image
                                            geselecteerdeFotoPad = path
                                            toonFotoVergroten = true
                                        }
                                } else {
                                    Text("Foto niet beschikbaar")
                                        .foregroundColor(.red)
                                        .frame(width: UIScreen.main.bounds.width * 0.45, height: 150)
                                }
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        Text("Geen foto's beschikbaar")
                            .foregroundColor(.gray)
                    }

                    Text("Voertuig Notities")
                        .font(.headline)
                        .foregroundColor(Theme.textColor)
                        .padding(.top)

                    TextEditor(text: $notities)
                        .frame(height: 100)
                        .padding()
                        .background(Theme.textFieldBackground)
                        .cornerRadius(10)
                        .foregroundColor(Theme.textFieldText)
                        .padding(.horizontal)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)

                    Button(action: slaNotitiesOp) {
                        Text("Opslaan Notities")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Theme.primaryButtonBackground)
                            .foregroundColor(Theme.buttonText)
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 4)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
        }
        .fullScreenCover(isPresented: $toonFotoVergroten) {
            FotoVergrotenView(
                image: $geselecteerdeFoto,
                onClose: { toonFotoVergroten = false },
                onEdit: {
                    toonEditor = true
                }
            )
            .overlay(
                Group {
                    if toonEditor, let geselecteerdeFoto = geselecteerdeFoto {
                        AdvancedImageEditorView(image: geselecteerdeFoto) { updatedImage in
                            vervangEnSlaBewerkteFotoOp(updatedImage, fotoPad: geselecteerdeFotoPad!)
                            toonEditor = false
                        }
                        .background(Color.black.opacity(0.8))
                    }
                }
            )
        }
        .navigationTitle("Voertuig Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var merkTekst: String {
        switch voertuig {
        case .verkoop(let voertuigEntity):
            return voertuigEntity.merk ?? "Onbekend Merk"
        case .inruil(let inruilAutoEntity):
            return inruilAutoEntity.merk ?? "Onbekend Merk"
        }
    }

    private var kentekenTekst: String {
        switch voertuig {
        case .verkoop(let voertuigEntity):
            return voertuigEntity.kenteken ?? "Onbekend Kenteken"
        case .inruil(let inruilAutoEntity):
            return inruilAutoEntity.kenteken ?? "Onbekend Kenteken"
        }
    }

    private var fotoPaths: [String]? {
        switch voertuig {
        case .verkoop(let voertuigEntity):
            return voertuigEntity.fotoPaths
        case .inruil(let inruilAutoEntity):
            return inruilAutoEntity.fotoPaths
        }
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
        // Hier kun je de notities opslaan in je inruilauto-object in Core Data
    }

    func vervangEnSlaBewerkteFotoOp(_ updatedImage: UIImage, fotoPad: String) {
        guard let imageData = updatedImage.jpegData(compressionQuality: 1.0) else {
            print("Fout bij het omzetten van de afbeelding naar JPEG-formaat")
            return
        }
        
        let fotoURL = URL(fileURLWithPath: fotoPad)
        do {
            try imageData.write(to: fotoURL)
            print("Bewerkte foto succesvol opgeslagen op \(fotoURL.path)")
        } catch {
            print("Fout bij het opslaan van de bewerkte foto: \(error.localizedDescription)")
        }
    }
}
