//
//  AuthorView.swift
//  LibraryCollection
//
//  Created by Elizabeth Rose on 2/1/24.
//

import SwiftUI

struct AuthorView: View {
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss

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
    @State var authorTitles: [String] = []
        
    var body: some View {
        NavigationStack {
            Form {
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
                    }
                }
                /*  We only want the user to add title details at one point
                 in the process, so only allow a connectionn to it from one place */
                if !addingCoAuthor {
                    NavigationLink {
                        TitleDetailsView(authorIdString: authorIdString,
                                         titleIdString: titleIdString,
                                         newRecord: true,
                                         authorLastName: authorLastName,
                                         authorFirstName: authorFirstName,
                                         authorMiddleName: authorMiddleName)
                        
                    } label: {
                        Text("Add a new Title for this Author")
                            .font(.subheadline)
                            .foregroundStyle(Color.accentColor)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .buttonStyle(CustomButtonStyle())
                    .padding(.top)
                    .padding(.bottom)
                    
                }
                
                if authorTitles.count > 0 {
                    AuthorsWorksView(authorTitles: authorTitles, authorIdString: authorIdString)
                        .frame(maxWidth: .infinity)
                        .font(.subheadline)
                        .foregroundColor(Color.accentColor)
                }
            }
            
            .onAppear {
                GetAllTitlesByAuthor(authorIdString: authorIdString)
                focusedField = .authorFirstName
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    PerformValidateAndSave()
                    saveIsComplete = true
                    hideKeyboard()
                    dismiss()
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
                message: Text("Last Name is required and must be longer than one character."),
                primaryButton: .default(Text("OK")) {
                    lastNameWarning = false
                    dismiss()
                },
                secondaryButton: .cancel()
            )
        }
        .safeAreaPadding(20)
    }
}
