//
//  Account Functions.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/2/25.
//
//
import SQLite
import Foundation
import CryptoKit

extension Database {
    
    //check if the email is present in the users table
    static func emailExists(_ email: String) -> Bool {
        let cleaned_email = Database.normalize(email)
        let query = Database.shared.users.filter(Database.shared.email == cleaned_email)
        do {
            return try Database.shared.pluck(query) != nil
        } catch {
            print("SQLite error in doesEmailExist: \(error)")
            return false
        }
    }
    
    //lowercase string and remove whitespace
    static func normalize(_ s: String) -> String {
        s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    
    //check if password meets complexity requirements
    static func passwordValid(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^A-Za-z\\d]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    //add user to the database
    static func createUser(email: String, pass: String, SQ: String, SA: String, bg: String, accent: String, symps: String, prevMeds: String, emergMeds: String, triggs: String)
    throws {
        let normalizedEmail = Database.normalize(email)
        let hashedPassword = Database.hashString(pass)
        let hashedSecurityAnswer = Database.hashString(Database.normalize(SA))
        
        // Insert into users table
        let insertUser = Database.shared.users.insert(
            Database.shared.security_question <- SQ,
            Database.shared.security_answer <- hashedSecurityAnswer,
            Database.shared.email <- normalizedEmail,
            Database.shared.password <- hashedPassword,
            Database.shared.background_color <- bg,
            Database.shared.accent_color <- accent)
        
        //get user ID to use as foriegn key
        let userId: Int64
        do {
            userId = try Database.shared.run(insertUser)
        } catch {
            print("SQLite error in createUser (users): \(error)")
            throw error
        }
        
        // insert into symptoms table, seperate by comma and remove whitespace
        for symptom in symps.split(separator: ",").map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }) where !symptom.isEmpty {
            let insertSymptom = Database.shared.symptoms.insert(
                Database.shared.user_id <- userId,
                Database.shared.symptom_name <- symptom,
                Database.shared.symptom_start <- Date(),
                Database.shared.symptom_end <- nil
            )
            do {
                _ = try Database.shared.run(insertSymptom)
            } catch {
                print("SQLite error in createUser (symptoms): \(error)")
            }
        }
        
        // insert into triggers table, seperate by comma and remove whitespace
        for trigger in triggs.split(separator: ",").map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }) where !trigger.isEmpty {
            let insertTrigger = Database.shared.triggers.insert(
                Database.shared.user_id <- userId,
                Database.shared.trigger_name <- trigger,
                Database.shared.trigger_start <- Date(),
                Database.shared.trigger_end <- nil)
            
            do {
                _ = try Database.shared.run(insertTrigger)
            } catch {
                print("SQLite error in createUser (triggers): \(error)")
            }
        }
        
        // insert into prev meds table, seperate by comma and remove whitespace
        for med in prevMeds.split(separator: ",").map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }) where !med.isEmpty {
            let insertMed = Database.shared.medications.insert(
                Database.shared.user_id <- userId,
                Database.shared.medication_category <- "preventative",
                Database.shared.medication_name <- med,
                Database.shared.medication_start <- Date(),
                Database.shared.medication_end <- nil)
            
            do {
                _ = try Database.shared.run(insertMed)
            } catch {
                print("SQLite error in createUser (prev meds): \(error)")
            }
        }
        
        // insert into emeg meds table, seperate by comma and remove whitespace
        for med in emergMeds.split(separator: ",").map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }) where !med.isEmpty {
            let insertMed = Database.shared.medications.insert(
                Database.shared.user_id <- userId,
                Database.shared.medication_category <- "emergency",
                Database.shared.medication_name <- med,
                Database.shared.medication_start <- Date(),
                Database.shared.medication_end <- nil)
            do {
                _ = try Database.shared.run(insertMed)
            } catch {
                print("SQLite error in createUser (emergencyMeds): \(error)")
            }
        }
    }
    
    //check if email and password combo is valid
    func attemptLogin(email: String, password: String) -> (userId: Int64?, error: String?) {
        let normalizedEmail = Database.normalize(email)
        let hashedPassword = Database.hashString(password)
        
        do {
            // Query for a matching user
            let query = users.filter(self.email == normalizedEmail && self.password == hashedPassword)
            
            if let user = try pluck(query) {
                return (user[user_id], nil)
            } else {
                return (nil, "Invalid email or password")
            }
        } catch {
            return (nil, "SQLite error in attemptLogin: \(error)")
        }
    }
    
    //reset password function
    static func resetPassword(email: String, password: String) -> Bool {
        do {
            guard let userID = Database.shared.userFromEmail(email: email) else {
                print("Error in resetPassword")
                return false
            }
            
            //hash the password and grab the user's row
            let hashedPassword = Database.hashString(password)
            let userFilter = Database.shared.users.filter(Database.shared.user_id == userID)
            
            _ = try Database.shared.run(userFilter.update(Database.shared.password <- hashedPassword))
            return true
            
        } catch {
            print("SQLite error in resetPassword: \(error)")
            return false
        }
    }
    
    //delete user function
    func deleteUser(userID: Int64) {
        do {
            //set variables
            let users = Table("users")
            let id = SQLite.Expression<Int64>("user_id")
            
            let deleteQuery = users.filter(id == userID).delete()
            let _ = try run(deleteQuery)

        } catch {
            print("Failed to delete user \(userID): \(error)")
        }
    }
    
    //function to update a value in the users table
    func updateUser(userID: Int64, value: String, col: String){
        do {
            let users = Table("users")
            let id = SQLite.Expression<Int64>("user_id")
            let columnToUpdate = SQLite.Expression<String>(col)
            
            let updateQuery = users.filter(id == userID).update(columnToUpdate <- value)
            let _ = try Database.shared.run(updateQuery)
            
        } catch {
            print("Failed to update user \(userID): \(error)")
        }
    }
    
    //function to load the data for the profile page
    func loadData(userID: Int64,  symps: inout [String], triggs: inout [String], prevMeds: inout [String],  emergMeds: inout [String], SQ: inout String, SA: inout String, newSQ: inout String, bg: inout String, accent: inout String, newBG: inout String, newAccent: inout String,  theme: inout String, newTN: inout String) {
        //use helper functions to get all the data
        symps = Database.shared.getListVals(userId: userID, table: "symptoms", col: "symptom_name")
        symps=Database.deleteDups(list:symps)
        
        triggs = Database.shared.getListVals(userId: userID, table: "triggers", col: "trigger_name")
        triggs=Database.deleteDups(list:triggs)
        
        prevMeds = Database.shared.getListVals(userId: userID, table: "medications", col: "medication_name", filterCol: "medication_category", filterVal: "preventative")
        prevMeds=Database.deleteDups(list:prevMeds)
        
        emergMeds = Database.shared.getListVals(userId: userID, table: "medications", col: "medication_name", filterCol: "medication_category", filterVal: "emergency")
        emergMeds=Database.deleteDups(list:emergMeds)
        
        SQ = Database.shared.getSingleVal(userId: userID, col: "security_question") ?? "None set"
        SA = Database.shared.getSingleVal(userId: userID, col: "security_answer") ?? "None set"
        newSQ = SQ
        
        bg = Database.shared.getSingleVal(userId: userID, col: "background_color") ?? "None set"
        
        accent = Database.shared.getSingleVal(userId: userID, col: "accent_color") ?? "None set"
        
        newAccent = accent
        newBG = bg
        
        theme = Database.getThemeName(background: newBG, accent: newAccent)
        newTN = theme.contains("Custom") ? "Custom" : theme
    }
    
    //function for users adding a value to a category
    func insertItem(table: Table, userID: Int64, nameCol: SQLite.Expression<String>, name: String, startCol: SQLite.Expression<Date>, endCol: SQLite.Expression<Date?>, medCat: String? = nil) {
        
        var setters: [Setter] = [user_id <- userID, nameCol <- name, startCol <- Date(), endCol <- nil ]

        if let category = medCat {
            setters.append(Database.shared.medication_category <- category)
        }
        
        let insert = table.insert(setters)
        do {
            _ = try run(insert)
        } catch {
            print("Failed to insert \(name): \(error)")
        }
    }
    
    //function for users updating a value
    func updateItem(table: Table, userID: Int64, old: String, new: String, nameCol: SQLite.Expression<String>, medCat: String? = nil ) {
        var filter = table.filter(user_id == userID && nameCol == old)
        
        // If a category is provided, filter by it too
        if let category = medCat {
            filter = filter.filter(Database.shared.medication_category == category)
        }
        
        do {
            _ = try run(filter.update(nameCol <- new))
        } catch {
            print(" Failed to update \(old): \(error)")
        }
    }
    
    //function for users to stop an item
    func endItem( table: Table, userID: Int64, name: String, nameCol: SQLite.Expression<String>, endCol: SQLite.Expression<Date?>, medCat: String? = nil ) {
        var filter = table.filter(user_id == userID && nameCol == name)
        
        // If a category is provided, filter by it too
        if let category = medCat {
            filter = filter.filter(Database.shared.medication_category == category)
        }
        
        do {
            _ = try run(filter.update(endCol <- Date()))
            if let category = medCat {
                print("Ended \(name) (\(category)) at \(Date())")
            } else {
                print("Ended \(name) at \(Date())")
            }
        } catch {
            print("Failed to end \(name): \(error)")
        }
    }
    
    //delete list duplicates (sometimes needed csv variables)
    static func deleteDups(list: [String]) -> [String]{
        var tempList = [String]()
        for item in list{
            if !tempList.contains(item){
                tempList.append(item)
            }
        }
        return tempList
    }
    
    //get the user ID from the email address
    func userFromEmail(email: String) -> Int64? {
        do {
            let emailColumn = SQLite.Expression<String>("email")
            let targetColumn = SQLite.Expression<Int64>("user_id")
            if let row = try pluck(users.filter(emailColumn == email)) {
                return row[targetColumn]
            }
        } catch {
            print("SQL error in userFromEmail: \(error)")
        }
        return nil
    }
}

//
//  Account Functions.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/30/25.
//
//
//  Account Functions.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/30/25.
//
//
//  Account Functions.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/30/25.
//
//
//  Account Functions.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/30/25.
//
//
//  Account Functions.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/30/25.
//
//
//import Foundation
//import Supabase
//import CryptoKit
//
//extension Database {
//    
//    // Check if the email is present in the users table
//    static func emailExists(_ email: String) async -> Bool {
//        let cleanedEmail = Database.normalize(email)
//        do {
//            let users: [User] = try await Database.shared.client
//                .from("users")
//                .select()
//                .eq("email", value: cleanedEmail)
//                .execute()
//                .value
//            return !users.isEmpty
//        } catch {
//            print("Supabase error in emailExists: \(error)")
//            return false
//        }
//    }
//    
//    // Lowercase string and remove whitespace
//    static func normalize(_ s: String) -> String {
//        s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
//    }
//    
//    // Check if password meets complexity requirements
//    static func passwordValid(_ password: String) -> Bool {
//        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^A-Za-z\\d]).{8,}$"
//        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
//    }
//    
//    // Add user to the database (now uses the existing addUser function)
//    static func createUser(email: String, pass: String, SQ: String, SA: String, bg: String, accent: String, symps: String, prevMeds: String, emergMeds: String, triggs: String) async throws {
//        let normalizedEmail = Database.normalize(email)
//        let hashedPassword = Database.hashString(pass)
//        let hashedSecurityAnswer = Database.hashString(Database.normalize(SA))
//        
//        _ = try await Database.shared.addUser(
//            security_question_string: SQ,
//            security_answer_string: hashedSecurityAnswer,
//            emailAddress: normalizedEmail,
//            passwordHash: hashedPassword,
//            userBackground: bg,
//            userAccent: accent,
//            preventativeMedsCSV: prevMeds,
//            emergencyMedsCSV: emergMeds,
//            symptomsCSV: symps,
//            triggersCSV: triggs
//        )
//    }
//    
//    // Check if email and password combo is valid
//    func attemptLogin(email: String, password: String) async -> (userId: Int64?, error: String?) {
//        let normalizedEmail = Database.normalize(email)
//        let hashedPassword = Database.hashString(password)
//        
//        do {
//            let users: [User] = try await client
//                .from("users")
//                .select()
//                .eq("email", value: normalizedEmail)
//                .eq("password", value: hashedPassword)
//                .execute()
//                .value
//            
//            if let user = users.first {
//                return (user.userId, nil)
//            } else {
//                return (nil, "Invalid email or password")
//            }
//        } catch {
//            return (nil, "Supabase error in attemptLogin: \(error)")
//        }
//    }
//    
//    // Reset password function
//    static func resetPassword(email: String, password: String) async -> Bool {
//        do {
//            guard let userId = await Database.shared.userFromEmail(email: email) else {
//                print("Error in resetPassword: user not found")
//                return false
//            }
//            
//            let hashedPassword = Database.hashString(password)
//            
//            struct PasswordUpdate: Encodable {
//                let password: String
//            }
//            
//            let updateData = PasswordUpdate(password: hashedPassword)
//            
//            try await Database.shared.client
//                .from("users")
//                .update(updateData)
//                .eq("user_id", value: String(userId))
//                .execute()
//            
//            return true
//        } catch {
//            print("Supabase error in resetPassword: \(error)")
//            return false
//        }
//    }
//    
//    // Delete user function
//    func deleteUser(userID: Int64) async {
//        do {
//            try await client
//                .from("users")
//                .delete()
//                .eq("user_id", value: String(userID))
//                .execute()
//        } catch {
//            print("Failed to delete user \(userID): \(error)")
//        }
//    }
//    
//    // Function to update a value in the users table
//    func updateUser(userID: Int64, value: String, col: String) async {
//        do {
//            // Create encodable struct for update
//            struct GenericUpdate: Encodable {
//                private let data: [String: String]
//                
//                init(column: String, value: String) {
//                    self.data = [column: value]
//                }
//                
//                func encode(to encoder: Encoder) throws {
//                    var container = encoder.container(keyedBy: DynamicKey.self)
//                    for (key, value) in data {
//                        guard let dynamicKey = DynamicKey(stringValue: key) else { continue }
//                        try container.encode(value, forKey: dynamicKey)
//                    }
//                }
//                
//                struct DynamicKey: CodingKey {
//                    var stringValue: String
//                    var intValue: Int? { return nil }
//                    init?(stringValue: String) { self.stringValue = stringValue }
//                    init?(intValue: Int) { return nil }
//                }
//            }
//            
//            let updateData = GenericUpdate(column: col, value: value)
//            
//            try await client
//                .from("users")
//                .update(updateData)
//                .eq("user_id", value: String(userID))
//                .execute()
//        } catch {
//            print("Failed to update user \(userID): \(error)")
//        }
//    }
//    
//    // Function to load the data for the profile page
//    func loadData(userID: Int64, symps: inout [String], triggs: inout [String], prevMeds: inout [String], emergMeds: inout [String], SQ: inout String, SA: inout String, newSQ: inout String, bg: inout String, accent: inout String, newBG: inout String, newAccent: inout String, theme: inout String, newTN: inout String) async {
//        do {
//            symps = try await Database.shared.getListVals(userId: userID, table: "symptoms", col: "symptom_name")
//            symps = Database.deleteDups(list: symps)
//            
//            triggs = try await Database.shared.getListVals(userId: userID, table: "triggers", col: "trigger_name")
//            triggs = Database.deleteDups(list: triggs)
//            
//            prevMeds = try await Database.shared.getListVals(userId: userID, table: "medications", col: "medication_name", filterCol: "medication_category", filterVal: "preventative")
//            prevMeds = Database.deleteDups(list: prevMeds)
//            
//            emergMeds = try await Database.shared.getListVals(userId: userID, table: "medications", col: "medication_name", filterCol: "medication_category", filterVal: "emergency")
//            emergMeds = Database.deleteDups(list: emergMeds)
//            
//            SQ = try await Database.shared.getSingleVal(userId: userID, col: "security_question") ?? "None set"
//            SA = try await Database.shared.getSingleVal(userId: userID, col: "security_answer") ?? "None set"
//            newSQ = SQ
//            
//            bg = try await Database.shared.getSingleVal(userId: userID, col: "background_color") ?? "None set"
//            accent = try await Database.shared.getSingleVal(userId: userID, col: "accent_color") ?? "None set"
//            
//            newAccent = accent
//            newBG = bg
//            
//            theme = Database.getThemeName(background: newBG, accent: newAccent)
//            newTN = theme.contains("Custom") ? "Custom" : theme
//        } catch {
//            print("Error loading data: \(error)")
//        }
//    }
//    
//    // Function for users adding a value to a category
//    func insertItem(tableName: String, userID: Int64, name: String, medCat: String? = nil) async {
//        do {
//            switch tableName.lowercased() {
//            case "medications":
//                guard let category = medCat else { return }
//                let medicationData = MedicationInsert(
//                    user_id: userID,
//                    medication_category: category,
//                    medication_name: name,
//                    medication_start: ISO8601DateFormatter().string(from: Date())
//                )
//                try await client.from("medications").insert(medicationData).execute()
//                
//            case "symptoms":
//                let symptomData = SymptomInsert(
//                    user_id: userID,
//                    symptom_name: name,
//                    symptom_start: ISO8601DateFormatter().string(from: Date())
//                )
//                try await client.from("symptoms").insert(symptomData).execute()
//                
//            case "triggers":
//                let triggerData = TriggerInsert(
//                    user_id: userID,
//                    trigger_name: name,
//                    trigger_start: ISO8601DateFormatter().string(from: Date())
//                )
//                try await client.from("triggers").insert(triggerData).execute()
//                
//            default:
//                print("Unknown table: \(tableName)")
//            }
//        } catch {
//            print("Failed to insert \(name): \(error)")
//        }
//    }
//    
//    // Function for users updating a value
//    func updateItem(tableName: String, userID: Int64, old: String, new: String, medCat: String? = nil) async {
//        do {
//            let nameColumn: String
//            switch tableName.lowercased() {
//            case "medications":
//                nameColumn = "medication_name"
//            case "symptoms":
//                nameColumn = "symptom_name"
//            case "triggers":
//                nameColumn = "trigger_name"
//            default:
//                print("Unknown table: \(tableName)")
//                return
//            }
//            
//            // Create encodable struct for update
//            struct GenericUpdate: Encodable {
//                private let data: [String: String]
//                
//                init(column: String, value: String) {
//                    self.data = [column: value]
//                }
//                
//                func encode(to encoder: Encoder) throws {
//                    var container = encoder.container(keyedBy: DynamicKey.self)
//                    for (key, value) in data {
//                        guard let dynamicKey = DynamicKey(stringValue: key) else { continue }
//                        try container.encode(value, forKey: dynamicKey)
//                    }
//                }
//                
//                struct DynamicKey: CodingKey {
//                    var stringValue: String
//                    var intValue: Int? { return nil }
//                    init?(stringValue: String) { self.stringValue = stringValue }
//                    init?(intValue: Int) { return nil }
//                }
//            }
//            
//            let updateData = GenericUpdate(column: nameColumn, value: new)
//            
//            // Build query
//            var query = try client
//                .from(tableName)
//                .update(updateData)
//                .eq("user_id", value: String(userID))
//                .eq(nameColumn, value: old)
//            
//            if let category = medCat {
//                query = query.eq("medication_category", value: category)
//            }
//            
//            try await query.execute()
//        } catch {
//            print("Failed to update \(old): \(error)")
//        }
//    }
//    
//    // Function for users to stop an item
//    func endItem(tableName: String, userID: Int64, name: String, medCat: String? = nil) async {
//        do {
//            let nameColumn: String
//            let endColumn: String
//            
//            switch tableName.lowercased() {
//            case "medications":
//                nameColumn = "medication_name"
//                endColumn = "medication_end"
//            case "symptoms":
//                nameColumn = "symptom_name"
//                endColumn = "symptom_end"
//            case "triggers":
//                nameColumn = "trigger_name"
//                endColumn = "trigger_end"
//            default:
//                print("Unknown table: \(tableName)")
//                return
//            }
//            
//            let endDate = ISO8601DateFormatter().string(from: Date())
//            
//            // Create encodable struct for update
//            struct GenericUpdate: Encodable {
//                private let data: [String: String]
//                
//                init(column: String, value: String) {
//                    self.data = [column: value]
//                }
//                
//                func encode(to encoder: Encoder) throws {
//                    var container = encoder.container(keyedBy: DynamicKey.self)
//                    for (key, value) in data {
//                        guard let dynamicKey = DynamicKey(stringValue: key) else { continue }
//                        try container.encode(value, forKey: dynamicKey)
//                    }
//                }
//                
//                struct DynamicKey: CodingKey {
//                    var stringValue: String
//                    var intValue: Int? { return nil }
//                    init?(stringValue: String) { self.stringValue = stringValue }
//                    init?(intValue: Int) { return nil }
//                }
//            }
//            
//            let updateData = GenericUpdate(column: endColumn, value: endDate)
//            
//            var query = try client
//                .from(tableName)
//                .update(updateData)
//                .eq("user_id", value: String(userID))
//                .eq(nameColumn, value: name)
//            
//            if let category = medCat {
//                query = query.eq("medication_category", value: category)
//            }
//            
//            try await query.execute()
//            
//            if let category = medCat {
//                print("Ended \(name) (\(category)) at \(Date())")
//            } else {
//                print("Ended \(name) at \(Date())")
//            }
//        } catch {
//            print("Failed to end \(name): \(error)")
//        }
//    }
//    
//    // Delete list duplicates
//    static func deleteDups(list: [String]) -> [String] {
//        var tempList = [String]()
//        for item in list {
//            if !tempList.contains(item) {
//                tempList.append(item)
//            }
//        }
//        return tempList
//    }
//    
//    // Get the user ID from the email address
//    func userFromEmail(email: String) async -> Int64? {
//        do {
//            let users: [User] = try await client
//                .from("users")
//                .select()
//                .eq("email", value: email)
//                .execute()
//                .value
//            return users.first?.userId
//        } catch {
//            print("Supabase error in userFromEmail: \(error)")
//            return nil
//        }
//    }
//}
