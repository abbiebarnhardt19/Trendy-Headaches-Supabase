//
//  Analytics View Functions.swift
//  Trendy Headaches Supabase
//
//  Created by Abigail Barnhardt on 11/15/25.
//

import Foundation

extension AnalyticsView {

    //assign values from preloaded data
    func setupAnalyticsView() async {

        // Update everything on the main thread
        await MainActor.run {

            //colors
            bg = preloadManager.bg
            accent = preloadManager.accent

            //logs
            logs = preloadManager.analyticsLogs
            
            //filter options
            medData = preloadManager.medData
            symptomOptions = preloadManager.analyticsSymptoms
            selectedSymptoms = preloadManager.analyticsSymptoms
            triggerOptions = preloadManager.analyticsTriggers
            prevMedOptions = preloadManager.analyticsPrevMeds
            startDate = preloadManager.analyticsLogs.map { $0.date }.min() ?? Date()
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
