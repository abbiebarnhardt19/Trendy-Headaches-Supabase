//
//  EditProfile.swift
//  Trendy Headaches Supabase
//
//  Created by Abigail Barnhardt on 11/15/25.
//

import SwiftUI

struct EditProfile: View {
    let screenWidth: CGFloat
    let userID: Int64
    
    @Binding var symps: [String]
    @Binding var prevMeds: [String]
    @Binding var triggs: [String]
    @Binding var emergMeds: [String]
    
    @Binding var newSQ: String
    @Binding var newSA: String
    @Binding var newTN: String
    @Binding var newBG: String
    @Binding var newAcc: String
    let themeOptions: [String]
    
    let saveProfileChanges: () -> Void
    
    var body: some View {
        let colWidth = screenWidth / 2 - 20
        
        VStack {
            CustomText(text: "User Profile", color: newAcc, textAlign: .center, textSize: 45)
                .padding(.top, 30)
                .padding(.bottom, 10)
            
            HStack(alignment: .top) {
                VStack(alignment: .center, spacing: 20) {
                    EditableSection(title: "Symptoms", items: $symps, table: "Symptoms", requiresReason: false, bg: newBG, accent: newAcc, colWidth: colWidth, userID: userID)
                    
                    EditableSection(title: "Preventative Treatments", items: $prevMeds, table: "Medications", requiresReason: true, medCat: "preventative", bg: newBG, accent: newAcc, colWidth: colWidth, userID: userID)
                    
                    SectionTitle(title:"Security Question", width: colWidth, color: newAcc)
                    CustomTextField(bg: newBG, accent: newAcc, placeholder: "", text: $newSQ, width: colWidth - 15, height: 50, corner: 8, textSize: 20, multiline: true)
                    
                    SectionTitle(title:"Color Theme", width: colWidth, color: newAcc)
                    ThemeDropdown(theme: $newTN, bg: $newBG, accent: $newAcc, options: themeOptions, width: colWidth - 15, height: 50, corner: 8, fontSize: 20)
                    
                    if newTN == "Custom" {
                        SectionTitle(title:"Hex Codes", width: colWidth, color: newAcc)
                        ColorTextField(accent: newAcc, bg: newBG, update: $newBG, placeholder: "Enter HEX color", width: colWidth-10)
                            .padding(.vertical, 15)
                        ColorTextField(accent: newAcc, bg: newBG, update: $newAcc, placeholder: "Enter HEX color", width: colWidth - 10)
                    }
                }
                .frame(maxWidth: colWidth)
                .padding(.leading, 10)
                
                VStack(alignment: .center, spacing: 20) {
                    EditableSection(title: "Triggers", items: $triggs, table: "Triggers", requiresReason: false, bg: newBG, accent: newAcc, colWidth: colWidth, userID: userID)
                    
                    EditableSection(title: "Emergency Treatments", items: $emergMeds, table: "Medications", requiresReason: true, medCat: "emergency", bg: newBG, accent: newAcc, colWidth: colWidth, userID: userID)
                    
                    SectionTitle(title:"Security Answer", width: colWidth, color: newAcc)
                    CustomTextField(bg: newBG, accent: newAcc, placeholder: "", text: $newSA, width: colWidth - 15, height: 50, corner: 8, textSize: 20, multiline: true)
                    
                    CustomButton(text: "Save", bg: newBG, accent: newAcc, height: 50, width: colWidth - 25, corner: 36, bold: true, textSize: 25, action: saveProfileChanges)
                        .padding(.top, 10)
                }
                .padding(.trailing, 10)
            }
            .frame(width: screenWidth)
            .padding(.bottom, 120)
        }
    }
}

