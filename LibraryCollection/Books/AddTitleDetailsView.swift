//
//  AddTitleDetailsView.swift
//  LibraryCollection
//
//  Created by Elizabeth Rose on 4/23/23.
//

import SwiftUI

struct AddTitleDetailsView: View {
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    @State var selectedTitle: String = ""
    @State var authorIdString: String = ""

    @State var titleIdString: String = ""
    @State var titleDetails: [TitleDetails] = []
    @State var titleDetailsId: String = ""
    @State var resultString: [String] = []
    @State var nameFormatter = NameFormatter()
    @State var title: String = ""
    
    @State var bookTypes = ["Hardback", "Paperback", "Audio", "Ebook", "Other"]
    @State var selectedType = ""
    @State var editionNumber = ""
    @State var genre = ""
    @State var ISBN = ""
    @State var publishingDate = ""
    @State var publishingHouse = ""
    @State var additionalAuthors: [String] = []
    
    @State var authorName = ""
    @State var selectedItem: String = ""
    @State var displayString: String = ""
    @State var comingFromSearch: Bool = false
    @State var searchType: String = "" //author or title - to correctly parse the selectedItem string
    @State var authorFirstName: String = ""
    @State var authorMiddleName: String = ""
    @State var authorLastName: String = ""

    @State var detailsHaveBeenSaved: Bool = false
    @State var showCoAuthorEntry: Bool = false
    @State var showNarratorEntry: Bool = false

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
                            .font(.footnote)
                        TextField ("New Title: ", text: $title)
                            .focused($focusedField, equals: .editionNumber)
                            .font(.subheadline)
                            .textContentType(.none)
                            .submitLabel(.next)
                            .lineLimit(2)
                            .accessibilityLabel("New Title")
                    }
                    Divider()
                    VStack(alignment: .leading) {
                        Text("Edition Number: ")
                            .foregroundStyle(Color.accentColor)
                            .font(.footnote)
                        TextField("Edition Number: ", text: $editionNumber)
                            .focused($focusedField, equals: .editionNumber)
                            .font(.subheadline)
                            .textContentType(.none)
                            .submitLabel(.next)
                            .accessibilityLabel("Edition Number")
                    }
                    Divider()
                    VStack(alignment: .leading) {
                        Text("Genre: ")
                            .foregroundStyle(Color.accentColor)
                            .font(.footnote)
                        TextField("Genre: ", text: $genre)
                            .focused($focusedField, equals: .genre)
                            .font(.subheadline)
                            .textContentType(.none)
                            .submitLabel(.next)
                            .accessibilityLabel("Genre")
                    }
                    Divider()
                    VStack(alignment: .leading) {
                        Text("ISBN: ")
                            .foregroundStyle(Color.accentColor)
                            .font(.footnote)
                        TextField("ISBN: ", text: $ISBN)
                            .focused($focusedField, equals: .ISBN)
                            .font(.subheadline)
                            .textContentType(.none)
                            .submitLabel(.next)
                            .accessibilityLabel("ISBN")
                    }
                    Divider()
                    VStack(alignment: .leading) {
                        Text("Published Date: ")
                            .foregroundStyle(Color.accentColor)
                            .font(.footnote)
                        TextField("Published date: ", text: $publishingDate)
                            .focused($focusedField, equals: .publishingDate)
                            .font(.subheadline)
                            .textContentType(.none)
                            .submitLabel(.next)
                            .accessibilityLabel("Published Date")
                    }
                    Divider()
                    VStack(alignment: .leading) {
                        Text("Publishing House: ")
                            .foregroundStyle(Color.accentColor)
                            .font(.footnote)
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
                    
                    Button("Save") {
                        if !detailsHaveBeenSaved {
                            SaveTitleDetails() //includes the title and titleauthor entries
                            detailsHaveBeenSaved = true
                            dismiss()
                        }
                    }
                }
                .buttonStyle(CustomButtonStyle())
                
                if showNarratorEntry {
                    NavigationLink {
                        AddNarratorView(titleIdString: titleIdString, titleName: title)
                    } label: {
                        Text("Narrator's entry")
                            .accessibilityLabel("Moving to narrator entry screen.")
                    }
                }
                
                if showCoAuthorEntry {
                    NavigationLink {
                        AddCoAuthorView(titleIdString: titleIdString, titleName: title)
                    } label: {
                        Text("Add additional Co-Authors here.")
                        .accessibilityLabel("Moving to co-Author entry screen.")
                    }
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
                
            } //Form
            .onAppear(perform: LoadValues)
            .autocorrectionDisabled(true)
            .safeAreaPadding(20)
        }
    }
}

