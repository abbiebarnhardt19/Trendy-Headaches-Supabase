//
//  LogView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/31/25.
//

import SwiftUI
import Foundation

struct LogView: View {
    //  Inputs
    var userID: Int64
    var existingLog: Int64? = nil
    var existingTable: String? = nil
    
    //color variable
    //@State var hasLoaded: Bool = false
    @State var bg: String = ""
    @State var accent: String = ""
    
    // Layout
    let leadPadd: CGFloat = 60
    @State var screenWidth: CGFloat = UIScreen.main.bounds.width
    @State  var screenHeight: CGFloat = UIScreen.main.bounds.height
    
    // Shared State
    @EnvironmentObject var tutorialManager: TutorialManager
    @EnvironmentObject var preloadManager: PreloadManager
    @EnvironmentObject var userSession: UserSession

    @State  var showSymptomView = true
    @State  var logID: Int64 = 0
    @State  var showPopup: Bool = false
    @State  var date: Date = Date()
    
    //  Symptom Log variables
    @State  var stringDate: String = ""
    @State  var onset: String?
    @State  var onsetOptions: [String] = ["From Wake", "Morning", "Afternoon", "Evening"]
    @State  var symp: String?
    @State  var sympOptions: [String] = []
    @State  var severity: Int64 = 1
    @State  var medTaken: Bool = false
    @State  var emergMedOptions: [String] = []
    @State  var medTakenName: String?
    @State  var sympDesc: String = ""
    @State  var notes: String = ""
    @State  var triggOptions: [String] = []
    @State  var selectedTriggs: [String] = []
    @State  var sympID: Int64 = 0
    @State  var triggIDs: [Int64] = []
    @State  var emergMedID: Int64? = nil
    
    //  Side Effect Log variables
    @State  var sideEffectName: String = ""
    @State  var sideEffectSev: Int64 = 0
    @State  var medOptions: [String] = []
    @State  var selectedMed: String?
    @State  var medID: Int64 = 0
    
    //for med popup
    @State  var medWorked: Bool? = nil
    @State  var oldLogIDs: [Int64] = [0]
    
    //for log editing
    @State  var medEffective: Bool = false
    
    @State  var listView = false
    
    // Date Formatter
     let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()
    
     var formValid: Bool {
        if showSymptomView{
            // Base condition for symptom log
            var isValid = symp != nil && severity > 0
            
            if medTaken {
                isValid = isValid && !(medTakenName?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
            }
            
            return isValid
            
        } else {
            // Side effect log condition
            return !sideEffectName.isEmpty && sideEffectSev > 0 && selectedMed != nil
        }
    }
    
    //  Body
    var body: some View {
        NavigationStack {
            ZStack {
                //only show log screen if data is loaded
                if preloadManager.isFinished{
                    LogBGComps(bg: bg, accent: accent)
                    
                    //if log needs emergency treatment effective
                    if showPopup, !oldLogIDs.isEmpty {
                        EmergencyMedPopup(selectedAnswer: $medWorked, isPresented: $showPopup,  oldLogID: oldLogIDs[0],  background: bg, accent: accent)
                            .zIndex(5)
                            .onDisappear {
                                // When the popup closes, remove the first ID
                                if !oldLogIDs.isEmpty {
                                    medWorked = nil
                                    oldLogIDs.removeFirst()
                                    
                                    // If there are more, show the next one
                                    if !oldLogIDs.isEmpty {
                                        showPopup = true
                                    }
                                }
                            }
                    }
                    
                    //scrollable part, header+ content
                    ScrollView {
                        headerSection
                            .padding(.top, 20)
                            .frame(width: screenWidth)
                        
                        if showSymptomView {
                            symptomLogView
                        } else {
                            sideEffectLogView
                        }
                    }
                    .padding(.leading, leadPadd)
                    
                    
                    if tutorialManager.showTutorial {
                        LogTutorialPopup(bg: $bg,  accent: $accent, userID: userID, onClose: { tutorialManager.endTutorial() }  )
                    }
                    
                    //nav bar
                    VStack { Spacer(); NavBarView(userID: userID, bg: $bg, accent: $accent, selected: .constant(0)) }
                        .zIndex(1)
                        .ignoresSafeArea(edges: .bottom)
                }
                //show loading screen while waiting for data
                else{
                    
                   let tempAccent = "#b5c4b9"
                   let tempBg = "#001d00"
                   // Show loading screen while preload is running
                   VStack {
                       MultiBlobSpinner(color: Color(hex: tempAccent))
                       CustomText(text: "Hang tight! We're loading your data.", color: tempAccent, width: screenWidth * 0.75, textAlign: .center, multiAlign: .center)
                       
                   }
                   .frame(maxWidth: screenWidth, maxHeight: .infinity)
                   .background(Color(hex: tempBg))
                }
            }
        }
        .task {
            //wait til data is fetched
            if !preloadManager.isFinished {
                await preloadManager.preloadAll(userID: userSession.userID)
            }

            // assign the preloaded values
            await setupLogView()
            
            //get popup
            let results = await Database.shared.emergencyMedPopup(userID: userID)
            if !results.isEmpty {
                oldLogIDs = results
                showPopup = true
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    //  Subviews
    
    //header and toggle, used in both symptom and side effect
     var headerSection: some View {
        HStack {
            CustomText(text: showSymptomView ? "Symptom Log" : "Side Effect Log", color: accent, textAlign: .center,  textSize: screenWidth * 0.1)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.trailing, 10)
            .padding(.top, 5)
            
            CustomToggle(color: accent, feature: $showSymptomView)
                .padding(.trailing, leadPadd)
                .padding(.top, 7)
        }
    }
    
    //symptom log view
     var symptomLogView: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 17) {
                DateTextField(date: $date, textValue: $stringDate, bg: $bg, accent: $accent, width: screenWidth * 0.8, bold: true)
                
                CustomText(text: "Symptom*", color: accent, bold: true, textSize: screenWidth * 0.06)
                MultipleChoice(options: $sympOptions, selected: $symp, accent: accent, width: screenWidth - 60, textSize: screenHeight * 0.05 / 2.2)
                
                CustomText(text: "Symptom Severity*", color: accent, bold: true, textSize: screenWidth * 0.06)
                Slider(value: $severity, range: 1...10, step: 1, color: accent, width: screenWidth - 50)
                
                CustomText(text: "Symptom Onset", color: accent, bold: true, textSize: screenWidth * 0.06)
                MultipleChoice(options: $onsetOptions, selected: $onset, accent: accent, width: screenWidth - 80, textSize: screenHeight * 0.05 / 2.2)
                
                SingleCheckbox(text: "Emergency Treatment?", color: accent, isOn: $medTaken, textSize: screenWidth * 0.06)
                
                if medTaken{
                    CustomText(text: "Emergency Treatment Name*", color: accent, bold: true, textSize: screenWidth * 0.06)
                    MultipleChoice(options: $emergMedOptions, selected: $medTakenName, accent: accent, width: screenWidth - 60,  textSize: screenHeight * 0.05 / 2.2)
                        
                    
                    if existingLog != nil{
                        SingleCheckbox(text: "Emergency Med Effective?", color: accent, isOn: $medEffective, textSize: screenWidth * 0.06)
                    }
                }
                
                CustomText(text: "Triggers Present", color: accent, bold: true, textSize: screenWidth * 0.06)
                
                
                MultipleCheckboxWrapped(options: $triggOptions, selected: $selectedTriggs, accent: bg,  bg: accent, width: screenWidth-100, textSize: screenHeight * 0.05 / 2.2)
                    .padding(.leading, 5)
                
                textFieldSection(title: "Symptom Description", text: $sympDesc)
                textFieldSection(title: "Notes", text: $notes)
                
                // Inside your symptom log view
                HStack{
                    Spacer()
                    
                    let buttonText = existingLog != nil ? "Submit" : "Save"

                    CustomButton(text: buttonText, bg: bg, accent: accent, height: screenHeight * 0.05, width: 150, textSize: screenWidth * 0.055) {
                        if existingLog == nil{
                            Task{
                                logID = await Database.shared.createLog(userID: userID, date: date, symptom_onset: onset, symptomName: symp ?? "",  severity: severity, med_taken: medTaken, medTakenName: medTakenName, symptom_desc: sympDesc, notes: notes, submit: Date(), triggerNames: selectedTriggs) ?? 0
                                
                                await preloadManager.preloadAll(userID: userID)
                                
                                listView = true
                            }
                        }
                        else{
                            Task {
                                if medTakenName != nil && medTakenName != ""{
                                    emergMedID = (await Database.shared.getIDFromName(tableName: "Medications", names: [medTakenName ?? ""], userID: userID)).first
                                }
                                else{
                                    emergMedID=nil
                                }
                                await Database.shared.updateSymptomLog(logID: existingLog ?? 0, userID: userID, date: date, onsetTime: onset, severity: severity, symptomID: sympID, medTaken: medTaken, medicationID: emergMedID, medWorked: medEffective, symptomDescription: sympDesc, notes: notes, triggerIDs: triggIDs)
                                
                                await preloadManager.preloadAll(userID: userID)
                                
                                listView = true
                            }
                        }
                    }
                    .disabled(!formValid)
                    .padding(.trailing, 40)
                    
                    // Navigation destination
                    .navigationDestination(isPresented: $listView) {
                            ListView(userID: userID)
                            .environmentObject(userSession)
                            .environmentObject(tutorialManager)
                            .environmentObject(preloadManager)
                        
                    }
                    Spacer()
                }
            }
            .padding(.bottom, 100)
        }
    }
    
    //side effect log
     var sideEffectLogView: some View {
        VStack(alignment: .leading, spacing: 16) {
            DateTextField(date: $date, textValue: $stringDate, bg: $bg, accent: $accent, width: screenWidth * 0.7,  bold: true)
            
            textFieldSection(title: "Side Effect*", text: $sideEffectName)
            
            CustomText(text: "Side Effect Severity*", color: accent, bold: true, textSize: 24)
            Slider(value: $sideEffectSev, range: 1...10, step: 1, color: accent, width: screenWidth - 50)
            
            CustomText(text: "Medication*", color: accent, bold: true, textSize: 24)
            MultipleChoice(options: $medOptions, selected: $selectedMed, accent: accent, width: screenWidth - 60, textSize: screenHeight * 0.05 / 2.2)
            
            HStack {
                Spacer()
                
                let buttonText = existingLog != nil ? "Submit" : "Save"
                
                CustomButton(text: buttonText, bg: bg, accent: accent, height: screenHeight * 0.05, width: 150, textSize: screenWidth * 0.055) {
                    if existingLog == nil {
                        Task{
                            logID = await Database.shared.createSideEffectLog(userID: userID, date: date, side_effect: sideEffectName, side_effect_severity: sideEffectSev, medicationName: selectedMed ?? "") ?? 0
                            
                            await preloadManager.preloadAll(userID: userID)

                            listView = true
                        }
                    } else {
                        Task {
                            await Database.shared.updateSideEffectLog(logID: existingLog ?? 0, userID: userID, date: date, sideEffectName: sideEffectName, sideEffectSeverity: sideEffectSev, medicationID: medID)
                            
                            await preloadManager.preloadAll(userID: userID)
                            
                            listView = true
                        }
                    }
                }
                .disabled(!formValid)
                .padding(.trailing, 40)
                .navigationDestination(isPresented: $listView) {
                    ListView(userID: userID)
                        .environmentObject(userSession)
                        .environmentObject(tutorialManager)
                        .environmentObject(preloadManager)
                }
                Spacer()
            }
        }
    }
    
    
    //text field, which is reused in both views
     func textFieldSection(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading) {
            CustomText(text: title, color: accent, bold: true, textSize: screenWidth * 0.06)
            CustomTextField(bg: bg, accent: accent, placeholder: "", text: text, width: screenWidth-50, height: min(screenHeight * 0.065, 50), textSize: screenHeight * 0.055 / 2.2, multiline: true, botPad: 0)
                .padding(.trailing, leadPadd + 20)
        }
    }
}

#Preview {
    LogView(userID: 12)
        .environmentObject(TutorialManager())
        .environmentObject(UserSession())
        .environmentObject(PreloadManager())
    
}
