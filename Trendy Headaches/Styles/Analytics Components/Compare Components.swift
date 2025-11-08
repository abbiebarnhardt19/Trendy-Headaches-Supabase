//
//  Compare Components.swift
//  Trendy Headaches Supabase
//
//  Created by Abigail Barnhardt on 11/8/25.
//

import SwiftUI

struct CompareComponents: View {
    var accent: String
    var bg: String
    @Binding var symptomOptions: [String]
    @State var selectedSymptom1: String? = ""
    @State var selectedSymptom2: String? = ""
    
    @State var dropdownOption: [String] = ["Symptom", "Dates", "Preventative Treatment"]
    @State var showFilter: Bool = true
    @State var compareMetric: String?
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    var body: some View {
        if showFilter{
            VStack{
                HStack{
                    let font = UIFont.systemFont(ofSize: screenWidth * 0.055, weight: .bold)
                    CustomText(text:"Comparison Filters ", color: bg, width: "Comparison Metric: ".width(usingFont: font)+10, bold: true, textSize: screenWidth * 0.055)
                        .padding(.trailing, 10)
                    
                    
                    Spacer()
                    HideButton(accent: accent, bg: bg, show: $showFilter)
                }
                .padding(.top, 5)
                .padding(.bottom, 10)
                
                CustomText(text: "Comparison Type", color: bg, width: screenWidth - 80, textSize: screenWidth*0.05)
                
                MultipleChoice(options: $dropdownOption, selected: $compareMetric, accent: bg, width: screenWidth-80, textSize: screenWidth * 0.05)
                    .padding(.bottom, 10)
                
                if compareMetric == "Symptom"
                {
                    CustomText(text: "Symptom 1", color: bg, textSize: screenWidth * 0.05)
                    MultipleChoice(options: $symptomOptions, selected: $selectedSymptom1, accent: bg, width: screenWidth-70, textSize: screenWidth * 0.045)
                        .padding(.bottom, 10)
                    
                    CustomText(text: "Symptom 2", color: bg, textSize: screenWidth * 0.05)
                    MultipleChoice(options: $symptomOptions, selected: $selectedSymptom2, accent: bg, width: screenWidth-70, textSize: screenWidth * 0.045)
                }
            }
            .padding(.horizontal, 15)
            .padding(.top, 10)
            .padding(.bottom, 20)
            .background(Color(hex:accent))
            .cornerRadius(20)
            .frame(width: screenWidth - 50, alignment: .leading)
            .padding(.bottom, 10)
        }
        //button for when hidden
        else {
            HStack {
                CustomButton( text: "Comparison Filters",  bg: bg,  accent: accent,  height: screenHeight * 0.06, width: screenWidth -  50,   corner: 30, bold: false,  textSize: screenWidth * 0.05, action: { showFilter.toggle() } )
            }
            .frame(width: screenWidth)
        }
    }
}
