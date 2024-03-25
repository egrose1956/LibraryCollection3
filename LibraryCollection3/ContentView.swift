//
//  ContentView.swift
//  LibraryUsingSwiftData
//
//  Created by Elizabeth Rose on 8/15/23.
//

import SwiftUI

struct ContentView: View {
    
    @State private var createNewAuthor: Bool = false
    
    enum FilterOptions {
        case worksTitles, authors, narrators, unknown
    }
    @State var filter: FilterOptions

    var body: some View {
        
        VStack(alignment: .center) {
            Text("LibraryCollection")
                .font(.title)
                .fontWeight(.bold)
        }
        NavigationStack {
            VStack {
                switch filter {
                case .authors:
                    AuthorsView()
                case .worksTitles:
                    TitlesView()
                case .narrators:
                    NarratorListView()
                default:
                    AuthorsView()
                }

                Section {
                    Image("oldbigbookshelf")
                        .resizable()
                        .scaledToFit()
                        .accessibilityLabel("Picture of a colorful fantasy bookshelf.")
                        .background(.tertiary)
                        .padding(.bottom, 10)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu("Viewing Options", systemImage: "text.justify") {
                        Button("View Titles") { filter = .worksTitles }
                        Button("View Authors") { filter = .authors}
                        Button("View Narrators") { filter = .narrators }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu("Author Actions", systemImage: "pencil") {
                        NavigationLink("Create New Author", destination: NewAuthorView())
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Image("magnifyingglass")
                            .resizable()
                            .scaledToFit()
                        NavigationLink("Search", destination: Search())
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color.accentColor)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .safeAreaPadding()
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
