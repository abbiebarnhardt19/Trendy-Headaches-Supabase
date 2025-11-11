//
//  Statistics Functions.swift
//  Trendy Headaches Supabase
//
//  Created by Abigail Barnhardt on 11/3/25.
//
import SwiftUI

//format dates for table
func formatDateString(dateString: String?) -> String {
    guard let dateString = dateString, !dateString.isEmpty else { return "N/A" }

    let isoFormatter = DateFormatter()
    isoFormatter.dateFormat = "yyyy-MM-dd"

    let outputFormatter = DateFormatter()
    outputFormatter.dateFormat = "MM/dd/yy"

    return isoFormatter.date(from: dateString).map { outputFormatter.string(from: $0) } ?? dateString
}


func calculateColumnWidths(medicationList: [Medication]) -> [CGFloat] {
    let font = UIFont.systemFont(ofSize: 14)
    
    //Medication Name Column
    let maxName = medicationList.map { $0.medicationName }.max(by: { $0.count < $1.count }) ?? ""
    let nameWidth = maxName.width(usingFont: font) + 15
    
    //Category Column (static: "emerg")
    let categoryWidth = "emerg".width(usingFont: font) + 15
    
    //Start & End Dates (static width)
    let dateWidth = "11/11/11".width(usingFont: font) + 15
    
    //Reason Column (up to 50 chars max or "Reason")
    let maxReason = medicationList.map { $0.endReason ?? "" }.max(by: { $0.count < $1.count }) ?? ""
    let reasonText = String(maxReason.prefix(50))
    let reasonWidth = max("Reason".width(usingFont: font), reasonText.width(usingFont: font)) + 20
    
    return [nameWidth, categoryWidth, dateWidth, dateWidth, reasonWidth]
}
