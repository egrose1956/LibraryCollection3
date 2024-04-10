//
//  TitleDetailsView.swift
//  LibraryCollection
//
//  Created by Elizabeth Rose on 4/9/24.
//

import SwiftUI

struct TitleDetailsView: View {
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    @State var authorIdString: String = ""
    @State var titleIdString: String = ""
    @State var title: String = ""
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
    
    enum Field {
            case selectedType
            case editionNumber
            case genre
            case ISBN
            case publishingDate
            case publishingHouse
        }
    @FocusState private var focusedField: Field?
    
    @State var titleHasChanged: Bool = false
    @State var newRecord: Bool = false
    
    //coming from the search results
    @State var selectedItem: String = ""
    
    //coming from NewAuthorView
    @State var authorLastName: String = ""
    @State var authorFirstName: String = ""
    @State var authorMiddleName:  String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                VStack {
                    //TODO: any changes required between add and edit?
                    VStack(alignment: .leading) {
                        Text("Title: ")
                            .foregroundStyle(Color.accentColor)
                            .font(.subheadline)
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
                    .focused($focusedField, equals: .selectedType)
                    .padding()
                    .textContentType(.none)
                    .submitLabel(.next)
                    .accessibilityLabel("Book Type Picker")
                    
                    VStack(alignment: .leading) {
                        Text("Title")
                            .foregroundStyle(Color.accentColor)
                            .font(.subheadline)
                        TextField ("New Title: ", text: $title)
                            .focused($focusedField, equals: .editionNumber)
                            .font(.subheadline)
                            .textContentType(.none)
                            .submitLabel(.next)
                            .lineLimit(2)
                            .accessibilityLabel("New Title")
                        
                        Divider()
                        
                        Text("Edition Number: ")
                            .foregroundStyle(Color.accentColor)
                            .font(.subheadline)
                        TextField("Edition Number: ", text: $editionNumber)
                            .focused($focusedField, equals: .editionNumber)
                            .font(.subheadline)
                            .textContentType(.none)
                            .submitLabel(.next)
                            .accessibilityLabel("Edition Number")
                        
                        Divider()
                        
                        Text("Genre: ")
                            .foregroundStyle(Color.accentColor)
                            .font(.subheadline)
                        TextField("Genre: ", text: $genre)
                            .focused($focusedField, equals: .genre)
                            .font(.subheadline)
                            .textContentType(.none)
                            .submitLabel(.next)
                            .accessibilityLabel("Genre")
                        
                        Divider()
                        
                        Text("ISBN: ")
                            .foregroundStyle(Color.accentColor)
                            .font(.subheadline)
                        TextField("ISBN: ", text: $ISBN)
                            .focused($focusedField, equals: .ISBN)
                            .font(.subheadline)
                            .textContentType(.none)
                            .submitLabel(.next)
                            .accessibilityLabel("ISBN")
                        
                        Divider()
                        
                        Text("Published Date: ")
                            .foregroundStyle(Color.accentColor)
                            .font(.subheadline)
                        TextField("Published date: ", text: $publishingDate)
                            .focused($focusedField, equals: .publishingDate)
                            .font(.subheadline)
                            .textContentType(.none)
                            .submitLabel(.next)
                            .accessibilityLabel("Published Date")
                        
                        Divider()
                        
                        Text("Publishing House: ")
                            .foregroundStyle(Color.accentColor)
                            .font(.subheadline)
                        TextField("Publisher: ", text: $publishingHouse)
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
                    case .publishingHouse:
#if DEBUG
                        let logger = appLogger()
                        logger.log(level: .info, message: "Case publishingHouse has been reached.")
#endif
                    default:
#if DEBUG
                        let logger = appLogger()
                        logger.log(level: .info, message: "Case default has been reached.")
#endif
                    }
                }
                
                HStack {
                    Button("Cancel Without Saving") { dismiss() }
                }
                .buttonStyle(CustomButtonStyle())
                
//TODO: Handle This code-if necessary
                if !newRecord {
                    if additionalAuthors.count > 0 {
                        HStack(alignment: .top, content: {
                            Text("All Authors: ")
                                .accessibilityLabel("All authors.")
                            VStack(alignment: .leading, content: {
                                ForEach(additionalAuthors, id: \.self) { coAuthor in
                                    Text("\(coAuthor)")
                                        .accessibilityValue("\(coAuthor)")
                                }
                            })
                            .font(.caption)
                        })
                    }
                }
//******************************************
                
            } //Form
            .onAppear(perform: LoadValues)
            .autocorrectionDisabled(true)
            .safeAreaPadding(20)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Menu("Additional Actions", systemImage: "text.justify") {
                    NavigationLink("Add a Co-Author",
                                   destination: AddCoAuthorView(titleIdString: titleIdString, titleName: title))
                    NavigationLink("Add a Narrator",
                                   destination: NarratorView(titleIdString: titleIdString, titleName: title))
               
                    }
                }
            ToolbarItem(placement: .bottomBar) {
                NavigationLink("Return to Main Screen") {
                    ContentView()
                }
                .buttonStyle(CustomButtonStyle())
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    SaveTitleDetails() //includes the title and titleauthor entries
                    hideKeyboard()
                }
                .buttonStyle(CustomButtonStyle())
            }
        }
    }
    
    func LoadValues() {
        
        if !newRecord {
            
            //this brings back title
            GetTitleById()
            authorIdString = GetAuthorId(filter: titleIdString)
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
}


