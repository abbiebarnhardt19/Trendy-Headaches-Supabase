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
    
    var frequencyData: [(key: String, count: Int)] {
        // Filter by category if provided
        let filteredLogs: [UnifiedLog] = {
            let category = categoryColumn.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if category == "all" || category.isEmpty {
                return logs
            } else {
                return logs.filter { ($0.log_type).lowercased() == category }
            }
        }()
        
        // Extract the values dynamically using the groupBy keyPath
        var values: [String] = []
        
        if let stringKeyPath = groupColumn as? KeyPath<UnifiedLog, String?> {
            // Handle String? KeyPath - filter out nil and empty strings, split by comma
            values = filteredLogs.flatMap { log -> [String] in
                guard let value = log[keyPath: stringKeyPath], !value.isEmpty else { return [] }
                // Split by comma and trim whitespace
                return value.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
            }
        } else if let arrayKeyPath = groupColumn as? KeyPath<UnifiedLog, [String]?> {
            // Handle [String]? KeyPath - flatten the arrays and filter out nil/empty
            values = filteredLogs.flatMap { log -> [String] in
                guard let array = log[keyPath: arrayKeyPath], !array.isEmpty else { return [] }
                return array.filter { !$0.isEmpty } // Also filter out empty strings within the array
            }
        }
        
        // Count occurrences of each unique value
        let counts = Dictionary(values.map { ($0, 1) }, uniquingKeysWith: +)
        
        // Sort descending by count
        return counts.map { ($0.key, $0.value) }.sorted { $0.count > $1.count }
    }
    
    var longestKeyWidth: CGFloat {
        let longestKey = frequencyData.max(by: { $0.key.count < $1.key.count })?.key ?? ""
        let font = UIFont.systemFont(ofSize: 12)
        let width = (longestKey as NSString).size(withAttributes: [.font: font]).width
        return width + 10
    }

    // MARK: - Body
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
                        let font = UIFont.systemFont(ofSize: 19, weight: .regular)
                        CustomText(text: chartName, color: bg, width: chartName.width(usingFont: font) + 15, textAlign: .center, textSize: 19)
                            .padding(.leading, 25)

                        Spacer()

                        Button(action: { showVisual.toggle() }) {
                            Image(systemName: "eye.slash.circle")
                                .resizable() // Add this!
                                .aspectRatio(contentMode: .fit)
                                .foregroundStyle(Color(hex: bg))
                                .frame(width: 25, height: 25)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.trailing, 25)
                        .padding(.top, 7)
                    }

                    if !frequencyData.isEmpty {
                        VStack {
                            ForEach(frequencyData, id: \.key) { item in
                                HStack(spacing: 0) {
                                    // Label column
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
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(hex: accent))
                                                .frame(height: 25)

                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(hex: bg))
                                                .frame(width: barWidth, height: 25)
                                            
                                            CustomText(text: "\(item.count) Log\(item.count == 1 ? "" : "s")", color: accent, width: barWidth, textAlign: .center, textSize: 12)
                                                .clipped()
                                        }
                                    }
                                    .frame(height: 30)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
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
            HiddenChart(bg: bg, accent: accent, chart: chartName, hideChart: $showVisual)
        }
    }
}
