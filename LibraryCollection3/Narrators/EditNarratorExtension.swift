//
//  EditNarratorExtension.swift
//  LibraryCollection
//
//  Created by Elizabeth Rose on 3/30/23.
//

import Foundation
import CoreData

extension EditNarrator {
    
    func CheckForExistingNarrator(narratorLastNameValue: String, narratorFirstNameValue: String) -> String {
        
        guard !narratorLastNameValue.isEmpty else { return "No Last Name"}
        
        let _fetchNarrator = NSFetchRequest<Narrator>(entityName: "Narrator")
        if !narratorFirstNameValue.isEmpty {
            _fetchNarrator.predicate =
            NSPredicate(format: "narratorLastName == %@ AND narratorFirstName == %@",
                        narratorLastNameValue, narratorFirstNameValue)
        } else {
            _fetchNarrator.predicate =
            NSPredicate(format: "narratorLastName CONTAINS[c] %@", narratorLastNameValue)
        }
        _fetchNarrator.resultType = NSFetchRequestResultType.managedObjectResultType
        _fetchNarrator.fetchLimit = 1
        
        do {
            let _narrator = try moc.fetch(_fetchNarrator)
            if _narrator.count > 0 {
                
                foundNarratorLastName = "\(_narrator[0].narratorLastName)"
                foundNarratorFirstName = _narrator[0].wrappedNarratorFirstName
           
                return "\(foundNarratorLastName + ", " + foundNarratorFirstName)"
            }
        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "No fetch from AddNarratorExtension:CheckForExistingNarrator. \(error), \(error.localizedDescription)")
            return ""
        }
        return ""
    }
    
    func SaveNarratorEdit() -> String {
        
        guard !narratorIdString.isEmpty else { return "No ID to process"}
        var returnString: String = ""
        
        do {
            
            let narratorId = UUID(uuidString: narratorIdString)!
            
            let narratorFetch = NSFetchRequest<Narrator>(entityName: "Narrator")
            narratorFetch.predicate = NSPredicate(format: "narratorId == %@", narratorId as CVarArg)
            narratorFetch.resultType = NSFetchRequestResultType.managedObjectResultType
            narratorFetch.fetchLimit = 1
            
            let editNarrator = try moc.fetch(narratorFetch)
            if !editNarrator.isEmpty {
                
                returnString = CheckForExistingNarrator(narratorLastNameValue: narratorLastName, narratorFirstNameValue: narratorFirstName)
                
                if returnString.count > 0 {
                    editResultsInDuplicateRecord = true
                    return "Duplicate Record Found"
                } else {
                    
                    editNarrator[0].narratorLastName = narratorLastName.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if !narratorFirstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        editNarrator[0].narratorFirstName = narratorFirstName
                    }
                    if !narratorMiddleName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        editNarrator[0].narratorMiddleName = narratorMiddleName
                    }
                    try moc.save()
                    moc.refreshAllObjects()
                }
            }

        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "Save failed from EditNarratorExtension:SaveNarratorEdit. \(error), \(error.localizedDescription)")
            return "Edit Process Failed"
        }
        return "Edit Process Complete"
    }
}
