//
//  AnalyticsView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/31/25.
//

import SwiftUI

struct AnalyticsView: View {
    
    var userID: Int64
    
    @State var bg: String = ""
    @State var accent: String = ""
    
    @State var selectedView: String = "Compare"
    
    @State var screenWidth: CGFloat = UIScreen.main.bounds.width
    @EnvironmentObject var tutorialManager: TutorialManager

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
    @State var selectedMetric: String? = "Symptoms"
    @State var selectedSymptom1: String? = "Migraine"
    @State var selectedSymptom2: String? = "Anxiety"
    @State var range1Start: Date = Date()
    @State var range1End: Date = Date()
    @State var range2Start: Date = Date()
    @State var range2End: Date = Date()
    @State var selectedMed1: String? = ""
    @State var selectedMed2: String? = ""
    
    
    //set end date for filter for the end of the current date
    @State var endDate: Date = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date()) ?? Date()
    

    
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
                        else if selectedView == "Compare"{
                            CompareMetric(accent: accent, bg: bg, compareMetric: $selectedMetric, symptomOptions: $symptomOptions, prevMedOptions: $prevMedOptions, selectedSymptom1: $selectedSymptom1, selectedSymptom2: $selectedSymptom2, range1Start: $range1Start, range1End: $range1End, range2Start: $range2Start, range2End: $range2End, selectedMed1: $selectedMed1, selectedMed2: $selectedMed2)
                            
                            CompareFilter(bg: bg, accent: accent, selectedMetric: $selectedMetric, symptomOptions: $symptomOptions, selectedSymptom: $selectedSymptoms, startDate: $startDate, endDate: $endDate, selectedTypes: $selectedTypes)
                            
                            let set1Frequency = getFrequencyValues(logList: filteredCompareLogs.0, prefix: "")
                            let set2Frequency = getFrequencyValues(logList: filteredCompareLogs.1, prefix: "")
                            
                            CompareStatCard(accent: accent, bg: bg, statName: "Average Frequency ", data: (set1Frequency, set2Frequency), dataLabels: compareLables)
                            
                            let set1Severity = getSeverityValues(logList: filteredCompareLogs.0, prefix: "Avg. Severity")
                            let set2Severity = getSeverityValues(logList: filteredCompareLogs.1, prefix: "Avg. Severity")
                            
                            CompareStatCard(accent: accent, bg: bg, statName: "Average Severity ", data: (set1Severity, set2Severity), dataLabels: compareLables)
                            
                            let set1Emerg = getEmergTreatmentFreq(logList: filteredCompareLogs.0)
                            let set2Emerg = getEmergTreatmentFreq(logList: filteredCompareLogs.1)
                            
                            CompareStatCard(accent: accent, bg: bg, statName: "Emergency Treatment Frequency ", data: (set1Emerg, set2Emerg), dataLabels: compareLables)
                            
                        }
                    }
                    .padding(.bottom, 170)
                }
                
                //show tutorial if needed
                if tutorialManager.showTutorial {
                    AnalyticsTutorialPopup(bg: $bg,  accent: $accent, userID: userID, onClose: { tutorialManager.endTutorial() }  )
                        .zIndex(100)
                }
                
                //nav bar
                VStack {
                    Spacer()
                    NavBarView(userID: userID, bg: $bg,  accent: $accent, selected: .constant(2))
                }
                .ignoresSafeArea(edges: .bottom)
                .zIndex(10)
                //get colors, logs, and filter values
                .task{
                    await fetchColors()
                    await getAnalyticsData()
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    AnalyticsView(userID: 12)
        .environmentObject(TutorialManager())
}

