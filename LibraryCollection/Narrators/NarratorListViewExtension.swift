//
//  NarratorListViewExtension.swift
//  LibraryCollection
//
//  Created by Elizabeth Rose on 4/10/24.
//

import Foundation
import CoreData

extension NarratorListView {
    
    func NarratorFilteredForTitle() {
        
        guard !titleIdString.isEmpty else { return }
        guard !narratorIdString.isEmpty else { return }
        narratorTitles.removeAll()
        
        let id = UUID(uuidString: narratorIdString)!
        
        let _fetchRequest = NSFetchRequest<TitleNarrator>(entityName: "TitleNarrator")
        _fetchRequest.predicate = NSPredicate(format: "narratorId == %@", id as CVarArg)
        _fetchRequest.resultType = NSFetchRequestResultType.managedObjectResultType
        
        do {
            let _tn = try moc.fetch(_fetchRequest)
            for i in (0..<_tn.count) {

                let titleId = _tn[i].titleId.uuidString
                
                let _fetchRequestTitle = NSFetchRequest<Title>(entityName: "Title")
                _fetchRequestTitle.predicate = NSPredicate(format: "titleId == %@", titleId as CVarArg)
                _fetchRequestTitle.resultType = NSFetchRequestResultType.managedObjectResultType
                
                let result = try moc.fetch(_fetchRequestTitle)
                for _ in (0..<result.count) {
                    let resultString = result[0].title + "*" + titleId
                    narratorTitles.append(resultString)
                }
            }
        } catch let error as NSError {
            let logger = appLogger()
            logger.log(level: .error, message: "No fetch from NarratorsWorksViewExtension:GetAllTitlesByNarrators. \(error), \(error.localizedDescription)")
        }
    }
    
}
