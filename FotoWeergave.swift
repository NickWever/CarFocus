import SwiftUI
import CoreData

// MARK: - IdentifiableImage Struct
/// Een structuur om afbeeldingen identificeerbaar te maken voor gebruik in SwiftUI ForEach-lussen.
struct IdentifiableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

// MARK: - FotoInfo Struct
/// Definieer FotoInfo struct voor het beheren van afbeeldingsinformatie
struct FotoInfo: Identifiable, Codable {
    var id: UUID = UUID()
    var naam: String
    var pad: String
    
    static func == (lhs: FotoInfo, rhs: FotoInfo) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - FotoWeergave Struct
struct FotoWeergave: View {
    var voertuig: VoertuigEntity
    @State private var geselecteerdeFoto: IdentifiableImage? = nil
    @State private var geselecteerdeFotoInfos = [FotoInfo]()  // Lijst van FotoInfo
    @State private var helderheid: Double = 0.0
    @State private var contrast: Double = 1.0
    @State private var verzadiging: Double = 1.0

    var voertuigID: String { voertuig.objectID.uriRepresentation().lastPathComponent }

    var body: some View {
        VStack {
            Text("Foto's van \(voertuig.merk ?? "Onbekend Merk") \(voertuig.type ?? "Onbekend Type")")
                .font(.title)
                .padding()

            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    if let fotoData = voertuig.fotoData, let foto = UIImage(data: fotoData) {
                        Image(uiImage: foto)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .padding()
                    } else {
                        Text("Geen foto's beschikbaar")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }

    // MARK: - Functie voor het toepassen van filters
    func applyFiltersToImage(_ image: UIImage) -> UIImage? {
        let context = CIContext()
        let ciImage = CIImage(image: image)

        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(helderheid, forKey: kCIInputBrightnessKey)
        filter?.setValue(contrast, forKey: kCIInputContrastKey)
        filter?.setValue(verzadiging, forKey: kCIInputSaturationKey)

        if let outputImage = filter?.outputImage, let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
}
