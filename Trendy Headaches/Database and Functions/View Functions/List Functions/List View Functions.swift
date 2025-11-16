//
//  List View Functions.swift
//  Trendy Headaches Supabase
//
//  Created by Abigail Barnhardt on 11/15/25.
//

import Foundation
import SwiftUI

extension ListView {
    func filterLogs() {
        
        logList = allLogs.filter { log in
            guard logTypeFilter.contains(log.log_type) else {
                return false
            }
            if log.date < startDate {
                return false
            }
            if log.date > endDate {
                return false
            }
            
            if log.severity < sevStart {
                return false
            }
            if log.severity > sevEnd {
                return false
            }
            
            guard selectedSymps.contains(log.symptom_name ?? "") else {
                return false
            }
            return true
        }
    }
    
    //assign values from preloaded data
    func setupListView() async {
        // First, run the preload-based assignments on the main thread
        await MainActor.run {
            // Colors
            bg = preloadManager.bg
            accent = preloadManager.accent
            
            // Logs
            allLogs = preloadManager.allLogs
            logList = allLogs
            
            // Start and end dates
            startDate = preloadManager.startDate
            stringStartDate = preloadManager.stringStartDate
            endDate = preloadManager.endDate
            stringEndDate = preloadManager.stringEndDate
            
            // Initial symptom options from preloaded logs
            sympOptions = preloadManager.symptomAndSideEffects
            selectedSymps = sympOptions
        }
    }
}

