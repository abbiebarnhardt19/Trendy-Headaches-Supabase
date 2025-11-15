//
//  Trendy_HeadachesApp.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/21/25.
//
import SwiftUI

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
            if userSession.isLoggedIn {
                NavigationStack {
                    DataLoaderView(userID: userSession.userID, firstLogin: false)
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
    let firstLogin: Bool  // <-- new
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
//                LogView(userID: userID, bg: .constant(bg), accent: .constant(accent))
//                    .environmentObject(tutorialManager)
//                    .onAppear {
//                        // Show tutorial if first login OR user never saw it
//                        if firstLogin || !hasSeenTutorial {
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                                tutorialManager.startTutorial()
//                                hasSeenTutorial = true
//                            }
//                        }
//                    }
                LogView(userID: userID)
                    .environmentObject(tutorialManager)
                    .onAppear {
                        // Show tutorial if first login OR user never saw it
                        if firstLogin || !hasSeenTutorial {
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
