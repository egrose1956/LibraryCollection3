//
//  EditTitleDetails.swift
//  LibraryCollection
//
//  Created by Elizabeth Rose on 3/28/23.
//

import SwiftUI

struct EditTitleDetails: View {
    
    @Environment(\.managedObjectContext) var moc

    @State var authorIdString: String = ""
    @State var titleIdString: String = ""
    @State var title: String = ""
    @State private var titleHasChanged: Bool = false
    @State var titleDetails: [TitleDetails] = []
    @State var titleDetailsId: String = ""
    
    
    @State var bookTypes = ["Hardback", "Paperback", "Audio", "Ebook", "Other"]
    @State var selectedType: String = ""
    @State var editionNumber: String = ""
    @State var genre: String = ""
    @State var ISBN: String = ""
    @State var publishingDate: String = ""
    @State var publishingHouse: String = ""
    @State var additionalAuthors: [String] = []
    
    @State var displayCoAuthorsAndNarrators: Bool = false
    
    enum Field {
        case selectedType
        case editionNumber
        case genre
        case ISBN
        case publishingDate
        case publishingHouse
    }
    @FocusState private var focusedField: Field?
    
    var body: some View {
        NavigationStack {
            Form {
                VStack {
                    VStack(alignment: .leading) {
                        Text("Title: ")
                            .foregroundStyle(Color.accentColor)
                            .font(.footnote)
                        TextField("Title: \(title)", text: $title)
                            .font(.title3)
                            .fontWeight(.bold)
                            .accessibilityLabel("Title Details for \(title)")
                            .onChange(of: title) {
                                titleHasChanged = true
                            }
                    }
                    
                    Picker("Select book type", selection: $selectedType) {
                        ForEach(bookTypes, id: \.self) { type in
                            Text(type)
                                .accessibilityLabel("\(type)")
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(5)
                    .focused($focusedField, equals: .selectedType)
                    .textContentType(.none)
                    .submitLabel(.next)
                    .accessibilityLabel("Book Type Picker")
                    
                    VStack(alignment: .leading) {
                        Text("Edition Number: ")
                            .foregroundStyle(Color.accentColor)
                            .font(.footnote)
                        TextField("Edition Number: \(editionNumber)", text: $editionNumber)
                            .focused($focusedField, equals: .editionNumber)
                            .font(.subheadline)
                            .textContentType(.none)
                            .submitLabel(.next)
                            .accessibilityLabel("Edition Number")
                        
                        Divider()
                    
                        Text("Genre: ")
                            .foregroundStyle(Color.accentColor)
                            .font(.footnote)
                        TextField("Genre: \(genre)", text: $genre)
                            .focused($focusedField, equals: .genre)
                            .font(.subheadline)
                            .textContentType(.none)
                            .submitLabel(.next)
                            .accessibilityLabel("Genre")
                        
                        Divider()
                        
                        Text("ISBN: ")
                            .foregroundStyle(Color.accentColor)
                        TextField("ISBN: \(ISBN)", text: $ISBN)
                            .focused($focusedField, equals: .ISBN)
                            .textContentType(.none)
                            .submitLabel(.next)
                            .accessibilityLabel("ISBN")
                    
                        Divider()
                        
                        Text("Published Date: ")
                            .foregroundStyle(Color.accentColor)
                            .font(.footnote)
                        TextField("Published date: \(publishingDate)", text: $publishingDate)
                            .focused($focusedField, equals: .publishingDate)
                            .font(.subheadline)
                            .textContentType(.none)
                            .submitLabel(.next)
                            .accessibilityLabel("Published Date")
                        
                        Divider()
                        
                        Text("Publisher: ")
                            .foregroundStyle(Color.accentColor)
                            .font(.footnote)
                        TextField("Publisher: \(publishingHouse)", text: $publishingHouse)
                            .focused($focusedField, equals: .publishingHouse)
                            .font(.subheadline)
                            .textContentType(.none)
                            .submitLabel(.done)
                            .accessibilityLabel("Publishing House")
                    }
                }
                .onSubmit {
                    switch focusedField {
                    case .selectedType:
                        focusedField = .editionNumber
                    case .editionNumber:
                        focusedField = .genre
                    case .genre:
                        focusedField = .ISBN
                    case .ISBN:
                        focusedField = .publishingDate
                    case .publishingDate:
                        focusedField = .publishingHouse

                    default:
                        #if DEBUG
                            let logger = appLogger()
                            logger.log(level: .info, message: "Case default has been reached.")
                        #endif
                    }
                }

                NavigationLink {
                    CoAuthorsAndNarratorsView(titleIdString: titleIdString, titleName: title)
                } label: {
                     Text("Display information for existing Co-Authors and Narrators")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            LoadValues()
        }
        .keyboardType(.default)
        .autocorrectionDisabled(true)
        .safeAreaPadding(20)
        .onDisappear {
            if titleHasChanged {
                SaveTitleChanges()
            }
            SaveTitleDetails()
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                NavigationLink("Add a Co-Author",
                               destination: AddCoAuthorView(titleIdString: titleIdString, titleName: title))
            
                NavigationLink("Add a Narrator",
                               destination: AddNarratorView(titleIdString: titleIdString, titleName: title))
                
            }
        }
    }
    
    func LoadValues() {
        
        //this brings back title
        GetTitleById()
        
        GetTitleDetailsById()
        GetCoAuthors()
        
        if titleDetails.count > 0 {
            
            titleDetailsId = titleDetails[0].titleDetailsId.uuidString
            titleIdString = titleDetails[0].titleId.uuidString
            selectedType = titleDetails[0].bookType
            editionNumber = titleDetails[0].wrappedEditionNumber
            genre = titleDetails[0].wrappedGenre
            ISBN = titleDetails[0].wrappedISBN
            publishingDate = titleDetails[0].wrappedPublishingDate
            publishingHouse = titleDetails[0].wrappedPublishingHouse
        }
    }
}
