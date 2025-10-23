//
//  LogFunctions.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/2/25.

import Foundation
import Supabase
import CryptoKit

extension Database {
    
    // Create log function
    func createLog(userID: Int64, date: Date, symptom_onset: String?, symptom: Int64, severity: Int64, med_taken: Bool, med_taken_id: Int64?, symptom_desc: String, notes: String, submit: Date, triggerIDs: [Int64] = []) async -> Int64? {
        
        do {
            struct LogInsert: Encodable {
                let user_id: Int64
                let date: String
                let onset_time: String?
                let severity_level: Int64
                let symptom_id: Int64
                let med_taken: Bool
                let log_medication_id: Int64?
                let med_worked: Bool?
                let symptom_description: String
                let notes: String
                let submit_time: String
            }
            
            let dateFormatter = ISO8601DateFormatter()
            
            let logData = LogInsert(
                user_id: userID,
                date: dateFormatter.string(from: date),
                onset_time: symptom_onset,
                severity_level: severity,
                symptom_id: symptom,
                med_taken: med_taken,
                log_medication_id: med_taken_id,
                med_worked: nil,
                symptom_description: symptom_desc,
                notes: notes,
                submit_time: dateFormatter.string(from: submit)
            )
            
            let insertedLog: Log = try await client
                .from("Logs")
                .insert(logData)
                .select()
                .single()
                .execute()
                .value
            
            let logID = insertedLog.logId
            
            // Associate triggers in junction table
            for trigID in triggerIDs {
                struct LogTriggerInsert: Encodable {
                    let lt_log_id: Int64  // Changed from log_id
                    let lt_trigger_id: Int64  // Changed from trigger_id
                }
                
                let linkData = LogTriggerInsert(lt_log_id: logID, lt_trigger_id: trigID)
                try await client.from("Log_Triggers").insert(linkData).execute()
            }
            
            return logID
        } catch {
            print("Failed to create log: \(error)")
            return nil
        }
    }
    
    // Create a side effect log
    func createSideEffectLog(userID: Int64, date: Date, submit_time: Date, side_effect: String, side_effect_severity: Int64, medication_id: Int64) async -> Int64? {
        do {
            struct SideEffectInsert: Encodable {
                let user_id: Int64
                let date: String
                let side_effect_submit_time: String
                let side_effect_name: String
                let side_effect_severity: Int64
                let medication_id: Int64
            }
            
            let dateFormatter = ISO8601DateFormatter()
            
            let sideEffectData = SideEffectInsert(
                user_id: userID,
                date: dateFormatter.string(from: date),
                side_effect_submit_time: dateFormatter.string(from: submit_time),
                side_effect_name: side_effect,
                side_effect_severity: side_effect_severity,
                medication_id: medication_id
            )
            
            let insertedSideEffect: SideEffect = try await client
                .from("Side_Effects")
                .insert(sideEffectData)
                .select()
                .single()
                .execute()
                .value
            
            return insertedSideEffect.sideEffectId
        } catch {
            print("Failed to create side effect log: \(error)")
            return nil
        }
    }
    
    // Function to get logs that need a med followup
    func emergencyMedPopup(userID: Int64) async -> [Int64] {
        var results: [Int64] = []
        
        do {
            let logs: [Log] = try await client
                .from("Logs")
                .select()
                .eq("user_id", value: String(userID))
                .eq("med_taken", value: "true")
                .is("med_worked", value: nil)
                .execute()
                .value
            
            for log in logs {
                results.append(log.logId)
            }
        } catch {
            print("Database error: \(error)")
        }
        
        return results
    }
    
    // Function to update the log with effectiveness
    func updateMedEffective(logID: Int64, medEffectiveValue: Bool) async {
        do {
            struct MedWorkedUpdate: Encodable {
                let med_worked: Bool
            }
            
            let updateData = MedWorkedUpdate(med_worked: medEffectiveValue)
            
            try await client
                .from("Logs")
                .update(updateData)
                .eq("log_id", value: String(logID))
                .execute()
        } catch {
            print("Failed to update log \(logID): \(error)")
        }
    }
    
    // Function to update the rest of the log
    func updateSymptomLog(logID: Int64, userID: Int64, date: Date?, onsetTime: String?, severity: Int64?, symptomID: Int64?, medTaken: Bool?, medicationID: Int64?, medWorked: Bool?, symptomDescription: String?, notes: String?, triggerIDs: [Int64]?) async {
        do {
            // Build update data dynamically
            var updateDict: [String: Any] = [:]
            
            if let newDate = date {
                updateDict["date"] = ISO8601DateFormatter().string(from: newDate)
            }
            if let newOnset = onsetTime {
                updateDict["onset_time"] = newOnset
            }
            if let newSeverity = severity {
                updateDict["severity_level"] = newSeverity
            }
            if let newSymptomID = symptomID {
                updateDict["symptom_id"] = newSymptomID
            }
            if let newMedTaken = medTaken {
                updateDict["med_taken"] = newMedTaken
            }
            if let newMedicationID = medicationID {
                updateDict["log_medication_id"] = newMedicationID
            }
            if let newMedWorked = medWorked {
                updateDict["med_worked"] = newMedWorked
            }
            if let newSymptomDesc = symptomDescription {
                updateDict["symptom_description"] = newSymptomDesc
            }
            if let newNotes = notes {
                updateDict["notes"] = newNotes
            }
            
            // Perform update only if there's something to update
            if !updateDict.isEmpty {
                let jsonData = try JSONSerialization.data(withJSONObject: updateDict)
                let jsonString = String(data: jsonData, encoding: .utf8)!
                
                try await client
                    .from("Logs")
                    .update(jsonString)
                    .eq("log_id", value: String(logID))
                    .execute()
            }
            
            // Update triggers separately if needed
            if let newTriggerIDs = triggerIDs {
                // Remove old triggers for this log
                try await client
                    .from("Log_Triggers")
                    .delete()
                    .eq("log_id", value: String(logID))
                    .execute()
                
                // Insert new trigger links
                for tID in newTriggerIDs {
                    struct LogTriggerInsert: Encodable {
                        let log_id: Int64
                        let trigger_id: Int64
                    }
                    
                    let linkData = LogTriggerInsert(log_id: logID, trigger_id: tID)
                    try await client.from("Log_Triggers").insert(linkData).execute()
                }
            }
        } catch {
            print("Error updating symptom log: \(error)")
        }
    }
    
    // Update a side effects log
    func updateSideEffectLog(logID: Int64, userID: Int64, date: Date?, sideEffectName: String?, sideEffectSeverity: Int64?, medicationID: Int64?) async {
        do {
            var updateDict: [String: Any] = [:]
            
            if let newDate = date {
                updateDict["date"] = ISO8601DateFormatter().string(from: newDate)
            }
            if let newName = sideEffectName {
                updateDict["side_effect_name"] = newName
            }
            if let newSeverity = sideEffectSeverity {
                updateDict["side_effect_severity"] = newSeverity
            }
            if let newMedicationID = medicationID {
                updateDict["medication_id"] = newMedicationID
            }
            
            // Perform update only if there's something to update
            if !updateDict.isEmpty {
                let jsonData = try JSONSerialization.data(withJSONObject: updateDict)
                let jsonString = String(data: jsonData, encoding: .utf8)!
                
                try await client
                    .from("Side_Effects")
                    .update(jsonString)
                    .eq("side_effect_id", value: String(logID))
                    .execute()
            }
        } catch {
            print("Error updating side effect log: \(error)")
        }
    }
    
    // Get the details of the log for the popup
    func getLogDetails(logID: Int64) async -> (userID: Int64, date: Date, symptomName: String, symptomID: Int64, emergencyMedID: Int64?, emergencyMedName: String)? {
        do {
            // Get the log
            let logs: [Log] = try await client
                .from("Logs")
                .select()
                .eq("log_id", value: String(logID))
                .execute()
                .value
            
            guard let log = logs.first else { return nil }
            
            let userID = log.userId
            let dateFormatter = ISO8601DateFormatter()
            let date = dateFormatter.date(from: log.date) ?? Date()
            let symptomID = log.symptomId
            let emergencyMedID = log.logMedicationId
            
            // Get symptom name
            var symptomName = ""
            let symptoms: [Symptom] = try await client
                .from("Symptoms")
                .select()
                .eq("symptom_id", value: String(symptomID))
                .execute()
                .value
            if let symptom = symptoms.first {
                symptomName = symptom.symptomName
            }
            
            // Get medication name
            var emergencyMedName = ""
            if let medID = emergencyMedID {
                let medications: [Medication] = try await client
                    .from("Medications")
                    .select()
                    .eq("medication_id", value: String(medID))
                    .execute()
                    .value
                if let medication = medications.first {
                    emergencyMedName = medication.medicationName
                }
            }
            
            return (userID, date, symptomName, symptomID, emergencyMedID, emergencyMedName)
        } catch {
            print("Database error while fetching log details: \(error)")
        }
        return nil
    }
    
    // Get the id of an instance from its name and user
    func getIDFromName(tableName: String, names: [String], userID: Int64) async -> [Int64] {
        let singular = String(tableName.dropLast().lowercased())
        _ = "\(singular)_id"
        let nameColumn = "\(singular)_name"
        
        var ids: [Int64] = []
        
        for name in names {
            do {
                let result = try await client
                    .from(tableName)
                    .select()
                    .eq("user_id", value: String(userID))
                    .eq(nameColumn, value: name)
                    .execute()
                
                // Parse response based on table name
                switch tableName {
                case "Symptoms":
                    let symptoms: [Symptom] = try JSONDecoder().decode([Symptom].self, from: result.data)
                    if let symptom = symptoms.first {
                        ids.append(symptom.symptomId)
                    }
                case "Medications":
                    let medications: [Medication] = try JSONDecoder().decode([Medication].self, from: result.data)
                    if let medication = medications.first {
                        ids.append(medication.medicationId)
                    }
                case "Triggers":
                    let triggers: [Trigger] = try JSONDecoder().decode([Trigger].self, from: result.data)
                    if let trigger = triggers.first {
                        ids.append(trigger.triggerId)
                    }
                default:
                    print("Unknown table: \(tableName)")
                }
            } catch {
                print("Error querying \(tableName) for '\(name)': \(error)")
            }
        }
        
        return ids
    }
    
    // Function to load in log for editing
    func getUnifiedLog(by logID: Int64, logType: String) async -> UnifiedLog? {
        do {
            if logType == "Symptom" {
                let logs: [Log] = try await client
                    .from("Logs")
                    .select()
                    .eq("log_id", value: String(logID))
                    .execute()
                    .value
                
                guard let log = logs.first else { return nil }
                
                let dateFormatter = ISO8601DateFormatter()
                let logDate = dateFormatter.date(from: log.date) ?? Date()
                let submitDate = dateFormatter.date(from: log.submitTime) ?? Date()
                
                // Get symptom name
                let symptomID = log.symptomId
                var symptomName: String? = nil
                let symptoms: [Symptom] = try await client
                    .from("Symptoms")
                    .select()
                    .eq("symptom_id", value: String(symptomID))
                    .execute()
                    .value
                if let symptom = symptoms.first {
                    symptomName = symptom.symptomName
                }
                
                // Get medication info
                var medicationID: Int64? = nil
                var medicationName: String? = nil
                if let mID = log.logMedicationId {
                    medicationID = mID
                    let medications: [Medication] = try await client
                        .from("Medications")
                        .select()
                        .eq("medication_id", value: String(mID))
                        .execute()
                        .value
                    if let medication = medications.first {
                        medicationName = medication.medicationName
                    }
                }
                
                // Get triggers
                var triggerIDs: [Int64] = []
                var triggerNames: [String] = []
                let logTriggers: [LogTrigger] = try await client
                    .from("Log_Triggers")
                    .select()
                    .eq("lt_log_id", value: String(logID))
                    .execute()
                    .value
                
                for logTrigger in logTriggers {
                    let tID = logTrigger.lt_trigger_id
                    triggerIDs.append(tID)
                    let triggers: [Trigger] = try await client
                        .from("Triggers")
                        .select()
                        .eq("lt_trigger_id", value: String(tID))
                        .execute()
                        .value
                    if let trigger = triggers.first {
                        triggerNames.append(trigger.triggerName)
                    }
                }
                
                return UnifiedLog(
                    log_id: log.logId,
                    user_id: log.userId,
                    log_type: "Symptom",
                    date: logDate,
                    severity: log.severityLevel,
                    submit_time: submitDate,
                    symptom_id: symptomID,
                    symptom_name: symptomName,
                    onset_time: log.onsetTime,
                    med_taken: log.medTaken,
                    medication_id: medicationID,
                    medication_name: medicationName,
                    med_worked: log.medWorked,
                    symptom_description: log.symptomDescription,
                    notes: log.notes,
                    trigger_ids: triggerIDs,
                    trigger_names: triggerNames,
                    side_effect_med: nil
                )
            } else {
                let sideEffects: [SideEffect] = try await client
                    .from("Side_Effects")
                    .select()
                    .eq("side_effect_id", value: String(logID))
                    .execute()
                    .value
                
                guard let sideEffect = sideEffects.first else { return nil }
                
                let dateFormatter = ISO8601DateFormatter()
                let sideEffectDate = dateFormatter.date(from: sideEffect.date) ?? Date()
                let submitDate = dateFormatter.date(from: sideEffect.sideEffectSubmitTime) ?? Date()
                
                let medicationID = sideEffect.medicationId
                var medicationName: String? = nil
                
                if let medID = medicationID {
                    let medications: [Medication] = try await client
                        .from("Medications")
                        .select()
                        .eq("medication_id", value: String(medID))
                        .execute()
                        .value
                    if let medication = medications.first {
                        medicationName = medication.medicationName
                    }
                }
                
                return UnifiedLog(
                    log_id: sideEffect.sideEffectId,
                    user_id: sideEffect.userId,
                    log_type: "SideEffect",
                    date: sideEffectDate,
                    severity: sideEffect.sideEffectSeverity,
                    submit_time: submitDate,
                    symptom_id: nil,
                    symptom_name: nil,
                    onset_time: nil,
                    med_taken: nil,
                    medication_id: medicationID,
                    medication_name: medicationName,
                    med_worked: nil,
                    symptom_description: nil,
                    notes: nil,
                    trigger_ids: nil,
                    trigger_names: nil,
                    side_effect_med: sideEffect.sideEffectName
                )
            }
        } catch {
            print("Error fetching \(logType) log \(logID): \(error)")
        }
        return nil
    }
}
