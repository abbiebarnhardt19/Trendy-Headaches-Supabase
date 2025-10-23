//
//  ListFunctions.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/2/25.

import Foundation
import Supabase

extension Database {
    
    func getLogList(userID: Int64) async -> [UnifiedLog] {
        var unifiedLogs: [UnifiedLog] = []
        
        do {
            // Fetch symptom logs with all related data in ONE query
            let response = try await client
                .from("Logs")
                .select("""
                    *,
                    symptom:Symptoms!symptom_id(*),
                    medication:Medications!log_medication_id(*),
                    log_triggers:Log_Triggers!lt_log_id(
                        trigger:Triggers!lt_trigger_id(*)
                    )
                """)
                .eq("user_id", value: Int(userID))
                .execute()
            
            // Decode the response manually since it has nested data
            let json = try JSONSerialization.jsonObject(with: response.data) as! [[String: Any]]
            
            for logData in json {
                // Parse basic log data
                let logId = logData["log_id"] as! Int64
                let userId = logData["user_id"] as! Int64
                let date = logData["date"] as! String
                let onsetTime = logData["onset_time"] as? String
                let severityLevel = logData["severity_level"] as! Int64
                let symptomId = logData["symptom_id"] as! Int64
                let medTaken = logData["med_taken"] as! Bool
                let logMedicationId = logData["log_medication_id"] as? Int64
                let medWorked = logData["med_worked"] as? Bool
                let symptomDescription = logData["symptom_description"] as! String
                let notes = logData["notes"] as! String
                let submitTime = logData["submit_time"] as! String
                
                // Get symptom name from joined data
                var symptomName: String? = nil
                if let symptomDict = logData["symptom"] as? [String: Any] {
                    symptomName = symptomDict["symptom_name"] as? String
                }
                
                // Get medication name from joined data
                var medicationName: String? = nil
                if let medDict = logData["medication"] as? [String: Any] {
                    medicationName = medDict["medication_name"] as? String
                }
                
                // Get trigger names from joined data
                var triggerNames: [String] = []
                if let logTriggers = logData["log_triggers"] as? [[String: Any]] {
                    for ltDict in logTriggers {
                        if let triggerDict = ltDict["trigger"] as? [String: Any],
                           let triggerName = triggerDict["trigger_name"] as? String {
                            triggerNames.append(triggerName)
                        }
                    }
                }
                
                // Parse dates
                // Parse dates
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"

                let logDate = dateFormatter.date(from: date) ?? Date()
                let submitDate = dateFormatter.date(from: submitTime) ?? Date()
                
                let unifiedLog = UnifiedLog(
                    log_id: logId,
                    user_id: userId,
                    log_type: "Symptom",
                    date: logDate,
                    severity: severityLevel,
                    submit_time: submitDate,
                    symptom_id: symptomId,
                    symptom_name: symptomName,
                    onset_time: onsetTime,
                    med_taken: medTaken,
                    medication_id: logMedicationId,
                    medication_name: medicationName,
                    med_worked: medWorked,
                    symptom_description: symptomDescription,
                    notes: notes,
                    trigger_ids: nil,
                    trigger_names: triggerNames,
                    side_effect_med: nil
                )
                
                unifiedLogs.append(unifiedLog)
            }
            
            // Fetch side effect logs with medication in ONE query
            let sideEffectResponse = try await client
                .from("Side_Effects")
                .select("""
                    *,
                    medication:Medications!medication_id(*)
                """)
                .eq("user_id", value: Int(userID))
                .execute()
            
            let sideEffectJson = try JSONSerialization.jsonObject(with: sideEffectResponse.data) as! [[String: Any]]
            
            for seData in sideEffectJson {
                let sideEffectId = seData["side_effect_id"] as! Int64
                let userId = seData["user_id"] as! Int64
                let medicationId = seData["medication_id"] as? Int64
                let sideEffectName = seData["side_effect_name"] as! String
                let sideEffectSeverity = seData["side_effect_severity"] as! Int64
                let date = seData["date"] as! String
                let sideEffectSubmitTime = seData["side_effect_submit_time"] as! String
                
                // Get medication name from joined data
                var medicationName: String? = nil
                if let medDict = seData["medication"] as? [String: Any] {
                    medicationName = medDict["medication_name"] as? String
                }
                
                // Parse dates
                let dateFormatter = ISO8601DateFormatter()
                let sideEffectDate = dateFormatter.date(from: date) ?? Date()
                let submitDate = dateFormatter.date(from: sideEffectSubmitTime) ?? Date()
                
                let unifiedLog = UnifiedLog(
                    log_id: sideEffectId,
                    user_id: userId,
                    log_type: "Side Effect",
                    date: sideEffectDate,
                    severity: sideEffectSeverity,
                    submit_time: submitDate,
                    symptom_id: nil,
                    symptom_name: sideEffectName,
                    onset_time: nil,
                    med_taken: nil,
                    medication_id: medicationId,
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
//            unifiedLogs.sort {
//                if $0.date == $1.date {
//                    return $0.submit_time > $1.submit_time
//                }
//                return $0.date > $1.date
//            }
            
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
                    .eq("log_id", value: Int(logID))
                    .execute()
            } else {
                try await client
                    .from("Side_Effects")
                    .delete()
                    .eq("side_effect_id", value: Int(logID))
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
        let lt_log_id: Int64
        let lt_trigger_id: Int64
        
        enum CodingKeys: String, CodingKey {
            case lt_log_id = "lt_log_id"
            case lt_trigger_id = "lt_trigger_id"
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
