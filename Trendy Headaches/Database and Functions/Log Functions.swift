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
            let dateFormatter = ISO8601DateFormatter()
            
            let logData = LogInsert(user_id: userID, date: dateFormatter.string(from: date), onset_time: symptom_onset, severity_level: severity, symptom_id: symptom, med_taken: med_taken, log_medication_id: med_taken_id, med_worked: nil, symptom_description: symptom_desc, notes: notes, submit_time: dateFormatter.string(from: submit))
            
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
                let side_effect_date: String
                let side_effect_submit_time: String
                let side_effect_name: String
                let side_effect_severity: Int64
                let side_effect_medication_id: Int64
            }
            
            let dateFormatter = ISO8601DateFormatter()
            
            let sideEffectData = SideEffectInsert(
                user_id: userID,
                side_effect_date: dateFormatter.string(from: date),
                side_effect_submit_time: dateFormatter.string(from: submit_time),
                side_effect_name: side_effect,
                side_effect_severity: side_effect_severity,
                side_effect_medication_id: medication_id
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
            // Create a struct for the update
            struct LogUpdate: Encodable {
                var date: String?
                var onset_time: String?
                var severity_level: Int64?
                var symptom_id: Int64?
                var med_taken: Bool?
                var log_medication_id: Int64?
                var med_worked: Bool?
                var symptom_description: String?
                var notes: String?
            }
            
            var update = LogUpdate()
            
            if let newDate = date {
                update.date = ISO8601DateFormatter().string(from: newDate)
            }
            if let newOnset = onsetTime {
                update.onset_time = newOnset
            }
            if let newSeverity = severity {
                update.severity_level = newSeverity
            }
            if let newSymptomID = symptomID {
                update.symptom_id = newSymptomID
            }
            if let newMedTaken = medTaken {
                update.med_taken = newMedTaken
            }
            if let newMedicationID = medicationID {
                update.log_medication_id = newMedicationID
            }
            if let newMedWorked = medWorked {
                update.med_worked = newMedWorked
            }
            if let newSymptomDesc = symptomDescription {
                update.symptom_description = newSymptomDesc
            }
            if let newNotes = notes {
                update.notes = newNotes
            }
            
            // Perform the update
            try await client
                .from("Logs")
                .update(update)
                .eq("log_id", value: Int(logID))  // Changed from String
                .execute()
            
            // Update triggers separately if needed
            if let newTriggerIDs = triggerIDs {
                // Remove old triggers for this log
                try await client
                    .from("Log_Triggers")
                    .delete()
                    .eq("lt_log_id", value: Int(logID))
                    .execute()
                
                // Insert new trigger links
                for tID in newTriggerIDs {
                    struct LogTriggerInsert: Encodable {
                        let lt_log_id: Int64
                        let lt_trigger_id: Int64
                    }
                    
                    let linkData = LogTriggerInsert(lt_log_id: logID, lt_trigger_id: tID)
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        do {
            let response = try await client
                .from("Logs")
                .select("""
                    *,
                    symptom:Symptoms!symptom_id(*),
                    medication:Medications!log_medication_id(*)
                """)
                .eq("log_id", value: Int(logID))
                .single()
                .execute()
            
            let json = try JSONSerialization.jsonObject(with: response.data) as! [String: Any]
            
            let uid = json["user_id"] as! Int64
            let dt = dateFormatter.date(from: json["date"] as! String) ?? Date()
            let sid = json["symptom_id"] as! Int64
            let mid = json["log_medication_id"] as? Int64
            
            let symptomDict = json["symptom"] as? [String: Any]
            let sname = symptomDict?["symptom_name"] as? String ?? ""
            
            let medDict = json["medication"] as? [String: Any]
            let mname = medDict?["medication_name"] as? String ?? ""
            
            return (uid, dt, sname, sid, mid, mname)
        } catch {
            print("Database error while fetching log details: \(error)")
            return nil
        }
    }
    
    // Get the id of an instance from its name and user
    func getIDFromName(tableName: String, names: [String], userID: Int64) async -> [Int64] {
        let nameColumn = "\(String(tableName.dropLast().lowercased()))_name"
        var ids: [Int64] = []
        
        for name in names {
            do {
                let json = try await client
                    .from(tableName)
                    .select()
                    .eq("user_id", value: Int(userID))
                    .eq(nameColumn, value: name)
                    .execute()
                
                let data = try JSONSerialization.jsonObject(with: json.data) as! [[String: Any]]
                
                if let first = data.first {
                    let idKey = "\(String(tableName.dropLast().lowercased()))_id"
                    if let id = first[idKey] as? Int64 {
                        ids.append(id)
                    }
                }
            } catch {
                print("Error querying \(tableName) for '\(name)': \(error)")
            }
        }
        return ids
    }
    
    func getUnifiedLog(by logID: Int64, logType: String) async -> UnifiedLog? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        do {
            if logType == "Symptom" {
                let response = try await client
                    .from("Logs")
                    .select("""
                        *,
                        symptom:Symptoms!symptom_id(*),
                        medication:Medications!log_medication_id(*),
                        log_triggers:Log_Triggers!lt_log_id(trigger:Triggers!lt_trigger_id(*))
                    """)
                    .eq("log_id", value: Int(logID))
                    .single()
                    .execute()
                
                let json = try JSONSerialization.jsonObject(with: response.data) as! [String: Any]
                
                let symptomDict = json["symptom"] as? [String: Any]
                let medDict = json["medication"] as? [String: Any]
                let logTriggers = json["log_triggers"] as? [[String: Any]] ?? []
                
                let triggerIDs = logTriggers.compactMap {
                    ($0["trigger"] as? [String: Any])?["trigger_id"] as? Int64
                }
                let triggerNames = logTriggers.compactMap {
                    ($0["trigger"] as? [String: Any])?["trigger_name"] as? String
                }
                
                let id = json["log_id"] as! Int64
                let uid = json["user_id"] as! Int64
                let dt = dateFormatter.date(from: json["date"] as! String) ?? Date()
                let sev = json["severity_level"] as! Int64
                let sub = dateFormatter.date(from: json["submit_time"] as! String) ?? Date()
                let sid = json["symptom_id"] as? Int64
                let sname = symptomDict?["symptom_name"] as? String
                let onset = json["onset_time"] as? String
                let taken = json["med_taken"] as? Bool
                let mid = json["log_medication_id"] as? Int64
                let mname = medDict?["medication_name"] as? String
                let worked = json["med_worked"] as? Bool
                let desc = json["symptom_description"] as? String
                let note = json["notes"] as? String
                let tids = triggerIDs.isEmpty ? nil : triggerIDs
                let tnames = triggerNames.isEmpty ? nil : triggerNames

                return UnifiedLog( log_id: id, user_id: uid, log_type: "Symptom", date: dt, severity: sev,  submit_time: sub, symptom_id: sid, symptom_name: sname, onset_time: onset, med_taken: taken, medication_id: mid, medication_name: mname, med_worked: worked, symptom_description: desc, notes: note, trigger_ids: tids, trigger_names: tnames, side_effect_med: nil)
            } else {
                let response = try await client
                    .from("Side_Effects")
                    .select("*, medication:Medications!medication_id(*)")
                    .eq("side_effect_id", value: Int(logID))
                    .single()
                    .execute()
                
                let json = try JSONSerialization.jsonObject(with: response.data) as! [String: Any]
                let medDict = json["side_effect_medication"] as? [String: Any]
                let id = json["side_effect_id"] as! Int64
                let uid = json["user_id"] as! Int64
                let dt = dateFormatter.date(from: json["side_effect_date"] as! String) ?? Date()
                let sev = json["side_effect_severity"] as! Int64
                let sub = dateFormatter.date(from: json["side_effect_submit_time"] as! String) ?? Date()
                let mid = json["medication_id"] as? Int64
                let mname = medDict?["medication_name"] as? String
                let sename = json["side_effect_name"] as? String

                return UnifiedLog(log_id: id, user_id: uid, log_type: "SideEffect", date: dt, severity: sev, submit_time: sub, symptom_id: nil, symptom_name: nil, onset_time: nil, med_taken: nil, medication_id: mid, medication_name: mname, med_worked: nil, symptom_description: nil, notes: nil, trigger_ids: nil, trigger_names: nil, side_effect_med: sename)
            }
        } catch {
            print("Error fetching \(logType) log \(logID): \(error)")
            return nil
        }
    }
}
