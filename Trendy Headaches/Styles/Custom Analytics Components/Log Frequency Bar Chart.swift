//
//  Log Frequency Bar Chart.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/14/25.
//

import SwiftUI

struct TooltipOverlay: View {
    var month: Date
    var symptom: String
    var data: [(month: Date, symptoms: [(symptom: String, count: Int)])]
    var sympOrder: [String]
    var chartWidth: CGFloat
    var chartHeight: CGFloat
    var maxCount: Int
    var colorMap: [String: Color]

    @State private var measWid: CGFloat = 0
    @State private var measHeight: CGFloat = 0

    private struct ToolWidKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }

    private struct ToolHeiKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }

    var tooltipInfo: (x: CGFloat, y: CGFloat, width: CGFloat, color: Color, count: Int, segHeight: CGFloat, percent: Double)? {
        let cal = Calendar.current
        guard
            let mon = data.first(where: { cal.isDate($0.month, equalTo: month, toGranularity: .month) }),
            let sym = mon.symptoms.first(where: { $0.symptom == symptom })
        else { return nil }

        let total = mon.symptoms.reduce(0) { $0 + $1.count }
        let percent = total > 0 ? Double(sym.count) / Double(total) * 100 : 0

        // chart metrics
        let (yAx, pad, space): (CGFloat, CGFloat, CGFloat) = (15, 20, 10)
        let bars = CGFloat(max(1, data.count))
        let barW = (chartWidth - yAx - pad - space * (bars - 1)) / bars
        let usedW = barW.isFinite && barW > 0 ? barW : (chartWidth - yAx - space * 11 - 20) / 12

        // x positions
        let i = CGFloat(data.firstIndex { cal.isDate($0.month, equalTo: month, toGranularity: .month) } ?? 0)
        let barL = yAx + pad / 2 + i * (usedW + space)
        let barR = barL + usedW

        // segment height + center
        let yMax = CGFloat(maxCount)
        var (cum, seg): (CGFloat, CGFloat) = (0, 0)
        for n in sympOrder {
            guard let d = mon.symptoms.first(where: { $0.symptom == n }) else { continue }
            let h = chartHeight * CGFloat(d.count) / yMax
            if n == symptom { seg = h; break } else { cum += h }
        }
        let segY = cum + seg / 2

        // tooltip width + clamped x
        let effW = max(60, measWid > 0 ? measWid : 120)
        let (gap, lMost, rMost): (CGFloat, CGFloat, CGFloat) = (10, effW/2, chartWidth - effW/2)
        let rightX = barR + gap + effW/2
        let leftX  = barL - gap - effW/2
        let cenX = rightX + effW <= chartWidth
            ? rightX
            : leftX >= 0 ? leftX
            : min(rMost, max(lMost, (chartWidth - effW) / 2))

        return ( x: min(rMost, max(lMost, cenX)), y: segY, width: effW, color: colorMap[symptom] ?? .gray, count: sym.count, segHeight: seg, percent: percent)
    }

    var body: some View {
        if let info = tooltipInfo {
            let textColor: Color = Color.isHexDark(info.color.hexString) ? .white : .black
            
            VStack(spacing: 2) {
                Text(symptom.capitalizedWords)
                    .font(.system(size: 12, weight: .bold, design: .serif))
                    .fixedSize()
                Text("\(info.count) logs (\(Int(info.percent))%)")
                    .font(.system(size: 10, design: .serif))
                    .fixedSize()
            }
            .foregroundColor(textColor)
            .padding(6)
            .background(
                ZStack {
                    info.color
                        .cornerRadius(6)
                    GeometryReader { proxy in
                        Color.clear.preference(key: ToolWidKey.self, value: proxy.size.width)
                    }
                    GeometryReader { proxy in
                        Color.clear.preference(key: ToolHeiKey.self, value: proxy.size.height)
                    }
                })
            .onPreferenceChange(ToolWidKey.self) { value in
                DispatchQueue.main.async { self.measWid = value }
            }
            .onPreferenceChange(ToolHeiKey.self) { height in
                DispatchQueue.main.async { self.measHeight = height }
            }
            .position(x: info.x, y: info.y + 5)
        }
    }
}

struct CustomStackedBarChart: View {
    var logList: [UnifiedLog]
    var accent: String
    var bg: String
    @Binding var hideChart: Bool

    @State var showKey: Bool = false
    @State var yearOff: Int = 0
    @State private var selMon: Date? = nil
    @State private var selSymp: String? = nil
    @State private var width = UIScreen.main.bounds.width - 30

    //get all the month data
    private var data: [(month: Date, symptoms: [(symptom: String, count: Int)])] {
            let cal = Calendar.current
            let startMon = cal.date(byAdding: .month, value: -11, to: cal.date(from: cal.dateComponents([.year, .month], from: Date()))!)!
            let months = (0..<12).compactMap { cal.date(byAdding: .month, value: $0, to: startMon) }
            let logsByMonth = Dictionary(grouping: logList.filter { $0.date >= startMon }) {
                cal.date(from: cal.dateComponents([.year, .month], from: $0.date))!
        }
    
        return months.map { month in
            (month, logsByMonth[month]?.reduce(into: [String: Int]()) { $0[$1.symptom_name ?? "Unknown", default: 0] += 1 }
                    .map { ($0.key, $0.value) } ?? [])
        }
    }

    private var maxCount: Int {
        max(data.map { $0.symptoms.map(\.count).reduce(0, +) }.max() ?? 1, 1)
    }

    private var sympOrder: [String] {
        let globalSymptomCounts = Dictionary(grouping: data.flatMap { $0.symptoms }) { $0.symptom }
            .mapValues { $0.map(\.count).reduce(0, +) }
        return globalSymptomCounts.sorted {
            if $0.value == $1.value { return $0.key > $1.key }
            return $0.value < $1.value
        }.map { $0.key }
    }

    var body: some View {
        let color = Color(hex: accent)
        let colorMap = Dictionary(uniqueKeysWithValues: zip(sympOrder, color.generateColors(from: color, count: sympOrder.count)))

        let chartHeight: CGFloat = 150
        let yStep = max(1, Int(ceil(Double(maxCount) / 5)))
        let yMax = ((maxCount + yStep - 1) / yStep) * yStep
        let yVals = Array(stride(from: 0, through: yMax, by: yStep))

        let yAxWid: CGFloat = 15
        let barSpac: CGFloat = 10
        let barWidth = (width - yAxWid - barSpac * 11 - 20) / 12

        VStack(alignment: .leading, spacing: 10) {
            // Buttons
            HStack {
                HStack{
                    CustomButton(systemImage: "chevron.left", bg: bg,  accent: accent, height: 15, width: 12, botPad: 0) { yearOff -= 1}
                    
                    CustomText(text:"Logs by Symptom", color:bg, width:150, textAlign:.center, textSize:18)
                    
                    CustomButton(systemImage: "chevron.right", bg: bg,  accent: accent, height: 15, width: 12, disabled: yearOff >= 0, botPad: 0) {yearOff += 1}
                }
                .padding(.bottom, 10)
                
                Spacer()
                
                CustomButton(text:"Key", bg: accent, accent: bg, height: 25, width: 45, textSize: 12){showKey.toggle()}
                
                CustomButton(text:"Hide", bg: accent, accent: bg, height: 25, width: 45, textSize: 12){hideChart.toggle()}
            }
            .padding(.horizontal, 20)
            
            // Chart area with Y-axis and bars
            ZStack(alignment:.topLeading) {
                HStack(alignment: .top, spacing:0) {
                    // Y-axis
                    VStack(spacing:0) {
                        ForEach(yVals.reversed(), id:\.self) { value in
                            CustomText(text:"\(value)", color:bg, width:yAxWid, textAlign: .trailing, textSize:10)
                                .padding(.trailing,7)
                                .frame(height:1)
                                .offset(y:-3)
                            if value>0 { Spacer().frame(height: chartHeight*CGFloat(yStep)/CGFloat(yMax)) }
                        }
                    }
                    .frame(height: chartHeight, alignment:.top)
                    
                    ZStack(alignment:.topLeading) {
                        //bars
                        VStack(spacing:0) {
                            ForEach(yVals.reversed(), id:\.self) { value in
                                Rectangle().fill(Color(hex:bg).opacity(0.3)).frame(height:1)
                                if value>0 { Spacer().frame(height: chartHeight*CGFloat(yStep)/CGFloat(yMax)) }
                            }
                        }
                        .frame(height: chartHeight)
                        
                        // Bars
                        HStack(alignment:.bottom, spacing:barSpac) {
                            ForEach(data, id:\.month) { monData in
                                VStack(spacing:2) {
                                    ZStack(alignment:.bottom) {
                                        RoundedRectangle(cornerRadius:6).fill(color.opacity(0.2))
                                        VStack(spacing: 0) {
                                            let popGap: CGFloat = 8

                                        ForEach(sympOrder, id: \.self) { symp in
                                            if let s = monData.symptoms.first(where: { $0.symptom == symp }) {
                                                let segHeight = chartHeight * CGFloat(s.count) / CGFloat(yMax)
                                                let isSel = selMon == monData.month && selSymp == s.symptom
                                                let topPad: CGFloat = isSel ? popGap / 2 : 0
                                                let botPad: CGFloat = isSel ? popGap / 2 : 0

                                                Rectangle()
                                                    .fill(colorMap[s.symptom] ?? .gray)
                                                    .frame(height: segHeight)
                                                    .padding(.top, topPad)
                                                    .padding(.bottom, botPad)
                                                    .onTapGesture {
                                                        withAnimation(.spring()) {
                                                            if selMon == monData.month && selSymp == s.symptom {
                                                                selMon = nil
                                                                selSymp = nil
                                                            } else {
                                                                selMon = monData.month
                                                                selSymp = s.symptom
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        .clipShape(RoundedRectangle(cornerRadius:8))
                                    }
                                    .frame(width:barWidth,height:chartHeight)
                                    
                                    CustomText(text: monthLabel(for: monData.month), color:bg, textAlign:.center, textSize:8)
                                        .fixedSize()
                                        .padding(.top,5)
                                }
                            }
                        }
                    }
                }
                
                // popup if segment is selected
                if let selMon, let selSymp {
                    TooltipOverlay(month: selMon, symptom: selSymp, data: data, sympOrder: sympOrder, chartWidth: width, chartHeight: chartHeight, maxCount: maxCount, colorMap: colorMap)
                }
            }
            .frame(height:chartHeight+30)
            
            //symptom legend
            if showKey {
                BarSymptomKey(sympOrder: sympOrder, colorMap: colorMap, bg: bg, width: width - 50)
                    .padding(.leading, 25)
                    .padding(.bottom, 5)
            }
        }
        .padding(.vertical,10)
        .background(Color(hex:accent))
        .cornerRadius(30)
        .frame(width:width)
        .padding(.bottom, 10)
    }

    private var monthFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "MMM yyyy"
        return df
    }

    private func monthLabel(for date: Date) -> String {
        let month = monthFormatter.string(from: date).prefix(3)
        let year = monthFormatter.string(from: date).suffix(4)
        return "\(month),\n\(year)"
    }
}

struct BarSymptomKey: View {
    var sympOrder: [String]
    var colorMap: [String: Color]
    var bg: String
    var width: CGFloat
    
    var body: some View {
        let rows = computeRows()
        
        VStack(alignment: .leading, spacing: 8) {
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack(spacing: 10) {
                    ForEach(rows[rowIndex], id: \.self) { symptom in
                        HStack(spacing: 5) {
                            Circle()
                                .fill(colorMap[symptom] ?? .gray)
                                .frame(width: 10, height: 10)
                            
                            CustomText(
                                text: symptom.capitalizedWords.count > 10
                                    ? String(symptom.capitalizedWords.prefix(10)) + "…"
                                    : symptom.capitalizedWords,
                                color: bg,
                                textSize: 12
                            )
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .fixedSize(horizontal: true, vertical: false)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(width: width, alignment: .leading)
    }
    
    private func computeRows() -> [[String]] {
        var rows: [[String]] = [[]]
        var currentRowWidth: CGFloat = 0
        let font = UIFont.systemFont(ofSize: 12, weight: .regular)
        let itemSpacing: CGFloat = 10
        
        for symptom in sympOrder {
            let displayText = symptom.capitalizedWords.count > 10
                ? String(symptom.capitalizedWords.prefix(10)) + "…"
                : symptom.capitalizedWords
            let textWidth = displayText.width(usingFont: font)
            // Circle + gap + text
            let itemWidth = 10 + 5 + textWidth
            
            // Calculate what the new width would be if we add this item
            let newRowWidth = currentRowWidth == 0 ? itemWidth : currentRowWidth + itemSpacing + itemWidth
            
            // Allow going significantly over to pack more items
            if newRowWidth > width * 1.3 && !rows[rows.count - 1].isEmpty {
                // Start a new row
                rows.append([symptom])
                currentRowWidth = itemWidth
            } else {
                // Add to current row
                rows[rows.count - 1].append(symptom)
                currentRowWidth = newRowWidth
            }
        }
        
        return rows
    }
}
