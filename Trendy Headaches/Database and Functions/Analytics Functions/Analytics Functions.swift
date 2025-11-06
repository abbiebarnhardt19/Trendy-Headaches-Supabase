//
//  Analytics Functions.swift
//  Trendy Headaches Supabase
//
//  Created by Abigail Barnhardt on 10/29/25.
//

import Foundation

//get logs, meds, symptoms, triggers, and earliest log date
func fetchAnalyticsData(userID: Int) async throws -> ([UnifiedLog], [Medication], [String], [String], Date?) {
    
    var logs: [UnifiedLog] = []
    var medData: [Medication] = []
    var symptomOptions: [String] = []
    var triggerOptions: [String] = []
    var earliestLogDate: Date? = nil
    
    // Fetch logs
    do {
        logs = try await Database.shared.getLogList(userID: Int64(userID))
        
        // Compute earliest log date (if any logs exist)
        if !logs.isEmpty {
            earliestLogDate = logs
                .compactMap { $0.date } // assumes `date` is optional Date?
                .min() // find earliest
        }
    } catch let error as NSError {
        if error.code != NSURLErrorCancelled {
            print("Error fetching logs: \(error)")
        }
    }
    
    // Fetch medications
    do {
        medData = try await Database.shared.getMedications(userId: Int64(userID))
    } catch let error as NSError {
        if error.code != NSURLErrorCancelled {
            print("Error fetching medications: \(error)")
        }
    }
    
    // Fetch symptom + trigger options
    do {
        //get symptom list
        let symptoms = try await Database.shared.getListVals(userId: Int64(userID), table: "Symptoms", col: "symptom_name",  includeInactive: true)
        
        //get side effect list
        let sideEffects = try await Database.shared.getListVals(userId: Int64(userID), table: "Side_Effects", col: "side_effect_name", includeInactive: true)
        
        // Combine symptoms and side effects and remove duplicates
        symptomOptions = Array(Set(symptoms + sideEffects)).sorted()
        
        //get triggers
        let triggers = try await Database.shared.getListVals(userId: Int64(userID), table: "Triggers", col: "trigger_name", includeInactive: true )
        
        //remove duplicates
        triggerOptions = Array(Set(triggers)).sorted()
        
    } catch let error as NSError {
        if error.code != NSURLErrorCancelled {
            print("Error fetching symptoms or side effects: \(error)")
        }
    }
    
    return (logs, medData, symptomOptions, triggerOptions, earliestLogDate)
}
