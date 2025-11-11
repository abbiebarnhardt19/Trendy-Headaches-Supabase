//
//  Med Timeline Functions.swift
//  Trendy Headaches Supabase
//
//  Created by Abigail Barnhardt on 10/28/25.
//

import SwiftUI

func formatDateShort(_ dateString: String?) -> String {
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

func calculateMonthlyTicks(medications: [Medication]) -> [Date] {
    guard let minDate = getMinDate(medications: medications),
          let maxDate = getMaxDate(medications: medications) else {
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

func calculatePosition(dateString: String, totalWidth: CGFloat, medications: [Medication]) -> CGFloat? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    guard let date = dateFormatter.date(from: dateString),
          let minDate = getMinDate(medications: medications),
          let maxDate = getMaxDate(medications: medications) else {
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

func generateMedicationColors(bg: String, medications: [Medication]) -> [String: Color] {
    let baseColor = Color(hex: bg)
    let colors = baseColor.generateColors(from: baseColor, count: medications.count)
    return Dictionary(uniqueKeysWithValues: zip(medications.map { $0.medicationName }, colors))
}

func getMinDate(medications: [Medication]) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    
    let allDates = medications.compactMap { formatter.date(from: $0.medicationStart) } +
                   medications.compactMap { med in
                       guard let end = med.medicationEnd, !end.isEmpty else { return nil }
                       return formatter.date(from: end)
                   }
    
    return allDates.min()
}

func getMaxDate(medications: [Medication]) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    
    let allDates = medications.compactMap { formatter.date(from: $0.medicationStart) } +
                   medications.compactMap { med in
                       guard let end = med.medicationEnd, !end.isEmpty else { return nil }
                       return formatter.date(from: end)
                   }
    
    return allDates.max() ?? Date()
}

func formatDate(_ dateString: String?) -> String {
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

func formatMonthDay(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM\nyyyy"
    return formatter.string(from: date)
}

func calculateStapleHeights(totalWidth: CGFloat, medications: [Medication]) -> [Int: CGFloat] {
    var heights: [Int: CGFloat] = [:]
    var usedRanges: [(start: CGFloat, end: CGFloat, height: CGFloat)] = []
    let baseHeight: CGFloat = 15
    let heightIncrement: CGFloat = 3
    
    for (index, med) in medications.enumerated() {
        var height = baseHeight
        
        if let startPos = calculatePosition(dateString: med.medicationStart, totalWidth: totalWidth, medications: medications) {
            let endPos: CGFloat
            
            if let endString = med.medicationEnd, !endString.isEmpty,
               let calculatedEndPos = calculatePosition(dateString: endString, totalWidth: totalWidth, medications: medications) {
                endPos = calculatedEndPos
            } else {
                endPos = startPos + 30
            }
            
            var overlaps = true
            while overlaps {
                overlaps = false
                for range in usedRanges {
                    let horizontalOverlap = !(endPos < range.start || startPos > range.end)
                    let heightDiff = abs(height - range.height)
                    
                    if horizontalOverlap && heightDiff < 20 {
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

func getFrameHeight(showPopup: Bool, width: CGFloat, medications: [Medication]) -> CGFloat {
    let timelineWidth = width - 60
    let stapleHeights = calculateStapleHeights(totalWidth: timelineWidth, medications: medications)
    let maxHeight = stapleHeights.values.max() ?? 40
    let baseHeight = maxHeight + 60
    
    if showPopup {
        return baseHeight + 50
    }
    
    return baseHeight
}
