//
//  Calendar Functions.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/17/25.
//

import SwiftUI
import Foundation


// MARK: - Calendar / Analytics Utility Functions

func generateSymptomToIconMap(from logs: [UnifiedLog]) -> [String: String] {
    let icons = [
        "circle.fill", "square.fill", "triangle.fill",
        "star.fill", "diamond.fill", "hexagon.fill",
        "heart.fill", "bolt.fill", "leaf.fill", "flame.fill"
    ]

    var mapping: [String: String] = [:]
    let uniqueSymptoms = Set(logs.compactMap { $0.symptom_name }).sorted()

    for (index, symptom) in uniqueSymptoms.enumerated() {
        mapping[symptom] = icons[index % icons.count]
    }

    return mapping
}

// Color mapping for severity levels
func color(forSeverity severity: Int64) -> Color {
    switch severity {
    case 1: return Color(hex: "#FFB950")
    case 2: return Color(hex: "#FFAD33")
    case 3: return Color(hex: "#FF931F")
    case 4: return Color(hex: "#FF7E33")
    case 5: return Color(hex: "#FA5E1F")
    case 6: return Color(hex: "#EC3F13")
    case 7: return Color(hex: "#B81702")
    case 8: return Color(hex: "#A50104")
    case 9: return Color(hex: "#8E0103")
    case 10: return Color(hex: "#7A0103")
    default: return Color.gray
    }
}


func makeDays(for month: Date, using calendar: Calendar = .current) -> [Date?] {
    var days: [Date?] = []
    let range = calendar.range(of: .day, in: .month, for: month)!
    let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
    let firstWeekday = calendar.component(.weekday, from: firstDay)
    
    for _ in 1..<firstWeekday { days.append(nil) }
    for day in range {
        if let date = calendar.date(byAdding: .day, value: day-1, to: firstDay) {
            days.append(date)
        }
    }
    return days
}

func monthYearString(for date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "LLLL yyyy"
    return formatter.string(from: date)
}

func isToday(_ date: Date, using calendar: Calendar = .current) -> Bool {
    calendar.isDateInToday(date)
}

func changeMonth(currentMonth: Date, by offset: Int, using calendar: Calendar = .current) -> Date {
    return calendar.date(byAdding: .month, value: offset, to: currentMonth) ?? currentMonth
}

// Calculate text width for layout
func textWidth(for text: String, fontSize: CGFloat = 14) -> CGFloat {
    let font = UIFont.systemFont(ofSize: fontSize)
    let attributes = [NSAttributedString.Key.font: font]
    let size = text.size(withAttributes: attributes)
    return size.width
}
//
//// Generate rows of icons + symptom names
//func genSympKey(
//    from symptomToIcon: [String: String],
//    accent: String,
//    width: CGFloat,
//    itemHeight: CGFloat = 13
//) -> some View {
//    var widthUsed: CGFloat = 0
//    var rows: [[(String, String)]] = [[]]
//
//    for symptom in symptomToIcon.keys.sorted() {
//        let iconName = symptomToIcon[symptom] ?? "questionmark.square.fill"
//        let displayText = String(symptom.prefix(12))
//        let itemWidth = textWidth(for: displayText) + itemHeight
//
//        if widthUsed + itemWidth > width {
//            rows.append([])
//            widthUsed = 0
//        }
//        rows[rows.count - 1].append((symptom, iconName))
//        widthUsed += itemWidth
//    }
//
//    return VStack(alignment: .leading) {
//        ForEach(0..<rows.count, id: \.self) { rowIndex in
//            HStack {
//                ForEach(rows[rowIndex], id: \.0) { item in
//                    HStack(spacing: 4) {
//                        Image(systemName: item.1)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: itemHeight, height: itemHeight)
//                            .foregroundColor(Color(hex: accent))
//                        CustomText(
//                            text: String(item.0.prefix(12)),
//                            color: accent,
//                            textSize: 12
//                        )
//                        .lineLimit(1)
//                        .truncationMode(.tail)
//                    }
//                    .padding(.vertical, 2)
//                    .padding(.horizontal, 4)
//                }
//            }
//        }
//    }
//}
//
func icon(for symptom: String?, symptomToIcon: [String: String]) -> String {
    guard let name = symptom, !name.isEmpty else { return "questionmark.square.fill" }
    return symptomToIcon[name] ?? "questionmark.square.fill"
}
