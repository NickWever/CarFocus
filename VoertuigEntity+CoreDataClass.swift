import Foundation
import CoreData

@objc(VoertuigEntity)
public class VoertuigEntity: NSManagedObject, Codable {

    enum CodingKeys: String, CodingKey {
        case id, merk, type, kenteken, fotoPaths, fotoData, verkoopstatus, notities
        case klantVoornaam, klantAchternaam, klantTelefoonnummer, klantEmail
        case isLease, isVerkocht, afleverDatum, folderPath // Voeg folderPath toe
    }

    // Encoder (naar JSON vertalen)
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(merk, forKey: .merk)
        try container.encode(type, forKey: .type)
        try container.encode(kenteken, forKey: .kenteken)
        try container.encode(fotoPaths, forKey: .fotoPaths)
        try container.encode(fotoData, forKey: .fotoData)
        try container.encode(verkoopstatus, forKey: .verkoopstatus)
        try container.encode(notities, forKey: .notities)
        
        // Nieuwe velden voor klantgegevens en status
        try container.encode(klantVoornaam, forKey: .klantVoornaam)
        try container.encode(klantAchternaam, forKey: .klantAchternaam)
        try container.encode(klantTelefoonnummer, forKey: .klantTelefoonnummer)
        try container.encode(klantEmail, forKey: .klantEmail)
        try container.encode(isLease, forKey: .isLease)
        try container.encode(isVerkocht, forKey: .isVerkocht)
        try container.encode(afleverDatum, forKey: .afleverDatum)
        
        // Encodeer folderPath
        try container.encode(folderPath, forKey: .folderPath)
    }

    // Decoder (van JSON naar object)
    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.context!] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.missingManagedObjectContext
        }

        let entity = NSEntityDescription.entity(forEntityName: "VoertuigEntity", in: context)!
        self.init(entity: entity, insertInto: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.merk = try container.decodeIfPresent(String.self, forKey: .merk)
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self.kenteken = try container.decodeIfPresent(String.self, forKey: .kenteken)
        self.fotoPaths = try container.decodeIfPresent([String].self, forKey: .fotoPaths)
        self.fotoData = try container.decodeIfPresent(Data.self, forKey: .fotoData)
        self.verkoopstatus = try container.decodeIfPresent(String.self, forKey: .verkoopstatus)
        self.notities = try container.decodeIfPresent(String.self, forKey: .notities)
        
        // Decodeer nieuwe velden voor klantgegevens en status
        self.klantVoornaam = try container.decodeIfPresent(String.self, forKey: .klantVoornaam)
        self.klantAchternaam = try container.decodeIfPresent(String.self, forKey: .klantAchternaam)
        self.klantTelefoonnummer = try container.decodeIfPresent(String.self, forKey: .klantTelefoonnummer)
        self.klantEmail = try container.decodeIfPresent(String.self, forKey: .klantEmail)
        self.isLease = try container.decodeIfPresent(Bool.self, forKey: .isLease) ?? false
        self.isVerkocht = try container.decodeIfPresent(Bool.self, forKey: .isVerkocht) ?? false
        self.afleverDatum = try container.decodeIfPresent(Date.self, forKey: .afleverDatum)
        
        // Decodeer folderPath
        self.folderPath = try container.decodeIfPresent(String.self, forKey: .folderPath)
    }

    // Standaard init voor NSManagedObject
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
}
