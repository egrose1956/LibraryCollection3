//
//  NewAuthorExtension.swift
//  LibraryCollection
//
//  Created by Elizabeth Rose on 1/12/23.
//
import Foundation
import CoreData
import SwiftUI

extension NewAuthorView {
    
    func FormatInput() {
        
        let myAuthor: FetchedResults<Author>.Element? = author
        guard myAuthor != nil else { return }
                
        authorFirstName = author!.authorFirstName ?? ""
        authorMiddleName = author!.authorMiddleName ?? ""
        authorLastName = author!.authorLastName
        authorIdString = author!.authorId.uuidString
    }

    func PerformValidationAndSave() {
        
        if authorFirstName.isEmpty && authorMiddleName.isEmpty && authorLastName.isEmpty {
            //go back if there isn't any author name entered
            lastNameWarning = true
            return
        }
            
        if authorLastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || authorLastName.count < 2 {
            lastNameWarning = true
            return
        }
   
        //check to see if we already have an author by this name
        guard !authorLastName.isEmpty else { return }
        
        if !authorFirstName.isEmpty {
            CheckForExistingAuthor(lastNameValue: authorLastName, firstNameValue: authorFirstName)
        } else {
            CheckForExistingAuthor(lastNameValue: authorLastName, firstNameValue: "")
        }
        
        //if this author doesn't exist, add them
        if authorIdString == "" {
            SaveAuthor()
        }
        
        //if a title is proferred - check to see if there is already an author
        //for this title
        if !inputTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            
            if !existingAuthorLastName.isEmpty {
                //Check for an author name in the text field below
                //and go get the titleId for this title by that author.
                CheckForExistingAuthorOfThisTitle(title: inputTitle, existingAuthorLastName: existingAuthorLastName, existingAuthorFirstName: existingAuthorFirstName)
                
                //add a titleauthor record with this author and existing titleId
                AddTitleAuthorOnly(title: existingTitleIdString, author: authorIdString)
                
            }
        }
    }
   
    func SaveAuthor() {
        
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
                GetAllTitlesByAuthor()
            }
        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "No fetch from AddAuthorAndTitleExtension:SaveAuthor. \(error), \(error.localizedDescription)")
        }
    }
    
    func AddTitleAuthorOnly(title: String, author: String) {
        
        guard !title.isEmpty else { return }
        guard !author.isEmpty else { return }
        
        do {
            let tA = TitleAuthor(context: moc)
            tA.titleAuthorId = UUID()
            tA.titleId = UUID(uuidString: title)!
            tA.authorId = UUID(uuidString: author)!
            
            try moc.save()
            moc.refreshAllObjects()
            GetAllTitlesByAuthor()
            
        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "No save at: from AddAuthorAndTitleExtension:AddTitleAuthorOnly. \(error), \(error.localizedDescription)")
        }
    }
    
    func CheckForExistingAuthorOfThisTitle(title: String, existingAuthorLastName: String, existingAuthorFirstName: String) {
        
        var authorID: UUID
        var titleID: UUID
        
        let _fetchRequest = NSFetchRequest<Author>(entityName: "Author")
        if !existingAuthorFirstName.isEmpty {
            _fetchRequest.predicate = NSPredicate(format: "authorLastName CONTAINS[c] %@ AND authorFirstName CONTAINS[c] %@", existingAuthorLastName, existingAuthorFirstName)
        } else {
            _fetchRequest.predicate = NSPredicate(format: "authorLastName CONTAINS[c] %@", existingAuthorLastName)
        }
        _fetchRequest.resultType = NSFetchRequestResultType.managedObjectResultType
        
        do {
            let _authors = try moc.fetch(_fetchRequest)
            if _authors.count > 0 {
                for i in 0..<_authors.count {
                    authorID = _authors[i].authorId
                    
                    let _fetchRequestTA = NSFetchRequest<TitleAuthor>(entityName: "TitleAuthor")
                    _fetchRequestTA.predicate = NSPredicate(format: "authorId = %@", authorID as CVarArg)
                    _fetchRequestTA.resultType = NSFetchRequestResultType.managedObjectResultType
                    
                    do {
                        let _TA = try moc.fetch(_fetchRequestTA)
                        if _TA.count > 0 {
                            for j in 0..<_TA.count {
                                titleID = _TA[j].titleId
                                
                                let _fetchRequestTitle = NSFetchRequest<Title>(entityName: "Title")
                                _fetchRequestTitle.predicate = NSPredicate(format: "titleId = %@", titleID as CVarArg)
                                _fetchRequestTitle.resultType = NSFetchRequestResultType.managedObjectResultType
                                
                                do {
                                    let _title = try moc.fetch(_fetchRequestTitle)
                                    if _title.count > 0 {
                                        for k in 0..<_title.count {
                                            if _title[k].title == title {
                                                existingTitleIdString = _title[k].titleId.uuidString
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "No match found: AddAuthorAndTitleExtension:CheckForExistingAuthorOfThisTitle. \(error), \(error.localizedDescription)")
        }
    }
        
    func CheckForExistingAuthor(lastNameValue: String, firstNameValue: String) {
        
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
                //author exists
                authorIdString = _authors[0].authorId.uuidString
            }
        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "No fetch from AddAuthorAndTitleExtension:CheckForExistingAuthor. \(error), \(error.localizedDescription)")
        }
    }
    
    
    
    func GetAllTitlesByAuthor() {
        
        filteredTitles = []
        moc.refreshAllObjects()
        var authorTitlesId: [UUID] = []
        
        let _fetchRequest = NSFetchRequest<TitleAuthor>(entityName: "TitleAuthor")
        _fetchRequest.predicate = NSPredicate(format: "authorId == %@", authorIdString)
        _fetchRequest.resultType = NSFetchRequestResultType.managedObjectResultType
        
        do {
            let _ta = try moc.fetch(_fetchRequest)
            //logger.log(level:.info, message: "There are \(_ta.count) titles for this author in TitleAuthor")
            for i in (0..<_ta.count) {
                authorTitlesId.append(_ta[i].titleId)
            }
        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "No fetch from AddAuthorAndTitleExtension:GetAllTitlesByAuthor. \(error), \(error.localizedDescription)")
        }
           
        for i in (0..<authorTitlesId.count) {
            
            let filter = authorTitlesId[i]
            
            let _fetchRequestTitle = NSFetchRequest<Title>(entityName: "Title")
            _fetchRequestTitle.predicate = NSPredicate(format: "titleId == %@", filter as CVarArg)
            _fetchRequestTitle.resultType = NSFetchRequestResultType.managedObjectResultType

            do {
                let _title = try moc.fetch(_fetchRequestTitle)
                for i in (0..<_title.count) {
                    //logger.log(level: .info, message: "Trying to append \(_title[i].title) and \(authorTitlesId[i].uuidString)")
                    filteredTitles.append(_title[i].title + "*" + authorTitlesId[i].uuidString)
                }
            } catch let error as NSError {
                let logger = appLogger()
                logger.log(level: .error, message: "No fetch from AddAuthorAndTitleExtension:GetAllTitlesByAuthor. \(error), \(error.localizedDescription)")
            }
        }
    }
}

