//
//  Database.swift
//  learning_xcode
//
//  Created by Abigail Barnhardt on 8/24/25.

import Foundation
import Supabase

enum DatabaseError: Error {
    case connectionFailed
    case insertFailed(String)
    case queryFailed(String)
    case userNotFound
}

class Database {
    static let shared = Database()
    internal let client: SupabaseClient
    
    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: SupabaseConfig.supabaseURL)!,
            supabaseKey: SupabaseConfig.supabaseAnonKey
        )
    }
    
    // MARK: - Insert Structs
    
    struct UserInsert: Encodable {
        let email: String
        let password: String
        let security_question: String
        let security_answer: String
        let background_color: String
        let accent_color: String
    }
    
    struct MedicationInsert: Encodable {
        let user_id: Int64
        let medication_category: String
        let medication_name: String
        let medication_start: String
        let medication_end: String?
        
        init(user_id: Int64, medication_category: String, medication_name: String, medication_start: String, medication_end: String? = nil) {
            self.user_id = user_id
            self.medication_category = medication_category
            self.medication_name = medication_name
            self.medication_start = medication_start
            self.medication_end = medication_end
        }
    }
    
    struct SymptomInsert: Encodable {
        let user_id: Int64
        let symptom_name: String
        let symptom_start: String
        let symptom_end: String?
        
        init(user_id: Int64, symptom_name: String, symptom_start: String, symptom_end: String? = nil) {
            self.user_id = user_id
            self.symptom_name = symptom_name
            self.symptom_start = symptom_start
            self.symptom_end = symptom_end
        }
    }
    
    struct TriggerInsert: Encodable {
        let user_id: Int64
        let trigger_name: String
        let trigger_start: String
        let trigger_end: String?
        
        init(user_id: Int64, trigger_name: String, trigger_start: String, trigger_end: String? = nil) {
            self.user_id = user_id
            self.trigger_name = trigger_name
            self.trigger_start = trigger_start
            self.trigger_end = trigger_end
        }
    }
    
    func addUser(
        security_question_string: String,
        security_answer_string: String,
        emailAddress: String,
        passwordHash: String,
        userBackground: String,
        userAccent: String,
        preventativeMedsCSV: String? = nil,
        emergencyMedsCSV: String? = nil,
        symptomsCSV: String? = nil,
        triggersCSV: String? = nil
    ) async throws -> Int64 {
        
        let userData = UserInsert(
            email: emailAddress,
            password: passwordHash,
            security_question: security_question_string,
            security_answer: security_answer_string,
            background_color: userBackground,
            accent_color: userAccent
        )
        
        // Insert user
        let insertedUser: User
        do {
            insertedUser = try await client
                .from("Users")
                .insert(userData)
                .select()
                .single()
                .execute()
                .value
        } catch let error as PostgrestError {
            print("Failed to insert user:")
            print("- Message: \(error.message)")
            print("- Code: \(error.code ?? "no code")")
            print("- Details: \(error.detail ?? "no details")")
            print("- Hint: \(error.hint ?? "no hint")")
            throw DatabaseError.insertFailed("Failed to create user account: \(error.message)")
        } catch {
            print("Unexpected error inserting user: \(error)")
            throw DatabaseError.insertFailed("Failed to create user account")
        }
        
        let userId = insertedUser.userId
        print("User created successfully with ID: \(userId)")
        
        // Insert preventative medications
        if let preventative = preventativeMedsCSV, !preventative.isEmpty {
            let medsArray = preventative.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            for med in medsArray where !med.isEmpty {
                let medicationData = MedicationInsert(
                    user_id: userId,
                    medication_category: "preventative",
                    medication_name: med,
                    medication_start: ISO8601DateFormatter().string(from: Date())
                )
                do {
                    try await client.from("Medications").insert(medicationData).execute()
                } catch let error as PostgrestError {
                    print("Failed to insert preventative medication '\(med)':")
                    print("- Message: \(error.message)")
                    print("- Code: \(error.code ?? "no code")")
                    // Continue with other medications instead of failing completely
                } catch {
                    print("Unexpected error inserting preventative medication '\(med)': \(error)")
                }
            }
        }
        
        // Insert emergency medications
        if let emergency = emergencyMedsCSV, !emergency.isEmpty {
            let medsArray = emergency.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            for med in medsArray where !med.isEmpty {
                let medicationData = MedicationInsert(
                    user_id: userId,
                    medication_category: "emergency",
                    medication_name: med,
                    medication_start: ISO8601DateFormatter().string(from: Date())
                )
                do {
                    try await client.from("Medications").insert(medicationData).execute()
                } catch let error as PostgrestError {
                    print("Failed to insert emergency medication '\(med)':")
                    print("- Message: \(error.message)")
                    print("- Code: \(error.code ?? "no code")")
                    // Continue with other medications instead of failing completely
                } catch {
                    print("Unexpected error inserting emergency medication '\(med)': \(error)")
                }
            }
        }
        
        // Insert triggers
        if let triggersList = triggersCSV, !triggersList.isEmpty {
            let array = triggersList.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            for trig in array where !trig.isEmpty {
                let triggerData = TriggerInsert(
                    user_id: userId,
                    trigger_name: trig,
                    trigger_start: ISO8601DateFormatter().string(from: Date())
                )
                do {
                    try await client.from("Triggers").insert(triggerData).execute()
                } catch let error as PostgrestError {
                    print("Failed to insert trigger '\(trig)':")
                    print("- Message: \(error.message)")
                    print("- Code: \(error.code ?? "no code")")
                    // Continue with other triggers instead of failing completely
                } catch {
                    print("Unexpected error inserting trigger '\(trig)': \(error)")
                }
            }
        }
        
        // Insert symptoms
        if let symptomsList = symptomsCSV, !symptomsList.isEmpty {
            let array = symptomsList.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            for symptom in array where !symptom.isEmpty {
                let symptomData = SymptomInsert(
                    user_id: userId,
                    symptom_name: symptom,
                    symptom_start: ISO8601DateFormatter().string(from: Date())
                )
                do {
                    try await client.from("Symptoms").insert(symptomData).execute()
                } catch let error as PostgrestError {
                    print("Failed to insert symptom '\(symptom)':")
                    print("- Message: \(error.message)")
                    print("- Code: \(error.code ?? "no code")")
                    // Continue with other symptoms instead of failing completely
                } catch {
                    print("Unexpected error inserting symptom '\(symptom)': \(error)")
                }
            }
        }
        
        print("User setup completed for user ID: \(userId)")
        return userId
    }
    // MARK: - Model Structs
    
    struct User: Codable {
        let userId: Int64
        let email: String
        let password: String
        let securityQuestion: String
        let securityAnswer: String
        let backgroundColor: String
        let accentColor: String
        
        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case email
            case password
            case securityQuestion = "security_question"
            case securityAnswer = "security_answer"
            case backgroundColor = "background_color"
            case accentColor = "accent_color"
        }
    }
    
    struct Symptom: Codable {
        let symptomId: Int64
        let userId: Int64
        let symptomName: String
        let symptomStart: String
        let symptomEnd: String?
        
        enum CodingKeys: String, CodingKey {
            case symptomId = "symptom_id"
            case userId = "user_id"
            case symptomName = "symptom_name"
            case symptomStart = "symptom_start"
            case symptomEnd = "symptom_end"
        }
    }
    
    struct Medication: Codable {
        let medicationId: Int64
        let userId: Int64
        let medicationCategory: String
        let medicationName: String
        let medicationStart: String
        let medicationEnd: String?
        
        enum CodingKeys: String, CodingKey {
            case medicationId = "medication_id"
            case userId = "user_id"
            case medicationCategory = "medication_category"
            case medicationName = "medication_name"
            case medicationStart = "medication_start"
            case medicationEnd = "medication_end"
        }
    }
    
    struct Trigger: Codable {
        let triggerId: Int64
        let userId: Int64
        let triggerName: String
        let triggerStart: String
        let triggerEnd: String?
        
        enum CodingKeys: String, CodingKey {
            case triggerId = "trigger_id"
            case userId = "user_id"
            case triggerName = "trigger_name"
            case triggerStart = "trigger_start"
            case triggerEnd = "trigger_end"
        }
    }
}
