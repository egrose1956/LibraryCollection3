//
//  NarratorListViewExtension.swift
//  LibraryCollection
//
//  Created by Elizabeth Rose on 4/10/24.
//

import Foundation
import CoreData

extension NarratorListView {
    
    func GetAllNarratorsForTitle(narratorIdString: String, titleIdString: String) {
        
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
    
}
