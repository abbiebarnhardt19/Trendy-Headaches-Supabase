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


