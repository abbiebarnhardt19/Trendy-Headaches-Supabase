//
//  TutorialManager.swift
//  Trendy Headaches Supabase
//
//  Created by Abigail Barnhardt on 11/13/25.
//

import SwiftUI

class TutorialManager: ObservableObject {
    @Published var showTutorial = true
    @Published var currentStep = 0

    func startTutorial() {
        currentStep = 0
        showTutorial = true
    }

    func nextStep() {
        currentStep += 1
    }

    func endTutorial() {
        showTutorial = false
    }
}
