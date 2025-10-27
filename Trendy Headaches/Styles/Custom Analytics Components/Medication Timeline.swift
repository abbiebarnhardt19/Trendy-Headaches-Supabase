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
    
    var body: some View {
        let colorMap = generateMedicationColors()
        
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
            }
            .padding(.vertical, 10)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Spacer()
                    
                    VStack(spacing: 20) {
                        ZStack(alignment: .topLeading) {
                            let timelineWidth = width - 60
                            let markerHeight: CGFloat = 30
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
                                        .frame(width: 2, height: 10)
                                    
                                    let font = UIFont.systemFont(ofSize: 14, weight: .regular)
                                    let title = formatMonthDay(months[index])
                                    CustomText(text: title, color: bg, width: title.width(usingFont: font), textAlign: .center, bold: false, textSize: 14)
                                }
                                .position(x: xPos, y: lineY + 10)
                            }
                            
                            // Medication markers
                            ForEach(Array(medications.enumerated()), id: \.offset) { medIndex, med in
                                let color = colorMap[med.medicationName] ?? Color.gray
                                
                                // Start marker
                                if let startPos = calculatePosition(dateString: med.medicationStart, totalWidth: timelineWidth) {
                                    VStack(spacing: 3) {
                                        
                                        let font = UIFont.systemFont(ofSize: 12, weight: .regular)
                                        let startText = "\(med.medicationName) Start"
                                        CustomText(text: startText, color: bg, width: startText.width(usingFont: font), textAlign: .center, multiAlign: .center, textSize: 12)
                                        
                                        Rectangle()
                                            .fill(color)
                                            .frame(width: 2, height: markerHeight)
                                    }
                                    .position(x: startPos, y: lineY - markerHeight / 2 - 10)
                                    .onTapGesture {
                                        selectedMed = med
                                        showPopup = true
                                    }
                                    
                                    Circle()
                                        .fill(color)
                                        .frame(width: 8, height: 8)
                                        .position(x: startPos, y: lineY )
                                }
                                
                                // End marker
                                if let endString = med.medicationEnd, !endString.isEmpty,
                                   let endPos = calculatePosition(dateString: endString, totalWidth: timelineWidth) {
                                    VStack(spacing: 3) {
                                        
                                        let font = UIFont.systemFont(ofSize: 12, weight: .regular)
                                        let endText = "\(med.medicationName) End"
                                        CustomText(text: endText, color: bg, width: endText.width(usingFont: font), textAlign: .center, multiAlign: .center, textSize: 12)
                                        
                                        Rectangle()
                                            .fill(color)
                                            .frame(width: 2, height: markerHeight)
                                    }
                                    .position(x: endPos, y: lineY - markerHeight / 2 - 10)
                                    .onTapGesture {
                                        selectedMed = med
                                        showPopup = true
                                    }
                                    
                                    Circle()
                                        .fill(color)
                                        .frame(width: 8, height: 8)
                                        .position(x: endPos, y: lineY )
                                }
                            }
                        }
                        .frame(width: width - 60, height: 70)
                    }
                    .padding(.vertical, 20)
                    .padding(.bottom, 20)
                    
                    Spacer()
                }
            }
        }
        .background(Color(hex: accent))
        .cornerRadius(20)
        .frame(width: width)
        .padding(.bottom, 10)
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
    
    private func generateMedicationColors() -> [String: Color] {
        let baseColor = Color(hex: bg)
        let colors = baseColor.generateColors(from: baseColor, count: medications.count)
        return Dictionary(uniqueKeysWithValues: zip(medications.map { $0.medicationName }, colors))
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
        
        let totalTimeRange = maxDate.timeIntervalSince(minDate)
        let offset = date.timeIntervalSince(minDate)
        return CGFloat(offset / totalTimeRange) * totalWidth
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
        formatter.dateFormat = "MMM yy"
        return formatter.string(from: date)
    }
}
