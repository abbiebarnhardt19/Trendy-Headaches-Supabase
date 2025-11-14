//
//  Tutorial Components.swift
//  Trendy Headaches Supabase
//
//  Created by Abigail Barnhardt on 11/13/25.
//

import SwiftUI

struct AnalyticsTutorialPopup: View {
    @State var bg: String
    @State var accent: String
    @State var userID: Int64
    var onNext: () -> Void
    var onClose: () -> Void

    let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        NavigationStack{
            ZStack {
                
                VStack(spacing: 10){
                    HStack{
                        CustomText(text: "Analytics Page", color: bg, textAlign: .center, bold: true, textSize: 24)
                            .padding(.bottom, 5)
                            .padding(.leading, 22+5)
                        
                        Button(action: { print("Close")
                            onClose() }) {
                                Image(systemName: "xmark.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundStyle(Color(hex:bg))
                                    .frame(width: 22, height: 22)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.trailing, 5)
                            .padding(.bottom, 15)
                    }
                    
                    
                    
                    CustomText(text: "Three sections: Graphs, Stats, and Compare. Filter by date, symptom, and log type",  color: bg, width: screenWidth * 0.8, textAlign: .center, multiAlign: .center, textSize: 18)
                        .padding(.bottom, 5)
                    
                    
                    (Text("Graphs:").bold() + Text(" See data visually"))
                        .foregroundColor(Color(hex: bg))
                        .font(.system(size: 18, design: .serif))
                        .multilineTextAlignment(.center)
                        .frame(width: screenWidth * 0.75)
                    
                    (Text("Stats:").bold() + Text(" See data numerically"))
                        .foregroundColor(Color(hex: bg))
                        .font(.system(size: 18, design: .serif))
                        .multilineTextAlignment(.center)
                        .frame(width: screenWidth * 0.75)
                    
                    (Text("Compare:").bold() + Text(" compare data between date range, symptom, and treatment"))
                        .foregroundColor(Color(hex: bg))
                        .font(.system(size: 18, design: .serif))
                        .multilineTextAlignment(.center)
                        .frame(width: screenWidth * 0.75)
                        .padding(.bottom, 5)
                    
                    CustomNavButton(label: "Next", dest:  ProfileView(userID: userID, bg: $bg, accent: $accent), bg: accent, accent: bg, width: 90, height: 40, textSize: 18)
                }
                .padding()
                .frame(width: screenWidth * 0.85)
                .background(Color(hex: accent))
                .cornerRadius(30)
                .shadow(radius: 10)
                .overlay(RoundedRectangle(cornerRadius: 30)
                    .stroke(Color(hex: bg), lineWidth: 3) )
            }
        }
    }
}


struct LogTutorialPopup: View {
    @State var bg: String
    @State var accent: String
    var userID: Int64
    var onNext: () -> Void
    var onClose: () -> Void

    let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        ZStack {

            VStack(spacing: 10){
                HStack{
                    CustomText(text: "Log Page", color: bg, textAlign: .center, bold: true, textSize: 24)
                        .padding(.bottom, 5)
                        .padding(.leading, 22+5)
                    
                    Button(action: { print("Close")
                    onClose() }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(Color(hex:bg))
                            .frame(width: 22, height: 22)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 5)
                    .padding(.bottom, 15)
                }

                CustomText(text: "Enter logs for symptoms and side effects. Use the toggle at the top to switch between the two. Fields marked with an asterisk are required; all other fields are optional but can provide additional insights. After submitting a log, you will be redirected to the list page.",  color: bg, width: screenWidth * 0.8, textAlign: .center, multiAlign: .center, textSize: 18)
                .padding(.bottom, 5)
                
                CustomText(text: "If you indicated that you took an emergency treatment to help your symptom, the next time you visit the log page you’ll be prompted to record whether the treatment was effective.",  color: bg, width: screenWidth * 0.8, textAlign: .center, multiAlign: .center, textSize: 18)
                .padding(.bottom, 5)
                
//                CustomButton(text: "Next", bg: accent, accent: bg, height: 40, width: 90, textSize: 18, action: {print("Next")})
                
                CustomNavButton(label: "Next", dest:  ListView(userID: userID, bg: $bg, accent: $accent), bg: accent, accent: bg, width: 90, height: 40, textSize: 18)
            }
            .padding()
            .frame(width: screenWidth * 0.85)
            .background(Color(hex: accent))
            .cornerRadius(30)
            .shadow(radius: 10)
            .overlay(RoundedRectangle(cornerRadius: 30)
                    .stroke(Color(hex: bg), lineWidth: 3) )
        }
    }
}

struct ListTutorialPopup: View {
    @State var bg: String
    @State var accent: String
    @State var userID: Int64
    var onNext: () -> Void
    var onClose: () -> Void

    let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        ZStack {

            VStack(spacing: 10){
                HStack{
                    CustomText(text: "List Page", color: bg, textAlign: .center, bold: true, textSize: 24)
                        .padding(.bottom, 5)
                        .padding(.leading, 22+5)
                    
                    Button(action: { print("Close")
                    onClose() }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(Color(hex:bg))
                            .frame(width: 22, height: 22)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 5)
                    .padding(.bottom, 15)
                }

                CustomText(text: "View your logs in a table format. Use the filter button to narrow logs by type, date, or symptom. You can also use it to add additional columns to the table.",  color: bg, width: screenWidth * 0.8, textAlign: .center, multiAlign: .center, textSize: 18)
                
                CustomText(text: "To edit a log, select it from the table. You’ll be taken to the log page, where the fields will be automatically filled with its details. Make your changes and click “Save.”",  color: bg, width: screenWidth * 0.8, textAlign: .center, multiAlign: .center, textSize: 18)
                .padding(.bottom, 5)
                
//                CustomButton(text: "Next", bg: accent, accent: bg, height: 40, width: 90, textSize: 18, action: {print("Next")})
                
                CustomNavButton(label: "Next", dest:  AnalyticsView(userID: userID, bg: $bg, accent: $accent), bg: accent, accent: bg, width: 90, height: 40, textSize: 18)
            }
            .padding()
            .frame(width: screenWidth * 0.85)
            .background(Color(hex: accent))
            .cornerRadius(30)
            .shadow(radius: 10)
            .overlay(RoundedRectangle(cornerRadius: 30)
                    .stroke(Color(hex: bg), lineWidth: 3) )
        }
    }
}

