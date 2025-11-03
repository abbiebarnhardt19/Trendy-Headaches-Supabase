//
//  Statistics Functions.swift
//  Trendy Headaches Supabase
//
//  Created by Abigail Barnhardt on 11/3/25.
//
import SwiftUI
func formatDateString(dateString: String?) -> String {
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MM/dd/yy"
        return df
    }()
    guard let dateString = dateString, !dateString.isEmpty else { return "N/A" }
    let isoFormatter = DateFormatter()
    isoFormatter.dateFormat = "yyyy-MM-dd"
    if let date = isoFormatter.date(from: dateString) {
        return dateFormatter.string(from: date)
    } else {
        return dateString
    }
}

func calculateColumnWidths(medicationList: [Medication]) -> [CGFloat] {
    let font = UIFont.systemFont(ofSize: 14)
    var widths: [CGFloat] = []
    
    // Name: 10 chars of the longest name
    if let maxName = medicationList.map({ $0.medicationName }).max(by: { $1.count > $0.count }) {
        widths.append(maxName.width(usingFont: font) + 15)
    } else {
        widths.append(10 * 10) // fallback
    }
    
    // Cat.: 5 chars max
    widths.append("emerg".width(usingFont: font) + 15)
    
    // Start & End: date width
    let dateSample = "11/11/11"
    widths.append(dateSample.width(usingFont: font) + 15)
    widths.append(dateSample.width(usingFont: font) + 15)
    
    // Reason: max 50 characters or "Reason", whichever is larger
    let maxReason = medicationList.map { ($0.endReason ?? "") }.max(by: { $1.count > $0.count }) ?? ""
    let reasonText = String(maxReason.prefix(50))
    let reasonWidth = max("Reason ".width(usingFont: font), reasonText.width(usingFont: font))
    widths.append(reasonWidth + 20)
    
    return widths
}
