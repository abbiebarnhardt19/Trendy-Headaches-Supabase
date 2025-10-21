//
//  ListFunctions.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/2/25.


import SQLite
import Foundation

extension Database {
    
    //get all the logs for a user and sort them
    func getLogList(userID: Int64) -> [UnifiedLog] {
        var unifiedLogs: [UnifiedLog] = []

        do {
            let symptomLogsQuery = logs.filter(self.user_id == userID)
            
            for row in try self.prepare(symptomLogsQuery) {
                let sid = row[self.symptom_id]
                let mid = row[self.log_medication_id]
                
                // Fetch symptom name via ID
                var symptomName: String? = nil
                let symptomQuery = symptoms.filter(self.symptom_id == sid)
                if let symptomRow = try self.pluck(symptomQuery) {
                    symptomName = symptomRow[self.symptom_name]
                }
                
                // Fetch medication name (if any)
                var medicationName: String? = nil
                if let mid = mid {
                    let medQuery = medications.filter(self.medication_id == mid)
                    if let medRow = try self.pluck(medQuery) {
                        medicationName = medRow[self.medication_name]
                    }
                }
                
                // Fetch triggers (optional)
                var triggerNames: [String] = []
                let triggerJoin = log_triggers
                    .join(triggers, on: log_triggers[self.lt_trigger_id] == triggers[self.trigger_id])
                    .filter(log_triggers[self.lt_log_id] == row[self.log_id])
                
                for trigRow in try self.prepare(triggerJoin) {
                    triggerNames.append(trigRow[self.trigger_name])
                }
                
                // Create Symptom log
                let unifiedLog = UnifiedLog(log_id: row[self.log_id], user_id: row[self.user_id], log_type: "Symptom",  date: row[self.date], severity: row[self.severity],  submit_time: row[self.submit_time], symptom_id: sid, symptom_name: symptomName,  onset_time: row[self.onset_time], med_taken: row[self.med_taken], medication_id: mid, medication_name: medicationName, med_worked: row[self.med_worked], symptom_description: row[self.symptom_description], notes: row[self.notes], trigger_ids: nil, trigger_names: triggerNames,  side_effect_med: nil)
                
                unifiedLogs.append(unifiedLog)
            }
            
            let sideEffectQuery = side_effects.filter(self.user_id == userID)
            
            for row in try self.prepare(sideEffectQuery) {
                let mid = row[self.side_effect_medication_id]
                
                // Fetch medication name
                var medicationName: String? = nil
                if let mid = mid {
                    let medQuery = medications.filter(self.medication_id == mid)
                    if let medRow = try self.pluck(medQuery) {
                        medicationName = medRow[self.medication_name]
                    }
                }
                
                // Create SideEffect log
                let unifiedLog = UnifiedLog( log_id: row[self.side_effect_id], user_id: row[self.user_id], log_type: "Side Effect", date: row[self.side_effect_date], severity: row[self.side_effect_severity], submit_time: row[self.side_effect_submit_time], symptom_id: nil,  symptom_name: row[self.side_effect_name], onset_time: nil, med_taken: nil,  medication_id: nil, medication_name: nil, med_worked: nil, symptom_description: nil, notes: nil, trigger_ids: nil,  trigger_names: nil,  side_effect_med: medicationName)
                
                unifiedLogs.append(unifiedLog)
            }
            
            unifiedLogs.sort {
                if $0.date == $1.date {
                    return ($0.submit_time) > ($1.submit_time)
                }
                return $0.date > $1.date
            }
        } catch {
            print(" Error fetching unified logs: \(error)")
        }
        return unifiedLogs
    }
    
    //function to delete log based on log id and table
    func deleteLog(logID: Int64, table:String) {
        do {
            if table == "Symptom" {
                let logs = Table("logs")
                let idColumn = SQLite.Expression<Int64>("log_id")
                
                let logToDelete = logs.filter(idColumn == logID)
                let delete = logToDelete.delete()
                
                let _ = try run(delete)
            }
            else{
                let logs = Table("side_effects")
                let idColumn = SQLite.Expression<Int64>("side_effect_id")
                
                let logToDelete = logs.filter(idColumn == logID)
                let delete = logToDelete.delete()
                
                let _ = try run(delete)
            }
        } catch {
            print(" Failed to delete log with ID \(logID): \(error)")
        }
    }
}
//
////
////  Log Functions.swift
////  Trendy Headaches
////
////  Created by Abigail Barnhardt
////
//
//import Foundation
//import Supabase
//
//extension Database {
//    
//    // Get all the logs for a user and sort them
//    func getLogList(userID: Int64) async -> [UnifiedLog] {
//        var unifiedLogs: [UnifiedLog] = []
//        
//        do {
//            // Fetch symptom logs
//            let symptomLogs: [Log] = try await client
//                .from("logs")
//                .select()
//                .eq("user_id", value: String(userID))
//                .execute()
//                .value
//            
//            for log in symptomLogs {
//                // Fetch symptom name via ID
//                var symptomName: String? = nil
//                let symptoms: [Symptom] = try await client
//                    .from("symptoms")
//                    .select()
//                    .eq("symptom_id", value: String(log.symptomId))
//                    .execute()
//                    .value
//                if let symptom = symptoms.first {
//                    symptomName = symptom.symptomName
//                }
//                
//                // Fetch medication name (if any)
//                var medicationName: String? = nil
//                if let medId = log.logMedicationId {
//                    let medications: [Medication] = try await client
//                        .from("medications")
//                        .select()
//                        .eq("medication_id", value: String(medId))
//                        .execute()
//                        .value
//                    if let medication = medications.first {
//                        medicationName = medication.medicationName
//                    }
//                }
//                
//                // Fetch triggers
//                var triggerNames: [String] = []
//                let logTriggers: [LogTrigger] = try await client
//                    .from("log_triggers")
//                    .select()
//                    .eq("log_id", value: String(log.logId))
//                    .execute()
//                    .value
//                
//                for logTrigger in logTriggers {
//                    let triggers: [Trigger] = try await client
//                        .from("triggers")
//                        .select()
//                        .eq("trigger_id", value: String(logTrigger.triggerId))
//                        .execute()
//                        .value
//                    if let trigger = triggers.first {
//                        triggerNames.append(trigger.triggerName)
//                    }
//                }
//                
//                // Parse date from ISO8601 string
//                let dateFormatter = ISO8601DateFormatter()
//                let logDate = dateFormatter.date(from: log.date) ?? Date()
//                let submitDate = dateFormatter.date(from: log.submitTime) ?? Date()
//                
//                // Create Symptom log
//                let unifiedLog = UnifiedLog(
//                    log_id: log.logId,
//                    user_id: log.userId,
//                    log_type: "Symptom",
//                    date: logDate,
//                    severity: log.severityLevel,
//                    submit_time: submitDate,
//                    symptom_id: log.symptomId,
//                    symptom_name: symptomName,
//                    onset_time: log.onsetTime,
//                    med_taken: log.medTaken,
//                    medication_id: log.logMedicationId,
//                    medication_name: medicationName,
//                    med_worked: log.medWorked,
//                    symptom_description: log.symptomDescription,
//                    notes: log.notes,
//                    trigger_ids: nil,
//                    trigger_names: triggerNames,
//                    side_effect_med: nil
//                )
//                
//                unifiedLogs.append(unifiedLog)
//            }
//            
//            // Fetch side effect logs
//            let sideEffectLogs: [SideEffect] = try await client
//                .from("side_effects")
//                .select()
//                .eq("user_id", value: String(userID))
//                .execute()
//                .value
//            
//            for sideEffect in sideEffectLogs {
//                // Fetch medication name
//                var medicationName: String? = nil
//                if let medId = sideEffect.medicationId {
//                    let medications: [Medication] = try await client
//                        .from("medications")
//                        .select()
//                        .eq("medication_id", value: String(medId))
//                        .execute()
//                        .value
//                    if let medication = medications.first {
//                        medicationName = medication.medicationName
//                    }
//                }
//                
//                // Parse date from ISO8601 string
//                let dateFormatter = ISO8601DateFormatter()
//                let sideEffectDate = dateFormatter.date(from: sideEffect.date) ?? Date()
//                let submitDate = dateFormatter.date(from: sideEffect.sideEffectSubmitTime) ?? Date()
//                
//                // Create SideEffect log
//                let unifiedLog = UnifiedLog(
//                    log_id: sideEffect.sideEffectId,
//                    user_id: sideEffect.userId,
//                    log_type: "Side Effect",
//                    date: sideEffectDate,
//                    severity: sideEffect.sideEffectSeverity,
//                    submit_time: submitDate,
//                    symptom_id: nil,
//                    symptom_name: sideEffect.sideEffectName,
//                    onset_time: nil,
//                    med_taken: nil,
//                    medication_id: nil,
//                    medication_name: nil,
//                    med_worked: nil,
//                    symptom_description: nil,
//                    notes: nil,
//                    trigger_ids: nil,
//                    trigger_names: nil,
//                    side_effect_med: medicationName
//                )
//                
//                unifiedLogs.append(unifiedLog)
//            }
//            
//            // Sort logs
//            unifiedLogs.sort {
//                if $0.date == $1.date {
//                    return $0.submit_time > $1.submit_time
//                }
//                return $0.date > $1.date
//            }
//            
//        } catch {
//            print("Error fetching unified logs: \(error)")
//        }
//        
//        return unifiedLogs
//    }
//    
//    // Function to delete log based on log id and table
//    func deleteLog(logID: Int64, table: String) async {
//        do {
//            if table == "Symptom" {
//                try await client
//                    .from("logs")
//                    .delete()
//                    .eq("log_id", value: String(logID))
//                    .execute()
//            } else {
//                try await client
//                    .from("side_effects")
//                    .delete()
//                    .eq("side_effect_id", value: String(logID))
//                    .execute()
//            }
//        } catch {
//            print("Failed to delete log with ID \(logID): \(error)")
//        }
//    }
//}
