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
    var width: CGFloat
    @Binding var hideChart: Bool
    
    var body: some View {
        HStack {
            CustomButton( text: "Show \(chart) Visual",  bg: bg,  accent: accent,  height: 50, width: UIScreen.main.bounds.width -  30,   corner: 30, bold: false,  textSize: 22, action: { hideChart.toggle() } )
        }
        .frame(width: width)
    }
}


struct analyticsFilter: View {
    @State var accent: String
    @State var bg: String
    @Binding var start: Date
    @Binding var end: Date
    @Binding var stringStart: String
    @Binding var stringEnd: String
    @Binding var sympOptions: [String]
    @Binding var selectedSymps: [String]
    
    @State private var expandedWidth: CGFloat = 215
    @State private var unexpandedWidth: CGFloat = 255
    
    enum FilterSection {
        case none, columns, logType, date, severity, symptoms
    }
    
    @State private var expandedSection: FilterSection = .none
    @State private var dropdownWidths: [FilterSection: (collapsed: CGFloat, expanded: CGFloat)] = [.columns: (100, 315), .logType: (100, 140),  .date: (55, 270),  .severity: (90, 190),  .symptoms: (120, 300)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            // MARK: Date
            sectionButton(title: "Date", section: .date) {
                VStack {
                    DateTextField(date: $start, textValue: $stringStart, bg: $accent,  accent: $bg, width: 155, label: "Start:", bold: false)
                        .padding(.top, 10)
                    
                    DateTextField(date: $end, textValue: $stringEnd, bg: $accent,  accent: $bg, width: 155, label: "End:", bold: false)
                }
                .padding(.leading, 5)
            }
            
            // MARK: Symptoms
            sectionButton(title: "Symptoms", section: .symptoms) {
                
                MultipleCheckboxWrapped(options: $sympOptions, selected: $selectedSymps, accent: accent,  bg: bg, width: expandedWidth)
                .padding(.top, 10)
            }
        }
        .padding(10)
        .padding(.trailing, 10)
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
            .stroke(Color(hex: bg), lineWidth: 5))
        .background(Color(hex: accent))
        .cornerRadius(20)
        .padding(.bottom, 20)
    }
    
    // MARK: Section Button Helper
    @ViewBuilder
    private func sectionButton<Content: View>(
        title: String,
        section: FilterSection,
        @ViewBuilder content: () -> Content
    ) -> some View {
        let widths = dropdownWidths[section] ?? (300, 300)
        let expandedWidth = widths.expanded
        let isExpanded = expandedSection == section
        
        let currentWidth: CGFloat = {
            if let activeWidths = dropdownWidths[expandedSection] {
                return expandedSection == .none ? widths.collapsed : activeWidths.expanded
            } else {
                return widths.collapsed
            }
        }()
        
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 5) {
                CustomText(text: title, color: bg,  width: currentWidth, textAlign: .leading, bold: true)
                
                Button(action: {
                    withAnimation(.easeInOut) {
                        self.expandedSection = isExpanded ? .none : section
                    }
                }) {
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: bg))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 5)
                
            if isExpanded {
                content()
                    .frame(width: expandedWidth, alignment: .leading)
            }
        }
        .frame(width: isExpanded ? currentWidth : 160, alignment: .leading)
    }
}
