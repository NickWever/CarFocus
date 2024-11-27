//
//  AutoEntity.swift
//  CarFocus
//
//  Created by Nick Wever on 17/10/2024.
//

import CoreData

@objc(AutoEntity)
public class AutoEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var merk: String
    @NSManaged public var model: String
    @NSManaged public var kenteken: String
    @NSManaged public var klantNaam: String
    @NSManaged public var klantTelefoonnummer: String
    @NSManaged public var verkoopstatus: String
    @NSManaged public var proefritDatum: Date?
    @NSManaged public var notities: String?
}

// MARK: - Extension for CoreData Fetching
extension AutoEntity {
    static func fetchRequest() -> NSFetchRequest<AutoEntity> {
        let request = NSFetchRequest<AutoEntity>(entityName: "AutoEntity")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \AutoEntity.merk, ascending: true)]
        return request
    }
}
