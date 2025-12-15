//
//  PreLoadManager.swift
//  Trendy Headaches Supabase
//
//  Created by Abigail Barnhardt on 11/16/25.
//
import SwiftUI

class PreloadManager: ObservableObject {

    // Colors
    @Published var bg = "#000000"
    @Published var accent = "#FFFFFF"

    // Logs + Filters
    @Published var allLogs: [UnifiedLog] = []
    @Published var startDate = Date()
    @Published var endDate = Date()
    @Published var stringStartDate = ""
    @Published var stringEndDate = ""
    @Published var filterSymptoms: [String] = []
    @Published var symptomAndSideEffects: [String] = []

    //  Log Setup
    @Published var sympOptions: [String] = []
    @Published var triggOptions: [String] = []
    @Published var medOptions: [String] = []
    @Published var emergMedOptions: [String] = []
    @Published var todayString = ""

    // Profile
    @Published var symps: [String] = []
    @Published var triggs: [String] = []
    @Published var prevMeds: [String] = []
    @Published var emergMeds: [String] = []
    @Published var sQ = ""
    @Published var sA = ""
    @Published var themeName = ""

    // Analytics
    @Published var analyticsLogs: [UnifiedLog] = []
    @Published var medData: [Medication] = []
    @Published var analyticsSymptoms: [String] = []
    @Published var analyticsTriggers: [String] = []
    @Published var analyticsPrevMeds: [String] = []

    // change when fetch completed
    @Published var isFinished = false

    //function to get all needed values at once
    func preloadAll(userID: Int64) async {
        let existingUserIDs = await Database.shared.getAllUserIDs()
        
        if existingUserIDs.contains(userID){
            do {
               
                // create tasks
                async let colorsTask = Database.shared.getColors(userID: userID)
                async let logsTask = Database.shared.getLogList(userID: userID)
                async let profileTask = Database.shared.loadData(userID: userID)
                async let analyticsTask = fetchAnalyticsData(userID: Int(userID))
                
                async let sympTask = Database.shared.getListVals(userId: userID, table: "Symptoms", col: "symptom_name")
                async let sideEffectTask = Database.shared.getListVals(userId: userID, table: "Side_Effects", col: "side_effect_name")
                async let triggTask = Database.shared.getListVals(userId: userID, table: "Triggers", col: "trigger_name")
                async let medTask = Database.shared.getListVals(userId: userID, table: "Medications", col: "medication_name")
                async let emergMedTask = Database.shared.getListVals(userId: userID, table: "Medications", col: "medication_name", filterVal: "emergency")
                
                // get query results
                let (bgColor, accentColor) = await colorsTask
                let allLogsResult = (try? await logsTask) ?? []
                let profileResult = await profileTask
                let analyticsResult = try? await analyticsTask
                let sympList = (try? await sympTask) ?? []
                let sideEffectList = (try? await sideEffectTask) ?? []
                let triggList = Database.deleteDups(list: (try? await triggTask) ?? [])
                let medList = (try? await medTask) ?? []
                let emergMedList = (try? await emergMedTask) ?? []
                
                // combined logic
                let combinedSymptoms = Array(Set(sympList + sideEffectList)).sorted()
                
                let logSymptoms = Array(Set(allLogsResult.compactMap { $0.symptom_name }))
                    .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
                
                // ---------------- set the values ----------------
                await MainActor.run {
                    bg = bgColor
                    accent = accentColor
                    allLogs = allLogsResult
                    sympOptions = sympList
                    triggOptions = triggList
                    medOptions = medList
                    emergMedOptions = emergMedList
                    symptomAndSideEffects = combinedSymptoms
                    filterSymptoms = logSymptoms
                    
                    // Dates
                    if let earliest = allLogsResult.map({ $0.date }).min() {
                        startDate = earliest
                        stringStartDate = DateFormatter.localizedString(from: earliest, dateStyle: .short, timeStyle: .none)
                    }
                    endDate = Date()
                    stringEndDate = DateFormatter.localizedString(from: endDate, dateStyle: .short, timeStyle: .none)
                    todayString = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
                    
                    // Profile
                    if let profile = profileResult {
                        symps = profile.symps
                        triggs = profile.triggs
                        prevMeds = profile.prevMeds
                        emergMeds = profile.emergMeds
                        sQ = profile.SQ
                        sA = profile.SA
                        themeName = profile.theme
                    }
                    
                    
                    // Analytics
                    if let result = analyticsResult {
                        analyticsLogs = result.0
                        medData = result.1
                        analyticsSymptoms = result.2
                        analyticsTriggers = result.3
                        analyticsPrevMeds = result.4
                        if let analyticDate = result.5 { startDate = analyticDate }
                    }
                    //indicate loading is done so pages can now access values
                    isFinished = true
                }

                
            } catch {
                if (error as NSError).code == -999 {
                    return
                }
                print("Error during preloadAll:", error)
            }
        }
        else{
            print("Tried to run preload manager with \(userID)")
        }
    }
    
    //function to load just the logs
//    func preloadLogs(userID: Int64) async {
//        let startTime = Date()
//        let existingUserIDs = await Database.shared.getAllUserIDs()
//        
//        if existingUserIDs.contains(userID){
//            do {
//                async let logsTask = Database.shared.getLogList(userID: userID)
//
//                let allLogsResult = (try? await logsTask) ?? []
//                
//                // ---------------- set the values ----------------
//                await MainActor.run {
//                    
//                    allLogs = allLogsResult
//
//                    //indicate loading is done so pages can now access values
//                    isFinished = true
//                    
//                    let elapsed = Date().timeIntervalSince(startTime)
//                    print("preload Logs took \(String(format: "%.3f", elapsed)) seconds")
//                }
//                
//            } catch {
//                if (error as NSError).code == -999 {
//                    return
//                }
//                print("Error during preloadLogs:", error)
//            }
//        }
//        else{
//            print("Tried to run preload manager with \(userID)")
//        }
//    }
    func preloadLogs(userID: Int64) async {

        do {
            let logs = try await Database.shared.getLogList(userID: userID)

            await MainActor.run {
                allLogs = logs
                isFinished = true
            }

        } catch {
            if (error as NSError).code == -999 { return }
            print("Error during preloadLogs:", error)
        }
    }

    
}
