//
//  User Session.swift
//  Trendy Headaches Supabase
//
//  Created by Abigail Barnhardt on 11/7/25.
//

import Foundation

//class UserSession: ObservableObject {
//    @Published var isLoggedIn = false
//    @Published var userID: Int64 = 0
//    @Published var username: String = ""
//    
//    private let userDefaults = UserDefaults.standard
//    
//    init() {
//        // Check if user was previously logged in
//        if let savedUserID = userDefaults.value(forKey: "userID") as? Int64,
//           let savedUsername = userDefaults.string(forKey: "username") {
//            self.userID = savedUserID
//            self.username = savedUsername
//            self.isLoggedIn = true
//        }
//    }
//    
//    func login(userID: Int64, username: String) {
//        self.userID = userID
//        self.username = username
//        self.isLoggedIn = true
//        
//        // Save to UserDefaults
//        userDefaults.set(userID, forKey: "userID")
//        userDefaults.set(username, forKey: "username")
//    }
//    
//    func logout() {
//        self.userID = 0
//        self.username = ""
//        self.isLoggedIn = false
//        
//        // Clear UserDefaults
//        userDefaults.removeObject(forKey: "userID")
//        userDefaults.removeObject(forKey: "username")
//    }
//}

class UserSession: ObservableObject {
    @Published var isLoggedIn = false
    @Published var userID: Int64 = 0
    @Published var username: String = ""
    @Published var preloadManager: PreloadManager? = nil // Store preloaded data per session

    private let userDefaults = UserDefaults.standard
    
    init() {
        if let savedUserID = userDefaults.value(forKey: "userID") as? Int64,
           let savedUsername = userDefaults.string(forKey: "username") {
            self.userID = savedUserID
            self.username = savedUsername
            self.isLoggedIn = true
            Task {
                await loadPreloadManager()
            }
        }
    }
    
    func login(userID: Int64, username: String) {
        self.userID = userID
        self.username = username
        self.isLoggedIn = true
        
        userDefaults.set(userID, forKey: "userID")
        userDefaults.set(username, forKey: "username")
        
        Task {
            await loadPreloadManager()
        }
    }
    
    func logout() {
        self.userID = 0
        self.username = ""
        self.isLoggedIn = false
        self.preloadManager = nil // Clear data on logout
        
        userDefaults.removeObject(forKey: "userID")
        userDefaults.removeObject(forKey: "username")
    }
    
    private func loadPreloadManager() async {
        let manager = PreloadManager()
        await manager.preloadAll(userID: self.userID)
        await MainActor.run {
            self.preloadManager = manager
        }
    }
}
