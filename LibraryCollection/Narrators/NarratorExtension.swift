//
//  NarratorExtension.swift
//  LibraryCollection
//
//  Created by Elizabeth Rose on 4/8/23.
//

import Foundation
import CoreData

extension NarratorListView {
  
    func GetAllNarratorsForTitle() {
        
        guard !titleIdString.isEmpty else { return }
        
        let nameFormatter = NameFormatter()
        filteredNarrators.removeAll()
                
        let _fetchTN = NSFetchRequest<TitleNarrator>(entityName: "TitleNarrator")
        _fetchTN.predicate = NSPredicate(format: "titleId = %@", UUID(uuidString: titleIdString)! as CVarArg)
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


