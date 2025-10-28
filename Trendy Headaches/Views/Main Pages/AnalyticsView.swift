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
    
    @State var logs: [UnifiedLog] = []
    @State var allLogs: [UnifiedLog] = []
    @State private var screenWidth: CGFloat = UIScreen.main.bounds.width
    @State private var screenHeight: CGFloat = UIScreen.main.bounds.height
    @State private var hideCalendar: Bool = true
    @State private var hideSeverity: Bool = true
    @State private var hideFreqChart: Bool = true
    @State private var hideMedTimeline: Bool = false
    @State private var showFilter: Bool = false
    
    @State var startDate: Date = Date()
    @State var endDate: Date = Date()
    @State var stringStartDate: String = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
    @State var stringEndDate: String = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
    
    @State var sympOptions: [String] = []
    @State var selectedSymps: [String] = []
    
    @State var medOptions: [String] = []
    @State var selectedMeds: [String] = []
    @State var medData: [Medication] = []
    
//    func filterLogs() {
//        
//        logs = allLogs.filter { log in
//            if log.date < startDate { return false }
//            if log.date > endDate { return false }
//
//            guard selectedSymps.contains(log.symptom_name ?? "") else { return false }
//            
//            
//            // Check if log date falls within any selected medication's active period
//            if selectedMeds.isEmpty {
//                return false
//            }
//            
//            let hasActiveMed = medData.contains { med in
//                // Only check preventative medications
//                guard med.medicationCategory == "preventative" else {
//                    return false
//                }
//                
//                // Check if medication is in selected list
//                guard selectedMeds.contains(med.medicationName) else {
//                    return false
//                }
//                
//                // Convert string dates to Date objects
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "yyyy-MM-dd"
//                
//                guard let medStartDate = dateFormatter.date(from: med.medicationStart) else {
//                    print("Failed to parse start date: \(med.medicationStart)")
//                    return false
//                }
//                
//                // Check if log date is after medication start
//                if log.date < medStartDate { return false }
//                
//                // If end_date exists, check if log is before it
//                if let endDateString = med.medicationEnd, !endDateString.isEmpty {
//                    if let medEndDate = dateFormatter.date(from: endDateString) {
//                        if log.date > medEndDate {
//                            return false
//                        }
//                    }
//                }
//                
//                return true
//            }
//            
//            if !hasActiveMed { return false }
//            
//            return true
//        }
//    }
    func filterLogs() {
        print("Total logs: \(allLogs.count)")
        print("Selected symptoms: \(selectedSymps)")
        print("Selected meds: \(selectedMeds)")
        print("Med data count: \(medData.count)")
        
        logs = allLogs.filter { log in
            if log.date < startDate {
                print("❌ Log filtered: before startDate")
                return false
            }
            if log.date > endDate {
                print("❌ Log filtered: after endDate")
                return false
            }

            guard selectedSymps.contains(log.symptom_name ?? "") else {
                print("❌ Log filtered: symptom not selected - \(log.symptom_name ?? "nil")")
                return false
            }
            
            if selectedMeds.isEmpty {
                print("❌ Log filtered: no meds selected")
                return false
            }
            
            print("🔍 Checking log date: \(log.date)")
            print("Available meds in medData: \(medData.map { "\($0.medicationName) (\($0.medicationCategory))" })")

            let hasActiveMed = medData.contains { med in
                print("  Checking med: \(med.medicationName), category: \(med.medicationCategory)")
                
                guard med.medicationCategory == "preventative" else {
                    print("    ❌ Not preventative")
                    return false
                }
                
                print("    ✓ Is preventative")
                print("    Selected meds: \(selectedMeds)")
                
                guard selectedMeds.contains(med.medicationName) else {
                    print("    ❌ Not in selected meds")
                    return false
                }
                
                print("    ✓ Is selected")
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                
                print("    Med start string: '\(med.medicationStart)'")
                guard let medStartDate = dateFormatter.date(from: med.medicationStart) else {
                    print("    ⚠️ Failed to parse start date: \(med.medicationStart)")
                    return false
                }
                
                print("    Med start date: \(medStartDate)")
                print("    Log date: \(log.date)")
                print("    Log >= Start? \(log.date >= medStartDate)")
                
                if log.date < medStartDate {
                    print("    ❌ Log before med start")
                    return false
                }
                
                if let endDateString = med.medicationEnd, !endDateString.isEmpty {
                    print("    Med end string: '\(endDateString)'")
                    if let medEndDate = dateFormatter.date(from: endDateString) {
                        print("    Med end date: \(medEndDate)")
                        print("    Log <= End? \(log.date <= medEndDate)")
                        if log.date > medEndDate {
                            print("    ❌ Log after med end")
                            return false
                        }
                    }
                } else {
                    print("    ✓ No end date (ongoing)")
                }
                
                print("    ✅ Found active med: \(med.medicationName)")
                return true
            }

            print("hasActiveMed result: \(hasActiveMed)")

            if !hasActiveMed {
                print("❌ Log filtered: no active preventative med")
                return false
            }
            
            print("✅ Log passed all filters")
            return true
        }
        
        print("Filtered logs: \(logs.count)")
    }
    
    var body: some View {
        NavigationStack{
            ZStack {
                AnalyticsBGComps(bg: bg, accent: accent)
                
                ScrollView{
                    VStack(spacing: 0) {
                        VStack{
                            HStack{
                                Spacer()
                                let font = UIFont.systemFont(ofSize: screenWidth * 0.1 + 5, weight: .regular)
                                CustomText(text: "Analytics", color: accent, width: "Analytics".width(usingFont: font), textSize: screenWidth * 0.1)
                                FilterDropDown(accent: accent, bg: bg, popUp: $showFilter, width: screenWidth * 0.12)
                            }
                        }
                        .frame(width: screenWidth)
                        .padding(.top, 25)
                        .padding(.bottom, 15)
                        .padding(.trailing, 20)
                    

                        if !hideCalendar{
                            CalendarView(logs: logs, hideChart: $hideCalendar, bg: bg, accent: accent, sympIcon: generateSymptomToIconMap(from: logs))
                        }
                        else{
                            HiddenChart(bg: bg, accent: accent, chart: "Calendar",  hideChart: $hideCalendar)
                        }
                        
                        if !hideSeverity{
                            SeverityPieChart(logList: logs, accent: accent, bg: bg, hideChart: $hideSeverity)
                                .padding(.bottom, 10)
                        }
                        else{
                            HiddenChart(bg: bg, accent: accent, chart: "Log Severity",  hideChart: $hideSeverity)
                        }
                        
                        if !hideFreqChart{
                            CustomStackedBarChart(logList: logs, accent: accent, bg: bg, hideChart: $hideFreqChart)
                        }
                        else{
                            HiddenChart(bg: bg, accent: accent, chart: "Logs by Symptom",  hideChart: $hideFreqChart)
                        }
                        
                        if !hideMedTimeline {
                            MedicationTimeline(medications: medData, bg: bg, accent: accent, width: screenWidth - 40, hideTimeline: $hideMedTimeline)
                        }
                        else {
                            HiddenChart(bg: bg, accent: accent, chart: "Treatment Timeline", hideChart: $hideMedTimeline)
                        }
                    }
                    .padding(.bottom, 170)
                }
                
                // Filter popup as overlay
                if showFilter {
                    VStack {
                        HStack {
                            Spacer()
                            analyticsFilter(accent: accent, bg: bg, start: $startDate, end: $endDate, stringStart: $stringStartDate, stringEnd: $stringEndDate, sympOptions: $sympOptions, selectedSymps: $selectedSymps, medOptions: $medOptions, selectedMeds: $selectedMeds)
                                .padding(.trailing, screenWidth * 0.14 / 3.5)
                                .padding(.top, 80)
                        }
                        Spacer()
                    }
                    .zIndex(1000)
                }
    
                VStack {
                    Spacer()

                    NavBarView(userID: userID, bg: $bg,  accent: $accent, selected: .constant(2))
                }
                .ignoresSafeArea(edges: .bottom)
                .zIndex(10)
                .task {
                    do {
                        allLogs = try await Database.shared.getLogList(userID: userID)
                        logs = allLogs
                    } catch {
                        if (error as NSError).code != NSURLErrorCancelled {
                            print("Error fetching unified logs: \(error)")
                        }
                    }
                    
                    if let earliest = allLogs.map({ $0.date }).min() {
                        startDate = earliest
                        stringStartDate = DateFormatter.localizedString(from: earliest, dateStyle: .short, timeStyle: .none)
                    }
                    
                    sympOptions = Array(Set( allLogs.compactMap { log in
                                if let symptom = log.symptom_name, !symptom.isEmpty {
                                    return symptom
                                } else {
                                    return nil
                                }
                            }))
                    .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }

                    selectedSymps = sympOptions
                    
                    Task {
                        do {
                            medOptions = try await Database.shared.getListVals(userId: userID, table: "Medications", col: "medication_name", filterCol: "medication_category", filterVal: "preventative", includeInactive: true)
                            selectedMeds = medOptions
                        } catch {
                            if (error as NSError).code != NSURLErrorCancelled {
                                print("Error fetching medications: \(error)")
                            }
                        }
                    }
                    
                    do {
                        medData = try await Database.shared.getMedications(userId: userID)
                    } catch {
                        if (error as NSError).code != NSURLErrorCancelled {
                            print("Error fetching medications: \(error)")
                        }
                    }
                }
                .onChange(of: startDate) {  filterLogs() }
                .onChange(of: endDate) { filterLogs() }
                .onChange(of: selectedSymps) {filterLogs()}
                .onChange(of: selectedMeds) {filterLogs()}
            }
        }
    }
}

#Preview {
    AnalyticsView(userID:11, bg: .constant("#001d00"), accent: .constant("#b5c4b9"))
}
