//
//  Analytics View Functions.swift
//  Trendy Headaches Supabase
//
//  Created by Abigail Barnhardt on 11/15/25.
//

import Foundation

extension AnalyticsView {
    func fetchColors() async {
            let colors = await Database.shared.getColors(userID: userID)
            bg = colors.0
            accent = colors.1
    }
    
    func getAnalyticsData() async {
        do {
            let result = try await fetchAnalyticsData(userID: Int(userID))
            logs = result.0
            medData = result.1
            symptomOptions = result.2
            selectedSymptoms = result.2
            triggerOptions = result.3
            prevMedOptions = result.4
            startDate = result.5 ?? Date()
        } catch {
            print("Error fetching all data:", error)
        }
    }
    
    func filterCompareLogs(
        logs: [UnifiedLog],
        medData: [Medication],
        rangeStart: Date,
        rangeEnd: Date,
        selectedSymptom: String?,
        selectedMed: String?,
        startDate: Date,
        endDate: Date,
        selectedSymptoms: [String],
        selectedTypes: [String]
    ) -> [UnifiedLog] {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return logs.filter { log in
            let logDate = log.date
            
            // global filters First
            let withinMainDateRange = logDate >= startDate && logDate <= endDate
            let symptomMatch = selectedSymptoms.contains(log.symptom_name ?? "")
            let typeMatch = selectedTypes.contains(log.log_type)
            guard withinMainDateRange && symptomMatch && typeMatch else { return false }
            
            //compare-specific filters
            // custom date range
            if rangeEnd.timeIntervalSince(rangeStart) > 1 {
                return logDate >= rangeStart && logDate <= rangeEnd
            }
            
            // symptom
            if let symptom = selectedSymptom, !symptom.isEmpty {
                let logSymptom = log.symptom_name?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
                return logSymptom == symptom.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            }
            
            // medication
            if let medName = selectedMed, !medName.isEmpty {
                guard let med = medData.first(where: {
                    $0.medicationName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                    == medName.lowercased()
                }) else { return false }
                
                guard let startMed = formatter.date(from: med.medicationStart) else { return false }
                let endMed = med.medicationEnd.flatMap { formatter.date(from: $0) }
                
                if let end = endMed {
                    return logDate >= startMed && logDate <= end
                } else {
                    return logDate >= startMed
                }
            }
            
            // Default (if no compare condition applies)
            return false
        }
    }
}
