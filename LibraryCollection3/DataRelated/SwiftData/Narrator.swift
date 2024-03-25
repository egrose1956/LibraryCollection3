//
//  Narrator.swift
//  LibraryUsingSwiftData
//
//  Created by Elizabeth Rose on 8/22/23.
//

import Foundation
import SwiftData

@Model
class Narrator {
    
    var timestamp: Date = Date.now
    var narratorIdString: String = ""
    var narratorFirstName: String = ""
    var narratorMiddleName: String = ""
    var narratorLastName: String = ""

    var titles: [Title]?
    
    init(narratorIdString: String, narratorFirstName: String, narratorMiddleName: String, narratorLastName: String) {
        self.narratorIdString = narratorIdString
        self.narratorLastName = narratorLastName
        self.narratorFirstName = narratorFirstName.isEmpty ? "" : narratorFirstName
        self.narratorMiddleName = narratorMiddleName.isEmpty ? "" : narratorMiddleName
    }
}
