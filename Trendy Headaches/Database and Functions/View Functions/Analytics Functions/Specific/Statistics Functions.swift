//
//  Statistics Functions.swift
//  Trendy Headaches Supabase
//
//  Created by Abigail Barnhardt on 11/3/25.
//
import SwiftUI

//format dates
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

//get total logs, average per week, and average per month
func getFrequencyValues(logList: [UnifiedLog], prefix: String = "Average ") -> [String]{
        
        //display a no data message if there are no logs
        guard !logList.isEmpty else { return ["No data available"] }
        
        //get all the log dates
        let dates = logList.map { $0.date }
        
        //initalize results with total logs
        var results = ["Total Logs: \(logList.count)"]
        
        //calcuate average logs per week
        let calendar = Calendar.current
        let weeks = calendar.dateComponents([.weekOfYear], from: dates.min() ?? Date(), to: dates.max() ?? Date()).weekOfYear ?? 0
        
        let weekCount = max(weeks, 1)
        let weeklyAverage = Double(logList.count) / Double(weekCount)
        results.append("\(prefix)Per Week: \(String(format: "%.1f", weeklyAverage))")
        
        //calculate average logs per month
        let months = calendar.dateComponents([.month], from: dates.min() ?? Date(), to: dates.max() ?? Date()).month ?? 0
        
        let monthCount = max(months, 1)
        let monthlyAverage = Double(logList.count) / Double(monthCount)
        results.append("\(prefix)Per Month: \(String(format: "%.1f", monthlyAverage))")
        
        return results
}

func getSeverityValues(logList: [UnifiedLog], prefix: String = "Average Log Severity") -> [String]{
    //no data message
    guard logList.count > 0 else { return ["No data available"] }
        
    //get average severity level
    let totalSeverity = logList.reduce(0) { $0 + $1.severity }
    let averageSeverity = Double(totalSeverity) / Double(logList.count)
    return ["\(prefix): \(String(format: "%.1f", averageSeverity))"]
}


//function to get the average times emergency treatment is administrated in a week
func getEmergTreatmentFreq(logList: [UnifiedLog]) -> [String]{
    //only get logs where emergency treatment was administered
    let filteredLogs = logList.filter { $0.med_taken == true }
    
    //no data warning
    guard !filteredLogs .isEmpty else { return ["No data available"] }
    
    //get all the log dates
    let dates = filteredLogs .map { $0.date }
    
    //initalize results with total logs
    var results = ["Total: \(filteredLogs .count)"]
    
    //calcuate average logs per week
    let calendar = Calendar.current
    let weeks = calendar.dateComponents([.weekOfYear], from: dates.min() ?? Date(), to: dates.max() ?? Date()).weekOfYear ?? 0
    
    let weekCount = max(weeks, 1)
    let weeklyAverage = Double(filteredLogs.count) / Double(weekCount)
    results.append("Per Week: \(String(format: "%.1f", weeklyAverage))")
    
    return results
}
