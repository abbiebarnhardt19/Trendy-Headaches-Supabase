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
    
    @EnvironmentObject var tutorialManager: TutorialManager
    @EnvironmentObject var preloadManager: PreloadManager
    @EnvironmentObject var userSession: UserSession

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
                
                //show tutorial if needed
                if tutorialManager.showTutorial {
                    ListTutorialPopup(bg: $bg,  accent: $accent, userID: userID, onClose: { tutorialManager.endTutorial() }  )
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
                    .environmentObject(preloadManager)
                    .environmentObject(userSession)
                    .environmentObject(tutorialManager)
            }
            .navigationDestination(
                isPresented: Binding(
                    get: { selectLog != nil },
                    set: { if !$0 { selectLog = nil } } ) ) {
                        if let id = selectLog, let table = selectTable {
                            LogView(userID: userID, existingLog: id, existingTable: table)
                                .navigationBarBackButtonHidden(true)
                                .environmentObject(preloadManager)
                                .environmentObject(userSession)
                                .environmentObject(tutorialManager)
                        }
                        
            }
        }
        .task {
            //wait til data is fetched
            if !preloadManager.isFinished {
                await preloadManager.preloadAll(userID: userSession.userID)
            }
            
            //get preloaded values
            await setupListView()

        }
        .onChange(of: startDate) { filterLogs() }
        .onChange(of: endDate) {  filterLogs() }
        .onChange(of: logTypeFilter) { filterLogs() }
        .onChange(of: sevStart) {  filterLogs() }
        .onChange(of: sevEnd) {  filterLogs() }
        .onChange(of: selectedSymps) {  filterLogs() }
        .onChange(of: deleteCount) {
            Task {
                await preloadManager.preloadAll(userID: userID)
                await setupListView() }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    ListView(userID: 47)
        .environmentObject(TutorialManager())
        .environmentObject(PreloadManager())
        .environmentObject(UserSession())
}
