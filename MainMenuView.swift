import SwiftUI
import CoreData

struct MainMenuView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.edgesIgnoringSafeArea(.all)
                
                ScrollView {  // Toegevoegd ScrollView om de hele pagina scrollbaar te maken
                    VStack(spacing: 20) {
                        Image("CarFocusLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .padding(.top, 40)

                        // Grid met knoppen
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            navigationButton(title: "Nieuw Voertuig", systemImage: "car.fill", destination: VoegNieuwVoertuigToeWeergave())
                            navigationButton(title: "Inruil Voertuig", systemImage: "arrow.2.squarepath", destination: VoegInruilAutoToeWeergave())
                            navigationButton(title: "Voertuigen Overzicht", systemImage: "list.bullet", destination: VoertuigenOverzichtWeergave())
                            navigationButton(title: "Lopende Verkopen", systemImage: "cart.fill", destination: LopendeVerkopenWeergave())
                            navigationButton(title: "Afleveringen", systemImage: "doc.plaintext", destination: AfleveringWeergave())
                            navigationButton(title: "Zoekopdrachten", systemImage: "magnifyingglass", destination: ZoekopdrachtWeergave())
                            navigationButton(title: "Lease Calculator", systemImage: "dollarsign.circle", destination: LeaseCalculatorView())
                            navigationButton(title: "Instellingen", systemImage: "gearshape.fill", destination: InstellingenHoofdWeergave())
                        }
                        .padding(.horizontal, 20)

                        Spacer()
                    }
                }
            }
            .navigationBarTitle("CarFocus", displayMode: .inline)
            .navigationBarHidden(true)
        }
    }

    // Herbruikbare navigatieknop met bestemming
    private func navigationButton<Destination: View>(title: String, systemImage: String, destination: Destination) -> some View {
        NavigationLink(destination: destination) {
            VStack {
                Image(systemName: systemImage)
                    .font(.largeTitle)
                    .foregroundColor(Theme.textColor)
                Text(title)
                    .font(.headline)
                    .foregroundColor(Theme.textColor)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(width: 150, height: 150)
            .background(Theme.primaryButtonBackground)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Preview voor ontwikkelaars
struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
            .preferredColorScheme(.dark)
    }
}
