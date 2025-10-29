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
            CustomButton( text: "\(chart)",  bg: bg,  accent: accent,  height: screenHeight * 0.06, width: screenWidth -  30,   corner: 30, bold: false,  textSize: screenWidth * 0.055, action: { hideChart.toggle() } )
        }
        .frame(width: screenWidth)
    }
}

struct filterSymptom: View {
    var bg: String
    var accent: String
    @Binding var symptomOptions: [String]
    @Binding var selectedSymptom : [String]
    
    @State private var showSymptomFilter: Bool = false
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        if showSymptomFilter {
            VStack(alignment: .leading, spacing: 10) {
                HStack{
                    CustomText(text:"Select Symptom: ", color: bg, textSize: screenWidth * 0.055)
                    
                    CustomButton(text: "Hide", bg: accent, accent: bg, height: 30, width: 50, textSize: 14) {
                        showSymptomFilter.toggle()
                    }
                }
                
                MultipleCheckboxWrapped(options: $symptomOptions, selected: $selectedSymptom, accent: accent, bg: bg, width: screenWidth * 0.7)
            }
            .padding(.horizontal, 15)
            .padding(.top, 10)
            .padding(.bottom, 20)
            .background(Color(hex:accent))
            .cornerRadius(20)
            .frame(maxWidth: screenWidth * 0.9, alignment: .leading)
            .padding(.bottom, 10)
        }

        else {
            HStack {
                
                CustomButton( text: "Select Symptom",  bg: bg,  accent: accent,  height: screenHeight * 0.06, width: screenWidth -  30,   corner: 30, bold: false,  textSize: screenWidth * 0.055, action: { showSymptomFilter.toggle() } )
            }
            .frame(width: screenWidth)
        }
    }
}

struct analyticsDropdown: View {
    var accent: String
    var bg: String
    @Binding var selectedView: String
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    let options = ["Graph", "Statistics", "Comparisons"]
    
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            HStack(spacing: 5) {
                Spacer()
                
                let font = UIFont.systemFont(ofSize: screenWidth * 0.1 + 5, weight: .regular)
                
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    HStack(spacing: 5) {
                        CustomText(
                            text: selectedView,
                            color: accent,
                            width: selectedView.width(usingFont: font),
                            textSize: screenWidth * 0.1
                        )
                        
                        // Caret / arrow
                        Image(systemName: "chevron.down")
                            .resizable()
                            .frame(width: screenWidth * 0.05, height: screenWidth * 0.05 / 2)
                            .foregroundColor(Color(hex:accent))
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                            .animation(.easeInOut(duration: 0.2), value: isExpanded)
                            .padding(.trailing, 25)
                            .padding(.top, 5)
                    }
                }
            }
            
            // Dropdown list
            if isExpanded {
                VStack(alignment: .trailing, spacing: 5) {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            selectedView = option
                            withAnimation {
                                isExpanded = false
                            }
                        }) {
                            Text(option)
                                .foregroundColor(.primary)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(5)
                    }
                }
                .padding(.trailing, 20)
                .padding(.top,10)
            }
        }
        .frame(width: screenWidth)
        .padding(.top, 25)
        .padding(.bottom, 15)
    }
}
