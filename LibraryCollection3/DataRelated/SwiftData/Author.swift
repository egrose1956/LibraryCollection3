//
//  Author.swift
//  LibraryUsingSwiftData
//
//  Created by Elizabeth Rose on 8/15/23.
//

import SwiftUI
import SwiftData

@Model
class Author {
    
    var timestamp: Date = Date.now
    var authorIdString: String = ""
    var authorFirstName: String = ""
    var authorMiddleName: String = ""
    var authorLastName: String = ""
    @Relationship(deleteRule: .nullify, inverse: \Title.authors)
    var titles: [Title]?
     
    init(authorIdString: String, authorFirstName: String, authorMiddleName: String, authorLastName: String) {
        self.authorIdString = authorIdString
        self.authorLastName = authorLastName
        self.authorFirstName = authorFirstName.isEmpty ? "" : authorFirstName
        self.authorMiddleName = authorMiddleName.isEmpty ? "" : authorMiddleName
    }
}
