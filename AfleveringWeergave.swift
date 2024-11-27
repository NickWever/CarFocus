import SwiftUI
import EventKit

// Maak een wrapperstruct voor foutmeldingen
struct FoutmeldingWrapper: Identifiable {
    let id = UUID()
    let bericht: String
}

struct AfleveringWeergave: View {
    @State private var klantVoornaam: String = ""
    @State private var klantAchternaam: String = ""
    @State private var klantTelefoonnummer: String = ""
    @State private var kenteken: String = ""
    @State private var merk: String = ""
    @State private var type: String = ""
    @State private var afleverDatum: Date = Date()
    @State private var afleverNotities: String = ""
    
    @State private var foutmelding: FoutmeldingWrapper? = nil
    
    var body: some View {
        VStack {
            ScrollView {
                Spacer(minLength: 20)

                // Titel
                Text("Nieuwe Aflevering Invoeren")
                    .font(.largeTitle)
                    .foregroundColor(Theme.textColor)
                    .padding(.bottom, 20)

                // Klantgegevens invoeren
                klantGegevensSectie()
                    .padding()

                // Auto gegevens invoeren
                autoGegevensSectie()
                    .padding()

                // Notities invoeren
                notitieSectie()
                    .padding()

                // Datum kiezen voor de aflevering
                datumPickerSectie()
                    .padding()

                // Opslaan knop en toevoegen aan agenda
                opslaanKnopSectie()
                    .padding(.bottom)
            }
            .padding()
        }
        .background(Theme.background.edgesIgnoringSafeArea(.all))
        .alert(item: $foutmelding) { error in
            Alert(title: Text("Fout"), message: Text(error.bericht), dismissButton: .default(Text("OK")))
        }
    }

    // MARK: - Subviews
    private func klantGegevensSectie() -> some View {
        VStack(alignment: .leading) {
            Text("Klantgegevens")
                .font(.headline)
                .foregroundColor(Theme.textColor)
                .padding(.bottom, 10)

            TextField("Voornaam", text: $klantVoornaam)
                .padding()
                .background(Theme.textFieldBackground)
                .cornerRadius(10)
                .foregroundColor(Theme.textFieldText)
                .padding(.bottom, 10)

            TextField("Achternaam", text: $klantAchternaam)
                .padding()
                .background(Theme.textFieldBackground)
                .cornerRadius(10)
                .foregroundColor(Theme.textFieldText)
                .padding(.bottom, 10)

            TextField("Telefoonnummer", text: $klantTelefoonnummer)
                .padding()
                .background(Theme.textFieldBackground)
                .cornerRadius(10)
                .foregroundColor(Theme.textFieldText)
                .keyboardType(.phonePad)
                .padding(.bottom, 10)
        }
    }

    private func autoGegevensSectie() -> some View {
        VStack(alignment: .leading) {
            Text("Auto Gegevens")
                .font(.headline)
                .foregroundColor(Theme.textColor)
                .padding(.bottom, 10)

            TextField("Merk", text: $merk)
                .padding()
                .background(Theme.textFieldBackground)
                .cornerRadius(10)
                .foregroundColor(Theme.textFieldText)
                .padding(.bottom, 10)

            TextField("Type", text: $type)
                .padding()
                .background(Theme.textFieldBackground)
                .cornerRadius(10)
                .foregroundColor(Theme.textFieldText)
                .padding(.bottom, 10)

            TextField("Kenteken", text: $kenteken)
                .padding()
                .background(Theme.textFieldBackground)
                .cornerRadius(10)
                .foregroundColor(Theme.textFieldText)
                .padding(.bottom, 10)
        }
    }

    private func notitieSectie() -> some View {
        VStack(alignment: .leading) {
            Text("Notities")
                .font(.headline)
                .foregroundColor(Theme.textColor)
                .padding(.bottom, 10)

            TextEditor(text: $afleverNotities)
                .padding()
                .frame(height: 150)
                .background(Theme.textFieldBackground)
                .cornerRadius(10)
                .foregroundColor(Theme.textFieldText)
        }
    }

    private func datumPickerSectie() -> some View {
        VStack(alignment: .leading) {
            Text("Afleverdatum en tijd")
                .font(.headline)
                .foregroundColor(Theme.textColor)
                .padding(.bottom, 10)

            DatePicker("Selecteer datum en tijd", selection: $afleverDatum, displayedComponents: [.date, .hourAndMinute])
                .labelsHidden()
                .padding()
                .background(Theme.textFieldBackground)
                .cornerRadius(10)
                .foregroundColor(Theme.textFieldText)
        }
    }

    private func opslaanKnopSectie() -> some View {
        VStack {
            Button(action: voegAfspraakToeAanAgenda) {
                Text("Opslaan en Toevoegen aan Agenda")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Theme.primaryButtonBackground)
                    .foregroundColor(Theme.buttonText)
                    .cornerRadius(10)
            }
        }
    }

    // MARK: - Acties
    private func voegAfspraakToeAanAgenda() {
        // Check of alle verplichte velden zijn ingevuld
        guard !klantVoornaam.isEmpty, !klantAchternaam.isEmpty, !klantTelefoonnummer.isEmpty, !kenteken.isEmpty, !merk.isEmpty, !type.isEmpty else {
            foutmelding = FoutmeldingWrapper(bericht: "Vul alle verplichte velden in.")
            return
        }

        // EventStore gebruiken om toegang te krijgen tot de agenda
        let eventStore = EKEventStore()

        // Vraag volledige toegang tot de agenda
        eventStore.requestFullAccessToEvents { (granted, error) in
            if granted && error == nil {
                let newEvent = EKEvent(eventStore: eventStore)
                newEvent.title = "Aflevering \(kenteken) - \(merk) \(type) - \(klantVoornaam) \(klantAchternaam)"
                newEvent.startDate = afleverDatum
                newEvent.endDate = afleverDatum.addingTimeInterval(60 * 60) // Standaard 1 uur
                newEvent.notes = afleverNotities
                newEvent.calendar = eventStore.defaultCalendarForNewEvents
                
                do {
                    try eventStore.save(newEvent, span: .thisEvent)
                    DispatchQueue.main.async {
                        foutmelding = FoutmeldingWrapper(bericht: "Aflevering is toegevoegd aan de agenda!")
                    }
                } catch {
                    DispatchQueue.main.async {
                        foutmelding = FoutmeldingWrapper(bericht: "Fout bij het toevoegen aan de agenda: \(error.localizedDescription)")
                    }
                }
            } else {
                DispatchQueue.main.async {
                    foutmelding = FoutmeldingWrapper(bericht: "Geen toegang tot de agenda.")
                }
            }
        }
    }
}

struct AfleveringWeergave_Previews: PreviewProvider {
    static var previews: some View {
        AfleveringWeergave()
    }
}
