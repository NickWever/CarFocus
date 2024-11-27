import SwiftUI
import CoreData
import UIKit
import Foundation


struct Theme {
    // Achtergrondkleuren
    static let background = Color(hexString: "#3C3C3C")    // Donkergrijze achtergrond
    static let cardBackground = Color.white                // Witte achtergrond voor kaarten
    static let primaryButtonBackground = Color(hexString: "#FF6F3C") // Diep oranje voor primaire actieknoppen
    static let secondaryButtonBackground = Color(hexString: "#800020") // Bordeauxrood voor secundaire knoppen
    static let textColor = Color(hexString: "#EAEAEA")     // Lichtgrijze kleur voor tekst
    static let subtitleText = Color(hexString: "#C0C0C0")  // Nog lichtere grijs voor subtitel tekst
    static let textFieldBackground = Color.white           // Witte achtergrond voor tekstvakken
    static let textFieldText = Color.black                // Zwarte kleur voor tekst in invulvelden
    static let buttonText = Color.white                   // Witte kleur voor tekst op knoppen
    static let accent = Color(hexString: "#00A3E0")       // Accent kleur
}



// MARK: - Hex-kleurinitialisatie
extension Color {
    init(hexString: String) {
        var hexSanitized = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized

        var rgbValue: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgbValue)
        
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1.0)
    }
}

// Aangepaste TextField-stijl voor witte achtergrond
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(10)
            .background(Theme.textFieldBackground)  // Witte achtergrond voor tekstvakken
            .cornerRadius(8)
            .foregroundColor(Theme.textFieldText)  // Zwarte kleur voor tekst
            .font(.system(size: 18, weight: .medium))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.clear, lineWidth: 0)
            )
    }
}


// Gebruik `CustomTextFieldStyle` direct op `TextField`-elementen en pas de stijl toe per element.


// Custom titel tekst met een modernere look
struct TitleText: View {
    var text: String
    var body: some View {
        Text(text)
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .foregroundColor(Theme.accent) // Accentkleur toegepast op de titel
            .padding(.bottom, 10)
    }
}

// Custom subtitle tekst met subtielere stijl
struct SubtitleText: View {
    var text: String
    var body: some View {
        Text(text)
            .font(.system(size: 16, weight: .medium, design: .default))
            .foregroundColor(Theme.textColor)
            .padding(.bottom, 5)
    }
}

// Luxe knopweergave met aangepaste stijl
struct LuxButton: View {
    var text: String
    var action: (() -> Void)?

    var body: some View {
        Button(action: {
            action?()
        }) {
            Text(text)
                .font(.headline)
                .foregroundColor(Theme.buttonText)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Theme.primaryButtonBackground)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 4)
        }
    }
}

// In je hoofdapplicatie kun je nu de accentkleur op meer elementen toepassen:

@main
struct CarFocusApp: App {
    // Initialiseer de PersistenceController
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainMenuView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
                .accentColor(Theme.accent) // Toepassen van accentkleur op navigatiebalk en andere UI-elementen
        }
    }
}
