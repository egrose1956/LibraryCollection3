//
//  Previewer.swift
//  FaceFacts
//
//  Created by Paul Hudson on 22/12/2023.
//  Many thanks, Paul!!  E.G. Rose

import Foundation
import SwiftData

@MainActor
struct Previewer {
    let container: ModelContainer
    let author: Author
    let title: Title

    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Author.self, configurations: config)

        author = Author(timestamp: Date.now, authorId: UUID(), authorLastName: "Rose", authorFirstName: "William", authorMiddleName:"Louis")
        title = Title(timestamp: Date.now, titleId: UUID(), title: "Bessie: Book One")

        container.mainContext.insert(author)
    }
}
