//
//  AuthorsListView.swift
//  LibraryCollection
//
//  Created by Elizabeth Rose on 1/29/24.
//

import SwiftUI
import CoreData

struct AuthorsListView: View {
    
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\.authorLastName)
        ]
    ) var authors: FetchedResults<Author>
    
    @State private var deleteWarning: Bool = false
    @State var authorIdString: String = ""
    
    @State var titleIdArray: [String] = []
    @State var narratorIdArray: [String] = []
    @State var authorTitles: [String] = []
            
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
                        NavigationLink("Create Author") {
                            AuthorView()
                        }
                        .buttonStyle(CustomButtonStyle())
                    }
                } else {
                    Text("Authors")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.accentColor)
                    List {
                        ForEach (authors, id: \.authorId) { author in
                            
                            NavigationLink {
                                AuthorView(authorLastName: author.authorLastName,
                                           authorFirstName: author.wrappedAuthorFirstName,
                                           authorMiddleName: author.wrappedAuthorMiddleName,
                                           authorIdString: author.authorId.uuidString, authorTitles: authorTitles)
                                .onTapGesture {
                                    authorIdString = author.authorId.uuidString
                                }
                            } label: {
                                                     
                                let nameFormatter = NameFormatter()
                                
                                let fullNameString = nameFormatter.ConcatenateNameFields(lastName: author.authorLastName,
                                                                                         firstName: author.authorFirstName,
                                                                                         middleName: author.authorMiddleName)
                                Text(fullNameString)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.subheadline)
                                    .accessibilityValue("Author's name is \(fullNameString)")
                            }
//                            .onTapGesture {
//                                authorIdString = author.authorId.uuidString
//                            }
                            .swipeActions(allowsFullSwipe: false) {
                                Button() {
                                    deleteWarning = true
                                    authorIdString = author.authorId.uuidString
                                } label: {
                                    Label("Delete", systemImage: "trash.fill")
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
        }
    }
}
/*
#if DEBUG
                                    // if in debug mode and the function is uncommented...
                                    // this functionality is included for the developer to clean data
                                    // from the tables for testing purposes. It is unlikely to ever be
                                    // accessible to the user - maybe move to "admin" module?

                                     //deleteRelatedAuthorFiles(authorIdString: authorIdString)
#endif
*/
