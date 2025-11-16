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
            //refresh with new values
            await preloadManager.preloadAll(userID: userID)
            
            isEditing = false
        }
    }
    
    
    //assign preloaded values
    func setupProfile() async {

        await MainActor.run {
            // profile data
            symps = preloadManager.symps
            triggs = preloadManager.triggs
            prevMeds = preloadManager.prevMeds
            emergMeds = preloadManager.emergMeds
            sQ = preloadManager.sQ
            sA = preloadManager.sA
            newSQ = preloadManager.sQ

            // Colors
            bg = preloadManager.bg
            accent = preloadManager.accent
            newBG = preloadManager.bg
            newAcc = preloadManager.accent

            // Theme
            themeName = preloadManager.themeName
            newTN = preloadManager.themeName.contains("Custom") ? "Custom" : preloadManager.themeName
        }
    }

}
