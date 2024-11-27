import SwiftUI
import CoreData

struct LopendeVerkopenWeergave: View {
    @Environment(\.managedObjectContext) private var viewContext

    // Ophalen van voertuigen uit Core Data, gesorteerd op merk
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VoertuigEntity.merk, ascending: true)],
        animation: .default)
    private var voertuigen: FetchedResults<VoertuigEntity>

    @State private var zoekTerm: String = ""

    var body: some View {
        VStack {
            // Zoekbalk voor het filteren van voertuigen op merk of kenteken
            zoekBalkSectie()

            // Lijst met gefilterde voertuigen
            voertuigLijst()
        }
        .background(Theme.background.edgesIgnoringSafeArea(.all))
        .navigationBarTitle("Lopende Verkopen")
    }

    // MARK: - Subviews

    private func zoekBalkSectie() -> some View {
        TextField("Zoek op merk of kenteken", text: $zoekTerm)
            .padding()
            .background(Theme.textFieldBackground)  // Witte achtergrond voor de zoekbalk
            .cornerRadius(10)
            .foregroundColor(Theme.textFieldText)  // Zwarte tekstkleur in de zoekbalk
            .padding(.horizontal)
    }

    private func voertuigLijst() -> some View {
        List {
            ForEach(filteredVoertuigen(), id: \.id) { voertuig in  // Gebruik hier een uniek kenmerk zoals 'id'
                NavigationLink(destination: VerkoopDetailView(voertuig: voertuig)) { // Geef het voertuig object door
                    voertuigDetails(voertuig: voertuig)
                }
            }
            .onDelete(perform: deleteVoertuigen)
        }
        .listStyle(PlainListStyle())
        .background(Theme.background)
    }

    private func voertuigDetails(voertuig: VoertuigEntity) -> some View {
        VStack(alignment: .leading) {
            Text("\(voertuig.merk ?? "Onbekend Merk") \(voertuig.type ?? "Onbekend Type")")
                .font(.headline)
                .foregroundColor(Theme.textColor)
            Text("Kenteken: \(voertuig.kenteken ?? "Onbekend Kenteken")")
                .font(.subheadline)
                .foregroundColor(Theme.textColor.opacity(0.7))  // Gebruik een lichte tint voor secundaire informatie
            Text("Status: \(voertuig.verkoopstatus ?? "Onbekend")")
                .font(.subheadline)
                .foregroundColor(voertuig.verkoopstatus == "Verkocht" ? .green : .orange)
        }
    }

    // MARK: - Functies

    private func filteredVoertuigen() -> [VoertuigEntity] {
        let zoektermLageKast = zoekTerm.lowercased()

        // Filter voertuigen op basis van merk of kenteken
        return voertuigen.filter { voertuig in
            let merkBevatZoekterm = voertuig.merk?.lowercased().contains(zoektermLageKast) ?? false
            let kentekenBevatZoekterm = voertuig.kenteken?.lowercased().contains(zoektermLageKast) ?? false
            return merkBevatZoekterm || kentekenBevatZoekterm
        }
    }

    // Functie om voertuigen te verwijderen
    private func deleteVoertuigen(at offsets: IndexSet) {
        withAnimation {
            offsets.map { voertuigen[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                print("Fout bij het verwijderen van voertuig: \(error.localizedDescription)")
            }
        }
    }
}
