import Foundation
import CoreData

extension VoertuigEntity {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<VoertuigEntity> {
        return NSFetchRequest<VoertuigEntity>(entityName: "VoertuigEntity")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var merk: String?
    @NSManaged public var type: String?
    @NSManaged public var kenteken: String?
    @NSManaged public var fotoPaths: [String]?  // Array voor afbeeldingspaden
    @NSManaged public var fotoData: Data?       // Voor het opslaan van afbeeldingen als binary data
    @NSManaged public var notities: String?     // Voor het opslaan van notities
    @NSManaged public var verkoopstatus: String? // Voor de verkoopstatus van het voertuig
    
    // Nieuwe velden voor klantinformatie en voertuigstatus
    @NSManaged public var klantVoornaam: String?     // Voornaam van de klant
    @NSManaged public var klantAchternaam: String?   // Achternaam van de klant
    @NSManaged public var klantTelefoonnummer: String? // Telefoonnummer van de klant
    @NSManaged public var klantEmail: String?        // E-mailadres van de klant
    @NSManaged public var isLease: Bool              // Geeft aan of het voertuig een lease is
    @NSManaged public var isVerkocht: Bool           // Geeft aan of het voertuig is verkocht
    @NSManaged public var afleverDatum: Date?        // Afleverdatum voor het voertuig
    
    // Nieuw veld voor folderPath
    @NSManaged public var folderPath: String?        // Path naar de map waar de foto's worden opgeslagen
}

// Zorg ervoor dat de klasse conform is aan Identifiable
extension VoertuigEntity: Identifiable {}
