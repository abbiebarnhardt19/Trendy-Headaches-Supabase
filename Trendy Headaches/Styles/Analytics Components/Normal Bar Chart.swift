//
//  Normal Bar Chart.swift
//  Trendy Headaches Supabase
//
//  Created by Abigail Barnhardt on 10/30/25.
//
//
import SwiftUI

struct AnalyticsBarChart: View {
    var logs: [UnifiedLog]
    var categoryColumn: String
    var groupColumn: Any // Changed to Any to accept different KeyPath types
    var chartName: String
    var accent: String
    var bg: String

    @State private var showVisual = false
    let width = UIScreen.main.bounds.width - 50
    
    //get the dats that determines bar size
    var frequencyData: [(key: String, count: Int)] {
        // Filter by category if provided
        let category = categoryColumn.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // Special case for med effectiveness, since calculating a percent and getting a count
        if category == "med_worked" {
            // Only include logs that have a non-nil med_worked value
            let validLogs = logs.filter { $0.med_worked != nil }
            
            // Group by medication name
            let grouped = Dictionary(grouping: validLogs) { log in
                log.medication_name ?? "Unknown"
            }
            
            // Calculate percent effectiveness per medication
            var results: [(key: String, count: Int)] = []
            for (medName, medLogs) in grouped {
                
                let total = medLogs.count
                let workedCount = medLogs.filter { $0.med_worked == true }.count
                let percentage = Int(Double(workedCount) / Double(total) * 100)
                
                results.append((key: medName, count: percentage))
            }
            
            // Sort descending by percent
            return results.sorted { $0.count > $1.count }
        }
        
        //section for getting frequency count
        var values: [String] = []
        
        //cases for a single string vs a list of strings
        if let stringKeyPath = groupColumn as? KeyPath<UnifiedLog, String?> {
            values = logs.flatMap { log -> [String] in
                guard let value = log[keyPath: stringKeyPath], !value.isEmpty else { return [] }
                return value.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
            }
        } else if let arrayKeyPath = groupColumn as? KeyPath<UnifiedLog, [String]?> {
            values = logs.flatMap { log -> [String] in
                guard let array = log[keyPath: arrayKeyPath], !array.isEmpty else { return [] }
                return array.filter { !$0.isEmpty }
            }
        }
        
        //get the counts for each value
        let counts = Dictionary(values.map { ($0, 1) }, uniquingKeysWith: +)
        return counts.map { ($0.key, $0.value) }.sorted { $0.count > $1.count }
    }
    
    //get the width of the longest key so all are set the same
    var longestKeyWidth: CGFloat {
        let longestKey = frequencyData.max(by: { $0.key.count < $1.key.count })?.key ?? ""
        let font = UIFont.systemFont(ofSize: 12)
        let width = (longestKey as NSString).size(withAttributes: [.font: font]).width
        return width + 10
    }

    var body: some View {
        if showVisual {
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(hex: accent))
                    .frame(width: width)
                    .padding(.horizontal, 10)

                VStack(alignment: .leading, spacing: 12) {
                    // Header
                    HStack {
                        //chart title
                        let font = UIFont.systemFont(ofSize: 19, weight: .bold)
                        CustomText(text: chartName, color: bg, width: chartName.width(usingFont: font) + 15, textAlign: .leading, bold: true, textSize: 19)
                            .padding(.leading, 35)

                        Spacer()

                        //hide the chart
                        HideButton(accent: accent, bg: bg, show: $showVisual)
                        .padding(.trailing, 25)
                    }

                    if !frequencyData.isEmpty {
                        VStack {
                            ForEach(frequencyData, id: \.key) { item in
                                HStack(spacing: 0) {
                                    // bar label
                                    let font = UIFont.systemFont(ofSize: 12)
                                    CustomText(text: item.key, color: bg, width: item.key.width(usingFont: font) + 10, textSize: 12)
                                        .frame(width: longestKeyWidth, alignment: .trailing)
                                        .padding(.leading, 5)
                                        .padding(.bottom, 5)

                                    // Bar column
                                    GeometryReader { geo in
                                        let maxCount = frequencyData.first?.count ?? 1
                                        let ratio = CGFloat(item.count) / CGFloat(maxCount)
                                        let barWidth = geo.size.width * ratio - 5

                                        ZStack(alignment: .leading) {
                                            //bar with full width, hidden
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(hex: accent))
                                                .frame(height: 25)

                                            //actual bar
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(hex: bg))
                                                .frame(width: barWidth, height: 25)
                                            
                                            //text in the bar, figure out if it needs % or log, and if log needs an s
                                            CustomText(text: categoryColumn.lowercased() == "med_worked"  ? "\(item.count)% " : "\(item.count) Log\(item.count == 1 ? "" : "s")", color: accent, width: barWidth,  textAlign: .center,  textSize: 12)
                                                .clipped()
                                        }
                                    }
                                    .frame(height: 30)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    //no data warning
                    else{
                        CustomText(text: "No Data", color: bg, textAlign: .center, bold: true)
                            .padding(.bottom, 10)
                    }
                }
                .padding(.bottom, 10)
                .padding(.top, 5)
            }
            .frame(width: width)
            .padding(.bottom, 10)
        } else {
            //show chart button
            HiddenChart(bg: bg, accent: accent, chart: chartName, hideChart: $showVisual)
        }
    }
}
