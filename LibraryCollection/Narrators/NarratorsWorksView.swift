//
//  NarratorsWorksView.swift
//  LibraryCollection
//
//  Created by Elizabeth Rose on 4/16/24.
//

import CoreData
import SwiftUI

struct NarratorsWorksView: View {
        
    @Environment(\.managedObjectContext) var moc
    
    @State var narratorIdString: String
    @State var titleIdString: String = ""
    @State var narratorTitles: [String] = []
    
    var body: some View {
        
        VStack(alignment: .center) {
            Text("Narrators's Current Works: ")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(Color.accentColor)
            
            NavigationStack {
                ScrollView {
                    ForEach (narratorTitles, id:\.self) { selectedItem in
                        
                        Text("\(selectedItem.components(separatedBy: "*")[0])")
//                        NavigationLink("\(selectedItem.components(separatedBy: "*")[0])",
//                                       destination: TitleDetailsView(authorIdString: authorIdString,
//                                                                     titleIdString: selectedItem.components(separatedBy: "*")[1]))
                    }
                }
                .onAppear {
                    moc.refreshAllObjects()
                    GetAllTitlesByNarrator(narratorIdString: narratorIdString)
                }
            }
        }
    }
    
        
//        func GetComponentValues(componentString: String) {
//            titleIdString = componentString.components(separatedBy: "*")[1]
//        }
}

