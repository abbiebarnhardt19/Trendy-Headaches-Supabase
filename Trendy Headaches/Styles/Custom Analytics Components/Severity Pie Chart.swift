//
//  Severity Pie Chart.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/14/25.
//

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

//actual chart
struct SeverityPieChart: View {
    var logList: [UnifiedLog]
    var accent: String
    var bg: String
    @Binding var hideChart: Bool
    
    @State private var selectedSlice: String? = nil
    
    private var severityCounts: [(severity: String, count: Int)] {
        Dictionary(grouping: logList, by: \.severity)
            .map { (String($0.key), $0.value.count) }
            .sorted { Int($0.0)! < Int($1.0)! }
    }
    
    var body: some View {
        let chartSize: CGFloat = 170
        let baseColor = Color(hex: accent)
        let popOutOffset: CGFloat = 15
        let counts = severityCounts.map(\.count)
        let sliceColors = baseColor.generateColors(from: baseColor, count: counts.count)
        
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: accent))
                .frame(width: UIScreen.main.bounds.width - 40, height: chartSize + 70)
            
            VStack {
                HStack {
                    CustomText(text:"Log Severity", color: bg, width: 140, textSize: 20)
                        .padding(.leading, 30)
                    Spacer()
                    Button(action: { hideChart.toggle() }) {
                        CustomText(text: "Hide", color: accent, width: 45, textAlign: .center, textSize: 12)
                            .frame(height: 25)
                            .background(Color(hex: bg))
                            .cornerRadius(20)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 20)
                }
                .frame(width: UIScreen.main.bounds.width - 30)
                .padding(.top, 20)
                
                ZStack {
                    ForEach(severityCounts.indices, id: \.self) { idx in
                        let item = severityCounts[idx]
                        let start = startAngle(for: idx, counts: counts)
                        let end = endAngle(for: idx, counts: counts)
                        let mid = Angle(degrees: (start.degrees + end.degrees) / 2)
                        let isSelected = selectedSlice == item.severity
                        let dx = cos(mid.radians) * (isSelected ? popOutOffset : 0)
                        let dy = sin(mid.radians) * (isSelected ? popOutOffset : 0)
                        let sliceColor = sliceColors[idx]
                        let textColor = Color.isHexDark(sliceColor.toHex() ?? accent) ? Color.white : Color.black
                        
                        PieSliceShape(startAngle: start, endAngle: end)
                            .fill(sliceColor)
                            .overlay(PieSliceShape(startAngle: start, endAngle: end).stroke(.black, lineWidth: 2))
                            .frame(width: chartSize, height: chartSize)
                            .offset(x: dx, y: dy)
                            .onTapGesture { withAnimation(.spring()) { selectedSlice = isSelected ? nil : item.severity } }
                        
                        Text(item.severity)
                            .font(.system(size: 18, design: .serif))
                            .foregroundColor(textColor)
                            .position(
                                x: chartSize/2 + cos(mid.radians) * chartSize * 0.35 + dx,
                                y: chartSize/2 + sin(mid.radians) * chartSize * 0.35 + dy
                            )
                    }
                    
                    if let selected = selectedSlice,
                       let idx = severityCounts.firstIndex(where: { $0.severity == selected }) {
                        let item = severityCounts[idx]
                        let mid = Angle(degrees: (startAngle(for: idx, counts: counts).degrees + endAngle(for: idx, counts: counts).degrees)/2)
                        let dx = -cos(mid.radians) * 50
                        let dy = -sin(mid.radians) * 50
                        let symptomCounts = makeSymptomCounts(for: selected, logs: logList)
                        
                        TooltipView(severity: item.severity, total: item.count, logListCount: logList.count, symptoms: symptomCounts, accent: accent, bg: bg)
                            .position(x: chartSize/2 + dx, y: chartSize/2 + dy)
                    }
                }
                .frame(width: chartSize, height: chartSize)
                Spacer()
            }
            .frame(width: chartSize + 40, height: chartSize + 80)
            .padding(.bottom, 10)
        }
    }
}

// detail popup
struct TooltipView: View {
    let severity: String
    let total: Int
    let logListCount: Int
    let symptoms: [SymptomCount]
    let accent: String
    let bg: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Sev. \(severity): \(total) \(total==1 ? "log" : "logs") (\(Int(Double(total)/Double(logListCount)*100))%)")
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
