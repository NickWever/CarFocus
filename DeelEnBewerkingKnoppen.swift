import SwiftUI

struct DeelEnBewerkingKnoppen: View {
    @Binding var toonDeelSheet: Bool
    @Binding var toonAdvancedImageEditorSheet: Bool
    @Binding var geselecteerdeFoto: UIImage?
    var voertuigID: String

    var body: some View {
        VStack {
            // Knop om foto's te delen
            Button(action: {
                toonDeelSheet = true
            }) {
                Text("Deel foto's")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .sheet(isPresented: $toonDeelSheet) {
                deelFotos(fotoPaths: [], voertuigID: voertuigID) // Pas aan met juiste fotoPaths
            }

            // Knop om geavanceerde bewerking te openen
            Button(action: {
                toonAdvancedImageEditorSheet = true
            }) {
                Text("Bewerk Foto")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .sheet(isPresented: $toonAdvancedImageEditorSheet) {
                if let geselecteerdeFoto = geselecteerdeFoto {
                    AdvancedImageEditorView(image: geselecteerdeFoto, onComplete: { updatedImage in
                        self.geselecteerdeFoto = updatedImage
                    })
                } else {
                    Text("Geen foto geselecteerd")
                }
            }
        }
    }
}
