//
//  EditAuthorExtension.swift
//  LibraryCollection
//
//  Created by Elizabeth Rose on 3/27/23.
//

import Foundation
import CoreData

extension EditAuthorView {
    
    func CheckForExistingAuthor(lastNameValue: String, firstNameValue: String) -> String {
        
        let _fetchRequest = NSFetchRequest<Author>(entityName: "Author")
        
        if !firstNameValue.isEmpty {
            _fetchRequest.predicate = NSPredicate(format: "authorLastName CONTAINS[c] %@ AND authorFirstName CONTAINS[c] %@", lastNameValue, firstNameValue)
        } else {
            _fetchRequest.predicate = NSPredicate(format: "authorLastName CONTAINS[c] %@", lastNameValue)
        }
        _fetchRequest.resultType = NSFetchRequestResultType.managedObjectResultType
        _fetchRequest.fetchLimit = 1
        
        do {
            let _authors = try moc.fetch(_fetchRequest)
            if _authors.count > 0 {
                
                return "\(_authors[0].authorLastName + ", " + _authors[0].wrappedAuthorFirstName)"
            }
        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "No fetch from AddAuthorAndTitleExtension:CheckForExistingAuthor. \(error), \(error.localizedDescription)")
            return ""
        }
        return "Author Found"
    }
    
    func SaveAuthorEdit() -> String {
        
        guard !authorIdString.isEmpty else { return "No ID to process"}
        var returnString: String = ""
        
        do {
            
            let authorId = UUID(uuidString: authorIdString)!
            
            let authorFetch = NSFetchRequest<Author>(entityName: "Author")
            authorFetch.predicate = NSPredicate(format: "authorId == %@", authorId as CVarArg)
            authorFetch.resultType = NSFetchRequestResultType.managedObjectResultType
            authorFetch.fetchLimit = 1
            
            let editAuthor = try moc.fetch(authorFetch)
            if !editAuthor.isEmpty {

                returnString = CheckForExistingAuthor(lastNameValue: editAuthor[0].authorLastName, firstNameValue: editAuthor[0].wrappedAuthorFirstName)
                
                if returnString.count > 0 {
                    
                    editAuthor[0].authorLastName = authorLastName.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if !authorFirstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        editAuthor[0].authorFirstName = authorFirstName
                    }
                    
                    if !authorMiddleName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        editAuthor[0].authorMiddleName = authorMiddleName
                    }
                    try moc.save()
                    moc.refreshAllObjects()
                }
            }

        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "No fetch from EditAuthorExtension:SaveAuthorEdit. \(error), \(error.localizedDescription)")
            return "Edit Process Failed"
        }
        return "Edit Complete"
    }
}
