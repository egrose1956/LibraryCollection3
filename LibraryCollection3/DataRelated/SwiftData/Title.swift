//
//  Book.swift
//  LibraryCollectionSwiftData
//
//  Created by Elizabeth Rose on 1/20/24.
//

import Foundation
import SwiftData

@Model
final class Title {
    
    var timestamp: Date = Date.now
    var titleIdString: String = ""
    var title: String = ""
    
    @Relationship(deleteRule: .cascade) 
    var details: [TitleDetails]?
    
    var authors: [Author]?
    var narrators: [Narrator]?

    init(titleIdString: String, title: String) {
        self.titleIdString = titleIdString
        self.title = title
    }
}
