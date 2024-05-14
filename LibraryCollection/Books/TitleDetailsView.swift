//
//  TitleDetailsView.swift
//  LibraryCollection
//
//  Created by Elizabeth Rose on 4/9/24.
//

import SwiftUI
import CoreData

struct TitleDetailsView: View {
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    @State var authorIdString: String
    @State var titleIdString: String = ""
    @State var title: String = ""
    @State var titleDetails: [TitleDetails] = []
    @State var titleDetailsId: String = ""
    @State var narratorListForTitle: [String] = []
    
    //holds the loaded data to compare to the current
    //data at save time to identify any changes
    @State var beginningTitle: String = ""
    @State var beginningSelectedType: String = ""
    @State var beginningEditionNumber: String = ""
    @State var beginningGenre: String = ""
    @State var beginningISBN: String = ""
    @State var beginningPublishingDate: String = ""
    @State var beginningPublishingHouse: String = ""
    @State var formHasChanges: Bool = false
    
    //to populate the picker
    @State var bookTypes = ["Hardback", "Paperback", "Audio", "Ebook"]
    
    //to hold bound data
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
    
    //coming from NarratorsWorksView
    @State var narratorIdString: String = ""
    
    @State var saveComplete: Bool = false
    @State var unsavedWarning: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                VStack(alignment: .leading) {
                    //TODO: any changes required between add and edit?
                    if !newRecord {
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
                    } else {
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
                    }
                    Divider()
                    
                    Picker("Select book type", selection: $selectedType) {
                        ForEach(bookTypes, id: \.self) { type in
                            Text(type)
                                .accessibilityLabel("\(type)")
                        }
                    }
                    .pickerStyle(.segmented)
                    .focused($focusedField, equals: .selectedType)
                    .textContentType(.none)
                    .submitLabel(.next)
                    .accessibilityLabel("Book Type Picker")
                    
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
                
                if selectedType == "Audio" {
                    if narratorListForTitle.count > 0 {
                        HStack(alignment: .top, content: {
                            Text("All Narrators: ")
                                .accessibilityLabel("All narrators.")
                            VStack(alignment: .leading, content: {
                                ForEach(narratorListForTitle, id: \.self) { narrator in
                                    Text("\(narrator)")
                                        .accessibilityValue("\(narrator)")
                                }
                            })
                            .font(.caption)
                        })
                    }
                }
            }
            .onAppear(perform: LoadValues)
            .autocorrectionDisabled(true)
            .toolbar(id: "return") {
                ToolbarItem(id: "home", placement: .bottomBar) {
                    NavigationLink("Return to Main Screen") {
                        ContentView(returning: true)
                    }
                    .buttonStyle(CustomButtonStyle())
                }
            }
            .toolbar(id: "mainSave") {
                ToolbarItem(id: "save", placement: .topBarTrailing) {
                    Button("Save") {
                        SaveProcess()
                        hideKeyboard()
                    }
                }
            }
            .toolbar(id: "more") {
                ToolbarItem(id: "additional", placement: .secondaryAction) {
                    Menu("Additional Actions", systemImage: "text.justify") {
                        NavigationLink("Add a Co-Author") {
                            AuthorView(inputTitle: title, titleIdString: titleIdString, addingCoAuthor: true)
                        }
                        if selectedType == "Audio" {
                            if !titleIdString.isEmpty {
                                NavigationLink("Add a Narrator") {
                                    NarratorView(titleIdString: titleIdString, titleName: title)
                                }
                                .onTapGesture {
                                    SaveProcess()
                                }
                            }
                        }
                    }
                }
            }
            .toolbarRole(.automatic)
        } //nav stack
        .alert(isPresented: $unsavedWarning) {
            Alert(
                title: Text("Save Warning"),
                message: Text("Any changes made to this title's details have not been saved. Save now?"),
                primaryButton: .default(Text("OK")) {
                    SaveProcess()
                    hideKeyboard()
                },
                secondaryButton: .cancel()
            )
            
        }
        .safeAreaPadding()
    }
    
    func SaveProcess() {
        CheckForFormChanges ()
        if formHasChanges {
            let returnValue = SaveTitle()
            if returnValue == true {
                try? SaveTitleDetails()
                saveComplete = true
                formHasChanges = false
                ResetValues()
            }
        }
    }
    
    func CheckForFormChanges() {
        if title != beginningTitle
            || selectedType != beginningSelectedType
            || editionNumber != beginningEditionNumber
            || genre != beginningGenre
            || ISBN != beginningISBN
            || publishingDate != beginningPublishingDate
            || publishingHouse != beginningPublishingHouse {
            
            formHasChanges = true
        }
    }
    
    func LoadValues() {
        
        if !newRecord {
            //this brings back title
            GetTitleById()
            beginningTitle = title
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
                if selectedType == "Audio" {
                    GetAllNarratorsForTitle()
                }
            }
        } else {
            beginningTitle = ""
            beginningSelectedType = ""
            beginningEditionNumber = ""
            beginningGenre = ""
            beginningISBN = ""
            beginningPublishingDate = ""
            beginningPublishingHouse = ""
        }
    }
            
    func ResetValues() {
        beginningTitle = title
        beginningSelectedType = selectedType
        beginningEditionNumber = editionNumber
        beginningGenre = genre
        beginningISBN = ISBN
        beginningPublishingDate = publishingDate
        beginningPublishingHouse = publishingHouse
    }
}


