//
//  AuthorsWorksView.swift
//  LibraryCollection
//
//  Created by Elizabeth Rose on 4/2/23.
//

import SwiftUI
import CoreData

struct AuthorsWorksView: View {
    
    @Environment(\.managedObjectContext) var moc
    
    @State var authorIdString: String
    @State var titleIdString: String = ""
    @State var filteredTitles: [String] = []
    
    var body: some View {
        
        VStack(alignment: .center) {
            Text("Author's Current Works: ")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(Color.accentColor)
            
            NavigationStack {
                ScrollView {
                    ForEach (filteredTitles, id:\.self) { selectedItem in
                        NavigationLink("\(selectedItem.components(separatedBy: "*")[0])",
                                       destination: EditTitleDetails(authorIdString: authorIdString,
                                                                     titleIdString: selectedItem.components(separatedBy: "*")[1]))
                    }
                }
                .onAppear {
                    moc.refreshAllObjects()
                    GetAllTitlesByAuthor(authorIdString: authorIdString)
                }
            }
        }
    }
    
    func GetComponentValues(componentString: String) {
        titleIdString = componentString.components(separatedBy: "*")[1]
    }
}

