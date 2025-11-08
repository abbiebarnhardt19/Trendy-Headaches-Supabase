////
////  Trendy_HeadachesApp.swift
////  Trendy Headaches
////
////  Created by Abigail Barnhardt on 8/21/25.
////
//
//import SwiftUI
//
@main
struct Trendy_HeadachesApp: App {
    
    //makes the default nav bar transparent
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground() // makes it transparent
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear // removes the bottom border

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
    
    var body: some Scene {
        WindowGroup {
            //original view created with project
            //ContentView()
            //
            InitialView()
        }
    }
}

//
//  Trendy_HeadachesApp.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/21/25.
//

import SwiftUI
//
//@main
//struct Trendy_HeadachesApp: App {
//    @StateObject private var userSession = UserSession()
//    
//    //makes the default nav bar transparent
//    init() {
//        let appearance = UINavigationBarAppearance()
//        appearance.configureWithTransparentBackground() // makes it transparent
//        appearance.backgroundColor = .clear
//        appearance.shadowColor = .clear // removes the bottom border
//
//        UINavigationBar.appearance().standardAppearance = appearance
//        UINavigationBar.appearance().scrollEdgeAppearance = appearance
//        UINavigationBar.appearance().compactAppearance = appearance
//    }
//    
//    var body: some Scene {
//        WindowGroup {
//            if userSession.isLoggedIn {
//                // User is logged in - show main app
//               let bg = try await Database.shared.getSingleVal(userId: userSession.userID, col: "background_color")
//              let accent = try await Database.shared.getSingleVal(userId: userSession.userID, col: "accent_color")
//                LogView(userID: userSession.userID, bg: .constant(bg ?? "000000"), accent: .constant(accent ?? "#FFFFFF"))
//                                    .environmentObject(userSession)
//            } else {
//                // User not logged in - show initial/login view
//                InitialView()
//                    .environmentObject(userSession)
//            }
//        }
//    }
//}
//
//@main
//struct Trendy_HeadachesApp: App {
//    @StateObject private var userSession = UserSession()
//    
//    //makes the default nav bar transparent
//    init() {
//        let appearance = UINavigationBarAppearance()
//        appearance.configureWithTransparentBackground() // makes it transparent
//        appearance.backgroundColor = .clear
//        appearance.shadowColor = .clear // removes the bottom border
//
//        UINavigationBar.appearance().standardAppearance = appearance
//        UINavigationBar.appearance().scrollEdgeAppearance = appearance
//        UINavigationBar.appearance().compactAppearance = appearance
//    }
//    
//    var body: some Scene {
//        WindowGroup {
//            if userSession.isLoggedIn {
//                // User is logged in - show data loader
//                DataLoaderView(userID: userSession.userID)
//                    .environmentObject(userSession)
//            } else {
//                // User not logged in - show initial/login view
//                InitialView()
//                    .environmentObject(userSession)
//            }
//        }
//    }
//}
//
//// Add this in the same file
//struct DataLoaderView: View {
//    let userID: Int64
//    @State private var bg: String = "#000000"
//    @State private var accent: String = "#FFFFFF"
//    @State private var isLoading = true
//    
//    var body: some View {
//        Group {
//            if isLoading {
//                ProgressView("Loading...")
//            } else {
//                LogView(userID: userID, bg: .constant(bg), accent: .constant(accent))
//            }
//        }
//        .task {
//            do {
//                let fetchedBg = try await Database.shared.getSingleVal(userId: userID, col: "background_color")
//                let fetchedAccent = try await Database.shared.getSingleVal(userId: userID, col: "accent_color")
//                
//                self.bg = fetchedBg ?? "#000000"
//                self.accent = fetchedAccent ?? "#FFFFFF"
//                self.isLoading = false
//            } catch {
//                print("Error loading preferences: \(error)")
//                self.isLoading = false
//            }
//        }
//    }
//}
