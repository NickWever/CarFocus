//
//  DeelControllerHelper.swift
//  CarFocus
//
//  Created by Nick Wever on 07/10/2024.
//

import SwiftUI
import UIKit

// MARK: - ActivityViewController om afbeeldingen te delen

/// Een representable struct om een `UIActivityViewController` weer te geven voor het delen van bestanden.
struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Functie om foto's te delen

/// Functie om foto's te delen via UIActivityViewController
func deelFotos(fotoPaths: [String], voertuigID: String) -> ActivityViewController {
    // Laad de afbeeldingen van de opgegeven paden
    let images = fotoPaths.compactMap { laadAfbeelding(fotoNaam: $0, voertuigID: voertuigID) }
    
    // Creëer en retourneer de ActivityViewController met de afbeeldingen om te delen
    return ActivityViewController(activityItems: images)
}

// MARK: - Helper Functie om een afbeelding te laden

/// Helper functie om een afbeelding te laden van een bestandspad
func laadAfbeelding(fotoNaam: String, voertuigID: String) -> UIImage? {
    // Verkrijg het pad naar de documentenmap
    let documentenMap = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    // Maak een volledige URL voor de afbeelding met voertuigID en fotoNaam
    let fotoURL = documentenMap.appendingPathComponent("Voertuigen/\(voertuigID)/\(fotoNaam)")
    
    // Probeer de afbeelding te laden vanaf het pad
    do {
        let imageData = try Data(contentsOf: fotoURL)
        return UIImage(data: imageData)
    } catch {
        print("Fout bij het laden van afbeelding: \(error.localizedDescription)")
        return nil
    }
}
