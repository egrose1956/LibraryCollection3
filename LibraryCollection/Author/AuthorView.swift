//
//  AuthorView.swift
//  LibraryCollection
//
//  Created by Elizabeth Rose on 2/1/24.
//

import SwiftUI

struct AuthorView: View {
    
    @Environment(\.managedObjectContext) var moc

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
    
    @State var addingCoAuthor: Bool = false
        
    var body: some View {
        NavigationStack {
            Form {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text("First Name: ")
                            .foregroundStyle(Color.accentColor)
                            .font(.subheadline)
                        TextField("Author First Name", text: $authorFirstName)
                            .focused($focusedField, equals: .authorFirstName)
                            .font(.subheadline)
                            .textContentType(.givenName)
                            .submitLabel(.next)
                            .accessibilityLabel("Author First Name")
                    
                    Divider()
                    
                        Text("Middle Name: ")
                            .foregroundStyle(Color.accentColor)
                            .font(.subheadline)
                        TextField("Author Middle Name", text: $authorMiddleName)
                            .focused($focusedField, equals: .authorMiddleName)
                            .font(.subheadline)
                            .textContentType(.middleName)
                            .submitLabel(.next)
                            .accessibilityLabel("Author Middle Name")
                    
                    Divider()
                    
                        Text("Last Name: ")
                            .foregroundStyle(Color.accentColor)
                            .font(.subheadline)
                        TextField("Author Last Name", text: $authorLastName)
                            .font(.subheadline)
                            .focused($focusedField, equals: .authorLastName)
                            .textContentType(.familyName)
                            .submitLabel(.next)
                            .accessibilityLabel("Author Last Name")
                    }
                    
                    NavigationLink {

                        TitleDetailsView(authorIdString: authorIdString,
                                         newRecord: true,
                                         authorLastName: authorLastName,
                                         authorFirstName: authorFirstName,
                                         authorMiddleName: authorMiddleName)
                        
                    } label: {
                        Text("Add a new Title for this Author")
                            .font(.title2)
                            .foregroundStyle(Color.accentColor)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .buttonStyle(CustomButtonStyle())
                    .padding(.top)
                    .padding(.bottom)
                    
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
                    VStack(alignment: .center) {
                        AuthorsWorksView(authorIdString: authorIdString)
                    }
                    .frame(maxWidth: .infinity)
                    .font(.subheadline)
                    .foregroundColor(Color.accentColor)
                    
                    
                    }
                }
            } //Form
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        PerformValidateAndSave()
                        saveIsComplete = true

                        hideKeyboard()
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    NavigationLink("Return to Main Screen") {
                        ContentView(returning: true)
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
        if saveIsComplete && !addingCoAuthor {
            NavigationLink {
                TitleDetailsView(authorIdString: authorIdString,
                                newRecord: true,
                                authorLastName: authorLastName,
                                authorFirstName: authorFirstName,
                                authorMiddleName: authorMiddleName)
            } label: {
                Text("Add New Title")
                    .font(.title2)
                    .foregroundStyle(Color.accentColor)
            }
            .padding(.top)
            .onAppear {
                focusedField = .authorFirstName
            }
            .safeAreaPadding(20)
       } //navStack
    } //body
}
