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
    
    @State var selectedView: String = "Graphs"
    
    @State private var screenWidth: CGFloat = UIScreen.main.bounds.width

    //values to be intialized on appear from database
    @State var logs: [UnifiedLog] = []
    @State var symptomOptions: [String] = []
    @State var selectedSymptoms: [String] = []
    @State var selectedTypes: [String] = ["Symptom", "Side Effect"]
    @State var startDate: Date = Date()
    @State var medData: [Medication] = []
    @State var triggerOptions: [String] = []
    
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
    
    var body: some View {
        NavigationStack{
            ZStack {
                //things that are present regardless of analytics type
                AnalyticsBGComps(bg: bg, accent: accent)
                
                ScrollView{
                    HStack{
                        Spacer()
                        //change analytics type
                        AnalyticsDropdown(accent: accent, bg: bg, options: ["Graphs", "Statistics", "Comparison"],selected: $selectedView)
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
                            CustomText(text: "Compairison Screen", color: accent)
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
                        startDate = result.3 ?? Date()
                        
                        triggerOptions = try await Database.shared.getListVals(userId: userID, table: "Triggers", col: "trigger_name")
                        
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
