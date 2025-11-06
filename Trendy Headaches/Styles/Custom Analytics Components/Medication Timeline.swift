//
//  Medication Table.swift
//  Trendy Headaches Supabase
//
//  Created by Abigail Barnhardt on 10/26/25.
//
import SwiftUI

struct MedicationTimeline: View {
    var medications: [Medication]
    var bg: String
    var accent: String
    var width: CGFloat
    
    @State private var selectedMed: Medication? = nil
    @State private var showPopup: Bool = false
    @State private var popupPosition: CGPoint = .zero
    @State private var showKey: Bool = false
    @State private var showVisual: Bool = false
    
    var body: some View {
        let colorMap = generateMedicationColors(bg: bg, medications: medications)
        
        if showVisual{
            ZStack {
                VStack(spacing: 0) {
                    // Title and Hide button
                    HStack {
                        let font = UIFont.systemFont(ofSize: 19, weight: .bold)
                        let title = "Treatment Timeline"
                        CustomText(text:title, color:bg, width: title.width(usingFont: font) + 15, textAlign:.center,bold: true, textSize: 19)
                            .padding(.leading, 20)
                        
                        Spacer()
                        
                        HStack{
                            Button(action: { showKey.toggle() }) {
                                Image(systemName: "info.circle")
                                    .resizable() // Add this!
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundStyle(Color(hex:bg))
                                    .frame(width: 25, height: 25)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.trailing, 5)
                            
                            Button(action: { showVisual.toggle() }) {
                                Image(systemName: "eye.slash.circle")
                                    .resizable() // Add this!
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundStyle(Color(hex: bg))
                                    .frame(width: 25, height: 25)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 10)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            Spacer()
                            
                            VStack(spacing: 20) {
                                ZStack(alignment: .topLeading) {
                                    let timelineWidth = width - 60
                                    let lineY: CGFloat = 60
                                    
                                    // Horizontal line
                                    Rectangle()
                                        .fill(Color(hex: bg))
                                        .frame(width: timelineWidth, height: 2)
                                        .position(x: timelineWidth / 2, y: lineY)
                                    
                                    // Monthly ticks with dates below
                                    let months = calculateMonthlyTicks(medications: medications)
                                    ForEach(0..<months.count, id: \.self) { index in
                                        let xPos = CGFloat(index) / CGFloat(max(1, months.count - 1)) * timelineWidth
                                        
                                        VStack(spacing: 5) {
                                            Rectangle()
                                                .fill(Color(hex: bg))
                                                .frame(width: 3, height: 10)
                                            
                                            let font = UIFont.systemFont(ofSize: 14, weight: .regular)
                                            let title = formatMonthDay(months[index])
                                            CustomText(text: title, color: bg, width: "####".width(usingFont: font), textAlign: .center, multiAlign: .center, bold: false, textSize: 14)
                                        }
                                        .position(x: xPos, y: lineY + 20)
                                    }
                                    
                                    // Medication staple shapes
                                    let stapleHeights = calculateStapleHeights(totalWidth: timelineWidth, medications: medications)

                                    ForEach(Array(medications.enumerated()), id: \.offset) { medIndex, med in
                                        let color = colorMap[med.medicationName] ?? Color.gray
                                        let markerHeight = stapleHeights[medIndex] ?? 40
                                        
                                        if let startPos = calculatePosition(dateString: med.medicationStart, totalWidth: timelineWidth, medications: medications) {
                                            
                                            if let endString = med.medicationEnd, !endString.isEmpty,
                                               let endPos = calculatePosition(dateString: endString, totalWidth: timelineWidth, medications: medications) {
                                                let centerX = (startPos + endPos) / 2
                                                
                                                // Staple shape connecting start to end
                                                Path { path in
                                                    path.move(to: CGPoint(x: startPos, y: lineY))
                                                    path.addLine(to: CGPoint(x: startPos, y: lineY - markerHeight))
                                                    path.addLine(to: CGPoint(x: endPos, y: lineY - markerHeight))
                                                    path.addLine(to: CGPoint(x: endPos, y: lineY))
                                                }
                                                .stroke(color, lineWidth: 5)
                                                .onTapGesture {
                                                    selectedMed = med
                                                    popupPosition = CGPoint(x: centerX, y: lineY - markerHeight - 15)
                                                    showPopup = true
                                                }
                                                
                                                // Circles at start and end
                                                Circle()
                                                    .fill(color)
                                                    .frame(width: 10, height: 10)
                                                    .position(x: startPos, y: lineY)
                                                    .onTapGesture {
                                                        selectedMed = med
                                                        popupPosition = CGPoint(x: centerX, y: lineY - markerHeight - 15)
                                                        showPopup = true
                                                    }
                                                
                                                Circle()
                                                    .fill(color)
                                                    .frame(width: 10, height: 10)
                                                    .position(x: endPos, y: lineY)
                                                    .onTapGesture {
                                                        selectedMed = med
                                                        popupPosition = CGPoint(x: centerX, y: lineY - markerHeight - 15)
                                                        showPopup = true
                                                    }
                                                
                                            } else {
                                                // Medication with no end date - rotated L shape (up then right)
                                                let extensionLength: CGFloat = 30
                                                
                                                Path { path in
                                                    path.move(to: CGPoint(x: startPos, y: lineY))
                                                    path.addLine(to: CGPoint(x: startPos, y: lineY - markerHeight))
                                                    path.addLine(to: CGPoint(x: startPos + extensionLength, y: lineY - markerHeight))
                                                }
                                                .stroke(color, lineWidth: 5)
                                                .onTapGesture {
                                                    selectedMed = med
                                                    popupPosition = CGPoint(x: startPos - 110, y: lineY - markerHeight / 2)
                                                    showPopup = true
                                                }
                                                
                                                Circle()
                                                    .fill(color)
                                                    .frame(width: 10, height: 10)
                                                    .position(x: startPos, y: lineY)
                                                    .onTapGesture {
                                                        selectedMed = med
                                                        popupPosition = CGPoint(x: startPos - 80, y: lineY - markerHeight / 2)
                                                        showPopup = true
                                                    }
                                            }
                                        }
                                    }
                                    
                                    // Small bubble popup
                                    if showPopup, let med = selectedMed {
                                        VStack(alignment: .leading, spacing: 5) {
                                            let font = UIFont.systemFont(ofSize: 14, weight: .regular)
                                            HStack {
                                                CustomText(text: "Treatment: ", color: accent, width: "Treatment: ".width(usingFont: font) + 7, bold: true, textSize: 14)
                                                CustomText(text: med.medicationName, color: accent, width: med.medicationName.width(usingFont: font)+7, bold: false, textSize: 14)
                                            }
                                            HStack {
                                                let med_start = formatDateShort(med.medicationStart)
                                                CustomText(text: "Start: ", color: accent, width: "Start: ".width(usingFont: font)+7, bold: true, textSize: 14)
                                                CustomText(text: med_start, color: accent, width: med_start.width(usingFont: font)+7, bold: false, textSize: 14)
                                            }
                                            
                                            HStack {
                                                let med_end = formatDateShort(med.medicationEnd)
                                                CustomText(text: "End: ", color: accent, width: "End: ".width(usingFont: font)+7, bold: true, textSize: 14)
                                                CustomText(text: med_end, color: accent, width: med_end.width(usingFont: font)+7, bold: false, textSize: 14)
                                            }
                                            
                                            if !med.medicationCategory.isEmpty {
                                                HStack{
                                                    CustomText(text: "Category: ", color: accent, width: "Category: ".width(usingFont: font)+7, bold: true, textSize: 14)
                                                    CustomText(text: med.medicationCategory, color: accent, width: med.medicationCategory.width(usingFont: font)+7, bold: false, textSize: 14)
                                                }
                                            }
                                        }
                                        .padding(8)
                                        .background(Color(hex: bg))
                                        .cornerRadius(8)
                                        .position(x: popupPosition.x, y: popupPosition.y - 45)
                                        .onTapGesture {
                                            showPopup = false
                                        }
                                    }
                                }
                                .padding(.top, showPopup ? 45 : 0)
                                .frame(width: width - 60, height: getFrameHeight(showPopup: showPopup, width: width, medications: medications))
                            }
                            .padding(.top, 20)
                            .padding(.leading, 22)
                            
                            Spacer()
                        }
                        if showKey{
                            MedKey(colorMap: colorMap, bg: bg, width: width-60)
                        }
                        
                    }
                }
                .background(Color(hex: accent))
                .cornerRadius(20)
                .frame(width: width)
                .padding(.bottom, 10)
                .contentShape(Rectangle())
                .onTapGesture {
                    if showPopup {
                        showPopup = false
                    }
                }
            }
            .onTapGesture {
                showPopup = false
            }
        }
        else{
            HiddenChart(bg: bg, accent: accent, chart: "Treatment Timeline", hideChart: $showVisual)
        }
        
    }
}


struct MedKey: View {
    var colorMap: [String: Color]
    var bg: String
    var width: CGFloat
    var itemHeight: CGFloat = 13
    
    var body: some View {
        let rows = rowsForKey(items: colorMap.sorted(by: { $0.key < $1.key }), width: width, text: { $0.key }, iconWidth: 10, iconTextGap: 4, horizontalPadding: 8, mapResult: { (key, color) in (key, color) }) as! [[(String, Color)]]
        
        VStack(alignment: .leading, spacing: 8) {
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack(spacing: 10) {
                    ForEach(0..<rows[rowIndex].count, id: \.self) { itemIndex in
                        let item = rows[rowIndex][itemIndex]
                        HStack(spacing: 4) {
                            Circle()
                                .frame(width: itemHeight, height: itemHeight)
                                .foregroundColor(item.1)
                            CustomText(
                                text: String(item.0.prefix(12)),
                                color: bg,
                                textSize: 12
                            )
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .fixedSize(horizontal: true, vertical: false)
                        }
                        .padding(.vertical, 2)
                        .padding(.horizontal, 4)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(width: width, alignment: .leading)
        .padding(.bottom, 10)
    }
}
