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
    @State var narratorListForTitle: [String] = []
    @State var nameFormatter = NameFormatter()
    @State var deleteWarning: Bool = false
    @State var narratorIdString: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
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
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.accentColor)
    
                    List(narrators, id: \.narratorId) { selectedNarrator in

                        NavigationLink { 
                            NarratorView(narrator: selectedNarrator)
                        } label: {
                            Text(nameFormatter.ConcatenateNameFields(lastName: selectedNarrator.narratorLastName,
                                                                     firstName: selectedNarrator.wrappedNarratorFirstName,
                                                                     middleName: selectedNarrator.wrappedNarratorMiddleName))
                            .font(.subheadline)
                            .accessibilityLabel("Proceeding to edit \(selectedNarrator.wrappedNarratorFirstName) \(selectedNarrator.narratorLastName)")
                        }
                        .onTapGesture {
                            narratorIdString = selectedNarrator.narratorId.uuidString
                        }
                        .swipeActions(allowsFullSwipe: false) {
                            Button() {
                                deleteWarning = true
                                narratorIdString = selectedNarrator.narratorId.uuidString
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                            .tint(.red)
                        }
                    }
                }
            } //Group
            .onAppear {
                if !titleName.isEmpty {
                    GetAllNarratorsForTitle(narratorIdString: narratorIdString, titleIdString: titleIdString)
                }
            }
            // TODO: A link to all titles narrator has performed, authors they have read for?? Edit??
        }
    }
}
