import SwiftUI

struct CreateAccountView2: View {
    // Form data from previous pages
    var email: String = ""
    var passOne: String = ""
    var SQ: String = ""
    var SA: String = ""
    
    // Color theme options
    private let themeOptions = [ "Classic Light", "Light Pink", "Classic Dark", "Dark Green", "Dark Blue", "Dark Purple", "Custom" ]
    
    // User-selected theme values
    @State private var theme: String = "Dark Green"
    @State private var bg: String = "#001D00"
    @State private var accent: String = "#B5C4B9"

    // Layout constants
    private let leadPad: CGFloat = 180
    private let screenWidth = UIScreen.main.bounds.width
    private let hexWidth = UIScreen.main.bounds.width / 2 - 40
    
    var body: some View {
        NavigationStack {
            ZStack {
                Create2BGComps(bg: bg, accent: accent)
                
                VStack(spacing: 20) {
                    // Header
                    CustomText(text: "Choose a color theme", color: accent)
                        .padding(.leading, leadPad)

                    // Theme dropdown
                    ThemeDropdown(theme: $theme, bg: $bg, accent: $accent, options: themeOptions,  width: screenWidth - 50, height: 50, corner: 30, fontSize: 22)

                    // Custom theme input fields
                    if theme == "Custom" {
                        CustomText(text: "Or, enter two hex codes to design a theme", color: accent, width: screenWidth - 50,  textAlign: .center, multiAlign: .center)
                        .padding(.bottom, 10)
                        
                        HStack (spacing: 20){
                            ColorTextField(accent: accent, bg: bg, update: $bg, placeholder: "Enter HEX color", width: hexWidth)
                            
                            ColorTextField(accent: accent, bg: bg, update: $accent, placeholder: "Enter HEX color", width: hexWidth)
                        }
                    }
                    
                    // Continue button
                    CustomNavButton(label: "Continue", dest: CreateAccountView3( bg: bg, accent: accent, email: email, passOne: passOne, SQ: SQ,  SA: SA)
                        .environmentObject(UserSession())
                        .environmentObject(TutorialManager())
                        .environmentObject(PreloadManager()), bg: bg,  accent: accent)
                }
                .padding()
            }
        }
    }
}

#Preview {
    CreateAccountView2(
        email: "test@example.com",
        passOne: "password123",
        SQ: "Your first pet?",
        SA: "Fluffy"
    )
}
