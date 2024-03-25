//
//  AuthorsView.swift
//  LibraryCollection3
//
//  Created by Elizabeth Rose on 1/29/24.
//

import SwiftUI
import CoreData

struct AuthorsView: View {
    
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\.authorLastName)
        ]
    ) var authors: FetchedResults<Author>
    
    @State var showNewAuthorSheet: Bool = false
    @State private var deleteWarning: Bool = false
    @State var authorIdString: String = ""
    //For delete functionality:
    @State var titleIdArray: [String] = []
    @State var narratorIdArray: [String] = []
    
    var body: some View {
        NavigationStack {
            Group {
                if authors.isEmpty {
                    ContentUnavailableView {
                        Image(systemName: "person.slash")
                            .font(.largeTitle)
                    } description: {
                        Text("Add New Author")
                    } actions: {
                        Button("Create Author") {
                            showNewAuthorSheet = true
                        }
                        .buttonStyle(CustomButtonStyle())
                    }
                } else {
                    Text("Authors")
                        .font(.title3)
                        .fontWeight(.bold)
                    List {
                        ForEach (authors) { author in
                            NavigationLink {
                                EditAuthorView(authorIdString: author.authorId.uuidString, authorLastName: author.authorLastName, authorFirstName: author.wrappedAuthorFirstName,
                                               authorMiddleName: author.wrappedAuthorMiddleName)
                            } label: {
                                let nameFormatter = NameFormatter()
                                
                                let fullNameString = nameFormatter.ConcatenateNameFields(lastName: author.authorLastName,
                                                                                         firstName: author.authorFirstName,
                                                                                         middleName: author.authorMiddleName)
                                Text(fullNameString)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.title3)
                                    .accessibilityValue("Author's name is \(fullNameString)")
                                
                            }
                            .swipeActions(allowsFullSwipe: false) {
                                Button("Deleting") {
                                    deleteWarning = true
                                    authorIdString = author.authorId.uuidString
#if DEBUG
                                    // if in debug mode and the function is uncommented...
                                    // this functionality is included for the developer to clean data
                                    // from the tables for testing purposes. It is unlikely to be
                                    // accessible to the user
                                    
                                     deleteRelatedAuthorFiles(authorIdString: authorIdString)
#endif
                                }
                                .tint(.red)
                            }
                        }
                    }
                    .alert(isPresented: $deleteWarning) {
                        Alert(
                            title: Text ("Warning: Continuing will delete the author and all titles they have written."),
                            message: Text("This cannot be undone. Do you still wish to proceed?"),
                            primaryButton: .destructive(Text("Yes, Delete.")) {
                                //TODO: Decide how far we delete down the stack.
                                //for now, just the Author and TitleAuthor records
                                //see swipe action button for the full stack delete
                                //AND MAKE SURE TO COMMENT IT OUT AFTER TESTING
                                
                                deleteTitleAuthorandAuthorRecord()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
            }
            .foregroundColor(Color.accentColor)
            .sheet(isPresented: $showNewAuthorSheet) {
                NewAuthorView()
            }
        }
    }
}
