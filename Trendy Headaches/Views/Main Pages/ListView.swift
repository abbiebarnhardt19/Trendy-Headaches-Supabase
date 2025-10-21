//
//  ListView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 9/19/25.
//

import SwiftUI

struct ListView: View {
    var userID: Int64
    @Binding var bg: String
    @Binding var accent: String

    //for clicking on lost
    @State private var selectLog: Int64? = nil
    @State private var selectTable: String? = nil
    @State private var showLog: Bool = false
    
    //list of all logs for the table
    @State private var logList: [UnifiedLog] = []
    
    //bool for showing the filter dropdowns
    @State private var showFilter: Bool = false
    
    //column options filter
    @State var colOptions: [String] = ["Log Type", "Date", "Symptom", "Sev.", "Onset", "Triggers", "Em. Med. Taken?", "Em. Med. Name", "Em. Med. Worked?", "Symp. Desc.", "Notes ", "S.E. Med."]
    @State var selectedCols: [String] = ["Log Type", "Date", "Symptom", "Sev."]
    
    //for date filter
    @State var startDate: Date = Date()
    @State var endDate: Date = Date()
    @State var stringStartDate: String = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
    @State var stringEndDate: String = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
    
    //for severity filter
    @State var sevStart: Int64 = 1
    @State var sevEnd: Int64 = 10
    
    //for log type filter
    @State var logTypeOptions: [String] = ["Symptom", "Side Effect"]
    @State var logTypeFilter: [String] = ["Symptom", "Side Effect"]
    
    //for symptom filter
    @State var sympOptions: [String] = []
    @State var selectedSymps: [String] = []
    
    //for deleting
    @State var deleteCount: Int64 = 0
    
    //size variables
    var screenWidth: CGFloat = UIScreen.main.bounds.width
    var screenHeight: CGFloat = UIScreen.main.bounds.height
    var popupHeight: CGFloat = UIScreen.main.bounds.height-150 - 170 - 60
    
    //call this when any filter values change
    func filterLogs() {
        let allLogs = Database.shared.getLogList(userID: userID)
        logList = allLogs.filter { log in
            guard logTypeFilter.contains(log.log_type) else { return false }
            
            if log.date < startDate { return false }
            if log.date > endDate { return false }
            
            if log.severity < sevStart { return false }
            if log.severity > sevEnd { return false }
            
            guard selectedSymps.contains(log.symptom_name ?? "") else { return false }
            
            return true
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ListBGComps(bg: bg, accent: accent)
                
                VStack {
                    //page label
                    HStack{
                        CustomText(text: "Log List", color: accent, width:210, textAlign: .leading,  multiAlign: .leading,  textSize: 53)
                            .frame(height: 80)
                            .padding(.leading, UIScreen.main.bounds.width * 0.15)
                        Spacer()
                    }
                    .padding(.top, 10)
                    
                    //table
                    HStack{
                        Spacer()
                        ScrollableLogTable( userID: userID, list: logList, selectedCols: selectedCols, bg: bg, accent: accent, height: popupHeight, width: screenWidth - 20, deleteCount: $deleteCount, onLogTap: { id, table in
                            selectLog = id
                            selectTable = table
                        })
                        Spacer()
                    }
                    Spacer()
                }
                
                //filter dropdowns
                if showFilter {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            filterPopUp(accent: accent, bg: bg, colOptions: colOptions, selectedCols: $selectedCols, typeOptions: $logTypeOptions, type: $logTypeFilter, start: $startDate, end: $endDate, stringStart: $stringStartDate, stringEnd: $stringEndDate, sevStart: $sevStart, sevEnd: $sevEnd, sympOptions: $sympOptions, selectedSymps: $selectedSymps)
                                .padding(.trailing, 45)
                                .padding(.bottom, 130)
                        }
                    }
                    .transition(.move(edge: .bottom))
                    .zIndex(10)
                }

                //nav bar
                VStack {
                    Spacer()
                    HStack{
                        Spacer()
                        FilterDropDown(accent: accent, popUp: $showFilter)
                            .padding(.trailing, 10)
                            .padding(.bottom, UIScreen.main.bounds.height * 0.06)
                    }
                    NavBarView(userID: userID, bg: $bg,  accent: $accent, selected: .constant(1))
                }
                .ignoresSafeArea(edges: .bottom)
                .zIndex(1)
            }
            //go to log page when log is clicked
            .navigationDestination(isPresented: $showLog) {
                LogView(userID: userID, bg: $bg, accent: $accent)
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(
                isPresented: Binding(
                    get: { selectLog != nil },
                    set: { if !$0 { selectLog = nil } } ) ) {
                if let id = selectLog, let table = selectTable {
                    LogView(userID: userID, existingLog: id, existingTable: table, bg: $bg, accent: $accent)
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
        //load in user logs
        .onAppear{
            logList = Database.shared.getLogList(userID: userID)
            
            if let earliest = logList.map({ $0.date }).min() {
                startDate = earliest
                stringStartDate = DateFormatter.localizedString(from: earliest, dateStyle: .short, timeStyle: .none)
            }
            
            sympOptions = Array(Set( logList.compactMap { log in
                        if let symptom = log.symptom_name, !symptom.isEmpty {
                            return symptom
                        } else {
                            return nil
                        }
                    }))
            .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }

            selectedSymps = sympOptions
        }
        //update filters when values change
        .onChange(of: startDate) {  filterLogs() }
        .onChange(of: endDate) { filterLogs() }
        .onChange(of: logTypeFilter) {  filterLogs() }
        .onChange(of: sevStart) { filterLogs() }
        .onChange(of: sevEnd) {  filterLogs() }
        .onChange(of: selectedSymps) {  filterLogs() }
        .onChange(of: deleteCount) {  filterLogs() }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    ListView(userID: 1, bg: .constant("#001d00"), accent: .constant("#b5c4b9"))
}
