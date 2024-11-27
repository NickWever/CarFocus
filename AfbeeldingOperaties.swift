import UIKit
import SwiftUI

// MARK: - Functie om filters toe te passen op een afbeelding
func pasFiltersToeOpAfbeelding(_ afbeelding: UIImage, helderheid: Double, contrast: Double, verzadiging: Double) -> UIImage? {
    let context = CIContext()
    guard let ciImage = CIImage(image: afbeelding) else {
        print("Fout: Kan geen CIImage maken van de inputafbeelding")
        return nil
    }
    
    guard let filter = CIFilter(name: "CIColorControls") else {
        print("Fout: Kan CIColorControls filter niet maken")
        return nil
    }
    filter.setValue(ciImage, forKey: kCIInputImageKey)
    filter.setValue(Float(helderheid), forKey: kCIInputBrightnessKey)
    filter.setValue(Float(contrast), forKey: kCIInputContrastKey)
    filter.setValue(Float(verzadiging), forKey: kCIInputSaturationKey)
    
    if let outputImage = filter.outputImage, let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
        return UIImage(cgImage: cgImage)
    }
    return nil
}

// MARK: - Functie om een nieuwe achtergrond toe te passen op de afbeelding
func pasAchtergrondToeOpAfbeelding(_ afbeelding: UIImage, _ nieuweAchtergrond: UIImage) -> UIImage? {
    // Hier kan aangepaste segmentatie- en achtergrondvervanging worden toegepast
    return afbeelding // Teruggeven van de originele afbeelding totdat deze functie is geïmplementeerd
}

// MARK: - Functie om een afbeelding op te slaan in de Documenten-directory (Bestanden-app)
func slaFotoOpInMap(image: UIImage, naam: String, merk: String, type: String, kenteken: String, voltooi: @escaping (String?) -> Void) {
    DispatchQueue.global(qos: .background).async {
        let documentenMap = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // Creëer mapnaam met merk, type en kenteken
        let mapNaam = "\(merk)_\(type)_\(kenteken)".replacingOccurrences(of: " ", with: "_") // Verwijder spaties
        let voertuigMap = documentenMap.appendingPathComponent(mapNaam)

        // Maak de map aan als deze nog niet bestaat
        if !FileManager.default.fileExists(atPath: voertuigMap.path) {
            do {
                try FileManager.default.createDirectory(at: voertuigMap, withIntermediateDirectories: true, attributes: nil)
                print("Map aangemaakt op: \(voertuigMap.path)")
            } catch {
                print("Fout bij het aanmaken van de map: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    voltooi(nil)
                }
                return
            }
        }

        // Sla de afbeelding op in de map
        let fileURL = voertuigMap.appendingPathComponent(naam)
        if let data = image.jpegData(compressionQuality: 1.0) {
            do {
                try data.write(to: fileURL)
                print("Afbeelding succesvol opgeslagen op: \(fileURL.path)")
                DispatchQueue.main.async {
                    voltooi(fileURL.path)  // Pad van de opgeslagen foto
                }
            } catch {
                print("Fout bij het opslaan van de afbeelding: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    voltooi(nil)
                }
            }
        }
    }
}

// MARK: - Functie om foto's ook naar de Foto's-app op te slaan
func slaFotoOpInFotosApp(image: UIImage) {
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    print("Afbeelding opgeslagen in Foto's-app")
}

// MARK: - Debugging hulp
func printDocumentenPad() {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    print("Documenten directory pad: \(documentsDirectory.path)")
}
