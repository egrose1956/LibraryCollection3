//
//  AddNarratorView.swift
//  LibraryCollection
//
//  Created by Elizabeth Rose on 2/7/23.
//

import SwiftUI

struct AddNarratorView: View {
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\.narratorLastName)
        ]
    ) var narrators: FetchedResults<Narrator>
    
    @State var narrator: FetchedResults<Narrator>.Element?
    
    @State var titleIdString: String
    @State var titleName: String
    @State var narratorListForTitle: [String] = []
    
    @State var narratorIdString: String = ""
    @State var narratorFirstName: String = ""
    @State var narratorMiddleName: String = ""
    @State var narratorLastName: String = ""

    @State var newNarratorId: String = ""
    @State var newNarratorFirstName: String = ""
    @State var newNarratorMiddleName: String = ""
    @State var newNarratorLastName: String = ""
    
    @State var selectedNarrator: String = ""
        
    @State var nameFormatter = NameFormatter()
    @State var lastNameAlert: Bool = false
    @State var alreadyExists: Bool = false
    @State var labelText:String = ""
        
    enum FocusedField {
        case newNarratorFirstName
        case newNarratorMiddleName
        case newNarratorLastName
    }
    @FocusState private var focusedField: FocusedField?
    
    var body: some View {
        NavigationStack {
            Form {
                
                VStack(alignment: .leading) {
                    Text("All Existing Narrators")
                        .bold()
                        .accessibilityLabel("All Existing Narrators")
                    Text("You may select from these existing narrator(s) or \nadd a new one below.\nLast name must not be empty.")
                        .foregroundStyle(Color.accentColor)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                        .padding(5)
                        .accessibilityLabel("Select from existing narrators.")
                    List {
                        
                        ForEach(narrators, id: \.narratorId) { narrator in
                            Text(nameFormatter.ConcatenateNameFields(lastName: narrator.narratorLastName,
                                                                     firstName: narrator.wrappedNarratorFirstName,
                                                                     middleName: narrator.wrappedNarratorMiddleName))
                            .accessibilityLabel("\(narrator.narratorLastName), \(narrator.wrappedNarratorFirstName)")
                            .onTapGesture {
                                newNarratorLastName = narrator.narratorLastName
                                newNarratorFirstName = narrator.wrappedNarratorFirstName
                                newNarratorMiddleName = narrator.wrappedNarratorMiddleName
                            }
                        }
                    }
                }
                .font(.subheadline)
                
                VStack(alignment: .leading) {
                    
                    if !titleName.isEmpty {
                        Text("Narrator(s) for: \(titleName)")
                            .padding(5)
                            .foregroundStyle(Color.accentColor)
                            .accessibilityLabel("Narrators for \(titleName)")
                    }
                    
                    List {
                        ForEach(narratorListForTitle, id: \.self) { selectedItem in
                            Text("\(selectedItem)")
                                .onTapGesture {
                                    if !selectedItem.isEmpty {
                                        narratorLastName = ""
                                        narratorFirstName = ""
                                        narratorMiddleName = ""
                                        if selectedItem.contains(", ") {
                                            narratorLastName = selectedItem.components(separatedBy: ", ")[0]
                                            let firstAndMiddle = selectedItem.components(separatedBy: ", ")[1]
                                            if firstAndMiddle.components(separatedBy: " ").count > 1 {
                                                narratorFirstName = firstAndMiddle.components(separatedBy: " ")[0]
                                                narratorMiddleName = firstAndMiddle.components(separatedBy: " ")[1]
                                            } else {
                                                narratorFirstName = firstAndMiddle
                                            }
                                        } else {
                                            narratorLastName = selectedItem
                                        }
                                    }
                                }
                            
                        }
                    }
                }
                VStack(alignment: .leading) {
                    if !titleName.isEmpty {
                        Text("Add New Narrator for: \(titleName)")
                            .foregroundStyle(Color.accentColor)
                    } else {
                        Text("Adding...")
                            .accessibilityLabel("Ready to add new narrator.")
                    }
                    VStack(alignment: .leading) {
                        Text("First Name: ")
                            .foregroundStyle(Color.accentColor)
                            .font(.footnote)
                        TextField("Narrator First Name", text: $newNarratorFirstName)
                            .focused($focusedField, equals: .newNarratorFirstName)
                            .font(.subheadline)
                            .textContentType(.givenName)
                            .submitLabel(.next)
                            .accessibilityLabel("Enter Narrator First Name")
                    }
                    Divider()
                    VStack(alignment: .leading) {
                        Text("Middle Name: ")
                            .foregroundStyle(Color.accentColor)
                            .font(.footnote)
                        TextField("Narrator Middle Name", text: $newNarratorMiddleName)
                            .focused($focusedField, equals: .newNarratorMiddleName)
                            .font(.subheadline)
                            .textContentType(.middleName)
                            .submitLabel(.next)
                            .accessibilityLabel("Enter Narrator Middle Name")
                    }
                    Divider()
                    VStack(alignment: .leading) {
                        Text("Last Name: ")
                            .foregroundStyle(Color.accentColor)
                            .font(.footnote)
                        TextField("Narrator Last Name", text: $newNarratorLastName)
                            .focused($focusedField, equals: .newNarratorLastName)
                            .font(.subheadline)
                            .textContentType(.familyName)
                            .submitLabel(.done)
                            .accessibilityLabel("Enter Narrator Last Name")
                    }
                }
                .onSubmit {
                    switch focusedField {
                    case .newNarratorFirstName:
                        focusedField = .newNarratorMiddleName
                    case .newNarratorMiddleName:
                        focusedField = .newNarratorLastName
                    case .newNarratorLastName:
                        guard !newNarratorLastName.isEmpty else {
                            lastNameAlert = true
                            let logger = appLogger()
                            logger.log(level: .info, message: "Narrator Last Name must not be empty.")
                            return
                        }
                    default:
#if DEBUG
                        let logger = appLogger()
                        logger.log(level: .info, message: "Case default has been reached.")
#endif
                    }
                }
                .alert("Last name is missing or is too short. Must be more than one character.", isPresented: $lastNameAlert) {
                    Button("Ok") {}
//                        .dismiss
                }
                .accessibilityLabel("Last name is missing or is too short.")
                .alert("This narrator is already in our database.", isPresented: $alreadyExists) {
                    Button("Ok") {
                        narratorFirstName = ""
                        narratorMiddleName = ""
                        narratorLastName = ""
                        alreadyExists = false
                    }
                    .accessibilityLabel("Ok")
                }
                .toolbar {
                    NavigationLink("Edit Narrator", destination: EditNarrator(narratorLastName: newNarratorLastName,
                                                                              narratorFirstName: newNarratorFirstName,
                                                                              narratorMiddleName: newNarratorMiddleName,
                                                                              narratorIdString: narratorIdString))
                }
            } //form
            .onAppear {
                if !titleIdString.isEmpty {
                    if !titleName.isEmpty {
                        GetNarratorsForTitle(narratorIdString: narratorIdString, titleIdString: titleIdString)
                    } else {
#if DEBUG
                        let logger = appLogger()
                        logger.log(level: .error, message: "No titleId available.")
#endif
                    }
                }
                focusedField = .newNarratorFirstName
            }
            .keyboardType(.default)
            .autocorrectionDisabled(true)
            .safeAreaPadding(20)
            .onDisappear {
                if newNarratorLastName.isEmpty {
                    lastNameAlert = true
                }
                ValidateNarratorAndSave()
            }
        } //Nav Stack
    }
}

