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
            CustomButton( text: "\(chart)",  bg: bg,  accent: accent,  height: screenHeight * 0.06, width: screenWidth -  50,   corner: 30, bold: false,  textSize: screenWidth * 0.055, action: { hideChart.toggle() } )
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
            .frame(width: screenWidth - 40, alignment: .leading)
            .padding(.bottom, 10)
        }

        else {
            HStack {
                
                CustomButton( text: "Select Symptom",  bg: bg,  accent: accent,  height: screenHeight * 0.06, width: screenWidth -  50,   corner: 30, bold: false,  textSize: screenWidth * 0.055, action: { showSymptomFilter.toggle() } )
            }
            .frame(width: screenWidth)
        }
    }
}

struct analyticsDropdown: View {
    var accent: String
    var bg: String
    @Binding var selectedView: String

    private let options = ["Graphs", "Statistics", "Comparisons"]
    private let screenWidth = UIScreen.main.bounds.width
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .trailing, spacing: 6) {
            // Label button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 5) {
                    let font = UIFont.systemFont(ofSize: screenWidth * 0.09 + 5, weight: .regular)

                    CustomText(
                        text: selectedView,
                        color: accent,
                        width: selectedView.width(usingFont: font),
                        textSize: screenWidth * 0.09
                    )

                    Image(systemName: "chevron.down")
                        .resizable()
                        .frame(width: screenWidth * 0.05, height: screenWidth * 0.05 / 2)
                        .foregroundColor(Color(hex: accent))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.easeInOut(duration: 0.25), value: isExpanded)
                        .padding(.top, 4)
                }
                .padding(.horizontal, 10)
                .padding(.top, 35)
            }

            // Dropdown menu
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(options.indices, id: \.self) { index in
                        let option = options[index]

                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedView = option
                                isExpanded = false
                            }
                        }) {
                            let font = UIFont.systemFont(ofSize: screenWidth * 0.055 + 5, weight: .regular)
                            HStack {
                                CustomText(
                                    text: option,
                                    color: bg,
                                    width: "Comparisons".width(usingFont: font),
                                    textAlign: .center,
                                    textSize: screenWidth * 0.055
                                )
                                Spacer()
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(option == selectedView ? Color(hex: accent).opacity(0.55) :  Color(hex: accent) )
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
                .shadow(radius: 2)
                .frame(width: "Comparisons".width(usingFont: UIFont.systemFont(ofSize: screenWidth * 0.055 + 5)) + 40)
                .transition(.move(edge: .top).combined(with: .opacity))
                .padding(.bottom, 10)
                .padding(.top, 5)
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.trailing, 20)
    }
       
}
