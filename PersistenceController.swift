import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "CarFocusModel") // Zorg dat deze naam overeenkomt met je .xcdatamodeld
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Voeg hier je error handling toe
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }

    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
}
