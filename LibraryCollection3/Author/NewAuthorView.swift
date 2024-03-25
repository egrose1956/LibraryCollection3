//
//  NewAuthorView.swift
//  LibraryCollection3
//
//  Created by Elizabeth Rose on 2/1/24.
//

import SwiftUI

struct NewAuthorView: View {
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    @State var author: FetchedResults<Author>.Element?
    @State var filteredTitles: [String] = []
        
    @State var authorLastName: String = ""
    @State var authorFirstName: String = ""
    @State var authorMiddleName:  String = ""
    @State var authorIdString: String = ""
    
    @State var inputTitle = ""
    @State var titleIdString = ""
    @State var existingTitleIdString = ""
    @State var existingAuthorLastName: String = ""
    @State var existingAuthorFirstName: String = ""
    
    @State var lastNameWarning: Bool = false
    @State var saveIsComplete: Bool = false
    
    enum Field {
        case authorFirstName
        case authorMiddleName
        case authorLastName
    }
    @FocusState private var focusedField: Field?
    
    var body: some View {
        NavigationStack {
            Form {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text("First Name: ")
                            .foregroundStyle(Color.accentColor)
                            .font(.footnote)
                        TextField("Author First Name", text: $authorFirstName)
                            .focused($focusedField, equals: .authorFirstName)
                            .font(.subheadline)
                            .textContentType(.givenName)
                            .submitLabel(.next)
                            .accessibilityLabel("Author First Name")
                    }
                    Divider()
                    VStack(alignment: .leading) {
                        Text("Middle Name: ")
                            .foregroundStyle(Color.accentColor)
                            .font(.footnote)
                        TextField("Author Middle Name", text: $authorMiddleName)
                            .focused($focusedField, equals: .authorMiddleName)
                            .font(.subheadline)
                            .textContentType(.middleName)
                            .submitLabel(.next)
                            .accessibilityLabel("Author Middle Name")
                    }
                    Divider()
                    VStack(alignment: .leading) {
                        Text("Last Name: ")
                            .foregroundStyle(Color.accentColor)
                            .font(.footnote)
                        TextField("Author Last Name", text: $authorLastName)
                            .font(.subheadline)
                            .focused($focusedField, equals: .authorLastName)
                            .textContentType(.familyName)
                            .submitLabel(.next)
                            .accessibilityLabel("Author Last Name")
                    }
                    .onSubmit {
                        switch focusedField {
                        case .authorFirstName:
                            focusedField = .authorMiddleName
                        case .authorMiddleName:
                            focusedField = .authorLastName
                        case .authorLastName:
                            if authorLastName.count < 2 {
                                lastNameWarning = true
                            }
                        default:
#if DEBUG
                            let logger = appLogger()
                            logger.log(level: .info, message: "Case default has been reached.")
#endif
                        } // switch
                    }
                    if saveIsComplete {
                        NavigationLink {
                            AddTitleDetailsView(authorIdString: authorIdString,
                                                authorFirstName: authorFirstName,
                                                authorMiddleName: authorMiddleName,
                                                authorLastName: authorLastName)
                        } label: {
                            Text("Add New Title")
                                .font(.title2)
                                .foregroundStyle(Color.accentColor)
                        }
                        .padding(.top)
                    }
                }
            } //Form
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(CustomButtonStyle())
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        PerformValidationAndSave()
                        saveIsComplete = true
                    }
                    .buttonStyle(CustomButtonStyle())
                }
            }
            .alert(isPresented: $lastNameWarning) {
                Alert(
                    title: Text("Last Name Validation"),
                    message: Text("Last Name is empty or very short. Should we proceed to Save?"),
                    primaryButton: .default(Text("Yes")) {
                        lastNameWarning = false
                    },
                    secondaryButton: .cancel()
                )
            } // Alert
            .onAppear {
                focusedField = .authorFirstName
            }
        } //navStack
        .safeAreaPadding(20)
    } //body
}
