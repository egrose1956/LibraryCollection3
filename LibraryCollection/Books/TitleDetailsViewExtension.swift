//
//  TitleDetailsViewExtension.swift
//  LibraryCollection
//
//  Created by Elizabeth Rose on 4/9/24.
//

import CoreData
import Foundation

extension TitleDetailsView {
    
    func SaveTitleDetails() {
        
        let resultString = CheckForExistingTitleDetailsRecord()
        
        if resultString.contains("Error") {
            //error exists that needs to be handled by the data manager.
            return
        } else {
            //the resultString should be the titleDetaisId, either
            //retrieved or created in the function called above
            
            
            //sets up an object to hold the values to assign to the moc
            let saveDetails = TitleDetails(context: moc)
            
            guard !authorIdString.isEmpty else { return }
            
            //prep code for the add/edit functionality
            
            if !newRecord {
                
                //if this is an edit, why doesn't it have an id?
                guard !titleIdString.isEmpty else { return }
                
            } //end of prep code/
            
            //this is to add new Title, TitleAuthor and TitleDetails records
            //or to update anything changed on the titleDetails screen
            let returnValue = SaveTitle()
            if !returnValue { return }
            
            //THIS CODE IS COMMON TO BOTH ADD AND EDIT
            
            saveDetails.titleDetailsId = UUID(uuidString: titleDetailsId)!
            
            saveDetails.titleId = UUID(uuidString: titleIdString)!
            
            saveDetails.bookType = selectedType
            
            if !editionNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                saveDetails.editionNumber = (editionNumber.trimmingCharacters(in: .whitespacesAndNewlines))
            }
            
            if !genre.trimmingCharacters(in:  .whitespacesAndNewlines).isEmpty {
                saveDetails.genre = genre.trimmingCharacters(in:  .whitespacesAndNewlines)
            }
            
            if !ISBN.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                saveDetails.isbn = ISBN.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            if !publishingHouse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                saveDetails.publishingHouse = publishingHouse.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            if !publishingDate.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                saveDetails.publishingDate = publishingDate.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            if moc.hasChanges {
                do {
                    try moc.save()
                    moc.refreshAllObjects()
                    
                } catch let error as NSError {
                    let logger = appLogger()
                    logger.log(level: .error, message: "Save Error in TitleDetailsViewExtension:SaveTitleDetails. \(error), \(error.localizedDescription)")
                }
            }
        }
    }
    
    func GetTitleIdByTitleAndAuthorName() {
        
        guard !authorIdString.isEmpty else { return }
        guard !title.isEmpty else { return }
        
        //clear previously used variables
        titleIdString = ""
        
        //declare new working variables
        var titleIdArray: [String] = []
        var titleIdTwoArray: [String] = []
        let authorId = UUID(uuidString: authorIdString)
        
        let _fetchRequestTA = NSFetchRequest<TitleAuthor>(entityName: "TitleAuthor")
        _fetchRequestTA.predicate = NSPredicate(format: "authorId == %@", authorId! as CVarArg)
        _fetchRequestTA.resultType = NSFetchRequestResultType.managedObjectResultType
        
        do {
            //get all the titleIds for the titlesRunn
            //matching the passed in authorId in the TitleAuthor table
            let _TA = try moc.fetch(_fetchRequestTA)
            if _TA.count > 0  {
                for i in 0..<_TA.count {
                    titleIdArray.append(_TA[i].titleId.uuidString)
                }
            }
            
            let _fetchTitles = NSFetchRequest<Title>(entityName: "Title")
            _fetchTitles.predicate = NSPredicate(format: "title CONTAINS[c] %@", title)
            _fetchTitles.resultType = NSFetchRequestResultType.managedObjectResultType
            
            //get all the titleIds for the title selected by the user
            let _titles = try moc.fetch(_fetchTitles)
            if _titles.count > 0 {
                for i in 0..<_titles.count {
                    titleIdTwoArray.append(_titles[i].titleId.uuidString)
                }
            }
            
            //now loop through the first set of titleId results and
            //compare the ids to a loop-through of the second set of results.
            //the match returned will be titleId for the details requested.
            for i in 0..<titleIdArray.count {
                for j in 0..<titleIdTwoArray.count {
                    if titleIdArray[i] == titleIdTwoArray[j] {
                        titleIdString = titleIdArray[i]
                    }
                }
            }
        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "No fetch from TitleDetailsViewExtension:GetTitleByTitleAndAuthorName. \(error), \(error.localizedDescription)")
        }
    }
    
    func CheckForExistingTitleDetailsRecord() -> String {
        
        var resultString: String = ""
        
        let _fetchRequest = NSFetchRequest<TitleDetails>(entityName: "TitleDetails")
        _fetchRequest.predicate = NSPredicate(format: "titleId == %@", titleIdString as CVarArg)
        _fetchRequest.resultType = NSFetchRequestResultType.managedObjectResultType
        
        do {
            let _ID = try moc.fetch(_fetchRequest)
            
            if _ID.count > 1 {
                resultString =  "Error in existing data-too many records."
            } else if _ID.count > 0 {
                resultString = _ID[0].titleDetailsId.uuidString
            } else if _ID.count < 1 {
                let newTitleDetailsId = UUID()
                resultString = newTitleDetailsId.uuidString
            }
            
            titleDetailsId = resultString
            
            return resultString
            
        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "Error No fetch from TitleDetailsViewExtension:CheckForExistingTitleDetailsRecord. \(error), \(error.localizedDescription)")
            return error.localizedDescription
        }
    }   
        
    func CheckForExistingTitle(titleNameFilter: String, authorIdString: String) -> Bool {
        
        guard !authorIdString.isEmpty else { return false}
        guard !titleNameFilter.isEmpty else { return false}
        
        let authorId = UUID(uuidString: authorIdString)
        
        let _fetchRequest = NSFetchRequest<Title>(entityName: "Title")
        _fetchRequest.predicate = NSPredicate(format: "title CONTAINS[c] %@", titleNameFilter)
        _fetchRequest.resultType = NSFetchRequestResultType.managedObjectResultType
        
        do {
            let _title = try moc.fetch(_fetchRequest)
            if _title.count > 0 {
                
                for _ in 0..<_title.count {
                    
                    let _TA = NSFetchRequest<TitleAuthor>(entityName: "TitleAuthor")
                    _TA.predicate = NSPredicate(format: "authorId == %@", authorId! as CVarArg)
                    _TA.resultType = NSFetchRequestResultType.managedObjectResultType
                    
                    do {
                        let _titles = try moc.fetch(_TA)
                        if _titles.count > 0  {
                            //already have for this author
                            titleIdString = _titles[0].titleId.uuidString
                            return true
                        }
                    }
                }
            } else {
                titleIdString = ""
                return false
            }
        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "No fetch from AuthorAndTitleExtension:CheckForExistingTitle. \(error), \(error.localizedDescription)")
            return false
        }
        return true
    }
    
    func SaveTitle() -> Bool {
        
        guard !authorIdString.isEmpty else { return false }
        guard !title.isEmpty else { return false }
        
        var returnValue: Bool = true //happy path
        if titleIdString.isEmpty {
            returnValue = CheckForExistingTitle(titleNameFilter: title, authorIdString: authorIdString)
        }
            
        //add a new title and titleAuthor record
        if returnValue == false {
            do {
                //get the object contexts
                let titleRecord = Title(context: moc)
                
                //assign values to the objecs for the title table
                titleRecord.titleId = UUID()
                titleRecord.title = title
                
                titleIdString = titleRecord.titleId.uuidString
                
                let titleAuthor = TitleAuthor(context: moc)
                
                //assign values to the objects for the titleauthor table
                titleAuthor.titleAuthorId = UUID()
                titleAuthor.authorId = UUID(uuidString: authorIdString)!
                titleAuthor.titleId = titleRecord.titleId
                
                //save the title
                try moc.save()
                moc.refreshAllObjects()
                
                //may need this later
                //GetAllTitlesByAuthor()
                
            } catch {
                let logger = appLogger()
                logger.log(level: .error, message: "No save at: AddAuthorAndTitleExtension:SaveTitle. \(error), \(error.localizedDescription)")
                return false
            }
            return true
        } else {
            
            //so update the title in the title table
            let _fetchRequest = NSFetchRequest<Title>(entityName: "Title")
            _fetchRequest.predicate = NSPredicate(format: "titleId == %@", titleIdString)
            _fetchRequest.resultType = NSFetchRequestResultType.managedObjectResultType
            _fetchRequest.fetchLimit = 1
            
            do {
                
                let editTitle = try moc.fetch(_fetchRequest)
                if !editTitle.isEmpty {
                    editTitle[0].titleId = UUID(uuidString: titleIdString)!
                    editTitle[0].title = title.trimmingCharacters(in: .whitespacesAndNewlines)
                }
                
                try moc.save()
                moc.refreshAllObjects()
                
            } catch let error as NSError {
                let logger = appLogger()
                logger.log(level: .error, message: "No fetch from TitleDetailsViewExtension:SaveTitleChanges. \(error), \(error.localizedDescription)")
                return false
            }
            return true
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
            
            if _titleDetails.count > 0 {
                titleDetails = _titleDetails
            }
            
        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "No fetch from TitleDetailsViewExtension:GetTitleDetailsByID. \(error), \(error.localizedDescription)")
            
        }
    }
    
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
            logger.log(level: .error, message: "No fetch from TitleDetailsViewExtension:GetCoAuthors. \(error), \(error.localizedDescription)")
        }
    }
    
    func GetAuthorId(filter: String) -> String {
        
        var idString: String = ""
        
        let _fetchId = NSFetchRequest<TitleAuthor>(entityName: "TitleAuthor")
        _fetchId.predicate = NSPredicate(format: "titleId == %@", filter)
        _fetchId.resultType = NSFetchRequestResultType.managedObjectResultType
        _fetchId.fetchLimit = 1
        
        do {
            let id = try moc.fetch(_fetchId)
            if id.count > 0 {
                for i in 0..<id.count {
                    idString = id[i].authorId.uuidString
                }
            }
        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "No fetch from TitleListViewExtension:GetAuthorId. \(error), \(error.localizedDescription)")
        }
        
        return idString
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
            logger.log(level: .error, message: "No fetch from TitleDetailsViewExtension:GetTitleByID. \(error), \(error.localizedDescription)")
            
        }
    }
}

