//
//  Analytics Computed Vars.swift
//  Trendy Headaches Supabase
//
//  Created by Abigail Barnhardt on 11/15/25.
//

import Foundation

extension AnalyticsView{
    //build the labels for each selected metric
    var compareLables: (String, String){
        var labelOne: String = ""
        var labelTwo: String = ""
        
        if selectedMetric == "Dates"{
            let range1StartString = "\(DateFormatter.localizedString(from: range1Start, dateStyle: .short, timeStyle: .none))"
            let range1EndString = "\(DateFormatter.localizedString(from: range1End, dateStyle: .short, timeStyle: .none))"
            labelOne = "\(range1StartString)-\(range1EndString)"
            
            let range2StartString = "\(DateFormatter.localizedString(from: range2Start, dateStyle: .short, timeStyle: .none))"
            let range2EndString = "\(DateFormatter.localizedString(from: range2End, dateStyle: .short, timeStyle: .none))"
            labelTwo = "\(range2StartString)-\(range2EndString)"
        }
        else if selectedMetric == "Symptom"{
            labelOne = selectedSymptom1 ?? ""
            labelTwo = selectedSymptom2 ?? ""
        }
        else if selectedMetric == "Preventative Treatment"{
            labelOne = selectedMed1 ?? ""
            labelTwo = selectedMed2 ?? ""
        }
        return (labelOne, labelTwo)
    }
    
    //filter logs based date, symptom, and log type
    var filteredLogs: [UnifiedLog] {
        
        let filtered = logs.filter { log in
            
            let withinDateRange = log.date >= startDate && log.date <= endDate
            let symptomMatch = selectedSymptoms.contains(log.symptom_name ?? "")
            let typeMatch = selectedTypes.contains(log.log_type)

            return symptomMatch && withinDateRange && typeMatch
        }
        return filtered
    }
    
    var filteredCompareLogs: ([UnifiedLog], [UnifiedLog]) {
        let filtered1 = filterCompareLogs(logs: logs, medData: medData, rangeStart: range1Start, rangeEnd: range1End, selectedSymptom: selectedSymptom1, selectedMed: selectedMed1, startDate: startDate, endDate: endDate, selectedSymptoms: selectedSymptoms, selectedTypes: selectedTypes)
        
        let filtered2 = filterCompareLogs(logs: logs, medData: medData, rangeStart: range2Start, rangeEnd: range2End,  selectedSymptom: selectedSymptom2, selectedMed: selectedMed2,  startDate: startDate, endDate: endDate, selectedSymptoms: selectedSymptoms, selectedTypes: selectedTypes)
        
        return (filtered1, filtered2)
    }
}
