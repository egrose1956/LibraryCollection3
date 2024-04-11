//
//  AddCoAuthorView.swift
//  LibraryCollection
//
//  Created by Elizabeth Rose on 4/16/23.
//

import SwiftUI

struct AddCoAuthorView: View {
    
    @Environment(\.managedObjectContext) var moc
    
    @State var titleIdString: String
    @State var titleName: String
    @State var authorFirstName:String = ""
    @State var authorMiddleName: String = ""
    @State var authorLastName: String = ""
    @State var authorIdString:String = ""
    @State var resultString: [String] = []
    
    enum Field {
        case authorFirstName
        case authorMiddleName
        case authorLastName
    }
    @FocusState private var focusedField: Field?
    
    @State var nameFormatter = NameFormatter()
    @State var lastNameAlert: Bool = false
    @State var coAuthorisShowingConfirmation: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                
                Text("Authors(s) for: \(titleName)")
                    .foregroundStyle(Color.accentColor)
                    .accessibilityLabel("Authors for: \(titleName)")
                    .padding(.leading)
                    .disabled(true)
                List {
                    ForEach(resultString, id: \.self) { selectedItem in
                        Text("\(selectedItem)")
                            .accessibilityLabel("\(selectedItem)")
                            .onTapGesture {
                                authorLastName = ""
                                authorFirstName = ""
                                authorMiddleName = ""
                                if !selectedItem.isEmpty {
                                    if selectedItem.contains(", ") {
                                        authorLastName = selectedItem.components(separatedBy: ", ")[0]
                                        let firstAndMiddle = selectedItem.components(separatedBy: ", ")[1]
                                        if firstAndMiddle.components(separatedBy: " ").count > 1 {
                                            authorFirstName = firstAndMiddle.components(separatedBy: " ")[0]
                                            authorMiddleName = firstAndMiddle.components(separatedBy: " ")[1]
                                        } else {
                                            authorFirstName = firstAndMiddle
                                        }
                                    } else {
                                        authorLastName = selectedItem
                                    }
                                }
                            }
                            .accessibilityValue("\(selectedItem)")
                    }
                }
                .font(.subheadline)
                .foregroundStyle(Color.accentColor)
                
                Text("Adding a Co-Author for \(titleName)")
                    .padding(5)
                    .foregroundStyle(Color.accentColor)
                    .accessibilityLabel("Ready to add")
                    .padding(.leading)
                    .disabled(true)
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
                                .focused($focusedField, equals: .authorLastName)
                                .font(.subheadline)
                                .textContentType(.familyName)
                                .submitLabel(.done)
                                .accessibilityLabel("Author Last Name")
                        
                    }
                }
                .onSubmit {
                    switch focusedField {
                    case .authorFirstName:
                        focusedField = .authorMiddleName
                    case .authorMiddleName:
                        focusedField = .authorLastName
                    case .authorLastName:
                        guard !authorLastName.isEmpty else {
                            lastNameAlert = true
#if DEBUG
                            let logger = appLogger()
                            logger.log(level: .info, message: "Author Last Name has been reached.")
#endif
                            return
                        }
                    default:
#if DEBUG
                        let logger = appLogger()
                        logger.log(level: .info, message: "Case default has been reached.")
#endif
                    }
                }
                .alert("Author's Last Name length may be missing or too short.", isPresented: $lastNameAlert) {
                    Button("Ok") {
                        lastNameAlert = true
                        return
                    }
                    .accessibilityLabel("Ok")
                }
                .accessibilityLabel("Last Name is missing or too short.")
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        PerformValidationAndSave()
                        hideKeyboard()
                    }
//                    NavigationLink("Edit Author", destination: EditAuthorView(authorIdString: authorIdString,
//                                                                              authorLastName: authorLastName,
//                                                                              authorFirstName: authorFirstName,
//                                                                              authorMiddleName: authorMiddleName))
                }
                ToolbarItem(placement: .bottomBar) {
                    NavigationLink("Return to Main Screen") {
                        ContentView(returning: true)
                    }
                    .buttonStyle(CustomButtonStyle())
                }
            }
            .onAppear {
                focusedField = .authorFirstName
                GetAllAuthorsByTitleId()
                moc.refreshAllObjects()
            }
            .safeAreaPadding(20)
        } //NavStack
        .navigationBarTitleDisplayMode(.inline)
        .keyboardType(.default)
        .autocorrectionDisabled(true)
        .safeAreaPadding(20)
    }
}

