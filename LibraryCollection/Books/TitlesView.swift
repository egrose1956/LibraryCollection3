//
//  TitlesView.swift
//  LibraryCollection
//
//  Created by Elizabeth Rose on 1/20/24.
//

import SwiftUI
import CoreData

struct TitlesView: View {
    
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.title)
    ]) var titles: FetchedResults<Title>
    
    @State var authorIdString: String = ""
    
    @State var resultString: String = ""
    @State var titleIdString: String = ""
    @State var title: String = ""
    @State private var safeToDelete: Bool = false
       
    var body: some View {
        NavigationStack {
            Group {
                if titles.isEmpty {
                    ContentUnavailableView {
                        Image(systemName: "books.vertical")
                            .font(.largeTitle)
                    } description: {
                        Text("No Books Available. Add an Author or add a new title to a current author.")
                    } actions: {

                    }
                } else {
                    Text("Titles")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.accentColor)
                    
                    List {
                        ForEach (titles) { selectedItem in
                            NavigationLink {
                                EditTitleDetails(titleIdString: selectedItem.titleId.uuidString)
                            } label: {
                                Text(selectedItem.title.isEmpty ? "" : selectedItem.title)
                            }
                            .swipeActions(allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    titleIdString = selectedItem.titleId.uuidString
                                    safeToDelete = true
                                } label: {
                                    Label("Delete", systemImage: "trash.fill")
                                }
                                .tint(.red)
                            }
                        }
                    }
                    .font(.title2)
                    .foregroundStyle(Color.accentColor)
                    .alert("Confirm action", isPresented: $safeToDelete) {
                        Button("Delete? This can't be undone.", role: .destructive) {
                            if authorIdString.isEmpty {
                                authorIdString = GetAuthorId(filter: titleIdString)
                            }
                            DeleteSelectedTitle(titleId: titleIdString, authorId: authorIdString)
                            moc.refreshAllObjects()
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                }
            }
        }
    }
}


