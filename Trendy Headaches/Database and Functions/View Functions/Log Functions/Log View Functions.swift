//
//  Log View Functions.swift
//  Trendy Headaches Supabase
//
//  Created by Abigail Barnhardt on 11/15/25.
//

import Foundation

extension LogView {
    
    func LogSetupHelper() async {
        do {
            // Load colors first
            let colors = await Database.shared.getColors(userID: userID)
            bg = colors.0
            accent = colors.1
            //hasLoaded = true

            // Fetch lists
            async let sympTask = Database.shared.getListVals(userId: userID, table: "Symptoms", col: "symptom_name")
            async let triggTask = Database.shared.getListVals(userId: userID, table: "Triggers", col: "trigger_name")
            async let medTask = Database.shared.getListVals(userId: userID, table: "Medications", col: "medication_name")
            async let emergTask = Database.shared.getListVals(userId: userID, table: "Medications", col: "medication_name", filterVal: "emergency")

            sympOptions = try await sympTask
            triggOptions = Database.deleteDups(list: try await triggTask)
            medOptions = try await medTask
            emergMedOptions = try await emergTask

            stringDate = formatter.string(from: Date())

            if let log = existingLog {
                await loadExistingLogHelper(log)
            }
        } catch {
            print("Error loading data:", error)
        }
    }

    func loadExistingLogHelper(_ existingLog: Int64) async {
        guard let log = await Database.shared.getUnifiedLog(by: existingLog, logType: existingTable ?? "") else { return }

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
            stringDate = formatter.string(from: log.date)
            sideEffectName = log.side_effect_med ?? ""
            sideEffectSev = log.severity
            selectedMed = log.medication_name ?? ""
            medID = log.medication_id ?? 0
            showSymptomView = false
        }
    }
}
