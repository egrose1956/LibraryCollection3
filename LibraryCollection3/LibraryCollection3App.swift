//
//  LibraryCollection3App.swift
//  LibraryCollection3
//
//  Created by Elizabeth Rose on 1/19/24.
//

import SwiftUI
//import SwiftData

@main
struct LibraryCollection3App: App {
    
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView(filter: .authors)
                .environment(\.managedObjectContext,
                              persistenceController.container.viewContext)
        
        }
        
        //SwiftData - if reverting back, add (or uncomment) an import for SwiftData
        
        //    let container: ModelContainer
        //
        //    var body: some Scene {
        //
        //        WindowGroup {
        //            ContentView()
        //        }
        //        .modelContainer(container)
        //    }
        //
        //    init() {
        //
        //        let schema = Schema([Author.self])
        //        let config = ModelConfiguration("LibraryCollection", schema: schema)
        //        do {
        //            container = try ModelContainer(for: schema, configurations: config)
        //            //container.mainContext.autosaveEnabled = false
        //        } catch {
        //            fatalError("Could not configure the container.")
        //        }
        //
        //#if DEBUG
        //        //--------------------------------------------------------------------------
        //            //WARNING: This deletes all data and database configuration.
        //            //This can not be reversed.  If the data store has not been backed up
        //            //then everything will be lost.
        //        //TODO: Delete this before production
        //        //container.deleteAllData()
        //        //---------------------------------------------------------------------------
        //
        //        print(URL.applicationSupportDirectory.path(percentEncoded: false) + ("LibraryCollection.store"))
        //#endif
        
    }
}
