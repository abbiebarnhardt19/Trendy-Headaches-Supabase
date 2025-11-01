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
    
    @State var logs: [UnifiedLog] = []
    @State var allLogs: [UnifiedLog] = []
    @State private var screenWidth: CGFloat = UIScreen.main.bounds.width
    @State private var screenHeight: CGFloat = UIScreen.main.bounds.height
    @State private var hideCalendar: Bool = true
    @State private var hideSeverity: Bool = true
    @State private var hideFreqChart: Bool = true
    @State private var hideMedTimeline: Bool = true
   
    @State var symptomOptions: [String] = []
    @State var selectedSymptoms: [String] = []
    
    @State var startDate: Date = Date()
    @State var endDate: Date = Date()

    
    @State var medData: [Medication] = []
    
    var filteredLogs: [UnifiedLog] {
        print("DEBUG filteredLogs: selectedSymptoms = \(selectedSymptoms)")
        print("DEBUG filteredLogs: startDate = \(startDate), endDate = \(endDate)")
        
        if selectedSymptoms.isEmpty {
            print("DEBUG filteredLogs: selectedSymptoms is EMPTY, returning []")
            return []
        } else {
            let filtered = logs.filter { log in
                guard let name = log.symptom_name else {
                    return false
                }
                
                let withinDateRange = log.date >= startDate && log.date <= endDate
                let symptomMatch = selectedSymptoms.contains(name)
                
                if log.trigger_names != nil {
                    print("DEBUG: Log \(log.log_id) - symptom: \(name), date: \(log.date), symptomMatch: \(symptomMatch), dateMatch: \(withinDateRange), triggers: \(log.trigger_names ?? [])")
                }
                
                return symptomMatch && withinDateRange
            }
            print("DEBUG filteredLogs: Returning \(filtered.count) logs")
            return filtered
        }
    }
    
    var body: some View {
        NavigationStack{
            ZStack {
                AnalyticsBGComps(bg: bg, accent: accent)
                
                ScrollView{
                    analyticsDropdown(accent: accent, bg: bg, selectedView: $selectedView)
                    
                    if selectedView == "Graphs"{
                        
                        VStack(spacing: 0) {
                            
                            filterSymptom(bg: bg, accent: accent, symptomOptions: $symptomOptions, selectedSymptom: $selectedSymptoms, startDate: $startDate, endDate: $endDate)
                            
                            LogCalendarView(logs: filteredLogs, bg: bg, accent: accent, sympIcon: generateSymptomToIconMap(from: filteredLogs))
                            
                            GenericPieChart(logList: filteredLogs, accent: accent, bg: bg, chartTitle: "Log Severity", groupBy: \.severity)
                            
                            CustomStackedBarChart(logList: filteredLogs, accent: accent, bg: bg)
                            
                            MedicationTimeline(medications: medData, bg: bg, accent: accent, width: screenWidth - 40)
                            
                            MedTakenCalendarView(logs: filteredLogs, bg: bg, accent: accent)
                            
                            GenericPieChart(logList: filteredLogs, accent: accent, bg: bg, chartTitle: "Emergency Treatment Effective", groupBy: \.med_worked)
                            
                            GenericPieChart(logList: filteredLogs, accent: accent, bg: bg, chartTitle: "Symptom Onset", groupBy: \.onset_time)
                            
                            AnalyticsBarChart(logs: filteredLogs, categoryColumn: "Side Effect", groupColumn: \UnifiedLog.side_effect_med, chartName: "Side Effect Medication", accent: accent, bg: bg)
                            
                            AnalyticsBarChart(logs: filteredLogs, categoryColumn: "Symptom", groupColumn: \UnifiedLog.trigger_names, chartName: "Trigger Frequency", accent: accent, bg: bg)
                            
                            AnalyticsBarChart(logs: filteredLogs, categoryColumn: "Symptom", groupColumn: \UnifiedLog.symptom_description, chartName: "Symptom Description", accent: accent, bg: bg)
                            
                            
                        }
                        .padding(.bottom, 170)
                    }
                    
                    else{
                        CustomText(text: "New Screen", color: accent)
                    }
                }
    
                VStack {
                    Spacer()
                    NavBarView(userID: userID, bg: $bg,  accent: $accent, selected: .constant(2))
                }
                .ignoresSafeArea(edges: .bottom)
                .zIndex(10)
                .onAppear {
                    // Set endDate when view first appears
                    let calendar = Calendar.current
                    endDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: Date()) ?? Date()
                }
                .task {
                    do {
                        let result = try await fetchAnalyticsData(userID: Int(userID))
                        logs = result.0
                        medData = result.1
                        symptomOptions = result.2
                        selectedSymptoms = result.2
                        startDate = result.3 ?? Date()
                        
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
