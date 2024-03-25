//
//  AuthorsViewExtension.swift
//  LibraryCollection3
//
//  Created by Elizabeth Rose on 3/18/24.
//

import Foundation
import CoreData

extension AuthorsView {
    
    //TODO: probably should be in a transaction--is sqlite sophisticated enough for this?
    //Not likely to be used for a user.  In place to clear data while testing.
    
    func deleteRelatedAuthorFiles(authorIdString: String) {
        
        //Gather authorId array and titleId arry first - do not clear until finished
        //the gathering of title data is done in deleteTitleAuthorandAuthorRecord()
        // 1.
        deleteTitleAuthorandAuthorRecord()
        
        // 2.
        deleteTitleNarratorRecord()
/*
        // 3.--this may delete a narrator for other titles-
        //leave commented out for now
        //deleteNarratorforTitle()
*/
        //4.
        deleteTitleDetails()
        
        //5.
        deleteTitleRecord()
        
    }
    
    
    func deleteTitleAuthorandAuthorRecord() {
        
        //This begins the process and needs to have a clear array
        titleIdArray.removeAll()
        
        //to cascade the author's deletion, the TitleAuthor table should have it's
        //corresponding records removed
        guard !authorIdString.isEmpty else { return }
        
        do {
            
            let authorId: UUID = UUID(uuidString: authorIdString)!
            
            let titleAuthorFetch = NSFetchRequest<TitleAuthor>(entityName: "TitleAuthor")
            titleAuthorFetch.predicate = NSPredicate(format: "authorId == %@", authorId as CVarArg)
            titleAuthorFetch.resultType = NSFetchRequestResultType.managedObjectResultType
            
            let titleAuthorDelete = try moc.fetch(titleAuthorFetch)
            
            if titleAuthorDelete.count > 0 {
                for i in 0..<titleAuthorDelete.count {
                    titleIdArray.append(titleAuthorDelete[i].titleId.uuidString)
                    moc.delete(titleAuthorDelete[i])
                }
            }
            
            let authorRecordFetch = NSFetchRequest<Author>(entityName: "Author")
            authorRecordFetch.predicate = NSPredicate(format: "authorId == %@", authorId as CVarArg)
            authorRecordFetch.resultType = NSFetchRequestResultType.managedObjectResultType
            authorRecordFetch.fetchLimit = 1
            
            let authorToDelete = try moc.fetch(authorRecordFetch)
            if !authorToDelete.isEmpty {
                moc.delete(authorToDelete[0])
            }
            try moc.save()
            
        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "TitleAuthorAndAuthorDelete error in AuthorsViewExtension. \(error), \(error.localizedDescription)")
        }
        
    }
    
    func deleteTitleRecord() {
        
        guard !titleIdArray.isEmpty else { return }
        
        do {
            
            for i in 0..<titleIdArray.count {
                // get the narratorIds on record for all the titleIds
                //loop through and add narratorIds to a narrator array
                // then use that for deleting narrator in deleteNarratorforTitle()
                
                let titleFetch = NSFetchRequest<Title>(entityName: "Title")
                titleFetch.predicate = NSPredicate(format: "titleId == %@", titleIdArray[i] as CVarArg)
                titleFetch.resultType = NSFetchRequestResultType.managedObjectResultType
                titleFetch.fetchLimit = 1
                
                let titleToDelete = try moc.fetch(titleFetch)
                
                if !titleToDelete.isEmpty {
                    moc.delete(titleToDelete[0])
                }
            }
            
            try moc.save()
            
        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "TitleNarrator Delete error in AuthorsViewExtension. \(error), \(error.localizedDescription)")
        }
        
    }
    
    func deleteTitleNarratorRecord() {
        
        guard !titleIdArray.isEmpty else { return }
        
        //narratorIdArray.removeAll()
        
        do {
            
            for i in 0..<titleIdArray.count {
                // get the narratorIds on record for all the titleIds
                //loop through and add narratorIds to a narrator array
                // then use that for deleting narrator in deleteNarratorforTitle()
                
                let recordFetch = NSFetchRequest<TitleNarrator>(entityName: "TitleNarrator")
                recordFetch.predicate = NSPredicate(format: "titleId == %@", titleIdArray[i] as CVarArg)
                recordFetch.resultType = NSFetchRequestResultType.managedObjectResultType
                recordFetch.fetchLimit = 1
                
                let titleToDelete = try moc.fetch(recordFetch)
                
                if !titleToDelete.isEmpty {
                    //may not need this functionality
                    //narratorIdArray.append(titleToDelete[i].narratorId.uuidString)
                    moc.delete(titleToDelete[0])
                }
            }
            
            try moc.save()
            
        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "TitleNarrator Delete error in AuthorsViewExtension. \(error), \(error.localizedDescription)")
        }
    }
    
/*  //may not need this functionality aas it might delete a narrator for other titles
    func deleteNarratorforTitle() {
        
        guard !narratorIdArray.isEmpty else { return }
        
        do {
            
            for i in 0..<narratorIdArray.count {
                // get the narratorIds on record for all the titleIds
                //loop through and add narratorIds to a narrator array
                // then use that for deleting narrator in deleteNarratorforTitle()
                
                let narratorRecordFetch = NSFetchRequest<Narrator>(entityName: "Narrator")
                narratorRecordFetch.predicate = NSPredicate(format: "titleId == %@", titleIdArray[i] as CVarArg)
                narratorRecordFetch.resultType = NSFetchRequestResultType.managedObjectResultType
                narratorRecordFetch.fetchLimit = 1
                
                let narratorToDelete = try moc.fetch(narratorRecordFetch)
                if !narratorToDelete.isEmpty {
                    moc.delete(narratorToDelete[0])
                }
            }
            
            try moc.save()
            
            
        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "Narrator Delete error in AuthorsViewExtension. \(error), \(error.localizedDescription)")
        }
    }
 */
    
    func deleteTitleDetails() {
        
        guard !titleIdArray.isEmpty else { return }
        
        do {
            
            for i in 0..<titleIdArray.count {
                
                let titleDetailsFetch = NSFetchRequest<TitleDetails>(entityName: "TitleDetails")
                titleDetailsFetch.predicate = NSPredicate(format: "titleId == %@", titleIdArray[i] as CVarArg)
                titleDetailsFetch.resultType = NSFetchRequestResultType.managedObjectResultType
                
                let detailToDelete = try moc.fetch(titleDetailsFetch)
                if !detailToDelete.isEmpty {
                    moc.delete(detailToDelete[0])
                }
            }
            
            try moc.save()
            
        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "TitleAuthorAndAuthorDelete error in AuthorsViewExtension. \(error), \(error.localizedDescription)")
        }
        
    }
}
