import SwiftUI
import UIKit

// MARK: - InstellingenModel
class InstellingenModel: ObservableObject {
    @Published var gekozenOpslagLocatie: OpslagLocatie = .appMap
}

// MARK: - OpslagLocatie Enum
enum OpslagLocatie: String, CaseIterable {
    case appMap = "App-map"
    case fotosApp = "Foto's-app"
    case icloud = "iCloud"
    case dropbox = "Dropbox"
    case nas = "NAS Systeem"
}

// MARK: - Hoofdinstellingenweergave
struct InstellingenHoofdWeergave: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Voertuig Instellingen")) {
                    NavigationLink(destination: InstellingenNieuweVoertuigenWeergave()) {
                        Text("Nieuwe Voertuigen")
                    }
                    NavigationLink(destination: InstellingenInruilVoertuigenWeergave()) {
                        Text("Inruilvoertuigen")
                    }
                }

                Section(header: Text("Bedrijfsinstellingen")) {
                    NavigationLink(destination: BedrijfsLogoInstellingenWeergave()) {
                        Text("Bedrijfslogo")
                    }
                    NavigationLink(destination: AchtergrondInstellingenWeergave()) {
                        Text("Achtergronden")
                    }
                }

                Section(header: Text("Opslaginstellingen")) {
                    NavigationLink(destination: InstellingenOpslagWeergave()) {
                        Text("Opslaglocatie")
                    }
                }
            }
            .navigationTitle("Instellingen")
        }
    }
}

// MARK: - Opslaglocatie Instellingen Weergave
struct InstellingenOpslagWeergave: View {
    @ObservedObject var instellingenModel = InstellingenModel()

    var body: some View {
        Form {
            Section(header: Text("Kies Opslaglocatie")) {
                Picker("Opslaglocatie", selection: $instellingenModel.gekozenOpslagLocatie) {
                    ForEach(OpslagLocatie.allCases, id: \.self) { locatie in
                        Text(locatie.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
        .navigationTitle("Opslaglocatie")
    }
}

// MARK: - Instellingen voor de volgorde van foto's bij nieuwe voertuigen
struct InstellingenNieuweVoertuigenWeergave: View {
    @State private var fotoLijst: [String] = UserDefaults.standard.object(forKey: "fotoLijstNieuweVoertuigen") as? [String] ?? ["Voorkant", "Achterkant", "Interieur"]
    @State private var opslaanFotoLijst: [String] = UserDefaults.standard.object(forKey: "fotoOpslaanLijstNieuweVoertuigen") as? [String] ?? ["Voorkant", "Achterkant", "Interieur"]
    @State private var nieuweFotoNaam: String = ""
    @State private var volgordeOpgeslagen = false

    var body: some View {
        VolgordeInstellingenWeergave(
            titel: "Volgorde van Foto's - Nieuwe Voertuigen",
            fotoLijstKey: "fotoLijstNieuweVoertuigen",
            opslaanFotoLijstKey: "fotoOpslaanLijstNieuweVoertuigen"
        )
    }
}

// MARK: - Instellingen voor de volgorde van foto's bij inruilvoertuigen
struct InstellingenInruilVoertuigenWeergave: View {
    var body: some View {
        VolgordeInstellingenWeergave(
            titel: "Volgorde van Foto's - Inruilvoertuigen",
            fotoLijstKey: "fotoLijstInruilVoertuigen",
            opslaanFotoLijstKey: "fotoOpslaanLijstInruilVoertuigen"
        )
    }
}

// MARK: - Volgorde Instellingen Weergave
struct VolgordeInstellingenWeergave: View {
    let titel: String
    let fotoLijstKey: String
    let opslaanFotoLijstKey: String

    @State private var fotoLijst: [String]
    @State private var opslaanFotoLijst: [String]
    @State private var nieuweFotoNaam: String = ""
    @State private var volgordeOpgeslagen = false

    init(titel: String, fotoLijstKey: String, opslaanFotoLijstKey: String) {
        self.titel = titel
        self.fotoLijstKey = fotoLijstKey
        self.opslaanFotoLijstKey = opslaanFotoLijstKey
        self._fotoLijst = State(initialValue: UserDefaults.standard.object(forKey: fotoLijstKey) as? [String] ?? ["Voorkant", "Achterkant", "Interieur"])
        self._opslaanFotoLijst = State(initialValue: UserDefaults.standard.object(forKey: opslaanFotoLijstKey) as? [String] ?? ["Voorkant", "Achterkant", "Interieur"])
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Wijzig de volgorde waarin de foto's worden gemaakt")
                .font(.headline)
                .padding(.top)

            List {
                ForEach(fotoLijst, id: \.self) { foto in
                    Text(foto)
                }
                .onMove(perform: moveFotoInMaakLijst)
            }
            .environment(\.editMode, .constant(.active))

            HStack {
                TextField("Nieuwe foto", text: $nieuweFotoNaam)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                Button("Toevoegen") {
                    if !nieuweFotoNaam.isEmpty {
                        fotoLijst.append(nieuweFotoNaam)
                        nieuweFotoNaam = ""
                    }
                }
                .padding(.trailing)
                .disabled(nieuweFotoNaam.isEmpty)
            }

            Button("Opslaan volgorde te maken foto's") {
                UserDefaults.standard.set(fotoLijst, forKey: fotoLijstKey)
                volgordeOpgeslagen = true
            }
            .padding()
            .background(volgordeOpgeslagen ? Color.green : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            Text("Wijzig de volgorde waarin de foto's worden opgeslagen")
                .font(.headline)
                .padding(.top)

            List {
                ForEach(opslaanFotoLijst, id: \.self) { foto in
                    Text(foto)
                }
                .onMove(perform: moveFotoInOpslaanLijst)
            }
            .environment(\.editMode, .constant(.active))

            Button("Opslaan volgorde opgeslagen foto's") {
                UserDefaults.standard.set(opslaanFotoLijst, forKey: opslaanFotoLijstKey)
                volgordeOpgeslagen = true
            }
            .padding()
            .background(volgordeOpgeslagen ? Color.green : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .navigationTitle(titel)
        .padding()
        .onAppear {
            volgordeOpgeslagen = false
        }
    }

    private func moveFotoInMaakLijst(from source: IndexSet, to destination: Int) {
        fotoLijst.move(fromOffsets: source, toOffset: destination)
        volgordeOpgeslagen = false
    }

    private func moveFotoInOpslaanLijst(from source: IndexSet, to destination: Int) {
        opslaanFotoLijst.move(fromOffsets: source, toOffset: destination)
        volgordeOpgeslagen = false
    }
}

// MARK: - Placeholder voor bedrijfslogo instellingen
struct BedrijfsLogoInstellingenWeergave: View {
    var body: some View {
        Text("Instellingen voor Bedrijfslogo")
            .navigationTitle("Bedrijfslogo")
    }
}


// Achtergrondinstellingenweergave voor het beheren van achtergronden
struct AchtergrondInstellingenWeergave: View {
    @State private var afbeeldingPaden: [String] = loadImagePaths() ?? []
    @State private var achtergronden: [UIImage] = []
    @State private var toonAchtergrondPicker = false
    @State private var nieuweAchtergrond: UIImage?

    // Voeg standaardafbeeldingen toe die altijd beschikbaar zijn
    private let standaardAchtergronden: [UIImage] = [
        UIImage(named: "achtergrond1")!,
        UIImage(named: "achtergrond2")!,
        UIImage(named: "achtergrond3")!
    ]

    var body: some View {
        Form {
            Section(header: Text("Achtergronden")) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        // Toon standaardafbeeldingen
                        ForEach(standaardAchtergronden.indices, id: \.self) { index in
                            Image(uiImage: standaardAchtergronden[index])
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .cornerRadius(10)
                        }
                        
                        // Toon dynamische achtergronden die zijn toegevoegd door de gebruiker
                        ForEach(achtergronden.indices, id: \.self) { index in
                            Image(uiImage: achtergronden[index])
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .cornerRadius(10)
                                .overlay(
                                    Button(action: {
                                        verwijderAchtergrond(at: index)
                                    }) {
                                        Image(systemName: "minus.circle")
                                            .foregroundColor(.red)
                                    }
                                    .padding(5),
                                    alignment: .topTrailing
                                )
                        }
                    }
                }

                Button("Voeg nieuwe achtergrond toe") {
                    toonAchtergrondPicker = true
                }
            }
        }
        .navigationTitle("Achtergronden")
        .sheet(isPresented: $toonAchtergrondPicker) {
            afbeeldingPicker(image: $nieuweAchtergrond) { geselecteerdeAfbeelding in
                if let afbeelding = geselecteerdeAfbeelding {
                    voegNieuweAchtergrondToe(afbeelding)
                }
            }
        }
        .onAppear {
            laadAchtergronden()
        }
    }

    private func laadAchtergronden() {
        achtergronden = afbeeldingPaden.compactMap { loadImage(atPath: $0) }
    }

    private func voegNieuweAchtergrondToe(_ afbeelding: UIImage) {
        if let path = saveImage(afbeelding, fileName: UUID().uuidString + ".jpg") {
            afbeeldingPaden.append(path)
            achtergronden.append(afbeelding)
            saveImagePaths(afbeeldingPaden)
        }
    }

    private func verwijderAchtergrond(at index: Int) {
        let path = afbeeldingPaden.remove(at: index)
        achtergronden.remove(at: index)
        deleteImage(atPath: path)
        saveImagePaths(afbeeldingPaden)
    }

    private func afbeeldingPicker(image: Binding<UIImage?>, completion: @escaping (UIImage?) -> Void) -> some View {
        ImagePicker(image: image) { geselecteerdeAfbeelding in
            completion(geselecteerdeAfbeelding)
        }
    }
}


// MARK: - Functies voor bestandssysteembeheer

func saveImage(_ image: UIImage, fileName: String) -> String? {
    if let data = image.jpegData(compressionQuality: 1.0) {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            try data.write(to: url)
            return url.path
        } catch {
            print("Fout bij opslaan afbeelding:", error)
        }
    }
    return nil
}

func loadImage(atPath path: String) -> UIImage? {
    let url = URL(fileURLWithPath: path)
    if let data = try? Data(contentsOf: url) {
        return UIImage(data: data)
    }
    return nil
}

func deleteImage(atPath path: String) {
    let url = URL(fileURLWithPath: path)
    do {
        try FileManager.default.removeItem(at: url)
    } catch {
        print("Fout bij verwijderen afbeelding:", error)
    }
}

func saveImagePaths(_ paths: [String]) {
    UserDefaults.standard.set(paths, forKey: "achtergronden")
}

func loadImagePaths() -> [String]? {
    return UserDefaults.standard.stringArray(forKey: "achtergronden")
}

func getDocumentsDirectory() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
}
