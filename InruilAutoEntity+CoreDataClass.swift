import Foundation
import CoreData

@objc(InruilAutoEntity)
public class InruilAutoEntity: NSManagedObject, Codable {
    
    enum CodingKeys: String, CodingKey {
        case id, merk, type, kenteken, fotoPaths, folderPath // Voeg folderPath toe aan de CodingKeys
    }
    
    // Encoder (vertaal naar JSON)
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(merk, forKey: .merk)
        try container.encode(type, forKey: .type)
        try container.encode(kenteken, forKey: .kenteken)
        try container.encode(fotoPaths, forKey: .fotoPaths)
        try container.encode(folderPath, forKey: .folderPath) // Codeer folderPath
    }
    
    // Decoder (vertaal van JSON naar Core Data object)
    required convenience public init(from decoder: Decoder) throws {
        let context = PersistenceController.shared.container.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "InruilAutoEntity", in: context)!
        self.init(entity: entity, insertInto: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.merk = try container.decodeIfPresent(String.self, forKey: .merk)
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self.kenteken = try container.decodeIfPresent(String.self, forKey: .kenteken)
        self.fotoPaths = try container.decodeIfPresent([String].self, forKey: .fotoPaths)
        self.folderPath = try container.decodeIfPresent(String.self, forKey: .folderPath) // Decodeer folderPath
    }
    
    // Standaard init voor NSManagedObject
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
}
