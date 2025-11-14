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

@main
struct Trendy_HeadachesApp: App {
    @StateObject private var userSession = UserSession()
    @StateObject private var tutorialManager = TutorialManager()
    @AppStorage("hasSeenTutorial") private var hasSeenTutorial = false
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
    
    var body: some Scene {
        WindowGroup {
//            if userSession.isLoggedIn {
//                DataLoaderView(userID: userSession.userID)
//                    .environmentObject(userSession)
//                    .environmentObject(tutorialManager)
//            } else {
//                InitialView()
//                    .environmentObject(userSession)
//            }
            if userSession.isLoggedIn {
                NavigationStack {
                    DataLoaderView(userID: userSession.userID)
                }
                .environmentObject(userSession)
                .environmentObject(tutorialManager)
            } else {
                InitialView()
                    .environmentObject(userSession)
            }

        }
    }
}


struct DataLoaderView: View {
    let userID: Int64
    @State private var bg: String = "#000000"
    @State private var accent: String = "#FFFFFF"
    @State private var isLoading = true
    @EnvironmentObject var tutorialManager: TutorialManager
    @AppStorage("hasSeenTutorial") private var hasSeenTutorial = false

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading...")
            } else {

                    LogView(userID: userID, bg: .constant(bg), accent: .constant(accent))
                        .environmentObject(tutorialManager)
                        .onAppear {
                            // ✅ Only show once after successful first login/account creation
                            if !hasSeenTutorial {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    tutorialManager.startTutorial()
                                    hasSeenTutorial = true
                                }
                            }
                }
            }
        }
        .task {
            do {
                let fetchedBg = try await Database.shared.getSingleVal(userId: userID, col: "background_color")
                let fetchedAccent = try await Database.shared.getSingleVal(userId: userID, col: "accent_color")
                self.bg = fetchedBg ?? "#000000"
                self.accent = fetchedAccent ?? "#FFFFFF"
                self.isLoading = false
            } catch {
                print("Error loading preferences: \(error)")
                self.isLoading = false
            }
        }
    }
}
