//
//  EditTitleDetailsExtension.swift
//  LibraryCollection
//
//  Created by Elizabeth Rose on 3/28/23.
//

import Foundation
import CoreData

extension EditTitleDetails {
    
    func GetCoAuthors() {
        
        guard !titleIdString.isEmpty else { return }
        
        var authorIds: [String] = []
        additionalAuthors.removeAll()
        
        let _fetchCoAuthors = NSFetchRequest<TitleAuthor>(entityName: "TitleAuthor")
        _fetchCoAuthors.predicate = NSPredicate(format: "titleId == %@", UUID(uuidString: titleIdString)! as CVarArg)
        _fetchCoAuthors.resultType = NSFetchRequestResultType.managedObjectResultType
        
        do {
            let _coAuthors = try moc.fetch(_fetchCoAuthors)
            if _coAuthors.count > 0 {
                for i in 0..<_coAuthors.count {
                    authorIds.append(_coAuthors[i].authorId.uuidString)
                }
            }
            
            if authorIds.count > 0 {
                for j in 0..<authorIds.count {
                    
                    let _fetchCoAuthorNames = NSFetchRequest<Author>(entityName: "Author")
                    _fetchCoAuthorNames.predicate = NSPredicate(format: "authorId == %@", UUID(uuidString: authorIds[j])! as CVarArg)
                    _fetchCoAuthorNames.resultType = NSFetchRequestResultType.managedObjectResultType
                    
                    let _names = try moc.fetch(_fetchCoAuthorNames)
                    let nameFormatter = NameFormatter()
                    for k in 0..<_names.count {
                        additionalAuthors.append(nameFormatter.ConcatenateNameFields(lastName: _names[k].authorLastName,
                                                                                     firstName: _names[k].wrappedAuthorFirstName,
                                                                                     middleName: _names[k].wrappedAuthorMiddleName))
                    }
                }
            }
        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "No fetch from AddTitleDetailsViewExtension:GetCoAuthors. \(error), \(error.localizedDescription)")
        }
    }
    
    func GetTitleDetailsById()  {

        guard !titleIdString.isEmpty else { return }
        
        titleDetails.removeAll()

        let _fetchRequestDetails = NSFetchRequest<TitleDetails>(entityName: "TitleDetails")
        _fetchRequestDetails.predicate = NSPredicate(format: "titleId == %@", titleIdString)
        _fetchRequestDetails.resultType = NSFetchRequestResultType.managedObjectResultType
        
        
        do {
            let _titleDetails = try moc.fetch(_fetchRequestDetails)
            
            titleDetails = _titleDetails
            
        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "No fetch from AddTitleDetailsViewExtension:GetTitleDetailsByID. \(error), \(error.localizedDescription)")
            
        }
    }
    
    func GetTitleById()  {

        title.removeAll()
        
        if titleIdString.isEmpty {
            titleIdString = UUID().uuidString
        }

        let _fetchRequestTitle = NSFetchRequest<Title>(entityName: "Title")
        _fetchRequestTitle.predicate = NSPredicate(format: "titleId == %@", titleIdString)
        _fetchRequestTitle.resultType = NSFetchRequestResultType.managedObjectResultType
        
        
        do {
            let _title = try moc.fetch(_fetchRequestTitle)
            
            titleIdString = _title[0].titleId.uuidString
            title = _title[0].title
            
            
        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "No fetch from AddTitleDetailsViewExtension:GetTitleByID. \(error), \(error.localizedDescription)")
            
        }
    }
    
    func SaveTitleChanges() {
  
        if titleIdString.isEmpty {
            let titleId = UUID()
            titleIdString = titleId.uuidString
        }
                
        do {
            
            //update the title in the title table
            let _fetchRequest = NSFetchRequest<Title>(entityName: "Title")
            _fetchRequest.predicate = NSPredicate(format: "titleId == %@", titleIdString)
            _fetchRequest.resultType = NSFetchRequestResultType.managedObjectResultType
            _fetchRequest.fetchLimit = 1
            
            let editTitle = try moc.fetch(_fetchRequest)
            if !editTitle.isEmpty {
                editTitle[0].titleId = UUID(uuidString: titleIdString)!
                editTitle[0].title = title.trimmingCharacters(in: .whitespacesAndNewlines)
            }
  
            try moc.save()
            moc.refreshAllObjects()
            
        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "No fetch from AddTitleDetailsViewExtension:SaveTitleChanges. \(error), \(error.localizedDescription)")
        }
    }
    
    func SaveTitleDetails() {
        
        guard !titleIdString.isEmpty && !titleDetailsId.isEmpty else { return }
        
        do {

            let _fetchRequest = NSFetchRequest<TitleDetails>(entityName: "TitleDetails")
            _fetchRequest.predicate = NSPredicate(format: "titleDetailsId == %@ && titleId == %@", titleDetailsId, titleIdString)
            _fetchRequest.resultType = NSFetchRequestResultType.managedObjectResultType
            _fetchRequest.fetchLimit = 1
            
            let saveDetails = try moc.fetch(_fetchRequest)
            
            if !saveDetails.isEmpty {
                
                saveDetails[0].bookType = selectedType
                
                if editionNumber.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                    saveDetails[0].editionNumber = (editionNumber.trimmingCharacters(in: .whitespacesAndNewlines))
                }
                
                if genre.trimmingCharacters(in:  .whitespacesAndNewlines) != "" {
                    saveDetails[0].genre = genre.trimmingCharacters(in:  .whitespacesAndNewlines)
                }
                
                if ISBN.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                    saveDetails[0].isbn = ISBN.trimmingCharacters(in: .whitespacesAndNewlines)
                }
                
                if publishingHouse.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                    saveDetails[0].publishingHouse = publishingHouse.trimmingCharacters(in: .whitespacesAndNewlines)
                }
                
                if publishingDate.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                    saveDetails[0].publishingDate = publishingDate.trimmingCharacters(in: .whitespacesAndNewlines)
                }

            }

            try moc.save()
            moc.refreshAllObjects()
                
        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "No fetch from AddTitleDetailsViewExtension:SaveTitleDetails. \(error), \(error.localizedDescription)")
        }
    }
}
