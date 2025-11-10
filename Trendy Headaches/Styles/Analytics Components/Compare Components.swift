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
    @Binding var prevMedOptions: [String]
    @Binding var selectedSymptom1: String?
    @Binding var selectedSymptom2: String?
    @Binding var range1Start: Date
    @Binding var range1End: Date
    @Binding var range2Start: Date
    @Binding var range2End: Date
    @Binding var selectedMed1: String?
    @Binding var selectedMed2: String?
    
    @State var dropdownOption: [String] = ["Symptom", "Dates", "Preventative Treatment"]
    @State var showFilter: Bool = true
    @State var compareMetric: String?
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    //make a constant date to check if value has been changed
    let mainDate = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
    
    //if values are still defaults, display no string. Else, display string date
    var range1String: [String] {
        let range1StartString = DateFormatter.localizedString(from: range1Start, dateStyle: .short, timeStyle: .none)
        let range1EndString = DateFormatter.localizedString(from: range1End, dateStyle: .short, timeStyle: .none)
        
        if range1StartString == mainDate && range1EndString == mainDate {
            return ["", ""]
        } else {
            return [range1StartString, range1EndString]
        }
    }

    var range2String: [String] {
        let range2StartString = DateFormatter.localizedString(from: range2Start, dateStyle: .short, timeStyle: .none)
        let range2EndString = DateFormatter.localizedString(from: range2End, dateStyle: .short, timeStyle: .none)
        
        if range2StartString == mainDate && range2EndString == mainDate {
            return ["", ""]
        } else {
            return [range2StartString, range2EndString]
        }
    }

    
    var body: some View {
        if showFilter{
            VStack{
                //header section
                HStack{
                    let font = UIFont.systemFont(ofSize: screenWidth * 0.055, weight: .bold)
                    CustomText(text:"Comparison Filters ", color: bg, width: "Comparison Metric: ".width(usingFont: font)+10, bold: true, textSize: screenWidth * 0.055)
                        .padding(.trailing, 10)
                    
                    
                    Spacer()
                    HideButton(accent: accent, bg: bg, show: $showFilter)
                    
                }
                .padding(.top, 5)

                
                //horizontal line for readability
                Divider()
                    .frame(height: 1)
                    .overlay(Color(hex: bg))
                    .padding(.bottom, 10)
                
                
                CustomText(text: "Comparison Type", color: bg, width: screenWidth - 80, bold: true, textSize: screenWidth*0.05)
                
                MultipleChoice(options: $dropdownOption, selected: $compareMetric, accent: bg, width: screenWidth-80, textSize: screenWidth * 0.05)
                    .padding(.bottom, 10)
                
                //if its symtpom, show symptom mc
                if compareMetric == "Symptom"
                {
                    //divider line between type and symptom header
                    Divider()
                        .frame(height: 1)
                        .overlay(Color(hex: bg))
                        .padding(.vertical, 7)
                    
                    VStack{
                        CustomText(text: "Symptom 1", color: bg, bold: true, textSize: screenWidth * 0.05)
                        
                        MultipleChoice(options: $symptomOptions, selected: $selectedSymptom1, accent: bg, width: screenWidth-80, textSize: screenWidth * 0.045)
                    }
                    
                    Divider()
                        .frame(height: 1)
                        .overlay(Color(hex: bg))
                        .padding(.vertical, 7)
                    
                    VStack{
                        CustomText(text: "Symptom 2", color: bg, bold: true, textSize: screenWidth * 0.05)
                        MultipleChoice(options: $symptomOptions, selected: $selectedSymptom2, accent: bg, width: screenWidth-80, textSize: screenWidth * 0.045)
                    }
                }
                
                //if its dates, show date fields
                else if compareMetric == "Dates"{
                    let fieldWidth = screenWidth - 70 - "Start:".width(usingFont: UIFont.systemFont(ofSize: screenWidth * 0.055, weight: .regular))
                    
                    Divider()
                        .frame(height: 1)
                        .overlay(Color(hex: bg))
                        .padding(.vertical, 7)
                    
                    VStack{
                        CustomText(text: "Range 1", color: bg, bold: true, textSize: screenWidth * 0.05)
                        
                        HStack{
                            DateTextField(date: $range1Start, textValue: .constant(range1String[0]), bg: .constant(accent), accent: .constant(bg), width: fieldWidth, label: "Start:", height: 45, labelTextSize: screenWidth * 0.05)
                            Spacer()
                        }
                        HStack{
                            DateTextField(date: $range1End, textValue: .constant(range1String[1]), bg: .constant(accent), accent: .constant(bg), width: fieldWidth, label: "End:", height: 45, labelTextSize: screenWidth * 0.05)
                            Spacer()
                        }
                    }
                    
                    Divider()
                        .frame(height: 1)
                        .overlay(Color(hex: bg))
                        .padding(.vertical, 7)
                       
                    VStack{
                        CustomText(text: "Range 2", color: bg, bold: true, textSize: screenWidth * 0.05)
                        
                        HStack{
                            
                            DateTextField(date: $range2Start, textValue: .constant(range2String[0]), bg: .constant(accent), accent: .constant(bg), width: fieldWidth, label: "Start:", height: 45, labelTextSize: screenWidth * 0.05)
                            Spacer()
                        }
                        
                        HStack{
                            DateTextField(date: $range2End, textValue: .constant(range2String[1]), bg: .constant(accent), accent: .constant(bg), width: fieldWidth, label: "End:", height: 45,  labelTextSize: screenWidth * 0.05)
                            Spacer()
                        }
                    }
                }
                
                //if its prev med, show med mc
                else if compareMetric == "Preventative Treatment"{
                    Divider()
                        .frame(height: 1)
                        .overlay(Color(hex: bg))
                        .padding(.vertical, 7)
                    
                    VStack{
                        CustomText(text: "Preventative Treament 1", color: bg, bold: true, textSize: screenWidth * 0.055)
                        
                        MultipleChoice(options: $prevMedOptions, selected: $selectedMed1, accent: bg, width: screenWidth - 80)
                    }
                    
                    Divider()
                        .frame(height: 1)
                        .overlay(Color(hex: bg))
                        .padding(.vertical, 7)
                    
                    VStack{
                        CustomText(text: "Preventative Treament 2", color: bg, bold: true, textSize: screenWidth * 0.055)
                        
                        MultipleChoice(options: $prevMedOptions, selected: $selectedMed2, accent: bg, width: screenWidth - 80)
                    }
                    
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
