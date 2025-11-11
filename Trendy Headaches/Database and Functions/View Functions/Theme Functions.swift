//
//  Theme Functions.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/2/25.
//

import SQLite
import Foundation
import CryptoKit

extension Database {
    
    //function to get hex codes from theme name
    static func getThemeColors(theme: String, currentBackground: String, currentAccent: String) -> (background: String, accent: String) {
        switch theme {
        case "Classic Light":
            return ("#FAF7F7", "#5E5D5D")
        case "Light Pink":
            return ("#F3D9DC", "#C78283")
        case "Classic Dark":
            return ("#0A0A0A", "#CCCCCC")
        case "Dark Green":
            return ("#001D00", "#B5C4B9")
        case "Dark Blue":
            return ("#0b3954", "#b5c6e0")
        case "Dark Purple":
            return ("#291C2D", "#CEC5dE")
        case "Custom":
            // Return whatever the user already has
            return (currentBackground, currentAccent)
        default:
            // Fallback for unknown theme names
            return (currentBackground, currentAccent)
        }
    }
    
    //function to get theme name from hex codes
    static func getThemeName(background: String, accent: String) -> String{
        var themeName = ""
        let background = background.uppercased()
        let accent = accent.uppercased()
        
        if background == "#FAF7F7" && accent == "#5E5D5D" {
            themeName = "Classic Light"
        }
        else if background == "#F3D9DC" && accent == "#C78283"{
            themeName = "Light Pink"
        }
        else if background == "#0A0A0A" && accent == "#CCCCCC" {
            themeName = "Classic Dark"
        }
        else if background == "#001D00" && accent == "#B5C4B9" {
            themeName = "Dark Green"
        }
        else if background == "#0b3954" && accent == "#b5c6e0"{
            themeName = "Dark Blue"
        }
        else if background == "#291C2D" && accent == "#CEC5dE" {
            themeName = "Dark Purple"
        }
        else{
            themeName = "Custom (\(background) and \(accent))"
        }
        return themeName
    }
}
