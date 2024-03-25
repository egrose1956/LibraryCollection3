/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A class that sets up the Core Data stack.
*/

import CoreData
import SwiftData

struct PersistenceController {
    
    static let shared = PersistenceController()
    
    //Example file had static preview configuration here.

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
//        guard let modelURL = Bundle.main.url(forResource: "LibraryCollection3", withExtension: "/DataModel.sqlite") else {
//            fatalError("Unable to find data model in the bundle.")
//        }
        
//        guard let coreDataModel = NSManagedObjectModel(contentsOf: modelURL) else {
//            fatalError("Unable to create Core Data model.")
//        }
        
        //init needs this to identify the data model we configured(the .xcdatamodel
        container = NSPersistentContainer(name: "DataModel")
        
        //directory path to our application in url format
        //let urlPath = Bundle.main.resourceURL
        let urlPath = (URL.applicationSupportDirectory.path(percentEncoded: false) + ("DataModel.sqlite"))
        
        //        let description = container.persistentStoreDescriptions.first
        //        description?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null/")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
#if DEBUG
    print(urlPath)
#endif

        self.container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        self.container.viewContext.undoManager = nil
    }
    
    func save() {
        
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
                context.refreshAllObjects()
            } catch {
                print("Error on saving the moc context in PersistenceController")
            }
        }
    }
}
