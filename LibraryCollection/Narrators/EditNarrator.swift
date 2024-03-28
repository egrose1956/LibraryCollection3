//
//  EditNarrator.swift
//  LibraryCollection
//
//  Created by Elizabeth Rose on 3/30/23.
//

import SwiftUI

struct EditNarrator: View {
    
    @Environment(\.managedObjectContext) var moc
    
    @State var narrator: FetchedResults<Narrator>.Element?
    
    @State var titleIdString: String = ""
    @State var narratorLastName: String = ""
    @State var narratorFirstName: String = ""
    @State var narratorMiddleName: String = ""
    @State var narratorIdString: String = ""
    @State var foundNarratorLastName: String = "" //for edit search for duplicates
    @State var foundNarratorFirstName: String = "" //for edit search for duplicates
    
    enum Field {
        case narratorFirstName
        case narratorMiddleName
        case narratorLastName
    }
    @FocusState private var focusedField: Field?
    
    @State private var lastNameAlert: Bool = false
    @State var editResultsInDuplicateRecord: Bool = false
    @State var editProcessResults: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                VStack {
                    HStack {
                        Text("First Name: ")
                            .foregroundStyle(Color.accentColor)
                        TextField("Narrator First Name", text: $narratorFirstName)
                            .focused($focusedField, equals: .narratorFirstName)
                            .textContentType(.givenName)
                            .submitLabel(.next)
                            .accessibilityLabel("Narrator First Name")
                    }
                    HStack {
                        Text("Middle Name: ")
                            .foregroundColor(Color.accentColor)
                        TextField("Narrator Middle Name", text: $narratorMiddleName)
                            .focused($focusedField, equals: .narratorMiddleName)
                            .textContentType(.middleName)
                            .submitLabel(.next)
                            .accessibilityLabel("Narrator Middle Name")
                    }
                    HStack {
                        Text("Last Name: ")
                        TextField("Narrator Last Name", text: $narratorLastName)
                            .focused($focusedField, equals: .narratorLastName)
                            .textContentType(.familyName)
                            .submitLabel(.done)
                            .accessibilityLabel("Narrator Last Name")
                    }
                }
                .onSubmit {
                    switch focusedField {
                    case .narratorFirstName:
                        focusedField = .narratorMiddleName
                    case .narratorMiddleName:
                        focusedField = .narratorLastName
                    case .narratorLastName:
                        if narratorLastName.isEmpty || narratorLastName.count < 2 {
                            lastNameAlert = true
                        }
                    default:
                        #if DEBUG
                            let logger = appLogger()
                            logger.log(level: .info, message: "Case default has been reached.")
                        #endif
                    }
                }
                .alert("Narrator's Last Name may be missing or too short.", isPresented: $lastNameAlert) {
                    Button("Ok") {}
                    .accessibilityLabel("Ok")
                }
                .accessibilityLabel("Last Name is too short.")
                .alert("This edit has resulted in a possible duplication. Nothing saved.", isPresented: $editResultsInDuplicateRecord) {
                    Button("Ok") {}
                        .accessibilityLabel("Ok")
                }
                .accessibilityLabel("This edit resulted in a possible duplication. Nothing saved.")
            }
        }
        .onAppear {
            titleIdString = titleIdString
            focusedField = .narratorFirstName
            FormatInput()
        }
        .keyboardType(.default)
        .autocorrectionDisabled(true)
        .safeAreaPadding(20)
        .onDisappear {
            PerformEditValidationAndSave()
        }
    }
        
    func FormatInput() {
        
        let myNarrator: FetchedResults<Narrator>.Element? = narrator
        guard myNarrator != nil else { return }
                
        narratorFirstName = narrator!.narratorFirstName ?? ""
        narratorMiddleName = narrator!.narratorMiddleName ?? ""
        narratorLastName = narrator!.narratorLastName
        narratorIdString = narrator!.narratorId.uuidString
    }
    
    func PerformEditValidationAndSave() {
        
        if narratorFirstName.isEmpty && narratorMiddleName.isEmpty && narratorLastName.isEmpty {
            //go back if there isn't any author name entered
            return
        }
            
        if narratorLastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || narratorLastName.count < 2 {
            lastNameAlert = true
            return
        }
        
        editProcessResults = SaveNarratorEdit()
    }
}
