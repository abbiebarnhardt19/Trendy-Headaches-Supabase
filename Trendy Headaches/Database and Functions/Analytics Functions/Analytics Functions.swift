//
//  Analytics Functions.swift
//  Trendy Headaches Supabase
//
//  Created by Abigail Barnhardt on 10/29/25.
//

import Foundation

// Make it public if needed outside the module
func fetchAnalyticsData(userID: Int) async throws -> ([UnifiedLog],  [Medication], [String]) {
    
    var logs: [UnifiedLog] = []
    var medData: [Medication] = []
    var symptomOptions: [String] = []
    
    // Fetch logs
    do {
        logs = try await Database.shared.getLogList(userID: Int64(userID))
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
    
    // Fetch symptom options
    do {
        symptomOptions = try await Database.shared.getListVals(
            userId: Int64(userID),
            table: "Symptoms",
            col: "symptom_name",
            includeInactive: true
        )
    } catch let error as NSError {
        if error.code != NSURLErrorCancelled {
            print("Error fetching symptoms: \(error)")
        }
    }
    
    return (logs, medData, symptomOptions)
}
