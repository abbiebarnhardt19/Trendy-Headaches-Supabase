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
    
    @State var medData: [Medication] = []
    
    var filteredLogs: [UnifiedLog] {
        if selectedSymptoms.isEmpty {
            return [] // ← return empty instead of all logs
        } else {
            return logs.filter { log in
                if let name = log.symptom_name {
                    return selectedSymptoms.contains(name)
                }
                return false
            }
        }
    }

    
    var body: some View {
        NavigationStack{
            ZStack {
                AnalyticsBGComps(bg: bg, accent: accent)
                
                ScrollView{
                    analyticsDropdown(accent: accent, bg: bg, selectedView: .constant("Graphs"))
                    
                    VStack(spacing: 0) {
                        
                        filterSymptom(bg: bg, accent: accent, symptomOptions: $symptomOptions, selectedSymptom: $selectedSymptoms)
                    
                        CalendarView(logs: filteredLogs, bg: bg, accent: accent, sympIcon: generateSymptomToIconMap(from: filteredLogs))
                        
                        SeverityPieChart(logList: filteredLogs, accent: accent, bg: bg)
                        
                        CustomStackedBarChart(logList: filteredLogs, accent: accent, bg: bg)
                        
                        MedicationTimeline(medications: medData, bg: bg, accent: accent, width: screenWidth - 40)
                    }
                    .padding(.bottom, 170)
                }
    
                VStack {
                    Spacer()
                    NavBarView(userID: userID, bg: $bg,  accent: $accent, selected: .constant(2))
                }
                .ignoresSafeArea(edges: .bottom)
                .zIndex(10)
                .task {
                    do {
                        let result = try await fetchAnalyticsData(userID: Int(userID))
                        logs = result.0
                        medData = result.1
                        symptomOptions = result.2
                        selectedSymptoms = result.2
                    } catch {
                        print("Error fetching all data:", error)
                    }
                }
            }
        }
    }
}

#Preview {
    AnalyticsView(userID:11, bg: .constant("#001d00"), accent: .constant("#b5c4b9"))
}
