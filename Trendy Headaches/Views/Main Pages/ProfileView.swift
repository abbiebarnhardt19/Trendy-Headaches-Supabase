//
//  ProfileView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/31/25.

import SwiftUI

struct ProfileView: View {
    // Passed-in Values
    var userID: Int64

    //colors
    @State var bg: String = ""
    @State var accent: String = ""
    
    @EnvironmentObject var userSession: UserSession
    @EnvironmentObject var tutorialManager: TutorialManager
    
    //  UI State
    @State  var isEditing = false
    @State  var logOut = false
    @State  var showLogView = false
    @State  var showDelete = false
    
    //  User Data
    @State  var symps: [String] = []
    @State  var triggs: [String] = []
    @State  var prevMeds: [String] = []
    @State  var emergMeds: [String] = []
    @State  var sQ = ""
    @State  var sA = ""
    @State  var themeName = ""
    
    //  Editable Values
    @State  var newSQ = ""
    @State  var newSA = ""
    @State  var newTN = ""
    @State  var newBG = ""
    @State  var newAcc = ""
    
    //  Constants
     let themeOptions = ["Classic Light", "Light Pink", "Light Yellow", "Classic Dark",  "Dark Green", "Dark Blue", "Dark Purple", "Custom"]
     let buttonNames = ["Edit Profile", "App Tutorial", "Sign Out", "Delete Account"]
     let screenWidth = UIScreen.main.bounds.width
     let screenHeight = UIScreen.main.bounds.height

    var body: some View {
        NavigationStack {
            ZStack {
                ProfileBGComps(bg: newBG, accent: newAcc)
                
                // Content
                ScrollView {
                    VStack{
                        if isEditing {
                            EditProfile(screenWidth: screenWidth, userID: userID, symps: $symps, prevMeds: $prevMeds, triggs: $triggs, emergMeds: $emergMeds, newSQ: $newSQ, newSA: $newSA, newTN: $newTN, newBG: $newBG, newAcc: $newAcc, themeOptions: themeOptions, saveProfileChanges: saveProfileChanges)
                        } else {
                            ViewProfile(screenWidth: screenWidth, symps: $symps, prevMeds: $prevMeds, triggs: $triggs, emergMeds: $emergMeds, newSQ: $newSQ, themeName: $newTN, accent: $accent, newAcc: $newAcc, newBG: $newBG, isEditing: $isEditing, showLogView: $showLogView, logOut: $logOut, showDelete: $showDelete, buttonNames: buttonNames)
                        }
                    }
                }
                .ignoresSafeArea(edges: .bottom)
                
                if tutorialManager.showTutorial{
                    ProfileTutorialPopup(bg: $bg,  accent: $accent, userID: userID, onClose: { tutorialManager.endTutorial() }  )

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
            .navigationBarBackButtonHidden(true)
            //go to login if cancel account
            .fullScreenCover(isPresented: $logOut) {
                InitialView()
            }
            .fullScreenCover(isPresented: $showLogView) {
                LogView(userID: userID)
                    .navigationBarBackButtonHidden(true)
            }
            //get data on load
            .task {
                await getProfileData()
            }
        }
    }
}

#Preview {
    ProfileView(userID: 12)
        .environmentObject(UserSession())
        .environmentObject(TutorialManager())
}
