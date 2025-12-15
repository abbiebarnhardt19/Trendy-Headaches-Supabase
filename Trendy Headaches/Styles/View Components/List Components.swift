//
//  Table Styles.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/2/25.
//

import SwiftUI

//button to trigger filter dropdown
struct FilterButton: View {
    @Binding var accent: String
    @Binding var bg: String
    @Binding var popUp: Bool
    var width: CGFloat
    
    var body: some View {
        //when clicked, toggle showing of filter optioms
        Button(action: { popUp.toggle() }) {
            ZStack {
                //circle with lines in it to indicate filter
                Circle()
                    .fill(Color(hex: bg))
                    .frame(width: width * 0.9, height: width * 0.9)
                
                Image(systemName: "line.horizontal.3.decrease.circle")
                    .font(.system(size: width))
                    .foregroundColor(Color(hex: accent))
            }
            .frame(width: width, height: width)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

//adjust filter values
struct FilterOptions: View {
    @Binding var accent: String
    @Binding var bg: String
    @State var colOptions: [String]
    @Binding var selectedCols: [String]
    @Binding var typeOptions: [String]
    @Binding var type: [String]
    @Binding var start: Date
    @Binding var end: Date
    @Binding var stringStart: String
    @Binding var stringEnd: String
    @Binding var sevStart: Int64
    @Binding var sevEnd: Int64
    @Binding var sympOptions: [String]
    @Binding var selectedSymps: [String]


    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height

    enum FilterSection {
        case none, columns, logType, date, severity, symptoms
    }

    //sections expand when clicked, with differernt width
    @State private var expandedWidth: CGFloat = 215
    @State private var unexpandedWidth: CGFloat = 255
    @State private var expandedSection: FilterSection = .none
    @State private var dropdownWidths: [FilterSection: (collapsed: CGFloat, expanded: CGFloat)] = [.columns: (100, 250), .logType: (100, 160),  .date: (55, 280),  .severity: (90, 190),  .symptoms: (120, 300)]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            //column section
                sectionButton(title: "Columns", section: .columns) {
                    MultipleCheckboxWrapped(options: $colOptions, selected: $selectedCols, accent: accent, bg: bg, width: (dropdownWidths[.columns]?.expanded ?? 250) - 30, textSize: screenWidth * 0.045)
                    .padding(.top, 10)
                    .padding(.leading, 5)
                }
            
            // log type section
            sectionButton(title: "Log Type", section: .logType) {
                MultipleCheckboxWrapped(options: $typeOptions, selected: $type, accent: accent, bg: bg, width: (dropdownWidths[.logType]?.expanded ?? 250) - 20, textSize: screenWidth * 0.045)
                .padding(.top, 10)
                .padding(.leading, 2)
            }

            //date section
            sectionButton(title: "Date", section: .date) {
                VStack {
                    DateTextField(date: $start, textValue: $stringStart, bg: $accent,  accent: $bg, width: 250, label: "Start:")
                        .padding(.top, 10)

                    DateTextField(date: $end, textValue: $stringEnd, bg: $accent,  accent: $bg, width: 250, label: "End:")
                }
                .padding(.leading, 5)
            }

            //severity section
            sectionButton(title: "Severity", section: .severity) {
                HStack {
                    CustomTextField(bg: accent,  accent: bg, placeholder: "", text: Binding(get: { String(sevStart) }, set: { sevStart = Int64($0) ?? 0 }),
                                    width: min(screenWidth * 0.15, 65), height: min(screenHeight * 0.05, 45), textSize: screenHeight * 0.045 / 2.2, align: .center)
                    .padding(.top, 10)
                    
                    VStack(alignment: .center){
                        CustomText(text: " to ", color: bg, width: 30)
                    }
                    .frame(height: min(screenHeight * 0.055, 45))
                    
                    CustomTextField(bg: accent, accent: bg, placeholder: "", text: Binding(get: { String(sevEnd) }, set: { sevEnd = Int64($0) ?? 0 }), width: min(screenWidth * 0.15, 65), height: min(screenHeight * 0.05, 45), textSize: screenHeight * 0.045 / 2.2, align: .center)
                    .padding(.top, 10)
                }
                .padding(.leading, 10)
            }

            // symptom section
            sectionButton(title: "Symptoms", section: .symptoms) {
                MultipleCheckboxWrapped(options: $sympOptions, selected: $selectedSymps, accent: accent, bg: bg, width: (dropdownWidths[.symptoms]?.expanded ?? 250) - 30 , textSize: screenWidth * 0.045)
                .padding(.top, 10)
                .padding(.leading, 5)
            }
        }
        .padding(10)
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(hex: bg), lineWidth: 3))
        .background(Color(hex: accent))
        .cornerRadius(20)
    }
        
    // resuable section button
    @ViewBuilder
    private func sectionButton<Content: View>(
        title: String,
        section: FilterSection,
        @ViewBuilder content: () -> Content
    ) -> some View {
        //get the widths for that section
        let widths = dropdownWidths[section] ?? (300, 300)
        let sectionExpandedWidth = widths.expanded
        let isExpanded = expandedSection == section
        
        //set width based on currently expanded
        let currentWidth: CGFloat = {
            if let activeWidths = dropdownWidths[expandedSection] {
                return expandedSection == .none ? widths.collapsed : activeWidths.expanded
            } else {
                return widths.collapsed
            }
        }()
        
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 5) {
                //label
                CustomText(text: title, color: bg,  width: currentWidth, textAlign: .leading, bold: true)
                
                //expansion button
                Button(action: {
                    withAnimation(.easeInOut) {
                        self.expandedSection = isExpanded ? .none : section
                    }
                }) {
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: bg))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 5)
                
            //adjust content to expanded width
            if isExpanded {
                content()
                    .frame(width: sectionExpandedWidth, alignment: .leading)
                    .clipped()
            }
        }
        .frame(width: isExpanded ? currentWidth : 160, alignment: .leading)
    }
}

//table for displaying all logs
struct ScrollableLogTable: View {
    var userID: Int64
    var list: [UnifiedLog]
    var selectedCols: [String]
    @Binding var bg: String
    @Binding var accent: String
    @State var height: CGFloat
    @State var width: CGFloat
    @Binding var deleteCount: Int64

    var onLogTap: ((Int64, String) -> Void)? = nil

    @State private var columnWidths: [String: CGFloat] = [:]
    @State private var defaultWidths: [String: CGFloat] = [:]
    @State private var activeColumn: String? = nil
    @State private var dragOffset: CGFloat = 0

    @State private var showDeleteAlert = false
    @State private var logToDelete: UnifiedLog? = nil

    private var headerHeight: CGFloat { screenWidth * 0.045 * 1.5 + 10}
    private var rowHeight: CGFloat { screenWidth * 0.04 * 1.8 + 2}
    
    let screenWidth = UIScreen.main.bounds.width

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .short
        return f
    }
    
    //set the width of the table
    var tableWidth: CGFloat {
        let contentWidth = selectedCols.reduce(0) { sum, col in
            sum + (columnWidths[col] ?? defaultWidths[col] ?? 100)
        }
        return min(width, contentWidth)
    }

    //set minimum widths for columns that have fixed content
    private func minWidth(for column: String) -> CGFloat {
        let padding: CGFloat = 25
        
        // Special cases for Date and Onset columns
        switch column {
        case "Date":
            let font = UIFont.systemFont(ofSize: screenWidth * 0.04, weight: .regular)
            return "10/26/25".width(usingFont: font) + padding
        case "Onset":
            let font = UIFont.systemFont(ofSize: screenWidth * 0.04, weight: .regular)
            return "From Wake".width(usingFont: font) + padding
        default:
            let font = UIFont.systemFont(ofSize: screenWidth * 0.045, weight: .bold)
            return column.width(usingFont: font) + padding
        }
    }

    //func to size the columns
    private func autoWidth(for column: String) -> CGFloat {
        let charWidth: CGFloat = 9.5
        let padding: CGFloat = 25
        let maxRowCount = list.map { value(for: column, in: $0).count }.max() ?? 0
        let rawWidth = CGFloat(maxRowCount) * charWidth + padding
        
        let minWidth = minWidth(for: column)
        return max(rawWidth, minWidth)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Outer wrapper for rounded corners
            ZStack(alignment: .topLeading) {
                Color.clear // takes no extra space
                ScrollView([.vertical, .horizontal], showsIndicators: true) {
                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        //top row frozen at top
                        Section(header:
                            VStack(spacing: 0) {
                                headerRow
                            //top row slightly differrent color
                            Rectangle()
                                .fill(Color(hex: bg).opacity(0.4))
                                .frame(height: 2)
                            } )
                        {
                            //make each individual row
                            ForEach(list, id: \.id) { log in
                                row(for: log)
                                Rectangle()
                                    .fill(Color(hex: bg).opacity(0.3))
                                    .frame(height: 2)
                            }
                        }
                    }
                    .background(Color(hex: accent))
                }
            }
            .background(Color(hex: accent))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: bg).opacity(0.5), lineWidth: 1) )
            .frame(height: min(height, headerHeight + 2 + CGFloat(list.count) * (rowHeight + 2) + 7))
            .frame(width: tableWidth)
        }

        .onAppear {
            UIScrollView.appearance().bounces = false
            UIScrollView.appearance().showsVerticalScrollIndicator = true
            UIScrollView.appearance().showsHorizontalScrollIndicator = true

            // Use modern API to get the app's windows
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                for window in windowScene.windows {
                    for subview in window.subviews {
                        if let scrollView = subview as? UIScrollView {
                            scrollView.flashScrollIndicators()
                        }
                    }
                }
            }
            for col in selectedCols {
                let width = autoWidth(for: col)
                columnWidths[col] = width
                defaultWidths[col] = width
            }
        }
        //for deleting log
        .alert("Delete Log?", isPresented: $showDeleteAlert, presenting: logToDelete) { log in
            Button("Delete", role: .destructive) {
                Task {
                    await Database.shared.deleteLog(logID: log.log_id, table: log.log_type)
                }
                deleteCount += 1
            }
            Button("Cancel", role: .cancel) {}
        } message: { _ in
            Text("Are you sure you want to delete this log?")
        }
    }

    //top row
    private var headerRow: some View {
        HStack(spacing: 0) {
            ForEach(selectedCols.indices, id: \.self) { index in
                let column = selectedCols[index]
                let isLastColumn = index == selectedCols.count - 1
                
                ZStack(alignment: .trailing) {
                    //column name
                    CustomText(text: column, color: bg,  textAlign: .center, multiAlign: .center, bold: true, textSize: screenWidth * 0.045)
                        .frame(width: effectiveWidth(for: column), height: headerHeight)
                        .padding(.trailing, isLastColumn ? 5 : 0)
                        .background(Color.blend(Color(hex: bg), Color(hex: accent), ratio: 0.8))

                    //all but last column resizing
                    if !isLastColumn {
                        //invisiable rectangle for dragging
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: 10)
                            .contentShape(Rectangle())
                            .gesture(DragGesture(minimumDistance: 1)
                                .onChanged { value in
                                    if activeColumn != column {
                                        activeColumn = column
                                        dragOffset = 0
                                    }
                                    dragOffset = value.translation.width
                                }
                                .onEnded { value in
                                    if let col = activeColumn {
                                        let minWidth = minWidth(for: col)
                                        let newWidth = (columnWidths[col] ?? autoWidth(for: col)) + value.translation.width
                                        columnWidths[col] = max(newWidth, minWidth)
                                    }
                                    activeColumn = nil
                                    dragOffset = 0
                                })
                            .onTapGesture(count: 2) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    columnWidths[column] = defaultWidths[column]
                                }
                            }
                    }
                }
                
                // Divider for all but the last column
                if !isLastColumn {
                    Rectangle()
                        .fill(Color(hex: bg).opacity(0.4))
                        .frame(width: 2)
                }
            }
        }
        .background(Color(hex: accent))
    }

    //row template
    private func row(for log: UnifiedLog) -> some View {
        let isLastRow = log.id == list.last?.id

        return HStack(spacing: 0) {
            //go through each column
            ForEach(selectedCols.indices, id: \.self) { index in
                let column = selectedCols[index]
                let isLastColumn = index == selectedCols.count - 1

                //get column value
                CustomText(text: value(for: column, in: log), color: bg,  textAlign: .center, textSize: screenWidth * 0.04)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(width: effectiveWidth(for: column), height: rowHeight)
                .background(Color(hex: accent))
                
                // Divider for all but the last column
                if !isLastColumn {
                    Rectangle()
                        .fill(Color(hex: bg).opacity(0.3))
                        .frame(width: 2)
                    
                } else {
                    // Add right padding space for last column
                    Spacer(minLength: 5)
                        .frame(width: 5)
                        .background(Color(hex: accent))
                }
            }
        }
        //add extra padding on last row for horizontal scroll indicator
        .padding(.bottom, isLastRow ? 7 : 0)
        .contentShape(Rectangle())
        //on hold delete row
        .onLongPressGesture(minimumDuration: 1.0) {
            logToDelete = log
            showDeleteAlert = true
        }
        //on tap move to log page
        .simultaneousGesture(
            TapGesture().onEnded {
                onLogTap?(log.log_id, log.log_type)
            })
    }

    // adjusting width
    private func effectiveWidth(for column: String) -> CGFloat {
        let minWidth = minWidth(for: column)
        if column == activeColumn {
            let proposed = (columnWidths[column] ?? autoWidth(for: column)) + dragOffset
            return max(proposed, minWidth)
        } else {
            return columnWidths[column] ?? autoWidth(for: column)
        }
    }

    // value mapping
    private func value(for column: String, in log: UnifiedLog) -> String {
        switch column {
        case "Log Type": return log.log_type
        case "Symptom": return log.symptom_name ?? ""
        case "Date": return dateFormatter.string(from: log.date)
        case "Sev.": return "\(log.severity)"
        case "Notes": return log.notes ?? ""
        case "Symp. Desc.": return log.symptom_description ?? ""
        case "Triggers": return log.trigger_names?.joined(separator: ", ") ?? ""
        case "Onset": return log.onset_time ?? ""
        case "Em. Med. Name": return log.medication_name ?? ""
        case "Em. Med. Taken?": return log.med_taken == true ? "Yes" : "No"
        case "Em. Med. Worked?": return log.med_worked == true ? "Yes" : "No"
        case "S.E. Med.": return log.side_effect_med ?? ""
        default: return ""
        }
    }
}
