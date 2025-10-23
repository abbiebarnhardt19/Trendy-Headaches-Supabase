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
    @Binding var bg: String
    @Binding var accent: String
    
    // Layout
    private let leadPadd: CGFloat = 40
    @State private var screenWidth: CGFloat = UIScreen.main.bounds.width
    
    // Shared State
    @State private var showSymptomView = true
    @State private var logID: Int64 = 0
    @State private var showPopup: Bool = false
    @State private var date: Date = Date()
    
    //  Symptom Log variables
    @State private var stringDate: String = ""
    @State private var onset: String?
    @State private var onsetOptions: [String] = ["From Wake", "Morning", "Afternoon", "Evening"]
    @State private var symp: String?
    @State private var sympOptions: [String] = []
    @State private var severity: Int64 = 1
    @State private var medTaken: Bool = false
    @State private var emergMedOptions: [String] = []
    @State private var medTakenName: String?
    @State private var sympDesc: String = ""
    @State private var notes: String = ""
    @State private var triggOptions: [String] = []
    @State private var selectedTriggs: [String] = []
    @State private var sympID: Int64 = 0
    @State private var triggIDs: [Int64] = []
    @State private var emergMedID: Int64? = nil
    
    //  Side Effect Log variables
    @State private var sideEffectDate: String = ""
    @State private var sideEffectName: String = ""
    @State private var sideEffectSev: Int64 = 0
    @State private var medOptions: [String] = []
    @State private var selectedMed: String?
    @State private var medID: Int64 = 0
    
    //for med popup
    @State private var medWorked: Bool? = nil
    @State private var oldLogIDs: [Int64] = [0]
    
    //for log editing
    @State private var medEffective: Bool = false
    
    @State private var listView = false
    
    // Date Formatter
    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()
    
    private var formValid: Bool {
        if showSymptomView{
            // Base condition for symptom log
            var isValid = symp != nil && severity > 0
            
            // Extra check: if medTaken is true, require medTakenName
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
                
                LogBGComps(bg: bg, accent: accent)
                
                
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
                
                VStack { Spacer(); NavBarView(userID: userID, bg: $bg, accent: $accent, selected: .constant(0)) }
                    .zIndex(1)
                    .ignoresSafeArea(edges: .bottom)
            }
        }
        .task {
            await setupData()
            let results = await Database.shared.emergencyMedPopup(userID: userID)
            if !results.isEmpty {
                oldLogIDs = results
                showPopup = true
            }
        }
    }
    
    //  Subviews
    
    //header and toggle
    private var headerSection: some View {
        HStack {
            CustomText(text: showSymptomView ? "Symptom Log" : "Side Effect Log", color: accent, textAlign: .center,  textSize: 43)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.trailing, 10)
            
            CustomToggle(color: accent, feature: $showSymptomView)
                .padding(.trailing, leadPadd)
                .padding(.top, 7)
        }
    }
    
    //symptom log view
    private var symptomLogView: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 16) {
                dateField(label: "Date:", date: $date, text: $stringDate)
                
                CustomText(text: "Symptom*", color: accent, bold: true, textSize: 24)
                MultipleChoice(options: $sympOptions, selected: $symp, accent: accent, width: screenWidth - 140 )
                
                CustomText(text: "Symptom Severity*", color: accent, bold: true, textSize: 24)
                Slider(value: $severity, range: 1...10, step: 1, color: accent, width: screenWidth - 50)
                
                CustomText(text: "Symptom Onset", color: accent, bold: true, textSize: 24)
                MultipleChoice(options: $onsetOptions, selected: $onset, accent: accent, width: screenWidth - 140 )
                
                
                SingleCheckbox(text: "Emergency Med Taken?", color: accent, isOn: $medTaken)
                
                if medTaken{
                    CustomText(text: "Emergency Med Name*", color: accent, bold: true, textSize: 24)
                    MultipleChoice(options: $emergMedOptions, selected: $medTakenName, accent: accent, width: screenWidth - 140 )
                        
                    
                    if existingLog != nil{
                        SingleCheckbox(text: "Emergency Med Effective?", color: accent, isOn: $medEffective )
                    }
                }
                
                CustomText(text: "Triggers Present", color: accent, bold: true, textSize: 24)
                
                MultipleCheckboxWrapped(options: $triggOptions, selected: $selectedTriggs, accent: bg,  bg: accent, width: screenWidth-140, textSize: 20)
                    .padding(.leading, 5)
                
                textFieldSection(title: "Symptom Description", text: $sympDesc)
                textFieldSection(title: "Notes", text: $notes)
                
                // Inside your symptom log view
                HStack{
                    Spacer()
                    
                    let buttonText = existingLog != nil ? "Submit" : "Save"

                    CustomButton(text: buttonText, bg: bg, accent: accent, height: 50, width: 150) {
                        if existingLog == nil{
                            submitSymptomLog()
                        }
                        else{
                            Task {
                                if medTakenName != nil && medTakenName != ""{
                                    emergMedID = (await Database.shared.getIDFromName(tableName: "Medications", names: [medTakenName ?? ""], userID: userID)).first
                                }
                                else{
                                    emergMedID=nil
                                }
                                print("stringDate: \(stringDate)")
                                print("date: \(date)")
                                await Database.shared.updateSymptomLog(logID: existingLog ?? 0, userID: userID, date: date, onsetTime: onset, severity: severity, symptomID: sympID, medTaken: medTaken, medicationID: emergMedID, medWorked: medEffective, symptomDescription: sympDesc, notes: notes, triggerIDs: triggIDs)
                                
                                listView = true
                            }
                        }
                    }
                    .disabled(!formValid)
                    .padding(.trailing, 40)
                    // Navigation destination
                    .navigationDestination(isPresented: $listView) {
                        ListView(userID: userID, bg: $bg, accent: $accent)
                    }
                    Spacer()
                }
            }
            
            .padding(.bottom, 100)
        }
    }
    

    
    //side effect log
    private var sideEffectLogView: some View {
        VStack(alignment: .leading, spacing: 16) {
            dateField(label: "Date:", date: $date, text: $sideEffectDate)
            
            textFieldSection(title: "Side Effect*", text: $sideEffectName)
            
            CustomText(text: "Side Effect Severity*", color: accent, bold: true, textSize: 24)
            Slider(value: $sideEffectSev, range: 1...10, step: 1, color: accent, width: screenWidth - 50)
            
            CustomText(text: "Medication*", color: accent, bold: true, textSize: 24)
            MultipleChoice(options: $medOptions, selected: $selectedMed, accent: accent, width: screenWidth - 140 )
            
            HStack{
                Spacer()
                
                let buttonText = existingLog != nil ? "Submit" : "Save"

                CustomButton(text: buttonText, bg: bg, accent: accent, height: 50, width: 150) {
                    if existingLog == nil{
                        submitSideEffectLog()
                    }
                    else{
                        Task {
                            await Database.shared.updateSideEffectLog(logID: existingLog ?? 0, userID: userID, date: date, sideEffectName: sideEffectName, sideEffectSeverity: sideEffectSev, medicationID: medID)
                            listView = true
                        }
                    }// call your function first
                    listView = true  // then trigger navigation
                }
                .disabled(!formValid)
                .padding(.trailing, 40)
                // Navigation destination
                .navigationDestination(isPresented: $listView) {
                    ListView(userID: userID, bg: $bg, accent: $accent)
                }
                Spacer()
            }
        }
    }
    
    // Components
    
    //date field, which is reused for both views
    private func dateField(label: String, date: Binding<Date>, text: Binding<String>) -> some View {
        HStack {
            DateTextField(date: date, textValue: text, bg: $bg, accent: $accent, label: label)
        }
    }
    
    //text field, which is reused in both views
    private func textFieldSection(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading) {
            CustomText(text: title, color: accent, bold: true, textSize: 24)
            CustomTextField(bg: bg, accent: accent, placeholder: "", text: text, width: screenWidth - 50, height: 45, textSize: 20, multiline: true)
                .padding(.trailing, leadPadd + 20)
        }
    }
    
    //Functions
    
    //get profile data to fill mutliple choice options
    private func setupData() async {
        //get the current date
        stringDate = formatter.string(from: Date())
        sideEffectDate = formatter.string(from: Date())
        
        //get data from database
        sympOptions = (try? await Database.shared.getListVals(userId: userID, table: "Symptoms", col: "symptom_name")) ?? []
        triggOptions = Database.deleteDups(list: (try? await Database.shared.getListVals(userId: userID, table: "Triggers", col: "trigger_name")) ?? [])
        medOptions = (try? await Database.shared.getListVals(userId: userID, table: "Medications", col: "medication_name")) ?? []

        emergMedOptions = (try? await Database.shared.getListVals(userId: userID, table: "Medications", col: "medication_name", filterCol: "medication_category", filterVal: "emergency")) ?? []
        
        if let existingLog = existingLog {
            if let log = await Database.shared.getUnifiedLog(by: existingLog, logType: existingTable ?? "") {
                
                if log.log_type == "Symptom" {
                    severity = log.severity
                    sympDesc = log.symptom_description ?? ""
                    notes = log.notes ?? ""
                    onset = log.onset_time ?? ""
                    medTaken = log.med_taken ?? false
                    date = log.date
                    stringDate = formatter.string(from: date)
                    symp = log.symptom_name
                    sympID = log.symptom_id ?? 0
                    medTakenName = log.medication_name ?? ""
                    emergMedID = log.medication_id ?? 0
                    selectedTriggs = log.trigger_names ?? []
                    triggIDs = log.trigger_ids ?? []
                    medEffective = log.med_worked ?? false
                    showSymptomView = true

                } else if log.log_type == "SideEffect" {
                    sideEffectDate = formatter.string(from: log.date)
                    sideEffectName = log.side_effect_med ?? ""
                    sideEffectSev = log.severity
                    selectedMed = log.medication_name ?? ""
                    medID = log.medication_id ?? 0

                    showSymptomView = false
                }

            } else {
                notes = "test"
            }
        }

    }
    
    //function to add the log to the database
    private func submitSymptomLog(){
        Task {
            
            //get the symptoms and triggers from the names
            sympID = (await Database.shared.getIDFromName(tableName: "Symptoms", names: [symp ?? ""], userID: userID)).first ?? 0
            
            triggIDs = await Database.shared.getIDFromName(tableName: "Triggers", names: selectedTriggs, userID: userID)
            
            if medTakenName != ""{
                emergMedID = (await Database.shared.getIDFromName(tableName: "Medications", names: [medTakenName ?? ""], userID: userID)).first
            }
            
            //convert the date from string format
            let enteredDate = formatter.date(from: stringDate) ?? Date()
            
            //add log to database
            logID = await Database.shared.createLog(userID: userID,  date: date, symptom_onset: onset ?? "", symptom: sympID, severity: severity, med_taken: medTaken, med_taken_id: emergMedID, symptom_desc: sympDesc, notes: notes, submit: Date(), triggerIDs: triggIDs) ?? 0
            
            listView = true
        }
    }
    
    //function to add the side effect to the database
    private func submitSideEffectLog() {
        Task {
            //get the medication ID from the name
            medID = (await Database.shared.getIDFromName(tableName: "Medications", names: [selectedMed ?? ""], userID: userID)).first ?? 0
           
            //convert the date from a string
            let enteredDate = formatter.date(from: sideEffectDate) ?? Date()
            
            //add it to the database
            logID = await Database.shared.createSideEffectLog(userID: userID, date: enteredDate, submit_time: Date(), side_effect: sideEffectName, side_effect_severity: sideEffectSev, medication_id: medID) ?? 0
            
            listView = true
        }
    }
}

#Preview {
    LogView(userID: 9, bg: .constant("#001d00"), accent: .constant("#b5c4b9"))
}
