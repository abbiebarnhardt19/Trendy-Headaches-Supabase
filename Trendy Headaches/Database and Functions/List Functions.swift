//
//  ListFunctions.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/2/25.

import Foundation
import Supabase

extension Database {
    
    // Get all the logs for a user and sort them
    func getLogList(userID: Int64) async -> [UnifiedLog] {
        var unifiedLogs: [UnifiedLog] = []
        
        do {
            // Fetch symptom logs
            let symptomLogs: [Log] = try await client
                .from("Logs")
                .select()
                .eq("user_id", value: String(userID))
                .execute()
                .value
            
            for log in symptomLogs {
                // Fetch symptom name via ID
                var symptomName: String? = nil
                let symptoms: [Symptom] = try await client
                    .from("Symptoms")
                    .select()
                    .eq("symptom_id", value: String(log.symptomId))
                    .execute()
                    .value
                if let symptom = symptoms.first {
                    symptomName = symptom.symptomName
                }
                
                // Fetch medication name (if any)
                var medicationName: String? = nil
                if let medId = log.logMedicationId {
                    let medications: [Medication] = try await client
                        .from("Medications")
                        .select()
                        .eq("medication_id", value: String(medId))
                        .execute()
                        .value
                    if let medication = medications.first {
                        medicationName = medication.medicationName
                    }
                }
                
                // Fetch triggers
                var triggerNames: [String] = []
                let logTriggers: [LogTrigger] = try await client
                    .from("Log_Triggers")
                    .select()
                    .eq("log_id", value: String(log.logId))
                    .execute()
                    .value
                
                for logTrigger in logTriggers {
                    let triggers: [Trigger] = try await client
                        .from("Triggers")
                        .select()
                        .eq("trigger_id", value: String(logTrigger.triggerId))
                        .execute()
                        .value
                    if let trigger = triggers.first {
                        triggerNames.append(trigger.triggerName)
                    }
                }
                
                // Parse date from ISO8601 string
                let dateFormatter = ISO8601DateFormatter()
                let logDate = dateFormatter.date(from: log.date) ?? Date()
                let submitDate = dateFormatter.date(from: log.submitTime) ?? Date()
                
                // Create Symptom log
                let unifiedLog = UnifiedLog(
                    log_id: log.logId,
                    user_id: log.userId,
                    log_type: "Symptom",
                    date: logDate,
                    severity: log.severityLevel,
                    submit_time: submitDate,
                    symptom_id: log.symptomId,
                    symptom_name: symptomName,
                    onset_time: log.onsetTime,
                    med_taken: log.medTaken,
                    medication_id: log.logMedicationId,
                    medication_name: medicationName,
                    med_worked: log.medWorked,
                    symptom_description: log.symptomDescription,
                    notes: log.notes,
                    trigger_ids: nil,
                    trigger_names: triggerNames,
                    side_effect_med: nil
                )
                
                unifiedLogs.append(unifiedLog)
            }
            
            // Fetch side effect logs
            let sideEffectLogs: [SideEffect] = try await client
                .from("Side_Effects")
                .select()
                .eq("user_id", value: String(userID))
                .execute()
                .value
            
            for sideEffect in sideEffectLogs {
                // Fetch medication name
                var medicationName: String? = nil
                if let medId = sideEffect.medicationId {
                    let medications: [Medication] = try await client
                        .from("Medications")
                        .select()
                        .eq("medication_id", value: String(medId))
                        .execute()
                        .value
                    if let medication = medications.first {
                        medicationName = medication.medicationName
                    }
                }
                
                // Parse date from ISO8601 string
                let dateFormatter = ISO8601DateFormatter()
                let sideEffectDate = dateFormatter.date(from: sideEffect.date) ?? Date()
                let submitDate = dateFormatter.date(from: sideEffect.sideEffectSubmitTime) ?? Date()
                
                // Create SideEffect log
                let unifiedLog = UnifiedLog(
                    log_id: sideEffect.sideEffectId,
                    user_id: sideEffect.userId,
                    log_type: "Side Effect",
                    date: sideEffectDate,
                    severity: sideEffect.sideEffectSeverity,
                    submit_time: submitDate,
                    symptom_id: nil,
                    symptom_name: sideEffect.sideEffectName,
                    onset_time: nil,
                    med_taken: nil,
                    medication_id: nil,
                    medication_name: nil,
                    med_worked: nil,
                    symptom_description: nil,
                    notes: nil,
                    trigger_ids: nil,
                    trigger_names: nil,
                    side_effect_med: medicationName
                )
                
                unifiedLogs.append(unifiedLog)
            }
            
            // Sort logs
            unifiedLogs.sort {
                if $0.date == $1.date {
                    return $0.submit_time > $1.submit_time
                }
                return $0.date > $1.date
            }
            
        } catch {
            print("Error fetching unified logs: \(error)")
        }
        
        return unifiedLogs
    }
    
    // Function to delete log based on log id and table
    func deleteLog(logID: Int64, table: String) async {
        do {
            if table == "Symptom" {
                try await client
                    .from("Logs")
                    .delete()
                    .eq("log_id", value: String(logID))
                    .execute()
            } else {
                try await client
                    .from("Side_Effects")
                    .delete()
                    .eq("side_effect_id", value: String(logID))
                    .execute()
            }
        } catch {
            print("Failed to delete log with ID \(logID): \(error)")
        }
    }
    
    struct Log: Codable {
        let logId: Int64
        let userId: Int64
        let date: String
        let onsetTime: String?
        let severityLevel: Int64
        let symptomId: Int64
        let medTaken: Bool
        let logMedicationId: Int64?
        let medWorked: Bool?
        let symptomDescription: String
        let notes: String
        let submitTime: String
        
        enum CodingKeys: String, CodingKey {
            case logId = "log_id"
            case userId = "user_id"
            case date
            case onsetTime = "onset_time"
            case severityLevel = "severity_level"
            case symptomId = "symptom_id"
            case medTaken = "med_taken"
            case logMedicationId = "log_medication_id"
            case medWorked = "med_worked"
            case symptomDescription = "symptom_description"
            case notes
            case submitTime = "submit_time"
        }
    }

    struct LogTrigger: Codable {
        let logId: Int64
        let triggerId: Int64
        
        enum CodingKeys: String, CodingKey {
            case logId = "log_id"
            case triggerId = "trigger_id"
        }
    }

    struct SideEffect: Codable {
        let sideEffectId: Int64
        let userId: Int64
        let medicationId: Int64?
        let sideEffectName: String
        let sideEffectSeverity: Int64
        let date: String
        let sideEffectSubmitTime: String
        
        enum CodingKeys: String, CodingKey {
            case sideEffectId = "side_effect_id"
            case userId = "user_id"
            case medicationId = "medication_id"
            case sideEffectName = "side_effect_name"
            case sideEffectSeverity = "side_effect_severity"
            case date
            case sideEffectSubmitTime = "side_effect_submit_time"
        }
    }
}
