//
//  Custom Analytics Components.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/2/25.
//

import SwiftUI

struct HiddenChart: View {
    var bg: String
    var accent: String
    var chart: String
    @Binding var hideChart: Bool
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        HStack {
            CustomButton( text: "\(chart)",  bg: bg,  accent: accent,  height: screenHeight * 0.06, width: screenWidth -  50,   corner: 30, bold: false,  textSize: screenWidth * 0.05, action: { hideChart.toggle() } )
        }
        .frame(width: screenWidth)
    }
}

struct AnalyticsFilter: View {
    var bg: String
    var accent: String
    @Binding var symptomOptions: [String]
    @Binding var selectedSymptom : [String]
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var selectedTypes:[String]
    
    @State private var showSymptomFilter: Bool = false
    
    // Date Formatter
    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    @State var typeOptions = ["Symptom", "Side Effect"]
    
    var body: some View {
        
        @State var startDateString = formatter.string(from: startDate)
        @State var endDateString = formatter.string(from: endDate)
        
        if showSymptomFilter {
            VStack(alignment: .leading, spacing: 10) {
                HStack{
                    CustomText(text:"Select Log Type: ", color: bg, bold: true, textSize: screenWidth * 0.05)
                    
                    Button(action: { showSymptomFilter.toggle() }) {
                        Image(systemName: "eye.slash.circle")
                            .resizable() // Add this!
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(Color(hex: bg))
                            .frame(width: 25, height: 25)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                MultipleCheckboxWrapped(options: $typeOptions, selected: $selectedTypes, accent: accent, bg: bg, width: screenWidth * 0.65)
                    .padding(.bottom, 5)
                
                CustomText(text:"Select Symptom: ", color: bg, bold: true, textSize: screenWidth * 0.05)

                MultipleCheckboxWrapped(options: $symptomOptions, selected: $selectedSymptom, accent: accent, bg: bg, width: screenWidth * 0.65)
                    .padding(.bottom, 5)
                
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

        else {
            HStack {
                
                CustomButton( text: "Filters",  bg: bg,  accent: accent,  height: screenHeight * 0.06, width: screenWidth -  50,   corner: 30, bold: false,  textSize: screenWidth * 0.05, action: { showSymptomFilter.toggle() } )
            }
            .frame(width: screenWidth)
        }
    }
}

struct AnalyticsDropdown: View {
    var accent: String
    var bg: String
    var options: [String]
    @Binding var selected: String
    var textSize: CGFloat = UIScreen.main.bounds.width * 0.09
    
    private let screenWidth = UIScreen.main.bounds.width
    @State private var isExpanded = false
    
    var body: some View {
        let optionTextSize = max(textSize*0.5, 14)
        let labelFont = UIFont.systemFont(ofSize: textSize, weight: .regular)
        let dropdownFont = UIFont.systemFont(ofSize: optionTextSize, weight: .regular)
        let longestWidthForDropdown = options.map { $0.width(usingFont: dropdownFont) }.max() ?? 0
        
        
        VStack(alignment: .trailing, spacing: 6) {
            // Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 5) {
                    CustomText(
                        text: selected,
                        color: accent,
                        width: selected.width(usingFont: labelFont)+15,
                        textAlign: .leading,
                        textSize: textSize
                    )
                    
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
            
            // Expanded menu (appears below button)
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(options.indices, id: \.self) { index in
                        let option = options[index]
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selected = option
                                isExpanded = false
                            }
                        }) {
                            HStack {
                                CustomText(
                                    text: option,
                                    color: bg,
                                    width: longestWidthForDropdown + 10,
                                    textAlign: .center,
                                    textSize: optionTextSize
                                )
                                Spacer()
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
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
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: accent).opacity(0.6), lineWidth: 1)
                )
                .frame(width: longestWidthForDropdown + 14 * 2 + 15)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}
