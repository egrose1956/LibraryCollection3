//
//  TitlesView.swift
//  LibraryCollection3
//
//  Created by Elizabeth Rose on 1/20/24.
//

import SwiftUI

struct TitlesView: View {
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.title)
    ]) var titles: FetchedResults<Title>
    
    @State var authorIdString: String = ""
    
    @State var resultString: String = ""
    @State var titleIdString: String = ""
    @State var title: String = ""
    @State private var newTitleAndDetails: Bool = false
    @State private var safeToDelete: Bool = false
       
    var body: some View {
        NavigationStack {
            Group {
                if titles.isEmpty {
                    ContentUnavailableView {
                        Image(systemName: "books.vertical")
                            .font(.largeTitle)
                    } description: {
                        Text("Add New Title and Details")
                    } actions: {
                        Button("Create Book Details") {
                            newTitleAndDetails.toggle()
                        }
                        .buttonStyle(CustomButtonStyle())
                    }
                } else {
                    Text("Titles")
                        .font(.title3)
                        .fontWeight(.bold)
                    List {
                        ForEach(titles) { title in
                            NavigationLink {
                                EditTitleDetails(titleIdString: title.titleId.uuidString)
                            } label: {
                                Text(title.title.isEmpty ? "" : title.title)
                            } //label
                            .swipeActions(allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    safeToDelete.toggle()
                                    moc.delete(title)
                                    do {
                                        try moc.save()
                                    } catch {
                                        let logger = appLogger()
                                        logger.log(level: .info, message: "Save of title delete failed.")
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash.fill")
                                }
                            }
                        }
                    }
                }
            }
            .font(.title2)
            .foregroundStyle(Color.accentColor)
            .alert("Confirm action", isPresented: $safeToDelete) {
                Button("Delete? This can't be undone.", role: .destructive){}
                Button("Cancel", role: .cancel) { dismiss() }
            }
            // to add another book for an existing author
            if newTitleAndDetails {
                AddTitleDetailsView(authorIdString: authorIdString)
            }
        }
    }
}


