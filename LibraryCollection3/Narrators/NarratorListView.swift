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
    
    var body: some View {
        NavigationStack {
            Text("Narrators")
                .font(.title3)
                .fontWeight(.bold)
            Form {
                if !titleName.isEmpty {
                    Text("Narrators For: \(titleName)")
                        .accessibilityLabel("Narrators For: \(titleName)")
                }
                
                List(narrators, id: \.narratorId) { narrator in

                    NavigationLink(destination: EditNarrator(narrator: narrator)) {
                        Text(nameFormatter.ConcatenateNameFields(lastName: narrator.narratorLastName,
                                                               firstName: narrator.wrappedNarratorFirstName,
                                                               middleName: narrator.wrappedNarratorMiddleName))
                            .accessibilityLabel("Proceeding to edit \(narrator.wrappedNarratorFirstName) \(narrator.narratorLastName)")
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
//        .toolbar {
//            TODO: A link to all titles narrator has performed, authors they have read for?? Edit??
//        }
    }
}

//struct NarratorListView_Previews: PreviewProvider {
//    static var previews: some View {
//        NarratorListView()
//    }
//}
