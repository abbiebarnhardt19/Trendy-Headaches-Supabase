//
//  TutorialManager.swift
//  Trendy Headaches Supabase
//
//  Created by Abigail Barnhardt on 11/13/25.
//

import SwiftUI

class TutorialManager: ObservableObject {
    @Published var showTutorial = true

    func startTutorial() {
        showTutorial = true
    }

    func endTutorial() {
        showTutorial = false
    }
}
