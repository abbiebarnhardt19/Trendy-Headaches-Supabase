//
//  Tutorial Components.swift
//  Trendy Headaches Supabase
//
//  Created by Abigail Barnhardt on 11/13/25.
//

import SwiftUI

struct TutorialPopup: View {
    var title: String
    var message: String
    var buttonText: String
    var accent: String
    var onNext: () -> Void

    var body: some View {
        ZStack {

            
            VStack(spacing: 16) {
                Text(title)
                    .font(.title3)
                    .bold()
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button(buttonText) {
                    print("button works")
                }
                .zIndex(1000)
            }
            .padding()
            .frame(maxWidth: 300)
            .background(Color(hex: accent))
            .cornerRadius(16)
            .shadow(radius: 10)
        }
    }
}

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

                CustomText(text:"Get detailed insights into your headache patterns and triggers.", color: bg, width: screenWidth * 0.75, textAlign: .center, multiAlign: .center, textSize: 18)
                    .padding(.bottom, 5)
                
                CustomText(text:"The Analytics page is split into three sections: Graphs, Stats, and Compare", color: bg, width: screenWidth * 0.7, textAlign: .center, multiAlign: .center, textSize: 18)
                
//                CustomText(text:"Graphs- see log statistics in visual format", color: bg, width: screenWidth * 0.7, textAlign: .center, multiAlign: .center, textSize: 18)
                
                CustomText(text:"Stats- see log statistics in numerical format", color: bg, width: screenWidth * 0.7, textAlign: .center, multiAlign: .center, textSize: 18)
                
                CustomText(text:"Compare- compare log statistics between symptoms, date ranges, and medications", color: bg, width: screenWidth * 0.7, textAlign: .center, multiAlign: .center, textSize: 18)
                    .padding(.bottom, 5)
                
                CustomButton(text: "Next", bg: accent, accent: bg, height: 40, width: 90, textSize: 18, action: {print("Next")})
            }
            .padding()
            .frame(width: screenWidth * 0.8)
            .background(Color(hex: accent))
            .cornerRadius(30)
            .shadow(radius: 10)
            .overlay(RoundedRectangle(cornerRadius: 30)
                    .stroke(Color(hex: bg), lineWidth: 3) )
        }
    }
}

