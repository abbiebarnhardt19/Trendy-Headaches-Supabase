//
//  Trendy_HeadachesApp.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/21/25.
//

import SwiftUI

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
