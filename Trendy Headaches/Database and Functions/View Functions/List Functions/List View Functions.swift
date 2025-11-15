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
    
    func fetchLogsAndSetupFilters() async {
        do {
            allLogs = try await Database.shared.getLogList(userID: userID)
            logList = allLogs
            
            // Set start and end dates
            if let earliest = allLogs.map({ $0.date }).min() {
                startDate = earliest
                stringStartDate = DateFormatter.localizedString(from: earliest, dateStyle: .short, timeStyle: .none)
            }
            endDate = Date()
            stringEndDate = DateFormatter.localizedString(from: endDate, dateStyle: .short, timeStyle: .none)
            
            // Set symptom options
            sympOptions = Array(Set(allLogs.compactMap { $0.symptom_name }))
                .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
            selectedSymps = sympOptions
        } catch {
            if (error as NSError).code != NSURLErrorCancelled {
                print("Error fetching logs: \(error)")
            }
        }
    }

    func fetchColors() async {
            let colors = await Database.shared.getColors(userID: userID)
            bg = colors.0
            accent = colors.1
            hasLoaded = true
    }

}

