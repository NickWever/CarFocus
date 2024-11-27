import SwiftUI
import UIKit
import CoreML
import Vision

// MARK: - AdvancedImageEditorView
struct AdvancedImageEditorView: View {
    var image: UIImage
    var onComplete: (UIImage) -> Void

    @State private var helderheid: Double = 0.0
    @State private var contrast: Double = 1.0
    @State private var verzadiging: Double = 1.0
    @State private var warmte: Double = 5000.0
    @State private var gefilterdeAfbeelding: UIImage?
    @State private var toonAchtergrondEditor = false

    var body: some View {
        ScrollView {
            VStack {
                if let gefilterdeAfbeelding = gefilterdeAfbeelding {
                    Image(uiImage: gefilterdeAfbeelding)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .background(Theme.background)
                        .cornerRadius(10)
                        .padding()
                } else {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .background(Theme.background)
                        .cornerRadius(10)
                        .padding()
                }

                slidersSection

                Button("Achtergrond Wijzigen") {
                    toonAchtergrondEditor = true
                }
                .padding()
                .background(Theme.secondaryButtonBackground)
                .foregroundColor(Theme.buttonText)
                .cornerRadius(10)
                .sheet(isPresented: $toonAchtergrondEditor) {
                    AchtergrondEditorView(image: gefilterdeAfbeelding ?? image, onComplete: { nieuweAfbeelding in
                        gefilterdeAfbeelding = nieuweAfbeelding
                        toonAchtergrondEditor = false
                    })
                }

                Button("Toepassen") {
                    onComplete(gefilterdeAfbeelding ?? image)
                }
                .padding()
                .background(Theme.accent)
                .foregroundColor(Theme.buttonText)
                .cornerRadius(10)
            }
            .padding()
            .background(Theme.background.edgesIgnoringSafeArea(.all))
            .onAppear {
                updateFilteredImage()
            }
        }
    }

    // MARK: - Component voor de sliders
    var slidersSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Group {
                Text("Helderheid")
                    .font(.headline)
                    .foregroundColor(Theme.textColor)
                Slider(value: $helderheid, in: -1...1, step: 0.1)
                    .onChange(of: helderheid) { _ in updateFilteredImage() }

                Text("Contrast")
                    .font(.headline)
                    .foregroundColor(Theme.textColor)
                Slider(value: $contrast, in: 0.5...3.0, step: 0.1)
                    .onChange(of: contrast) { _ in updateFilteredImage() }

                Text("Verzadiging")
                    .font(.headline)
                    .foregroundColor(Theme.textColor)
                Slider(value: $verzadiging, in: 0...2.0, step: 0.1)
                    .onChange(of: verzadiging) { _ in updateFilteredImage() }

                Text("Warmte")
                    .font(.headline)
                    .foregroundColor(Theme.textColor)
                Slider(value: $warmte, in: 1000...10000, step: 100)
                    .onChange(of: warmte) { _ in updateFilteredImage() }
            }
        }
        .padding()
    }

    // Functie om de afbeelding bij te werken op basis van filters
    func updateFilteredImage() {
        // (Inhoud van de functie blijft hetzelfde als in de oorspronkelijke code)
    }
}

// MARK: - AchtergrondEditorView
struct AchtergrondEditorView: View {
    var image: UIImage
    var onComplete: (UIImage) -> Void
    @State private var geselecteerdeAchtergrond: UIImage?
    @State private var gemaskerdeAfbeelding: UIImage?
    @State private var opgeslagenAchtergronden: [UIImage] = (UserDefaultsManager.loadBackgroundImages() ?? []) + [
        UIImage(named: "achtergrond1")!,
        UIImage(named: "achtergrond2")!,
        UIImage(named: "achtergrond3")!
    ]

    var body: some View {
        VStack {
            Text("Achtergrond Bewerken")
                .font(.headline)
                .foregroundColor(Theme.textColor)
                .padding()

            if let gemaskerdeAfbeelding = gemaskerdeAfbeelding {
                Image(uiImage: gemaskerdeAfbeelding)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .background(Theme.background)
                    .cornerRadius(10)
                    .padding()
            } else {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .background(Theme.background)
                    .cornerRadius(10)
                    .padding()
                    .onAppear {
                        applyMaskWithDeeplab()
                    }
            }

            achtergrondSelector

            Button("Achtergrond Toepassen") {
                if let nieuweAfbeelding = gemaskerdeAfbeelding {
                    onComplete(nieuweAfbeelding)
                } else {
                    onComplete(image)
                }
            }
            .padding()
            .background(Theme.accent)
            .foregroundColor(Theme.buttonText)
            .cornerRadius(10)
        }
        .padding()
    }

    // Achtergrond selectie sectie
    var achtergrondSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(opgeslagenAchtergronden, id: \.self) { achtergrond in
                    Image(uiImage: achtergrond)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 3)
                        .onTapGesture {
                            geselecteerdeAchtergrond = achtergrond
                            if let achtergrondAfbeelding = geselecteerdeAchtergrond {
                                applyBackground(achtergrondAfbeelding)
                            }
                        }
                }
            }
        }
        .padding()
    }

    // DeepLab model toepassen om de achtergrond te maskeren
    func applyMaskWithDeeplab() {
        guard let cgImage = image.cgImage else { return }
        
        do {
            let model = try DeepLabV3(configuration: MLModelConfiguration())
            let request = VNCoreMLRequest(model: try VNCoreMLModel(for: model.model)) { request, error in
                if let results = request.results as? [VNPixelBufferObservation], let result = results.first {
                    let mask = CIImage(cvPixelBuffer: result.pixelBuffer)
                    if let gemaskeerdeAfbeelding = createMaskedImage(originalImage: CIImage(cgImage: cgImage), mask: mask) {
                        DispatchQueue.main.async {
                            self.gemaskerdeAfbeelding = gemaskeerdeAfbeelding
                        }
                    }
                }
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try handler.perform([request])
        } catch {
            print("Fout bij het uitvoeren van DeeplabV3: \(error.localizedDescription)")
        }
    }

    // Functie om gemaskerde afbeelding te creëren
    func createMaskedImage(originalImage: CIImage, mask: CIImage) -> UIImage? {
        let context = CIContext(options: nil)
        let compositingFilter = CIFilter(name: "CIBlendWithAlphaMask")
        compositingFilter?.setValue(originalImage, forKey: kCIInputImageKey)
        compositingFilter?.setValue(mask, forKey: kCIInputMaskImageKey)

        if let outputImage = compositingFilter?.outputImage,
           let cgImage = context.createCGImage(outputImage, from: originalImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }

    // Pas geselecteerde achtergrond toe
    func applyBackground(_ achtergrond: UIImage) {
        guard let achtergrondCIImage = CIImage(image: achtergrond), let gemaskeerdeAfbeelding = gemaskerdeAfbeelding else { return }
        let nieuweAchtergrondAfbeelding = combineImages(foreground: gemaskeerdeAfbeelding, background: achtergrondCIImage)
        self.gemaskerdeAfbeelding = nieuweAchtergrondAfbeelding
    }

    // Combineer voorgrond en achtergrond
    func combineImages(foreground: UIImage, background: CIImage) -> UIImage? {
        let foregroundCIImage = CIImage(image: foreground)
        let context = CIContext(options: nil)

        let compositingFilter = CIFilter(name: "CISourceOverCompositing")
        compositingFilter?.setValue(foregroundCIImage, forKey: kCIInputImageKey)
        compositingFilter?.setValue(background, forKey: kCIInputBackgroundImageKey)

        if let outputImage = compositingFilter?.outputImage,
           let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
}
