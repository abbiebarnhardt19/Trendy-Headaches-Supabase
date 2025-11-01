//
//  Med Taken Calendar.swift
//  Trendy Headaches Supabase
//
//  Created by Abigail Barnhardt on 10/30/25.
//

import SwiftUI

struct MedTakenCalendarView: View {
    let logs: [UnifiedLog]
    var bg: String
    var accent: String

    @State private var currentMonth = Date()
    @State private var showKey = false
    private let calendar = Calendar.current
    private let weekDays = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    private let width = UIScreen.main.bounds.width - 80
    let maxMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))!
    
    @State var showVisual: Bool = false
    
    // Generate medication colors based on unique medications
    private var medicationColors: [String: Color] {
        
        
        let uniqueMeds = Array(Set(logs.compactMap { log -> String? in
            guard log.med_taken == true, let medName = log.medication_name else { return nil }
            return medName
        })).sorted()
        
        guard !uniqueMeds.isEmpty else { return [:] }
        
        let colors: [Color]
        if uniqueMeds.count == 1 {
            // For a single medication, use the base accent color
            colors = [Color(hex: bg)]
        } else {
            colors = Color(hex: accent).generateColors(from: Color(hex: accent), count: uniqueMeds.count)
        }
        
        var result: [String: Color] = [:]
        for i in 0..<min(uniqueMeds.count, colors.count) {
            result[uniqueMeds[i]] = colors[i]
        }
        return result
    }

    var body: some View {
        if showVisual{
            VStack(spacing: 10) {
                TopBar
                WeekdayLabels
                CalendarGrid
                if showKey {
                    MedicationKey(bg: bg, accent: accent, width: width, medicationColors: medicationColors)
                }
            }
            .frame(width: width)
            .padding()
            .background(Color(hex: accent))
            .cornerRadius(20)
            .padding(.bottom, 10)
        }
        else{
            HiddenChart(bg: bg, accent: accent, chart: "Emergency Treatment Calendar", hideChart: $showVisual)
        }
    }

    //calendar parts
    private var TopBar: some View {
        HStack(spacing: 8) {
            CustomButton(systemImage: "chevron.left", bg: bg, accent: accent, height: 20, width: 12) {currentMonth = changeMonth(currentMonth: currentMonth, by: -1)}
            
            let font = UIFont.systemFont(ofSize: 19, weight: .regular)
            let title = monthYearString(for: currentMonth)
            CustomText(text: title, color: bg, width: title.width(usingFont: font), textAlign: .center, textSize: 19)
                .padding(.bottom, 9)
            
            CustomButton(systemImage: "chevron.right", bg: bg, accent: accent, height: 20, width: 12, disabled: currentMonth >= maxMonth) {currentMonth = changeMonth(currentMonth: currentMonth, by: 1)}
            
            Spacer()
            
            Button(action: { showKey.toggle() }) {
                Image(systemName: "info.circle")
                    .resizable() // Add this!
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(Color(hex:bg))
                    .frame(width: 25, height: 25)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.trailing, 5)
            .padding(.bottom, 5)
            
            Button(action: { showVisual.toggle() }) {
                Image(systemName: "eye.slash.circle")
                    .resizable() // Add this!
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(Color(hex: bg))
                    .frame(width: 25, height: 25)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.bottom, 5)
        }
        .frame(height: 20)
    }

    private var WeekdayLabels: some View {
        HStack {
            ForEach(weekDays, id: \.self) { day in
                CustomText(text: day, color: bg, textAlign: .center, textSize: 14)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    //lay out the days on the grid
    private var CalendarGrid: some View {
        let days = makeDays(for: currentMonth)
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
            ForEach(days.indices, id: \.self) { idx in
                if let date = days[idx] {
                    // Filter for logs where medication was taken and has a medication name
                    let dayLogs = logs.filter { log in
                        calendar.isDate(log.date, inSameDayAs: date) &&
                        log.med_taken == true &&
                        log.medication_name != nil
                    }
                    MedTakenDayCell(date: date, logs: dayLogs, bg: bg, calendar: calendar, medicationColors: medicationColors)
                } else {
                    Spacer().frame(height: 20)
                }
            }
        }
    }
}

//make each day
struct MedTakenDayCell: View {
    let date: Date
    let logs: [UnifiedLog]
    let bg: String
    let calendar: Calendar
    let medicationColors: [String: Color]

    var body: some View {
        ZStack {
            // Day number
            CustomText(text: "\(calendar.component(.day, from: date))", color: bg, textAlign: .center, textSize: 14)

            // Med icons - circles colored by medication
            ForEach(Array(logs.enumerated()), id: \.offset) { i, log in
                MedIcon(log: log, index: i, total: logs.count, medicationColors: medicationColors)
            }
        }
        .frame(height: 25)
    }
}

//medication icon - always a circle, color based on medication
struct MedIcon: View {
    let log: UnifiedLog
    let index: Int
    let total: Int
    let medicationColors: [String: Color]

    var body: some View {
        let angle = Double(index)/Double(total) * 360
        let radius: CGFloat = 12
        Circle()
            .frame(width: 6, height: 6)
            .foregroundColor(medicationColors[log.medication_name ?? ""] ?? .gray)
            .offset(x: cos(angle * .pi / 180) * radius, y: sin(angle * .pi / 180) * radius)
    }
}
// Key showing medication colors
struct MedicationKey: View {
    let bg: String
    let accent: String
    let width: CGFloat
    let medicationColors: [String: Color]
    var itemHeight: CGFloat = 13
    
    var body: some View {
        let rows = computeRows()
        
        VStack(alignment: .leading, spacing: 8) {
            
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack(spacing: 10) {
                    ForEach(rows[rowIndex], id: \.0) { item in
                        HStack(spacing: 4) {
                            Circle()
                                .frame(width: 10, height: 10)
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
        .cornerRadius(10)
        .padding(.leading, 10)
    }
    
    private func computeRows() -> [[(String, Color)]] {
        var rows: [[(String, Color)]] = [[]]
        var currentRowWidth: CGFloat = 0
        let font = UIFont.systemFont(ofSize: 12, weight: .regular)
        let itemSpacing: CGFloat = 10
        let horizontalPadding: CGFloat = 8
        let iconTextGap: CGFloat = 4
        let circleWidth: CGFloat = 10
        
        for med in medicationColors.keys.sorted() {
            guard let color = medicationColors[med] else { continue }
            let displayText = String(med.prefix(12))
            let textWidth = displayText.width(usingFont: font)
            // circle + gap + text + padding
            let itemWidth = circleWidth + iconTextGap + textWidth + horizontalPadding
            
            // Calculate what the new width would be if we add this item
            let newRowWidth = currentRowWidth == 0 ? itemWidth : currentRowWidth + itemSpacing + itemWidth
            
            // Wrap to new row if needed
            if newRowWidth > width && !rows[rows.count - 1].isEmpty {
                // Start a new row
                rows.append([(med, color)])
                currentRowWidth = itemWidth
            } else {
                // Add to current row
                rows[rows.count - 1].append((med, color))
                currentRowWidth = newRowWidth
            }
        }
        
        return rows
    }
}
