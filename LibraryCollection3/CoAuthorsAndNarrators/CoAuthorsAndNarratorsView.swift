//
//  CoAuthorsAndNarratorsView.swift
//  LibraryCollection3
//
//  Created by Elizabeth Rose on 3/11/24.
//

import SwiftUI
import CoreData

struct CoAuthorsAndNarratorsView: View {
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    @State var titleIdString: String = ""
    @State var titleName: String = ""
    @State var filteredAuthors: [String] = []
    @State var filteredNarrators: [String] = []
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                
                if !filteredAuthors.isEmpty {
                    Text("Co-Authors for: \(titleName)")
                        .padding(.bottom)
                    List {
                        ForEach (filteredAuthors, id: \.self)  { author in
                            Text("\(author)")
                        }
                    }
                } else {
                    Text("No Co-Authors for: \(titleName)")
                }
                
                if !filteredNarrators.isEmpty {
                    Text("Narrators:")
                        .padding(.bottom)
                    List {
                        ForEach (filteredNarrators, id: \.self)  { narrator in
                            Text("\(narrator)")
                        }
                    }
                } else {
                    Text("No Narrators")
                }
                Button("Cancel") {dismiss()}
                    .buttonStyle(CustomButtonStyle())
            }
            .font(.title2)
            .foregroundStyle(Color.accentColor)
            .safeAreaPadding(20)
        }
        .onAppear() {
            LoadCoAuthors()
            LoadNarrators()
        }
    }
}
