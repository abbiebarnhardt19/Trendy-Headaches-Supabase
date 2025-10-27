//
//  General Access Functions.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/30/25.

import Foundation
import Supabase

extension Database {
    
    // Get a single column value using userID from users table
    func getSingleVal(userId: Int64, col: String) async throws -> String? {
        let user: User = try await client
            .from("Users")
            .select()
            .eq("user_id", value: String(userId))
            .single()
            .execute()
            .value
        
        // Map column names to User properties
        switch col {
        case "email":
            return user.email
        case "password":
            return user.password
        case "security_question":
            return user.securityQuestion
        case "security_answer":
            return user.securityAnswer
        case "background_color":
            return user.backgroundColor
        case "accent_color":
            return user.accentColor
        default:
            return nil
        }
    }
    
    // Get all values for a user from a table where userID is a foreign key
    func getListVals(userId: Int64, table: String, col: String, filterCol: String? = nil, filterVal: String? = nil) async throws -> [String] {
        switch table.lowercased() {
        case "medications":
            let medications: [Medication] = try await fetchFilteredList(userId: userId, tableName: "Medications", filterCol: filterCol, filterVal: filterVal)
            let result = medications.compactMap { medication in
                switch col {
                case "medication_name":
                    return medication.medicationName
                case "medication_category":
                    return medication.medicationCategory
                default:
                    return nil
                }
            }
            return result
            
        case "symptoms":
            let symptoms: [Symptom] = try await fetchFilteredList(userId: userId, tableName: "Symptoms", filterCol: filterCol, filterVal: filterVal)
            let result = symptoms.compactMap { symptom in
                switch col {
                case "symptom_name":
                    return symptom.symptomName
                default:
                    return nil
                }
            }
            return result
            
        case "triggers":
            let triggers: [Trigger] = try await fetchFilteredList(userId: userId, tableName: "Triggers", filterCol: filterCol, filterVal: filterVal)
            let result = triggers.compactMap { trigger in
                switch col {
                case "trigger_name":
                    return trigger.triggerName
                default:
                    return nil
                }
            }
            return result
            
        case "side_effects":
            let side_effects: [SideEffect] = try await client
                .from("Side_Effects")
                .select()
                .eq("user_id", value: Int(userId))
                .execute()
                .value
            
            let result = side_effects.compactMap { side_effect in
                switch col {
                case "side_effect_name":
                    return side_effect.sideEffectName
                default:
                    return nil
                }
            }
            // Remove duplicates and sort
            return Array(Set(result)).sorted()
            
        default:
            print(" Unknown table: \(table)")
            return []
        }
    }
    
    // Helper function to fetch filtered lists
    private func fetchFilteredList<T: Codable>(userId: Int64, tableName: String, filterCol: String?, filterVal: String?) async throws -> [T] {
        let endColumnName = "\(tableName.dropLast().lowercased())_end"
        var query = client
            .from(tableName)
            .select()
            .eq("user_id", value: Int(userId))
            .is(endColumnName, value: nil)
        
        if let filterCol = filterCol, let filterVal = filterVal {
            query = query.eq(filterCol, value: filterVal)
        }
        
        return try await query.execute().value
    }
    
    func getMedications(userId: Int64) async throws -> [Medication] {
        let query = client
            .from("Medications")
            .select()
            .eq("user_id", value: Int(userId))
        
        let response: [Medication] = try await query.execute().value
        return response
    }
    
}
