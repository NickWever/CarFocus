import Foundation
import CoreData

extension ZoekopdrachtEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ZoekopdrachtEntity> {
        return NSFetchRequest<ZoekopdrachtEntity>(entityName: "ZoekopdrachtEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var merk: String?
    @NSManaged public var model: String?
    @NSManaged public var motor: String?
    @NSManaged public var pk: Int32
    @NSManaged public var gewensteKmStand: Int32
    @NSManaged public var bouwjaar: Int16
    @NSManaged public var naamKlant: String?
    @NSManaged public var telefoonnummerKlant: String?
    @NSManaged public var emailKlant: String?
    @NSManaged public var gewensteLeverdatum: Date?
}

extension ZoekopdrachtEntity: Identifiable {}
