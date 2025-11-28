//
//  EditingView.swift
//  Trendy Headaches Supabase
//
//  Created by Abigail Barnhardt on 11/15/25.
//

import SwiftUI

struct ViewProfile: View {
    let screenWidth: CGFloat
    
    @Binding var symps: [String]
    @Binding var prevMeds: [String]
    @Binding var triggs: [String]
    @Binding var emergMeds: [String]
    @Binding var newSQ: String
    @Binding var themeName: String
    @Binding var accent: String
    @Binding var newAcc: String
    @Binding var newBG: String
    
    @Binding var isEditing: Bool
    @Binding var showLogView: Bool
    @Binding var logOut: Bool
    @Binding var showDelete: Bool
    
    let buttonNames: [String]
    @EnvironmentObject var tutorialManager: TutorialManager
    @EnvironmentObject var userSession: UserSession
    
    var body: some View {
        let colWidth = screenWidth / 2 - 20
        
        VStack {
            CustomText(text: "User Profile", color: newAcc, textAlign: .center, textSize: 45)
                .padding(.vertical, 50)
            
            HStack(alignment: .top) {
                VStack {
                    SectionList(colTitle: "Symptoms", items: symps, width: colWidth, color: accent)
                    SectionList(colTitle: "Preventative Treatments", items: prevMeds, width: colWidth, color: accent)
                    SectionList(colTitle: "Security Question", items: [newSQ], width: colWidth, color: accent)
                }
                .frame(maxWidth: colWidth)
                
                VStack {
                    SectionList(colTitle: "Triggers", items: triggs, width: colWidth, color: accent)
                    SectionList(colTitle: "Emergency Treatments", items: emergMeds, width: colWidth, color: accent)
                    SectionList(colTitle: "Color Theme", items: [themeName], width: colWidth, color: accent)
                    
                    HStack {
                        Spacer()
                        let buttonActions: [() -> Void] = [
                            { isEditing = true },
                            { tutorialManager.startTutorial(); showLogView = true },
                            { userSession.logout(); logOut = true },
                            { showDelete = true }
                        ]
                        
                        FloatButton(accent: newAcc, bg: newBG, options: buttonNames, actions: buttonActions)
                            .padding(.top, 20)
                    }
                    .padding(.trailing, 10)
                }
                .frame(maxWidth: colWidth)
            }
        }
    }
}
