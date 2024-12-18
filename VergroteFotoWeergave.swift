import SwiftUI
import UIKit

struct FotoVergrotenView: View {
    @Binding var image: UIImage?            // Binding om afbeelding van elders te ontvangen
    var onClose: () -> Void                 // Functie om weergave te sluiten
    var onEdit: () -> Void                  // Functie om naar de bewerkingspagina te gaan
    @State private var toonDelenSheet = false
    @State private var rotatieGraden: Double = 0

    var body: some View {
        VStack {
            // Controle of de afbeelding geladen is
            if let image = image {
                Image(uiImage: image.rotated(by: rotatieGraden))
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: UIScreen.main.bounds.height * 0.7)
                    .padding()
            } else {
                Text("Kan foto niet laden")
                    .foregroundColor(.gray)
            }

            HStack(spacing: 20) {
                // Bewerken knop
                Button("Bewerk Foto") {
                    onEdit()
                }
                .padding()
                .background(Theme.primaryButtonBackground)
                .foregroundColor(Theme.buttonText)
                .cornerRadius(10)
                
                // Draai de afbeelding met 90 graden bij elke druk op de knop
                Button("Draai Foto") {
                    rotatieGraden += 90
                    if rotatieGraden == 360 { rotatieGraden = 0 }
                }
                .padding()
                .background(Theme.accent)
                .foregroundColor(Theme.buttonText)
                .cornerRadius(10)
                
                // Deel de foto
                Button("Deel Foto") {
                    toonDelenSheet = true
                }
                .padding()
                .background(Theme.secondaryButtonBackground)
                .foregroundColor(Theme.buttonText)
                .cornerRadius(10)
                .sheet(isPresented: $toonDelenSheet) {
                    if let image = image {
                        DeelFotoActivityViewController(activityItems: [image])
                    }
                }
                
                // Sluit de weergave
                Button("Sluiten") {
                    onClose()
                }
                .padding()
                .background(Theme.primaryButtonBackground)
                .foregroundColor(Theme.buttonText)
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Theme.background.edgesIgnoringSafeArea(.all))
    }
}

// MARK: - DeelFotoActivityViewController voor het delen
struct DeelFotoActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - UIImage Extension voor Rotatie
extension UIImage {
    func rotated(by degrees: Double) -> UIImage {
        let radians = degrees * .pi / 180
        var newSize = CGRect(origin: CGPoint.zero, size: self.size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        newSize.width = max(newSize.width, 1)
        newSize.height = max(newSize.height, 1)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        context.rotate(by: CGFloat(radians))
        
        self.draw(in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2,
                             width: self.size.width, height: self.size.height))
        
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return rotatedImage
    }
}
