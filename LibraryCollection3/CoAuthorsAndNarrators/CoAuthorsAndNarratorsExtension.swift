//
//  CoAuthorsAndNavigatorsExtension.swift
//  LibraryCollection3
//
//  Created by Elizabeth Rose on 3/11/24.
//

import Foundation
import CoreData

extension CoAuthorsAndNarratorsView {
    
    func LoadCoAuthors() {
                
        guard !titleIdString.isEmpty else { return }
        
        filteredAuthors = []

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
                                filteredAuthors.append(workingString)
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
   
    func LoadNarrators() {
        
        guard !titleIdString.isEmpty else { return }
        
        let nameFormatter = NameFormatter()
        filteredNarrators.removeAll()
                
        let _fetchTN = NSFetchRequest<TitleNarrator>(entityName: "TitleNarrator")
        _fetchTN.predicate = NSPredicate(format: "titleId == %@", titleIdString)
        _fetchTN.resultType = NSFetchRequestResultType.managedObjectResultType
        
        do {
            let _TN = try moc.fetch(_fetchTN)
            if _TN.count > 0 {
                for i in 0..<_TN.count {
                    
                    let _fetchNarrator = NSFetchRequest<Narrator>(entityName: "Narrator")
                    _fetchNarrator.predicate = NSPredicate(format: "narratorId = %@", _TN[i].narratorId.uuidString)
                    _fetchNarrator.resultType = NSFetchRequestResultType.managedObjectResultType
                    
                    do{
                        var returnName: String = ""
                        
                        let _narr = try moc.fetch(_fetchNarrator)
                        if _narr.count > 0 {
                            for i in 0..<_narr.count {
                                returnName = nameFormatter.ConcatenateNameFields(lastName: _narr[i].narratorLastName,
                                                                                 firstName: _narr[i].wrappedNarratorFirstName,
                                                                                 middleName: _narr[i].wrappedNarratorMiddleName)
                                filteredNarrators.append(returnName)
                            }
                            
                        }
                    }
                }
            }
            
        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "No fetch from NarratorListViewExtension:GetAllNarratorsForTitle. \(error), \(error.localizedDescription)")
        }
    }
}
