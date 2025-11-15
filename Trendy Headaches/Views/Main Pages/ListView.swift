//
//  ListView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 9/19/25.

import SwiftUI

struct ListView: View {
    var userID: Int64
    
    @State var hasLoaded: Bool = false
    @State var bg: String = ""
    @State var accent: String = ""

    //for clicking on log
    @State var selectLog: Int64? = nil
    @State var selectTable: String? = nil
    @State var showLog: Bool = false
    
    //list of all logs for the table
    @State var logList: [UnifiedLog] = []
    @State var allLogs: [UnifiedLog] = []
    
    //bool for showing the filter dropdowns
    @State var showFilter: Bool = false
    
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
    var maxTableHeight: CGFloat = UIScreen.main.bounds.height * 0.62
    
    //for tutorial
    @EnvironmentObject var tutorialManager: TutorialManager

    var body: some View {
        
        NavigationStack {
            ZStack {
                ListBGComps(bg: bg, accent: accent)
                
                VStack {
                    //page label
                    VStack{
                        HStack{
                            FilterButton(accent: $accent, bg: $bg, popUp: $showFilter, width: screenWidth * 0.12)
                                .padding(.trailing, 5)
                            let font = UIFont.systemFont(ofSize: screenWidth * 0.1 + 5, weight: .regular)
                            CustomText(text: "Log List", color: accent, width: "Log List".width(usingFont: font), textSize: screenWidth * 0.1)
                            
                            Spacer()
                        }
                    }
                    .frame(width: screenWidth)
                    .padding(.top, 25)
                    .padding(.bottom, 15)
                    .padding(.leading, 40)
                    
                    //table
                    HStack{
                        Spacer()
                        ScrollableLogTable( userID: userID, list: logList, selectedCols: selectedCols, bg: $bg, accent: $accent, height: maxTableHeight, width: screenWidth - 20, deleteCount: $deleteCount, onLogTap: { id, table in
                            selectLog = id
                            selectTable = table
                        })
                        Spacer()
                    }
                    Spacer()
                }
                
                // Filter popup as overlay
                if showFilter {
                    VStack {
                        HStack {
                            FilterOptions(accent: $accent, bg: $bg, colOptions: colOptions, selectedCols: $selectedCols, typeOptions: $logTypeOptions, type: $logTypeFilter, start: $startDate, end: $endDate, stringStart: $stringStartDate, stringEnd: $stringEndDate, sevStart: $sevStart, sevEnd: $sevEnd, sympOptions: $sympOptions, selectedSymps: $selectedSymps)
                                .padding(.leading, 40)

                            Spacer()
                        }
                        Spacer()
                    }
                    .padding(.top, screenHeight * 0.1)
                    .zIndex(1000)
                }
                
                if tutorialManager.showTutorial {
                    ListTutorialPopup(bg: $bg,  accent: $accent, userID: userID, onClose: { tutorialManager.endTutorial() }  )

                    .zIndex(100)
                }

                //nav bar
                VStack {
                    Spacer()
                    NavBarView(userID: userID, bg: $bg,  accent: $accent, selected: .constant(1))
                }
                .ignoresSafeArea(edges: .bottom)
                .zIndex(1)
            }

            .navigationDestination(isPresented: $showLog) {
                LogView(userID: userID)
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(
                isPresented: Binding(
                    get: { selectLog != nil },
                    set: { if !$0 { selectLog = nil } } ) ) {
                        if let id = selectLog, let table = selectTable {
                            LogView(userID: userID, existingLog: id, existingTable: table)
                                .navigationBarBackButtonHidden(true)
                        }
            }
        }
        .task {
            await fetchLogsAndSetupFilters()
            await fetchColors()
    
            // Also fetch symptom + side effect options
            Task {
                do {
                    let symptomList = try await Database.shared.getListVals(userId: userID, table: "Symptoms", col: "symptom_name")
                    let sideEffectList = try await Database.shared.getListVals(userId: userID, table: "Side_Effects", col: "side_effect_name")
                    sympOptions = Array(Set(symptomList + sideEffectList)).sorted()
                    selectedSymps = sympOptions
                } catch {
                    if (error as NSError).code != NSURLErrorCancelled {
                        print("Error fetching symptom options: \(error)")
                    }
                }
            }
        }
        .onChange(of: startDate) { filterLogs() }
        .onChange(of: endDate) {  filterLogs() }
        .onChange(of: logTypeFilter) { filterLogs() }
        .onChange(of: sevStart) {  filterLogs() }
        .onChange(of: sevEnd) {  filterLogs() }
        .onChange(of: selectedSymps) {  filterLogs() }
        .onChange(of: deleteCount) {
            Task { await fetchLogsAndSetupFilters() }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    ListView(userID: 12)
        .environmentObject(TutorialManager())
}
