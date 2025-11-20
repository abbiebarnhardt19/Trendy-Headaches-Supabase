//
//  Med Taken Calendar.swift
//  Trendy Headaches Supabase
//
//  Created by Abigail Barnhardt on 10/30/25.
//

import SwiftUI

//calendar for tracking emegency treatments
struct MedTakenCalendarView: View {
    let logs: [UnifiedLog]
    var bg: String
    var accent: String

    @State private var currentMonth = Date()
    @State private var showKey = false
    @State var showVisual: Bool = false
    
    //constants
    private let calendar = Calendar.current
    private let weekDays = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    private let width = UIScreen.main.bounds.width * 0.8
    let maxMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))!
    
    // Generate medication colors based on unique medications
    private var medicationColors: [String: Color] {
        
        //get all the treatments that are used
        let uniqueMeds = Array(Set(logs.compactMap { log -> String? in
            guard log.med_taken == true, let medName = log.medication_name else { return nil }
            return medName })).sorted()
        
        guard !uniqueMeds.isEmpty else { return [:] }
        
        let colors: [Color]
        if uniqueMeds.count == 1 {
            // For a single medication, use the base accent color
            colors = [Color(hex: bg)]
        } else {
            //get a color for each symptom
            colors = Color(hex: accent).generateColors(from: Color(hex: accent), count: uniqueMeds.count)
        }
        
        //map meds to colors
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
                        .padding(.top, 5)
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
            //move back one month
            HStack{
                CustomButton(systemImage: "chevron.left", bg: bg, accent: accent, height: 20, width: 12) {currentMonth = changeMonth(currentMonth: currentMonth, by: -1)}
                
                //current month label
                let fontSize = width * 0.07
                let font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
                let title = monthYearString(for: currentMonth)
                CustomText(text: title, color: bg, width: title.width(usingFont: font), textAlign: .center, bold: true, textSize: fontSize)
                    .padding(.bottom, 9)
                
                //more forward one month
                CustomButton(systemImage: "chevron.right", bg: bg, accent: accent, height: 20, width: 12, disabled: currentMonth >= maxMonth) {currentMonth = changeMonth(currentMonth: currentMonth, by: 1)}
            }
            .padding(.top ,5)
            
            Spacer()
            
            //show the symbol key
            ShowKeyButton(accent: accent, bg: bg, show: $showKey)
            .padding(.bottom, 5)
            
            //show the hide button
            HideButton(accent: accent, bg: bg, show: $showVisual)
            .padding(.bottom, 5)
        }
        
    }

    private var WeekdayLabels: some View {
        HStack {
            let itemWidth = width / 7 * 0.375
            ForEach(weekDays, id: \.self) { day in
                CustomText(text: day, color: bg, textAlign: .center, textSize:  itemWidth)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    //lay out the days on the grid
    private var CalendarGrid: some View {
        let days = makeDays(for: currentMonth)
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 20) {
            ForEach(days.indices, id: \.self) { idx in
                if let date = days[idx] {
                    // Filter for logs where medication was taken and has a medication name
                    let dayLogs = logs.filter { log in
                        calendar.isDate(log.date, inSameDayAs: date) &&
                        log.med_taken == true &&
                        log.medication_name != nil
                    }
                    //add the cell with the date and occurances
                    MedTakenDayCell(date: date, logs: dayLogs, bg: bg, calendar: calendar, medicationColors: medicationColors)
                } else {
                    Spacer().frame(height: 20)
                }
            }
        }
    }
}

//make each day with the treatment instances
struct MedTakenDayCell: View {
    let date: Date
    let logs: [UnifiedLog]
    let bg: String
    let calendar: Calendar
    let medicationColors: [String: Color]
    
    let width = UIScreen.main.bounds.width * 0.8

    var body: some View {
        ZStack {
            // Day number
            let radius = width * 0.055
            let size = width / 7 * 0.5
            CustomText(text: "\(calendar.component(.day, from: date))", color: bg, textAlign: .center, textSize: size)

            let iconSize =  width * 0.035
            // circles colored by medication
            ForEach(Array(logs.enumerated()), id: \.offset) { i, log in
                let angle = Double(i)/Double(logs.count) * 360
                Circle()
                    .frame(width: iconSize, height: iconSize)
                    .foregroundColor(medicationColors[log.medication_name ?? ""] ?? .gray)
                    .offset(x: cos(angle * .pi / 180) * radius, y: sin(angle * .pi / 180) * radius)
            }
        }
        .frame(height: 25)
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
        //split medications onto rows
        let rows = rowsForKey( items: medicationColors.sorted(by: { $0.key < $1.key }), width: width, text: { $0.key },  iconWidth: 10, iconTextGap: 4, horizontalPadding: 8, font: .systemFont(ofSize: 18), mapResult: { (key, color) in (key, color) }) as! [[(String, Color)]]
        
        VStack(alignment: .leading, spacing: 8) {
            //go through each row
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack(spacing: 10) {
                    //go through each med
                    ForEach(rows[rowIndex], id: \.0) { item in
                        HStack(spacing: 4) {
                            //circle with that med's color
                            Circle()
                                .frame(width: 10, height: 10)
                                .foregroundColor(item.1)
                                .padding(.trailing, 2)
                            
                            //med label
                            CustomText(text: String(item.0.prefix(15)),  color: bg, textSize: 18)
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
}
