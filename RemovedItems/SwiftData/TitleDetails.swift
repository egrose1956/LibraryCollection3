//
//  BookDetails.swift
//  LibraryCollectionSwiftData
//
//  Created by Elizabeth Rose on 1/20/24.
//

import Foundation
import SwiftData

@Model
final class TitleDetails {
    
    var titleDetailsTimestamp: Date = Date.now
    var titleDetailsIdString: String = ""
    var authorIdString: String = ""
    var titleIdString: String = ""
    var title: String? = ""
    var bookType: String? = ""
    var editionNumber: String? = ""
    var genre: String? = ""
    var isbn: String? = ""
    var publishingDate: String? = ""
    var publishingHouse: String? = ""
    
    var titles: [Title]?
        
    init(titleDetailsIdString: String, 
         authorIdString: String,
         titleIdString: String,
         title: String? = nil,
         bookType: String? = nil,
         editionNumber: String? = nil,
         genre: String? = nil,
         isbn: String? = nil,
         publishingDate: String? = nil,
         publishingHouse: String? = nil) {
        
        self.titleDetailsIdString = titleDetailsIdString
        self.authorIdString = authorIdString
        self.titleIdString = titleIdString
        self.title = title
        self.bookType = bookType
        self.editionNumber = editionNumber
        self.genre = genre
        self.isbn = isbn
        self.publishingDate = publishingDate
        self.publishingHouse = publishingHouse
    }
}
