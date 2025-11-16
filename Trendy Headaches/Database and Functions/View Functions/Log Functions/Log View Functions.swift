//
//  Log View Functions.swift
//  Trendy Headaches Supabase
//
//  Created by Abigail Barnhardt on 11/15/25.
//

import Foundation

extension LogView {
    
    func setupLogView() async {

        // Colors
        bg = preloadManager.bg
        accent = preloadManager.accent

        //Log choice options
        sympOptions = preloadManager.sympOptions
        triggOptions = preloadManager.triggOptions
        medOptions = preloadManager.medOptions
        emergMedOptions = preloadManager.emergMedOptions

        // Today’s date
        stringDate = preloadManager.todayString

        // If editing an existing log, load it
        if let log = existingLog {
            await loadExistingLogHelper(log)
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
