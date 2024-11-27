import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VoertuigEntity.merk, ascending: true)],
        animation: .default)
    private var voertuigen: FetchedResults<VoertuigEntity>
    
    @State private var geselecteerdeFoto: UIImage?
    @State private var isCameraActive = false
    @State private var toonCamera = false
    @State private var huidigeFotoIndex = 0
    private let fotoNamen = ["Voorkant", "Achterkant", "Interieur"] // Voeg meer fotonamen toe indien nodig
    @State private var opgeslagenFotos: [UIImage] = [] // Opslag voor tijdelijke foto's
    
    var body: some View {
        NavigationView {
            List {
                ForEach(voertuigen) { voertuig in
                    NavigationLink(destination: voertuigDetailView(voertuig: voertuig)) {
                        HStack {
                            if let eersteFoto = voertuig.fotoPaths?.first,
                               let afbeelding = FileManagerHelper.shared.loadImage(atPath: eersteFoto) {
                                Image(uiImage: afbeelding)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            VStack(alignment: .leading) {
                                Text(voertuig.merk ?? "Onbekend Merk")
                                    .font(.headline)
                                Text(voertuig.type ?? "Onbekend Type")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Voertuigen")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        toonCamera = true
                    }) {
                        Label("Voeg voertuig toe", systemImage: "plus")
                    }
                }
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

        }
    }
    
    // MARK: - Voertuig detailweergave
    func voertuigDetailView(voertuig: VoertuigEntity) -> some View {
        VStack {
            Text(voertuig.merk ?? "Onbekend Merk")
                .font(.largeTitle)
                .padding()

            if let fotoPaths = voertuig.fotoPaths {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(fotoPaths, id: \.self) { fotoPath in
                            if let image = FileManagerHelper.shared.loadImage(atPath: fotoPath) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 150)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .shadow(radius: 2)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle(voertuig.merk ?? "Voertuig Detail")
    }
    
    // MARK: - Foto-opslagfunctie
    func fotoOpgeslagen(_ afbeelding: UIImage) {
        opgeslagenFotos.append(afbeelding)
        geselecteerdeFoto = afbeelding
    }
    
    // MARK: - Huidige foto naam updaten
    func updateFotoNaam() {
        if huidigeFotoIndex < fotoNamen.count - 1 {
            huidigeFotoIndex += 1
        } else {
            huidigeFotoIndex = 0 // Reset indien alle foto's zijn genomen
            toonCamera = false // Sluit de camera na de laatste foto
        }
    }

    // MARK: - Huidige foto naam ophalen
    func huidigeFotoNaam() -> String {
        return fotoNamen[huidigeFotoIndex]
    }

    // Reset de index bij het sluiten van de camera
    func resetFotoIndex() {
        huidigeFotoIndex = 0
    }
}
