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
        client = SupabaseClient(supabaseURL: URL(string: SupabaseConfig.supabaseURL)!,  supabaseKey: SupabaseConfig.supabaseAnonKey)
    }
    
    func addUser(security_question_string: String, security_answer_string: String, emailAddress: String, passwordHash: String, userBackground: String, userAccent: String, preventativeMedsCSV: String? = nil, emergencyMedsCSV: String? = nil, symptomsCSV: String? = nil, triggersCSV: String? = nil) async throws -> Int64 {
        
        let userData = UserInsert(email: emailAddress, password: passwordHash, security_question: security_question_string, security_answer: security_answer_string, background_color: userBackground, accent_color: userAccent)
        
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
                let medicationData = MedicationInsert(user_id: userId, medication_category: "preventative", medication_name: med, medication_start: ISO8601DateFormatter().string(from: Date()), medication_end: nil)
                do {
                    try await client.from("Medications").insert(medicationData).execute()
                } catch let error as PostgrestError {
                    print("Failed to insert preventative medication '\(med)':")
                    print("- Message: \(error.message)")
                    print("- Code: \(error.code ?? "no code")")
                } catch {
                    print("Unexpected error inserting preventative medication '\(med)': \(error)")
                }
            }
        }
        
        // Insert emergency medications
        if let emergency = emergencyMedsCSV, !emergency.isEmpty {
            let medsArray = emergency.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            for med in medsArray where !med.isEmpty {
                let medicationData = MedicationInsert(user_id: userId, medication_category: "emergency", medication_name: med, medication_start: ISO8601DateFormatter().string(from: Date()), medication_end: nil)
                do {
                    try await client.from("Medications").insert(medicationData).execute()
                } catch let error as PostgrestError {
                    print("Failed to insert emergency medication '\(med)':")
                    print("- Message: \(error.message)")
                    print("- Code: \(error.code ?? "no code")")
                } catch {
                    print("Unexpected error inserting emergency medication '\(med)': \(error)")
                }
            }
        }
        
        // Insert triggers
        if let triggersList = triggersCSV, !triggersList.isEmpty {
            let array = triggersList.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            for trig in array where !trig.isEmpty {
                let triggerData = TriggerInsert(user_id: userId, trigger_name: trig,
                                                trigger_start: ISO8601DateFormatter().string(from: Date()), trigger_end: nil)
                do {
                    try await client.from("Triggers").insert(triggerData).execute()
                } catch let error as PostgrestError {
                    print("Failed to insert trigger '\(trig)':")
                    print("- Message: \(error.message)")
                    print("- Code: \(error.code ?? "no code")")
                } catch {
                    print("Unexpected error inserting trigger '\(trig)': \(error)")
                }
            }
        }
        
        // Insert symptoms
        if let symptomsList = symptomsCSV, !symptomsList.isEmpty {
            let array = symptomsList.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            for symptom in array where !symptom.isEmpty {
                let symptomData = SymptomInsert( user_id: userId, symptom_name: symptom, symptom_start: ISO8601DateFormatter().string(from: Date()), symptom_end: nil)
                do {
                    try await client.from("Symptoms").insert(symptomData).execute()
                } catch let error as PostgrestError {
                    print("Failed to insert symptom '\(symptom)':")
                    print("- Message: \(error.message)")
                    print("- Code: \(error.code ?? "no code")")
                } catch {
                    print("Unexpected error inserting symptom '\(symptom)': \(error)")
                }
            }
        }
        return userId
    }
}
