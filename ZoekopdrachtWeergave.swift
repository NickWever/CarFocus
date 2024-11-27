import SwiftUI
import CoreData

struct ZoekopdrachtWeergave: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ZoekopdrachtEntity.gewensteLeverdatum, ascending: true)],
        animation: .default)
    private var zoekopdrachten: FetchedResults<ZoekopdrachtEntity>
    
    @State private var toonNieuweZoekopdracht = false

    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.edgesIgnoringSafeArea(.all) // Achtergrondkleur uit Theme
                
                List {
                    ForEach(zoekopdrachten) { zoekopdracht in
                        VStack(alignment: .leading, spacing: 5) {
                            Text("\(zoekopdracht.merk ?? "") \(zoekopdracht.model ?? "")")
                                .font(.headline)
                                .foregroundColor(Theme.textColor) // Gebruik Theme kleur
                            Text("Motor: \(zoekopdracht.motor ?? "")")
                                .font(.subheadline)
                                .foregroundColor(Theme.textColor)
                            Text("PK: \(zoekopdracht.pk)")
                                .font(.subheadline)
                                .foregroundColor(Theme.textColor)
                            Text("Gewenste KM-stand: \(zoekopdracht.gewensteKmStand)")
                                .font(.subheadline)
                                .foregroundColor(Theme.textColor)
                            Text("Bouwjaar: \(zoekopdracht.bouwjaar)")
                                .font(.subheadline)
                                .foregroundColor(Theme.textColor)
                            Text("Gewenste Leverdatum: \(formattedDate(zoekopdracht.gewensteLeverdatum ?? Date()))")
                                .font(.subheadline)
                                .foregroundColor(Theme.textColor)
                            Text("Klant: \(zoekopdracht.naamKlant ?? "")")
                                .font(.subheadline)
                                .foregroundColor(Theme.textColor)
                            Text("Telefoon: \(zoekopdracht.telefoonnummerKlant ?? "")")
                                .font(.subheadline)
                                .foregroundColor(Theme.textColor)
                            Text("Email: \(zoekopdracht.emailKlant ?? "")")
                                .font(.subheadline)
                                .foregroundColor(Theme.textColor)
                        }
                        .padding(.vertical, 5)
                    }
                    .onDelete(perform: verwijderZoekopdrachten)
                }
                .navigationTitle("Zoekopdrachten")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                            .foregroundColor(Theme.buttonText) // Gebruik Theme kleur voor knoppen
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { toonNieuweZoekopdracht = true }) {
                            Label("Nieuwe Zoekopdracht", systemImage: "plus")
                                .foregroundColor(Theme.buttonText)
                        }
                        .padding()
                        .background(Theme.primaryButtonBackground) // Knopachtergrond uit Theme
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 4)
                    }
                }
                .sheet(isPresented: $toonNieuweZoekopdracht) {
                    NieuweZoekopdrachtWeergave()
                        .environment(\.managedObjectContext, viewContext)
                }
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func verwijderZoekopdrachten(at offsets: IndexSet) {
        for index in offsets {
            let zoekopdracht = zoekopdrachten[index]
            viewContext.delete(zoekopdracht)
        }
        do {
            try viewContext.save()
        } catch {
            print("Fout bij verwijderen van zoekopdracht: \(error.localizedDescription)")
        }
    }
}
