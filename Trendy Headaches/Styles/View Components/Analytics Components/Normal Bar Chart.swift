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

    @State private var showVisual = true
    let width = UIScreen.main.bounds.width * 0.9
    
    //trunacte long labels
//    func capLabel(_ text: String, max: Int = 8) -> String {
//        text.count > max ? String(text.prefix(max)) + "…" : text
//    }

    
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
//    var longestKeyWidth: CGFloat {
//        let fontSize = (UIScreen.main.bounds.width - 80) * 0.07
//        let font = UIFont.systemFont(ofSize: fontSize)
//
//        // Cap all keys to max 8 characters
//        let cappedKeys = frequencyData.map { capLabel($0.key) }
//
//        // Find the visually longest capped key
//        let longestKey = cappedKeys.max(by: {
//            ($0 as NSString).size(withAttributes: [.font: font]).width <
//            ($1 as NSString).size(withAttributes: [.font: font]).width
//        }) ?? ""
//
//        // Return width + padding
//        let width = (longestKey as NSString).size(withAttributes: [.font: font]).width
//        return width + 10
//    }


    var body: some View {
        
         
        if showVisual {
            
            let baseColor = Color(hex: accent)
            // Generate a distinct color for each bar using the provided helper
            let barColors: [Color] = baseColor.generateColors(from: baseColor, count: frequencyData.count)
            
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(hex: accent))
                    .frame(width: width)
                    .padding(.horizontal, 10)

                VStack(alignment: .leading, spacing: 12) {
                    // Header
                    HStack {
                        //chart title
                        let fontSize = (UIScreen.main.bounds.width - 80) * 0.07
                        let font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
                        CustomText(text: chartName, color: bg, width: chartName.width(usingFont: font) + 15, textAlign: .leading, bold: true, textSize: fontSize)
                            .padding(.leading, 35)

                        Spacer()

                        //hide the chart
                        HideButton(accent: accent, bg: bg, show: $showVisual)
                        .padding(.trailing, 25)
                    }
                    .padding(.top, 3)

                    if !frequencyData.isEmpty {
                        VStack {
                            ForEach(Array(frequencyData.enumerated()), id: \.element.key) { index, item in
                                HStack(spacing: 0) {
                                    // bar label
                                    let fontSize = width * 0.05
//                                    let font = UIFont.systemFont(ofSize: fontSize)
//                                    let capped = capLabel(item.key)
//                                    CustomText(text: capped, color: bg, width: capped.width(usingFont: font)+10, textSize: fontSize)
//                                        .frame(width: longestKeyWidth, alignment: .trailing)
//                                        .padding(.trailing, 5)
//                                        .padding(.bottom, 5)
                                        

                                    // Bar column
                                    GeometryReader { geo in
                                        let maxCount = frequencyData.first?.count ?? 1
                                        let ratio = CGFloat(item.count) / CGFloat(maxCount)
                                        let barWidth = max((width * 0.9) * ratio , 20)

                                        ZStack(alignment: .center) {
                                            //bar with full width, hidden
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(.clear)
                                                .frame(height: 30)

                                            //actual bar
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(index < barColors.count ? barColors[index] : baseColor)
                                                .frame(width: barWidth, height: 30)
                                            
                                            let fullText = categoryColumn.lowercased() == "med_worked"
                                                ? "\(item.count)%"
                                                : "\(item.count) Log\(item.count == 1 ? "" : "s")"

                                            let shortText = "\(item.count)"
                                            let widthThreshold: CGFloat = 60
                                           
                                            let barHex = barColors[index].toHex() ?? accent
                                            let isDark = Color.isHexDark(barHex)
                                            let textColor: Color = isDark ? .white : .black

                                            CustomText(
                                                text: barWidth < widthThreshold ? shortText : fullText,
                                                color: textColor.toHex() ?? accent,
                                                width: barWidth,
                                                textAlign: .center,
                                                textSize: fontSize)
                                            .clipped()

                                        }
                                        .padding(.leading, 10)
                                    }
                                    .frame(height: 30)
                                }
                            }
                            let labels = frequencyData.map { $0.key }
                            let colorMap = Dictionary(uniqueKeysWithValues: zip(labels, barColors))
                            BarChartKey(labels: labels, colorMap: colorMap, bg: bg, width: width*0.9)
                        }

                        
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


//symptom color key

//symptom color key
struct BarChartKey: View {
    var labels: [String]
    var colorMap: [String: Color]
    var bg: String
    var width: CGFloat
    
    var body: some View {
        //break symptoms into rows
        let rows = rowsForKey(items: labels, width: width-20, text: { $0.capitalizedWords.count > 10 ? String($0.capitalizedWords.prefix(15)) + "…" : $0.capitalizedWords }, iconWidth: 10,  iconTextGap: 5, horizontalPadding: 0, font: .systemFont(ofSize: 18), mapResult: { symptom in symptom }) as! [[String]]
        
        VStack(alignment: .center, spacing: 8) {
            //each row
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack(spacing: 10) {
                    //each symptom in the row
                    ForEach(rows[rowIndex], id: \.self) { symptom in
                        HStack(spacing: 5) {
                            //circle with the color
                            Circle()
                                .fill(colorMap[symptom] ?? .gray)
                                .frame(width: 10, height: 10)
                            
                            //symptom label
                            CustomText( text: symptom.capitalizedWords.count > 25
                                    ? String(symptom.capitalizedWords.prefix(25)) + "…"
                                    : symptom.capitalizedWords, color: bg, textSize: 18)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .fixedSize(horizontal: true, vertical: false)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .frame(width: width, alignment: .leading)
        .padding(.top, 10)
    }
}

