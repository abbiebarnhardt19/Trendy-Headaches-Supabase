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
    var onClose: () -> Void

    let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
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

