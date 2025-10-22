////
////  ForgotPasswordView3.swift
////  Trendy Headaches
////
////  Created by Abigail Barnhardt on 8/29/25.
////
//
//import SwiftUI
//
//struct ForgotPasswordView3: View {
//    //  Input
//    let email: String
//
//    //  State
//    @State private var passOne = ""
//    @State private var passTwo = ""
//    @State private var updated = false
//    @State private var currentPass = ""
//
//    // Theme
//    private let accent = "#b5c4b9"
//    private let bg = "#001d00"
//    private let leadPadd: CGFloat = 30
//    private let screenWidth = UIScreen.main.bounds.width
//
//    //  Validation
//    private var resetValid: Bool {
//        passOne == passTwo && passOne != currentPass && Database.passwordValid(passOne)
//    }
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                Forgot3BGComps(bg: bg, accent: accent)
//
//                ScrollView {
//                    VStack{
//                        HStack {
//                            Spacer()
//                            CustomText( text: "Last Step", color: accent, width: 100, textAlign: .trailing, textSize: 50)
//                                .padding(.top, 40)
//                                .padding(.bottom, 5)
//                                .padding(.trailing, 15)
//                        }
//                        
//                        CustomText(text: "New Password", color: accent)
//                            .padding(.leading, leadPadd)
//                        
//                        CustomTextField(bg: bg, accent: accent,  placeholder: "",  text: $passOne,  secure: true )
//                        
//                        // Password warnings
//                        if !passOne.isEmpty {
//                            if !Database.passwordValid(passOne) {
//                                CustomWarningText(text: "8+ chars: uppercase, lowercase, number, & symbol.")
//                                    .padding(.bottom, 5)
//                            } else if Database.hashString(passOne) == currentPass {
//                                CustomWarningText(text: "New password must differ from previous password.")
//                                    .padding(.bottom, 5)
//                            } else {
//                                CustomWarningText(text: "")
//                                    .padding(.bottom, 15)
//                            }
//                        } else {
//                            CustomWarningText(text: "")
//                                .padding(.bottom, 15)
//                        }
//                        CustomText(text: "Confirm New Password", color: accent)
//                            .padding(.leading, leadPadd)
//                        
//                        CustomTextField(bg: bg, accent: accent, placeholder: "", text: $passTwo,  secure: true )
//                        
//                        if !passTwo.isEmpty && passTwo != passOne {
//                            CustomWarningText(text: "Passwords do not match.")
//                                .padding(.bottom, 5)
//                        } else {
//                            CustomWarningText(text: " ")
//                                .padding(.bottom, 5)
//                        }
//                        CustomButton(text: "Reset Password",  bg: bg, accent: accent, height: 50, width: 200) {
//                            updated = Database.resetPassword(email: email, password: passOne)
//                        }
//                        .padding(.bottom, 120)
//                        .disabled(!resetValid)
//                        .opacity(resetValid ? 1.0 : 0.5)
//                        .navigationDestination(isPresented: $updated) {
//                            LoginView()
//                        }
//                    }
//                    .frame(height: UIScreen.main.bounds.height)
//                }
//                .onAppear {
//                    if let currentUser = Database.shared.userFromEmail(email: email) {
//                        currentPass = Database.shared.getSingleVal(userId: currentUser, col: "password") ?? ""
//                    }
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    ForgotPasswordView3(email: "")
//}

//
//  ForgotPasswordView3.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/29/25.
//

import SwiftUI

struct ForgotPasswordView3: View {
    //  Input
    let email: String

    //  State
    @State private var passOne = ""
    @State private var passTwo = ""
    @State private var updated = false
    @State private var currentPass = ""

    // Theme
    private let accent = "#b5c4b9"
    private let bg = "#001d00"
    private let leadPadd: CGFloat = 30
    private let screenWidth = UIScreen.main.bounds.width

    //  Validation
    private var resetValid: Bool {
        passOne == passTwo && passOne != currentPass && Database.passwordValid(passOne)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Forgot3BGComps(bg: bg, accent: accent)

                ScrollView {
                    VStack{
                        HStack {
                            Spacer()
                            CustomText( text: "Last Step", color: accent, width: 100, textAlign: .trailing, textSize: 50)
                                .padding(.top, 40)
                                .padding(.bottom, 5)
                                .padding(.trailing, 15)
                        }
                        
                        CustomText(text: "New Password", color: accent)
                            .padding(.leading, leadPadd)
                        
                        CustomTextField(bg: bg, accent: accent,  placeholder: "",  text: $passOne,  secure: true )
                        
                        // Password warnings
                        if !passOne.isEmpty {
                            if !Database.passwordValid(passOne) {
                                CustomWarningText(text: "8+ chars: uppercase, lowercase, number, & symbol.")
                                    .padding(.bottom, 5)
                            } else if passOne == currentPass {
                                CustomWarningText(text: "New password must differ from previous password.")
                                    .padding(.bottom, 5)
                            } else {
                                CustomWarningText(text: "")
                                    .padding(.bottom, 15)
                            }
                        } else {
                            CustomWarningText(text: "")
                                .padding(.bottom, 15)
                        }
                        CustomText(text: "Confirm New Password", color: accent)
                            .padding(.leading, leadPadd)
                        
                        CustomTextField(bg: bg, accent: accent, placeholder: "", text: $passTwo,  secure: true )
                        
                        if !passTwo.isEmpty && passTwo != passOne {
                            CustomWarningText(text: "Passwords do not match.")
                                .padding(.bottom, 5)
                        } else {
                            CustomWarningText(text: " ")
                                .padding(.bottom, 5)
                        }
                        CustomButton(text: "Reset Password",  bg: bg, accent: accent, height: 50, width: 200) {
                            Task {
                                updated = await Database.resetPassword(email: email, password: passOne)
                            }
                        }
                        .padding(.bottom, 120)
                        .disabled(!resetValid)
                        .opacity(resetValid ? 1.0 : 0.5)
                        .navigationDestination(isPresented: $updated) {
                            LoginView()
                        }
                    }
                    .frame(height: UIScreen.main.bounds.height)
                }
                .task {
                    if let currentUser = await Database.shared.userFromEmail(email: email) {
                        currentPass = (try? await Database.shared.getSingleVal(userId: currentUser, col: "password")) ?? ""
                    }
                }
            }
        }
    }
}

#Preview {
    ForgotPasswordView3(email: "")
}
