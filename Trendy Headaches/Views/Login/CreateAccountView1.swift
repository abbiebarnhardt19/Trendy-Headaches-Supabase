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
    
    // Computed property: form validation
    private var formIsValid: Bool {
        !email.isEmpty &&  !pass_one.isEmpty &&  !pass_two.isEmpty &&  !SQ.isEmpty &&  !SA.isEmpty &&  pass_one == pass_two && Database.passwordValid(pass_one) &&  emailAvail  }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Create1BGComps(bg: bg, accent: accent)
                
                ScrollView {
                    ZStack {
                        VStack(spacing: 5) {
                            header
                            emailSection
                            passwordSection
                            confirmPasswordSection
                            securitySection
                            continueButton
                        }
                        .padding(.top, 10)
                    }
                }
            }
        }
    }
}

// MARK: - Subviews
private extension CreateAccountView {
    var header: some View {
        CustomText(text: "Create Account", color: accent, textAlign: .center, textSize: 50)
            .padding(.bottom, 10)
    }
    
    var emailSection: some View {
        VStack(spacing: 5) {
            fieldLabel("Email")
            CustomTextField(bg: bg, accent: accent, placeholder: "", text: $email)
                .onChange(of: email) {
                    debounceEmailCheck()
                }
            
            if !emailAvail && !email.isEmpty {
                CustomWarningText(text: "There is already an account using this email")
            } else {
                CustomWarningText(text: "") // spacing placeholder
                    .padding(.bottom, 11)
            }
        }
    }
    
    var passwordSection: some View {
        VStack(spacing: 5) {
            fieldLabel("Password")
            CustomTextField(bg: bg, accent: accent, placeholder: "", text: $pass_one, secure: true)
            
            if !Database.passwordValid(pass_one) && !pass_one.isEmpty {
                CustomWarningText(text: "8+ chars: uppercase, lowercase, number, & symbol")
            } else {
                CustomWarningText(text: "      ")
            }
        }
    }
    
    var confirmPasswordSection: some View {
        VStack(spacing: 5) {
            fieldLabel("Confirm Password")
            CustomTextField(bg: bg, accent: accent, placeholder: "", text: $pass_two, secure: true)
            
            if !pass_two.isEmpty && pass_two != pass_one {
                CustomWarningText(text: "Passwords do not match.")
            } else {
                CustomWarningText(text: "       ")
            }
        }
    }
    
    var securitySection: some View {
        VStack(spacing: 5) {
            fieldLabel("Security Question")
            CustomTextField(bg: bg, accent: accent, placeholder: "", text: $SQ)
            
            CustomWarningText(text: "       ") // for spacing
            
            fieldLabel("Security Question Answer")
            CustomTextField(bg: bg, accent: accent, placeholder: "", text: $SA)
        }
    }
    
    var continueButton: some View {
        CustomNavButton(
            label: "Continue",
            dest: CreateAccountView2(email: email, passOne: pass_one,  SQ: SQ, SA: SA),  bg: bg, accent: accent, width: 150)
        .disabled(!formIsValid)
        .opacity(formIsValid ? 1 : 0.5)
        .padding(.bottom, 45)
    }
    
    func fieldLabel(_ text: String) -> some View {
        CustomText(text: text, color: accent)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 30)
    }
    
    func debounceEmailCheck() {
        checkEmail?.cancel()
        checkEmail = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            if !Task.isCancelled {
                emailAvail = !Database.emailExists(email)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CreateAccountView()
    }
}
