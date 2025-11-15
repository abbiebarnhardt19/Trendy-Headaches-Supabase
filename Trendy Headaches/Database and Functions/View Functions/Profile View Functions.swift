//
//  Profile View Functions.swift
//  Trendy Headaches Supabase
//
//  Created by Abigail Barnhardt on 11/15/25.
//

extension ProfileView{
    func saveProfileChanges() {
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
    
    func getProfileData() async{
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
