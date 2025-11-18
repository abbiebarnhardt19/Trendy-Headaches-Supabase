//
//  Compare Components.swift
//  Trendy Headaches Supabase
//
//  Created by Abigail Barnhardt on 11/8/25.
//

import SwiftUI

struct CompareMetric: View {
    var accent: String
    var bg: String
    @Binding var compareMetric: String?
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
    @State var showFilter: Bool = false
    
    
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
                    CustomText(text:"Comparison Metric", color: bg, width: "Comparison Metric: ".width(usingFont: font)+10, bold: true, textSize: screenWidth * 0.055)
                        .padding(.trailing, 10)
                    
                    Spacer()
                    HideButton(accent: accent, bg: bg, show: $showFilter)
                    
                }
                .padding(.top, 5)

                
                //horizontal line for readability
                Divider()
                    .frame(height: 1)
                    .overlay(Color(hex: bg))
                    .padding(.bottom, 5)
                
                
                CustomText(text: "Comparison Metric", color: bg, width: screenWidth - 80, bold: true, textSize: screenWidth*0.055)
                
                MultipleChoice(options: $dropdownOption, selected: $compareMetric, accent: bg, width: screenWidth-80, textSize: screenWidth * 0.05)
                    .padding(.bottom, 10)
                
                //if its symtpom, show symptom mc
                if compareMetric == "Symptom"
                {
                    //divider line between type and symptom header
                    Divider()
                        .frame(height: 1)
                        .overlay(Color(hex: bg))
                        .padding(.bottom, 3)
                    
                    VStack{
                        CustomText(text: "Symptom 1", color: bg, bold: true, textSize: screenWidth * 0.055)
                        
                        MultipleChoice(options: $symptomOptions, selected: $selectedSymptom1, accent: bg, width: screenWidth-75, textSize: screenWidth * 0.05)
                    }
                    
                    Divider()
                        .frame(height: 1)
                        .overlay(Color(hex: bg))
                        .padding(.bottom, 3)
                    
                    VStack{
                        CustomText(text: "Symptom 2", color: bg, bold: true, textSize: screenWidth * 0.055)
                        MultipleChoice(options: $symptomOptions, selected: $selectedSymptom2, accent: bg, width: screenWidth-80, textSize: screenWidth * 0.05)
                    }
                }
                
                //if its dates, show date fields
                else if compareMetric == "Dates"{
                    let fieldWidth = screenWidth - 70 - "Start:".width(usingFont: UIFont.systemFont(ofSize: screenWidth * 0.055, weight: .regular))
                    
                    Divider()
                        .frame(height: 1)
                        .overlay(Color(hex: bg))
                        .padding(.bottom, 3)
                    
                    VStack{
                        CustomText(text: "Range 1", color: bg, bold: true, textSize: screenWidth * 0.05)
                        
                        HStack{
                            DateTextField(date: $range1Start, textValue: .constant(range1String[0]), bg: .constant(accent), accent: .constant(bg), width: fieldWidth, label: "Start:", height: 40, labelTextSize: screenWidth * 0.05)
                            Spacer()
                        }
                        HStack{
                            DateTextField(date: $range1End, textValue: .constant(range1String[1]), bg: .constant(accent), accent: .constant(bg), width: fieldWidth, label: "End:", height: 40, labelTextSize: screenWidth * 0.05)
                            Spacer()
                        }
                    }
                    
                    Divider()
                        .frame(height: 1)
                        .overlay(Color(hex: bg))
                        .padding(.bottom, 3)
                       
                    VStack{
                        CustomText(text: "Range 2", color: bg, bold: true, textSize: screenWidth * 0.05)
                        
                        HStack{
                            
                            DateTextField(date: $range2Start, textValue: .constant(range2String[0]), bg: .constant(accent), accent: .constant(bg), width: fieldWidth, label: "Start:", height: 40, labelTextSize: screenWidth * 0.05)
                            Spacer()
                        }
                        
                        HStack{
                            DateTextField(date: $range2End, textValue: .constant(range2String[1]), bg: .constant(accent), accent: .constant(bg), width: fieldWidth, label: "End:", height: 40,  labelTextSize: screenWidth * 0.05)
                            Spacer()
                        }
                    }
                }
                
                //if its prev med, show med mc
                else if compareMetric == "Preventative Treatment"{
                    Divider()
                        .frame(height: 1)
                        .overlay(Color(hex: bg))
                        .padding(.bottom, 3)
                    
                    VStack{
                        CustomText(text: "Preventative Treament 1", color: bg, bold: true, textSize: screenWidth * 0.055)
                        
                        MultipleChoice(options: $prevMedOptions, selected: $selectedMed1, accent: bg, width: screenWidth - 80)
                    }
                    
                    Divider()
                        .frame(height: 1)
                        .overlay(Color(hex: bg))
                        .padding(.bottom, 3)
                    
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
            //reset values when new comparison is selected
            .onChange(of: compareMetric) { oldValue, newValue in
                switch newValue {
                case "Symptom":
                    selectedMed1 = ""
                    selectedMed2 = ""
                    range1Start = Date()
                    range1End = Date()
                    range2Start = Date()
                    range2End = Date()

                case "Dates":
                    selectedSymptom1 = ""
                    selectedSymptom2 = ""
                    selectedMed1 = ""
                    selectedMed2 = ""

                case "Preventative Treatment":
                    selectedSymptom1 = ""
                    selectedSymptom2 = ""
                    range1Start = Date()
                    range1End = Date()
                    range2Start = Date()
                    range2End = Date()

                default:
                    break
                }
            }
        }
        //button for when hidden
        else {
            HStack {
                CustomButton( text: "Comparison Metric",  bg: bg,  accent: accent,  height: screenHeight * 0.06, width: screenWidth -  50,   corner: 30, bold: false,  textSize: screenWidth * 0.05, action: { showFilter.toggle() } )
            }
            .frame(width: screenWidth)
        }
    }
}

//other analytics filter, but doesnt show the section for the selected compare metric
struct CompareFilter: View{
    var bg: String
    var accent: String
    @Binding var selectedMetric: String?
    @Binding var symptomOptions: [String]
    @Binding var selectedSymptom : [String]
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var selectedTypes:[String]
    
    @State private var showFilter: Bool = false
    
    // Date Formatter
    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    //dont need to pass in because always the same
    @State var typeOptions = ["Symptom", "Side Effect"]
    
    var body: some View {
        //dont need to pass in, just generate from the passed in date
        @State var startDateString = formatter.string(from: startDate)
        @State var endDateString = formatter.string(from: endDate)
        
        if showFilter {
            VStack(alignment: .leading, spacing: 10) {
                //top section in h stack so label and hide button on same line
                HStack{
                    let font = UIFont.systemFont(ofSize: screenWidth * 0.06, weight: .bold)
                    CustomText(text:"Other Filters", color: bg, width: "Comparison Metric: ".width(usingFont: font)+10, bold: true, textSize: screenWidth * 0.06)
                        .padding(.trailing, 10)
                    
                    Spacer()
                    HideButton(accent: accent, bg: bg, show: $showFilter)
                    
                }
                .padding(.top, 5)
                
                Divider()
                    .frame(height: 1)
                    .overlay(Color(hex: bg))
                    .padding(.bottom, 3)
                
                //alays show this because this isnt a compare metric
                CustomText(text:"Select Log Type: ", color: bg, bold: true, textSize: screenWidth * 0.055)

                //log type checkbox
                MultipleCheckboxWrapped(options: $typeOptions, selected: $selectedTypes, accent: accent, bg: bg, width: screenWidth * 0.65, textSize: screenWidth * 0.05)
                    .padding(.bottom, 5)

                //dont show symptom selection if thats the selected metric
                if selectedMetric != "Symptom"{
                    
                    Divider()
                        .frame(height: 1)
                        .overlay(Color(hex: bg))
                        .padding(.bottom, 3)
                    //symptom checkbox
                    CustomText(text:"Select Symptom: ", color: bg, bold: true, textSize: screenWidth * 0.055)
                    
                    MultipleCheckboxWrapped(options: $symptomOptions, selected: $selectedSymptom, accent: accent, bg: bg, width: screenWidth * 0.65, textSize: screenWidth * 0.05)
                        .padding(.bottom, 5)
                    
                }
                
                //dont show date selection if thats the selected metric
                if selectedMetric != "Dates"{
                    
                    Divider()
                        .frame(height: 1)
                        .overlay(Color(hex: bg))
                        .padding(.bottom, 3)
                    
                    //date fields
                    CustomText(text:"Date Range: ", color: bg, bold: true, textSize: screenWidth * 0.055)
                        .padding(.bottom, 5)
                    
                    DateTextField(date: $startDate, textValue: $startDateString, bg: .constant(accent), accent: .constant(bg), width: screenWidth / 1.5, label: "Start:", height: 35, fieldTextSize: screenWidth * 0.05, labelTextSize: screenWidth * 0.055)
                    
                    DateTextField(date: $endDate, textValue: $endDateString, bg: .constant(accent), accent: .constant(bg), width: screenWidth / 1.5, label: "End: ", height: 35, fieldTextSize: screenWidth * 0.05, labelTextSize: screenWidth * 0.055)
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
                CustomButton( text: "Filters",  bg: bg,  accent: accent,  height: screenHeight * 0.06, width: screenWidth -  50,   corner: 30, bold: false,  textSize: screenWidth * 0.05, action: { showFilter.toggle() } )
            }
            .frame(width: screenWidth)
        }
    }
}

//resuable card for comparing stats
struct CompareStatCard: View {
    var accent: String
    var bg: String
    var statName: String
    var data: ([String], [String])
    var dataLabels: (String, String)
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    @State var showStats: Bool = false
    
    var body: some View {
        if showStats{
            VStack(spacing: 0){
                //header section
                HStack{
                    let font = UIFont.systemFont(ofSize: screenWidth * 0.055, weight: .bold)
                    CustomText(text:statName, color: bg, width: statName.width(usingFont: font)+10, bold: true, textSize: screenWidth * 0.055)
                        .padding(.trailing, 10)
                    
                    Spacer()
                    HideButton(accent: accent, bg: bg, show: $showStats)
                    
                }
                .padding(.top, 5)
                .padding(.bottom, 10)
                
                //line dividing the header and the data
                Divider()
                    .frame(height: 1)
                    .overlay(Color(hex: bg))
                
                //vertical line filling gap between horiztonal line and vertical line
                Divider()
                    .frame(width: 1, height: 12)
                    .overlay(Color(hex: bg))
                
                //metric 1
                HStack(alignment: .top){
                    VStack(spacing: 5){
                        //title of metric
                        CustomText(text: dataLabels.0, color: bg, textAlign: .center, bold: true, textSize: screenWidth * 0.0475)
                            .padding(.bottom, 5)
                        
                        //data
                        ForEach(data.0, id: \.self) { item in
                            CustomText(text: item, color: bg, textAlign: .center, textSize: screenWidth * 0.045)
                        }
                    }
                    
                    //vertical line dividing metrics
                    Divider()
                        .frame(width: 1)
                        .overlay(Color(hex: bg))
                    
                    //metric 2
                    VStack(spacing: 5){
                        //metric title
                        CustomText(text: dataLabels.1, color: bg, textAlign: .center, bold: true,  textSize: screenWidth * 0.0475)
                            .padding(.bottom, 5)
                        
                        //data
                        ForEach(data.1, id: \.self) { item in
                            CustomText(text: item, color: bg, textAlign: .center, textSize: screenWidth * 0.045)
                        }
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
        //if hidden, show show button
        else{
            HStack {
                CustomButton( text: statName,  bg: bg,  accent: accent,  height: screenHeight * 0.06, width: screenWidth -  50,   corner: 30, bold: false,  textSize: screenWidth * 0.05, action: { showStats.toggle() } )
            }
            .frame(width: screenWidth)
        }
    }
}
