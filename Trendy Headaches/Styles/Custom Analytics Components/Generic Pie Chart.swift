//
//  Severity Pie Chart.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/14/25.
//
//
//import SwiftUI
//
////slice
//struct PieSliceShape: Shape {
//    var startAngle: Angle
//    var endAngle: Angle
//    
//    func path(in rect: CGRect) -> Path {
//        let center = CGPoint(x: rect.midX, y: rect.midY)
//        let radius = min(rect.width, rect.height) / 2
//        
//        var path = Path()
//        path.move(to: center)
//        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
//        path.closeSubpath()
//        return path
//    }
//}
//
////slice outline
//struct PieSliceDivider: Shape {
//    var angle: Angle
//    
//    func path(in rect: CGRect) -> Path {
//        let center = CGPoint(x: rect.midX, y: rect.midY)
//        let radius = min(rect.width, rect.height) / 2
//        let endPoint = CGPoint( x: center.x + CGFloat(cos(angle.radians)) * radius, y: center.y + CGFloat(sin(angle.radians)) * radius)
//        var path = Path()
//        path.move(to: center)
//        path.addLine(to: endPoint)
//        return path
//    }
//}
//
////actual chart - generic version
//struct GenericPieChart<T: Hashable>: View {
//    var logList: [UnifiedLog]
//    var accent: String
//    var bg: String
//    var chartTitle: String
//    var groupBy: KeyPath<UnifiedLog, T>
//    
//    @State private var selectedSlice: String? = nil
//    @State private var showVisual: Bool = false
//    
//    private var groupedCounts: [(key: String, count: Int)] {
//        let grouped = Dictionary(grouping: logList) { log -> String? in
//            let value = log[keyPath: groupBy]
//            if let stringValue = value as? String {
//                return stringValue.isEmpty ? nil : stringValue
//            } else if let intValue = value as? Int64 {
//                return String(intValue)
//            } else if let optionalString = value as? String? {
//                if let unwrapped = optionalString, !unwrapped.isEmpty {
//                    return unwrapped
//                }
//                return nil
//            } else {
//                return String(describing: value)
//            }
//        }
//        .compactMap { (key, value) -> (String, Int)? in
//            guard let key = key else { return nil }
//            return (key, value.count)
//        }
//        
//        // Check if all keys are numeric
//        let allNumeric = grouped.allSatisfy { Int($0.0) != nil }
//        
//        if allNumeric {
//            // Sort numerically
//            return grouped.sorted { Int($0.0) ?? 0 < Int($1.0) ?? 0 }
//        } else {
//            // Sort alphabetically
//            return grouped.sorted { $0.0 < $1.0 }
//        }
//    }
//    
//    private var isNumeric: Bool {
//        groupedCounts.allSatisfy { Int($0.key) != nil }
//    }
//    
//    var body: some View {
//        if showVisual {
//            let chartSize: CGFloat = 170
//            let baseColor = Color(hex: accent)
//            let popOutOffset: CGFloat = 15
//            let counts = groupedCounts.map(\.count)
//            let sliceColors = baseColor.generateColors(from: baseColor, count: counts.count)
//            
//            ZStack {
//                RoundedRectangle(cornerRadius: 20)
//                    .fill(Color(hex: accent))
//                    .frame(width: UIScreen.main.bounds.width - 50)
//                
//                VStack(spacing: 10) {
//                    HStack {
//                        CustomText(text: chartTitle, color: bg, width: 200, textSize: 20)
//                            .padding(.leading, 30)
//                        Spacer()
//                        Button(action: { showVisual.toggle() }) {
//                            CustomText(text: "Hide", color: accent, width: 45, textAlign: .center, textSize: 12)
//                                .frame(height: 25)
//                                .background(Color(hex: bg))
//                                .cornerRadius(20)
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                        .padding(.trailing, 20)
//                    }
//                    .frame(width: UIScreen.main.bounds.width - 30)
//                    .padding(.top, 10)
//                    
//                    ZStack {
//                        ForEach(groupedCounts.indices, id: \.self) { idx in
//                            let item = groupedCounts[idx]
//                            let start = startAngle(for: idx, counts: counts)
//                            let end = endAngle(for: idx, counts: counts)
//                            let mid = Angle(degrees: (start.degrees + end.degrees) / 2)
//                            let isSelected = selectedSlice == item.key
//                            let dx = cos(mid.radians) * (isSelected ? popOutOffset : 0)
//                            let dy = sin(mid.radians) * (isSelected ? popOutOffset : 0)
//                            let sliceColor = sliceColors[idx]
//                            let textColor = Color.isHexDark(sliceColor.toHex() ?? accent) ? Color.white : Color.black
//                            
//                            PieSliceShape(startAngle: start, endAngle: end)
//                                .fill(sliceColor)
//                                .overlay(PieSliceShape(startAngle: start, endAngle: end).stroke(.black, lineWidth: 2))
//                                .frame(width: chartSize, height: chartSize)
//                                .offset(x: dx, y: dy)
//                                .onTapGesture { withAnimation(.spring()) { selectedSlice = isSelected ? nil : item.key } }
//                            
//                            // Only show text labels for numeric values
//                            if isNumeric {
//                                Text(item.key)
//                                    .font(.system(size: 18, design: .serif))
//                                    .foregroundColor(textColor)
//                                    .position(
//                                        x: chartSize/2 + cos(mid.radians) * chartSize * 0.35 + dx,
//                                        y: chartSize/2 + sin(mid.radians) * chartSize * 0.35 + dy
//                                    )
//                            }
//                        }
//                        
//                        if let selected = selectedSlice,
//                           let idx = groupedCounts.firstIndex(where: { $0.key == selected }) {
//                            let item = groupedCounts[idx]
//                            let mid = Angle(degrees: (startAngle(for: idx, counts: counts).degrees + endAngle(for: idx, counts: counts).degrees)/2)
//                            let dx = -cos(mid.radians) * 50
//                            let dy = -sin(mid.radians) * 50
//                            let selectedLogs = logList.filter { log -> Bool in
//                                let value = log[keyPath: groupBy]
//                                if let stringValue = value as? String {
//                                    return stringValue == selected
//                                } else if let intValue = value as? Int64 {
//                                    return String(intValue) == selected
//                                } else if let optionalString = value as? String? {
//                                    return optionalString == selected
//                                } else {
//                                    return String(describing: value) == selected
//                                }
//                            }
//                            let symptomCounts = makeSymptomCounts(for: selected, logs: selectedLogs)
//                            
//                            TooltipView(
//                                label: item.key,
//                                total: item.count,
//                                logListCount: logList.count,
//                                symptoms: symptomCounts,
//                                accent: accent,
//                                bg: bg
//                            )
//                            .position(x: chartSize/2 + dx, y: chartSize/2 + dy)
//                        }
//                    }
//                    .frame(width: chartSize, height: chartSize)
//                    
//                    // Show color key for string values
//                    if !isNumeric {
//                        PieChartColorKey(
//                            items: groupedCounts,
//                            colors: sliceColors,
//                            bg: bg,
//                            width: UIScreen.main.bounds.width - 80
//                        )
//                    }
//                    
//                    Spacer()
//                }
//                
//            }
//            .padding(.bottom, 10)
//        } else {
//            HiddenChart(bg: bg, accent: accent, chart: chartTitle, hideChart: $showVisual)
//        }
//    }
//}
//
//// Color key for string values
//struct PieChartColorKey: View {
//    let items: [(key: String, count: Int)]
//    let colors: [Color]
//    let bg: String
//    let width: CGFloat
//    var itemHeight: CGFloat = 13
//    
//    var body: some View {
//        let rows = computeRows()
//        
//        VStack(alignment: .leading, spacing: 8) {
//            ForEach(0..<rows.count, id: \.self) { rowIndex in
//                HStack(spacing: 10) {
//                    ForEach(rows[rowIndex], id: \.0) { item in
//                        HStack(spacing: 4) {
//                            Circle()
//                                .frame(width: 10, height: 10)
//                                .foregroundColor(item.2)
//                            
//                            CustomText(
//                                text: String(item.0.prefix(12)),
//                                color: bg,
//                                textSize: UIScreen.main.bounds.width * 0.04)
//                            .lineLimit(1)
//                            .truncationMode(.tail)
//                            .fixedSize(horizontal: true, vertical: false)
//                        }
//                        .padding(.horizontal, 4)
//                    }
//                }
//                .frame(maxWidth: .infinity, alignment: .leading)
//            }
//        }
//        .frame(width: width, alignment: .leading)
//        .padding(.leading, 10)
//        .padding(.top, 10)
//    }
//    
//    private func computeRows() -> [[(String, Int, Color)]] {
//        var rows: [[(String, Int, Color)]] = [[]]
//        var currentRowWidth: CGFloat = 0
//        let font = UIFont.systemFont(ofSize: 12, weight: .regular)
//        let itemSpacing: CGFloat = 10
//        let horizontalPadding: CGFloat = 8
//        let iconTextGap: CGFloat = 4
//        let circleWidth: CGFloat = 10
//        
//        for (index, item) in items.enumerated() {
//            let color = colors[index]
//            let displayText = String(item.key.prefix(12))
//            let textWidth = displayText.width(usingFont: font)
//            let itemWidth = circleWidth + iconTextGap + textWidth + horizontalPadding
//            
//            let newRowWidth = currentRowWidth == 0 ? itemWidth : currentRowWidth + itemSpacing + itemWidth
//            
//            if newRowWidth > width && !rows[rows.count - 1].isEmpty {
//                rows.append([(item.key, item.count, color)])
//                currentRowWidth = itemWidth
//            } else {
//                rows[rows.count - 1].append((item.key, item.count, color))
//                currentRowWidth = newRowWidth
//            }
//        }
//        
//        return rows
//    }
//}
//
//// detail popup
//struct TooltipView: View {
//    let label: String
//    let total: Int
//    let logListCount: Int
//    let symptoms: [SymptomCount]
//    let accent: String
//    let bg: String
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 6) {
//            Text("\(label): \(total) \(total==1 ? "log" : "logs") (\(Int(Double(total)/Double(logListCount)*100))%)")
//                .foregroundColor(Color(hex: accent))
//                .font(.system(size: 18, design: .serif))
//            ForEach(symptoms) { item in
//                HStack(alignment: .top, spacing: 6) {
//                    Text("•").foregroundColor(Color(hex: accent)).font(.system(size: 16, design: .serif))
//                    Text(item.symptom.prefix(8) + (item.symptom.count > 8 ? "…" : "") + ": \(item.count) (\(Int(Double(item.count)/Double(total)*100))%)")
//                        .foregroundColor(Color(hex: accent))
//                        .font(.system(size: 16, design: .serif))
//                }
//            }
//        }
//        .padding(10)
//        .background(Color(hex: bg))
//        .cornerRadius(10)
//        .shadow(radius: 4)
//    }
//}

import SwiftUI

//slice
struct PieSliceShape: Shape {
    var startAngle: Angle
    var endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        var path = Path()
        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()
        return path
    }
}

//slice outline
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

//actual chart - generic version
struct GenericPieChart<T: Hashable>: View {
    var logList: [UnifiedLog]
    var accent: String
    var bg: String
    var chartTitle: String
    var groupBy: KeyPath<UnifiedLog, T>
    
    @State private var selectedSlice: String? = nil
    @State private var showVisual: Bool = false
    
    private var groupedCounts: [(key: String, count: Int)] {
        print("DEBUG: Starting grouping with logList count: \(logList.count)")
        
        let grouped = Dictionary(grouping: logList) { log -> String? in
            let value = log[keyPath: groupBy]
            print("DEBUG: Processing value: \(value), type: \(type(of: value))")
            
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
    
    private var isNumeric: Bool {
        groupedCounts.allSatisfy { Int($0.key) != nil }
    }
    
    private var isBoolean: Bool {
        let keys = Set(groupedCounts.map { $0.key })
        return keys.isSubset(of: ["Yes", "No"])
    }
    
    var body: some View {
        if showVisual {
            let chartSize: CGFloat = 170
            let baseColor = Color(hex: accent)
            let popOutOffset: CGFloat = 15
            let counts = groupedCounts.map(\.count)
            let sliceColors = baseColor.generateColors(from: baseColor, count: counts.count)
            
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: accent))
                    .frame(width: UIScreen.main.bounds.width - 50)
                
                VStack(spacing: 10) {
                    HStack {
                        let font = UIFont.systemFont(ofSize: 20, weight: .regular)
                        CustomText(text: chartTitle, color: bg, width: chartTitle.width(usingFont: font) + 15, textSize: 20)
                            .padding(.leading, 30)
                        Spacer()
                        
                        Button(action: { showVisual.toggle() }) {
                            Image(systemName: "eye.slash.circle")
                                .resizable() // Add this!
                                .aspectRatio(contentMode: .fit)
                                .foregroundStyle(Color(hex: bg))
                                .frame(width: 25, height: 25)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.trailing, 20)
                    }
                    .frame(width: UIScreen.main.bounds.width - 30)
                    .padding(.top, 10)
                    
                    if !groupedCounts.isEmpty{
                        ZStack {
                            ForEach(groupedCounts.indices, id: \.self) { idx in
                                let item = groupedCounts[idx]
                                let start = startAngle(for: idx, counts: counts)
                                let end = endAngle(for: idx, counts: counts)
                                let mid = Angle(degrees: (start.degrees + end.degrees) / 2)
                                let isSelected = selectedSlice == item.key
                                let dx = cos(mid.radians) * (isSelected ? popOutOffset : 0)
                                let dy = sin(mid.radians) * (isSelected ? popOutOffset : 0)
                                let sliceColor = sliceColors[idx]
                                let textColor = Color.isHexDark(sliceColor.toHex() ?? accent) ? Color.white : Color.black
                                
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
                                        .position(
                                            x: chartSize/2 + cos(mid.radians) * chartSize * 0.35 + dx,
                                            y: chartSize/2 + sin(mid.radians) * chartSize * 0.35 + dy
                                        )
                                }
                            }
                            
                            if let selected = selectedSlice,
                               let idx = groupedCounts.firstIndex(where: { $0.key == selected }) {
                                let item = groupedCounts[idx]
                                let mid = Angle(degrees: (startAngle(for: idx, counts: counts).degrees + endAngle(for: idx, counts: counts).degrees)/2)
                                let dx = -cos(mid.radians) * 50
                                let dy = -sin(mid.radians) * 50
                                let selectedLogs = logList.filter { log -> Bool in
                                    let value = log[keyPath: groupBy]
                                    if let boolValue = value as? Bool {
                                        return (boolValue ? "Yes" : "No") == selected
                                    } else if let optionalBool = value as? Bool? {
                                        guard let unwrapped = optionalBool else { return false }
                                        return (unwrapped ? "Yes" : "No") == selected
                                    } else if let stringValue = value as? String {
                                        return stringValue == selected
                                    } else if let intValue = value as? Int64 {
                                        return String(intValue) == selected
                                    } else if let optionalString = value as? String? {
                                        return optionalString == selected
                                    } else {
                                        return String(describing: value) == selected
                                    }
                                }
                                let symptomCounts = makeSymptomCounts(for: selected, logs: selectedLogs)
                                
                                TooltipView(
                                    label: item.key,
                                    total: item.count,
                                    logListCount: logList.count,
                                    symptoms: symptomCounts,
                                    accent: accent,
                                    bg: bg
                                )
                                .position(x: chartSize/2 + dx, y: chartSize/2 + dy)
                            }
                        }
                        .frame(width: chartSize, height: chartSize)
                        
                        
                        // Show color key for string values (not boolean or numeric)
                        if !isNumeric && !isBoolean {
                            PieChartColorKey(
                                items: groupedCounts,
                                colors: sliceColors,
                                bg: bg,
                                width: UIScreen.main.bounds.width - 80
                            )
                        }
                        
                        Spacer()
                    }
                    else{
                        CustomText(text:"No Data", color:bg, textAlign: .center, bold: true)
                            .padding(.bottom, 10)
                    }
                }
            }
            .padding(.bottom, 10)
            
            
        } else {
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
        let rows = computeRows()
        
        VStack(alignment: .leading, spacing: 8) {
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack(spacing: 10) {
                    ForEach(rows[rowIndex], id: \.0) { item in
                        HStack(spacing: 4) {
                            Circle()
                                .frame(width: 10, height: 10)
                                .foregroundColor(item.2)
                            
                            CustomText(
                                text: String(item.0.prefix(12)),
                                color: bg,
                                textSize: UIScreen.main.bounds.width * 0.04)
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
    
    private func computeRows() -> [[(String, Int, Color)]] {
        var rows: [[(String, Int, Color)]] = [[]]
        var currentRowWidth: CGFloat = 0
        let font = UIFont.systemFont(ofSize: 12, weight: .regular)
        let itemSpacing: CGFloat = 10
        let horizontalPadding: CGFloat = 8
        let iconTextGap: CGFloat = 4
        let circleWidth: CGFloat = 10
        
        for (index, item) in items.enumerated() {
            let color = colors[index]
            let displayText = String(item.key.prefix(12))
            let textWidth = displayText.width(usingFont: font)
            let itemWidth = circleWidth + iconTextGap + textWidth + horizontalPadding
            
            let newRowWidth = currentRowWidth == 0 ? itemWidth : currentRowWidth + itemSpacing + itemWidth
            
            if newRowWidth > width && !rows[rows.count - 1].isEmpty {
                rows.append([(item.key, item.count, color)])
                currentRowWidth = itemWidth
            } else {
                rows[rows.count - 1].append((item.key, item.count, color))
                currentRowWidth = newRowWidth
            }
        }
        
        return rows
    }
}

// detail popup
struct TooltipView: View {
    let label: String
    let total: Int
    let logListCount: Int
    let symptoms: [SymptomCount]
    let accent: String
    let bg: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(label): \(total) \(total==1 ? "log" : "logs") (\(Int(Double(total)/Double(logListCount)*100))%)")
                .foregroundColor(Color(hex: accent))
                .font(.system(size: 18, design: .serif))
            ForEach(symptoms) { item in
                HStack(alignment: .top, spacing: 6) {
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
