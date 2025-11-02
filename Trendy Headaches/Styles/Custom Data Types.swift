//
//  Custom Data Types.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/2/25.
//

import SwiftUI

struct UnifiedLog {
    // Common fields
    var log_id: Int64
    var user_id: Int64
    var log_type: String          // "Symptom" or "SideEffect"
    var date: Date
    var severity: Int64
    var submit_time: Date
    
    // Symptom-specific fields
    var symptom_id: Int64?
    var symptom_name: String?
    var onset_time: String?
    var med_taken: Bool?
    var medication_id: Int64?
    var medication_name: String?
    var med_worked: Bool?
    var symptom_description: String?
    var notes: String?
    var trigger_ids: [Int64]?
    var trigger_names: [String]?

    var side_effect_med: String?
    
    // Computed ID
    var id: String { "\(log_type)_\(log_id)" }
}

// Struct for bullet list items
struct SymptomCount: Identifiable {
    let id = UUID()
    let symptom: String
    let count: Int
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
    let endReason: String?
    
    enum CodingKeys: String, CodingKey {
        case medicationId = "medication_id"
        case userId = "user_id"
        case medicationCategory = "medication_category"
        case medicationName = "medication_name"
        case medicationStart = "medication_start"
        case medicationEnd = "medication_end"
        case endReason = "end_reason"
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

// MARK: - Insert Structs
struct UserInsert: Encodable {
    let email, password, security_question, security_answer, background_color, accent_color: String
}

struct MedicationInsert: Encodable {
    let user_id: Int64
    let medication_category, medication_name, medication_start: String
    let medication_end: String?
    let end_reason: String?
}

struct SymptomInsert: Encodable {
    let user_id: Int64
    let symptom_name, symptom_start: String
    let symptom_end: String?
}

struct TriggerInsert: Encodable {
    let user_id: Int64
    let trigger_name, trigger_start: String
    let trigger_end: String?
}

struct Log: Codable {
    let logId: Int64
    let userId: Int64
    let date: String
    let onsetTime: String?
    let severityLevel: Int64
    let symptomId: Int64
    let medTaken: Bool
    let logMedicationId: Int64?
    let medWorked: Bool?
    let symptomDescription: String
    let notes: String
    let submitTime: String
    
    enum CodingKeys: String, CodingKey {
        case logId = "log_id"
        case userId = "user_id"
        case date
        case onsetTime = "onset_time"
        case severityLevel = "severity_level"
        case symptomId = "symptom_id"
        case medTaken = "med_taken"
        case logMedicationId = "log_medication_id"
        case medWorked = "med_worked"
        case symptomDescription = "symptom_description"
        case notes
        case submitTime = "submit_time"
    }
}

struct LogTrigger: Codable {
    let lt_log_id: Int64
    let lt_trigger_id: Int64
    
    enum CodingKeys: String, CodingKey {
        case lt_log_id = "lt_log_id"
        case lt_trigger_id = "lt_trigger_id"
    }
}

struct SideEffect: Codable {
    let sideEffectId: Int64
    let userId: Int64
    let medicationId: Int64?
    let sideEffectName: String
    let sideEffectSeverity: Int64
    let date: String
    let sideEffectSubmitTime: String
    
    enum CodingKeys: String, CodingKey {
        case sideEffectId = "side_effect_id"
        case userId = "user_id"
        case medicationId = "medication_id"
        case sideEffectName = "side_effect_name"
        case sideEffectSeverity = "side_effect_severity"
        case date = "side_effect_date"
        case sideEffectSubmitTime = "side_effect_submit_time"
    }
}

struct LogInsert: Encodable {
    let user_id: Int64
    let date: String
    let onset_time: String?
    let severity_level: Int64
    let symptom_id: Int64
    let med_taken: Bool
    let log_medication_id: Int64?
    let med_worked: Bool?
    let symptom_description: String
    let notes: String
    let submit_time: String
}
