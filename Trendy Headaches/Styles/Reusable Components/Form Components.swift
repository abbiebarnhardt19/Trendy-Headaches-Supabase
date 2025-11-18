//
//  Custom Form Components.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/2/25.
//

import SwiftUI

//custom switch
struct CustomToggle: View {
    var color: String
    @Binding var feature: Bool
    
    var body: some View {
        //rectangle with a white circle indicating what is selected
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(hex: color))
            .frame(width: 50, height: 32)
            .overlay(Circle()
                .fill(.white)
                .padding(3)
                .offset(x: feature ? 10 : -10) )
        //on tap, change selected value
            .onTapGesture { feature.toggle() }
    }
}

//hex field, can click for color picker
struct ColorTextField: View {
    var accent: String
    var bg: String
    @Binding var update: String
    var placeholder: String = ""
    var width: CGFloat
    var corner: CGFloat? = 30
    
    @State private var selectedColor: Color = .white
    
    var body: some View {
        //text field to type hex code
        CustomTextField(bg: bg, accent: accent, placeholder: placeholder, text: $update, width: width, corner: corner ?? 30, maxLength: 7)
        .frame(height: 40)
        .overlay(alignment: .trailing) {
            //button to click to get color picker
            ZStack {
                Image(systemName: "eyedropper")
                    .foregroundColor(Color(hex: bg))
                    .font(.system(size: 17, weight: .bold))
                    .padding(.trailing, 15)
                
                // Transparent but tappable ColorPicker over the same spot
                ColorPicker("", selection: $selectedColor, supportsOpacity: false)
                    .labelsHidden()
                    .opacity(0.015)
                    .frame(width: 28, height: 28)
                    .contentShape(Circle())
                    .padding(.trailing, 15)
            }
            .padding(.bottom, 8)
        }
        //update color immediately
        .onChange(of: selectedColor, initial: false) { oldColor, newColor in
            update = newColor.toHex() ?? "FFFFFF"
        }
        .onAppear {
            selectedColor = Color(hex: update)
        }
    }
}

// date text field with date picker
struct DateTextField: View {
    @Binding var date: Date
    @Binding var textValue: String
    @Binding var bg: String
    @Binding var accent: String
    var width: CGFloat = 220
    var label: String = "Date:"
    var bold: Bool = false
    var height: CGFloat = UIScreen.main.bounds.width * 0.125
    var fieldTextSize: CGFloat = UIScreen.main.bounds.width * 0.05
    var labelTextSize: CGFloat = UIScreen.main.bounds.width * 0.06
    
    @State private var showDatePicker: Bool = false
    @State private var screenWidth = UIScreen.main.bounds.width
    
    private var formatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .short
        return f
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                //text field label
                let font = UIFont.systemFont(ofSize: labelTextSize, weight: .regular)
                CustomText(text: label, color: accent, width: "Tests".width(usingFont: font)+10, bold: bold, textSize: labelTextSize)
                
                //make the text field however much room is left
                let fieldWidth = max(0, width - label.width(usingFont: font))
                CustomTextField(bg: bg, accent: accent, placeholder: " ", text: $textValue, width: fieldWidth , height: height, textSize: fieldTextSize, botPad: 0)
            }
            .overlay(
                HStack {
                    Spacer()
                    //button to activate date picker
                    Button(action: {
                        withAnimation { showDatePicker.toggle() }
                    }) {
                        Image(systemName: "calendar")
                            .foregroundColor(Color(hex: bg))
                            .font(.system(size: fieldTextSize * 1.2))
                            .padding(.trailing, 15)
                    }
                }
            )
            .buttonStyle(PlainButtonStyle())
            
            if showDatePicker {
                //custom date picker
                    CustomCalendarView( selectedDate: $date, isPresented: $showDatePicker, bg: bg, accent: accent, width: width)
                        .frame(width: width)
                        .background(Color(hex: accent))
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                        .colorScheme(Color.isHexDark(accent) ? .dark : .light)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .onChange(of: date) {
                            textValue = formatter.string(from: date)
                            withAnimation { showDatePicker = false }
                        }
                        .padding(.top, 8)
                        .zIndex(1000)
            }
        }
    }
}

// Custom date picker
struct CustomCalendarView: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    let bg: String
    let accent: String
    let width: CGFloat
    
    @State private var currentMonth: Date = Date()
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    // Calculate proportional spacing based on width
    private var spacing: CGFloat { width * 0.02 }
    private var cellHeight: CGFloat { (width - (spacing * 8)) / 7 }
    
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    
    //get the number of days in the current month
    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        var days: [Date?] = []
        var date = monthFirstWeek.start
        
        //get all the days for the month
        while date < monthInterval.end {
            if calendar.isDate(date, equalTo: currentMonth, toGranularity: .month) {
                days.append(date)
            } else {
                days.append(nil)
            }
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        
        // complete the last week
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
    
    var body: some View {
        VStack(spacing: spacing) {
            HStack {
                //go back a month
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color(hex: bg))
                        .font(.system(size: width * 0.05, weight: .semibold))
                        .frame(width: width * 0.12, height: width * 0.12)
                        .background(Color(hex: accent))
                }
                
                //current month
                let month = monthYearFormatter.string(from: currentMonth)
                let font = UIFont.systemFont(ofSize: width * 0.07, weight: .regular)
                CustomText(text: month, color: bg, width: month.width(usingFont: font), textSize: width * 0.07)
                
                //go forward a month
                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color(hex: bg))
                        .font(.system(size: width * 0.05, weight: .semibold))
                        .frame(width: width * 0.12, height: width * 0.12)
                        .background(Color(hex: accent))
                }
            }
            .padding(.horizontal, width * 0.02)
            .padding(.top, width * 0.02)
            
            // Days of week bar
            HStack(spacing: 0) {
                ForEach(daysOfWeek, id: \.self) { day in
                    CustomText(text: day, color: bg, textAlign:.center, textSize: width * 0.045)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, width * 0.02)
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: 7), spacing: spacing) {
                ForEach(0..<daysInMonth.count, id: \.self) { index in
                    if let date = daysInMonth[index] {
                        //make a cell for each date
                        PickerDayCell(date: date, isSelected: calendar.isDate(date, inSameDayAs: selectedDate), isToday: calendar.isDateInToday(date), isFutureDate: date > Date(), bg: bg,  accent: accent, width: width, cellHeight: cellHeight ) {
                            selectedDate = date
                        }
                    } else {
                        //empty space for incomplete week
                        Rectangle()
                            .fill(Color(hex: accent))
                            .frame(height: cellHeight)
                    }
                }
            }
            .padding(.horizontal, width * 0.02)
            .padding(.bottom, width * 0.03)
        }
        .background(Color(hex: accent))
        .onAppear {
            currentMonth = selectedDate
        }
    }
    
    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            withAnimation {
                currentMonth = newMonth
            }
        }
    }
}

// Day cell for date picker
struct PickerDayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isFutureDate: Bool
    let bg: String
    let accent: String
    let width: CGFloat
    let cellHeight: CGFloat
    let action: () -> Void
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        Button(action: {
            if !isFutureDate {
                action()
            }
        }) {
            ZStack {
                //buble around selected date
                if isSelected {
                    RoundedRectangle(cornerRadius: width * 0.08)
                        .fill(Color(hex: bg))
                } else {
                    RoundedRectangle(cornerRadius: width * 0.04)
                        .fill(Color(hex: accent))
                }
                
                //bold date number if it is the current day
                CustomText(text: dayNumber, color: isSelected ? accent : bg, textAlign: .center, bold: isToday ? true : isSelected ? true : false, textSize: width * 0.06)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(isFutureDate ? 0.7 : 1.0)
            }
            .frame(height: cellHeight)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isFutureDate)
    }
}

//checkbox with label next to it
struct SingleCheckbox: View {
    var text: String
    var color: String
    @Binding var isOn: Bool
    var textSize: CGFloat = 24

    var body: some View {
        //clickable to toggle isOn
        Button {
            isOn.toggle()
        } label: {
            HStack {
                //lable
                let font = UIFont.systemFont(ofSize: textSize, weight: .bold)
                CustomText(text: text, color: color,width: text.width(usingFont: font) + 15, textAlign: .center, bold: true, textSize: textSize)
                    .padding(.trailing, 15)
                
                //box icon, different depending in isOn
                Image(systemName: isOn ? "checkmark.square.fill" : "square")
                    .resizable()
                    .frame(width: textSize, height: textSize)
                    .foregroundColor(Color(hex: color))
                
                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width)
        }
        .buttonStyle(.plain)
        .frame(width: UIScreen.main.bounds.width)
    }
}

//numerical slider
struct Slider: View {
    @Binding var value: Int64
    let range: ClosedRange<Int64>
    let step: Int
    var color: String
    var width: CGFloat

    //get increments from start to end of range
    private var steps: [Int64] {
        stride(from: range.lowerBound, through: range.upperBound, by: step).map {$0}}
    
    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geo in
                let trackWidth = geo.size.width
                let margin: CGFloat = 14
                let usableWidth = trackWidth - 2 * margin
                let spacing = usableWidth / CGFloat(steps.count - 1)
                let index = steps.firstIndex(of: value) ?? 0

                ZStack(alignment: .leading) {
                    //shows unused part
                    Rectangle()
                        .fill(Color(hex: color).opacity(0.3))
                        .frame(width: usableWidth + 2 * margin, height: 4)
                        .position(x: trackWidth / 2, y: geo.size.height / 2)

                    //shows used part
                    Rectangle()
                        .fill(Color(hex: color))
                        .frame(width: CGFloat(index) * spacing, height: 4)
                        .position(x: margin + CGFloat(index) * spacing / 2, y: geo.size.height / 2)

                    //tick marks
                    ForEach(0..<steps.count, id: \.self) { i in
                        Rectangle()
                            .fill(Color(hex: color))
                            .frame(width: 2, height: 14)
                            .position(x: margin + CGFloat(i) * spacing, y: geo.size.height / 2)
                    }

                    //dragable circle
                    Circle()
                        .fill(Color(hex: color))
                        .frame(width: 28, height: 28)
                        .position(x: margin + CGFloat(index) * spacing, y: geo.size.height / 2)
                        .gesture(DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                let clampedX = min(max(gesture.location.x - margin, 0), usableWidth)
                                let nearestIndex = Int(round(clampedX / spacing))
                                let safeIndex = min(max(nearestIndex, 0), steps.count - 1)
                                value = steps[safeIndex] })
                }
            }
            .frame(height: 30)

            //tick labels
            HStack(spacing: 0) {
                ForEach(steps, id: \.self) { stepValue in
                    CustomText(text: "\(Int(stepValue))",  color: color, textAlign: .center,  textSize: 18)
                    .frame(width: width / 10)
                }
            }
            .padding(.horizontal, 10)
        }
        .frame(width: width)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

//multiple options, can only choose one
struct MultipleChoice: View {
    @Binding var options: [String]
    @Binding var selected: String?
    var accent: String
    var width: CGFloat
    var textSize: CGFloat?

    let circleWidth: CGFloat = 20
    let spacing: CGFloat = 20

    var body: some View {
        //split options into rows
        let rows = computeRowsForForm(options: options, textSize: textSize ?? 20, width: width, itemHeight: 20)
        
        VStack(alignment: .leading, spacing: 12) {
            //go through each row
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack(spacing: 20) {
                    //go through each option
                    ForEach(rows[rowIndex], id: \.self) { option in
                        HStack(spacing: 8) {
                           //select indicator
                            Circle()
                                .stroke(Color(hex: accent), lineWidth: 2)
                                .background(Circle()
                                    .fill(selected == option ? Color(hex: accent) : Color.clear))
                                .frame(width: circleWidth, height: circleWidth)
                            
                            //label
                            CustomText(text: option, color: accent, textSize: textSize ?? 20)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .if(option.count <= 15) { view in
                                    view.fixedSize(horizontal: true, vertical: false)
                                }
                        }
                        .contentShape(Rectangle())
                        //when clicked, make it selected
                        .onTapGesture {
                            selected = option
                        }
                    }
                }
                .frame(maxWidth: width, alignment: .leading)
            }
        }
        .frame(width: width, alignment: .leading)
        .padding(.leading, 2)
        .onAppear {
            //auto select if theres only one option
            if options.count == 1 {
                selected = options[0]
            }
        }
    }
}

// Helper extension for conditional view modifier
extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

//dropdown option picker for choosing color theme
struct ThemeDropdown: View {
    @Binding var theme: String
    @Binding var bg: String
    @Binding var accent: String
    var options: [String]
    var width: CGFloat
    var height: CGFloat
    var corner: CGFloat
    var fontSize: CGFloat
    
    var body: some View {
        Menu {
            //chang the value of theme
            Picker(selection: $theme, label: EmptyView()) {
                ForEach(options, id: \.self) { theme in
                    Text(theme)
                        .padding(.leading, 5)
                }
            }
        } label: {
            HStack {
                //display currently selected
                Text(theme)
                    .font(.system(size: fontSize, design: .serif))
                    .padding(.leading, 5)
                Spacer()
                //dropdown indicator
                Image(systemName: "chevron.down")
                    .font(.system(size: 16, weight: .semibold))
                    .padding(.trailing, 20)
            }
            .padding(.leading, 10)
            .frame(width: width, height: height, alignment: .leading)
            .background( RoundedRectangle(cornerRadius: corner)
                    .fill(Color(hex: accent)))
            .foregroundColor(Color(hex: bg))
        }
        //immediately update values
        .onChange(of: theme) {
            let colors = Database.getThemeColors(theme: theme, currentBackground: bg, currentAccent: accent)
            bg = colors.background
            accent = colors.accent
        }
        .buttonStyle(.plain)
        .padding(.bottom, 20)
    }
}

//multiple options, can select multiple
struct MultipleCheckboxWrapped: View {
    @Binding var options: [String]
    @Binding var selected: [String]
    var accent: String
    var bg: String
    var width: CGFloat
    var itemHeight: CGFloat = 20
    var textSize: CGFloat = 14
    
    var body: some View {
        //split options into rows
        let rows = computeRowsForForm(options: options, textSize: textSize, width: width, itemHeight: itemHeight)
        
        VStack(alignment: .leading, spacing: 8) {
            //go through each row
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack(spacing: 8) {
                    //go through each option in that row
                    ForEach(rows[rowIndex], id: \.self) { option in
                        HStack(spacing: 4) {
                            ZStack {
                                //checkbox
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color(hex: bg), lineWidth: 2)
                                    .background(RoundedRectangle(cornerRadius: 4)
                                            .fill(selected.contains(option) ? Color(hex: bg) : Color.clear))
                                    .frame(width: itemHeight, height: itemHeight)
                                
                                //filled selected checkbox with mark
                                if selected.contains(option) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color(hex: accent))
                                        .font(.system(size: itemHeight * 0.6, weight: .bold))
                                }
                            }
                            
                            //checkbox label
                            CustomText( text: option, color: bg, textSize: textSize)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .if(option.count <= 15) { view in
                                view.fixedSize(horizontal: true, vertical: false)
                            }
                            .padding(.leading, 4)
                        }
                        .contentShape(Rectangle())
                        //on tap mark as selected
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                if let index = selected.firstIndex(of: option) {
                                    selected.remove(at: index)
                                } else {
                                    selected.append(option)
                                }
                            }
                        }
                        .padding(.vertical, 2)
                        .padding(.horizontal, 4)
                    }
                }
                .frame(maxWidth: width, alignment: .leading)
            }
        }
        .frame(width: width, alignment: .leading)
    }
}
