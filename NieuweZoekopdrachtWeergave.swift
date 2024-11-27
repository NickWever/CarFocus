import SwiftUI
import CoreData

struct NieuweZoekopdrachtWeergave: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    // Zoekopdracht eigenschappen
    @State private var merk: String = ""
    @State private var model: String = ""
    @State private var motor: String = ""
    @State private var pk: Int32?
    @State private var gewensteKmStand: Int32?
    @State private var bouwjaar: Int16?
    @State private var naamKlant: String = ""
    @State private var telefoonnummerKlant: String = ""
    @State private var emailKlant: String = ""
    @State private var gewensteLeverdatum: Date = Date()

    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.edgesIgnoringSafeArea(.all) // Achtergrondkleur uit Theme

                Form {
                    Section(header: Text("Voertuig Informatie").foregroundColor(Theme.textColor)) {
                        customTextField("Merk", text: $merk)
                        customTextField("Model", text: $model)
                        customTextField("Motor", text: $motor)
                        
                        customNumberField("PK", value: $pk)
                        customNumberField("Gewenste KM Stand", value: $gewensteKmStand)
                        customNumberField("Bouwjaar", value: $bouwjaar)
                    }
                    
                    Section(header: Text("Klant Informatie").foregroundColor(Theme.textColor)) {
                        customTextField("Naam Klant", text: $naamKlant)
                        customTextField("Telefoonnummer", text: $telefoonnummerKlant)
                        customTextField("Email", text: $emailKlant)
                        
                        DatePicker("Gewenste Leverdatum", selection: $gewensteLeverdatum, displayedComponents: .date)
                            .foregroundColor(Theme.textColor)
                            .datePickerStyle(.compact)
                    }
                }
                .background(Theme.background)
                .navigationTitle("Nieuwe Zoekopdracht")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Annuleer") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(Theme.buttonText)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Opslaan") {
                            voegZoekopdrachtToe()
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(Theme.buttonText)
                    }
                }
            }
        }
    }

    // MARK: - Custom TextField met Theme
    private func customTextField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .padding(10)
            .background(Theme.textFieldBackground)
            .cornerRadius(8)
            .foregroundColor(Theme.textColor)
    }

    // MARK: - Custom NumberField voor optionele Int waarden
    private func customNumberField<T: BinaryInteger>(_ placeholder: String, value: Binding<T?>) -> some View {
        TextField(placeholder, value: value, formatter: NumberFormatter())
            .keyboardType(.numberPad)
            .padding(10)
            .background(Theme.textFieldBackground)
            .cornerRadius(8)
            .foregroundColor(Theme.textColor)
    }

    // MARK: - Voeg Zoekopdracht Toe aan Core Data
    private func voegZoekopdrachtToe() {
        let nieuweZoekopdracht = ZoekopdrachtEntity(context: viewContext)
        nieuweZoekopdracht.id = UUID()
        nieuweZoekopdracht.merk = merk
        nieuweZoekopdracht.model = model
        nieuweZoekopdracht.motor = motor
        nieuweZoekopdracht.pk = pk ?? 0
        nieuweZoekopdracht.gewensteKmStand = gewensteKmStand ?? 0
        nieuweZoekopdracht.bouwjaar = bouwjaar ?? 0
        nieuweZoekopdracht.naamKlant = naamKlant
        nieuweZoekopdracht.telefoonnummerKlant = telefoonnummerKlant
        nieuweZoekopdracht.emailKlant = emailKlant
        nieuweZoekopdracht.gewensteLeverdatum = gewensteLeverdatum

        do {
            try viewContext.save()
        } catch {
            print("Fout bij opslaan van zoekopdracht: \(error)")
        }
    }
}
