//
//  AddTitleDetailsViewExtension.swift
//  LibraryCollection
//
//  Created by Elizabeth Rose on 2/1/23.
//
import Foundation
import CoreData

extension AddTitleDetailsView {
    
    func LoadValues() {
        
        guard !selectedItem.isEmpty || !authorIdString.isEmpty else { return }

        if !authorIdString.isEmpty {
            CheckForExistingAuthor(authorIdValue: authorIdString)
        } else {
            
            authorLastName = selectedItem.components(separatedBy: ",")[0].trimmingCharacters(in: .whitespacesAndNewlines)
            authorFirstName = selectedItem.components(separatedBy: ",")[1].trimmingCharacters(in: .whitespacesAndNewlines)
            CheckForExistingAuthor(lastNameValue: authorLastName,
                                                    firstNameValue: authorFirstName)
        }
        
        if comingFromSearch {
            if searchType == "author" {
                ParseStringAuthor(selectedItem: selectedItem)
                displayString = "Displaying: \(selectedTitle) \n Written by: \(authorName)"
                comingFromSearch = false
            } else {
                ParseStringTitle(selectedItem: selectedItem)
            }
        } else {
            
            let fullNameString = nameFormatter.ConcatenateNameFields(lastName: authorLastName,
                                                                     firstName: authorFirstName,
                                                                     middleName: authorMiddleName)
            displayString = "Displaying: \(selectedTitle) \n Written by: \(fullNameString)"
        }

        selectedItem = selectedTitle
        
        GetTitleIdByTitleAndAuthorName()
        GetTitleDetailsById()
        GetCoAuthors()
//        let nav = NarratorListView()
//            nav.GetAllNarratorsForTitle()
        
        if titleDetails.count > 0 {
            title = selectedItem
            detailsHaveBeenSaved = true
            selectedType = titleDetails[0].bookType
            editionNumber = titleDetails[0].wrappedEditionNumber
            genre = titleDetails[0].wrappedGenre
            ISBN = titleDetails[0].wrappedISBN
            publishingDate = titleDetails[0].wrappedPublishingDate
            publishingHouse = titleDetails[0].wrappedPublishingHouse
            titleDetailsId = titleDetails[0].titleDetailsId.uuidString
            titleIdString = titleDetails[0].titleId.uuidString
        }
    }
    
    func ParseStringTitle(selectedItem: String) {
        
        for i in (0..<selectedItem.components(separatedBy: "*").count) {
            if i == 0 {
                selectedTitle = selectedItem.components(separatedBy: "*")[i]
            } else if i == 1 {
                titleIdString = selectedItem.components(separatedBy: "*")[i]
            } else if i == 2 {
                authorIdString = selectedItem.components(separatedBy: "*")[i]
            } else if i == 3 {
                authorName = selectedItem.components(separatedBy: "*")[i]
                authorLastName = selectedItem.components(separatedBy: "*")[i].components(separatedBy: ", ")[0]
                authorFirstName = selectedItem.components(separatedBy: "*")[i].components(separatedBy: ", ")[1]
            }
        }
    }
    
    func ParseStringAuthor(selectedItem: String) {
        
        var stringParts = selectedItem.components(separatedBy: ",")
        authorFirstName = stringParts[1].trimmingCharacters(in: .whitespacesAndNewlines)
        
        authorLastName = stringParts[0]
        
        authorName = authorLastName
        if !authorFirstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            authorName = authorName + ", " + authorFirstName
        }
        
        stringParts.removeAll()
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
    
    func CheckForExistingTitle(titleNameFilter: String, authorIdString: String) {
        
        guard !authorIdString.isEmpty else { return }
        guard !titleNameFilter.isEmpty else { return }
        
        let authorId = UUID(uuidString: authorIdString)
        
        let _fetchRequest = NSFetchRequest<Title>(entityName: "Title")
        _fetchRequest.predicate = NSPredicate(format: "title CONTAINS[c] %@", titleNameFilter)
        _fetchRequest.resultType = NSFetchRequestResultType.managedObjectResultType
        
        do {
            let _title = try moc.fetch(_fetchRequest)
            if _title.count > 0 {
                
                for i in 0..<_title.count {
                    
                    let _TA = NSFetchRequest<TitleAuthor>(entityName: "TitleAuthor")
                    _TA.predicate = NSPredicate(format: "titleId == %@ AND authorId == %@", _title[i].titleId as CVarArg,
                                                authorId! as CVarArg)
                    _TA.resultType = NSFetchRequestResultType.managedObjectResultType
                    
                    do {
                        let _titles = try moc.fetch(_TA)
                        if _titles.count > 0  {
                            //already have for this author
                            titleIdString = _titles[0].titleId.uuidString
                        }
                    }
                }
            } else {
                titleIdString = ""
            }
        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "No fetch from AddAuthorAndTitleExtension:CheckForExistingTitle. \(error), \(error.localizedDescription)")
        }
    }
    
       
    func SaveTitle(authorIdString: String) -> String {
        
        guard !title.isEmpty else { return ""}
        guard !authorIdString.isEmpty else { return ""}
        
        CheckForExistingTitle(titleNameFilter: title, authorIdString: authorIdString)
        
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
            return titleIdString
            
        } catch {
            let logger = appLogger()
            logger.log(level: .error, message: "No save at: AddAuthorAndTitleExtension:SaveTitle. \(error), \(error.localizedDescription)")
            return ""
        }
    }

    func SaveTitleDetails() {
        
        guard !authorIdString.isEmpty else { return }
        
        titleIdString = SaveTitle(authorIdString: authorIdString)
        
        guard !titleIdString.isEmpty else { return }
        let newTitleId: UUID = UUID(uuidString: titleIdString)!

        let saveDetails = TitleDetails(context: moc)
        saveDetails.titleDetailsId = UUID()
        
        let _fetchRequest = NSFetchRequest<TitleDetails>(entityName: "TitleDetails")
        _fetchRequest.predicate = NSPredicate(format: "titleDetailId == %@ && titleId == %@", saveDetails.titleDetailsId as CVarArg, titleIdString as CVarArg)
        _fetchRequest.resultType = NSFetchRequestResultType.managedObjectResultType

        saveDetails.titleId = newTitleId
        
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
                logger.log(level: .error, message: "Save Error in AddTitleDetailsViewExtension:SaveTitleDetails. \(error), \(error.localizedDescription)")
            }
        }
    }
    
    func CheckForExistingAuthor(authorIdValue: String) {
        
        guard !authorIdValue.isEmpty else { return }
        
        let _fetchRequest = NSFetchRequest<Author>(entityName: "Author")
        _fetchRequest.predicate = NSPredicate(format: "authorId == %@", UUID(uuidString: authorIdValue)! as CVarArg)
        _fetchRequest.resultType = NSFetchRequestResultType.managedObjectResultType
        
        do {
            let _existingAuthor = try moc.fetch(_fetchRequest)
            if _existingAuthor.count > 0 {
                authorFirstName = (_existingAuthor[0].wrappedAuthorFirstName)
                authorMiddleName = (_existingAuthor[0].wrappedAuthorMiddleName)
                authorLastName = _existingAuthor[0].authorLastName
            }
        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "No fetch from AddTitleDetailsViewExtension:CheckForExistingAuthor. \(error), \(error.localizedDescription)")
        }
    }
    
    func CheckForExistingAuthor(lastNameValue: String, firstNameValue: String) {
        
        guard !lastNameValue.isEmpty else { return }
        
        let _fetchRequest = NSFetchRequest<Author>(entityName: "Author")
        if firstNameValue == "" {
            _fetchRequest.predicate = NSPredicate(format: "authorLastName BEGINSWITH[c] %@", lastNameValue)
        } else {
            _fetchRequest.predicate = NSPredicate(format: "authorLastName BEGINSWITH[c] %@ AND authorFirstName BEGINSWITH[c] %@", lastNameValue, firstNameValue)
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
            logger.log(level: .error, message: "No fetch from AddTitleDetailsViewExtension:CheckForExistingAuthor. \(error), \(error.localizedDescription)")
        }
    }
    
    func GetTitleIdByTitleAndAuthorName() {
        
        guard !authorIdString.isEmpty else { return }
        guard !selectedTitle.isEmpty else { return }
        
        //clear previously used variables
        resultString = []
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
            _fetchTitles.predicate = NSPredicate(format: "title CONTAINS[c] %@", selectedTitle)
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
            logger.log(level: .error, message: "No fetch from AddTitleDetailsViewExtension:GetTitleByTitleAndAuthorName. \(error), \(error.localizedDescription)")
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
            if _coAuthors.count > 1 {
                for i in 0..<_coAuthors.count {
                    authorIds.append(_coAuthors[i].authorId.uuidString)
                }
            }
            
            for j in 0..<authorIds.count {
                let _fetchCoAuthorNames = NSFetchRequest<Author>(entityName: "Author")
                _fetchCoAuthorNames.predicate = NSPredicate(format: "authorId == %@", authorIds[j])
                _fetchCoAuthorNames.resultType = NSFetchRequestResultType.managedObjectResultType
            
                let nameFormatter = NameFormatter()
                let _names = try moc.fetch(_fetchCoAuthorNames)
                for k in 0..<_names.count {
            
                    additionalAuthors.append(nameFormatter.ConcatenateNameFields(lastName: _names[k].authorLastName,
                                                                                 firstName: _names[k].wrappedAuthorFirstName,
                                                                                 middleName: _names[k].wrappedAuthorMiddleName))
                }
            }
        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "No fetch from AddTitleDetailsViewExtension:GetCoAuthors. \(error), \(error.localizedDescription)")
        }
    }    
}
