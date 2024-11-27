import Foundation
import CoreData

extension InruilAutoEntity {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<InruilAutoEntity> {
        return NSFetchRequest<InruilAutoEntity>(entityName: "InruilAutoEntity")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var merk: String?
    @NSManaged public var type: String?
    @NSManaged public var kenteken: String?
    @NSManaged public var fotoPaths: [String]?  // Array voor afbeeldingspaden
    @NSManaged public var notities: String?
    @NSManaged public var folderPath: String?   // Pad naar de map waar foto's zijn opgeslagen
}

// Identificeerbaar in SwiftUI
extension InruilAutoEntity: Identifiable { }
