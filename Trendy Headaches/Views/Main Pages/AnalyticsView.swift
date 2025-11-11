//
//  AnalyticsView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/31/25.
//

import SwiftUI

struct AnalyticsView: View {
    
    var userID: Int64
    @Binding var bg: String
    @Binding var accent: String
    
    @State var selectedView: String = "Compare"
    
    @State private var screenWidth: CGFloat = UIScreen.main.bounds.width

    //values to be intialized on appear from database
    @State var logs: [UnifiedLog] = []
    @State var symptomOptions: [String] = []
    @State var selectedSymptoms: [String] = []
    @State var selectedTypes: [String] = ["Symptom", "Side Effect"]
    @State var startDate: Date = Date()
    @State var medData: [Medication] = []
    @State var triggerOptions: [String] = []
    @State var prevMedOptions: [String] = []
    
    //for comparison
    @State var selectedSymptom1: String? = ""
    @State var selectedSymptom2: String? = ""
    @State var range1Start: Date = Date()
    @State var range1End: Date = Date()
    @State var range2Start: Date = Date()
    @State var range2End: Date = Date()
    @State var selectedMed1: String? = ""
    @State var selectedMed2: String? = ""
    
    
    //set end date for filter for the end of the current date
    @State var endDate: Date = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date()) ?? Date()
    
    //filter logs based date, symptom, and log type
    var filteredLogs: [UnifiedLog] {
        
        let filtered = logs.filter { log in
            
            let withinDateRange = log.date >= startDate && log.date <= endDate
            let symptomMatch = selectedSymptoms.contains(log.symptom_name ?? "")
            let typeMatch = selectedTypes.contains(log.log_type)

            return symptomMatch && withinDateRange && typeMatch
        }
        return filtered
    }
//    
//    var filteredCompareLogs: ([UnifiedLog], [UnifiedLog]){
//        let filtered1 = compareLogs1.filter { log in
//            
//            let withinDateRange = log.date >= startDate && log.date <= endDate
//            let symptomMatch = selectedSymptoms.contains(log.symptom_name ?? "")
//            let typeMatch = selectedTypes.contains(log.log_type)
//
//            return symptomMatch && withinDateRange && typeMatch
//        }
//        
//        let filtered2 = compareLogs2.filter { log in
//            
//            let withinDateRange = log.date >= startDate && log.date <= endDate
//            let symptomMatch = selectedSymptoms.contains(log.symptom_name ?? "")
//            let typeMatch = selectedTypes.contains(log.log_type)
//
//            return symptomMatch && withinDateRange && typeMatch
//        }
//        return (filtered1, filtered2)
//    }
//    
//    var compareLogs1: [UnifiedLog] {
//        //go through each log and return the ones that match the conditions
//        return logs.filter { log in
//
//            let logDate: Date = log.date
//
//            //  Date range filter (only if user selected a range)
//            if range1End.timeIntervalSince(range1Start) > 1 {
//                return logDate >= range1Start && logDate <= range1End
//            }
//
//            // Symptom filter
//            if let symptom = selectedSymptom1, !symptom.isEmpty {
//                let logSymptom = log.symptom_name?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
//                return logSymptom == symptom.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
//            }
//
//            // Medication filter
//            else if let medName = selectedMed1, !medName.isEmpty {
//                
//                // Find the medication object
//                guard let med = medData.first(where: {
//                    $0.medicationName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
//                    == medName.lowercased()
//                }) else {
//                    return false
//                }
//                
//                // Convert medication start/end
//                let formatter = DateFormatter()
//                formatter.dateFormat = "yyyy-MM-dd"
//                
//                guard let startDate = formatter.date(from: med.medicationStart) else {
//                    print("Could not parse start date for \(med.medicationName)")
//                    return false
//                }
//                let endDate = med.medicationEnd.flatMap { formatter.date(from: $0) }
//
//                
//                // Compare logDate against med dates
//                if let end = endDate {
//                    return logDate >= startDate && logDate <= end
//                } else {
//                    return logDate >= startDate
//                }
//            }
//            // Default
//            return false
//        }
//    }
//    
//    var compareLogs2: [UnifiedLog] {
//        //go through each log and return the ones that match the conditions
//        return logs.filter { log in
//
//            let logDate: Date = log.date
//
//            //  Date range filter (only if user selected a range)
//            if range2End.timeIntervalSince(range2Start) > 1 {
//                return logDate >= range2Start && logDate <= range2End
//            }
//
//            // Symptom filter
//            if let symptom = selectedSymptom2, !symptom.isEmpty {
//                let logSymptom = log.symptom_name?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
//                return logSymptom == symptom.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
//            }
//
//            // Medication filter
//            else if let medName = selectedMed2, !medName.isEmpty {
//                
//                // Find the medication object
//                guard let med = medData.first(where: {
//                    $0.medicationName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
//                    == medName.lowercased()
//                }) else {
//                    return false
//                }
//                
//                // Convert medication start/end
//                let formatter = DateFormatter()
//                formatter.dateFormat = "yyyy-MM-dd"
//                
//                guard let startDate = formatter.date(from: med.medicationStart) else {
//                    print("Could not parse start date for \(med.medicationName)")
//                    return false
//                }
//                let endDate = med.medicationEnd.flatMap { formatter.date(from: $0) }
//
//                // Compare logDate against med dates
//                if let end = endDate {
//                    return logDate >= startDate && logDate <= end
//                } else {
//                    return logDate >= startDate
//                }
//            }
//            // Default
//            return false
//        }
//    }
    
    var filteredCompareLogs: ([UnifiedLog], [UnifiedLog]) {
        let filtered1 = filterCompareLogs(
            logs: logs,
            medData: medData,
            rangeStart: range1Start,
            rangeEnd: range1End,
            selectedSymptom: selectedSymptom1,
            selectedMed: selectedMed1,
            startDate: startDate,
            endDate: endDate,
            selectedSymptoms: selectedSymptoms,
            selectedTypes: selectedTypes
        )
        
        let filtered2 = filterCompareLogs(
            logs: logs,
            medData: medData,
            rangeStart: range2Start,
            rangeEnd: range2End,
            selectedSymptom: selectedSymptom2,
            selectedMed: selectedMed2,
            startDate: startDate,
            endDate: endDate,
            selectedSymptoms: selectedSymptoms,
            selectedTypes: selectedTypes
        )
        
        return (filtered1, filtered2)
    }

    func filterCompareLogs(
        logs: [UnifiedLog],
        medData: [Medication],
        rangeStart: Date,
        rangeEnd: Date,
        selectedSymptom: String?,
        selectedMed: String?,
        startDate: Date,
        endDate: Date,
        selectedSymptoms: [String],
        selectedTypes: [String]
    ) -> [UnifiedLog] {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return logs.filter { log in
            let logDate = log.date
            
            // --- Apply Global Filters First ---
            let withinMainDateRange = logDate >= startDate && logDate <= endDate
            let symptomMatch = selectedSymptoms.contains(log.symptom_name ?? "")
            let typeMatch = selectedTypes.contains(log.log_type)
            guard withinMainDateRange && symptomMatch && typeMatch else { return false }
            
            // --- Compare-specific Filters ---
            
            // If user picked a custom date range
            if rangeEnd.timeIntervalSince(rangeStart) > 1 {
                return logDate >= rangeStart && logDate <= rangeEnd
            }
            
            // If user picked a symptom
            if let symptom = selectedSymptom, !symptom.isEmpty {
                let logSymptom = log.symptom_name?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
                return logSymptom == symptom.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            }
            
            // If user picked a medication
            if let medName = selectedMed, !medName.isEmpty {
                guard let med = medData.first(where: {
                    $0.medicationName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                    == medName.lowercased()
                }) else { return false }
                
                guard let startMed = formatter.date(from: med.medicationStart) else { return false }
                let endMed = med.medicationEnd.flatMap { formatter.date(from: $0) }
                
                if let end = endMed {
                    return logDate >= startMed && logDate <= end
                } else {
                    return logDate >= startMed
                }
            }
            
            // Default (if no compare condition applies)
            return false
        }
    }


    var body: some View {
        NavigationStack{
            ZStack {
                //things that are present regardless of analytics type
                AnalyticsBGComps(bg: bg, accent: accent)
                
                ScrollView{
                    HStack{
                        Spacer()
                        //change analytics type
                        AnalyticsDropdown(accent: accent, bg: bg, options: ["Graphs", "Statistics", "Compare"],selected: $selectedView)
                            .padding(.trailing, 20)
                            .padding(.top, 20)
                    }
                        
                    VStack{
                        if selectedView == "Graphs"{

                            AnalyticsFilter(bg: bg, accent: accent, symptomOptions: $symptomOptions, selectedSymptom: $selectedSymptoms, startDate: $startDate, endDate: $endDate, selectedTypes: $selectedTypes)
                            
                            LogCalendarView(logs: filteredLogs, bg: bg, accent: accent, sympIcon: generateSymptomToIconMap(from: filteredLogs))
                            
                            GenericPieChart(logList: filteredLogs, accent: accent, bg: bg, chartTitle: "Log Severity", groupBy: \.severity)
                            
                            CustomStackedBarChart(logList: filteredLogs, accent: accent, bg: bg)
                            
                            AnalyticsBarChart(logs: filteredLogs, categoryColumn: "Symptom", groupColumn: \UnifiedLog.trigger_names, chartName: "Trigger Frequency", accent: accent, bg: bg)
                            
                            AnalyticsBarChart(logs: filteredLogs, categoryColumn: "Symptom", groupColumn: \UnifiedLog.symptom_description, chartName: "Symptom Description Key Words", accent: accent, bg: bg)
                            
                            GenericPieChart(logList: filteredLogs, accent: accent, bg: bg, chartTitle: "Symptom Onset", groupBy: \.onset_time)
                            
                            MedTakenCalendarView(logs: filteredLogs, bg: bg, accent: accent)
                            
                            AnalyticsBarChart(logs: filteredLogs, categoryColumn: "med_worked", groupColumn: "medication_name", chartName: "Emergency Treatment Effective", accent: accent, bg: bg)
                            
                            AnalyticsBarChart(logs: filteredLogs, categoryColumn: "Side Effect", groupColumn: \UnifiedLog.side_effect_med, chartName: "Side Effect Medication", accent: accent, bg: bg)
                        }
                        
                        else if selectedView == "Statistics"{
                            
                            AnalyticsFilter(bg: bg, accent: accent, symptomOptions: $symptomOptions, selectedSymptom: $selectedSymptoms, startDate: $startDate, endDate: $endDate, selectedTypes: $selectedTypes)
                            
                            LogFrequencyStats(accent: accent, bg: bg, logList: filteredLogs)
                            
                            SeverityStats(accent: accent, bg: bg, logList: filteredLogs)
                            
                            OnsetStats(accent: accent, bg: bg, logList: filteredLogs)
                            
                            TriggerStats(accent: accent, bg: bg, logList: filteredLogs, triggerOptions: triggerOptions)
                            
                            DescriptionStats(accent: accent, bg: bg, logList: filteredLogs)
                            
                            MedicationTable(accent: accent, bg: bg, medList: medData)
                            
                            EmergencyMedStats(accent: accent, bg: bg, logList: filteredLogs)
                            
                            SideEffectStats(accent: accent, bg: bg, logList: filteredLogs)
                        }
                        //else comparison
                        else{
                            CompareComponents(accent: accent, bg: bg, symptomOptions: $symptomOptions, prevMedOptions: $prevMedOptions, selectedSymptom1: $selectedSymptom1, selectedSymptom2: $selectedSymptom2, range1Start: $range1Start, range1End: $range1End, range2Start: $range2Start, range2End: $range2End, selectedMed1: $selectedMed1, selectedMed2: $selectedMed2)
                            
                            AnalyticsFilter(bg: bg, accent: accent, symptomOptions: $symptomOptions, selectedSymptom: $selectedSymptoms, startDate: $startDate, endDate: $endDate, selectedTypes: $selectedTypes)
                            
                            LogCalendarView(logs: filteredCompareLogs.1, bg: bg, accent: accent, sympIcon: generateSymptomToIconMap(from: filteredCompareLogs.1))
                        }
                    }
                    .padding(.bottom, 170)
                }
    
                //nav bar
                VStack {
                    Spacer()
                    NavBarView(userID: userID, bg: $bg,  accent: $accent, selected: .constant(2))
                }
                .ignoresSafeArea(edges: .bottom)
                .zIndex(10)
                //get values from daabase
                .task {
                    do {
                        let result = try await fetchAnalyticsData(userID: Int(userID))
                        logs = result.0
                        medData = result.1
                        symptomOptions = result.2
                        selectedSymptoms = result.2
                        triggerOptions = result.3
                        prevMedOptions = result.4
                        startDate = result.5 ?? Date()
                    } catch {
                        print("Error fetching all data:", error)
                    }
                }
            }
        }
    }
}

#Preview {
    AnalyticsView(userID:12, bg: .constant("#001d00"), accent: .constant("#b5c4b9"))
}
