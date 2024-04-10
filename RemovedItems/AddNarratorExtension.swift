//
//  NarratorExtension.swift
//  LibraryCollection
//
//  Created by Elizabeth Rose on 2/7/23.
//
import Foundation
import CoreData
import os

extension NarratorView {
    
    func CheckForExistingNarrator(narratorLastNameValue: String, narratorFirstNameValue: String) -> String {
        
        guard !narratorLastNameValue.isEmpty else { return "LastName is missing."}
        
        let _fetchNarrator = NSFetchRequest<Narrator>(entityName: "Narrator")
        if !narratorFirstNameValue.isEmpty {
            _fetchNarrator.predicate =
            NSPredicate(format: "narratorLastName CONTAINS[c] %@ AND narratorFirstName CONTAINS[c] %@",
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
                
                if addOrEdit == "add" {
                    
                    narratorIdString = _narrator[0].narratorId.uuidString
                }
                if addOrEdit == "editing" {
                    
                    foundNarratorLastName = "\(_narrator[0].narratorLastName)"
                    foundNarratorFirstName = _narrator[0].wrappedNarratorFirstName
                    
                    return "\(foundNarratorLastName + ", " + foundNarratorFirstName)"
                }
            }
        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "No fetch from AddNarratorExtension:CheckForExistingNarrator. \(error), \(error.localizedDescription)")
            return ""
        }
        return ""
    }
    
    func CheckForExistingTitleNarratorRecord(narratorIdString: String, titleIdString: String) -> String {
        
        guard !narratorIdString.isEmpty else { return "No narrator data." }
        guard !titleIdString.isEmpty else { return "No title data."}
        
        let _fetchRecord = NSFetchRequest<TitleNarrator>(entityName: "TitleNarrator")
        var resultString: String = ""
        
        _fetchRecord.predicate =
            NSPredicate(format: "narratorId == %@ AND titleId == %@",
                        narratorIdString, titleIdString)

        _fetchRecord.resultType = NSFetchRequestResultType.managedObjectResultType
        _fetchRecord.fetchLimit = 1
        
        do {
            let _narrator = try moc.fetch(_fetchRecord)
            if _narrator.count > 0 {
                
                resultString = _narrator[0].narratorId.uuidString
            }
        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "Error in fetch from CheckForExistingTitleNarratorRecord. \(error), \(error.localizedDescription)")
            return "Error"
        }
        return resultString
    }
    
    func ValidateNarratorAndSave() {

        CheckForExistingNarrator(narratorLastNameValue: newNarratorLastName, narratorFirstNameValue: newNarratorFirstName)
        
        if narratorIdString.isEmpty {
            //no narrator by this name and no passed in title
            //so just save the narrator - probably coming from
            //the main screen menu
            SaveNarrator()
        }
            
        if !titleIdString.isEmpty {
            
            if !narratorIdString.isEmpty && !titleIdString.isEmpty  {
                
                //check for existing title/narrator record so as not to duplicate.
                let results = CheckForExistingTitleNarratorRecord(narratorIdString: narratorIdString, titleIdString: titleIdString)
                
                if results.isEmpty {
                    //we do have a narrator - either already or just added
                    //we do have a title and titleIDString so
                    //save narrator and title - probably coming from adding of
                    //title details
                    AddTitleNarratorRecord(titleIdString: titleIdString)
                }
                
            }
        }
        narratorFirstName = newNarratorFirstName
        narratorMiddleName = newNarratorMiddleName
        narratorLastName = newNarratorLastName
        
        newNarratorFirstName = ""
        newNarratorMiddleName = ""
        newNarratorLastName = ""
    }
        
    func GetNarratorsForTitle(narratorIdString: String, titleIdString: String) {
        
        narratorListForTitle.removeAll()
        
        let _fetchTNarrator = NSFetchRequest<TitleNarrator>(entityName: "TitleNarrator")
        _fetchTNarrator.predicate = NSPredicate(format: "titleId == %@", titleIdString)
        _fetchTNarrator.resultType = NSFetchRequestResultType.managedObjectResultType
        
        do {
            let _Tnarrators = try moc.fetch(_fetchTNarrator)
            if _Tnarrators.count > 0 {
                for i in 0..<_Tnarrators.count {
                    
                    //get the narratorId(s) - the go to the narrator table for the naems
                    let idString = _Tnarrators[i].narratorId.uuidString
                    
                    let _fetchNarrator = NSFetchRequest<Narrator>(entityName: "Narrator")
                    _fetchNarrator.predicate = NSPredicate(format: "narratorId == %@", idString)
                    _fetchNarrator.resultType = NSFetchRequestResultType.managedObjectResultType
                    
                    let _narrators = try moc.fetch(_fetchNarrator)
                    if _narrators.count > 0 {
                        
                        let nameFormatter = NameFormatter()
                        for i in 0..<_narrators.count {
                            narratorListForTitle.append(nameFormatter.ConcatenateNameFields(lastName: _narrators[i].narratorLastName,
                                                                                       firstName: _narrators[i].wrappedNarratorFirstName,
                                                                                       middleName: _narrators[i].wrappedNarratorMiddleName))
                        }
                    }
                }
            }
        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "No fetch from AddNarratorExtension:GetNarratorsForTitle. \(error), \(error.localizedDescription)")
        }
    }
    
    func SaveNarrator() -> String {
        
        if addOrEdit == "editing" {
            guard !narratorIdString.isEmpty else { return "No ID to process"}
            
            do {
                
                let narrator = Narrator(context: moc)
                
                narrator.narratorId = UUID()
                
                narrator.narratorLastName = newNarratorLastName
                
                if newNarratorFirstName.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                    narrator.narratorFirstName = newNarratorFirstName
                }
                if newNarratorMiddleName.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                    narrator.narratorMiddleName = newNarratorMiddleName
                }
                
                narratorIdString = narrator.narratorId.uuidString
                
                try moc.save()
                moc.refreshAllObjects()
                
                return ""
                
            } catch let error as NSError {
                let logger = appLogger()
                logger.log(level: .error, message: "Save Error from NarratorExtension:SaveNarrator. \(error), \(error.localizedDescription)")
            }
        } else {
            do {
                
                let narratorId = UUID(uuidString: narratorIdString)!
                var returnString: String = ""
                
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

    func AddTitleNarratorRecord(titleIdString: String) {
        
        guard !titleIdString.isEmpty else { return }
        guard !narratorIdString.isEmpty else {return }
        
        let titleNarrator = TitleNarrator(context: moc)
        
        let titleID: UUID = UUID(uuidString: titleIdString)!
        let narratorID: UUID = UUID(uuidString: narratorIdString)!
        
        titleNarrator.titleNarratorId = UUID()
        titleNarrator.titleId = titleID
        titleNarrator.narratorId = narratorID
            
        do {
            try moc.save()
            moc.refreshAllObjects()
        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "No fetch from AddNarratorExtension:AddTitleNarratorRecord. \(error), \(error.localizedDescription)")
        }
    }

}
