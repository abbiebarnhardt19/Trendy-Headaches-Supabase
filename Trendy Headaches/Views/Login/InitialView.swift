//
//  InitialView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/24/25.
//

import SwiftUI

struct InitialView: View {
    //  Theme
    private let accent = "#b5c4b9"
    private let bg = "#001d00"
    private let screenWidth = UIScreen.main.bounds.width

    //  State
    @State private var showPolicy = false
    @State private var createAccount = false

    var body: some View {
        NavigationStack {
            ZStack {
                InitialViewBGComps(bg: bg, accent: accent)

                //  Content
                VStack(spacing: 20) {
                    CustomText( text: "Trendy Headaches", color: accent, width: screenWidth - 50, textAlign: .center, multiAlign: .center, textSize: 50 )

                    // Sign In Button
                    CustomNavButton( label: "Sign In", dest: LoginView(), bg: bg, accent: accent)

                    // Sign Up Button (Shows Policy First)
                    CustomButton(text: "Sign Up", bg: bg, accent: accent,  height: 55, width: 180 ) {
                        showPolicy = true
                    }
                }
            }
            // Launch database
            .onAppear {
                _ = Database.shared 
            }

            //  Modals & Navigation
            .fullScreenCover(isPresented: $showPolicy) {
                PolicySheetView(policyFileName: "DataPolicy", showsAgreeButton: true,
                    onAgree: { createAccount = true })
            }
            .navigationDestination(isPresented: $createAccount) {
                CreateAccountView()
            }
        }
    }
}

#Preview {
    InitialView()
}
