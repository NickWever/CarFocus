import SwiftUI
import CoreData

struct VerkoopDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var klantVoornaam: String = ""
    @State private var klantAchternaam: String = ""
    @State private var klantTelefoonnummer: String = ""
    @State private var klantEmail: String = ""
    @State private var isLease: Bool = false
    @State private var isAutoVerkocht: Bool = false
    @State private var afleverDatum: Date = Date()

    var voertuig: VoertuigEntity  // Het specifieke voertuig

    var body: some View {
        ZStack {
            Color(.systemGray5).edgesIgnoringSafeArea(.all) // Lichte achtergrondkleur

            ScrollView {
                VStack(spacing: 20) {
                    Text("Verkoop Details voor \(voertuig.merk ?? "Onbekend Merk")")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                        .padding(.top)

                    klantGegevensSectie()
                        .padding(.horizontal)
                    
                    leaseOfKoopSectie()
                        .padding(.horizontal)

                    verkoopSectie()
                        .padding(.horizontal)

                    if isAutoVerkocht {
                        afleverSectie()
                            .padding(.horizontal)
                    }

                    opslaanKnopSectie()
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            laadVerkoopgegevens()
        }
    }

    // MARK: - Subviews

    private func klantGegevensSectie() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Klantgegevens")
                .font(.headline)
                .foregroundColor(.black)
            
            VStack(spacing: 10) {
                TextField("Voornaam", text: $klantVoornaam)
                    .textFieldStyle()
                
                TextField("Achternaam", text: $klantAchternaam)
                    .textFieldStyle()
                
                TextField("Telefoonnummer", text: $klantTelefoonnummer)
                    .textFieldStyle()
                    .keyboardType(.phonePad)
                
                TextField("E-mailadres", text: $klantEmail)
                    .textFieldStyle()
                    .keyboardType(.emailAddress)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
    }

    private func leaseOfKoopSectie() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Lease of Koop")
                .font(.headline)
                .foregroundColor(.black)
            
            Toggle("Lease Voertuig", isOn: $isLease)
                .toggleStyle(SwitchToggleStyle(tint: .blue))
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
    }

    private func verkoopSectie() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Verkoopstatus")
                .font(.headline)
                .foregroundColor(.black)
            
            Toggle("Auto Verkocht", isOn: $isAutoVerkocht)
                .toggleStyle(SwitchToggleStyle(tint: .green))
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
    }

    private func afleverSectie() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Afleverdatum")
                .font(.headline)
                .foregroundColor(.black)
            
            DatePicker("Selecteer een afleverdatum", selection: $afleverDatum, displayedComponents: [.date])
                .labelsHidden()
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
    }

    private func opslaanKnopSectie() -> some View {
        VStack {
            Button(action: slaVerkoopOp) {
                Text("Verkoop Opslaan")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
            }
        }
    }

    // MARK: - Acties

    private func laadVerkoopgegevens() {
        klantVoornaam = voertuig.klantVoornaam ?? ""
        klantAchternaam = voertuig.klantAchternaam ?? ""
        klantTelefoonnummer = voertuig.klantTelefoonnummer ?? ""
        klantEmail = voertuig.klantEmail ?? ""
        isLease = voertuig.isLease
        isAutoVerkocht = voertuig.isVerkocht
        afleverDatum = voertuig.afleverDatum ?? Date()
    }

    private func slaVerkoopOp() {
        voertuig.klantVoornaam = klantVoornaam
        voertuig.klantAchternaam = klantAchternaam
        voertuig.klantTelefoonnummer = klantTelefoonnummer
        voertuig.klantEmail = klantEmail
        voertuig.isLease = isLease
        voertuig.isVerkocht = isAutoVerkocht
        voertuig.afleverDatum = afleverDatum

        do {
            try viewContext.save()
            print("Verkoopgegevens succesvol opgeslagen!")
        } catch {
            print("Fout bij het opslaan van de verkoopgegevens: \(error)")
        }
    }
}

// MARK: - Custom TextField Style
extension TextField {
    func textFieldStyle() -> some View {
        self
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
            .foregroundColor(.black)
    }
}
