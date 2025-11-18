//
//  Statistics Components.swift
//  Trendy Headaches Supabase
//
//  Created by Abigail Barnhardt on 11/1/25.
//

import SwiftUI

//resuable component for stats cards
struct StatsCard: View {
    var title: String
    var items: [String]
    var accent: String
    var bg: String
    @Binding var show: Bool

    let screenWidth = UIScreen.main.bounds.width
    
    @State var typeFilter = "All Types"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack(alignment: .top){
                let font = UIFont.systemFont(ofSize: screenWidth * 0.06, weight: .bold)
                CustomText(text: title, color: bg, width: title.width(usingFont: font) + 10, bold: true, textSize: screenWidth * 0.06)
            
                Spacer()
                
                //hide button
                HideButton(accent: accent, bg: bg, show: $show)
            }
            .frame(width: screenWidth - 50 - 15 * 2)
            .padding(.bottom, 5)
            
            // Display each stat
            ForEach(items, id: \.self) { item in
                CustomText(text: item, color: bg, textSize: screenWidth * 0.055)
            }
        }
        .padding(.horizontal, 15)
        .padding(.top, 10)
        .padding(.bottom, 20)
        .background(Color(hex: accent))
        .cornerRadius(20)
        .frame(width: screenWidth - 50, alignment: .leading)
        .padding(.bottom, 10)
    }
}

//shows how many logs a user has total and weekly and monthly average
struct LogFrequencyStats: View{
    var accent: String
    var bg: String
    var logList: [UnifiedLog]
    
    let screenWidth = UIScreen.main.bounds.width

    @State var showStats: Bool = false

    var body: some View{
        
        //get the total, weekly average, and monthly average
        let frequencyStats = getFrequencyValues(logList: logList)
        
        //show the data
        if showStats{
            //card with header+data
            StatsCard(title: "Frequency Stats:", items: frequencyStats, accent: accent, bg: bg, show: $showStats)
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
    
    var body: some View{
        let averageSeverity = getSeverityValues(logList: logList)
        //card with the header+ data
        if showStats{
            StatsCard(title: "Average Severity:", items: averageSeverity, accent: accent, bg: bg, show: $showStats)
        }
        //if hidden, show show button
        else{
            HStack {
                HiddenChart(bg:bg, accent:accent, chart:"Average Severity", hideChart: $showStats)
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
        //also has to be symptom
        let filteredLogs = logList.filter { log in
            if let onset = log.onset_time, !onset.isEmpty, log.log_type == "Symptom" {
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
            StatsCard(title: "Symptom Onset Stats:", items: onsetPercents, accent: accent, bg: bg, show: $showStats)
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

//treatment history table
struct MedicationTable: View {
    var accent: String
    var bg: String
    var medList: [Medication]

    @State private var showStats: Bool = false
    
    let screenWidth = UIScreen.main.bounds.width
    let rowHeight: CGFloat = 35
    let visibleRows = 5
    
    private let columns = ["Name", "Cat.", "Start", "End", "Reason"]
    
    var body: some View {
        if showStats {
        VStack(spacing: 10) {
            //header
            HStack(alignment: .top){
                let font = UIFont.systemFont(ofSize: screenWidth * 0.06, weight: .bold)
                let title = "Treatment History: "
                CustomText(text: title, color: bg, width: title.width(usingFont: font) + 20, bold: true, textSize: screenWidth * 0.06)
            
                Spacer()
                
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
            .padding(.top, 10)

            //get the widths of each column
            let colWidths = calculateColumnWidths(medicationList: medList)

            //scroll horizontal and vertical with froxen top row
                ScrollView([.vertical, .horizontal], showsIndicators: true) {
                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        //frozen top row
                        Section(header:
                            HStack(spacing: 0) {
                            //make row headers
                            
                                ForEach(columns.indices, id: \.self) { i in
                                    CustomText(text: columns[i],color: bg,  textAlign: .center, bold: true,  textSize: screenWidth * 0.05)
                                    .frame(width: colWidths[i], height: rowHeight)
                                    .background(Color.blend(Color(hex: bg), Color(hex: accent), ratio: 0.8))
                                    .border(Color(hex: bg).opacity(0.2), width: 1)
                                }
                            })
                        {
                            //each of the data rows
                            ForEach(medList, id: \.medicationId) { med in
                                HStack(spacing: 0) {
                                    //format the dates to ##/##/##
                                    let startDisplay = formatDateString(dateString: med.medicationStart)
                                    let endDisplay = formatDateString(dateString:med.medicationEnd)
                                   
                                    //shorten med types
                                    let categoryDisplay = {
                                        switch med.medicationCategory.lowercased() {
                                        case "preventative": return "prev"
                                        case "emergency": return "emerg"
                                        default: return med.medicationCategory
                                        }
                                    }()
                                    
                                    let rowData = [med.medicationName, categoryDisplay, startDisplay,  endDisplay,  med.endReason ?? ""]

                                    //make each cell in the row
                                    ForEach(rowData.indices, id: \.self) { i in
                                        CustomText( text: rowData[i],color: bg, textAlign: .center,textSize: screenWidth * 0.035)
                                        .frame(width: colWidths[i], height: rowHeight)
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
        //if hidden, show the show button
        else{
            HiddenChart(bg: bg, accent: accent, chart: "Treatment Histroy", hideChart: $showStats)
        }
    }
}

//emergency med effectiveness stats
struct EmergencyMedStats: View{
    var accent: String
    var bg: String
    var logList: [UnifiedLog]
    
    let screenWidth = UIScreen.main.bounds.width
    @State var showStats: Bool = false
    
    //get the percent effective for each med
    var medicationEffectiveness: [String] {
        // Filter to only logs where medication was taken and effectivness recorded
        let medLogs = logList.filter { $0.med_taken == true && $0.med_worked != nil && $0.log_type == "Symptom"}
        
        // No data warning
        guard !medLogs.isEmpty else { return ["No data available"] }
        
        // Group logs by medication_name
        let groupedByMedication = Dictionary(grouping: medLogs) { log in
            log.medication_name ?? "Unknown Medication"
        }
        
        // Calculate effectiveness percentage for each medication
        var result: [String] = ["Logs With Emergency Treatment:  \(medLogs.count)"]
        
        for (medication, logs) in groupedByMedication {
            let total = logs.count
            let effectiveCount = logs.filter { $0.med_worked == true }.count
            let percentEffective = (Double(effectiveCount) / Double(total)) * 100.0
            
            result.append("\(medication): \(String(format: "%.1f", percentEffective))% effective")
        }
        return result
    }

    var body: some View{
        //show stats
        if showStats{
            //card with header+data
            StatsCard(title: "Emergency Treatment Effectiveness:", items: medicationEffectiveness, accent: accent, bg: bg, show: $showStats)
        }
        //if hidden, show show button
        else{
            HStack {
                HiddenChart(bg:bg, accent:accent, chart:"Emergency Treatment Stats", hideChart: $showStats)
            }
            .frame(width: screenWidth)
        }
    }
}

//show how often a trigger is present in logs
struct TriggerStats: View{
    var accent: String
    var bg: String
    var logList: [UnifiedLog]
    var triggerOptions: [String]
    
    let screenWidth = UIScreen.main.bounds.width
    @State var showStats: Bool = false
    
    //get the percent of logs with each trigger
    var triggerStats: [String] {
        let symptomLogs = logList.filter {$0.log_type == "Symptom"}
        //no data message
        guard !symptomLogs .isEmpty else { return ["No data available"] }
        
        // Count how many logs contain each trigger
        var triggerCounts: [String: Int] = [:]
        
        //see if a trigger is present in a logs trigger array, if so , count it
        for log in symptomLogs  {
            guard let triggers = log.trigger_names else { continue }
            for trigger in Set(triggers) {
                triggerCounts[trigger, default: 0] += 1
            }
        }
        
        //initialize result array with total
        var result: [String] = ["Total Logs: \(symptomLogs.count)"]
        
        //  Loop through every trigger option and get its prevelency
        for trigger in triggerOptions {
            let count = triggerCounts[trigger] ?? 0
            let percent = (Double(count) / Double(symptomLogs.count)) * 100
            result.append("\(trigger): \(String(format: "%.1f", percent))% of logs")
        }
        
        return result
    }

    var body: some View{
        //show the stats
        if showStats{
            //card with header+stats
            StatsCard(title: "Trigger Stats", items: triggerStats, accent: accent, bg: bg, show: $showStats)
        }
        //if hidden, show show button
        else{
            HStack {
                HiddenChart(bg:bg, accent:accent, chart:"Trigger Stats", hideChart: $showStats)
            }
            .frame(width: screenWidth)
        }
    }
}

//shows the prevelence of description phrases
struct DescriptionStats: View{
    var accent: String
    var bg: String
    var logList: [UnifiedLog]
    
    let screenWidth = UIScreen.main.bounds.width
    @State var showStats: Bool = false
    
    //ge the prevelence of each phrase
    var descriptionStats: [String] {
        //only get logs where descrioption is entered
        let descriptionLogs = logList.filter { $0.symptom_description != nil && !$0.symptom_description!.isEmpty && $0.log_type == "Symptom"}
        
        //no data warning
        guard !descriptionLogs .isEmpty else { return ["No data available"] }
        
        //initalize results with total logs
        var results = ["Logs With Description: \(descriptionLogs.count)"]
        
        var values: [String] = []

        //get each instance of a description phrase
        values = descriptionLogs.flatMap { log -> [String] in
            guard let value = log.symptom_description, !value.isEmpty else { return [] }
            
            // Split by comma, trim whitespace, and remove empty strings
            return value
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }

        // Count how many times each phrase appears
        let counts = Dictionary(values.map { ($0, 1) }, uniquingKeysWith: +)

        //Convert count to percent
        for (phrase, count) in counts {
            let percentage = Double(count) / Double(descriptionLogs.count) * 100
            let formatted = "\(phrase): \(String(format: "%.1f", percentage))%"
            results.append(formatted)
        }
        
        return results
    }

    var body: some View{
        if showStats{
            //card with header+stats
            StatsCard(title: "Symptom Description Stats:", items: descriptionStats, accent: accent, bg: bg, show: $showStats)
        }
        //show show stats button
        else{
            HStack {
                HiddenChart(bg:bg, accent:accent, chart:"Symptom Description Stats", hideChart: $showStats)
            }
            .frame(width: screenWidth)
        }
    }
}

//show distribution of side effect meds
struct SideEffectStats: View{
    var accent: String
    var bg: String
    var logList: [UnifiedLog]
    
    let screenWidth = UIScreen.main.bounds.width
    @State var showStats: Bool = false
    
    //get what percent of side effects are caused by each med
    var sideEffectStats: [String] {
        //only use side effect logs
        let sideEffectLogs = logList.filter { $0.log_type == "Side Effect"}
        
        guard !sideEffectLogs .isEmpty else { return ["No data available"] }
        
        //initalize results with total
        var results = ["Logs With Description: \(sideEffectLogs.count)"]
        
        //get all the instances of side efect med
        let values = sideEffectLogs.compactMap { $0.side_effect_med }

        //count how many times each med appears
        let counts = Dictionary(values.map { ($0, 1) }, uniquingKeysWith: +)

        // Convert counts to percent
        for (phrase, count) in counts {
            let percentage = Double(count) / Double(sideEffectLogs.count) * 100
            let formatted = "\(phrase): \(String(format: "%.1f", percentage))%"
            results.append(formatted)
        }
        
        return results
    }

    var body: some View{
        if showStats{
            //card with header+stats
            StatsCard(title: "Side Effect Stats:", items: sideEffectStats, accent: accent, bg: bg, show: $showStats)
        }
        //if hidden, show show button
        else{
            HStack {
                HiddenChart(bg:bg, accent:accent, chart:"Side Effect Stats", hideChart: $showStats)
            }
            .frame(width: screenWidth)
        }
    }
}
