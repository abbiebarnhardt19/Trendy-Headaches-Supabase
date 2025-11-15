//
//  Pie Chart Functions.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/17/25.
//
import SwiftUI

func startAngle(for index: Int, counts: [Int]) -> Angle {
    let total = counts.reduce(0, +)
    let sumBefore = counts.prefix(index).reduce(0, +)
    return Angle(degrees: Double(sumBefore) / Double(total) * 360 - 90)
}

func endAngle(for index: Int, counts: [Int]) -> Angle {
    let total = counts.reduce(0, +)
    let sumUpTo = counts.prefix(index + 1).reduce(0, +)
    return Angle(degrees: Double(sumUpTo) / Double(total) * 360 - 90)
}

func makeSymptomCounts(for severity: String, logs: [UnifiedLog]) -> [SymptomCount] {
    guard let severityInt = Int64(severity) else { return [] }

    let filteredLogs = logs.filter { $0.severity == severityInt }

    let grouped = Dictionary(grouping: filteredLogs, by: { $0.symptom_name })

    return grouped
        .map { SymptomCount(symptom: $0.key ?? "", count: $0.value.count) }
        .sorted { $0.count > $1.count }
}
