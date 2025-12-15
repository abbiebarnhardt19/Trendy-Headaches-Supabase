//
//  ListFunctions.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/2/25.

import Foundation
import Supabase

extension Database {
    
//    func getLogList(userID: Int64) async throws -> [UnifiedLog] {
//        var unifiedLogs: [UnifiedLog] = []
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        
//        do {
//            // Fetch symptom logs
//            let response = try await client
//                .from("Logs")
//                .select("""
//                    *,
//                    symptom:Symptoms!symptom_id(*),
//                    medication:Medications!log_medication_id(*),
//                    log_triggers:Log_Triggers!lt_log_id(trigger:Triggers!lt_trigger_id(*))
//                """)
//                .eq("user_id", value: Int(userID))
//                .execute()
//            
//            let json = try JSONSerialization.jsonObject(with: response.data) as! [[String: Any]]
//            
//            for logData in json {
//                let symptomDict = logData["symptom"] as? [String: Any]
//                let medDict = logData["medication"] as? [String: Any]
//                let logTriggers = logData["log_triggers"] as? [[String: Any]] ?? []
//                
//                let triggerNames = logTriggers.compactMap {
//                    ($0["trigger"] as? [String: Any])?["trigger_name"] as? String
//                }
//                
//                
//                let newLog = UnifiedLog( log_id: logData["log_id"] as! Int64, user_id: logData["user_id"] as! Int64, log_type: "Symptom", date: dateFormatter.date(from: logData["date"] as! String) ?? Date(), severity: logData["severity_level"] as! Int64, submit_time: dateFormatter.date(from: logData["submit_time"] as! String) ?? Date(), symptom_id: logData["symptom_id"] as? Int64, symptom_name: symptomDict?["symptom_name"] as? String, onset_time: logData["onset_time"] as? String, med_taken: logData["med_taken"] as? Bool, medication_id: logData["log_medication_id"] as? Int64, medication_name: medDict?["medication_name"] as? String, med_worked: logData["med_worked"] as? Bool, symptom_description: logData["symptom_description"] as? String, notes: logData["notes"] as? String, trigger_ids: nil, trigger_names: triggerNames.isEmpty ? nil : triggerNames, side_effect_med: nil )
//                
//                unifiedLogs.append(newLog)
//            }
//            
//            // Fetch side effect logs
//            let seResponse = try await client
//                .from("Side_Effects")
//                .select("*, medication:Medications!medication_id(*)")
//                .eq("user_id", value: Int(userID))
//                .execute()
//            
//            let seJson = try JSONSerialization.jsonObject(with: seResponse.data) as! [[String: Any]]
//            
//            for seData in seJson {
//                let medDict = seData["medication"] as? [String: Any]
//                
//                unifiedLogs.append(UnifiedLog(log_id: seData["side_effect_id"] as! Int64, user_id: seData["user_id"] as! Int64, log_type: "Side Effect", date: dateFormatter.date(from: seData["side_effect_date"] as! String) ?? Date(), severity: seData["side_effect_severity"] as! Int64, submit_time: dateFormatter.date(from: seData["side_effect_submit_time"] as! String) ?? Date(), symptom_id: nil, symptom_name: seData["side_effect_name"] as? String, onset_time: nil, med_taken: nil, medication_id: seData["side_effect_medication_id"] as? Int64, medication_name: nil, med_worked: nil, symptom_description: nil, notes: nil, trigger_ids: nil,  trigger_names: nil, side_effect_med: medDict?["medication_name"] as? String))
//            }
//        } catch {
//            if (error as NSError).code == -999 {
//                return []
//            }
//            print("Error fetching unified logs: \(error)")
//        }
//        return unifiedLogs.sorted { $0.date > $1.date }
//    }
    
    // MARK: - Shared Date Formatter
        static let isoDateFormatter: ISO8601DateFormatter = {
            let f = ISO8601DateFormatter()
            f.formatOptions = [.withFullDate]
            return f
        }()

    // MARK: - Decodable Models

    struct LogResponse: Decodable {
        let log_id: Int64
        let user_id: Int64
        let date: String
        let severity_level: Int64
        let submit_time: String
        let symptom_id: Int64?
        let onset_time: String?
        let med_taken: Bool?
        let log_medication_id: Int64?
        let med_worked: Bool?
        let symptom_description: String?
        let notes: String?

        let symptom: SymptomResponse?
        let medication: MedicationResponse?
        let log_triggers: [LogTriggerResponse]?
    }

    struct SymptomResponse: Decodable {
        let symptom_name: String
    }

    struct MedicationResponse: Decodable {
        let medication_name: String
    }

    struct LogTriggerResponse: Decodable {
        let trigger: TriggerResponse?
    }

    struct TriggerResponse: Decodable {
        let trigger_name: String
    }

    struct SideEffectResponse: Decodable {
        let side_effect_id: Int64
        let user_id: Int64
        let side_effect_date: String
        let side_effect_severity: Int64
        let side_effect_submit_time: String
        let side_effect_name: String?
        let side_effect_medication_id: Int64?

        let medication: MedicationResponse?
    }

    // MARK: - Optimized getLogList

    func getLogList(userID: Int64) async throws -> [UnifiedLog] {

        let formatter = Database.isoDateFormatter

        async let logsTask: [LogResponse] = client
            .from("Logs")
            .select("""
                log_id, user_id, date, severity_level, submit_time,
                symptom_id, onset_time, med_taken, log_medication_id,
                med_worked, symptom_description, notes,
                symptom:Symptoms(symptom_name),
                medication:Medications(medication_name),
                log_triggers:Log_Triggers(
                    trigger:Triggers(trigger_name)
                )
            """)
            .eq("user_id", value: Int(userID))
            .execute()
            .value

        async let sideEffectsTask: [SideEffectResponse] = client
            .from("Side_Effects")
            .select("""
                side_effect_id, user_id, side_effect_date,
                side_effect_severity, side_effect_submit_time,
                side_effect_name, side_effect_medication_id,
                medication:Medications(medication_name)
            """)
            .eq("user_id", value: Int(userID))
            .execute()
            .value

        let (logs, sideEffects) = try await (logsTask, sideEffectsTask)

        var unifiedLogs: [UnifiedLog] = []
        unifiedLogs.reserveCapacity(logs.count + sideEffects.count)

        // ---- Symptom Logs ----
        for log in logs {
            let triggerNames = log.log_triggers?
                .compactMap { $0.trigger?.trigger_name }

            unifiedLogs.append(
                UnifiedLog(
                    log_id: log.log_id,
                    user_id: log.user_id,
                    log_type: "Symptom",
                    date: formatter.date(from: log.date) ?? Date(),
                    severity: log.severity_level,
                    submit_time: formatter.date(from: log.submit_time) ?? Date(),
                    symptom_id: log.symptom_id,
                    symptom_name: log.symptom?.symptom_name,
                    onset_time: log.onset_time,
                    med_taken: log.med_taken,
                    medication_id: log.log_medication_id,
                    medication_name: log.medication?.medication_name,
                    med_worked: log.med_worked,
                    symptom_description: log.symptom_description,
                    notes: log.notes,
                    trigger_ids: nil,
                    trigger_names: triggerNames?.isEmpty == false ? triggerNames : nil,
                    side_effect_med: nil
                )
            )
        }

        // ---- Side Effect Logs ----
        for se in sideEffects {
            unifiedLogs.append(
                UnifiedLog(
                    log_id: se.side_effect_id,
                    user_id: se.user_id,
                    log_type: "Side Effect",
                    date: formatter.date(from: se.side_effect_date) ?? Date(),
                    severity: se.side_effect_severity,
                    submit_time: formatter.date(from: se.side_effect_submit_time) ?? Date(),
                    symptom_id: nil,
                    symptom_name: se.side_effect_name,
                    onset_time: nil,
                    med_taken: nil,
                    medication_id: se.side_effect_medication_id,
                    medication_name: nil,
                    med_worked: nil,
                    symptom_description: nil,
                    notes: nil,
                    trigger_ids: nil,
                    trigger_names: nil,
                    side_effect_med: se.medication?.medication_name
                )
            )
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
            if (error as NSError).code == -999 {
                return
            }
            print("Failed to delete log with ID \(logID): \(error)")
        }
    }
}
