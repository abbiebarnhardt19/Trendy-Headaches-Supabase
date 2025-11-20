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
            if (error as NSError).code == -999 {
                return false
            }
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
    static func createUser(email: String, pass: String, SQ: String, SA: String, bg: String, accent: String, symps: String, prevMeds: String, emergMeds: String, triggs: String) async throws -> Int64{
        let normalizedEmail = Database.normalize(email)
        
        let userID = try await Database.shared.addUser( security_question_string: SQ, security_answer_string: SA, emailAddress: normalizedEmail, passwordHash: hashString(pass), userBackground: bg, userAccent: accent, preventativeMedsCSV: prevMeds, emergencyMedsCSV: emergMeds, symptomsCSV: symps, triggersCSV: triggs)
        
        return userID
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
                .eq("password", value: hashString(password))
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
            
            try await Database.shared.client
                .from("Users")
                .update(["password": hashString(password)])
                .eq("user_id", value: Int(userId))
                .execute()
            
            return true
        } catch {
            if (error as NSError).code == -999 {
                return false
            }
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
                .eq("user_id", value: Int(userID))
                .execute()
        } catch {
            if (error as NSError).code == -999 {
                return
            }
            
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
            if (error as NSError).code == -999 {
                return
            }
            print("Failed to update user \(userID): \(error)")
        }
    }
    
    // Function to load the data for the profile page, multiple async calls so its faster
    func loadData(userID: Int64) async -> (symps: [String], triggs: [String], prevMeds: [String], emergMeds: [String], SQ: String, SA: String, bg: String, accent: String, theme: String)? {
        do {
            // Fire all async calls concurrently
            async let sympsTask = Database.shared.getListVals(userId: userID, table: "Symptoms", col: "symptom_name")
            async let triggsTask = Database.shared.getListVals(userId: userID, table: "Triggers", col: "trigger_name")
            async let prevMedsTask = Database.shared.getListVals(userId: userID, table: "Medications", col: "medication_name", filterCol: "medication_category", filterVal: "preventative")
            async let emergMedsTask = Database.shared.getListVals(userId: userID, table: "Medications", col: "medication_name", filterCol: "medication_category", filterVal: "emergency")
            async let SQTask = Database.shared.getSingleVal(userId: userID, col: "security_question")
            async let SATask = Database.shared.getSingleVal(userId: userID, col: "security_answer")
            async let bgTask = Database.shared.getSingleVal(userId: userID, col: "background_color")
            async let accentTask = Database.shared.getSingleVal(userId: userID, col: "accent_color")
            
            // Wait for all results
            var symps = try await sympsTask
            var triggs = try await triggsTask
            var prevMeds = try await prevMedsTask
            var emergMeds = try await emergMedsTask
            let SQ = try await SQTask ?? "None set"
            let SA = try await SATask ?? "None set"
            let bg = try await bgTask ?? "#ffffff"
            let accent = try await accentTask ?? "#000000"
            
            // Remove duplicates
            symps = Database.deleteDups(list: symps)
            triggs = Database.deleteDups(list: triggs)
            prevMeds = Database.deleteDups(list: prevMeds)
            emergMeds = Database.deleteDups(list: emergMeds)
            
            let theme = Database.getThemeName(background: bg, accent: accent)
            
            return (symps, triggs, prevMeds, emergMeds, SQ, SA, bg, accent, theme)
            
        } catch {
            if (error as NSError).code == -999 {
                return nil
            }
            print("ERROR in loadData: \(error)")
            return nil
        }
    }
    
    // Function for users adding a value to a category
    func insertItem(tableName: String, userID: Int64, name: String, medCat: String? = nil) async {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        
        do {
            switch tableName.lowercased() {
            case "medications":
                guard let category = medCat else { return }
                let medicationData = MedicationInsert(user_id: userID, medication_category: category, medication_name: name, medication_start: dateString, medication_end: nil, end_reason: nil)
                try await client.from("Medications").insert(medicationData).execute()
                
            case "symptoms":
                let symptomData = SymptomInsert(user_id: userID, symptom_name: name, symptom_start: dateString, symptom_end: nil)
                try await client.from("Symptoms").insert(symptomData).execute()
                
            case "triggers":
                let triggerData = TriggerInsert(user_id: userID, trigger_name: name, trigger_start: dateString, trigger_end: nil)
    
                try await client.from("Triggers").insert(triggerData).execute()
                
            default:
                print("Unknown table: \(tableName)")
            }
        } catch {
            if (error as NSError).code == -999 {
                return
            }
            print("Failed to insert \(name): \(error)")
        }
    }
    
    // Function for users updating a value
    func updateItem(tableName: String, userID: Int64, old: String, new: String, medCat: String? = nil) async {
        do {
            let nameColumn: String
            switch tableName.lowercased() {
            case "medications":
                nameColumn = "medication_name"
            case "symptoms":
                nameColumn = "symptom_name"
            case "triggers":
                nameColumn = "trigger_name"
            default:
                print("Unknown table: \(tableName)")
                return
            }
            
            var query = try client
                .from(tableName)
                .update([nameColumn: new])
                .eq("user_id", value: Int(userID))
                .eq(nameColumn, value: old)
            
            if let category = medCat {
                query = query.eq("medication_category", value: category)
            }
            
            try await query.execute()
        } catch {
            if (error as NSError).code == -999 {
                return
            }
            print("Failed to update \(old): \(error)")
        }
    }
    
    func endItem(
        tableName: String,
        userID: Int64,
        name: String,
        medCat: String? = nil,
        endReason: String? = nil
    ) async {
        do {
            let nameColumn: String
            let endColumn: String
            let endReasonColumn: String?

            // Match database column names
            switch tableName.lowercased() {
            case "medications":
                nameColumn = "medication_name"
                endColumn = "medication_end"
                endReasonColumn = "end_reason"
            case "symptoms":
                nameColumn = "symptom_name"
                endColumn = "symptom_end"
                endReasonColumn = nil
            case "triggers":
                nameColumn = "trigger_name"
                endColumn = "trigger_end"
                endReasonColumn = nil
            default:
                print("Unknown table: \(tableName)")
                return
            }

            // Format date
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let endDate = formatter.string(from: Date())

            // Default reason
            let reasonToSave = (endReason?.isEmpty ?? true) ? "Unknown" : endReason!

            // Only include valid dictionary keys
            var updateData: [String: String] = [endColumn: endDate]
            if let endReasonColumn = endReasonColumn {
                updateData[endReasonColumn] = reasonToSave
            }

            // Build query
            var query = try client
                .from(tableName)
                .update(updateData)
                .eq("user_id", value: Int(userID))
                .eq(nameColumn, value: name)

            if let category = medCat {
                query = query.eq("medication_category", value: category)
            }

            // Execute
            print("Update data being sent to Supabase:", updateData)
            let result = try await query.execute()
            print("Supabase result:", result)
            print(" Ended \(name) with reason: \(reasonToSave) at \(Date())")

        } catch {
            if (error as NSError).code == -999 {
                return
            }
            print(" Failed to end \(name): \(error)")
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
            if (error as NSError).code == -999 {
                return nil
            }
            print("Supabase error in userFromEmail: \(error)")
            return nil
        }
    }
    
    //get the users colors
    func getColors(userID: Int64) async -> (String, String) {
        do {
            let users: [UserColors] = try await client
                .from("Users")
                .select("background_color, accent_color")
                .eq("user_id", value: Int(userID))
                .execute()
                .value

            if let user = users.first {
                return (user.background_color, user.accent_color)
            } else {
                return ("", "")
            }

        } catch {
            if (error as NSError).code == -999 {
                return ("","")
            }
            print("Supabase error in getColors: \(error)")
            return ("", "")
        }
    }
    
    struct UserIDRow: Decodable { let user_id: Int64 }

    func getAllUserIDs() async -> [Int64] {
        do {
            let rows: [UserIDRow] = try await client
                .from("Users")
                .select("user_id") 
                .execute()
                .value

            return rows.map { $0.user_id }
        }
        catch {
            print("Error fetching user IDs: \(error)")
            return []
        }
    }



}
