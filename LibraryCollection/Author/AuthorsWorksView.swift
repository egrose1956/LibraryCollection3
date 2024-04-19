//
//  AuthorsWorksView.swift
//  LibraryCollection
//
//  Created by Elizabeth Rose on 4/2/23.
//

import SwiftUI
import CoreData

struct AuthorsWorksView: View {
        
    @State var authorTitles: [String] = []
    @State var authorIdString: String
    @State var titleIdString: String = ""
    
    var body: some View {
        
        VStack(alignment: .center) {
            Text("Author's Current Works: ")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(Color.accentColor)
            
            NavigationStack {
                ScrollView {
                    ForEach (authorTitles, id:\.self) { selectedItem in
                        NavigationLink("\(selectedItem.components(separatedBy: "*")[0])",
                                       destination: TitleDetailsView(authorIdString: authorIdString,
                                                                     titleIdString: selectedItem.components(separatedBy: "*")[1]))
                    }
                }
            }
        }
    }
}

