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
                SymptomKey(sympIcon: sympIcon, accent: bg, width: width)
            }
        }
        .frame(width: width)
        .padding()
        .background(Color(hex: accent))
        .cornerRadius(30)
        .padding(.bottom, 10)
    }

    //calendar parts
    private var TopBar: some View {
        HStack(spacing: 8) {
            CustomButton(systemImage: "chevron.left", bg: bg, accent: accent, height: 15, width: 12) {currentMonth = changeMonth(currentMonth: currentMonth, by: -1)}
            
            CustomText(text: monthYearString(for: currentMonth), color: bg, width: textWidth(for: monthYearString(for: currentMonth), fontSize: 18), textAlign: .center, textSize: 18)
                .padding(.bottom, 9)
            
            CustomButton(systemImage: "chevron.right", bg: bg, accent: accent, height: 15, width: 12, disabled: currentMonth >= maxMonth) {currentMonth = changeMonth(currentMonth: currentMonth, by: 1)}
            
            Spacer()
            
            CustomButton(text: "Key", bg: accent, accent: bg, height: 25, width: 45, textSize: 12) { showKey.toggle() }
            CustomButton(text: "Hide", bg: accent, accent: bg, height: 25, width: 45, textSize: 12) { hideChart.toggle() }
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
struct SymptomKey: View {
    let sympIcon: [String: String]
    var accent: String
    var width: CGFloat
    var itemHeight: CGFloat = 13

    var body: some View {
        genSympKey(from: sympIcon, accent: accent, width: width, itemHeight: itemHeight)
            .frame(width: width, alignment: .leading)
            .padding(.bottom, 10)
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
        .padding(.bottom, 30)
    }
}
