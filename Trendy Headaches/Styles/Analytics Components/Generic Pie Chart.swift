//
//  Severity Pie Chart.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/14/25.

import SwiftUI

//Slice shape
struct PieSliceShape: Shape {
    var startAngle: Angle
    var endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        //determine center and size
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        //create slice shape path
        var path = Path()
        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()
        return path
    }
}

//outline of each slice
struct PieSliceDivider: Shape {
    var angle: Angle
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let endPoint = CGPoint( x: center.x + CGFloat(cos(angle.radians)) * radius, y: center.y + CGFloat(sin(angle.radians)) * radius)
        var path = Path()
        path.move(to: center)
        path.addLine(to: endPoint)
        return path
    }
}

//assemble the slices, works for multiple data types
struct GenericPieChart<T: Hashable>: View {
    var logList: [UnifiedLog]
    var accent: String
    var bg: String
    var chartTitle: String
    var groupBy: KeyPath<UnifiedLog, T>
    
    @State private var selectedSlice: String? = nil
    @State private var showVisual: Bool = false
    
    //get the counts for each option
    private var groupedCounts: [(key: String, count: Int)] {
        let grouped = Dictionary(grouping: logList) { log -> String? in
            let value = log[keyPath: groupBy]
            
            // Handle Bool? (optional boolean)
            if let optionalBool = value as? Bool? {
                guard let unwrapped = optionalBool else {
                    return nil
                }
                let result = unwrapped ? "Yes" : "No"
                return result
            }
            // Handle Bool (non-optional boolean)
            else if let boolValue = value as? Bool {
                let result = boolValue ? "Yes" : "No"
                return result
            }
            // Handle String
            else if let stringValue = value as? String {
                return stringValue.isEmpty ? nil : stringValue
            }
            // Handle Int64
            else if let intValue = value as? Int64 {
                return String(intValue)
            }
            // Handle String? (optional string)
            else if let optionalString = value as? String? {
                if let unwrapped = optionalString, !unwrapped.isEmpty {
                    return unwrapped
                }
                return nil
            }
            else {
                return String(describing: value)
            }
        }
        
        //get the actual counts based on their frequency in grouped
        let result = grouped.compactMap { (key, value) -> (String, Int)? in
            guard let key = key else { return nil }
            return (key, value.count)
        }
        
        // Check if all keys are numeric
        let allNumeric = result.allSatisfy { Int($0.0) != nil }
        
        if allNumeric {
            return result.sorted { Int($0.0) ?? 0 < Int($1.0) ?? 0 }
        } else {
            return result.sorted { $0.0 < $1.0 }
        }
    }
    
    //check if its a numeric type
    private var isNumeric: Bool {
        groupedCounts.allSatisfy { Int($0.key) != nil }
    }
    
    //check if its a boolean type
    private var isBoolean: Bool {
        let keys = Set(groupedCounts.map { $0.key })
        return keys.isSubset(of: ["Yes", "No"])
    }
    
    var body: some View {
        if showVisual {
            //set constants
            let chartSize: CGFloat = 170
            let baseColor = Color(hex: accent)
            let popOutOffset: CGFloat = 15
            let counts = groupedCounts.map(\.count)
            let sliceColors = baseColor.generateColors(from: baseColor, count: counts.count)
            
            ZStack {
                //rectange background
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: accent))
                    .frame(width: UIScreen.main.bounds.width - 50)
                
                //header with label and hide button
                VStack(spacing: 10) {
                    HStack {
                        let font = UIFont.systemFont(ofSize: 20, weight: .bold)
                        CustomText(text: chartTitle, color: bg, width: chartTitle.width(usingFont: font) + 15, bold: true, textSize: 20)
                            .padding(.leading, 30)
                        
                        Spacer()
                        
                        //button to hide chart
                        HideButton(accent: accent, bg: bg, show: $showVisual)
                        .padding(.trailing, 20)
                    }
                    .frame(width: UIScreen.main.bounds.width - 30)
                    .padding(.top, 10)
                    
                    //show pie chart if theres data
                    if !groupedCounts.isEmpty{
                        ZStack {
                            //make each slice
                            ForEach(groupedCounts.indices, id: \.self) { idx in
                                //constants for creating the slice and positioning it
                                let item = groupedCounts[idx]
                                let start = startAngle(for: idx, counts: counts)
                                let end = endAngle(for: idx, counts: counts)
                                let mid = Angle(degrees: (start.degrees + end.degrees) / 2)
                                let isSelected = selectedSlice == item.key
                                let dx = cos(mid.radians) * (isSelected ? popOutOffset : 0)
                                let dy = sin(mid.radians) * (isSelected ? popOutOffset : 0)
                                let sliceColor = sliceColors[idx]
                                let textColor = Color.isHexDark(sliceColor.toHex() ?? accent) ? Color.white : Color.black
                                
                                //make the slice itself
                                PieSliceShape(startAngle: start, endAngle: end)
                                    .fill(sliceColor)
                                    .overlay(PieSliceShape(startAngle: start, endAngle: end).stroke(.black, lineWidth: 2))
                                    .frame(width: chartSize, height: chartSize)
                                    .offset(x: dx, y: dy)
                                    .onTapGesture { withAnimation(.spring()) { selectedSlice = isSelected ? nil : item.key } }
                                
                                // Show text labels for numeric or boolean values
                                if isNumeric || isBoolean {
                                    Text(item.key)
                                        .font(.system(size: 18, design: .serif))
                                        .foregroundColor(textColor)
                                        .position( x: chartSize/2 + cos(mid.radians) * chartSize * 0.35 + dx,  y: chartSize/2 + sin(mid.radians) * chartSize * 0.35 + dy )
                                }
                            }

                            //if its selected, pop it out and show the tooltip
                            if let selected = selectedSlice,
                               let idx = groupedCounts.firstIndex(where: { $0.key == selected }) {
                                
                                let item = groupedCounts[idx]
                                let mid = Angle(degrees: (startAngle(for: idx, counts: counts).degrees + endAngle(for: idx, counts: counts).degrees ) / 2)

                                let dx = -cos(mid.radians) * 50
                                let dy = -sin(mid.radians) * 50

                                let selectedLogs = logList.filter { log in
                                    let value = log[keyPath: groupBy]
                                    let valueString: String = {
                                        if let boolValue = value as? Bool {
                                            return boolValue ? "Yes" : "No"
                                        }
                                        if let optionalBool = value as? Bool? {
                                            return (optionalBool ?? false) ? "Yes" : "No"
                                        }
                                        if let stringValue = value as? String {
                                            return stringValue
                                        }
                                        if let intValue = value as? Int64 {
                                            return String(intValue)
                                        }
                                        if let optionalString = value as? String? {
                                            return optionalString ?? ""
                                        }
                                        return String(describing: value)
                                    }()
                                    return valueString == selected
                                }

                                let symptomCounts = makeSymptomCounts(for: selected, logs: selectedLogs)

                                //tooltip with more data, position next to slice
                                TooltipView(label: item.key, total: item.count, logListCount: logList.count, symptoms: symptomCounts, accent: accent, bg: bg)
                                .position(x: chartSize / 2 + dx, y: chartSize / 2 + dy)
                            }
                        }
                        .frame(width: chartSize, height: chartSize)
                        
                        
                        // Show color key for string values, since labels are too big for slices
                        if !isNumeric && !isBoolean {
                            PieChartColorKey( items: groupedCounts, colors: sliceColors, bg: bg, width: UIScreen.main.bounds.width - 80)
                        }
                        
                        Spacer()
                    }
                    else{
                        //no data warning
                        CustomText(text:"No Data", color:bg, textAlign: .center, bold: true)
                            .padding(.bottom, 10)
                    }
                }
            }
            .padding(.bottom, 10)
        } else {
            //button to show chart if hidden
            HiddenChart(bg: bg, accent: accent, chart: chartTitle, hideChart: $showVisual)
        }
    }
}

// Color key for string values
struct PieChartColorKey: View {
    let items: [(key: String, count: Int)]
    let colors: [Color]
    let bg: String
    let width: CGFloat
    var itemHeight: CGFloat = 13
    
    var body: some View {
        let rows = rowsForKey(items: items, width: width, text: { $0.key },  iconWidth: 10, iconTextGap: 4, horizontalPadding: 8, mapResult: { item in (item.key, item.count, colors[items.firstIndex(where: { $0.key == item.key })!]) }) as! [[(String, Int, Color)]]
        
        VStack(alignment: .leading, spacing: 8) {
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack(spacing: 10) {
                    ForEach(rows[rowIndex], id: \.0) { item in
                        //circle with the slice color followed by the label
                        HStack(spacing: 4) {
                            Circle()
                                .frame(width: 10, height: 10)
                                .foregroundColor(item.2)
                            
                            CustomText(text: String(item.0.prefix(12)), color: bg, textSize: UIScreen.main.bounds.width * 0.04)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .fixedSize(horizontal: true, vertical: false)
                        }
                        .padding(.horizontal, 4)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(width: width, alignment: .leading)
        .padding(.leading, 10)
        .padding(.top, 10)
    }
}

// detail popup for selected slice
struct TooltipView: View {
    let label: String
    let total: Int
    let logListCount: Int
    let symptoms: [SymptomCount]
    let accent: String
    let bg: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            //label+ log count + percent
            Text("\(label): \(total) \(total==1 ? "log" : "logs") (\(Int(Double(total)/Double(logListCount)*100))%)")
                .foregroundColor(Color(hex: accent))
                .font(.system(size: 18, design: .serif))
            
            //show symptom breakdown for severity
            ForEach(symptoms) { item in
                HStack(alignment: .top, spacing: 6) {
                    //each symptom and its percent
                    Text("•").foregroundColor(Color(hex: accent)).font(.system(size: 16, design: .serif))
                    Text(item.symptom.prefix(8) + (item.symptom.count > 8 ? "…" : "") + ": \(item.count) (\(Int(Double(item.count)/Double(total)*100))%)")
                        .foregroundColor(Color(hex: accent))
                        .font(.system(size: 16, design: .serif))
                }
            }
        }
        .padding(10)
        .background(Color(hex: bg))
        .cornerRadius(10)
        .shadow(radius: 4)
    }
}
