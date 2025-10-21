//
//  LogFunctions.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/2/25.
//

import SQLite
import Foundation
import CryptoKit

extension Database {
    
    //create log function
    func createLog(userID: Int64,  date: Date, symptom_onset: String?, symptom: Int64,  severity: Int64, med_taken: Bool, med_taken_id: Int64?,  symptom_desc: String,  notes: String,  submit: Date, triggerIDs: [Int64] = []) -> Int64? {
        
        do {
            // Insert log row
            let insert = Database.shared.logs.insert( Database.shared.user_id <- userID,
                Database.shared.date <- date,
                Database.shared.onset_time <- symptom_onset,
                Database.shared.severity <- severity,
                Database.shared.symptom_id <- symptom,
                Database.shared.med_taken <- med_taken,
                Database.shared.log_medication_id <- med_taken_id,
                Database.shared.med_worked <- nil,
                Database.shared.symptom_description <- symptom_desc,
                Database.shared.notes <- notes,
                Database.shared.submit_time <- submit)
            
            // Execute insert
            let logID = try Database.shared.run(insert)
            
            // If triggers were passed in, associate them in the junction table
            for trigID in triggerIDs {
                let linkInsert = Database.shared.log_triggers.insert(
                    Database.shared.lt_log_id <- logID,
                    Database.shared.lt_trigger_id <- trigID)
               
                _ = try Database.shared.run(linkInsert)
            }
            return logID
        } catch {
            print("Failed to create log: \(error)")
            return nil
        }
    }
    
    //crerate a side effect log
    func createSideEffectLog(userID: Int64, date: Date,  submit_time:Date, side_effect: String, side_effect_severity: Int64, medication_id: Int64 ) -> Int64? {
            do {
                let insert = Database.shared.side_effects.insert(
                    Database.shared.user_id <- userID,
                    Database.shared.side_effect_date <- date,
                    Database.shared.side_effect_submit_time <- submit_time,
                    Database.shared.side_effect_name <- side_effect,
                    Database.shared.side_effect_severity <- side_effect_severity,
                    Database.shared.side_effect_medication_id <- medication_id)
                
                // Execute insert
                let logID = try Database.shared.run(insert)
                return logID
            } catch {
                print("Failed to create log: \(error)")
                return nil
            }
        }
    
    //function to get logs that need a med followup
    func emergencyMedPopup(userID: Int64) -> [Int64] {
        var results: [Int64] = []
        
        do {
            let logs = Database.shared.logs
            
            let query = logs
                .filter(Database.shared.user_id == userID)
                .filter(Database.shared.med_taken == true)
                .filter(Database.shared.med_worked == nil)
            
            let rows = try Database.shared.prepare(query)
            
            for row in rows {
                let logID = row[Database.shared.log_id] // Get just the log ID
                results.append(logID)
            }
        } catch {
            print("Database error: \(error)")
        }
        return results
    }
    
    //function to update the log with effectiveness
    func updateMedEffective(logID: Int64, medEffectiveValue: Bool) {
        do {
            let log = logs.filter(log_id == logID)
            _ = try run(log.update(med_worked <- medEffectiveValue))
            
        } catch {
            print(" Failed to update log \(logID): \(error)")
        }
    }
    
    //function to update the rest of the log
    func updateSymptomLog(logID: Int64,  userID: Int64, date: Date?, onsetTime: String?,  severity: Int64?,  symptomID: Int64?, medTaken: Bool?, medicationID: Int64?, medWorked: Bool?,  symptomDescription: String?, notes: String?,  triggerIDs: [Int64]? ) {
        do {
            // Fetch current row
            let query = logs.filter(self.log_id == logID)
            guard let row = try pluck(query) else { return }
            
            // Build update dictionary dynamically
            var setters: [Setter] = []
            
            if let newDate = date, newDate != row[self.date] {
                setters.append(self.date <- newDate)
            }
            
            if let newOnset = onsetTime, newOnset != row[self.onset_time] {
                setters.append(self.onset_time <- newOnset)
            }
            
            if let newSeverity = severity, newSeverity != row[self.severity] {
                setters.append(self.severity <- newSeverity)
            }
            
            if let newSymptomID = symptomID, newSymptomID != row[self.symptom_id] {
                setters.append(self.symptom_id <- newSymptomID)
            }
            
            if let newMedTaken = medTaken, newMedTaken != row[self.med_taken] {
                setters.append(self.med_taken <- newMedTaken)
            }
            
            if let newMedicationID = medicationID, newMedicationID != row[self.log_medication_id] {
                setters.append(self.log_medication_id <- newMedicationID)
            }
            
            if let newMedWorked = medWorked, newMedWorked != row[self.med_worked] {
                setters.append(self.med_worked <- newMedWorked)
            }
            
            if let newSymptomDesc = symptomDescription, newSymptomDesc != row[self.symptom_description] {
                setters.append(self.symptom_description <- newSymptomDesc)
            }
            
            if let newNotes = notes, newNotes != row[self.notes] {
                setters.append(self.notes <- newNotes)
            }
            
            // Perform update only if there’s something to update
            if !setters.isEmpty {
                let updateQuery = query.update(setters)
               _ =  try run(updateQuery)
            }
            
            // Update triggers separately if needed
            if let newTriggerIDs = triggerIDs {
                // Remove old triggers for this log
               _ = try run(log_triggers.filter(lt_log_id == logID).delete())
                
                // Insert new trigger links
                for tID in newTriggerIDs {
                    _ = try run(log_triggers.insert(lt_log_id <- logID, lt_trigger_id <- tID))
                }
            }
        } catch {
            print("Error updating symptom log: \(error)")
        }
    }
    
    //update a side effects log
    func updateSideEffectLog( logID: Int64, userID: Int64, date: Date?, sideEffectName: String?,  sideEffectSeverity: Int64?, medicationID: Int64?) {
        do {
            // Fetch current row
            let query = side_effects.filter(self.side_effect_id == logID)
            guard let row = try pluck(query) else { return }

            var setters: [Setter] = []
            
            if let newDate = date, newDate != row[self.side_effect_date] {
                setters.append(self.side_effect_date <- newDate)
            }
            
            if let newName = sideEffectName, newName != row[self.side_effect_name] {
                setters.append(self.side_effect_name <- newName)
            }
            
            if let newSeverity = sideEffectSeverity, newSeverity != row[self.side_effect_severity] {
                setters.append(self.side_effect_severity <- newSeverity)
            }
            
            if let newMedicationID = medicationID, newMedicationID != row[self.side_effect_medication_id] {
                setters.append(self.side_effect_medication_id <- newMedicationID)
            }
            
            // Perform update only if there’s something to update
            if !setters.isEmpty {
                let updateQuery = query.update(setters)
                _ = try run(updateQuery)
            }
        } catch {
            print("Error updating side effect log: \(error)")
        }
    }
    
    //get the details of the log for the popup
    func getLogDetails(logID: Int64) -> (userID: Int64, date: Date, symptomName: String, symptomID: Int64, emergencyMedID: Int64?, emergencyMedName: String)? {
        do {
            let logs = Database.shared.logs
            let symptoms = Database.shared.symptoms
            let medications = Database.shared.medications
            
            // Get the log row for the given logID
            let logQuery = logs.filter(Database.shared.log_id == logID)
            if let logRow = try Database.shared.pluck(logQuery) {
                
                // Extract base log info
                let userID = logRow[Database.shared.user_id]
                let date = logRow[Database.shared.date]
                let symptomID = logRow[Database.shared.symptom_id]
                let emergencyMedID = logRow[Database.shared.log_medication_id]
               
                // Get symptom name
                var symptomName = ""
                let symptomQuery = symptoms.filter(Database.shared.symptom_id == symptomID)
                if let symptomRow = try Database.shared.pluck(symptomQuery) {
                    symptomName = symptomRow[Database.shared.symptom_name]
                }
                // Get medication name
                var emergencyMedName = ""
                if let medID = emergencyMedID {
                    let medQuery = medications.filter(Database.shared.medication_id == medID)
                    if let medRow = try Database.shared.pluck(medQuery) {
                        emergencyMedName = medRow[Database.shared.medication_name]
                    }
                }
                return (userID, date, symptomName, symptomID, emergencyMedID, emergencyMedName)
            }
        } catch {
            print("Database error while fetching log details: \(error)")
        }
        return nil
    }
    
    //get the id of an instance from its name and user
    func getIDFromName(tableName: String, names: [String], userID: Int64) -> [Int64] {
        let singular = String(tableName.dropLast())
        let idColumn = SQLite.Expression<Int64>("\(singular)_id")
        let nameColumn = SQLite.Expression<String>("\(singular)_name")
        let userColumn = SQLite.Expression<Int64>("user_id")
        let table = Table(tableName)
        
        var ids: [Int64] = []
        
        for name in names {
            let query = table.filter(userColumn == userID && nameColumn == name)
            do {
                if let row = try Database.shared.pluck(query) {
                    ids.append(row[idColumn])
                } else {
                    print("No row found for '\(name)'")
                }
            } catch {
                print("Error querying \(tableName) for '\(name)': \(error)")
            }
        }
        return ids
    }
    
    //function to load in log for editing
    func getUnifiedLog(by logID: Int64, logType: String) -> UnifiedLog? {
        do {
            if logType == "Symptom"{
                let query = logs.filter(self.log_id == logID)
                if let row = try pluck(query) {
                    // Get symptom name
                    let symptomID = row[self.symptom_id]
                    var symptomName: String? = nil
                    if let sRow = try pluck(symptoms.filter(self.symptom_id == symptomID)) {
                        symptomName = sRow[self.symptom_name]
                    }
                    // Get medication info
                    var medicationID: Int64? = nil
                    var medicationName: String? = nil
                    if let mID = row[self.log_medication_id] {
                        medicationID = mID
                        if let mRow = try pluck(medications.filter(self.medication_id == mID)) {
                            medicationName = mRow[self.medication_name]
                        }
                    }
                    // Get triggers
                    var triggerIDs: [Int64] = []
                    var triggerNames: [String] = []
                    let triggerQuery = log_triggers.filter(lt_log_id == logID)
                    for tRow in try prepare(triggerQuery) {
                        let tID = tRow[lt_trigger_id]
                        triggerIDs.append(tID)
                        if let tRow = try pluck(triggers.filter(trigger_id == tID)) {
                            triggerNames.append(tRow[self.trigger_name])
                        }
                    }
                    return UnifiedLog(log_id: row[self.log_id], user_id: row[self.user_id], log_type: "Symptom", date: row[self.date], severity: row[self.severity], submit_time: row[self.submit_time],  symptom_id: symptomID, symptom_name: symptomName, onset_time: row[self.onset_time], med_taken: row[self.med_taken], medication_id: medicationID, medication_name: medicationName, med_worked: row[self.med_worked],  symptom_description: row[self.symptom_description], notes: row[self.notes], trigger_ids: triggerIDs, trigger_names: triggerNames, side_effect_med: nil)
                }
            }
            else{
                let query = side_effects.filter(self.side_effect_id == logID)
                if let row = try pluck(query) {
                    let medicationID = row[self.side_effect_medication_id]
                    var medicationName: String? = nil
                    
                    // Lookup medication name
                    if let medID = medicationID {
                        let medQuery = medications.filter(self.medication_id == medID)
                        if let medRow = try pluck(medQuery) {
                            medicationName = medRow[self.medication_name]
                        }
                    }
                    return UnifiedLog(log_id: row[self.side_effect_id], user_id: row[self.user_id],  log_type: "SideEffect", date: row[self.side_effect_date],  severity: row[self.side_effect_severity], submit_time: row[self.side_effect_submit_time], symptom_id: nil, symptom_name: nil, onset_time: nil, med_taken: nil, medication_id: medicationID, medication_name: medicationName, med_worked: nil, symptom_description: nil, notes: nil, trigger_ids: nil, trigger_names: nil, side_effect_med: row[self.side_effect_name])
                }
            }
        } catch {
            print("Error fetching \(logType) log \(logID): \(error)")
        }
        return nil
    }
}
