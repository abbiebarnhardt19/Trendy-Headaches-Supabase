//
//  Calendar.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/14/25.
//

import SwiftUI

struct LogCalendarView: View {
    let logs: [UnifiedLog]
    var bg: String
    var accent: String
    let sympIcon: [String: String]

    @State private var currentMonth = Date()
    @State private var showKey = false
    
    //constants
    private let calendar = Calendar.current
    private let weekDays = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    private let width = UIScreen.main.bounds.width - 80
    let maxMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))!
    
    @State var showVisual: Bool = false

    var body: some View {
        if showVisual{
            VStack(spacing: 10) {
                //modular design
                TopBar
                WeekdayLabels
                CalendarGrid
                //show keys for icon shapes and colors
                if showKey {
                    SeverityKeyBar(accent: bg)
                    SymptomKey(symptomToIcon: sympIcon, accent: bg)
                }
            }
            .frame(width: width)
            .padding()
            .background(Color(hex: accent))
            .cornerRadius(20)
            .padding(.bottom, 10)
        }
        //if hidden, show the show button
        else{
            HiddenChart(bg: bg, accent: accent, chart: "Log Calendar", hideChart: $showVisual)
        }
    }

    //the label part of the chart with the month and buttons
    private var TopBar: some View {
        HStack(spacing: 8) {
            
            //go back a month
            CustomButton(systemImage: "chevron.left", bg: bg, accent: accent, height: 20, width: 12) {currentMonth = changeMonth(currentMonth: currentMonth, by: -1)}
            
            //current month name displayed
            let font = UIFont.systemFont(ofSize: 19, weight: .bold)
            let title = monthYearString(for: currentMonth)
            CustomText(text: title, color: bg, width: title.width(usingFont: font), textAlign: .center, bold: true, textSize: 19)
                .padding(.bottom, 9)
            
            //go forward a month, can't if already on most recent month
            CustomButton(systemImage: "chevron.right", bg: bg, accent: accent, height: 20, width: 12, disabled: currentMonth >= maxMonth) {currentMonth = changeMonth(currentMonth: currentMonth, by: 1)}

            Spacer()
            
            //button to show the icon + color key
            ShowKeyButton(accent: accent, bg: bg, show: $showKey)
            .padding(.bottom, 5)
            
            //button to hid the visual, resused for each visual
            HideButton(accent: accent, bg: bg, show: $showVisual)
                .padding(.bottom, 5)
        }
        .frame(height: 20)
    }

    //make the text for each day of the week
    private var WeekdayLabels: some View {
        HStack {
            ForEach(weekDays, id: \.self) { day in
                CustomText(text: day, color: bg, textAlign: .center, textSize: 14)
                    .frame(maxWidth: .infinity)
            }
        }
    }

        //lay out the day cells on the grid
    private var CalendarGrid: some View {
        let days = makeDays(for: currentMonth)
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
            //add each cell individually
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

//make the number for each day and add log symbols
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

//log icon with colors
struct LogIcon: View {
    let log: UnifiedLog
    let index: Int
    let total: Int
    let sympIcon: [String: String]

    var body: some View {
        //make the circle around the date
        let angle = Double(index)/Double(total) * 360
        let radius: CGFloat = 12
        
        //image with the icon set by the symptom and the color set by severity
        Image(systemName: icon(for: log.symptom_name, symptomToIcon: sympIcon))
            .resizable()
            .scaledToFit()
            .frame(width: 6, height: 6)
            .foregroundColor(color(forSeverity: log.severity))
            .offset(x: cos(angle * .pi / 180) * radius, y: sin(angle * .pi / 180) * radius)
    }
}

//map icons to symptoms
struct SymptomKey: View {
    var symptomToIcon: [String: String]
    var accent: String
    
    //constants
    let width: CGFloat = UIScreen.main.bounds.width - 80
    let itemHeight: CGFloat = 13
    
    var body: some View {
        //alphabatize the symptoms
        let sortedSymp = symptomToIcon.sorted(by: { $0.key < $1.key })
        let rows = rowsForKey(items: sortedSymp, width: width, text: { $0.key },  iconWidth: itemHeight, iconTextGap: 4, horizontalPadding: 8, font: .systemFont(ofSize: 12), mapResult: { pair in
                (pair.key, pair.value)
            }) as! [[(String, String)]]

        //go through and add each symptom, wrapping rows if needed
        VStack(alignment: .leading, spacing: 8) {
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack(spacing: 10) {
                    ForEach(rows[rowIndex], id: \.0) { item in
                        HStack(spacing: 4) {
                            //symptom symbol
                            Image(systemName: item.1)
                                .resizable()
                                .scaledToFit()
                                .frame(width: itemHeight, height: itemHeight)
                                .foregroundColor(Color(hex: accent))
                            
                            //symptom name
                            CustomText(text: String(item.0.prefix(12)), color: accent, textSize: 12)
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
}


//making the color key
struct SeverityKeyBar: View {
    var accent: String
    
    let width: CGFloat = 300
    let height: CGFloat = 20

    //colors for 1-10
    private let severityColors: [Color] = [ "#FFB950", "#FFAD33", "#FF931F", "#FF7E33", "#FA5E1F",  "#EC3F13", "#B81702", "#A50104", "#8E0103", "#7A0103"].map(Color.init(hex:))

    var body: some View {
        VStack(spacing: 4) {
            // Gradient bar
            RoundedRectangle(cornerRadius: height / 2)
                .fill(LinearGradient(colors: severityColors, startPoint: .leading, endPoint: .trailing))
                .frame(width: width, height: height)

            //number level
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
