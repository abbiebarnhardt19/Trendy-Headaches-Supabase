//
//  Account Functions.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/2/25.

import Foundation
import Supabase
import CryptoKit

extension Database {
    
    // Check if the email is present in the users table
    static func emailExists(_ email: String) async -> Bool {
        let cleanedEmail = Database.normalize(email)
        do {
            let users: [User] = try await Database.shared.client
                .from("Users")
                .select()
                .eq("email", value: cleanedEmail)
                .execute()
                .value
            return !users.isEmpty
        } catch let error as NSError where error.code == NSURLErrorCancelled {
            // Ignore cancellation errors - they're expected when debouncing
            return false
        } catch {
            print("Supabase error in emailExists: \(error)")
            return false
        }
    }
    
    // Lowercase string and remove whitespace
    static func normalize(_ s: String) -> String {
        s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    
    // Check if password meets complexity requirements
    static func passwordValid(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^A-Za-z\\d]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    // Add user to the database (now uses the existing addUser function)
    static func createUser(email: String, pass: String, SQ: String, SA: String, bg: String, accent: String, symps: String, prevMeds: String, emergMeds: String, triggs: String) async throws {
        let normalizedEmail = Database.normalize(email)
        //let hashedPassword = Database.hashString(pass)
        //let hashedSecurityAnswer = Database.hashString(Database.normalize(SA))
        
        _ = try await Database.shared.addUser(
            security_question_string: SQ,
            security_answer_string: SA,
            emailAddress: normalizedEmail,
            passwordHash: pass,
            userBackground: bg,
            userAccent: accent,
            preventativeMedsCSV: prevMeds,
            emergencyMedsCSV: emergMeds,
            symptomsCSV: symps,
            triggersCSV: triggs
        )
    }
    
    // Check if email and password combo is valid
    func attemptLogin(email: String, password: String) async -> (userId: Int64?, error: String?) {
        let normalizedEmail = Database.normalize(email)
        //let hashedPassword = Database.hashString(password)
        
        do {
            let users: [User] = try await client
                .from("Users")
                .select()
                .eq("email", value: normalizedEmail)
                .eq("password", value: password)
                .execute()
                .value
            
            if let user = users.first {
                return (user.userId, nil)
            } else {
                return (nil, "Invalid email or password")
            }
        } catch {
            return (nil, "Supabase error in attemptLogin: \(error)")
        }
    }
    
    // Reset password function
    static func resetPassword(email: String, password: String) async -> Bool {
        do {
            guard let userId = await Database.shared.userFromEmail(email: email) else {
                print("Error in resetPassword: user not found")
                return false
            }
            
            //let hashedPassword = Database.hashString(password)
            
            struct PasswordUpdate: Encodable {
                let password: String
            }
            
            let updateData = PasswordUpdate(password: password)
            
            try await Database.shared.client
                .from("Users")
                .update(updateData)
                .eq("user_id", value: String(userId))
                .execute()
            
            return true
        } catch {
            print("Supabase error in resetPassword: \(error)")
            return false
        }
    }
    
    // Delete user function
    func deleteUser(userID: Int64) async {
        do {
            try await client
                .from("Users")
                .delete()
                .eq("user_id", value: String(userID))
                .execute()
        } catch {
            print("Failed to delete user \(userID): \(error)")
        }
    }
    
    // Function to update a value in the users table
    func updateUser(userID: Int64, value: String, col: String) async {
        do {
            // Create encodable struct for update
            struct GenericUpdate: Encodable {
                private let data: [String: String]
                
                init(column: String, value: String) {
                    self.data = [column: value]
                }
                
                func encode(to encoder: Encoder) throws {
                    var container = encoder.container(keyedBy: DynamicKey.self)
                    for (key, value) in data {
                        guard let dynamicKey = DynamicKey(stringValue: key) else { continue }
                        try container.encode(value, forKey: dynamicKey)
                    }
                }
                
                struct DynamicKey: CodingKey {
                    var stringValue: String
                    var intValue: Int? { return nil }
                    init?(stringValue: String) { self.stringValue = stringValue }
                    init?(intValue: Int) { return nil }
                }
            }
            
            let updateData = GenericUpdate(column: col, value: value)
            
            try await client
                .from("Users")
                .update(updateData)
                .eq("user_id", value: String(userID))
                .execute()
        } catch {
            print("Failed to update user \(userID): \(error)")
        }
    }
    
    // Function to load the data for the profile page
    func loadData(userID: Int64) async -> (symps: [String], triggs: [String], prevMeds: [String], emergMeds: [String], SQ: String, SA: String, bg: String, accent: String, theme: String)? {
        print("🧪 INLINE TEST START")

        do {
            print("Testing Symptoms with different approaches...")
            
            // Test 1: Direct query, no filters
            let test1: [Symptom] = try await client
                .from("Symptoms")
                .select()
                .execute()
                .value
            print("Test 1 - All symptoms: \(test1.count)")
            
            // Test 2: Filter by user_id as Int
            let test2: [Symptom] = try await client
                .from("Symptoms")
                .select()
                .eq("user_id", value: 9)
                .execute()
                .value
            print("Test 2 - user_id=9 (as Int): \(test2.count)")
            
            // Test 3: Filter by user_id as String
            let test3: [Symptom] = try await client
                .from("Symptoms")
                .select()
                .eq("user_id", value: "9")
                .execute()
                .value
            print("Test 3 - user_id='9' (as String): \(test3.count)")
            
        } catch {
            print("Test error: \(error)")
        }
        print("🧪 INLINE TEST END")
        print("🚀 loadData called with userID: \(userID)")
        
        do {
            print("📋 About to fetch symptoms...")
            var symps = try await Database.shared.getListVals(userId: userID, table: "Symptoms", col: "symptom_name")
            print("   Symptoms result: \(symps)")
            symps = Database.deleteDups(list: symps)
            
            print("📋 About to fetch triggers...")
            var triggs = try await Database.shared.getListVals(userId: userID, table: "Triggers", col: "trigger_name")
            print("   Triggers result: \(triggs)")
            triggs = Database.deleteDups(list: triggs)
            
            print("📋 About to fetch preventative meds...")
            var prevMeds = try await Database.shared.getListVals(userId: userID, table: "Medications", col: "medication_name", filterCol: "medication_category", filterVal: "preventative")
            print("   Preventative meds result: \(prevMeds)")
            prevMeds = Database.deleteDups(list: prevMeds)
            
            print("📋 About to fetch emergency meds...")
            var emergMeds = try await Database.shared.getListVals(userId: userID, table: "Medications", col: "medication_name", filterCol: "medication_category", filterVal: "emergency")
            print("   Emergency meds result: \(emergMeds)")
            emergMeds = Database.deleteDups(list: emergMeds)
            
            let SQ = try await Database.shared.getSingleVal(userId: userID, col: "security_question") ?? "None set"
            let SA = try await Database.shared.getSingleVal(userId: userID, col: "security_answer") ?? "None set"
            
            let bg = try await Database.shared.getSingleVal(userId: userID, col: "background_color") ?? "None set"
            let accent = try await Database.shared.getSingleVal(userId: userID, col: "accent_color") ?? "None set"
            
            let theme = Database.getThemeName(background: bg, accent: accent)
            
            print("✅ loadData completed successfully")
            return (symps, triggs, prevMeds, emergMeds, SQ, SA, bg, accent, theme)
        } catch {
            print("❌ ERROR in loadData: \(error)")
            return nil
        }
    }
    
    // Function for users adding a value to a category
    func insertItem(tableName: String, userID: Int64, name: String, medCat: String? = nil) async {
        do {
            switch tableName.lowercased() {
            case "Medications":
                guard let category = medCat else { return }
                let medicationData = MedicationInsert(
                    user_id: userID,
                    medication_category: category,
                    medication_name: name,
                    medication_start: ISO8601DateFormatter().string(from: Date())
                )
                try await client.from("Medications").insert(medicationData).execute()
                
            case "Symptoms":
                let symptomData = SymptomInsert(
                    user_id: userID,
                    symptom_name: name,
                    symptom_start: ISO8601DateFormatter().string(from: Date())
                )
                try await client.from("Symptoms").insert(symptomData).execute()
                
            case "Triggers":
                let triggerData = TriggerInsert(
                    user_id: userID,
                    trigger_name: name,
                    trigger_start: ISO8601DateFormatter().string(from: Date())
                )
                try await client.from("Triggers").insert(triggerData).execute()
                
            default:
                print("Unknown table: \(tableName)")
            }
        } catch {
            print("Failed to insert \(name): \(error)")
        }
    }
    
    // Function for users updating a value
    func updateItem(tableName: String, userID: Int64, old: String, new: String, medCat: String? = nil) async {
        do {
            let nameColumn: String
            switch tableName.lowercased() {
            case "Medications":
                nameColumn = "medication_name"
            case "Symptoms":
                nameColumn = "symptom_name"
            case "Triggers":
                nameColumn = "trigger_name"
            default:
                print("Unknown table: \(tableName)")
                return
            }
            
            // Create encodable struct for update
            struct GenericUpdate: Encodable {
                private let data: [String: String]
                
                init(column: String, value: String) {
                    self.data = [column: value]
                }
                
                func encode(to encoder: Encoder) throws {
                    var container = encoder.container(keyedBy: DynamicKey.self)
                    for (key, value) in data {
                        guard let dynamicKey = DynamicKey(stringValue: key) else { continue }
                        try container.encode(value, forKey: dynamicKey)
                    }
                }
                
                struct DynamicKey: CodingKey {
                    var stringValue: String
                    var intValue: Int? { return nil }
                    init?(stringValue: String) { self.stringValue = stringValue }
                    init?(intValue: Int) { return nil }
                }
            }
            
            let updateData = GenericUpdate(column: nameColumn, value: new)
            
            // Build query
            var query = try client
                .from(tableName)
                .update(updateData)
                .eq("user_id", value: String(userID))
                .eq(nameColumn, value: old)
            
            if let category = medCat {
                query = query.eq("medication_category", value: category)
            }
            
            try await query.execute()
        } catch {
            print("Failed to update \(old): \(error)")
        }
    }
    
    // Function for users to stop an item
    func endItem(tableName: String, userID: Int64, name: String, medCat: String? = nil) async {
        do {
            let nameColumn: String
            let endColumn: String
            
            switch tableName.lowercased() {
            case "Medications":
                nameColumn = "medication_name"
                endColumn = "medication_end"
            case "Symptoms":
                nameColumn = "symptom_name"
                endColumn = "symptom_end"
            case "Triggers":
                nameColumn = "trigger_name"
                endColumn = "trigger_end"
            default:
                print("Unknown table: \(tableName)")
                return
            }
            
            let endDate = ISO8601DateFormatter().string(from: Date())
            
            // Create encodable struct for update
            struct GenericUpdate: Encodable {
                private let data: [String: String]
                
                init(column: String, value: String) {
                    self.data = [column: value]
                }
                
                func encode(to encoder: Encoder) throws {
                    var container = encoder.container(keyedBy: DynamicKey.self)
                    for (key, value) in data {
                        guard let dynamicKey = DynamicKey(stringValue: key) else { continue }
                        try container.encode(value, forKey: dynamicKey)
                    }
                }
                
                struct DynamicKey: CodingKey {
                    var stringValue: String
                    var intValue: Int? { return nil }
                    init?(stringValue: String) { self.stringValue = stringValue }
                    init?(intValue: Int) { return nil }
                }
            }
            
            let updateData = GenericUpdate(column: endColumn, value: endDate)
            
            var query = try client
                .from(tableName)
                .update(updateData)
                .eq("user_id", value: String(userID))
                .eq(nameColumn, value: name)
            
            if let category = medCat {
                query = query.eq("medication_category", value: category)
            }
            
            try await query.execute()
            
            if let category = medCat {
                print("Ended \(name) (\(category)) at \(Date())")
            } else {
                print("Ended \(name) at \(Date())")
            }
        } catch {
            print("Failed to end \(name): \(error)")
        }
    }
    
    // Delete list duplicates
    static func deleteDups(list: [String]) -> [String] {
        var tempList = [String]()
        for item in list {
            if !tempList.contains(item) {
                tempList.append(item)
            }
        }
        return tempList
    }
    
    // Get the user ID from the email address
    func userFromEmail(email: String) async -> Int64? {
        do {
            let users: [User] = try await client
                .from("Users")
                .select()
                .eq("email", value: email)
                .execute()
                .value
            return users.first?.userId
        } catch {
            print("Supabase error in userFromEmail: \(error)")
            return nil
        }
    }
}
