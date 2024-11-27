import SwiftUI
import CoreData

struct VoegInruilAutoToeWeergave: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @State private var merk: String = ""
    @State private var type: String = ""
    @State private var kenteken: String = ""
    @State private var fotoLijst: [String] = ["Voorkant", "Achterkant", "Interieur"]
    @State private var optioneleFotoLijst: [String] = ["Extra Foto 1", "Extra Foto 2"]
    @State private var huidigeFotoIndex: Int = 0
    @State private var makenVanExtraFoto = false
    @State private var geselecteerdeFoto: UIImage? = nil
    @State private var toonCamera = false
    @State private var fotosOpgeslagen: [String] = []
    @State private var foutmelding: String = ""
    @State private var notities: String = ""
    @State private var isCameraActive = false
    @State private var voertuigFolderPath: String? = nil

    var body: some View {
        ZStack {
            Theme.background.edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 20) {
                    Text("Voeg Inruilauto Toe")
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
                    fotoOpgeslagen(afbeelding)
                    updateFotoNaam() // Zorg ervoor dat de volgende foto automatisch wordt ingesteld
                },
                huidigeFotoNaam: Binding(get: { huidigeFotoNaam() }, set: { _ in })
            )
        }


        .onAppear {
            if voertuigFolderPath == nil {
                voertuigFolderPath = FileManagerHelper.shared.createFolderForVehicle(merk: merk, type: type, kenteken: kenteken, voertuigType: "Inruil")?.path
            }
        }
    }

    // MARK: - Functie voor huidige fotonaam ophalen
    private func huidigeFotoNaam() -> String {
        return makenVanExtraFoto ? optioneleFotoLijst[huidigeFotoIndex] : fotoLijst[huidigeFotoIndex]
    }

    private func updateFotoNaam() {
        if makenVanExtraFoto {
            huidigeFotoIndex = (huidigeFotoIndex + 1) % optioneleFotoLijst.count
        } else {
            huidigeFotoIndex += 1
            if huidigeFotoIndex >= fotoLijst.count {
                huidigeFotoIndex = 0
                makenVanExtraFoto = true
            }
        }
    }

    // MARK: - Functies voor afbeelding- en gegevensverwerking

    private func fotoOpgeslagen(_ foto: UIImage) {
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

    private func laadAfbeelding(fotoPad: String) -> UIImage? {
        FileManagerHelper.shared.loadImage(atPath: fotoPad)
    }

    private func verwijderFoto(fotoPad: String) {
        FileManagerHelper.shared.deleteImage(atPath: fotoPad)
        fotosOpgeslagen.removeAll { $0 == fotoPad }
    }

    private func slaInruilAutoOp() {
        guard !merk.isEmpty, !type.isEmpty, !kenteken.isEmpty else {
            foutmelding = "Vul alle voertuiggegevens in."
            return
        }

        FileManagerHelper.shared.slaInruilAutoOp(
            merk: merk,
            type: type,
            kenteken: kenteken,
            notities: notities,
            fotos: fotosOpgeslagen,
            context: viewContext
        )
        presentationMode.wrappedValue.dismiss()  // Keert terug naar het hoofdmenu
    }

    // MARK: - UI Secties
    private var voertuigInformatieSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            TextField("Merk", text: $merk)
                .textFieldStyle(CustomTextFieldStyle())

            TextField("Type", text: $type)
                .textFieldStyle(CustomTextFieldStyle())

            TextField("Kenteken", text: $kenteken)
                .textFieldStyle(CustomTextFieldStyle())
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
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 100)
                                    .cornerRadius(10)
                                    .onTapGesture {
                                        bewerkFotoOpties(fotoPad: fotoPad)
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
                .foregroundColor(Theme.textFieldText)
        }
        .padding(.horizontal)
    }

    private var opslaanKnop: some View {
        Button(action: {
            slaInruilAutoOp()
        }) {
            Text("Opslaan Inruilauto")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Theme.primaryButtonBackground)
                .foregroundColor(Theme.buttonText)
                .cornerRadius(10)
        }
        .padding(.horizontal)
    }

    // MARK: - Foto Bewerken Opties

    private func bewerkFotoOpties(fotoPad: String) {
        let alert = UIAlertController(title: "Foto Opties", message: "Wilt u de foto bewerken of opnieuw maken?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Bewerken", style: .default, handler: { _ in
            bewerkFoto(fotoPad: fotoPad)
        }))
        
        alert.addAction(UIAlertAction(title: "Opnieuw maken", style: .default, handler: { _ in
            verwijderFoto(fotoPad: fotoPad)
            toonCamera = true
            isCameraActive = true
        }))
        
        alert.addAction(UIAlertAction(title: "Annuleer", style: .cancel, handler: nil))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(alert, animated: true, completion: nil)
        }
    }

    private func bewerkFoto(fotoPad: String) {
        if let image = FileManagerHelper.shared.loadImage(atPath: fotoPad) {
            FileManagerHelper.shared.slaFotoOpInMap(image: image, naam: fotoPad, folderPath: voertuigFolderPath ?? "") { _ in
                print("Foto bewerkt en opgeslagen.")
            }
        }
    }
}

