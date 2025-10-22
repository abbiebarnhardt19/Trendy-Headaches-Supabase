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
        
        print("🔍 getListVals - userId: \(userId), table: \(table), col: \(col)")
        
        switch table.lowercased() {
        case "medications":
            print("   → Fetching medications...")
            let medications: [Medication] = try await fetchFilteredList(userId: userId, tableName: "Medications", filterCol: filterCol, filterVal: filterVal)
            print("   ← Received \(medications.count) medications")
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
            print("   ← Returning \(result.count) medication names")
            return result
            
        case "symptoms":
            print("   → Fetching symptoms...")
            let symptoms: [Symptom] = try await fetchFilteredList(userId: userId, tableName: "Symptoms", filterCol: filterCol, filterVal: filterVal)
            print("   ← Received \(symptoms.count) symptoms")
            let result = symptoms.compactMap { symptom in
                switch col {
                case "symptom_name":
                    return symptom.symptomName
                default:
                    return nil
                }
            }
            print("   ← Returning \(result.count) symptom names")
            return result
            
        case "triggers":
            print("   → Fetching triggers...")
            let triggers: [Trigger] = try await fetchFilteredList(userId: userId, tableName: "Triggers", filterCol: filterCol, filterVal: filterVal)
            print("   ← Received \(triggers.count) triggers")
            let result = triggers.compactMap { trigger in
                switch col {
                case "trigger_name":
                    return trigger.triggerName
                default:
                    return nil
                }
            }
            print("   ← Returning \(result.count) trigger names")
            return result
            
        default:
            print("   ⚠️ Unknown table: \(table)")
            return []
        }
    }
    
    // Helper function to fetch filtered lists
    private func fetchFilteredList<T: Codable>(userId: Int64, tableName: String, filterCol: String?, filterVal: String?) async throws -> [T] {
        let endColumnName = "\(tableName.dropLast().lowercased())_end"
        
        print("🔍 fetchFilteredList DEBUG:")
        print("   Table: \(tableName)")
        print("   UserId: \(userId) (type: Int64)")
        print("   End column: \(endColumnName)")
        print("   Filter: \(filterCol ?? "none") = \(filterVal ?? "none")")
        
        // First, try to fetch ALL records to see if there's any data
        print("\n📊 Checking if table has ANY data...")
        let allRecords: [T] = try await client
            .from(tableName)
            .select()
            .execute()
            .value
        print("   Total records in \(tableName): \(allRecords.count)")
        
        // Now check records for this user (without the end filter)
        print("\n👤 Checking records for user_id = \(userId)...")
        let userRecords: [T] = try await client
            .from(tableName)
            .select()
            .eq("user_id", value: Int(userId))
            .execute()
            .value
        print("   Records for this user: \(userRecords.count)")
        
        // Now add the end filter
        print("\n🔚 Checking with end column filter...")
        var query = client
            .from(tableName)
            .select()
            .eq("user_id", value: Int(userId))
            .is(endColumnName, value: nil)
        
        if let filterCol = filterCol, let filterVal = filterVal {
            print("   Adding filter: \(filterCol) = \(filterVal)")
            query = query.eq(filterCol, value: filterVal)
        }
        
        let response: [T] = try await query.execute().value
        print("   ✅ Final result: \(response.count) records")
        print("   Response: \(response)")
        
        return response
    }
    
}
