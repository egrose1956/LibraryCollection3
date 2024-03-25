//
//  EditAuthorView.swift
//  LibraryCollection3
//
//  Created by Elizabeth Rose on 1/24/24.
//

import CoreData
import SwiftUI

struct EditAuthorView: View {
    
    @Environment(\.managedObjectContext) var moc
    
    @State var selectedTitle: String = ""
    @State var authorIdString: String = ""
    @State var authorLastName: String = ""
    @State var authorFirstName: String = ""
    @State var authorMiddleName: String = ""
    
    @State private var lastNameWarning: Bool = false
    @State var showTitleDetails: Bool = false
    
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
                    Text("First Name: ")
                        .foregroundStyle(Color.accentColor)
                        .font(.footnote)
                    TextField("Author First Name", text: $authorFirstName)
                        .font(.subheadline)
                        .focused($focusedField, equals: .authorFirstName)
                        .textContentType(.givenName)
                        .submitLabel(.next)
                        .accessibilityLabel("Author First Name")
                    
                    Divider()
                    
                    Text("Middle Name: ")
                        .foregroundStyle(Color.accentColor)
                        .font(.footnote)
                    TextField("Author Middle Name", text: $authorMiddleName)
                        .font(.subheadline)
                        .focused($focusedField, equals: .authorMiddleName)
                        .textContentType(.middleName)
                        .submitLabel(.next)
                        .accessibilityLabel("Author Middle Name")
                    
                    Divider()
                    
                    Text("Last Name: ")
                        .foregroundStyle(Color.accentColor)
                        .font(.footnote)
                    TextField("Author Last Name", text: $authorLastName)
                        .font(.subheadline)
                        .focused($focusedField, equals: .authorLastName)
                        .textContentType(.familyName)
                        .submitLabel(.next)
                        .accessibilityLabel("Author Last Name")
                } //VStack
                
                NavigationLink {

                    AddTitleDetailsView(authorIdString: authorIdString)
                    
                } label: {
                    Text("Add a new Title for this Author")
                        .font(.title2)
                        .foregroundStyle(Color.accentColor)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .buttonStyle(CustomButtonStyle())
                .padding(.top)
                .padding(.bottom)
                
                VStack(alignment: .center) {
                    AuthorsWorksView(authorIdString: authorIdString)
                }
                
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
            .alert(isPresented: $lastNameWarning) {
                Alert(
                    title: Text("Last Name is empty or very short. Should we proceed to Save?"),
                    primaryButton: .default(Text("Yes")) {
                        lastNameWarning = false
                    },
                    secondaryButton: .cancel()
                )
            }
        } //Navigation Stack
        .sheet(isPresented: $showTitleDetails) {
            AddTitleDetailsView(selectedTitle: selectedTitle,
                                authorIdString: authorIdString,
                                authorFirstName: authorFirstName,
                                authorMiddleName: authorMiddleName,
                                authorLastName: authorLastName)
        }
        .onAppear {
            authorIdString = authorIdString
            moc.refreshAllObjects()
        }
        .safeAreaPadding(20)
        .onDisappear {
            UpdateAuthor()
        }
        .navigationBarTitleDisplayMode(.inline)
        .font(.title2)
    } //Body
    
    func UpdateAuthor() {
        let resultString = SaveAuthorEdit()
        if resultString == "Edit Process Failed" {
            //Do something??
        }
    }
}


