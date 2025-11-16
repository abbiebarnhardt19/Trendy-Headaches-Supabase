//
//  TutorialManager.swift
//  Trendy Headaches Supabase
//
//  Created by Abigail Barnhardt on 11/13/25.
//

import SwiftUI

//class TutorialManager: ObservableObject {
//    @Published var showTutorial = true
//
//    func startTutorial() {
//        showTutorial = true
//    }
//
//    func endTutorial() {
//        showTutorial = false
//    }
//}

class TutorialManager: ObservableObject {
    @Published var showTutorial: Bool {
        didSet {
            UserDefaults.standard.set(!showTutorial, forKey: "tutorialCompleted")
        }
    }

    init() {
        // If tutorialCompleted was true, showTutorial should be false
        self.showTutorial = !UserDefaults.standard.bool(forKey: "tutorialCompleted")
    }

    func startTutorial() {
        showTutorial = true
    }

    func endTutorial() {
        showTutorial = false
    }
}
