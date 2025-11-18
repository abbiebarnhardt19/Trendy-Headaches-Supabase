//
//  Custom Analytics Components.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/2/25.
//

import SwiftUI

//button with chart/stat name to show it
struct HiddenChart: View {
    var bg: String
    var accent: String
    var chart: String
    @Binding var hideChart: Bool
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        HStack {
            CustomButton( text: "\(chart)",  bg: bg,  accent: accent,  height: screenHeight * 0.06, width: screenWidth -  50,   corner: 30, bold: false,  textSize: screenWidth * 0.055, action: { hideChart.toggle() } )
        }
        .frame(width: screenWidth)
    }
}

//filter by symptom, log type, and date
struct AnalyticsFilter: View {
    var bg: String
    var accent: String
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
                    let font = UIFont.systemFont(ofSize: screenWidth * 0.055, weight: .bold)
                    CustomText(text:"Filters", color: bg, width: "Filters ".width(usingFont: font)+10, bold: true, textSize: screenWidth * 0.055)
                        .padding(.trailing, 10)
                    
                    Spacer()
                    HideButton(accent: accent, bg: bg, show: $showFilter)
                    
                }
                .padding(.top, 5)
                
                Divider()
                    .frame(height: 1)
                    .overlay(Color(hex: bg))
                    .padding(.bottom, 3)
                
                CustomText(text:"Log Type: ", color: bg, bold: true, textSize: screenWidth * 0.05)

                //log type checkbox
                MultipleCheckboxWrapped(options: $typeOptions, selected: $selectedTypes, accent: accent, bg: bg, width: screenWidth * 0.65)
                    .padding(.bottom, 5)
                
                Divider()
                    .frame(height: 1)
                    .overlay(Color(hex: bg))
                    .padding(.bottom, 3)
                
                //symptom checkbox
                CustomText(text:"Symptom: ", color: bg, bold: true, textSize: screenWidth * 0.05)

                MultipleCheckboxWrapped(options: $symptomOptions, selected: $selectedSymptom, accent: accent, bg: bg, width: screenWidth * 0.65)
                    .padding(.bottom, 5)
                
                Divider()
                    .frame(height: 1)
                    .overlay(Color(hex: bg))
                    .padding(.bottom, 3)
                
                //date fields
                CustomText(text:"Date Range: ", color: bg, bold: true, textSize: screenWidth * 0.05)
                    .padding(.bottom, 5)
                
                DateTextField(date: $startDate, textValue: $startDateString, bg: .constant(accent), accent: .constant(bg), width: screenWidth / 1.5, label: "Start:", height: 35, fieldTextSize: 16, labelTextSize: screenWidth * 0.045)

                DateTextField(date: $endDate, textValue: $endDateString, bg: .constant(accent), accent: .constant(bg), width: screenWidth / 1.5, label: "End: ", height: 35, fieldTextSize: 16, labelTextSize: screenWidth * 0.045)
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
                CustomButton( text: "Filters",  bg: bg,  accent: accent,  height: screenHeight * 0.06, width: screenWidth -  50,   corner: 30, bold: false,  textSize: screenWidth * 0.055, action: { showFilter.toggle() } )
            }
            .frame(width: screenWidth)
        }
    }
}

//dropdown with no background, for switching analytics view
struct AnalyticsDropdown: View {
    var accent: String
    var bg: String
    var options: [String]
    @Binding var selected: String
    var textSize: CGFloat = UIScreen.main.bounds.width * 0.09
    
    private let screenWidth = UIScreen.main.bounds.width
    @State private var isExpanded = false
    
    var body: some View {
        //used for different sized dropdowns
        let optionTextSize = max(textSize*0.5, 14)
        let labelFont = UIFont.systemFont(ofSize: textSize, weight: .regular)
        let dropdownFont = UIFont.systemFont(ofSize: optionTextSize, weight: .regular)
        let longestWidthForDropdown = options.map { $0.width(usingFont: dropdownFont) }.max() ?? 0
        
        
        VStack(alignment: .trailing, spacing: 6) {
            // Button, can click on label or chevron
            Button(action: {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isExpanded.toggle()
                }}) {
                //text for current view
                HStack(spacing: 5) {
                    CustomText(text: selected, color: accent, width: selected.width(usingFont: labelFont)+15, textAlign: .leading, textSize: textSize )
                    
                    //shape to indicate dropdown
                    Image(systemName: "chevron.down")
                        .resizable()
                        .frame(width: textSize * 0.6, height: textSize * 0.3)
                        .foregroundColor(Color(hex: accent))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.easeInOut(duration: 0.25), value: isExpanded)
                        .padding(.top, 5)
                        .padding(.leading, 2)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            //Show dropdown options when clicked
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(options.indices, id: \.self) { index in
                        let option = options[index]
                        
                        //make each option a button with text, when clicked, it changes selected view and collapses the dropdown
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selected = option
                                isExpanded = false
                            }
                        }) {
                            //each option
                            HStack {
                                CustomText( text: option, color: bg, width: longestWidthForDropdown + 10, textAlign: .center, textSize: optionTextSize)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            //make selected different color
                            .background(option == selected ? Color(hex: accent).opacity(0.55) :  Color(hex: accent) )
                        }
                        .buttonStyle(.plain)
                        
                        if index != options.count - 1 {
                            Divider()
                                .background(Color(hex:bg).opacity(0.7))
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: accent).opacity(0.6), lineWidth: 1) )
                .frame(width: longestWidthForDropdown + 14 * 2 + 15)
                .transition(.move(edge: .top).combined(with: .opacity))
                .padding(.bottom, 7)
            }
        }
    }
}

struct HideButton: View{
    var accent: String
    var bg: String
    @Binding var show: Bool
    
    let screenWidth = UIScreen.main.bounds.width
    
    var body: some View{
        let size = screenWidth * 0.075
        Button(action: { show.toggle() }) {
            Image(systemName: "eye.slash.circle")
                .resizable() // Add this!
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(Color(hex: bg))
                .frame(width: size, height: size)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ShowKeyButton: View{
    var accent: String
    var bg: String
    @Binding var show: Bool
    
    let screenWidth = UIScreen.main.bounds.width
    
    var body: some View{
        let size = screenWidth * 0.075
        
        Button(action: { show.toggle() }) {
            Image(systemName: "info.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(Color(hex:bg))
                .frame(width: size, height: size)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.trailing, 5)
    }
}
