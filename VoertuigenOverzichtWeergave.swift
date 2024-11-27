import SwiftUI
import CoreData

// De overzichtsweergave van voertuigen
struct VoertuigenOverzichtWeergave: View {
    @Environment(\.managedObjectContext) private var viewContext

    // Fetch requests voor verkoop- en inruilvoertuigen
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VoertuigEntity.merk, ascending: true)],
        animation: .default)
    private var voertuigen: FetchedResults<VoertuigEntity>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \InruilAutoEntity.merk, ascending: true)],
        animation: .default)
    private var inruilVoertuigen: FetchedResults<InruilAutoEntity>

    @State private var zoekTerm: String = ""

    enum FilterType: String, CaseIterable {
        case verkoop = "Verkoop Voertuigen"
        case inruil = "Inruil Voertuigen"
        case alle = "Alle Voertuigen"
    }

    @State private var geselecteerdeFilter: FilterType = .alle

    var body: some View {
        VStack {
            Spacer(minLength: 20)

            // Titel
            Text("Voertuigen Overzicht")
                .font(.largeTitle)
                .foregroundColor(Theme.textColor)
                .padding(.bottom, 20)

            // Zoekbalk
            TextField("Zoek op merk of kenteken", text: $zoekTerm)
                .padding()
                .background(Theme.textFieldBackground) // Witte achtergrond uit Theme
                .cornerRadius(10)
                .foregroundColor(Theme.textFieldText)  // Zwarte tekstkleur uit Theme
                .padding(.horizontal)

            // Picker voor filteren
            Picker("Filter", selection: $geselecteerdeFilter) {
                ForEach(FilterType.allCases, id: \.self) { filter in
                    Text(filter.rawValue)
                        .tag(filter)
                        .foregroundColor(Theme.textColor) // Zwarte tekst voor leesbaarheid
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .background(Theme.secondaryButtonBackground) // Bordeauxrode achtergrond voor de segment picker
            .padding()
            .cornerRadius(8)
            .shadow(color: .gray, radius: 5)

            // Lijst met secties voor Verkoopvoertuigen en Inruilvoertuigen
            List {
                if geselecteerdeFilter == .verkoop || geselecteerdeFilter == .alle {
                    verkoopVoertuigenSectie
                }

                if geselecteerdeFilter == .inruil || geselecteerdeFilter == .alle {
                    inruilVoertuigenSectie
                }
            }
            .listStyle(PlainListStyle())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.clear)
            .padding(.horizontal)

            // Voeg Voertuig Toe knop
            NavigationLink(destination: VoegNieuwVoertuigToeWeergave()) {
                Text("Voeg Voertuig Toe")
                    .font(.headline)
                    .foregroundColor(Theme.buttonText)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Theme.primaryButtonBackground)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .background(Theme.background.edgesIgnoringSafeArea(.all)) // Donkere achtergrond
        .navigationBarTitle("Voertuigen Overzicht", displayMode: .inline) // Navigatiebalk met titel
        .navigationBarBackButtonHidden(false) // Standaard terug-knop zichtbaar maken
    }

    // Sectie voor verkoopvoertuigen
    private var verkoopVoertuigenSectie: some View {
        Section(header: Text("Verkoop Voertuigen")
                    .font(.headline)
                    .foregroundColor(Theme.textColor)) {
            let gefilterdeVerkoopVoertuigen = voertuigen.filter { voertuig in
                zoekTerm.isEmpty ||
                voertuig.merk?.localizedCaseInsensitiveContains(zoekTerm) == true ||
                voertuig.kenteken?.localizedCaseInsensitiveContains(zoekTerm) == true
            }

            ForEach(gefilterdeVerkoopVoertuigen) { voertuig in
                NavigationLink(destination: VoertuigDetailView(voertuig: .verkoop(voertuig))) {
                    VStack(alignment: .leading) {
                        Text(voertuig.merk ?? "Onbekend Merk")
                            .font(.headline)
                            .foregroundColor(Theme.textColor)
                        Text(voertuig.kenteken ?? "Onbekend Kenteken")
                            .font(.subheadline)
                            .foregroundColor(Theme.textColor.opacity(0.7)) // Lichte tint voor kenteken
                    }
                }
            }
            .onDelete(perform: deleteVoertuigen)
        }
    }

    // Sectie voor inruilvoertuigen
    private var inruilVoertuigenSectie: some View {
        Section(header: Text("Inruil Voertuigen")
                    .font(.headline)
                    .foregroundColor(Theme.textColor)) {
            let gefilterdeInruilVoertuigen = inruilVoertuigen.filter { voertuig in
                zoekTerm.isEmpty ||
                voertuig.merk?.localizedCaseInsensitiveContains(zoekTerm) == true ||
                voertuig.kenteken?.localizedCaseInsensitiveContains(zoekTerm) == true
            }

            ForEach(gefilterdeInruilVoertuigen) { voertuig in
                NavigationLink(destination: VoertuigDetailView(voertuig: .inruil(voertuig))) {
                    VStack(alignment: .leading) {
                        Text(voertuig.merk ?? "Onbekend Merk")
                            .font(.headline)
                            .foregroundColor(Theme.textColor)
                        Text(voertuig.kenteken ?? "Onbekend Kenteken")
                            .font(.subheadline)
                            .foregroundColor(Theme.textColor.opacity(0.7)) // Lichte tint voor kenteken
                    }
                }
            }
            .onDelete(perform: deleteInruilVoertuigen)
        }
    }

    // Functie om verkoopvoertuigen te verwijderen
    private func deleteVoertuigen(offsets: IndexSet) {
        withAnimation {
            offsets.map { voertuigen[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                print("Fout bij het verwijderen van verkoopvoertuig: \(error.localizedDescription)")
            }
        }
    }

    // Functie om inruilvoertuigen te verwijderen
    private func deleteInruilVoertuigen(offsets: IndexSet) {
        withAnimation {
            offsets.map { inruilVoertuigen[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                print("Fout bij het verwijderen van inruilvoertuig: \(error.localizedDescription)")
            }
        }
    }
}
