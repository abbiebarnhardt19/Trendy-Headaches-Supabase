//
//  LoginView.swift
//  Trendy Headaches
//

import SwiftUI

struct LoginView: SwiftUI.View {
    //  Theme
    var bg: String = "#001d00"
    var accent: String = "#b5c4b9"
    
    // User variables
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var loggedIn = false
    @State private var error: String? = nil
    @State private var userId: Int64? = nil
    @EnvironmentObject var userSession: UserSession
    
    //  Layout
    private let leadPadd: CGFloat = 25
    private let screenHeight: CGFloat = UIScreen.main.bounds.height
    private let screenWidth: CGFloat = UIScreen.main.bounds.width
    
    var body: some SwiftUI.View {
        NavigationStack {
            ZStack {
                LoginBGComps(bg: bg, accent: accent)
                //  Content
                VStack(spacing: 10) {
                        CustomText(text: "Log In",  color: accent, width: 150, textAlign: .leading,  textSize: 55)
                    
                    // Email
                    CustomText(text: "Email", color: accent)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, leadPadd)
                    
                    CustomTextField(bg: bg, accent: accent, placeholder: "", text: $email, width: screenWidth - 50)
                    
                    // Password
                    CustomText(text: "Password", color: accent)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, leadPadd)
                    
                    CustomTextField(bg: bg, accent: accent, placeholder: "", text: $password, width: screenWidth - 50, secure: true)
                    
                    // Forgot Password Link
                    CustomLink(destination: ForgotPasswordView1(), text: "Forgot Password?", accent: accent)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, leadPadd)
                    
                    // Login Button
                    CustomButton(text: "Log In", bg: bg, accent: accent) {
                        Task {
                            let result = await Database.shared.attemptLogin(email: email, password: password)
                            userId = result.userId
                            error = result.error
                            
                            if let userId = result.userId {
                                // Login successful - save session
                                userSession.login(userID: userId, username: email)
                            }
                            
                            loggedIn = userId != nil
                        }
                    }
                    
                    // Error Message
                    if let error = error {
                        CustomWarningText(text: error)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        CustomWarningText(text: " ") // Reserve space
                    }
                }
                .padding(.horizontal)
                .onAppear { _ = Database.shared }
                
                //  Navigation
                .navigationDestination(isPresented: $loggedIn) {
                    LogView(userID: userId ?? 0, bg: .constant(bg),  accent: .constant(accent))
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
}
