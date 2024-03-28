/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A class that sets up the Core Data stack.
*/
import Foundation
import CoreData

class PersistenceController {
    
    static let shared = PersistenceController()
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
                        
        let container = NSPersistentCloudKitContainer(name: "DataModel")
        
//#if DEBUG
//        // Only initialize the schema when building the app with the
//        // Debug build configuration.
//        do {
//            // Use the container to initialize the development schema.
//            try container.initializeCloudKitSchema(options: [])
//        } catch {
//            let logger = appLogger()
//            logger.log(level: .info, message: "initializeCloudKitSchema has failed.")
//        }
//
//#endif

//        // Create a store description for a local store
//        let localStoreLocation = URL(fileURLWithPath: "Bundle.main.applicationSupportDirectory")
//        let localStoreDescription =
//                NSPersistentStoreDescription(url: localStoreLocation)
//        localStoreDescription.configuration = "Default"
//
        // Create a store description for a CloudKit-backed local store
        let cloudStoreLocation = URL(fileURLWithPath: "iCloud/com/RiverThree/LibraryCollection")
        let cloudStoreDescription = NSPersistentStoreDescription(url: cloudStoreLocation)
        cloudStoreDescription.configuration = "Default"
        cloudStoreDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.RiverThree.LibraryCollection")

        // Update the container's list of store descriptions
//        container.persistentStoreDescriptions = [
//            localStoreDescription
//        ]
//        
//    #if DEBUG
//        print(container.persistentStoreDescriptions)
//    #endif
        
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        })
        
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.viewContext.undoManager = nil
        
        

        
        return container
        
    }()
    
    
    func save() {
        
        let context = persistentContainer.viewContext
        
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
