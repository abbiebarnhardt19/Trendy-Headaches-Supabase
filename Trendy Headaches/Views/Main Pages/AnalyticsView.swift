////
////  AnalyticsView.swift
////  Trendy Headaches
////
////  Created by Abigail Barnhardt on 8/31/25.
////
//
////testing if the new supabase repo works
//import SwiftUI
////test
//
//struct AnalyticsView: View {
//    
//    var userID: Int64
//    @Binding var bg: String
//    @Binding var accent: String
//    
//    @State var logs: [UnifiedLog] = []
//    @State private var screenWidth: CGFloat = UIScreen.main.bounds.width
//    @State private var hideCalendar: Bool = true
//    @State private var hideSeverity: Bool = true
//    @State private var hideFreqChart: Bool = false
//    @State private var showFilter: Bool = false
//    
//    @State var startDate: Date = Date()
//    @State var endDate: Date = Date()
//    @State var stringStartDate: String = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
//    @State var stringEndDate: String = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
//    
//    @State var sympOptions: [String] = []
//    @State var selectedSymps: [String] = []
//    
//    func filterLogs() {
//        let allLogs = Database.shared.getLogList(userID: userID)
//        logs = allLogs.filter { log in
//            if log.date < startDate { return false }
//            if log.date > endDate { return false }
//            
//            guard selectedSymps.contains(log.symptom_name ?? "") else { return false }
//            
//            return true
//        }
//    }
//    
//    var body: some View {
//        NavigationStack{
//            ZStack {
//                AnalyticsBGComps(bg: bg, accent: accent)
//                ScrollView{
//                    VStack(spacing: 0) {
//                        HStack{
//                            Spacer()
//                            CustomText(text: "Analytics", color: accent, width: 220, textSize: 53)
//                        }
//                        .frame(width: screenWidth)
//                        .padding(.vertical, 25)
//                        .padding(.trailing, 20)
//
//                        if !hideCalendar{
//                            CalendarView(logs: logs, hideChart: $hideCalendar, bg: bg, accent: accent, sympIcon: generateSymptomToIconMap(from: logs))
//                        }
//                        else{
//                            HiddenChart(bg: bg, accent: accent, chart: "Calendar", width: screenWidth,  hideChart: $hideCalendar)
//                        }
//                        
//                        if !hideSeverity{
//                            SeverityPieChart(logList: logs, accent: accent, bg: bg, hideChart: $hideSeverity)
//                                .padding(.bottom, 10)
//                        }
//                        else{
//                            HiddenChart(bg: bg, accent: accent, chart: "Log Severity", width: screenWidth,  hideChart: $hideSeverity)
//                        }
//                        
//                        if !hideFreqChart{
//                            CustomStackedBarChart(logList: logs, accent: accent, bg: bg, hideChart: $hideFreqChart)
//                        }
//                        else{
//                            HiddenChart(bg: bg, accent: accent, chart: "Logs by Symptom", width: screenWidth,  hideChart: $hideFreqChart)
//                        }
//                    }
//                    .padding(.bottom, 150)
//                }
//    
//                // Nav bar overlay at bottom
//                VStack {
//                    Spacer()
//                    HStack{
//                        if showFilter{
//                            Spacer()
//                            analyticsFilter(accent: accent, bg: bg, start: $startDate, end: $endDate, stringStart: $stringStartDate, stringEnd: $stringEndDate, sympOptions: $sympOptions, selectedSymps: $selectedSymps)
//                                .padding(.trailing, 20)
//                        }
//                    }
//                    HStack{
//                        Spacer()
//                        FilterDropDown(accent: bg, popUp: $showFilter)
//                            .padding(.bottom, 12)
//                    }
//
//                    NavBarView(userID: userID, bg: $bg,  accent: $accent, selected: .constant(2))
//                }
//                .ignoresSafeArea(edges: .bottom)
//                .zIndex(10)
//                .onAppear{
//                    logs = Database.shared.getLogList(userID: userID)
//                    
//                    if let earliest = logs.map({ $0.date }).min() {
//                        startDate = earliest
//                        stringStartDate = DateFormatter.localizedString(from: earliest, dateStyle: .short, timeStyle: .none)
//                    }
//                    
//                    sympOptions = Array(Set( logs.compactMap { log in
//                                if let symptom = log.symptom_name, !symptom.isEmpty {
//                                    return symptom
//                                } else {
//                                    return nil
//                                }
//                            }))
//                    .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
//
//                    selectedSymps = sympOptions
//                }
//                .onChange(of: startDate) {  filterLogs() }
//                .onChange(of: endDate) { filterLogs() }
//                .onChange(of: selectedSymps) {filterLogs()}
//            }
//        }
//    }
//}
//
//#Preview {
//    AnalyticsView(userID: 1, bg: .constant("#001d00"), accent: .constant("#b5c4b9"))
//}

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
    @State private var hideFreqChart: Bool = false
    @State private var showFilter: Bool = false
    
    @State var startDate: Date = Date()
    @State var endDate: Date = Date()
    @State var stringStartDate: String = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
    @State var stringEndDate: String = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
    
    @State var sympOptions: [String] = []
    @State var selectedSymps: [String] = []
    
    func filterLogs() {
        logs = allLogs.filter { log in
            if log.date < startDate { return false }
            if log.date > endDate { return false }
            
            guard selectedSymps.contains(log.symptom_name ?? "") else { return false }
            
            return true
        }
    }
    
    var body: some View {
        NavigationStack{
            ZStack {
                AnalyticsBGComps(bg: bg, accent: accent)
                ScrollView{
                    VStack(spacing: 0) {
                        HStack{
                            Spacer()
                            CustomText(text: "Analytics", color: accent, width: 220, textSize: 53)
                        }
                        .frame(width: screenWidth)
                        .padding(.vertical, 25)
                        .padding(.trailing, 20)

                        if !hideCalendar{
                            CalendarView(logs: logs, hideChart: $hideCalendar, bg: bg, accent: accent, sympIcon: generateSymptomToIconMap(from: logs))
                        }
                        else{
                            HiddenChart(bg: bg, accent: accent, chart: "Calendar", width: screenWidth,  hideChart: $hideCalendar)
                        }
                        
                        if !hideSeverity{
                            SeverityPieChart(logList: logs, accent: accent, bg: bg, hideChart: $hideSeverity)
                                .padding(.bottom, 10)
                        }
                        else{
                            HiddenChart(bg: bg, accent: accent, chart: "Log Severity", width: screenWidth,  hideChart: $hideSeverity)
                        }
                        
                        if !hideFreqChart{
                            CustomStackedBarChart(logList: logs, accent: accent, bg: bg, hideChart: $hideFreqChart)
                        }
                        else{
                            HiddenChart(bg: bg, accent: accent, chart: "Logs by Symptom", width: screenWidth,  hideChart: $hideFreqChart)
                        }
                    }
                    .padding(.bottom, 150)
                }
    
                // Nav bar overlay at bottom
                VStack {
                    Spacer()
                    HStack{
                        if showFilter{
                            Spacer()
                            analyticsFilter(accent: accent, bg: bg, start: $startDate, end: $endDate, stringStart: $stringStartDate, stringEnd: $stringEndDate, sympOptions: $sympOptions, selectedSymps: $selectedSymps)
                                .padding(.trailing, 20)
                        }
                    }
                    HStack{
                        Spacer()
                        FilterDropDown(accent: bg, popUp: $showFilter, width: CGFloat(60))
                            .padding(.bottom, 12)
                    }

                    NavBarView(userID: userID, bg: $bg,  accent: $accent, selected: .constant(2), width: screenWidth, height: screenHeight)
                }
                .ignoresSafeArea(edges: .bottom)
                .zIndex(10)
                .task {
                    allLogs = await Database.shared.getLogList(userID: userID)
                    logs = allLogs
                    
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
                }
                .onChange(of: startDate) {  filterLogs() }
                .onChange(of: endDate) { filterLogs() }
                .onChange(of: selectedSymps) {filterLogs()}
            }
        }
    }
}

#Preview {
    AnalyticsView(userID:11, bg: .constant("#001d00"), accent: .constant("#b5c4b9"))
}
