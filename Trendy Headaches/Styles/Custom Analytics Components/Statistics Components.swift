//
//  Statistics Components.swift
//  Trendy Headaches Supabase
//
//  Created by Abigail Barnhardt on 11/1/25.
//
import SwiftUI

struct logFrequencyStats: View{
    var accent: String
    var bg: String
    var logList: [UnifiedLog]
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    @State var showStats: Bool = false
    @State var typeFilter: String = "All Types"
    
    // Filtered logs based on type
    var filteredLogs: [UnifiedLog] {
        switch typeFilter {
        case "Symptom":
            return logList.filter { $0.log_type == "Symptom" }
        case "Side Effect":
            return logList.filter { $0.log_type == "Side Effect" }
        default: // "All Types"
            return logList
        }
    }
    
    // Calculate statistics
    var totalLogs: Int {
        filteredLogs.count
    }
    
    var averagePerWeek: Double {
        guard !filteredLogs.isEmpty else { return 0.0 }
        
        let dates = filteredLogs.map { $0.date }
        guard let earliest = dates.min(), let latest = dates.max() else { return 0.0 }
        
        let calendar = Calendar.current
        let weeks = calendar.dateComponents([.weekOfYear], from: earliest, to: latest).weekOfYear ?? 0
        
        // At least 1 week if there are logs
        let weekCount = max(weeks, 1)
        return Double(totalLogs) / Double(weekCount)
    }
    
    var averagePerMonth: Double {
        guard !filteredLogs.isEmpty else { return 0.0 }
        
        let dates = filteredLogs.map { $0.date }
        guard let earliest = dates.min(), let latest = dates.max() else { return 0.0 }
        
        let calendar = Calendar.current
        let months = calendar.dateComponents([.month], from: earliest, to: latest).month ?? 0
        
        // At least 1 month if there are logs
        let monthCount = max(months, 1)
        return Double(totalLogs) / Double(monthCount)
    }
    
    var body: some View{
        if showStats{
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top){
                    let font = UIFont.systemFont(ofSize: screenWidth * 0.05, weight: .bold)
                    CustomText(text:"Frequency Stats:", color: bg, width: "Frequency Stats:".width(usingFont: font) + 10, bold: true, textSize: screenWidth * 0.05)
                    
                    AnalyticsDropdown(accent: bg, bg: accent, options: ["All Types" , "Symptom", "Side Effect"], selected: $typeFilter, textSize: screenWidth * 0.05)
                    
                    Spacer() // Add spacer to push button to the right
                    
                    Button(action: { showStats.toggle() }) {
                        Image(systemName: "eye.slash.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(Color(hex: bg))
                            .frame(width: 25, height: 25)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .frame(width: screenWidth - 50 - 15 * 2)
                .padding(.bottom, 5)
                
                CustomText(text: "Total Logs: \(totalLogs)", color: bg, textSize: screenWidth * 0.045)
                CustomText(text: "Average Per Week: \(String(format: "%.1f", averagePerWeek))", color: bg, textSize: screenWidth * 0.045)
                CustomText(text: "Average Per Month: \(String(format: "%.1f", averagePerMonth))", color: bg, textSize: screenWidth * 0.045)
            }
            .padding(.horizontal, 15)
            .padding(.top, 10)
            .padding(.bottom, 20)
            .background(Color(hex:accent))
            .cornerRadius(20)
            .frame(width: screenWidth - 50, alignment: .leading)
            .padding(.bottom, 10)
        }
        else{
            HStack {
                HiddenChart(bg:bg, accent:accent, chart:"Frequency Stats", hideChart: $showStats)
            }
            .frame(width: screenWidth)
        }
    }
}


struct severityStats: View{
    var accent: String
    var bg: String
    var logList: [UnifiedLog]
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    @State var showStats: Bool = false
    @State var typeFilter: String = "All Types"
    
    // Filtered logs based on type
    var filteredLogs: [UnifiedLog] {
        switch typeFilter {
        case "Symptom":
            return logList.filter { $0.log_type == "Symptom" }
        case "Side Effect":
            return logList.filter { $0.log_type == "Side Effect" }
        default: // "All Types"
            return logList
        }
    }
    
    // Calculate statistics
    var totalLogs: Int {
        filteredLogs.count
    }
    
    var averageSeverity: Double {
        guard totalLogs > 0 else { return 0.0 }
        
        let totalSeverity = filteredLogs.reduce(0) { $0 + $1.severity }
        return Double(totalSeverity) / Double(totalLogs)
    }
    
    var body: some View{
        if showStats{
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top){
                    let font = UIFont.systemFont(ofSize: screenWidth * 0.05, weight: .bold)
                    CustomText(text:"Severity Stats:", color: bg, width: "Severity Stats:".width(usingFont: font) + 10, bold: true, textSize: screenWidth * 0.05)
                    
                    AnalyticsDropdown(accent: bg, bg: accent, options: ["All Types" , "Symptom", "Side Effect"], selected: $typeFilter, textSize: screenWidth * 0.05)
                    
                    Spacer() // Add spacer to push button to the right
                    
                    Button(action: { showStats.toggle() }) {
                        Image(systemName: "eye.slash.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(Color(hex: bg))
                            .frame(width: 25, height: 25)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .frame(width: screenWidth - 50 - 15 * 2)
                .padding(.bottom, 5)
                
                CustomText(text: "Average Log Severity: \(String(format: "%.1f", averageSeverity))", color: bg, textSize: screenWidth * 0.045)
            }
            .padding(.horizontal, 15)
            .padding(.top, 10)
            .padding(.bottom, 20)
            .background(Color(hex:accent))
            .cornerRadius(20)
            .frame(width: screenWidth - 50, alignment: .leading)
            .padding(.bottom, 10)
        }
        else{
            HStack {
                HiddenChart(bg:bg, accent:accent, chart:"Severity Stats", hideChart: $showStats)
            }
            .frame(width: screenWidth)
        }
    }
}

struct onsetStats: View{
    var accent: String
    var bg: String
    var logList: [UnifiedLog]
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    @State var showStats: Bool = true
    
    var totalLogs: Int {
        logList.count
    }
    
    var onsetPercent: [Double] {
        // Filter to only logs where onset_time is not nil and not empty
        let logsWithOnset = logList.filter { log in
            if let onset = log.onset_time, !onset.isEmpty {
                return true
            }
            return false
        }
        
        let totalLogsWithOnset = logsWithOnset.count
    
        
        guard totalLogsWithOnset > 0 else { return [0.0, 0.0, 0.0, 0.0, 0.0] }
        
        let totalFromWake = logsWithOnset.filter { $0.onset_time == "From Wake" }.count
        let fromWakePercent = Double(totalFromWake) / Double(totalLogsWithOnset) * 100.0
        
        let totalMorning = logsWithOnset.filter { $0.onset_time == "Morning" }.count
        let morningPercent = Double(totalMorning) / Double(totalLogsWithOnset) * 100.0
        
        let totalAfternoon = logsWithOnset.filter { $0.onset_time == "Afternoon" }.count
        let afternoonPercent = Double(totalAfternoon) / Double(totalLogsWithOnset) * 100.0
        
        let totalEvening = logsWithOnset.filter { $0.onset_time == "Evening" }.count
        let eveningPercent = Double(totalEvening) / Double(totalLogsWithOnset) * 100.0
        
        return [Double(totalLogsWithOnset), fromWakePercent, morningPercent, afternoonPercent, eveningPercent]
    }

    var body: some View{
        if showStats{
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top){
                    let font = UIFont.systemFont(ofSize: screenWidth * 0.05, weight: .bold)
                    CustomText(text:"Symptom Onset Stats:", color: bg, width: "Symptom Onset Stats:".width(usingFont: font) + 10, bold: true, textSize: screenWidth * 0.05)
                
                    
                    Spacer() // Add spacer to push button to the right
                    
                    Button(action: { showStats.toggle() }) {
                        Image(systemName: "eye.slash.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(Color(hex: bg))
                            .frame(width: 25, height: 25)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .frame(width: screenWidth - 50 - 15 * 2)
                .padding(.bottom, 5)
                
                CustomText(text:  "Total Logs With Recorded Onset: \(Int(onsetPercent[0]))", color: bg, textSize: screenWidth * 0.045)
                CustomText(text:  "From Wake Onset: \(String(format: "%.1f%%", onsetPercent[1]))", color: bg, textSize: screenWidth * 0.045)
                CustomText(text:  "Morning Onset: \(String(format: "%.1f%%", onsetPercent[2]))", color: bg, textSize: screenWidth * 0.045)
                CustomText(text:  "Afternoon Onset: \(String(format: "%.1f%%", onsetPercent[3]))", color: bg, textSize: screenWidth * 0.045)
                CustomText(text:  "Evening Onset: \(String(format: "%.1f%%", onsetPercent[4]))", color: bg, textSize: screenWidth * 0.045)
            }
            .padding(.horizontal, 15)
            .padding(.top, 10)
            .padding(.bottom, 20)
            .background(Color(hex:accent))
            .cornerRadius(20)
            .frame(width: screenWidth - 50, alignment: .leading)
            .padding(.bottom, 10)
        }
        else{
            HStack {
                HiddenChart(bg:bg, accent:accent, chart:"Symptom Onset Stats", hideChart: $showStats)
            }
            .frame(width: screenWidth)
        }
    }
}
