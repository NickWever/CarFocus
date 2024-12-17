import SwiftUI
import CoreData
import UIKit

struct VoegNieuwVoertuigToeWeergave: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    // Voertuig gegevens
    @State private var merk: String = ""
    @State private var type: String = ""
    @State private var kenteken: String = ""
    @State private var notities: String = ""
    
    // Afbeeldingen
    @State private var fotoLijst: [String] = ["Voorkant", "Achterkant", "Interieur"]
    @State private var optioneleFotoLijst: [String] = ["Extra Foto 1", "Extra Foto 2"]
    @State private var huidigeFotoIndex: Int = 0
    @State private var fotosOpgeslagen: [String] = []
    @State private var toonCamera = false
    @State private var geselecteerdeFoto: UIImage? = nil
    @State private var isCameraActive = false
    @State private var makenVanExtraFoto = false
    @State private var toonGroteFoto = false
    @State private var geselecteerdeFotoPad: IdentifiableString?

    // Foutmeldingen
    @State private var foutmelding = ""
    @State private var voertuigFolderPath: String? = nil

    var body: some View {
        ZStack {
            Theme.background.edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 20) {
                    Text("Voeg Nieuw Voertuig Toe")
                        .font(.largeTitle)
                        .foregroundColor(Theme.textColor)
                        .padding(.top)

                    voertuigInformatieSection
                    afbeeldingenSection
                    notitiesSection
                    opslaanKnop
                }
                .padding()
            }
        }
        .alert(isPresented: Binding<Bool>(get: { !foutmelding.isEmpty }, set: { _ in foutmelding = "" })) {
            Alert(title: Text("Fout"), message: Text(foutmelding), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $toonCamera) {
            CameraView(
                geselecteerdeFoto: $geselecteerdeFoto,
                isCameraActive: $isCameraActive,
                voltooiFoto: { afbeelding in
                    fotoOpgeslagen(afbeelding.fixedOrientation()) // Apply fixedOrientation before saving
                    updateFotoNaam() // Zorg ervoor dat de volgende foto automatisch wordt ingesteld
                },
                huidigeFotoNaam: Binding(get: { huidigeFotoNaam() }, set: { _ in })
            )
        }
        .fullScreenCover(item: $geselecteerdeFotoPad) { fotoPad in
            if let foto = FileManagerHelper.shared.loadImage(atPath: fotoPad.value) {
                FotoVergrotenView(image: .constant(foto), onClose: {
                    geselecteerdeFotoPad = nil
                }, onEdit: {
                    // Add edit action here if needed
                })
            }
        }
        .onAppear {
            laadFotoVolgorde()
            if voertuigFolderPath == nil {
                voertuigFolderPath = FileManagerHelper.shared.createFolderForVehicle(merk: merk, type: type, kenteken: kenteken, voertuigType: "Verkoop")?.path
            }
        }
    }

    private func huidigeFotoNaam() -> String {
        return makenVanExtraFoto ? optioneleFotoLijst[huidigeFotoIndex] : fotoLijst[huidigeFotoIndex]
    }

    private func updateFotoNaam() {
        if makenVanExtraFoto {
            huidigeFotoIndex = (huidigeFotoIndex + 1) % optioneleFotoLijst.count
        } else {
            huidigeFotoIndex = (huidigeFotoIndex + 1) % fotoLijst.count
            makenVanExtraFoto = huidigeFotoIndex == 0
        }
    }

    // MARK: - Functies voor opslaan en foto verwerking

    func fotoOpgeslagen(_ foto: UIImage) {
        guard let folderPath = voertuigFolderPath else {
            foutmelding = "Geen folderpad beschikbaar voor het voertuig"
            return
        }
        let fotoNaam = "\(UUID().uuidString).jpg"
        FileManagerHelper.shared.slaFotoOpInMap(image: foto, naam: fotoNaam, folderPath: folderPath) { fotoPad in
            if let fotoPad = fotoPad {
                fotosOpgeslagen.append(fotoPad)
                geselecteerdeFoto = nil
            } else {
                foutmelding = "Fout bij het opslaan van de foto"
            }
        }
    }
    func laadFotoVolgorde() {
        fotoLijst = UserDefaults.standard.object(forKey: "fotoLijstNieuweVoertuigen") as? [String] ?? ["Voorkant", "Achterkant", "Interieur"]
    }

    func slaVoertuigOp() {
        guard !merk.isEmpty, !type.isEmpty, !kenteken.isEmpty else {
            foutmelding = "Vul alle voertuiggegevens in voordat je het voertuig opslaat."
            return
        }

        if voertuigFolderPath == nil {
            voertuigFolderPath = FileManagerHelper.shared.createFolderForVehicle(merk: merk, type: type, kenteken: kenteken, voertuigType: "Verkoop")?.path
        }

        let nieuwVoertuig = VoertuigEntity(context: viewContext)
        nieuwVoertuig.id = UUID()
        nieuwVoertuig.merk = merk
        nieuwVoertuig.type = type
        nieuwVoertuig.kenteken = kenteken
        nieuwVoertuig.fotoPaths = fotosOpgeslagen
        nieuwVoertuig.notities = notities
        nieuwVoertuig.folderPath = voertuigFolderPath
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            foutmelding = "Fout bij het opslaan van het voertuig in Core Data: \(error.localizedDescription)"
        }
    }
    
    func verwijderFoto(fotoPad: String) {
        FileManagerHelper.shared.deleteImage(atPath: fotoPad)
        fotosOpgeslagen.removeAll { $0 == fotoPad }
    }
    
    // MARK: - Componenten voor de UI-secties

    private var voertuigInformatieSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            TextField("Merk", text: $merk)
                .padding()
                .background(Theme.textFieldBackground)
                .cornerRadius(10)
                .foregroundColor(Theme.textFieldText)
            
            TextField("Type", text: $type)
                .padding()
                .background(Theme.textFieldBackground)
                .cornerRadius(10)
                .foregroundColor(Theme.textFieldText)
            
            TextField("Kenteken", text: $kenteken)
                .padding()
                .background(Theme.textFieldBackground)
                .cornerRadius(10)
                .foregroundColor(Theme.textFieldText)
        }
        .padding(.horizontal)
    }

    private var afbeeldingenSection: some View {
        VStack {
            Text(huidigeFotoIndex < fotoLijst.count || makenVanExtraFoto ? "Maak foto: \(huidigeFotoNaam())" : "Alle verplichte foto's zijn gemaakt.")
                .font(.headline)
                .foregroundColor(Theme.textColor)
                .padding(.horizontal)

            Button(action: {
                toonCamera = true
                isCameraActive = true
            }) {
                Text(huidigeFotoIndex < fotoLijst.count || makenVanExtraFoto ? "Maak Foto voor \(huidigeFotoNaam())" : "Maak Extra Foto")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Theme.primaryButtonBackground)
                    .foregroundColor(Theme.buttonText)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(fotosOpgeslagen, id: \.self) { fotoPad in
                        VStack {
                            if let image = FileManagerHelper.shared.loadImage(atPath: fotoPad) {
                                Button(action: {
                                    geselecteerdeFotoPad = IdentifiableString(value: fotoPad)
                                }) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill() // Changed to scaledToFill
                                        .frame(width: 120, height: 120) // Changed frame size
                                        .clipShape(RoundedRectangle(cornerRadius: 15)) // Changed corner radius
                                        .shadow(radius: 5) // Added shadow
                                }
                            } else {
                                Text("Kan foto niet laden")
                                    .foregroundColor(.red)
                            }

                            Button(action: { verwijderFoto(fotoPad: fotoPad) }) {
                                Text("Verwijderen")
                                    .font(.footnote)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private var notitiesSection: some View {
        VStack(alignment: .leading) {
            Text("Voertuig Notities")
                .font(.headline)
                .foregroundColor(Theme.textColor)
                .padding(.top)

            TextEditor(text: $notities)
                .frame(height: 100)
                .padding()
                .background(Theme.secondaryButtonBackground)
                .cornerRadius(10)
                .foregroundColor(.black)
        }
    }

    private var opslaanKnop: some View {
        Button(action: { slaVoertuigOp() }) {
            Text("Opslaan Voertuig")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Theme.primaryButtonBackground)
                .foregroundColor(Theme.buttonText)
                .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}

struct IdentifiableString: Identifiable {
    let id = UUID()
    let value: String
}
