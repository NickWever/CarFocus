//
//  AfbeeldingHelper.swift
//  CarFocus
//
//  Created by Nick Wever on 13/11/2024.
//

import UIKit
import SwiftUI

struct AfbeeldingHelper {
    
    static let shared = AfbeeldingHelper()
    
    private init() {}
    
    // MARK: - Filters toepassen
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
    
    // MARK: - Achtergrond toepassen
    func pasAchtergrondToeOpAfbeelding(_ afbeelding: UIImage, _ nieuweAchtergrond: UIImage) -> UIImage? {
        return afbeelding // Vervang met de echte implementatie
    }
    
    // MARK: - Afbeelding opslaan in Documenten-directory
    func slaFotoOpInMap(image: UIImage, naam: String, merk: String, type: String, kenteken: String, voltooi: @escaping (String?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let documentenMap = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let mapNaam = "\(merk)_\(type)_\(kenteken)".replacingOccurrences(of: " ", with: "_")
            let voertuigMap = documentenMap.appendingPathComponent(mapNaam)

            if !FileManager.default.fileExists(atPath: voertuigMap.path) {
                do {
                    try FileManager.default.createDirectory(at: voertuigMap, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("Fout bij het aanmaken van de map: \(error.localizedDescription)")
                    DispatchQueue.main.async { voltooi(nil) }
                    return
                }
            }

            let fileURL = voertuigMap.appendingPathComponent(naam)
            if let data = image.jpegData(compressionQuality: 1.0) {
                do {
                    try data.write(to: fileURL)
                    DispatchQueue.main.async { voltooi(fileURL.path) }
                } catch {
                    print("Fout bij het opslaan van de afbeelding: \(error.localizedDescription)")
                    DispatchQueue.main.async { voltooi(nil) }
                }
            }
        }
    }
    
    // MARK: - Foto opslaan in Foto's-app
    func slaFotoOpInFotosApp(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        print("Afbeelding opgeslagen in Foto's-app")
    }
    
    // MARK: - Debugging hulp
    func printDocumentenPad() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print("Documenten directory pad: \(documentsDirectory.path)")
    }
}
  
