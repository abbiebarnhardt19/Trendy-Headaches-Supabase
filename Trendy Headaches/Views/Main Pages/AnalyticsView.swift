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
    
    var compareLogs1: [UnifiedLog] {
        //go through each log and return the ones that match the conditions
        return logs.filter { log in

            let logDate: Date = log.date

            //  Date range filter (only if user selected a range)
            if range1End.timeIntervalSince(range1Start) > 1 {
                return logDate >= range1Start && logDate <= range1End
            }

            // Symptom filter
            if let symptom = selectedSymptom1, !symptom.isEmpty {
                print("Running symptom filter for:", symptom)
                let logSymptom = log.symptom_name?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
                return logSymptom == symptom.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            }

            // Medication filter
            else if let medName = selectedMed1, !medName.isEmpty {
                
                // Find the medication object
                guard let med = medData.first(where: {
                    $0.medicationName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                    == medName.lowercased()
                }) else {
                    return false
                }
                
                // Convert medication start/end
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                
                guard let startDate = formatter.date(from: med.medicationStart) else {
                    print("Could not parse start date for \(med.medicationName)")
                    return false
                }
                let endDate = med.medicationEnd.flatMap { formatter.date(from: $0) }

                
                // Compare logDate against med dates
                if let end = endDate {
                    return logDate >= startDate && logDate <= end
                } else {
                    return logDate >= startDate
                }
            }
            // Default
            return false
        }
    }
    
    var compareLogs2: [UnifiedLog] {
        //go through each log and return the ones that match the conditions
        return logs.filter { log in

            let logDate: Date = log.date

            //  Date range filter (only if user selected a range)
            if range2End.timeIntervalSince(range2Start) > 1 {
                return logDate >= range2Start && logDate <= range2End
            }

            // Symptom filter
            if let symptom = selectedSymptom2, !symptom.isEmpty {
                print("Running symptom filter for:", symptom)
                let logSymptom = log.symptom_name?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
                return logSymptom == symptom.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            }

            // Medication filter
            else if let medName = selectedMed2, !medName.isEmpty {
                
                // Find the medication object
                guard let med = medData.first(where: {
                    $0.medicationName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                    == medName.lowercased()
                }) else {
                    return false
                }
                
                // Convert medication start/end
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                
                guard let startDate = formatter.date(from: med.medicationStart) else {
                    print("Could not parse start date for \(med.medicationName)")
                    return false
                }
                let endDate = med.medicationEnd.flatMap { formatter.date(from: $0) }

                
                // Compare logDate against med dates
                if let end = endDate {
                    return logDate >= startDate && logDate <= end
                } else {
                    return logDate >= startDate
                }
            }
            // Default
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
                            
                            MedTakenCalendarView(logs: filteredLogs, bg: bg, accent: accent)
                            
                            GenericPieChart(logList: filteredLogs, accent: accent, bg: bg, chartTitle: "Emergency Treatment Effective", groupBy: \.med_worked)
                            
                            GenericPieChart(logList: filteredLogs, accent: accent, bg: bg, chartTitle: "Symptom Onset", groupBy: \.onset_time)
                            
                            AnalyticsBarChart(logs: filteredLogs, categoryColumn: "Side Effect", groupColumn: \UnifiedLog.side_effect_med, chartName: "Side Effect Medication", accent: accent, bg: bg)
                            
                            AnalyticsBarChart(logs: filteredLogs, categoryColumn: "Symptom", groupColumn: \UnifiedLog.trigger_names, chartName: "Trigger Frequency", accent: accent, bg: bg)
                            
                            AnalyticsBarChart(logs: filteredLogs, categoryColumn: "Symptom", groupColumn: \UnifiedLog.symptom_description, chartName: "Symptom Description Key Words", accent: accent, bg: bg)
                        }
                        
                        else if selectedView == "Statistics"{
                            
                            AnalyticsFilter(bg: bg, accent: accent, symptomOptions: $symptomOptions, selectedSymptom: $selectedSymptoms, startDate: $startDate, endDate: $endDate, selectedTypes: $selectedTypes)
                            
                            LogFrequencyStats(accent: accent, bg: bg, logList: filteredLogs)
                            
                            SeverityStats(accent: accent, bg: bg, logList: filteredLogs)
                            
                            OnsetStats(accent: accent, bg: bg, logList: filteredLogs)
                            
                            MedicationTable(accent: accent, bg: bg, medList: medData)
                            
                            EmergencyMedStats(accent: accent, bg: bg, logList: filteredLogs)
                            
                            TriggerStats(accent: accent, bg: bg, logList: filteredLogs, triggerOptions: triggerOptions)
                            
                            DescriptionStats(accent: accent, bg: bg, logList: filteredLogs)
                            
                            SideEffectStats(accent: accent, bg: bg, logList: filteredLogs)
                        }
                        //else comparison
                        else{
                            CompareComponents(accent: accent, bg: bg, symptomOptions: $symptomOptions, prevMedOptions: $prevMedOptions, selectedSymptom1: $selectedSymptom1, selectedSymptom2: $selectedSymptom2, range1Start: $range1Start, range1End: $range1End, range2Start: $range2Start, range2End: $range2End, selectedMed1: $selectedMed1, selectedMed2: $selectedMed2)
                            
                            LogCalendarView(logs: compareLogs2, bg: bg, accent: accent, sympIcon: generateSymptomToIconMap(from: compareLogs2))
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
                //get valies from daabase
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
