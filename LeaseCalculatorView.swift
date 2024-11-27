import SwiftUI

struct LeaseCalculatorView: View {
    @State private var aanschafWaarde: Double = 0.0
    @State private var btwInbegrepen: Bool = false
    @State private var rentePercentage: Double = 0.0
    @State private var looptijd: Int = 36
    @State private var aanbetaling: Double = 0.0
    @State private var slottermijn: Double = 0.0
    @State private var maandelijkseBetaling: Double?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Lease Calculator")
                    .font(.largeTitle)
                    .foregroundColor(Theme.textColor)
                    .padding()

                VStack(alignment: .leading, spacing: 15) {
                    Text("Lease Details")
                        .font(.headline)
                        .foregroundColor(Theme.textColor)

                    leaseDetailInput(title: "Aanschafwaarde excl. BTW", value: $aanschafWaarde, keyboardType: .decimalPad)
                    
                    Toggle("BTW inbegrepen", isOn: $btwInbegrepen)
                        .toggleStyle(SwitchToggleStyle(tint: Theme.accent))
                        .padding(.top, 5)

                    leaseDetailInputPercentage(title: "Rente (%)", value: $rentePercentage)

                    leaseDetailInputInt(title: "Looptijd (maanden)", value: $looptijd, keyboardType: .numberPad)

                    leaseDetailInput(title: "Aanbetaling", value: $aanbetaling, keyboardType: .decimalPad)
                    leaseDetailInput(title: "Slottermijn", value: $slottermijn, keyboardType: .decimalPad)
                }
                .padding()
                .background(Theme.background)
                .cornerRadius(12)
                .shadow(radius: 5)
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Resultaat")
                        .font(.headline)
                        .foregroundColor(Theme.textColor)
                        .padding(.bottom, 5)

                    if let maandelijkseBetaling = maandelijkseBetaling {
                        Text("Maandelijkse Betaling: \(maandelijkseBetaling, format: .currency(code: "EUR"))")
                            .font(.headline)
                            .foregroundColor(Theme.textColor)
                    } else {
                        Text("Voer alle gegevens in en druk op 'Bereken'")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Theme.background)
                .cornerRadius(12)
                .shadow(radius: 5)
                .padding(.horizontal)

                Button(action: berekenMaandelijkseBetaling) {
                    Text("Bereken")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Theme.primaryButtonBackground)
                        .foregroundColor(Theme.buttonText)
                        .cornerRadius(10)
                }
                .padding()
                .padding(.bottom, 20)
            }
        }
        .background(Theme.background.edgesIgnoringSafeArea(.all))
    }

    @ViewBuilder
    private func leaseDetailInput(title: String, value: Binding<Double>, keyboardType: UIKeyboardType) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(Theme.textColor)
            
            TextField("", value: value, format: .currency(code: "EUR"))
                .keyboardType(keyboardType)
                .padding(10)
                .background(Color.white)
                .cornerRadius(8)
                .foregroundColor(.black)
        }
        .padding(.bottom, 10)
    }

    @ViewBuilder
    private func leaseDetailInputPercentage(title: String, value: Binding<Double>) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(Theme.textColor)
            
            TextField("", value: value, format: .number.precision(.fractionLength(2)))
                .keyboardType(.decimalPad)
                .padding(10)
                .background(Color.white)
                .cornerRadius(8)
                .foregroundColor(.black)
        }
        .padding(.bottom, 10)
    }

    @ViewBuilder
    private func leaseDetailInputInt(title: String, value: Binding<Int>, keyboardType: UIKeyboardType) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(Theme.textColor)
            
            TextField("", value: value, format: .number)
                .keyboardType(keyboardType)
                .padding(10)
                .background(Color.white)
                .cornerRadius(8)
                .foregroundColor(.black)
        }
        .padding(.bottom, 10)
    }

    private func berekenMaandelijkseBetaling() {
        let autoPrijs = btwInbegrepen ? aanschafWaarde * 1.21 : aanschafWaarde
        let financieringsBedrag = autoPrijs - aanbetaling

        let maandRente = (rentePercentage / 100) / 12.0
        let n = Double(looptijd)

        if maandRente > 0 {
            maandelijkseBetaling = (financieringsBedrag * maandRente) / (1 - pow(1 + maandRente, -n)) + (slottermijn / n)
        } else {
            maandelijkseBetaling = financieringsBedrag / n
        }
    }
}

