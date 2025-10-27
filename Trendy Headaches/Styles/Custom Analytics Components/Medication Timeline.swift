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
    @Binding var hideTimeline: Bool
    
    @State private var selectedMed: Medication? = nil
    @State private var showPopup: Bool = false
    @State private var popupPosition: CGPoint = .zero
    
    var body: some View {
        let colorMap = generateMedicationColors()
        
        ZStack {
            VStack(spacing: 0) {
                // Title and Hide button
                HStack {
                    CustomText(text: "Medication Timeline", color: bg, bold: true, textSize: 18)
                        .padding(.leading, 20)
                    
                    Spacer()
                    
                    CustomButton(text: "Hide", bg: accent, accent: bg, height: 30, width: 50, textSize: 14) {
                        hideTimeline.toggle()
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
                                let markerHeight: CGFloat = 40
                                let lineY: CGFloat = 60
                                
                                // Horizontal line
                                Rectangle()
                                    .fill(Color(hex: bg))
                                    .frame(width: timelineWidth, height: 2)
                                    .position(x: timelineWidth / 2, y: lineY)
                                
                                // Monthly ticks with dates below
                                let months = calculateMonthlyTicks()
                                ForEach(0..<months.count, id: \.self) { index in
                                    let xPos = CGFloat(index) / CGFloat(max(1, months.count - 1)) * timelineWidth
                                    
                                    VStack(spacing: 5) {
                                        Rectangle()
                                            .fill(Color(hex: bg))
                                            .frame(width: 3, height: 10)
                                        
                                        let font = UIFont.systemFont(ofSize: 14, weight: .regular)
                                        let title = formatMonthDay(months[index])
                                        CustomText(text: title, color: bg, width: title.width(usingFont: font), textAlign: .center, multiAlign: .center, bold: false, textSize: 14)
                                    }
                                    .position(x: xPos, y: lineY + 20)
                                }
                                
                                // Medication staple shapes
                                // Medication staple shapes
                                let stapleHeights = calculateStapleHeights(totalWidth: timelineWidth)
                                let maxHeight = stapleHeights.values.max() ?? 40
                                let frameHeight = maxHeight + 80 // Add extra space for labels and padding

                                ForEach(Array(medications.enumerated()), id: \.offset) { medIndex, med in
                                    let color = colorMap[med.medicationName] ?? Color.gray
                                    let markerHeight = stapleHeights[medIndex] ?? 40
                                    
                                    if let startPos = calculatePosition(dateString: med.medicationStart, totalWidth: timelineWidth) {
                                        
                                        if let endString = med.medicationEnd, !endString.isEmpty,
                                           let endPos = calculatePosition(dateString: endString, totalWidth: timelineWidth) {
                                            let centerX = (startPos + endPos) / 2
                                            
                                            // Staple shape connecting start to end
                                            Path { path in
                                                path.move(to: CGPoint(x: startPos, y: lineY))
                                                path.addLine(to: CGPoint(x: startPos, y: lineY - markerHeight))
                                                path.addLine(to: CGPoint(x: endPos, y: lineY - markerHeight))
                                                path.addLine(to: CGPoint(x: endPos, y: lineY))
                                            }
                                            .stroke(color, lineWidth: 3)
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
                                            .stroke(color, lineWidth: 3)
                                            .onTapGesture {
                                                selectedMed = med
                                                popupPosition = CGPoint(x: startPos - 80, y: lineY - markerHeight / 2)
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
                                        let font = UIFont.systemFont(ofSize: 10, weight: .regular)
                                        HStack {
                                            CustomText(text: "Treatment: ", color: accent, width: "Treatment: ".width(usingFont: font) + 5, bold: true, textSize: 10)
                                            CustomText(text: med.medicationName, color: accent, width: med.medicationName.width(usingFont: font)+5, bold: false, textSize: 10)
                                        }
                                        HStack {
                                            let med_start = formatDateShort(med.medicationStart)
                                            CustomText(text: "Start: ", color: accent, width: "Start: ".width(usingFont: font)+5, bold: true, textSize: 10)
                                            CustomText(text: med_start, color: accent, width: med_start.width(usingFont: font)+5, bold: false, textSize: 10)
                                        }
                                        
                                        HStack {
                                            let med_end = formatDateShort(med.medicationEnd)
                                            CustomText(text: "End: ", color: accent, width: "End: ".width(usingFont: font)+5, bold: true, textSize: 10)
                                            CustomText(text: med_end, color: accent, width: med_end.width(usingFont: font)+5, bold: false, textSize: 10)
                                        }
                                        
                                        if !med.medicationCategory.isEmpty {
                                            HStack{
                                                CustomText(text: "Category: ", color: accent, width: "Category: ".width(usingFont: font)+5, bold: true, textSize: 10)
                                                CustomText(text: med.medicationCategory, color: accent, width: med.medicationCategory.width(usingFont: font)+5, bold: false, textSize: 10)
                                            }
                                        }
                                    }
                                    .padding(8)
                                    .background(Color(hex: bg))
                                    .cornerRadius(8)
                                    .position(x: popupPosition.x, y: popupPosition.y - 35)
                                    .onTapGesture {
                                        showPopup = false
                                    }
                                }
                            }
                            .padding(.top, showPopup ? 25 : 0)
                            .frame(width: width - 60, height: getFrameHeight())
                        }
                        .padding(.top, 20)
                        .padding(.leading, 22)
                        
                        Spacer()
                    }
                }
            }
            .background(Color(hex: accent))
            .cornerRadius(20)
            .frame(width: width)
            .padding(.bottom, 10)
        }
        .onTapGesture {
            // Dismiss popup when tapping outside
            showPopup = false
        }
    }
    
    private func formatDateShort(_ dateString: String?) -> String {
        guard let dateString = dateString, !dateString.isEmpty else {
            return "Active"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        formatter.dateFormat = "M/d/yy"
        return formatter.string(from: date)
    }
    
    private func calculateMonthlyTicks() -> [Date] {
        guard let minDate = getMinDate(), let maxDate = getMaxDate() else {
            return []
        }
        
        let calendar = Calendar.current
        var currentDate = calendar.date(from: calendar.dateComponents([.year, .month], from: minDate))!
        var months: [Date] = []
        
        while currentDate <= maxDate {
            months.append(currentDate)
            guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentDate) else { break }
            currentDate = nextMonth
        }
        
        return months
    }

    private func calculatePosition(dateString: String, totalWidth: CGFloat) -> CGFloat? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = dateFormatter.date(from: dateString),
              let minDate = getMinDate(),
              let maxDate = getMaxDate() else {
            return nil
        }
        
        if minDate == maxDate {
            return totalWidth / 2
        }
        
        let calendar = Calendar.current
        guard let firstDayOfMinMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: minDate)),
              let firstDayOfMaxMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: maxDate)) else {
            return nil
        }
        
        guard let endOfTimeline = calendar.date(byAdding: .month, value: 1, to: firstDayOfMaxMonth) else {
            return nil
        }
        
        let totalTimeRange = endOfTimeline.timeIntervalSince(firstDayOfMinMonth)
        let offset = date.timeIntervalSince(firstDayOfMinMonth)
        return CGFloat(offset / totalTimeRange) * totalWidth
    }
    
    private func generateMedicationColors() -> [String: Color] {
        let baseColor = Color(hex: bg)
        let colors = baseColor.generateColors(from: baseColor, count: medications.count)
        return Dictionary(uniqueKeysWithValues: zip(medications.map { $0.medicationName }, colors))
    }
    
    private func getMinDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let allDates = medications.compactMap { dateFormatter.date(from: $0.medicationStart) } +
                       medications.compactMap { med in
                           guard let endString = med.medicationEnd, !endString.isEmpty else { return nil }
                           return dateFormatter.date(from: endString)
                       }
        
        return allDates.min()
    }
    
    private func getMaxDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let allDates = medications.compactMap { dateFormatter.date(from: $0.medicationStart) } +
                       medications.compactMap { med in
                           guard let endString = med.medicationEnd, !endString.isEmpty else { return nil }
                           return dateFormatter.date(from: endString)
                       }
        
        let maxFromData = allDates.max()
        return maxFromData ?? Date()
    }
    
    private func formatDate(_ dateString: String?) -> String {
        guard let dateString = dateString, !dateString.isEmpty else {
            return "Active"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func formatMonthDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM\nyyyy"
        return formatter.string(from: date)
    }
    
    private func calculateStapleHeights(totalWidth: CGFloat) -> [Int: CGFloat] {
        var heights: [Int: CGFloat] = [:]
        var usedRanges: [(start: CGFloat, end: CGFloat, height: CGFloat)] = []
        let baseHeight: CGFloat = 15
        let heightIncrement: CGFloat = 3 // Changed from 25 to 15
        
        for (index, med) in medications.enumerated() {
            var height = baseHeight
            
            if let startPos = calculatePosition(dateString: med.medicationStart, totalWidth: totalWidth) {
                let endPos: CGFloat
                
                if let endString = med.medicationEnd, !endString.isEmpty,
                   let calculatedEndPos = calculatePosition(dateString: endString, totalWidth: totalWidth) {
                    endPos = calculatedEndPos
                } else {
                    // For active meds, use start pos + extension length
                    endPos = startPos + 30
                }
                
                // Check for overlaps with existing staples
                var overlaps = true
                while overlaps {
                    overlaps = false
                    for range in usedRanges {
                        // Check if horizontal ranges overlap and heights are similar
                        let horizontalOverlap = !(endPos < range.start || startPos > range.end)
                        let heightDiff = abs(height - range.height)
                        
                        if horizontalOverlap && heightDiff < 20 { // Changed from 30 to 20
                            overlaps = true
                            height += heightIncrement
                            break
                        }
                    }
                }
                
                heights[index] = height
                usedRanges.append((start: startPos, end: endPos, height: height))
            }
        }
        
        return heights
    }
    
//    private func getFrameHeight() -> CGFloat {
//        let timelineWidth = width - 60
//        let stapleHeights = calculateStapleHeights(totalWidth: timelineWidth)
//        let maxHeight = stapleHeights.values.max() ?? 40
//        return maxHeight + 60
//    }
    
    private func getFrameHeight() -> CGFloat {
        let timelineWidth = width - 60
        let stapleHeights = calculateStapleHeights(totalWidth: timelineWidth)
        let maxHeight = stapleHeights.values.max() ?? 40
        let baseHeight = maxHeight + 60
        
        // If popup is showing and positioned high, add extra space
        if showPopup  {
            return baseHeight + 30 // Add popup height
        }
        
        return baseHeight
    }
}
