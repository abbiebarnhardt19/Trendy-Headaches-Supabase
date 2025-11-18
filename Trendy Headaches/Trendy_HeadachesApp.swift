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
    @StateObject private var preloadManager = PreloadManager()
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
                .environmentObject(preloadManager)
            } else {
                InitialView()
                    .environmentObject(userSession)
                    .environmentObject(tutorialManager)
                    .environmentObject(preloadManager)
            }
        }
    }
}

struct DataLoaderView: View {
    let userID: Int64
    let firstLogin: Bool

    @EnvironmentObject var tutorialManager: TutorialManager
    @EnvironmentObject var preloadManager: PreloadManager
    @EnvironmentObject var userSession: UserSession
    @AppStorage("hasSeenTutorial") private var hasSeenTutorial = false

    var body: some View {
        LogView(userID: userID)
            .environmentObject(tutorialManager)
            .environmentObject(preloadManager)
            .environmentObject(userSession)
            .task {
                // PRELOAD EVERYTHING
                print (userID)
                preloadManager.isFinished = false
                await preloadManager.preloadAll(userID: userID)


                // TUTORIAL
                if firstLogin || !hasSeenTutorial {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        tutorialManager.startTutorial()
                        hasSeenTutorial = true
                    }
                }
            }
    }
}

