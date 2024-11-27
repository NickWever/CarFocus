import Foundation
import UIKit
import CoreData
import SwiftUI

// MARK: - FileManagerHelper Struct voor bestandsbeheer en Core Data-integratie

struct FileManagerHelper {
    
    static let shared = FileManagerHelper()
    private init() {}

    // MARK: - Mapbeheer voor voertuigen

    func createFolderForVehicle(merk: String, type: String, kenteken: String, voertuigType: String) -> URL? {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let folderName = "\(merk), \(type), \(kenteken)"
        let folderURL: URL
        
        switch voertuigType {
        case "Verkoop":
            folderURL = documentsURL.appendingPathComponent("Voertuigen/Verkoop/\(folderName)")
        case "Inruil":
            folderURL = documentsURL.appendingPathComponent("Voertuigen/Inruil/\(folderName)")
        default:
            folderURL = documentsURL.appendingPathComponent("Voertuigen/Overig/\(folderName)")
        }

        do {
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
            return folderURL
        } catch {
            print("Fout bij het aanmaken van de map: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Afbeeldingbeheer in map

    func slaFotoOpInMap(image: UIImage, naam: String, folderPath: String, completion: @escaping (String?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let fileURL = URL(fileURLWithPath: folderPath).appendingPathComponent(naam)
            if let data = image.jpegData(compressionQuality: 1.0) {
                do {
                    try data.write(to: fileURL)
                    DispatchQueue.main.async {
                        completion(fileURL.path)
                    }
                } catch {
                    DispatchQueue.main.async {
                        print("Fout bij het opslaan van de afbeelding: \(error.localizedDescription)")
                        completion(nil)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    print("Fout bij het converteren van de afbeelding naar JPEG")
                    completion(nil)
                }
            }
        }
    }

    func loadImage(atPath path: String) -> UIImage? {
        let url = URL(fileURLWithPath: path)
        if let data = try? Data(contentsOf: url) {
            return UIImage(data: data)
        }
        return nil
    }

    func deleteImage(atPath path: String) {
        let fileURL = URL(fileURLWithPath: path)
        try? FileManager.default.removeItem(at: fileURL)
    }

    // MARK: - Core Data Opslag Functies voor VoertuigEntity en InruilAutoEntity
    
    func slaInruilAutoOp(merk: String, type: String, kenteken: String, notities: String, fotos: [String], context: NSManagedObjectContext) {
        guard let inruilAuto = NSEntityDescription.insertNewObject(forEntityName: "InruilAutoEntity", into: context) as? InruilAutoEntity else {
            print("Fout bij het aanmaken van InruilAutoEntity")
            return
        }
        
        inruilAuto.id = UUID()
        inruilAuto.merk = merk
        inruilAuto.type = type
        inruilAuto.kenteken = kenteken
        inruilAuto.notities = notities
        inruilAuto.fotoPaths = fotos
        
        if let folderPath = createFolderForVehicle(merk: merk, type: type, kenteken: kenteken, voertuigType: "Inruil") {
            inruilAuto.folderPath = folderPath.path
        }
        
        do {
            try context.save()
            print("Inruilauto succesvol opgeslagen in Core Data.")
        } catch {
            print("Fout bij het opslaan van de inruilauto: \(error.localizedDescription)")
        }
    }

    func slaVoertuigOp(merk: String, type: String, kenteken: String, notities: String, fotos: [String], context: NSManagedObjectContext) {
        guard let voertuig = NSEntityDescription.insertNewObject(forEntityName: "VoertuigEntity", into: context) as? VoertuigEntity else {
            print("Fout bij het aanmaken van VoertuigEntity")
            return
        }
        
        voertuig.id = UUID()
        voertuig.merk = merk
        voertuig.type = type
        voertuig.kenteken = kenteken
        voertuig.notities = notities
        voertuig.fotoPaths = fotos
        
        if let folderPath = createFolderForVehicle(merk: merk, type: type, kenteken: kenteken, voertuigType: "Verkoop") {
            voertuig.folderPath = folderPath.path
        }

        do {
            try context.save()
            print("Voertuig succesvol opgeslagen in Core Data.")
        } catch {
            print("Fout bij het opslaan van het voertuig: \(error.localizedDescription)")
        }
    }

    func haalFotosOpVoorVoertuig(voertuig: VoertuigEntity) -> [UIImage] {
        return laadFotosUitPadArray(voertuig.fotoPaths)
    }

    func haalFotosOpVoorInruilAuto(inruilAuto: InruilAutoEntity) -> [UIImage] {
        return laadFotosUitPadArray(inruilAuto.fotoPaths)
    }

    private func laadFotosUitPadArray(_ fotoPaths: [String]?) -> [UIImage] {
        var images: [UIImage] = []
        fotoPaths?.forEach { path in
            if let image = loadImage(atPath: path) {
                images.append(image)
            }
        }
        return images
    }

    func verwijderFotoVanVoertuig(voertuig: VoertuigEntity, fotoPad: String, context: NSManagedObjectContext) {
        deleteImage(atPath: fotoPad)
        voertuig.fotoPaths?.removeAll { $0 == fotoPad }
        do {
            try context.save()
            print("Foto succesvol verwijderd en wijzigingen opgeslagen in Core Data.")
        } catch {
            print("Fout bij het opslaan van het voertuig na verwijderen foto: \(error.localizedDescription)")
        }
    }
    
    func verwijderFotoVanInruilAuto(inruilAuto: InruilAutoEntity, fotoPad: String, context: NSManagedObjectContext) {
        deleteImage(atPath: fotoPad)
        inruilAuto.fotoPaths?.removeAll { $0 == fotoPad }
        do {
            try context.save()
            print("Foto succesvol verwijderd en wijzigingen opgeslagen in Core Data.")
        } catch {
            print("Fout bij het opslaan van de inruilauto na verwijderen foto: \(error.localizedDescription)")
        }
    }

    // MARK: - Documentenmap URL
    func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
func slaFotoOpInICloud(image: UIImage, naam: String, voltooi: @escaping (String?) -> Void) {
    DispatchQueue.global(qos: .background).async {
        guard let icloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") else {
            DispatchQueue.main.async {
                voltooi(nil)
            }
            return
        }

        let fileURL = icloudURL.appendingPathComponent(naam)
        if let data = image.jpegData(compressionQuality: 1.0) {
            do {
                try data.write(to: fileURL)
                DispatchQueue.main.async {
                    voltooi(fileURL.path)
                }
            } catch {
                DispatchQueue.main.async {
                    print("Fout bij opslaan naar iCloud: \(error.localizedDescription)")
                    voltooi(nil)
                }
            }
        }
    }
}

