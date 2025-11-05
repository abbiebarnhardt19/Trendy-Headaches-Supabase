//
//  Statistics Components.swift
//  Trendy Headaches Supabase
//
//  Created by Abigail Barnhardt on 11/1/25.
//

import SwiftUI

//shows how many logs a user has total and weekly and monthly average
struct LogFrequencyStats: View{
    var accent: String
    var bg: String
    var logList: [UnifiedLog]
    
    let screenWidth = UIScreen.main.bounds.width

    @State var showStats: Bool = false
    @State var typeFilter: String = "All Types"
    
    //filter the log based on type, default to both types
    var filteredLogs: [UnifiedLog] {
        switch typeFilter {
        case "Symptom":
            return logList.filter { $0.log_type == "Symptom" }
        case "Side Effect":
            return logList.filter { $0.log_type == "Side Effect" }
        default:
            return logList
        }
    }
    
    //get the totals and averages
    var frequencyStats: [String] {
        
        //display a no data message if there are no logs
        guard !filteredLogs.isEmpty else { return ["No log data available"] }
        
        //get all the log dates
        let dates = filteredLogs.map { $0.date }
        
        //initalize results with total logs
        var results = ["Total Logs: \(filteredLogs.count)"]
        
        //calcuate average logs per week
        let calendar = Calendar.current
        let weeks = calendar.dateComponents([.weekOfYear], from: dates.min() ?? Date(), to: dates.max() ?? Date()).weekOfYear ?? 0
        
        let weekCount = max(weeks, 1)
        let weeklyAverage = Double(filteredLogs.count) / Double(weekCount)
        results.append("Weekly Average: \(String(format: "%.1f", weeklyAverage))")
        
        //calculate average logs per month
        let months = calendar.dateComponents([.month], from: dates.min() ?? Date(), to: dates.max() ?? Date()).month ?? 0
        
        let monthCount = max(months, 1)
        let monthlyAverage = Double(filteredLogs.count) / Double(monthCount)
        results.append("Monthly Average: \(String(format: "%.1f", monthlyAverage))")
        
        return results
    }

    
    var body: some View{
        //show the data
        if showStats{
            VStack(alignment: .leading, spacing: 10) {
                //top bar of section
                HStack(alignment: .top){
                    
                    let font = UIFont.systemFont(ofSize: screenWidth * 0.05, weight: .bold)
                    CustomText(text:"Frequency Stats:", color: bg, width: "Frequency Stats:".width(usingFont: font) + 10, bold: true, textSize: screenWidth * 0.05)
                    
                    //filter by log type
                    AnalyticsDropdown(accent: bg, bg: accent, options: ["All Types" , "Symptom", "Side Effect"], selected: $typeFilter, textSize: screenWidth * 0.05)
                    
                    Spacer()
                    
                    HideButton(accent: accent, bg: bg, show: $showStats)
                }
                .frame(width: screenWidth - 50 - 15 * 2)
                .padding(.bottom, 5)
                
                //list out each stat
                ForEach(frequencyStats, id: \.self) { item in
                    CustomText( text: item,  color: bg,  textSize: screenWidth * 0.045)
                }
            }
            .padding(.horizontal, 15)
            .padding(.top, 10)
            .padding(.bottom, 20)
            .background(Color(hex:accent))
            .cornerRadius(20)
            .frame(width: screenWidth - 50, alignment: .leading)
            .padding(.bottom, 10)
        }
        //if hidden, show show button
        else{
            HStack {
                HiddenChart(bg:bg, accent:accent, chart:"Frequency Stats", hideChart: $showStats)
            }
            .frame(width: screenWidth)
        }
    }
}

//average log severity
struct SeverityStats: View{
    var accent: String
    var bg: String
    var logList: [UnifiedLog]
    
    let screenWidth = UIScreen.main.bounds.width

    @State var showStats: Bool = false
    @State var typeFilter: String = "All Types"
    
    // Filtered logs based on type
    var filteredLogs: [UnifiedLog] {
        switch typeFilter {
        case "Symptom":
            return logList.filter { $0.log_type == "Symptom" }
        case "Side Effect":
            return logList.filter { $0.log_type == "Side Effect" }
        default:
            return logList
        }
    }
    
    var averageSeverity: Double {
        guard filteredLogs.count > 0 else { return 0.0 }
        
        let totalSeverity = filteredLogs.reduce(0) { $0 + $1.severity }
        return Double(totalSeverity) / Double(filteredLogs.count)
    }
    
    var body: some View{
        if showStats{
            VStack(alignment: .leading, spacing: 10) {
                //top header
                HStack(alignment: .top){
                    let font = UIFont.systemFont(ofSize: screenWidth * 0.05, weight: .bold)
                    CustomText(text:"Severity Stats:", color: bg, width: "Severity Stats:".width(usingFont: font) + 10, bold: true, textSize: screenWidth * 0.05)
                    
                    AnalyticsDropdown(accent: bg, bg: accent, options: ["All Types" , "Symptom", "Side Effect"], selected: $typeFilter, textSize: screenWidth * 0.05)
                    
                    Spacer()
                    
                    HideButton(accent: accent, bg: bg, show: $showStats)
                }
                .frame(width: screenWidth - 50 - 15 * 2)
                .padding(.bottom, 5)
                
                //average severity
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
        //if hidden, show show button
        else{
            HStack {
                HiddenChart(bg:bg, accent:accent, chart:"Severity Stats", hideChart: $showStats)
            }
            .frame(width: screenWidth)
        }
    }
}

//stats showing what percent of logs were in each onset time
struct OnsetStats: View{
    var accent: String
    var bg: String
    var logList: [UnifiedLog]
    
    let screenWidth = UIScreen.main.bounds.width
    @State var showStats: Bool = false
    
    var onsetPercents: [String] {
        // Filter to only logs where onset_time is not nil and not empty
        let filteredLogs = logList.filter { log in
            if let onset = log.onset_time, !onset.isEmpty {
                return true
            }
            return false
        }
        
        //no data message
        guard filteredLogs.count > 0 else { return ["No data available"] }
        
        let onsetOptions = ["From Wake", "Morning", "Afternoon", "Evening"]
        var results = ["Logs With Onset: \(filteredLogs.count)"]
        
        //get the percent of logs for each onset option
        for option in onsetOptions {
            let onsetTotal = filteredLogs.filter { $0.onset_time == option }.count
            let onsetPercent = Double(onsetTotal) / Double(filteredLogs.count) * 100.0
            results.append("\(option): \(String(format: "%.1f%%", onsetPercent))")
        }
        
        return results
    }

    var body: some View{
        //show the stats
        if showStats{
            VStack(alignment: .leading, spacing: 10) {
                //top header
                HStack(alignment: .top){
                    let font = UIFont.systemFont(ofSize: screenWidth * 0.05, weight: .bold)
                    CustomText(text:"Symptom Onset Stats:", color: bg, width: "Symptom Onset Stats:".width(usingFont: font) + 10, bold: true, textSize: screenWidth * 0.05)
                
                    Spacer()
                    
                    HideButton(accent: accent, bg: bg, show: $showStats)
                }
                .frame(width: screenWidth - 50 - 15 * 2)
                .padding(.bottom, 5)
                
                //the stats
                ForEach(onsetPercents, id: \.self) { option in
                    CustomText( text: option, color: bg, textSize: screenWidth * 0.045)
                }
            }
            .padding(.horizontal, 15)
            .padding(.top, 10)
            .padding(.bottom, 20)
            .background(Color(hex:accent))
            .cornerRadius(20)
            .frame(width: screenWidth - 50, alignment: .leading)
            .padding(.bottom, 10)
        }
        //if hidden, show the show button
        else{
            HStack {
                HiddenChart(bg:bg, accent:accent, chart:"Symptom Onset Stats", hideChart: $showStats)
            }
            .frame(width: screenWidth)
        }
    }
}


struct ScrollableMedicationTable: View {
    var accent: String
    var bg: String
    var medicationList: [Medication]

    @State private var showStats: Bool = false
    
    let screenWidth = UIScreen.main.bounds.width
    let rowHeight: CGFloat = 35
    let visibleRows = 5
    
    private let columns = ["Name", "Cat.", "Start", "End", "Reason"]
    
    var body: some View {
        if showStats {
        VStack(spacing: 10) {
            // Title + toggle
            HStack {
                let font = UIFont.systemFont(ofSize: 18, weight: .bold)
                let title = "Treatment History"
                
                CustomText( text: title,  color: bg,  width: title.width(usingFont: font) + 20, bold: true,  textSize: 18)
                
                Spacer()
                
                HideButton(accent: accent, bg: bg, show: $showStats)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)

            let columnWidths = calculateColumnWidths(medicationList: medicationList)

                ScrollView([.vertical, .horizontal], showsIndicators: true) {
                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        Section(header:
                            HStack(spacing: 0) {
                                ForEach(columns.indices, id: \.self) { i in
                                    CustomText(text: columns[i],color: bg,  textAlign: .center, bold: true,  textSize: 16)
                                    .frame(width: columnWidths[i], height: rowHeight)
                                    .background(Color.blend(Color(hex: bg), Color(hex: accent), ratio: 0.8))
                                    .border(Color(hex: bg).opacity(0.2), width: 1)
                                }
                            })
                        {
                            ForEach(medicationList, id: \.medicationId) { med in
                                HStack(spacing: 0) {
                                    let startDisplay = formatDateString(dateString: med.medicationStart)
                                    let endDisplay = formatDateString(dateString:med.medicationEnd)
                                    let categoryDisplay = {
                                        switch med.medicationCategory.lowercased() {
                                        case "preventative": return "prev"
                                        case "emergency": return "emerg"
                                        default: return med.medicationCategory
                                        }
                                    }()
                                    
                                    let rowData = [med.medicationName, categoryDisplay, startDisplay,  endDisplay,  med.endReason ?? ""]

                                    ForEach(rowData.indices, id: \.self) { i in
                                        CustomText( text: rowData[i],color: bg, textAlign: .center,textSize: screenWidth * 0.035)
                                        .frame(width: columnWidths[i], height: rowHeight)
                                        .background(Color(hex: accent).opacity(0.2))
                                        .border(Color(hex: bg).opacity(0.2), width: 1)
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(width: screenWidth - 80,
                       height: rowHeight * CGFloat(visibleRows) + 5)
                .background(Color(hex: accent).opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .contentShape(RoundedRectangle(cornerRadius: 12))
                .padding(.bottom, 15)
            }
        .frame(width: screenWidth - 50)
        .background(Color(hex: accent))
        .cornerRadius(20)
        }
        else{
            HiddenChart(bg: bg, accent: accent, chart: "Treatment Histroy", hideChart: $showStats)
        }
    }
}


struct EmergencyMedStats: View{
    var accent: String
    var bg: String
    var logList: [UnifiedLog]
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    @State var showStats: Bool = false
    
    
    var medicationEffectiveness: [String] {
        // Filter to only logs where medication was taken
        let medLogs = logList.filter { $0.med_taken == true && $0.med_worked != nil}
        
        let totalLogs = medLogs.count
        
        // Guard in case no medication logs exist
        guard !medLogs.isEmpty else { return ["No medication data available"] }
        
        // Group logs by medication_name
        let groupedByMedication = Dictionary(grouping: medLogs) { log in
            log.medication_name ?? "Unknown Medication"
        }
        
        // Calculate effectiveness percentage for each medication
        var result: [String] = ["Logs With Emergency Treatment:  \(totalLogs)"]
        
        for (medication, logs) in groupedByMedication {
            let total = logs.count
            
            let effectiveCount = logs.filter { $0.med_worked == true }.count
            
            let percentEffective = (Double(effectiveCount) / Double(total)) * 100.0
            
            result.append("\(medication): \(String(format: "%.1f", percentEffective))% effective")
        }
        return result
    }


    var body: some View{
        if showStats{
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top){
                    let font = UIFont.systemFont(ofSize: screenWidth * 0.05, weight: .bold)
                    let text = "Emergency Treatment Effectiveness:"
                    CustomText(text: text, color: bg, width: text.width(usingFont: font) + 10, bold: true, textSize: screenWidth * 0.05)
                
                    Spacer()
                    
                    HideButton(accent: accent, bg: bg, show: $showStats)
                }
                .frame(width: screenWidth - 50 - 15 * 2)
                .padding(.bottom, 5)
                
                ForEach(medicationEffectiveness, id: \.self) { item in
                    CustomText(
                        text: item,
                        color: bg,
                        textSize: screenWidth * 0.045
                    )
                }
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
                HiddenChart(bg:bg, accent:accent, chart:"Emergency Treatment Stats", hideChart: $showStats)
            }
            .frame(width: screenWidth)
        }
    }
}


struct TriggerStats: View{
    var accent: String
    var bg: String
    var logList: [UnifiedLog]
    var triggerOptions: [String]
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    @State var showStats: Bool = false
    
    
    var triggerStats: [String] {
        // All logs
        let allLogs = logList
        guard !allLogs.isEmpty else { return ["No trigger data available"] }
        
        // Count how many logs contain each trigger
        var triggerCounts: [String: Int] = [:]
        
        for log in allLogs {
            guard let triggers = log.trigger_names else { continue }
            for trigger in Set(triggers) {
                triggerCounts[trigger, default: 0] += 1
            }
        }
        
        let totalLogCount = allLogs.count
        var result: [String] = ["Total Logs: \(totalLogCount)"]
        
        //  Loop through every trigger option, even if it's not present in any logs
        for trigger in triggerOptions {
            let count = triggerCounts[trigger] ?? 0
            let percent = (Double(count) / Double(totalLogCount)) * 100
            result.append("\(trigger): \(String(format: "%.1f", percent))% of logs")
        }
        
        return result
    }

    var body: some View{
        if showStats{
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top){
                    let font = UIFont.systemFont(ofSize: screenWidth * 0.05, weight: .bold)
                    let text = "Trigger Stats:"
                    CustomText(text: text, color: bg, width: text.width(usingFont: font) + 10, bold: true, textSize: screenWidth * 0.05)
                
                    Spacer()
                    
                    HideButton(accent: accent, bg: bg, show: $showStats)
                }
                .frame(width: screenWidth - 50 - 15 * 2)
                .padding(.bottom, 5)
                
                ForEach(triggerStats, id: \.self) { item in
                    CustomText(
                        text: item,
                        color: bg,
                        textSize: screenWidth * 0.045
                    )
                }
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
                HiddenChart(bg:bg, accent:accent, chart:"Trigger Stats", hideChart: $showStats)
            }
            .frame(width: screenWidth)
        }
    }
}

struct DescriptionStats: View{
    var accent: String
    var bg: String
    var logList: [UnifiedLog]
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    @State var showStats: Bool = false
    
    
    var descriptionStats: [String] {
        let descriptionLogs = logList.filter { $0.symptom_description != nil && !$0.symptom_description!.isEmpty}
        
        let totalLogs = descriptionLogs.count
        
        var results = ["Total Side Effect Logs: \(totalLogs)"]
        
        var values: [String] = []

        values = descriptionLogs.flatMap { log -> [String] in
            guard let value = log.symptom_description, !value.isEmpty else { return [] }
            
            // Split by comma, trim whitespace, remove empty strings
            return value
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }

        // Count occurrences
        let counts = Dictionary(values.map { ($0, 1) }, uniquingKeysWith: +)
        
        let total = values.count

        // Step 4: Convert to percent format
        for (phrase, count) in counts {
            let percentage = Double(count) / Double(total) * 100
            let formatted = "\(phrase): \(String(format: "%.1f", percentage))%"
            results.append(formatted)
        }
        
        return results
    }

    var body: some View{
        if showStats{
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top){
                    let font = UIFont.systemFont(ofSize: screenWidth * 0.05, weight: .bold)
                    let text = "Symptom Description Stats:"
                    CustomText(text: text, color: bg, width: text.width(usingFont: font) + 10, bold: true, textSize: screenWidth * 0.05)
                
                    Spacer()
                    
                    HideButton(accent: accent, bg: bg, show: $showStats)
                }
                .frame(width: screenWidth - 50 - 15 * 2)
                .padding(.bottom, 5)
                
                ForEach(descriptionStats, id: \.self) { item in
                    CustomText(
                        text: item,
                        color: bg,
                        textSize: screenWidth * 0.045
                    )
                }
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
                HiddenChart(bg:bg, accent:accent, chart:"Symptom Description Stats", hideChart: $showStats)
            }
            .frame(width: screenWidth)
        }
    }
}

struct SideEffectStats: View{
    var accent: String
    var bg: String
    var logList: [UnifiedLog]
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    @State var showStats: Bool = true
    
    
    var sideEffectStats: [String] {
        let sideEffectLogs = logList.filter { $0.log_type == "Side Effect"}
        
        let totalLogs = sideEffectLogs.count
        
        var results = ["Logs With Description: \(totalLogs)"]
        
        let values = sideEffectLogs.compactMap { $0.side_effect_med }

        // Count occurrences
        let counts = Dictionary(values.map { ($0, 1) }, uniquingKeysWith: +)

        // Step 4: Convert to percent
        for (phrase, count) in counts {
            let percentage = Double(count) / Double(totalLogs) * 100
            let formatted = "\(phrase): \(String(format: "%.1f", percentage))%"
            results.append(formatted)
        }
        
        return results
    }

    var body: some View{
        if showStats{
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top){
                    let font = UIFont.systemFont(ofSize: screenWidth * 0.05, weight: .bold)
                    let text = "Side Effect Stats:"
                    CustomText(text: text, color: bg, width: text.width(usingFont: font) + 10, bold: true, textSize: screenWidth * 0.05)
                
                    Spacer()
                    
                    HideButton(accent: accent, bg: bg, show: $showStats)
                }
                .frame(width: screenWidth - 50 - 15 * 2)
                .padding(.bottom, 5)
                
                ForEach(sideEffectStats, id: \.self) { item in
                    CustomText(
                        text: item,
                        color: bg,
                        textSize: screenWidth * 0.045
                    )
                }
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
                HiddenChart(bg:bg, accent:accent, chart:"Side Effect Stats", hideChart: $showStats)
            }
            .frame(width: screenWidth)
        }
    }
}


