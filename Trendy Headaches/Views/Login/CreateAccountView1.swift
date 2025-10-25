import SwiftUI

struct CreateAccountView: View {
    
    // Editable fields
    @State private var email: String = ""
    @State private var SQ: String = ""
    @State private var SA: String = ""
    @State private var pass_one: String = ""
    @State private var pass_two: String = ""
    @State private var emailAvail: Bool = true
    @State private var checkEmail: Task<Void, Never>? = nil
    
    // Colors and layout
    private let accent = "#b5c4b9"
    private let bg = "#001d00"
    
    private let screenWidth = UIScreen.main.bounds.width
    private let screenHeight = UIScreen.main.bounds.height
    private let spacing = UIScreen.main.bounds.height * 0.012
    
    // Computed property: form validation
    private var formIsValid: Bool {
        !email.isEmpty &&  !pass_one.isEmpty &&  !pass_two.isEmpty &&  !SQ.isEmpty &&  !SA.isEmpty &&  pass_one == pass_two && Database.passwordValid(pass_one) &&  emailAvail  }
    
    var body: some View {
        GeometryReader { geometry in
            let topInsert = geometry.safeAreaInsets.top
            let bottomInsert = geometry.safeAreaInsets.bottom  // ← Add this
            NavigationStack {
                ZStack {
                    Color(hex: bg).ignoresSafeArea()
                        .zIndex(0)
                    Create1BGComps(bg: bg, accent: accent, fixedHeight: geometry.size.height, topInsert: topInsert, bottomInsert: bottomInsert)  // ← Pass it
                        .zIndex(2)
                        .ignoresSafeArea(.keyboard)
                    
                    ScrollView {
                        VStack(spacing: spacing) {
                            Spacer()
                            header
                            emailSection
                            passwordSection
                            confirmPasswordSection
                            securitySection
                            continueButton
                            Spacer()
                        }
                        .padding(.top, topInsert - 30)
                    }
                    .zIndex(1)
                }
                .ignoresSafeArea(edges: .top)
                .toolbarBackground(.hidden, for: .navigationBar)
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Subviews
private extension CreateAccountView {
    var header: some View {
        CustomText(text: "Create Account", color: accent, textAlign: .center, textSize: screenWidth*0.11)
    }
    
    var emailSection: some View {
        VStack(spacing: spacing) {
            fieldLabel("Email")
            CustomTextField(bg: bg, accent: accent, placeholder: "", text: $email, width: screenWidth-50, height: screenHeight * 0.065, textSize: screenHeight * 0.065 / 2.2)
                .onChange(of: email) {
                    debounceEmailCheck()
                }
            
            if !emailAvail && !email.isEmpty {
                CustomWarningText(text: "There is already an account using this email")
            }
        }
    }
    
    var passwordSection: some View {
        VStack(spacing: spacing) {
            fieldLabel("Password")
            CustomTextField(bg: bg, accent: accent, placeholder: "", text: $pass_one,  width: screenWidth-50, height: screenHeight * 0.065, textSize: screenHeight * 0.065 / 2.2, secure: true)
            
            if !Database.passwordValid(pass_one) && !pass_one.isEmpty {
                CustomWarningText(text: "8+ chars: uppercase, lowercase, number, & symbol")
            }
        }
    }
    
    var confirmPasswordSection: some View {
        VStack(spacing: spacing) {
            fieldLabel("Confirm Password")
            CustomTextField(bg: bg, accent: accent, placeholder: "", text: $pass_two, width: screenWidth-50, height: screenHeight * 0.065, textSize: screenHeight * 0.065 / 2.2,  secure: true)
            
            if !pass_two.isEmpty && pass_two != pass_one {
                CustomWarningText(text: "Passwords do not match.")
            }
        }
    }
    
    var securitySection: some View {
        VStack(spacing: spacing) {
            fieldLabel("Security Question")
            CustomTextField(bg: bg, accent: accent, placeholder: "", text: $SQ, width: screenWidth-50, height: screenHeight * 0.065, textSize: screenHeight * 0.065 / 2.2)
            
            fieldLabel("Security Question Answer")
            CustomTextField(bg: bg, accent: accent, placeholder: "", text: $SA, width: screenWidth-50, height: screenHeight * 0.065, textSize: screenHeight * 0.065 / 2.2)
        }
    }
    
    var continueButton: some View {
        CustomNavButton(
            label: "Continue",
            dest: CreateAccountView2(email: email, passOne: pass_one,  SQ: SQ, SA: SA),  bg: bg, accent: accent, width: 150, height: screenHeight * 0.06, textSize: screenWidth * 0.055)
        .disabled(!formIsValid)
        .opacity(formIsValid ? 1 : 0.5)
        .padding(.bottom, 55)
    }
    
    func fieldLabel(_ text: String) -> some View {
        CustomText(text: text, color: accent, textSize:  screenWidth*0.055)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 30)
    }
    
    func debounceEmailCheck() {
        checkEmail?.cancel()
        checkEmail = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            if !Task.isCancelled {
                emailAvail = !(await Database.emailExists(email))
            }
        }
    }
}

#Preview {
    NavigationStack {
        CreateAccountView()
    }
}
