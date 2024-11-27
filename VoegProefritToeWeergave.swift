import SwiftUI
import EventKit

struct Foutmelding: Identifiable {
    var id = UUID()
    var bericht: String
}

struct VoegProefritToeWeergave: View {
    @State private var klantNaam: String = ""
    @State private var klantTelefoon: String = ""
    @State private var proefritDatum: Date = Date()
    @State private var notities: String = ""

    var voertuig: VoertuigEntity
    @State private var foutmelding: Foutmelding?

    var body: some View {
        ZStack {
            Theme.background.edgesIgnoringSafeArea(.all) // Achtergrondkleur vanuit Theme

            ScrollView {
                VStack(spacing: 20) {
                    Text("Plan Proefrit voor \(voertuig.merk ?? "Onbekend Merk")")
                        .font(.largeTitle)
                        .foregroundColor(Theme.textColor)
                        .padding(.top)

                    inputSection(title: "Naam Klant", text: $klantNaam)
                    inputSection(title: "Telefoonnummer", text: $klantTelefoon, keyboardType: .phonePad)

                    datePickerSection(title: "Datum proefrit", selection: $proefritDatum)

                    TextEditor(text: $notities)
                        .padding()
                        .frame(height: 150)
                        .background(Theme.secondaryButtonBackground)
                        .cornerRadius(10)
                        .foregroundColor(Theme.textFieldText)
                        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
                        .padding(.horizontal)
                        .overlay(
                            Text(notities.isEmpty ? "Notities" : "")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 12)
                                .allowsHitTesting(false),
                            alignment: .topLeading
                        )

                    saveButton()

                    Spacer()
                }
                .padding()
            }
            .alert(item: $foutmelding) { foutmelding in
                Alert(title: Text("Fout"), message: Text(foutmelding.bericht), dismissButton: .default(Text("OK")))
            }
        }
    }

    // MARK: - Subviews

    private func inputSection(title: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
                .foregroundColor(Theme.textColor)
            
            TextField(title, text: text)
                .padding()
                .background(Theme.secondaryButtonBackground)
                .cornerRadius(10)
                .foregroundColor(Theme.textFieldText)
                .keyboardType(keyboardType)
                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
        }
        .padding(.horizontal)
    }

    private func datePickerSection(title: String, selection: Binding<Date>) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
                .foregroundColor(Theme.textColor)

            DatePicker("", selection: selection, displayedComponents: [.date, .hourAndMinute])
                .labelsHidden()
                .padding()
                .background(Theme.secondaryButtonBackground)
                .cornerRadius(10)
                .foregroundColor(Theme.textFieldText)
                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
        }
        .padding(.horizontal)
    }

    private func saveButton() -> some View {
        Button(action: voegProefritToeAanAgenda) {
            Text("Opslaan en Toevoegen aan Agenda")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Theme.primaryButtonBackground)
                .foregroundColor(Theme.buttonText)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
        }
        .padding(.horizontal)
        .padding(.top)
    }

    // MARK: - Functies

    private func voegProefritToeAanAgenda() {
        guard !klantNaam.isEmpty, !klantTelefoon.isEmpty else {
            foutmelding = Foutmelding(bericht: "Vul alle velden in.")
            return
        }

        let eventStore = EKEventStore()

        eventStore.requestAccess(to: .event) { granted, error in
            if granted && error == nil {
                let newEvent = EKEvent(eventStore: eventStore)
                newEvent.title = "Proefrit: \(voertuig.merk ?? "Onbekend") \(voertuig.type ?? "Onbekend")"
                newEvent.startDate = proefritDatum
                newEvent.endDate = proefritDatum.addingTimeInterval(60 * 60)
                newEvent.notes = "Klant: \(klantNaam)\nTelefoonnummer: \(klantTelefoon)\nNotities: \(notities)"
                newEvent.calendar = eventStore.defaultCalendarForNewEvents

                do {
                    try eventStore.save(newEvent, span: .thisEvent)
                    DispatchQueue.main.async {
                        foutmelding = Foutmelding(bericht: "Proefrit is toegevoegd aan de agenda!")
                    }
                } catch {
                    DispatchQueue.main.async {
                        foutmelding = Foutmelding(bericht: "Fout bij het toevoegen aan de agenda: \(error.localizedDescription)")
                    }
                }
            } else {
                DispatchQueue.main.async {
                    foutmelding = Foutmelding(bericht: "Geen toegang tot de agenda.")
                }
            }
        }
    }
}
