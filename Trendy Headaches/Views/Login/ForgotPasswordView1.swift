//
//  ForgotPasswordView1.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/28/25.
//
import SwiftUI

struct ForgotPasswordView1: View {
    // Editable fields
    @State private var email: String = ""
    @State private var emailExists: Bool? = nil
    @State private var checkEmail: Task<Void, Never>? = nil
    
    // Theme colors and layout
    private let accent = "#b5c4b9"
    private let bg = "#001d00"
    private let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        NavigationStack {
            ZStack {
                Forgot1BGComps(bg: bg, accent: accent)
                
                VStack(spacing: 20) {
                    // Header and instructions
                    CustomText(text: "Forgot your password?", color: accent, width: screenWidth - 50, textAlign: .center, multiAlign: .center,  textSize: 50)
                    
                    CustomText( text: "No worries! Enter your email below to start the password reset process.",  color: accent, width: screenWidth - 50,  textAlign: .center, multiAlign: .center, textSize: 18)
                    
                    // Email input with debounced availability check
                    CustomTextField(bg: bg, accent: accent, placeholder: "", text: $email)
                        .keyboardType(.emailAddress)
                        .onChange(of: email) {
                            checkEmail?.cancel()
                            checkEmail = Task {
                                try? await Task.sleep(nanoseconds: 500_000_000)
                                if !Task.isCancelled {
                                    emailExists = await Database.emailExists(email)
                                }
                            }
                        }
                    
                    // Warning message
                    if let exists = emailExists, !exists {
                        CustomWarningText(text: "No account found with this email")
                    } else {
                        CustomWarningText(text: " ")
                    }
                    
                    // Continue button
                    CustomNavButton( label: "Continue", dest: ForgotPasswordView2(email: Database.normalize(email)), bg: bg, accent: accent,  width: screenWidth / 2 - 20)
                    .disabled(!(emailExists ?? false))
                    .opacity((emailExists ?? false) ? 1.0 : 0.5)
                }
                .padding()
            }
        }
    }
}

#Preview {
    ForgotPasswordView1()
}
