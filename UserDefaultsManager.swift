import Foundation
import UIKit

class UserDefaultsManager {
    
    // MARK: - Bestandsdirectory voor afbeeldingen
    static let afbeeldingenDirectory: URL = {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imageDirectory = documentDirectory.appendingPathComponent("Afbeeldingen")
        
        if !FileManager.default.fileExists(atPath: imageDirectory.path) {
            try? FileManager.default.createDirectory(at: imageDirectory, withIntermediateDirectories: true)
        }
        return imageDirectory
    }()
    
    // MARK: - Afbeeldingen opslaan en ophalen
    static func saveImage(_ image: UIImage, fileName: String) -> String? {
        let fileURL = afbeeldingenDirectory.appendingPathComponent(fileName)
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return nil }
        
        do {
            try imageData.write(to: fileURL)
            return fileURL.path
        } catch {
            print("Fout bij opslaan afbeelding: \(error)")
            return nil
        }
    }
    
    static func loadImage(atPath path: String) -> UIImage? {
        return UIImage(contentsOfFile: path)
    }
    
    static func deleteImage(atPath path: String) {
        let fileURL = URL(fileURLWithPath: path)
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    // MARK: - Meerdere afbeeldingspaden opslaan en ophalen
    static func saveImagePaths(_ paths: [String], forKey key: String) {
        UserDefaults.standard.set(paths, forKey: key)
    }
    
    static func loadImagePaths(forKey key: String) -> [String]? {
        return UserDefaults.standard.stringArray(forKey: key)
    }
    
    // MARK: - Achtergrondafbeeldingen opslaan en ophalen (nieuwe functie)
    static func loadBackgroundImages() -> [UIImage]? {
        guard let paths = loadImagePaths(forKey: "achtergronden") else { return nil }
        return paths.compactMap { loadImage(atPath: $0) }
    }
}
