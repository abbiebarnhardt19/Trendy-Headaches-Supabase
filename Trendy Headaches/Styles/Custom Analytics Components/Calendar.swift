//
//  Calendar.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/14/25.
//

import SwiftUI

struct CalendarView: View {
    let logs: [UnifiedLog]
    @Binding var hideChart: Bool
    var bg: String
    var accent: String
    let sympIcon: [String: String]

    @State private var currentMonth = Date()
    @State private var showKey = false
    private let calendar = Calendar.current
    private let weekDays = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    private let width = UIScreen.main.bounds.width - 60
    let maxMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))!

    var body: some View {
        VStack(spacing: 10) {
            TopBar
            WeekdayLabels
            CalendarGrid
            if showKey {
                SeverityKeyBar(accent: bg, width: width, height: 20)
                SymptomKey(symptomToIcon: sympIcon, accent: bg, width: width)
            }
        }
        .frame(width: width)
        .padding()
        .background(Color(hex: accent))
        .cornerRadius(20)
        .padding(.bottom, 10)
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
            
            CustomButton(text: "Key", bg: accent, accent: bg, height: 30, width: 50, textSize: 14) { showKey.toggle() }
            CustomButton(text: "Hide", bg: accent, accent: bg, height: 30, width: 50, textSize: 14) { hideChart.toggle() }
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
                    let dayLogs = logs.filter { calendar.isDate($0.date, inSameDayAs: date) }
                    DayCell(date: date, logs: dayLogs, bg: bg, sympIcon: sympIcon, calendar: calendar)
                } else {
                    Spacer().frame(height: 20)
                }
            }
        }
    }
}

//make each day
struct DayCell: View {
    let date: Date
    let logs: [UnifiedLog]
    let bg: String
    let sympIcon: [String: String]
    let calendar: Calendar

    var body: some View {
        ZStack {
            // Day number
            CustomText(text: "\(calendar.component(.day, from: date))", color: bg, textAlign: .center, textSize: 14)

            // Log icons
            ForEach(Array(logs.enumerated()), id: \.offset) { i, log in
                LogIcon(log: log, index: i, total: logs.count, sympIcon: sympIcon)
            }
        }
        .frame(height: 25)
    }
}

//log icon with symbol
struct LogIcon: View {
    let log: UnifiedLog
    let index: Int
    let total: Int
    let sympIcon: [String: String]

    var body: some View {
        let angle = Double(index)/Double(total) * 360
        let radius: CGFloat = 12
        Image(systemName: icon(for: log.symptom_name, symptomToIcon: sympIcon))
            .resizable()
            .scaledToFit()
            .frame(width: 6, height: 6)
            .foregroundColor(color(forSeverity: log.severity))
            .offset(x: cos(angle * .pi / 180) * radius, y: sin(angle * .pi / 180) * radius)
    }
}

//make a key for mapping the shapes to the symptoms
//struct SymptomKey: View {
//    let sympIcon: [String: String]
//    var accent: String
//    var width: CGFloat
//    var itemHeight: CGFloat = 13
//
//    var body: some View {
//        genSympKey(from: sympIcon, accent: accent, width: width, itemHeight: itemHeight)
//            .frame(width: width, alignment: .leading)
//            .padding(.bottom, 10)
//    }
//}

struct SymptomKey: View {
    var symptomToIcon: [String: String]
    var accent: String
    var width: CGFloat
    var itemHeight: CGFloat = 13
    
    var body: some View {
        let rows = computeRows()
        
        VStack(alignment: .leading, spacing: 8) {
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack(spacing: 10) {
                    ForEach(rows[rowIndex], id: \.0) { item in
                        HStack(spacing: 4) {
                            Image(systemName: item.1)
                                .resizable()
                                .scaledToFit()
                                .frame(width: itemHeight, height: itemHeight)
                                .foregroundColor(Color(hex: accent))
                            CustomText(
                                text: String(item.0.prefix(12)),
                                color: accent,
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
    }
    
    private func computeRows() -> [[(String, String)]] {
        var rows: [[(String, String)]] = [[]]
        var currentRowWidth: CGFloat = 0
        let font = UIFont.systemFont(ofSize: 12, weight: .regular)
        let itemSpacing: CGFloat = 10
        let horizontalPadding: CGFloat = 8
        let iconTextGap: CGFloat = 4
        
        for symptom in symptomToIcon.keys.sorted() {
            let iconName = symptomToIcon[symptom] ?? "questionmark.square.fill"
            let displayText = String(symptom.prefix(12))
            let textWidth = displayText.width(usingFont: font)
            // icon + gap + text + padding
            let itemWidth = itemHeight + iconTextGap + textWidth + horizontalPadding
            
            // Calculate what the new width would be if we add this item
            let newRowWidth = currentRowWidth == 0 ? itemWidth : currentRowWidth + itemSpacing + itemWidth
            
            // Wrap to new row if needed
            if newRowWidth > width && !rows[rows.count - 1].isEmpty {
                // Start a new row
                rows.append([(symptom, iconName)])
                currentRowWidth = itemWidth
            } else {
                // Add to current row
                rows[rows.count - 1].append((symptom, iconName))
                currentRowWidth = newRowWidth
            }
        }
        
        return rows
    }
}


//making the color key
struct SeverityKeyBar: View {
    var accent: String
    var width: CGFloat = 300
    var height: CGFloat = 20

    private let severityColors: [Color] = [
        "#FFB950", "#FFAD33", "#FF931F", "#FF7E33", "#FA5E1F",
        "#EC3F13", "#B81702", "#A50104", "#8E0103", "#7A0103"
    ].map(Color.init(hex:))

    var body: some View {
        VStack(spacing: 4) {
            // Gradient bar
            RoundedRectangle(cornerRadius: height / 2)
                .fill(LinearGradient(colors: severityColors, startPoint: .leading, endPoint: .trailing))
                .frame(width: width, height: height)

            HStack(spacing: 0) {
                ForEach(1...10, id: \.self) { level in
                    CustomText(text: "\(level)", color: accent, textAlign: .center, textSize: 14)
                        .frame(width: width / 10)
                }
            }
        }
        .frame(width: width)
        .padding(.vertical, 10)
    }
}
