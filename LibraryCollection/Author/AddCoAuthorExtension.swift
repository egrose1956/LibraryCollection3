//
//  AddCoAuthorExtension.swift
//  LibraryCollection
//
//  Created by Elizabeth Rose on 4/16/23.
//

import Foundation
import CoreData

extension AddCoAuthorView {
        
    func PerformValidationAndSave() {
        
        if authorFirstName.isEmpty && authorMiddleName.isEmpty && authorLastName.isEmpty {
            //go back if there isn't any author name entered
            lastNameAlert = true
            return
        }
        
        if authorLastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || authorLastName.count < 2 {
            lastNameAlert = true
            return
        }
//        var duplicateTitle = CheckForExistingTitle()
//        if duplicateTitle {
//            duplicateTitle = true
//            return
//        }
        
        //check to see if we already have an author by this name
        var duplicate = CheckForExistingAuthor(authorLastName: authorLastName, authorFirstName: authorFirstName, authorMiddleName: authorMiddleName)
        
        if !duplicate {
            SaveCoAuthor()
        }
        
        duplicate = false
        duplicate = CheckForExistingCoAuthorOfThisTitle(authorIdString: authorIdString)
            
        if !duplicate {
            AddTitleAuthorOnly(titleIdString: titleIdString, authorIdString: authorIdString)
        }
        
        coAuthorisShowingConfirmation = true
    }
    
    func CheckForExistingTitle() -> Bool {
        do {

            let _fetchRequestDupTitle = NSFetchRequest<Title>(entityName: "Title")
            _fetchRequestDupTitle.predicate = NSPredicate(format: "title = %@", titleName as CVarArg)
            _fetchRequestDupTitle.resultType = NSFetchRequestResultType.managedObjectResultType
            _fetchRequestDupTitle.fetchLimit = 1
            
            let _TC = try moc.fetch(_fetchRequestDupTitle)
            if _TC.count > 0 {
                
                return true
            }
            
        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "No match found: AddCoAuthorExtension:CheckForExistingTitle. \(error), \(error.localizedDescription)")
        }
        return false
    }
    
    func CheckForExistingCoAuthorOfThisTitle(authorIdString: String) -> Bool {
        
        guard !authorIdString.isEmpty else {
            return true
        }
        let authorID = UUID(uuidString: authorIdString)!
        
        guard !titleIdString.isEmpty else {
            return false
        }
        let titleID = UUID(uuidString: titleIdString)!
        
        do {

            let _fetchRequestTA = NSFetchRequest<TitleAuthor>(entityName: "TitleAuthor")
            _fetchRequestTA.predicate = NSPredicate(format: "authorId = %@ AND titleId = %@", authorID as CVarArg, titleID as CVarArg)
            _fetchRequestTA.resultType = NSFetchRequestResultType.managedObjectResultType
            _fetchRequestTA.fetchLimit = 1
            
            let _TA = try moc.fetch(_fetchRequestTA)
            if _TA.count > 0 {
                
                return true
            }
            
        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "No match found: AddCoAuthorExtension:CheckForExistingCoAuthorOfThisTitle. \(error), \(error.localizedDescription)")
        }
        return false
    }
    
    func CheckForExistingAuthor(authorLastName: String, authorFirstName: String, authorMiddleName: String) -> Bool {
        
        let _fetchRequest = NSFetchRequest<Author>(entityName: "Author")
        
        if !authorFirstName.isEmpty && !authorMiddleName.isEmpty {
            _fetchRequest.predicate = NSPredicate(format: "authorLastName BEGINSWITH[c] %@ AND authorFirstName BEGINSWITH[c] %@ AND authorMiddleName BEGINSWITH[c] %@", authorLastName, authorFirstName, authorMiddleName)
        } else if !authorFirstName.isEmpty {
            _fetchRequest.predicate = NSPredicate(format: "authorLastName BEGINSWITH[c] %@ AND authorFirstName BEGINSWITH[c] %@", authorLastName, authorFirstName)
        } else {
            _fetchRequest.predicate = NSPredicate(format: "authorLastName BEGINSWITH[c] %@", authorLastName)
        }

        _fetchRequest.resultType = NSFetchRequestResultType.managedObjectResultType
        _fetchRequest.fetchLimit = 1
        
        do {
            let _authors = try moc.fetch(_fetchRequest)
            if _authors.count > 0 {
                authorIdString = _authors[0].authorId.uuidString
                return true
            }
        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "No match found: AddCoAuthorExtension:CheckForExistingAuthor. \(error), \(error.localizedDescription)")
        }
        return false
    }
    
    func SaveCoAuthor() {
        
        do {
            let authors = Author(context: moc)
            
            authors.authorId = UUID()
            
            authors.authorLastName = authorLastName
            
            if authorFirstName.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                authors.authorFirstName = authorFirstName
            }
            if authorMiddleName.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                authors.authorMiddleName = authorMiddleName
            }
            
            authorIdString = authors.authorId.uuidString
            if authorIdString.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                try moc.save()
                moc.refreshAllObjects()
            }
        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "Save error at AddCoAuthor:SaveAuthor. \(error), \(error.localizedDescription)")
        }
    }
    
    func GetAllAuthorsByTitleId() {
        
        guard !titleIdString.isEmpty else { return }
        
        resultString = []

        let _fetchTAuthor = NSFetchRequest<TitleAuthor>(entityName: "TitleAuthor")
        _fetchTAuthor.predicate = NSPredicate(format: "titleId == %@", titleIdString)
        _fetchTAuthor.resultType = NSFetchRequestResultType.managedObjectResultType
        
        do {
            let _TA = try moc.fetch(_fetchTAuthor)
            if _TA.count > 0 {
                for i in 0..<_TA.count {
                    
                    let _author = NSFetchRequest<Author>(entityName: "Author")
                    _author.predicate = NSPredicate(format: "authorId == %@", _TA[i].authorId as CVarArg)
                    _author.resultType = NSFetchRequestResultType.managedObjectResultType
                    
                    do {
                        let _authorName = try moc.fetch(_author)
                        if _authorName.count > 0 {
                            var workingString = ""
                            for i in 0..<_authorName.count {
                                workingString.append("\(_authorName[i].authorLastName)")
                                if !_authorName[i].wrappedAuthorFirstName.isEmpty {
                                    workingString.append(", \(_authorName[i].wrappedAuthorFirstName)")
                                }
                                resultString.append(workingString)
                                workingString.removeAll()
                            }
                        }
                    }
                }
            }

        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "No fetch from AddCoAuthorExtension:GetAllAuthorssByTitleId. \(error), \(error.localizedDescription)")
        }
    }
    
    func AddTitleAuthorOnly(titleIdString: String, authorIdString: String) {
        
        guard !titleIdString.isEmpty else { return }
        guard !authorIdString.isEmpty else { return }
        
        do {
            let tA = TitleAuthor(context: moc)
            tA.titleAuthorId = UUID()
            tA.titleId = UUID(uuidString: titleIdString)!
            tA.authorId = UUID(uuidString: authorIdString)!
            
            try moc.save()
            moc.refreshAllObjects()
            
        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "No save at: from AddCoAuthorExtension:AddTitleAuthorOnly. \(error), \(error.localizedDescription)")
        }
    }
    
}
