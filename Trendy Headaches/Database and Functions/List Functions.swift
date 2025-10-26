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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        do {
            // Fetch symptom logs
            let response = try await client
                .from("Logs")
                .select("""
                    *,
                    symptom:Symptoms!symptom_id(*),
                    medication:Medications!log_medication_id(*),
                    log_triggers:Log_Triggers!lt_log_id(trigger:Triggers!lt_trigger_id(*))
                """)
                .eq("user_id", value: Int(userID))
                .execute()
            
            let json = try JSONSerialization.jsonObject(with: response.data) as! [[String: Any]]
            
            for logData in json {
                let symptomDict = logData["symptom"] as? [String: Any]
                let medDict = logData["medication"] as? [String: Any]
                let logTriggers = logData["log_triggers"] as? [[String: Any]] ?? []
                
                let triggerNames = logTriggers.compactMap {
                    ($0["trigger"] as? [String: Any])?["trigger_name"] as? String
                }
                
                unifiedLogs.append(UnifiedLog( log_id: logData["log_id"] as! Int64, user_id: logData["user_id"] as! Int64, log_type: "Symptom", date: dateFormatter.date(from: logData["date"] as! String) ?? Date(), severity: logData["severity_level"] as! Int64, submit_time: dateFormatter.date(from: logData["submit_time"] as! String) ?? Date(), symptom_id: logData["symptom_id"] as? Int64, symptom_name: symptomDict?["symptom_name"] as? String, onset_time: logData["onset_time"] as? String, med_taken: logData["med_taken"] as? Bool, medication_id: logData["log_medication_id"] as? Int64, medication_name: medDict?["medication_name"] as? String, med_worked: logData["med_worked"] as? Bool, symptom_description: logData["symptom_description"] as? String, notes: logData["notes"] as? String, trigger_ids: nil, trigger_names: triggerNames.isEmpty ? nil : triggerNames, side_effect_med: nil ))
            }
            
            // Fetch side effect logs
            let seResponse = try await client
                .from("Side_Effects")
                .select("*, medication:Medications!medication_id(*)")
                .eq("user_id", value: Int(userID))
                .execute()
            
            let seJson = try JSONSerialization.jsonObject(with: seResponse.data) as! [[String: Any]]
            
            for seData in seJson {
                let medDict = seData["medication"] as? [String: Any]
                
                unifiedLogs.append(UnifiedLog(log_id: seData["side_effect_id"] as! Int64, user_id: seData["user_id"] as! Int64, log_type: "Side Effect", date: dateFormatter.date(from: seData["side_effect_date"] as! String) ?? Date(), severity: seData["side_effect_severity"] as! Int64, submit_time: dateFormatter.date(from: seData["side_effect_submit_time"] as! String) ?? Date(), symptom_id: nil, symptom_name: seData["side_effect_name"] as? String, onset_time: nil, med_taken: nil, medication_id: seData["side_effect_medication_id"] as? Int64, medication_name: nil, med_worked: nil, symptom_description: nil, notes: nil, trigger_ids: nil,  trigger_names: nil, side_effect_med: medDict?["medication_name"] as? String))
            }
        } catch {
            print("Error fetching unified logs: \(error)")
        }
        return unifiedLogs.sorted { $0.date > $1.date }
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
}
