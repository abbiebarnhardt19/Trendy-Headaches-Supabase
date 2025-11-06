//
//  Dynamic Spacing Functions.swift
//  Trendy Headaches Supabase
//
//  Created by Abigail Barnhardt on 11/5/25.
//

import SwiftUI



//function for wrapping on multiple choice and checkboxes
func computeRowsForForm(options: [String], textSize: CGFloat, width: CGFloat, itemHeight: CGFloat) -> [[String]] {
    var rows: [[String]] = [[]]
    var currentRowWidth: CGFloat = 0
    let font = UIFont.systemFont(ofSize: textSize, weight: .regular)
    let itemSpacing: CGFloat = 8
    
    for option in options {
        let textWidth = option.width(usingFont: font)
        // For options > 10 chars, cap the width to prevent overflow
        let maxTextWidth = option.count > 10 ? width - itemHeight - 4 - 50 : textWidth
        let itemWidth = itemHeight + 4 + min(textWidth, maxTextWidth)
        
        let newRowWidth = currentRowWidth == 0 ? itemWidth : currentRowWidth + itemSpacing + itemWidth
        
        if newRowWidth > width && !rows[rows.count - 1].isEmpty {
            rows.append([option])
            currentRowWidth = itemWidth
        } else {
            rows[rows.count - 1].append(option)
            currentRowWidth = newRowWidth
        }
    }
    return rows
}

//function to wrap rows on keys
func rowsForKey<T>(
    items: [T],
    width: CGFloat,
    text: (T) -> String,
    iconWidth: CGFloat,
    iconTextGap: CGFloat,
    horizontalPadding: CGFloat,
    font: UIFont = .systemFont(ofSize: 12),
    itemSpacing: CGFloat = 10,
    mapResult: (T) -> (Any)
) -> [[Any]] {
    
    var rows: [[Any]] = [[]]
    var currentRowWidth: CGFloat = 0
    
    for item in items {
        let displayText = String(text(item).prefix(12))
        let textWidth = displayText.width(usingFont: font)
        let itemWidth = iconWidth + iconTextGap + textWidth + horizontalPadding
        
        let newRowWidth = currentRowWidth == 0 ? itemWidth : currentRowWidth + itemSpacing + itemWidth
        
        if newRowWidth > width && !rows.last!.isEmpty {
            rows.append([mapResult(item)])
            currentRowWidth = itemWidth
        } else {
            rows[rows.count - 1].append(mapResult(item))
            currentRowWidth = newRowWidth
        }
    }
    
    return rows
}
