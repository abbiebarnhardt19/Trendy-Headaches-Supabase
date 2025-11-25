//
//  Log Frequency Bar Chart.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/14/25.
//

import SwiftUI

//stacked bar chart for symptoms and months
struct CustomStackedBarChart: View {
    var logList: [UnifiedLog]
    var accent: String
    var bg: String

    @State var showKey: Bool = false
    @State var yearOff: Int = 0
    @State private var selMon: Date? = nil
    @State private var selSymp: String? = nil
    
    @State private var showVisual: Bool = false
    
    // Make width responsive
    private var screenWidth: CGFloat { UIScreen.main.bounds.width }
    private var width: CGFloat { screenWidth - 40 }
    private var horizontalPadding: CGFloat { min(20, screenWidth * 0.05) }

    //get all the month data
    private var data: [(month: Date, symptoms: [(symptom: String, count: Int)])] {
        let cal = Calendar.current
        // Use yearOff to shift the date range
        let baseDate = cal.date(byAdding: .year, value: yearOff, to: Date())!
        let startMon = cal.date(byAdding: .month, value: -11, to: cal.date(from: cal.dateComponents([.year, .month], from: baseDate))!)!
        let months = (6..<12).compactMap { cal.date(byAdding: .month, value: $0, to: startMon) }
        
        //break the logs up by month
        let logsByMonth = Dictionary(grouping: logList.filter { $0.date >= startMon && $0.date <= baseDate }) {
            cal.date(from: cal.dateComponents([.year, .month], from: $0.date))!
        }

        return months.map { month in
            (month, logsByMonth[month]?.reduce(into: [String: Int]()) { $0[$1.symptom_name ?? "Unknown", default: 0] += 1 }
                    .map { ($0.key, $0.value) } ?? [])
        }
    }

    //get the max number of logs per month to set y axis
    private var maxCount: Int {
        max(data.map { $0.symptoms.map(\.count).reduce(0, +) }.max() ?? 1, 1)
    }

    //sort symptoms by number of logs
    private var sympOrder: [String] {
        let globalSymptomCounts = Dictionary(grouping: data.flatMap { $0.symptoms }) { $0.symptom }
            .mapValues { $0.map(\.count).reduce(0, +) }
        return globalSymptomCounts.sorted {
            if $0.value == $1.value { return $0.key > $1.key }
            return $0.value < $1.value
        }.map { $0.key }
    }
    
    //format dates
    private var monthFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "MMM yyyy"
        return df
    }

    var body: some View {
        if showVisual{
            let color = Color(hex: accent)
            let colorMap = Dictionary(uniqueKeysWithValues: zip(sympOrder, color.generateColors(from: color, count: sympOrder.count)))
            
            //use the max number of logs in a month and chart height to set y axis and scale
            let chartHeight: CGFloat = 170
            let yStep = max(1, Int(ceil(Double(maxCount) / 5)))
            let yMax = ((maxCount + yStep - 1) / yStep) * yStep
            let yVals = Array(stride(from: 0, through: yMax, by: yStep))
            
            // size y axis width and the size of the bars
            let yAxWid: CGFloat = 25
            let leftPadding: CGFloat = min(10, screenWidth * 0.025)
            let rightPadding: CGFloat = min(10, screenWidth * 0.025)
            let barSpac: CGFloat = max(4, min(10, screenWidth * 0.02))
            let availableWidth = width - yAxWid - leftPadding - rightPadding - (barSpac * 11)
            let barWidth = max(20, availableWidth / 6)
            
            VStack(alignment: .leading, spacing: 10) {
                //header
                HStack {
                    HStack(spacing: 0) {
                        //go back a year
                        CustomButton(systemImage: "chevron.left", bg: bg, accent: accent, height: 20, width: 12, botPad: 0) { yearOff -= 1}
                            .padding(.trailing, 5)
                        
                        //graph title
                        let fontSize = width * 0.065
                        let font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
                        let title = "Logs by Symptom"
                        CustomText(text:title, color:bg, width: title.width(usingFont: font) + 15, textAlign:.center, bold: true, textSize: fontSize)
                        
                        
                        //move up a year, only if thats not in the future
                        CustomButton(systemImage: "chevron.right", bg: bg, accent: accent, height: 20, width: 12, disabled: yearOff >= 0, botPad: 0) {yearOff += 1}
                            .padding(.leading, 5)
                    }
                    .padding(.bottom, 5)
                    
                    Spacer()
                    
                    //button to show color key
                    ShowKeyButton(accent: accent, bg: bg, show: $showKey)
                    
                    HideButton(accent: accent, bg: bg, show: $showVisual)
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.bottom, 20)
                
                // only show graph if theres data
                if !logList.isEmpty{
                    ZStack(alignment:.topLeading) {
                        HStack(alignment: .top, spacing:0) {
                            // y-axis
                            VStack(spacing:0) {
                                let  yAxisFont = width * 0.04
                                ForEach(yVals.reversed(), id:\.self) { value in
                                    CustomText(text:"\(value)", color:bg, width:yAxWid, textAlign: .center, textSize:yAxisFont)
                                        .frame(height:1)
                                        .offset(x:5, y:-3)
                                    
                                    if value>0 { Spacer().frame(height: chartHeight*CGFloat(yStep)/CGFloat(yMax)) }
                                }
                            }
                            .frame(height: chartHeight, alignment:.top)
                            
                            Spacer()
                                .frame(width: leftPadding)
                            
                            ZStack(alignment:.topLeading) {
                                //grid lines
                                VStack(spacing:0) {
                                    ForEach(yVals.reversed(), id:\.self) { value in
                                        Rectangle().fill(Color(hex:bg).opacity(0.3)).frame(height:1)
                                        if value>0 { Spacer().frame(height: chartHeight*CGFloat(yStep)/CGFloat(yMax)) }
                                    }
                                }
                                .frame(height: chartHeight)
                                
                                // Bars
                                HStack(alignment:.bottom, spacing:barSpac) {
                                    //go through each month
                                    ForEach(data, id:\.month) { monData in
                                        VStack(spacing:2) {
                                            ZStack(alignment:.bottom) {
                                                RoundedRectangle(cornerRadius:6).fill(color.opacity(0.2))
                                                VStack(spacing: 0) {
                                                    let popGap: CGFloat = 8
                                                    
                                                    //go through each symptom
                                                    ForEach(sympOrder, id: \.self) { symp in
                                                        //get the size of that symptom's segment
                                                        if let s = monData.symptoms.first(where: { $0.symptom == symp }) {
                                                            let segHeight = chartHeight * CGFloat(s.count) / CGFloat(yMax)
                                                            let isSel = selMon == monData.month && selSymp == s.symptom
                                                            let topPad: CGFloat = isSel ? popGap / 2 : 0
                                                            let botPad: CGFloat = isSel ? popGap / 2 : 0
                                                            
                                                            //make the actual segment
                                                            Rectangle()
                                                                .fill(colorMap[s.symptom] ?? .gray)
                                                                .frame(height: segHeight)
                                                                .padding(.top, topPad)
                                                                .padding(.bottom, botPad)
                                                                .onTapGesture {
                                                                    //pop it out if selected
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
                                            
                                            //month label underneath that month's segments
                                            CustomText(text: monthLabel(for: monData.month), color:bg, textAlign:.center, textSize: min(18, screenWidth * 0.057))
                                            //.fixedSize()
                                                .padding(.top,15)
                                        }
                                    }
                                }
                                .frame(maxWidth: availableWidth + (barSpac * 11))
                            }
                            
                            Spacer()
                                .frame(width: rightPadding)
                        }
                        
                        // popup if segment is selected
                        if let selMon, let selSymp {
                            TooltipOverlay(month: selMon, symptom: selSymp, data: data, sympOrder: sympOrder, chartWidth: width - leftPadding - rightPadding, chartHeight: chartHeight, maxCount: maxCount, colorMap: colorMap)
                                .offset(x: yAxWid + leftPadding)
                        }
                    }
                    .frame(height:chartHeight+30)
                }
                else{
                    CustomText(text: "No Data", color: bg, textAlign: .center, bold: true)
                        .padding(.bottom, 10)
                }
                
                //symptom legend
                if showKey {
                    BarSymptomKey(sympOrder: sympOrder, colorMap: colorMap, bg: bg, width: width - (horizontalPadding * 2))
                        .padding(.horizontal, horizontalPadding)
                        .padding(.bottom, 5)
                        .padding(.top, 10)
                }
            }
            .padding(.vertical,10)
            .background(Color(hex:accent))
            .cornerRadius(20)
            .frame(width:width)
            .padding(.bottom, 10)
        }
        //if hidden, show show button
        else{
            HiddenChart(bg: bg, accent: accent, chart: "Log Frequency Chart", hideChart: $showVisual)
        }
    }
    
    private func monthLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/yy"   // 9/25
        return formatter.string(from: date)
    }

}

//symptom color key
struct BarSymptomKey: View {
    var sympOrder: [String]
    var colorMap: [String: Color]
    var bg: String
    var width: CGFloat
    
    var body: some View {
        //break symptoms into rows
        let rows = rowsForKey(items: sympOrder, width: width-20, text: { $0.capitalizedWords.count > 10 ? String($0.capitalizedWords.prefix(15)) + "…" : $0.capitalizedWords }, iconWidth: 10,  iconTextGap: 5, horizontalPadding: 0, font: .systemFont(ofSize: 18), mapResult: { symptom in symptom }) as! [[String]]
        
        VStack(alignment: .leading, spacing: 8) {
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
                            CustomText( text: symptom.capitalizedWords.count > 10
                                    ? String(symptom.capitalizedWords.prefix(15)) + "…"
                                    : symptom.capitalizedWords, color: bg, textSize: 18)
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
}

//get the popup for selected segment
struct TooltipOverlay: View {
    var month: Date
    var symptom: String
    var data: [(month: Date, symptoms: [(symptom: String, count: Int)])]
    var sympOrder: [String]
    var chartWidth: CGFloat
    var chartHeight: CGFloat
    var maxCount: Int
    var colorMap: [String: Color]

    @State private var measuredWidth: CGFloat = 0

    var body: some View {
        
        //get the data and positioning for the tooltip
        if let info = infoForTooltip() {
            //the color of the tooltip is the color of the bar, set text color based on darkness of that color
            let textColor = Color.isHexDark(info.color.hexString) ? Color.white : Color.black

            //display the data
            VStack(spacing: 2) {
                let fontSize = chartWidth * 0.055
                Text(symptom.capitalizedWords)
                    .font(.system(size: fontSize, weight: .bold, design: .serif))
                Text("\(info.count) logs (\(Int(info.percent))%)")
                    .font(.system(size: fontSize * 0.85, design: .serif))
            }
            .foregroundColor(textColor)
            .padding(6)
            //make it clickable
            .background( info.color
                    .cornerRadius(6)
                    .overlay( GeometryReader { g in
                            Color.clear
                                .onAppear { measuredWidth = g.size.width }
                        }) )
            .position(x: info.x, y: info.y + 5)
        }
    }
    
    //function to get positioning and information that goes in the tooltip
    private func infoForTooltip() -> (x: CGFloat, y: CGFloat, width: CGFloat, color: Color, count: Int, percent: Double)? {
        
        let calendar = Calendar.current
        
        //get the data for the selected month
        guard let monthData = data.first(where: { calendar.isDate($0.month, equalTo: month, toGranularity: .month) }),
              let sym = monthData.symptoms.first(where: { $0.symptom == symptom }),
              let index = data.firstIndex(where: { calendar.isDate($0.month, equalTo: month, toGranularity: .month) })
        else { return nil }

        //get the total logs and total selected symptom for selected month
        let total = monthData.symptoms.reduce(0) { $0 + $1.count }
        let percent = total > 0 ? Double(sym.count) / Double(total) * 100 : 0

        //get the size and position of the month bar
        let barWidth = chartWidth / CGFloat(max(data.count, 1))
        let barX = barWidth * CGFloat(index)

        // Stack height before this symptom to figure out popout height
        let yOffset = sympOrder.prefix { $0 != symptom }.compactMap { name -> CGFloat? in
            monthData.symptoms.first { $0.symptom == name }.map { chartHeight * CGFloat($0.count) / CGFloat(maxCount) }
        }.reduce(0, +)

        //get the height of the selected segment for positioning
        let segHeight = chartHeight * CGFloat(sym.count) / CGFloat(maxCount)
        
        //get center of that segment
        let centerY = yOffset + segHeight / 2

        //get the x value
        let width = max(measuredWidth, 80)
        let rightX = barX + barWidth + 10 + width / 2
        let leftX  = barX - 10 - width / 2
        let x = min(chartWidth - width / 2,
                    max(width / 2, rightX <= chartWidth ? rightX : leftX))

        return (x, centerY, width, colorMap[symptom] ?? .gray, sym.count, percent)
    }
}
