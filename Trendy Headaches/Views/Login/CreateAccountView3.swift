import SwiftUI
import CryptoKit

struct CreateAccountView3: View {
    // Info from previous pages
    var bg: String = ""
    var accent: String = ""
    var email: String = ""
    var passOne: String = ""
    var SQ: String = ""
    var SA: String = ""
    
    // Editable variables for this page
    @State private var symps: String = ""
    @State private var prevMeds: String = ""
    @State private var emergMeds: String = ""
    @State private var triggs: String = ""
    @State private var created = false
    
    // Layout constants
    private let screenWidth = UIScreen.main.bounds.width
    private let leadPadd = CGFloat(20)
    
    var body: some View {
        NavigationStack {
            ZStack {
                Create3BGComps(bg: bg, accent: accent)
                
                ScrollView {
                    ZStack {
                        VStack(spacing: 15) {
                            // Header
                            CustomText(text: "One Last Step", color: accent, textAlign: .center, textSize: 50)
                                .padding(.top, 15)
                            
                            CustomText(text: "Add multiple items by separating them with commas.", color: accent,  width: screenWidth - 30, textAlign: .center, multiAlign: .center,  textSize: 18)
                            .padding(.bottom, 20)
                            
                            // Input fields
                            Group {
                                labeledField("Symptom or Illness", text: $symps)
                                labeledField("Preventative Treatments", text: $prevMeds)
                                labeledField("Emergency Treatments", text: $emergMeds)
                                labeledField("Triggers", text: $triggs)
                            }
                            
                            // Submit button
                            CustomButton(text: "Submit", bg: bg, accent: accent) {
                                createAccount()
                            }
                            .padding(.bottom, 40)
                        }
                        .zIndex(1)
                        .padding()
                    }
                    
                    .navigationDestination(isPresented: $created) {
                        LoginView(bg: bg, accent: accent)
                    }
                }
            }
           
        }
    }
    
    @ViewBuilder
    private func labeledField(_ label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            CustomText(text: label, color: accent)
                .padding(.leading, leadPadd)
            CustomTextField(bg: bg, accent: accent, placeholder: "", text: text)
                .padding(.leading, leadPadd-10)
        }
    }
    
    private func createAccount() {
        do{
            try Database.createUser(email: email, pass: passOne,  SQ: SQ,  SA: SA,  bg: bg, accent: accent, symps: symps, prevMeds: prevMeds, emergMeds: emergMeds, triggs: triggs)
            created = true
        }
        catch{
            print("Failed to create account")
        }
    }
}

#Preview {
    NavigationStack {
        CreateAccountView3()
    }
}
