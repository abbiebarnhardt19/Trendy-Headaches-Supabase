//
//  Tutorial Components.swift
//  Trendy Headaches Supabase
//
//  Created by Abigail Barnhardt on 11/13/25.
//

import SwiftUI

struct AnalyticsTutorialPopup: View {
    var bg: String
    var accent: String
    var onNext: () -> Void

    let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        ZStack {

            VStack(spacing: 10){
                CustomText(text: "Analytics Page", color: bg, textAlign: .center, bold: true, textSize: 24)
                    .padding(.bottom, 5)

                CustomText(text: "Get insights into your headache patterns and triggers. Filter logs by date, symptom, and type.",  color: bg, width: screenWidth * 0.8, textAlign: .leading, multiAlign: .leading, textSize: 18)
                .padding(.bottom, 5)

                CustomText(text: "The Analytics page has three sections: Graphs, Stats, and Compare.", color: bg, width: screenWidth * 0.80, textAlign: .center, multiAlign: .center, textSize: 18)

                (Text("Graphs:").bold() + Text(" View your logs in charts and graphs."))
                    .foregroundColor(Color(hex: bg))
                    .font(.system(size: 18, design: .serif))
                    .multilineTextAlignment(.center)
                    .frame(width: screenWidth * 0.75)

                (Text("Stats:").bold() + Text(" See your log data in numbers."))
                    .foregroundColor(Color(hex: bg))
                    .font(.system(size: 18, design: .serif))
                    .multilineTextAlignment(.center)
                    .frame(width: screenWidth * 0.75)

                (Text("Compare:").bold() + Text(" Compare logs by symptom, date, or medication."))
                    .foregroundColor(Color(hex: bg))
                    .font(.system(size: 18, design: .serif))
                    .multilineTextAlignment(.center)
                    .frame(width: screenWidth * 0.75)

                
                CustomButton(text: "Next", bg: accent, accent: bg, height: 40, width: 90, textSize: 18, action: {print("Next")})
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

