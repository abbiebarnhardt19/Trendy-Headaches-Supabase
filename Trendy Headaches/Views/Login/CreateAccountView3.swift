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
    private let screenHeight = UIScreen.main.bounds.height
    private let spacing = UIScreen.main.bounds.height * 0.0275

    private let leadPadd = CGFloat(20)
    
    var body: some View {
        GeometryReader { geometry in
            let topInsert = geometry.safeAreaInsets.top
            let bottomInsert = geometry.safeAreaInsets.bottom
            
            NavigationStack {
                ZStack {
                    Color(hex: bg).ignoresSafeArea()
                        .zIndex(0)
                    Create1BGComps(bg: bg, accent: accent, fixedHeight: geometry.size.height, topInsert: topInsert, bottomInsert: bottomInsert)
                        .zIndex(2)
                        .ignoresSafeArea(.keyboard)
                    
                    ScrollView {
                        VStack(spacing: spacing) {
                            Spacer()
                            CustomText(text: "One Last Step", color: accent, textAlign: .center, textSize: screenWidth*0.11)
                            
                            CustomText(text: "Add multiple items by separating them with commas.", color: accent,  width: screenWidth - 30, textAlign: .center, multiAlign: .center,  textSize: screenWidth*0.05)
                            
                            // Input fields
                            Group {
                                labeledField("Symptom or Illness", text: $symps)
                                labeledField("Preventative Treatments", text: $prevMeds)
                                labeledField("Emergency Treatments", text: $emergMeds)
                                labeledField("Triggers", text: $triggs)
                            }
                            
                            // Submit button
                            CustomButton(text: "Submit", bg: bg, accent: accent, height: screenHeight * 0.06, width: 150,  textSize: screenWidth * 0.055) {
                                Task {
                                    await createAccount()
                                }
                            }
                            .padding(.bottom, 40)
                            Spacer()
                        }
                        .padding(.top, topInsert - 40)
                    }
                    .zIndex(1)
                    .navigationDestination(isPresented: $created) {
                        LoginView(bg: bg, accent: accent)
                    }
                }
                .ignoresSafeArea(edges: .top)
                .toolbarBackground(.hidden, for: .navigationBar)
            }
        }
        .ignoresSafeArea(.keyboard)
    }
    
    @ViewBuilder
    private func labeledField(_ label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack{
            CustomText(text: label, color: accent, width: screenWidth-50, textSize:  screenWidth*0.055)
            }
            .frame(width: screenWidth)
            
            HStack{
                CustomTextField(bg: bg, accent: accent, placeholder: "", text: text, width: screenWidth-50, height: screenHeight * 0.065, textSize: screenHeight * 0.065 / 2.2)
            }
            .frame(width: screenWidth)
        }
    }
    
    private func createAccount() async {
        do{
            try await Database.createUser(email: email, pass: passOne,  SQ: SQ,  SA: SA,  bg: bg, accent: accent, symps: symps, prevMeds: prevMeds, emergMeds: emergMeds, triggs: triggs)
            created = true
        }
        catch{
            print("Failed to create account")
            print("Error type: \(type(of: error))")
        }
    }
}

#Preview {
    NavigationStack {
        CreateAccountView3()
    }
}
