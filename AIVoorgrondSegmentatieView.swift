//
//  AIVoorgrondSegmentatieView.swift
//  CarFocus
//
//  Created by Nick Wever on 29/10/2024.
//

import SwiftUI
import CoreML
import Vision
import UIKit

struct AIVoorgrondSegmentatieView: View {
    var inputImage: UIImage
    var newBackgroundImage: UIImage?
    var onComplete: (UIImage) -> Void

    @State private var segmentedImage: UIImage? = nil
    @State private var isProcessing = false

    var body: some View {
        VStack {
            if let segmentedImage = segmentedImage {
                Image(uiImage: segmentedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                Text("Achtergrond gewijzigd!")
            } else if isProcessing {
                Text("Bezig met het verwerken van de afbeelding...")
                    .onAppear {
                        performSegmentation(inputImage)
                    }
            } else {
                Text("Kan afbeelding niet verwerken.")
            }
        }
        .onAppear {
            performSegmentation(inputImage)
        }
    }

    func performSegmentation(_ image: UIImage) {
        isProcessing = true

        // Probeer het model te initialiseren met `init(configuration:)` en vang eventuele fouten op
        do {
            let model = try VNCoreMLModel(for: DeepLabV3(configuration: MLModelConfiguration()).model)
            
            let request = VNCoreMLRequest(model: model) { request, error in
                if let error = error {
                    print("Fout tijdens het uitvoeren van ML-request: \(error.localizedDescription)")
                    isProcessing = false
                    return
                }

                guard let results = request.results as? [VNPixelBufferObservation],
                      let pixelBuffer = results.first?.pixelBuffer else {
                    print("Fout: Geen resultaten ontvangen van het ML-model")
                    isProcessing = false
                    return
                }

                if let maskImage = createMaskFromPixelBuffer(pixelBuffer) {
                    DispatchQueue.main.async {
                        self.segmentedImage = combineWithNewBackground(foreground: maskImage)
                        self.isProcessing = false
                    }
                } else {
                    print("Fout bij het creëren van het masker van de afbeelding")
                    isProcessing = false
                }
            }

            guard let cgImage = image.cgImage else {
                print("Fout bij het converteren van UIImage naar CGImage")
                isProcessing = false
                return
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    print("Fout bij het uitvoeren van het request: \(error.localizedDescription)")
                    isProcessing = false
                }
            }
        } catch {
            print("Fout bij het laden van het DeepLabV3-model: \(error.localizedDescription)")
            isProcessing = false
        }
    }

    func createMaskFromPixelBuffer(_ pixelBuffer: CVPixelBuffer) -> UIImage? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()

        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

    func combineWithNewBackground(foreground: UIImage) -> UIImage? {
        guard let newBackgroundImage = newBackgroundImage else {
            return foreground
        }

        let newSize = CGSize(width: foreground.size.width, height: foreground.size.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }

        newBackgroundImage.draw(in: CGRect(origin: .zero, size: newSize))
        foreground.draw(in: CGRect(origin: .zero, size: newSize))

        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
