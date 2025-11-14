//
//  ProfileView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/31/25.

import SwiftUI

struct ProfileView: View {
    // Passed-in Values
    var userID: Int64
    @Binding var bg: String
    @Binding var accent: String
    
    @EnvironmentObject var userSession: UserSession
    @EnvironmentObject var tutorialManager: TutorialManager
    
    //  UI State
    @State private var isEditing = false
    @State private var logOut = false
    @State private var showLogView = false
    @State private var showDelete = false
    
    //  User Data
    @State private var symps: [String] = []
    @State private var triggs: [String] = []
    @State private var prevMeds: [String] = []
    @State private var emergMeds: [String] = []
    @State private var sQ = ""
    @State private var sA = ""
    @State private var themeName = ""
    
    //  Editable Values
    @State private var newSQ = ""
    @State private var newSA = ""
    @State private var newTN = ""
    @State private var newBG = ""
    @State private var newAcc = ""
    
    //  Constants
    private let themeOptions = ["Classic Light", "Light Pink", "Light Yellow", "Classic Dark",  "Dark Green", "Dark Blue", "Dark Purple", "Custom"]
    private let buttonNames = ["Edit Profile", "App Tutorial", "Sign Out", "Delete Account"]
    private let screenWidth = UIScreen.main.bounds.width
    private let screenHeight = UIScreen.main.bounds.height
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                ProfileBGComps(bg: newBG, accent: newAcc)
                
                // Content
                ScrollView {
                    VStack{
                        if isEditing {
                            editingView()
                        } else {
                            viewingView()
                        }
                    }
                }
                .ignoresSafeArea(edges: .bottom)
                
                if tutorialManager.showTutorial {
                    ProfileTutorialPopup(bg: bg,  accent: accent, userID: userID, onClose: { tutorialManager.endTutorial() }  )

                    .zIndex(100)
                }
                
                // Bottom Nav Bar
                VStack {
                    Spacer()
                    NavBarView(userID: userID, bg: $newBG, accent: $newAcc, selected: .constant(3))
                }
                .ignoresSafeArea(edges: .bottom)
                .zIndex(1)
            }
            //delete confirmation
            .alert("Are you sure you want to delete your account?", isPresented: $showDelete) {
                Button("Delete", role: .destructive) {
                    Task {
                        await Database.shared.deleteUser(userID: userID)
                        userSession.logout()
                        logOut = true
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            //go to login if cancel account
            .fullScreenCover(isPresented: $logOut) {
                InitialView()
            }
            //get data on load
            .task {
                if let data = await Database.shared.loadData(userID: userID) {
                    symps = data.symps
                    triggs = data.triggs
                    prevMeds = data.prevMeds
                    emergMeds = data.emergMeds
                    sQ = data.SQ
                    sA = data.SA
                    newSQ = data.SQ
                    bg = data.bg
                    accent = data.accent
                    newBG = data.bg
                    newAcc = data.accent
                    themeName = data.theme
                    newTN = data.theme.contains("Custom") ? "Custom" : data.theme
                }
            }
        }
    }
    
    // Editing View
    @ViewBuilder
    private func editingView() -> some View {
        let colWidth = screenWidth / 2
        
        CustomText(text: "User Profile", color: newAcc, textAlign: .center, textSize: 45)
            .padding(.top, 30)
            .padding(.bottom, 10)
        
        HStack(alignment: .top) {
            VStack(alignment: .center) {
                //symptom editable list
                sectionTitle("Symptoms", width: colWidth)
                EditableList(items: $symps,  title: "Symptoms", bg: newBG, accent: newAcc,
                     onAdd: { newSymptom in
                    Task {
                        await Database.shared.insertItem(tableName: "Symptoms", userID: userID, name: newSymptom.capitalized)
                    }
                },
                             
                    onEdit: { oldValue, newValue in
                    Task {
                        await Database.shared.updateItem(tableName: "Symptoms", userID: userID, old: oldValue, new: newValue.capitalized)
                    }
                },
                     
                     onDelete: { (value,nil) in
                    Task {
                        await Database.shared.endItem(tableName: "Symptoms", userID: userID, name: value)
                    }
                })
                
                //prev meds editable list
                sectionTitle("Preventative Medications", width: colWidth)
                EditableList(items: $prevMeds, title: "Preventative Medications", bg: newBG, accent: newAcc, requiresReason: true,
                     onAdd: { newPrevMed in
                    Task {
                        await Database.shared.insertItem(tableName: "Medications", userID: userID, name: newPrevMed.capitalized, medCat: "preventative")
                    }
                },
                             
                    onEdit: { oldValue, newValue in
                    Task {
                        await Database.shared.updateItem(tableName: "Medications", userID: userID, old: oldValue, new: newValue.capitalized, medCat: "preventative")
                    }
                },
                             
                    onDelete: { (value, reason) in
                    Task {
                        await Database.shared.endItem(tableName: "Medications", userID: userID, name: value, medCat: "preventative", endReason: reason)
                    }
                })
                
                //non-editable list fields
                sectionTitle("Security Question", width: colWidth)
                CustomTextField(bg: newBG, accent: newAcc, placeholder: "",  text: $newSQ,  width: colWidth - 15, height: 50, corner: 8, textSize: 20,  multiline: true)
                
                sectionTitle("Color Theme", width: colWidth)
                ThemeDropdown(theme: $newTN, bg: $newBG, accent: $newAcc, options: themeOptions, width: colWidth - 15, height: 50,  corner: 8, fontSize: 20)
                
                //conditionally show hex code text boxes
                if newTN == "Custom" {
                    sectionTitle("Hex Codes", width: colWidth)
                    ColorTextField(accent: newAcc, bg: newBG, update: $newBG, placeholder: "Enter HEX color", width: colWidth-10)
                    .padding(.vertical, 15)

                    ColorTextField(accent: newAcc, bg: newBG, update: $newAcc, placeholder: "Enter HEX color", width: colWidth - 10)
                }
            }
            .frame(maxWidth: colWidth)
            .padding(.leading, 10)
            
            //second column
            VStack {
                //triggers editable list
                sectionTitle("Triggers", width: colWidth)
                EditableList(items: $triggs, title: "Triggers", bg: newBG, accent: newAcc,
                     onAdd: { newTrigger in
                    Task {
                        await Database.shared.insertItem(tableName: "Triggers", userID: userID, name: newTrigger.capitalized)
                    }
                },
                             
                     onEdit: { oldValue, newValue in
                    Task {
                        await Database.shared.updateItem(tableName: "Triggers", userID: userID, old: oldValue, new: newValue.capitalized)
                    }
                },
                     
                     onDelete: { (value, nil) in
                    Task {
                        await Database.shared.endItem(tableName: "Triggers", userID: userID, name: value)
                    }
                })
                
                //emerg meds editable list
                sectionTitle("Emergency Medications", width: colWidth)
                EditableList( items: $emergMeds, title: "Emergency Medications", bg: newBG, accent: newAcc, requiresReason: true,
                      onAdd: { newEmergencyMed in
                    Task {
                        await Database.shared.insertItem(tableName: "Medications", userID: userID, name: newEmergencyMed.capitalized, medCat: "emergency")
                    }
                },
                              
                    onEdit: { oldValue, newValue in
                    Task {
                        await Database.shared.updateItem(tableName: "Medications", userID: userID, old: oldValue, new: newValue.capitalized, medCat: "emergency")
                    }
                },
                              
                    onDelete: { (value, reason) in
                    Task {
                        await Database.shared.endItem(tableName: "Medications", userID: userID, name: value, medCat: "emergency", endReason: reason)
                    }
                })
                
                //non-edtiable list text field
                sectionTitle("Security Answer", width: colWidth)
                CustomTextField(bg: newBG, accent: newAcc, placeholder: "", text: $newSA, width: colWidth - 15, height: 50, corner: 8, textSize: 16)
                
                //push the changes to the database
                CustomButton( text: "Save", bg: newBG, accent: newAcc, height: 50, width: colWidth - 25, corner: 36,  bold: true, textSize: 25, action: saveProfileChanges )
                .padding(.top, 10)
            }
            .padding(.trailing, 10)
        }
        .frame(width: screenWidth)
        .padding(.bottom, 120)
    }
    
    //  Viewing View
    @ViewBuilder
    private func viewingView() -> some View {
        let colWidth = screenWidth / 2
        
        CustomText(text: "User Profile", color: newAcc, textAlign: .center, textSize: 45)
            .padding(.vertical, 50)
        
        HStack(alignment: .top) {
            //column one
            VStack {
                //display the data in a non-editable list
                section(colTitle: "Symptoms", items: symps, width: colWidth)
                section(colTitle: "Preventative Meds", items: prevMeds, width: colWidth)
                section(colTitle: "Security Question", items: [newSQ], width: colWidth)
            }
            .frame(maxWidth: colWidth)
            
            //column two
            VStack {
                //display the data in a non-editable list
                section(colTitle: "Triggers", items: triggs, width: colWidth)
                section(colTitle: "Emergency Meds", items: emergMeds, width: colWidth)
                section(colTitle: "Color Theme", items: [themeName], width: colWidth)
                
                //options button
                HStack {
                    Spacer()
                    let buttonActions: [() -> Void] = [ { isEditing = true },  { tutorialManager.startTutorial()
                    showLogView = true},  {userSession.logout()
                        logOut = true },  { showDelete = true } ]
                    
                    FloatButton( accent: newAcc,  bg: newBG,  options: buttonNames, actions: buttonActions)
                        .padding(.top, 20)
                    
                    NavigationLink(
                        destination: LogView(userID: userID, bg: $bg, accent: $accent)
                            .environmentObject(tutorialManager),
                        isActive: $showLogView
                    ) {
                        EmptyView()
                    }

                }
                .padding(.trailing, 10)
            }
            .frame(maxWidth: colWidth)
        }
    }
    
    //Break repetive code into reusable sections
    private func sectionTitle(_ title: String, width: CGFloat) -> some View {
        CustomText(text: title, color: newAcc, width: width - 15, textAlign: .center, multiAlign: .center, bold: true)
    }
    
    private func section(colTitle: String, items: [String], width: CGFloat) -> some View {
            VStack {
                sectionTitle(colTitle, width: width)
                CustomList(items: items, color: newAcc)
            }
    }
    
    
    
    private func saveProfileChanges() {
        Task {
            if sQ != newSQ {
                await Database.shared.updateUser(userID: userID, value: newSQ.capitalized, col: "security_question")
            }
            
            let normSA = Database.normalize(newSA)
            if normSA != sA {
                await Database.shared.updateUser(userID: userID, value: normSA.capitalized, col: "security_answer")
            }
            
            if bg != newBG {
                await Database.shared.updateUser(userID: userID, value: newBG, col: "background_color")
                bg = newBG
                themeName = Database.getThemeName(background: newBG, accent: newAcc)
                newTN = themeName.contains("Custom") ? "Custom" : themeName
            }
            
            if accent != newAcc {
                await Database.shared.updateUser(userID: userID, value: newAcc, col: "accent_color")
                accent = newAcc
            }
            isEditing = false
        }
    }
}

#Preview {
    ProfileView(userID: 12, bg: .constant("#001d00"), accent: .constant("#b5c4b9"))
        .environmentObject(TutorialManager())
}
