//
//  NarratorListView.swift
//  LibraryCollection
//
//  Created by Elizabeth Rose on 2/9/23.
//

import SwiftUI

struct NarratorListView: View {
    
    @Environment(\.managedObjectContext) var moc
            
    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\.narratorLastName)
        ]
    ) var narrators: FetchedResults<Narrator>
    
    //For sending the selected narrator for editing
    @State var narrator: FetchedResults<Narrator>.Element?
    
    @State var titleIdString: String = ""
    @State var titleName: String = ""
    @State var filteredNarrators: [String] = []
    @State var nameFormatter = NameFormatter()
    @State var deleteWarning: Bool = false
    @State var narratorIdString: String = ""
    
    var body: some View {
        NavigationStack {
            Group {
                if narrators.isEmpty {
                    ContentUnavailableView {
                        Image(systemName: "person.slash")
                            .font(.largeTitle)
                    } description: {
                        VStack(alignment: .center) {
                            Text("No Narrators Created.")
                            Text("Narrators are created from the Title details screen.")
                        }
                    }
                } else {
                    Text("Narrators")
                        .font(.title3)
                        .fontWeight(.bold)
                    Form {
                        if !titleName.isEmpty {
                            Text("Narrators For: \(titleName)")
                                .accessibilityLabel("Narrators For: \(titleName)")
                        }
                        if !narrators.isEmpty {
                            List(narrators, id: \.narratorId) { narrator in
                                
                                NavigationLink(destination: EditNarrator(narrator: narrator)) {
                                    Text(nameFormatter.ConcatenateNameFields(lastName: narrator.narratorLastName,
                                                                             firstName: narrator.wrappedNarratorFirstName,
                                                                             middleName: narrator.wrappedNarratorMiddleName))
                                    .font(.subheadline)
                                    .accessibilityLabel("Proceeding to edit \(narrator.wrappedNarratorFirstName) \(narrator.narratorLastName)")
                                }
                            }
                            .swipeActions(allowsFullSwipe: false) {
                                Button() {
                                    deleteWarning = true
                                    narratorIdString = narrator!.narratorId.uuidString
                                } label: {
                                    Label("Delete", systemImage: "trash.fill")
                                }
                                .tint(.red)
                            }
                        }
                    }
                }
            }
            .onAppear {
                if !titleName.isEmpty {
                    GetAllNarratorsForTitle()
                }
            }
            .foregroundColor(Color.accentColor)
            
            // TODO: A link to all titles narrator has performed, authors they have read for?? Edit??
        }
    }
}
